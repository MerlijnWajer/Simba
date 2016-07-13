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

    psexportedmethods.inc for the Mufasa Macro Library
}

{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@CallProc,'function CallProc(ProcName: string; var V: TVariantArray): Variant;');
AddFunction(@ThreadSafeCall,'function ThreadSafeCall(ProcName: string; var V: TVariantArray): Variant;');
AddFunction(@pswriteln,'procedure Writeln(x: string);'); //PS defines a special, keep this for CPascal
AddFunction(@ps_debugln,'procedure DebugLn(str : string);');
{$ENDIF}


{ DTM }
SetCurrSection('DTM');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@ps_SetDTMName, 'procedure SetDTMName(DTM : integer;const name : string);');
AddFunction(@ps_DTMFromString, 'function DTMFromString(const DTMString: String): Integer;');
AddFunction(@ps_FreeDTM, 'procedure FreeDTM(DTM: Integer);');
AddFunction(@ps_FindDTM, 'function FindDTM(DTM: Integer; var x, y: Integer; xs, ys, xe, ye: Integer): Boolean;');
AddFunction(@ps_FindDTMs, 'function FindDTMs(DTM: Integer; var p: TPointArray; xs, ys, xe, ye: Integer): Boolean;');
AddFunction(@ps_FindDTMRotatedSE, 'function FindDTMRotatedSE(DTM: Integer; var x, y: Integer; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: Extended): Boolean;');
AddFunction(@ps_FindDTMRotatedAlternating, 'function FindDTMRotatedAlternating(DTM: Integer; var x, y: Integer; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: Extended): Boolean;');
AddFunction(@ps_FindDTMsRotatedSE, 'function FindDTMsRotatedSE(DTM: Integer; var Points: TPointArray; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: T2DExtendedArray) : Boolean;');
AddFunction(@ps_FindDTMsRotatedAlternating, 'function FindDTMsRotatedAlternating(DTM: Integer; var Points: TPointArray; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: T2DExtendedArray) : Boolean;');
AddFunction(@ps_addDTM, 'function AddMDTM(const d: TMDTM): Integer;');
AddFunction(@ps_addDTM, 'function AddDTM(const d: TMDTM): Integer;');
AddFunction(@ps_DTMExists, 'function DTMExists(index : integer) : boolean;');
AddFunction(@ps_addTSDTM, 'function AddSDTM(const d: TSDTM): Integer;');
AddFunction(@ps_GetDTM ,'function GetDTM(index: Integer) : TMDTM');
AddFunction(@ps_SDTMToMDTM, 'function SDTMToMDTM(Const DTM: TSDTM): TMDTM;');
{$ENDIF}
AddFunction(@ps_PrintDTM, 'procedure PrintDTM(const DTM : TMDTM);');
AddFunction(@ps_MDTMToSDTM, 'function MDTMToSDTM(Const DTM: TMDTM): TSDTM;');
AddFunction(@ps_CreateDTMPoint,'function CreateDTMPoint(x,y,c,t,asz : integer; bp : boolean) : TMDTMPoint;');

{maths}
SetCurrSection('Math');
AddFunction(@ps_round,'function Round(e:extended) : integer');
AddFunction(@ps_ceil,'function ceil(e : extended) : integer');
AddFunction(@ps_floor,'function floor(e : extended) : integer');
AddFunction(@ps_pow,'function pow(base,exponent : extended) : extended');
AddFunction(@ps_exp,'function exp(exponent : extended) : extended');
AddFunction(@ps_RiemannGauss,'function RiemannGauss(Xstart,StepSize,Sigma : extended; AmountSteps : integer) : extended;');
AddFunction(@ps_DiscreteGauss,'function DiscreteGauss(Xstart,Xend : integer; sigma : extended) : TExtendedArray;');
AddFunction(@ps_GaussMatrix,'function GaussMatrix(N : integer; sigma : extended) : T2DExtendedArray;');
AddFunction(@ps_max,'function Max(a, b: Integer): Integer;');
AddFunction(@ps_min,'function Min(a, b: Integer): Integer;');
AddFunction(@ps_minE,'function MinE(a, b: extended): Extended;');
AddFunction(@ps_maxE,'function MaxE(a, b: extended): Extended;');
AddFunction(@ps_iAbs,'function iAbs(a : integer) : integer;');
AddFunction(@ps_ArcTan2,'function ArcTan2(y,x : extended) : extended;');
AddFunction(@ps_IntToBox,'function IntToBox(xs,ys,xe,ye : integer) : TBox;');
AddFunction(@ps_IntInBox,'function IntInBox(x, y: Integer; Box: TBox): Boolean;');
AddFunction(@ps_PointToBox,'function PointToBox(topLeft,bottomRight: TPoint): TBox;');
AddFunction(@ps_PointInBox,'function PointInBox(PT : TPoint; Box: TBox): Boolean;');
AddFunction(@ps_sqr,'function Sqr(e : extended) : extended;');
AddFunction(@ps_point,'function Point(x,y:integer) : TPoint;');
AddFunction(@ps_Distance,'function Distance(xs,ys,xe,ye : integer) : integer;');
AddFunction(@ps_hypot,'function Hypot(X, Y: Extended): Extended;');
AddFunction(@ps_RandomRange,'function RandomRange(aFrom,aTo: Integer): Integer;');
AddFunction(@ps_Random,'function Random(Int: integer): integer;');
AddFunction(@ps_RandomE,'function RandomE: extended;');
AddFunction(@ps_incex,'procedure IncEx(var x : integer; increase : integer);');
AddFunction(@ps_DecEx,'procedure DecEx(var x : integer; Decrease : integer);');
AddFunction(@ps_BinCoe,'function BinCoe(a, b: LongInt): Extended;');
AddFunction(@ps_FixD,'function FixD(Degrees : extended) : Extended;');
AddFunction(@ps_InRange,'function InRange(const value,min,max : integer) : boolean;');
AddFunction(@ps_logn,'function logn(base, x : extended): extended;');
AddFunction(@ps_log10,'function log10(f : extended): extended;');
AddFunction(@ps_ln,'function ln(x : extended) : extended;');
AddFunction(@ps_inttohex,'function IntToHex(number : integer) : string');
AddFunction(@ps_hextoint,'function HexToInt(Hex : string) : integer');
AddFunction(@ps_sar,'function sar(AValue : longint; shift : byte) : longint;');
AddFunction(@ps_ror,'function ror(num : longword; shift : byte) : LongWord;');
AddFunction(@ps_rol,'function rol(num : longword; shift : byte) : LongWord;');
AddFunction(@ps_tan, 'function tan(e: extended): extended;');
AddFunction(@ps_radians, 'function radians(e: extended): extended;');
AddFunction(@ps_degrees, 'function degrees(e: extended): extended;');
AddFunction(@ps_ArcSin, 'function ArcSin(e: extended): extended;');
AddFunction(@ps_ArcCos, 'function ArcCos(e: extended): extended;');
AddFunction(@ps_ArcTan, 'function ArcTan(e: extended): extended;');
AddFunction(@ps_Cotan, 'function Cotan(e: extended): extended;');
AddFunction(@ps_Secant, 'function Secant(e: extended): extended;');
AddFunction(@ps_Cosecant, 'function Cosecant(e: extended): extended;');
AddFunction(@ps_Cot, 'function Cot(e: extended): extended;');
AddFunction(@ps_Sec, 'function Sec(e: extended): extended;');
AddFunction(@ps_Csc, 'function Csc(e: extended): extended;');
AddFunction(@ps_Cosh, 'function Cosh(e: extended): extended;');
AddFunction(@ps_Sinh, 'function Sinh(e: extended): extended;');
AddFunction(@ps_Tanh, 'function Tanh(e: extended): extended;');
AddFunction(@ps_CotH, 'function CotH(e: extended): extended;');
AddFunction(@ps_SecH, 'function SecH(e: extended): extended;');
AddFunction(@ps_CscH, 'function CscH(e: extended): extended;');
AddFunction(@ps_ArcCosh, 'function ArcCosh(e: extended): extended;');
AddFunction(@ps_ArcSinh, 'function ArcSinh(e: extended): extended;');
AddFunction(@DecRet, 'function DecRet(e: Extended): Extended;');
AddFunction(@ps_MinA, 'function MinA(a: TIntegerArray): Integer;');
AddFunction(@ps_MaxA, 'function MaxA(a: TIntegerArray): Integer;');
AddFunction(@ps_Sum64IntArr, 'function Sum64IntArr(const Arr: TIntegerArray): Int64;');
AddFunction(@ps_FixRad, 'function FixRad(rad: Extended): Extended;');
AddFunction(@ps_MiddleBox,'function MiddleBox(b : TBox) : TPoint;');
AddFunction(@ps_InAbstractBox, 'function InAbstractBox(x1, y1, x2, y2, x3, y3, x4, y4: Integer; x, y: Integer): Boolean;');

{$IFNDEF MML_EXPORT_THREADSAFE}
{window}
SetCurrSection('Window');
AddFunction(@ps_Freeze, 'function Freeze: boolean;');
AddFunction(@ps_Unfreeze, 'function Unfreeze: boolean;');
AddFunction(@ps_GetClientDimensions, 'procedure GetClientDimensions(var w, h:integer);');
AddFunction(@ps_GetClientPosition, 'procedure GetClientPosition(var left, top:integer);');
AddFunction(@ps_SetTargetBitmap,'function SetTargetBitmap(Bitmap : integer): integer;');
AddFunction(@ps_SetTargetArray, 'function SetTargetArray(P: Integer; w, h: integer): integer;');
AddFunction(@ps_SetEIOSTarget, 'function SetEIOSTarget(name, initargs: String): integer;');
AddFunction(@ps_MouseSetClientArea, 'function MouseSetClientArea(x1, y1, x2, y2: integer): boolean;');
AddFunction(@ps_MouseResetClientArea, 'procedure MouseResetClientArea;');
AddFunction(@ps_ImageSetClientArea, 'function ImageSetClientArea(x1, y1, x2, y2: integer): boolean;');
AddFunction(@ps_ImageResetClientArea, 'procedure ImageResetClientArea;');
AddFunction(@ps_SetImageTarget,'procedure SetImageTarget(idx: integer);');
AddFunction(@ps_SetKeyMouseTarget,'procedure SetKeyMouseTarget(idx: integer);');
AddFunction(@ps_GetImageTarget,'function GetImageTarget: integer;');
AddFunction(@ps_GetKeyMouseTarget,'function GetKeyMouseTarget: integer;');
AddFunction(@ps_ExportImageTarget,'function ExportImageTarget : TTarget_Exported;');
AddFunction(@ps_ExportKeyMouseTarget,'function ExportKeyMouseTarget : TTarget_Exported;');
AddFunction(@ps_FreeTarget,'procedure FreeTarget(idx: integer);');
AddFunction(@ps_SetDesktopAsClient,'procedure SetDesktopAsClient;');
AddFunction(@ps_ActivateClient, 'procedure ActivateClient;');
AddFunction(@ps_IsTargetValid, 'function IsTargetValid: boolean;');
AddFunction(@ps_GetNativeWindow, 'function GetNativeWindow: integer;');
{$ENDIF}

{files}
SetCurrSection('Files');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@ps_CreateFile, 'function CreateFile(const Path: string): Integer;');
AddFunction(@ps_OpenFile, 'function OpenFile(const Path: string; Shared: Boolean): Integer;');
AddFunction(@ps_RewriteFile, 'function RewriteFile(const Path: string; Shared: Boolean): Integer;');
AddFunction(@ps_AppendFile, 'function AppendFile(const Path: string): Integer;');
AddFunction(@ps_CloseFile, 'procedure CloseFile(FileNum: Integer);');
AddFunction(@ps_EndOfFile, 'function EndOfFile(FileNum: Integer): Boolean;');
AddFunction(@ps_FileSize, 'function FileSize(FileNum: Integer): LongInt;');
AddFunction(@ps_ReadFileString, 'function ReadFileString(FileNum: Integer; var s: string; x: Integer): Boolean;');
AddFunction(@ps_WriteFileString, 'function WriteFileString(FileNum: Integer; s: string): Boolean;');
AddFunction(@ps_SetFileCharPointer, 'function SetFileCharPointer(FileNum, cChars, Origin: Integer): Integer;');
AddFunction(@ps_FilePointerPos, 'function FilePointerPos(FileNum: Integer): Integer;');
{$ENDIF}
AddFunction(@ps_DirectoryExists,'function DirectoryExists(const DirectoryName : string ) : Boolean;');
AddFunction(@ps_CreateDirectory,'function CreateDirectory(const DirectoryName : string) : boolean;');
AddFunction(@ps_FileExists,'function FileExists (const FileName : string ) : Boolean;');
AddFunction(@ps_ForceDirectories,'function ForceDirectories(const dir : string) : boolean;');
AddFunction(@ps_GetFiles,'function GetFiles(const Path, Ext : string) : TStringArray;');
AddFunction(@ps_GetDirectories,'function GetDirectories(const path : string) : TStringArray;');
AddFunction(@ps_DeleteFile, 'function DeleteFile(const Filename: string): Boolean;');
AddFunction(@ps_RenameFile, 'function RenameFile(const Oldname, NewName: string): Boolean;');
AddFunction(@ps_WriteINI,'procedure WriteINI(const Section, KeyName, NewString, FileName: string);');
AddFunction(@ps_ReadINI,'function ReadINI(const Section, KeyName, FileName: string): string;');
AddFunction(@ps_DeleteINI,'procedure DeleteINI(const Section, KeyName, FileName: string);');
AddFunction(@ps_ExtractFileExt,'function ExtractFileExt(const FileName: string): string;');
AddFunction(@ps_DeleteDirectory, 'function DeleteDirectory(const Dir: String; const Empty: Boolean): Boolean;');

{other}
SetCurrSection('Other');
AddFunction(@ps_Wait, 'procedure wait(t: LongWord);');
AddFunction(@ps_Wait, 'procedure Sleep(t: LongWord);');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@ps_GetTClient,'function GetTClient : TClient;');
AddFunction(@ps_SetSupressExceptions, 'procedure SetSupressExceptions(Supress : boolean);');
AddFunction(@ps_SaveScreenshot,'procedure SaveScreenshot(FileName: string);');
AddFunction(@ps_TerminateScript,'procedure TerminateScript;');
AddFunction(@ps_AddOnTerminate,'function AddOnTerminate(const proc : string) : Boolean;');
AddFunction(@ps_DeleteOnTerminate,'function DeleteOnTerminate(const proc : string) : Boolean;');
{$ENDIF}
AddFunction(@ps_now,'function Now: TDateTime;');
AddFunction(@ps_date,'function Date : TDateTime;');
AddFunction(@ps_GetTickCount, 'function GetSystemTime: LongWord;');
AddFunction(@ps_GetTickCount, 'function GetTickCount: LongWord;');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@ps_GetTimeRunning,'function GetTimeRunning: LongWord;');
{$ENDIF}
AddFunction(@ps_DecodeTime,'procedure DecodeTime(DateTime : TDateTime; var Hour,Min,Sec,MSec : word);');
AddFunction(@ps_DecodeDate,'procedure DecodeDate ( const SourceDate  : TDateTime; var Year, Month, Day  : Word );');
AddFunction(@ps_ConvertTime,'procedure ConvertTime(Time: integer; var h, m, s: integer);');
AddFunction(@ps_ConvertTime64,'procedure ConvertTime64(time: int64; var y, m, w, d, h, min, s: integer);');
AddFunction(@ps_HakunaMatata,'procedure HakunaMatata;');
AddFunction(@ps_Simba,'procedure Simba;');
AddFunction(@ps_PlaySound,'procedure PlaySound(Sound : string);');
AddFunction(@ps_StopSound,'procedure StopSound;');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@ps_DisplayDebugImgWindow,'procedure DisplayDebugImgWindow(w, h: integer);');
AddFunction(@ps_DrawBitmapDebugImg,'procedure DrawBitmapDebugImg(bmp: integer);');
AddFunction(@ps_GetDebugBitmap,'function GetDebugBitmap: integer;');
AddFunction(@ps_ClearDebugImg,'procedure ClearDebugImg;');
AddFunction(@ps_ClearDebug,'procedure ClearDebug;');
AddFunction(@ps_Status,'procedure Status(Status : string);');
AddFunction(@ps_Disguise,'procedure Disguise(Caption : string);');
AddFunction(@ps_SetScriptProp, 'function SetScriptProp(Prop : TSP_Property; Value: TVariantArray): boolean;');
AddFunction(@ps_GetScriptProp, 'function GetScriptProp(Prop : TSP_Property;var Value: TVariantArray): boolean;');
AddFunction(@ps_InputQuery,'function InputQuery(const ACaption, APrompt : String; var Value : String) : Boolean;');
AddFunction(@ps_ShowMessage,'procedure ShowMessage(msg : string);');
AddFunction(@ps_messageBox,'function MessageBox(Text, Caption: string; Flags: LongInt): Integer;');
AddFunction(@ps_MessageDlg,'function MessageDlg(const Caption, Msg: string; DlgType: TMsgDlgType;  Buttons: TMsgDlgButtons) : integer;');
AddFunction(@ps_ShowBalloonHint, 'procedure ShowBalloonHint(const Title, Hint: string; const Timeout: Integer; const Flag: TBalloonFlags);');
AddFunction(@ps_SetClipBoard, 'procedure SetClipBoard(const Data: string);');
AddFunction(@ps_GetClipBoard, 'function GetClipBoard: string;');
AddFunction(@ps_GetProcesses, 'function GetProcesses: TSysProcArr;');
AddFunction(@ps_GetProcessMem, 'function GetProcessMem(processID: LongInt): Int64;');
AddFunction(@ps_GetProcessID, 'function GetProcessID : LongInt;');
AddFunction(@ps_SetTarget, 'procedure SetTarget(Proc: TSysProc);');
{$ENDIF}

{string}
SetCurrSection('String');
AddFunction(@ps_Capitalize,'function Capitalize(str : string) : string;');
AddFunction(@ps_CompressString,'function CompressString(const Str : string) : string;');
AddFunction(@ps_DecompressString,'function DecompressString(const Compressed : string) : string;');
AddFunction(@ps_Base64Encode,'function Base64Encode(const str : string) : string;');
AddFunction(@ps_Base64Decode,'function Base64Decode(const str : string) : string;');
AddFunction(@ps_Format,'function Format(const fmt : string;const args : array of const) : string;');
AddFunction(@ps_LevDist, 'function LevDistance(src, target: string): Integer;');
AddFunction(@ps_NormLevDist, 'function NormLevDistance(src, target: string): Extended;');
AddFunction(@ps_StringMatch, 'function StringMatch(checkCompare, goalCompare: string): extended;');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(nil,'function ToStr(x) : string;');
{$ENDIF}
AddFunction(@ps_Between,'function Between(s1, s2, str: string): string;');
AddFunction(@ps_MultiBetween, 'function MultiBetween(str, s1, s2: string): TStringArray;');
AddFunction(@ps_IntToStr, 'function IntToStr(value: Integer): String;');
AddFunction(@ps_FloatToStr, 'function FloatToStr(value: Extended): String;');
AddFunction(@ps_BoolToStr, 'function BoolToStr(value: Boolean): String;');
AddFunction(@ps_StrToInt, 'function StrToInt(value: String): Integer;');
AddFunction(@ps_StrToIntDef, 'function StrToIntDef(value: String; default: Integer): Integer;');
AddFunction(@ps_StrToFloat, 'function StrToFloat(value: String): Extended;');
AddFunction(@ps_StrToFloatDef, 'function StrToFloatDef(value: String; default: Extended): Extended;');
AddFunction(@ps_StrToBool, 'function StrToBool(value: String): Boolean;');
AddFunction(@ps_StrToBoolDef, 'function StrToBoolDef(value: String; default: Boolean): Boolean;');
AddFunction(@ps_ExtractFromStr,'function ExtractFromStr( Str : string; Extract : StrExtr) : string;');
AddFunction(@ps_Replace,'function Replace(Text, FindStr, ReplaceStr: string; Flags: TReplaceFlags): string;');
AddFunction(@ps_Replace,'function ReplaceWrap(Text, FindStr, ReplaceStr: string; Flags: TReplaceFlags): string;');
AddFunction(@ps_Implode,'function Implode(Glue: string; Pieces: TStringArray): string;');
AddFunction(@ps_Explode,'function Explode(del, str: string): TStringArray;');
AddFunction(@ps_explodewrap,'procedure ExplodeWrap(del, str: string; var res : TStringArray);');
AddFunction(@ps_PadL,'function Padl(s: String; i: longInt): String;');
AddFunction(@Ps_Padz,'function Padz(s: String; i: longInt): String;');
AddFunction(@ps_padR,'function Padr(s: String; i: longInt): String;');
AddFunction(@ps_ExecRegExpr,'function ExecRegExpr( const RegExpr, InputStr : String) : boolean;');
AddFunction(@ps_SplitRegExpr,'procedure SplitRegExpr( const RegExpr, InputStr : String; Pieces : TStringList);');
AddFunction(@ps_ReplaceRegExpr,'function ReplaceRegExpr( const RegExpr, InputStr, ReplaceStr : String; UseSubstitution : boolean) : String;');
AddFunction(@ps_PosEx, 'function PosEx(needle, haystack: String; offset: integer): integer;');
AddFunction(@ps_IsArrInStr, 'function IsArrInStr(strArr: TStringArray; s: string): boolean;');
AddFunction(@ps_PosMulti, 'function PosMulti(const SubStr: String; Text: string): TIntegerArray;');

{crypto}
SetCurrSection('Crypto');
AddFunction(@ps_hash, 'function hash(const HashType: THashType; const Data: string): string;');
AddFunction(@ps_haval, 'function haval(const Data: string): string;');
AddFunction(@ps_md4, 'function md4(const Data: string): string;');
AddFunction(@ps_md5, 'function md5(const Data: string): string;');
AddFunction(@ps_ripemd128, 'function ripemd128(const Data: string): string;');
AddFunction(@ps_ripemd160, 'function ripemd160(const Data: string): string;');
AddFunction(@ps_sha1, 'function sha1(const Data: string): string;');
AddFunction(@ps_sha256, 'function sha256(const Data: string): string;');
AddFunction(@ps_sha384, 'function sha384(const Data: string): string;');
AddFunction(@ps_sha512, 'function sha512(const Data: string): string;');
AddFunction(@ps_tiger, 'function tiger(const Data: string): string;');
AddFunction(@ps_rc2_encrypt, 'procedure rc2_encrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc2_decrypt, 'procedure rc2_decrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc4_encrypt, 'procedure rc4_encrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc4_decrypt, 'procedure rc4_decrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc5_encrypt, 'procedure rc5_encrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc5_decrypt, 'procedure rc5_decrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc6_encrypt, 'procedure rc6_encrypt(const Key: string; const HashType: THashType; var Data: string);');
AddFunction(@ps_rc6_decrypt, 'procedure rc6_decrypt(const Key: string; const HashType: THashType; var Data: string);');

{web}
SetCurrSection('Web');
AddFunction(@ps_OpenWebPage,'procedure OpenWebPage(const url : string);');
{$IFNDEF MML_EXPORT_THREADSAFE}
AddFunction(@ps_GetPage,'function GetPage(const url : string): string;');
AddFunction(@ps_InitializeHTTPClient,'function InitializeHTTPClient(HandleCookies: Boolean): Integer;');
AddFunction(@ps_InitializeHTTPClient,'function InitializeHTTPClientWrap(HandleCookies: Boolean): Integer;');
AddFunction(@ps_FreeHTTPClient,'procedure FreeHTTPClient(Client: Integer);');
AddFunction(@ps_GetHTTPPage,'function GetHTTPPage(Client: Integer;const URL: string): string;');
AddFunction(@ps_SetHTTPUserAgent,'procedure SetHTTPUserAgent(Client: Integer;const Agent: string);');
AddFunction(@ps_PostHTTPPage,'function PostHTTPPage(Client: Integer;const Url,PostData: string): string;');
AddFunction(@ps_PostHTTPPageEx,'function PostHTTPPageEx(Client: Integer;const Url: string): string;');
AddFunction(@ps_ClearPostData,'procedure ClearPostData(Client: Integer);');
AddFunction(@ps_AddPostVariable,'procedure AddPostVariable(Client: Integer;const VarName, VarValue: string);');
AddFunction(@ps_GetRawHeaders,'function GetRawHeaders(Client: Integer): string;');
AddFunction(@ps_SetProxy,'procedure SetProxy(Client : Integer; pHost, pPort : String);');
{$ENDIF}

{socket}
{$IFNDEF MML_EXPORT_THREADSAFE}
SetCurrSection('Socket');
AddFunction(@ps_CreateSocket, 'function CreateSocket: integer;');
AddFunction(@ps_FreeSocket, 'procedure FreeSocket(Index: integer);');
AddFunction(@ps_ConnectSocket, 'procedure ConnectSocket(Client: integer; IP, Port: string);');
AddFunction(@ps_BindSocket, 'procedure BindSocket(Client: integer; IP, Port: string);');
AddFunction(@ps_ListenSocket, 'procedure ListenSocket(Client: integer);');
AddFunction(@ps_AcceptSocket, 'function AcceptSocket(Client: integer): integer;');
AddFunction(@ps_CloseSocket, 'procedure CloseSocket(Client: integer);');
AddFunction(@ps_RecvSocket, 'function RecvSocket(Client: integer): string;');
AddFunction(@ps_RecvSocketStr, 'function RecvSocketStr(Client: integer): string;');
AddFunction(@ps_RecvSocketEx, 'function RecvSocketEx(Client, Length: integer): string;');
AddFunction(@ps_SendSocket, 'procedure SendSocket(Client: integer; Data: string);');
AddFunction(@ps_SetSocketTimeout, 'procedure SetTimeout(Client, Time: integer);');
AddFunction(@ps_SocketInfo, 'procedure SocketInfo(Client: integer; out IP, Port: string);');
{$ENDIF}

{ Color Conversions and Speed }
SetCurrSection('Color Convert');
AddFunction(@ps_ColorToRGB, 'procedure ColorToRGB(Color: integer; var r, g, b: Integer);');
AddFunction(@ps_RGBToColor, 'function RGBtoColor(r, g, b: Integer): TColor;');
AddFunction(@ps_ColorToHSL, 'procedure ColorToHSL(Color: Integer; var h, s, l: Extended);');
AddFunction(@ps_HSLToColor, 'function HSLToColor(H, S, L: Extended): TColor;');
AddFunction(@ps_ColorToXYZ, 'procedure ColorToXYZ(Color: Integer; var x, y, z: Extended);');
AddFunction(@ps_XYZToColor, 'function XYZToColor(X, Y, Z: Extended): TColor;');
AddFunction(@ps_RGBToHSL, 'procedure RGBToHSL(R, G, B: Integer; var h, s, l: Extended);');
AddFunction(@ps_HSLToRGB, 'procedure HSLtoRGB(H, S, L: extended; var R, G ,B: Integer);');
AddFunction(@ps_RGBToXYZ, 'procedure RGBToXYZ(R, G, B: Integer;var x, y ,z: Extended);');
AddFunction(@ps_XYZToRGB, 'procedure XYZToRGB(X, Y, Z: Extended; var R, G, B: Integer);');
AddFunction(@ps_XYZToHSL, 'procedure XYZToHSL(X, Y, Z: Extended; out H, S, L: Extended);');
AddFunction(@ps_HSLToXYZ, 'procedure HSLToXYZ(H, S, L: Extended; out X, Y, Z: Extended);');
AddFunction(@ps_XYZtoCIELab, 'procedure XYZtoCIELab(X, Y, Z: Extended; out L, a, b: Extended);');
AddFunction(@ps_CIELabtoXYZ, 'procedure CIELabtoXYZ(L, a, b: Extended; out X, Y, Z: Extended);');
AddFunction(@ps_CIELabToRGB, 'procedure CIELabToRGB(L, a, b: Extended; out rr, gg, bb: Integer);');
AddFunction(@ps_RGBToCIELab, 'procedure RGBToCIELab(rr, gg, bb: integer; out L, a, b: Extended);');
AddFunction(@ps_CIELabToColor, 'function CIELabToColor(L, a, b: Extended): TColor;');
AddFunction(@ps_ColorToCIELab, 'procedure ColorToCIELab(Color: integer; out L, a, b: Extended);');
AddFunction(@ps_CIELabToHSL, 'procedure CIELabToHSL(L, a, b: Extended; out HH, SS, LL: Extended);');
AddFunction(@ps_HSLToCIELab, 'procedure HSLToCIELab(HH, SS, LL: Extended; out L, a, b: Extended);');

{$IFNDEF MML_EXPORT_THREADSAFE}
{ Color Finding }
SetCurrSection('Color');
AddFunction(@ps_SetColorToleranceSpeed, 'procedure SetColorToleranceSpeed(cts: integer);');
AddFunction(@ps_GetToleranceSpeed, 'function GetToleranceSpeed: Integer;');
AddFunction(@ps_SetToleranceSpeed2Modifiers, 'procedure SetToleranceSpeed2Modifiers(nHue, nSat: Extended);');
AddFunction(@ps_GetToleranceSpeed2Modifiers, 'procedure GetToleranceSpeed2Modifiers(var hMod, sMod: Extended);');
AddFunction(@ps_SetToleranceSpeed3Modifier, 'procedure SetToleranceSpeed3Modifier(Modifier: Extended);');
AddFunction(@ps_GetToleranceSpeed3Modifier, 'function GetToleranceSpeed3Modifier: Extended;');
AddFunction(@ps_GetColor,'function GetColor(x, y: Integer): Integer;');
AddFunction(@ps_GetColors,'function GetColors(const Coords : TPointArray) : TIntegerArray;');
AddFunction(@ps_GetColorsWrap,'procedure GetColorsWrap(Coords : TPointArray; var Colors :TIntegerArray);');
AddFunction(@ps_FindColor, 'function FindColor(var x, y: integer; color, xs, ys, xe, ye: integer): boolean;');
AddFunction(@ps_FindColorTolerance, 'function FindColorTolerance(var x, y: integer; color, xs, ys, xe, ye, tol: integer): boolean;');
AddFunction(@ps_FindColors, 'function FindColors(var TPA: TPointArray; color, xs, ys, xe, ye: integer): boolean;');
AddFunction(@ps_SimilarColors,'function SimilarColors(Col1, Col2, Tolerance: integer): boolean');
AddFunction(@ps_CountColor,'function CountColor(Color, xs, ys, xe, ye: Integer): Integer;');
AddFunction(@ps_CountColorTolerance,'function CountColorTolerance(Color, xs, ys, xe, ye, Tolerance: Integer): Integer;');
AddFunction(@ps_FindColorsTolerance,'function FindColorsTolerance(var Points: TPointArray; Color, xs, ys, xe, ye, Tolerance: Integer): Boolean;');
AddFunction(@ps_FindColorSpiral,'function FindColorSpiral(var x, y: Integer; color, xs, ys, xe, ye: Integer): Boolean;');
AddFunction(@ps_FindColorSpiralTolerance,'function FindColorSpiralTolerance(var x, y: Integer; color, xs, ys, xe, ye,Tol: Integer): Boolean;');
AddFunction(@ps_FindColorsSpiralTolerance,'function FindColorsSpiralTolerance(x, y: Integer; var Points: TPointArray; color, xs, ys, xe, ye: Integer; Tolerance: Integer) : boolean;');
AddFunction(@ps_FindColoredArea, 'function FindColoredArea(var x, y: Integer; color, xs, ys, xe, ye, MinArea: Integer): Boolean');
AddFunction(@ps_FindColoredAreaTolerance, 'function FindColoredAreaTolerance(var x, y : Integer; color, xs, ys, xe, ye, MinArea, Tolerance : Integer): Boolean');
{$ENDIF}

{$IFNDEF MML_EXPORT_THREADSAFE}
{Mouse etc.}
SetCurrSection('Mouse');
AddFunction(@ps_MoveMouse, 'procedure MoveMouse(x, y: integer);');
AddFunction(@ps_ScrollMouse,'procedure Scrollmouse(x,y : integer; Clicks : integer);');
AddFunction(@ps_GetMousePos, 'procedure GetMousePos(var x, y: integer);');
AddFunction(@ps_HoldMouse, 'procedure HoldMouse(x, y: integer; clickType: integer);');
AddFunction(@ps_ReleaseMouse, 'procedure ReleaseMouse(x, y: integer; clickType: integer);');
AddFunction(@ps_ClickMouse, 'procedure ClickMouse(x, y: integer; clickType: integer);');
AddFunction(@ps_IsMouseButtonDown,'function IsMouseButtonDown(button : integer) : boolean;');
{$ENDIF}

{$IFNDEF MML_EXPORT_THREADSAFE}
{Keyboard}
SetCurrSection('Keyboard');
AddFunction(@ps_KeyDown, 'procedure KeyDown(key: Word);');
AddFunction(@ps_KeyUp, 'procedure KeyUp(key: Word);');
AddFunction(@ps_PressKey, 'procedure PressKey(key: Word);');
AddFunction(@ps_SendKeys, 'procedure SendKeys(const s: string; keywait, keymodwait: integer);');
AddFunction(@ps_isKeyDown, 'function IsKeyDown(key: Word): Boolean;');
AddFunction(@ps_GetKeyCode,'function GetKeyCode(c : char) : integer;');
{$ENDIF}

{$IFNDEF MML_EXPORT_THREADSAFE}
{ OCR}
SetCurrSection('OCR');
AddFunction(@ps_rs_GetUpText, 'function rs_GetUpText: string;');
AddFunction(@ps_rs_GetUpTextAt, 'function rs_GetUpTextAt(x, y : integer): string;');
AddFunction(@ps_rs_GetUpTextAtEx, 'function rs_GetUpTextAtEx(x, y: integer; shadow: boolean; fontname: string): string');
AddFunction(@ps_SetUpTextFilter, 'procedure rs_SetUpTextFilter(filterdata: TOcrFilterDataArray);');
AddFunction(@ps_ResetUpTextFilter, 'procedure rs_ResetUpTextFilter;');
AddFunction(@ps_BitmapFromText, 'function BitmapFromText(const text, font: String): integer;');
AddFunction(@ps_TPAFromText, 'function TPAFromText(const text, font: String;var w,h : integer): TPointArray;');
AddFunction(@ps_TPAFromTextWrap,'procedure TPAFromTextWrap(const text, font: String;var w,h : integer;var TPA : TPointArray);');
AddFunction(@ps_MaskFromText, 'function MaskFromText(const text, font: String): TMask;');
AddFunction(@ps_GetTextAt,'function GetTextAt(const atX, atY, minvspacing, maxvspacing, hspacing,color, tol, len: integer;const font: string): string;');
AddFunction(@ps_getTextAtEx,'function GetTextAtEx(const xs,ys,xe,ye, minvspacing, maxvspacing, hspacing,color, tol: integer;const font: string): string;');
AddFunction(@ps_GetTextAtEx,'function GetTextAtExWrap(const xs,ys,xe,ye, minvspacing, maxvspacing, hspacing,color, tol: integer;const font: string): string;');
AddFunction(@ps_gettextATPA,'function GetTextATPA(const ATPA : T2DPointArray; const maxvspacing : integer; const font : string): string;');
AddFunction(@ps_LoadSystemFont,'function LoadSystemFont(const SysFont : TFont; const FontName : string) : boolean;');
AddFunction(@ps_LoadFont, 'function LoadFont(const FontName: string; shadow: boolean): boolean;');
AddFunction(@ps_FreeFont, 'function FreeFont(const FontName: string): boolean;');
AddFunction(@ps_IsFontLoaded, 'function IsFontLoaded(const FontName: string): boolean;');
AddFunction(@ps_FilterUpTextByCharacteristics, 'procedure ocr_FilterUpTextByCharacteristics(bmp: TMufasaBitmap);');
{$ENDIF}

{$IFNDEF MML_EXPORT_THREADSAFE}
{Bitmaps}
SetCurrSection('Bitmaps');
AddFunction(@ps_CreateBitmapString,'function CreateBitmapString(bmp : integer) : string;');
AddFunction(@ps_GetMufasaBitmap,'function GetMufasaBitmap(bmp : integer) : TMufasaBitmap;');
AddFunction(@ps_CreateBitmap,'function CreateBitmap(w,h :integer) : integer;');
AddFunction(@ps_FreeBitmap,'procedure FreeBitmap(Bmp: integer);');
AddFunction(@ps_SaveBitmap,'procedure SaveBitmap(Bmp: integer; path : string);');
AddFunction(@ps_BitmapExists, 'function BitmapExists(Index : integer) : boolean;');
AddFunction(@ps_BitmapFromString,'function BitmapFromString(Width,Height : integer; Data : string): integer;');
AddFunction(@ps_LoadBitmap,'function LoadBitmap(Path : string) : integer;');
AddFunction(@ps_SetBitmapSize,'procedure SetBitmapSize(Bmp,NewW,NewH : integer);');
AddFunction(@ps_GetBitmapSize,'procedure GetBitmapSize(Bmp : integer; var BmpW,BmpH : integer);');
AddFunction(@ps_SetPersistentMemoryBitmap, 'procedure SetPersistentMemoryBitmap(bmp: integer; mem: PtrUInt; awidth, aheight: integer);');
AddFunction(@ps_ResetPersistentMemoryBitmap, 'procedure ResetPersistentMemoryBitmap(bmp: Integer);');
AddFunction(@ps_StretchBitmapResize,'procedure StretchBitmapResize(Bmp,NewW,NewH : integer);');
AddFunction(@ps_ResizeBitmapEx,'procedure ResizeBitmapEx(const bmp: integer; const Method: TBmpResizeMethod; const NewWidth, NewHeight: integer);');
AddFunction(@ps_CreateMirroredBitmap,'function CreateMirroredBitmap(Bmp : integer) : integer;');
AddFunction(@ps_CreateMirroredBitmapEx,'function CreateMirroredBitmapEx(Bmp : integer; MirrorStyle : TBmpMirrorStyle) : integer;');
AddFunction(@ps_FastSetPixel,'procedure FastSetPixel(bmp,x,y : integer; Color : TColor);');
AddFunction(@ps_FastSetPixels,'procedure FastSetPixels(bmp : integer; TPA : TPointArray; Colors : TIntegerArray);');
AddFunction(@ps_FastGetPixel,'function FastGetPixel(bmp, x,y : integer) : TColor;');
AddFunction(@ps_FastGetPixels,'function FastGetPixels(Bmp : integer; TPA : TPointArray) : TIntegerArray;');
AddFunction(@ps_GetBitmapAreaColors,'function GetBitmapAreaColors(bmp,xs, ys, xe, ye: Integer): T2DIntegerArray;');
AddFunction(@ps_FindColorsBitmap, 'function FindColorsBitmap(bmp: integer; var points: TPointArray; const color: integer): boolean;');
AddFunction(@ps_FastDrawClear,'procedure FastDrawClear(bmp : integer; Color : TColor);');
AddFunction(@ps_FastDrawTransparent,'procedure FastDrawTransparent(x, y: Integer; SourceBitmap, TargetBitmap: Integer);');
AddFunction(@ps_SetTransparentColor,'procedure SetTransparentColor(bmp : integer; Color : TColor);');
AddFunction(@ps_GetTransparentColor,'function GetTransparentColor(bmp: integer) : TColor;');
AddFunction(@ps_FastReplaceColor,'procedure FastReplaceColor(Bmp : integer; OldColor,NewColor : TColor);');
AddFunction(@ps_CopyClientToBitmap, 'procedure CopyClientToBitmap(bmp, xs, ys, xe, ye: Integer);');
AddFunction(@ps_BitmapFromClient,'function BitmapFromClient(const xs, ys, xe, ye: Integer): Integer;');
AddFunction(@ps_SetBitmapName, 'procedure SetBitmapName(Bmp : integer; name : string);');
AddFunction(@ps_FindBitmap,'function FindBitmap(bitmap: integer; var x, y: Integer): Boolean;');
AddFunction(@ps_FindBitmapIn,'function FindBitmapIn(bitmap: integer; var x, y: Integer;  xs, ys, xe, ye: Integer): Boolean;');
AddFunction(@ps_FindBitmapToleranceIn,'function FindBitmapToleranceIn(bitmap: integer; var x, y: Integer; xs, ys, xe, ye: Integer; tolerance: Integer): Boolean;');
AddFunction(@ps_FindBitmapSpiral,'function FindBitmapSpiral(bitmap: Integer; var x, y: Integer; xs, ys, xe, ye: Integer): Boolean;');
AddFunction(@ps_FindBitmapsSpiralTolerance,'function FindBitmapsSpiralTolerance(bitmap: integer; x, y: Integer; var Points : TPointArray; xs, ys, xe, ye,tolerance: Integer): Boolean;');
AddFunction(@ps_FindBitmapSpiralTolerance,'function FindBitmapSpiralTolerance(bitmap: integer; var x, y: Integer; xs, ys, xe, ye,tolerance : integer): Boolean;');
AddFunction(@ps_RotateBitmap,'function RotateBitmap(bitmap: Integer; angle: Extended): Integer;');
AddFunction(@ps_Desaturate,'function DesaturateBitmap(Bitmap : integer) : integer;');
AddFunction(@ps_InvertBitmap,'procedure InvertBitmap(Bitmap : integer);');
AddFunction(@ps_CopyBitmap,'function CopyBitmap(Bitmap:  integer) : integer');
AddFunction(@ps_GreyScaleBitmap,'function GreyScaleBitmap(bitmap : integer) : integer');
AddFunction(@ps_BrightnessBitmap,'function BrightnessBitmap(Bitmap,br : integer) : integer;');
AddFunction(@ps_ContrastBitmap,'function ContrastBitmap(bitmap : integer; co : extended) : integer;');
AddFunction(@ps_PosterizeBitmap,'function PosterizeBitmap(Bitmap : integer; po : integer) : integer;');
AddFunction(@ps_CreateMaskFromBitmap,'function CreateMaskFromBitmap(Bitmap : integer) : TMask;');
AddFunction(@ps_FindMaskTolerance,'function FindMaskTolerance(const mask: TMask; var x, y: Integer; xs,ys, xe, ye: Integer; Tolerance, ContourTolerance: Integer): Boolean;');
AddFunction(@ps_FindBitmapMaskTolerance,'function FindBitmapMaskTolerance(mask: Integer; var x, y: Integer; xs, ys, xe, ye: Integer; Tolerance, ContourTolerance: Integer): Boolean;');
AddFunction(@ps_FindDeformedBitmapToleranceIn,'function FindDeformedBitmapToleranceIn(bitmap: integer; var x,y: Integer; xs, ys, xe, ye: Integer; tolerance: Integer; Range: Integer; AllowPartialAccuracy: Boolean; var accuracy: Extended): Boolean;');
AddFunction(@ps_DrawTPABitmap,'procedure DrawTPABitmap(bitmap: integer; TPA: TPointArray; Color: integer);');
AddFunction(@ps_DrawATPABitmap,'procedure DrawATPABitmap(bitmap: integer; ATPA: T2DPointArray);');
AddFunction(@ps_LineToBitmap,'procedure DrawLineBitmap(bitmap: integer; Src,Dest: TPoint;Color: integer);');
AddFunction(@ps_DrawATPABitmapEx,'procedure DrawATPABitmapEx(bitmap: integer; ATPA: T2DPointArray; Colors: TIntegerArray);');
AddFunction(@ps_DrawBitmap,'procedure DrawBitmap(Bmp: Integer; Dest: TCanvas; x, y: Integer);');
AddFunction(@ps_RectangleBitmap,'procedure RectangleBitmap(bitmap : integer; const box : TBox; Color : TColor);');
AddFunction(@ps_FloodfillBitmap,'procedure FloodFillBitmap(bitmap : integer; const StartPoint : TPoint; const SearchCol,ReplaceCol : TColor);');
AddFunction(@ps_ConvoluteBitmap,'function ConvoluteBitmap(bitmap : integer; matrix : T2DExtendedArray) : integer;');
AddFunction(@ps_CalculatePixelShift,'function CalculatePixelShift(Bmp1,Bmp2 : Integer; CompareBox : TBox) : integer;');
AddFunction(@ps_CalculatePixelShiftTPA,'function CalculatePixelShiftTPA(Bmp1,Bmp2 : Integer; CPoints: TPointArray) : integer;');
AddFunction(@ps_CalculatePixelTolerance,'function CalculatePixelTolerance(Bmp1,Bmp2 : Integer; CompareBox : TBox; CTS : integer) : extended;');
AddFunction(@ps_CalculatePixelToleranceTPA,'function CalculatePixelToleranceTPA(Bmp1,Bmp2 : Integer; CPoints: TPointArray; CTS : integer) : extended;');
AddFunction(@ps_CropBitmap,'procedure CropBitmap(const bmp: integer; const xs, ys, xe, ye: integer);');
AddFunction(@ps_GetColorsBitmap,'function GetColorsBitmap(const bmp: integer): TIntegerArray;');
AddFunction(@ps_BitmapToMatrix,'function BitmapToMatrix(const bmp: integer): T2DIntegerArray;');
AddFunction(@ps_DrawMatrixBitmap,'procedure DrawMatrixBitmap(const bmp: integer; const matrix: T2DIntegerArray);');
AddFunction(@ps_ThresholdAdaptiveBitmap,'procedure ThresholdAdaptiveBitmap(const bmp: integer; Alpha, Beta: Byte; Invert: Boolean; Method: TBmpThreshMethod; C: Integer);');
{$ENDIF}

{tpa}
SetCurrSection('TPA');
AddFunction(@ps_Quicksort,'procedure Quicksort(var Arr : TIntegerArray);');
AddFunction(@ps_tSwap,'procedure tSwap(var a, b: TPoint);');
AddFunction(@ps_tpaSwap,'procedure tpaSwap(var a, b: TPointArray);');
AddFunction(@ps_SwapE,'procedure SwapE(var a, b: Extended);');
AddFunction(@ps_RAaSTPAEx,'procedure RAaSTPAEx(var a: TPointArray; const w, h: Integer);');
AddFunction(@ps_RAaSTPA,'procedure RAaSTPA(var a: TPointArray; const Dist: Integer);');
AddFunction(@ps_NearbyPointInArrayEx,'function NearbyPointInArrayEx(const P: TPoint; w, h:Integer;const  a: TPointArray): Boolean;');
AddFunction(@ps_NearbyPointInArray,'function NearbyPointInArray(const P: TPoint; Dist:Integer;const  a: TPointArray): Boolean;');
AddFunction(@ps_QuickTPASort,'procedure QuickTPASort(var A: TIntegerArray; var B: TPointArray; iLo, iHi: Integer; SortUp: Boolean);');
AddFunction(@ps_QuickATPASort,'procedure QuickATPASort(var A: TIntegerArray; var B: T2DPointArray; iLo, iHi: Integer; SortUp: Boolean);');
AddFunction(@ps_SortTPAByX,'procedure SortTPAByX(var a: TPointArray; const LowToHi: Boolean);');
AddFunction(@ps_SortTPAByY,'procedure SortTPAByY(var a: TPointArray; const LowToHi: Boolean);');
AddFunction(@ps_FindTPARows,'function FindTPARows(a: TPointArray): T2DPointArray;');
AddFunction(@ps_FindTPAColumns,'function FindTPAColumns(a: TPointArray): T2DPointArray;');
AddFunction(@ps_SortTPAFrom,'procedure SortTPAFrom(var a: TPointArray; const From: TPoint);');
AddFunction(@ps_SortATPAFrom,'procedure SortATPAFrom(var a: T2DPointArray; const From: TPoint);');
AddFunction(@ps_SortATPAFromFirstPoint,'procedure SortATPAFromFirstPoint(var a: T2DPointArray; const From: TPoint);');
AddFunction(@ps_SortATPAFromMidPoint,'procedure SortATPAFromMidPoint(var a: T2DPointArray; const From: TPoint);');
AddFunction(@ps_SortATPAFromFirstPointX,'procedure SortATPAFromFirstPointX(var a: T2DPointArray; const From: TPoint);');
AddFunction(@ps_SortATPAFromFirstPointY,'procedure SortATPAFromFirstPointY(var a: T2DPointArray; const From: TPoint);');
AddFunction(@ps_InvertTPA,'procedure InvertTPA(var a: TPointArray);');
AddFunction(@ps_InvertATPA,'procedure InvertATPA(var a: T2DPointArray);');
AddFunction(@ps_MiddleTPAEx,'function MiddleTPAEx(const TPA: TPointArray; var x, y: Integer): Boolean;');
AddFunction(@ps_MiddleTPA,'function MiddleTPA(const tpa: TPointArray): TPoint;');
AddFunction(@ps_MedianTPAEx, 'procedure MedianTPAEx(var tpa: TPointArray; out x, y: integer);');
AddFunction(@ps_MedianTPA, 'function MedianTPA(var tpa: TPointArray): TPoint;');
AddFunction(@ps_SortATPASize,'procedure SortATPASize(var a: T2DPointArray; const BigFirst: Boolean);');
AddFunction(@ps_SortATPAFromSize,'procedure SortATPAFromSize(var a: T2DPointArray; const Size: Integer; CloseFirst: Boolean);');
AddFunction(@ps_FilterTPAsBetween, 'procedure FilterTPAsBetween(var atpa: T2DPointArray; const minLength, maxLength: integer);');
AddFunction(@ps_InIntArrayEx,'function InIntArrayEx(const a: TIntegerArray; var Where: Integer; const Number: Integer): Boolean;');
AddFunction(@ps_InIntArray,'function InIntArray(const a: TIntegerArray; Number: Integer): Boolean;');
AddFunction(@ps_ClearSameIntegers,'procedure ClearSameIntegers(var a: TIntegerArray);');
AddFunction(@ps_ClearSameIntegersAndTPA,'procedure ClearSameIntegersAndTPA(var a: TIntegerArray; var p: TPointArray);');
AddFunction(@ps_SplitTPAEx,'function SplitTPAEx(const arr: TPointArray; w, h: Integer): T2DPointArray;');
AddFunction(@ps_SplitTPA,'function SplitTPA(const arr: TPointArray; Dist: Integer): T2DPointArray;');
AddFunction(@ps_ClusterTPAEx, 'function ClusterTPAEx(const TPA: TPointArray; width, height: Integer): T2DPointArray;');
AddFunction(@ps_ClusterTPA, 'function ClusterTPA(const TPA: TPointArray; dist: Integer): T2DPointArray;');
AddFunction(@ps_FloodFillTPA,'function FloodFillTPA(const TPA : TPointArray) : T2DPointArray;');
AddFunction(@ps_FilterPointsPieEx,'procedure FilterPointsPieEx(var Points: TPointArray; const SD, ED, MinR, MaxR: Extended; Mx, My: Integer; Natural: Boolean);');
AddFunction(@ps_FilterPointsPie,'procedure FilterPointsPie(var Points: TPointArray; const SD, ED, MinR, MaxR: Extended; Mx, My: Integer);');
AddFunction(@ps_FilterPointsLine,'procedure FilterPointsLine(var Points: TPointArray; Radial: Extended; Radius, MX, MY: Integer);');
AddFunction(@ps_filterpointsdist,'procedure FilterPointsDist(var Points: TPointArray; const MinDist, MaxDist: Extended; Mx, My: Integer);');
AddFunction(@ps_FilterPointsBox, 'procedure FilterPointsBox(var points: TPointArray; x1, y1, x2, y2: integer);');
AddFunction(@ps_filterTPADist, 'procedure FilterTPADist(var TPA: TPointArray; maxDist: integer);');
AddFunction(@ps_GetATPABounds,'function GetATPABounds(const ATPA: T2DPointArray): TBox;');
AddFunction(@ps_GetTPABounds,'function GetTPABounds(const TPA: TPointArray): TBox;');
AddFunction(@ps_FindTPAinTPA,'function FindTPAinTPA(const SearchTPA, TotalTPA: TPointArray; var Matches: TPointArray): Boolean;');
AddFunction(@ps_GetSamePointsATPA,'function GetSamePointsATPA(const  ATPA : T2DPointArray; var Matches : TPointArray) : boolean;');
AddFunction(@ps_FindTextTPAinTPA,'function FindTextTPAinTPA(Height : integer;const  SearchTPA, TotalTPA: TPointArray; var Matches: TPointArray): Boolean;');
AddFunction(@ps_SortCircleWise,'procedure SortCircleWise(var tpa: TPointArray; const cx, cy, StartDegree: Integer; SortUp, ClockWise: Boolean);');
AddFunction(@ps_LinearSort,'procedure LinearSort(var tpa: TPointArray; cx, cy, sd: Integer; SortUp: Boolean);');
AddFunction(@ps_RotatePoint,'function RotatePoint(Const p: TPoint; angle, mx, my: Extended): TPoint;');
AddFunction(@ps_ChangeDistPT,'function ChangeDistPT(const PT : TPoint; mx,my : integer; newdist : extended) : TPoint;');
AddFunction(@ps_ChangeDistTPA,'function ChangeDistTPA(var TPA : TPointArray; mx,my : integer; newdist : extended) : boolean;');
AddFunction(@ps_FindGapsTPA,'function FindGapsTPA(const TPA: TPointArray; MinPixels: Integer): T2DPointArray;');
AddFunction(@ps_RemoveDistTPointArray,'function RemoveDistTPointArray(x, y, dist: Integer;const  ThePoints: TPointArray; RemoveHigher: Boolean): TPointArray;');
AddFunction(@ps_CombineTPA,'function CombineTPA(const Ar1, Ar2: TPointArray): TPointArray;');
AddFunction(@ps_ReArrangeandShortenArrayEx,'function ReArrangeandShortenArrayEx(const a: TPointArray; w, h: Integer): TPointArray;');
AddFunction(@ps_ReArrangeandShortenArray,'function ReArrangeandShortenArray(const a: TPointArray; Dist: Integer): TPointArray;');
AddFunction(@ps_TPAtoATPAEx,'function TPAtoATPAEx(const TPA: TPointArray; w, h: Integer): T2DPointArray;');
AddFunction(@ps_TPAtoATPA,'function TPAtoATPA(const TPA: TPointArray; Dist: Integer): T2DPointArray;');
AddFunction(@ps_CombineIntArray,'function CombineIntArray(const Ar1, Ar2: TIntegerArray): TIntegerArray;');
AddFunction(@ps_MergeATPA,'function MergeATPA(const ATPA : T2DPointArray)  : TPointArray;');
AddFunction(@ps_AppendTPA,'procedure AppendTPA(var TPA: TPointArray; const ToAppend: TPointArray);');
AddFunction(@ps_TPAFromLine, 'function TPAFromLine(const x1, y1, x2, y2: Integer): TPointArray;');
AddFunction(@ps_EdgeFromBox, 'function EdgeFromBox(const Box: TBox): TPointArray;');
AddFunction(@ps_TPAFromBox,'function TPAFromBox(const Box : TBox) : TPointArray;');
AddFunction(@ps_TPAFromEllipse,'function TPAFromEllipse(const CX, CY, XRadius, YRadius : Integer) : TPointArray;');
AddFunction(@ps_TPAFromCircle,'function TPAFromCircle(const CX, CY, Radius : Integer) : TPointArray;');
AddFunction(@ps_TPAFromPolygon, 'function TPAFromPolygon(const shape: TPointArray): TPointArray;');
AddFunction(@ps_FillEllipse,'procedure FillEllipse(var a: TPointArray);');
AddFunction(@ps_RotatePoints,'function RotatePoints(Const P: TPointArray; A, cx, cy: Extended): TPointArray ;');
AddFunction(@ps_FindTPAEdges,'function FindTPAEdges(const p: TPointArray): TPointArray;');
AddFunction(@ps_ClearTPAFromTPA,'function ClearTPAFromTPA(const arP, ClearPoints: TPointArray): TPointArray;');
AddFunction(@ps_ReturnPointsNotInTPA,'function ReturnPointsNotInTPA(Const TotalTPA: TPointArray; const Box: TBox): TPointArray;');
AddFunction(@ps_PointInTPA,'function PointInTPA(p: TPoint;const  arP: TPointArray): Boolean;');
AddFunction(@ps_ClearDoubleTPA,'procedure ClearDoubleTPA(var TPA: TPointArray);');
AddFunction(@ps_TPACountSort,'procedure TPACountSort(Var TPA: TPointArray;const max: TPoint;Const SortOnX : Boolean);');
AddFunction(@ps_TPACountSortBase,'procedure TPACountSortBase(Var TPA: TPointArray;const maxx, base: TPoint; const SortOnX : Boolean);');
AddFunction(@ps_InvertTIA,'procedure InvertTIA(var tI: TIntegerArray);');
AddFunction(@ps_SumIntegerArray,'function SumIntegerArray(const Ints : TIntegerArray): Integer;');
AddFunction(@ps_AverageTIA,'function AverageTIA(const tI: TIntegerArray): Integer;');
AddFunction(@ps_AverageExtended,'function AverageExtended(const tE: TExtendedArray): Extended;');
AddFunction(@ps_SplitTPAExWrap,'procedure SplitTPAExWrap(const arr: TPointArray; w, h: Integer; var res : T2DPointArray);');
AddFunction(@ps_SplitTPAWrap,'procedure SplitTPAWrap(const arr: TPointArray; Dist: Integer; var res: T2DPointArray);');
AddFunction(@ps_FindGapsTPAWrap,'procedure FindGapsTPAWrap(const TPA: TPointArray; MinPixels: Integer; var Res : T2DPointArray);');
AddFunction(@ps_RemoveDistTPointArrayWrap,'procedure RemoveDistTPointArrayWrap(x, y, dist: Integer;const  ThePoints: TPointArray; RemoveHigher: Boolean; var Res :  TPointArray);');
AddFunction(@ps_CombineTPAWrap,'procedure CombineTPAWrap(const Ar1, Ar2: TPointArray; var Res :  TPointArray);');
AddFunction(@ps_ReArrangeandShortenArrayExWrap,'procedure ReArrangeandShortenArrayExWrap(const a: TPointArray; w, h: Integer; var Res :  TPointArray);');
AddFunction(@ps_ReArrangeandShortenArrayWrap,'procedure ReArrangeandShortenArrayWrap(const a: TPointArray; Dist: Integer; var Res :  TPointArray);');
AddFunction(@ps_TPAtoATPAExWrap,'procedure TPAtoATPAExWrap(const TPA: TPointArray; w, h: Integer; var Res :  T2DPointArray);');
AddFunction(@ps_TPAtoATPAWrap,'procedure TPAtoATPAWrap(const TPA: TPointArray; Dist: Integer; var Res :  T2DPointArray);');
AddFunction(@ps_MiddleTPAWrap,'procedure MiddleTPAWrap(const TPA: TPointArray; var Res: TPoint);');
AddFunction(@ps_CombineIntArrayWrap, 'procedure CombineIntArrayWrap(const Ar1, Ar2: TIntegerArray; var Res :  TIntegerArray);');
AddFunction(@ps_ReturnPointsNotInTPAWrap,'procedure ReturnPointsNotInTPAWrap(Const TotalTPA: TPointArray; const Box: TBox; var Res :  TPointArray);');
AddFunction(@ps_MergeATPAWrap,'procedure MergeATPAWrap(const ATPA : T2DPointArray; var Res: TPointArray);');
AddFunction(@ps_TPAFromLineWrap, 'procedure TPAFromLineWrap(const x1, y1, x2, y2: Integer; var Res: TPointArray);');
AddFunction(@ps_EdgeFromBoxWrap, 'procedure EdgeFromBoxWrap(const Box: TBox; var Res: TPointArray);');
AddFunction(@ps_TPAFromBoxWrap,'procedure TPAFromBoxWrap(const Box : TBox; var Res : TPointArray);');
AddFunction(@ps_TPAFromEllipseWrap,'procedure TPAFromEllipseWrap(const CX, CY, XRadius, YRadius : Integer; var Res : TPointArray);');
AddFunction(@ps_TPAFromCircleWrap,'procedure TPAFromCircleWrap(const CX, CY, Radius : Integer; var Res : TPointArray);');
AddFunction(@ps_RotatePointsWrap,'procedure RotatePointsWrap(Const P: TPointArray; A, cx, cy: Extended; var Res :  TPointArray);');
AddFunction(@ps_FindTPAEdgesWrap,'procedure FindTPAEdgesWrap(const p: TPointArray; var Res :  TPointArray);');
AddFunction(@ps_ClearTPAFromTPAWrap,'procedure ClearTPAFromTPAWrap(const arP, ClearPoints: TPointArray;  var Res :  TPointArray);');
AddFunction(@ps_SameTPA,'function SameTPA(const aTPA, bTPA: TPointArray): Boolean;');
AddFunction(@ps_TPAInATPA,'function TPAInATPA(const TPA: TPointArray;const  InATPA: T2DPointArray; var Index: LongInt): Boolean;');
AddFunction(@ps_offsetTPA,'procedure OffsetTPA(var TPA : TPointArray; const Offset : TPoint);');
AddFunction(@ps_offsetATPA,'procedure OffsetATPA(var ATPA : T2DPointArray; const Offset : TPoint);');
AddFunction(@ps_copyTPA,'function CopyTPA(const TPA : TPointArray) : TPointArray;');
AddFunction(@ps_CopyATPA,'function CopyATPA(const ATPA : T2DPointArray) : T2DPointArray;');
AddFunction(@ps_TPAPosNext,'function  TPAPosNext(const Find: TPoint; const V: TPointArray; const PrevPos: Integer;const IsSortedAscending: Boolean): Integer;');
AddFunction(@ps_GlueTPAs, 'function GlueTPAs(const V1, V2: TPointArray; const IsSortedAscending,byDifference: Boolean):TPointArray;');

{SQLite3}
{$IFNDEF MML_EXPORT_THREADSAFE}
{$IFDEF USE_SQLITE}
if (SQLite3Loaded) then
begin
  SetCurrSection('SQLite3');
  AddFunction(@ps_sqlite_version, 'function sqlite_version() : string;');
  AddFunction(@ps_sqlite_version_num, 'function sqlite_version_num() : integer;');
  AddFunction(@ps_sqlite_escape, 'function sqlite_escape(s : string) : string;');
  AddFunction(@ps_sqlite_close, 'procedure sqlite_close(index : integer);');
  AddFunction(@ps_sqlite_open, 'function sqlite_open(filename : string) : integer;');
  AddFunction(@ps_sqlite_open_v2, 'function sqlite_open_v2(filename : string; flags : integer) : integer;');
  AddFunction(@ps_sqlite_errmsg, 'function sqlite_errMsg(index : integer) : string;');
  AddFunction(@ps_sqlite_errcode, 'function sqlite_errCode(index : integer) : integer;');
  AddFunction(@ps_sqlite_query, 'function sqlite_query(index : integer; sql : string) : boolean;');
  AddFunction(@ps_sqlite_queryvalue, 'function sqlite_queryValue(index : integer; sql : string; out Data : T2DStringArray) : boolean;');
  AddFunction(@ps_sqlite_queryresult, 'function sqlite_queryResult(index : integer; sql : string; var error : boolean) : T2DStringArray;');
end;
{$ENDIF}

SetCurrSection('Settings');
AddFunction(@ps_KeyIsSetting, 'function KeyIsSetting(const KeyName: String): Boolean;');
AddFunction(@ps_KeyIsDirectory, 'function KeyIsDirectory(const KeyName: String): Boolean;');
AddFunction(@ps_GetSettingValue, 'function GetSettingValue(const KeyName: String): String;');
AddFunction(@ps_GetSettingValueDef, 'function GetSettingValueDef(const KeyName, defVal: String): String;');
AddFunction(@ps_SetSettingValue,'function SetSettingValue(const KeyName,value : string) : boolean;');
AddFunction(@ps_ListSettings, 'function ListSettings(const KeyName: String; var KeyReturn: TStringArray) : boolean;');
AddFunction(@ps_DeleteSetting, 'function DeleteSetting(const KeyName: String): Boolean;');
AddFunction(@ps_DeleteSubSettings, 'function DeleteSubSettings(const KeyName: String): Boolean;');
{$ENDIF}
