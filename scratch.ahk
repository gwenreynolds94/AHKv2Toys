#Requires AutoHotkey v2.0-rc
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

Class TestConf {
    Static Values := Map()

    __Get(Key, Params) {
        Return TestConf.Values[Key]
    }

    __Set(Key, Params, Value) {
        TestConf.Values[Key] := Value
    }
}

tMap := Map(
    "abc", Map(
        "a", "AAA",
        "b", "BBB",
        "c", "CCC"
    ),
    "def", Map(
        "d", "DDD",
        "e", "EEE",
        "f", "FFF"
    ),
    "ghi", Map(
        "g", "GGG",
        "h", "HHH",
        "i", "III"
    )
)

Class THMap {

    Static CurrentValue := 0

    __Get(Key, Params) {
        return tMap[THMap.CurrentValue][Key]
    }
    __Set(Key, Params, Value) {
        tMap[THMap.CurrentValue][Key] := Value
    }
}

Class THMapp {
    __Get(Key, Params) {
        THMap.CurrentValue := Key
        return THMap()
    }
    __Set(Key, Params, Value) {

    }
}

timap := THMapp()


tpaths := [
    ".\butt.conf",
    ".\butss\buttss.conf",
    "buttsss.conf"
]

tcf := [
    "asdasda=4tgag4G4WRGaergwa4gg",
    "ASFA23rffadf=232G4G4TGAE",
    "AsdQrgs23234=1"
]

F10::
{
    tenb := IniRead(".\DOsrc\.ahkonf", "Enabled")
    tenbp := Map()
    Loop Parse, tenb, "`n", "`r" {
        RegExMatch(A_LoopField, "([^=]+)=(.+)", &_re_match)
        tenbp[_re_match.1] := _re_match.2
    }
    for k,v in tenbp
        stdo k, v
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

SetTimer ((*)=>ExitApp()), -20000

F8:: ExitApp
