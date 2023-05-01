#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include ..\DEBUG\DBT.ahk
#Include WinHookConstants.ahk

Class WinHookFactory {
    hook := 0x0
    callback := {}
    min_event := 0x0
    max_event := 0x0

    __New(_callback, _min_event, _max_event?) {
        this.callback := _callback ? _callback : this.DefaultCallback
        this.min_event := _min_event
        this.max_event := _max_event ?? _min_event
    }

    DefaultCallback(event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
        Critical("Off")
        hWinEventHook := this
        Tooltip 'event handle: ' hWinEventHook '`n' .
                'event: ' event '`n' .
                'hwnd: ' hwnd
        SetTimer((*)=>ToolTip(), -6666)
    }

    Register() {
        if this.hook
            Throw Error('Cannot register a currently registered ' .
                        'WinHook without first unregistering it.')
        else this.hook := DllCall(
            'User32\SetWinEventHook',
            'Int', this.min_event,
            'Int', this.max_event,
            'Ptr', 0,
            'Ptr', CallbackCreate(this.callback, 'F'),
            'Int', 0,
            'Int', 0,
            'Int', 0
        )
        return !!this.hook
    }

    Unregister() {
        if not this.hook
            Throw Error('Cannot unregister a WinHook that isn`'t ' .
                        'currently registered.')
        else this.hook := DllCall('User32\UnhookWinEvent', 'Ptr', this.hook)
    }
}
