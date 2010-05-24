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

    Mufasa Math Unit for the Mufasa Macro Library
}

unit mmath;
// mufasa math

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,MufasaTypes;

function RotatePoints(const P: TPointArray;const A, cx, cy: Extended): TPointArray;
function RotatePoint(const p: TPoint;const angle, mx, my: Extended): TPoint;
function ChangeDistPT(const PT : TPoint; mx,my : integer; newdist : extended) : TPoint;
function ChangeDistTPA(var TPA : TPointArray; mx,my : integer; newdist : extended) : boolean;

implementation
uses
  math;

{/\
  Rotates the given points (P) by A (in radians) around the point defined by cx, cy.
/\}

function RotatePoints(const P: TPointArray;const A, cx, cy: Extended): TPointArray;

var
   I, L: Integer;

begin
  L := High(P);
  SetLength(Result, L + 1);
  for I := 0 to L do
  begin
    Result[I].X := Round(cx + cos(A) * (p[i].x - cx) - sin(A) * (p[i].y - cy));
    Result[I].Y := Round(cy + sin(A) * (p[i].x - cx) + cos(A) * (p[i].y - cy));
  end;
end;

{/\
  Rotates the given point (p) by A (in radians) around the point defined by cx, cy.
/\}

function RotatePoint(const p: TPoint;const angle, mx, my: Extended): TPoint;

begin
  Result.X := Round(mx + cos(angle) * (p.x - mx) - sin(angle) * (p.y - my));
  Result.Y := Round(my + sin(angle) * (p.x - mx) + cos(angle) * (p.y- my));
end;

function ChangeDistPT(const PT : TPoint; mx,my : integer; newdist : extended) : TPoint;
var
  angle : extended;
begin
  angle := ArcTan2(pt.y-my,pt.x-mx);
  result.x := round(cos(angle) * newdist) + mx;
  result.y := round(sin(angle) * newdist) + my;
end;

function ChangeDistTPA(var TPA : TPointArray; mx,my : integer; newdist : extended) : boolean;
var
  angle : extended;
  i : integer;
begin
  result := false;
  if length(TPA) < 1 then
    exit;
  result := true;
  try
    for i := high(TPA) downto 0 do
    begin
      angle := ArcTan2(TPA[i].y-my,TPA[i].x-mx);
      TPA[i].x := round(cos(angle) * newdist) + mx;
      TPA[i].y := round(sin(angle) * newdist) + my;
    end;
  except
    result := false;
  end;

end;

end.

