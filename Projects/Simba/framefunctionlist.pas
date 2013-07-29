{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië and Merlijn Wajer

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

    Frame Function List form for Simba
}
unit framefunctionlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, MufasaBase,Forms, ComCtrls, StdCtrls, Controls,
  ExtCtrls, Buttons,mmisc,v_ideCodeInsight, newsimbasettings;

type

  { TFillThread }

  TFillThread = class(TThread)
  public
    Analyzer : TCodeInsight;
    MS : TMemoryStream;
    FunctionList : ^TTreeView;
    IncludesNode,ScriptNode : TTreeNode;
    procedure execute; override;
  end;
  { TFunctionListFrame }

  TFunctionListFrame = class(TFrame)
    editSearchList: TEdit;
    FunctionList: TTreeView;
    FunctionListLabel: TLabel;
    CloseButton: TSpeedButton;
    ClearSearch: TSpeedButton;
    Panel1: TPanel;
    procedure ClearSearchClick(Sender: TObject);
    procedure editSearchListChange(Sender: TObject);
    procedure FillThreadTerminate(Sender: TObject);
    procedure FrameEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure FunctionListDblClick(Sender: TObject);
    procedure FunctionListDeletion(Sender: TObject; Node: TTreeNode);
    procedure FunctionListLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FunctionListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DockFormOnClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure CloseButtonClick(Sender: TObject);
    procedure FunctionListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FFilterTree: TTreeView;
    FLastScript: string;
    FLastInterp: Integer;
    Filtering: boolean;
    FillThread: TFillThread;
    procedure FilterTreeVis(Vis : boolean);
    function GetFilterTree: TTreeView;
    { private declarations }
  public
    DraggingNode : TTreeNode;
    ScriptNode : TTreeNode;
    IncludesNode : TTreeNode;
    InCodeCompletion : boolean;
    CompletionCaret : TPoint;
    StartWordCompletion : TPoint;
    CompletionLine : string;
    CompletionStart : string;
    property FilterTree : TTreeView read GetFilterTree;
    procedure LoadScriptTree( Script : String);
    function Find(Next : boolean; backwards : boolean = false) : boolean;
    { public declarations }
  end; 

  TMethodInfo = packed record
    MethodStr,Filename : PChar;
    BeginPos,endpos : integer;
  end;
  PMethodInfo = ^TMethodInfo;

implementation

uses
  SimbaUnit, Graphics, stringutil, simpleanalyzer,v_ideCodeParser,lclintf;

{ TFunctionListFrame }

procedure TFunctionListFrame.editSearchListChange(Sender: TObject);
begin
  Find(false);
end;

procedure TFunctionListFrame.ClearSearchClick(Sender: TObject);
begin
  editSearchList.Text := '';
  Find(false);
end;

procedure TFunctionListFrame.FillThreadTerminate(Sender: TObject);
begin
  FillThread.Analyzer.Free;
  ScriptNode.Expand(true);
  FunctionList.EndUpdate;
  if Filtering then
  begin
    FilterTreeVis(True);
    Find(false,false);
  end;
  FillThread := nil;
end;

procedure TFunctionListFrame.FrameEndDock(Sender, Target: TObject; X, Y: Integer);
begin
  if (Target is TPanel) then
  begin
     SimbaForm.SplitterFunctionList.Visible := true;
     CloseButton.Visible:= true;
  end
  else if (Target is TCustomDockForm) then
  begin
    TCustomDockForm(Target).Caption := 'Functionlist';
    TCustomDockForm(Target).OnClose := @DockFormOnClose;
    SimbaForm.SplitterFunctionList.Visible:= false;
    CloseButton.Visible:= false;
  end;
end;

procedure TFunctionListFrame.FunctionListDblClick(Sender: TObject);
var
  Node : TTreeNode;
  MethodInfo : TMethodInfo;
begin
  if FilterTree.Visible then
    Node := FilterTree.Selected
  else
    node := FunctionList.Selected;

  if (node<> nil) and (node.Level > 0) and (node.Data <> nil) then
    if InCodeCompletion then
    begin
      SimbaForm.CurrScript.SynEdit.InsertTextAtCaret( GetMethodName(PMethodInfo(node.Data)^.MethodStr,true));
      SimbaForm.RefreshTab;
    end
    else
    begin
      MethodInfo := PMethodInfo(node.Data)^;
      if (DraggingNode = node) and (MethodInfo.BeginPos > 0) then
        if (MethodInfo.Filename = nil) or ((MethodInfo.Filename = '') xor FileExistsUTF8(MethodInfo.Filename)) then
        begin
          if (MethodInfo.Filename <> nil) and (MethodInfo.Filename <> '') then
            SimbaForm.LoadScriptFile(MethodInfo.Filename,true,true);
          SimbaForm.CurrScript.SynEdit.SelStart := MethodInfo.BeginPos + 1;
          SimbaForm.CurrScript.SynEdit.SelEnd := MethodInfo.EndPos + 1;
        end;
    end;
end;

procedure TFunctionListFrame.FunctionListDeletion(Sender: TObject;
  Node: TTreeNode);
var
  MethodInfo : PMethodInfo;
begin
  if node.data <> nil then
  begin
    MethodInfo := PMethodInfo(Node.data);
    if MethodInfo^.MethodStr <> nil then
      StrDispose(MethodInfo^.MethodStr);
    if MethodInfo^.FileName <> nil then
      StrDispose(MethodInfo^.filename);
    Freemem(node.data,sizeof(TMethodInfo));
  end;
end;

procedure TFunctionListFrame.FunctionListLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Self.DragKind := dkDock;
  Self.BeginDrag(false, 40);
end;

procedure TFunctionListFrame.DockFormOnClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
  SimbaForm.MenuItemFunctionList.Checked := False;
end;

procedure TFunctionListFrame.CloseButtonClick(Sender: TObject);
begin
  self.Hide;
  SimbaForm.MenuItemFunctionList.Checked := False;
end;

procedure TFunctionListFrame.FunctionListMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   N: TTreeNode;
   MethodInfo : TMethodInfo;
begin
  if InCodeCompletion then
  begin;
    mDebugLn('Not yet implemented');
    exit;
  end;
  if not (Sender is TTreeView) then
    exit;
  N := TTreeView(Sender).GetNodeAt(x, y);
  if(N = nil)then
    exit;
end;

procedure TFunctionListFrame.FilterTreeVis(Vis: boolean);
begin
  FunctionList.Visible:= not Vis;
  FilterTree.Visible := Vis;
end;

function TFunctionListFrame.GetFilterTree: TTreeView;
begin
  Result := FFilterTree;
  if Assigned(Result) then
    exit;
  FFilterTree := TTreeView.Create(Self);
  FFilterTree.Parent := Self;
  FFilterTree.Visible := false;
  FFilterTree.SetBounds(FunctionList.Left,FunctionList.Top,FunctionList.Width,FunctionList.Height);
  FFilterTree.Align := alClient;
  FFilterTree.ReadOnly:= True;
  FFilterTree.ScrollBars:= ssAutoBoth;
  FFilterTree.OnMouseDown:= FunctionList.OnMouseDown;
  FFilterTree.OnMouseUp:= FunctionList.OnMouseUp;
  FFilterTree.OnChange:= FunctionList.OnChange;
  FFilterTree.OnExit := FunctionList.OnExit;
  FFilterTree.OnDblClick:= FunctionList.OnDblClick;
  Result := FFilterTree;
  //We do not want to delete the data from the FilterTree
//  FilterTree.OnDeletion:= FunctionList.OnDeletion;
end;

procedure TFunctionListFrame.LoadScriptTree(Script: String);
begin
  if script = '' then
    exit;
  if ScriptNode = nil then
    exit;
  if FillThread <> nil then {Already busy filling!}
    exit;
  if ((FLastScript = Script) and (FLastInterp = SimbaSettings.Interpreter._Type.Value)) then
    exit;
  if SimbaForm.CurrScript = nil then
    exit;
  FLastScript := Script;
  FLastInterp := SimbaSettings.Interpreter._Type.Value;
  Filtering := FilterTree.Visible;
  if FilterTree.Visible then
    FilterTreeVis(false);
  FunctionList.BeginUpdate;
  ScriptNode.DeleteChildren;
  FillThread := TFillThread.Create(true);
  FillThread.FunctionList := @Self.FunctionList;
  FillThread.Analyzer := TCodeInsight.Create;
  with FillThread,FillThread.Analyzer do
  begin
    OnFindInclude := @SimbaForm.OnCCFindInclude;
    OnLoadLibrary := @SimbaForm.OnCCLoadLibrary;
    FileName := SimbaForm.CurrScript.ScriptFile;
    MS := TMemoryStream.Create;
    MS.Write(Script[1],length(script));
    OnTerminate:=@FillThreadTerminate;
    FreeOnTerminate := True;
    FillThread.ScriptNode := self.ScriptNode;
    FillThread.IncludesNode := self.IncludesNode;
  end;
  FillThread.resume;
 //See FillThreadTerminate for the rest of this procedure
end;

function TFunctionListFrame.Find(Next : boolean; backwards : boolean = false) : boolean;
var
  Start,Len,i,ii,index,posi,c: Integer;
  FoundFunction : boolean;
  LastSection : Array[1..2] of String;
  str : string;
  RootNode : TTreeNode;
  NormalNode,tmpNode : TTreeNode;
  Node : TTreeNode;
  InsertStr : string;
begin
  if(editSearchList.Text = '')then
  begin
    editSearchList.Color := clWhite;
    FunctionList.FullCollapse;
    if InCodeCompletion then
    begin;
      SimbaForm.CurrScript.SynEdit.Lines[CompletionCaret.y - 1] := CompletionStart;
      SimbaForm.CurrScript.SynEdit.LogicalCaretXY:= point(CompletionCaret.x,CompletionCaret.y);
      SimbaForm.CurrScript.SynEdit.SelEnd:= SimbaForm.CurrScript.SynEdit.SelStart;
    end;
    FilterTreeVis(False);
    ScriptNode.Expand(true);
    exit;
  end;

  //We only have to search the next item in our filter tree.. Fu-king easy!
  if next then
  begin;
    if FilterTree.Visible = false then
    begin;
      mDebugLn('ERROR: You cannot search next, since the Tree isnt generated yet');
      Find(false);
      exit;
    end;
    if FilterTree.Selected <> nil then
    begin;
      if backwards then
        start := FilterTree.Selected.AbsoluteIndex  - 1
      else
        Start := FilterTree.Selected.AbsoluteIndex + 1;
    end
    else
    begin
      if backwards then
        Start := FilterTree.Items.Count - 1
      else
        Start := 0;
    end;
    Len := FilterTree.Items.Count;
    i := start + len; //This is for the backwards compatibily, we do mod anways.. it just makes sure -1 isn't negative.
    c := 0;
    while c < (len ) do
    begin;
      if (FilterTree.Items[i mod len].HasChildren = false) then
      begin
        FilterTree.Items[i mod len].Selected:= true;
        InsertStr := FilterTree.Items[i mod len].Text;
        Result := true;
        break;
      end;
      if backwards then
        dec(i)
      else
        inc(i);
      inc(c);
    end;
  end else
  begin
    FilterTree.BeginUpdate;
    FilterTree.Items.Clear;

    FoundFunction := False;
    if FunctionList.Selected <> nil then
      Start := FunctionList.Selected.AbsoluteIndex
    else
      Start := 0;
    Len := FunctionList.Items.Count;
    LastSection[1] := '';
    LastSection[2] := '';
    for i := start to start + FunctionList.Items.Count - 1 do
    begin;
      Node := FunctionList.Items[i mod FunctionList.Items.Count];
      if(Node.Level >= 1) and (node.HasChildren = false) then
        if(pos(lowercase(editSearchList.Text), lowercase(Node.Text)) > 0)then
        begin
          if not FoundFunction then
          begin
            FoundFunction := True;
            index := i mod FunctionList.Items.Count;
            InsertStr:= node.Text;
          end;
          if node.level = 2 then
          begin;
            if node.Parent.text <> lastsection[2] then
            begin
              if node.parent.parent.text <> lastsection[1] then
              begin;
                rootnode := FilterTree.Items.AddChild(nil,node.parent.parent.text);
                lastsection[1] := rootnode.text;
                rootnode := FilterTree.Items.AddChild(Rootnode,node.parent.text);
                lastsection[2] := rootnode.text;
              end else
              begin
                rootnode := FilterTree.Items.AddChild(rootnode.parent,node.parent.text);
                lastsection[2] := rootnode.text;
              end;
            end;
          end else
          begin
            if node.parent.text <> lastsection[1] then
            begin
              rootnode := FilterTree.Items.AddChild(nil,node.parent.text);
              lastsection[1] := Rootnode.text;
            end;
          end;
          FilterTree.Items.AddChild(RootNode,Node.Text).Data := Node.Data;
  //        break;
        end;
      end;
      Result := FoundFunction;

      if Result then
      begin;
        FilterTreeVis(True);
        FilterTree.FullExpand;
        c := 0;
        while FilterTree.Items[c].HasChildren do
          inc(c);
        FilterTree.Items[c].Selected:= True;
        mDebugLn(FunctionList.Items[Index].Text);
        FunctionList.FullCollapse;
        FunctionList.Items[Index].Selected := true;
        FunctionList.Items[index].ExpandParents;
        editSearchList.Color := clWhite;


      end else
      begin
        FilterTreeVis(false);
        editSearchList.Color := 6711039;
        if InCodeCompletion then
          SimbaForm.CurrScript.SynEdit.Lines[CompletionCaret.y - 1] := CompletionStart;
      end;
    FilterTree.EndUpdate;
  end;

  if result and InCodeCompletion then
    begin;
      str := format(CompletionLine, [InsertStr]);
      with SimbaForm.CurrScript.SynEdit do
      begin;
        Lines[CompletionCaret.y - 1] := str;
        LogicalCaretXY:= StartWordCompletion;
        i := SelStart;
        posi := pos(lowercase(editSearchList.text), lowercase(InsertStr)) + length(editSearchList.text) - 1; //underline the rest of the word
        if Posi = Length(InsertStr) then //Special occasions
        begin;
          if Length(editSearchList.Text) <> Posi then          //We found the last part of the text -> for exmaple when you Search for bitmap, you can find LoadBitmap -> We underline 'Load'
          begin;
            SelStart := i;
            SelEnd := i + pos(lowercase(editSearchList.text), lowercase(InsertStr)) -1;
            Exit;
          end;
          //We searched for the whole text -> for example LoadBitmap, and we found LoadBitmap -> Underline the whole text
          Posi := 0;
        end;
        //Underline the rest of the word
        SelStart := i + posi;
        SelEnd := SelStart + Length(InsertStr) - posi;
      end;
    end;
end;

procedure TFunctionListFrame.FunctionListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   N: TTreeNode;
begin
  if button = mbRight then
    exit;
  if InCodeCompletion then
  begin;
    mDebugLn('Not yet implemented');
    exit;
  end;
  if not (Sender is TTreeView) then
    exit;
  N := TTreeView(Sender).GetNodeAt(x, y);
  if(N = nil)then
  begin
    Self.DragKind := dkDock;
    Self.BeginDrag(false, 40);
    exit;
  end;
  Self.DragKind := dkDrag;
  if(Button = mbLeft) and (N.Level > 0)then
    Self.BeginDrag(False, 10);
  DraggingNode := N;
end;


{ TFillThread }

procedure TFillThread.execute;
var
   IncludesArr: TStringList;
  procedure AddProcsTree(Node : TTreeNode; Procs : TDeclarationList; Path : string);
  var
    i : integer;
    tmpNode : TTreeNode;
  begin;
    if procs = nil then
      exit;
    for i := 0 to Procs.Count - 1 do
      if (Procs[i] <> nil) and (Procs[i] is TciProcedureDeclaration) then
        with Procs[i] as TciProcedureDeclaration do
          if name <> nil then
          begin
            tmpNode := FunctionList^.Items.AddChild(Node,name.ShortText);
            tmpNode.Data := GetMem(SizeOf(TMethodInfo));
            FillChar(PMethodInfo(tmpNode.Data)^,SizeOf(TMethodInfo),0);
            with PMethodInfo(tmpNode.Data)^ do
            begin
              MethodStr := strnew(Pchar(CleanDeclaration));
              Filename:= strnew(pchar(path));
              BeginPos:= name.StartPos ;
              EndPos :=  name.StartPos + Length(TrimRight(name.RawText));
            end;
          end;
  end;

  procedure AddIncludes(ParentNode : TTreeNode; Include : TCodeInsight);
  var
    i : integer;
  begin;
    if (IncludesArr.IndexOf(ExpandFileName(Include.FileName)) < 0) then
    begin
      parentNode := FunctionList^.Items.AddChild(
                   IncludesNode,ExtractFileNameOnly(
                   Include.FileName));

      AddProcsTree(parentNode,Include.Items,Include.FileName);

      IncludesArr.Add(ExpandFileName(Include.FileName));
    end;

    for I := 0 to High(Include.Includes) do
      AddIncludes(ParentNode, Include.Includes[I]);
  end;
var
  i : integer;
begin
  Analyzer.Run(MS,nil,-1,true);
  AddProcsTree(ScriptNode,Analyzer.Items,Analyzer.FileName); //Add the procedures of the script to the script tree

  IncludesArr := TStringList.Create;
  IncludesArr.CaseSensitive := False;

  //Lame condition.. We must check if nothing new has been included since
  //last generation of the tree.. However, this will do fine for now ;)
  if IncludesNode.Count <> length(Analyzer.Includes) then
  begin;
    IncludesNode.DeleteChildren;
    for i := 0 to high(Analyzer.Includes) do
      AddIncludes(IncludesNode, Analyzer.Includes[i]);
  end;

  IncludesArr.Free;
end;

initialization
  {$R *.lfm}

end.

