#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

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
        /** @prop {Func} disableontrigger */
        disableontrigger : {}
    }

    Class Defaults {
        /** @prop {Number} timeout */
        Static timeout := 2000,
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


    /** @param {String|Number|Boolean} _timeout */
    __New(_timeout := 2000) {
        this.timeout   := this.ParsedTimeout[_timeout]
        this.boundmeth.bindkey          := ObjBindMethod(this, "MapKey"          )
        this.boundmeth.activate         := ObjBindMethod(this, "Activate"        )
        ; this.boundmeth.deactivate       := this.Deactivate.Bind(this)
        this.boundmeth.deactivate       := ObjBindMethod(this, "Deactivate"      )
        this.boundmeth.disableontrigger := ObjBindMethod(this, "DisableOnTrigger")
    }

    /**
     * @prop {Number|Boolean} ParsedTimeout
     * @param {String|Number|Boolean} _timeout
     */
    ParsedTimeout[_timeout] =>  (!_timeout)     ? (
                    (this.timeout = "none")     ? ;
                          0 : this.timeout      ) :
                        (_timeout = "none") ? 0 : ;
                       (_timeout = "unset")     ? ;
                  KeyTable.Defaults.timeout     : ;
                         (_timeout = "max")     ? ;
                            this.maxtimeout     : ;
                       (_timeout is Number)     ? ;
                       Abs(Round(_timeout)) : 0 ; ;

    /**
     * @param {Number|String|Boolean} [_timeout=False]
     */
    Activate(_timeout:=False, *) {
        bmda := this.boundmeth.deactivate
        for _key, _action in this.keys
            Hotkey _key, _action, "On"
        if (_tmoparsed := this.ParsedTimeout[_timeout])
            SetTimer bmda, (_tmoparsed * (-1))
        this._active := True
    }

    /**
     */
    Deactivate(*) {
        bmda := this.boundmeth.deactivate
        SetTimer(bmda, 0)
        for _key, _action in this.keys
            Hotkey _key, "Off"
        this._active := False
    }

    ; DisableOnTrigger(_key_action, *) {
    ;     this.Deactivate()
    ;     _key_action()
    ; }

    /**
     * @param {String} _key_new
     * @param {Func} _action_new
     * @param {Boolean} [_auto_off=False]
     */
    MapKey(_key_new, _action_new, _auto_off:=False, *) {
        bmda := this.boundmeth.deactivate
        RunFuncs(_funcs, *) {
            for _f in _funcs
                _f()
        }
        _func_list := [_action_new]
        if _auto_off
            _func_list.InsertAt(1, bmda)
        this.keys[_key_new] := RunFuncs.Bind(_func_list)
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
    Toggle(_timeout?) {
        _timeout := IsSet(_timeout) ? _timeout : False
        this.Active[_timeout] := !this.Active
    }
}
/**
 * KeyTable
 * NumericListener
 */

/**
 * @class
 */
Class NestedKeyTable {

    Class BoundMethods {
        /** @prop {Func} bindkey */
        bindkey     := {}
        /** @prop {Func} activate */
        activate    := {}
        /** @prop {Func} deactivate */
        deactivate  := {}
        /** @prop {Func} disableontrigger */
        disableontrigger := {}
    }

    Class Defaults {
        /** @prop {Number} timeout */
        Static timeout := 2000,
        /** @prop {Integer} maxtimeout */
            maxtimeout := (60 * 1000)
    }

    /** @prop {Number|Boolean} timeout */
        timeout := 2000

    /** @prop {KeyTable.BoundMethods} boundmeth */
        , boundmeth := {bindkey:{}, activate:{}, deactivate:{}, disableontrigger:{}}

    /** @prop {Map<String,(Func|BoundFunc)>} keys */
        , keys := Map()

    /** @prop {Map} ktbls */
        , ktbls := Map()

    /** @prop {Integer} maxtimeout */
        , maxtimeout := 60 * 1000

    /** @prop {Boolean} _active */
        , _active := False


    /** @param {String|Number|Boolean} _timeout */
    __New(_timeout := 2000) {
        this.timeout   := this.ParsedTimeout[_timeout]
        this.boundmeth := NestedKeyTable.BoundMethods()
        this.boundmeth.bindkey          := ObjBindMethod(this, "MapKey"          )
        this.boundmeth.activate         := ObjBindMethod(this, "Activate"        )
        this.boundmeth.deactivate       := ObjBindMethod(this, "Deactivate"      )
        this.boundmeth.disableontrigger := ObjBindMethod(this, "DisableOnTrigger")
    }

    /**
     * @prop {Number|Boolean} ParsedTimeout
     * @param {String|Number|Boolean} _timeout
     */
    ParsedTimeout[_timeout] =>  (!_timeout)     ? (
                    (this.timeout = "none")     ? ;
                          0 : this.timeout      ) :
                        (_timeout = "none") ? 0 : ;
                       (_timeout = "unset")     ? ;
                  KeyTable.Defaults.timeout     : ;
                         (_timeout = "max")     ? ;
                            this.maxtimeout     : ;
                       (_timeout is Number)     ? ;
                       Abs(Round(_timeout)) : 0 ; ;

    /**
     * @param {Number|String|Boolean} [_timeout=False]
     */
    Activate(_timeout:=False, *) {
        bmda := this.boundmeth.deactivate
        for _key, _action in this.keys
            Hotkey _key, _action, "On"
        if (_tmoparsed := this.ParsedTimeout[_timeout])
            SetTimer bmda, (_tmoparsed * (-1))
        this._active := True
    }

    /**
     */
    Deactivate(*) {
        bmda := this.boundmeth.deactivate
        SetTimer(bmda, 0)
        for _key, _action in this.keys
            Hotkey _key, "Off"
        this._active := False
    }

    ; DisableOnTrigger(_key_action, *) {
    ;     this.Deactivate()
    ;     _key_action()
    ; }

    /**
     * @param {String} _key_new
     * @param {Func} _action_new
     * @param {Boolean} [_auto_off=False]
     */
    MapKey(_key_new, _action_new, _auto_off:=False, *) {
        bmda := this.boundmeth.deactivate
        RunFuncs(_funcs, *) {
            for _f in _funcs
                _f()
        }
        _func_list := [_action_new]
        if _auto_off
            _func_list.InsertAt(1, bmda)
        this.keys[_key_new] := RunFuncs.Bind(_func_list)
    }

    /**
     * @param {Array} _kpath
     * @param {Func} _action
     * @param {String|Number|Boolean} [_timeout=3000]
     */
    MapKeyPath(_kpath, _action, _timeout:=3000) {
        bmda     := this.boundmeth.deactivate
        _kpath   := (_kpath is Array) ? _kpath : [_kpath]
        kpathrev := _kpath.Reverse()
        pathlen  := _kpath.Length
        klen     := pathlen - 1
        kstart   := _kpath[1]
        kend     := _kpath[pathlen]

        /** @var {Array} tbgrp */
        tbgrp := this.ktbls[_kpath] := []
        tbgrp.Push(this)
        Loop klen
            tbgrp.Push(KeyTable(_timeout))

        Loop (pathlen - 1) {
            i := pathlen - A_Index
            tbgrp[i].MapKey(
                _kpath[i],
                ; (*)=>(tbgrp[i+1].Activate(_timeout)),
                ; tbgrp[i+1].Activate.Bind(_timeout),
                ObjBindMethod(tbgrp[i+1], "Activate", _timeout),
                True
            )
        }

        tbgrp[pathlen].MapKey(kend, _action, True)
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
    Toggle(_timeout?) {
        _timeout := IsSet(_timeout) ? _timeout : False
        this.Active[_timeout] := !this.Active
    }
}











