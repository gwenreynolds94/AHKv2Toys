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


      timeout := 2000
    /** @prop {bindkey:BindKey,activate:Activate,deactivate:Deactivate} */
    , boundmeth := {bindkey:{}, activate:{}, deactivate:{}}
    /** @prop {Map<String,(Func|BoundFunc)>} */
    , keys := Map()
    /** @prop {Integer} maxtimeout */
    , maxtimeout := 60 * 1000
    /** @prop {Boolean} _active */
    , _active := False

    /** @param {number} _timeout */
    __New(_timeout := 2000) {
        this.timeout := IsNumber(_timeout) ? Abs(_timeout) : this.maxtimeout
        this.boundmeth := {
            bindkey:  ObjBindMethod(this, "BindKey"),
            activate:  ObjBindMethod(this, "Activate"),
            deactivate:  ObjBindMethod(this, "Deactivate")
        }
    }

          /**
     * @typedef {Func} Activate
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
            (_to = "max") ? _mxto:=this.maxtimeout :
            (IsNumber(_to)) ? ((-1)*_to) : (_thto:=(-1)*this.timeout) ? (_thto) : _mxto
        )
    }

    /**
     * @typedef {Func} Deactivate
     */
    Deactivate(*) {
        this._active := False
        for _key, _action in this.keys
            Hotkey _key, _action, "Off"
    }

    /**
     * @typedef {Func} MapKey
     * @param {String} _key_new
     * @param {Func} _action_new
     */
    MapKey(_key_new, _action_new, *) {
        this.keys[_key_new] := _action_new
    }

    BindKey(_key_new, _action_new, *) {
        this.keys[_key_new] := _action_new
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
}










