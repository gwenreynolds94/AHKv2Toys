;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk
#Include Utils\BuiltinsExtend.ahk
#Include Utils\WinUtil\WinUtil.ahk
#Include Utils\DetectComputer.ahk


; Class Mouse360 {
;     Static mouse_x := (-1)
;          , mouse_y := (-1)
;          , previous_tick := (-1)
;          , starting_tick := (-1)
;          , speed := -50
;          , duration := 5
;          , bound_methods := {}
; 
;     Static __New() {
;         this.bound_methods := {
;             move360: ObjBindMethod(this, "Move360"),
;             activate360: ObjBindMethod(this, "Activate360")
;         }
;     }
; 
;     Static Move360() {
;         current_tick := A_TickCount
;         if this.starting_tick = (-1)
;             this.starting_tick := current_tick
;         if (current_tick - this.starting_tick) > (this.duration * 1000) {
;             this.mouse_x := this.mouse_y := this.previous_tick := this.starting_tick := (-1)
;             SetTimer(,0)
;             return
;         }
;         if this.previous_tick = (-1)
;             delta_time := 1
;         else delta_time := (current_tick - this.previous_tick) / 1000
;         this.previous_tick := current_tick
;         delta_x := delta_time * this.speed
;         if this.mouse_y = (-1) {
;             bufPOINT := Buffer(8)
;             DllCall "GetCursorPos", "Ptr", bufPOINT
;             this.mouse_y := NumGet(bufPOINT, 4, "Int")
;         }
;         if this.mouse_x = (-1) {
;             bufPOINT := Buffer(8)
;             DllCall "GetCursorPos", "Ptr", bufPOINT
;             this.mouse_x := NumGet(bufPOINT, 0, "Int")
;         } else {
;             this.mouse_x += delta_x
;         }
;         DllCall "SetCursorPos", "Int", this.mouse_x , "Int", this.mouse_y
;     }
; 
;     Static Activate360() {
;         move360 := this.bound_methods.move360
;         SetTimer move360, 10
;     }
; }
; 
; 
; #0::Mouse360.Activate360

; ;setglobal() {
; ;    global ass := 12
; ;    msgbox ass
; ;    ass := 14
; ;    msgbox ass
; ;}
; ;
; ;#0::setglobal

; ActivateNewBrowser 'wezterm-gui.exe'

; MsgBox 'start'
;
; run 'msedge.exe'
;
; WinUtil.WinWaitNewActive('ahk_exe msedge.exe')
;
; MsgBox 'end'

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



iExe := "iTunesVisualizerHost.exe"
iClass := "ITUNES OOPWIND"

F9::{
    WinActivate "ahk_exe " iExe
}



F8::ExitApp
