;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk
#Include Utils\BuiltinsExtend.ahk
#Include Utils\WinUtil\WinUtil.ahk

ActivateNewBrowser(_browser) {
    WaitForWindow(_initial_list) {
        WinWait 'ahk_exe' _browser
        WinWaitActive 'ahk_exe ' _browser
        new_list := wingetlist('ahk_exe ' _browser)
        if new_list.Length > _initial_list.Length
            for _id in new_list
                if not _initial_list.IndexOf(_id)
                    return _id
        return WaitForWindow(new_list)
    }
    initial_list := wingetlist('ahk_exe ' _browser)
    Run _browser
    WaitForWindow initial_list
    msgbox 'sadfsdf'
}

; ActivateNewBrowser 'wezterm-gui.exe'

MsgBox 'start'

run 'msedge.exe'

WinUtil.WinWaitNewActive('ahk_exe msedge.exe')

MsgBox 'end'

; Run("msedge.exe",,, &new_pid)
; tooltip new_pid
;
; A_DetectHiddenWindows := true
; WinWaitActive 'ahk_pid ' new_pid
; tooltip new_pid 'asdsad'
; A_DetectHiddenWindows := false
;
; WinWaitActive('ahk_exe msedge.exe')
; tooltip new_pid ':: ' wingetpid()


F8::ExitApp