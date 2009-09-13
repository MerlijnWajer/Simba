unit plugins;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,dynlibs;

type
  TMPluginMethod = record
    FuncPtr : pointer;
    FuncStr : string;
  end;

  TMPlugin = record
    Methods : Array of TMPluginMethod;
    dllHandle : TLibHandle;
    filename : string;
    MethodLen : integer;
  end;
  TMPluginArray = array of TMPlugin;

  { TMPlugins }

  TMPlugins = class (TObject)
  private
    Plugins : TMPluginArray;
    PluginLen : integer;
    procedure FreePlugins;
  public
    PluginDirs : TStringList;
    procedure ValidateDirs;
    procedure LoadPluginsDir( DirIndex : integer);
    function LoadPlugin(PluginName : string) : integer;
    property Count : integer read PluginLen;
    property MPlugins : TMPluginArray read Plugins;
    constructor Create;
    destructor Destroy;override;
  end;



implementation

uses
  MufasaTypes,FileUtil;

{ TMPlugins }

procedure TMPlugins.FreePlugins;
var
  I : integer;
begin
  for i := 0 to PluginLen - 1 do
  begin;
    if (Plugins[i].dllHandle > 0) then
    try
      FreeLibrary(Plugins[i].dllHandle);
    except
    end;
  end;
  SetLength(Plugins,0);
  PluginLen:= 0;
end;

procedure TMPlugins.ValidateDirs;
var
  i : integer;
  TempStr : string;
begin
  for i := 0 to PluginDirs.Count - 1 do
  begin;
    if DirectoryExists(PluginDirs.Strings[i]) = false then
      raise Exception.createFMT('Directory(%s) does not exist',[PluginDirs[i]]);
    TempStr := PluginDirs.Strings[i];
    if (TempStr[Length(TempStr)] <> DS) then
    begin;
      if (TempStr[Length(TempStr)] = '\') or (TempStr[Length(TempStr)] = '/') then
        TempStr[Length(TempStr)] := DS
      else
        TempStr := TempStr + DS;
      PluginDirs.Strings[i] := TempStr;
    end;
  end;
end;

procedure TMPlugins.LoadPluginsDir(DirIndex: integer);
var
  PlugExt: String = {$IFDEF LINUX}'*.so';{$ELSE}'*.dll';{$ENDIF}
  FileSearcher : TSearchRec;
begin
  if (DirIndex < 0) or (DirIndex >= PluginDirs.Count) then
    Exit;
  if FindFirst(PluginDirs.Strings[DirIndex] + PlugExt, faAnyFile, FileSearcher) <> 0 then
  begin;
    FindClose(FileSearcher);
    Exit;
  end;
  repeat
    LoadPlugin(FileSearcher.Name);
  until FindNext(FileSearcher) <> 0;
  FindClose(FileSearcher);
end;

function TMPlugins.LoadPlugin(PluginName: string): Integer;
var
  i, ii : integer;
  pntrArrc     :  function : integer; stdcall;
  GetFuncInfo  :  function (x: Integer; var ProcAddr: Pointer; var ProcDef: PChar) : Integer; stdcall;
  GetTypeCount :  function : Integer; stdcall;
  GetTypeInfo  :  function (x: Integer; var sType, sTypeDef: string): Integer; stdcall;
  PD : PChar;
  pntr : Pointer;
  arrc : integer;
  Status : LongInt;
  PlugExt: String = {$IFDEF LINUX}'.so';{$ELSE}'.dll';{$ENDIF}
begin
  ii := -1;
  Result := -1;
  ValidateDirs;
  PluginName := ExtractFileNameWithoutExt(PluginName);
  for i := 0 to PluginDirs.Count - 1 do
    if FileExists(PluginDirs.Strings[i] + Pluginname + PlugExt) then
    begin;
      if ii <> -1 then
        Raise Exception.CreateFmt('Plugin(%s) has been found multiple times',[PluginName]);
      ii := i;
    end;
  for i := 0 to PluginLen - 1 do
    if Plugins[i].filename = (PluginDirs.Strings[ii] + PluginName + PlugExt) then
      Exit(i);
  pd := StrAlloc(255);
  SetLength(Plugins,PluginLen + 1);
  Writeln(Format('Loading plugin %s at %s',[PluginName,PluginDirs.Strings[ii]]));
  Plugins[PluginLen].filename:= PluginDirs.Strings[ii] + Pluginname + PlugExt;
  Plugins[PluginLen].dllHandle:= LoadLibrary(PChar(Plugins[PluginLen].filename));
  if Plugins[PluginLen].dllHandle = 0 then
    Raise Exception.CreateFMT('Error loading plugin %s',[Plugins[PluginLen].filename]);
  Pointer(pntrArrc) := GetProcAddress(Plugins[PluginLen].dllHandle, PChar('GetFunctionCount'));
  if @pntrArrc = nil then
    Raise Exception.CreateFMT('Error loading plugin %s',[Plugins[PluginLen].filename]);
  arrc := pntrArrc();
  SetLength(Plugins[PluginLen].Methods, ArrC);
  Pointer(GetFuncInfo) := GetProcAddress(Plugins[PluginLen].dllHandle, PChar('GetFunctionInfo'));
  if @GetFuncInfo = nil then
    Raise Exception.CreateFMT('Error loading plugin %s',[Plugins[PluginLen].filename]);
  Plugins[PluginLen].MethodLen := Arrc;
  for ii := 0 to ArrC-1 do
  begin;
    if (GetFuncInfo(ii, pntr, pd) < 0) then
      Continue;
    Plugins[Pluginlen].Methods[ii].FuncPtr := pntr;
    Plugins[Pluginlen].Methods[ii].FuncStr := pd;
  end;
  Result := PluginLen;
  inc(PluginLen);
  StrDispose(pd);

end;


constructor TMPlugins.Create;
begin
  inherited Create;
  PluginLen := 0;
  PluginDirs := TStringList.Create;
end;

destructor TMPlugins.Destroy;
begin
  FreePlugins;
  PluginDirs.Free;
  inherited Destroy;
end;

end.

