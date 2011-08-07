unit psextension;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, virtualextension, forms, client, uPSComponent,uPSCompiler,
  uPSRuntime, stdCtrls, uPSPreProcessor,MufasaTypes,MufasaBase, web,
  bitmaps, plugins, libloader, dynlibs,internets,scriptproperties, settingssandbox, updater;



type

    { TSimbaPSExtension }

  TSimbaPSExtension = class(TVirtualSimbaExtension)
  private
    PSInstance: TPSScript;
    FWorking: Boolean;
    Script: TStringList;
    FClient : TClient;
    procedure StartExtension;
    function FreeScript: boolean;
    function InitScript: Boolean;
    procedure OutputMessages;
  protected
    procedure RegisterPSCComponents(Sender: TObject; x: TPSPascalCompiler);
    procedure RegisterPSRComponents(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
    procedure RegisterMyMethods(x: TPSScript);
    procedure OnPSExecute(Sender: TPSScript);
    function OnNeedFile(Sender: TObject;const OrginFileName: string; var FilePath, Output: string): Boolean;
    procedure SetEnabled(bool : boolean);override;
  public
    constructor Create(FileStr: String; StartDisabled : boolean = false);
    destructor Destroy; override;
    function HookExists(const HookName: String): Boolean;override;
    function ExecuteHook(const HookName: String;var Args:TVariantArray; out OutVariant : Variant): Integer;override;
    property Working : boolean read FWorking;
  end;

implementation
uses
  colour_conv,dtmutil,
  {$ifdef mswindows}windows,  MMSystem,{$endif}//MMSystem -> Sounds
  uPSC_std, uPSC_controls,uPSC_classes,uPSC_graphics,uPSC_stdctrls,uPSC_forms, uPSC_menus,
  uPSC_extctrls, uPSC_mml, uPSC_dll, //Compile-libs
  uPSUtils,
  fontloader,
  IOmanager,//TTarget_Exported
  IniFiles,//Silly INI files
  stringutil, //String st00f

  uPSR_std, uPSR_controls,uPSR_classes,uPSR_graphics,uPSR_stdctrls,uPSR_forms, uPSR_mml,
  uPSR_menus, uPSI_ComCtrls, uPSI_Dialogs, uPSR_dll,
  files,
  dialogs,
  dtm, //Dtms!
  uPSR_extctrls, //Runtime-libs
  Graphics, //For Graphics types
  math, //Maths!
  mmath, //Real maths!
  strutils,
  fileutil,
  tpa, //Tpa stuff
  SynRegExpr,
  lclintf,
  httpsend,
  superobject,
  Clipbrd,
  DCPcrypt2,
  DCPhaval,
  DCPmd4, DCPmd5,
  DCPripemd128, DCPripemd160,
  DCPsha1, DCPsha256, DCPsha512,
  DCPtiger,
  SimbaUnit,updateform, mmisc, mmlpsthread;  // for GetTickCount and others.//Writeln

{$ifdef Linux}
  {$define PS_SafeCall}
{$else}
//{$define PS_SafeCall}
{$endif}
{$MACRO ON}
{$ifdef PS_SafeCall}
  {$define extdecl := safecall}
{$else}
  {$define extdecl := register}
{$endif}

procedure psWriteLn(s: string);
begin
  SimbaForm._WriteLn(s);
end;

function TSimbaPSExtension.HookExists(const HookName: String): Boolean;
begin
  Result := False;
  if FWorking then
    if PSInstance.Exec.GetProc(HookName) <> InvalidVal then
      result := True;
end;

function TSimbaPSExtension.ExecuteHook(const HookName: String;var Args: TVariantArray; out OutVariant : Variant): Integer;
begin
  result := SExt_error;
  if not FWorking then
    exit;
  try
    outvariant := PSInstance.ExecuteFunction(Args, HookName);
    result := SExt_ok;
  except
    on e : exception do
      psWriteLn(format('Error in Simba extension (%s): %s',[Self.GetName,e.message]));
  end;
end;

constructor TSimbaPSExtension.Create(FileStr: String; StartDisabled: boolean = false);
begin
  inherited create;
  FWorking := False;
  FClient := TClient.Create('',SimbaForm.Manager);
  FileName := FileStr;
  try
    Script := TStringList.Create;
    Script.LoadFromFile(FileName);
  except
    raise Exception.CreateFmt('File %s could not be read', [FileName]);
  end;
  FEnabled := false;
  PSInstance := nil;
  if not StartDisabled then
    StartExtension;
end;

function TSimbaPSExtension.InitScript: Boolean;
begin
  if not HookExists('init') then
    exit(false);
  result := true;
  try
    PSInstance.ExecuteFunction([], 'init');
  except
    result := false;
  end;
end;

function TSimbaPSExtension.FreeScript: boolean;
var
  bla : variant;
  Args : TVariantArray;
begin
  if not HookExists('Free') then
    exit(false);
  result := ExecuteHook('Free',Args,bla) = SExt_ok;
end;

{$DEFINE MML_EXPORT_THREADSAFE}
{$I ../../Units/MMLAddon/PSInc/Wrappers/other.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/settings.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/bitmap.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/window.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/tpa.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/strings.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/crypto.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/colour.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/colourconv.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/math.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/mouse.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/file.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/keyboard.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/dtm.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/ocr.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/internets.inc}
{$I ../../Units/MMLAddon/PSInc/Wrappers/extensions.inc}
{$I ../../Units/MMLAddon/PSInc/psmethods.inc}

procedure TSimbaPSExtension.RegisterMyMethods(x: TPSScript);
  procedure SetCurrSection(s: string);
  begin
  end;
begin
  with SimbaForm, x do
  begin
    {$i ../../Units/MMLAddon/PSInc/psexportedmethods.inc}
    AddFunction(@ext_SDTMToMDTM,'function SDTMToMDTM(Const DTM: TSDTM): TMDTM;');
    AddFunction(@ext_GetPage,'function GetPage(const url : string) : string');
    AddFunction(@ext_DecompressBZip2,'function DecompressBZip2(const input: string;out output : string; const BlockSize: Cardinal): boolean;');
    AddFunction(@ext_UnTar,'function UnTar(const Input : string; out Content : TStringArray) : boolean;');
    AddFunction(@ext_UnTarEx,'function UnTarEx(const Input : string;const outputdir : string; overwrite : boolean): boolean;');
    AddFunction(@ext_MessageDlg,'function MessageDlg(const aCaption, aMsg: string; DlgType: TMsgDlgType;Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;');
    AddFunction(@ext_InputQuery,'function InputQuery(const ACaption, APrompt : String; var Value : String) : Boolean;');
    AddFunction(@ext_ScriptText,'function ScriptText: string;');
    AddFunction(@ext_GetSelectedText, 'function GetSelectedText: string;');
    AddFunction(@ext_OpenScript,'procedure OpenScript(Name, Data: string; Run: boolean);');
    AddFunction(@ext_OpenScriptEx,'procedure OpenScriptEx(FileName: string; Run: boolean);');
    AddRegisteredPTRVariable('Settings','TMMLSettingsSandbox');
    AddFunction(@ext_GetPageEx,'function GetPageEx(const URL, PostData, MimeType: string): string;');
    AddFunction(@ext_GetJSONValue,'function GetJSONValue(const Data, Value: string): string;');
    AddRegisteredVariable('Simba','TForm');
    AddRegisteredVariable('Simba_MainMenu','TMainMenu');
    AddRegisteredVariable('Client','TClient');
  end;
end;

procedure TSimbaPSExtension.OnPSExecute(Sender: TPSScript);
begin
  Sender.SetVarToInstance('Simba',SimbaForm);
  Sender.SetVarToInstance('Simba_MainMenu',SimbaForm.MainMenu);
  Sender.SetVarToInstance('Client',FClient);
  Sender.SetPointerToData('Settings',@Self.Settings,Sender.FindNamedType('TMMLSettingsSandbox'));
end;

procedure TSimbaPSExtension.SetEnabled(bool: boolean);
var
  temp : variant;
  Args : TVariantArray;
begin
  if bool <> FEnabled then
  begin
    if bool then
    begin;
      if not assigned(PSInstance) then //We enable it for the first time, calls SetEnabled.
        StartExtension
      else
      begin
        if not FWorking then
          Exit;
        if hookexists('attach') then
          ExecuteHook('attach',Args,temp);
      end;
    end else
      if HookExists('detach') then
        ExecuteHook('detach',Args,temp);
  end;
  inherited SetEnabled(bool);
end;


procedure TMufasaBitmapCopyClientToBitmap(self : TMufasaBitmap; Resize : boolean;x,y : integer; xs, ys, xe, ye: Integer);
begin
  self.CopyClientToBitmap(SimbaForm.Manager,resize,x,y,xs,ys,xe,ye);
end;

procedure TSimbaPSExtension.RegisterPSCComponents(Sender: TObject; x: TPSPascalCompiler);
var
  AppPath, ScriptPath: string;
  i: Integer;
begin
  SIRegister_Std(x);
  SIRegister_Controls(x);
  SIRegister_Classes(x, true);
  SIRegister_Graphics(x, true);
  SIRegister_stdctrls(x);
  SIRegister_Forms(x);
  SIRegister_ExtCtrls(x);
  SIRegister_Menus(x);
  SIRegister_ComCtrls(x);
  SIRegister_Dialogs(x);

  AppPath := MainDir + DirectorySeparator;
  ScriptPath := ExtractFileDir(Filename);
  with SimbaForm,x do
  begin
    {$I ../../Units/MMLAddon/PSInc/pscompile.inc}
    AddTypes('TStringArray','Array of String');
    AddConstantN('ExtPath', 'string').SetString({$IFDEF USE_EXTENSIONS}ExtPath{$ELSE}''{$ENDIF});
    for i := 0 to high(VirtualKeys) do
      AddConstantN(Format('VK_%S',[VirtualKeys[i].Str]),'Byte').SetInt(VirtualKeys[i].Key);
  end;
  SIRegister_MML(x);
  RegisterDll_Compiletime(x);

  with x.AddFunction('procedure writeln;').decl do
    with AddParam do
    begin
      OrgName:= 'x';
      Mode:= pmIn;
    end;
  with x.AddFunction('function ToStr:string').decl do
    with addparam do
    begin
      OrgName:= 'x';
      Mode:= pmIn;
    end;
  with x.AddFunction('procedure swap;').decl do
  begin
    with addparam do
    begin
      OrgName:= 'x';
      Mode:= pmInOut;
    end;
    with addparam do
    begin
      OrgName:= 'y';
      Mode:= pmInOut;
    end;
  end;
end;

procedure TSimbaPSExtension.RegisterPSRComponents(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
begin
  RIRegister_Std(x);
  RIRegister_Classes(x, True);
  RIRegister_Controls(x);
  RIRegister_Graphics(x, True);
  RIRegister_stdctrls(x);
  RIRegister_Forms(x);
  RIRegister_ExtCtrls(x);
  RIRegister_Menus(x);
  RIRegister_ComCtrls(x);
  RIRegister_Dialogs(x);
  RegisterDLLRuntime(se);
  RIRegister_MML(x);
{  with x.FindClass('TMufasaBitmap') do
  begin
    RegisterMethod(@TMufasaBitmapCopyClientToBitmap,'CopyClientToBitmap');
  end;}

  se.RegisterFunctionName('WRITELN',@Writeln_,nil,nil);
  se.RegisterFunctionName('TOSTR',@ToStr_,nil,nil);
  se.RegisterFunctionName('SWAP',@swap_,nil,nil);
end;

destructor TSimbaPSExtension.Destroy;
begin
  FClient.free;
  FreeScript;
  if Assigned(PSInstance) then
    FreeAndNil(PSInstance);
  Script.Free;
  inherited;
end;

function TSimbaPSExtension.OnNeedFile(Sender: TObject;
  const OrginFileName: string; var FilePath, Output: string): Boolean;
var
  path: string;
  f: TFileStream;
begin
  with SimbaForm do
    path := FindFile(FilePath,[includepath,  ExtractFileDir(Filename),ExtractFileDir(OrginFileName)]);
  if path = '' then
  begin
    psWriteln(Path + ' doesn''t exist');
    Result := false;
    Exit;
  end;
  FilePath := path;//Yeah!

  try
    f:= TFileStream.Create(UTF8ToSys(Path), fmOpenRead);
    SetLength(Output, f.Size);
    f.Read(Output[1], Length(Output));
    result:= true;
    f.free;
  except
    Result := false;
    psWriteln('TSimbaPSExtension.OnNeedFile');
  end;
end;

procedure TSimbaPSExtension.StartExtension;
begin
  if assigned(PSInstance) then
    exit;//Already started..
  { Create script, and see if the extension is valid. (If it compiles) }
  PSInstance := TPSScript.Create(nil);

  with PSInstance do
  begin
    {$I ../../Units/MMLAddon/PSInc/psdefines.inc}
    Defines.Add('PS_EXTENSION');
    Defines.Add('EXTENSION');
  end;

  PSInstance.Script := Self.Script;
  PSInstance.OnCompImport:=@RegisterPSCComponents;
  PSInstance.OnExecImport:=@RegisterPSRComponents;
  PSInstance.OnCompile:=@RegisterMyMethods;
  PSInstance.OnExecute:=@OnPSExecute;
  PSInstance.OnNeedFile:=@OnNeedFile;
  PSInstance.UsePreProcessor:= True;

  psWriteLn(Format('Loading extension %s', [FileName]));
  try
    FWorking := PSInstance.Compile;
  except
    on e : exception do
      psWriteLn(format('Error in Simba extension (%s) : %s',[FileName,e.message]));
  end;
  if FWorking then
    psWriteLn('Extension Enabled')
  else
  begin
    psWriteLn('Extension Disabled - Did not compile');
    OutputMessages;
  end;

  if InitScript then
    mDebugLn('Init procedure succesfully called')
  else
    mDebugLn('Init procedure didn''t execute right, or couldn''t be found');
  Enabled:= FWorking;
end;

procedure TSimbaPSExtension.OutputMessages;
var
  l: Longint;
begin
  for l := 0 to PSInstance.CompilerMessageCount - 1 do
    psWriteLn(PSInstance.CompilerErrorToStr(l) + ' at line ' + inttostr(PSInstance.CompilerMessages[l].Row));
end;


end.

