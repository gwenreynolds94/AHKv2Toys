
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
        found := False
        for _i, _v in this
            found := (_v = _value) ? _i : found
        return found
    }

    FromRange(_index:=1, _index2?) {
        if _index < 0
            _index := this.Length + _index
        if _index < 1
            _index := 1
        else if _index > this.Length
            _index := this.Length

        if IsSet(_index2) {
            if _index2 < 0
                _index2 := this.Length + _index2
            if _index2 < _index
                _index2 := _index
            else if _index2 > this.Length
                _index2 := this.Length
        } else _index2 := this.Length

        out_array := []

        loop (_index2 - _index) + 1
            out_array.Push(this[(_index + A_Index) - 1])

        return out_array
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



