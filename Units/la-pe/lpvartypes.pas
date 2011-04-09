{
	Author: Niels A.D
	Project: Lape (http://code.google.com/p/la-pe/)
	License: GNU Lesser GPL (http://www.gnu.org/licenses/lgpl.html)

	All (script)type and (script)variable classes, including corresponding evaluation functions (runtime/compile time).
}
unit lpvartypes;

{$I lape.inc}

interface

uses
  Classes, SysUtils,
  lptypes, lpparser, lpcodeemitter;

const
  Lape_OptionsDef = [];
  Lape_PackRecordsDef = 2;

type
  TLapeType = class;
  TLapeStackVar = class;
  TLapeGlobalVar = class;
  TLapeCompilerBase = class;

  TLapeBaseTypes = array[ELapeBaseType] of TLapeType;
  TLapeTypeArray = array of TLapeType;
  TLapeVarStack = {$IFDEF FPC}specialize{$ENDIF} TLapeList<TLapeStackVar>;

  TVarPos = record
    isPointer: Boolean;
    Offset: Integer;
    case MemPos: EMemoryPos of
      mpVar: (StackVar: TLapeStackVar);
      mpMem: (GlobalVar: TLapeGlobalVar);
      mpStack: (ForceVariable: Boolean);
  end;
  TResVar = record
    VarType: TLapeType;
    VarPos: TVarPos;
  end;

  ELapeParameterType = (lptNormal, lptConst, lptVar, lptOut);
  TLapeParameter = record
    ParType: ELapeParameterType;
    VarType: TLapeType;
    Default: TLapeGlobalVar;
  end;
  TLapeParameterList = {$IFDEF FPC}specialize{$ENDIF} TLapeList<TLapeParameter>;

  TLapeVar = class(TLapeDeclaration)
  protected
    FVarType: TLapeType;
    function getBaseType: ELapeBaseType; virtual;
    function getSize: Integer; virtual;
    function getInitialization: Boolean; virtual;
    function getFinalization: Boolean; virtual;
  public
    isConstant: Boolean;
    constructor Create(AVarType: TLapeType; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil); reintroduce; virtual;

    property VarType: TLapeType read FVarType;
    property BaseType: ELapeBaseType read getBaseType;
    property Size: Integer read getSize;
    property NeedInitialization: Boolean read getInitialization;
    property NeedFinalization: Boolean read getFinalization;
  end;

  TLapeStackVar = class(TLapeVar)
  protected
    FStack: TLapeVarStack;
    procedure setStack(Stack: TLapeVarStack); virtual;
    function getOffset: Integer; virtual;
  public
    constructor Create(AVarType: TLapeType; AStack: TLapeVarStack; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil); reintroduce; virtual;
    destructor Destroy; override;

    property Stack: TLapeVarStack read FStack write setStack;
    property Offset: Integer read getOffset;
  end;

  TLapeStackTempVar = class(TLapeStackVar)
  protected
    FLock: Integer;
    function getLocked: Boolean;
    procedure setLocked(DoLock: Boolean);
  public
    constructor Create(AVarType: TLapeType; AStack: TLapeVarStack; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil); override;
    function IncLock(Count: Integer = 1): Integer; virtual;
    function Declock(Count: Integer = 1): Integer; virtual;
    property Locked: Boolean read getLocked write setLocked;
  end;

  TLapeParameterVar = class(TLapeStackVar)
  protected
    FParType: ELapeParameterType;
    function getSize: Integer; override;
    function getInitialization: Boolean; override;
    function getFinalization: Boolean; override;
  public
    constructor Create(AParType: ELapeParameterType; AVarType: TLapeType; AStack: TLapeVarStack; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil); reintroduce; virtual;
    property ParType: ELapeParameterType read FParType;
  end;

  TLapeGlobalVar = class(TLapeVar)
  protected
    FBasePtr: Pointer;
    FPtr: Pointer;
    function getAsString: lpString; virtual;
    function getAsInt: Int64; virtual;
  public
    DoManage: Boolean;
    constructor Create(AVarType: TLapeType; Initialize: Boolean = True; ManagePtr: Boolean = True; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil); reintroduce; overload; virtual;
    constructor Create(AVarType: TLapeType; Ptr: Pointer; ManagePtr: Boolean = False; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil); reintroduce; overload; virtual;
    destructor Destroy; override;

    property Ptr: Pointer read FPtr;
    property AsString: lpString read getAsString;
    property AsInteger: Int64 read getAsInt;
  end;

  TLapeType = class(TLapeDeclaration)
  protected
    FBaseType: ELapeBaseType;
    FCompiler: TLapeCompilerBase;
    FSize: Integer;
    FInit: (__Unknown, __Yes, __No);
    FAsString: lpString;

    function getSize: Integer; virtual;
    function getBaseIntType: ELapeBaseType; virtual;
    function getInitialization: Boolean; virtual;
    function getFinalization: Boolean; virtual;
    function getAsString: lpString; virtual;
  public
    constructor Create(ABaseType: ELapeBaseType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; virtual;
    function Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean; reintroduce; virtual;
    function CompatibleWith(Other: TLapeType): Boolean; virtual;

    function VarToString(v: Pointer): lpString; virtual;
    function VarToInt(v: Pointer): Int64; virtual;

    function NewGlobalVarP(Ptr: Pointer = nil; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: AnsiString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; overload; virtual;
	{$IFNDEF Lape_NoWideString}
    function NewGlobalVarStr(Str: WideString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; overload; virtual;
	{$ENDIF}
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; overload; virtual; abstract;
    function NewGlobalVarTok(Parser: TLapeTokenizerBase; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;

    function CanHaveChild: Boolean; virtual;
    function HasChild(n: lpString): Boolean; virtual;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; overload; virtual;
    function EvalRes(Op: EOperator; Right: TLapeGlobalVar): TLapeType; overload; virtual;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; virtual;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; overload; virtual;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; Pos: PDocPos = nil): TResVar; overload; virtual;

    procedure Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil); overload; virtual;
    procedure Finalize(v: TResVar; UseCompiler: Boolean = True; Pos: PDocPos = nil); overload; virtual;
    procedure Finalize(v: TLapeVar; var Offset: Integer; UseCompiler: Boolean = False; Pos: PDocPos = nil); overload; virtual;
    procedure Finalize(v: TLapeVar; UseCompiler: Boolean = False; Pos: PDocPos = nil); overload; virtual;

    property BaseType: ELapeBaseType read FBaseType;
    property Compiler: TLapeCompilerBase read FCompiler;
    property Size: Integer read getSize;
    property BaseIntType: ELapeBaseType read getBaseIntType;
    property NeedInitialization: Boolean read getInitialization;
    property NeedFinalization: Boolean read getFinalization;
    property AsString: lpString read getAsString;
  end;

  TLapeType_Type = class(TLapeType)
  protected
    FTType: TLapeType;
    function getAsString: lpString; override;
  public
    constructor Create(AType: TLapeType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;

    property TType: TLapeType read FTType;
  end;

  {$IFDEF FPC}generic{$ENDIF} TLapeType_Integer<_Type> = class(TLapeType)
  protected type
    PType = ^_Type;
  var public
    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Val: _Type; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
  end;

  {$IFDEF FPC}generic{$ENDIF} TLapeType_Float<_Type> = class(TLapeType)
  protected type
    PType = ^_Type;
  var public
    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Val: _Type; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
  end;

  {$IFDEF FPC}generic{$ENDIF} TLapeType_Char<_Type> = class(TLapeType)
  protected type
    PType = ^_Type;
  var public
    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Val: _Type; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
  end;

  TLapeType_UInt8 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<UInt8>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Int8 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<Int8>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_UInt16 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<UInt16>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Int16 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<Int16>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_UInt32 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<UInt32>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Int32 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<Int32>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_UInt64 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<UInt64>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Int64 = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Integer<Int64>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_Single = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Float<Single>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Double = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Float<Double>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Currency = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Float<Currency>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_Extended = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Float<Extended>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_AnsiChar = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Char<AnsiChar>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_WideChar = class({$IFDEF FPC}specialize{$ENDIF} TLapeType_Char<WideChar>)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_Variant = class(TLapeType)
  public
    constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function VarToString(v: Pointer): lpString; override;

    function NewGlobalVar(Val: Variant; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
  end;

  TLapeType_SubRange = class(TLapeType)
  protected
    FRange: TLapeRange;
    FVarType: TLapeType;
    function getAsString: lpString; override;
  public
    constructor Create(ARange: TLapeRange; ACompiler: TLapeCompilerBase; AVarType: TLapeType; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;

    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Value: Int64 = 0; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;

    property Range: TLapeRange read FRange;
    property VarType: TLapeType read FVarType;
  end;

  TEnumMap = TStringList;
  TLapeType_Enum = class(TLapeType_SubRange)
  protected
    FMemberMap: TEnumMap;
    FSmall: Boolean;
    function getAsString: lpString; override;
  public
    FreeMemberMap: Boolean;
    constructor Create(ACompiler: TLapeCompilerBase; AMemberMap: TEnumMap; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;
    destructor Destroy; override;

    function addMember(Value: Int16; AName: lpString): Int16; overload; virtual;
    function addMember(AName: lpString): Int16; overload; virtual;

    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Value: Int64 = 0; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;

    property MemberMap: TEnumMap read FMemberMap;
    property Small: Boolean read FSmall;
  end;

  TLapeType_Boolean = class(TLapeType_Enum)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_Bool = class(TLapeType_SubRange)
  public
    constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;
    destructor Destroy; override;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;
  end;

  TLapeType_ByteBool = class(TLapeType_Bool)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_WordBool = class(TLapeType_Bool)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_LongBool = class(TLapeType_Bool)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  {$IFDEF Lape_SmallCode}
  TLapeType_EvalBool = TLapeType_Boolean;
  {$ELSE}
  TLapeType_EvalBool = TLapeType_LongBool;
  {$ENDIF}

  TLapeType_Set = class(TLapeType)
  protected
    FRange: TLapeType_SubRange;
    FSmall: Boolean;
    function getAsString: lpString; override;
  public
    constructor Create(ARange: TLapeType_SubRange; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;

    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Values: array of UInt8; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;
    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;

    property Range: TLapeType_SubRange read FRange;
    property Small: Boolean read FSmall;
  end;

  TLapeType_Pointer = class(TLapeType)
  protected
    FPType: TLapeType;
    function getAsString: lpString; override;
  public
    constructor Create(ACompiler: TLapeCompilerBase; PointerType: TLapeType = nil; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;
    function Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean; override;

    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(Ptr: Pointer = nil; AName: lpString = ''; ADocPos: PDocPos = nil; AsValue: Boolean = True): TLapeGlobalVar; virtual;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;

    function HasType: Boolean;
    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;

    property PType: TLapeType read FPType;
  end;

  TLapeType_DynArray = class(TLapeType_Pointer)
  protected
    function getAsString: lpString; override;
  public
    constructor Create(ArrayType: TLapeType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;
    function VarToString(v: Pointer): lpString; override;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;
    procedure Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil); override;
  end;

  TLapeType_StaticArray = class(TLapeType_DynArray)
  protected
    FRange: TLapeRange;

    function getSize: Integer; override;
    function getAsString: lpString; override;
  public
    constructor Create(ARange: TLapeRange; ArrayType: TLapeType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;

    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; reintroduce; virtual;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;
    procedure Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil); override;

    property Range: TLapeRange read FRange;
  end;

  TLapeType_String = class(TLapeType_DynArray)
  public
    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVarStr(Str: AnsiString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
    function NewGlobalVar(Str: AnsiString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; reintroduce; overload; virtual;
  {$IFNDEF Lape_NoWideString}
    function NewGlobalVarStr(Str: WideString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
    function NewGlobalVar(Str: WideString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; reintroduce; overload; virtual;
  {$ENDIF}
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
    function NewGlobalVar(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; reintroduce; overload; virtual;

    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;
  end;

  TLapeType_AnsiString = class(TLapeType_String)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_WideString = class(TLapeType_String)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;
  TLapeType_UnicodeString = class(TLapeType_String)
    public constructor Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual; end;

  TLapeType_ShortString = class(TLapeType_StaticArray)
  protected
    function getAsString: lpString; override;
  public
    constructor Create(ACompiler: TLapeCompilerBase; ASize: UInt8 = High(UInt8); AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;

    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; override;
    function NewGlobalVar(Str: ShortString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; reintroduce; overload; virtual;

    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;
  end;

  TRecordField = record
    Offset: Word;
    FieldType: TLapeType;
  end;
  TRecordFieldMap = {$IFDEF FPC}specialize{$ENDIF} TLapeStringMap<TRecordField>;

  TLapeType_Record = class(TLapeType)
  protected
    FFieldMap: TRecordFieldMap;
    function getAsString: lpString; override;
  public
    FreeFieldMap: Boolean;
    constructor Create(ACompiler: TLapeCompilerBase; AFieldMap: TRecordFieldMap; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;
    destructor Destroy; override;
    function Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean; override;

    procedure addField(FieldType: TLapeType; AName: lpString; Alignment: Byte = 1); virtual;
    function VarToString(v: Pointer): lpString; override;
    function NewGlobalVar(AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalRes(Op: EOperator; Right: TLapeGlobalVar): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;
    procedure Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil); override;

    property FieldMap: TRecordFieldMap read FFieldMap;
  end;

  TLapeType_Union = class(TLapeType_Record)
  protected
    function getAsString: lpString; override;
  public
    constructor Create(ACompiler: TLapeCompilerBase; AFieldMap: TRecordFieldMap; AName: lpString = ''; ADocPos: PDocPos = nil); override;
    procedure addField(FieldType: TLapeType; AName: lpString; Alignment: Byte = 1); override;
  end;

  TLapeType_Method = class(TLapeType)
  protected
    FParams: TLapeParameterList;
    function getSize: Integer; override;
    function getAsString: lpString; override;
    function getParamSize: Integer; virtual;
    function getParamInitialization: Boolean; virtual;
  public
    FreeParams: Boolean;
    Res: TLapeType;

    constructor Create(ACompiler: TLapeCompilerBase; AParams: TLapeParameterList; ARes: TLapeType = nil; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; overload; virtual;
    constructor Create(ACompiler: TLapeCompilerBase; AParams: array of TLapeType; AParTypes: array of ELapeParameterType; AParDefaults: array of TLapeGlobalVar; ARes: TLapeType = nil; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; overload; virtual;
    function CreateCopy: TLapeType; override;
    destructor Destroy; override;
    function Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean; override;

    procedure addParam(p: TLapeParameter); virtual;
    procedure setImported(v: TLapeGlobalVar; isImported: Boolean); virtual;
    function NewGlobalVar(Ptr: Pointer = nil; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; overload; virtual;
    function NewGlobalVar(CodePos: TCodePos; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; overload; virtual;

    function EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType; override;
    function EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar; override;
    function Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar; override;

    property Params: TLapeParameterList read FParams;
    property ParamSize: Integer read getParamSize;
    property ParamInitialization: Boolean read getParamInitialization;
  end;

  TLapeType_OverloadedMethod = class(TLapeType)
  protected
    FMethods: TLapeDeclarationList;
  public
    FreeMethods: Boolean;
    constructor Create(ACompiler: TLapeCompilerBase; AMethods: TLapeDeclarationList; AName: lpString = ''; ADocPos: PDocPos = nil); reintroduce; virtual;
    function CreateCopy: TLapeType; override;
    destructor Destroy; override;

    procedure addMethod(AMethod: TLapeGlobalVar); virtual;
    function getMethod(AType: TLapeType_Method): TLapeGlobalVar; overload; virtual;
    function getMethod(AParams: TLapeTypeArray; AResult: TLapeType = nil): TLapeGlobalVar; overload; virtual;
    function NewGlobalVar(AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar; virtual;

    property Methods: TLapeDeclarationList read FMethods;
  end;

  TLapeWithList = {$IFDEF FPC}specialize{$ENDIF} TLapeList<TLapeType>;
  TLapeStackInfo = class(TLapeBaseClass)
  protected
    FDeclarations: TLapeDeclCollection;
    FVarStack: TLapeVarStack;

    function getVar(Index: Integer): TLapeStackVar; virtual;
    function getCount: Integer; virtual;
    function getTotalSize: Integer; virtual;
    function getTotalParamSize: Integer; virtual;
    function getTotalNoParamSize: Integer; virtual;
    function getInitialization: Boolean; virtual;
    function getFinalization: Boolean; virtual;
  public
    Owner: TLapeStackInfo;
    FreeVars: Boolean;
    CodePos: Integer;

    constructor Create(AOwner: TLapeStackInfo = nil; ManageVars: Boolean = True); reintroduce; virtual;
    destructor Destroy; override;

    function getDeclaration(Name: lpString): TLapeDeclaration; virtual;
    function hasDeclaration(Name: lpString): Boolean; virtual;
    function getTempVar(VarType: TLapeType; Lock: Integer = 1): TLapeStackTempVar; virtual;
    function addDeclaration(Decl: TLapeDeclaration): Integer; virtual;
    function addVar(StackVar: TLapeStackVar): TLapeStackVar; overload; virtual;
    function addVar(VarType: TLapeType; Name: lpString = ''): TLapeStackVar; overload; virtual;
    function addVar(ParType: ELapeParameterType; VarType: TLapeType; Name: lpString = ''): TLapeStackVar; overload; virtual;

    property Declarations: TLapeDeclCollection read FDeclarations;
    property VarStack: TLapeVarStack read FVarStack;
    property Vars[Index: Integer]: TLapeStackVar read getVar; default;
    property Count: Integer read getCount;
    property TotalSize: Integer read getTotalSize;
    property TotalParamSize: Integer read getTotalParamSize;
    property TotalNoParamSize: Integer read getTotalNoParamSize;
    property NeedInitialization: Boolean read getInitialization;
    property NeedFinalization: Boolean read getFinalization;
  end;

  TLapeCodeEmitter = class(TLapeCodeEmitterBase)
  public
    function _IncCall(ACodePos: TResVar; AParamSize: UInt16; var Offset: Integer; Pos: PDocPos = nil): Integer; overload;
    function _IncCall(ACodePos: TResVar; AParamSize: UInt16; Pos: PDocPos = nil): Integer; overload;

    function _InvokeImportedProc(AMemPos: TResVar; AParamSize: UInt16; var Offset: Integer; Pos: PDocPos = nil): Integer; overload;
    function _InvokeImportedProc(AMemPos: TResVar; AParamSize: UInt16; Pos: PDocPos = nil): Integer; overload;
    function _InvokeImportedFunc(AMemPos, AResPos: TResVar; AParamSize: UInt16; var Offset: Integer; Pos: PDocPos = nil): Integer; overload;
    function _InvokeImportedFunc(AMemPos, AResPos: TResVar; AParamSize: UInt16; Pos: PDocPos = nil): Integer; overload;

    //function _JmpIf(Target: TCodePos; Cond: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer; overload; virtual;
    //function _JmpIf(Target: TCodePos; Cond: TResVar; Pos: PDocPos = nil): Integer; overload; virtual;
    function _JmpRIf(Jmp: TCodeOffset; Cond: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer; overload; virtual;
    function _JmpRIf(Jmp: TCodeOffset; Cond: TResVar; Pos: PDocPos = nil): Integer; overload; virtual;
    function _JmpRIfNot(Jmp: TCodeOffset; Cond: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer; overload; virtual;
    function _JmpRIfNot(Jmp: TCodeOffset; Cond: TResVar; Pos: PDocPos = nil): Integer; overload; virtual;

    function _Eval(AProc: TLapeEvalProc; Dest, Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer; overload; virtual;
    function _Eval(AProc: TLapeEvalProc; Dest, Left, Right: TResVar; Pos: PDocPos = nil): Integer; overload; virtual;
  end;

  ECompilerOption = (lcoAssertions, lcoShortCircuit);
  ECompilerOptionsSet = set of ECompilerOption;

  TLapeCompilerBase = class(TLapeBaseClass)
  protected
    FEmitter: TLapeCodeEmitter;
    FStackInfo: TLapeStackInfo;
    FBaseTypes: TLapeBaseTypes;
    FGlobalDeclarations: TLapeDeclarationList;
    FManagedDeclarations: TLapeDeclarationList;

    FOptions: ECompilerOptionsSet;
    FOptions_PackRecords: UInt8;

    procedure Reset; virtual;
    procedure setEmitter(AEmitter: TLapeCodeEmitter); virtual;
  public
    FreeEmitter: Boolean;

    constructor Create(AEmitter: TLapeCodeEmitter = nil; ManageEmitter: Boolean = True); reintroduce; virtual;
    destructor Destroy; override;
    procedure Clear; virtual;

    function IncStackInfo(AStackInfo: TLapeStackInfo; var Offset: Integer; Emit: Boolean = True; Pos: PDocPos = nil): TLapeStackInfo; overload; virtual;
    function IncStackInfo(Emit: Boolean = False): TLapeStackInfo; overload; virtual;
    function DecStackInfo(var Offset: Integer; InFunction: Boolean = False; Emit: Boolean = True; DoFree: Boolean = False; Pos: PDocPos = nil): TLapeStackInfo; overload; virtual;
    function DecStackInfo(InFunction: Boolean = False; Emit: Boolean = False; DoFree: Boolean = False): TLapeStackInfo; overload; virtual;

    function getBaseType(Name: lpString): TLapeType; overload; virtual;
    function getBaseType(t: ELapeBaseType): TLapeType; overload; virtual;
    function addLocalDecl(v: TLapeDeclaration; AStackInfo: TLapeStackInfo): TLapeDeclaration; overload; virtual;
    function addLocalDecl(v: TLapeDeclaration): TLapeDeclaration; overload; virtual;
    function addGlobalDecl(v: TLapeDeclaration): TLapeDeclaration; virtual;
    function addManagedDecl(v: TLapeDeclaration): TLapeDeclaration; virtual;
    function addManagedVar(v: TLapeVar): TLapeVar; virtual;
    function addManagedType(v: TLapeType): TLapeType; virtual;
    function addStackVar(VarType: TLapeType; Name: lpString): TLapeStackVar; virtual;
    function getTempVar(VarType: ELapeBaseType; Lock: Integer = 1): TLapeStackTempVar; overload; virtual;
    function getTempVar(VarType: TLapeType; Lock: Integer = 1): TLapeStackTempVar; overload; virtual;
    function getTempStackVar(VarType: ELapeBaseType): TResVar; overload; virtual;
    function getTempStackVar(VarType: TLapeType): TResVar; overload; virtual;
    function getPointerType(PType: ELapeBaseType): TLapeType_Pointer; overload; virtual;
    function getPointerType(PType: TLapeType): TLapeType_Pointer; overload; virtual;
    function getDeclaration(Name: lpString; AStackInfo: TLapeStackInfo; LocalOnly: Boolean = False): TLapeDeclaration; overload; virtual;
    function getDeclaration(Name: lpString; LocalOnly: Boolean = False): TLapeDeclaration; overload; virtual;
    function hasDeclaration(Name: lpString; AStackInfo: TLapeStackInfo; LocalOnly: Boolean = False): Boolean; overload; virtual;
    function hasDeclaration(Name: lpString; LocalOnly: Boolean = False): Boolean; overload; virtual;

    property StackInfo: TLapeStackInfo read FStackInfo;
    property BaseTypes: TLapeBaseTypes read FBaseTypes;
    property GlobalDeclarations: TLapeDeclarationList read FGlobalDeclarations;
    property ManagedDeclarations: TLapeDeclarationList read FManagedDeclarations;
  published
    property Emitter: TLapeCodeEmitter read FEmitter write setEmitter;
    property Options: ECompilerOptionsSet read FOptions write FOptions default Lape_OptionsDef;
    property Options_PackRecords: UInt8 read FOptions_PackRecords write FOptions_PackRecords default Lape_PackRecordsDef;
  end;

procedure ClearBaseTypes(var Arr: TLapeBaseTypes);
procedure LoadBaseTypes(var Arr: TLapeBaseTypes; Compiler: TLapeCompilerBase);
procedure setNullResVar(var v: TResVar; Unlock: Integer = 0); {$IFDEF Lape_Inline}inline;{$ENDIF}
function getResVar(v: TLapeVar): TResVar; {$IFDEF Lape_Inline}inline;{$ENDIF}
procedure getDestVar(var Dest, Res: TResVar; Op: EOperator; Compiler: TLapeCompilerBase); {$IFDEF Lape_Inline}inline;{$ENDIF}
function isVariable(v: TResVar): Boolean; {$IFDEF Lape_Inline}inline;{$ENDIF}

const
  NullResVar: TResVar = (VarType: nil; VarPos: (isPointer: False; Offset: 0; MemPos: mpNone;  GlobalVar: nil));
  VarResVar:  TResVar = (VarType: nil; VarPos: (isPointer: False; Offset: 0; MemPos: mpVar;   StackVar : nil));
  StackResVar:TResVar = (VarType: nil; VarPos: (isPointer: False; Offset: 0; MemPos: mpStack; ForceVariable: False));

  Lape_RefParams = [lptOut, lptVar];

implementation

uses
  Variants,
  lpeval, lpexceptions, lpinterpreter;

procedure ClearBaseTypes(var Arr: TLapeBaseTypes);
var
  t: ELapeBaseType;
begin
  for t := Low(ELapeBaseType) to High(ELapeBaseType) do
    if (Arr[t] <> nil) then
      FreeAndNil(Arr[t]);
end;

procedure LoadBaseTypes(var Arr: TLapeBaseTypes; Compiler: TLapeCompilerBase);
begin
  Arr[ltUInt8] := TLapeType_UInt8.Create(Compiler, LapeTypeToString(ltUInt8));
  Arr[ltInt8] := TLapeType_Int8.Create(Compiler, LapeTypeToString(ltInt8));
  Arr[ltUInt16] := TLapeType_UInt16.Create(Compiler, LapeTypeToString(ltUInt16));
  Arr[ltInt16] := TLapeType_Int16.Create(Compiler, LapeTypeToString(ltInt16));
  Arr[ltUInt32] := TLapeType_UInt32.Create(Compiler, LapeTypeToString(ltUInt32));
  Arr[ltInt32] := TLapeType_Int32.Create(Compiler, LapeTypeToString(ltInt32));
  Arr[ltUInt64] := TLapeType_UInt64.Create(Compiler, LapeTypeToString(ltUInt64));
  Arr[ltInt64] := TLapeType_Int64.Create(Compiler, LapeTypeToString(ltInt64));
  Arr[ltSingle] := TLapeType_Single.Create(Compiler, LapeTypeToString(ltSingle));
  Arr[ltDouble] := TLapeType_Double.Create(Compiler, LapeTypeToString(ltDouble));
  Arr[ltCurrency] := TLapeType_Currency.Create(Compiler, LapeTypeToString(ltCurrency));
  Arr[ltExtended] := TLapeType_Extended.Create(Compiler, LapeTypeToString(ltExtended));
  Arr[ltBoolean] := TLapeType_Boolean.Create(Compiler, LapeTypeToString(ltBoolean));
  Arr[ltByteBool] := TLapeType_ByteBool.Create(Compiler, LapeTypeToString(ltByteBool));
  Arr[ltWordBool] := TLapeType_WordBool.Create(Compiler, LapeTypeToString(ltWordBool));
  Arr[ltLongBool] := TLapeType_LongBool.Create(Compiler, LapeTypeToString(ltLongBool));
  Arr[ltAnsiChar] := TLapeType_AnsiChar.Create(Compiler, LapeTypeToString(ltAnsiChar));
  Arr[ltWideChar] := TLapeType_WideChar.Create(Compiler, LapeTypeToString(ltWideChar));
  Arr[ltShortString] := TLapeType_ShortString.Create(Compiler, High(UInt8), LapeTypeToString(ltShortString));
  Arr[ltAnsiString] := TLapeType_AnsiString.Create(Compiler, LapeTypeToString(ltAnsiString));
  Arr[ltWideString] := TLapeType_WideString.Create(Compiler, LapeTypeToString(ltWideString));
  Arr[ltUnicodeString] := TLapeType_UnicodeString.Create(Compiler, LapeTypeToString(ltUnicodeString));
  Arr[ltVariant] := TLapeType_Variant.Create(Compiler, LapeTypeToString(ltVariant));
  Arr[ltPointer] := TLapeType_Pointer.Create(Compiler, nil, LapeTypeToString(ltPointer));
end;

procedure setNullResVar(var v: TResVar; Unlock: Integer = 0);
begin
  if (Unlock > 0) and (v.VarPos.MemPos = mpVar) and (v.VarPos.StackVar <> nil) and (v.VarPos.StackVar is TLapeStackTempVar) then
    TLapeStackTempVar(v.VarPos.StackVar).DecLock(Unlock);
  v := NullResVar;
end;

function getResVar(v: TLapeVar): TResVar;
begin
  Result := NullResVar;
  if (v <> nil) then
  begin
    Result.VarType := v.VarType;
    if (v is TLapeStackVar) then
    begin
      Result.VarPos.MemPos := mpVar;
      Result.VarPos.StackVar := v as TLapeStackVar;
    end
    else if (v is TLapeGlobalVar) then
    begin
      Result.VarPos.MemPos := mpMem;
      Result.VarPos.GlobalVar := v as TLapeGlobalVar;
    end;
    if (v is TLapeParameterVar) then
      Result.VarPos.isPointer := (TLapeParameterVar(v).ParType in Lape_RefParams);
  end;
end;

procedure getDestVar(var Dest, Res: TResVar; Op: EOperator; Compiler: TLapeCompilerBase);
begin
  if (op = op_Assign) then
    setNullResVar(Dest)
  else if (op <> op_Deref) and (Dest.VarPos.MemPos <> mpNone) and ({(Dest.VarType = nil) or} ((Res.VarType <> nil) and Res.VarType.Equals(Dest.VarType))) then
    Res := Dest
  else
  begin
    if (Res.VarType = nil) or ((op <> op_Deref) and (((Dest.VarPos.MemPos = mpStack) and (Dest.VarType = nil)) or ((Res.VarType.BaseType in LapeStackTypes) and ((Dest.VarPos.MemPos <> mpVar) or (Dest.VarType <> nil))))) then
      Res.VarPos.MemPos := mpStack
    else
      with Res, VarPos do
      begin
        MemPos := mpVar;
        if (op = op_Deref) then
          StackVar := Compiler.getTempVar(ltPointer)
        else
          StackVar := Compiler.getTempVar(Res.VarType);
      end;
    setNullResVar(Dest);
  end;
end;

function isVariable(v: TResVar): Boolean;
begin
  Result := ((v.VarPos.MemPos = mpStack) and (v.VarPos.isPointer or v.VarPos.ForceVariable)) or
    ((v.VarPos.MemPos = mpMem) and (v.VarPos.GlobalVar <> nil) and (not v.VarPos.GlobalVar.isConstant)) or
    ((v.VarPos.MemPos = mpVar) and (v.VarPos.StackVar <> nil) and (not v.VarPos.StackVar.isConstant));
end;

function TLapeVar.getBaseType: ELapeBaseType;
begin
  Result := FVarType.BaseType;
end;

function TLapeVar.getSize: Integer;
begin
  Result := FVarType.Size;
end;

function TLapeVar.getInitialization: Boolean;
begin
  Result := FVarType.NeedInitialization;
end;

function TLapeVar.getFinalization: Boolean;
begin
  Result := FVarType.NeedFinalization;
end;

constructor TLapeVar.Create(AVarType: TLapeType; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil);
begin
  Assert(AVarType <> nil);
  inherited Create(AName, ADocPos, AList);

  isConstant := (AName = '');
  FVarType := AVarType;
end;

procedure TLapeStackVar.setStack(Stack: TLapeVarStack);
begin
  if (Stack <> FStack) then
  begin
    if (FStack <> nil) then
      FStack.DeleteItem(Self);
    FStack := Stack;
    if (FStack <> nil) and (FStack.IndexOf(Self) < 0) then
      FStack.add(Self);
  end;
end;

function TLapeStackVar.getOffset: Integer;
var
  i: Integer;
begin
  Result := 0;
  if (FStack = nil) then
    Exit;
  for i := 0 to FStack.Count - 1 do
    if (FStack[i] = Self) then
      Exit
    else
      Result := Result + FStack[i].Size;
  Result := -1;
end;

constructor TLapeStackVar.Create(AVarType: TLapeType; AStack: TLapeVarStack; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil);
begin
  inherited Create(AVarType, AName, ADocPos, AList);
  setStack(AStack);
end;

destructor TLapeStackVar.Destroy;
begin
  setStack(nil);
  inherited;
end;

constructor TLapeStackTempVar.Create(AVarType: TLapeType; AStack: TLapeVarStack; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil);
begin
  inherited;
  FLock := 0;
  isConstant := True;
end;

function TLapeStackTempVar.getLocked: Boolean;
begin
  Result := (FLock > 0);
end;

procedure TLapeStackTempVar.setLocked(DoLock: Boolean);
begin
  if DoLock then
    FLock := 1
  else
    FLock := 0;
end;

function TLapeStackTempVar.IncLock(Count: Integer = 1): Integer;
begin
  Inc(FLock, Count);
  Result := FLock;
end;

function TLapeStackTempVar.DecLock(Count: Integer = 1): Integer;
begin
  Dec(FLock, Count);
  if (FLock < 0) then
    FLock := 0;
  Result := FLock;
end;

function TLapeParameterVar.getSize: Integer;
begin
  if (FParType in Lape_RefParams) then
    Result := SizeOf(Pointer)
  else
    Result := inherited;
end;

function TLapeParameterVar.getInitialization: Boolean;
begin
  Result := False;
end;

function TLapeParameterVar.getFinalization: Boolean;
begin
  Result := (not (FParType in Lape_RefParams)) and inherited;
end;

constructor TLapeParameterVar.Create(AParType: ELapeParameterType; AVarType: TLapeType; AStack: TLapeVarStack; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil);
begin
  inherited Create(AVarType, AStack, AName, ADocPos, AList);
  FParType := AParType;
  isConstant := (FParType = lptConst);
end;

function TLapeGlobalVar.getAsString: lpString;
begin
  if (FPtr <> nil) and (FVarType <> nil) then
    Result := FVarType.VarToString(FPtr)
  else
    Result := Name;
end;

function TLapeGlobalVar.getAsInt: Int64;
begin
  if (FPtr <> nil) and (FVarType <> nil) then
    Result := FVarType.VarToInt(FPtr)
  else
    Result := -1;
end;

constructor TLapeGlobalVar.Create(AVarType: TLapeType; Initialize: Boolean = True; ManagePtr: Boolean = True; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil);
begin
  inherited Create(AVarType, AName, ADocPos, AList);

  FBasePtr := nil;
  FPtr := nil;
  DoManage := ManagePtr;

  if Initialize and (FVarType.Size > 0) then
  begin
    {$IFDEF Lape_SmallCode}
    //getMem(FPtr, FVarType.Size);
    getMem(FBasePtr, FVarType.Size + 4);
    FPtr := {$IFDEF FPC}Align(FBasePtr, 4){$ELSE}Pointer(PtrUInt(FBasePtr) + PtrUInt(FBasePtr) mod 4){$ENDIF};
    {$ELSE}
    //Assure aligned memory
    getMem(FBasePtr, FVarType.Size + 16);
    FPtr := {$IFDEF FPC}Align(FBasePtr, 16){$ELSE}Pointer(PtrUInt(FBasePtr) + PtrUInt(FBasePtr) mod 16){$ENDIF};
    {$ENDIF}
    FillChar(FPtr^, FVarType.Size, 0);
  end;
end;

constructor TLapeGlobalVar.Create(AVarType: TLapeType; Ptr: Pointer; ManagePtr: Boolean = False; AName: lpString = ''; ADocPos: PDocPos = nil; AList: TLapeDeclarationList = nil);
begin
  Create(AVarType, False, ManagePtr, AName, ADocPos, AList);
  FPtr := Ptr;
end;

destructor TLapeGlobalVar.Destroy;
begin
  if (FPtr <> nil) and DoManage then
  begin
    if (FVarType <> nil) then
      FVarType.Finalize(Self, False);

    if (FBasePtr <> nil) then
      FreeMem(FBaseptr)
    else
      FreeMem(FPtr);
  end;

  inherited;
end;

function TLapeType.getSize: Integer;
begin
  if (FSize = 0) then
  begin
    FSize := LapeTypeSize[FBaseType];
    if (FSize = 0) then
      FSize := -1;
  end;
  Result := FSize;
end;

function TLapeType.getBaseIntType: ELapeBaseType;
begin
  if (not (FBaseType in LapeOrdinalTypes + [ltPointer])) then
    Result := ltUnknown
  else if (FBaseType in LapeIntegerTypes) then
    Result := FBaseType
  else case Size of
    1: Result := ltUInt8;
    2: Result := ltUInt16;
    4: Result := ltUInt32;
    8: Result := ltUInt64;
    else LapeException(lpeImpossible);
  end;
end;

function TLapeType.getInitialization: Boolean;
begin
  if (FInit = __Unknown) then
    if (FBaseType in LapeNoInitTypes) then
      FInit := __No
    else
      FInit := __Yes;
  Result := (FInit = __Yes) and (Size > 0);
end;

function TLapeType.getFinalization: Boolean;
begin
  Result := (not (FBaseType in LapeSetTypes)) and NeedInitialization;
end;

function TLapeType.getAsString: lpString;
begin
  if (FAsString = '') then
    FAsString := LapeTypeToString(BaseType);
  Result := FAsString;
end;

constructor TLapeType.Create(ABaseType: ELapeBaseType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(AName, ADocPos);

  FBaseType := ABaseType;
  FCompiler := ACompiler;
  FSize := 0;
  FInit := __Unknown;
  FAsString := '';
end;

function TLapeType.VarToString(v: Pointer): lpString;
begin
  Result := AsString;
end;

function TLapeType.VarToInt(v: Pointer): Int64;
begin
  if (v = nil) then
    Result := 0
  else
    case BaseIntType of
      ltInt8: Result := PInt8(v)^;
      ltUInt8: Result := PUInt8(v)^;
      ltInt16: Result := PInt16(v)^;
      ltUInt16: Result := PUInt16(v)^;
      ltInt32: Result := PInt32(v)^;
      ltUInt32: Result := PUInt32(v)^;
      ltInt64: Result := PInt64(v)^;
      ltUInt64: Result := PUInt64(v)^;
      else Result := -1;
    end;
end;

function TLapeType.Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean;
begin
  Result := (Other = Self) or (
    (Other <> nil) and
    (Other.BaseType = BaseType) and
    (Other.Size = Size) and
    (Other.AsString = AsString)
  );
end;

function TLapeType.CompatibleWith(Other: TLapeType): Boolean;
begin
  Result := (EvalRes(op_Assign, Other) <> nil);
end;

function TLapeType.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType;
begin
  Result := TLapeClassType(Self.ClassType).Create(FBaseType, FCompiler, Name, @DocPos);
end;

function TLapeType.NewGlobalVarP(Ptr: Pointer = nil; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  if (Ptr = nil) then
    Result := TLapeGlobalVar.Create(Self, True, True, AName, ADocPos)
  else
    Result := TLapeGlobalVar.Create(Self, Ptr, False, AName, ADocPos);
end;

function TLapeType.NewGlobalVarStr(Str: AnsiString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarStr(UnicodeString(Str), AName, ADocPos);
end;

{$IFNDEF Lape_NoWideString}
function TLapeType.NewGlobalVarStr(Str: WideString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarStr(UnicodeString(Str), AName, ADocPos);
end;
{$ENDIF}

function TLapeType.NewGlobalVarTok(Parser: TLapeTokenizerBase; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarStr(Parser.TokString, AName, ADocPos);
end;

function TLapeType.CanHaveChild: Boolean;
begin
  Result := FBaseType in LapeStructTypes;
end;

function TLapeType.HasChild(n: lpString): Boolean;
var
  s: TLapeGlobalVar;
begin
  if (not CanHaveChild()) or (FCompiler = nil) then
    Exit(False);
  s := FCompiler.getBaseType(ltString).NewGlobalVarStr(n);
  try
    Result := EvalRes(op_Dot, s) <> nil;
  finally
    s.Free();
  end;
end;

function TLapeType.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  Assert(FCompiler <> nil);

  if (Op = op_Addr) then
    Result := FCompiler.getPointerType(Self)
  else if (Op = op_Assign) and (Right <> nil) and (getEvalRes(Op, FBaseType, Right.BaseType) <> ltUnknown) then
    Result := Self
  else if (Right = nil) then
    Result := FCompiler.getBaseType(getEvalRes(Op, FBaseType, ltUnknown))
  else
    Result := FCompiler.getBaseType(getEvalRes(Op, FBaseType, Right.BaseType));
end;

function TLapeType.EvalRes(Op: EOperator; Right: TLapeGlobalVar): TLapeType;
begin
  if (Right <> nil) then
    Result := EvalRes(Op, Right.VarType)
  else
    Result := EvalRes(Op, TLapeType(nil));
end;

function TLapeType.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  p: TLapeEvalProc;
  t: TLapeType;

  function TryCast(DoRight: Boolean; out Res: TLapeGlobalVar): Boolean;
  var
    a: TLapeGlobalVar;
  begin
    if Left.VarType.Equals(Right.VarType) or
       (DoRight and (not Left.VarType.CompatibleWith(Right.VarType))) or
       ((not DoRight) and (not Right.VarType.CompatibleWith(Left.VarType)))
    then
      Exit(False);

    try
      if DoRight then
        a := Left.VarType.NewGlobalVarP()
      else
        a := Right.VarType.NewGlobalVarP();
      try
        if DoRight then
          Res := a.VarType.EvalConst(op, Left, a.VarType.EvalConst(op_Assign, a, Right))
        else
          Res := a.VarType.EvalConst(op, a.VarType.EvalConst(op_Assign, a, Left), Right);
        Result := True;
      finally
        a.Free();
      end;
    except
      Result := False;
    end;
  end;

begin
  Result := nil;
  Assert(FCompiler <> nil);
  Assert((Left <> nil) or (Right <> nil));

  if (Left = nil) then
  begin
    Left := Right;
    Right := nil;
  end;
  if (Op = op_UnaryPlus) then
    Exit(Left);

  try
    if (Right = nil) then
    begin
      t := EvalRes(Op);
      if (op = op_Addr) then
        Exit(t.NewGlobalVarP(@Left.Ptr))
      else if (op = op_Deref) then
        Exit(t.NewGlobalVarP(PPointer(Left.Ptr)^));

      p := getEvalProc(Op, FBaseType, ltUnknown);
    end
    else if (op <> op_Assign) or Left.VarType.CompatibleWith(Right.VarType) then
    begin
      p := getEvalProc(Op, FBaseType, Right.BaseType);
      t := EvalRes(Op, Right);
    end
    else
      p := nil;

    if (t = nil) or ({$IFNDEF FPC}@{$ENDIF}p = nil) or ({$IFNDEF FPC}@{$ENDIF}p = {$IFNDEF FPC}@{$ENDIF}LapeEvalErrorProc) then
      if (op = op_Assign) and (Right <> nil) and (Right.VarType <> nil) then
        LapeException(lpeIncompatibleAssignment, [Right.VarType.AsString, AsString])
      else if (not (op in UnaryOperators)) and (Right <> nil) and (Right.VarType <> nil) and (not Left.VarType.Equals(Right.VarType)) then
      begin
        if Left.VarType.Equals(Right.VarType) or
          ((Left.VarType.Size >= Right.VarType.Size) and (not TryCast(True, Result)) and (not TryCast(False, Result))) or
          ((Left.VarType.Size <  Right.VarType.Size) and (not TryCast(False, Result)) and (not TryCast(True, Result))) then
        LapeException(lpeIncompatibleOperator2, [LapeOperatorToString(op), AsString, Right.VarType.AsString])
      end
      else if (op in UnaryOperators) then
        LapeException(lpeIncompatibleOperator1, [LapeOperatorToString(op), AsString])
      else
        LapeException(lpeIncompatibleOperator, [LapeOperatorToString(op)]);

    if (Op = op_Assign) then
    begin
      if (Right = nil) then
        LapeException(lpeInvalidAssignment);
      Result := Left;
      p(Result.Ptr, Right.Ptr, nil);
    end
    else
    begin
      Result := t.NewGlobalVarP();
      if (Right = nil) then
        p(Result.Ptr, Left.Ptr, nil)
      else
        p(Result.Ptr, Left.Ptr, Right.Ptr);
    end;
  finally
    if (op <> op_Assign) and (Result <> nil) and (Left <> nil) then
      Result.isConstant := Left.isConstant and ((Right = nil) or Right.isConstant);
  end;
end;

function TLapeType.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  p: TLapeEvalProc;

  function TryCast(DoRight: Boolean; out Res: TResVar): Boolean;
  var
    a, b: TResVar;
  begin
    if Left.VarType.Equals(Right.VarType, False) or
       (DoRight and (not Left.VarType.CompatibleWith(Right.VarType))) or
       ((not DoRight) and (not Right.VarType.CompatibleWith(Left.VarType)))
    then
      Exit(False);

    a := NullResVar;
    b := NullResVar;
    b.VarPos.MemPos := mpVar;
    if DoRight then
      b.VarType := Left.VarType
    else
      b.VarType := Right.VarType;
    try
      b.VarPos.StackVar := FCompiler.getTempVar(b.VarType);
      try
        if DoRight then
          Res := b.VarType.Eval(op, Dest, Left, b.VarType.Eval(op_Assign, a, b, Right, Offset, Pos), Offset, Pos)
        else
          Res := b.VarType.Eval(op, Dest, b.VarType.Eval(op_Assign, a, b, Left, Offset, Pos), Right, Offset, Pos);
        Result := True;
      finally
        setNullResVar(b, 1);
      end;
    except
      Result := False;
    end;
  end;

  function isConstant(r: TResVar): Boolean;
  begin
    if (r.VarPos.MemPos = mpMem) and (r.VarPos.GlobalVar <> nil) then
      Result := r.VarPos.GlobalVar.isConstant
    else if (r.VarPos.MemPos = mpVar) and (r.VarPos.StackVar <> nil) then
      Result := r.VarPos.StackVar.isConstant
    else if (r.VarPos.MemPos = mpStack) then
      Result := not r.VarPos.ForceVariable
    else
      Result := True;
  end;

begin
  Result := NullResVar;
  Assert(FCompiler <> nil);
  Assert((Left.VarPos.MemPos <> NullResVar.VarPos.MemPos) or (Right.VarPos.MemPos <> NullResVar.VarPos.MemPos));

  if (Left.VarPos.MemPos = NullResVar.VarPos.MemPos) then
  begin
    Left := Right;
    Right := NullResVar;
  end;
  if (op = op_UnaryPlus) then
  begin
    setNullResVar(Dest);
    Exit(Left);
  end;

  Result.VarType := EvalRes(Op, Right.VarType);
  getDestVar(Dest, Result, Op, FCompiler);

  {
  Write(Left.VarType.AsString, ' ', LapeOperatorToString(op), ' ');
  if (Right.VarType <> nil) then
    Write(Right.VarType.AsString, ' ');
  if (Result.VarType <> nil) then
    WriteLn('-> ', Result.VarType.AsString)
  else
    WriteLn('-> ?');
  }

  if (Right.VarType = nil) then
    p := getEvalProc(Op, FBaseType, ltUnknown)
  else if (op <> op_Assign) or Left.VarType.CompatibleWith(Right.VarType) then
    p := getEvalProc(Op, FBaseType, Right.VarType.BaseType)
  else
    p := nil;

  if (Result.VarType = nil) or ({$IFNDEF FPC}@{$ENDIF}p = nil) or ({$IFNDEF FPC}@{$ENDIF}p = {$IFNDEF FPC}@{$ENDIF}LapeEvalErrorProc) then
    if (op = op_Assign) and (Right.VarType <> nil) then
      LapeException(lpeIncompatibleAssignment, [Right.VarType.AsString, AsString])
    else if (not (op in UnaryOperators)) and (Right.VarType <> nil) and (not Left.VarType.Equals(Right.VarType)) then
      if ((Left.VarType.Size >= Right.VarType.Size) and (not TryCast(True, Result)) and (not TryCast(False, Result))) or
         ((Left.VarType.Size <  Right.VarType.Size) and (not TryCast(False, Result)) and (not TryCast(True, Result))) then
        LapeException(lpeIncompatibleOperator2, [LapeOperatorToString(op), AsString, Right.VarType.AsString])
      else
        Exit
    else if (op in UnaryOperators) then
      LapeException(lpeIncompatibleOperator1, [LapeOperatorToString(op), AsString])
    else
      LapeException(lpeIncompatibleOperator, [LapeOperatorToString(op)]);

  if (op = op_Assign) then
  begin
    if (Left.VarType = nil) or (Right.VarType = nil) or (Dest.VarPos.MemPos <> NullResVar.VarPos.MemPos) then
      LapeException(lpeInvalidAssignment);

    FCompiler.Emitter._Eval(p, Left, Right, NullResVar, Offset, Pos);
    Result := Left;
  end
  else
  begin
    if (op = op_Addr) and (not isVariable(Left)) then
      LapeException(lpeVariableExpected);
    FCompiler.Emitter._Eval(p, Result, Left, Right, Offset, Pos);
  end;

  if (op = op_Deref) then
    Result.VarPos.isPointer := (Result.VarPos.MemPos = mpVar);
  if (op <> op_Assign) then
    if (Result.VarPos.MemPos = mpMem) and (Result.VarPos.GlobalVar <> nil) then
      Result.VarPos.GlobalVar.isConstant := isConstant(Dest) and isConstant(Left) and isConstant(Right)
    else if (Result.VarPos.MemPos = mpVar) and (Result.VarPos.StackVar <> nil) then
      Result.VarPos.StackVar.isConstant := isConstant(Dest) and isConstant(Left) and isConstant(Right);
end;

function TLapeType.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; Pos: PDocPos = nil): TResVar;
var o: Integer;
begin
  o := -1;
  Result := Eval(op, Dest, Left, Right, o, Pos);
end;

procedure TLapeType.Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil);
var
  p: TLapeEvalProc;
  l, r: TResVar;

  function FullNil(p: Pointer; Size: Integer): Boolean;
  var
    i: Integer;
  begin
    if (p = nil) then
      Exit(True);
    for i := 0 to Size - 1 do
      if (PByteArray(p)^[i] <> 0) then
        Exit(False);
    Result := True;
  end;

begin
  Assert(v.VarType = Self);
  if (v.VarPos.MemPos = NullResVar.VarPos.MemPos) or (not NeedFinalization) then
    Exit;
  if (v.VarPos.MemPos = mpMem) and (v.VarPos.GlobalVar <> nil) and FullNil(v.VarPos.GlobalVar.Ptr, Size) then
    Exit;

  r := NullResVar;
  l := NullResVar;
  l.VarType := Self;
  l.VarPos.MemPos := mpMem;
  if UseCompiler and (FCompiler <> nil) then
    l.VarPos.GlobalVar := TLapeGlobalVar(FCompiler.addManagedVar(NewGlobalVarP()))
  else
    l.VarPos.GlobalVar := NewGlobalVarP();

  try
    p := getEvalProc(op_Assign, FBaseType, FBaseType);
    if ({$IFNDEF FPC}@{$ENDIF}p <> nil) and ({$IFNDEF FPC}@{$ENDIF}p <> {$IFNDEF FPC}@{$ENDIF}LapeEvalErrorProc) then
      if UseCompiler and (FCompiler <> nil) then
        FCompiler.Emitter._Eval(p, v, l, r, Offset, Pos)
      else if (v.VarPos.MemPos = mpMem) and (v.VarPos.GlobalVar <> nil) then
        p(v.VarPos.GlobalVar.Ptr, l.VarPos.GlobalVar.Ptr, nil);
  finally
    if (not UseCompiler) or (FCompiler = nil) then
      FreeAndNil(l.VarPos.GlobalVar);
  end;
end;

procedure TLapeType.Finalize(v: TResVar; UseCompiler: Boolean = True; Pos: PDocPos = nil);
var o: Integer;
begin
  o := -1;
  Finalize(v, o, UseCompiler, Pos);
end;

procedure TLapeType.Finalize(v: TLapeVar; var Offset: Integer; UseCompiler: Boolean = False; Pos: PDocPos = nil);
begin
  Finalize(getResVar(v), Offset, UseCompiler, Pos);
end;

procedure TLapeType.Finalize(v: TLapeVar; UseCompiler: Boolean = False; Pos: PDocPos = nil);
var o: Integer;
begin
  o := -1;
  Finalize(v, o, UseCompiler, Pos);
end;

function TLapeType_Type.getAsString: lpString;
begin
  if (FTType <> nil) then
    Result := FTType.AsString
  else
    Result := '';
end;

constructor TLapeType_Type.Create(AType: TLapeType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUnknown, ACompiler, AName, ADocPos);
  FTType := AType;
end;

function TLapeType_Type.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Type;
begin
  Result := TLapeClassType(Self.ClassType).Create(FTType, FCompiler, Name, @DocPos);
end;

function TLapeType_Integer{$IFNDEF FPC}<_Type>{$ENDIF}.VarToString(v: Pointer): lpString;
begin
  {$IFDEF FPC}
  Result := IntToStr(Int64(PType(v)^));
  {$ELSE}
  Result := 'Not implemented yet';
  {$ENDIF}
end;

function TLapeType_Integer{$IFNDEF FPC}<_Type>{$ENDIF}.NewGlobalVar(Val: _Type; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PType(Result.Ptr)^ := Val;
end;

function TLapeType_Integer{$IFNDEF FPC}<_Type>{$ENDIF}.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
{$IFNDEF FPC}var a: Int64; b: PType;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := NewGlobalVar(StrToInt64(Str), AName, ADocPos);
  {$ELSE}
  a := StrToInt64(Str); b := @a;
  Result := NewGlobalVar(b^ , AName, ADocPos);
  {$ENDIF}
end;

function TLapeType_Float{$IFNDEF FPC}<_Type>{$ENDIF}.VarToString(v: Pointer): lpString;
begin
  {$IFDEF FPC}
  Result := FloatToStr(Extended(PType(v)^));
  {$ELSE}
  Result := 'Not implemented yet';
  {$ENDIF}
end;

function TLapeType_Float{$IFNDEF FPC}<_Type>{$ENDIF}.NewGlobalVar(Val: _Type; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PType(Result.Ptr)^ := Val;
end;

function TLapeType_Float{$IFNDEF FPC}<_Type>{$ENDIF}.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
{$IFNDEF FPC}var a: Extended; b: PType;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := NewGlobalVar(StrToFloatDot(Str), AName, ADocPos);
  {$ELSE}
  a := StrToFloatDot(Str); b := @a;
  Result := NewGlobalVar(b^ , AName, ADocPos);
  {$ENDIF}
end;

function TLapeType_Char{$IFNDEF FPC}<_Type>{$ENDIF}.VarToString(v: Pointer): lpString;
begin
  {$IFDEF FPC}
  Result := '#'+IntToStr(Integer(PType(v)^));
  {$ELSE}
  Result := 'Not implemented yet';
  {$ENDIF}
end;

function TLapeType_Char{$IFNDEF FPC}<_Type>{$ENDIF}.NewGlobalVar(Val: _Type; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PType(Result.Ptr)^ := Val;
end;

function TLapeType_Char{$IFNDEF FPC}<_Type>{$ENDIF}.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
{$IFNDEF FPC}var a: WideChar; b: PType;{$ENDIF}
var
  c: Integer;
begin
  if (Length(Str) <> 1) then
    try
      if (Str[1] = '#') then
        Delete(Str, 1, 1);
      c := StrToInt(Str);
      Result := NewGlobalVarP(nil, AName, ADocPos);
      case Size of
        1: PUInt8(Result.Ptr)^ := c;
        2: PUInt16(Result.Ptr)^ := c;
        else LapeException(lpeImpossible);
      end;
    except
      LapeException(lpeInvalidValueForType, [AsString]);
    end;

  {$IFDEF FPC}
  Result := NewGlobalVar(_Type(Str[1]), AName, ADocPos);
  {$ELSE}
  a := Str[1]; b := @a;
  Result := NewGlobalVar(b^, AName, ADocPos);
  {$ENDIF}
end;

constructor TLapeType_UInt8.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUInt8, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Int8.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltInt8, ACompiler, AName, ADocPos);
end;

constructor TLapeType_UInt16.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUInt16, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Int16.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltInt16, ACompiler, AName, ADocPos);
end;

constructor TLapeType_UInt32.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUInt32, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Int32.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltInt32, ACompiler, AName, ADocPos);
end;

constructor TLapeType_UInt64.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUInt64, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Int64.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltInt64, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Single.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltSingle, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Double.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltDouble, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Currency.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltCurrency, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Extended.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltExtended, ACompiler, AName, ADocPos);
end;

constructor TLapeType_AnsiChar.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltAnsiChar, ACompiler, AName, ADocPos);
end;

constructor TLapeType_WideChar.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltWideChar, ACompiler, AName, ADocPos);
end;

constructor TLapeType_Variant.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltVariant, ACompiler, AName, ADocPos);
end;

function TLapeType_Variant.VarToString(v: Pointer): lpString;
begin
  if (v <> nil) then
  try
    Result := VarTypeAsText(VarType(PVariant(v)^));
    Result := Result + '(' + PVariant(v)^ + ')';
  except
  end
  else
    Result := inherited;
end;

function TLapeType_Variant.NewGlobalVar(Val: Variant; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PVariant(Result.Ptr)^ := Val;
end;

function TLapeType_Variant.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVar(Str, AName, ADocPos);
end;

function TLapeType_SubRange.getAsString: lpString;
begin
  if (FAsString = '') then
    if (FVarType <> nil) then
      FAsString := FVarType.VarToString(@FRange.Lo) + '..' + FVarType.VarToString(@FRange.Hi)
    else
      FAsString := IntToStr(FRange.Lo) + '..' + IntToStr(FRange.Hi);
  Result := inherited;
end;

constructor TLapeType_SubRange.Create(ARange: TLapeRange; ACompiler: TLapeCompilerBase; AVarType: TLapeType; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUnknown, ACompiler, AName, ADocPos);
  if (AVarType = nil) then
    if (FRange.Lo < 0) then
      AVarType := FCompiler.getBaseType(DetermineIntType('-'+IntToStr(ARange.Hi)))
    else
      AVarType := FCompiler.getBaseType(DetermineIntType(ARange.Hi));
 if (AVarType <> nil) then
   FBaseType := AVarType.BaseType;
 FRange := ARange;
 FVarType := AVarType;
end;

function TLapeType_SubRange.VarToString(v: Pointer): lpString;
begin
  if (FVarType <> nil) then
    Result := FVarType.VarToString(v)
  else
    Result := IntToStr(VarToInt(v));
end;

function TLapeType_SubRange.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_SubRange;
begin
  Result := TLapeClassType(Self.ClassType).Create(FRange, FCompiler, FVarType, Name, @DocPos);
  Result.FBaseType := FBaseType;
end;

function TLapeType_SubRange.NewGlobalVar(Value: Int64 = 0; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  if (Value < FRange.Lo) or (Value > FRange.Hi) then
    LapeException(lpeOutOfTypeRange);

  Result := NewGlobalVarP(nil, AName);
  case BaseIntType of
    ltInt8: PInt8(Result.Ptr)^ := Value;
    ltUInt8: PUInt8(Result.Ptr)^ := Value;
    ltInt16: PInt16(Result.Ptr)^ := Value;
    ltUInt16: PUInt16(Result.Ptr)^ := Value;
    ltInt32: PInt32(Result.Ptr)^ := Value;
    ltUInt32: PUInt32(Result.Ptr)^ := Value;
    ltInt64: PInt64(Result.Ptr)^ := Value;
    ltUInt64: PUInt64(Result.Ptr)^ := Value;
  end;
end;

function TLapeType_SubRange.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  with FVarType.NewGlobalVarStr(Str) do
  try
    Result := NewGlobalVar(AsInteger, AName, ADocPos);
  finally
    Free();
  end;
end;

function TLapeType_Enum.getAsString: lpString;
var
  i: Integer;
begin
  if (FAsString = '') then
  begin
    FAsString := '(';
    for i := 0 to FMemberMap.Count - 1 do
    begin
      if (FMemberMap[i] = '') then
        Continue;
      if (FAsString <> '(') then
        FAsString := FAsString + ', ';
      FAsString := FAsString + FMemberMap[i] + '=' + IntToStr(i);
    end;
    FAsString := FAsString + ')';
  end;
  Result := inherited;
end;

constructor TLapeType_Enum.Create(ACompiler: TLapeCompilerBase; AMemberMap: TEnumMap; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(NullRange, ACompiler, nil, AName, ADocPos);
  FBaseType := ltLargeEnum;
  FVarType := nil;

  FreeMemberMap := (AMemberMap = nil);
  if (AMemberMap = nil) then
  begin
    AMemberMap := TEnumMap.Create();
    AMemberMap.CaseSensitive := {$IFDEF Lape_CaseSensitive}True{$ELSE}False{$ENDIF};
  end;
  FMemberMap := AMemberMap;

  FRange.Hi := FMemberMap.Count - 1;
  FSmall := (FRange.Hi <= Ord(High(ELapeSmallEnum)));
  if FSmall then
    FBaseType := ltSmallEnum;
end;

destructor TLapeType_Enum.Destroy;
begin
  if FreeMemberMap then
    FMemberMap.Free();
  inherited;
end;

function TLapeType_Enum.addMember(Value: Int16; AName: lpString): Int16;
var
  i: Integer;
begin
  if (Value < FMemberMap.Count) then
    LapeException(lpeInvalidRange)
  else if (AName = '') or (FMemberMap.IndexOf(AName) > -1) then
    LapeException(lpeDuplicateDeclaration);

  FAsString := '';
  Result:= FMemberMap.Count;

  for i := FMemberMap.Count to Value - 1 do
    FMemberMap.add('');
  FMemberMap.add(AName);

  FRange.Hi := Result;
  FSmall := (FRange.Hi <= Ord(High(ELapeSmallEnum)));
  if (not FSmall) then
    FBaseType := ltLargeEnum;
end;

function TLapeType_Enum.addMember(AName: lpString): Int16;
begin
  Result := addMember(FMemberMap.Count, AName);
end;

function TLapeType_Enum.VarToString(v: Pointer): lpString;
var
  i: Integer;
begin
  try
    Result := '';
    i := VarToInt(v);

    if (FBaseType in LapeBoolTypes) then
      if (i = 0) then
        Result := 'False'
      else
        Result := 'True'
    else
    begin
      if (i > -1) and (i < FMemberMap.Count) then
        Result := FMemberMap[i];

      if (Result = '') then
        if (Name <> '') then
          Result := Name + '(' + IntToStr(i) + ')'
        else
          Result := 'InvalidEnum';
    end;
  except
    Result := 'EnumException';
  end;
end;

function TLapeType_Enum.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Enum;
begin
  Result := TLapeClassType(Self.ClassType).Create(FCompiler, FMemberMap, Name, @DocPos);
  Result.FBaseType := FBaseType;
end;

function TLapeType_Enum.NewGlobalVar(Value: Int64 = 0; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName);
  if FSmall then
    PLapeSmallEnum(Result.Ptr)^ := ELapeSmallEnum(Value)
  else
    PLapeLargeEnum(Result.Ptr)^ := ELapeLargeEnum(Value);
end;

function TLapeType_Enum.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  try
    Result := NewGlobalVar(StrToInt(Str), AName, ADocPos);
  except
    Result := NewGlobalVar(FMemberMap.IndexOf(Str), AName, ADocPos);
  end;
end;

function TLapeType_Enum.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  if (Right <> nil) and (Right.BaseIntType <> ltUnknown) and
     (((BaseType in LapeBoolTypes) and (op in BinaryOperators + EnumOperators) and (Right.BaseType in LapeBoolTypes)) or
     ((op in EnumOperators) and ((not (Right.BaseType in LapeEnumTypes)) or Equals(Right))))
  then
  begin
    Result := FCompiler.getBaseType(BaseIntType).EvalRes(Op, FCompiler.getBaseType(Right.BaseIntType));
    if (not (op in CompareOperators)) then
      Result := Self;
  end
  else
    Result := inherited;
end;

function TLapeType_Enum.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  v: TLapeType;
  t: TLapeGlobalVar;
begin
  Assert(FCompiler <> nil);
  Assert((Left = nil) or (Left.VarType = Self));

  if (Right <> nil) and (Right.VarType <> nil) and (Right.VarType.BaseIntType <> ltUnknown) and
     (((BaseType in LapeBoolTypes) and (op in BinaryOperators + EnumOperators) and (Right.VarType.BaseType in LapeBoolTypes)) or
     ((op in EnumOperators) and ((not (Right.VarType.BaseType in LapeEnumTypes)) or Equals(Right.VarType))))
  then
  try
    v := Right.FVarType;
    if (BaseIntType = ltUnknown) or (Right.FVarType = nil) or (Right.FVarType.BaseIntType = ltUnknown) then
      LapeException(lpeInvalidEvaluation);

    Left.FVarType := FCompiler.getBaseType(BaseIntType);
    Right.FVarType := FCompiler.getBaseType(Right.FVarType.BaseIntType);

    Result := Left.VarType.EvalConst(Op, Left, Right);
    if (not (op in CompareOperators)) then
      if (Result.VarType.BaseIntType = BaseIntType) then
        Result.FVarType := Self
      else
      try
        t := Result;
        Result := NewGlobalVarP();
        Result := EvalConst(op_Assign, Result, t);
      finally
        FreeAndNil(t);
      end;
  finally
    Left.FVarType := Self;
    Right.FVarType := v;
  end
  else
    Result := inherited;
end;

function TLapeType_Enum.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  v: TLapeType;
  a, t: TResVar;
begin
  Assert(FCompiler <> nil);
  Assert(Left.VarType = Self);

  if (Right.VarType <> nil) and (Right.VarType.BaseIntType <> ltUnknown) and
     (((BaseType in LapeBoolTypes) and (op in BinaryOperators + EnumOperators) and (Right.VarType.BaseType in LapeBoolTypes)) or
     ((op in EnumOperators) and ((not (Right.VarType.BaseType in LapeEnumTypes)) or Equals(Right.VarType))))
  then
  try
    a := NullResVar;
    t := NullResVar;
    v := Right.VarType;
    if (BaseIntType = ltUnknown) or (Right.VarType = nil) or (Right.VarType.BaseIntType = ltUnknown) then
      LapeException(lpeInvalidEvaluation);

    Left.VarType := FCompiler.getBaseType(BaseIntType);
    Right.VarType := FCompiler.getBaseType(Right.VarType.BaseIntType);

    if (Dest.VarType <> nil) and Equals(Dest.VarType) then
      t := Dest;
    Result := Left.VarType.Eval(Op, Dest, Left, Right, Offset, Pos);
    if (not (op in CompareOperators)) then
      if (Result.VarType.BaseIntType = BaseIntType) then
        Result.VarType := Self
      else
      try
        Dest := t;
        t := Result;
        Result := NullResVar;
        Result.VarType := Self;
        getDestVar(Dest, Result, op_Unknown, FCompiler);
        Result := Eval(op_Assign, a, Result, t, Offset, Pos);
      finally
        SetNullResVar(t, 1);
      end;
  finally
    Left.VarType := Self;
    Right.VarType := v;
  end
  else
    Result := inherited;
end;

constructor TLapeType_Boolean.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ACompiler, nil, AName, ADocPos);
  addMember('False');
  addMember('True');
  FBaseType := ltBoolean;
end;

constructor TLapeType_Bool.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(NullRange, ACompiler, ACompiler.getBaseType(ltBoolean).CreateCopy(), AName, ADocPos);
end;

destructor TLapeType_Bool.Destroy;
begin
  FVarType.Free();
  inherited;
end;

function TLapeType_Bool.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Bool;
begin
  Result := TLapeClassType(Self.ClassType).Create(FCompiler, Name, @DocPos);
  Result.FBaseType := FBaseType;
  TLapeType_Bool(Result).FRange := FRange;
  TLapeType_Bool(Result).FVarType.FSize := FVarType.FSize;
end;

function TLapeType_Bool.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  Result := FVarType.EvalRes(Op, Right);
end;

function TLapeType_Bool.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
begin
  Assert(Left.VarType = Self);
  Left.FVarType := FVarType;
  try
    Result := FVarType.EvalConst(Op, Left, Right);
  finally
    Left.FVarType := Self;
  end;
end;

function TLapeType_Bool.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
begin
  Assert(Left.VarType = Self);
  Left.VarType := FVarType;
  try
    Result := FVarType.Eval(Op, Dest, Left, Right, Offset, Pos);
  finally
    Left.VarType := Self;
  end;
end;

constructor TLapeType_ByteBool.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
const BoolRange: TLapeRange =(Lo: Ord(Low(UInt8{ByteBool})); Hi: Ord(High(UInt8{ByteBool})));
begin
  inherited Create(ACompiler, AName, ADocPos);
  FRange := BoolRange;
  FBaseType := ltByteBool;
  FVarType.FSize := LapeTypeSize[ltByteBool];
end;

constructor TLapeType_WordBool.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
const BoolRange: TLapeRange =(Lo: Ord(Low(UInt16{WordBool})); Hi: Ord(High(UInt16{WordBool})));
begin
  inherited Create(ACompiler, AName, ADocPos);
  FRange := BoolRange;
  FBaseType := ltWordBool;
  FVarType.FSize := LapeTypeSize[ltWordBool];
end;

constructor TLapeType_LongBool.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
const BoolRange: TLapeRange =(Lo: Ord(Low(UInt32{LongBool})); Hi: Ord(High(UInt32{LongBool})));
begin
  inherited Create(ACompiler, AName, ADocPos);
  FRange := BoolRange;
  FBaseType := ltLongBool;
  FVarType.FSize := LapeTypeSize[ltLongBool];
end;

function TLapeType_Set.getAsString: lpString;
begin
  if (FAsString = '') then
    FAsString := 'set of ' + FRange.AsString;
  Result := inherited;
end;

constructor TLapeType_Set.Create(ARange: TLapeType_SubRange; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  Assert(ARange <> nil);
  inherited Create(ltLargeSet, ACompiler, AName, ADocPos);

  FRange := ARange;
  FSmall := (FRange.Range.Hi <= Ord(High(ELapeSmallEnum)));
  if FSmall then
    FBaseType := ltSmallSet;

  if (FRange.Range.Lo < Ord(Low(ELapeSmallEnum))) or (FRange.Range.Hi > Ord(High(ELapeLargeEnum))) then
    LapeException(lpeOutOfTypeRange);
end;

function TLapeType_Set.VarToString(v: Pointer): lpString;
var
  i: Integer;
begin
  Result := '[';
  for i := FRange.Range.Lo to FRange.Range.Hi do
    if (FSmall and (ELapeSmallEnum(i) in PLapeSmallSet(v)^)) or ((not FSmall) and (ELapeLargeEnum(i) in PLapeLargeSet(v)^)) then
    begin
      if (Result <> '[') then
        Result := Result + ', ';
      Result := Result + FRange.VarToString(@i);
    end;
  Result := Result + ']';
end;

function TLapeType_Set.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Set;
begin
  Result := TLapeClassType(Self.ClassType).Create(FRange, FCompiler, Name, @DocPos);
end;

function TLapeType_Set.NewGlobalVar(Values: array of UInt8; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
var
  i: Integer;
begin
  Result := NewGlobalVarP(nil, AName);
  for i := 0 to High(Values) do
    if FSmall then
      PLapeSmallSet(Result.Ptr)^ := PLapeSmallSet(Result.Ptr)^ + [ELapeSmallEnum(Values[i])]
    else
      PLapeLargeSet(Result.Ptr)^ := PLapeLargeSet(Result.Ptr)^ + [ELapeLargeEnum(Values[i])]
end;

function TLapeType_Set.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  Result := nil;
  if (Right = nil) then
    Result := inherited
  else
    case getEvalRes(Op, FBaseType, Right.FBaseType) of
      ltSmallEnum, ltLargeEnum:
        if (not (Right.FBaseType in LapeEnumTypes)) or Right.Equals(FRange) then
          Result := FRange.VarType;
      ltSmallSet, ltLargeSet:
        if (not (Right.FBaseType in LapeEnumTypes + LapeSetTypes)) or Right.Equals(FRange) or Equals(Right) then
          Result := Self;
      else
        Result := inherited;
    end;
end;

function TLapeType_Pointer.getAsString: lpString;
begin
  if (FAsString = '') and (FBaseType = ltPointer) then
    if (FPType <> nil) then
      FAsString := '^'+FPType.AsString;
  Result := inherited;
end;

constructor TLapeType_Pointer.Create(ACompiler: TLapeCompilerBase; PointerType: TLapeType = nil; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltPointer, ACompiler, AName, ADocPos);
  FPType := PointerType;
end;

function TLapeType_Pointer.Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean;
begin
  if (Other <> nil) and (Other.BaseType = BaseType) and ContextOnly then
    Result := (FPType = nil) or (TLapeType_Pointer(Other).PType = nil) or inherited
  else
    Result := inherited;
end;

function TLapeType_Pointer.VarToString(v: Pointer): lpString;
begin
  if ((v = nil) or (PPointer(v)^ = nil)) then
    Result := 'nil'
  else
  begin
    Result := '0x'+IntToHex(PtrUInt(PPointer(v)^), 1);
    try
      if (FPType <> nil) then
        Result := Result + '(' + FPType.VarToString(PPointer(v)^) + ')';
    except end;
  end;
end;

function TLapeType_Pointer.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Pointer;
begin
  Result := TLapeClassType(Self.ClassType).Create(FCompiler, FPType, Name, @DocPos);
end;

function TLapeType_Pointer.NewGlobalVar(Ptr: Pointer = nil; AName: lpString = ''; ADocPos: PDocPos = nil;  AsValue: Boolean = True): TLapeGlobalVar;
begin
  if AsValue then
  begin
    Result := NewGlobalVarP(nil, AName, ADocPos);
    PPointer(Result.FPtr)^ := Ptr;
  end
  else if (Ptr = nil) then
  begin
    Result := NewGlobalVarP(Pointer(-1), AName, ADocPos);
    Result.FPtr := nil;
  end
  else
    Result := NewGlobalVarP(Ptr, AName, ADocPos);
end;

function TLapeType_Pointer.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVar(Pointer(StrToInt64(Str)), AName, ADocPos);
end;

function TLapeType_Pointer.HasType: Boolean;
begin
  Result := FPType <> nil;
end;

function TLapeType_Pointer.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  if (op = op_Deref) then
    Result := FPType
  else if (op = op_Index) then
    Result := Self
  else
  begin
    Result := inherited;
    if (Result <> nil) and (Result.BaseType = ltPointer) and (TLapeType_Pointer(Result).PType = nil) and (FCompiler <> nil) then
      Result := FCompiler.getPointerType(FPType);
  end;
end;

function TLapeType_Pointer.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  v: TLapeType;
  s, r: TLapeGlobalVar;
begin
  Assert(FCompiler <> nil);
  Assert((Left = nil) or (Left.VarType is TLapeType_Pointer));

  if (op = op_Index) and (Right <> nil) then
  begin
    v := Right.FVarType;
    if (Right.FVarType = nil) or (Right.FVarType.BaseIntType = ltUnknown) then
      if (Right <> nil) and (Right.VarType <> nil) then
        LapeException(lpeInvalidIndex, [Right.VarType.AsString])
      else
        LapeException(lpeInvalidEvaluation)
    else
      Right.FVarType := FCompiler.getBaseType(Right.VarType.BaseIntType);

    s := FCompiler.getBaseType(ltInt32).NewGlobalVarStr(IntToStr(FPType.Size));
    r := nil;
    try
      if (FPType.Size <> 1) then
        r := Right.VarType.EvalConst(op_Multiply, Right, s)
      else
        r := Right;

      Result := //Result := (Pointer + Index * PSize)
        EvalConst(
          op_Plus,
          Left,
          r
        );
    finally
      if (r <> nil) and (r <> Right) then
        r.Free();
      s.Free();
      Right.FVarType := v;
    end;
  end
  else
    Result := inherited;
end;

function TLapeType_Pointer.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  a, r: TResVar;
  v: TLapeType;
begin
  Assert(FCompiler <> nil);
  Assert(Left.VarType is TLapeType_Pointer);
  a := NullResVar;

  if (op = op_Index) then
  begin
    v := Right.VarType;
    if (Right.VarType = nil) or (Right.VarType.BaseIntType = ltUnknown) then
      if (Right.VarType <> nil) then
        LapeException(lpeInvalidIndex, [Right.VarType.AsString])
      else
        LapeException(lpeInvalidEvaluation)
    else
      Right.VarType := FCompiler.getBaseType(Right.VarType.BaseIntType);

    r := Right;
    if (FPType.Size <> 1) then
      r :=
        Right.VarType.Eval(
          op_Multiply,
          a,
          Right,
          getResVar(FCompiler.addManagedVar(FCompiler.getBaseType(ltInt32).NewGlobalVarStr(IntToStr(FPType.Size)))),
          Offset,
          Pos
        );

    Result := //Result := (Pointer + Index * PSize)
      Eval(
        op_Plus,
        Dest,
        Left,
        r,
        Offset,
        Pos
      );
    Right.VarType := v;
  end
  else
    Result := inherited;
end;

function TLapeType_DynArray.getAsString: lpString;
begin
  if (FAsString = '') and (FBaseType = ltDynArray) then
    if (FPType <> nil) then
      FAsString := 'array of ' + FPType.AsString
    else
      FAsString := 'array';
  Result := inherited;
end;

constructor TLapeType_DynArray.Create(ArrayType: TLapeType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ACompiler, ArrayType, AName, ADocPos);
  FBaseType := ltDynArray;
end;

function TLapeType_DynArray.VarToString(v: Pointer): lpString;
var
  i: Integer;
  p: Pointer;
begin
  Result := '[';
  if (v <> nil) and (FPType <> nil) then
  begin
    p := PPointer(v)^;
    for i := 0 to Length(PCodeArray(v)^) - 1 do
    begin
      if (i > 0) then
        Result := Result + ', ';
      Result := Result + FPType.VarToString(Pointer(PtrUInt(p) + UInt32(FPType.Size * i)));
    end;
  end;
  Result := Result + ']';
end;

function TLapeType_DynArray.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_DynArray;
begin
  Result := TLapeClassType(Self.ClassType).Create(FPType, FCompiler, Name, @DocPos);
  Result.FBaseType := FBaseType;
end;

function TLapeType_DynArray.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  if (op = op_Index) then
    Result := FPType
  else
    Result := inherited;
end;

function TLapeType_DynArray.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  b: ELapeBaseType;
  l: TLapeGlobalVar;
begin
  Assert((Left = nil) or (Left.VarType is TLapeType_Pointer));
  if (op = op_Index) then
  begin
    b := FBaseType;
    FBaseType := ltPointer;
    l := nil;
    try
      l := inherited EvalConst(Op, Left, Right);
      Result := //Result := Pointer[Index]^
        EvalConst(
          op_Deref,
          l,
          nil
        );
    finally
      if (l <> nil) then
        l.Free();
      FBaseType := b;
    end;
  end
  else
    Result := inherited;
end;

function TLapeType_DynArray.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  a: TResVar;
  b: ELapeBaseType;
begin
  Assert(Left.VarType is TLapeType_Pointer);
  a := NullResVar;

  if (op = op_Index) then
  try
    b := FBaseType;
    FBaseType := ltPointer;
    if (not Left.VarPos.isPointer) then
    begin
      Result := inherited Eval(Op, Dest, Left, Right, Offset, Pos);
      Result.VarPos.isPointer := True;
      Result.VarType := FPType;
    end
    else
    begin
      a := inherited Eval(Op, a, Left, Right, Offset, Pos);
      Result := //Result := Pointer[Index]^
        Eval(
          op_Deref,
          Dest,
          a,
          NullResVar,
          Offset,
          Pos
        );
      SetNullResVar(a, 1);
    end;
  finally
    FBaseType := b;
  end
  else
    Result := inherited;
end;

procedure TLapeType_DynArray.Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil);
begin
  Assert(v.VarType = Self);
  if (FBaseType in LapeStringTypes) then
  begin
    inherited;
    Exit;
  end else if (v.VarPos.MemPos = NullResVar.VarPos.MemPos) or (not NeedFinalization) then
    Exit;
end;

function TLapeType_StaticArray.getSize: Integer;
begin
  if (FPType = nil) then
    Exit(-1);
  FSize := (FRange.Hi - FRange.Lo + 1) * FPType.Size;
  Result := FSize;
end;

function TLapeType_StaticArray.getAsString: lpString;
begin
  if (FAsString = '') then
  begin
    FAsString := 'array [' + IntToStr(FRange.Lo) + '..' + IntToStr(FRange.Hi) + ']';
    if (FPType <> nil) then
      FAsString := FAsString + ' of ' + FPType.AsString;
  end;
  Result := inherited;
end;

constructor TLapeType_StaticArray.Create(ARange: TLapeRange; ArrayType: TLapeType; ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ArrayType, ACompiler, AName, ADocPos);
  FBaseType := ltStaticArray;
  if (ArrayType <> nil) and ArrayType.NeedInitialization then
    FInit := __Yes
  else
    FInit := __No;

  FRange := ARange;
end;

function TLapeType_StaticArray.VarToString(v: Pointer): lpString;
var
  i: Integer;
begin
  Result := '[';
  if (v <> nil) and (FPType <> nil) then
    for i := 0 to FRange.Hi - FRange.Lo do
    begin
      if (i > 0) then
        Result := Result + ', ';
      Result := Result + FPType.VarToString(Pointer(PtrInt(v) + (FPType.Size * i)));
    end;
  Result := Result + ']';
end;

function TLapeType_StaticArray.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_StaticArray;
begin
  Result := TLapeClassType(Self.ClassType).Create(FRange, FPType, FCompiler, Name, @DocPos);
  Result.FBaseTYpe := FBaseType;
end;

function TLapeType_StaticArray.NewGlobalVar(AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
end;

function TLapeType_StaticArray.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  if (op = op_Assign) and (FPType <> nil) and (Right <> nil) and (Right is TLapeType_StaticArray) and
     ((TLapeType_StaticArray(Right).Range.Hi - TLapeType_StaticArray(Right).Range.Lo) = (Range.Hi - Range.Lo)) and
     FPType.CompatibleWith(TLapeType_StaticArray(Right).FPType) then
    Result := Self
  else
    Result := inherited;
end;

function TLapeType_StaticArray.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  i: Integer;
  v: TLapeType;
  low, l, r: TLapeGlobalVar;
begin
  Assert(FCompiler <> nil);
  Assert((Left = nil) or (Left.VarType is TLapeType_Pointer));

  if (op = op_Index) and (Right <> nil) then
  begin
    v := Right.FVarType;
    if (Right.VarType = nil) or (Right.FVarType.BaseIntType = ltUnknown) then
      if (Right.VarType <> nil) then
        LapeException(lpeInvalidIndex, [Right.VarType.AsString])
      else
        LapeException(lpeInvalidEvaluation)
    else if (Right.AsInteger < FRange.Lo) or (Right.AsInteger > FRange.Hi) then
      LapeException(lpeOutOfTypeRange)
    else
      Right.FVarType := FCompiler.getBaseType(Right.VarType.BaseIntType);

    l := EvalConst(op_Addr, Left, nil);
    try
      if (FRange.Lo = 0) then
        Result := inherited EvalConst(Op, l, Right)
      else
      begin
        r := nil;
        try
          low := FCompiler.getBaseType(DetermineIntType(FRange.Lo)).NewGlobalVarStr(IntToStr(FRange.Lo));
          r := Right.VarType.EvalConst(op_Minus, Right, low);
          Result := //Result := @Pointer[Index - Lo]^
            inherited EvalConst(
              Op,
              l,
              r
            );
        finally
          if (low <> nil) then
            low.Free();
          if (r <> nil) then
            r.Free();
        end;
      end;
    finally
      l.Free();
      Right.FVarType := v;
    end;
  end
  else if (op = op_Assign) and (not (BaseType in LapeStringTypes)) and (Right <> nil) and (Right.VarType <> nil) and CompatibleWith(Right.VarType) then
  begin
    l := nil;
    r := nil;

    for i := 0 to FRange.Hi - FRange.Lo do
    try
      l := FPType.NewGlobalVarP(Pointer(PtrInt(Left.Ptr) + (FPType.Size * i)));
      r := FPType.NewGlobalVarP(Pointer(PtrInt(Right.Ptr) + (FPType.Size * i)));
      FPType.EvalConst(op_Assign, l, r);
    finally
      if (l <> nil) then
        FreeAndNil(l);
      if (r <> nil) then
        FreeAndNil(r);
    end;
    Result := Left;
  end
  else
    Result := inherited;
end;

function TLapeType_StaticArray.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  a, t: TResVar;
  b: Boolean;
  v: TLapeType;
  c, l, h: TLapeVar;
  o: Integer;
begin
  Assert(FCompiler <> nil);
  Assert(Left.VarType is TLapeType_Pointer);
  a := NullResVar;
  t := NullResVar;

  if (op = op_Index) then
  try
    b := ((Left.VarPos.MemPos = mpMem) and (Left.VarPos.GlobalVar <> nil) and Left.VarPos.GlobalVar.isConstant) or
      ((Left.VarPos.MemPos = mpVar) and (Left.VarPos.StackVar <> nil) and Left.VarPos.StackVar.isConstant) or
      ((Left.VarPos.MemPos = mpStack) and (not Left.VarPos.ForceVariable));
    if b then
      case Left.VarPos.MemPos of
        mpMem: Left.VarPos.GlobalVar.isConstant := False;
        mpVar: Left.VarPos.StackVar.isConstant := False;
        mpStack: Left.VarPos.ForceVariable := True;
      end;

    if (not Left.VarPos.isPointer) then
      t := Eval(op_Addr, a, Left, NullResVar, Offset, Pos)
    else
    begin
      t := Left;
      t.VarPos.isPointer := False;
      t.VarType := FCompiler.getPointerType(PType);
    end;

    if (FRange.Lo = 0) then
      Result := inherited Eval(Op, Dest, t, Right, Offset, Pos)
    else
    try
      v := Right.VarType;
      if (Right.VarType = nil) or (Right.VarType.BaseIntType = ltUnknown) then
        if (Right.VarType <> nil) then
          LapeException(lpeInvalidIndex, [Right.VarType.AsString])
        else
          LapeException(lpeInvalidEvaluation)
      else
        Right.VarType := FCompiler.getBaseType(Right.VarType.BaseIntType);

      Result := //Result := @Pointer[Index - Lo]^
        inherited Eval(
          Op,
          Dest,
          t,
          Right.VarType.Eval(op_Minus, a, Right, getResVar(
            FCompiler.addManagedVar(
              FCompiler.getBaseType(DetermineIntType(FRange.Lo)).NewGlobalVarStr(IntToStr(FRange.Lo))
            )
          ), Offset, Pos),
          Offset,
          Pos
        );
    finally
      Right.VarType := v;
    end;
  finally
    if (not Left.VarPos.isPointer) then
      SetNullResVar(t, 1);

    if b then
      case Left.VarPos.MemPos of
        mpMem: Left.VarPos.GlobalVar.isConstant := True;
        mpVar: Left.VarPos.StackVar.isConstant := True;
        mpStack: Left.VarPos.ForceVariable := False;
      end;
  end
  else if (op = op_Assign) and (not (BaseType in LapeStringTypes)) and (Right.VarType <> nil) and CompatibleWith(Right.VarType) then
    if (not NeedInitialization) and Equals(Right.VarType) and (Size in [1, 2, 4, 8]) then
    try
      v := Right.VarType;
      case Size of
        1: Left.VarType := FCompiler.getBaseType(ltUInt8);
        2: Left.VarType := FCompiler.getBaseType(ltUInt16);
        4: Left.VarType := FCompiler.getBaseType(ltUInt32);
        8: Left.VarType := FCompiler.getBaseType(ltUInt64);
      end;
      Right.VarType := Left.VarType;
      Result := Left.VarType.Eval(op_Assign, Dest, Left, Right, Offset, Pos);
    finally
      Left.VarType := Self;
      Right.VarType := v;
    end
    else
    begin
      if (Left.VarPos.MemPos = mpStack) and (not Left.VarPos.ForceVariable) then
      begin
        FCompiler.Emitter._GrowStack(Size, Offset, Pos);
        Left.VarPos.ForceVariable := True;
        b := True;
      end
      else
        b := False;

      c := FCompiler.getTempVar(ltInt64, 2);
      l := FCompiler.addManagedVar(FCompiler.getBaseType(DetermineIntType(FRange.Lo - 1)).NewGlobalVarStr(IntToStr(FRange.Lo)));
      h := FCompiler.addManagedVar(FCompiler.getBaseType(DetermineIntType(FRange.Hi + 1)).NewGlobalVarStr(IntToStr(FRange.Hi)));
      t := c.VarType.Eval(op_Assign, t, GetResVar(c), GetResVar(l), Offset, Pos);
      o := Offset;
      FPType.Eval(op_Assign, a, Eval(op_Index, a, Left, t, Offset, Pos), Eval(op_Index, a, Right, t, Offset, Pos), Offset, Pos);
      c.VarType.Eval(op_Assign, a, t, c.VarType.Eval(op_Plus, a, t, getResVar(FCompiler.addManagedVar(c.VarType.NewGlobalVarStr('1'))), Offset, Pos), Offset, Pos);
      FCompiler.Emitter._JmpRIf(o - Offset, c.VarType.Eval(op_cmp_LessThanOrEqual, a, t, getResVar(h), Offset, Pos), Offset, Pos);
      setNullResVar(t, 2);

      Result := Left;
      if b then
        Left.VarPos.ForceVariable := False;
    end
  else
    Result := inherited;
end;

procedure TLapeType_StaticArray.Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil);
var
  i, o: Integer;
  a, _v: TResVar;
  c, l, h: TLapeVar;
begin
  Assert(v.VarType = Self);
  if (v.VarPos.MemPos = NullResVar.VarPos.MemPos) or (not NeedFinalization) then
    Exit;

  _v := NullResVar;
  a := NullResVar;
  if UseCompiler and (FCompiler <> nil) then
  begin
    c := FCompiler.getTempVar(ltInt64, 2);
    l := FCompiler.addManagedVar(FCompiler.getBaseType(DetermineIntType(FRange.Lo - 1)).NewGlobalVarStr(IntToStr(FRange.Lo)));
    h := FCompiler.addManagedVar(FCompiler.getBaseType(DetermineIntType(FRange.Hi + 1)).NewGlobalVarStr(IntToStr(FRange.Hi)));
    _v := c.VarType.Eval(op_Assign, _v, GetResVar(c), GetResVar(l), Offset, Pos);
    o := Offset;
    FPType.Finalize(Eval(op_Index, a, v, _v, Offset, Pos), Offset, UseCompiler, Pos);
    c.VarType.Eval(op_Assign, a, _v, c.VarType.Eval(op_Plus, a, _v, getResVar(FCompiler.addManagedVar(c.VarType.NewGlobalVarStr('1'))), Offset, Pos), Offset, Pos);
    FCompiler.Emitter._JmpRIf(o - Offset, c.VarType.Eval(op_cmp_LessThanOrEqual, a, _v, getResVar(h), Offset, Pos), Offset, Pos);
    setNullResVar(_v, 2);
  end
  else if (v.VarPos.MemPos <> mpMem) then
    LapeException(lpeImpossible)
  else
    for i := 0 to FRange.Hi - FRange.Lo do
    try
      _v := v;
      _v.VarType := FPType;
      _v.VarPos.GlobalVar := _v.VarType.NewGlobalVarP(Pointer(PtrInt(_v.VarPos.GlobalVar.Ptr) + (FPType.Size * i)));
      FPType.Finalize(_v, Offset, UseCompiler, Pos);
    finally
      FreeAndNil(_v.VarPos.GlobalVar);
    end;
end;

function TLapeType_String.VarToString(v: Pointer): lpString;
begin
  if (FBaseType = ltAnsiString) then
    Result := '`'+PAnsiString(v)^+'`'
  else if (FBaseType = ltWideString) then
    Result := '`'+PWideString(v)^+'`'
  else if (FBaseType = ltUnicodeString) then
    Result := '`'+PUnicodeString(v)^+'`'
  else
    Result := '`'+PlpString(v)^+'`';
end;

function TLapeType_String.NewGlobalVarStr(Str: AnsiString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PAnsiString(Result.Ptr)^ := Str;
end;

function TLapeType_String.NewGlobalVar(Str: AnsiString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarStr(Str, AName, ADocPos);
end;

{$IFNDEF Lape_NoWideString}
function TLapeType_String.NewGlobalVarStr(Str: WideString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PWideString(Result.Ptr)^ := Str;
end;

function TLapeType_String.NewGlobalVar(Str: WideString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarStr(Str, AName, ADocPos);
end;
{$ENDIF}

function TLapeType_String.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PUnicodeString(Result.Ptr)^ := Str;
end;

function TLapeType_String.NewGlobalVar(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarStr(Str, AName, ADocPos);
end;

function TLapeType_String.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  v: TLapeType;
  low, r: TLapeGlobalVar;
begin
  Assert(FCompiler <> nil);
  Assert((Left = nil) or (Left.VarType is TLapeType_Pointer));

  if (op = op_Index) and (Right <> nil) then
  begin
    v := Right.FVarType;
    if (Right.VarType = nil) or (Right.FVarType.BaseIntType = ltUnknown) then
      if (Right.VarType <> nil) then
        LapeException(lpeInvalidIndex, [Right.VarType.AsString])
      else
        LapeException(lpeInvalidEvaluation)
    else if (Right.AsInteger < 1) then
      LapeException(lpeOutOfTypeRange)
    else
      Right.FVarType := FCompiler.getBaseType(Right.VarType.BaseIntType);

    r := nil;
    try
      low := FCompiler.getBaseType(ltUInt8).NewGlobalVarStr('1');
      r := Right.VarType.EvalConst(op_Minus, Right, low);
      Result := //Result := Pointer[Index - 1]^
        inherited EvalConst(
          Op,
          Left,
          r
        );
    finally
      if (low <> nil) then
        low.Free();
      if (r <> nil) then
        r.Free();
      Right.FVarType := v;
    end;
  end
  else
    Result := inherited;
end;

function TLapeType_String.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
begin
  Assert(FCompiler <> nil);
  Assert(Left.VarType is TLapeType_Pointer);

  Result := inherited;
  if (op = op_Index) and (FPType <> nil) then
  begin
    if (not Result.VarPos.isPointer) then
      LapeException(lpeImpossible);
    Result.VarPos.Offset := -FPType.Size;
  end;
end;

constructor TLapeType_AnsiString.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  Assert(ACompiler <> nil);
  inherited Create(ACompiler.getBaseType(ltAnsiChar), ACompiler, AName, ADocPos);
  FBaseType := ltAnsiString;
end;

constructor TLapeType_WideString.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  Assert(ACompiler <> nil);
  inherited Create(ACompiler.getBaseType(ltWideChar), ACompiler, AName, ADocPos);
  FBaseType := ltWideChar;
end;

constructor TLapeType_UnicodeString.Create(ACompiler: TLapeCompilerBase; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  Assert(ACompiler <> nil);
  inherited Create(ACompiler.getBaseType(ltWideChar), ACompiler, AName, ADocPos);
  FBaseType := ltUnicodeString;
end;

function TLapeType_ShortString.getAsString: lpString;
begin
  if (FAsString = '') then
  begin
    FAsString := inherited;
    FAsString := FAsString + '[' + IntToStr(FRange.Hi) + ']';
  end;
  Result := inherited;
end;

constructor TLapeType_ShortString.Create(ACompiler: TLapeCompilerBase; ASize: UInt8 = High(UInt8); AName: lpString = ''; ADocPos: PDocPos = nil);
var
  r: TLapeRange;
begin
  r.Lo := 0;
  r.Hi := ASize;
  Assert(ACompiler <> nil);
  inherited Create(r, ACompiler.getBaseType(ltAnsiChar), ACompiler, AName, ADocPos);
  FBaseType := ltShortString;
end;

function TLapeType_ShortString.VarToString(v: Pointer): lpString;
begin
  Result := '`'+PShortString(v)^+'`';
end;

function TLapeType_ShortString.NewGlobalVarStr(Str: UnicodeString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  if (Length(Str) >= FRange.Hi) then
    Delete(Str, FRange.Hi, Length(Str) - FRange.Hi + 1);
  PShortString(Result.Ptr)^ := Str;
end;

function TLapeType_ShortString.NewGlobalVar(Str: ShortString; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  PShortString(Result.Ptr)^ := Str;
end;

function TLapeType_ShortString.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  p: TLapeEvalProc;
begin
  Assert(FCompiler <> nil);
  Assert((Left = nil) or (Left.VarType is TLapeType_Pointer));

  if (op = op_Assign) and (Right <> nil) and (Right.VarType <> nil) and CompatibleWith(Right.VarType) then
    if (Right.VarType is TLapeType_ShortString) and (FRange.Hi <> TLapeType_ShortString(Right.VarType).Range.Hi) then
    begin
      p := getEvalProc(op_Assign, ltShortString, ltUInt8);
      Assert(({$IFNDEF FPC}@{$ENDIF}p <> nil) and ({$IFNDEF FPC}@{$ENDIF}p <> {$IFNDEF FPC}@{$ENDIF}LapeEvalErrorProc));
      p(Left.Ptr, Right.Ptr, @FRange.Hi);
    end
    else
    begin
      if (FRange.Hi < High(UInt8)) then
      begin
        Result := FCompiler.getBaseType(ltShortString).NewGlobalVarP();
        Result := Result.VarType.EvalConst(Op, Result, Right);
      end
      else
        Result := inherited;

      Result := inherited;
      if (Result <> nil) and (Result.VarType <> nil) and (Result.VarType is TLapeType_ShortString) and (FRange.Hi <> TLapeType_ShortString(Result.VarType).Range.Hi) then
        with Result do
        begin
          Result := EvalConst(op_Assign, Left, Result);
          Free();
        end;
    end
  else
    Result := inherited;
end;

function TLapeType_ShortString.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  p: TLapeEvalProc;
  a: TResVar;
begin
  Assert(FCompiler <> nil);
  Assert(Left.VarType is TLapeType_Pointer);
  Result := NullResVar;
  a := NullResVar;

  if (op = op_Assign) and (Right.VarType <> nil) and CompatibleWith(Right.VarType) then
    if (Right.VarType is TLapeType_ShortString) and (FRange.Hi <> TLapeType_ShortString(Right.VarType).Range.Hi) then
    begin
      p := getEvalProc(op_Assign, ltShortString, ltUInt8);
      Assert(({$IFNDEF FPC}@{$ENDIF}p <> nil) and ({$IFNDEF FPC}@{$ENDIF}p <> {$IFNDEF FPC}@{$ENDIF}LapeEvalErrorProc));
      FCompiler.Emitter._Eval(p, Left, Right, getResVar(FCompiler.addManagedVar(FCompiler.getBaseType(ltUInt8).NewGlobalVarStr(IntToStr(FRange.Hi)))), Offset, Pos);
      Result := Left;
    end
    else
    begin
      if (FRange.Hi < High(UInt8)) then
      begin
        a := StackResVar;
        a.VarType := FCompiler.getBaseType(ltShortString);
        getDestVar(Dest, a, op_Unknown, FCompiler);
        Result := a.VarType.Eval(Op, Dest, a, Right, Offset, Pos)
      end
      else
        Result := inherited;

      if (Result.VarType <> nil) and (Result.VarType is TLapeType_ShortString) and (FRange.Hi <> TLapeType_ShortString(Result.VarType).Range.Hi) then
      begin
        Result := Eval(op_Assign, Dest, Left, Result, Offset, Pos);
        SetNullResVar(a, 1);
      end;
    end
  else
    Result := inherited;
end;

function TLapeType_Record.getAsString: lpString;
var
  i: Integer;
begin
  if (FAsString = '') then
  begin
    FAsString := 'record ';
    for i := 0 to FFieldMap.Count - 1 do
      FAsString := FAsString + '[' + IntToStr(FFieldMap.ItemsI[i].Offset) + ']' + FFieldMap.ItemsI[i].FieldType.AsString + '; ';
    FAsString := FAsString + 'end';
  end;
  Result := inherited;
end;

constructor TLapeType_Record.Create(ACompiler: TLapeCompilerBase; AFieldMap: TRecordFieldMap; AName: lpString = ''; ADocPos: PDocPos = nil);
const
  InvalidRec: TRecordField = (Offset: Word(-1); FieldType: nil);
begin
  inherited Create(ltRecord, ACompiler, AName, ADocPos);

  FreeFieldMap := (AFieldMap = nil);
  if (AFieldMap = nil) then
    AFieldMap := TRecordFieldMap.Create(InvalidRec);
  FFieldMap := AFieldMap;
end;

destructor TLapeType_Record.Destroy;
begin
  if FreeFieldMap then
    FFieldMap.Free();
  inherited;
end;

procedure TLapeType_Record.addField(FieldType: TLapeType; AName: lpString; Alignment: Byte = 1);
var
  Field: TRecordField;
begin
  if (FSize < 0) or (FFieldMap.Count < 1) then
    FSize := 0;
  if (FInit = __Unknown) or (FFieldMap.Count < 1) then
    FInit := __No;
  FAsString := '';
  Field.Offset := FSize;
  Field.FieldType := FieldType;
  if FFieldMap.ExistsItemI(AName) then
    LapeException(lpeDuplicateDeclaration, [AName]);
  FSize := FSize + FieldType.Size + (FieldType.Size mod Alignment);
  if (FInit <> __Yes) and FieldType.NeedInitialization then
    FInit := __Yes;
  FFieldMap[AName] := Field;
end;

function TLapeType_Record.Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean;
var
  i: Integer;
begin
  Result := inherited;
  if Result and (not ContextOnly) and (Other <> Self) and (Other is TLapeType_Record) then
  try
    for i := 0 to FFieldMap.Count - 1 do
      if (LapeCase(FFieldMap.Index[i]) <> LapeCase(TLapeType_Record(Other).FieldMap.Index[i])) then
        Exit(False);
  except
    Result := False;
  end;
end;

function TLapeType_Record.VarToString(v: Pointer): lpString;
var
  i: Integer;
begin
  Result := '{';
  for i := 0 to FFieldMap.Count - 1 do
  begin
    if (i > 0) then
      Result := Result + ', ';
    Result := Result + FFieldMap.Index[i] + ' = ' + FFieldMap.ItemsI[i].FieldType.VarToString(Pointer(PtrUInt(v) + FFieldMap.ItemsI[i].Offset));
  end;
  Result := Result + '}';
end;

function TLapeType_Record.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Record;
begin
  Result := TLapeClassType(Self.ClassType).Create(FCompiler, FFieldMap, Name, @DocPos);
  Result.FInit := FInit;
  Result.FSize := FSize;
end;

function TLapeType_Record.NewGlobalVar(AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
end;

function TLapeType_Record.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
var
  i: Integer;
begin
  if (op = op_Assign) and (Right <> nil) and (Right is TLapeType_Record) and
     (TLapeType_Record(Right).FieldMap.Count = FFieldMap.Count) then
  begin
    for i := 0 to FFieldMap.Count - 1 do
      if (not FFieldMap.ItemsI[i].FieldType.CompatibleWith(TLapeType_Record(Right).FieldMap.ItemsI[i].FieldType)) then
      begin
        Result := inherited;
        Exit;
      end;
    Result := Self
  end
  else
    Result := inherited;
end;

function TLapeType_Record.EvalRes(Op: EOperator; Right: TLapeGlobalVar): TLapeType;
begin
  if (Op = op_Dot) and (Right <> nil) and (Right.BaseType = ltString) then
    Result := FFieldMap[PlpString(Right.Ptr)^].FieldType
  else
    Result := inherited;
end;

function TLapeType_Record.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  i: Integer;
  s: lpString;
  l, r, ls, rs: TLapeGlobalVar;
begin
  Assert((Left = nil) or (Left.VarType = Self));
  if (Op = op_Dot) and (Left <> nil) and (Right <> nil) and (Right.VarType <> nil) and (Right.VarType.BaseType = ltString) then
  begin
    if (Right.Ptr <> nil) then
      s := PlpString(Right.Ptr)^
    else
      s := '';
    if (s <> '') and FFieldMap.ExistsItemI(s) then
      Result := FFieldMap[s].FieldType.NewGlobalVarP(Pointer(PtrUInt(Left.Ptr) + FFieldMap[s].Offset))
    else
      LapeException(lpeUnknownDeclaration, [s]);
    Result.isConstant := Left.isConstant;
  end
  else if (op = op_Assign) and (Right <> nil) and (Right.VarType <> nil) and CompatibleWith(Right.VarType) then
  begin
    ls := nil;
    rs := nil;
    l := nil;
    r := nil;

    for i := 0 to FFieldMap.Count - 1 do
    try
      ls := FCompiler.getBaseType(ltString).NewGlobalVarStr(FFieldMap.Index[i]);
      rs := FCompiler.getBaseType(ltString).NewGlobalVarStr(TLapeType_Record(Right.VarType).FieldMap.Index[i]);

      l := EvalConst(op_Dot, Left, ls);
      r := Right.VarType.EvalConst(op_Dot, Right, rs);
      l.VarType.EvalConst(op_Assign, l, r);
    finally
      if (ls <> nil) then
        FreeAndNil(ls);
      if (rs <> nil) then
        FreeAndNil(rs);
      if (l <> nil) then
        FreeAndNil(l);
      if (r <> nil) then
        FreeAndNil(r);
    end;
    Result := Left;
  end
  else
    inherited;
end;

function TLapeType_Record.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  i: Integer;
  s: lpString;
  a, l, r, ls, rs: TResVar;
  v: TLapeType;
begin
  Assert(FCompiler <> nil);
  Assert(Left.VarType = Self);
  a := NullResVar;

  if (Op = op_Dot) and (Right.VarPos.MemPos = mpMem) and (Right.VarType <> nil) and (Right.VarType.BaseType = ltString) then
  begin
    if (Right.VarPos.GlobalVar.Ptr <> nil) then
      s := PlpString(Right.VarPos.GlobalVar.Ptr)^
    else
      s := '';

    setNullResVar(Dest);
    Result := Left;
    if (s = '') or (not FFieldMap.ExistsItemI(s)) then
      LapeException(lpeUnknownDeclaration, [s]);

    Result.VarType := FFieldMap[s].FieldType;
    case Left.VarPos.MemPos of
      mpMem:
        begin
          Result.VarPos.GlobalVar := TLapeGlobalVar(FCompiler.addManagedVar(Result.VarType.NewGlobalVarP(Pointer(PtrUInt(Left.VarPos.GlobalVar.Ptr) + FFieldMap[s].Offset))));
          Result.VarPos.GlobalVar.isConstant := Left.VarPos.GlobalVar.isConstant;
        end;
      mpVar:
        begin
          Result.VarPos.Offset := Result.VarPos.Offset + FFieldMap[s].Offset;
          Result.VarPos.StackVar.isConstant := Left.VarPos.StackVar.isConstant;
        end;
      mpStack:
        begin
          Result.VarPos.Offset := Result.VarPos.Offset - FFieldMap[s].Offset;
          Result.VarPos.ForceVariable := Left.VarPos.ForceVariable;
        end;
      else LapeException(lpeImpossible);
    end
  end
  else if (op = op_Assign) and (Right.VarType <> nil) and CompatibleWith(Right.VarType) then
    if (not NeedInitialization) and Equals(Right.VarType) and (Size in [1, 2, 4, 8]) then
    try
      v := Right.VarType;
      case Size of
        1: Left.VarType := FCompiler.getBaseType(ltUInt8);
        2: Left.VarType := FCompiler.getBaseType(ltUInt16);
        4: Left.VarType := FCompiler.getBaseType(ltUInt32);
        8: Left.VarType := FCompiler.getBaseType(ltUInt64);
      end;
      Right.VarType := Left.VarType;
      Result := Left.VarType.Eval(op_Assign, Dest, Left, Right, Offset, Pos);
    finally
      Left.VarType := Self;
      Right.VarType := v;
    end
    else
    begin
      for i := 0 to FFieldMap.Count - 1 do
      try
        ls := getResVar(FCompiler.addManagedVar(FCompiler.getBaseType(ltString).NewGlobalVarStr(FFieldMap.Index[i])));
        rs := getResVar(FCompiler.addManagedVar(FCompiler.getBaseType(ltString).NewGlobalVarStr(TLapeType_Record(Right.VarType).FieldMap.Index[i])));

        l := Eval(op_Dot, a, Left, ls, Offset, Pos);
        r := Right.VarType.Eval(op_Dot, a, Right, rs, Offset, Pos);
        l.VarType.Eval(op_Assign, Dest, l, r, Offset, Pos);
      finally
        SetNullResVar(l, 1);
        SetNullResVar(r, 1);
      end;
      Result := Left;
    end
  else
    inherited;
end;

procedure TLapeType_Record.Finalize(v: TResVar; var Offset: Integer; UseCompiler: Boolean = True; Pos: PDocPos = nil);
var
  i: Integer;
  _v: TResVar;
begin
  Assert(v.VarType = Self);
  if (v.VarPos.MemPos = NullResVar.VarPos.MemPos) or (not NeedFinalization) then
    Exit;

  for i := 0 to FFieldMap.Count - 1 do
  try
    _v := v;
    _v.VarType := FFieldMap.ItemsI[i].FieldType;
    case _v.VarPos.MemPos of
      mpMem:
        if UseCompiler and (FCompiler <> nil) then
          _v.VarPos.GlobalVar := TLapeGlobalVar(FCompiler.addManagedVar(_v.VarType.NewGlobalVarP(Pointer(PtrUInt(_v.VarPos.GlobalVar.Ptr) + FFieldMap.ItemsI[i].Offset))))
        else
          _v.VarPos.GlobalVar := _v.VarType.NewGlobalVarP(Pointer(PtrUInt(_v.VarPos.GlobalVar.Ptr) + FFieldMap.ItemsI[i].Offset));
      mpVar: _v.VarPos.Offset := _v.VarPos.Offset + FFieldMap.ItemsI[i].Offset;
      else LapeException(lpeImpossible);
    end;
    _v.VarType.Finalize(_v, Offset, UseCompiler, Pos);
  finally
    if ((not UseCompiler) or (FCompiler = nil)) and (_v.VarPos.MemPos = mpMem) and (_v.VarPos.GlobalVar <> nil) then
      FreeAndNil(_v.VarPos.GlobalVar);
    setNullResVar(_v, 1);
  end;
end;

function TLapeType_Union.getAsString: lpString;
var
  i: Integer;
begin
  if (FAsString = '') then
  begin
    FAsString := 'union ';
    for i := 0 to FFieldMap.Count - 1 do
      FAsString := FAsString + FFieldMap.ItemsI[i].FieldType.AsString + '; ';
    FAsString := FAsString + 'end';
  end;
  Result := inherited;
end;

constructor TLapeType_Union.Create(ACompiler: TLapeCompilerBase; AFieldMap: TRecordFieldMap; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited;
  FBaseType := ltUnion;
end;

procedure TLapeType_Union.addField(FieldType: TLapeType; AName: lpString; Alignment: Byte = 1);
var
  Field: TRecordField;
  m: Integer;
begin
  if (FSize < 0) or (FFieldMap.Count < 1) then
    FSize := 0;
  if (FInit = __Unknown) or (FFieldMap.Count < 1) then
    FInit := __No;
  FAsString := '';
  Field.Offset := 0;
  Field.FieldType := FieldType;
  if FFieldMap.ExistsItemI(AName) then
    LapeException(lpeDuplicateDeclaration, [AName]);
  m := FieldType.Size + (FieldType.Size mod Alignment);
  if (m > FSize) then
    FSize := m;
  if (FInit <> __Yes) and FieldType.NeedInitialization then
    FInit := __Yes;
  FFieldMap[AName] := Field;
end;

function TLapeType_Method.getSize: Integer;
begin
  if (FSize = 0) then
    FSize := LapeTypeSize[ltImportedMethod];
  Result := inherited;
end;

function TLapeType_Method.getAsString: lpString;
var
  i: Integer;
begin
  if (FAsString = '') then
  begin
    if (Res <> nil) then
      FAsString := 'function('
    else
      FAsString := 'procedure(';

    for i := 0 to FParams.Count - 1 do
    begin
      if (i > 0) then
        FAsString := FAsString + ',';
      if (FParams[i].ParType in Lape_RefParams) then
        FAsString := FAsString + '<';
      if (FParams[i].Default <> nil) then
        FAsString := FAsString + '[';
      if (FParams[i].VarType = nil) then
        FAsString := FAsString + '*unknown*'
      else
        FAsString := FAsString + FParams[i].VarType.AsString;
      if (FParams[i].Default <> nil) then
        FAsString := FAsString + ']';
      if (FParams[i].ParType in Lape_RefParams) then
        FAsString := FAsString + '>';
    end;

    FAsString := FAsString + ')';
    if (Res <> nil) then
      FAsString := FAsString + ':' + Res.AsString;
  end;
  Result := inherited;
end;

function TLapeType_Method.getParamSize: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FParams.Count - 1 do
    if (FParams[i].ParType in Lape_RefParams) then
      Result := Result + SizeOf(Pointer)
    else
      Result := Result + FParams[i].VarType.Size;
  if (Res <> nil) then
    Result := Result + SizeOf(Pointer);
end;

function TLapeType_Method.getParamInitialization: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FParams.Count - 1 do
    if (not (FParams[i].ParType in Lape_RefParams)) and (FParams[i].VarType <> nil) and FParams[i].VarType.NeedInitialization then
      Exit(True);
end;

constructor TLapeType_Method.Create(ACompiler: TLapeCompilerBase; AParams: TLapeParameterList; ARes: TLapeType = nil; AName: lpString = ''; ADocPos: PDocPos = nil);
const
  NullPar: TLapeParameter = (ParType: lptNormal; VarType: nil; Default: nil);
begin
  inherited Create(ltPointer, ACompiler, AName, ADocPos);

  FreeParams := (AParams = nil);
  if (AParams = nil) then
    AParams := TLapeParameterList.Create(NullPar, dupAccept);
  FParams := AParams;
  Res := ARes;
end;

constructor TLapeType_Method.Create(ACompiler: TLapeCompilerBase; AParams: array of TLapeType; AParTypes: array of ELapeParameterType; AParDefaults: array of TLapeGlobalVar; ARes: TLapeType = nil; AName: lpString = ''; ADocPos: PDocPos = nil);
var
  a: TLapeParameter;
  i: Integer;
begin
  if (Length(AParams) <> Length(AParTypes)) or (Length(AParams) <> Length(AParDefaults)) then
    LapeException(lpeArrayLengthsDontMatch, [Format('%d, %d, %d', [Length(AParams), Length(AParTypes), Length(AParDefaults)])]);

  Create(ACompiler, nil, ARes, AName, ADocPos);
  for i := 0 to High(AParams) do
  begin
    a.ParType := AParTypes[i];
    a.VarType := AParams[i];
    a.Default := AParDefaults[i];
    FParams.add(a);
  end;
end;

destructor TLapeType_Method.Destroy;
begin
  if FreeParams then
    FParams.Free();
  inherited;
end;

function TLapeType_Method.Equals(Other: TLapeType; ContextOnly: Boolean = True): Boolean;
begin
  if ContextOnly and (Other <> nil) and (Other is TLapeType_Method) and (Other.AsString = AsString) then
    Result := True
  else
    Result := inherited;
end;

function TLapeType_Method.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_Method;
begin
  Result := TLapeClassType(Self.ClassType).Create(FCompiler, FParams, Res, Name, @DocPos);
  Result.FBaseType := FBaseType;
end;

procedure TLapeType_Method.addParam(p: TLapeParameter);
begin
  if (p.VarType = nil) and (p.Default = nil) then
    LapeException(lpeImpossible);
  FParams.Add(p);
end;

procedure TLapeType_Method.setImported(v: TLapeGlobalVar; isImported: Boolean);
var
  b: ELapeBaseType;
begin
  if isImported then
    b := ltImportedMethod
  else
    b := ltScriptMethod;

  if (v = nil) or ((v.VarType <> nil) and (v.VarType.BaseType = b)) then
    Exit;

  v.FVarType := CreateCopy();
  v.FVarType.FBaseType := b;
  if (FCompiler <> nil) then
    v.FVarType := FCompiler.addManagedType(v.FVarType);
end;

function TLapeType_Method.NewGlobalVar(Ptr: Pointer = nil; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  setImported(Result, True);
  PPointer(Result.Ptr)^ := Ptr;
end;

function TLapeType_Method.NewGlobalVar(CodePos: TCodePos; AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
  setImported(Result, False);
  PCodePos(Result.Ptr)^ := CodePos;
end;

function TLapeType_Method.EvalRes(Op: EOperator; Right: TLapeType = nil): TLapeType;
begin
  if (FBaseType = ltPointer) and (Op = op_Assign) and (Right <> nil) and ((Right.BaseType = ltPointer) or Equals(Right)) then
    Result := Self
  else
    Result := inherited;
end;

function TLapeType_Method.EvalConst(Op: EOperator; Left, Right: TLapeGlobalVar): TLapeGlobalVar;
var
  t: TLapeType;
begin
  if (FBaseType = ltPointer) and (Op = op_Assign) and (Right <> nil) and (Right.VarType <> nil) and ((Right.VarType.BaseType = ltPointer) or Equals(Right.VarType)) then
    try
      FBaseType := ltImportedMethod;
      t := Right.FVarType;
      if (t.BaseType = ltPointer) then
        Right.FVarType := Self;
      Result := inherited;
    finally
      FBaseType := ltPointer;
      Right.FVarType := t;
    end
  else
    Result := inherited;
end;

function TLapeType_Method.Eval(Op: EOperator; var Dest: TResVar; Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): TResVar;
var
  t: TLapeType;
begin
  if (FBaseType = ltPointer) and (Op = op_Assign) and (Right.VarType <> nil) and ((Right.VarType.BaseType = ltPointer) or Equals(Right.VarType)) then
    try
      FBaseType := ltImportedMethod;
      t := Right.VarType;
      if (t.BaseType = ltPointer) then
        Right.VarType := Self;
      Result := inherited;
    finally
      FBaseType := ltPointer;
      Right.VarType := t;
    end
  else
    Result := inherited;
end;

constructor TLapeType_OverloadedMethod.Create(ACompiler: TLapeCompilerBase; AMethods: TLapeDeclarationList; AName: lpString = ''; ADocPos: PDocPos = nil);
begin
  inherited Create(ltUnknown, ACompiler, AName, ADocPos);

  FreeMethods := (AMethods = nil);
  if (AMethods = nil) then
    AMethods := TLapeDeclarationList.Create(nil);
  FMethods := AMethods;
end;

destructor TLapeType_OverloadedMethod.Destroy;
begin
  if FreeMethods then
    FMethods.Free();
  inherited;
end;

function TLapeType_OverloadedMethod.CreateCopy: TLapeType;
type TLapeClassType = class of TLapeType_OverloadedMethod;
begin
  Result := TLapeClassType(Self.ClassType).Create(FCompiler, FMethods, Name, @DocPos);
end;

function TLapeType_OverloadedMethod.NewGlobalVar(AName: lpString = ''; ADocPos: PDocPos = nil): TLapeGlobalVar;
begin
  Result := NewGlobalVarP(nil, AName, ADocPos);
end;

procedure TLapeType_OverloadedMethod.addMethod(AMethod: TLapeGlobalVar);
var
  i: Integer;
begin
  if (AMethod = nil) or (AMethod.VarType = nil) or (not (AMethod.VarType is TLapeType_Method)) then
    LapeException(lpeImpossible);
  for i := 0 to FMethods.Items.Count - 1 do
    if (TLapeGlobalVar(FMethods.Items[i]).VarType.Equals(AMethod.VarType)) then
      LapeException(lpeDuplicateDeclaration, [AMethod.VarType.AsString]);
  FMethods.addDeclaration(AMethod);
end;

function TLapeType_OverloadedMethod.getMethod(AType: TLapeType_Method): TLapeGlobalVar;
var
  i: Integer;
begin
  for i := 0 to FMethods.Items.Count - 1 do
    if (TLapeGlobalVar(FMethods.Items[i]).VarType.Equals(AType)) then
      Exit(TLapeGlobalVar(FMethods.Items[i]));
  Result := nil;
end;

function TLapeType_OverloadedMethod.getMethod(AParams: TLapeTypeArray; AResult: TLapeType = nil): TLapeGlobalVar;
var
  m, i, c, min_c: Integer;
  Match: Boolean;

  function SizeWeight(a, b: TLapeType): Integer; {$IFDEF Lape_Inline}inline;{$ENDIF}
  begin
    Result := Abs(a.Size - b.Size);
    if (a.Size > b.Size) then
      Result := Result * 8;
  end;

begin
  Result := nil;
  min_c := High(Integer);

  for m := 0 to FMethods.Items.Count - 1 do
    with TLapeType_Method(TLapeGlobalVar(FMethods.Items[m]).VarType) do
    begin
      if (Length(AParams) > Params.Count) or ((AResult <> nil) and (Res = nil)) then
        Continue;

      if (AResult = nil) or AResult.Equals(Res) then
        c := Params.Count
      else if (not AResult.CompatibleWith(Res)) then
        Continue
      else
        c := SizeWeight(AResult, Res) + Params.Count + 1;

      Match := True;
      for i := 0 to Params.Count - 1 do
      begin
        Match := False;
        if ((i >= Length(AParams)) or (AParams[i] = nil)) and (Params[i].Default = nil) then
          Break
        else if (((i >= Length(AParams)) or (AParams[i] = nil)) and (Params[i].Default <> nil)) or ((Params[i].VarType <> nil) and Params[i].VarType.Equals(AParams[i])) then
          c := c - 1
        else if (Params[i].ParType in Lape_RefParams) then
          Break
        else if (Params[i].VarType <> nil) and (not Params[i].VarType.CompatibleWith(AParams[i])) then
          Break
        else if (Params[i].VarType <> nil) then
          c := c + SizeWeight(Params[i].VarType, AParams[i]);
        Match := True;
      end;

      if Match then
        if (c = min_c) then
          Result := nil
        else if (c < min_c) then
        begin
          Result := TLapeGlobalVar(FMethods.Items[m]);
          min_c := c;
        end;
    end;
end;

function TLapeStackInfo.getVar(Index: Integer): TLapeStackVar;
begin
  Result := FVarStack[Index];
end;

function TLapeStackInfo.getCount: Integer;
begin
  Result := FVarStack.Count;
end;

function TLapeStackInfo.getTotalSize: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FVarStack.Count - 1 do
    Result := Result + FVarStack[i].Size;
end;

function TLapeStackInfo.getTotalParamSize: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FVarStack.Count - 1 do
    if (FVarStack[i] is TLapeParameterVar) then
      Result := Result + FVarStack[i].Size;
end;

function TLapeStackInfo.getTotalNoParamSize: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FVarStack.Count - 1 do
    if (not (FVarStack[i] is TLapeParameterVar)) then
      Result := Result + FVarStack[i].Size;
end;

function TLapeStackInfo.getInitialization: Boolean;
{$IFDEF Lape_AlwaysInitialize}
begin Result := True;
{$ELSE}
var
  i: Integer;
begin
  for i := 0 to FVarStack.Count - 1 do
    if FVarStack[i].NeedInitialization then
      Exit(True);
  Result := False;
{$ENDIF}
end;

function TLapeStackInfo.getFinalization: Boolean;
var
  i: Integer;
begin
  for i := 0 to FVarStack.Count - 1 do
    if FVarStack[i].NeedFinalization then
      Exit(True);
  Result := False;
end;

constructor TLapeStackInfo.Create(AOwner: TLapeStackInfo = nil; ManageVars: Boolean = True);
begin
  inherited Create();

  Owner := AOwner;
  FDeclarations := TLapeDeclCollection.Create(nil);
  FVarStack := TLapeVarStack.Create(nil);
  FreeVars := ManageVars;
  CodePos := -1;
end;

destructor TLapeStackInfo.Destroy;
var
  i: Integer;
begin
  FDeclarations.Free();
  for i := FVarStack.Count - 1 downto 0 do
    if FreeVars then
      FVarStack[i].Free()
    else
      FVarStack[i].Stack := nil;
  FVarStack.Free();

  inherited;
end;

function TLapeStackInfo.getDeclaration(Name: lpString): TLapeDeclaration;
var
  i: Integer;
begin
  Name := LapeCase(Name);
  for i := 0 to FDeclarations.Count - 1 do
    if (LapeCase(FDeclarations[i].Name) = Name) then
      Exit(FDeclarations[i]);
  Result := nil;
end;

function TLapeStackInfo.hasDeclaration(Name: lpString): Boolean;
begin
  Result := getDeclaration(Name) <> nil;
end;

function TLapeStackInfo.getTempVar(VarType: TLapeType; Lock: Integer = 1): TLapeStackTempVar;
var
  i: Integer;
begin
  if (VarType = nil) then
    Exit(nil);

  try
    for i := 0 to FVarStack.Count - 1 do
      if (FVarStack[i] is TLapeStackTempVar) and (not TLapeStackTempVar(FVarStack[i]).Locked) and FVarStack[i].VarType.Equals(VarType) then
      begin
        Result := TLapeStackTempVar(FVarStack[i]);
        Result.FVarType := VarType;
        Exit;
      end;
    Result := TLapeStackTempVar(addVar(VarType));
  finally
    TLapeStackTempVar(Result).IncLock(Lock);
  end;
end;

function TLapeStackInfo.addDeclaration(Decl: TLapeDeclaration): Integer;
begin
  if FDeclarations.ExistsItem(Decl) or ((Decl.Name <> '') and hasDeclaration(Decl.Name)) then
    LapeException(lpeDuplicateDeclaration, [Decl.Name]);
  Result := FDeclarations.add(Decl);
end;

function TLapeStackInfo.addVar(StackVar: TLapeStackVar): TLapeStackVar;
begin
  if (StackVar = nil) then
    Exit(nil);
  StackVar.Stack := FVarStack;
  Result := StackVar;
  addDeclaration(StackVar);
end;

function TLapeStackInfo.addVar(VarType: TLapeType; Name: lpString = ''): TLapeStackVar;
begin
  if (Name = '') then
    Result := addVar(TLapeStackTempVar.Create(VarType, nil, Name))
  else
    Result := addVar(TLapeStackVar.Create(VarType, nil, Name));
end;

function TLapeStackInfo.addVar(ParType: ELapeParameterType; VarType: TLapeType; Name: lpString = ''): TLapeStackVar;
begin
  Result := addVar(TLapeParameterVar.Create(ParType, VarType, nil, Name));
end;

function TLapeCodeEmitter._IncCall(ACodePos: TResVar; AParamSize: UInt16; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;
var
  e: Boolean;
begin
  Assert(ACodePos.VarType <> nil);
  e := False;

  case getMemoryPos(ACodePos.VarPos) of
    //mmpStk: Result := _IncCall_Stk(AParamSize + ACodePos.VarType.Size, AParamSize, Offset, Pos);
    //mmpPStk: Result := _IncCall_PStk(AParamSize, Offset, Pos);
    mmpVar: Result := _IncCall_Var(ACodePos.VarPos.StackVar.Offset + ACodePos.VarPos.Offset, AParamSize, Offset, Pos);
    mmpPVar: Result := _IncCall_PVar(ACodePos.VarPos.StackVar.Offset, ACodePos.VarPos.Offset, AParamSize, Offset, Pos);
    mmpPtr: Result := _IncCall_Ptr(ACodePos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
    else e := True;
  end;

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._IncCall(ACodePos: TResVar; AParamSize: UInt16; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _IncCall(ACodePos, AParamSize, o, Pos);
end;

function TLapeCodeEmitter._InvokeImportedProc(AMemPos: TResVar; AParamSize: UInt16; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;
var
  e: Boolean;
begin
  Assert(AMemPos.VarType <> nil);
  e := False;

  case getMemoryPos(AMemPos.VarPos) of
    //mmpStk: Result := _InvokeImported_Stk(AParamSize + AMemPos.VarType.Size, AParamSize, Offset, Pos);
    //mmpPStk: Result := _InvokeImported_PStk(AParamSize, Offset, Pos);
    mmpVar: Result := _InvokeImported_Var(AMemPos.VarPos.StackVar.Offset + AMemPos.VarPos.Offset, AParamSize, Offset, Pos);
    mmpPVar: Result := _InvokeImported_PVar(AMemPos.VarPos.StackVar.Offset, AMemPos.VarPos.Offset, AParamSize, Offset, Pos);
    mmpPtr: Result := _InvokeImported_Ptr(AMemPos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
    else e := True;
  end;

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._InvokeImportedProc(AMemPos: TResVar; AParamSize: UInt16; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _InvokeImportedProc(AMemPos, AParamSize, o, Pos);
end;

function TLapeCodeEmitter._InvokeImportedFunc(AMemPos, AResPos: TResVar; AParamSize: UInt16; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;
var
  e: Boolean;
begin
  Assert(AMemPos.VarType <> nil);
  Assert(AResPos.VarType <> nil);
  e := False;

  case getMemoryPos(AMemPos.VarPos) of
    {
    mmpStk: case getMemoryPos(AResPos.VarPos) of
      mmpStk: Result := _InvokeImported_Stk_Stk(AParamSize + AMemPos.VarType.Size, AParamSize, AResPos.VarType.Size, Offset, Pos);
      mmpPStk: Result := _InvokeImported_Stk_PStk(AParamSize + AMemPos.VarType.Size, AParamSize, Offset, Pos);
      mmpVar: Result := _InvokeImported_Stk_Var(AParamSize + AMemPos.VarType.Size, AResPos.VarPos.StackVar.Offset + AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPVar: Result := _InvokeImported_Stk_PVar(AParamSize + AMemPos.VarType.Size, AResPos.VarPos.StackVar.Offset, AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPtr: Result := _InvokeImported_Stk_Ptr(AParamSize + AMemPos.VarType.Size, AResPos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
      else e := True;
    end;
    }
    mmpVar: case getMemoryPos(AResPos.VarPos) of
      mmpStk: Result := _InvokeImported_Var_Stk(AMemPos.VarPos.StackVar.Offset + AMemPos.VarPos.Offset, AParamSize, AResPos.VarType.Size, Offset, Pos);
      {$IFDEF Lape_PStkD}
      mmpPStk: Result := _InvokeImported_Var_PStk(AMemPos.VarPos.StackVar.Offset + AMemPos.VarPos.Offset, AParamSize, Offset, Pos);
      {$ENDIF}
      mmpVar: Result := _InvokeImported_Var_Var(AMemPos.VarPos.StackVar.Offset + AMemPos.VarPos.Offset, AResPos.VarPos.StackVar.Offset + AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPVar: Result := _InvokeImported_Var_PVar(AMemPos.VarPos.StackVar.Offset + AMemPos.VarPos.Offset, AResPos.VarPos.StackVar.Offset, AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPtr: Result := _InvokeImported_Var_Ptr(AMemPos.VarPos.StackVar.Offset + AMemPos.VarPos.Offset, AResPos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
      else e := True;
    end;
    mmpPVar: case getMemoryPos(AResPos.VarPos) of
      mmpStk: Result := _InvokeImported_PVar_Stk(AMemPos.VarPos.StackVar.Offset, AMemPos.VarPos.Offset, AParamSize, AResPos.VarType.Size, Offset, Pos);
      {$IFDEF Lape_PStkD}
      mmpPStk: Result := _InvokeImported_PVar_PStk(AMemPos.VarPos.StackVar.Offset, AMemPos.VarPos.Offset, AParamSize, Offset, Pos);
      {$ENDIF}
      mmpVar: Result := _InvokeImported_PVar_Var(AMemPos.VarPos.StackVar.Offset, AResPos.VarPos.StackVar.Offset + AResPos.VarPos.Offset, AMemPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPVar: Result := _InvokeImported_PVar_PVar(AMemPos.VarPos.StackVar.Offset, AResPos.VarPos.StackVar.Offset, AMemPos.VarPos.Offset, AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPtr: Result := _InvokeImported_PVar_Ptr(AMemPos.VarPos.StackVar.Offset, AMemPos.VarPos.Offset, AResPos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
      else e := True;
    end;
    mmpPtr: case getMemoryPos(AResPos.VarPos) of
      mmpStk: Result := _InvokeImported_Ptr_Stk(AMemPos.VarPos.GlobalVar.Ptr, AParamSize, AResPos.VarType.Size, Offset, Pos);
      {$IFDEF Lape_PStkD}
      mmpPStk: Result := _InvokeImported_Ptr_PStk(AMemPos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
      {$ENDIF}
      mmpVar: Result := _InvokeImported_Ptr_Var(AMemPos.VarPos.GlobalVar.Ptr, AResPos.VarPos.StackVar.Offset + AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPVar: Result := _InvokeImported_Ptr_PVar(AMemPos.VarPos.GlobalVar.Ptr, AResPos.VarPos.StackVar.Offset, AResPos.VarPos.Offset, AParamSize, Offset, Pos);
      mmpPtr: Result := _InvokeImported_Ptr_Ptr(AMemPos.VarPos.GlobalVar.Ptr, AResPos.VarPos.GlobalVar.Ptr, AParamSize, Offset, Pos);
      else e := True;
    end;
    else e := True;
  end;

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._InvokeImportedFunc(AMemPos, AResPos: TResVar; AParamSize: UInt16; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _InvokeImportedFunc(AMemPos, AResPos, AParamSize, o, Pos);
end;

{
function TLapeCodeEmitter._JmpIf(Target: TCodePos; Cond: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;
var
  e: Boolean;
begin
  Assert(Cond.VarType <> nil);
  e := False;

  case getMemoryPos(Cond.VarPos) of
    mmpStk:
      case Cond.VarType.Size of
        1: Result := _JmpIf8_Stk(Target, Offset, Pos);
        2: Result := _JmpIf16_Stk(Target, Offset, Pos);
        4: Result := _JmpIf32_Stk(Target, Offset, Pos);
        8: Result := _JmpIf64_Stk(Target, Offset, Pos);
        else e := True;
      end;
    mmpVar:
      case Cond.VarType.Size of
        1: Result := _JmpIf8_Var(Target, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        2: Result := _JmpIf16_Var(Target, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        4: Result := _JmpIf32_Var(Target, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        8: Result := _JmpIf64_Var(Target, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        else e := True;
      end;
    mmpPtr:
      case Cond.VarType.Size of
        1: Result := _JmpIf8_Ptr(Target, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        2: Result := _JmpIf16_Ptr(Target, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        4: Result := _JmpIf32_Ptr(Target, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        8: Result := _JmpIf64_Ptr(Target, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        else e := True;
      end;
    mmpPStk:
      case Cond.VarType.Size of
        1: Result := _JmpIf8_PStk(Target, Offset, Pos);
        2: Result := _JmpIf16_PStk(Target, Offset, Pos);
        4: Result := _JmpIf32_PStk(Target, Offset, Pos);
        8: Result := _JmpIf64_PStk(Target, Offset, Pos);
        else e := True;
      end;
    mmpPVar:
      case Cond.VarType.Size of
        1: Result := _JmpIf8_PVar(Target, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        2: Result := _JmpIf16_PVar(Target, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        4: Result := _JmpIf32_PVar(Target, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        8: Result := _JmpIf64_PVar(Target, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        else e := True;
      end;
    else e := True;
  end;

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._JmpIf(Target: TCodePos; Cond: TResVar; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _JmpIf(Target, Cond, o, Pos);
end;
}

function TLapeCodeEmitter._JmpRIf(Jmp: TCodeOffset; Cond: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;
var
  e: Boolean;
begin
  Assert(Cond.VarType <> nil);
  e := False;

  case getMemoryPos(Cond.VarPos) of
    mmpStk:
      case Cond.VarType.Size of
        1: Result := _JmpRIf8_Stk(Jmp, Offset, Pos);
        2: Result := _JmpRIf16_Stk(Jmp, Offset, Pos);
        4: Result := _JmpRIf32_Stk(Jmp, Offset, Pos);
        8: Result := _JmpRIf64_Stk(Jmp, Offset, Pos);
        else e := True;
      end;
    mmpVar:
      case Cond.VarType.Size of
        1: Result := _JmpRIf8_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        2: Result := _JmpRIf16_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        4: Result := _JmpRIf32_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        8: Result := _JmpRIf64_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        else e := True;
      end;
    mmpPtr:
      case Cond.VarType.Size of
        1: Result := _JmpRIf8_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        2: Result := _JmpRIf16_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        4: Result := _JmpRIf32_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        8: Result := _JmpRIf64_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        else e := True;
      end;
    mmpPStk:
      case Cond.VarType.Size of
        1: Result := _JmpRIf8_PStk(Jmp, Offset, Pos);
        2: Result := _JmpRIf16_PStk(Jmp, Offset, Pos);
        4: Result := _JmpRIf32_PStk(Jmp, Offset, Pos);
        8: Result := _JmpRIf64_PStk(Jmp, Offset, Pos);
        else e := True;
      end;
    mmpPVar:
      case Cond.VarType.Size of
        1: Result := _JmpRIf8_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        2: Result := _JmpRIf16_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        4: Result := _JmpRIf32_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        8: Result := _JmpRIf64_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        else e := True;
      end;
    else e := True;
  end;

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._JmpRIf(Jmp: TCodeOffset; Cond: TResVar; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _JmpRIf(Jmp, Cond, o, Pos);
end;

function TLapeCodeEmitter._JmpRIfNot(Jmp: TCodeOffset; Cond: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;
var
  e: Boolean;
begin
  Assert(Cond.VarType <> nil);
  e := False;

  case getMemoryPos(Cond.VarPos) of
    mmpStk:
      case Cond.VarType.Size of
        1: Result := _JmpRIfNot8_Stk(Jmp, Offset, Pos);
        2: Result := _JmpRIfNot16_Stk(Jmp, Offset, Pos);
        4: Result := _JmpRIfNot32_Stk(Jmp, Offset, Pos);
        8: Result := _JmpRIfNot64_Stk(Jmp, Offset, Pos);
        else e := True;
      end;
    mmpVar:
      case Cond.VarType.Size of
        1: Result := _JmpRIfNot8_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        2: Result := _JmpRIfNot16_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        4: Result := _JmpRIfNot32_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        8: Result := _JmpRIfNot64_Var(Jmp, Cond.VarPos.StackVar.Offset + Cond.VarPos.Offset, Offset, Pos);
        else e := True;
      end;
    mmpPtr:
      case Cond.VarType.Size of
        1: Result := _JmpRIfNot8_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        2: Result := _JmpRIfNot16_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        4: Result := _JmpRIfNot32_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        8: Result := _JmpRIfNot64_Ptr(Jmp, Cond.VarPos.GlobalVar.Ptr, Offset, Pos);
        else e := True;
      end;
    mmpPStk:
      case Cond.VarType.Size of
        1: Result := _JmpRIfNot8_PStk(Jmp, Offset, Pos);
        2: Result := _JmpRIfNot16_PStk(Jmp, Offset, Pos);
        4: Result := _JmpRIfNot32_PStk(Jmp, Offset, Pos);
        8: Result := _JmpRIfNot64_PStk(Jmp, Offset, Pos);
        else e := True;
      end;
    mmpPVar:
      case Cond.VarType.Size of
        1: Result := _JmpRIfNot8_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        2: Result := _JmpRIfNot16_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        4: Result := _JmpRIfNot32_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        8: Result := _JmpRIfNot64_PVar(Jmp, Cond.VarPos.StackVar.Offset, Cond.VarPos.Offset, Offset, Pos);
        else e := True;
      end;
    else e := True;
  end;

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._JmpRIfNot(Jmp: TCodeOffset; Cond: TResVar; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _JmpRIfNot(Jmp, Cond, o, Pos);
end;

function TLapeCodeEmitter._Eval(AProc: TLapeEvalProc; Dest, Left, Right: TResVar; var Offset: Integer; Pos: PDocPos = nil): Integer;
type
  EMyMemoryPos = (mmpNone, mmpPtr, mmpVar, mmpStk, mmpPVar, mmpPStk);

  function getMemoryPos(v: TVarPos): EMyMemoryPos; inline;
  begin
    Result := mmpNone;
    case v.MemPos of
      mpMem:
        if v.isPointer then
          LapeException(lpeImpossible)
        else
          Result := mmpPtr;
      mpVar:
        if v.isPointer then
          Result := mmpPVar
        else
          Result := mmpVar;
      mpStack:
        if v.isPointer then
          Result := mmpPStk
        else
          Result := mmpStk;
    end;
  end;

var
  d, l, r: EMyMemoryPos;
  StackIncD, StackIncL, StackIncR: TStackInc;
  e: Boolean;
begin
  Assert({$IFNDEF FPC}@{$ENDIF}AProc <> nil);
  Assert((Dest.VarType <> nil) and (Left.VarType <> nil));

  d := getMemoryPos(Dest.VarPos);
  l := getMemoryPos(Left.VarPos);
  r := getMemoryPos(Right.VarPos);
  e := False;

  StackIncD := Dest.VarType.Size;
  if (Left.VarPos.MemPos = mpStack) and Left.VarPos.ForceVariable then
    StackIncL := 0
  else if Left.VarPos.isPointer then
    StackIncL := SizeOf(Pointer)
  else
    StackIncL := Left.VarType.Size;
  if (Right.VarType = nil) or ((Right.VarPos.MemPos = mpStack) and Right.VarPos.ForceVariable) then
    StackIncR := 0
  else if Right.VarPos.isPointer then
    StackIncR := SizeOf(Pointer)
  else
    StackIncR := Right.VarType.Size;

  {$I lpcodeemitter_evalcase.inc}

  if e then
    LapeException(lpeInvalidEvaluation);
end;

function TLapeCodeEmitter._Eval(AProc: TLapeEvalProc; Dest, Left, Right: TResVar; Pos: PDocPos = nil): Integer;
var o: Integer;
begin
  o := -1;
  Result := _Eval(AProc, Dest, Left, Right, o, Pos);
end;

procedure TLapeCompilerBase.setEmitter(AEmitter: TLapeCodeEmitter);
begin
  if FreeEmitter and (FEmitter <> nil) then
    FEmitter.Free();
  FEmitter := AEmitter;
  if (FEmitter <> nil) then
    FEmitter.Reset();
end;

procedure TLapeCompilerBase.Reset;
begin
  if (FEmitter <> nil) then
    FEmitter.Reset();
  while (DecStackInfo(False, False, (FStackInfo <> nil) and (FStackInfo.Owner = nil)) <> nil) do ;
end;

constructor TLapeCompilerBase.Create(AEmitter: TLapeCodeEmitter = nil; ManageEmitter: Boolean = True);
begin
  inherited Create();

  Options := Lape_OptionsDef;
  Options_PackRecords := Lape_PackRecordsDef;

  FreeEmitter := ManageEmitter;
  if (AEmitter = nil) then
    AEmitter := TLapeCodeEmitter.Create();
  FEmitter := AEmitter;

  LoadBaseTypes(FBaseTypes, Self);
  FGlobalDeclarations := TLapeDeclarationList.Create(nil);
  FManagedDeclarations := TLapeDeclarationList.Create(nil);
end;

destructor TLapeCompilerBase.Destroy;
begin
  Clear();
  setEmitter(nil);

  FreeAndNil(FGlobalDeclarations);
  FreeAndNil(FManagedDeclarations);
  ClearBaseTypes(FBaseTypes);

  inherited;
end;

procedure TLapeCompilerBase.Clear;
begin
  FGlobalDeclarations.Delete(TLapeVar, True);
  FManagedDeclarations.Delete(TLapeVar, True);
  FGlobalDeclarations.Clear();
  FManagedDeclarations.Clear();
  Reset();
end;

function TLapeCompilerBase.IncStackInfo(AStackInfo: TLapeStackInfo; var Offset: Integer; Emit: Boolean = True; Pos: PDocPos = nil): TLapeStackInfo;
begin
  if (AStackInfo <> nil) then
  begin
    AStackInfo.Owner := FStackInfo;
    FStackInfo := AStackInfo;
    if Emit then
    begin
      AStackInfo.CodePos := Emitter._ExpandVar(0, Offset, Pos);
      Emitter._IncTry(0, Try_NoExcept, Offset, Pos);
    end
    else
      AStackInfo.CodePos := -1;
  end
  else
    FStackInfo := nil;
  Result := FStackInfo;
end;

function TLapeCompilerBase.IncStackInfo(Emit: Boolean = False): TLapeStackInfo;
var o: Integer;
begin
  o := -1;
  Result := IncStackInfo(TLapeStackInfo.Create(FStackInfo), o, Emit);
end;

function TLapeCompilerBase.DecStackInfo(var Offset: Integer; InFunction: Boolean = False; Emit: Boolean = True; DoFree: Boolean = False; Pos: PDocPos = nil): TLapeStackInfo;
var
  i: Integer;
begin
  if (FStackInfo = nil) then
    Result := nil
  else
  begin
    Result := FStackInfo.Owner;

    if Emit then
      if (FStackInfo.TotalSize > 0) or InFunction then
      begin
        if InFunction and (FStackInfo.TotalNoParamSize <= 0) then
          Emitter.Delete(FStackInfo.CodePos, ocSize + SizeOf(TStackOffset), Offset);

        Emitter._DecTry(Offset, Pos);
        Emitter._IncTry(Offset - FStackInfo.CodePos, Try_NoExcept, FStackInfo.CodePos, Pos);

        with FStackInfo.VarStack do
        begin
          i := 0;
          while (i < Count) do
          begin
            if Items[i].NeedFinalization then
            begin
              Items[i].VarType.Finalize(Items[i], Offset, True, Pos);
              if (Items[i] is TLapeStackTempVar) then
                TLapeStackTempVar(Items[i]).Locked := True;
            end;
            Inc(i);
          end;
          for i := 0 to Count - 1 do
            if (Items[i] is TLapeStackTempVar) then
              TLapeStackTempVar(Items[i]).Locked := False;
        end;

        Emitter._PopVar(FStackInfo.TotalSize, Offset, Pos);
        if InFunction then
          Emitter._DecCall_EndTry(Offset, Pos)
        else
          Emitter._EndTry(Offset, Pos);

        WriteLn('Vars on stack: ', FStackInfo.Count);

        if (not InFunction) then
          if FStackInfo.NeedInitialization then
            Emitter._ExpandVarAndInit(FStackInfo.TotalSize, FStackInfo.CodePos, Pos)
          else
            Emitter._ExpandVar(FStackInfo.TotalSize, FStackInfo.CodePos, Pos)
        else if (FStackInfo.TotalNoParamSize > 0) then
          if FStackInfo.NeedInitialization then
            Emitter._GrowVarAndInit(FStackInfo.TotalNoParamSize, FStackInfo.CodePos, Pos)
          else
            Emitter._GrowVar(FStackInfo.TotalNoParamSize, FStackInfo.CodePos, Pos);
      end
      else
        Emitter.Delete(FStackInfo.CodePos, ocSize*2 + SizeOf(TStackOffset) + SizeOf(TOC_IncTry), Offset);

    if DoFree then
      FStackInfo.Free();
    FStackInfo := Result;
  end;
end;

function TLapeCompilerBase.DecStackInfo(InFunction: Boolean = False; Emit: Boolean = False; DoFree: Boolean = False): TLapeStackInfo;
var o: Integer;
begin
  o := -1;
  Result := DecStackInfo(o, InFunction, Emit, DoFree);
end;

function TLapeCompilerBase.getBaseType(Name: lpString): TLapeType;
var
  t: ELapeBaseType;
begin
  Name := LapeCase(Name);
  for t := Low(FBaseTypes) to High(FBaseTypes) do
    if (FBaseTypes[t] <> nil) and (LapeCase(FBaseTypes[t].Name) = Name) then
      Exit(FBaseTypes[t]);
  Result := nil;
end;

function TLapeCompilerBase.getBaseType(t: ELapeBaseType): TLapeType;
begin
  Result := FBaseTypes[t];
end;

function TLapeCompilerBase.addLocalDecl(v: TLapeDeclaration; AStackInfo: TLapeStackInfo): TLapeDeclaration;
begin
  if (v = nil) then
    Exit(nil);
  Result := v;
  if (AStackInfo = nil) then
    FGlobalDeclarations.addDeclaration(v)
  else
    AStackInfo.addDeclaration(v);
end;

function TLapeCompilerBase.addLocalDecl(v: TLapeDeclaration): TLapeDeclaration;
begin
  Result := addLocalDecl(v, FStackInfo);
end;

function TLapeCompilerBase.addGlobalDecl(v: TLapeDeclaration): TLapeDeclaration;
begin
  if (v = nil) then
    Exit(nil);
  Result := v;
  FGlobalDeclarations.addDeclaration(v);
end;

function TLapeCompilerBase.addManagedDecl(v: TLapeDeclaration): TLapeDeclaration;
begin
  if (v = nil) then
    Exit(nil);
  Result := v;
  FManagedDeclarations.addDeclaration(v);
end;

function TLapeCompilerBase.addManagedVar(v: TLapeVar): TLapeVar;
var
  i: Integer;
  p: TLapeEvalProc;
  d: EvalBool;
  a: TLapeDeclArray;
begin
  if (v = nil) then
    Exit(nil);
  if (v is TLapeGlobalVar) and v.isConstant and (v.Name = '') then
  begin
    a := FManagedDeclarations.getByClass(TLapeGlobalVar);
    for i := 0 to High(a) do
      if (v = a[i]) then
        Exit(v)
      else if TLapeGlobalVar(a[i]).isConstant and (a[i].Name = '') and (TLapeGlobalVar(a[i]).VarType <> nil) and TLapeGlobalVar(a[i]).VarType.Equals(v.VarType, False) then
      begin
        p := getEvalProc(op_cmp_Equal, TLapeGlobalVar(a[i]).VarType.BaseType, v.VarType.BaseType);
        if ({$IFNDEF FPC}@{$ENDIF}p = nil) or ({$IFNDEF FPC}@{$ENDIF}p = {$IFNDEF FPC}@{$ENDIF}LapeEvalErrorProc) or (getEvalRes(op_cmp_Equal, TLapeGlobalVar(a[i]).VarType.BaseType, v.VarType.BaseType) <> ltEvalBool) then
          Continue;
        p(@d, TLapeGlobalVar(a[i]).Ptr, TLapeGlobalVar(v).Ptr);
        if d then
        begin
          v.Free();
          Exit(TLapeGlobalVar(a[i]));
        end;
      end;
  end;
  Result := TLapeVar(addManagedDecl(v));
end;

function TLapeCompilerBase.addManagedType(v: TLapeType): TLapeType;
var
  i: Integer;
  a: TLapeDeclArray;
begin
  if (v = nil) then
    Exit(nil);

  a := FManagedDeclarations.getByClass(TLapeType);
  for i := 0 to High(a) do
    if (v = a[i]) then
      Exit(v)
    else if TLapeType(a[i]).Equals(v, False) then
    begin
      v.Free();
      Exit(TLapeType(a[i]));
    end;
  Result := TLapeType(addManagedDecl(v));
end;

function TLapeCompilerBase.addStackVar(VarType: TLapeType; Name: lpString): TLapeStackVar;
begin
  Assert(FStackInfo <> nil);
  Result := FStackInfo.addVar(VarType, Name);
  Assert(not (Result is TLapeStackTempVar));
end;

function TLapeCompilerBase.getTempVar(VarType: ELapeBaseType; Lock: Integer = 1): TLapeStackTempVar;
begin
  Result := getTempVar(FBaseTypes[VarType], Lock);
end;

function TLapeCompilerBase.getTempVar(VarType: TLapeType; Lock: Integer = 1): TLapeStackTempVar;
begin
  Result := FStackInfo.getTempVar(VarType, Lock);
end;

function TLapeCompilerBase.getTempStackVar(VarType: ELapeBaseType): TResVar;
begin
  Result := getTempStackVar(FBaseTypes[VarType]);
end;

function TLapeCompilerBase.getTempStackVar(VarType: TLapeType): TResVar;
begin
  Result := StackResVar;
  Result.VarType := VarType;
end;

function TLapeCompilerBase.getPointerType(PType: ELapeBaseType): TLapeType_Pointer;
begin
  Result := getPointerType(FBaseTypes[PType]);
end;

function TLapeCompilerBase.getPointerType(PType: TLapeType): TLapeType_Pointer;
begin
  Result := TLapeType_Pointer(addManagedType(TLapeType_Pointer.Create(Self, PType)));
end;

function TLapeCompilerBase.getDeclaration(Name: lpString; AStackInfo: TLapeStackInfo; LocalOnly: Boolean = False): TLapeDeclaration;
var
  a: TLapeDeclArray;
begin
  if (AStackInfo <> nil) then
  begin
    Result := AStackInfo.getDeclaration(Name);
    if (Result <> nil) or LocalOnly then
      Exit;
  end;

  a := GlobalDeclarations.getByName(Name);
  if (Length(a) > 1) then
    LapeException(lpeDuplicateDeclaration, [Name])
  else if (Length(a) > 0) and (a[0] <> nil) then
    Result := a[0]
  else
    Result := getBaseType(Name);
end;

function TLapeCompilerBase.getDeclaration(Name: lpString; LocalOnly: Boolean = False): TLapeDeclaration;
begin
  Result := getDeclaration(Name, FStackInfo, LocalOnly);
end;

function TLapeCompilerBase.hasDeclaration(Name: lpString; AStackInfo: TLapeStackInfo; LocalOnly: Boolean = False): Boolean;
begin
  if (AStackInfo <> nil) then
  begin
    Result := AStackInfo.hasDeclaration(Name);
    if Result or LocalOnly then
      Exit;
  end;

  if (Length(GlobalDeclarations.getByName(Name)) > 0) then
    Result := True
  else
    Result := getBaseType(Name) <> nil;
end;

function TLapeCompilerBase.hasDeclaration(Name: lpString; LocalOnly: Boolean = False): Boolean;
begin
  Result := hasDeclaration(Name, FStackInfo, LocalOnly);
end;

end.

