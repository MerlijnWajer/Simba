unit lpTIOManager_Windows;
//Depends: TIOManager, TIOManager_Abstract, string, TNativeWindow, TSysProc, Hwnd

{$mode objfpc}{$H+}
{$I Simba.inc}

interface

uses
  Classes, SysUtils, lpcompiler, lptypes, lpClassHelper;

procedure Register_TIOManager(Compiler: TLapeCompiler);

implementation

uses
  iomanager, os_windows, MufasaTypes;

type
  PIOManager = ^TIOManager;
  PNativeWindow = ^TNativeWindow;

//constructor Create;
procedure TIOManager_Init(const Params: PParamArray); lape_extdecl
begin
  PIOManager(Params^[0])^ := TIOManager.Create();
end;

//constructor Create(plugin_dir: string);
procedure TIOManager_InitEx(const Params: PParamArray); lape_extdecl
begin
  PIOManager(Params^[0])^ := TIOManager.Create(PlpString(Params^[1])^);
end;

//function SetTarget(target: TNativeWindow): integer; overload;
procedure TIOManager_SetTarget(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  Pinteger(Result)^ := PIOManager(Params^[0])^.SetTarget(PNativeWindow(Params^[1])^);
end;

//procedure SetDesktop; override;
procedure TIOManager_SetDesktop(const Params: PParamArray); lape_extdecl
begin
  PIOManager(Params^[0])^.SetDesktop;
end;

//function GetProcesses: TSysProcArr; override;
procedure TIOManager_GetProcesses(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PSysProcArr(Result)^ := PIOManager(Params^[0])^.GetProcesses();
end;

//function GetProcessMem(processID: LongInt): Int64; override;
procedure TIOManager_GetProcessMem(const Params: PParamArray; const Result: Pointer); lape_extdecl
begin
  PInt64(Result)^ := PIOManager(Params^[0])^.GetProcessMem(PLongint(Params^[1])^);
end;

//procedure SetTargetEx(Proc: TSysProc); overload;
procedure TIOManager_SetTargetEx(const Params: PParamArray); lape_extdecl
begin
  PIOManager(Params^[0])^.SetTargetEx(PSysProc(Params^[1])^);
end;

//procedure Free();
procedure TIOManager_Free(const Params: PParamArray); lape_extdecl
begin
  PIOManager(Params^[0])^.Free();
end;

procedure Register_TIOManager(Compiler: TLapeCompiler);
begin
  with Compiler do
  begin
    addClass('TIOManager', 'TIOManager_Abstract');

    addGlobalType('UInt32', 'TNativeWindow');

    addGlobalFunc('procedure TIOManager.Init(); overload;', @TIOManager_Init);
    addGlobalFunc('procedure TIOManager.Init(plugin_dir: string); overload;', @TIOManager_InitEx);
    addGlobalFunc('function TIOManager.SetTarget2(target: TNativeWindow): integer;', @TIOManager_SetTarget); //inheritence issue...
    addGlobalFunc('procedure TIOManager.SetDesktop();', @TIOManager_SetDesktop);
    addGlobalFunc('function TIOManager.GetProcesses(): TSysProcArr;', @TIOManager_GetProcesses);
    addGlobalFunc('function TIOManager.GetProcessMem(processID: LongInt): Int64;', @TIOManager_GetProcessMem);
    addGlobalFunc('procedure TIOManager.SetTargetEx(Proc: TSysProc);', @TIOManager_SetTargetEx);
    addGlobalFunc('procedure TIOManager.Free();', @TIOManager_Free);
  end;
end;

end.

