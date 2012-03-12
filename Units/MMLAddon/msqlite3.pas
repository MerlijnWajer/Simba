{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Veneti� and Merlijn Wajer

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

    SQLite3 for the Mufasa Macro Library
}
unit msqlite3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3, math;

type
  TStringArray = array of string;
  T2DStringArray = array of TStringArray;
  P2DStringArray = ^T2DStringArray;

  TMSQLite3 = class(TObject)
  protected
    Client : TObject;
    ConnList : array of ppsqlite3;
  public
    function version() : string;
    function version_num() : integer;
    function escape(s : string) : string;
    function open_db(filename : string; flags : integer) : integer;
    function query(index : integer; sql : string) : boolean;
    function queryvalue(index : integer; sql : string; out data : T2DStringArray) : boolean;
    function getHandle(index : integer) : ppsqlite3;
    function errcode(index : integer) : integer;
    function errmsg(index : integer) : string;
    procedure closeHandle(index : integer);
    constructor Create(Owner : TObject);
    destructor Destroy; override;
  end;

implementation

uses
  Client;

// http://sqlite.org/c3ref/errcode.html
function TMSQLite3.errcode(index : integer) : integer;
begin
  result := sqlite3_errcode(getHandle(index)^);
end;

// http://sqlite.org/c3ref/errcode.html
function TMSQLite3.errmsg(index : integer) : string;
begin
  result := sqlite3_errmsg(getHandle(index)^);
end;

function msqlite3_callback(sender : Pointer; Columns : Integer; ColumnValues, ColumnNames: PPChar) : integer; cdecl;
var
  i, l : integer;
begin
  result := SQLITE_OK;
  l := Length(P2DStringArray(sender)^) + 1;
  SetLength(P2DStringArray(sender)^, l);
  if Columns > 0 then
  begin
    SetLength(P2DStringArray(sender)^[l - 1], Columns);
    for i := 0 to Columns - 1 do
    begin
      P2DStringArray(sender)^[l - 1][i] := ColumnValues^;
      Inc(ColumnValues);
    end;
  end;
end;

// http://sqlite.org/c3ref/libversion.html
function TMSQLite3.version() : string;
begin
  result := sqlite3_libversion();
end;

// http://sqlite.org/c3ref/libversion.html
function TMSQLite3.version_num() : integer;
begin
  result := sqlite3_libversion_number();
end;

// http://sqlite.org/faq.html#q14
function TMSQLite3.escape(s : string) : string;
begin
  result := StringReplace(s, #39, #39#39, [rfReplaceAll]);
end;

// http://sqlite.org/c3ref/open.html
function TMSQLite3.open_db(filename : string; flags : integer = (SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE)) : integer;
var
  filenameC : PChar;
  l, ecode : integer;
  emsg : string;
begin
  l := length(ConnList);
  SetLength(ConnList, l + 1);
  result := l;
  filenameC := StrPCopy(StrAlloc(length(filename) + 1), filename);
  if sqlite3_open_v2(filenameC, @(ConnList[result]), flags, nil) <> SQLITE_OK then
  begin
    ecode := errcode(result);
    emsg := errmsg(result);
    closeHandle(result);
    result := -1;
    raise exception.CreateFmt('TMSQLite3.open_db: Error opening database ''%s'' : SQLite error (%d): %s' , [filename, ecode, emsg]);
  end;
  StrDispose(filenameC);
end;

// http://sqlite.org/c3ref/exec.html
function TMSQLite3.query(index : integer; sql : string) : boolean;
var
  sqlC : PChar;
begin
  sqlC := StrPCopy(StrAlloc(length(sql) + 1), sql);
  result := sqlite3_exec(getHandle(index)^, sqlC, nil, nil, nil) = SQLITE_OK;
  StrDispose(sqlC);
end;

function TMSQLite3.queryValue(index : integer; sql : string; out data : T2DStringArray) : boolean;
var
  sqlC : PChar;
begin
  sqlC := StrPCopy(StrAlloc(length(sql) + 1), sql);
  result := sqlite3_exec(getHandle(index)^, sqlC, @msqlite3_callback, @data, nil) = SQLITE_OK;
  StrDispose(sqlC);
end;

function TMSQLite3.getHandle(index : integer) : ppsqlite3;
begin
  if not InRange(Index, 0, Length(ConnList)) then
    raise exception.CreateFmt('TMSQLite3.getHandle: Trying to access a database handle (%d) that is out of range', [index]);
  if (ConnList[index] = nil) then
    raise exception.CreateFmt('TMSQLite3.getHandle: Trying to access a database handle (%d) that has already been freed', [index]);
  Result := @(ppsqlite3(ConnList[index]));
end;

procedure TMSQLite3.closeHandle(index : integer);
begin
  if not InRange(index, 0, Length(ConnList)) then
    raise exception.CreateFmt('TMSQLite3.closeHandle: Trying to free a database handle (%d) that is out of range', [index]);
  if ppsqlite3(ConnList[index]) = nil then
    raise exception.CreateFmt('TMSQLite3.closeHandle: Trying to free a database handle (%d) that has already been freed', [index]);
  sqlite3_close(GetHandle(index)^);
  ConnList[index] := nil;
end;

constructor TMSQLite3.Create(Owner : TObject);
begin
  inherited Create;
  Client := Owner;
end;

destructor TMSQLite3.Destroy();
var
  i : integer;
begin
  for i := high(ConnList) downto 0 do
    if ConnList[i] <> nil then
    begin
      closeHandle(i);
      ConnList[i] := nil;
      TClient(Client).Writeln(Format('Database handle [%d] has not been freed in the script, freeing it now.', [i]));
    end;
  SetLength(ConnList, 0);
  inherited Destroy;
end;

end.
