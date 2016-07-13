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

    lpexportedmethods.inc for the Mufasa Macro Library
}

{ Other }
SetCurrSection('Other');
//AddGlobalFunc('procedure Writeln(const str: string);', @Lape_Writeln);
AddGlobalFunc('function AddOnTerminate(const proc: string; skipIfUserTerminated: Boolean = False): Boolean;', @Lape_AddOnTerm);
AddGlobalFunc('function DeleteOnTerminate(const proc: string): Boolean;', @Lape_DelOnTerm);
AddGlobalFunc('function SetScriptProp(prop: TSP_Property; Value: TVariantArray): boolean', @Lape_SetScriptProp);
AddGlobalFunc('function GetScriptProp(prop: TSP_Property; var Value: TVariantArray): boolean', @Lape_GetScriptProp);
AddGlobalFunc('procedure Wait(t: DWord);', @Lape_Wait);
AddGlobalFunc('procedure Sleep(t: DWord); override', @Lape_Wait); // XXX: OVERRIDE THIS
AddGlobalFunc('procedure PlaySound(Sound: string);', @Lape_PlaySound);
AddGlobalFunc('Procedure StopSound;', @Lape_StopSound);
AddGlobalFunc('procedure ClearDebug;', @Lape_ClearDebug);
AddGlobalFunc('procedure SetSupressExceptions(Supress: boolean);', @Lape_SetSupressExceptions);
AddGlobalFunc('procedure SaveScreenshot(FileName: string);', @Lape_SaveScreenshot);
AddGlobalFunc('procedure DisplayDebugImgWindow(w,h: integer);', @Lape_DisplayDebugImgWindow);
AddGlobalFunc('procedure DrawBitmapDebugImg(bmp: integer);', @Lape_DrawBitmapDebugImg);
AddGlobalFunc('function GetDebugBitmap: integer', @Lape_GetDebugBitmap);
AddGlobalFunc('procedure ClearDebugImg;', @Lape_ClearDebugImg);
AddGlobalFunc('procedure Status(Status: string);', @Lape_Status);
AddGlobalFunc('procedure Disguise(Caption: string);', @Lape_Disguise);
AddGlobalFunc('procedure ShowMessage(msg: string);', @Lape_ShowMessage);
AddGlobalFunc('function MessageBox(Text, Caption: string; Flags: LongInt): Integer', @Lape_MessageBox);
AddGlobalFunc('function MessageDlg(const Caption, Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): integer', @Lape_MessageDlg);
AddGlobalFunc('function InputQuery(const ACaption, APrompt: String; var Value: String): Boolean', @Lape_InputQuery);
AddGlobalFunc('procedure ShowBalloonHint(const Title, Hint: string; const Timeout: Integer; const Flag: TBalloonFlags);', @Lape_ShowBalloonHint);
AddGlobalFunc('procedure TerminateScript;', @Lape_TerminateScript);
AddGlobalFunc('function GetTimeRunning: LongWord', @Lape_GetTimeRunning);
{$IFNDEF FUNC_LIST}
AddGlobalFunc('function GetSystemTime: LongWord', PPointer(Compiler['GetTickCount'].Ptr)^); //TODO: FIX!!
{$ENDIF}
AddGlobalFunc('function GetTClient: TClient', @Lape_GetTClient);
AddGlobalFunc('procedure ConvertTime(Time: integer; var h,m,s: integer);', @Lape_ConvertTime);
AddGlobalFunc('procedure ConvertTime64(Time: int64; var y, m, w, d, h, min, s: integer);', @Lape_ConvertTime64);
AddGlobalFunc('procedure HakunaMatata;', @Lape_HakunaMatata);
AddGlobalFunc('procedure Simba;', @Lape_Simba);
AddGlobalFunc('procedure SetClipBoard(const Data: string);', @Lape_SetClipBoard);
AddGlobalFunc('function GetClipBoard: string', @Lape_GetClipBoard);
AddGlobalFunc('function GetProcesses: TSysProcArr', @Lape_GetProcesses);
AddGlobalFunc('function GetProcessMem(processID: LongInt): Int64;', @Lape_GetProcessMem);
AddGlobalFunc('function GetProcessID : LongInt', @Lape_GetProcessID);
AddGlobalFunc('procedure SetTarget(Proc: TSysProc);', @Lape_SetTarget);
AddGlobalFunc('function ExtractFileExt(const FileName: string): string', @Lape_ExtractFileExt);
AddGlobalFunc('function GetEnvironmentVariable(const VarName: string): string;', @Lape_GetEnvironmentVariable);

{ DTM }
SetCurrSection('DTM');
AddGlobalFunc('function FindDTM(DTM: Integer; var x, y: Integer; xs, ys, xe, ye: Integer): Boolean', @Lape_FindDTM);
AddGlobalFunc('function FindDTMs(DTM: Integer; var p: TPointArray; xs, ys, xe, ye: Integer): Boolean', @Lape_FindDTMs);
AddGlobalFunc('function FindDTMRotatedAlternating(DTM: Integer; var x, y: Integer; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: Extended): Boolean', @Lape_FindDTMRotatedAlternating);
AddGlobalFunc('function FindDTMRotatedSE(DTM: Integer; var x, y: Integer; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: Extended): Boolean', @Lape_FindDTMRotatedSE);
AddGlobalFunc('function FindDTMsRotatedAlternating(DTM: Integer; var Points: TPointArray; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: T2DExtendedArray): Boolean', @Lape_FindDTMsRotatedAlternating);
AddGlobalFunc('function FindDTMsRotatedSE(DTM: Integer; var Points: TPointArray; xs, ys, xe, ye: Integer; sAngle, eAngle, aStep: Extended; var aFound: T2DExtendedArray): Boolean', @Lape_FindDTMsRotatedSE);
AddGlobalFunc('procedure SetDTMName(DTM: integer; const name: string);', @Lape_SetDTMName);
AddGlobalFunc('function DTMFromString(const DTMString: String): Integer', @Lape_DTMFromString);
AddGlobalFunc('procedure FreeDTM(DTM: Integer);', @Lape_FreeDTM);
AddGlobalFunc('function GetDTM(index: Integer): TMDTM', @Lape_GetDTM);
AddGlobalFunc('function AddSDTM(const d: TSDTM): Integer', @Lape_AddTSDTM);
AddGlobalFunc('function AddDTM(const d: TMDTM): Integer', @Lape_AddDTM);
AddGlobalFunc('function DTMExists(index : integer) : boolean', @Lape_DTMExists);
AddGlobalFunc('procedure PrintDTM(const aDTM: TMDTM);', @Lape_PrintDTM);
AddGlobalFunc('function MDTMToSDTM(Const DTM: TMDTM): TSDTM', @Lape_MDTMToSDTM);
AddGlobalFunc('function SDTMToMDTM(Const DTM: TSDTM): TMDTM', @Lape_SDTMToMDTM);
AddGlobalFunc('function CreateDTMPoint(x,y,c,t,asz: integer; bp: boolean): TMDTMPoint', @Lape_CreateDTMPoint);

{ Bitmap }
SetCurrSection('Bitmap');
AddGlobalFunc('function CreateBitmapString(bmp: integer): string', @Lape_CreateBitmapString);
AddGlobalFunc('function GetMufasaBitmap(bmp: integer): TMufasaBitmap', @Lape_GetMufasaBitmap);
AddGlobalFunc('function CreateBitmap(w,h: integer): integer', @Lape_CreateBitmap);
AddGlobalFunc('procedure FreeBitmap(Number: integer);', @Lape_FreeBitmap);
AddGlobalFunc('procedure SaveBitmap(Bmp: integer; path: string);', @Lape_SaveBitmap);
AddGlobalFunc('function BitmapExists(Index : integer) : boolean;', @Lape_BitmapExists);
AddGlobalFunc('function BitmapFromString(Width,height: integer; Data: string): integer', @Lape_BitmapFromString);
AddGlobalFunc('function LoadBitmap(Path: String): integer', @Lape_LoadBitmap);
AddGlobalFunc('procedure SetBitmapSize(Bmp,NewW,NewH: integer);', @Lape_SetBitmapSize);
AddGlobalFunc('procedure StretchBitmapResize(Bmp,NewW,NewH: integer);', @Lape_StretchBitmapResize);
AddGlobalFunc('procedure ResizeBitmapEx(const bmp: integer; const Method: TBmpResizeMethod; const NewWidth, NewHeight: integer);', @Lape_ResizeBitmapEx);
AddGlobalFunc('procedure GetBitmapSize(Bmp: integer; var BmpW,BmpH: integer);', @Lape_GetBitmapSize);
AddGlobalFunc('procedure SetPersistentMemoryBitmap(bmp: integer; mem: PtrUInt; awidth, aheight: integer);', @Lape_SetPersistentMemoryBitmap);
AddGlobalFunc('procedure ResetPersistentMemoryBitmap(bmp: integer);', @Lape_ResetPersistentMemoryBitmap);
AddGlobalFunc('procedure SetBitmapName(Bmp: integer; name: string);', @Lape_SetBitmapName);
AddGlobalFunc('function CreateMirroredBitmap(Bmp: integer): integer', @Lape_CreateMirroredBitmap);
AddGlobalFunc('function CreateMirroredBitmapEx(Bmp: integer; MirrorStyle: TBmpMirrorStyle): integer', @Lape_CreateMirroredBitmapEx);
AddGlobalFunc('function FastGetPixel(bmp,x,y: integer): LongWord', @Lape_FastGetPixel);
AddGlobalFunc('function FastGetPixels(bmp: integer; TPA: TPointArray): TIntegerArray', @Lape_FastGetPixels);
AddGlobalFunc('function GetBitmapAreaColors(bmp,xs, ys, xe, ye: Integer): T2DIntArray', @Lape_GetBitmapAreaColors);
AddGlobalFunc('function FindColorsBitmap(bmp: integer; var points: TPointArray; const color: integer): boolean;', @Lape_FindColorsBitmap);
AddGlobalFunc('procedure FastSetPixel(Bmp,x,y: integer; Color: TColor);', @Lape_FastSetPixel);
AddGlobalFunc('procedure FastSetPixels(Bmp: integer; TPA: TPointArray; Colors: TIntegerArray);', @Lape_FastSetPixels);
AddGlobalFunc('procedure DrawTPABitmap(bitmap: integer; TPA: TPointArray; Color: integer);', @Lape_DrawTPABitmap);
AddGlobalFunc('procedure DrawATPABitmap(bitmap: integer; ATPA: T2DPointArray);', @Lape_DrawATPABitmap);
AddGlobalFunc('procedure DrawATPABitmapEx(bitmap: integer; ATPA: T2DPointArray; Colors: TIntegerArray);', @Lape_DrawATPABitmapEx);
AddGlobalFunc('procedure FastDrawClear(bmp: integer; Color: TColor);', @Lape_FastDrawClear);
AddGlobalFunc('procedure DrawBitmap(Bmp: Integer; Dest: TCanvas; x, y: Integer);', @Lape_DrawBitmap);
AddGlobalFunc('procedure FastDrawTransparent(x, y: Integer; SourceBitmap, TargetBitmap: Integer);', @Lape_FastDrawTransparent);
AddGlobalFunc('procedure SetTransparentColor(Bmp: integer; Color: TColor);', @Lape_SetTransparentColor);
AddGlobalFunc('function GetTransparentColor(Bmp: integer): TColor', @Lape_GetTransparentColor);
AddGlobalFunc('procedure FastReplaceColor(bmp: Integer; OldColor, NewColor: TColor);', @Lape_FastReplaceColor);
AddGlobalFunc('procedure CopyClientToBitmap(bmp, xs, ys, xe, ye: Integer);', @Lape_CopyClientToBitmap);
AddGlobalFunc('function BitmapFromClient(const xs, ys, xe, ye: Integer): Integer', @Lape_BitmapFromClient);
AddGlobalFunc('function FindBitmap(Bitmap: integer; var x, y: Integer): Boolean', @Lape_FindBitmap);
AddGlobalFunc('function FindBitmapIn(bitmap: integer; var x, y: Integer; xs, ys, xe, ye: Integer): Boolean', @Lape_FindBitmapIn);
AddGlobalFunc('function FindBitmapToleranceIn(bitmap: integer; var x, y: Integer; xs, ys, xe, ye: Integer; tolerance: Integer): Boolean', @Lape_FindBitmapToleranceIn);
AddGlobalFunc('function FindBitmapSpiral(bitmap: Integer; var x, y: Integer; xs, ys, xe, ye: Integer): Boolean', @Lape_FindBitmapSpiral);
AddGlobalFunc('function FindBitmapsSpiralTolerance(bitmap: integer; x, y: Integer; var Points: TPointArray; xs, ys, xe, ye,tolerance: Integer): Boolean', @Lape_FindBitmapsSpiralTolerance);
AddGlobalFunc('function FindBitmapSpiralTolerance(bitmap: integer; var x, y: Integer; xs, ys, xe, ye,tolerance: integer): Boolean', @Lape_FindBitmapSpiralTolerance);
AddGlobalFunc('function RotateBitmap(bitmap: Integer; angle: Extended): Integer', @Lape_RotateBitmap);
AddGlobalFunc('function RotateBitmapEx(Bitmap: Integer; Angle: Single; Expand: Boolean; Smooth: Boolean): Integer', @Lape_RotateBitmapEx);
AddGlobalFunc('function Desaturate(Bitmap: integer): integer', @Lape_Desaturate);
AddGlobalFunc('procedure InvertBitmap(Bitmap: integer);', @Lape_InvertBitmap);
AddGlobalFunc('function CopyBitmap(Bitmap: integer): integer', @Lape_CopyBitmap);
AddGlobalFunc('function GreyScaleBitmap(Bitmap: integer): integer', @Lape_GreyScaleBitmap);
AddGlobalFunc('function BrightnessBitmap(Bitmap, br: integer): integer', @Lape_BrightnessBitmap);
AddGlobalFunc('function ContrastBitmap(bitmap: integer; co: extended): integer', @Lape_ContrastBitmap);
AddGlobalFunc('function PosterizeBitmap(Bitmap: integer; po: integer): integer', @Lape_PosterizeBitmap);
AddGlobalFunc('function CreateMaskFromBitmap(Bitmap: integer): TMask', @Lape_CreateMaskFromBitmap);
AddGlobalFunc('function FindMaskTolerance(const mask: TMask; var x, y: Integer; xs,ys, xe, ye: Integer; Tolerance, ContourTolerance: Integer): Boolean', @Lape_FindMaskTolerance);
AddGlobalFunc('function FindBitmapMaskTolerance(mask: Integer; var x, y: Integer; xs, ys, xe, ye: Integer; Tolerance, ContourTolerance: Integer): Boolean', @Lape_FindBitmapMaskTolerance);
AddGlobalFunc('function FindDeformedBitmapToleranceIn(bitmap: integer; var x, y: Integer; xs, ys, xe, ye: Integer; tolerance: Integer; Range: Integer; AllowPartialAccuracy: Boolean; var accuracy: Extended): Boolean', @Lape_FindDeformedBitmapToleranceIn);
AddGlobalFunc('procedure RectangleBitmap(bitmap: integer; const box: TBox; Color: TColor);', @Lape_RectangleBitmap);
AddGlobalFunc('procedure RectangleBitmapEx(const Bitmap: Integer; const Box: TBox; const Color: Integer; const Transparency: Extended);', @Lape_RectangleBitmapEx);
AddGlobalFunc('procedure FloodFillBitmap(bitmap: integer; const StartPoint: TPoint; const SearchCol,ReplaceCol: TColor);', @Lape_FloodFillBitmap);
AddGlobalFunc('function ConvoluteBitmap(bitmap: integer; matrix: T2DExtendedArray): integer;', @Lape_ConvoluteBitmap);
AddGlobalFunc('procedure ThresholdAdaptiveBitmap(const bmp: integer; Alpha, Beta: Byte; Invert: Boolean; Method: TBmpThreshMethod; C: Integer);', @Lape_ThresholdAdaptiveBitmap);
AddGlobalFunc('procedure CropBitmap(const bmp: integer; const xs, ys, xe, ye: integer);', @Lape_CropBitmap);
AddGlobalFunc('procedure BlurBitmap(const bmp, block: integer);', @Lape_BlurBitmap);
AddGlobalFunc('procedure DrawTextBitmap(const Bitmap: Integer; const Text, FontName: string; const pnt: TPoint; const Shadow: Boolean; const Color: Integer);', @Lape_DrawTextBitmap);
AddGlobalFunc('procedure DrawSystemTextBitmap(const Bitmap: Integer; const Text, FontName: string; const FontSize: Integer; const pnt: TPoint; const Shadow: Boolean; const Color: Integer); ', @Lape_DrawSystemTextBitmap);
AddGlobalFunc('function CalculatePixelShift(Bmp1, Bmp2: Integer; CompareBox: TBox): integer', @Lape_CalculatePixelShift);
AddGlobalFunc('function CalculatePixelShiftTPA(Bmp1, Bmp2: Integer; CPoints: TPointArray) : integer;', @Lape_CalculatePixelShiftTPA);
AddGlobalFunc('function CalculatePixelTolerance(Bmp1, Bmp2: Integer; CompareBox: TBox; CTS: integer): extended', @Lape_CalculatePixelTolerance);
AddGlobalFunc('function CalculatePixelToleranceTPA(Bmp1, Bmp2: Integer; CPoints: TPointArray; CTS: integer) : extended;', @Lape_CalculatePixelToleranceTPA);
AddGlobalFunc('function GetColorsBitmap(const bmp: integer): TIntegerArray;', @Lape_GetColorsBitmap);
AddGlobalFunc('function BitmapToMatrix(const bmp: integer): T2DIntegerArray;',@Lape_BitmapToMatrix);
AddGlobalFunc('procedure DrawMatrixBitmap(const bmp: integer; const Matrix: T2DIntegerArray);', @Lape_DrawMatrixBitmap);

{ Math }
SetCurrSection('Math');
AddGlobalFunc('function pow(base,exponent: extended): extended', @Lape_pow);
AddGlobalFunc('function RiemannGauss(Xstart,StepSize,Sigma: extended; AmountSteps: integer): extended', @Lape_RiemannGauss);
AddGlobalFunc('function DiscreteGauss(Xstart,Xend: integer; sigma: extended): TExtendedArray', @Lape_DiscreteGauss);
AddGlobalFunc('function GaussMatrix(N: integer; sigma: extended): T2DExtendedArray', @Lape_GaussMatrix);
//AddGlobalFunc('function Max(a, b: integer): integer', @Lape_Max);
//AddGlobalFunc('function Min(a, b: Integer): Integer', @Lape_Min);
AddGlobalFunc('function MinE(a, b: extended): extended', @Lape_MinE);
AddGlobalFunc('function MaxE(a, b: extended): extended', @Lape_MaxE);
AddGlobalFunc('function Point(x, y: integer): TPoint', @Lape_Point);
AddGlobalFunc('function Distance(x1,y1,x2,y2: integer): integer', @Lape_Distance);
//AddGlobalFunc('function Hypot(X, Y: Extended): Extended', @Lape_Hypot);
AddGlobalFunc('function RandomRange(const aFrom, aTo: Integer): Integer', @Lape_RandomRange);
AddGlobalFunc('function RandomE: extended', @Lape_RandomE);
//AddGlobalFunc('function ArcTan2(y,x: extended): extended', @Lape_ArcTan2);
AddGlobalFunc('procedure IncEx(var x: integer; increase: integer);', @Lape_IncEx);
AddGlobalFunc('procedure DecEx(var x: integer; Decrease: integer);', @Lape_DecEx);
AddGlobalFunc('function Factorial(number: longword): Int64', @Lape_Factorial);
AddGlobalFunc('function BinCoe(a, b: LongInt): Extended', @Lape_BinCoe);
AddGlobalFunc('function FixD(Degrees: extended): Extended', @Lape_FixD);
AddGlobalFunc('function InRange(const value,min,max: integer): boolean', @Lape_InRange);
AddGlobalFunc('function IntToBox(x1,y1,x2,y2: integer): TBox', @Lape_IntToBox);
AddGlobalFunc('function IntInBox(x, y: Integer; Box: TBox): Boolean', @Lape_IntInBox);
AddGlobalFunc('function PointToBox(PT1,PT2: TPoint): TBox', @Lape_PointToBox);
AddGlobalFunc('function PointInBox(PT: TPoint; Box: TBox): Boolean', @Lape_PointInBox);
AddGlobalFunc('function logn(base, x: extended): extended', @Lape_logn);
AddGlobalFunc('function sar(AValue: longint; shift: byte): longint', @Lape_sar);
AddGlobalFunc('function ror(num: longword; shift: byte): LongWord', @Lape_ror);
AddGlobalFunc('function rol(num: longword; shift: byte): LongWord', @Lape_rol);
//AddGlobalFunc('function tan(e: extended): extended', @Lape_tan);
AddGlobalFunc('function radians(e: extended): extended', @Lape_radians);
AddGlobalFunc('function degrees(e: extended): extended', @Lape_degrees);
//AddGlobalFunc('function ArcSin(e: extended): extended', @Lape_ArcSin);
//AddGlobalFunc('function ArcCos(e: extended): extended', @Lape_ArcCos);
//AddGlobalFunc('function Cotan(e: extended): extended', @Lape_Cotan);
//AddGlobalFunc('function Secant(e: extended): extended', @Lape_Secant);
//AddGlobalFunc('function Cosecant(e: extended): extended', @Lape_Cosecant);
AddGlobalFunc('function Cot(e: extended): extended', @Lape_Cot);
AddGlobalFunc('function Sec(e: extended): extended', @Lape_Sec);
AddGlobalFunc('function Csc(e: extended): extended', @Lape_Csc);
//AddGlobalFunc('function Cosh(e: extended): extended', @Lape_Cosh);
//AddGlobalFunc('function Sinh(e: extended): extended', @Lape_Sinh);
//AddGlobalFunc('function Tanh(e: extended): extended', @Lape_Tanh);
AddGlobalFunc('function CotH(e: extended): extended', @Lape_CotH);
AddGlobalFunc('function SecH(e: extended): extended', @Lape_SecH);
AddGlobalFunc('function CscH(e: extended): extended', @Lape_CscH);
//AddGlobalFunc('function ArcCosh(e: extended): extended', @Lape_ArcCosh);
//AddGlobalFunc('function ArcSinh(e: extended): extended', @Lape_ArcSinh);
AddGlobalFunc('function DecRet(e: Extended): Extended', @Lape_DecRet);
AddGlobalFunc('function log10(f: Extended): Extended', @Lape_log10);
AddGlobalFunc('function MinA(a: TIntegerArray): Integer', @Lape_MinA);
AddGlobalFunc('function MaxA(a: TIntegerArray): Integer', @Lape_MaxA);
AddGlobalFunc('function Sum64IntArr(const Arr: TIntegerArray): Int64;', @Lape_Sum64IntArr);
AddGlobalFunc('function IntToHex(number: Integer): String; overload;', @Lape_IntToHex);
AddGlobalFunc('function FixRad(rad: Extended): Extended;', @Lape_FixRad);
AddGlobalFunc('function InAbstractBox(x1, y1, x2, y2, x3, y3, x4, y4: Integer; x, y: Integer): Boolean;', @Lape_InAbstractBox);
AddGlobalFunc('function MiddleBox(b: TBox): TPoint', @Lape_MiddleBox);

{ Color }
SetCurrSection('Color');
AddGlobalFunc('function GetColor(x,y: integer): TColor', @Lape_GetColor);
AddGlobalFunc('procedure GetColorsWrap(Coords: TPointArray; var Colors: TIntegerArray);', @Lape_GetColorsWrap);
AddGlobalFunc('function GetColors(const Coords: TPointArray): TIntegerArray', @Lape_GetColors);
AddGlobalFunc('function FindColor(var x, y: integer; color, x1, y1, x2, y2: integer): boolean', @Lape_FindColor);
AddGlobalFunc('function FindColorTolerance(var x, y: integer; color, x1, y1, x2, y2, tol: integer): boolean', @Lape_FindColorTolerance);
AddGlobalFunc('function FindColors(var TPA: TPointArray; Color, x1, y1, x2, y2: Integer): Boolean', @Lape_FindColors);
AddGlobalFunc('procedure SetColorToleranceSpeed(cts: Integer);', @Lape_SetColorToleranceSpeed);
AddGlobalFunc('function GetToleranceSpeed: Integer', @Lape_GetToleranceSpeed);
AddGlobalFunc('procedure SetToleranceSpeed2Modifiers(nHue, nSat: Extended);', @Lape_SetToleranceSpeed2Modifiers);
AddGlobalFunc('procedure GetToleranceSpeed2Modifiers(var hMod, sMod: Extended);', @Lape_GetToleranceSpeed2Modifiers);
AddGlobalFunc('procedure SetToleranceSpeed3Modifier(Modifier: Extended);', @Lape_SetToleranceSpeed3Modifier);
AddGlobalFunc('function GetToleranceSpeed3Modifier: Extended;', @Lape_GetToleranceSpeed3Modifier);
AddGlobalFunc('function SimilarColors(Col1,Col2,Tol: integer): boolean', @Lape_SimilarColors);
AddGlobalFunc('function CountColor(Color, xs, ys, xe, ye: Integer): Integer', @Lape_CountColor);
AddGlobalFunc('function CountColorTolerance(Color, xs, ys, xe, ye, Tolerance: Integer): Integer', @Lape_CountColorTolerance);
AddGlobalFunc('function FindColorsTolerance(var Points: TPointArray; Color, xs, ys, xe, ye, Tolerance: Integer): Boolean', @Lape_FindColorsTolerance);
AddGlobalFunc('function FindColorSpiral(var x, y: Integer; color, xs, ys, xe, ye: Integer): Boolean', @Lape_FindColorSpiral);
AddGlobalFunc('function FindColorSpiralTolerance(var x, y: Integer; color, xs, ys, xe, ye,Tol: Integer): Boolean', @Lape_FindColorSpiralTolerance);
AddGlobalFunc('function FindColorsSpiralTolerance(x, y: Integer; var Points: TPointArray; color, xs, ys, xe, ye: Integer; Tolerance: Integer): boolean', @Lape_FindColorsSpiralTolerance);
AddGlobalFunc('function FindColoredArea(var x, y: Integer; color, xs, ys, xe, ye: Integer; MinArea: Integer): Boolean', @Lape_FindColoredArea);
AddGlobalFunc('function FindColoredAreaTolerance(var x, y: Integer; Color, xs, ys, xe, ye, MinArea, tol: Integer): Boolean', @Lape_FindColoredAreaTolerance);

{ Color Conversions }
SetCurrSection('Color Conversions');
AddGlobalFunc('procedure ColorToRGB(Color: integer; var r, g, b: Integer);', @Lape_ColorToRGB);
AddGlobalFunc('function RGBtoColor(r, g, b: Integer): TColor', @Lape_RGBtoColor);
AddGlobalFunc('procedure ColorToHSL(Color: Integer; var h, s, l: Extended);', @Lape_ColorToHSL);
AddGlobalFunc('function HSLToColor(H, S, L: Extended): TColor', @Lape_HSLToColor);
AddGlobalFunc('procedure ColorToXYZ(Color: Integer; var x, y, z: Extended);', @Lape_ColorToXYZ);
AddGlobalFunc('function XYZToColor(X, Y, Z: Extended): TColor', @Lape_XYZToColor);
AddGlobalFunc('procedure RGBToHSL(R, G, B: Integer; var h, s, l: Extended);', @Lape_RGBToHSL);
AddGlobalFunc('procedure HSLtoRGB(H, S, L: extended; var R, G,B: Integer);', @Lape_HSLtoRGB);
AddGlobalFunc('procedure RGBToXYZ(R, G, B: Integer; var x, y,z: Extended);', @Lape_RGBToXYZ);
AddGlobalFunc('procedure XYZToRGB(X, Y, Z: Extended; var R, G, B: Integer);', @Lape_XYZToRGB);
AddGlobalFunc('procedure XYZToHSL(X, Y, Z: Extended; out H, S, L: Extended);', @Lape_XYZToHSL);
AddGlobalFunc('procedure HSLToXYZ(H, S, L: Extended; out X, Y, Z: Extended);', @Lape_HSLToXYZ);
AddGlobalFunc('procedure XYZtoCIELab(X, Y, Z: Extended; out L, a, b: Extended);', @Lape_XYZtoCIELab);
AddGlobalFunc('procedure CIELabtoXYZ(L, a, b: Extended; out X, Y, Z: Extended);', @Lape_CIELabtoXYZ);
AddGlobalFunc('procedure CIELabToRGB(L, a, b: Extended; out rr, gg, bb: Integer);', @Lape_CIELabToRGB);
AddGlobalFunc('procedure RGBToCIELab(rr, gg, bb: integer; out L, a, b: Extended);', @Lape_RGBToCIELab);
AddGlobalFunc('function CIELabToColor(L, a, b: Extended): TColor;', @Lape_CIELabToColor);
AddGlobalFunc('procedure ColorToCIELab(Color: integer; out L, a, b: Extended);', @Lape_ColorToCIELab);
AddGlobalFunc('procedure CIELabToHSL(L, a, b: Extended; out HH, SS, LL: Extended);', @Lape_CIELabToHSL);
AddGlobalFunc('procedure HSLToCIELab(HH, SS, LL: Extended; out L, a, b: Extended);', @Lape_HSLToCIELab);
AddGlobalFunc('function ColorToGray(const Color: Integer): TColor', @Lape_ColorToGray);

{ Crypto }
SetCurrSection('Crypto');
AddGlobalFunc('function haval(Data: string): string', @Lape_haval);
AddGlobalFunc('function md4(Data: string): string', @Lape_md4);
AddGlobalFunc('function md5(Data: string): string', @Lape_md5);
AddGlobalFunc('function ripemd128(Data: string): string', @Lape_ripemd128);
AddGlobalFunc('function ripemd160(Data: string): string', @Lape_ripemd160);
AddGlobalFunc('function sha1(Data: string): string', @Lape_sha1);
AddGlobalFunc('function sha256(Data: string): string', @Lape_sha256);
AddGlobalFunc('function sha384(Data: string): string', @Lape_sha384);
AddGlobalFunc('function sha512(Data: string): string', @Lape_sha512);
AddGlobalFunc('function tiger(Data: string): string', @Lape_tiger);
AddGlobalFunc('procedure rc2_encrypt(const Key: string; const HashType: THashType; var Data: string);', @Lape_rc2_encrypt);
AddGlobalFunc('procedure rc2_decrypt(const Key: string; const HashType: THashType; var Data: string);', @Lape_rc2_decrypt);

{ Files }
SetCurrSection('Files');
AddGlobalFunc('function CreateFile(const Path: string): Integer', @Lape_CreateFile);
AddGlobalFunc('function OpenFile(const Path: string; Shared: Boolean): Integer', @Lape_OpenFile);
AddGlobalFunc('function RewriteFile(const Path: string; Shared: Boolean): Integer', @Lape_RewriteFile);
AddGlobalFunc('function AppendFile(const Path: string): Integer', @Lape_AppendFile);
AddGlobalFunc('procedure CloseFile(FileNum: Integer);', @Lape_CloseFile);
AddGlobalFunc('function EndOfFile(FileNum: Integer): Boolean', @Lape_EndOfFile);
AddGlobalFunc('function FileSize(FileNum: Integer): LongInt', @Lape_FileSize);
AddGlobalFunc('function ReadFileString(FileNum: Integer; var s: string; x: Integer): Boolean', @Lape_ReadFileString);
AddGlobalFunc('function WriteFileString(FileNum: Integer; s: string): Boolean', @Lape_WriteFileString);
AddGlobalFunc('function SetFileCharPointer(FileNum, cChars, Origin: Integer): Integer', @Lape_SetFileCharPointer);
AddGlobalFunc('function FilePointerPos(FileNum: Integer): Integer', @Lape_FilePointerPos);
AddGlobalFunc('function FileExists(const FileName: string): Boolean', @Lape_FileExists);
AddGlobalFunc('function DirectoryExists(const DirectoryName: string): Boolean', @Lape_DirectoryExists);
AddGlobalFunc('function CreateDirectory(const DirectoryName: string): boolean', @Lape_CreateDirectory);
AddGlobalFunc('function ForceDirectories(const dir: string): boolean', @Lape_ForceDirectories);
AddGlobalFunc('function GetFiles(const Path, Ext: string): TStringArray', @Lape_GetFiles);
AddGlobalFunc('function GetDirectories(const path: string): TStringArray', @Lape_GetDirectories);
AddGlobalFunc('function DeleteFile(const Filename: string): Boolean',  @Lape_DeleteFile);
AddGlobalFunc('function RenameFile(const Oldname, NewName: string): Boolean;', @Lape_RenameFile);
AddGlobalFunc('procedure WriteINI(const Section, KeyName, NewString, FileName: string);', @Lape_WriteINI);
AddGlobalFunc('function ReadINI(const Section, KeyName, FileName: string): string', @Lape_ReadINI);
AddGlobalFunc('procedure DeleteINI(const Section, KeyName, FileName: string);', @Lape_DeleteINI);
AddGlobalFunc('function DeleteDirectory(const Dir: String; const Empty: Boolean): Boolean;', @Lape_DeleteDirectory);
AddGlobalFunc('procedure ZipFiles(const ToFolder: string; const Files: TStringArray);', @Lape_ZipFiles);
AddGlobalFunc('procedure UnZipFile(const FilePath, TargetPath: string);', @Lape_UnZipFile);

{ Web }
SetCurrSection('Web');
AddGlobalFunc('procedure OpenWebPage(const url: string);', @Lape_OpenWebPage);
AddGlobalFunc('function GetPage(const S: String): String', @Lape_GetPage);
AddGlobalFunc('function InitializeHTTPClient(HandleCookies: Boolean): Integer', @Lape_InitializeHTTPClient);
AddGlobalFunc('procedure FreeHTTPClient(Client: Integer);', @Lape_FreeHTTPClient);
AddGlobalFunc('function GetHTTPPage(Client: Integer; const URL: string): string', @Lape_GetHTTPPage);
AddGlobalFunc('procedure SetHTTPUserAgent(Client: Integer; const Agent: string);', @Lape_SetHTTPUserAgent);
AddGlobalFunc('function PostHTTPPage(Client: Integer; const Url,PostData: string): string', @Lape_PostHTTPPage);
AddGlobalFunc('function PostHTTPPageEx(Client: Integer; const Url: string): string', @Lape_PostHTTPPageEx);
AddGlobalFunc('procedure ClearPostData(Client: Integer);', @Lape_ClearPostData);
AddGlobalFunc('procedure AddPostVariable(Client: Integer; const VarName, VarValue: string);', @Lape_AddPostVariable);
AddGlobalFunc('function GetRawHeaders(Client: Integer): string', @Lape_GetRawHeaders);
AddGlobalFunc('procedure SetProxy(Client: Integer; pHost, pPort: String);', @Lape_SetProxy);

{ Socket }
SetCurrSection('Socket');
AddGlobalFunc('function RecvSocketStr(Client: integer): string', @Lape_RecvSocketStr);
AddGlobalFunc('function RecvSocket(Client: integer): string', @Lape_RecvSocket);
AddGlobalFunc('function RecvSocketEx(Client, Length: integer): string', @Lape_RecvSocketEx);
AddGlobalFunc('procedure SendSocket(Client: integer; Data: string);', @Lape_SendSocket);
AddGlobalFunc('procedure ConnectSocket(Client: integer; IP, Port: string);', @Lape_ConnectSocket);
AddGlobalFunc('procedure CloseSocket(Client: integer);', @Lape_CloseSocket);
AddGlobalFunc('procedure SetSocketTimeout(Client, Time: integer);', @Lape_SetSocketTimeout);
AddGlobalFunc('procedure BindSocket(Client: integer; IP, Port: string);', @Lape_BindSocket);
AddGlobalFunc('procedure ListenSocket(Client: integer);', @Lape_ListenSocket);
AddGlobalFunc('function AcceptSocket(Client: integer): integer', @Lape_AcceptSocket);
AddGlobalFunc('procedure SocketInfo(Client: integer; out IP, Port: string);', @Lape_SocketInfo);
AddGlobalFunc('function CreateSocket: integer', @Lape_CreateSocket);
AddGlobalFunc('procedure FreeSocket(Client: integer);', @Lape_FreeSocket);

{ Mouse }
SetCurrSection('Mouse');
AddGlobalFunc('procedure MoveMouse(x, y: integer);', @Lape_MoveMouse);
AddGlobalFunc('procedure ScrollMouse(x,y: integer; Clicks: integer);', @Lape_ScrollMouse);
AddGlobalFunc('procedure GetMousePos(var x, y: integer);', @Lape_GetMousePos);
AddGlobalFunc('function ConvIntClickType(Int: Integer): TClickType', @Lape_ConvIntClickType);
AddGlobalFunc('procedure HoldMouse(x, y: integer; clickType: integer);', @Lape_HoldMouse);
AddGlobalFunc('procedure ReleaseMouse(x, y: integer; clickType: integer);', @Lape_ReleaseMouse);
AddGlobalFunc('procedure ClickMouse(x, y: integer; clickType: integer);', @Lape_ClickMouse);
AddGlobalFunc('function IsMouseButtonDown(button: integer): boolean', @Lape_IsMouseButtonDown);

{ Keyboard }
SetCurrSection('Keyboard');
AddGlobalFunc('procedure KeyDown(key: Word);', @Lape_KeyDown);
AddGlobalFunc('procedure KeyUp(key: Word);', @Lape_KeyUp);
AddGlobalFunc('procedure SendKeys(const s: string; keywait, keymodwait: integer);', @Lape_SendKeys);
AddGlobalFunc('procedure PressKey(key: Word);', @Lape_PressKey);
AddGlobalFunc('function isKeyDown(key: Word): boolean', @Lape_isKeyDown);
AddGlobalFunc('function GetKeyCode(c: char): integer', @Lape_GetKeyCode);

{ OCR }
SetCurrSection('OCR');
AddGlobalFunc('function rs_GetUpText: String', @Lape_rs_GetUpText);
AddGlobalFunc('function rs_GetUpTextAtEx(x, y: integer; shadow: boolean; fontname: string): string', @Lape_rs_GetUpTextAtEx);
AddGlobalFunc('function rs_GetUpTextAt(x, y: integer): string', @Lape_rs_GetUpTextAt);
AddGlobalFunc('function BitmapFromText(const text, font: String): integer', @Lape_BitmapFromText);
AddGlobalFunc('function MaskFromText(const text, font: String): TMask', @Lape_MaskFromText);
AddGlobalFunc('procedure TPAFromTextWrap(const text, font: String; var w,h: integer; out TPA: TPointArray);', @Lape_TPAFromTextWrap);
AddGlobalFunc('function TPAFromText(const text, font: String; var w,h: integer): TPointArray', @Lape_TPAFromText);
AddGlobalFunc('function GetTextATPA(const ATPA: T2DPointArray; const maxvspacing: integer; const font: string): string', @Lape_GetTextATPA);
AddGlobalFunc('function GetTextAt(const atX, atY, minvspacing, maxvspacing, hspacing, color, tol, len: integer; const font: string): string', @Lape_GetTextAt);
AddGlobalFunc('function GetTextAtEx(const xs,ys,xe,ye, minvspacing, maxvspacing, hspacing, color, tol: integer; const font: string): string', @Lape_GetTextAtEx);
AddGlobalFunc('procedure rs_SetUpTextFilter(filterdata: TOcrFilterDataArray);', @Lape_SetUpTextFilter);
AddGlobalFunc('procedure rs_ResetUpTextFilter;', @Lape_ResetUpTextFilter);
AddGlobalFunc('function LoadSystemFont(const SysFont: TFont; const FontName: string): boolean', @Lape_LoadSystemFont);
AddGlobalFunc('function LoadFont(const FontName: string; shadow: boolean): boolean', @Lape_LoadFont);
AddGlobalFunc('function FreeFont(const FontName: string): boolean', @Lape_FreeFont);
AddGlobalFunc('function IsFontLoaded(const FontName: string): boolean;', @Lape_IsFontLoaded);
AddGlobalFunc('procedure ocr_FilterUpTextByCharacteristics(bmp: TMufasaBitmap);', @Lape_FilterUpTextByCharacteristics);

{ Settings }
SetCurrSection('Settings');
AddGlobalFunc('function SetSettingValue(const KeyName,value: string): boolean', @Lape_SetSettingValue);
AddGlobalFunc('function KeyIsSetting(const KeyName: String): Boolean', @Lape_KeyIsSetting);
AddGlobalFunc('function KeyIsDirectory(const KeyName: String): Boolean', @Lape_KeyIsDirectory);
AddGlobalFunc('function GetSettingValue(const KeyName: String): String', @Lape_GetSettingValue);
AddGlobalFunc('function GetSettingValueDef(const KeyName, defVal: String): String', @Lape_GetSettingValueDef);
AddGlobalFunc('function ListSettings(const KeyName: String; var KeyReturn: TStringArray): boolean', @Lape_ListSettings);
AddGlobalFunc('function DeleteSetting(const KeyName: String): Boolean', @Lape_DeleteSetting);
AddGlobalFunc('function DeleteSubSettings(const KeyName: String): Boolean', @Lape_DeleteSubSettings);

{ String }
SetCurrSection('String');
AddGlobalFunc('function Capitalize(str: string): string', @Lape_Capitalize);
AddGlobalFunc('function CompressString(const Str: string): string', @Lape_CompressString);
AddGlobalFunc('function DecompressString(const Compressed: string): string', @Lape_DecompressString);
AddGlobalFunc('function Base64Encode(const str: string): string', @Lape_Base64Encode);
AddGlobalFunc('function Base64Decode(const str: string): string', @Lape_Base64Decode);
AddGlobalFunc('function ExtractFromStr(Str: string; Extract: StrExtr): string', @Lape_ExtractFromStr);
AddGlobalFunc('function Replace(Text, FindStr, ReplaceStr: string; Flags: TReplaceFlags): string', @Lape_Replace);
AddGlobalFunc('function Between(s1, s2, str: string): string', @Lape_Between);
AddGlobalFunc('function Implode(Glue: string; Pieces: TStringArray): string', @Lape_Implode);
AddGlobalFunc('function Explode(del, str: string): TStringArray', @Lape_Explode);
AddGlobalFunc('procedure ExplodeWrap(del, str: string; var res: TStringArray);', @Lape_ExplodeWrap);
AddGlobalFunc('function ExecRegExpr(const RegExpr, InputStr: String): boolean', @Lape_ExecRegExpr);
AddGlobalFunc('procedure SplitRegExpr(const RegExpr, InputStr: String; Pieces: TStrings);', @Lape_SplitRegExpr);
AddGlobalFunc('function ReplaceRegExpr(const RegExpr, InputStr, ReplaceStr: String; UseSubstitution: boolean): String', @Lape_ReplaceRegExpr);
AddGlobalFunc('function PosEx(needle, haystack: String; offset: integer): integer', @Lape_PosEx);
AddGlobalFunc('function LevDistance(src, target: string): Integer', @Lape_LevDist);
AddGlobalFunc('function NormLevDistance(src, target: string): Extended', @Lape_NormLevDist);
AddGlobalFunc('function StringMatch(checkCompare, goalCompare: string): extended;', @Lape_StringMatch);
AddGlobalFunc('function MultiBetween(str, s1, s2: string): TStringArray;', @Lape_MultiBetween);
AddGlobalFunc('function IsArrInStr(strArr: TStringArray; s: string): boolean;', @Lape_IsArrInStr);
AddGlobalFunc('function IsStrInArr(const s: string; const UsePos: Boolean; const arr: TStringArray): boolean;', @Lape_IsStrInArr);
AddGlobalFunc('function PosMulti(const SubStr: String; Text: string): TIntegerArray;', @Lape_PosMulti);

{ TPA }
SetCurrSection('TPA');
AddGlobalFunc('procedure Quicksort(var Arr: TIntegerArray);', @Lape_Quicksort);
AddGlobalFunc('procedure tSwap(var a, b: TPoint);', @Lape_tSwap);
AddGlobalFunc('procedure tpaSwap(var a, b: TPointArray);', @Lape_tpaSwap);
AddGlobalFunc('procedure SwapE(var a, b: Extended);', @Lape_SwapE);
AddGlobalFunc('procedure RAaSTPAEx(var a: TPointArray; const w, h: Integer);', @Lape_RAaSTPAEx);
AddGlobalFunc('procedure RAaSTPA(var a: TPointArray; const Dist: Integer);', @Lape_RAaSTPA);
AddGlobalFunc('function NearbyPointInArrayEx(const P: TPoint; w, h: Integer; const a: TPointArray): Boolean', @Lape_NearbyPointInArrayEx);
AddGlobalFunc('function NearbyPointInArray(const P: TPoint; Dist: Integer; const a: TPointArray): Boolean', @Lape_NearbyPointInArray);
AddGlobalFunc('procedure QuickTPASort(var A: TIntegerArray; var B: TPointArray; iLo, iHi: Integer; SortUp: Boolean);', @Lape_QuickTPASort);
AddGlobalFunc('procedure QuickATPASort(var A: TIntegerArray; var B: T2DPointArray; iLo, iHi: Integer; SortUp: Boolean);', @Lape_QuickATPASort);
AddGlobalFunc('procedure SortTPAByX(var a: TPointArray; const LowToHi: Boolean);', @Lape_SortTPAByX);
AddGlobalFunc('procedure SortTPAByY(var a: TPointArray; const LowToHi: Boolean);', @Lape_SortTPAByY);
AddGlobalFunc('function FindTPARows(a: TPointArray): T2DPointArray;', @Lape_FindTPARows);
AddGlobalFunc('function FindTPAColumns(a: TPointArray): T2DPointArray;', @Lape_FindTPAColumns);
AddGlobalFunc('procedure SortTPAFrom(var a: TPointArray; const From: TPoint);', @Lape_SortTPAFrom);
AddGlobalFunc('procedure SortATPAFrom(var a: T2DPointArray; const From: TPoint);', @Lape_SortATPAFrom);
AddGlobalFunc('procedure SortATPAFromFirstPoint(var a: T2DPointArray; const From: TPoint);', @Lape_SortATPAFromFirstPoint);
AddGlobalFunc('procedure SortATPAFromMidPoint(var a: T2DPointArray; const From: TPoint);', @Lape_SortATPAFromMidPoint);
AddGlobalFunc('procedure SortATPAFromFirstPointX(var a: T2DPointArray; const From: TPoint);', @Lape_SortATPAFromFirstPointX);
AddGlobalFunc('procedure SortATPAFromFirstPointY(var a: T2DPointArray; const From: TPoint);', @Lape_SortATPAFromFirstPointY);
AddGlobalFunc('procedure InvertTPA(var a: TPointArray);', @Lape_InvertTPA);
AddGlobalFunc('procedure InvertATPA(var a: T2DPointArray);', @Lape_InvertATPA);
AddGlobalFunc('function MiddleTPAEx(const TPA: TPointArray; var x, y: Integer): Boolean', @Lape_MiddleTPAEx);
AddGlobalFunc('function MiddleTPA(const tpa: TPointArray): TPoint', @Lape_MiddleTPA);
AddGlobalFunc('procedure MedianTPAEx(var tpa: TPointArray; out x, y: integer);', @Lape_MedianTPAEx);
AddGlobalFunc('function MedianTPA(var tpa: TPointArray): TPoint;', @Lape_MedianTPA);
AddGlobalFunc('procedure SortATPASize(var a: T2DPointArray; const BigFirst: Boolean);', @Lape_SortATPASize);
AddGlobalFunc('procedure SortATPAFromSize(var a: T2DPointArray; const Size: Integer; CloseFirst: Boolean);', @Lape_SortATPAFromSize);
AddGlobalFunc('procedure FilterTPAsBetween(var atpa: T2DPointArray; const minLength, maxLength: integer);', @Lape_FilterTPAsBetween);
AddGlobalFunc('function InIntArrayEx(const a: TIntegerArray; var Where: Integer; const Number: Integer): Boolean', @Lape_InIntArrayEx);
AddGlobalFunc('function InIntArray(const a: TIntegerArray; Number: Integer): Boolean', @Lape_InIntArray);
AddGlobalFunc('procedure ClearSameIntegers(var a: TIntegerArray);', @Lape_ClearSameIntegers);
AddGlobalFunc('procedure ClearSameIntegersAndTPA(var a: TIntegerArray; var p: TPointArray);', @Lape_ClearSameIntegersAndTPA);
AddGlobalFunc('function SplitTPAEx(const arr: TPointArray; w, h: Integer): T2DPointArray', @Lape_SplitTPAEx);
AddGlobalFunc('function SplitTPA(const arr: TPointArray; Dist: Integer): T2DPointArray', @Lape_SplitTPA);
AddGlobalFunc('function ClusterTPAEx(const TPA: TPointArray; width, height: Integer): T2DPointArray;', @Lape_ClusterTPAEx);
AddGlobalFunc('function ClusterTPA(const TPA: TPointArray; dist: Integer): T2DPointArray;', @Lape_ClusterTPA);
AddGlobalFunc('function FloodFillTPA(const TPA: TPointArray): T2DPointArray', @Lape_FloodFillTPA);
AddGlobalFunc('procedure FilterPointsPie(var Points: TPointArray; const SD, ED, MinR, MaxR: Extended; Mx, My: Integer);', @Lape_FilterPointsPie);
AddGlobalFunc('procedure FilterPointsDist(var Points: TPointArray; const MinDist, MaxDist: Extended; Mx, My: Integer);', @Lape_FilterPointsDist);
AddGlobalFunc('procedure FilterPointsLine(var Points: TPointArray; Radial: Extended; Radius, MX, MY: Integer);', @Lape_FilterPointsLine);
AddGlobalFunc('procedure FilterPointsBox(var points: TPointArray; x1, y1, x2, y2: integer);', @Lape_FilterPointsBox);
AddGlobalFunc('procedure FilterTPADist(var TPA: TPointArray; maxDist: integer);', @Lape_FilterTPADist);
AddGlobalFunc('function GetATPABounds(const ATPA: T2DPointArray): TBox', @Lape_GetATPABounds);
AddGlobalFunc('function GetTPABounds(const TPA: TPointArray): TBox', @Lape_GetTPABounds);
AddGlobalFunc('function FindTPAinTPA(const SearchTPA, TotalTPA: TPointArray; var Matches: TPointArray): Boolean', @Lape_FindTPAinTPA);
AddGlobalFunc('function GetSamePointsATPA(const ATPA: T2DPointArray; var Matches: TPointArray): boolean', @Lape_GetSamePointsATPA);
AddGlobalFunc('function FindTextTPAinTPA(Height: integer; const SearchTPA, TotalTPA: TPointArray; var Matches: TPointArray): Boolean', @Lape_FindTextTPAinTPA);
AddGlobalFunc('procedure SortCircleWise(var tpa: TPointArray; const cx, cy, StartDegree: Integer; SortUp, ClockWise: Boolean);', @Lape_SortCircleWise);
AddGlobalFunc('procedure LinearSort(var tpa: TPointArray; cx, cy, sd: Integer; SortUp: Boolean);', @Lape_LinearSort);
AddGlobalFunc('function RotatePoint(Const p: TPoint; angle, mx, my: Extended): TPoint', @Lape_RotatePoint);
AddGlobalFunc('function ChangeDistPT(const PT: TPoint; mx,my: integer; newdist: extended): TPoint', @Lape_ChangeDistPT);
AddGlobalFunc('function ChangeDistTPA(var TPA: TPointArray; mx,my: integer; newdist: extended): boolean', @Lape_ChangeDistTPA);
AddGlobalFunc('function FindGapsTPA(const TPA: TPointArray; MinPixels: Integer): T2DPointArray', @Lape_FindGapsTPA);
AddGlobalFunc('function RemoveDistTPointArray(x, y, dist: Integer; const ThePoints: TPointArray; RemoveHigher: Boolean): TPointArray', @Lape_RemoveDistTPointArray);
AddGlobalFunc('function CombineTPA(const Ar1, Ar2: TPointArray): TPointArray', @Lape_CombineTPA);
AddGlobalFunc('function ReArrangeandShortenArrayEx(const a: TPointArray; w, h: Integer): TPointArray', @Lape_ReArrangeandShortenArrayEx);
AddGlobalFunc('function ReArrangeandShortenArray(const a: TPointArray; Dist: Integer): TPointArray', @Lape_ReArrangeandShortenArray);
AddGlobalFunc('function TPAtoATPAEx(const TPA: TPointArray; w, h: Integer): T2DPointArray', @Lape_TPAtoATPAEx);
AddGlobalFunc('function TPAtoATPA(const TPA: TPointArray; Dist: Integer): T2DPointArray', @Lape_TPAtoATPA);
AddGlobalFunc('function CombineIntArray(const Ar1, Ar2: TIntegerArray): TIntegerArray', @Lape_CombineIntArray);
AddGlobalFunc('function MergeATPA(const ATPA: T2DPointArray): TPointArray', @Lape_MergeATPA);
AddGlobalFunc('procedure AppendTPA(var TPA: TPointArray; const ToAppend: TPointArray);', @Lape_AppendTPA);
AddGlobalFunc('function TPAFromLine(const x1, y1, x2, y2: Integer): TPointArray', @Lape_TPAFromLine);
AddGlobalFunc('function EdgeFromBox(const Box: TBox): TPointArray', @Lape_EdgeFromBox);
AddGlobalFunc('function TPAFromBox(const Box: TBox): TPointArray', @Lape_TPAFromBox);
AddGlobalFunc('function TPAFromEllipse(const CX, CY, XRadius, YRadius : Integer) : TPointArray', @Lape_TPAFromEllipse);
AddGlobalFunc('function TPAFromCircle(const CX, CY, Radius : Integer) : TPointArray', @Lape_TPAFromCircle);
AddGlobalFunc('function TPAFromPolygon(const shape: TPointArray) : TPointArray', @Lape_TPAFromPolygon);
AddGlobalFunc('procedure FillEllipse(var a: TPointArray);', @Lape_FillEllipse);
AddGlobalFunc('function RotatePoints(Const P: TPointArray; A, cx, cy: Extended): TPointArray', @Lape_RotatePoints);
AddGlobalFunc('function FindTPAEdges(const p: TPointArray): TPointArray', @Lape_FindTPAEdges);
AddGlobalFunc('function ClearTPAFromTPA(const arP, ClearPoints: TPointArray): TPointArray', @Lape_ClearTPAFromTPA);
AddGlobalFunc('function ReturnPointsNotInTPA(Const TotalTPA: TPointArray; const Box: TBox): TPointArray', @Lape_ReturnPointsNotInTPA);
AddGlobalFunc('function PointInTPA(p: TPoint; const arP: TPointArray): Boolean', @Lape_PointInTPA);
AddGlobalFunc('procedure ClearDoubleTPA(var TPA: TPointArray);', @Lape_ClearDoubleTPA);
AddGlobalFunc('procedure TPACountSort(Var TPA: TPointArray; const max: TPoint; Const SortOnX: Boolean);', @Lape_TPACountSort);
AddGlobalFunc('procedure TPACountSortBase(Var TPA: TPointArray; const maxx, base: TPoint; const SortOnX: Boolean);', @Lape_TPACountSortBase);
AddGlobalFunc('procedure InvertTIA(var tI: TIntegerArray);', @Lape_InvertTIA);
AddGlobalFunc('function SumIntegerArray(const Ints: TIntegerArray): Integer', @Lape_SumIntegerArray);
AddGlobalFunc('function AverageTIA(const tI: TIntegerArray): Integer', @Lape_AverageTIA);
AddGlobalFunc('function AverageExtended(const tE: TExtendedArray): Extended', @Lape_AverageExtended);
AddGlobalFunc('procedure SplitTPAExWrap(const arr: TPointArray; w, h: Integer; var res: T2DPointArray);', @Lape_SplitTPAExWrap);
AddGlobalFunc('procedure SplitTPAWrap(const arr: TPointArray; Dist: Integer; var res: T2DPointArray);', @Lape_SplitTPAWrap);
AddGlobalFunc('procedure FindGapsTPAWrap(const TPA: TPointArray; MinPixels: Integer; var Res: T2DPointArray);', @Lape_FindGapsTPAWrap);
AddGlobalFunc('procedure RemoveDistTPointArrayWrap(x, y, dist: Integer; const ThePoints: TPointArray; RemoveHigher: Boolean; var Res: TPointArray);', @Lape_RemoveDistTPointArrayWrap);
AddGlobalFunc('procedure CombineTPAWrap(const Ar1, Ar2: TPointArray; var Res: TPointArray);', @Lape_CombineTPAWrap);
AddGlobalFunc('procedure ReArrangeandShortenArrayExWrap(const a: TPointArray; w, h: Integer; var Res: TPointArray);', @Lape_ReArrangeandShortenArrayExWrap);
AddGlobalFunc('procedure ReArrangeandShortenArrayWrap(const a: TPointArray; Dist: Integer; var Res: TPointArray);', @Lape_ReArrangeandShortenArrayWrap);
AddGlobalFunc('procedure TPAtoATPAExWrap(const TPA: TPointArray; w, h: Integer; var Res: T2DPointArray);', @Lape_TPAtoATPAExWrap);
AddGlobalFunc('procedure TPAtoATPAWrap(const TPA: TPointArray; Dist: Integer; var Res: T2DPointArray);', @Lape_TPAtoATPAWrap);
AddGlobalFunc('procedure CombineIntArrayWrap(const Ar1, Ar2: TIntegerArray; var Res: TIntegerArray);', @Lape_CombineIntArrayWrap);
AddGlobalFunc('procedure MergeATPAWrap(const ATPA: T2DPointArray; var Res: TPointArray);', @Lape_MergeATPAWrap);
AddGlobalFunc('procedure TPAFromLineWrap(const x1, y1, x2, y2: Integer; var Res: TPointArray);', @Lape_TPAFromLineWrap);
AddGlobalFunc('procedure EdgeFromBoxWrap(const Box: TBox; var Res: TPointArray);', @Lape_EdgeFromBoxWrap);
AddGlobalFunc('procedure TPAFromBoxWrap(const Box: TBox; var Res: TPointArray);', @Lape_TPAFromBoxWrap);
AddGlobalFunc('procedure TPAFromEllipseWrap(const CX, CY, XRadius, YRadius : Integer; var Res: TPointArray);', @Lape_TPAFromEllipseWrap);
AddGlobalFunc('procedure TPAFromCircleWrap(const CX, CY, Radius : Integer; var Res: TPointArray);', @Lape_TPAFromCircleWrap);
AddGlobalFunc('procedure RotatePointsWrap(Const P: TPointArray; A, cx, cy: Extended; var Res: TPointArray);', @Lape_RotatePointsWrap);
AddGlobalFunc('procedure FindTPAEdgesWrap(const p: TPointArray; var Res: TPointArray);', @Lape_FindTPAEdgesWrap);
AddGlobalFunc('procedure ClearTPAFromTPAWrap(const arP, ClearPoints: TPointArray; var Res: TPointArray);', @Lape_ClearTPAFromTPAWrap);
AddGlobalFunc('procedure ReturnPointsNotInTPAWrap(Const TotalTPA: TPointArray; const Box: TBox; var Res: TPointArray);', @Lape_ReturnPointsNotInTPAWrap);
AddGlobalFunc('function SameTPA(const aTPA, bTPA: TPointArray): Boolean', @Lape_SameTPA);
AddGlobalFunc('function TPAInATPA(const TPA: TPointArray; const InATPA: T2DPointArray; var Index: LongInt): Boolean', @Lape_TPAInATPA);
AddGlobalFunc('procedure OffsetTPA(var TPA: TPointArray; const Offset: TPoint);', @Lape_OffsetTPA);
AddGlobalFunc('procedure OffsetATPA(var ATPA: T2DPointArray; const Offset: TPoint);', @Lape_OffsetATPA);
AddGlobalFunc('function CopyTPA(const TPA: TPointArray): TPointArray', @Lape_CopyTPA);
AddGlobalFunc('function CopyATPA(const ATPA: T2DPointArray): T2DPointArray', @Lape_CopyATPA);
AddGlobalFunc('function TPAPosNext(const Find: TPoint; const V: TPointArray; const PrevPos: Integer;const IsSortedAscending: Boolean): Integer;',@Lape_TPAPosNext);
AddGlobalFunc('function GlueTPAs(const V1, V2: TPointArray; const IsSortedAscending,byDifference: Boolean):TPointArray;',@Lape_GlueTPAs);
AddGlobalFunc('function PartitionTPA(const TPA: TPointArray; BoxWidth, BoxHeight: Integer): T2DPointArray;', @Lape_PartitionTPA);

{ Window }
SetCurrSection('Window');
AddGlobalFunc('procedure SetDesktopAsClient;', @Lape_SetDesktopAsClient);
AddGlobalFunc('function SetTargetArray(P: Integer; w, h: integer): integer', @Lape_SetTargetArray);
AddGlobalFunc('function SetTargetBitmap(bitmap: Integer): integer', @Lape_SetTargetBitmap);
AddGlobalFunc('function SetEIOSTarget(name, args: String): integer', @Lape_SetEIOSTarget);
AddGlobalFunc('function MouseSetClientArea(x1, y1, x2, y2: integer): boolean;', @Lape_MouseSetClientArea);
AddGlobalFunc('procedure MouseResetClientArea;', @Lape_MouseResetClientArea);
AddGlobalFunc('function ImageSetClientArea(x1, y1, x2, y2: integer): boolean;', @Lape_ImageSetClientArea);
AddGlobalFunc('procedure ImageResetClientArea;', @Lape_ImageResetClientArea);
AddGlobalFunc('procedure SetImageTarget(idx: integer);', @Lape_SetImageTarget);
AddGlobalFunc('procedure SetKeyMouseTarget(idx: integer);', @Lape_SetKeyMouseTarget);
AddGlobalFunc('function GetImageTarget: integer', @Lape_GetImageTarget);
AddGlobalFunc('function GetKeyMouseTarget: integer', @Lape_GetKeyMouseTarget);
AddGlobalFunc('function ExportImageTarget: TTarget_Exported', @Lape_ExportImageTarget);
AddGlobalFunc('function ExportKeyMouseTarget: TTarget_Exported', @Lape_ExportKeyMouseTarget);
AddGlobalFunc('procedure FreeTarget(idx: integer);', @Lape_FreeTarget);
AddGlobalFunc('procedure GetClientDimensions(var w, h: integer);', @Lape_GetClientDimensions);
AddGlobalFunc('procedure GetClientPosition(var left, top: integer);', @Lape_GetClientPosition);
AddGlobalFunc('function Freeze: boolean', @Lape_Freeze);
AddGlobalFunc('function Unfreeze: boolean', @Lape_Unfreeze);
AddGlobalFunc('procedure ActivateClient;', @Lape_ActivateClient);
AddGlobalFunc('function IsTargetValid: boolean', @Lape_IsTargetValid);
AddGlobalFunc('function GetNativeWindow: integer;', @Lape_GetNativeWindow);

{ SQLite3 }

{$IFDEF USE_SQLITE}
if (SQLite3Loaded) then
begin
  SetCurrSection('SQLite');
  AddGlobalFunc('function sqlite_version() : string;', @lp_sqlite_version);
  AddGlobalFunc('function sqlite_version_num() : integer;', @lp_sqlite_version_num);
  AddGlobalFunc('function sqlite_escape(s : string) : string;', @lp_sqlite_escape);
  AddGlobalFunc('procedure sqlite_close(index : integer);', @lp_sqlite_close);
  AddGlobalFunc('function sqlite_open(filename : string) : integer;', @lp_sqlite_open);
  AddGlobalFunc('function sqlite_open(filename : string; flags : integer) : integer; overload;', @lp_sqlite_open_v2);
  AddGlobalFunc('function sqlite_open_v2(filename : string; flags : integer) : integer;', @lp_sqlite_open_v2);
  AddGlobalFunc('function sqlite_errMsg(index : integer) : string;', @lp_sqlite_errmsg);
  AddGlobalFunc('function sqlite_errCode(index : integer) : integer;', @lp_sqlite_errcode);
  AddGlobalFunc('function sqlite_query(index : integer; sql : string) : boolean;', @lp_sqlite_query);
  AddGlobalFunc('function sqlite_query(index : integer; sql : string; out data : T2DStringArray) : boolean; overload;', @lp_sqlite_queryvalue);
  AddGlobalFunc('function sqlite_queryValue(index : integer; sql : string; out data : T2DStringArray) : boolean;', @lp_sqlite_queryvalue);
  AddGlobalFunc('function sqlite_queryValue(index : integer; sql : string; var error : boolean) : T2DStringArray; overload;', @lp_sqlite_queryresult);
  AddGlobalFunc('function sqlite_queryResult(index : integer; sql : string; var error : boolean) : T2DStringArray;', @lp_sqlite_queryresult);
end;
{$ENDIF}

{ Extensions }
//AddGlobalFunc('function ext_UnTar(const Input: string; var Content: TStringArray): boolean', @Lape_ext_UnTar);
//AddGlobalFunc('function ext_UnTarEx(const Input: string; const outputdir: string; overwrite: boolean): boolean', @Lape_ext_UnTarEx);
//AddGlobalFunc('function ext_DecompressBZip2(const input: string; var output: string; const BlockSize: Cardinal): boolean', @Lape_ext_DecompressBZip2);
//AddGlobalFunc('function ext_GetPage(const url: string): string', @Lape_ext_GetPage);
////AddGlobalFunc('function ext_MessageDlg(const aCaption, aMsg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer', @Lape_ext_MessageDlg);
////AddGlobalFunc('function ext_SDTMToMDTM(Const DTM: TSDTM): TMDTM', @Lape_ext_SDTMToMDTM);
//AddGlobalFunc('function ext_InputQuery(const ACaption, APrompt: String; var Value: String): Boolean', @Lape_ext_InputQuery);
//AddGlobalFunc('function ext_ScriptText: string', @Lape_ext_ScriptText);
//AddGlobalFunc('function ext_GetSelectedText: string', @Lape_ext_GetSelectedText);
//AddGlobalFunc('procedure ext_OpenScript(vName, Data: string; Run: boolean);', @Lape_ext_OpenScript);
//AddGlobalFunc('procedure ext_OpenScriptEx(FileName: string; Run: boolean);', @Lape_ext_OpenScriptEx);
//AddGlobalFunc('function ext_GetPageEx(const URL, PostData, MimeType: string): string', @Lape_ext_GetPageEx);
//AddGlobalFunc('function ext_GetJSONValue(const Data, Value: string): string', @Lape_ext_GetJSONValue);
