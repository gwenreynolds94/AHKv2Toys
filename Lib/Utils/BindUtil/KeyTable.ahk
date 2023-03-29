#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force


/**
 * KeyTable
 * NumericListener
 */

/**
 * @class
 */
Class KeyTable {

    Static __New() {
        Array_Reverse(__this) {
            new_array := []
            Loop __this.Length
                new_array.Push(__this[(__this.Length - A_Index) + 1])
            return new_array
        }
        if not Array.Prototype.HasMethod("Reverse")
            Array.Prototype.Reverse := Array_Reverse
    }

    Class BoundMethods {
        /** @prop {Func} bindkey */
        bindkey    := {}
        /** @prop {Func} activate */
        activate   := {}
        /** @prop {Func} deactivate */
        deactivate := {}
        /** @prop {Func} autooffcode */
        autooffcode := {}
    }

      timeout := 2000
    /** @prop {KeyTable.BoundMethods} boundmeth */
    , boundmeth := {bindkey:{}, activate:{}, deactivate:{}}
    /** @prop {Map<String,(Func|BoundFunc)>} keys */
    , keys := Map()
    /** @prop {Map} ktbls */
    , ktbls := Map()
    /** @prop {Integer} maxtimeout */
    , maxtimeout := 60 * 1000
    /** @prop {Boolean} _active */
    , _active := False

    /** @param {number} _timeout */
    __New(_timeout := 2000) {
        this.timeout := IsNumber(_timeout) ? Abs(_timeout) :
                        IsAlpha(_timeout)  ? (_timeout="max") ?
                        this.maxtimeout : _timeout : _timeout

        this.boundmeth := KeyTable.BoundMethods()
        this.boundmeth.bindkey := ObjBindMethod(this, "MapKey")
        this.boundmeth.activate := ObjBindMethod(this, "Activate")
        this.boundmeth.deactivate := ObjBindMethod(this, "Deactivate")
        this.boundmeth.autooffcode := ObjBindMethod(this, "AutoOffCode")
    }

    /**
     * @param {Number} _timeout
     */
    Activate(_timeout:=False, *) {
        this._active := True
        for _key, _action in this.keys
            Hotkey _key, _action, "On"
        if (_timeout = "none") or (not _timeout and (this.timeout = "none"))
            return
        _to := _timeout, _mxto := this.maxtimeout
        SetTimer(
            this.boundmeth.deactivate,
            (_to = "max") ? _mxto :
            (IsNumber(_to)) ? ((-1)*_to) : (_thto:=((-1)*this.timeout)) ? _thto : _mxto
        )
    }

    /**
     */
    Deactivate(*) {
        SetTimer this.boundmeth.deactivate, 0
        this._active := False
        for _key, _action in this.keys
            Hotkey _key, _action, "Off"
    }

    AutoOffCode(_action, *) {
        bmde := this.boundmeth.deactivate
        bmde()
        _action()
    }

    /**
     * @param {String} _key_new
     * @param {Func} _action_new
     * @param {Boolean} [_auto_off=False]
     */
    MapKey(_key_new, _action_new, _auto_off:=False, *) {
        this.keys[_key_new] := _auto_off ?
                ObjBindMethod(this, "AutoOffCode", _action_new) :
                _action_new
    }

    /**
     * @param {Array} _kpath
     * @param {Func} _action
     */
    MapKeyPath(_kpath, _action, _timeout:=3000) {
        _kpath := (_kpath is Array) ? _kpath : [_kpath]
        kpathrev := _kpath.Reverse()
        pathlen := _kpath.Length
        kstart := _kpath[1]
        kend := kpathrev[1]

        /** @var {Array} ktblgrp */
        ktblgrp := this.ktbls[_kpath] := []
        ktblgrp.Push _action
        Loop (pathlen-1)
            ktblgrp.Push KeyTable(_timeout)
        ktblgrp[pathlen].MapKey(kend, _action, True)
        k1act := (pathlen > 1) ?
                ; ktblgrp[2].Activate.Bind(_timeout) :
                ObjBindMethod(ktblgrp[2], "Activate", _timeout) :
                _action
        this.MapKey(kstart, k1act, True)

        Loop (pathlen - 2) {
            i := A_Index + 1
            ktblgrp[i].MapKey(
                _kpath[i],
                ; ktblgrp[i+1].Activate.Bind(_timeout),
                ObjBindMethod(ktblgrp[i+1], "Activate", _timeout),
                True
            )
        }
    }

    BindKey(_key_new, _action_new, _auto_off:=False, *) {
        if _auto_off
            this.keys[_key_new] := (*)=>(
                (this.Active := False),
                _action_new()
            )
        else this.keys[_key_new] := _action_new
    }

    Active[
        /** @var {Integer|Boolean} _timeout */
            _timeout:=False ] {
        Get => this._active
        Set {
            if !!Value and !this._active
                this.Activate(_timeout)
            else if !Value and !!this._active
                this.Deactivate()
            this._active := !!Value
        }
    }

    /**
     * @param {Integer|Boolean} [_timeout]
     */
    Toggle(_timeout?) {
        _timeout := IsSet(_timeout) ? _timeout : False
        this.Active[_timeout] := not this.Active
    }
}











