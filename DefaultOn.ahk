#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include %A_ScriptDir%\Scripts
#Include Lib\DBT.ahk



/** Hotkeys List
 *  ... {XButton1}, {XButton1 Up}  ==>  ClickToCopy
 *  ... ... XButton1->LButton2  =>  Ctrl+v
 *  ... ... XButton1->RButton2  =>  Ctrl+x
 *  ... ... XButton1->XButton1  =>  Ctrl+c
 * 
 *  ... {XButton2}, {XButton2 Up}  ==>  AltTabEsque
 *  ... ... XButton2->LButton2  =>  Activate Previous Active Window
 *  ... ... XButton2->RButton2  =>  Activate Previously Previous Active Window
 *  ... ... XButton2->XButton2  =>  SearchFirefoxFromClipboard (or Waterfox)
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
#Include Scritch\Scritch.ahk
;
NotesApp := ScritchGui( A_ScriptDir "\Resources\ScritchNotes",startHidden:=True)
Hotkey "<#v", (*)=> NotesApp.ToggleGui()
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:




;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; COMMENTS FORMATTING ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
#Include AutoFormatComments\FormatSingleLineComment.ahk
;
HotIf (*)=> (
    WinActive("ahk_exe code.exe")
    or WinActive("ahk_exe VSCodium.exe")
    or WinActive("ahk_exe sublime_text.exe"))
Hotkey "<^+p", (*)=> FormatSingleLineComment()
Hotkey "<^+o", (*)=> FormatSingleLineComment(" ")
Hotkey "<^+i", (*)=> FormatSingleLineComment("-")
Hotif
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
; Easier to activate when hand can move around mouse
$XButton1 Up::Return    
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
HotIf (*)=> InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < 300)
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
        Return SearchFirefoxFromClipboard() SetTimer(SendXButton2, 0)
    SetTimer(SendXButton2, -300)
}
$XButton2 Up::Return
SendXButton2(*) {
    SetTimer(, 0)
    Send("{XButton2}")
}
LWin & AppsKey::
SearchFirefoxFromClipboard(*) {
    SetTimer(SendXButton2, 0)
    SetTitleMatchMode "RegEx"
    if !(wTitle:=WinExist("ahk_exe \w+fox.exe$"))
        Return 0
    SetTitleMatchMode 2
    wIDstr:=("ahk_id " wTitle)
    WinGetPos ,, &wWidth
    if (wWidth < 701)
        WinMove ,, 701,, wIDstr
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
HotIf (*)=> InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < 300)
Hotkey("LButton", ActivateZIndex3)
Hotkey("RButton", ActivateZIndex4)
HotIf
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:




;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; MOVE & SIZE WINDOWS ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
#Include WinSize&PosUtils.ahk
;
#b::SizeWindow()
#s::SizeWindowHalf()
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; SEARCH AHKV2 DOCS FROM CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include SearchV2Docs\searchdocs.ahk
;
#z::SearchV2DocsFromClipboard()
;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:








Hotkey "F7" , (*)=> Reload() ;:;:;:;:;:;:;:;:;: DEBUG ;:;:;:;:;:;:;:;:;:;:;:;:;:
Hotkey "#F7", (*)=> ExitApp()  ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
