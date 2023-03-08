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

