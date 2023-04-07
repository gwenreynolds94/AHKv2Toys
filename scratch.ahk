#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <DEBUG\DBT>

;|- Class tstclass {
;|-     aaa := Map(666, "sixxx", 10563, "ran", 98798, "hi")
;|-     penis := Map([1,1], "oneone", [1,2], "onetwo", [2,1], "twoone", [2,2], "twotwo")
;|-     butt := Map()
;|-     P[_p:=False] {
;|-         Set => _p ? (this.penis[_p] := Value) : (this.penis := Value)
;|-         Get => _p ? this.penis[_p] : this.penis
;|-     }
;|-     V[_v:=False] {
;|-         Get {
;|-             _fnd := False
;|-             _flatkeys := []
;|-             for k, v in this.penis
;|-                 _flatkeys.Push ((_v == v) ? (_fnd:=k) : k)
;|-             if _v and _fnd
;|-                 return _fnd
;|-             return _flatkeys
;|-         }
;|-         Set {
;|-             _fnd := False
;|-             _flatkeys := []
;|-             for k, v in this.penis
;|-                 _flatkeys.Push ((_v == v) ? (_fnd:=k:=Value) : k)
;|-             return (_v ? (_fnd ? _fnd : False) : this.penis)
;|-         }
;|-     }
;|-     A[_param*] {
;|-         Set => (_param.Length == 1) ?
;|-                 (this.aaa[_param[1]] := Value) :
;|-                 (this.aaa:=Value)
;|-         Get => (_param.Length == 1) ?
;|-                 this.aaa[_param[1]] :
;|-                 this.aaa
;|-     }
;|-     B[_param] {
;|-         Set {
;|-             for i,v in this.aaa
;|-                 if v == _param
;|-                     i := Value
;|-         }
;|-         Get {
;|-             for i,v in this.aaa
;|-                 if v == _param
;|-                     return i
;|-         }
;|-     }
;|-     tprop[alt:=False] {
;|-         Get => alt
;|-         Set {
;|-             if alt
;|-                 stdo('isalt', Value)
;|-             else
;|-                 stdo('notalt', Value)
;|-         }
;|-     }
;|- }
;|-
;|- c := tstclass()
;|-
;|- stdo_opts := { _stdo_opts: { noprint : True } }
;|-
;|- c.penis["asdasd"] := "qweqweqwe"
;|-
;|- stdo(stdo(c.penis,{ __opts: { noprint : True }}))
;|-
;|- stdo(
;|-     (
;|-     false ?
;|-     "000" :
;|-     false ?
;|-     "111" :
;|-     "222"
;|-     ),
;|-     Type(123),
;|-     Type(1.23),
;|-     Type("000"),
;|-     Type("asd"),
;|- )
;|-
;|-
;|- stdo "asdasdasd", "Asdasdasdas"

;|- stdo (flt2nbr:=1.34) ":flt2nbr:" .
;|-----(HasBase(flt2nbr, Number.Prototype) ? "True" : "False")
;|- stdo (int2nbr:=1123) ":int2nbr:" .
;|-----(HasBase(int2nbr, Number.Prototype) ? "True" : "False")
;|- stdo (flt2int:=1.3) ":flt2int:" .
;|-----(HasBase(flt2int, Integer.Prototype) ? "True" : "False")
;|- stdo (int2int:=123) ":int2int:" .
;|-----(HasBase(int2int, Integer.Prototype) ? "True" : "False")
;|- stdo (int2flt:=41233) ":int2flt:" .
;|-----(HasBase(int2flt, Float.Prototype) ? "True" : "False")
;|- stdo (flt2flt:=1.112) ":flt2flt:" .
;|-----(HasBase(flt2flt, Float.Prototype) ? "True" : "False")

; gap := 8
; workheight := A_ScreenHeight - 2*gap
; workwidth := A_ScreenHeight - 2*gap
; hincr := (35 // 3) * 3
; wincr := (30 // 4) * 4
; hhalflower := (hincr // 2)
; tincr := hhalflower + Mod(hincr, 2) ; (hincr - 2*hhalflower)
; bincr := hhalflower
; whalflower := (wincr // 2)
; lincr := whalflower + Mod(wincr, 2) ; (wincr - 2*whalflower)
; rincr := whalflower

; stdo { t: tincr, b: bincr, l:lincr, r:rincr }
; asd := []
; asd.x := 13
; stdo "map_is_obj: " (Map() is Object),
;      "str_literal_is_obj: " ("string" is Object),
;      "str_instance_is_obj: " (String("string") is Object),
;      "obj_literal_is_obj: " ({} is Object),
;      "arr_literal_is_obj: " ([] is Object),
;      asd.HasProp("x")

; Class Callaclass {
;     Static bigass := [1,2,3,4,5,6,7,8,9,10],
;            woah := {x: "no", xxx: "why"}
;     evilass := [6,6,6,6,6,6,],
;         what := {asd: "qwe", zxc: "dfg"}
;
;     __New(_what) {
;         this.what := _what
;     }
;
;     Static __New() {
;         this.woah := A_TickCount
;         (Callaclass.NestedAss.AnoterhClass)
;         (Callaclass.NestedAss)
;     }
;
;     Call(_args*) {
;
;     }
;
;     __Call(_name, _params) {
;
;     }
;     Class NestedAss {
;         Static PoopProp => (
;             (*) => MsgBox(this.OwnProps().Name)
;         )
;         Static WooProp => 666
;         Class AnoterhClass {
;
;         }
;     }
; }
;
; Class FakeClass {
;     Static cc => Callaclass
;     Static nA => this.cc.NestedAss
;     Static pp => Callaclass.NestedAss.PoopProp
;     Static wp => Callaclass.NestedAss.WooProp
;     Static ac => Callaclass.NestedAss.AnoterhClass
; }
;
;
; NoImplement(*)
; {
;     throw Error("Not Implemented")
; }
;
; /**
;  * @interface
;  */
; Color()
; {
;
; }
;
; /**
;  * @return {Array<Number>}
;  */
; Color.Prototype.RGB = NoImplement.Bind()
;
; /**
;  * @class
;  * @implements {Color}
;  */
; TransparentColor()
; {
;
; }
;
; TransparentColor.Prototype.RGB := (*)=>()
;
; /**
;  * @return {Array<Number, Number, Number, Number>}
;  */
; TransparentColor().Prototype.RGBA := (*)=>[1,2,3,4]
;
; aasds := TransparentColor.Prototype.RGBA()

; Class TestConf {
;     Static Values := Map()
;
;     __Get( Key, Params ) {
;         Return TestConf.Values[ Key ]
;     }
;
;     __Set( Key, Params, Value ) {
;         TestConf.Values[ Key ] := Value
;     }
; }
;
; tMap := Map(
;     "abc", Map(
;         "a", "AAA",
;         "b", "BBB",
;         "c", "CCC"
;     ),
;     "def", Map(
;         "d", "DDD",
;         "e", "EEE",
;         "f", "FFF"
;     ),
;     "ghi", Map(
;         "g", "GGG",
;         "h", "HHH",
;         "i", "III"
;     )
; )
;
; Class THMap {
;
;     Static CurrentValue := 0
;
;     __Get( Key, Params ) {
;         Return tMap[ THMap.CurrentValue ][ Key ]
;     }
;     __Set( Key, Params, Value ) {
;         tMap[ THMap.CurrentValue ][ Key ] := Value
;     }
; }
;
; Class THMapp {
;     __Get( Key, Params ) {
;         THMap.CurrentValue := Key
;         Return THMap()
;     }
;     __Set( Key, Params, Value ) {
;
;     }
; }
;
; timap := THMapp()
;
; tpaths := [
;     ".\butt.conf",
;     ".\butss\buttss.conf",
;     "buttsss.conf"
; ]
;
; tcf := [
;     "asdasda=4tgag4G4WRGaergwa4gg",
;     "ASFA23rffadf=232G4G4TGAE",
;     "AsdQrgs23234=1"
; ]

; Class ObjectImproved extends Object {
;
;     /** @param {Array} _prop_pairs */
;     __New(_prop_pairs*) {
;         if Mod(_prop_pairs.Length, 2)
;             _prop_pairs.Pop
;         _last_key := ""
;         for _idx, _itm in _prop_pairs
;             if Mod(_idx, 2)
;                 _last_key := _itm
;             else this.%_last_key% := _itm
;     }
;
;     ShoutLength() {
;         MsgBox this.asd
;     }
; }
; ObjSetBase(Object, ObjectImproved.Prototype.Base)
; ; Object.Prototype
;
; Class ImprovedObjects {
;
; ; }

; Class __BuiltinClassExtension {
;     Static __New() {
;         clsproto := this.Prototype.__Class
;         clsname := SubStr(clsproto, 3)
;         if clsproto ~= "^[^_]{1,2}|__BuiltinClassExtension"
;             Return
;         cls := %clsname%
;         for _prop in this.Prototype.OwnProps()
;             if SubStr(_prop, 1, 1) != "__"
;                 cls.Prototype.%_prop% := this.Prototype.%_prop%
;     }
; }

; /**
;  * @extends {Array}
;  * @example <caption>Hello this is me</caption>
;  */
; Class __Array extends __BuiltinClassExtension {
;     ; Static __TargetClass := Array
;     ; Static __New() {
;     ;     for k in this.Prototype.OwnProps()
;     ;         if SubStr(k, 1, 1) != "_"
;     ;             Array.Prototype.%k% := this.Prototype.%k%
;     ; }

;     Reverse() {
;         new_array := []
;         Loop this.Length
;             new_array.Push(this[this.Length-A_Index + 1])
;         return new_array
;     }

;     IndexOf(_value) {
;         _found := False
;         for _i, _v in this
;             if _v = _value
;                 _found := _i
;         return _found
;     }

;     PushAnd(_v*) {
;         this.Push(_v*)
;         return this[this.Length]
;     }

; }

; Class __String extends __BuiltinClassExtension {

;     Length() {
;         Return StrLen(this)
;     }

;     Sub(_starting_pos, _length?) {
;         Return SubStr(this, _starting_pos, _length ?? unset)
;     }

;     StartsWith(_chars) {
;         Return this.Sub(1, _chars.Length()) == _chars
;     }

;     EndsWith(_chars) {
;         Return this.Sub((-1) * _chars.Length(), _chars.Length()) == _chars
;     }
; }

; Class __Butts extends Array {
;     _getthis := ObjBindMethod(this, "GetThis")
;     Len => this.Length
;     GetThis(something?, orelse?) {
;         stdo "!!!" (something ?? "%%") "!!!"
;         (orelse ?? (*)=>(0))()
;     }
; }

; ; asd := __Butts(1,2,3,4,5,6,66,666)
; ; getbutt := asd._getthis.Bind("oowie")
; ; stdo asd, __Butts, asd is __Butts
; ; getbutt()
; ;
; ; dsf := Map(1, "o", 2, "t")
; ; stdo (_:=dsf).Has(1) and _[1]

; stdo Array
; stdo __Array

; stdo Gui.Control.Prototype.GetOwnPropDesc("SetFont")

; String.Base := __String.Base
; String.Prototype.Append := __String.Prototype.Append
; for _p in String.Base.OwnProps()
;     stdo _p
; stdo String.Prototype
; for o in [Object, Array, Map, Primitive,
;             Number, Float, Integer, Float,
;             VarRef, Buffer, File, Func, Gui,
;             RegExMatchInfo, String, Gui.Control,
;             Gui.List, Gui.Tab, Gui.Pic, Error,
;             TypeError, UnsetError, MemberError,
;             PropertyError, MethodError, Closure,
;             Enumerator, InputHook, Menu, MenuBar,
;             ComValue, ComObjArray, ComValueRef,
;             ClipboardAll, Class]
;     stdo o, o.Base, "-----------------------------"

; /** @extends String */
; Class __String
; {
;     Len(*) {
;         Return StrLen(this)
;     }
; }
;
; ; __String.
;
;
; ; ObjSetBase(String, __String.Base)
; ; String.Prototype := __String.Prototype
;
; /** @var {Any} Array @extends __Array */
;
; /**
;  * @param {Any} _asd
;  * @return {__String}
;  */
; asdasd(_asd) {
;     Return __String(_asd)
; }
;
;
; for k in ObjOwnProps(String.Prototype)
;     stdo k
;
; for k in ObjOwnProps(String)
;     stdo k
;
;
;
; __Array__New(_This) {
;     cls := %(_This.Base.Prototype.__Class)%
;     for _prop in _This.Prototype.OwnProps()
;         if SubStr(_prop, 1, 2) != "__"
;             cls.Prototype.%_prop% := _This.Prototype.%_prop%
; }

; /** @type {TestConf} */
; asdasd := {x: 1, y: 2}

; /** @var {Butts} String */
; String := String
; String.Prototype.Len := __String.Prototype.Len

; __Array.Base.__New := __Array__New
; __Array.DefineProp()

; (__Array)

; stdo __Array(), Array.Prototype, String("asd").Len()

Class __Array extends Array {
    Reverse() {
        new_array := []
        Loop this.Length
            new_array.Push( this[ this.Length - A_Index + 1 ] )
        Return new_array
    }
}

__Array.Prototype.__Class := "Array"
For _prop in ObjOwnProps( __Array.Prototype )
    Array.Prototype.%_prop% := __Array.Prototype.%_prop%

stdo [ 1, 2, 3, 4, 5 ].Reverse()


F10:: {
    boop := "boop"
    stdo boop
    stdo String.Base.Base
    ; tenb := IniRead(".\DOsrc\.ahkonf", "Enabled")
    ; tenbp := Map()
    ; Loop Parse, tenb, "`n", "`r" {
    ;     RegExMatch(A_LoopField, "([^=]+)=(.+)", &_re_match)
    ;     tenbp[_re_match.1] := _re_match.2
    ; }
    ; for k,v in tenbp
    ;     stdo k, v
    ; for _, tp in tpaths{
    ;     SplitPath(tp, &_fname, &_fdir)
    ;     stdo    "name: " _fname "`n`txists: " FileExist(_fname) ,
    ;             "dir: " _fdir "`n`texists: " DirExist(_fdir)
    ; }
    ; asd := TestConf()
    ; stdo TestConf.Butts
    ; TestConf.Butts := "New Butt"
    ; stdo TestConf.Butts
    ; asd.asd := "asdasd"
    ; stdo [1414
    ;      ,3646
    ;      ,345
    ;      ,(
    ;         [ 345
    ;          ,87,
    ;          321,(TTT.asd)*])*]
    ; Msgbox "abc := (" abc ")`ndef := (`n`t" def "`n)`nghi := " ghi "`n`t`t))"
    ; tlst := []
    ; Loop 66
    ;     tlst.Push (67-A_Index)
    ; For _i, _nbr in tlst
    ;     stdo(_i "`t" _nbr)
    ; Until (A_Index > 30)

}

SetTimer ( ( * ) => ExitApp() ), -20000

F8:: ExitApp
