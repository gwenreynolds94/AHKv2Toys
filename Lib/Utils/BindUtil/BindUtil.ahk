#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force


#Include <Utils\BindUtil\KeyTable>
#Include <Utils\DetectComputer>


/**
 * @class
 */
Class LeaderKeys extends KeyTable {

    /** @prop {String} leader */
    leader   := ""
    _enabled := False

    /**
     * @param {string} _leader
     * @param {number} _timeout
     */
    __New(_leader := "#a", _timeout := 2000) {
        this.leader := _leader
        super.__New(_timeout)
        this.boundmeth.toggletable := ObjBindMethod(this, "ToggleLeader")
        this.boundmeth.disable := ObjBindMethod(this, "DisableLeader")
        this.boundmeth.enable := ObjBindMethod(this, "EnableLeader")
    }

    EnableLeader(_timeout?, *) {
        this._enabled := True
        _timeout := _timeout ?? this.timeout
        Hotkey this.leader,
            this.boundmeth.togglekeypaths.Bind(_timeout),
            "On"
    }

    DisableLeader(_timeout?, *) {
        this.Active := False
        Hotkey this.leader, "Off"
        this._enabled := False
    }

    ToggleLeader(_timeout?, *) {
        _timeout := _timeout ?? this.timeout
        this.Enabled[_timeout] := !this.Enabled
    }

    __Noop[_placeholder?] => (*) => ""

    Enabled[_timeout?] {
        get => this._enabled
        set {
            _timeout := _timeout ?? this.timeout
            if !!Value and !this._enabled
                this.EnableLeader(_timeout)
            else if !Value and !!this._enabled
                this.DisableLeader(_timeout)
        }
    }
}

Class LinkTable extends KeyTable {
    Static BrowserExe := ""

    Static __New() {
        this.BrowserExe := __PC.default_browser
    }

    _links := Map()

    __New(_timeout := 3000) {
        super.__New(_timeout)
    }

    /**
     *
     * @param {string} _name
     * @param {string|array} _key
     */
    Link[_name, _key := ""] {
        get => this._links.Has(_name) ? this._links[_name] : false
        set {
            _link := LinkTable.LinkItem(_name, Value)
            this._links[_name] := _link
            this.MapKeyPath(_key, _link.bflaunch)
        }
    }

    Class LinkItem {
        name := "",
            address := "",
            bflaunch := {}

        __New(_name, _addr) {
            this.name := _name
            this.address := _addr
            this.bflaunch := ObjBindMethod(this, "Launch")
        }

        Launch(*) {
            Run LinkTable.BrowserExe " " . (
                (this.address ~= "`"") ?
                (this.address) :
                ("`"" this.address "`""))
        }
    }
}

Class LaunchTable extends KeyTable {

}

Class CountLeader extends KeyTable {
    Class Callback {
        when := ""
        do := {}
    }

    __New(_timeout := 2000, _callback_object := False) {
        super.__New(_timeout)

    }
}