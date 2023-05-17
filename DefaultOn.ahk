#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

; #Include <DEBUG\DBT>
#Include <Utils\DetectComputer>
#Include <Utils\ConfTool>
#Include <Utils\BuiltinsExtend>
#Include <Utils\SearchV2Docs>
#Include <Utils\VolumeChangeGUI>
#Include <Utils\WinTransparency>
#Include <Utils\FormatComment>
#Include <Utils\URLPuppy>
#Include *i %A_ScriptDir%\ScinSkratch\Scritch.ahk
#Include <Utils\BindUtil\BindUtil>
#Include <Utils\WinUtil\WinUtil>


;; Script Config Class

Class ScriptDOConf {
    IsCapsDown         := False
    CurrentCapsMod     := ""
    CapsUpLeftHandKeys := [
        "",
        "^", "^!", "^+", "^#" , "^!+", "^!#",
        "!", "!+", "!#", "!+#",
        "+", "+#",
        "#"
    ]
    _subl_text_main_rgx := "\s.*Sublime\sText.+\(UNREGISTERED\)"
    _vsc_text_main_rgx  := ".*Visual\sStudio\sCode"
    X1NoCopy := False
    X2IsDown := False
    X1Delay  := 325
    X2Delay  := 325
    ThisPC   := __PC.name
    WindowCycleOffset := 1
    bcv2_exe := "BCV2.exe"
}

;; Global Config Class

Class GblDOConf extends ConfTool {
    /** 
     * @prop {ConfTool.SectionEdit} _enabled_edit 
     */
    _enabled_edit := {}

    __New() {
        super.__New(".\DOsrc\.ahkonf", Map(
            "General", Map(
                "X1Delay" , 325,
                "X2Delay" , 325,
                "X1NoCopy", 0,
                "X2IsDown", 0,
                "CloseCortanaInterval", 5000,
                "WindowCycleOffset", 1,
                "ReloadMessageDuration", 4000
            ),
            "Paths", Map(
                "BCV2Exe"    , "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\BetterClipboardV2\BCV2.exe",
                "ScritchAhk" , "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\ScinSkratch\Scritch.ahk",
                "AhkCodeTemp", "C:\WINDOWS\TEMP\A_TempCode.ahk",
                "AhkUIA"     , "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe",
                "OpenEnvVars", "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
            ),
            "Enabled", Map(
                "AltShiftWinDrag", 1 ,
                "BCV2"           , 1 ,
                "FormatComment"  , 1 ,
                "MouseHotkeys"   , 1 ,
                "Scritch"        , 1 ,
                "SearchV2"       , 1 ,
                "Transparency"   , 1 ,
                "VolumeChange"   , 1 ,
                "WinSizePos"     , 1 ,
                "CloseCortana"   , 1 ,
                "SearchFirefox"  , 1 ,
                "ShiftDelete"    , 1 ,
                "FocusOnHover"   , 1 ,
            ),
            "BCV2", Map(
                "Source", "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\BetterClipboardV2\BCV2.exe",
                "Dest"  , "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\DOsrc\BCV2.exe"
            ),
            "OpenEnvVars", Map(
                "Source", "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\Lib\Utils\UIA\OpenEnvironmentVars.ahk",
                "Dest"  , "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\DOsrc\OpenEnvironmentVars.ahk"
            ),
            "UIA64", Map(
                "Source", "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe",
                "Dest"  , "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\DOsrc\AutoHotkey64_UIA.exe"
            )
        ))
        this.Validate()
        this._enabled_edit := ConfTool.SectionEdit(this, "Enabled", "bool")
    }

    Class InstallProp {
        /** 
         * @prop {String} Dest 
         */
        Dest => ""
        /** 
         * @prop {String} Source 
         */
        Source => ""
    }

    EnabledEdit => this._enabled_edit

    Enabled => this.Ini.Enabled
    General => this.Ini.General
    Paths   => this.Ini.Paths
    /** 
     * @prop {GblDOConf.InstallProp} BCV2 
     */
    BCV2 => this.Ini.BCV2
    /** 
     * @prop {GblDOConf.InstallProp} OpenEnvVars 
     */
    OpenEnvVars => this.Ini.OpenEnvVars
    /** 
     * @prop {GblDOConf.InstallProp} UIA64 
     */
    UIA64 => this.Ini.UIA64
}


/** 
 * @var {GblDOConf} _G `GLOBAL` Config 
 */
_G := GblDOConf()

/** 
 * @var {ScriptDOConf} _S `SCRIPT` Config 
 */
_S := ScriptDOConf()
_S.X1Delay := _G.General.X1Delay
_S.X2Delay := _G.General.X2Delay
_S.WindowCycleOffset := _G.General.WindowCycleOffset

if __PC.name = "primary"
    _S.WindowCycleOffset -= 1

/** 
 * @var {Map} _T `TEMP` Config 
 */
_T := Map()

Hotkey "#F11", (*)=>_G.EnabledEdit.Show()

TraySetIcon ".\DOsrc\DefaultOn-1-1.png"

; _G.General.CloseCortanaInterval := 10 * 1000
; _G.General.ReloadMessageDuration := 4000


TriggerReload(*)
{
    min_dur := reload_delay := 500
    msg_dur := Max(_G.General.ReloadMessageDuration, min_dur)
    JKQuickToast(
        "Reloading DefaultOn.ahk",
        "Reloading...",
        msg_dur
    )
    SetTimer(
        (*)=>Reload(),
        (-1) * (msg_dur + reload_delay)
    )
}

Hotkey( "#F12", (*)=>TriggerReload() )
; Hotkey( "#Delete", (*)=>ExitApp() ),
Hotkey( "#F7", (*)=>ExitApp() )


; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:

JKQuickTip(_msg, _timeout_ms) {
    Try {
        _msg_str := String(_msg)
        _timeout_ms_int := Integer(_timeout_ms) * -1
        _types_are_valid := True
    } Catch Error as _invalid_types_err {
        _types_are_valid := False
    }
    If (_types_are_valid) {
        Tooltip _msg_str
        SetTimer((*)=>Tooltip(), _timeout_ms_int)
    }
}

JKQuickToast(_msg, _title, _timeout_ms?) {
    _timeout_ms := _timeout_ms ?? _G.General.ReloadMessageDuration
    ; HideTrayTip(*) {
    ;     TrayTip
    ;     if SubStr(A_OSVersion, 1, 3) = "10." {
    ;         A_IconHidden := True
    ;         SetTimer(
    ;                     (*) => (A_IconHidden := False),
    ;                     -200
    ;                 )
    ;     }
    ; }
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
    ; if _types_are_valid {
    ;     TrayTip _msg_str, _title_str
    ;     SetTimer (*)=> TrayTip(), _timeout_ms_int
    ;     SetTimer(
    ;                 (*)=>HideTrayTip(),
    ;                 _timeout_ms_int
    ;             )
    ; } else {
    ;     TrayTip "The passed parameters did not have the correct types",
    ;             "Could not display specified toast message"
    ;     SetTimer (*)=>TrayTip(), 4 * 1000 * (-1)
    ;     SetTimer(
    ;                 (*)=>HideTrayTip(),
    ;                 -4000
    ;             )
    ; }
}

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  FUCK CORTANA ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
FuckCortana(*) {
    if !_G.Enabled.CloseCortana
        return
    if ProcessExist("Cortana.exe")
        ProcessClose("Cortana.exe")
}
SetTimer FuckCortana, _G.General.CloseCortanaInterval
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  BETTER CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
; ExitBCB(ExitReason:="I want to", ExitCode?, *) {
;     if (ExitReason!="Reload") and !!ProcessExist(_S.bcv2_exe)
;         Run(_G.Paths.BCV2Exe " Off")
; }
; RestartBCB(*) {
;     Run(_G.Paths.BCV2Exe)
; }
; ToggleBCV2Process(*) {
;     Run _G.Paths.BCV2Exe (!!ProcessExist(_S.bcv2_exe) ? " Off" : "")
; }
(BCV2Manager)
Class BCV2Manager {
    Static _hotkeys := Map()
    Static __New() {
        OnExit ObjBindMethod(this, "WhenExit")
        if not _G.Enabled.BCV2
            return
        if !ProcessExist(_S.bcv2_exe)
            Run _G.Paths.BCV2Exe " On"
        this._hotkeys["#+c"] := (*)=> Run(_G.Paths.BCV2Exe " Off")
        this._hotkeys["#!c"] := (*)=> Run(_G.Paths.BCV2Exe " Toggle")
        this._hotkeys["^#c"] := (*)=> MsgBox(
            IniRead(A_AppData "/BetterClipboard/BCB.ini", "Settings", "State", "unset")
        )
        this.EnableHotkeys()
    }

    Static WhenExit(_exit_reason, *) {
        if (_exit_reason = "Reload") or !ProcessExist(_S.bcv2_exe)
            return 0
        Run _G.Paths.BCV2Exe " Off"
        return 0
    }

    static EnableHotkeys(*) {
        HotIf (*)=> !!_G.Enabled.BCV2
        for _key, _func in this._hotkeys
            Hotkey _key, _func, "On"
        HotIf
    }

    static DisableHotkeys(*) {
        for _key, _func in this._hotkeys
            Hotkey _key, "Off"
    }
}
; if !ProcessExist(_S.bcv2_exe) and !!_G.Enabled.BCV2
;     Run _G.Paths.BCV2Exe " On"
; BCV2OnExit(_exit_reason, *) {
;     ; if _exit_reason != "Reload" and !!ProcessExist(_S.bcv2_exe)
;     if _exit_reason != "Reload"
;         Run _G.Paths.BCV2Exe " Off"
;     return 0
; }
; OnExit BCV2OnExit
; HotIf (*)=> !!_G.Enabled.BCV2
; Hotkey "#+c", (*)=> Run(_G.Paths.BCV2Exe " Off"), "On"
; Hotkey "#!c", (*)=> Run(_G.Paths.BCV2Exe " On"), "On"
; HotIf

;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; SCRITCH NOTES ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;
ToggleNotesApp() {
    Static ScritchResourcePath := A_ScriptDir "\ScinSkratch",
            /** 
             * @type {ScritchGui} NotesApp 
             */
           NotesApp := False
    if !!NotesApp {
        NotesApp.ToggleGui()
    }
    else {
        NotesApp := ScritchGui(ScritchResourcePath, startHidden := True)
        NotesApp.ToggleGui
        NotesAppIsSet := True
    }
}
if !!FileExist(A_ScriptDir "\ScinSkratch\Scritch.ahk"){
    HotIf (*) => !!_G.Enabled.Scritch
    Hotkey "<#v", (*)=>ToggleNotesApp()
    HotIf
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  COMMENTS FORMATTING ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;; Format Comment Hotkeys
;
SetTitleMatchMode "Regex"
SetTitleMatchMode "Slow"
HotIf (*) => _G.Enabled.FormatComment and ((WinActive("i)\.ahk" _S._vsc_text_main_rgx)
    or WinActive("ahk_exe VSCodium.exe")))
Hotkey "<^+p", (*) => FormatSingleLineComment()
Hotkey "<^+o", (*) => FormatSingleLineComment(" ")
Hotkey "<^+i", (*) => FormatSingleLineComment("-")
HotIf (*) => _G.Enabled.FormatComment and WinActive("i)\.sublime-syntax" _S._subl_text_main_rgx)
Hotkey "<^+p", (*) => FormatSingleLineComment("#", "#", 0)
Hotkey "<^+o", (*) => FormatSingleLineComment(":", "#", 0)
Hotkey "<^+i", (*) => FormatSingleLineComment("-", "#", 0)
HotIf (*) => _G.Enabled.FormatComment and WinActive("i)\.ahk" _S._subl_text_main_rgx)
Hotkey "<^+p", (*) => FormatSingleLineComment("#", "`;", 0)
Hotkey "<^+o", (*) => FormatSingleLineComment("=", "`;", 0)
Hotkey "<^+i", (*) => FormatSingleLineComment("|", "`;", 1)
HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  CLICK TO COPY|CUT|PASTE ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
; Kick it all off
; $XButton1::
OnX1Down()
{
    ; Two XButton1 Up or Downs in <iGENERAL.X1Delay> ms Sends <LCtrl+C>, cancels sending XButton1
    if InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < _S.X1Delay) and !_S.X1NoCopy {
        _S.X1NoCopy := True
        Send("{LCtrl Down}c{LCtrl Up}")
        SetTimer(SendXButton1, 0)
        Return
    }
    ; XButton2->XButton1 Searches AutohHotkey V2 Docs
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < _S.X1Delay)
        Return SearchV2DocsFromClipboard() SetTimer(SendXButton1, 0)

    ; Otherwise set timer to send XButton1 after <iGENERAL.X1Delay> ms
    SetTimer SendXButton1, - _S.X1Delay
    _S.X1NoCopy := False
}
; Easier to activate when hand can move around mouse
; $XButton1 Up:: Return
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
HotIf (*) => !!_G.Enabled.MouseHotkeys
Hotkey "$XButton1", (*)=>OnX1Down()
Hotkey "$XButton1 Up", (*)=>""
; if right after XButton1 Up or Down ...SendPaste() | SendCut()
HotIf (*) => !!_G.Enabled.MouseHotkeys and ( InStr(A_PriorHotkey, "XButton1")
                    and (A_TimeSincePriorHotkey < _S.X1Delay)
                    and !_S.X1NoCopy )
Hotkey("LButton", SendPaste)
Hotkey("RButton", SendCut)
HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; XBUTTON2 ALT-TAB-ESQUE ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
_S.X2IsDown := False
; $XButton2::
OnX2Down(*)
{
    _S.X2IsDown := True
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < _S.X2Delay)
        Return SearchBrowserFromClipboard() . SetTimer(SendXButton2, 0)
    SetTimer(SendXButton2, -_S.X2Delay)
}
; $XButton2 Up::
; {
;     iGENERAL.X2IsDown := False
; }
SendXButton2(*) {
    SetTimer(,0)
    Return Send("{XButton2}")
}
if !!_G.Enabled.SearchFirefox {
    Hotkey "LWin & AppsKey", (*)=>SearchBrowserFromClipboard()
    Hotkey "LWin & RWin", (*)=>SearchBrowserFromClipboard()
}
SearchBrowserFromClipboard(*) {
    SetTimer(SendXButton2, 0)
    ; ddg_url := "https://www.duckduckgo.com/?q=" .
            ;    (A_Clipboard).Replace("\+", "%2B")
                            ; .Replace("\,", "%2C")
                            ; .Replace("\/", "%2F")
                            ; .Replace("\\", "%5C")
                            ; .Replace("\#", "%23")
                            ; .Replace("\$", "%24")
                            ; .Replace("\%", "%25")
                            ; .Replace("\&", "%26")
                            ; .Replace("\"", "%27")
                            ; .Replace("\s", "+")
    ; Run __PC.default_browser " " ddg_url

    Run __PC.default_browser " " URLPuppy.BuildDDGSearch(A_Clipboard)

    ; SetTitleMatchMode "RegEx"
    ; SetTitleMatchMode 2
    ; wIDstr := ("ahk_exe i)" __PC.default_browser.Replace("\.", "\."))
    ; if not WinExist(wIDstr) {
    ;     Run(__PC.default_browser)
    ;     new_win := WinUtil.WinWaitNewActive(wIDstr, 5)
    ; } else WinActivate(wIDstr)

    ; ; WinGetPos , , &wWidth
    ; ; if (wWidth < 701 and brsr == "fire")
    ; ;     WinMove , , 701, , wIDstr
    ; ; WinActivate wIDstr
    ; ; WinWaitActive wIDstr

    ; _kdelay := A_KeyDelay, _kdur := A_KeyDuration
    ; A_KeyDelay := 25
    ; A_KeyDuration := 5

    ; ; SetKeyDelay 25, 5

    ; SendEvent("{LCtrl Down}") , Sleep(10)
    ; SendEvent("t")            , Sleep(10)
    ; SendEvent("l")            , Sleep(10)
    ; SendEvent("v")            , Sleep(10)
    ; SendEvent("{LCtrl Up}")   , Sleep(10)
    ; SendEvent("{Enter}")
    ; A_KeyDelay := _kdelay
    ; A_KeyDuration := _kdur
}
; Activate window below current in the z-order
OnX2LButton(*) {
    SetTimer(SendXButton2, 0)
    WhenMouseOverBrowser(_focus_hwnd, *) {
        if not WinExist(_focus_hwnd)
            return
        WinActivate()
        if not WinWaitActive(,, 2)
            return
        pre_dly := A_KeyDelay
        pre_dur := A_KeyDuration
        A_KeyDelay := 20
        A_KeyDuration := 20
        Send "{LCtrl Down}{Tab}{LCtrl Up}"
        A_KeyDelay := pre_dly
        A_KeyDuration := pre_dur
    }
    MouseGetPos(&_mx, &_my, &_hwnd)
    if WinGetProcessName(_hwnd) ~= "^\s*(waterfox|Maxthon)\.exe\s*$"
        WhenMouseOverBrowser(_hwnd)
    else
        WinActivate("ahk_id " WinUtil.PrevWindow[1 + _S.WindowCycleOffset])
    ; DetectHiddenWindows False
    ; WinActivate WinGetList()[3+3]
    ; DetectHiddenWindows True
}
; Activate window 2 z-orders down
OnX2RButton(*) {
    SetTimer(SendXButton2, 0)
    WhenMouseOverBrowser(_focus_hwnd, *) {
        if not WinExist(_focus_hwnd)
            return
        WinActivate()
        if not WinWaitActive(,, 2)
            return
        pre_dly := A_KeyDelay
        pre_dur := A_KeyDuration
        A_KeyDelay := 20
        A_KeyDuration := 20
        Send "{LCtrl Down}{LShift Down}{Tab}{LShift Up}{LCtrl Up}"
        A_KeyDelay := pre_dly
        A_KeyDuration := pre_dur
    }
    MouseGetPos(&_mx, &_my, &_hwnd)
    if WinGetProcessName(_hwnd) ~= "^\s*(waterfox|Maxthon)\.exe\s*$"
        WhenMouseOverBrowser(_hwnd)
    else
        WinActivate("ahk_id " WinUtil.PrevWindow[2 + _S.WindowCycleOffset])
    ; DetectHiddenWindows False
    ; WinActivate WinGetList()[4+3]
    ; DetectHiddenWindows True
}
HotIf (*) => !!_G.Enabled.MouseHotkeys
HotKey "$XButton2", (*)=>OnX2Down()
Hotkey "$XButton2 Up", (*)=>(_S.X2IsDown:=False)
; if right after XButton1 Up or Down ...SendPaste() | SendCut()
HotIf (*) => !!_G.Enabled.MouseHotkeys and !!(InStr(A_PriorHotkey, "XButton2") and
              (A_TimeSincePriorHotkey < _S.X2Delay))
Hotkey("LButton", OnX2LButton)
Hotkey("RButton", OnX2RButton)
HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  MOVE & SIZE WINDOWS ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;; WinSizePos Hotkeys
;
HotIf (*)=> !!_G.Enabled.WinSizePos
Hotkey "#b", (*)=> WinUtil.Cycler.Fill(WinExist("A"))
; Hotkey "#b", (*) => WinUtil.Sizer.WinFull()
Hotkey "#s", (*)=> WinUtil.Cycler.HalfFill(WinExist("A"))
; Hotkey "#s", (*) => WinUtil.Sizer.WinHalf()
HotIf
; Hotkey "#b", (*)=> SizeWindow()
; Hotkey "#s", (*)=> SizeWindowHalf()
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ;  SEARCH AHKV2 DOCS FROM CLIPBOARD ; ; ; ; ; ; ; ; ; ;
;
;; Search AHKv2 Hotkeys
;
HotIf (*)=> !!_G.Enabled.SearchV2
Hotkey "#z", (*)=> SearchV2DocsFromClipboard()
HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; Volume Change On Shell Tray Scroll ; ; ; ; ; ; ; ; ; ; ; ;
;
;; Volume Change Gui
;
(VolChangeGui)
;
;
HotIf (*) => !!_G.Enabled.VolumeChange
#MaxThreadsBuffer True
HotIf (*)=> !!(WinUtil.WinUnderCursor["class"] ~= "Shell_(Secondary)?TrayWnd")
Hotkey "$WheelUp"   , (_THK)=>OnShellTrayScroll(_THK)
Hotkey "$WheelDown" , (_THK)=>OnShellTrayScroll(_THK)
Hotkey "$!WheelUp"  , (_THK)=>OnShellTrayAltScroll(_THK)
Hotkey "$!WheelDown", (_THK)=>OnShellTrayAltScroll(_THK)
Hotkey "MButton"    , (*)=>SetTimer(ToggleMuteOnMButtonHold, -500)
Hotkey "MButton Up" , (*)=>SetTimer(ToggleMuteOnMButtonHold, 0)
HotIf
OnShellTrayScroll(_ThisHotkey)
{
    _volMag := !!(SubStr(_ThisHotkey, 7)="Up") ? 1 : -1
    _volNew := Round(SoundGetVolume())+(4*_volMag)
    SoundSetVolume(_volFinal:=((_volNew > 100) ? 100 : (_volNew < 0) ? 0 : _volNew))
    VolChangeGui.AnimateShow()
}
OnShellTrayAltScroll(_ThisHotkey)
{
    _volMag := !!(SubStr(_ThisHotkey, 8)="Up") ? 1 : -1
    _volNew := Round(SoundGetVolume())+(10*_volMag)
SoundSetVolume(_volFinal:=((_volNew > 100) ? 100 : (_volNew < 0) ? 0 : _volNew))
    VolChangeGui.AnimateShow()
}
ToggleMuteOnMButtonHold(*) {
    SoundSetMute(!SoundGetMute())
    VolChangeGui.UpdateMuteStatus()
    Tooltip (SoundGetMute())?("Muted"):("Unmuted")
    SetTimer (*)=>Tooltip(), -1000
}
#MaxThreadsBuffer False
HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Alt+Shift+Drag Window Rect ; ; ; ; ; ; ; ; ; ; ;
;
;; AltShiftWinDrag
;
if !!_G.Enabled.AltShiftWinDrag
    (AltShiftDragWindowRect).InitHotkeys()
Class AltShiftDragWindowRect {
    Static isMoving := False
         , isSizing := False
         , home := { hwnd: -0x000001,
                     mouse: { x: -1, y: -1 },
                     win:   { x: -1, y: -1, w: -1, h: -1 } }
         , sizeMin := { w: 100, h: 100 }
    Static InitHotkeys() {
        HotIf (*)=> (_G.Enabled.AltShiftWinDrag     and
                    !(this.isMoving)                and
                    !((A_PriorHotkey="!+LButton")   and
                    (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+LButton", ObjBindMethod(this, "StartMoving")
        HotIf (*)=> (_G.Enabled.AltShiftWinDrag     and
                    !(this.isMoving)                and
                    !!((A_PriorHotkey="!+LButton")  and
                    (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+LButton", ObjBindMethod(this, "HalfWindow")
        HotIf (*)=> (_G.Enabled.AltShiftWinDrag     and
                    !(this.isSizing)                and
                    !((A_PriorHotkey="!+RButton")   and
                    (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+RButton", ObjBindMethod(this, "StartSizing")
        HotIf (*)=> (_G.Enabled.AltShiftWinDrag     and
                    !(this.isSizing)                and
                    !!((A_PriorHotkey="!+RButton")  and
                    (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+RButton", ObjBindMethod(this, "FitWindow")
        HotIf (*)=> (_G.Enabled.AltShiftWinDrag     and
                    !(this.isSizing)                and
                    !((A_PriorHotkey="!+MButton")   and
                    (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+MButton", ObjBindMethod(this, "CenterWindow")
        HotIf
    }
    Static StartMoving(*) {
        this.isMoving := True
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        this.home.mouse := WinVector.DLLUtil.DllMouseGetPos()
        this.home.mouse := WinVector.DLLUtil.DllMouseGetPos()
        this.home.win := WinVector.DLLUtil.DllWinGetRect(this.home.hwnd)
        SetTimer MovingLoop, 1
        MovingLoop() {
            if !(GetKeyState("LButton", "P"))
                SetTimer(,0), this.isMoving := False
            else {
                mouseNow := WinVector.DLLUtil.DllMouseGetPos()
                mouseDelta := { x: mouseNow.x - this.home.mouse.x,
                                y: mouseNow.y - this.home.mouse.y }
                winPosNew := { x: this.home.win.x + mouseDelta.x,
                               y: this.home.win.y + mouseDelta.y }
                WinVector.DLLUtil.DllWinSetRect(this.home.hwnd, winPosNew)
            }
        }
    }
    Static StartSizing(*) {
        this.isSizing := True
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        this.home.mouse := WinVector.DLLUtil.DllMouseGetPos()
        this.home.win := WinVector.DLLUtil.DllWinGetRect(this.home.hwnd)
        SetTimer SizingLoop, 1
        PostMessage(0x1666,1,,, "ahk_id " this.home.hwnd)
        SizingLoop() {
            if !(GetKeyState("RButton", "P")) {
                SetTimer(,0)
                this.isSizing := False
                PostMessage(0x1666,0,,, "ahk_id " this.home.hwnd)
            }
            else {
                mouseNow := WinVector.DLLUtil.DllMouseGetPos()
                mouseDelta := { x: mouseNow.x - this.home.mouse.x,
                                y: mouseNow.y - this.home.mouse.y }
                winSizeNew := {
                    w: ((_w:=this.home.win.w+mouseDelta.x) > this.sizeMin.w) ?
                                                        _w : this.sizeMin.w,
                    h: ((_h:=this.home.win.h+mouseDelta.y) > this.sizeMin.h) ?
                        DllCall("User32.dll\SystemParametersInfo",
                                "UInt", 0x100C, "UInt", 0, "UIntP", SPITrack, "UInt", False) . "`n" .
                                                        _h : this.sizeMin.h
                }
                WinVector.DLLUtil.DllWinSetRect(this.home.hwnd, winSizeNew)
            }
        }
    }
    Static CenterWindow(*) {
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        this.home.win := WinVector.DLLUtil.DllWinGetRect(this.home.hwnd)
        winPosNew := { x: (A_ScreenWidth - this.home.win.w)/2,
                       y: (A_ScreenHeight - this.home.win.h)/2 }
        WinVector.DLLUtil.DllWinSetRect(this.home.hwnd, winPosNew)
    }
    Static FitWindow(*) {
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        WinUtil.Sizer.WinFull(this.home.hwnd)
    }
    Static HalfWindow(*) {
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        WinUtil.Sizer.WinHalf(this.home.hwnd)
    }
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Adjust Window Transparency ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;; WinTransparency
;
(WinTransparency)
;
StepTransparencyAll(_direction) {
    clean_list := WinUtil.FilteredWinList[WinGetList()]
    for _hwnd in clean_list
        WinTransparency.StepWindow(_direction, "ahk_id " _hwnd)
}
if !!_G.Enabled.Transparency {
    Hotkey "!#f" , (*)=>WinTransparency.StepActive("Up")
    Hotkey "#f", (*)=>WinTransparency.StepActive("Down")
    ; Hotkey "!#t" , (*)=>WinTransparency.StepAllWindows("Up")
    ; Hotkey "#t", (*)=>WinTransparency.StepAllWindows("Down")
    Hotkey "^#g", (*)=>WinTransparency.ToggleActive()
    Hotkey "^#b", (*)=>WinTransparency.PromptSetActive()
    Hotkey "^#r", (*)=>WinTransparency.ResetActive()
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Shift+Delete Sans Cutting ; ; ; ; ; ; ; ; ; ; ; ;
;
if !!_G.Enabled.ShiftDelete
    Hotkey "$+Delete", (*)=> OnShiftDelete()
OnShiftDelete(*)
{
    B_Clipboard := A_Clipboard
    SendEvent "{LShift Down}{Delete}{LShift Up}"
    A_Clipboard := B_Clipboard
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:

:*:iidt::
{
    SendInput FormatTime(, "M/d/yyyy HH:mm")
}
:*:iidate::
{
    SendInput FormatTime(, "M/d/yyyy")
}
:*:iitime::
{
    SendInput FormatTime(, "HH:mm")
}
:*:p3p3::P3t3rP@n

Hotkey "^#e", (*)=> OpenEnvironmentVars()
OpenEnvironmentVars(){
    Try
        Run "`"" _G.Paths.AhkUIA "`"" A_Space "`"" _G.Paths.OpenEnvVars "`""
    Catch Error as err
        MsgBox A_ThisFunc "::`n" err.Extra
}

; --- Wezterm Config ----------------------------------------------------------
; -----------------------------------------------------------------------------

OnCapsDownGlobal(*) {
    global _S
    _S.IsCapsDown := True
    if GetKeyState("LWin")
        _S.CurrentCapsMod := "Middle"
    else if GetKeyState("LAlt") and GetKeyState("LShift")
        _S.CurrentCapsMod := "Right"
    else _S.CurrentCapsMod := "Left"
    Click(_S.CurrentCapsMod " Down")
}

OnCapsUpGlobal(*) {
    global _S
    _S.IsCapsDown := False
    Click _S.CurrentCapsMod " Up"
}

OnCapsDownWezterm(*)
{
    if GetKeyState("Shift", "P")
        SetStoreCapsLockMode(False) ,
            SendEvent("{CapsLock}") ,
         SetStoreCapsLockMode(True)
    else SendEvent( "{LCtrl Down}"  .
                    "{LAlt Down}"   .
                    "{LShift Down}" .
                    "p"             .
                    "{LShift Up}"   .
                    "{LAlt Up}"     .
                    "{LCtrl Up}"    )
}

SetupCapsLock(*) {
    global _S
    HotIf (*) => (( not WinActive("ahk_exe wezterm-gui.exe")) and (_S.IsCapsDown))
    for _, lfk in _S.CapsUpLeftHandKeys
        Hotkey lfk "CapsLock Up", OnCapsUpGlobal
    HotIf
}

HotIf (*)=> WinActive("ahk_exe wezterm-gui.exe")
Hotkey "*CapsLock", OnCapsDownWezterm
Hotkey "*CapsLock Up", (*)=>0
HotIf (*)=> ((not WinActive("ahk_exe wezterm-gui.exe")) and (not _S.IsCapsDown))
Hotkey "*CapsLock", OnCapsDownGlobal
HotIf
SetupCapsLock


KillHelpWindows()
{
    help_windows := WinGetList("ahk_exe hh.exe")
    for hhwin in help_windows
        if WinExist("ahk_id " hhwin)
            WinClose hhwin
}

/** @param {String|Number} [_class]
  * @param {...*}
 */
KillWindowClass(_class?, *) {
    living_windows   := WinGetList( "ahk_class " (IsSet(_class) ? _class :
        (slaughtered := WinGetClass("ahk_id " WinExist("A")))))
    death_total := 0
    for target in living_windows
        if WinExist("ahk_id " target)
            WinClose target, death_total += 1
    JKQuickToast(
        ("[ " String(slaughtered ? slaughtered : _class) " ] R.I.P.")
      , "Deaths: " String(death_total)
      , 5000
    )
}

/**
 * @class
 * @extends LeaderKeys
 */
Class WindowFairy extends LeaderKeys {
; Class WindowFairy extends KeyTable {

    increment := WinVector.Coord(20, 20, 30, 30),
    segment := {
        x: Round((A_ScreenWidth - 8*2) / 4),
        y: Round((A_ScreenHeight - 8*2) / 4)
    }
    default_mult := WinVector.Coord(1, 1, 1, 1),
    _coords := WinVector.Coord(),
    _coords_ready := False,
    weblinks := Map()

    Static __New() {
        this.instance := this()
        this.instance.Enabled := True
    }

    /**
     *
     * @param {String} [_leader="Alt & Space"]
     * @param {String} [_timeout="none"]
     * @param {Any} [default_increment] - Useless atm
     * @returns {WindowFairy}
     */
    __New(_leader := "Alt & Space", _timeout := "none", default_increment?) {
        super.__New(_leader, _timeout)
        this.MapKey("Up",
            (*) => this.Nudge(WinVector.Coord.Up.Mul(this.segment.y)))
        this.MapKey("Down",
            (*) => this.Nudge(WinVector.Coord.Down.Mul(this.segment.y)))
        this.MapKey("Left",
            (*) => this.Nudge(WinVector.Coord.Left.Mul(this.segment.x)))
        this.MapKey("Right",
            (*) => this.Nudge(WinVector.Coord.Right.Mul(this.segment.x)))

        wFairyMovements := Map(
            "Numpad1", (*) => Run("")
        )

        this.MapKey("[", (*) => this.Nudge(WinVector.Coord.Thin.Mul(this.segment.x)))
        this.MapKey("]", (*) => this.Nudge(WinVector.Coord.Wide.Mul(this.segment.x)))
        this.MapKey("-", (*) => this.Nudge(WinVector.Coord.Short.Mul(this.segment.y)))
        this.MapKey("=", (*) => this.Nudge(WinVector.Coord.Tall.Mul(this.segment.y)))
        this.MapKey(",", (*) => this.Cycle(1))
        this.MapKey(".", (*) => this.Cycle(2))
        this.MapKey("/", (*) => this.Cycle(3))
        this.MapKey("F12", (*) => TriggerReload())
        this.MapKey("BackSpace", (*) => this.Deactivate())
        this.MapKey("^/", (*) => this.Deactivate())


        mv := {
            x: this.segment.x // 6,
            y: this.segment.y // 6,
            w: this.segment.x // 3,
            h: this.segment.y // 3,
        }

        this.MapKeyPath(["p", "p"],
            (*) => (
                this.Nudge(
                    WinVector.Coord.Down.Mul(mv.y)
                    .Add(WinVector.Coord.Right.Mul(mv.x))
                    .Add(WinVector.Coord.Thin.Mul(mv.w))
                    .Add(WinVector.Coord.Short.Mul(mv.h))
                )
            ), "max"
        )

        this.MapKeyPath(["k", "k"], (*)=> WinClose(WinExist("A")))
        this.MapKeyPath(["k", "l"], (*)=>
            WinUtil.WinCloseProcesses(WinGetProcessName(WinExist("A")).Replace("\.", "\.")))
        this.MapKeyPath(["k", "h", "h"], (*)=> WinUtil.WinCloseProcesses("hh\.exe"))
        this.MapKeyPath(["o", "v", "s"], (*)=> Run("VSCodium.exe"))
        this.MapKeyPath(["o", "m", "x"], (*)=> Run("Maxthon.exe"))
        this.MapKeyPath(["o", "e", "x"], (*)=> Run("explorer.exe"))
        this.MapKeyPath(["o", "w", "z"], (*)=> Run("wezterm-gui.exe"))
        this.MapKeyPath(["o", "s", "t"], (*)=> Run("sublime_text.exe"))
        this.MapKeyPath(["o", "s", "m"], (*)=> Run("sublime_merge.exe"))
        this.MapKeyPath(["o", "i", "t"], (*)=> Run("itunes.exe"))
        this.MapKeyPath(["o", "l", "s"], (*)=> Run("C:\Users\" A_UserName "\AppData\Local\Logseq\Logseq.exe"))
        this.MapKeyPath(["o", "s", "i"], (*)=> Run("C:\Users\" A_UserName "\Desktop\Soundit.lnk"))
        this.MapKeyPath(["c", "c", "b"], (*)=> Run(_G.Paths.BCV2Exe " Toggle"))
        this.MapKeyPath(["a", "o", "t"], (*)=> WinSetAlwaysOnTop(true, WinExist("A")))
        this.MapKeyPath(["n", "o", "t"], (*)=> WinSetAlwaysOnTop(false, WinExist("A")))
        this.MapKeyPath(["f", "w", "f"], (*)=> !!(WinExist("ahk_exe waterfox.exe")) ? (WinActivate()) :
            (JKQuickToast("There aren't any waterfox windows open at the moment", "",)))


        _ahk_cache_dir := "C:\Users\" A_UserName "\.cache\.ahk2.jk\linkache\"

;         _ph_run_path := _ahk_cache_dir ".default-on.run.ph"
;         run_ph := !!FileExist(_ph_run_path) ? FileRead(_ph_run_path) : ""
;
;         this.MapKeyPath(["o", "p", "h"],
;             (*) => Run(run_ph)
;         )

        this.weblinks := weblinks := LinkTable()

        _ph_link_path  := _ahk_cache_dir "ph.linkpath"
        _han_link_path := _ahk_cache_dir "han.linkpath"
        _fb_link_path  := _ahk_cache_dir "fb.linkpath"
        _tph_link_path := _ahk_cache_dir "tph.linkpath"

        link_ph  := !!FileExist(_ph_link_path)  ? FileRead(_ph_link_path)  : "duckduckgo.com"
        link_han := !!FileExist(_han_link_path) ? FileRead(_han_link_path) : "duckduckgo.com"
        link_fb  := !!FileExist(_fb_link_path)  ? FileRead(_fb_link_path)  : "duckduckgo.com"
        link_tph := !!FileExist(_tph_link_path) ? FileRead(_tph_link_path) : "duckduckgo.com"
        link_emmylua     := "https://www.github.com/LuaLS/lua-language-server/wiki/Annotations"
        link_thqbygithub := "https://www.github.com/thqby/vscode-autohotkey2-lsp"

        weblinks.Link[           "ph" ,      ["p", "h"] ] := link_ph
        weblinks.Link[          "han" , ["h", "a", "n"] ] := link_han
        weblinks.Link[           "fb" ,      ["f", "b"] ] := link_fb
        weblinks.Link[          "tph" , ["t", "p", "h"] ] := link_tph
        weblinks.Link[      "emmylua" , ["e", "m", "y"] ] := link_emmylua
        weblinks.Link[  "thqbygithub" , ["t", "h", "q"] ] := link_thqbygithub
        weblinks.Link[        "gmail" ,      ["g", "m"] ] := "https://www.gmail.com"
        weblinks.Link[       "github" , ["g", "i", "t"] ] := "https://www.github.com"
        ; weblinks.Link[      "soundit" ,      ["s", "i"] ] := "http://192.168.1.4:9697/"
        weblinks.link[      "textnow" ,      ["t", "n"] ] := "https://www.textnow.com/"
        weblinks.Link[    "fancyedit" ,      ["f", "p"] ] := "https://www.textpaint.net/"
        weblinks.Link[ "fancyconvert" ,      ["f", "c"] ] := "https://www.textfancy.com/font-converter"
        weblinks.Link[ "vscodemarket" , ["v", "s", "m"] ] := "https://marketplace.visualstudio.com/VSCode"
        weblinks.Link[          "ddg" , ["d", "d", "g"] ] := "https://www.duckduckgo.com"
        weblinks.Link[       "paypal" , ["p", "a", "y"] ] := "https://www.paypal.com/"
        weblinks.Link[       "reddit" , ["r", "e", "d"] ] := "https://www.reddit.com"
        weblinks.Link[          "ora" , ["o", "r", "a"] ] := "https://www.ora.sh/"


        this.MapKey("l", (*) => (weblinks.Activate(2000)), True)

    }

    Cycle(count:=1) {
        target_window := WinUtil.PrevWindow[count + _S.WindowCycleOffset]
        WinActivate("ahk_id " target_window)
    }

    Coords {
        Get => this._coords
        Set => this._coords := Value
    }

    AHwnd => WinExist("A")

    Nudge(delta, hwnd:=0) {
        hwnd := hwnd ? hwnd : this.AHwnd
        ; _aPos := this.APos[hwnd]
        _aPos := WinVector.ActiveCoord.Add(delta)
        ; _aPos.x += delta.x
        ; _aPos.y += delta.y
        ; _aPos.w += delta.w
        ; _aPos.h += delta.h
        WinMove _aPos.x, _aPos.y, _aPos.w, _aPos.h, "ahk_id " hwnd
    }

    ClipWindow() {

    }

    FenceWindow() {

    }
}

Class LaunchFairy {
    /** 
     * @prop {KeyTable} main 
     */
    main := {}
    __New(_timeout := 3000) {
        this.main := KeyTable(_timeout)
    }

    /**
     * @param {Array} _key_path
     * @param {Func} _action
     */
    MapKeyPath(_key_path, _action)
    {
        pathlen := _key_path.Length
        ktbls := []
        for _key in _key_path
            ktbls.Push {}
        ktbls[pathlen] := KeyTable(this.main.timeout)
        ktbls[pathlen].MapKey( _key_path[pathlen], _action, True )
        Loop (pathlen - 1) {
            P_Index := pathlen - A_Index
            ktbls[P_Index] := KeyTable(this.main.timeout)
            ktbls[P_Index].MapKey(
                    _key_path[P_Index],
                    (*)=>(ktbls[(P_Index+1)].Activate()),
                    True
                )
        }

        this.main.MapKey( _key_path[1], (*)=>(ktbls[2].Activate()), True)
    }
}
;
; wFairy := WindowFairy()
; wFairy.Enabled := True

#F10::
{
    Msgbox A_ComputerName
    A_Clipboard := A_ComputerName
    WinUtil.ActiveWindowTracking := !WinUtil.ActiveWindowTracking
}

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Configuration ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

; Class DefaultOnConfiguration {
;     Static     config := {}
;         ,    Validate := {}
;         ,    CONF_DIR := A_ScriptDir "\DOsrc"
;         ,   CONF_NAME := "DOConfig.conf"
;
;     Static __New() {
;         this.Validate := (_this, _ini)=> _this.Conf.Validate(_ini)
;     }
;
;     Static TryInstallFiles() {
;         if !FileExist("")
;             FileInstall "", ""
;     }
;
;     Class Defaults {
;         /** ### General Configuration
;          * ~~~
;          * X1Delay              := 325
;          * X2Delay              := 325
;          * X1NoCopy             := False
;          * X2IsDown             := False
;          * CloseCortanaInterval := 1000*5
;          * ~~~
;          */
;         Class CONF_GENERAL {
;             X1Delay              := 325
;             X2Delay              := 325
;             X1NoCopy             := False
;             X2IsDown             := False
;             CloseCortanaInterval := 1000*5
;         }
;         /** ### Paths Configuration
;          * ~~~
;          * BCV2Exe              := A_ScriptDir "\BetterClipboardV2\BCV2.exe"
;          * ScritchAhk           := A_ScriptDir "\ScinSkratch\Scritch.ahk"
;          * AhkUIA               := "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
;          * AhkCodeTemp          := A_Temp "\A_TempCode.ahk"
;          * OpenEnvVars          := A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
;          * ~~~
;          */
;         Class CONF_PATHS {
;             BCV2Exe              := A_ScriptDir "\BetterClipboardV2\BCV2.exe"
;             ScritchAhk           := A_ScriptDir "\ScinSkratch\Scritch.ahk"
;             AhkUIA               := "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
;             AhkCodeTemp          := A_Temp "\A_TempCode.ahk"
;             OpenEnvVars          := A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
;         }
;         /** ### Enabled Features
;          * ~~~
;          * CloseCortana    := True, BCV2          := True
;          * Scritch         := True, FormatComment := True
;          * TabSwitcher     := True, Transparency  := True
;          * AltShiftWinDrag := True, VolumeChange  := True
;          * WinSizePos      := True, SearchV2      := True
;          * MouseHotkeys    := True, SearchFirefox := True
;          * ShiftDelete     := True
;          * ~~~
;          */
;         Class CONF_ENABLED {
;             CloseCortana         := True
;             BCV2                 := True
;             Scritch              := True
;             FormatComment        := True
;             TabSwitcher          := True
;             Transparency         := True
;             AltShiftWinDrag      := True
;             VolumeChange         := True
;             WinSizePos           := True
;             SearchV2             := True
;             MouseHotkeys         := True
;             SearchFirefox        := True
;             ShiftDelete          := True
;         }
;         /** ### Handling file installations
;          * ~~~
;          * [[this => DefaultConfiguration.Conf]]
;          * ~~~
;          * ` `***`Script to be run with UIAccess`***`-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`
;          * ~~~
;          * OpenEnvVars["Source"] := A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
;          * OpenEnvVars[ "Dest" ] := this.CONF_DIR "\OpenEnvironmentVars.ahk"
;          * ~~~
;          * ` `***`AHK .exe to run scripts with UIAccess`***`-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-`
;          * ~~~
;          * UIA64["Source"] := "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
;          * UIA64[ "Dest" ] := this.CONF_DIR "\AutoHotkey64_UIA.exe"
;          * ~~~
;          * ` `***`BetterClipboardV2 .exe to run`***`-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-`
;          * ~~~
;          * BCV2["Source"] := A_ScriptDir "\BetterClipboardV2\BCV2.exe"
;          * BCV2[ "Dest" ] := this.CONF_DIR "\BCV2.exe"
;          * ~~~
;          */
;         Class CONF_INSTALLS {
;             OpenEnvVars := Map( "Source", A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk",         ;
;                                 "Dest"  , DefaultOnConfiguration.CONF_DIR "\OpenEnvironmentVars.ahk" )  ;
;             UIA64 := Map( "Source", "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe",              ;
;                           "Dest"  , DefaultOnConfiguration.CONF_DIR "\AutoHotkey64_UIA.exe" ) ;         ;
;             BCV2 := Map( "Source", A_ScriptDir "\BetterClipboardV2\BCV2.exe",                 ;         ;
;                          "Dest"  , DefaultOnConfiguration.CONF_DIR "\BCV2.exe") ;             ;         ;
;         }
;     }
;
;     Class Conf {
;         Static  CONF_DIR      := DefaultOnConfiguration.CONF_DIR
;             ,   CONF_INI      := DefaultOnConfiguration.CONF_NAME
;             ,   CONF_INI_FP   := this.CONF_DIR "\" this.CONF_INI
;             ,   CONF_GENERAL  := DefaultOnConfiguration.Defaults.CONF_GENERAL()
;             ,   CONF_PATHS    := DefaultOnConfiguration.Defaults.CONF_PATHS()
;             ,   CONF_ENABLED  := DefaultOnConfiguration.Defaults.CONF_ENABLED()
;             ,   CONF_INSTALLS := DefaultOnConfiguration.Defaults.CONF_INSTALLS()
;             ,   IniGeneral    := {}
;             ,   IniPaths      := {}
;             ,   IniEnabled    := {}
;             ,   IniInstalls   := {}
;
;         Static __New() {
;             this.IniGeneral  := DefaultOnConfiguration.Conf._IniGeneral()
;             this.IniPaths    := DefaultOnConfiguration.Conf._IniPaths()
;             this.IniEnabled  := DefaultOnConfiguration.Conf._IniEnabled()
;             this.IniInstalls := DefaultOnConfiguration.Conf._IniInstalls()
;         }
;
;
;         Class _IniGeneral {
;             Static INI_SECTION := "General"
;             __Get(Name, Params) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 iniSection := DOConf.Conf._IniGeneral.INI_SECTION
;                 Return IniRead(confFP, iniSection, Name, "null")
;             }
;             __Set(Name, Params, Value) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 iniSection := DOConf.Conf._IniGeneral.INI_SECTION
;                 IniWrite(Value, confFP, iniSection, Name)
;             }
;         }
;
;         Class _IniPaths {
;             Static INI_SECTION := "Paths"
;             __Get(Name, Params) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 iniSection := DOConf.Conf._IniPaths.INI_SECTION
;                 Return IniRead(confFP, iniSection, Name, "null")
;             }
;             __Set(Name, Params, Value) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 iniSection := DOConf.Conf._IniPaths.INI_SECTION
;                 IniWrite(Value, confFP, iniSection, Name)
;             }
;         }
;
;
;         Class _IniEnabled {
;             Static INI_SECTION := "Enabled"
;             __Get(Name, Params) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 iniSection := DOConf.Conf._IniEnabled.INI_SECTION
;                 Return IniRead(confFP, iniSection, Name, "null")
;             }
;             __Set(Name, Params, Value) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 iniSection := DOConf.Conf._IniEnabled.INI_SECTION
;                 IniWrite(Value, confFP, iniSection, Name)
;             }
;         }
;
;         Class _IniInstalls {
;             __Get(Name, Params) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 Param := !!(Params.Length) ? Params[1] : ""
;                 if !(Param)
;                     Return { Source: IniRead(confFP, Name, "Source", "null"),
;                              Dest:   IniRead(confFP, Name, "Dest"  , "null")  }
;                 else if IsAlnum(Param) and (Param~="^(Source|Dest)$")
;                     Return IniRead(confFP, Name, Param, "null")
;                 else Return { Source: "null", Dest: "null" }
;             }
;             __Set(Name, Params, Value) {
;                 DOConf := DefaultOnConfiguration
;                 confFP := DOConf.Conf.CONF_INI_FP
;                 Param := !!(Params.Length) ? Params[1] : ""
;                 if !(Param) {
;                     if (Type(Value)="Object"){
;                         if Value.HasOwnProp("Source")
;                             IniWrite(Value.Source, confFP, Name, "Source")
;                         if Value.HasOwnProp("Dest")
;                             IniWrite(Value.Dest, confFP, Name, "Dest")
;                     } else if (Type(Value)="Map") {
;                         if Value.Has("Source")
;                             IniWrite(Value["Source"], confFP, Name, "Source")
;                         if Value.Has("Dest")
;                             IniWrite(Value["Dest"], confFP, Name, "Dest")
;                     }
;                 } else if IsAlnum(Param) and IsAlnum(Value) and (Param~="^(Source|Dest)$")
;                     IniWrite(Value, confFP, Name, Param)
;             }
;         }
;
;         ; @return {DefaultOnConfiguration.Defaults.CONF_GENERAL}
;         Static LiteralIniGeneral() {
;             _clone := DefaultOnConfiguration.Defaults.CONF_GENERAL()
;             for _k, _v in _clone.OwnProps()
;                 if ((i_v:=this.IniGeneral.%(_k)%)!="null")
;                     _clone.%(_k)% := i_v
;             Return _clone
;         }
;
;         ; @return {DefaultOnConfiguration.Defaults.CONF_PATHS}
;         Static LiteralIniPaths() {
;             _clone := DefaultOnConfiguration.Defaults.CONF_PATHS()
;             for _k, _v in this.CONF_PATHS.OwnProps()
;                 if ((i_v:=this.IniPaths.%(_k)%)!="null")
;                     _clone.%(_k)% := i_v
;             Return _clone
;         }
;
;         Static LiteralIniEnabled() {
;             _clone := DefaultOnConfiguration.Defaults.CONF_ENABLED()
;             for _k, _v in this.CONF_ENABLED.OwnProps()
;                 if ((i_v:=this.IniEnabled.%(_k)%)!="null")
;                     _clone.%(_k)% := i_v
;             Return _clone
;         }
;
;         Static LiteralIniInstalls() {
;             _clone := DefaultOnConfiguration.Defaults.CONF_INSTALLS()
;             for _id, _paths in this.CONF_INSTALLS.OwnProps() {
;                 _src:=this.IniInstalls.%(_id)%["Source"]
;                 _dst:=this.IniInstalls.%(_id)%["Dest"]
;                 if (_src!="null" and _dst!="null")
;                     _clone.%(_id)% := { Source: _src, Dest: _dst }
;             }
;             Return _clone
;         }
;
;         ; @prop {Boolean} CONF_INI_EXISTS
;         Static CONF_INI_EXISTS => !!(FileExist(this.CONF_INI_FP)~="A|N")
;
;         ; @prop {Boolean} CONF_DIR_EXISTS
;         Static CONF_DIR_EXISTS => !!(DirExist(this.CONF_DIR))
;
;         Static Validate(_ini:=True) {
;             IniValidate() {
;                 _iniSections := Map( "General" , Map("existing", Map(), "new", Map())
;                                    , "Paths"   , Map("existing", Map(), "new", Map())
;                                    , "Enabled" , Map("existing", Map(), "new", Map())
;                                    , "Installs", Map("existing", Map(), "new", Map()) )
;                 for _k, _v in this.CONF_GENERAL.OwnProps() {
;                     _ini_v := this.IniGeneral.%(_k)%
;                     if !!(_ini_v="null")
;                         this.IniGeneral.%(_k)% :=
;                             _iniSections["General"]["new"][_k] := _v
;                     else _iniSections["General"]["existing"][_k] := _ini_v
;                 }
;                 for _k, _v in this.CONF_PATHS.OwnProps() {
;                     _ini_v := this.IniPaths.%(_k)%
;                     if !!(_ini_v="null")
;                         this.IniPaths.%(_k)% :=
;                             _iniSections["Paths"]["new"][_k] := _v
;                     else _iniSections["Paths"]["existing"][_k] := _ini_v
;                 }
;                 for _k, _v in this.CONF_ENABLED.OwnProps() {
;                     _ini_v := this.IniEnabled.%(_k)%
;                     if !!(_ini_v="null")
;                         this.IniEnabled.%(_k)% :=
;                             _iniSections["Enabled"]["new"][_k] := _v
;                     else _iniSections["Enabled"]["existing"][_k] := _ini_v
;                 }
;                 for _id, _paths in this.CONF_INSTALLS.OwnProps() {
;                     if (Type(_paths)="Map") {
;                         if (_paths.Has("Source") and _paths.Has("Dest")) {
;                             _ini_src := this.IniInstalls.%(_id)%["Source"]
;                             _ini_dst := this.IniInstalls.%(_id)%["Dest"]
;                             if (_ini_src="null" or _ini_dst="null")
;                                 this.IniInstalls.%(_id)% :=
;                                     _iniSections["Installs"]["new"][_id] := _paths
;                             else
;                                 _iniSections["Installs"]["existing"][_id] :=
;                                     Map("Source", _ini_src, "Dest" , _ini_dst)
;                         }
;                     }
;                 }
;                 Return _iniSections
;             }
;             FPValidate(fp, dp) {
;                 GlobalDOConf := DefaultOnConfiguration
;                 if (!FileExist(fp) and !!FileExist(dp)) {
;                     FileAppend "[General]`r`n`r`n[Paths]`r`n`r`n[Enabled]", fp
;                     initRes := IniValidate()
;                     if (!!FileExist(fp))
;                         initRes.__Class := "ValidConf"
;                     else initRes.__Class := "InvalidConf"
;                     return initRes
;                 } else if (!FileExist(dp)) {
;                     retVal := Map(), retVal.__Class := "InvalidDir"
;                     Return GlobalDOConf.FileDirInvalid(fp, dp)
;                 }
;             }
;             DirValidate(fp, dp) {
;                 GlobalDOConf := DefaultOnConfiguration
;                 if !(FileExist(dp)) {
;                     SplitPath dp,, &confDirParent
;                     if !!(DirExist(confDirParent)) {
;                         DirCreate dp
;                         Return GlobalDOConf.FileDirWritten(fp, dp)
;                     } else Return GlobalDOConf.FileDirInvalid(fp, dp)
;                 } else GlobalDOConf.FileDirValid(fp, dp)
;             }
;             retVal := { dir: DirValidate(this.CONF_INI_FP, this.CONF_DIR)
;                       , file: FPValidate(this.CONF_INI_FP, this.CONF_DIR)
;                       , init: Map("unset", True) }
;             retval.init := (!!IsObject(retVal.file) && !!ObjHasOwnProp(retVal.file, "init")) ?
;                             retVal.file.init : (_ini) ? IniValidate()
;                                 : Map("unset", True)
;             Return retVal
;         }
;     }
;
;     Class FileValidationResult {
;         filePath := ""
;         fileDir := ""
;         __New(_filePath, _fileDir:="") {
;             this.filePath := _filePath
;             this.fileDir := !!(_fileDir) ? _fileDir : (SplitPath(_filePath,,&_fileDir), _fileDir)
;         }
;     }
;
;     Class FileWritten extends DefaultOnConfiguration.FileValidationResult {
;         verified := False
;         init := {}
;         __New(_filePath, _fileDir:="", _verified:=False, _init := "") {
;             super.__New(_filePath, _fileDir)
;             this.verified := _verified
;             this.init := (!!_init) ? _init : {}
;         }
;     }
;     Class FileDirWritten extends DefaultOnConfiguration.FileValidationResult {
;         verified := False
;         __New(_filePath, _fileDir:="", _verified:=False) {
;             super.__New(_filePath, _fileDir)
;             this.verified := _verified
;         }
;     }
;     Class FileDirInvalid extends DefaultOnConfiguration.FileValidationResult {
;         init := {}
;         __New(_filePath, _fileDir:="", _init:="") {
;             super.__New(_filePath, _fileDir)
;         }
;     }
;     Class FileDirValid extends DefaultOnConfiguration.FileValidationResult {
;         __New(_filePath, _fileDir:="") {
;             super.__New(_filePath, _fileDir)
;         }
;     }
;     Class FileInvalid extends DefaultOnConfiguration.FileValidationResult {
;         init := {}
;         __New(_filePath, _fileDir:="", _init:="") {
;             super.__New(_filePath, _fileDir)
;             this.init := (!!_init) ? _init : {}
;         }
;     }
;     Class FileValid extends DefaultOnConfiguration.FileValidationResult {
;         init := {}
;         __New(_filePath, _fileDir:="", _init:="") {
;             super.__New(_filePath, _fileDir)
;             this.init := (!!_init) ? _init : {}
;         }
;     }
; }
; CONF := (DefaultOnConfiguration)
; CONF.Validate(True)
;
; /**
;  * @var {DefaultOnConfiguration.Defaults.CONF_GENERAL} iGENERAL
;  */
; iGENERAL := DefaultOnConfiguration.Conf.LiteralIniGeneral()
;
; /**
;  * @var {DefaultOnConfiguration.Defaults.CONF_PATHS} iPATHS
;  */
; iPATHS := DefaultOnConfiguration.Conf.LiteralIniPaths()
;
; /**
;  * @var {DefaultOnConfiguration.Defaults.CONF_ENABLED} iENABLED
;  */
; iENABLED := DefaultOnConfiguration.Conf.LiteralIniEnabled()
;
; /**
;  * @var {DefaultOnConfiguration.Defaults.CONF_INSTALLS} iINSTALLS
;  */
; iINSTALLS := DefaultOnConfiguration.Conf.LiteralIniInstalls()
