#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

; #Include <DEBUG\DBT>

/** Hotkeys List
 *  ... {XButton1}, {XButton1 Up}  ==>  ClickToCopy
 *  ... ... XButton1->LButton2  =>  Ctrl+v
 *  ... ... XButton1->RButton2  =>  Ctrl+x
 *  ... ... XButton1->XButton1  =>  Ctrl+c
 *
 *  ... {XButton2}, {XButton2 Up}  ==>  AltTabEsque
 *  ... ... XButton2->LButton2  =>  Activate Previous Active Window
 *  ... ... XButton2->XButton2  =>  SearchFirefoxFromClipboard (or Waterfox)
 *  ... ... XButton2->RButton2  =>  Activate Previously Previous Active Window
 *
 *  ... "<^+p"  ==>  Single Line Comment Formatting  [Hard]
 *  ... "<^+o"  ==>  Single Line Comment Formatting  [Soft]
 *  ... "<^+i"  ==>  Single Line Comment Formatting  [Medium]
 *
 *  ... "<#v"   ==>  Scritch Notes Application
 */


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  SCRITCH NOTES ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include %A_ScriptDir%\ScinSkratch\Scritch.ahk
;
ScritchResourcePath := A_ScriptDir "\ScinSkratch"
NotesApp := ScritchGui(ScritchResourcePath, startHidden := True)
Hotkey "<#v", (*) => NotesApp.ToggleGui()
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; COMMENTS FORMATTING ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\FormatComment>
;
_subl_text_main_rgx := "\s.*Sublime\sText.+\(UNREGISTERED\)"
SetTitleMatchMode "Regex"
SetTitleMatchMode "Slow"
HotIf (*) => (WinActive("ahk_exe code.exe")
           or WinActive("ahk_exe VSCodium.exe"))
Hotkey "<^+p", (*) => FormatSingleLineComment()
Hotkey "<^+o", (*) => FormatSingleLineComment(" ")
Hotkey "<^+i", (*) => FormatSingleLineComment("-")
HotIf (*) => WinActive("i)\.sublime-syntax" _subl_text_main_rgx)
Hotkey "<^+p", (*) => FormatSingleLineComment("#", "#", 0)
Hotkey "<^+o", (*) => FormatSingleLineComment(":", "#", 0)
Hotkey "<^+i", (*) => FormatSingleLineComment("-", "#", 0)
HotIf (*)=> WinActive("i)\.ahk" _subl_text_main_rgx)
Hotkey "<^+p", (*) => FormatSingleLineComment("#", "`;", 0)
Hotkey "<^+o", (*) => FormatSingleLineComment("=", "`;", 0)
Hotkey "<^+i", (*) => FormatSingleLineComment("|", "`;", 1)
HotIf
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; CLICK TO COPY|CUT|PASTE ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
; Kick it all off
$XButton1::
{
    ; Two XButton1 Up or Downs in 300 ms Sends <Copy>, cancels sending XButton1
    if InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < 300)
        Return Send("{LCtrl Down}c{LCtrl Up}") SetTimer(SendXButton1, 0)
    ; XButton2->XButton1 Searches AutohHotkey V2 Docs
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < 300)
        Return SearchV2DocsFromClipboard() SetTimer(SendXButton1, 0)
    ; Otherwise set timer to send XButton1 for 300 ms
    SetTimer SendXButton1, -300
}
/**
    @type {Int}
*/
something:=40
; Easier to activate when hand can move around mouse
$XButton1 Up:: Return
; Send XButton1
SendXButton1(*) {
    SetTimer(, 0)
    Send("{XButton1}")
}
; Send <Cut> and cancel XButton1 timer
SendCut(*) {
    SetTimer(SendXButton1, 0)
    Send("{LCtrl Down}x{LCtrl Up}")
}
; Send <Paste> and cancel XButton1 timer
SendPaste(*) {
    SetTimer(SendXButton1, 0)
    Send("{LCtrl Down}v{LCtrl Up}")
}
; if right after XButton1 Up or Down ...SendPaste() | SendCut()
HotIf (*) => InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < 300)
Hotkey("LButton", SendPaste)
Hotkey("RButton", SendCut)
HotIf
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ;  XBUTTON2 ALT-TAB-ESQUE ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
$XButton2::
{
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < 300)
        Return SearchFirefoxFromClipboard() . SetTimer(SendXButton2, 0)
    SetTimer(SendXButton2, -300)
}
$XButton2 Up:: Return
SendXButton2(*) {
    SetTimer(,0)
    Return Send("{XButton2}")
}
LWin & AppsKey::
SearchFirefoxFromClipboard(*) {
    SetTimer(SendXButton2, 0)
    SetTitleMatchMode "RegEx"
    if !(wTitle := WinExist("ahk_exe \w+fox.exe$"))
        Return 0
    SetTitleMatchMode 2
    wIDstr := ("ahk_id " wTitle)
    WinGetPos , , &wWidth
    if (wWidth < 701)
        WinMove , , 701, , wIDstr
    WinActivate wIDstr
    WinWait wIDstr
    SetKeyDelay 25, 5
    SendEvent "{LCtrl Down}tkv{LCtrl Up}{Enter}"
}
; Activate window below current in the z-order
ActivateZIndex3(*) {
    SetTimer(SendXButton2, 0)
    DetectHiddenWindows False
    WinActivate WinGetList()[3]
    DetectHiddenWindows True
}
; Activate window 2 z-orders down
ActivateZIndex4(*) {
    SetTimer(SendXButton2, 0)
    DetectHiddenWindows False
    WinActivate WinGetList()[4]
    DetectHiddenWindows True
}
; if right after XButton1 Up or Down ...SendPaste() | SendCut()
HotIf (*) => InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < 300)
Hotkey("LButton", ActivateZIndex3)
Hotkey("RButton", ActivateZIndex4)
HotIf
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; MOVE & SIZE WINDOWS ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\WinSizePos>
;
#b:: SizeWindow()
#s:: SizeWindowHalf()
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; SEARCH AHKV2 DOCS FROM CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\SearchV2Docs>
;
#z:: SearchV2DocsFromClipboard()
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; SEARCH AHKV2 DOCS FROM CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ;
;
LWin & WheelUp::SoundSetVolume("+2")
LWin & WheelDown::SoundSetVolume("-2")
<#MButton::SoundSetMute("+1")
#HotIf GetKeyState("LWin")

/**
 * @param {Integer} _volume
 * @param {Boolean} _toggle *
 * ### `0` ... mute if not already muted
 * ### `100` ... unmute if not already unmuted
 * ### `1-100` ... set volume level
 */
AlterSound__ShowInfo(_volume:=0, _toggle:=False) {
    static   sound_gui :={}
         , _gw:=35, _gh:=100
         ,   _duration :=0x07D0
         ,    _opacity :=0xFF
         ,     AW_HIDE :=0x00010000
         , AW_ACTIVATE :=0x00020000
         ,    AW_BLEND :=0x00080000
    if !(sound_gui is Gui)
        _Initialize_Sound_Gui()

    _Show_Sound_Gui(*) {
        DllCall( "AnimateWindow", "Ptr", sound_gui.Hwnd
                                , "Int", 500
                                , "UInt", AW_ACTIVATE|AW_BLEND )
    }
    _Hide_Sound_Gui(*){
        DllCall( "AnimateWindow", "Ptr", sound_gui.Hwnd
                                , "Int", 500
                                , "UInt", AW_HIDE|AW_BLEND )
    }
    _Initialize_Sound_Gui(*) {
        ; @type {String} ExStyle, prevents window getting focus
        WS_EX_NOACTIVATE:="E0x08000000"
        sound_gui := Gui("+AlwaysOnTop -Caption +" WS_EX_NOACTIVATE)
        sound_gui.MarginX := sound_gui.MarginY := 0
        sound_gui.Add("Text", "x0 y0 w35 h100")
        sound_gui.SetFont("s14 cc35166", "Cousine")
        sound_gui.Show("x" 10 " y" (A_ScreenHeight-10-_gh) " w" _gw " h" _gh)
    }
}

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


Hotkey "F7", (*) => Reload()    ;:;:;:;:;:;:;:;:;: DEBUG ;:;:;:;:;:;:;:;:;:;:;:;
Hotkey "#F7", (*) => ExitApp()    ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
