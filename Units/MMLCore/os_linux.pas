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

      Linux OS specific implementation for Mufasa Macro Library
}
{$mode objfpc}{$H+}
unit os_linux;

{
  TODO's:
  - Allow selecting a different X display
  - Fix keyboard layout / SendString
}

interface

  uses
    Classes, SysUtils, mufasatypes, mufasabase, IOManager,
    xlib, x, xutil, XKeyInput, ctypes, syncobjs;

  type

    TNativeWindow = x.TWindow;

    TKeyInput = class(TXKeyInput)
      public
        procedure Down(Key: Word);
        procedure Up(Key: Word);
    end;

    { TWindow }

    TWindow = class(TWindow_Abstract)
      public
        constructor Create(display: PDisplay; screennum: integer; window: x.TWindow);
        destructor Destroy; override;
        procedure GetTargetDimensions(out w, h: integer); override;
        procedure GetTargetPosition(out left, top: integer); override;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override;
        procedure FreeReturnData; override;

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
        procedure HoldMouse(x,y: integer; button: TClickType); override;
        procedure ReleaseMouse(x,y: integer; button: TClickType); override;
        function  IsMouseButtonHeld( button : TClickType) : boolean;override;

        procedure SendString(str: string; keywait, keymodwait: integer); override;
        procedure HoldKey(key: integer); override;
        procedure ReleaseKey(key: integer); override;
        function IsKeyHeld(key: integer): boolean; override;
        function GetKeyCode(c : char) : integer;override;

        function GetNativeWindow: TNativeWindow;
        function GetHandle(): PtrUInt;
      private
        { display is the connection to the X server }
        display: PDisplay;

        { screen-number and selected window }
        screennum: integer;
        window: x.TWindow;

        { Reference to the XImage }
        buffer: PXImage;

        { For memory-leak checks }
        dirty: Boolean;  //true if image loaded

        { KeyInput class }
        keyinput: TKeyInput;

        { X Error Handler }
        oldXHandler: TXErrorHandler;

        { (Forced) Client Area }
        mx1, my1, mx2, my2: integer;
        ix1, iy1, ix2, iy2: integer;
        mcaset, icaset: Boolean;

        procedure MouseApplyAreaOffset(var x, y: integer);
        procedure ImageApplyAreaOffset(var x, y: integer);
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
      private
        procedure NativeInit; override;
        procedure NativeFree; override;
      public
        display: PDisplay;
        screennum: integer;
        desktop: x.TWindow;
    end;

  function MufasaXErrorHandler(para1:PDisplay; para2:PXErrorEvent):cint; cdecl;

implementation

  uses GraphType, interfacebase, lcltype, StringUtil;

  { PROBLEM: .Create is called on the main thread. ErrorCS etc aren't
    created on other threads. We will create them on the fly...
    More info below...}
  threadvar
    xerror: string;
  threadvar
    ErrorCS: syncobjs.TCriticalSection;


 {
    This is extremely hacky, but also very useful.
    We have to install a X error handler, because otherwise X
    will terminate our entire app on error.

    Since we want the right thread to recieve the right error, we have to
    fiddle a bit with threadvars, mutexes / semaphores.

    Another problem is that the script thread is initialised on the main thread.
    This means that all (threadvar!) semaphores initialised on the mainthread
    are NOT initialised on the script thread, which has yet to be started.
    Therefore, we check if it hasn't been created yet.

    ** Horrible solution, but WFM **

    This is the Handler function.

  }

  function MufasaXErrorHandler(para1:PDisplay; para2:PXErrorEvent):cint; cdecl;

  begin
    case para2^.error_code of
      1:  xerror := 'BadRequest';
      2:  xerror := 'BadValue';
      3:  xerror := 'BadWindow';
      4:  xerror := 'BadPixmap';
      5:  xerror := 'BadAtom';
      6:  xerror := 'BadCursor';
      7:  xerror := 'BadFont';
      8:  xerror := 'BadMatch';
      9:  xerror := 'BadDrawable';
      10: xerror := 'BadAccess';
      11: xerror := 'BadAlloc';
      12: xerror := 'BadColor';
      13: xerror := 'BadGC';
      14: xerror := 'BadIDChoice';
      15: xerror := 'BadName';
      16: xerror := 'BadLength';
      17: xerror := 'BadImplementation';
      else
        xerror := 'UNKNOWN';
    end;
    result := 0;
    mDebugLn('X Error: ' + xerror);
    mDebugLn('Error code: ' + inttostr(para2^.error_code));
    mDebugLn('Display: ' + inttostr(LongWord(para2^.display)));
    mDebugLn('Minor code: ' + inttostr(para2^.minor_code));
    mDebugLn('Request code: ' + inttostr(para2^.request_code));
    mDebugLn('Resource ID: ' + inttostr(para2^.resourceid));
    mDebugLn('Serial: ' + inttostr(para2^.serial));
    mDebugLn('Type: ' + inttostr(para2^._type));
  end;

 { TKeyInput }

  procedure TKeyInput.Down(Key: Word);
  begin
    DoDown(Key);
  end;

  procedure TKeyInput.Up(Key: Word);
  begin
    DoUp(Key);
  end;

  { TWindow }

  function TWindow.GetError: String;
  begin
    exit(xerror);
  end;

  function  TWindow.ReceivedError: Boolean;
  begin
    result := xerror <> '';
  end;

  procedure TWindow.ResetError;
  begin
    xerror := '';
  end;

  { See if the semaphores / CS are initialised }
  constructor TWindow.Create(display: PDisplay; screennum: integer; window: x.TWindow);
  begin
    inherited Create;
    self.display:= display;
    self.screennum:= screennum;
    self.window:= window;
    self.dirty:= false;
    self.keyinput:= TKeyInput.Create;
    self.mx1 := 0; self.my1 := 0; self.mx2 := 0; self.my2 := 0;
    self.mcaset := false;
    self.ix1 := 0; self.iy1 := 0; self.ix2 := 0; self.iy2 := 0;
    self.icaset := false;

    xerror := '';

    { XXX FIXME TODO O GOD WTF }
    if not assigned(ErrorCS) then
      ErrorCS := syncobjs.TCriticalSection.Create;
    ErrorCS.Enter;
    try
      oldXHandler:=XSetErrorHandler(@MufasaXErrorHandler);
    finally
      ErrorCS.Leave;
    end;
  end;

  destructor TWindow.Destroy;
    var
      erh: TXErrorHandler;
  begin
    FreeReturnData;
    keyinput.Free;

    { XXX FIXME TODO O GOD WTF }
    if not assigned(ErrorCS) then
      ErrorCS := syncobjs.TCriticalSection.Create;
    ErrorCS.Enter;

    erh := XSetErrorHandler(oldXHandler);
    try
      if erh <> @MufasaXErrorHandler then
        XSetErrorHandler(erh);
    finally
      ErrorCS.Leave;
    end;
    inherited Destroy;
  end;

  function TWindow.GetNativeWindow: TNativeWindow;
  begin
    result := self.window;
  end;

  function TWindow.GetHandle(): PtrUInt;
  begin
    Result := PtrUInt(GetNativeWindow());
  end;

  procedure TWindow.GetTargetDimensions(out w, h: integer);
  var
    Attrib: TXWindowAttributes;
  begin
    if icaset then
    begin
      w := ix2 - ix1;
      h := iy2 - iy1;
      exit;
    end;
    if XGetWindowAttributes(display, window, @Attrib) <> 0 Then
    begin
      W := Attrib.Width;
      H := Attrib.Height;
    end else
    begin
      W := -1;
      H := -1;
    end;
  end;

  procedure TWindow.GetTargetPosition(out left, top: integer);
  var
    Attrib: TXWindowAttributes;
  begin
    if XGetWindowAttributes(display, window, @Attrib) <> 0 Then
    begin
      left := Attrib.x;
      top := attrib.y;
    end else
    begin
      // XXX: this is tricky; what do we return when it doesn't exist?
      // The window can very well be at -1, -1. We'll return 0 for now.
      left := 0;
      top := 0;
    end;
  end;

  function TWindow.TargetValid: boolean;
  var
    Attrib: TXWindowAttributes;
  begin
    XGetWindowAttributes(display, window, @Attrib);
    result := not ReceivedError;
  end;

  { SetClientArea allows you to use a part of the actual client as a virtual
    client. Im other words, all mouse,find functions will be relative to the
    virtual client.

    XXX:
    I realise I can simply add a[x,y]1 to all of the functions rather than check
    for caset (since they're 0 if it's not set), but I figured it would be more
    clear this way.
  }
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

  procedure TWindow.ActivateClient;

  begin
    XSetInputFocus(display,window,RevertToParent,CurrentTime);
    XFlush(display);
    if ReceivedError then
      raise Exception.Create('Error: ActivateClient: ' + GetError);
  end;

  function TWindow.ReturnData(xs, ys, width, height: Integer): TRetData;
  var
    w,h: integer;
  begin
    GetTargetDimensions(w,h);
    if (xs < 0) or (xs + width > w) or (ys < 0) or (ys + height > h) then
      raise Exception.CreateFMT('TMWindow.ReturnData: The parameters passed are wrong; xs,ys %d,%d width,height %d,%d',[xs,ys,width,height]);
    if dirty then
      raise Exception.CreateFmt('ReturnData was called again without freeing'+
                                ' the previously used data. Do not forget to'+
                                ' call FreeReturnData', []);

    ImageApplyAreaOffset(xs, ys);

    buffer := XGetImage(display, window, xs, ys, width, height, AllPlanes, ZPixmap);
    if buffer = nil then
    begin
      mDebugLn('ReturnData: XGetImage Error. Dumping data now:');
      mDebugLn('xs, ys, width, height: ' + inttostr(xs) + ', '  + inttostr(ys) +
              ', ' + inttostr(width) + ', ' + inttostr(height));
      Result.Ptr := nil;
      Result.IncPtrWith := 0;
      raise Exception.CreateFMT('TMWindow.ReturnData: ReturnData: XGetImage Error', []);
      exit;
    end;
    Result.Ptr := PRGB32(buffer^.data);
    Result.IncPtrWith := 0;
    Result.RowLen := width;
    dirty:= true;
    //XSetErrorHandler(Old_Handler);
  end;

  procedure TWindow.FreeReturnData;
  begin
    if dirty then
    begin
      if (buffer <> nil) then
        XDestroyImage(buffer);
      buffer:= nil;
      dirty:= false;
    end;
  end;

  procedure TWindow.GetMousePosition(out x,y: integer);
  var
    event: TXButtonEvent;
  begin
    FillChar(event, SizeOf(event), 0);

    XQueryPointer(display, window,
                     @event.root, @event.window,
                     @event.x_root, @event.y_root,
                     @event.x, @event.y,
                     @event.state);

    x := event.x;
    y := event.y;

    x := x - mx1;
    y := y - my1;
  end;

  procedure TWindow.MoveMouse(x,y: integer);
  begin
    MouseApplyAreaOffset(x, y);
    XWarpPointer(display, None, window, 0, 0, 0, 0, X, Y);
    XFlush(display);
  end;

  procedure TWindow.HoldMouse(x,y: integer; button: TClickType);
  var
    event: TXButtonPressedEvent;
  begin
    FillChar(event, SizeOf(event), 0);

    case button of
      mouse_Left:   event.button := Button1;
      mouse_Middle: event.button := Button2;
      mouse_Right:  event.button := Button3;
    end;
    event.same_screen := cint(0);
    event.subwindow := window;

    while (event.subwindow <> None) do
    begin
      event.window := event.subwindow;

      XQueryPointer(display, event.window,
                       @event.root, @event.subwindow,
                       @event.x_root, @event.y_root,
                       @event.x, @event.y,
                       @event.state);
    end;

    event._type := ButtonPress;
    XSendEvent(display, PointerWindow, True, ButtonPressMask, @event);
    XFlush(display);
  end;

  procedure TWindow.ReleaseMouse(x,y: integer; button: TClickType);
  var
    event: TXButtonReleasedEvent;
  begin
    FillChar(event, SizeOf(event), 0);

    case button of
      mouse_Left:   event.button := Button1;
      mouse_Middle: event.button := Button2;
      mouse_Right:  event.button := Button3;
    end;
    event.same_screen := cint(0);
    event.subwindow := window;

    while (event.subwindow <> None) do
    begin
      event.window := event.subwindow;

      XQueryPointer(display, event.window,
                       @event.root, @event.subwindow,
                       @event.x_root, @event.y_root,
                       @event.x, @event.y,
                       @event.state);
    end;

    event._type := ButtonRelease;
    XSendEvent(display, PointerWindow, True, ButtonReleaseMask, @event);
    XFlush(display);
  end;

  function TWindow.IsMouseButtonHeld(button: TClickType): boolean;
  var
    event: TXEvent;
  begin
    FillChar(event, SizeOf(event), 0);

    XQueryPointer(display, event.xbutton.window,
                     @event.xbutton.root, @event.xbutton.window,
                     @event.xbutton.x_root, @event.xbutton.y_root,
                     @event.xbutton.x, @event.xbutton.y,
                     @event.xbutton.state);

    case button of
      mouse_Left:   Result := ((event.xbutton.state and Button1Mask) > 0);
      mouse_Middle: Result := ((event.xbutton.state and Button2Mask) > 0);
      mouse_Right:  Result := ((event.xbutton.state and Button3Mask) > 0);
      else
        Result := False;
    end;
  end;

  { TODO: Check if this supports multiple keyboard layouts, probably not }
  procedure TWindow.SendString(str: string; keywait, keymodwait: integer);
  var
    I, L: Integer;
    K: Byte;
    HoldShift: Boolean;
  begin
    HoldShift := False;
    L := Length(str);
    for I := 1 to L do
    begin
      if (((str[I] >= 'A') and (str[I] <= 'Z')) or
          ((str[I] >= '!') and (str[I] <= '&')) or
          ((str[I] >= '(') and (str[I] <= '+')) or
          (str[I] = ':') or
          ((str[I] >= '<') and (str[I] <= '@')) or
          ((str[I] >= '^') and (str[I] <= '_')) or
          ((str[I] >= '{') and (str[I] <= '~'))) then
      begin
        HoldKey(VK_SHIFT);
        HoldShift := True;
        sleep(keymodwait shr 1);
      end;

      K := GetKeyCode(str[I]);
      HoldKey(K);

      if keywait <> 0 then
        Sleep(keywait);

      ReleaseKey(K);

      if (HoldShift) then
      begin
        HoldShift := False;
        sleep(keymodwait shr 1);
        ReleaseKey(VK_SHIFT);
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
    raise Exception.CreateFmt('IsKeyDown isn''t implemented yet on Linux', []);
  end;

  function TWindow.GetKeyCode(c: char): integer;
  begin
    case C of
      '0'..'9' :Result := VK_0 + Ord(C) - Ord('0');
      'a'..'z' :Result := VK_A + Ord(C) - Ord('a');
      'A'..'Z' :Result := VK_A + Ord(C) - Ord('A');
      ' ' : result := VK_SPACE;
    else
      Raise Exception.CreateFMT('GetSimpleKeyCode - char (%s) is not in A..z',[c]);
    end
  end;

  { ***implementation*** IOManager }

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
    display := XOpenDisplay(nil);
    if display = nil then
      raise Exception.Create('Could not open a connection to the X Display');

    { DefaultScreen }
    screennum:= DefaultScreen(display);

    { Get the Desktop Window }
    desktop:= RootWindow(display,screennum)
  end;

  procedure TIOManager.NativeFree;
  begin
    XCloseDisplay(display);
  end;

  procedure TIOManager.SetDesktop;
  begin
    SetBothTargets(TWindow.Create(display, screennum, desktop));
  end;

  function TIOManager.SetTarget(target: x.TWindow): integer;
  begin
    result := SetBothTargets(TWindow.Create(display, screennum, target))
  end;

  function TIOManager.GetProcesses: TSysProcArr;
  begin
    raise Exception.Create('GetProcesses: Not Implemented.');
  end;

  function TIOManager.GetProcessMem(processID: LongInt): Int64;
  var
    list: TStringList;
  begin
    Result := -1;
    list := TStringList.Create;
    list.NameValueSeparator:=':';
    try
      list.LoadFromFile( Format('/proc/%d/status', [proc]) );
      Result := StrToInt64(ExtractFromStr(list.Values['VmRSS'], NUMBERS)) shl 10;
    finally
      list.Free();
    end;
  end;

  procedure TIOManager.SetTargetEx(Proc: TSysProc);
  begin
    raise Exception.Create('SetTargetEx: Not Implemented.');
  end;

end.
