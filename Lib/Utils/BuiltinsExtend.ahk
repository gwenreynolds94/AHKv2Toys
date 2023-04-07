
Class __Array extends Array {

    Static __New() {
        this.Prototype.__Class := "Array"
        for _prop in ObjOwnProps(this.Prototype)
            Array.Prototype.%_prop% := this.Prototype.%_prop%
    }

    Reverse() {
        new_array := []
        Loop this.Length
            new_array.Push(this[this.Length-A_Index + 1])
        return new_array
    }

    IndexOf(_value) {
        _found := False
        for _i, _v in this
            _found := (_v = _value) ? _i : _found
        return _found
    }

    PushPass(_values*) {
        this.Push(_values*)
        Return this[this.Length]
    }
}

Class __String extends String {

    Static __New() {
        this.Prototype.__Class := "String"
        for _prop in ObjOwnProps(this.Prototype)
            String.Prototype.%_prop% := this.Prototype.%_prop%
    }

    Length() {
        Return StrLen(this)
    }

    Sub(_starting_pos, _length?){
        Return SubStr(this, _starting_pos, _length ?? unset)
    }

    StartsWith(_chars) {
        Return this.Sub(1, _chars.Length()) == _chars
    }

    EndsWith(_chars) {
        Return this.Sub((-1) * _chars.Length(), _chars.Length()) == _chars
    }
}


; #Include C:\Users\jonat\Documents\gitrepos\AHKv2Toys\Lib\DEBUG\DBT.ahk


; Class __BuiltinClassExtension {
;     Static __TargetClass := "unset"
;     Static __New() {
;         cls := this.__TargetClass
;         if cls != "unset"
;             for _prop in this.Prototype.OwnProps()
;                 if SubStr(_prop, 1, 1) != "_"
;                     cls.Prototype.%_prop% := this.Prototype.%_prop%
;
;     }
; }

; Class __BuiltinClassExtension {
;     Static __New() {
;         clsproto := this.Prototype.__Class
;         clsname := SubStr(clsproto, 3)
;         if clsproto ~= "^[^_]{1,2}|__BuiltinClassExtension"
;             Return
;         cls := %clsname%
;         for _prop in this.Prototype.OwnProps()
;             if SubStr(_prop, 1, 2) != "__"
;                 cls.Prototype.%_prop% := this.Prototype.%_prop%
;     }
; }

; __BuiltinClassExt__New(_This) {
;     cls := %(_This.Base.Prototype.__Class)%
;     for _prop in ObjOwnProps(_This.Prototype)
;         if SubStr(_prop, 1, 2) != "__"
;             cls.Prototype.%_prop% := _This.Prototype.%_prop%
; }



; /**
;  * @class __Array
;  * @extends {Array|__BuiltinClassExtension}
;  */
; Class __Array extends __BuiltinClassExtension {
;     /** @extends {Array} */

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

;     PushPass(_values*) {
;         this.Push(_values*)
;         Return this[this.Length]
;     }
; }



