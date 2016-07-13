procedure Lape_Writeln(const Params: PParamArray); lape_extdecl
begin
  ps_Writeln(Pstring(Params^[0])^);
end;

procedure Lape_AddOnTerm(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PBoolean(Result)^ := ps_AddOnTerminate(PlpString(Params^[0])^, PBoolean(Params^[1])^);
end;

procedure Lape_DelOnTerm(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PBoolean(Result)^ := ps_DeleteOnTerminate(PlpString(Params^[0])^);
end;

procedure Lape_SetScriptProp(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pboolean(Result)^ := ps_SetScriptProp(PSP_Property(Params^[0])^, PVariantArray(Params^[1])^);
end;

procedure Lape_GetScriptProp(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pboolean(Result)^ := ps_GetScriptProp(PSP_Property(Params^[0])^, PVariantArray(Params^[1])^);
end;

procedure Lape_Wait(const Params: PParamArray); lape_extdecl
begin
  ps_Wait(PDWord(Params^[0])^);
end;

procedure Lape_PlaySound(const Params: PParamArray); lape_extdecl
begin
  ps_PlaySound(Pstring(Params^[0])^);
end;

procedure Lape_StopSound(const Params: PParamArray); lape_extdecl
begin
  ps_StopSound();
end;

procedure Lape_ClearDebug(const Params: PParamArray); lape_extdecl
begin
  ps_ClearDebug();
end;

procedure Lape_SetSupressExceptions(const Params: PParamArray); lape_extdecl
begin
  ps_SetSupressExceptions(Pboolean(Params^[0])^);
end;

procedure Lape_SaveScreenshot(const Params: PParamArray); lape_extdecl
begin
  ps_SaveScreenshot(Pstring(Params^[0])^);
end;

procedure Lape_DisplayDebugImgWindow(const Params: PParamArray); lape_extdecl
begin
  ps_DisplayDebugImgWindow(Pinteger(Params^[0])^, Pinteger(Params^[1])^);
end;

procedure Lape_DrawBitmapDebugImg(const Params: PParamArray); lape_extdecl
begin
  ps_DrawBitmapDebugImg(Pinteger(Params^[0])^);
end;

procedure Lape_GetDebugBitmap(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := ps_GetDebugBitmap();
end;

procedure Lape_ClearDebugImg(const Params: PParamArray); lape_extdecl
begin
  ps_ClearDebugImg();
end;

procedure Lape_Status(const Params: PParamArray); lape_extdecl
begin
  ps_Status(Pstring(Params^[0])^);
end;

procedure Lape_Disguise(const Params: PParamArray); lape_extdecl
begin
  ps_Disguise(Pstring(Params^[0])^);
end;

procedure Lape_ShowMessage(const Params: PParamArray); lape_extdecl
begin
  ps_ShowMessage(Pstring(Params^[0])^);
end;

procedure Lape_MessageBox(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PInteger(Result)^ := ps_MessageBox(Pstring(Params^[0])^, Pstring(Params^[1])^, PLongInt(Params^[2])^);
end;

procedure Lape_MessageDlg(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := ps_MessageDlg(Pstring(Params^[0])^, Pstring(Params^[1])^, PMsgDlgType(Params^[2])^, PMsgDlgButtons(Params^[3])^);
end;

procedure Lape_InputQuery(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PBoolean(Result)^ := ps_InputQuery(PString(Params^[0])^, PString(Params^[1])^, PString(Params^[2])^);
end;

procedure Lape_TerminateScript(const Params: PParamArray); lape_extdecl
begin
  ps_TerminateScript();
end;

procedure Lape_GetTimeRunning(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PLongWord(Result)^ := ps_GetTimeRunning();
end;

procedure Lape_GetTClient(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PClient(Result)^ := ps_GetTClient();
end;

procedure Lape_ConvertTime(const Params: PParamArray); lape_extdecl
begin
  ps_ConvertTime(Pinteger(Params^[0])^, Pinteger(Params^[1])^, Pinteger(Params^[2])^, Pinteger(Params^[3])^);
end;

procedure Lape_ConvertTime64(const Params: PParamArray); lape_extdecl
begin
  ps_ConvertTime64(Pint64(Params^[0])^, Pinteger(Params^[1])^, Pinteger(Params^[2])^, Pinteger(Params^[3])^, Pinteger(Params^[4])^, Pinteger(Params^[5])^, Pinteger(Params^[6])^, Pinteger(Params^[7])^);
end;

procedure Lape_HakunaMatata(const Params: PParamArray); lape_extdecl
begin
  ps_HakunaMatata();
end;

procedure Lape_Simba(const Params: PParamArray); lape_extdecl
begin
  ps_Simba();
end;

procedure Lape_SetClipBoard(const Params: PParamArray); lape_extdecl
begin
  ps_SetClipBoard(Pstring(Params^[0])^);
end;

procedure Lape_GetClipBoard(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pstring(Result)^ := ps_GetClipBoard();
end;

procedure Lape_GetProcessID(const Params : PParamArray; const Result : Pointer); lape_extdecl
begin
  PLongInt(Result)^ := ps_GetProcessID();
end;

procedure Lape_GetProcessMem(const Params : PParamArray; const Result : Pointer); lape_extdecl
begin
  PInt64(Result)^ := ps_GetProcessMem(PLongInt(Params^[0])^);
end;

procedure Lape_GetProcesses(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PSysProcArr(Result)^ := ps_GetProcesses();
end;

procedure Lape_SetTarget(const Params: PParamArray); lape_extdecl
begin
  ps_SetTarget(PSysProc(Params^[0])^);
end;

procedure Lape_GetEnvironmentVariable(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PlpString(Result)^ := ps_GetEnvironmentVariable(PString(Params^[0])^);
end;

procedure Lape_ShowBalloonHint(const Params: PParamArray); lape_extdecl
type
  PBalloonFlags = ^TBalloonFlags;
begin
  ps_ShowBalloonHint(PString(Params^[0])^, PString(Params^[1])^, PInteger(Params^[2])^, PBalloonFlags(Params^[3])^);
end;

