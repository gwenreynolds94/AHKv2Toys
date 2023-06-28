#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include ..\BuiltinsExtend.ahk
#Include ..\..\GdipLib\Gdip_Custom.ahk

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
        /**
         * @prop {Func} bindkey
         */
        bindkey          : {},
        /**
         * @prop {Func} activate
         */
        activate         : {},
        /**
         * @prop {Func} deactivate
         */
        deactivate       : {},
        /**
         * @prop {Func} toggletable
         */
        toggletable      : {},
        /**
         * @prop {Func} togglekeypaths
         */
        togglekeypaths   : {},
        /**
         * @prop {Func} disableontrigger
         */
        disableontrigger : {},
        /**
         * @prop {Func} enable
         */
        enable           : {},
        /**
         * @prop {Func} disable
         */
        disable          : {}
    }

    Class Defaults {
        /**
         * @prop {Number} timeout
         */
        Static timeout := False,
        /**
         * @prop {Integer} maxtimeout
         */
            maxtimeout := (60 * 1000)
    }

    /**
     * @prop {Number|Boolean} timeout
     */
        timeout := 2000

    ; /** @prop {KeyTable.BoundMethods} boundmeth */
        ; , boundmeth := {bindkey:{}, activate:{}, deactivate:{}, disableontrigger:{}}

    /**
     * @prop {Map} keys
     */
        , keys := Map()

    /**
     * @prop {Map} ktbls
     */
        , ktbls := Map()

    /**
     * @prop {Integer} maxtimeout
     */
        , maxtimeout := 60 * 1000

    /**
     * @prop {Integer} is_root
     */
        , is_root := False

    /**
     * @prop {Integer} _active
     */
        , _active := False

    /**
     * @prop {Integer} keytable_id used in KeyTable.KeyPressIndicator to ditnguish between keytables
     */
        , keytable_id := 0

    /**
     * @prop {Integer} last_keytable_id store last keytable_id to ensure unique id
     */
    static last_keytable_id := 0

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
     * @param {String|Integer|Number} _timeout
     * @return {KeyTable}
     */
    __New(_timeout := 2000, _is_root:=False) {
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
    ParsedTimeout[_timeout?] =>
      (!IsSet(_timeout) or (_timeout = "unset"))     ? ;
                       KeyTable.Defaults.timeout     : ;
                                     (!_timeout)     ? (
                         (this.timeout = "none") ? 0 : ;
                                   this.timeout      ) :
                              (_timeout = "max")     ? ;
                                 this.maxtimeout     : ;
                            (_timeout is Number)     ? ;
                    (_timeout > this.maxtimeout)     ? ;
                                 this.maxtimeout     : ;
                            Abs(Round(_timeout)) : 0 ; ;

    RealTimeout[_timeout?] {
        Get {
            _timeout := _timeout ?? "unset"
            switch _timeout {
                case "none", "unset":
                    return 0
                case "max":
                    return this.maxtimeout
            }
            return IsNumber(_timeout) ? _timeout : 0
        }
    }

    ; ParsedTimeout2[_timeout?] => this.RealTimeout[_timeout ?? this.timeout ?? unset]

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
        _key_action()
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

    Class KeyPressIndicator {
        static gdip_token := 0x000000
             , first_instance := true
             ; , instances := {}
             ; , shown_instances := Map()
             , active_keys := Map()
             , gui := {}


        static __New() {
            if !!KeyTable.KeyPressIndicator.first_instance {
                KeyTable.KeyPressIndicator.SetupGdip
                KeyTable.KeyPressIndicator.first_instance := false
            }
            this.SetupGui
        }

        static PushKey() {
            
        }

        static SetupGui() {
            this.gui := Gui("AlwaysOnTop Caption", "KeyPressIndicator", this)
        }

        static SetupGdip() {
            KeyTable.KeyPressIndicator.gdip_token := Gdip_Startup()
            if !KeyTable.KeyPressIndicator.gdip_token
                return QuikToast( "{KeyPressIndicator~SetupGdip} : KeyPressIndicator will not be shown"
                                , "Failed to start GDI+ <> KeyPressIndicator cannot be used"
                                , 3000 )
            OnExit KeyTable.KeyPressIndicator.ShutdownGdip
            ; ...whatever...

        }

        static ShutdownGdip(*){
            if !!KeyTable.KeyPressIndicator.gdip_token
                Gdip_Shutdown KeyTable.KeyPressIndicator.gdip_token
        }

        __Delete() {
            KeyTable.KeyPressIndicator.ShutdownGdip
        }
    }
}











