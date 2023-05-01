#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include *i <Utils\mouse\MouseTrack>
#Include *i ..\..\DEBUG\DBT.ahk

Class MouseTrack {
    this.callback_func := {}
    this.update_interval := 10
    this._enabled := true

    __New(_callback_func? , _update_interval?) {
        this.callback_func := _callback_func ?? this.DefaultCallback
        this.update_interval := _update_interval ?? this.update_interval

    }

    DefaultCallback() {

    }

    Enabled {
        get => this._enabled
        set => this._enabled := Value
    }

    Toggle() {
        this.Enabled := !this.Enabled
    }
}