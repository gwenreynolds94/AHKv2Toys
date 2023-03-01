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
;|- dbgo(stdo(c.penis,{ __opts: { noprint : True }}))
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
;|- dbgo "asdasdasd", "Asdasdasdas"

;|- dbgo (flt2nbr:=1.34) ":flt2nbr:" .
;|-----(HasBase(flt2nbr, Number.Prototype) ? "True" : "False")
;|- dbgo (int2nbr:=1123) ":int2nbr:" .
;|-----(HasBase(int2nbr, Number.Prototype) ? "True" : "False")
;|- dbgo (flt2int:=1.3) ":flt2int:" .
;|-----(HasBase(flt2int, Integer.Prototype) ? "True" : "False")
;|- dbgo (int2int:=123) ":int2int:" .
;|-----(HasBase(int2int, Integer.Prototype) ? "True" : "False")
;|- dbgo (int2flt:=41233) ":int2flt:" .
;|-----(HasBase(int2flt, Float.Prototype) ? "True" : "False")
;|- dbgo (flt2flt:=1.112) ":flt2flt:" .
;|-----(HasBase(flt2flt, Float.Prototype) ? "True" : "False")

gap := 8
workheight := A_ScreenHeight - 2*gap
workwidth := A_ScreenHeight - 2*gap
hincr := (35 // 3) * 3
wincr := (30 // 4) * 4
hhalflower := (hincr // 2)
tincr := hhalflower + Mod(hincr, 2) ; (hincr - 2*hhalflower)
bincr := hhalflower
whalflower := (wincr // 2)
lincr := whalflower + Mod(wincr, 2) ; (wincr - 2*whalflower)
rincr := whalflower



stdo { t: tincr, b: bincr, l:lincr, r:rincr }

F10::
{
    tlst := []
    Loop 66
        tlst.Push (67-A_Index)
    For _i, _nbr in tlst
        stdo(_i "`t" _nbr)
    Until (A_Index > 30)
}

SetTimer ((*)=>ExitApp()), -2000

F8:: ExitApp
