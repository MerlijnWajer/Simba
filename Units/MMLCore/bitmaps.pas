{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië, Merlijn Wajer and Jarl K. Holta.

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

    Bitmaps class for the Mufasa Macro Library
}

unit bitmaps;

{$mode objfpc}{$H+}
{$inline on}

interface
uses
  Classes, SysUtils, FPImage,IntfGraphics,graphtype,MufasaTypes,MufasaBase,graphics;

type
  TMBitmaps = class;

  TBmpMirrorStyle = (MirrorWidth,MirrorHeight,MirrorLine);
  TBmpThreshMethod = (TM_Mean, TM_MinMax);
  TBmpResizeMethod = (RM_Nearest, RM_Bilinear);

  { TMufasaBitmap }
  PMufasaBitmap = ^TMufasaBitmap;
  TMufasaBitmap = class(TObject)
  private
    FWidth,FHeight : integer;
    FTransparentColor : TRGB32;
    FTransparentSet : boolean;
    FIndex : integer;
    FName : string;
    FList: TMBitmaps;

    { True if we do not own FData }
    FExternData: boolean;
  public
    OnDestroy : procedure(Bitmap : TMufasaBitmap) of object;
    //FakeData : array of TRGB32;
    FData : PRGB32;
    property Name : string read FName write FName;
    property Index : integer read FIndex write FIndex;

    procedure SetSize(AWidth,AHeight : integer);
    procedure StretchResize(AWidth,AHeight : integer);
    procedure ResizeEx(Method: TBmpResizeMethod; NewWidth, NewHeight: integer);

    property Width : Integer read FWidth;
    property Height : Integer read FHeight;

    procedure SetPersistentMemory(mem: PtrUInt; awidth, aheight: integer);
    procedure ResetPersistentMemory;

    function PointInBitmap(x,y : integer) : boolean; inline;
    procedure ValidatePoint(x,y : integer);
    function SaveToFile(FileName : string) :boolean;
    procedure LoadFromFile(const FileName : string);
    procedure Rectangle(const Box : TBox;FillCol : TColor);
    procedure Rectangle(const Box: TBox; const Color: Integer; const Transparency: Extended); overload;
    procedure FloodFill(const StartPT : TPoint; const SearchCol, ReplaceCol : TColor);
    procedure FastSetPixel(x,y : integer; Color : TColor);
    procedure FastSetPixels(Points : TPointArray; Colors : TIntegerArray);
    procedure DrawATPA(ATPA : T2DPointArray; Colors : TIntegerArray);overload;
    procedure DrawATPA(ATPA : T2DPointArray);overload;
    procedure DrawTPA(Points : TPointArray; Color : TColor);
    procedure DrawToCanvas(x,y : integer; Canvas : TCanvas);
    procedure LineTo(Src,Dst: TPoint;Color: TColor);
    function FindColors(var points: TPointArray; const color: integer): boolean;
    function FastGetPixel(x,y : integer) : TColor;
    function FastGetPixels(Points : TPointArray) : TIntegerArray;
    function GetAreaColors(xs,ys,xe,ye : integer) : T2DIntArray;
    function GetColors: TIntegerArray;
    function GetHSLValues(xs, ys, xe, ye: integer): T2DHSLArray;
    procedure FastDrawClear(Color : TColor);
    procedure FastDrawTransparent(x, y: Integer; TargetBitmap: TMufasaBitmap);
    procedure FastReplaceColor(OldColor, NewColor: TColor);
    procedure CopyClientToBitmap(MWindow : TObject;Resize : boolean; xs, ys, xe, ye: Integer);overload;
    procedure CopyClientToBitmap(MWindow : TObject;Resize : boolean;x,y : integer; xs, ys, xe, ye: Integer);overload;
    procedure RotateBitmap(angle: Extended; TargetBitmap: TMufasaBitmap);
    procedure RotateBitmapEx(Angle: Single; Expand: Boolean; Smooth: Boolean; TargetBitmap: TMufasaBitmap);
    procedure Desaturate(TargetBitmap : TMufasaBitmap); overload;
    procedure Desaturate;overload;
    procedure GreyScale(TargetBitmap : TMufasaBitmap);overload;
    procedure GreyScale;
    procedure Brightness(TargetBitmap : TMufasaBitmap; br : integer); overload;
    procedure Brightness(br: integer);overload;
    procedure Contrast(TargetBitmap : TMufasaBitmap; co : Extended);overload;
    procedure Contrast(co: Extended);overload;
    procedure Invert(TargetBitmap : TMufasaBitmap);overload;
    procedure Invert;overload;
    procedure Posterize(TargetBitmap : TMufasaBitmap; Po : integer);overload;
    procedure Posterize(Po : integer);overload;
    procedure Convolute(TargetBitmap : TMufasaBitmap; Matrix : T2DExtendedArray);
    
    function  CompareAt(Other: TMufasaBitmap; Pt: TPoint; Tol: Int32): Extended;
    procedure Downsample(DownScale: Int32; TargetBitmap: TMufasaBitmap);
    function  MatchTemplate(Other: TMufasaBitmap; Formula: ETMFormula): TSingleMatrix;
    function  FindTemplate(Other: TMufasaBitmap; Formula: ETMFormula; MinMatch: Extended): TPoint;
    
    function Copy(const xs,ys,xe,ye : integer) : TMufasaBitmap; overload;
    function Copy: TMufasaBitmap;overload;
    procedure Blur(const Block, xs, ys, xe, ye: integer);
    procedure Blur(const Block: integer); overload;
    procedure Crop(const xs, ys, xe, ye: integer);
    function ToTBitmap: TBitmap;
    function ToString : string; override;
    function ToMatrix: T2DIntegerArray;
    procedure DrawMatrix(const matrix: T2DIntegerArray);
    procedure DrawMatrix(const Matrix: TSingleMatrix; ColorMapID: Int32 = 0); overload;
    procedure ThresholdAdaptive(Alpha, Beta: Byte; InvertIt: Boolean; Method: TBmpThreshMethod; C: Integer);
    function RowPtrs : TPRGB32Array;
    procedure LoadFromTBitmap(bmp: TBitmap);
    procedure LoadFromRawImage(RawImage: TRawImage);
    function CreateTMask : TMask;
    procedure ResizeBilinear(NewW, NewH: Integer);
    procedure DrawText(Text, Font: String; Position: TPoint; Shadow: Boolean;  Color: TColor);
    procedure DrawSystemText(Text: String; Font: TFont; Position: TPoint); overload;
    procedure DrawSystemText(Text, FontName: String; Size: Integer; Position: TPoint; Shadow: Boolean; Color: TColor); overload;
    procedure SetTransparentColor(Col : TColor);
    function GetTransparentColor : TColor;
    property TransparentColorSet : boolean read FTransparentSet;
    property List: TMBitmaps read FList write FList;
    procedure SetAlphaValue(const value : byte);
    constructor Create;
    destructor Destroy;override;
  end;
  TMufasaBmpArray = Array of TMufasaBitmap;
  
  { TMBitmaps }
  TMBitmaps = class(TObject)
  protected
    Client: TObject;
    FreeSpots: Array of integer;
    BmpArray: TMufasaBmpArray;
    BmpsCurr, BmpsHigh, FreeSpotsHigh, FreeSpotsLen: integer;
    function GetNewIndex : integer;
  public
    function GetBMP(Index : integer) : TMufasaBitmap;
    property Bmp[Index : integer]: TMufasaBitmap read GetBMP; default;
    function CreateBMP(w, h: integer): Integer;
    function ExistsBMP(Index : integer) : boolean;
    function AddBMP(_bmp: TMufasaBitmap): Integer;
    function CopyBMP( Bitmap : integer) : Integer;
    function CreateMirroredBitmap(bitmap: Integer; MirrorStyle : TBmpMirrorStyle): Integer;
    function CreateBMPFromFile(const Path : string) : integer;
    function CreateBMPFromString(width,height : integer; Data : string) : integer;overload;
    function CreateBMPFromString(BmpName: string; width, height: integer; Data: string) : integer;overload;
    function RemoveBMP(Number: Integer): TMufasaBitmap;
    constructor Create(Owner: TObject);
    destructor Destroy;override;
  end;

  Procedure ArrDataToRawImage(Ptr: PRGB32; Size: TPoint; out RawImage: TRawImage);
  function CalculatePixelShift(Bmp1,Bmp2 : TMufasaBitmap; CompareBox : TBox) : integer;
  function CalculatePixelShiftTPA(Bmp1, Bmp2: TMufasaBitmap; CPoints: TPointArray): integer;
  function CalculatePixelTolerance(Bmp1,Bmp2 : TMufasaBitmap; CompareBox : TBox; CTS : integer) : extended;
  function CalculatePixelToleranceTPA(Bmp1, Bmp2: TMufasaBitmap; CPoints: TPointArray; CTS: integer): extended;

implementation

uses
  paszlib, DCPbase64, math,
  client, tpa,
  colour_conv, simba.iomanager, mufasatypesutil,
  FileUtil, LazUTF8,
  matchTempl, matrix;


// Needs more fixing. We need to either copy the memory ourself, or somehow
// find a TRawImage feature to skip X bytes after X bytes read. (Most likely a
// feature)
Procedure ArrDataToRawImage(Ptr: PRGB32; Size: TPoint; out RawImage: TRawImage);
Begin
  RawImage.Init; { Calls raw.Description.Init as well }

  RawImage.Description.PaletteColorCount:=0;
  RawImage.Description.MaskBitsPerPixel:=0;
  RawImage.Description.Width := Size.X;
  RawImage.Description.Height:= Size.Y;

  RawImage.Description.Format := ricfRGBA;
  RawImage.Description.ByteOrder := riboLSBFirst;
  RawImage.Description.BitOrder:= riboBitsInOrder; // should be fine
  RawImage.Description.Depth:=24;
  RawImage.Description.BitsPerPixel:=32;
  RawImage.Description.LineOrder:=riloTopToBottom;
  RawImage.Description.LineEnd := rileDWordBoundary;

  RawImage.Description.RedPrec := 8;
  RawImage.Description.GreenPrec:= 8;
  RawImage.Description.BluePrec:= 8;
  RawImage.Description.AlphaPrec:=0;


  RawImage.Description.RedShift:=16;
  RawImage.Description.GreenShift:=8;
  RawImage.Description.BlueShift:=0;

  RawImage.DataSize := RawImage.Description.Width * RawImage.Description.Height
                       * (RawImage.Description.bitsperpixel shr 3);
  RawImage.Data := PByte(Ptr);
End;

function CalculatePixelShift(Bmp1, Bmp2: TMufasaBitmap; CompareBox: TBox): integer;
var
  x,y : integer;
  w1,w2 : integer;
begin
  Bmp1.ValidatePoint(comparebox.x1,comparebox.y1);
  Bmp1.ValidatePoint(comparebox.x2,comparebox.y2);
  Bmp2.ValidatePoint(comparebox.x1,comparebox.y1);
  Bmp2.ValidatePoint(comparebox.x2,comparebox.y2);
  Bmp1.SetAlphaValue(0);
  Bmp2.SetAlphaValue(0);
  w1 := bmp1.Width;
  w2 := bmp2.width;
  result := 0;
  for y := CompareBox.y1 to CompareBox.y2 do
    for x := CompareBox.x1 to CompareBox.x2 do
      if LongWord(Bmp1.FData[y * w1 + x]) <> LongWord(Bmp2.Fdata[y * w2 + x]) then
        inc(result);
end;

function CalculatePixelShiftTPA(Bmp1, Bmp2: TMufasaBitmap; CPoints: TPointArray): integer;
var
  i : integer;
  bounds: TBox;
  w1,w2 : integer;
begin
  bounds := GetTPABounds(CPoints);
  Bmp1.ValidatePoint(bounds.x1,bounds.y1);
  Bmp1.ValidatePoint(bounds.x2,bounds.y2);
  Bmp2.ValidatePoint(bounds.x1,bounds.y1);
  Bmp2.ValidatePoint(bounds.x2,bounds.y2);
  Bmp1.SetAlphaValue(0);
  Bmp2.SetAlphaValue(0);
  w1 := bmp1.width;
  w2 := bmp2.width;
  result := 0;
  for i := 0 to High(CPoints) do
    if LongWord(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x]) <>
        LongWord(Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x]) then
      inc(result);
end;

//CTS 0 counts the average difference in R,G,B per pixel
//CTS 1 counts the average difference using SQRT(Sqr(r) + sqr(g)+sqr(b));
function CalculatePixelTolerance(Bmp1, Bmp2: TMufasaBitmap; CompareBox: TBox;
  CTS: integer): extended;
var
  x,y : integer;
  w1,w2 : integer;
  Diff : int64;
begin
  Bmp1.ValidatePoint(comparebox.x1,comparebox.y1);
  Bmp1.ValidatePoint(comparebox.x2,comparebox.y2);
  Bmp2.ValidatePoint(comparebox.x1,comparebox.y1);
  Bmp2.ValidatePoint(comparebox.x1,comparebox.y1);
  Bmp1.SetAlphaValue(0);
  Bmp2.SetAlphaValue(0);
  w1 := bmp1.Width;
  w2 := bmp2.width;
  result := 0;
  if not InRange(CTS,0,1) then
    raise exception.CreateFmt('CTS Passed to CalculateTolerance must be in [0..1], it currently is %d',[CTS]);
  case CTS of
    0 : begin
          Diff := 0;
          for y := CompareBox.y1 to CompareBox.y2 do
            for x := CompareBox.x1 to CompareBox.x2 do
            begin
              Diff := Diff + abs(Bmp1.FData[y * w1 + x].r-Bmp2.Fdata[y * w2 + x].r) +
                             abs(Bmp1.FData[y * w1 + x].g-Bmp2.Fdata[y * w2 + x].g) +
                             abs(Bmp1.FData[y * w1 + x].b-Bmp2.Fdata[y * w2 + x].b);
            end;
          Result := Diff / (3 * (CompareBox.x2 - CompareBox.x1 + 1) * (CompareBox.y2-CompareBox.y1 + 1)); //We want the value for the whole Pixel; so divide by 3 (RGB)
        end;
    1 : begin
          for y := CompareBox.y1 to CompareBox.y2 do
            for x := CompareBox.x1 to CompareBox.x2 do
              Result := Result + Sqrt(Sqr(Bmp1.FData[y * w1 + x].r-Bmp2.Fdata[y * w2 + x].r) +
                                      Sqr(Bmp1.FData[y * w1 + x].g-Bmp2.Fdata[y * w2 + x].g) +
                                      Sqr(Bmp1.FData[y * w1 + x].b-Bmp2.Fdata[y * w2 + x].b));
          Result := Result / ((CompareBox.x2 - CompareBox.x1 + 1) * (CompareBox.y2-CompareBox.y1 + 1)); //We want the value for the whole Pixel;
        end;
  end;
end;

function CalculatePixelToleranceTPA(Bmp1, Bmp2: TMufasaBitmap; CPoints: TPointArray;
  CTS: integer): extended;
var
  i : integer;
  bounds: TBox;
  w1,w2 : integer;
  Diff : int64;
begin
  bounds := GetTPABounds(CPoints);
  Bmp1.ValidatePoint(bounds.x1,bounds.y1);
  Bmp1.ValidatePoint(bounds.x2,bounds.y2);
  Bmp2.ValidatePoint(bounds.x1,bounds.y1);
  Bmp2.ValidatePoint(bounds.x2,bounds.y2);
  Bmp1.SetAlphaValue(0);
  Bmp2.SetAlphaValue(0);
  w1 := bmp1.Width;
  w2 := bmp2.width;
  result := 0;
  if not InRange(CTS,0,1) then
    raise exception.CreateFmt('CTS Passed to CalculateTolerance must be in [0..1], it currently is %d',[CTS]);
  case CTS of
    0 : begin
          Diff := 0;
          for i := 0 to High(CPoints) do
            begin
              Diff := Diff + abs(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x].r-Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x].r) +
                             abs(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x].g-Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x].g) +
                             abs(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x].b-Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x].b);
            end;
          Result := Diff / (3 * (bounds.x2 - bounds.x1 + 1) * (bounds.y2-bounds.y1 + 1)); //We want the value for the whole Pixel; so divide by 3 (RGB)
        end;
    1 : begin

          for i := 0 to High(CPoints) do
            Result := Result + Sqrt(Sqr(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x].r-Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x].r) +
                                    Sqr(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x].g-Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x].g) +
                                    Sqr(Bmp1.FData[CPoints[i].y * w1 + CPoints[i].x].b-Bmp2.Fdata[CPoints[i].y * w2 + CPoints[i].x].b));
          Result := Result / ((bounds.x2 - bounds.x1 + 1) * (bounds.y2-bounds.y1 + 1)); //We want the value for the whole Pixel;
        end;
  end;
end;

{ TMBitmaps }

function TMBitmaps.GetNewIndex: integer;
begin
  if BmpsCurr < BmpsHigh then
  begin;
    inc(BmpsCurr);
    Result := BmpsCurr;
  end else if (FreeSpotsHigh > -1) then
  begin;
    Result := FreeSpots[FreeSpotsHigh];
    dec(FreeSpotsHigh);
  end else
  begin;
    SetLength(BmpArray, BmpsHigh + 6);
    BmpsHigh := BmpsHigh + 5;
    inc(BmpsCurr);
    Result := BmpsCurr;
  end;
end;

function TMBitmaps.GetBMP(Index: integer): TMufasaBitmap;
begin
  Result := nil;
  if (Index >= 0) and (Index <= BmpsCurr) then
    if BmpArray[Index] <> nil then
      Result := BmpArray[Index];
  if Result = nil then
    raise Exception.CreateFmt('The bitmap[%d] does not exist',[Index]);
end;

function TMBitmaps.CreateBMP(w,h : integer): Integer;
var
  Bitmap: TMufasaBitmap;
begin
  Bitmap := TMufasaBitmap.Create;
  Bitmap.SetSize(w,h);
  Result := addBMP(Bitmap);
end;

function TMBitmaps.AddBMP(_bmp: TMufasaBitmap): Integer;
begin
  Result := GetNewIndex;

  BmpArray[Result] := _bmp;
  BmpArray[Result].Index := Result;
  BmpArray[Result].List := Self;
end;

function TMBitmaps.CopyBMP(Bitmap: integer): Integer;
var
  InputBMP : TMufasaBitmap;
  OutputBMP : TMUfasaBitmap;
begin
  InputBMP := GetBMP(Bitmap);
  Result := CreateBMP(InputBmp.Width,InputBMP.Height);
  OutputBMP := GetBMP(Result);
  Move(InputBMP.FData[0],OutPutBMP.FData[0],InputBMP.Width * InputBMP.Height * SizeOf(TRGB32));
end;

function TMBitmaps.CreateMirroredBitmap(bitmap: Integer;
  MirrorStyle: TBmpMirrorStyle): Integer;
var
  w,h : integer;
  y,x : integer;
  Source,Dest : PRGB32;
begin
  Source := Bmp[Bitmap].FData;
  w := BmpArray[Bitmap].Width;
  h := BmpArray[Bitmap].Height;
  if MirrorStyle = MirrorLine then
    Result := CreateBMP(h,w)
  else
    Result := CreateBMP(w,h);
  Dest := BmpArray[Result].FData;
  case MirrorStyle of
    MirrorWidth :  for y := (h-1) downto 0 do
                     for x := (w-1) downto 0 do
                       Dest[y*w+x] := Source[y*w+w-1-x];
    MirrorHeight : for y := (h-1) downto 0 do
                    Move(Source[y*w],Dest[(h-1 - y) * w],w*SizeOf(TRGB32));
    MirrorLine :  for y := (h-1) downto 0 do
                     for x := (w-1) downto 0 do
                       Dest[x*h+y] := Source[y*w+x];

  end;
//Can be optmized, this is just proof of concept
end;

function TMBitmaps.CreateBMPFromFile(const Path: string): integer;
begin
  Result := CreateBMP(0,0);
  try
    BmpArray[Result].LoadFromFile(Path);
  except
    BmpArray[Result].Free();
    Result := -1; // meh
    raise;
  end;
end;

function HexToInt(HexNum: string): LongInt;inline;
begin
   Result:=StrToInt('$' + HexNum);
end;

function TMBitmaps.ExistsBMP(Index : integer) : boolean;
begin
  result := false;
  if (Index >= 0) and (Index <= BmpsCurr) then
      result := Assigned(BmpArray[Index]);
end;

function TMBitmaps.CreateBMPFromString(width, height: integer; Data: string): integer;
var
  I,II: LongWord;
  DestLen : LongWord;
  Dest,Source : string;
  DestPoint, Point : PByte;
  MufRaw : PRGB24;
  MufDest : PRGB32;


begin
  Result := CreateBMP(width,height);
  if (Data <> '') and (Length(Data) <> 6) then
  begin;
    Point := Pointer(BmpArray[Result].FData);
    if (Data[1] = 'b') or (Data[1] = 'm') then
    begin;
      Source := Base64DecodeStr(Copy(Data,2,Length(Data) - 1));
      Destlen := Width * Height * 3;
      Setlength(Dest,DestLen);
      if uncompress(PChar(Dest),Destlen,pchar(Source), Length(Source)) = Z_OK then
      begin;
        if data[1] = 'm' then //Our encrypted bitmap! Winnor.
        begin
          MufRaw:= @Dest[1];
          MufDest:= PRGB32(Point);
          for i := width * height - 1 downto 0 do
          begin
            MufDest[i].R:= MufRaw[i].R;
            MufDest[i].G := MufRaw[i].G;
            MufDest[i].B := MufRaw[i].B;
          end;
        end else
        if Data[1] = 'b'then
        begin
          DestPoint := @Dest[1];
          i := 0;
          ii := 2;
          Dec(DestLen);
          if DestLen > 2 then
          begin;
            while (ii < DestLen) do
            Begin;
              Point[i]:= DestPoint[ii+2];
              Point[i+1]:= DestPoint[ii+1];
              Point[i+2]:= DestPoint[ii];
              ii := ii + 3;
              i := i + 4;
            end;
            Point[i] := DestPoint[1];
            Point[i+1] := DestPoint[0];
            Point[i+2] := DestPoint[ii];
          end else if (Width = 1) and (Height =1 ) then
          begin;
            Point[0] := DestPoint[1];
            Point[1] := DestPoint[0];
            Point[2] := DestPoint[2];
          end;
        end;
      end;
    end else if Data[1] = 'z' then
    begin;
      Destlen := Width * Height * 3 *2;
      Setlength(Dest,DestLen);
      ii := (Length(Data) - 1) div 2;
      SetLength(Source,ii);
      for i := 1 to ii do
        Source[i] := Chr(HexToInt(Data[i * 2] + Data[i * 2+1]));
      if uncompress(PChar(Dest),Destlen,pchar(Source), ii) = Z_OK then
      begin;
        ii := 1;
        i := 0;
        while (II < DestLen) do
        begin;
          Point[i+2]:= HexToInt(Dest[ii] + Dest[ii + 1]);
          Point[i+1]:= HexToInt(Dest[ii+2] + Dest[ii + 3]);
          Point[i]:= HexToInt(Dest[ii+4] + Dest[ii + 5]);
          ii := ii + 6;
          i := i + 4;
        end;
      end;
    end else if LongWord(Length(Data)) = LongWord((Width * Height * 3 * 2)) then
    begin;
      ii := 1;
      i := 0;
      Destlen := Width * Height * 3 * 2;
      while (II < DestLen) do
      begin;
        Point[i+2]:= HexToInt(Data[ii] + Data[ii + 1]);
        Point[i+1]:= HexToInt(Data[ii+2] + Data[ii + 3]);
        Point[i]:= HexToInt(Data[ii+4] + Data[ii + 5]);
        ii := ii + 6;
        i := i + 4;
      end;
    end;
  end else
  begin;
    if Length(data) = 6 then
      BmpArray[Result].FastDrawClear(HexToInt(Data));
//    else
//      FastDrawClear(Result,clBlack);
  end;
end;

function TMBitmaps.CreateBMPFromString(BmpName: string; width, height: integer;
  Data: string): integer;
begin
  Result := Self.CreateBMPFromString(width,height,data);
  Bmp[Result].Name:= BmpName;
end;

function TMBitmaps.RemoveBMP(Number: Integer): TMufasaBitmap;
begin
  Result := GetBMP(Number);
  if (Number < BmpsCurr) then
  begin
    Inc(FreeSpotsHigh);
    if (FreeSpotsHigh = FreeSpotsLen) then
    begin
      Inc(FreeSpotsLen);
      SetLength(FreeSpots, FreeSpotsLen);
    end;

    FreeSpots[FreeSpotsHigh] := Number;
  end else
    Dec(BmpsCurr);

  BMPArray[Number] := nil;
  Result.Index := -1;
  Result.List := nil;
end;

function TMufasaBitmap.SaveToFile(FileName: string): boolean;
var
  RawImage: TRawImage;
  Image: TLazIntfImage;
begin
  if ExtractFileExt(FileName) = '' then
    FileName := FileName + '.bmp';

  ArrDataToRawImage(FData, Point(Self.FWidth, Self.FHeight), RawImage);

  Image := TLazIntfImage.Create(RawImage, False);

  try
    if not Image.SaveToFile(FileName) then
      raise Exception.CreateFmt('TMufasaBitmap.SaveToFile: Image format "%s" is not supported', [ExtractFileExt(FileName)]);
  finally
    Image.Free();
  end;
end;

procedure TMufasaBitmap.LoadFromFile(const FileName: string);
var
  LazIntf : TLazIntfImage;
  RawImageDesc : TRawImageDescription;
begin
  try
    LazIntf := TLazIntfImage.Create(0,0);
    RawImageDesc.Init_BPP32_B8G8R8_BIO_TTB(LazIntf.Width,LazIntf.Height);
    LazIntf.DataDescription := RawImageDesc;
    LazIntf.LoadFromFile(UTF8ToSys(FileName));
    if Assigned(FData) then
      Freemem(FData);
    Self.FWidth := LazIntf.Width;
    Self.FHeight := LazIntf.Height;
    FData := GetMem(Self.FWidth*Self.FHeight*SizeOf(TRGB32));
    Move(LazIntf.PixelData[0],FData[0],FWidth*FHeight*sizeOf(TRGB32));
  finally
    LazIntf.Free;
  end;
end;

function RGBToBGR(Color : TColor) : TRGB32; inline;
begin;
  Result.R := Color and $ff;
  Result.G := Color shr 8 and $ff;
  Result.B := Color shr 16 and $ff;
  Result.A := 0;
end;

procedure TMufasaBitmap.Rectangle(const Box: TBox;FillCol: TColor);
var
  y : integer;
  Col : Longword;
  Size : longword;
begin
  if (Box.x1 < 0) or (Box.y1 < 0) or (Box.x2 >= self.FWidth) or (Box.y2 >= self.FHeight) then
    raise exception.Create('The Box you passed to Rectangle exceed the bitmap''s bounds');
  if (box.x1 > box.x2) or (Box.y1 > box.y2) then
    raise exception.CreateFmt('The Box you passed to Rectangle doesn''t have normal bounds: (%d,%d) : (%d,%d)',
                               [Box.x1,box.y1,box.x2,box.y2]);
  col :=  Longword(RGBToBGR(FillCol));
  Size := Box.x2 - box.x1 + 1;
  for y := Box.y1 to Box.y2 do
    FillDWord(FData[y * self.FWidth + Box.x1],size,Col);
end;

procedure TMufasaBitmap.FloodFill(const StartPT: TPoint; const SearchCol,
  ReplaceCol: TColor);
var
  Stack : TPointArray;
  SIndex : Integer;
  CurrX,CurrY : integer;
  Search,Replace : LongWord;
procedure AddToStack(x,y : integer);inline;
begin
  if LongWord(FData[y * FWidth + x]) = Search then
  begin
    LongWord(FData[y * FWidth + x]) := Replace;
    Stack[SIndex].x := x;
    Stack[SIndex].y := y;
    inc(SIndex);
  end;
end;
begin
  ValidatePoint(StartPT.x,StartPT.y);
  Search := LongWord(RGBToBGR(SearchCol));
  Replace := LongWord(RGBToBGR(ReplaceCol));
  SetAlphaValue(0);
  if LongWord(FData[StartPT.y * FWidth + StartPT.x]) <> Search then //Only add items to the stack that are the searchcol.
    Exit;
  SetLength(Stack,FWidth * FHeight);
  SIndex := 0;
  AddToStack(StartPT.x,StartPT.y);
  SIndex := 0;
  while (SIndex >= 0) do
  begin;
    CurrX := Stack[SIndex].x;
    Curry := Stack[SIndex].y;
    if (CurrX > 0) and (CurrY > 0)         then AddToStack(CurrX - 1, CurrY - 1);
    if (CurrX > 0)                         then AddToStack(CurrX - 1, CurrY);
    if (CurrX > 0) and (CurrY + 1 < FHeight)     then AddToStack(CurrX - 1, CurrY + 1);
    if (CurrY + 1 < FHeight)                     then AddToStack(CurrX   ,  CurrY + 1);
    if (CurrX + 1 < FWidth) and (CurrY + 1 < FHeight) then AddToStack(CurrX + 1, CurrY + 1);
    if (CurrX + 1 < FWidth)                     then AddToStack(CurrX + 1, CurrY    );
    if (CurrX + 1 < FWidth) and (CurrY > 0)     then AddToStack(CurrX + 1, CurrY - 1);
    if (CurrY > 0)                         then AddToStack(CurrX    , CurrY - 1);
    Dec(SIndex);
  end;
end;

function TMufasaBitmap.Copy: TMufasaBitmap;
begin
  Result := TMufasaBitmap.Create;
  Result.SetSize(self.Width, self.Height);
  Move(self.FData[0], Result.FData[0],self.FWidth * self.FHeight * SizeOf(TRGB32));
end;

function TMufasaBitmap.Copy(const xs, ys, xe, ye: integer): TMufasaBitmap;
var
  i : integer;
begin
  ValidatePoint(xs,ys);
  ValidatePoint(xe,ye);
  Result := TMufasaBitmap.Create;
  Result.SetSize(xe-xs+1, ye-ys+1);
  for i := ys to ye do
    Move(self.FData[i * self.FWidth + xs], Result.FData[(i-ys) * result.FWidth],result.Width * SizeOf(TRGB32));
end;

procedure TMufasaBitmap.Crop(const xs, ys, xe, ye: integer);
var
  i: integer;
begin
  if (not Self.PointInBitmap(xs, ys)) or (not Self.PointInBitmap(xe, ye)) then
     raise exception.Create('TMufasaBitmap.Crop(): The bounds you pased to crop exceed the bitmap bounds');

  if (xs > xe) or (ys > ye) then
    raise exception.CreateFmt('TMufasaBitmap.Crop(): the bounds you passed doesn''t have normal bounds (%d,%d) : (%d,%d)', [xs, ys, xe, ye]);

  for i := ys to ye do
    Move(self.FData[i * self.width + xs], self.FData[(i-ys) * self.width], self.width * SizeOf(TRGB32));

  self.SetSize(xe-xs+1, ye-ys+1);
end;

function TMufasaBitmap.ToTBitmap: TBitmap;

var
  tr:TRawImage;

begin
  Result := TBitmap.Create;
  ArrDataToRawImage(Self.Fdata, point(self.width,self.height), tr);
  Result.LoadFromRawImage(tr, false);
end;

function TMufasaBitmap.ToString: string;
var
  i : integer;
  DestLen : longword;
  DataStr : string;
  CorrectData : PRGB24;
begin
  SetLength(DataStr,FWidth*FHeight*3);
  CorrectData:= PRGB24(@DataStr[1]);
  for i := FWidth*FHeight - 1 downto 0 do
  begin
    CorrectData[i].R := FData[i].R;
    CorrectData[i].G := FData[i].G;
    CorrectData[i].B := FData[i].B;
  end;
  DestLen := BufferLen;
  if compress(BufferString,destlen,PChar(DataStr),FWidth*FHeight*3) = Z_OK then
  begin;
    SetLength(DataStr,DestLen);
    move(bufferstring[0],dataStr[1],DestLen);
    result := 'm' + Base64EncodeStr(datastr);
    SetLength(datastr,0);
  end;
end;

function TMufasaBitmap.ToMatrix: T2DIntegerArray;
var
  wid, hei, x, y: integer;
begin
  SetLength(result, self.height, self.width);

  wid := (self.width -1);
  hei := (self.height -1);

  for y := 0 to hei do
    for x := 0 to wid do
      result[y][x] := BGRToRGB(self.FData[y * FWidth + x]);
end;

procedure TMufasaBitmap.DrawMatrix(const matrix: T2DIntegerArray);
var
  x, y, wid, hei: integer;
begin
  if (length(matrix) = 0) then
    raise exception.Create('Matrix with length 0 has been passed to TMufasaBitmap.DrawMatrix');

  self.SetSize(length(matrix[0]), length(matrix));

  wid := (self.width -1);
  hei := (self.height -1);

  for y := 0 to hei do
    for x := 0 to wid do
      self.FData[y * FWidth + x] := RGBToBGR(matrix[y][x]);
end;

procedure TMufasaBitmap.DrawMatrix(const Matrix: TSingleMatrix; ColorMapID: Int32 = 0); overload;
var
  x,y, wid,hei, color: Int32;
  _H,_S,_L: Extended;
  tmp: TSingleMatrix;
begin
  if (Length(matrix) = 0) then
    Raise Exception.Create('Matrix with length 0 has been passed to TMufasaBitmap.DrawMatrix');
  
  Self.SetSize(Length(matrix[0]), Length(matrix));

  wid := self.Width - 1;
  hei := self.Height - 1;
  tmp := MatrixNormMinMax(Matrix, 0,1);

  for y:=0 to hei do
    for x:=0 to wid do
    begin
      case ColorMapID of
        0:begin //cold blue to red
            _H := (1 - tmp[y,x]) * 67;
            _S := 40 + tmp[y,x] * 60;
            color := HSLToColor(_H,_S,50);
          end;
        1:begin //black -> blue -> red
            _H := (1 - tmp[y,x]) * 67;
            _L := tmp[y,x] * 50;
            color := HSLToColor(_H,100,_L);
          end;
        2:begin //white -> blue -> red
            _H := (1 - tmp[y,x]) * 67;
            _L := 100 - tmp[y,x] * 50;
            color := HSLToColor(_H,100,_L);
          end;
        3:begin //Light (to white)
            _L := (1 - tmp[y,x]) * 100;
            color := HSLToColor(0,0,_L);
          end;
        4:begin //Light (to black)
            _L := tmp[y,x] * 100;
            color := HSLToColor(0,0,_L);
          end;
        else
          begin //Custom black to hue to white
            _L := tmp[y,x] * 100;
            color := HSLToColor(ColorMapID/3.6,100,_L);
          end;
      end;
      Self.FastSetPixel(x,y,color);
    end;       
end;


function TMufasaBitmap.RowPtrs: TPRGB32Array;
var
  I : integer;
begin;
  setlength(result,FHeight);
  for i := 0 to FHeight - 1 do
    result[i] := FData + FWidth * i;
end;

procedure TMufasaBitmap.LoadFromRawImage(RawImage: TRawImage);

var
  x,y: integer;
  _24_old_p: PByte;
  rs,gs,bs:byte;
  data: PRGB32;


begin
  // clear data
  Self.SetSize(0,0);

  if (RawImage.Description.BitsPerPixel <> 24) and (RawImage.Description.BitsPerPixel <> 32) then
    raise Exception.CreateFMT('TMufasaBitmap.LoadFromRawImage - BitsPerPixel is %d', [RawImage.Description.BitsPerPixel]);

  {writeln('Bits per pixel: ' + Inttostr(RawImage.Description.BitsPerPixel));   }
  if RawImage.Description.LineOrder <> riloTopToBottom then
    raise Exception.Create('TMufasaBitmap.LoadFromRawImage - LineOrder is not riloTopToBottom');

 { writeln(format('LineOrder: theirs: %d, ours: %d', [RawImage.Description.LineOrder, riloTopToBottom]));  }


 // Todo, add support for other alignments.
 { if RawImage.Description.LineEnd <> rileDWordBoundary then
    raise Exception.Create('TMufasaBitmap.LoadFromRawImage - LineEnd is not rileDWordBoundary');         }

  //writeln(format('LineEnd: t', [RawImage.Description.LineEnd]));

  if RawImage.Description.Format<>ricfRGBA then
    raise Exception.Create('TMufasaBitmap.LoadFromRawImage - Format is not ricfRGBA');

  // Set w,h and alloc mem.
  Self.SetSize(RawImage.Description.Width, RawImage.Description.Height);

  {writeln(format('Image size: %d, %d', [FWidth,FHeight]));  }
  rs := RawImage.Description.RedShift shr 3;
  gs := RawImage.Description.GreenShift shr 3;
  bs := RawImage.Description.BlueShift shr 3;
 { writeln(format('Shifts(R,G,B): %d, %d, %d', [rs,gs,bs]));
  writeln(format('Bits per line %d, expected: %d',
  [RawImage.Description.BitsPerLine, RawImage.Description.BitsPerPixel * self.FWidth]));
  }


  if RawImage.Description.BitsPerPixel = 32 then
    Move(RawImage.Data[0], Self.FData[0],  self.FWidth * self.FHeight * SizeOf(TRGB32))
  else
  begin
    //FillChar(Self.FData[0], self.FWidth * self.FHeight * SizeOf(TRGB32), 0);
    data := self.FData;

    _24_old_p := RawImage.Data;
    for y := 0 to self.FHeight -1 do
    begin
      for x := 0 to self.FWidth -1 do
      begin
        // b is the first byte in the record.
        data^.b := _24_old_p[bs];
        data^.g := _24_old_p[gs];
        data^.r := _24_old_p[rs];
        data^.a := 0;

        inc(_24_old_p, 3);
        inc(data);
      end;

      case RawImage.Description.LineEnd of
        rileTight, rileByteBoundary: ; // do nothing
        rileWordBoundary:
          while (_24_old_p - RawImage.Data) mod 2 <> 0 do
            inc(_24_old_p);
        rileDWordBoundary:
          while (_24_old_p - RawImage.Data) mod 4 <> 0 do
            inc(_24_old_p);
        rileQWordBoundary:
          while (_24_old_p - RawImage.Data) mod 4 <> 0 do
            inc(_24_old_p);
        rileDQWordBoundary:
          while (_24_old_p - RawImage.Data) mod 8 <> 0 do
            inc(_24_old_p);
        end;
    end;
  end;
end;

procedure TMufasaBitmap.LoadFromTBitmap(bmp: TBitmap);

begin
//  bmp.BeginUpdate();
  LoadFromRawImage(bmp.RawImage);
//  bmp.EndUpdate();
end;

procedure TMufasaBitmap.FastSetPixel(x, y: integer; Color: TColor);
var
  TPA: array[0..0] of TPoint;
begin
  TPA[0].X := X;
  TPA[0].Y := Y;

  DrawTPA(TPA, Color);
end;

procedure TMufasaBitmap.FastSetPixels(Points: TPointArray; Colors: TIntegerArray);
var
  ATPA: T2DPointArray;
  i: Int32;
begin
  SetLength(ATPA, Length(Points), 1);
  for i := 0 to High(ATPA) do
    ATPA[i][0] := Points[i];

  DrawATPA(ATPA, Colors);
end;

procedure TMufasaBitmap.DrawATPA(ATPA: T2DPointArray; Colors: TIntegerArray);
var
  i: Int32;
begin
  if (Length(Colors) = 0) or (Length(ATPA) = 0) then
    Exit;

  for i := 0 to High(ATPA) do
    DrawTPA(ATPA[i], Colors[Min(i, High(Colors))]);
end;

procedure TMufasaBitmap.DrawATPA(ATPA: T2DPointArray);
var
  i: Int32;
begin
  if Length(ATPA) = 0 then
    Exit;

  for i := 0 to High(ATPA) do
    DrawTPA(ATPA[i], Random($FFFFFF));
end;

procedure TMufasaBitmap.DrawTPA(Points: TPointArray; Color: TColor);
var
  Ptr: PPoint;
  Upper: PtrUInt;
  BGR: TRGB32;
begin
  if Length(Points) = 0 then
    Exit;

  BGR := RGBToBGR(Color);

  Ptr := @Points[0];
  Upper := PtrUInt(@Points[High(Points)]);

  while (PtrUInt(Ptr) <= Upper) do
  begin
    if (Ptr^.X >= 0) and (Ptr^.Y >= 0) and (Ptr^.X < Self.FWidth) and (Ptr^.Y < Self.FHeight) then
      FData[Ptr^.Y * Self.FWidth + Ptr^.X] := BGR;

    Inc(Ptr);
  end;
end;

procedure TMufasaBitmap.DrawToCanvas(x,y : integer; Canvas: TCanvas);
var
  Bitmap : Graphics.TBitmap;
begin
  Bitmap := Self.ToTBitmap;
  Canvas.Draw(x,y,Bitmap);
  Bitmap.free;
end;

procedure TMufasaBitmap.LineTo(Src, Dst: TPoint;Color: TColor);
var
  TPA: TPointArray;
begin
  TPA:=TPAFromLine(src.x,src.y,dst.x,dst.y);
 // if (not Assigned(TPA)) or (Length(TPA)< 2) then exit;
  Self.DrawTPA(TPA,Color);
end;

//TODO - Best method would be using a mask to ignore the alpha, ie. (FDdata[c] and $FFFFFF00).
function TMufasaBitmap.FindColors(var points: TPointArray; const color: integer
  ): boolean;
var
  x, y, i, c,  wid, hei: integer;
  SearchColor: TRGB32;
begin
  SearchColor := RGBToBGR(color);

  wid := Self.Width;
  hei := Self.Height;

  SetLength(points, wid*hei);

  dec(wid);
  dec(hei);

  i := 0;
  for y := 0 to hei do
    for x := 0 to wid do
    begin
       c := (y * FWidth + x);
       SearchColor.a := Self.FData[c].a;

       if (LongWord(Self.FData[c]) = LongWord(SearchColor)) then
       begin
         Points[i].x := x;
         Points[i].y := y;
         inc(i);
       end;
    end;

  SetLength(Points, i);
  Result := (Length(Points) > 0);
end;

function TMufasaBitmap.FastGetPixel(x, y: integer): TColor;
begin
  ValidatePoint(x,y);
  Result := BGRToRGB(FData[y*FWidth+x]);
end;

function TMufasaBitmap.FastGetPixels(Points: TPointArray): TIntegerArray;
var
  i,len : integer;
  Box  : TBox;
begin
  len := high(Points);
  Box := GetTPABounds(Points);
  if (Box.x1 < 0) or (Box.y1 < 0) or (Box.x2 >= self.FWidth) or (Box.y2 >= self.FHeight) then
    raise exception.Create('The Points you passed to FastGetPixels exceed the bitmap''s bounds');
  SetLength(result,len+1);
  for i := 0 to len do
    Result[i] := BGRToRGB(FData[Points[i].y*FWidth + Points[i].x]);
end;

function TMufasaBitmap.GetAreaColors(xs, ys, xe, ye : integer): T2DIntArray;
var
  x,y : integer;
begin
  ValidatePoint(xs,ys);
  ValidatePoint(xe,ye);
  setlength(result,xe-xs+1,ye-ys+1);
  for x := xs to xe do
    for y := ys to ye do
      result[x-xs][y-ys] := BGRToRGB(FData[y*FWidth+x]);
end;

function TMufasaBitmap.GetHSLValues(xs, ys, xe, ye: integer): T2DHSLArray;
var
  x, y: integer;
begin
  ValidatePoint(xs,ys);
  ValidatePoint(xe,ye);
  setlength(result,ye-ys+1,xe-xs+1);
  for y := ys to ye do
    for x := xs to xe do
    begin                                                   { REWRITE THIS }
      RGBToHSL(FData[y*FWidth+x].R, FData[y*FWidth+x].G, FData[y*FWidth+x].B,
               Result[y-ys][x-xs].H, Result[y-ys][x-xs].S,
               Result[y-ys][x-xs].L);
    end;
end;

function TMufasaBitmap.GetColors: TIntegerArray;
var
  size, i: integer;
begin
  size := (self.height * self.width);
  SetLength(result, size);
  dec(size);

  for i := 0 to size do
    result[i] := BGRToRGB(self.FData[i]);
end;

procedure TMufasaBitmap.SetTransparentColor(Col: TColor);
begin
  self.FTransparentSet:= True;
  self.FTransparentColor:= RGBToBGR(Col);
end;

function TMufasaBitmap.GetTransparentColor: TColor;
begin
  if FTransparentSet then
    Result := BGRToRGB(FTransparentColor)
  else
    raise Exception.CreateFmt('Transparent color for Bitmap[%d] isn''t set',[index]);
end;

procedure TMufasaBitmap.SetAlphaValue(const value: byte);
var
  i : integer;
begin
  for i := FWidth * FHeight - 1 downto 0 do
    FData[i].A:= Value;
end;
procedure TMufasaBitmap.FastDrawClear(Color: TColor);
var
  i : integer;
  Rec : TRGB32;
begin
  Rec := RGBToBGR(Color);
  if FHeight > 0 then
  begin;
    for i := (FWidth-1) downto 0 do
      FData[i] := Rec;
    for i := (FHeight-1) downto 1 do
      Move(FData[0],FData[i*FWidth],FWidth*SizeOf(TRGB32));
  end;
end;

procedure TMufasaBitmap.FastDrawTransparent(x, y: Integer;
  TargetBitmap: TMufasaBitmap);
var
  MinW,MinH,TargetW,TargetH : Integer;
  loopx,loopy : integer;
begin
  TargetBitmap.ValidatePoint(x,y);
  TargetW := TargetBitmap.Width;
  TargetH := TargetBitmap.height;
  MinW := Min(FWidth-1,TargetW-x-1);
  MinH := Min(FHeight-1,TargetH-y-1);
  if FTransparentSet then
  begin;
    for loopy := 0 to MinH do
      for loopx := 0 to MinW do
      begin;
        FData[loopy * FWidth + loopx].A := 0;
        if LongWord(FData[loopy * FWidth + loopx]) <> LongWord(FTransparentColor) then
          TargetBitmap.FData[(loopy + y) * TargetW + loopx + x] := FData[Loopy * FWidth + loopx];
      end;
  end
  else
    for loopy := 0 to MinH do
      Move(FData[loopy*FWidth],TargetBitmap.FData[(loopy+y) * TargetW + x],(MinW+1) * SizeOf(TRGB32));

end;

procedure TMufasaBitmap.FastReplaceColor(OldColor, NewColor: TColor);
var
  OldCol,NewCol : TRGB32;
  i : integer;
begin
  OldCol := RGBToBGR(OldColor);
  NewCol := RGBToBGR(NewColor);
  for i := FWidth*FHeight-1 downto 0 do
  begin
    FData[i].a := 0;
    if LongWord(FData[i]) = LongWord(OldCol) then
      FData[i] := NewCol;
  end;
end;

procedure TMufasaBitmap.CopyClientToBitmap(MWindow : TObject;Resize : boolean; xs, ys, xe, ye: Integer);
var
  y: integer;
  wi,hi: integer;
  Data: TRetData;
  TargetWidth, TargetHeight: Int32;
begin
  if Resize then
    Self.SetSize(xe-xs+1,ye-ys+1);

  wi := Min(xe-xs + 1,Self.FWidth);
  hi := Min(ye-ys + 1,Self.FHeight);

  TIOManager(MWindow).GetDimensions(TargetWidth, TargetHeight);
  if (xs + wi > TargetWidth) or (ys + hi > TargetHeight) then
  begin
    if (FList <> nil) and (FList.Client <> nil) then
      TClient(FList.Client).WriteLn('Warning! The area passed to `CopyClientToBitmap` exceeds the clients bounds');

    xe := Min(xe, TargetWidth - 1);
    ye := Min(ye, TargetHeight - 1);
  end;

  Data := TIOManager(MWindow).ReturnData(xs,ys,wi,hi);

  if (Data = NullReturnData) then
  begin
    if (FList <> nil) and (FList.Client <> nil) then
      TClient(FList.Client).WriteLn('Warning! ReturnData returned null');
  end else
  begin
    for y := 0 to (hi-1) do
      Move(Data.Ptr[y * Data.RowLen], FData[y * self.FWidth],wi * SizeOf(TRGB32));
    
    TIOManager(MWindow).FreeReturnData();
  end;
end;

procedure TMufasaBitmap.CopyClientToBitmap(MWindow: TObject; Resize: boolean; x, y: integer; xs, ys, xe, ye: Integer);
var
  yy : integer;
  wi,hi : integer;
  Data: TRetData;
  TargetWidth, TargetHeight: Int32;
begin
  if Resize then
    Self.SetSize(xe-xs+1 + x,ye-ys+1 + y);

  ValidatePoint(x,y);
  wi := Min(xe-xs + 1 + x,Self.FWidth)-x;
  hi := Min(ye-ys + 1 + y,Self.FHeight)-y;

  TIOManager(MWindow).GetDimensions(TargetWidth, TargetHeight);
  if (xs + wi > TargetWidth) or (ys + hi > TargetHeight) then
  begin
    if (FList <> nil) and (FList.Client <> nil) then
      TClient(FList.Client).WriteLn('Warning! The area passed to `CopyClientToBitmap` exceeds the clients bounds');

    xe := Min(xe, TargetWidth - 1);
    ye := Min(ye, TargetHeight - 1);
  end;

  Data := TIOManager(MWindow).ReturnData(xs,ys,wi,hi);

  if (Data = NullReturnData) then
  begin
    if (FList <> nil) and (FList.Client <> nil) then
      TClient(FList.Client).WriteLn('Warning! ReturnData returned null');
  end else
  begin
    for yy := 0 to (hi-1) do
      Move(Data.Ptr[yy * (Data.RowLen)], FData[(yy + y) * self.FWidth + x], wi * SizeOf(TRGB32));

    TIOManager(MWindow).FreeReturnData();
  end;
end;


function RotatePointEdited(p: TPoint; angle, mx, my: Extended): TPoint;

begin
  Result.X := Ceil(mx + cos(angle) * (p.x - mx) - sin(angle) * (p.y - my));
  Result.Y := Ceil(my + sin(angle) * (p.x - mx) + cos(angle) * (p.y- my));
end;

//Scar rotates unit circle-wise.. Oh, scar doesnt update the bounds, so kinda crops ur image.
procedure TMufasaBitmap.RotateBitmap(angle: Extended;TargetBitmap : TMufasaBitmap);
var
  NewW,NewH : integer;
  CosAngle,SinAngle : extended;
  MinX,MinY,MaxX,MaxY : integer;
  i : integer;
  x,y : integer;
  OldX,OldY : integer;
  MiddlePoint : TPoint;
  NewCorners : array[1..4] of TPoint; //(xs,ye);(xe,ye);(xe,ys);(xs,ys)
begin
  MiddlePoint := Point((FWidth-1) div 2,(FHeight-1) div 2);
  CosAngle := Cos(Angle);
  SinAngle := Sin(Angle);
  MinX := MaxInt;
  MinY := MaxInt;
  MaxX := 0;
  MaxY := 0;
  NewCorners[1]:= RotatePointEdited(Point(0,FHeight-1),angle,middlepoint.x,middlepoint.y);
  NewCorners[2]:= RotatePointEdited(Point(FWidth-1,FHeight-1),angle,middlepoint.x,middlepoint.y);
  NewCorners[3]:= RotatePointEdited(Point(FWidth-1,0),angle,middlepoint.x,middlepoint.y);
  NewCorners[4]:= RotatePointEdited(Point(0,0),angle,middlepoint.x,middlepoint.y);
  for i := 1 to 4 do
  begin;
    if NewCorners[i].x > MaxX then
      MaxX := NewCorners[i].x;
    if NewCorners[i].Y > MaxY then
      MaxY := NewCorners[i].y;
    if NewCorners[i].x < MinX then
      MinX := NewCorners[i].x;
    if NewCorners[i].y < MinY then
      MinY := NewCorners[i].y;
  end;
  //mDebugLn(Format('Min: (%d,%d) Max : (%d,%d)',[MinX,MinY,MaxX,MaxY]));
  NewW := MaxX - MinX+1;
  NewH := MaxY - MinY+1;
 // mDebugLn(format('New bounds: %d,%d',[NewW,NewH]));
  TargetBitmap.SetSize(NewW,NewH);
  for y := NewH - 1 downto 0 do
    for x := NewW - 1 downto 0 do
    begin;
      Oldx := Round(MiddlePoint.x + CosAngle * (x + MinX-MiddlePoint.x) - SinAngle * (y + MinY - MiddlePoint.y));
      Oldy := Round(MiddlePoint.y + SinAngle * (x + MinX-MiddlePoint.x) + CosAngle * (y + MinY-MiddlePoint.y));
      if not ((Oldx <0) or (Oldx >= FWidth) or (Oldy < 0) or (Oldy >= FHeight)) then
        TargetBitmap.FData[ y * NewW + x] := Self.FData[OldY * FWidth + OldX];
    end;
end;

procedure __RotateNoExpand(Bitmap: TMufasaBitmap; Angle: Extended; TargetBitmap: TMufasaBitmap);
var
  x,y,mx,my,i,j,wid,hei: Int32;
  cosa,sina: Single;
begin
  TargetBitmap.SetSize(Bitmap.Width, Bitmap.Height);

  mx := (Bitmap.Width div 2);
  my := (Bitmap.Height div 2);
  cosa := cos(angle);
  sina := sin(angle);
  wid := (Bitmap.Width - 1);
  hei := (Bitmap.Height - 1);

  for i:=0 to hei do
    for j:=0 to wid do
    begin
      x := Round(mx + cosa * (j - mx) - sina * (i - my));
      y := Round(my + sina * (j - mx) + cosa * (i - my));
      if (x >= 0) and (x < wid) and (y >= 0) and (y < hei) then
        TargetBitmap.FData[i * Bitmap.Width + j] := Bitmap.FData[y * Bitmap.Width + x];
      end;
end;

procedure __RotateBINoExpand(Bitmap: TMufasaBitmap; Angle: Single; TargetBitmap: TMufasaBitmap);
var
  i,j,k,RR,GG,BB,mx,my,fX,fY,cX,cY,wid,hei: Int32;
  rX,rY,dX,dY,cosa,sina:Single;
  p0,p1,p2,p3: TRGB32;
  topR,topG,topB,BtmR,btmG,btmB:Single;
begin
  TargetBitmap.SetSize(Bitmap.Width, Bitmap.Height);

  cosa := Cos(Angle);
  sina := Sin(Angle);
  mX := Bitmap.Width div 2;
  mY := Bitmap.Height div 2;
  wid := (Bitmap.Width - 1);
  hei := (Bitmap.Height - 1);

  for i := 0 to hei do begin
    for j := 0 to wid do begin
      rx := (mx + cosa * (j - mx) - sina * (i - my));
      ry := (my + sina * (j - mx) + cosa * (i - my));

      fX := Trunc(rX);
      fY := Trunc(rY);
      cX := Ceil(rX);
      cY := Ceil(rY);

      if not((fX < 0) or (cX < 0) or (fX > wid) or (cX > wid) or
             (fY < 0) or (cY < 0) or (fY > hei) or (cY > hei)) then
      begin
        dx := rX - fX;
        dy := rY - fY;

        p0 := Bitmap.FData[fY * Bitmap.Width + fX];
        p1 := Bitmap.FData[fY * Bitmap.Width + cX];
        p2 := Bitmap.FData[cY * Bitmap.Width + fX];
        p3 := Bitmap.FData[cY * Bitmap.Width + cX];

        TopR := (1 - dx) * p0.R + dx * p1.R;
        TopG := (1 - dx) * p0.G + dx * p1.G;
        TopB := (1 - dx) * p0.B + dx * p1.B;
        BtmR := (1 - dx) * p2.R + dx * p3.R;
        BtmG := (1 - dx) * p2.G + dx * p3.G;
        BtmB := (1 - dx) * p2.B + dx * p3.B;

        RR := Round((1 - dy) * TopR + dy * BtmR);
        GG := Round((1 - dy) * TopG + dy * BtmG);
        BB := Round((1 - dy) * TopB + dy * BtmB);

        if (RR < 0) then RR := 0
        else if (RR > 255)then RR := 255;
        if (GG < 0) then GG := 0
        else if (GG > 255)then GG := 255;
        if (BB < 0) then BB := 0
        else if (BB > 255)then BB := 255;

        k := i * Bitmap.Width + j;
        TargetBitmap.FData[k].r := RR;
        TargetBitmap.FData[k].g := GG;
        TargetBitmap.FData[k].b := BB;
      end;
    end;
  end;
end;

procedure __RotateBIExpand(Bitmap: TMufasaBitmap; Angle: Single; TargetBitmap: TMufasaBitmap);

  function __GetNewSizeRotated(W,H:Int32; Angle:Single): TBox;
    function Rotate(p:TPoint; angle:Single; mx,my:Int32): TPoint;
    begin
      Result.X := Round(mx + cos(angle) * (p.x - mx) - sin(angle) * (p.y - my));
      Result.Y := Round(my + sin(angle) * (p.x - mx) + cos(angle) * (p.y - my));
    end;
  var B: TPointArray;
  begin
    SetLength(B, 4);
    FillChar(Result, SizeOf(TBox), 0);
    Result.X1 := $FFFFFF;
    Result.Y1 := $FFFFFF;
    B[0]:= Rotate(Point(0,h),angle, W div 2, H div 2);
    B[1]:= Rotate(Point(w,h),angle, W div 2, H div 2);
    B[2]:= Rotate(Point(w,0),angle, W div 2, H div 2);
    B[3]:= Rotate(Point(0,0),angle, W div 2, H div 2);
    Result := GetTPABounds(B);
  end;

var
  i,j,RR,GG,BB,mx,my,nW,nH,fX,fY,cX,cY,wid,hei,k: Int32;
  rX,rY,dX,dY,cosa,sina:Single;
  topR,topG,topB,BtmR,btmG,btmB:Single;
  p0,p1,p2,p3: TRGB32;
  NewB:TBox;
begin
  NewB := __GetNewSizeRotated(Bitmap.Width, Bitmap.Height,Angle);
  nW := (NewB.x2 - NewB.x1) + 1;
  nH := (NewB.y2 - NewB.y1) + 1;
  mX := nW div 2;
  mY := nH div 2;
  wid := (Bitmap.Width - 1);
  hei := (Bitmap.Height - 1);
  TargetBitmap.SetSize(nW, nH);
  cosa := Cos(Angle);
  sina := Sin(Angle);
  nW -= 1; nH -= 1;

  for i := 0 to nH do begin
    for j := 0 to nW do begin
      rx := (mx + cosa * (j - mx) - sina * (i - my));
      ry := (my + sina * (j - mx) + cosa * (i - my));

      fX := (Trunc(rX)+ NewB.x1);
      fY := (Trunc(rY)+ NewB.y1);
      cX := (Ceil(rX) + NewB.x1);
      cY := (Ceil(rY) + NewB.y1);

      if not((fX < 0) or (cX < 0) or (fX >= wid) or (cX >= wid) or
             (fY < 0) or (cY < 0) or (fY >= hei) or (cY >= hei)) then
      begin
        dx := rX - (fX - NewB.x1);
        dy := rY - (fY - NewB.y1);

        p0 := Bitmap.FData[fY * Bitmap.Width + fX];
        p1 := Bitmap.FData[fY * Bitmap.Width + cX];
        p2 := Bitmap.FData[cY * Bitmap.Width + fX];
        p3 := Bitmap.FData[cY * Bitmap.Width + cX];

        TopR := (1 - dx) * p0.R + dx * p1.R;
        TopG := (1 - dx) * p0.G + dx * p1.G;
        TopB := (1 - dx) * p0.B + dx * p1.B;
        BtmR := (1 - dx) * p2.R + dx * p3.R;
        BtmG := (1 - dx) * p2.G + dx * p3.G;
        BtmB := (1 - dx) * p2.B + dx * p3.B;

        RR := Round((1 - dy) * TopR + dy * BtmR);
        GG := Round((1 - dy) * TopG + dy * BtmG);
        BB := Round((1 - dy) * TopB + dy * BtmB);

        if (RR < 0) then RR := 0
        else if (RR > 255) then RR := 255;
        if (GG < 0) then GG := 0
        else if (GG > 255) then GG := 255;
        if (BB < 0) then BB := 0
        else if (BB > 255) then BB := 255;

        k := i * TargetBitmap.Width + j;
        TargetBitmap.FData[k].r := RR;
        TargetBitmap.FData[k].g := GG;
        TargetBitmap.FData[k].b := BB;
      end;
    end;
  end;
end;

procedure TMufasaBitmap.RotateBitmapEx(Angle: Single; Expand: Boolean; Smooth: Boolean; TargetBitmap: TMufasaBitmap);
begin
  case (Expand) of
    True:
      case (Smooth) of
        True:
          __RotateBIExpand(Self, Angle, TargetBitmap);
        False:
          Self.RotateBitmap(Angle, TargetBitmap);
      end;
    False:
      case (Smooth) of
        True:
          __RotateBINoExpand(Self, Angle, TargetBitmap);
        False:
          __RotateNoExpand(Self, Angle, TargetBitmap);
      end;
  end;
end;

procedure TMufasaBitmap.Desaturate;
var
  I : integer;
  He,Se,Le : extended;
  Ptr : PRGB32;
begin
  Ptr := FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    RGBToHSL(Ptr^.R,Ptr^.G,Ptr^.B,He,Se,Le);
    HSLtoRGB(He,0.0,Le,Ptr^.R,Ptr^.G,Ptr^.B);
    inc(ptr);
  end;
end;

procedure TMufasaBitmap.Desaturate(TargetBitmap: TMufasaBitmap);
var
  I : integer;
  He,Se,Le : extended;
  PtrOld,PtrNew : PRGB32;
begin
  TargetBitmap.SetSize(FWidth,FHeight);
  PtrOld := Self.FData;
  PtrNew := TargetBitmap.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    RGBToHSL(PtrOld^.R,PtrOld^.G,PtrOld^.B,He,Se,Le);
    HSLtoRGB(He,0.0,Le,PtrNew^.R,PtrNew^.G,PtrNew^.B);
    inc(ptrOld);
    inc(PtrNew);
  end;
end;

procedure TMufasaBitmap.GreyScale(TargetBitmap: TMufasaBitmap);
var
  I : integer;
  Lum : byte;
  PtrOld,PtrNew : PRGB32;
begin
  TargetBitmap.SetSize(FWidth,FHeight);
  PtrOld := Self.FData;
  PtrNew := TargetBitmap.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    Lum := Round(PtrOld^.r * 0.3 + PtrOld^.g * 0.59 + PtrOld^.b * 0.11);
    PtrNew^.r := Lum;
    PtrNew^.g := Lum;
    PtrNew^.b := Lum;
    inc(ptrOld);
    inc(PtrNew);
  end;
end;

procedure TMufasaBitmap.GreyScale;
var
  I : integer;
  Lum : Byte;
  Ptr: PRGB32;
begin
  Ptr := Self.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    Lum := Round(Ptr^.r * 0.3 + Ptr^.g * 0.59 + Ptr^.b * 0.11);
    Ptr^.r := Lum;
    Ptr^.g := Lum;
    Ptr^.b := Lum;
    inc(ptr);
  end;
end;

function BrightnessAdjust(Col:  byte; br : integer): byte;inline;
var
  temp : integer;
begin;
  Temp := Col + Br;
  if temp < 0 then
    temp := 0
  else if temp > 255 then
    temp := 255;
  result := temp;
end;
procedure TMufasaBitmap.Brightness(br: integer);
var
  I : integer;
  Ptr: PRGB32;
begin
  Ptr := Self.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    Ptr^.r := BrightnessAdjust(Ptr^.r,br);
    Ptr^.g := BrightnessAdjust(Ptr^.g,br);
    Ptr^.b := BrightnessAdjust(Ptr^.b,br);
    inc(ptr);
  end;
end;

procedure TMufasaBitmap.Brightness(TargetBitmap: TMufasaBitmap; br: integer);
var
  I : integer;
  PtrOld,PtrNew : PRGB32;
begin
  TargetBitmap.SetSize(FWidth,FHeight);
  PtrOld := Self.FData;
  PtrNew := TargetBitmap.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    PtrNew^.r := BrightnessAdjust(PtrOld^.r,br);
    PtrNew^.g := BrightnessAdjust(PtrOld^.g,br);
    PtrNew^.b := BrightnessAdjust(PtrOld^.b,br);
    inc(ptrOld);
    inc(PtrNew);
  end;
end;

const
  Grey = 128;
function ContrastAdjust(Col:  byte; co : extended): byte;inline;
var
  temp : integer;
begin;
  Temp := floor((col - Grey) * co) + grey;
  if temp < 0 then
    temp := 0
  else if temp > 255 then
    temp := 255;
  result := temp;
end;

procedure TMufasaBitmap.Contrast(co: Extended);
var
  I : integer;
  Ptr: PRGB32;
begin
  Ptr := Self.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    Ptr^.r := ContrastAdjust(Ptr^.r,co);
    Ptr^.g := ContrastAdjust(Ptr^.g,co);
    Ptr^.b := ContrastAdjust(Ptr^.b,co);
    inc(ptr);
  end;
end;

procedure TMufasaBitmap.Contrast(TargetBitmap: TMufasaBitmap; co: Extended);
var
  I : integer;
  PtrOld,PtrNew : PRGB32;
begin
  TargetBitmap.SetSize(FWidth,FHeight);
  PtrOld := Self.FData;
  PtrNew := TargetBitmap.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    PtrNew^.r := ContrastAdjust(PtrOld^.r,co);
    PtrNew^.g := ContrastAdjust(PtrOld^.g,co);
    PtrNew^.b := ContrastAdjust(PtrOld^.b,co);
    inc(ptrOld);
    inc(PtrNew);
  end;
end;

procedure TMufasaBitmap.Invert;
var
  i : integer;
begin
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    Self.FData[i].r := not Self.FData[i].r;
    Self.FData[i].g := not Self.FData[i].g;
    Self.Fdata[i].b := not Self.FData[i].b;
  end;
end;

procedure TMufasaBitmap.Invert(TargetBitmap: TMufasaBitmap);
var
  I : integer;
  PtrOld,PtrNew : PRGB32;
begin
  TargetBitmap.SetSize(FWidth,FHeight);
  PtrOld := Self.FData;
  PtrNew := TargetBitmap.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    PtrNew^.r := not PtrOld^.r;
    PtrNew^.g := not PtrOld^.g;
    PtrNew^.b := not PtrOld^.b;
    inc(ptrOld);
    inc(PtrNew);
  end;
end;

procedure TMufasaBitmap.Posterize(TargetBitmap: TMufasaBitmap; Po: integer);
var
  I : integer;
  PtrOld,PtrNew : PRGB32;
begin
  if not InRange(Po,1,255) then
    Raise exception.CreateFmt('Posterize Po(%d) out of range[1,255]',[Po]);
  TargetBitmap.SetSize(FWidth,FHeight);
  PtrOld := Self.FData;
  PtrNew := TargetBitmap.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
    PtrNew^.r := min(Round(PtrOld^.r / po) * Po, 255);
    PtrNew^.g := min(Round(PtrOld^.g / po) * Po, 255);
    PtrNew^.b := min(Round(PtrOld^.b / po) * Po, 255);
    inc(ptrOld);
    inc(PtrNew);
  end;
end;

procedure TMufasaBitmap.Posterize(Po: integer);
var
  I : integer;
  Ptr: PRGB32;
  {a:integer; }
begin
  if not InRange(Po,1,255) then
    Raise exception.CreateFmt('Posterize Po(%d) out of range[1,255]',[Po]);
  Ptr := Self.FData;
  for i := (FHeight*FWidth-1) downto 0 do
  begin;
   { a := round(ptr^.r / po);
    a := a * po;
    ptr^.r := min(a,255);
    a := round(ptr^.g / po);
    a := a * po;
    ptr^.g := min(a,255);
    a := round(ptr^.b / po);
    a := a * po;
    ptr^.b := min(a,255);      }
    ptr^.r := min(Round(ptr^.r / po) * Po, 255);
    ptr^.g := min(Round(ptr^.g / po) * Po, 255);
    ptr^.b := min(Round(ptr^.b / po) * Po, 255);
    inc(ptr);
  end;
end;

procedure TMufasaBitmap.Blur(const Block, xs, ys, xe, ye: integer);
var
  wid,hei,x,y,mid,fx,fy,size:Integer;
  red,green,blue,lx,ly,hx,hy,sl:Integer;
  bmp: TMufasaBitmap;
begin
  Size := (Block*Block);

  if (Size<=1) or (Block mod 2 = 0) then
    Exit;

  if (not Self.PointInBitmap(xs, ys)) or (not Self.PointInBitmap(xe, ye)) then
    raise exception.Create('TMufasaBitmap.Blur(): The bounds you pased to blur exceed the bitmap bounds');

  bmp := Self.Copy(xs, ys, xe, ye);
  wid := (bmp.Width - 1);
  hei := (bmp.Height - 1);
  mid := (Block div 2);

  try
    for y:=0 to hei do
    begin
      ly := Max(0,y-mid);
      hy := Min(hei,y+mid);
      for x:=0 to wid do
      begin
        lx := Max(0,x-mid);
        hx := Min(wid,x+mid);
        size := 0;
        red := 0; green := 0; blue := 0;

        for fy:=ly to hy do
          for fx:=lx to hx do
          begin
            sl := (fy * bmp.Width +fx);
            inc(red, bmp.FData[sl].R);
            inc(green, bmp.FData[sl].G);
            inc(blue, bmp.FData[sl].B);
            inc(size);
          end;

         sl := ((y+xs)*self.Width+(x+ys));
         Self.FData[sl].R := (red div size);
         Self.FData[sl].G := (green div size);
         Self.FData[sl].B := (blue div size);
      end;
    end;
  finally
    bmp.free();
  end;
end;

procedure TMufasaBitmap.Blur(const Block: integer); overload;
begin
  Self.Blur(Block, 0, 0, self.width -1, self.height -1);
end;

procedure TMufasaBitmap.Convolute(TargetBitmap : TMufasaBitmap; Matrix: T2DExtendedArray);
var
  x,y,yy,xx,cx,cy: Integer;
  Row,RowT : TPRGB32Array;
  mW,mH,midx,midy:Integer;
  valR,valG,valB: Extended;

  procedure ForceInBounds(x,y, Wid,Hig: Int32; out cx,cy: Int32); Inline;
  begin
    cx := x;
    cy := y;
    if cx >= Wid then   cx := Wid-1
    else if cx < 0 then cx := 0;
    if cy >= Hig then   cy := Hig-1
    else if cy < 0 then cy := 0;
  end;

begin
  TargetBitmap.SetSize(Self.FWidth,Self.FHeight);
  Row := RowPtrs;
  RowT := TargetBitmap.RowPtrs; //Target

  mW := High(Matrix[0]);
  mH := High(Matrix);
  midx := (mW+1) div 2;
  midy := (mH+1) div 2;
  for y:=0 to Self.FHeight-1 do
    for x:=0 to Self.FWidth-1 do
    begin
      valR := 0;
      valG := 0;
      valB := 0;
      for yy:=0 to mH do
        for xx:=0 to mW do
        begin
          ForceInBounds(x+xx-midx, y+yy-midy, Self.FWidth, Self.FHeight, cx, cy);
          valR := valR + (Matrix[yy][xx] * Row[cy][cx].R);
          valG := valG + (Matrix[yy][xx] * Row[cy][cx].G);
          valB := valB + (Matrix[yy][xx] * Row[cy][cx].B);
        end;
      RowT[y][x].R := round(valR);
      RowT[y][x].G := round(valG);
      RowT[y][x].B := round(valB);;
    end;
end;


function TMufasaBitmap.CompareAt(Other: TMufasaBitmap; Pt: TPoint; Tol: Int32): Extended;
var
  x,y,tw,th,SAD: Int32;
  c1,c2: TRGB32;
begin
  tw := Other.Width;
  th := Other.Height;
  if (tw = 0) or (th = 0) or (tw+pt.x > Self.FWidth) or (th+pt.y > Self.FHeight) then
    Exit(0);

  SAD := 0;
  for y:=0 to th-1 do
    for x:=0 to tw-1 do
    begin
      c1 := Self.FData [(y + pt.y) * FWidth + x + pt.x];
      c2 := Other.FData[y * tw + x];
      if Sqr(c1.R-c2.R) + Sqr(c1.G-c2.G) + Sqr(c1.B-c2.B) > Sqr(Tol) then
        Inc(SAD);
    end;
  
  Result := 1 - SAD / (FWidth*FHeight);
end;

procedure TMufasaBitmap.Downsample(DownScale: Int32; TargetBitmap: TMufasaBitmap);
var
  invArea: Double;
  function BlendArea(x1,y1: Int32): TRGB32; inline;
  var
    x,y:Int32;
    R:Int32=0; G:Int32=0; B:Int32=0;
  begin
    for y:=y1 to y1+DownScale-1 do
      for x:=x1 to x1+DownScale-1 do
      begin
        Inc(R, Self.FData[y*FWidth+x].R);
        Inc(G, Self.FData[y*FWidth+x].G);
        Inc(B, Self.FData[y*FWidth+x].B);
      end;
    Result.R := Round(R * invArea);
    Result.G := Round(G * invArea);
    Result.B := Round(B * invArea);
  end;
var
  x,y,nw,nh:Int32;
begin
  if (FWidth = 0) or (FHeight = 0) or (DownScale <= 0) then 
    Exit;
  
  nw := FWidth div DownScale;
  nh := FHeight div DownScale;
  invArea := Double(1.0) / Sqr(DownScale);
  TargetBitmap.SetSize(nW, nH);
  for y:=0 to nh-1 do
    for x:=0 to nw-1 do
      TargetBitmap.FData[y*nw+x] := BlendArea(x*DownScale, y*DownScale);
end;

function TMufasaBitmap.MatchTemplate(Other: TMufasaBitmap; Formula: ETMFormula): TSingleMatrix;
var
  y: Int32;
  Image, Templ: T2DIntArray;
begin
  if (FWidth < Other.Width) or (FHeight < Other.Height) then
    raise Exception.CreateFmt('Image must be larger than Template - Image(%d, %d), Templ(%d, %d)', [FWidth,FHeight, Other.Width, Other.Height]);

  SetLength(Image, Self.Height, Self.Width);
  SetLength(Templ, Other.Height, Other.Width);
  
  for y:=0 to Self.Height-1 do
    Move(Self.FData[y*Self.Width], Image[y,0], Self.Width*SizeOf(Int32));
  
  for y:=0 to Other.Height-1 do
    Move(Other.FData[y*Other.Width], Templ[y,0], Other.Width*SizeOf(Int32));
  
  Result := MatchTempl.MatchTemplate(Image, Templ, Int32(Formula));
end;

function TMufasaBitmap.FindTemplate(Other: TMufasaBitmap; Formula: ETMFormula; MinMatch: Extended): TPoint;
var
  xcorr: TSingleMatrix;
begin
  xcorr := Self.MatchTemplate(Other, Formula);
  
  if Formula in [TM_SQDIFF, TM_SQDIFF_NORMED] then
  begin
    Result := TPoint(MatrixArgMin(xcorr));
    if xcorr[Result.Y, Result.X] > MinMatch then
      Result := Point(-1,-1);
  end else
  begin
    Result := TPoint(MatrixArgMax(xcorr));
    if xcorr[Result.Y, Result.X] < MinMatch then
      Result := Point(-1,-1);
  end;
end;


function TMufasaBitmap.CreateTMask: TMask;
var
  x,y : integer;
  dX,dY : integer;
begin
  Result.BlackHi:= -1;
  Result.WhiteHi:= -1;
  Result.w := Self.Width;
  Result.h := Self.Height;
  SetLength(result.Black,FWidth*FHeight);
  SetLength(result.White,FWidth*FHeight);
  dX := FWidth-1;
  dY := FHeight-1;
  for y := 0 to dY do
    for x := 0 to dX do
    //Check for non-white/black pixels? Not for now atleast.
      if FData[y*FWidth+x].r = 255 then
      begin;
        inc(Result.WhiteHi);
        Result.White[Result.WhiteHi].x := x;
        Result.White[Result.WhiteHi].y := y;
      end else
      begin;
        inc(Result.BlackHi);
        Result.Black[Result.BlackHi].x := x;
        Result.Black[Result.BlackHi].y := y;
      end;
  SetLength(result.Black,Result.BlackHi+1);
  SetLength(result.White,Result.WhiteHi+1);
end;

procedure TMufasaBitmap.ResizeBilinear(NewW, NewH: Integer);
var
  x,y,i,j: Integer;
  p0,p1,p2,p3: TRGB32;
  ratioX,ratioY,dx,dy: Single;
  Temp: TMufasaBitmap;
  RR,GG,BB: Single;
  Row,RowT: TPRGB32Array;
begin
  Temp := Self.Copy();
  RowT:= Temp.RowPtrs;
  ratioX := (Self.Width-1) / NewW;
  ratioY := (Self.Height-1) / NewH;
  Self.SetSize(NewW, NewH);
  Row := Self.RowPtrs;
  Dec(NewW);
  for i:=0 to NewH-1 do
  for j:=0 to NewW do
  begin
    x := Trunc(ratioX * j);
    y := Trunc(ratioY * i);
    dX := ratioX * j - x;
    dY := ratioY * i - y;

    p0 := RowT[y][x];
    p1 := RowT[y][x+1];
    p2 := RowT[y+1][x];
    p3 := RowT[y+1][x+1];

    RR := p0.R * (1-dX) * (1-dY) +
          p1.R * (dX * (1-dY)) +
          p2.R * (dY * (1-dX)) +
          p3.R * (dX * dY);

    GG := p0.G * (1-dX) * (1-dY) +
          p1.G * (dX * (1-dY)) +
          p2.G * (dY * (1-dX)) +
          p3.G * (dX * dY);

    BB := p0.B * (1-dX) * (1-dY) +
          p1.B * (dX * (1-dY)) +
          p2.B * (dY * (1-dX)) +
          p3.B * (dX * dY);

    Row[i][j].R := Trunc(RR);
    Row[i][j].G := Trunc(GG);
    Row[i][j].B := Trunc(BB);
  end;
  Temp.Free();
end;

procedure TMufasaBitmap.Rectangle(const Box: TBox; const Color: Integer; const Transparency: Extended); overload;
var
  RR, GG, BB: Byte;
  Line, x, y: Longword;
begin
  Self.ValidatePoint(Box.X1, Box.Y1);
  Self.ValidatePoint(Box.X2, Box.Y2);

  if (Transparency > 1.00) then
  begin
    Self.Rectangle(Box, Color);
    Exit();
  end;

  if (Transparency = 0.00) then
    Exit();

  ColorToRGB(Color, RR, GG, BB);

  for y := Box.Y1 to Box.Y2 do
  begin
    Line := (y * Self.Width) + Box.x1;
    for x := Box.X1 to Box.X2 do
    begin
      Self.FData[Line].r := Round((Self.FData[Line].r * (1.0 - Transparency)) + (RR * Transparency));
      Self.FData[Line].g := Round((Self.FData[Line].g * (1.0 - Transparency)) + (GG * Transparency));
      Self.FData[Line].b := Round((Self.FData[Line].b * (1.0 - Transparency)) + (BB * Transparency));
      Inc(Line);
    end;
  end;
end;

procedure TMufasaBitmap.DrawText(Text, Font: String; Position: TPoint; Shadow: Boolean; Color: TColor);
var
  TPA: TPointArray;
  TextWidth, TextHeight: Int32;
begin
  if (FList = nil) then
    raise Exception.Create('TMufasaBitmap.DrawText requires the TMBitmaps list set');

  with FList.Client as TClient do
    TPA := MOCR.TextToFontTPA(Text, Font, TextWidth, TextHeight);

  OffsetTPA(TPA, Position);

  if Shadow then
  begin
    OffsetTPA(TPA, Point(1, 1));
    DrawTPA(TPA, $000000);
    OffsetTPA(TPA, Point(-1, -1));
  end;

  DrawTPA(TPA, Color);
end;

procedure TMufasaBitmap.DrawSystemText(Text: String; Font: TFont; Position: TPoint);
var
  TextWidth, TextHeight, Y: Int32;
begin
  with TBitmap.Create() do
  try
    PixelFormat := pf32bit;

    Canvas.Brush.Style := bsClear;
    Canvas.Font := Font;
    Canvas.GetTextSize(Text, TextWidth, TextHeight);

    if Position.X + TextWidth > Self.FWidth then
      TextWidth := Self.FWidth - Position.X;
    if Position.Y + TextHeight > Self.FHeight then
      TextHeight := Self.FHeight - Position.Y;

    if (TextWidth > 0) and (TextHeight > 0) then
    begin
      SetSize(TextWidth, TextHeight);

      BeginUpdate();

      for Y := Position.Y to Min(Position.Y + TextHeight - 1, Self.FHeight - 1) do
        if (Y >= 0) then
          Move(FData[Y * Self.FWidth + Max(0, Position.X)], ScanLine[Y - Position.Y]^, Width * 4);

      Canvas.TextOut(Min(Position.X, 0), Min(Position.Y, 0), Text);

      for Y := Position.Y to Min(Position.Y + TextHeight - 1, Self.FHeight - 1) do
        if (Y >= 0) then
          Move(ScanLine[Y - Position.Y]^, FData[Y * Self.FWidth + Max(0, Position.X)], Width * 4);

      EndUpdate();
    end;
  finally
    Free();
  end;
end;

procedure TMufasaBitmap.DrawSystemText(Text, FontName: String; Size: Integer; Position: TPoint; Shadow: Boolean; Color: TColor);
var
  Font: TFont;
begin
  Font := TFont.Create();
  Font.Name := FontName;
  Font.Size := Size;
  Font.Color := Color;

  DrawSystemText(Text, Font, Position);

  Font.Free();
end;

constructor TMBitmaps.Create(Owner: TObject);
begin
  inherited Create;
  SetLength(BmpArray,50);
  SetLength(FreeSpots, 50);
  FreeSpotsLen := 50;
  BmpsHigh := 49;
  BmpsCurr := -1;
  FreeSpotsHigh := -1;
  Self.Client := Owner;
end;

destructor TMBitmaps.Destroy;
var
  I : integer;
  WriteStr : string;
begin
  WriteStr := '[';
  for I := 0 to BmpsCurr do
    if Assigned(BmpArray[I]) then
    begin;
      if BmpArray[I].Name = '' then
        WriteStr := WriteStr + IntToStr(I) + ', '
      else
        WriteStr := WriteStr + bmpArray[I].Name + ', ';

      BmpArray[I].Free();
    end;

  if WriteStr <> '[' then  //Has unfreed bitmaps
  begin
    SetLength(WriteStr, Length(WriteStr) - 1);
    WriteStr[Length(writeStr)] := ']';
    TClient(Client).Writeln(Format('The following bitmaps were not freed: %s', [WriteStr]));
  end;

  SetLength(BmpArray, 0);
  SetLength(FreeSpots, 0);

  inherited Destroy;
end;


{ TMufasaBitmap }
procedure TMufasaBitmap.SetSize(AWidth, AHeight: integer);
var
  NewData : PRGB32;
  i,minw,minh : integer;
begin
  if FExternData then
    raise Exception.Create('Cannot resize a bitmap with FExternData = True!');

  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    if AWidth*AHeight <> 0 then
    begin;
      NewData := GetMem(AWidth * AHeight * SizeOf(TRGB32));
      FillDWord(NewData[0],AWidth*AHeight,0);
    end
    else
      NewData := nil;
    if Assigned(FData) and Assigned(NewData) and (FWidth*FHeight <> 0) then
    begin;
      minw := Min(AWidth,FWidth);
      minh := Min(AHeight,FHeight);
      for i := 0 to minh - 1 do
        Move(FData[i*FWidth],Newdata[i*AWidth],minw * SizeOf(TRGB32));
    end;
    if Assigned(FData) then
      FreeMem(FData);
    FData := NewData;
    FWidth := AWidth;
    FHeight := AHeight;
  end;
end;

procedure TMufasaBitmap.StretchResize(AWidth, AHeight: integer);
var
  NewData : PRGB32;
  x,y : integer;
begin
  if FExternData then
    raise Exception.Create('Cannot resize a bitmap with FExternData = True!');

  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin;
    if AWidth*AHeight <> 0 then
    begin;
      NewData := GetMem(AWidth * AHeight * SizeOf(TRGB32));
      FillDWord(NewData[0],AWidth*AHeight,0);
    end
    else
      NewData := nil;
    if Assigned(FData) and Assigned(NewData) and (FWidth*FHeight <> 0) then
    begin;
      for y := 0 to AHeight - 1 do
        for x := 0 to AWidth -1 do
          NewData[y*AWidth + x] := FData[((y * FHeight)div aheight) * FWidth+ (x * FWidth) div awidth];
    end;
    if Assigned(FData) then
      FreeMem(FData);
    FData := NewData;
    FWidth := AWidth;
    FHeight := AHeight;
  end;
end;

procedure TMufasaBitmap.ResizeEx(Method: TBmpResizeMethod; NewWidth,
  NewHeight: integer);
begin
  if (Self.FExternData) then
    raise Exception.Create('Cannot resize a bitmap with FExternData = True!');

  case (method) of
    RM_Nearest: Self.StretchResize(NewWidth, NewHeight);
    RM_Bilinear: Self.ResizeBilinear(NewWidth, NewHeight);
  end;
end;

procedure Swap(var a, b: byte); inline;
var
  t: Byte;
begin
  t := a;
  a := b;
  b := t;
end;

procedure TMufasaBitmap.ThresholdAdaptive(Alpha, Beta: Byte; InvertIt: Boolean; Method: TBmpThreshMethod; C: Integer);
var
  i,size: Int32;
  upper: PtrUInt;
  vMin,vMax,threshold: UInt8;
  Counter: Int64;
  Tab: Array [0..256] of UInt8;
  ptr: PRGB32;
begin
  if Alpha = Beta then Exit;
  if Alpha > Beta then Swap(Alpha, Beta);

  size := (Self.Width * Self.Height) - 1;
  upper := PtrUInt(@Self.FData[size]);
  //Finding the threshold - While at it convert image to grayscale.
  Threshold := 0;
  case Method of
    //Find the Arithmetic Mean / Average.
    TM_Mean:
    begin
      Counter := 0;
      ptr := Self.FData;
      while PtrUInt(Ptr) <= upper do
      begin
        Ptr^.B := (Ptr^.B + Ptr^.G + Ptr^.R) div 3;
        Counter += Ptr^.B;
        Inc(Ptr);
      end;
      Threshold := (Counter div size) + C;
    end;

    //Middle of Min- and Max-value
    TM_MinMax:
    begin
      vMin := 255;
      vMax := 0;
      ptr := Self.FData;
      while PtrUInt(Ptr) <= upper do
      begin
        ptr^.B := (ptr^.B + ptr^.G + ptr^.R) div 3;
        if ptr^.B < vMin then
          vMin := ptr^.B
        else if ptr^.B > vMax then
          vMax := ptr^.B;
        Inc(ptr);
      end;
      Threshold := ((vMax+Int32(vMin)) shr 1) + C;
    end;
  end;

  if InvertIt then Swap(Alpha, Beta);
  for i:=0 to (Threshold-1) do Tab[i] := Alpha;
  for i:=Threshold to 255 do Tab[i] := Beta;

  ptr := Self.FData;
  while PtrUInt(Ptr) <= upper do
  begin
    ptr^.R := Tab[Ptr^.B];
    ptr^.G := 0;
    ptr^.B := 0;
    ptr^.A := 0;
    Inc(ptr);
  end;
end;

procedure TMufasaBitmap.SetPersistentMemory(mem: PtrUInt; awidth, aheight: integer);
begin
  SetSize(0, 0);
  FExternData := True;
  FWidth := awidth;
  FHeight := aheight;

  FData := PRGB32(mem);
end;

procedure TMufasaBitmap.ResetPersistentMemory;
begin
  if not FExternData then
    raise Exception.Create('ResetPersistentMemory: Bitmap is not persistent (FExternData = False)');

  FExternData := False;
  FData := nil;

  SetSize(0, 0);
end;

function TMufasaBitmap.PointInBitmap(x, y: integer): boolean;
begin
  result := ((x >= 0) and (x < FWidth) and (y >= 0) and (y < FHeight));
end;

procedure TMufasaBitmap.ValidatePoint(x, y: integer);
begin
  if not(PointInBitmap(x,y)) then
    raise Exception.CreateFmt('You are accessing an invalid point, (%d,%d) at bitmap[%d]',[x,y,index]);
end;

constructor TMufasaBitmap.Create;
begin
  inherited Create;
  Name:= '';
  FTransparentSet:= False;
  SetSize(0,0);

  FExternData := False;

  Index := -1;
  List := nil;
  {FData:= nil;
  FWidth := 0;
  FHeight := 0; }
end;

destructor TMufasaBitmap.Destroy;
begin
  if Assigned(List) then
    List.removeBMP(Index);

  if Assigned(OnDestroy) then
    OnDestroy(Self);

  if Assigned(FData) and not FExternData then
    Freemem(FData);

  inherited Destroy;
end;

end.

