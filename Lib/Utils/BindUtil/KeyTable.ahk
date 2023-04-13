#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include ..\BuiltinsExtend.ahk

/**
 * KeyTable
 * NumericListener
 */

/**
 * @class
 */
Class KeyTable {

;    Class BoundMethods {
;        /** @prop {Func} bindkey */
;        bindkey     := {}
;        /** @prop {Func} activate */
;        activate    := {}
;        /** @prop {Func} deactivate */
;        deactivate  := {}
;        /** @prop {Func} disableontrigger */
;        disableontrigger := {}
;    }

    boundmeth := {
        /** @prop {Func} bindkey */
        bindkey          : {},
        /** @prop {Func} activate */
        activate         : {},
        /** @prop {Func} deactivate */
        deactivate       : {},
        /** @prop {Func} toggletable */
        toggletable      : {},
        /** @prop {Func} togglekeypaths */
        togglekeypaths   : {},
        /** @prop {Func} disableontrigger */
        disableontrigger : {},
        /** @prop {Func} enable */
        enable           : {},
        /** @prop {Func} disable */
        disable          : {}
    }

    Class Defaults {
        /** @prop {Number} timeout */
        Static timeout := False,
        /** @prop {Integer} maxtimeout */
            maxtimeout := (60 * 1000)
    }

    /** @prop {Number|Boolean} timeout */
        timeout := 2000

    ; /** @prop {KeyTable.BoundMethods} boundmeth */
        ; , boundmeth := {bindkey:{}, activate:{}, deactivate:{}, disableontrigger:{}}

    /** @prop {Map<String,(Func|BoundFunc)>} keys */
        , keys := Map()

    /** @prop {Map} ktbls */
        , ktbls := Map()

    /** @prop {Integer} maxtimeout */
        , maxtimeout := 60 * 1000

    /** @prop {Boolean} _active */
        , _active := False

    /**
     *  ### **`_timeout`**
     *  ----------
     *
     *  ```AutoHotkey2
     *
     *  {String} _timeout :=
     *         (_t == "none")  /*
     *      or (_t == "unset") ; KeyTable.Defaults.timeout == (60 * 1000)
     *      or (_t == "max")   ; this.maxtimeout
     * ```
     *
     *
     * @param {String|Number|Boolean} _timeout
     * @return {KeyTable}
     */
    __New(_timeout := 2000) {
        this.timeout   := this.ParsedTimeout[_timeout]
        this.boundmeth.bindkey          := ObjBindMethod(this, "MapKey"          )
        this.boundmeth.activate         := ObjBindMethod(this, "Activate"        )
        this.boundmeth.deactivate       := ObjBindMethod(this, "Deactivate"      )
        this.boundmeth.disableontrigger := ObjBindMethod(this, "DisableOnTrigger")
        this.boundmeth.togglekeypaths   := ObjBindMethod(this, "ToggleKeyPaths"  )
    }

    /**
     * @prop {Number|Boolean} ParsedTimeout
     * @param {String|Number|Boolean} _timeout
     */
    ParsedTimeout[_timeout] =>
      (!IsSet(_timeout) or (_timeout = "unset"))     ? ;
                       KeyTable.Defaults.timeout     : ;
            (!_timeout or this.timeout = "none") ? 0 : ;
                              (_timeout = "max")     ? ;
                                 this.maxtimeout     : ;
                            (_timeout is Number)     ? ;
                    (_timeout > this.maxtimeout)     ? ;
                                 this.maxtimeout     : ;
                            Abs(Round(_timeout)) : 0 ; ;

    /**
     * @param {Number|String|Boolean} [_timeout=False]
     */
    Activate(_timeout:=False, *) {
        bmda := this.boundmeth.deactivate
        ontrig := this.boundmeth.disableontrigger
        for _key, _action in this.keys
            Hotkey( _key, ((_action is KeyTable) ?
                          ontrig.Bind(_action.boundmeth.activate) :
                                                 (_action)) , "On")
        if (_tmoparsed := this.ParsedTimeout[_timeout])
            SetTimer bmda, (_tmoparsed * (-1))
        this._active := True
    }

    /**
     */
    Deactivate(*) {
        bmda := this.boundmeth.deactivate
        Try SetTimer(, 0)
        for _key, _action in this.keys
            Hotkey _key, "Off"
        this._active := False
    }

    DisableOnTrigger(_key_action, *) {
        bmda := this.boundmeth.deactivate
        bmda()
        SetTimer _key_action, (-10)
    }

    /**
     * @param {String} _key_new
     * @param {Func|KeyTable} _action_new
     * @param {Boolean} [_auto_off=False]
     */
    MapKey(_key_new, _action_new, _auto_off:=False, *) {
        ontrig := this.boundmeth.disableontrigger
        if _auto_off
            this.keys[_key_new] := ontrig.Bind(_action_new)
        else this.keys[_key_new] := _action_new
    }



    /**
     * @param {__Array} _kpath
     * @param {Func} _action
     * @param {String|Number|Boolean} [_timeout=3000]
     */
    MapKeyPath(_kpath, _action, _timeout:=3000) {
        kp := (_kpath is Array) ? _kpath : [_kpath]
        kplen := kp.Length
        ktbls := [this]
        if kplen > 1 {
            for _k in kp {
                curkeys := ktbls[ktbls.Length].keys
                ; nexttbl := KeyTable(_timeout)
                if !curkeys.Has(_k)
                    curkeys[_k] := KeyTable(_timeout)
                ktbls.Push(curkeys[_k])
            } Until (A_Index+1) >= kplen
        }
        ktbls[kplen].MapKey(kp[kplen], _action, True)
    }

    /** @param {Integer|Boolean} [_timeout=False] */
    Active[_timeout := False] {
        Get => this._active
        Set => (!!Value and !this._active) ? (this.Activate(_timeout)) :
               (!Value and !!this._active) ? (this.Deactivate()) :  ("")
    }

    /**
     * @param {Integer|Boolean} [_timeout]
     */
    ToggleKeyPaths(_timeout?, *) {
        _timeout := this.ParsedTimeout[_timeout ?? this.timeout]
        this.Active := !this.Active
    }
}











