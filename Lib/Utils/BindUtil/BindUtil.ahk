#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force


#Include <Utils\BindUtil\KeyTable>


/**
 * @class
 */
Class LeaderKeys extends KeyTable {

      /** @prop {String} leader */
    leader := ""
    , _enabled := False

    /**
     * @param {string} _leader
     * @param {number} _timeout
     */
    __New(_leader := "#a", _timeout:=2000) {
        super.__New(_timeout)
        this.leader := _leader
    }

    Enabled {
        Get => this._enabled
        Set {
            if !!Value and !this._enabled
                Hotkey this.leader, this.boundmeth.activate, "On"
            else if !Value and !!this._enabled
                Hotkey this.leader, this.boundmeth.activate, "Off"
            this._enabled := !!Value
        }
    }
}

Class LinkTable extends KeyTable {
    Static BrowserExe := "Maxthon.exe"

    _links := Map()

    __New(_timeout:=3000) {
        super.__New(_timeout)
    }

    Link[_name, _key:=""] {
        Get => this._links.Has(_name) ? this._links[_name] : false
        Set {
            _link := LinkTable.LinkItem(_name, Value)
            this._links[_name] := _link
            this.MapKey(_key, _link.bflaunch)
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
            Run LinkTable.BrowserExe " `"" this.address "`""
        }
    }
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

