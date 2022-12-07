#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

; #Include <DEBUG\DBT>

; #Include <GdipLib\Gdip_Custom>

/**
 *<]*>  Hotkey Overview
 * <.> ... {XButton1}, {XButton1 Up}  ==>  ClickToCopy
 *<`\> ... ... XButton1->LButton2  =>  Ctrl+v
 *<`\> ... ... XButton1->RButton2  =>  Ctrl+x
 *<`\> ... ... XButton1->XButton1  =>  Ctrl+c
 *
 * <.> ... {XButton2}, {XButton2 Up}  ==>  AltTabEsque
 *<`\> ... ... XButton2->LButton2  =>  Activate Previous Active Window
 *<`\> ... ... XButton2->XButton2  =>  SearchFirefoxFromClipboard (or Waterfox)
 *<`\> ... ... XButton2->RButton2  =>  Activate Previously Previous Active Window
 *
 *<`\> ... "<^+p"  ==>  Single Line Comment Formatting  [Hard]
 *<`\> ... "<^+o"  ==>  Single Line Comment Formatting  [Soft]
 *<`\> ... "<^+i"  ==>  Single Line Comment Formatting  [Medium]
 *
 *<`\> ... "<#v"   ==>  Scritch Notes Application
 */


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; FUCK CORTANA ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
FuckCortana(*) {
    if ProcessExist("Cortana.exe")
        ProcessClose("Cortana.exe")
}
SetTimer FuckCortana, (1000 * 5)
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; BETTER CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
if !ProcessExist("BCV2.exe") {
    Run(A_ScriptDir "\BetterClipboardV2\BCV2.exe")
}
ExitBCB(ExitReason, ExitCode) {
    if (ExitReason!="Reload")
        Run(A_ScriptDir "\BetterClipboardV2\BCV2.exe DoExit")
}
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
XButton2Down := False
$XButton2::
{
    global XButton2Down := True
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < 300)
        Return SearchFirefoxFromClipboard() . SetTimer(SendXButton2, 0)
    SetTimer(SendXButton2, -300)
}
$XButton2 Up::
{
    global XButton2Down := False
}
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
    SendEvent "{LCtrl Down}tlv{LCtrl Up}{Enter}"
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

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ;  Horizontal Scrolling (relies on <XButton2Down> variable) ; ; ; ; ; ; ; ; 
;
#HotIf !!XButton2Down
WheelUp::WheelLeft
WheelDown::WheelRight
#HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

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

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; Volume Change On Shell Tray Scroll ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\VolumeChangeGUI>
(VolChangeGui)
;
#HotIf !!((MouseGetPos(,, &_targetWin), WinGetClass("ahk_id " _targetWin))="Shell_TrayWnd")
#MaxThreadsBuffer True
$WheelUp:: 
$WheelDown::
{
    _volMag := !!(SubStr(ThisHotkey, 7)="Up") ? 1 : -1
    _volNew := Round(SoundGetVolume())+(2*_volMag)
    SoundSetVolume(_volFinal:=((_volNew > 100) ? 100 : (_volNew < 0) ? 0 : _volNew))
    VolChangeGui.Show()
}
$!WheelUp:: 
$!WheelDown::
{
    _volMag := !!(SubStr(ThisHotkey, 8)="Up") ? 1 : -1
    _volNew := Round(SoundGetVolume())+(10*_volMag)
    SoundSetVolume(_volFinal:=((_volNew > 100) ? 100 : (_volNew < 0) ? 0 : _volNew))
    VolChangeGui.Show()
}
MButton::
{
    SetTimer(ToggleMuteOnMButtonHold, -500)
}
MButton Up::
{
    SetTimer(ToggleMuteOnMButtonHold, 0)
}
ToggleMuteOnMButtonHold(*) {
    SoundSetMute(!SoundGetMute())
    VolChangeGui.UpdateMuteStatus()
    Tooltip (SoundGetMute())?("Muted"):("Unmuted")
    SetTimer (*)=>Tooltip(), -1000
}
#MaxThreadsBuffer False
#HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Alt+Shift+Drag Window Rect ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\DllCoords>
(AltShiftDragWindowRect)
Class AltShiftDragWindowRect {
    Static isMoving := False
         , isSizing := False
         , home := { hwnd: -0x000001,
                     mouse: { x: -1, y: -1 },
                     win:   { x: -1, y: -1, w: -1, h: -1 } }
         , sizeMin := { w: 100, h: 100 }
    Static __New() {
        HotIf (*)=> (!(this.isMoving) and !((A_PriorHotkey="!+LButton") and (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+LButton", ObjBindMethod(this, "StartMoving")
        HotIf (*)=> (!(this.isMoving) and !!((A_PriorHotkey="!+LButton") and (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+LButton", ObjBindMethod(this, "CenterWindow")
        HotIf (*)=> !(this.isSizing)
        Hotkey "!+RButton", ObjBindMethod(this, "StartSizing")
        HotIf
    }
    Static StartMoving(*) {
        this.isMoving := True
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        this.home.mouse := DllMouseGetPos()
        this.home.win := DllWinGetRect(this.home.hwnd)
        SetTimer MovingLoop, 1
        MovingLoop() {
            if !(GetKeyState("LButton", "P"))
                SetTimer(,0), this.isMoving := False
            else {
                mouseNow := DllMouseGetPos()
                mouseDelta := { x: mouseNow.x - this.home.mouse.x,
                                y: mouseNow.y - this.home.mouse.y }
                winPosNew := { x: this.home.win.x + mouseDelta.x,
                               y: this.home.win.y + mouseDelta.y }
                DllWinSetRect(this.home.hwnd, winPosNew)
            }
        }
    }
    Static StartSizing(*) {
        this.isSizing := True
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        this.home.mouse := DllMouseGetPos()
        this.home.win := DllWinGetRect(this.home.hwnd)
        SetTimer SizingLoop, 1
        PostMessage(0x1666,1,,, "ahk_id " this.home.hwnd)
        SizingLoop() {
            if !(GetKeyState("RButton", "P"))
                SetTimer(,0), this.isSizing := False, PostMessage(0x1666,0,,, "ahk_id " this.home.hwnd)
            else {
                mouseNow := DllMouseGetPos()
                mouseDelta := { x: mouseNow.x - this.home.mouse.x,
                                y: mouseNow.y - this.home.mouse.y }
                winSizeNew := {
                    w: ((_w:=this.home.win.w+mouseDelta.x) > this.sizeMin.w) ? _w : this.sizeMin.w,
                    h: ((_h:=this.home.win.h+mouseDelta.y) > this.sizeMin.h) ? _h : this.sizeMin.h
                }
                DllWinSetRect(this.home.hwnd, winSizeNew)
            }
        }
    }
    Static CenterWindow(*) {
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        this.home.win := DllWinGetRect(this.home.hwnd)
        winPosNew := { x: (A_ScreenWidth - this.home.win.w)/2,
                       y: (A_ScreenHeight - this.home.win.h)/2 }
        DllWinSetRect(this.home.hwnd, winPosNew)
    }
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Adjust Window Transparency ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Shift+Delete Sans Cutting ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
$+Delete::
{
    B_Clipboard := A_Clipboard
    SendEvent "{LShift Down}{Delete}{LShift Up}"
    A_Clipboard := B_Clipboard
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


Hotkey "#F7", (*) => ExitApp()    ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
