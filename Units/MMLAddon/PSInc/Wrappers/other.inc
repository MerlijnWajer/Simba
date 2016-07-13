{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009 by Raymond van Venetië and Merlijn Wajer

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

    Other.inc for the Mufasa Macro Library
}
procedure ps_Writeln(const str : string); extdecl;
begin
  psWriteln(str);
end;

{$IFNDEF MML_EXPORT_THREADSAFE}
function ps_SetScriptProp(prop : TSP_Property; Value: TVariantArray): boolean; extdecl;
var
  i: Integer;
begin
  Result := True;
  if prop = SP_OnTerminate then
    CurrThread.Prop.ClearOnTerminateProcs;
  for i:= 0 to High(Value) do
    if not CurrThread.Prop.AddProp(prop, Value[i]) then
      Result := False;
end;

function ps_GetScriptProp(prop : TSP_Property; var Value : TVariantArray) : boolean; extdecl;
begin;
  exit(CurrThread.Prop.GetProp(prop,value));
end;
{$ENDIF}

procedure ps_Wait(t: DWord); extdecl;
{$ifdef MSWINDOWS}
begin
  Sleep(t);
end;
{$else}
var
  EndTime : DWord;
begin
  if t > 50 then
  begin;
    EndTime := GetTickCount + t;
    while {(CurrThread.PSScript.Exec.Status = isRunning) and }(GetTickCount < EndTime) do
      Sleep(16);
  end else
  begin
    sleep(t);
  end;
end;
{$endif}

procedure ps_PlaySound( Sound : string); extdecl;
begin
  {$ifdef MSWINDOWS}
  sndPlaySound(PChar(sound),SND_ASYNC or SND_NODEFAULT);
  {$else}
  psWriteln(Format('Playing sound %s (not supported yet on Linux)',[sound]));
  {$endif}
end;

Procedure ps_StopSound; extdecl;
begin
  {$ifdef MSWINDOWS}
  sndPlaySoundW(nil,0);
  {$else}
  psWriteln('Stopping sound is not supported yet on Linux');
  {$endif}
end;

{$IFNDEF MML_EXPORT_THREADSAFE}
procedure ps_ClearDebug; extdecl;
begin
  CurrThread.FormCallBack(m_ClearDebug,nil);
end;

procedure ps_SetSupressExceptions(Supress : boolean);extdecl;
begin
  CurrThread.Client.MFinder.WarnOnly:= Supress;
end;

procedure ps_SaveScreenshot(FileName: string); extdecl;
var
  w,h : integer;
  bmp: TMufasaBitmap;
begin;
  CurrThread.Client.IOManager.GetDimensions(w,h);
  bmp := TMufasaBitmap.Create;
  try
      bmp.CopyClientToBitmap(CurrThread.Client.IOManager,True,0,0,w-1,h-1);
      bmp.SaveToFile(FileName);
  finally
      bmp.Free;
  end;
end;



procedure ps_DisplayDebugImgWindow(w,h : integer); extdecl;
var
  DispSize : TPoint;
begin;
  DispSize := Classes.Point(w,h);
  Currthread.FormCallBack(m_DisplayDebugImgWindow,@DispSize);
end;

procedure ps_DrawBitmapDebugImg(bmp : integer); extdecl;
var
  mbmp : TMufasaBitmap;
begin;
  mbmp := CurrThread.Client.MBitmaps[bmp];
  CurrThread.FormCallBack(m_DrawBitmapDebugImg,Pointer(mbmp));
end;

function ps_GetDebugBitmap : integer; extdecl;
var
  mbmp : TMufasaBitmap;
begin;
  result := CurrThread.Client.MBitmaps.CreateBMP(0,0);
  mbmp := CurrThread.Client.MBitmaps[result];
  CurrThread.FormCallBack(m_GetDebugBitmap,pointer(mbmp));
end;

procedure ps_ClearDebugImg; extdecl;
begin
  CurrThread.FormCallBack(m_ClearDebugImg,nil);
end;

procedure ps_Status(Status : string); extdecl;
var
  PStatus : PChar;
begin
  PStatus:= PChar(Status);
  CurrThread.FormCallBack(m_Status,PStatus);
end;

procedure ps_Disguise(Caption : string); extdecl;
var
  PCaption : PChar;
begin
  PCaption := PChar(Caption);
  CurrThread.FormCallBack(m_Disguise,PCaption);
end;

procedure ps_ShowMessage(msg: string); extdecl;
var
  PMsg: Pchar;
begin
  if (GetCurrentThreadID() = MainThreadID) then
    ShowMessage(msg)
  else begin
    PMsg := PChar(msg);
    CurrThread.FormCallBack(m_ShowMessage, PMsg);
  end;
end;

function ps_MessageBox(Text, Caption: string; Flags: LongInt): Integer;
var
  MessageBoxData: TMessageBoxdata;
begin
  if (GetCurrentThreadID() = MainThreadID) then
    Result := Application.MessageBox(PChar(Text), PChar(Caption), Flags)
  else
    with MessageBoxData do
    begin
      AText := PChar(Text);
      ACaption := PChar(Caption);
      AFlags := Flags;
      CurrThread.FormCallBack(m_MessageBox,@MessageBoxData);
      Result := res;
    end;
end;

function ps_MessageDlg(const Caption, Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): integer;
var
  MessageDlgData: TMessageDlgData;
begin
  if (GetCurrentThreadID() = MainThreadID) then
    Result := MessageDlg(Caption, Msg, DlgType, Buttons, 0)
  else
    with MessageDlgData do
    begin
      ACaption := Caption;
      AMsg := Msg;
      ADlgType := DlgType;
      Abuttons := Buttons;
      CurrThread.FormCallBack(m_MessageDlg,@MessageDlgData);
      Result := res;
    end;
end;

function ps_InputQuery(const ACaption, APrompt : String; var Value : String): Boolean;
var
  InputQueryData: TInputQueryData;
begin
  if (GetCurrentThreadID() = MainThreadID) then
    Result := InputQuery(ACaption, APrompt, Value)
  else begin
    InputQueryData.ACaption:= ACaption;
    InputQueryData.APrompt:= APrompt;
    InputQueryData.Value:= Value;
    CurrThread.FormCallBack(m_InputQuery, @InputQueryData);
    Result := InputQueryData.Res;
    Value := InputQueryData.Value;
  end;
end;

procedure ps_ShowBalloonHint(const Title, Hint: string; const Timeout: Integer; const Flag: TBalloonFlags);
var
  Data: TBalloonHintData;
begin
  Data.ATitle := Title;
  Data.AHint := Hint;
  Data.ATimeout := Timeout;
  Data.AFlag := Flag;
  CurrThread.FormCallBack(m_BalloonHint, @Data);
end;

procedure ps_TerminateScript; extdecl;
begin;
  CurrThread.Terminate;
end;

{$DEFINE PS_ADDONTERMINATE}
function ps_AddOnTerminate(const proc : string; skipIfUserTerminated: Boolean = False): Boolean; extdecl;
begin;
  result := CurrThread.Prop.AddProp(SP_OnTerminate, proc, skipIfUserTerminated);
end;

function ps_DeleteOnTerminate(const Proc : string): Boolean; extdecl;
begin;
  Result := CurrThread.Prop.DeleteOnTerminateProcs(Proc);
end;

function ps_GetTimeRunning: LongWord; extdecl;
begin;
  result := GetTickCount - CurrThread.StartTime;
end;

function ps_GetTClient : TClient; extdecl;
begin
  Result := CurrThread.Client;
end;

{$ENDIF}

procedure ps_ConvertTime(Time : integer; var h,m,s : integer); extdecl;
var
  x : integer;
begin;
  x := time;
  h := x div (3600000);
  x := x mod (3600000);
  m := x div (60000);
  x := x mod (60000);
  s := x div (1000);
end;

procedure ps_ConvertTime64(time: int64; var y, m, w, d, h, min, s: integer); extdecl;
var
  x : int64;
begin
  x := time;
  y := x div (31536000000); // 1000 * 60 * 60 * 24 * 365 (1 year or 365 days)
  x := x mod (31536000000);
  m := x div (2592000000); // 1000 * 60 * 60 * 24 * 30 (1 month or 30 days)
  x := x mod (2592000000);
  w := x div (604800000); // 1000 * 60 * 60 * 24 * 7 (1 week or 7 days)
  x := x mod (604800000);
  d := x div (86400000); // 1000 * 60 * 60 * 24 (1 day or 24 hours)
  x := x mod (86400000);
  h := x div (3600000); // 1000 * 60 * 60 (1 hour or 60 minutes)
  x := x mod (3600000);
  min := x div (60000); // 1000 * 60 (1 minute or 60 seconds)
  x := x mod (60000);
  s := x div (1000); // 1000 (1 second)
  x := x mod (1000);
end;

procedure ps_DecodeDate ( const SourceDate  : TDateTime; var Year, Month, Day  : Word ); extdecl;
begin
  decodedate(sourcedate,year,month,day);
end;
procedure ps_DecodeTime(DateTime : TDateTime; var Hour,Min,Sec,MSec : word); extdecl;
begin
  decodetime(datetime,hour,min,sec,msec);
end;
function ps_Now : TDateTime; extdecl;
begin
  result := now;
end;
function ps_Date : TDateTime; extdecl;
begin
  result := date;
end;
function ps_GetTickCount : Longword; extdecl;
begin
  result := GetTickCount;
end;
procedure ps_HakunaMatata; extdecl;
begin;
  OpenWebPage('https://www.youtube.com/watch?v=xB5ceAruYrI');
end;
procedure ps_Simba; extdecl;
begin
  psWriteln(DecompressString(Base64Decode('9AoAAHicldU7b+0gDADgvdL9D+AisSDOTrpUvWvGuzNVOkMn9v72a942j6T1dJrEX7AxqRAXYaS9up3iz8suVxoMKe+'+
            'NC6LGnbEhiCCfTzPfJ5cmgidj5J9MsezSQAyApGHGR17N9SpGoBj1tkuRkJHoAk3WeMfTC66GWbaTFtMAwZDPRjh73U4uCKGnRTh3NMK0mAjiXxA975iERASl'+
            'QjfcRLBVS963TKCQDb0m8Brwwv1IKAWkErcipPNAC5+JdPmY62hE/O3L8yE+T4k4PpGwi2aiEIn25zcqKMQ1a6bgNtGN4kJqJ1tYeqFwrMNDcCFvKjMsWXLOK'+
            'N19toPbBN2PmacG9BogFoW7CQD00JTHdZlLml1yQZiv8zzBxGlQzxoxlx+Gdjo8JQDMV8w/0UmCctC/PGZDIKKPFMIGOM8M5IlUyuMel05IwY3hiHoMTLJYdg'+
            'RKvhJxsGt5wzKI8PApjpQTQmj5CkIRIO6S3REPXZjD1kyNGxABm60IxLkdu8HqQOaRmt0TcTVVFHzCdq2oX6ae2CMRuo/bWuhdHfMhfSI8PTE3xIjAuIRu7An'+
            'hv0kN+e38+1GMPYH/hq1PcyKsywdWvI1n9Y4YXzsLydgSphI4G7i/AexYRTW2RJmBPqFqTcgtUW7T6dgQlwIDfrsIsyDCphcbot5eDPgviZ8Yt0S4Ne4Iuoy/H'+
            '+//1sR/NLyhCQ==')));
end;

procedure ps_SetClipBoard(const Data: string); extdecl;
begin
  try
    Clipboard.AsText := Data;
  except
    on e: exception do
      mDebugLn('Exception in SetClipBoard: ' + e.message);
  end;
end;

function ps_GetClipBoard: string; extdecl;
begin
  try
    Result := Clipboard.AsText;
  except
    on e: exception do
      mDebugLn('Exception in GetClipBoard: ' + e.message);
  end;
end;

function ps_GetProcesses: TSysProcArr;
begin
  Result := CurrThread.Client.IOManager.GetProcesses;
end;

function ps_GetProcessMem(processID: LongInt): Int64;
begin
  Result := CurrThread.Client.IOManager.GetProcessMem(processID);
end;

function ps_GetProcessID : LongInt;
begin
  Result := GetProcessID;
end;

procedure ps_SetTarget(Proc: TSysProc);
begin
  CurrThread.Client.IOManager.SetTargetEx(Proc);
end;

function ps_GetEnvironmentVariable(const VarName: string): string; extdecl;
begin
  result := GetEnvironmentVariableUTF8(VarName);
end;
