#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

; #Include <DEBUG\DBT>

#Include <GdipLib\Gdip_Custom>

/** Hotkeys List **
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  CLOSE CORTANA ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;

;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; BETTER CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
if !ProcessExist("BCV2.exe")
    Run(A_ScriptDir "\BetterClipboardV2\BCV2.exe")
;
ExitBCB(*) {
    if ProcessExist("BCV2.exe")
        WinClose("ahk_exe BCV2.exe")
}
;
OnExit ExitBCB
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


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
HotIf (*) => (WinActive("ahk_exe Code.exe")
    or WinActive("ahk_exe VSCodium.exe"))
Hotkey "<^+p", (*) => FormatSingleLineComment()
Hotkey "<^+o", (*) => FormatSingleLineComment(" ")
Hotkey "<^+i", (*) => FormatSingleLineComment("-")
HotIf (*) => WinActive("i)\.sublime-syntax" _subl_text_main_rgx)
Hotkey "<^+p", (*) => FormatSingleLineComment("#", "#", 0)
Hotkey "<^+o", (*) => FormatSingleLineComment(":", "#", 0)
Hotkey "<^+i", (*) => FormatSingleLineComment("-", "#", 0)
HotIf (*) => WinActive("i)\.ahk" _subl_text_main_rgx)
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
    if InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < 450)
        Return Send("{LCtrl Down}c{LCtrl Up}") SetTimer(SendXButton1, 0)
    ; XButton2->XButton1 Searches AutohHotkey V2 Docs
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < 450)
        Return SearchV2DocsFromClipboard() SetTimer(SendXButton1, 0)
    ; Otherwise set timer to send XButton1 for 450 ms
    SetTimer SendXButton1, -450
}
/** @type {Int} */
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
HotIf (*) => InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < 450)
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
LWin & WheelUp::AlterSound__ShowInfo("+2")
LWin & WheelDown::AlterSound__ShowInfo("-2")
<#MButton::SoundSetMute("+1")
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


/** ### AlterSound__ShowInfo()
 * @param {Integer | String} _volume
 *
 * `0-100` Set volume level
 *
 * `+n` Increment volume level
 *
 * `-n` Decremement volume level
 *
 * `toggle` Toggle mute/unmute
 *
 * `mute` Mute if not muted
 *
 * `unmute` Unmute if not unmuted
 *
 * @param {Integer} _guiWidth
 * @param {Integer} _guiHeight
 * @param {Integer} _guiDuration
 * @param {Integer} _guiFadeDuration
 */
AlterSound__ShowInfo(_volume:="", _guiWidth:=35, _guiHeight:=100
                                , _guiDuration:=2000, _guiFadeDuration:=300) {
         /**
          * @type {Gui} #
          * Gui object containing volume/mute status */
    static sound_gui := {}
         /**
          * @type {GuiControl} #
          * Progress gui control representing volume */
         , sound_prog := {}
         /**
          * @type {dwFlag} #
          * DWORD hide window flag for `AnimateWindow` */
         , AW_HIDE := 0x00010000
         /**
          * @type {dwFlag} #
          * DWORD show window flag for `AnimateWindow` */
         , AW_ACTIVATE := 0x00020000
         /**
          * @type {dwFlag} #
          * DWORD fading animation flag for `AnimateWindow`*/
         , AW_BLEND := 0x00080000
         /**
          * @type {String} #
          * ExStyle, prevents window getting focus */
         , WS_EX_NOACTIVATE := "E0x08000000"

    if !(sound_gui is Gui)
        _Initialize_Sound_Gui()

    if (_volume ~= "^[\+\-](0|1)?[0-9][0-9]?$") {
        SoundSetVolume(_volume)
        _currentVolume := Round(SoundGetVolume())
        _currentMute := SoundGetMute()
        sound_prog.Value := _currentVolume
        ToolTip(_currentVolume ", " (_currentMute ? "On" : "Off"))
        SetTimer((*)=>Tooltip(), -1000)
    } else if (_volume ~= "^(1[0-9]{2}|[1-9][0-9]|[0-9])$") {

    }

    if ControlGetVisible(sound_prog) {
        SetTimer _Hide_Sound_Gui, -2000
    } else {
        _Show_Sound_Gui()
        SetTimer _Hide_Sound_Gui, -2000
    }

    _Show_Sound_Gui(*) {
        DllCall( "AnimateWindow", "Ptr", sound_gui.Hwnd
                                , "Int", _guiFadeDuration
                                , "UInt", AW_ACTIVATE|AW_BLEND )
    }
    _Hide_Sound_Gui(*) {
        DllCall( "AnimateWindow", "Ptr", sound_gui.Hwnd
                                , "Int", _guiFadeDuration
                                , "UInt", AW_HIDE|AW_BLEND )
    }
    _Initialize_Sound_Gui(*) {
        sound_gui := Gui("+AlwaysOnTop -Caption +" WS_EX_NOACTIVATE)
        sound_gui.MarginX := sound_gui.MarginY := 0
        sound_gui.SetFont("s14 cc35166", "Cousine")
        sound_prog := sound_gui.Add("Progress", "x0 y0 w35 h100 Vertical Smooth", SoundGetVolume())
        sound_gui.Show("x" 10 " y" (A_ScreenHeight-10-_guiHeight) " w" _guiWidth " h" _guiHeight " Hide NA")
    }
}
; Hotkey "F8", (*) => AlterSound__ShowInfo()


Hotkey "F7", (*) => Reload()    ;:;:;:;:;:;:;:;:;: DEBUG ;:;:;:;:;:;:;:;:;:;:;:;
Hotkey "#F7", (*) => ExitApp()    ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
