{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië and Merlijn Wajer

    MML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MML.  If not, see <http://www.gnu.org/licenses/>.

	See the file COPYING, included in this distribution,
	for details about the copyright.

           Input/Output manager for Mufasa Macro Library
}

{$mode objfpc}{$H+}
unit IOManager;

interface

  uses
    Classes, SysUtils, mufasatypes, graphics, LCLType, bitmaps, LCLIntf, libloader, dynlibs;

  type    

    { This is the base class for the target functionality. If it provides a target, it extends this.  
    | Some methods in heregratuitous provide default functionality as a convinence. Only override as nessessary }

    { TTarget }

    TTarget = class(TObject)
      public
        
        { ONLY override some of the following methods if the target provides image functions, defaults 
        | to raise exceptions. GetColor provides default functionality using ReturData of width 1.     
        | FreeReturnData provides default of doing nothing. }
        procedure GetTargetDimensions(out w, h: integer); virtual;
        procedure GetTargetPosition(out left, top: integer); virtual;
        function GetColor(x,y : integer) : TColor; virtual;
        function ReturnData(xs, ys, width, height: Integer): TRetData; virtual;
        procedure FreeReturnData; virtual;
        procedure ActivateClient; virtual;
        function TargetValid: boolean; virtual;

        function MouseSetClientArea(x1, y1, x2, y2: integer): boolean; virtual;
        procedure MouseResetClientArea; virtual;
        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean; virtual;
        procedure ImageResetClientArea; virtual;

        { Sucky implementation }
        function  GetError: String; virtual;
        function  ReceivedError: Boolean; virtual;
        procedure ResetError; virtual;

        procedure GetMousePosition(out x,y: integer); virtual;
        procedure MoveMouse(x,y: integer); virtual;
        procedure ScrollMouse(x,y : integer; Lines : integer); virtual;
        procedure HoldMouse(x,y: integer; button: TClickType); virtual;
        procedure ReleaseMouse(x,y: integer; button: TClickType); virtual;
        function  IsMouseButtonHeld( button : TClickType) : boolean ; virtual;

        { ONLY override the following methods if the target provides key functions, defaults to 
        | raise exceptions }
        procedure SendString(str: string; keywait, keymodwait: integer); virtual;
        procedure HoldKey(key: integer); virtual;
        procedure ReleaseKey(key: integer); virtual;
        function IsKeyHeld(key: integer): boolean; virtual;
        function GetKeyCode(C : char) : integer; virtual;

        function GetHandle(): PtrUInt; virtual;
    end;
   
    { Implements a target that is a raw pixel array, e.g. stuff from a bitmap or a frozen state.
    | Currently this uses the pointer as-is, but it might be needed to make a local copy... }
    TRawTarget = class(TTarget)
      public
        constructor Create(rgb: prgb32; w,h: integer; CopyData : boolean = false);
        destructor Destroy; override;
        
        procedure GetTargetDimensions(out w, h: integer); override;
        procedure GetTargetPosition(out left, top: integer); override;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override;

        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean; override;
        procedure ImageResetClientArea; override;

      protected
        rgb: prgb32;
        freedata : boolean;
        w,h: integer;
      private
        ax1, ay1, ax2, ay2: integer;
        caset: boolean;
    end;

    TBitmapTarget = class(TTarget)
      public
        constructor Create(bitmap: TMufasaBitmap);
        destructor Destroy; override;

        procedure GetTargetDimensions(out w, h: integer); override;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override;

        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean; override;
        procedure ImageResetClientArea; override;
      protected
        bitmap: TMufasaBitmap;
      private
        ax1, ay1, ax2, ay2: integer;
        caset: boolean;
    end;
      
   { Implements a target that is a Window in the operating system. This class is abstract, i.e.,
   | the actual os-specific Implementation of TWindow is in one of the os units. }

    { TWindow_Abstract }

    TWindow_Abstract = class(TTarget)
      public
        procedure GetTargetDimensions(out w, h: integer); override; abstract;
        procedure GetTargetPosition(out left, top: integer); override; abstract;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override; abstract;

        function TargetValid: boolean; override; abstract;

        function  GetError: String; override; abstract;
        function  ReceivedError: Boolean; override; abstract;
        procedure ResetError; override; abstract;

        function MouseSetClientArea(x1, y1, x2, y2: integer): boolean; override; abstract;
        procedure MouseResetClientArea; override; abstract;
        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean; override; abstract;
        procedure ImageResetClientArea; override; abstract;

        procedure ActivateClient; override; abstract;
        procedure GetMousePosition(out x,y: integer); override; abstract;
        procedure MoveMouse(x,y: integer); override; abstract;
        procedure ScrollMouse(x,y : integer; Lines : integer); override; abstract;
        procedure HoldMouse(x,y: integer; button: TClickType); override; abstract;
        procedure ReleaseMouse(x,y: integer; button: TClickType); override; abstract;
        function  IsMouseButtonHeld( button : TClickType) : boolean;override; abstract;

        procedure SendString(str: string; keywait, keymodwait: integer); override; abstract;
        procedure HoldKey(key: integer); override; abstract;
        procedure ReleaseKey(key: integer); override; abstract;
        function IsKeyHeld(key: integer): boolean; override; abstract;
        function GetKeyCode(C : char) : integer; override; abstract;
    end;
        
    { Contains the pointers to a non-internal target implementation using the EIOS specification.
    | N.B. this *is* the specification that I will finalize the speficication as... Once this is
    | finalized that is. Trust me, its >9000 times easier to use a buffer across the language
    | barrier. And the internal target implementation of EIOS will make that verry efficient. }
    TEIOS_Client = record
      RequestTarget: function(initdata: PChar): pointer; stdcall;
      ReleaseTarget: procedure(target: pointer); stdcall;

      GetTargetDimensions: procedure(target: pointer; var w, h: integer); stdcall;
      GetTargetPosition: procedure(var left, top: integer); stdcall;
      GetImageBuffer: function(target: pointer): prgb32; stdcall;
      UpdateImageBuffer: procedure(target: pointer); stdcall;
      UpdateImageBufferBounds: procedure(target: pointer; sx,sy,ex,ey: integer); stdcall;

      GetMousePosition: procedure(target: pointer; var x,y: integer); stdcall;
      MoveMouse: procedure(target: pointer; x,y: integer); stdcall;
      ScrollMouse: procedure(target : pointer; x,y : integer; lines : integer); stdcall;
      HoldMouse: procedure(target: pointer; x,y: integer; button: integer); stdcall;
      ReleaseMouse: procedure(target: pointer; x,y: integer; button: integer); stdcall;
      IsMouseButtonHeld : function  (target : pointer; button: integer): boolean; stdcall;

      SendString: procedure(target: pointer; str: PChar; keywait, keymodwait: integer); stdcall;
      HoldKey: procedure(target: pointer; key: integer); stdcall;
      ReleaseKey: procedure(target: pointer; key: integer); stdcall;
      IsKeyHeld: function(target: pointer; key: integer): boolean; stdcall;
      GetKeyCode : function(target : pointer; C : char) : integer; stdcall;
    end;
    
    { Implements a EIOS target. This is, for all intensive purposes, a TRawTarget with added
    | key and mouse methods, as well as the capability to request a buffer update. N.B. that 
    | some EIOS implementors can and will update the buffer on their own. In that case, the
    | UpdateImageBuffer call is just a call to an empty method, OR does not exist. In the case
    | of an EIOS client not needing a method defined, it will not be exported and will be set
    | to NIL here. I think. Will get back to that. }

    { TEIOS_Target }

    TEIOS_Target = class(TTarget)
      public
        constructor Create(client: TEIOS_Client; initval: String);
        destructor Destroy; override;

        function MouseSetClientArea(x1, y1, x2, y2: integer): boolean; override;
        procedure MouseResetClientArea; override;
        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean; override;
        procedure ImageResetClientArea; override;

        procedure GetTargetDimensions(out w, h: integer); override;
        procedure GetTargetPosition(out left, top: integer); override;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override;

        procedure GetMousePosition(out x,y: integer); override;
        procedure MoveMouse(x,y: integer); override;
        procedure ScrollMouse(x,y : integer; Lines : integer); override;
        procedure HoldMouse(x,y: integer; button: TClickType); override;
        procedure ReleaseMouse(x,y: integer; button: TClickType); override;
        function  IsMouseButtonHeld( button : TClickType) : boolean;override;

        procedure SendString(str: string; keywait, keymodwait: integer); override;
        procedure HoldKey(key: integer); override;
        procedure ReleaseKey(key: integer); override;
        function IsKeyHeld(key: integer): boolean; override;
        function GetKeyCode(C : char) : integer; override;
        function GetHandle(): PtrUInt; override;    
        
      private
        client: TEIOS_Client;
        target: pointer;
        buffer: prgb32;
        width,height: integer;

        { (Forced) Client Area }
        mx1, my1, mx2, my2: integer;
        ix1, iy1, ix2, iy2: integer;
        mcaset, icaset: Boolean;

        procedure MouseApplyAreaOffset(var x, y: integer);
        procedure ImageApplyAreaOffset(var x, y: integer);
    end;

    { This is just a class that loads EIOS clients (like SMART) and sets them up to be used
    | as targets. I hope to have a method like... 
    | function SetTarget(eios_name: pchar; init_args: variant): integer;
    | where the init_args variant will be implied to be anything that can be cast to a pointer
    | in the binary side after it gets out of PascalScript. So, the only thing to setup SMART
    | would be the single call....
    | SetTarget('SMART',SmartSetupRecord);
    | Sexy, right? ;}
    TEIOS_Controller = class(TGenericLoader)
      public
        constructor Create();
        destructor Destroy; override;

        function ClientExists(name: string): boolean;
        function GetClient(name: string): TEIOS_Client;

      protected
        function InitPlugin(plugin: TLibHandle): boolean; override;
      private
        clients: array of TEIOS_Client;
        function FindClient(name: string): integer;
    end;

    {Basically like TEIOS_Client, only this is exported to some plugin, whilst TEIOS_Client is Imported
     Not all functions have to be 'set', it depends on the kind of target (Image/KeyMouse) }
    TTarget_Exported = record
      Target : Pointer;

      GetTargetDimensions: procedure(target: pointer; var w, h: integer); stdcall;
      GetTargetPosition: procedure(target: pointer; var top, left: integer); stdcall;
      GetColor : function(target: pointer;x,y : integer) : integer; stdcall;
      ReturnData : function(target: pointer;xs, ys, width, height: Integer): TRetData; stdcall;
      FreeReturnData : procedure(target: pointer); stdcall;

      GetMousePosition: procedure(target: pointer; var x,y: integer); stdcall;
      MoveMouse: procedure(target: pointer; x,y: integer); stdcall;
      ScrollMouse: procedure(target: pointer; x,y : integer; Lines : integer); stdcall;
      HoldMouse: procedure(target: pointer; x,y: integer; left: boolean); stdcall;
      ReleaseMouse: procedure(target: pointer; x,y: integer; left: boolean); stdcall;
      IsMouseButtonHeld : function  (target : pointer; left : boolean) : boolean;stdcall;

      SendString: procedure(target: pointer; str: PChar; keywait, keymodwait: integer); stdcall;
      HoldKey: procedure(target: pointer; key: integer); stdcall;
      ReleaseKey: procedure(target: pointer; key: integer); stdcall;
      IsKeyHeld: function(target: pointer; key: integer): boolean; stdcall;
      GetKeyCode : function(target : pointer; C : char) : integer; stdcall;
    end;

    { This class specifies the object that will go in the ThreadVar to give the script access
    | to targets. This class is abstract, i.e., the actual os-specific Implementation of 
    | TIOManager is in one of the os units. 
    | I assume you Simba people know what the methods you made do, and I'm mantaining 
    | Name -> Function compatibility from the TWindow and TMInput classes (e.g. key, image, 
    | and window functions). I decided to split targeting into input/output == image/keymouse, 
    | since they sometimes are treated as seperate entities. }

    { TIOManager_Abstract }

    TIOManager_Abstract = class(TObject)
      public
        constructor Create;
        constructor Create(plugin_dir: string);
        destructor Destroy; override;

        { Sucky implementation }
        function  GetError: String;
        function  ReceivedError: Boolean;
        procedure ResetError;
        
        procedure SetDesktop; virtual; abstract;
        function SetTarget(ArrPtr: PRGB32; Size: TPoint): integer; overload;
        function SetTarget(bmp : TMufasaBitmap) : integer; overload;
        function SetTarget(name, initargs: string): integer; overload;
        function TargetValid: Boolean;
        procedure BitmapDestroyed(Bitmap : TMufasaBitmap);

        function GetColor(x,y : integer) : TColor;
        function ReturnData(xs, ys, width, height: Integer): TRetData;
        procedure FreeReturnData;

        procedure GetDimensions(out W, H: Integer);
        procedure GetPosition(var Left, Top: Integer);
        procedure ActivateClient;

        function IsFrozen: boolean;
        procedure SetFrozen(makefrozen: boolean);

        function MouseSetClientArea(x1, y1, x2, y2: integer): boolean;
        procedure MouseResetClientArea;
        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
        procedure ImageResetClientArea;

        procedure GetMousePos(var X, Y: Integer);
        procedure MoveMouse(X, Y: Integer);
        procedure ScrollMouse(x,y : integer; Lines : integer);
        procedure HoldMouse(x,y : integer; button: TClickType);
        procedure ReleaseMouse(x,y : integer; button: TClickType);
        procedure ClickMouse(X, Y: Integer; button: TClickType);
        function  IsMouseButtonDown( button : TClickType) : boolean;

        procedure KeyUp(key: Word);
        procedure KeyDown(key: Word);
        procedure PressKey(key: Word);
        procedure SendText(text: string; keywait, keymodwait: integer);
        function isKeyDown(key: Word): Boolean;
        function GetKeyCode(c : char) : integer;

        function GetImageTarget: TTarget; overload;
        function GetKeyMouseTarget: TTarget; overload;
        function ExportImageTarget  : TTarget_Exported; overload;
        function ExportKeyMouseTarget  : TTarget_Exported; overload;

        procedure GetImageTarget(var idx: integer); overload;
        procedure GetKeyMouseTarget(var idx: integer); overload;
        procedure SetImageTarget(idx: integer);
        procedure SetKeyMouseTarget(idx: integer);
        procedure FreeTarget(idx: integer);
        procedure SetState(val: Boolean);
        
        function GetProcesses: TSysProcArr; virtual; abstract;
        function GetProcessMem(processID: LongInt): Int64; virtual; abstract;
        procedure SetTargetEx(Proc: TSysProc); virtual; abstract;
      protected
        function SetImageTarget(target: TTarget): integer;
        function SetKeyMouseTarget(target: TTarget): integer;
        function SetBothTargets(target: TTarget): integer;
        procedure NativeInit; virtual; abstract;
        procedure NativeFree; virtual; abstract;

      private
        keymouse: TTarget;
        image: TTarget;
        frozen: TTarget;
        freezebuffer: prgb32;
        bothsame: boolean;
        FStopping: Boolean;

        idxarr: array of TTarget;

        function GetTargetIdx(target: TTarget): integer;
        function GetIdxTarget(idx: integer): TTarget;
      property Stopping: Boolean Read FStopping write SetState;
    end;

    {These wrappers are for an exported TTarget_Exported. This is done so a plugin can acces the current target and use its methodes}
    procedure TTarget_Exported_GetTargetDimensions(target: pointer; var w, h: integer); stdcall;
    procedure TTarget_Exported_GetTargetPosition(target: pointer; var left, top: integer); stdcall;
    function TTarget_Exported_GetColor (target: pointer;x,y : integer) : integer; stdcall;
    function TTarget_Exported_ReturnData (target: pointer;xs, ys, width, height: Integer): TRetData; stdcall;
    procedure TTarget_Exported_FreeReturnData(target: pointer); stdcall;

    procedure TTarget_Exported_GetMousePosition(target: pointer; var x,y: integer); stdcall;
    procedure TTarget_Exported_MoveMouse(target: pointer; x,y: integer); stdcall;
    procedure TTarget_Exported_ScrollMouse(target: pointer; x,y : integer; Lines : integer); stdcall;
    procedure TTarget_Exported_HoldMouse(target: pointer; x,y: integer; left: boolean); stdcall;
    procedure TTarget_Exported_ReleaseMouse(target: pointer; x,y: integer; left: boolean); stdcall;
    function TTarget_Exported_IsMouseButtonHeld(target: pointer; left : boolean) : boolean;stdcall;

    procedure TTarget_Exported_SendString(target: pointer; str: PChar; keywait, keymodwait: integer); stdcall;
    procedure TTarget_Exported_HoldKey(target: pointer; key: integer); stdcall;
    procedure TTarget_Exported_ReleaseKey(target: pointer; key: integer); stdcall;
    function  TTarget_Exported_IsKeyHeld(target: pointer; key: integer): boolean; stdcall;
    function  TTarget_Exported_GetKeyCode(target : pointer; C : char) : integer; stdcall;

implementation

  uses FileUtil,
    {$IFDEF MSWINDOWS} os_windows {$ENDIF}
    {$IFDEF LINUX} os_linux {$ENDIF};

  var eios_controller: TEIOS_Controller;


//***implementation*** TIOManager

constructor TIOManager_Abstract.Create(plugin_dir: string);
begin
  inherited Create;
  SetLength(idxarr,0);
  eios_controller.AddPath(plugin_dir);
  keymouse:= nil;
  image:= nil;
  frozen:= nil;
  FStopping:=False;
  NativeInit;
  SetDesktop;
end;

constructor TIOManager_Abstract.Create;
begin
  inherited Create;
  keymouse:= nil;
  image:= nil;
  frozen:= nil;
  NativeInit;
  SetDesktop;
end;

destructor TIOManager_Abstract.Destroy;
var
  i: integer;
begin
  for i:= high(idxarr) downto 0 do
    idxarr[i].Free;
end;

procedure TIOManager_Abstract.FreeTarget(idx: integer);
begin
  if idx > high(idxarr) then
    raise Exception.Create('Invalid target index');
  if idxarr[idx] = nil then
    raise Exception.Create('Double free of target');
  idxarr[idx].Free;
  idxarr[idx]:= nil;
end;

function TIOManager_Abstract.GetTargetIdx(target: TTarget): integer;
var
  i: integer;
begin
  result:= -1;
  for i:= 0 to high(idxarr) do
  begin
    if idxarr[i] = target then
    begin
      result:= i;
      exit;
    end;
    if (idxarr[i] = nil) and (result = -1) then
      result:= i;
  end;
  if result = -1 then
  begin
    SetLength(idxarr,Length(idxarr) + 1);
    result:= high(idxarr);
  end;
  idxarr[result]:= target;
end;

function TIOManager_Abstract.GetIdxTarget(idx: integer): TTarget;
begin
  if idx > high(idxarr) then
    raise Exception.Create('Invalid target index');
  if idxarr[idx] = nil then
    raise Exception.Create('No target with specified index');
  result:= idxarr[idx];
end;

function TIOManager_Abstract.SetImageTarget(target: TTarget): integer;
begin
  if IsFrozen then
    raise Exception.Create('You cannot set a target when Frozen');
  result:= GetTargetIdx(target);
  image:= target;
end;

function TIOManager_Abstract.GetImageTarget: TTarget;
begin
  result := image;
end;

function TIOManager_Abstract.SetKeyMouseTarget(target: TTarget): integer;
begin
  result:= GetTargetIdx(target);
  keymouse:= target;
end;

function TIOManager_Abstract.GetKeyMouseTarget: TTarget;
begin
  result := keymouse;
end;

function TIOManager_Abstract.ExportImageTarget: TTarget_Exported;
begin
  FillChar(result,sizeof(TTarget_Exported),0);
  with result do
  begin
    Target:= image;
    GetTargetDimensions:= @TTarget_Exported_GetTargetDimensions;
    GetTargetPosition := @TTarget_Exported_GetTargetPosition;
    GetColor:= @TTarget_Exported_GetColor;
    ReturnData := @TTarget_Exported_ReturnData;
    FreeReturnData:= @TTarget_Exported_FreeReturnData;
  end;
end;

function TIOManager_Abstract.ExportKeyMouseTarget: TTarget_Exported;
begin
  FillChar(result,sizeof(TTarget_Exported),0);
  with result do
  begin
    Target:= KeyMouse;
    GetMousePosition := @TTarget_Exported_GetMousePosition;
    MoveMouse := @TTarget_Exported_MoveMouse;
    ScrollMouse:= @TTarget_Exported_ScrollMouse;
    HoldMouse := @TTarget_Exported_HoldMouse;
    ReleaseMouse := @TTarget_Exported_ReleaseMouse;

    SendString := @TTarget_Exported_SendString;
    HoldKey := @TTarget_Exported_HoldKey;
    ReleaseKey := @TTarget_Exported_ReleaseKey;
    IsKeyHeld := @TTarget_Exported_IsKeyHeld;
    GetKeyCode := @TTarget_Exported_GetKeyCode;
  end;
end;

function TIOManager_Abstract.SetBothTargets(target: TTarget): integer;
begin
  if IsFrozen then
    raise Exception.Create('You cannot set a target when Frozen');
  result:= GetTargetIdx(target);
  image:= target;
  keymouse:= target;
end;

procedure TIOManager_Abstract.SetFrozen(makefrozen: boolean);
var
  w,h: integer;
  buffer: TRetData;
begin
  if (makefrozen) and (IsFrozen) then
    raise Exception.Create('The window is already frozen.');
  if makefrozen then //No need for the Frozen = nil check, already done above with the exception.
  begin
    frozen:= image;
    frozen.GetTargetDimensions(w,h);
    buffer:= frozen.ReturnData(0,0,w,h);
    image:= TRawTarget.Create(buffer.Ptr,w,h,true);
    frozen.FreeReturnData;
  end else
  begin
    if not IsFrozen() then
      raise Exception.Create('Unfreeze called when the window is not frozen.')
    else
    begin
      image.Free();
      image:= frozen;
      frozen:= nil;
    end;
  end;
end;

function TIOManager_Abstract.IsFrozen: boolean;
begin
  result:= frozen <> nil;
end;

function TIOManager_Abstract.GetColor(x,y : integer) : TColor;
begin
  result:= image.GetColor(x,y);
end;

function TIOManager_Abstract.ReturnData(xs,ys,width,height: integer): TRetData;
begin
  result:= image.ReturnData(xs,ys,width,height);
end;

procedure TIOManager_Abstract.FreeReturnData;
begin
  image.freeReturnData();
end;

function TIOManager_Abstract.SetTarget(ArrPtr: PRGB32; Size: TPoint): integer;
begin
  result:= SetImageTarget(TRawTarget.Create(ArrPtr,Size.X,Size.Y));
end;

//Only checks the current image target, not targets that might be in the indexes...
procedure TIOManager_Abstract.BitmapDestroyed(Bitmap : TMufasaBitmap);
begin
  if image is TBitmapTarget then
    if (TBitmapTarget(image).bitmap = Bitmap) and (not FStopping) then
      raise Exception.Create('Target bitmap was destroyed!');
end;

function TIOManager_Abstract.SetTarget(bmp : TMufasaBitmap) : integer;
begin
  result:= SetImageTarget(TBitmapTarget.Create(bmp));
  bmp.OnDestroy:= @BitmapDestroyed;
end;

function TIOManager_Abstract.SetTarget(name, initargs: String): integer;
var
  client: TEIOS_Client;
begin
  if not eios_controller.ClientExists(name) then
    raise Exception.Create('EIOS Client by specified name does not exist');
  client:= eios_controller.GetClient(name);
  result:= SetBothTargets(TEIOS_Target.Create(client, initargs));
end;

procedure TIOManager_Abstract.SetImageTarget(idx: integer);
begin
  image:= GetIdxTarget(idx);
end;

procedure TIOManager_Abstract.SetKeyMouseTarget(idx: integer);
begin
  keymouse:= GetIdxTarget(idx);
end;

procedure TIOManager_Abstract.GetImageTarget(var idx: integer);
begin
  if IsFrozen then
    raise Exception.Create('Cannot get image target while frozen');
  idx:= GetTargetIdx(image);
end;

procedure TIOManager_Abstract.GetKeyMouseTarget(var idx: integer);
begin
  idx:= GetTargetIdx(keymouse);
end;

function TIOManager_Abstract.TargetValid: Boolean;
begin
  result:= false;
  if (keymouse <> nil) and (image <> nil) then
    result := (keymouse.TargetValid and image.TargetValid);
end;

procedure TIOManager_Abstract.GetDimensions(out W, H: Integer);
begin
  image.GetTargetDimensions(w,h)
end;

procedure TIOManager_Abstract.GetPosition(var Left, Top: Integer);
begin
  image.GetTargetPosition(Left, Top);
end;

procedure TIOManager_Abstract.ActivateClient; 
begin 
  keymouse.ActivateClient(); 
  {not sure if image needs activation or not, if its a native window keymouse == image so it should be good.}
end;

function TIOManager_Abstract.MouseSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  Result := keymouse.MouseSetClientArea(x1, y1, x2, y2);
end;
procedure TIOManager_Abstract.MouseResetClientArea;
begin
  keymouse.MouseResetClientArea;
end;
function TIOManager_Abstract.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  Result := image.ImageSetClientArea(x1, y1, x2, y2);
end;
procedure TIOManager_Abstract.ImageResetClientArea;
begin
  image.ImageResetClientArea;
end;

procedure TIOManager_Abstract.GetMousePos(var X, Y: Integer);
begin
  keymouse.GetMousePosition(x,y)
end;

procedure TIOManager_Abstract.MoveMouse(X, Y: Integer);
begin
  keymouse.MoveMouse(x,y);
end;

procedure TIOManager_Abstract.ScrollMouse(x, y: integer; Lines: integer);
begin
  keymouse.ScrollMouse(x,y,lines);
end;

procedure TIOManager_Abstract.HoldMouse(x,y : integer; button: TClickType);
begin
  keymouse.HoldMouse(x,y,button);
end;
procedure TIOManager_Abstract.ReleaseMouse(x,y : integer; button: TClickType);
begin
  keymouse.ReleaseMouse(x,y,button);
end;

procedure TIOManager_Abstract.ClickMouse(X, Y: Integer; button: TClickType);
begin
  HoldMouse(x,y,button);
  //BenLand100 note: probably should wait here
  ReleaseMouse(x,y,button);
end;

function TIOManager_Abstract.IsMouseButtonDown(button: TClickType): boolean;
begin
  result := keymouse.IsMouseButtonHeld(button);
end;

procedure TIOManager_Abstract.KeyUp(key: Word);
begin
  keymouse.ReleaseKey(key)
end;
procedure TIOManager_Abstract.KeyDown(key: Word);
begin
  keymouse.HoldKey(key)
end;
procedure TIOManager_Abstract.PressKey(key: Word);
begin
  keyup(key);
  keydown(key);
end;
procedure TIOManager_Abstract.SendText(text: string; keywait, keymodwait: integer);
begin
  keymouse.SendString(text, keywait, keymodwait);
end;

function TIOManager_Abstract.isKeyDown(key: Word): Boolean;
begin
  result:= keymouse.IsKeyHeld(key);
end;

function TIOManager_Abstract.GetKeyCode(c: char): integer;
begin
  result := keymouse.GetKeyCode(c);
end;

function TIOManager_Abstract.GetError: String;
begin
  if keymouse.ReceivedError then
    exit(keymouse.GetError);
  if image.ReceivedError then
    exit(image.GetError);
  raise Exception.Create('TIOManager_Abstract.GetError: NO ERROR!');
  exit('');
end;

function TIOManager_Abstract.ReceivedError: Boolean;
begin
  exit(keymouse.ReceivedError or image.ReceivedError);
end;

procedure TIOManager_Abstract.ResetError;
begin
  keymouse.ResetError;
  image.ResetError;
end;

// TRUE when STOPPING.
procedure TIOManager_Abstract.SetState(val: Boolean);
begin
  FStopping := val;
end;

//***implementation*** TTarget

procedure TTarget.GetTargetDimensions(out w, h: integer);
begin
  raise Exception.Create('GetTargetDimensions not available for this target');
end;

procedure TTarget.GetTargetPosition(out left, top: integer);
begin
  raise Exception.Create('GetTargetDimensions not available for this target');
end;

function TTarget.GetColor(x,y : integer) : TColor;
begin
  with ReturnData(x,y,1,1) do
    Result := RGBToColor(Ptr[0].r,Ptr[0].g,Ptr[0].b);
  FreeReturnData;
end;
function TTarget.ReturnData(xs, ys, width, height: Integer): TRetData;
begin
  raise Exception.Create('ReturnData not available for this target');
end;
procedure TTarget.FreeReturnData;
begin
  {do nothing by default}
end;
procedure TTarget.ActivateClient;
begin
  raise Exception.Create('ActivateClient not available for this target');
end;
function TTarget.TargetValid: boolean;
begin
  result:= true;
end;
function TTarget.MouseSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  raise Exception.Create('MouseSetClientArea not available for this target');
end;
procedure TTarget.MouseResetClientArea;
begin
  raise Exception.Create('MouseResetClientArea not available for this target');
end;
function TTarget.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  raise Exception.Create('ImageSetClientArea not available for this target');
end;
procedure TTarget.ImageResetClientArea;
begin
  raise Exception.Create('ImageResetClientArea not available for this target');
end;
function  TTarget.GetError: String;
begin
  raise Exception.Create('GetError not available for this target');
end;
function  TTarget.ReceivedError: Boolean;
begin
  raise Exception.Create('ReceivedError not available for this target');
end;
procedure TTarget.ResetError;
begin
  raise Exception.Create('ResetError not available for this target');
end;
procedure TTarget.GetMousePosition(out x,y: integer);
begin
  raise Exception.Create('GetMousePosition not available for this target');
end;
procedure TTarget.MoveMouse(x,y: integer);
begin
  raise Exception.Create('MoveMouse not available for this target');
end;
procedure TTarget.ScrollMouse(x,y : integer; lines : integer);
begin
  raise Exception.Create('ScrollMouse is not available for this target');
end;
procedure TTarget.HoldMouse(x,y: integer; button: TClickType);
begin
  raise Exception.Create('HoldMouse not available for this target');
end;
procedure TTarget.ReleaseMouse(x,y: integer; button: TClickType);
begin
  raise Exception.Create('ReleaseMouse not available for this target');
end;
function TTarget.IsMouseButtonHeld(button: TClickType): boolean;
begin
  raise Exception.Create('IsMouseButtonHeld not available for this target');
end;

procedure TTarget.SendString(str: string; keywait, keymodwait: integer);
begin
  raise Exception.Create('SendString not available for this target');
end;

procedure TTarget.HoldKey(key: integer);
begin
  raise Exception.Create('HoldKey not available for this target');
end;

procedure TTarget.ReleaseKey(key: integer);
begin
  raise Exception.Create('ReleaseKey not available for this target');
end;

function TTarget.IsKeyHeld(key: integer): boolean;
begin
  raise Exception.Create('IsKeyHeld not available for this target');
end;

function TTarget.GetKeyCode(C: char): integer;
begin
  raise Exception.CreateFMT('GetKeyCode - char (%s) to key is not available for this target.',[c]);
end;

function TTarget.GetHandle(): PtrUInt;
begin
  Result := 0;
  raise Exception.Create('GetHandle not available for this target');
end;

//***implementation*** TEIOS_Target

constructor TEIOS_Target.Create(client: TEIOS_Client; initval: String); begin
  inherited Create;
  self.client:= client;
  self.target:= nil;
  if Pointer(client.RequestTarget) <> nil then
     self.target:= client.RequestTarget(PChar(initval));
  if (self.target = nil) then
    raise Exception.Create('Setting EIOS target failed.');
  if Pointer(client.GetImageBuffer) <> nil then
     self.buffer:= client.GetImageBuffer(target)
  else
     self.buffer:= nil;
  GetTargetDimensions(self.width,self.height);

  self.mx1 := 0; self.my1 := 0; self.mx2 := 0; self.my2 := 0;
  self.mcaset := false;
  self.ix1 := 0; self.iy1 := 0; self.ix2 := 0; self.iy2 := 0;
  self.icaset := false;
end;

destructor TEIOS_Target.Destroy; begin
  if (client.ReleaseTarget <> nil) and (self.target <> nil) then
    client.ReleaseTarget(self.target);
  inherited Destroy;
end;

function TEIOS_Target.MouseSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  if ((x2 - x1) > self.width) or ((y2 - y1) > self.height) then
    exit(False);
  if (x1 < 0) or (y1 < 0) then
    exit(False);

  mx1 := x1; my1 := y1; mx2 := x2; my2 := y2;
  mcaset := True;
end;

procedure TEIOS_Target.MouseResetClientArea;
begin
  mx1 := 0; my1 := 0; mx2 := 0; my2 := 0;
  mcaset := False;
end;

function TEIOS_Target.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  if ((x2 - x1) > self.width) or ((y2 - y1) > self.height) then
    exit(False);
  if (x1 < 0) or (y1 < 0) then
    exit(False);

  ix1 := x1; iy1 := y1; ix2 := x2; iy2 := y2;
  icaset := True;
end;

procedure TEIOS_Target.ImageResetClientArea;
begin
  ix1 := 0; iy1 := 0; ix2 := 0; iy2 := 0;
  icaset := False;
end;

procedure TEIOS_Target.MouseApplyAreaOffset(var x, y: integer);
begin
  if mcaset then
  begin
    x := x + mx1;
    y := y + my1;
  end;
end;

procedure TEIOS_Target.ImageApplyAreaOffset(var x, y: integer);
begin
  if icaset then
  begin
    x := x + ix1;
    y := y + iy1;
  end;
end;

procedure TEIOS_Target.GetTargetDimensions(out w, h: integer);
begin
  if Pointer(client.GetTargetDimensions) <> nil then
  begin
    if icaset then
    begin
      w := ix2 - ix1;
      h := iy2 - iy1;
      exit;
    end;
    client.GetTargetDimensions(target,w,h)
  end else
    inherited GetTargetDimensions(w,h);
end;

procedure TEIOS_Target.GetTargetPosition(out left, top: integer);
begin
  if Pointer(client.GetTargetDimensions) <> nil then
    client.GetTargetDimensions(target,left,top)
  else
    inherited GetTargetDimensions(left,top);
end;

function TEIOS_Target.ReturnData(xs, ys, width, height: Integer): TRetData;
begin
  ImageApplyAreaOffset(xs, ys);
  if Pointer(client.UpdateImageBufferBounds) <> nil then
    client.UpdateImageBufferBounds(target,xs,ys,xs+width,ys+height)
  else if Pointer(client.UpdateImageBuffer) <> nil then
    client.UpdateImageBuffer(target)
  else begin
    {no update command exported}
  end;
  result.Ptr := buffer;
  result.RowLen:= self.width;
  result.IncPtrWith:= result.RowLen - width;
  Inc(result.Ptr, ys * result.RowLen + xs);

  if icaset then
  begin
    Inc(result.IncPtrWith, result.RowLen - (ix2 - ix1));
  end;
end;

procedure TEIOS_Target.GetMousePosition(out x,y: integer);
begin
  if Pointer(client.GetMousePosition) <> nil then
  begin
    client.GetMousePosition(target,x,y);
    x := x - mx1;
    y := y - my1;
  end else
    inherited GetMousePosition(x,y);
end;
procedure TEIOS_Target.MoveMouse(x,y: integer);
begin
  if Pointer(client.MoveMouse) <> nil then
  begin
    MouseApplyAreaOffset(x, y);
    client.MoveMouse(target,x,y)
  end else
    inherited MoveMouse(x,y);
end;
procedure TEIOS_Target.ScrollMouse(x,y : integer; Lines : integer);
begin
  if Pointer(Client.ScrollMouse) <> nil then
  begin
    MouseApplyAreaOffset(x, y);
    client.ScrollMouse(target,x,y,lines)
  end else
    inherited Scrollmouse(x,y,lines);
end;

procedure TEIOS_Target.HoldMouse(x,y: integer; button: TClickType);
begin
  if Pointer(client.HoldMouse) <> nil then
  begin
    MouseApplyAreaOffset(x, y);
    case button of
      mouse_Left:   client.HoldMouse(target,x,y,1);
      mouse_Middle: client.HoldMouse(target,x,y,2);
      mouse_Right:  client.HoldMouse(target,x,y,3);
    end;
  end else
    inherited HoldMouse(x,y,button);
end;
procedure TEIOS_Target.ReleaseMouse(x,y: integer; button: TClickType);
begin
  if Pointer(client.ReleaseMouse) <> nil then
  begin
    MouseApplyAreaOffset(x, y);
    case button of
      mouse_Left:   client.ReleaseMouse(target,x,y,1);
      mouse_Middle: client.ReleaseMouse(target,x,y,2);
      mouse_Right:  client.ReleaseMouse(target,x,y,3);
    end;
  end else
    inherited ReleaseMouse(x,y,button);
end;

function TEIOS_Target.IsMouseButtonHeld(button: TClickType): boolean;
begin
  if Pointer(client.IsMouseButtonHeld) <> nil then
  begin
    case button of
      mouse_Left:  result := client.IsMouseButtonHeld(target,1);
      mouse_Middle: result := client.IsMouseButtonHeld(target,2);
      mouse_Right: result := client.IsMouseButtonHeld(target,3);
    end;
  end else
    result := inherited IsMouseButtonHeld(button);
end;

procedure TEIOS_Target.SendString(str: string; keywait, keymodwait: integer);
begin
  if Pointer(client.SendString) <> nil then
    client.SendString(target,PChar(str), keywait, keymodwait)
  else
    inherited SendString(str, keywait, keymodwait);
end;
procedure TEIOS_Target.HoldKey(key: integer);
begin
  if Pointer(client.HoldKey) <> nil then
    client.HoldKey(target,key)
  else
    inherited HoldKey(key);
end;
procedure TEIOS_Target.ReleaseKey(key: integer);
begin
  if Pointer(client.ReleaseKey) <> nil then
    client.ReleaseKey(target,key)
  else
    inherited ReleaseKey(key);
end;
function TEIOS_Target.IsKeyHeld(key: integer): boolean;
begin
  if Pointer(client.IsKeyHeld) <> nil then
    result:= client.IsKeyHeld(target,key)
  else
    result:= inherited IsKeyHeld(key);
end;

function TEIOS_Target.GetKeyCode(C: char): integer;
begin
  if Pointer(client.GetKeyCode) <> nil then
    result:= client.GetKeyCode(target,C)
  else
    result:= inherited GetKeyCode(C);
end;

function TEIOS_Target.GetHandle(): PtrUInt;
begin
  Result := PtrUInt(Target);
end;

//***implementation*** TRawTarget

constructor TRawTarget.Create(rgb: prgb32; w,h: integer; CopyData : boolean = false);
begin
  inherited Create;
  self.w:= w;
  self.h:= h;
  self.freedata:= copydata;
  if CopyData then
  begin
    GetMem(self.rgb,w*h*sizeof(TRGB32));
    Move(rgb[0],self.rgb[0],w*h*sizeof(TRGB32));
  end else
    self.rgb:= rgb;

  self.ax1 := 0;
  self.ay1 := 0;
  self.ax2 := 0;
  self.ay2 := 0;
  self.caset := false;
end;

destructor TRawTarget.Destroy;
begin
  if freedata then
    Freemem(self.rgb,w*h*sizeof(TRGB32));
  inherited Destroy;
end;

procedure TRawTarget.GetTargetDimensions(out w, h: integer);
begin
  if caset then
  begin
    w := ax2 - ax1;
    h := ay2 - ay1;
    exit;
  end;
  w:= self.w;
  h:= self.h;
end;

procedure TRawTarget.GetTargetPosition(out left, top: integer);
begin
  { The RawTarget has no position on the screen }
  left := 0;
  top := 0;
end;

function TRawTarget.ReturnData(xs, ys, width, height: Integer): TRetData;
begin
  xs := xs + ax1;
  ys := ys + ay1;
  result.Ptr := rgb;
  result.RowLen:= self.w;
  result.IncPtrWith:= result.RowLen - width;
  Inc(result.Ptr, ys * result.RowLen + xs);

  if caset then
  begin
    Inc(result.IncPtrWith, result.RowLen - (ax2 - ax1));
  end;
end;

function TRawTarget.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  if ((x2 - x1) > self.w) or ((y2 - y1) > self.h) then
    exit(False);
  if (x1 < 0) or (y1 < 0) then
    exit(False);

  ax1 := x1; ay1 := y1; ax2 := x2; ay2 := y2;
  caset := True;
end;

procedure TRawTarget.ImageResetClientArea;
begin
  ax1 := 0; ay1 := 0; ax2 := 0; ay2 := 0;
  caset := False;
end;

//***implementation*** TBitmapTarget

constructor TBitmapTarget.Create(bitmap: TMufasaBitmap);
begin
  inherited Create;
  self.bitmap:= bitmap;
end;

destructor TBitmapTarget.Destroy;
begin
  inherited Destroy;
end;

procedure TBitmapTarget.GetTargetDimensions(out w, h: integer);
begin
  if caset then
  begin
    w := ax2 - ax1;
    h := ay2 - ay1;
    exit;
  end;
  h:= bitmap.Height;
  w:= bitmap.Width;
end;

function TBitmapTarget.ReturnData(xs, ys, width, height: Integer): TRetData;
begin
  xs := xs + ax1;
  ys := ys + ay1;
  result.Ptr := bitmap.FData;
  result.RowLen:= bitmap.Width;
  result.IncPtrWith:= result.RowLen - width;
  Inc(result.Ptr, ys * result.RowLen + xs);

  if caset then
  begin
    Inc(result.IncPtrWith, result.RowLen - (ax2 - ax1));
  end;
end;

function TBitmapTarget.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
begin
  if ((x2 - x1) > bitmap.Width) or ((y2 - y1) > bitmap.Height) then
    exit(False);
  if (x1 < 0) or (y1 < 0) then
    exit(False);

  ax1 := x1; ay1 := y1; ax2 := x2; ay2 := y2;
  caset := True;
end;

procedure TBitmapTarget.ImageResetClientArea;
begin
  ax1 := 0; ay1 := 0; ax2 := 0; ay2 := 0;
  caset := False;
end;

//***implementation*** TEIOS_Controller

constructor TEIOS_Controller.Create();
begin
  inherited Create;
end;

destructor TEIOS_Controller.Destroy;
begin
  SetLength(clients,0);
  inherited Destroy;
end;

function TEIOS_Controller.InitPlugin(plugin: TLibHandle): boolean;
var
  idx: integer;
begin
  idx:= Length(clients);
  SetLength(clients,idx+1);
  {link in all eios methods that *might* exist}
  with clients[idx] do
  begin
    Pointer(RequestTarget):= GetProcAddress(plugin, PChar('EIOS_RequestTarget'));
    Pointer(ReleaseTarget):= GetProcAddress(plugin, PChar('EIOS_ReleaseTarget'));

    Pointer(GetTargetDimensions):= GetProcAddress(plugin, PChar('EIOS_GetTargetDimensions'));
    Pointer(GetImageBuffer):= GetProcAddress(plugin, PChar('EIOS_GetImageBuffer'));
    Pointer(UpdateImageBuffer):= GetProcAddress(plugin, PChar('EIOS_UpdateImageBuffer'));
    Pointer(UpdateImageBufferBounds):= GetProcAddress(plugin, PChar('EIOS_UpdateImageBufferBounds'));

    Pointer(GetMousePosition):= GetProcAddress(plugin, PChar('EIOS_GetMousePosition'));
    Pointer(MoveMouse):= GetProcAddress(plugin, PChar('EIOS_MoveMouse'));
    Pointer(ScrollMouse) := GetProcAddress(plugin,PChar('EIOS_ScrollMouse'));
    Pointer(HoldMouse):= GetProcAddress(plugin, PChar('EIOS_HoldMouse'));
    Pointer(ReleaseMouse):= GetProcAddress(plugin, PChar('EIOS_ReleaseMouse'));

    Pointer(SendString):= GetProcAddress(plugin, PChar('EIOS_SendString'));
    Pointer(HoldKey):= GetProcAddress(plugin, PChar('EIOS_HoldKey'));
    Pointer(ReleaseKey):= GetProcAddress(plugin, PChar('EIOS_ReleaseKey'));
    Pointer(IsKeyHeld):= GetProcAddress(plugin, PChar('EIOS_IsKeyHeld'));
  end;
  {done linking in methods}
  result:= true;
end;

function TEIOS_Controller.FindClient(name: string): integer;
var
  i: integer;
begin
  result:= LoadPlugin(name);
end;

function TEIOS_Controller.ClientExists(name: string): boolean;
begin
  result:= FindClient(name) >= 0;
end;

function TEIOS_Controller.GetClient(name: string): TEIOS_Client;
var
  i: integer;
begin
  i:= FindClient(name);
  if i >= 0 then
    result:= clients[i]
end;

//***implementation*** TEIS_Exported wrappers

procedure TTarget_Exported_GetTargetDimensions(target: pointer; var w,
  h: integer); stdcall;
begin
  TTarget(Target).GetTargetDimensions(w,h);
end;

procedure TTarget_Exported_GetTargetPosition(target: pointer; var left,
  top: integer); stdcall;
begin
  TTarget(Target).GetTargetPosition(left,top);
end;

function TTarget_Exported_GetColor(target: pointer;x, y: integer): integer; stdcall;
begin
  result := TTarget(Target).GetColor(x,y);
end;

function TTarget_Exported_ReturnData(target: pointer;xs, ys, width, height: Integer): TRetData;
  stdcall;
begin
  result := TTarget(Target).ReturnData(xs,ys,width,height);
end;

procedure TTarget_Exported_FreeReturnData(target: pointer); stdcall;
begin
  TTarget(target).FreeReturnData;
end;


procedure TTarget_Exported_GetMousePosition(target: pointer; var x, y: integer
  ); stdcall;
begin
  TTarget(Target).GetMousePosition(x,y);
end;

procedure TTarget_Exported_MoveMouse(target: pointer; x, y: integer); stdcall;
begin
  TTarget(Target).MoveMouse(x,y);
end;
 procedure TTarget_Exported_ScrollMouse(target: pointer; x, y: integer;
  Lines: integer); stdcall;
begin
  TTarget(Target).ScrollMouse(x,y,lines);
end;

procedure TTarget_Exported_HoldMouse(target: pointer; x, y: integer;
  left: boolean); stdcall;
begin
  if left then
    TTarget(Target).HoldMouse(x,y,mouse_left)
  else
    TTarget(Target).HoldMouse(x,y,mouse_right);
end;

procedure TTarget_Exported_ReleaseMouse(target: pointer; x, y: integer;
  left: boolean); stdcall;
begin
  if left then
    TTarget(Target).ReleaseMouse(x,y,mouse_left)
  else
    TTarget(Target).ReleaseMouse(x,y,mouse_right);
end;

function TTarget_Exported_IsMouseButtonHeld(target: pointer; left: boolean
  ): boolean; stdcall;
begin
  if left then
    result := TTarget(Target).IsMouseButtonHeld(mouse_left)
  else
    result := TTarget(Target).IsMouseButtonHeld(mouse_right);
end;

procedure TTarget_Exported_SendString(target: pointer; str: PChar; keywait, keymodwait: integer); stdcall;
begin
  TTarget(Target).SendString(str, keywait, keymodwait);
end;

procedure TTarget_Exported_HoldKey(target: pointer; key: integer); stdcall;
begin
  TTarget(Target).HoldKey(key);
end;

procedure TTarget_Exported_ReleaseKey(target: pointer; key: integer); stdcall;
begin
  TTarget(Target).ReleaseKey(key);
end;

function TTarget_Exported_IsKeyHeld(target: pointer; key: integer): boolean;
  stdcall;
begin
  result := TTarget(Target).IsKeyHeld(key);
end;

function TTarget_Exported_GetKeyCode(target: pointer; C: char): integer;
  stdcall;
begin
  result := TTarget(target).GetKeyCode(c);
end;

initialization
  eios_controller:= TEIOS_Controller.Create;
finalization
  eios_controller.Free;
end.
