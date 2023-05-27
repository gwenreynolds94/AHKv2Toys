
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force


QuikToast(_msg, _title, _timeout_ms?) {
    _timeout_ms := _timeout_ms ?? _G.General.ReloadMessageDuration
    Try {
        _msg_str := String(_msg)
        _title_str := String(_title)
        _timeout_ms_int := Integer(_timeout_ms) * -1
        TrayTip _msg_str, _title_str
        SetTimer (*)=> TrayTip(), _timeout_ms_int
    } Catch Error as type_err {
        TrayTip "The passed parameters did not have the correct types",
                "Could not display specified toast message"
        SetTimer (*)=>TrayTip(), 4 * 1000 * (-1)
    }
}
