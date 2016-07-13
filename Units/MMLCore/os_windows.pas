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

     Windows OS specific implementation for Mufasa Macro Library
}

{$mode objfpc}{$H+}
unit os_windows;

interface

  uses
    Classes, SysUtils, mufasatypes, windows, graphics, LCLType, LCLIntf, bitmaps, IOManager, WinKeyInput, JwaPsApi;
    
  type

    TNativeWindow = Hwnd;

    TKeyInput = class(TWinKeyInput)
      public
        procedure Down(Key: Word);
        procedure Up(Key: Word);
    end;

    { TWindow }

    TWindow = class(TWindow_Abstract)
      public
        constructor Create;
        constructor Create(target: Hwnd); 
        destructor Destroy; override;
        procedure GetTargetDimensions(out w, h: integer); override;
        procedure GetTargetPosition(out left, top: integer); override;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override;
        function GetColor(x,y : integer) : TColor; override;

        function  GetError: String; override;
        function  ReceivedError: Boolean; override;
        procedure ResetError; override;

        function TargetValid: boolean; override;

        function MouseSetClientArea(x1, y1, x2, y2: integer): boolean; override;
        procedure MouseResetClientArea; override;
        function ImageSetClientArea(x1, y1, x2, y2: integer): boolean; override;
        procedure ImageResetClientArea; override;


        procedure ActivateClient; override;
        procedure GetMousePosition(out x,y: integer); override;
        procedure MoveMouse(x,y: integer); override;
        procedure ScrollMouse(x,y, lines : integer); override;
        procedure HoldMouse(x,y: integer; button: TClickType); override;
        procedure ReleaseMouse(x,y: integer; button: TClickType); override;
        function  IsMouseButtonHeld( button : TClickType) : boolean;override;

        procedure SendString(str: string; keywait, keymodwait: integer); override;
        procedure HoldKey(key: integer); override;
        procedure ReleaseKey(key: integer); override;
        function IsKeyHeld(key: integer): boolean; override;
        function GetKeyCode(c : char) : integer;override;

        function GetNativeWindow: TNativeWindow;
        function GetHandle(): PtrUInt; override;
      private
        handle: Hwnd;
        dc: HDC;
        buffer: TBitmap;
        buffer_raw: prgb32;
        width,height: integer;
        keyinput: TKeyInput;


        { (Forced) Client Area }
        mx1, my1, mx2, my2: integer;
        ix1, iy1, ix2, iy2: integer;
        mcaset, icaset: Boolean;
        procedure ValidateBuffer(w,h:integer);

        procedure MouseApplyAreaOffset(var x, y: integer);
        procedure ImageApplyAreaOffset(var x, y: integer);
      protected
        function WindowRect(out Rect : TRect) : Boolean; virtual;
    end;

    { TDesktopWindow }

    TDesktopWindow = class(TWindow)
    private
      constructor Create(DesktopHandle : HWND);
      function WindowRect(out Rect : TRect) : Boolean;override;
    end;

    TIOManager = class(TIOManager_Abstract)
      public
        constructor Create;
        constructor Create(plugin_dir: string);
        function SetTarget(target: TNativeWindow): integer; overload;
        procedure SetDesktop; override;
        
        function GetProcesses: TSysProcArr; override;
        function GetProcessMem(processID: LongInt): Int64; override;
        procedure SetTargetEx(Proc: TSysProc); overload;
      protected
        DesktopHWND : Hwnd;
        procedure NativeInit; override;
        procedure NativeFree; override;
    end;
    
implementation

  uses GraphType, interfacebase;

  type
    PMouseInput = ^TMouseInput;
    tagMOUSEINPUT = packed record
      dx: Longint;
      dy: Longint;
      mouseData: DWORD;
      dwFlags: DWORD;
      time: DWORD;
      dwExtraInfo: DWORD;
    end;
    TMouseInput = tagMOUSEINPUT;

    PKeybdInput = ^TKeybdInput;
    tagKEYBDINPUT = packed record
      wVk: WORD;
      wScan: WORD;
      dwFlags: DWORD;
      time: DWORD;
      dwExtraInfo: DWORD;
    end;
    TKeybdInput = tagKEYBDINPUT;

    PHardwareInput = ^THardwareInput;
    tagHARDWAREINPUT = packed record
      uMsg: DWORD;
      wParamL: WORD;
      wParamH: WORD;
    end;
    THardwareInput = tagHARDWAREINPUT;
    PInput = ^TInput;
    tagINPUT = packed record
      Itype: DWORD;
      case Integer of
        0: (mi: TMouseInput);
        1: (ki: TKeybdInput);
        2: (hi: THardwareInput);
    end;
    TInput = tagINPUT;

  const
    INPUT_MOUSE = 0;
    INPUT_KEYBOARD = 1;
    INPUT_HARDWARE = 2;

  function SendInput(cInputs: UINT; var pInputs: TInput; cbSize: Integer): UINT; stdcall; external user32 name 'SendInput';

//***implementation*** TKeyInput

  procedure TKeyInput.Down(Key: Word);
  begin
    DoDown(Key);
  end;

  procedure TKeyInput.Up(Key: Word);
  begin
    DoUp(Key);
  end;

//***implementation*** TWindow

  constructor TWindow.Create;
  begin
    inherited Create;
    self.buffer:= TBitmap.Create;
    self.buffer.PixelFormat:= pf32bit;
    keyinput:= TKeyInput.Create;

    self.mx1 := 0; self.my1 := 0; self.mx2 := 0; self.my2 := 0;
    self.mcaset := false;
    self.ix1 := 0; self.iy1 := 0; self.ix2 := 0; self.iy2 := 0;
    self.icaset := false;
  end;

  constructor TWindow.Create(target: Hwnd);
  begin
    inherited Create;
    self.buffer:= TBitmap.Create;
    self.buffer.PixelFormat:= pf32bit;
    keyinput:= TKeyInput.Create;
    self.handle:= target;
    self.dc:= GetWindowDC(target);

    self.mx1 := 0; self.my1 := 0; self.mx2 := 0; self.my2 := 0;
    self.mcaset := false;
    self.ix1 := 0; self.iy1 := 0; self.ix2 := 0; self.iy2 := 0;
    self.icaset := false;
  end;
  
  destructor TWindow.Destroy;
  begin
    ReleaseDC(handle,dc);//Dogdy as one might have used .create and not set a handle..
    buffer.Free;
    keyinput.Free;
    inherited Destroy; 
  end;

  function  TWindow.GetError: String;
  begin
    exit('');
  end;

  function  TWindow.ReceivedError: Boolean;
  begin
    exit(false);
  end;

  procedure TWindow.ResetError;
  begin

  end;

  function TWindow.GetNativeWindow: TNativeWindow;
  begin
    result := handle;
  end;

  function TWindow.GetHandle(): PtrUInt;
  begin
    Result := PtrUInt(GetNativeWindow());
  end;

  function TWindow.TargetValid: boolean;
  begin
    result:= IsWindow(handle);
  end;

  function TWindow.MouseSetClientArea(x1, y1, x2, y2: integer): boolean;
  var w, h: integer;
  begin
    { TODO: What if the client resizes (shrinks) and our ``area'' is too large? }
    GetTargetDimensions(w, h);
    if ((x2 - x1) > w) or ((y2 - y1) > h) then
      exit(False);
    if (x1 < 0) or (y1 < 0) then
      exit(False);

    mx1 := x1; my1 := y1; mx2 := x2; my2 := y2;
    mcaset := True;
  end;

  procedure TWindow.MouseResetClientArea;
  begin
    mx1 := 0; my1 := 0; mx2 := 0; my2 := 0;
    mcaset := False;
  end;

  function TWindow.ImageSetClientArea(x1, y1, x2, y2: integer): boolean;
  var w, h: integer;
  begin
    { TODO: What if the client resizes (shrinks) and our ``area'' is too large? }
    GetTargetDimensions(w, h);
    if ((x2 - x1) > w) or ((y2 - y1) > h) then
      exit(False);
    if (x1 < 0) or (y1 < 0) then
      exit(False);

    ix1 := x1; iy1 := y1; ix2 := x2; iy2 := y2;
    icaset := True;
  end;

  procedure TWindow.ImageResetClientArea;
  begin
    ix1 := 0; iy1 := 0; ix2 := 0; iy2 := 0;
    icaset := False;
  end;

  procedure TWindow.ActivateClient;
  begin
    SetForegroundWindow(handle);
  end;

  procedure TWindow.GetTargetDimensions(out w, h: integer);
  var
    Rect : TRect;
  begin
    if icaset then
    begin
      w := ix2 - ix1;
      h := iy2 - iy1;
      exit;
    end;
    WindowRect(rect);
    w:= Rect.Right - Rect.Left;
    h:= Rect.Bottom - Rect.Top;
  end;

  procedure TWindow.GetTargetPosition(out left, top: integer);
  var
    Rect : TRect;
  begin
    WindowRect(rect);
    left := Rect.Left;
    top := Rect.Top;
  end;
  
  function TWindow.GetColor(x,y : integer) : TColor;
  begin
    ImageApplyAreaOffset(x, y);
    result:= GetPixel(self.dc,x,y)
  end;
  
  procedure TWindow.ValidateBuffer(w,h:integer);
  var
     BmpInfo : Windows.TBitmap;
  begin
    if (w <> self.width) or (height <> self.height) then
    begin
      buffer.SetSize(w,h);
      self.width:= w;
      self.height:= h;
      GetObject(buffer.Handle, SizeOf(BmpInfo), @BmpInfo);
      self.buffer_raw := BmpInfo.bmBits;
    end;
  end;

  procedure TWindow.MouseApplyAreaOffset(var x, y: integer);
  begin
    if mcaset then
    begin
      x := x + mx1;
      y := y + my1;
    end;
  end;

  procedure TWindow.ImageApplyAreaOffset(var x, y: integer);
  begin
    if icaset then
    begin
      x := x + ix1;
      y := y + iy1;
    end;
  end;

  function TWindow.WindowRect(out Rect : TRect) : boolean;
  begin
    result := Windows.GetWindowRect(self.handle,rect);
  end;

  { This functions return a struct of pointer data.
    Data is blitted from the target window to the *start* of the buffer,
    and not to the corresponding position.
    So [xs,ys,xe,ye] is mapped to [0, 0, xe-xs, ye-ys].
  }
  function TWindow.ReturnData(xs, ys, width, height: Integer): TRetData;
  var
    temp: PRGB32;
    w,h : integer;
  begin
    GetTargetDimensions(w,h);
    ValidateBuffer(w,h);
    if (xs < 0) or (xs + width > w) or (ys < 0) or (ys + height > h) then
      raise Exception.CreateFMT('TMWindow.ReturnData: The parameters passed are wrong; xs,ys %d,%d width,height %d,%d',[xs,ys,width,height]);

    ImageApplyAreaOffset(xs, ys);

    Windows.BitBlt(self.buffer.Canvas.Handle,0,0, width, height, self.dc, xs,ys, SRCCOPY);
    Result.Ptr:= self.buffer_raw;

    Result.IncPtrWith:= w - width;
    Result.RowLen:= w;
  end;

  procedure TWindow.GetMousePosition(out x,y: integer);
  var
    MousePoint : TPoint;
    Rect : TRect;
  begin
    Windows.GetCursorPos(MousePoint);
    WindowRect(rect);
    x := MousePoint.x - Rect.Left;
    y := MousePoint.y - Rect.Top;

    x := x - mx1;
    y := y - my1;
  end;
  procedure TWindow.MoveMouse(x,y: integer);
  var
    rect : TRect;
    w,h: integer;
  begin
    MouseApplyAreaOffset(x, y);
    WindowRect(rect);
    x := x + rect.left;
    y := y + rect.top;
    Windows.SetCursorPos(x, y);
  end;

const
  MOUSEEVENTF_WHEEL = $800;
procedure TWindow.ScrollMouse(x, y, lines: integer);
var
  Input : TInput;
  Rect : TRect;
begin
  MouseApplyAreaOffset(x, y);
  WindowRect(rect);
  Input.Itype:= INPUT_MOUSE;
  FillChar(Input,Sizeof(Input),0);
  Input.mi.dx:= x + Rect.left;
  Input.mi.dy:= y + Rect.Top;
  Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_WHEEL;
  Input.mi.mouseData:= lines * WHEEL_DELTA;
  SendInput(1,Input, sizeof(Input));
end;

  procedure TWindow.HoldMouse(x,y: integer; button: TClickType);
  var
    Input : TInput;
    Rect : TRect;
  begin
    MouseApplyAreaOffset(x, y);
    WindowRect(rect);
    Input.Itype:= INPUT_MOUSE;
    FillChar(Input,Sizeof(Input),0);
    Input.mi.dx:= x + Rect.left;
    Input.mi.dy:= y + Rect.Top;
    case button of
      Mouse_Left: Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN;
      Mouse_Middle: Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN;
      Mouse_Right: Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN;
    end;
    SendInput(1,Input, sizeof(Input));
  end;
  procedure TWindow.ReleaseMouse(x,y: integer; button: TClickType);
  var
    Input : TInput;
    Rect : TRect;
  begin
    MouseApplyAreaOffset(x, y);
    WindowRect(rect);
    Input.Itype:= INPUT_MOUSE;
    FillChar(Input,Sizeof(Input),0);
    Input.mi.dx:= x + Rect.left;
    Input.mi.dy:= y + Rect.Top;
   case button of
      Mouse_Left: Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP;
      Mouse_Middle: Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP;
      Mouse_Right: Input.mi.dwFlags:= MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP;
    end;
    SendInput(1,Input, sizeof(Input));
  end;

function TWindow.IsMouseButtonHeld(button: TClickType): boolean;
begin
  case button of
     mouse_Left : Result := (GetAsyncKeyState(VK_LBUTTON) <> 0);
     mouse_Middle : Result := (GetAsyncKeyState(VK_MBUTTON) <> 0);
     mouse_Right : Result := (GetAsyncKeyState(VK_RBUTTON) <> 0);
  end;
end;

procedure TWindow.SendString(str: string; keywait, keymodwait: integer);
var
  I, L: integer;
  C: Byte;
  ScanCode, VK: Word;
  Shift: boolean;
begin
  L := Length(str);
  for I := 1 to L do
  begin
    VK := VkKeyScan(str[I]);
    Shift := (Hi(VK) > 0);
    C := LoByte(VK);
    ScanCode := MapVirtualKey(C, 0);
    if (ScanCode = 0) then
      Continue; // TODO/XXX: Perhaps raise an exception?

    // TODO/XXX: Do we wait when/after pressing shift as well?
    if (Shift) then
    begin
      Keybd_Event(VK_SHIFT, $2A, 0, 0);
      sleep(keymodwait shr 1) ;
    end;

    Keybd_Event(C, ScanCode, 0, 0);

    if keywait <> 0 then
        sleep(keywait);

    Keybd_Event(C, ScanCode, KEYEVENTF_KEYUP, 0);

    if (Shift) then
    begin
      sleep(keymodwait shr 1);
      Keybd_Event(VK_SHIFT, $2A, KEYEVENTF_KEYUP, 0);
    end;
  end;
end;

procedure TWindow.HoldKey(key: integer);
begin
  keyinput.Down(key);
end;
procedure TWindow.ReleaseKey(key: integer);
begin
  keyinput.Up(key);
end;
function TWindow.IsKeyHeld(key: integer): boolean;
begin
  Result := (GetAsyncKeyState(key)  <> 0);
end;

function TWindow.GetKeyCode(c: char): integer;
begin
  result := VkKeyScan(c) and $FF;
end;


//***implementation*** IOManager

constructor TIOManager.Create;
begin
  inherited Create;
end;

constructor TIOManager.Create(plugin_dir: string);
begin
  inherited Create(plugin_dir);
end;

procedure TIOManager.NativeInit;
begin
  self.DesktopHWND:= GetDesktopWindow;
end;

procedure TIOManager.NativeFree;
begin
end;

procedure TIOManager.SetDesktop;
begin
  SetBothTargets(TDesktopWindow.Create(DesktopHWND));
end;

function TIOManager.SetTarget(target: TNativeWindow): integer;
begin
  SetBothTargets(TWindow.Create(target));
end;

threadvar
  ProcArr: TSysProcArr;

function EnumProcess(Handle: HWND; Param: LPARAM): WINBOOL; stdcall;
var
  Proc: TSysProc;
  I: integer;
  pPid: DWORD;
begin
  Result := (not ((Handle = 0) or (Handle = null)));
  if ((Result) and (IsWindowVisible(Handle))) then
  begin
    I := Length(ProcArr);
    SetLength(ProcArr, I + 1);
    ProcArr[I].Handle := Handle;
    SetLength(ProcArr[I].Title, 255);
    SetLength(ProcArr[I].Title, GetWindowText(Handle, PChar(ProcArr[I].Title), Length(ProcArr[I].Title)));
    GetWindowSize(Handle, ProcArr[I].Width, ProcArr[I].Height);
    GetWindowThreadProcessId(Handle, pPid);
    ProcArr[I].Pid := pPid;
  end;
end;

function TIOManager.GetProcesses: TSysProcArr;
begin
  SetLength(ProcArr, 0);
  EnumWindows(@EnumProcess, 0);
  Result := ProcArr;
end;

function TIOManager.GetProcessMem(processID: LongInt): Int64;
var
  openHandle: HANDLE;
  ppsmemCounters: PROCESS_MEMORY_COUNTERS;
begin
  openHandle := OpenProcess(PROCESS_QUERY_INFORMATION, false, processID);
  if openHandle = 0 then
  begin
    writeln('GetProcessMem error: ', SysErrorMessage(GetLastOSError()));
    Exit(-1);
  end;

  GetProcessMemoryInfo(openHandle, ppsmemCounters, SizeOf(ppsmemCounters));
  CloseHandle(openHandle);
  Result := ppsmemCounters.WorkingSetSize;
end;

procedure TIOManager.SetTargetEx(Proc: TSysProc);
begin
  SetTarget(Proc.Handle);
end;

{ TDesktopWindow }

constructor TDesktopWindow.Create(DesktopHandle: HWND);
begin
  inherited Create;
  self.dc := GetDC(DesktopHandle);
  self.handle:= DesktopHandle;
end;

function TDesktopWindow.WindowRect(out Rect : TRect) : Boolean;
begin
  Rect.Left:= GetSystemMetrics(SM_XVIRTUALSCREEN);
  Rect.Top:= GetSystemMetrics(SM_YVIRTUALSCREEN);
  Rect.Right := GetSystemMetrics(SM_CXVIRTUALSCREEN);
  Rect.Bottom:= GetSystemMetrics(SM_CYVIRTUALSCREEN);
  Result := true;
end;

end.
