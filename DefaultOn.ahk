#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

; #Include <DEBUG\DBT>

; #Include <GdipLib\Gdip_Custom>

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Configuration ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

Class DefaultOnConfiguration {
            /* @prop {DefaultOnConfiguration.Conf} config */
    Static    config := {},
            /* @prop {Func} Validate */
            Validate := {}

    Static __New() {
        /* @type {DefaultOnConfiguration.Conf} */
        this.config := conf := DefaultOnConfiguration.Conf
        this.Validate := (_this, _ini)=> _this.config.Validate(_ini)
    }

    Static TryInstallFiles() {
        if !FileExist("")
            FileInstall "", ""
    }

    Class Conf {
        Static  CONF_DIR    :=  A_ScriptDir "\DOsrc"
            ,   CONF_INI    :=  "DOConfig.conf"
            ,   CONF_INI_FP :=  this.CONF_DIR "\" this.CONF_INI
            ,   CONF_GENERAL := Map(
                    "X1Delay"               , 325,
                    "X2Delay"               , 325,
                    "X1NoCopy"              , False,
                    "X2IsDown"              , False,
                    "CloseCortanaInterval"  , 1000*5
                )
            ,   CONF_PATHS := Map(
                    "BCV2Exe"    , A_ScriptDir "\BetterClipboardV2\BCV2.exe",
                    "ScritchAhk" , A_ScriptDir "\ScinSkratch\Scritch.ahk",
                    "AhkUIA"     , "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe",
                    "AhkCodeTemp", A_Temp "\A_TempCode.ahk",
                    "OpenEnvVars", A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
                )
            ,   CONF_ENABLED := Map(
                    "CloseCortana"      , True,
                    "BCV2"              , True,
                    "Scritch"           , True,
                    "FormatComment"     , True,
                    "TabSwitcher"       , True,
                    "Transparency"      , True,
                    "AltShiftWinDrag"   , True,
                    "VolumeChange"      , True,
                    "WinSizePos"        , True,
                    "SearchV2"          , True,
                    "MouseHotkeys"      , True,
                    "SearchFirefox"     , True,
                    "ShiftDelete"       , True
                )
            ,   CONF_INSTALLS := Map(
                    "OpenEnvVars", Map(
                            "Source", A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk",
                            "Dest"  , this.CONF_DIR "\OpenEnvironmentVars.ahk"
                        ),
                    "UIA64"      , Map(
                            "Source", "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe",
                            "Dest"  , this.CONF_DIR "\AutoHotkey64_UIA.exe"
                        ),
                    "BCV2"       , Map(
                            "Source", A_ScriptDir "\BetterClipboardV2\BCV2.exe",
                            "Dest"  , this.CONF_DIR "\BCV2.exe"
                        )
            )
            ,   IniGeneral := {}
            ,   IniPaths := {}
            ,   IniEnabled := {}
            ,   IniInstalls := {}

        Static __New() {
            this.IniGeneral  := DefaultOnConfiguration.Conf._IniGeneral()
            this.IniPaths    := DefaultOnConfiguration.Conf._IniPaths()
            this.IniEnabled  := DefaultOnConfiguration.Conf._IniEnabled()
            this.IniInstalls := DefaultOnConfiguration.Conf._IniInstalls()
        }


        Class _IniGeneral {
            Static INI_SECTION := "General"
            __Get(Name, Params) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                iniSection := DOConf.Conf._IniGeneral.INI_SECTION
                Return IniRead(confFP, iniSection, Name, "null")
            }
            __Set(Name, Params, Value) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                iniSection := DOConf.Conf._IniGeneral.INI_SECTION
                IniWrite(Value, confFP, iniSection, Name)
            }
        }

        Class _IniPaths {
            Static INI_SECTION := "Paths"
            __Get(Name, Params) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                iniSection := DOConf.Conf._IniPaths.INI_SECTION
                Return IniRead(confFP, iniSection, Name, "null")
            }
            __Set(Name, Params, Value) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                iniSection := DOConf.Conf._IniPaths.INI_SECTION
                IniWrite(Value, confFP, iniSection, Name)
            }
        }

        Class _IniEnabled {
            Static INI_SECTION := "Enabled"
            __Get(Name, Params) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                iniSection := DOConf.Conf._IniEnabled.INI_SECTION
                Return IniRead(confFP, iniSection, Name, "null")
            }
            __Set(Name, Params, Value) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                iniSection := DOConf.Conf._IniEnabled.INI_SECTION
                IniWrite(Value, confFP, iniSection, Name)
            }
        }

        Class _IniInstalls {
            __Get(Name, Params) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                Param := !!(Params.Length) ? Params[1] : ""
                if !(Param)
                    Return { Source: IniRead(confFP, Name, "Source", "null"),
                             Dest:   IniRead(confFP, Name, "Dest"  , "null")  }
                else if IsAlnum(Param) and (Param~="^(Source|Dest)$")
                    Return IniRead(confFP, Name, Param, "null")
                else Return { Source: "null", Dest: "null" }
            }
            __Set(Name, Params, Value) {
                DOConf := DefaultOnConfiguration
                confFP := DOConf.Conf.CONF_INI_FP
                Param := !!(Params.Length) ? Params[1] : ""
                if !(Param) {
                    if (Type(Value)="Object"){
                        if Value.HasOwnProp("Source")
                            IniWrite(Value.Source, confFP, Name, "Source")
                        if Value.HasOwnProp("Dest")
                            IniWrite(Value.Dest, confFP, Name, "Dest")
                    } else if (Type(Value)="Map") {
                        if Value.Has("Source")
                            IniWrite(Value["Source"], confFP, Name, "Source")
                        if Value.Has("Dest")
                            IniWrite(Value["Dest"], confFP, Name, "Dest")
                    }
                } else if IsAlnum(Param) and IsAlnum(Value) and (Param~="^(Source|Dest)$")
                    IniWrite(Value, confFP, Name, Param)
            }
        }

        Static LiteralIniGeneral() {
            _clone := {}
            for _k, _v in this.CONF_GENERAL
                if ((i_v:=this.IniGeneral.%(_k)%)!="null")
                    _clone.%(_k)% := i_v
            Return _clone
        }

        Static LiteralIniPaths() {
            _clone := {}
            for _k, _v in this.CONF_PATHS
                if ((i_v:=this.IniPaths.%(_k)%)!="null")
                    _clone.%(_k)% := i_v
            Return _clone
        }

        Static LiteralIniEnabled() {
            _clone := {}
            for _k, _v in this.CONF_ENABLED
                if ((i_v:=this.IniEnabled.%(_k)%)!="null")
                    _clone.%(_k)% := i_v
            Return _clone
        }

        Static LiteralIniInstalls() {
            _clone := {}
            for _id, _paths in this.CONF_INSTALLS {
                _src:=this.IniInstalls.%(_id)%["Source"]
                _dst:=this.IniInstalls.%(_id)%["Dest"]
                if (_src!="null" and _dst!="null")
                    _clone.%(_id)% := { Source: _src, Dest: _dst }
            }
            Return _clone
        }

        /* @prop {Boolean} CONF_INI_EXISTS */
        Static CONF_INI_EXISTS => !!(FileExist(this.CONF_INI_FP)~="A|N")
        
        /* @prop {Boolean} CONF_DIR_EXISTS */
        Static CONF_DIR_EXISTS => !!(DirExist(this.CONF_DIR))

        Static Validate(_ini:=False) {
            IniValidate() {
                _iniSections := Map( "General" , Map("existing", Map(), "new", Map())
                                   , "Paths"   , Map("existing", Map(), "new", Map())
                                   , "Enabled" , Map("existing", Map(), "new", Map()) 
                                   , "Installs", Map("existing", Map(), "new", Map()) )
                for _k, _v in this.CONF_GENERAL {
                    _ini_v := this.IniGeneral.%(_k)%
                    if ( (_ini_v="null") and (this.CONF_GENERAL.Has(_k)) )
                        this.IniGeneral.%(_k)% := 
                            _iniSections["General"]["new"][_k] := _v
                    else _iniSections["General"]["existing"][_k] := _ini_v
                }
                for _k, _v in this.CONF_PATHS {
                    _ini_v := this.IniPaths.%(_k)%
                    if ( (_ini_v="null") and (this.CONF_PATHS.Has(_k)) )
                        this.IniPaths.%(_k)% := 
                            _iniSections["Paths"]["new"][_k] := _v
                    else _iniSections["Paths"]["existing"][_k] := _ini_v
                }
                for _k, _v in this.CONF_ENABLED {
                    _ini_v := this.IniEnabled.%(_k)%
                    if ( (_ini_v="null") and (this.CONF_ENABLED.Has(_k)) )
                        this.IniEnabled.%(_k)% := 
                            _iniSections["Enabled"]["new"][_k] := _v
                    else _iniSections["Enabled"]["existing"][_k] := _ini_v
                }
                for _id, _paths in this.CONF_INSTALLS {
                    if (Type(_paths)="Map") {
                        if (_paths.Has("Source") and _paths.Has("Dest")) {
                            _ini_src := this.IniInstalls.%(_id)%["Source"]
                            _ini_dst := this.IniInstalls.%(_id)%["Dest"]
                            if (_ini_src="null" or _ini_dst="null")
                                this.IniInstalls.%(_id)% :=
                                    _iniSections["Installs"]["new"][_id] := _paths
                            else 
                                _iniSections["Installs"]["existing"][_id] := 
                                    Map("Source", _ini_src, "Dest" , _ini_dst)             
                        }
                    }
                }
                Return _iniSections
            }
            FPValidate(fp, dp) {
                DOConf := DefaultOnConfiguration
                if (!FileExist(fp) and !!FileExist(dp)) {
                    FileAppend "[General]`r`n`r`n[Paths]`r`n`r`n[Enabled]", fp
                    initRes := (_ini) ? (IniValidate()) 
                        : Map("General", False, "Paths", False, "Enabled", False)
                    if (!!FileExist(fp))
                        Return DOConf.FileWritten(fp, dp, True, initRes)
                    else Return DOConf.FileInvalid(fp, dp, initRes)
                } else if (!FileExist(dp))
                    Return DOConf.FileDirInvalid(fp, dp)
            }
            DirValidate(fp, dp) {
                DOConf := DefaultOnConfiguration
                if !(FileExist(dp)) {
                    SplitPath dp,, &confDirParent
                    if !!(DirExist(confDirParent)) {
                        DirCreate dp
                        Return DOConf.FileDirWritten(fp, dp)
                    } else Return DOConf.FileDirInvalid(fp, dp)
                } else DOConf.FileDirValid(fp, dp)
            }
            retVal := { dir: DirValidate(this.CONF_INI_FP, this.CONF_DIR)
                      , file: FPValidate(this.CONF_INI_FP, this.CONF_DIR)
                      , init: Map("General", False, "Paths", False, "Enabled", False) }
            retval.init := (!!IsObject(retVal.file) && !!ObjHasOwnProp(retVal.file, "init")) ? 
                            retVal.file.init : (_ini) ? IniValidate() 
                                : Map("General", False, "Paths", False, "Enabled", False)
            Return retVal
        }
    }

    Class FileValidationResult {
        filePath := ""
        fileDir := ""
        __New(_filePath, _fileDir:="") {
            this.filePath := _filePath
            this.fileDir := !!(_fileDir) ? _fileDir : (SplitPath(_filePath,,&_fileDir), _fileDir)
        }
    }

    Class FileWritten extends DefaultOnConfiguration.FileValidationResult {
        verified := False
        init := {}
        __New(_filePath, _fileDir:="", _verified:=False, _init := "") {
            super.__New(_filePath, _fileDir)
            this.verified := _verified
            this.init := (!!_init) ? _init : {}
        }
    }
    Class FileDirWritten extends DefaultOnConfiguration.FileValidationResult {
        verified := False
        __New(_filePath, _fileDir:="", _verified:=False) {
            super.__New(_filePath, _fileDir)
            this.verified := _verified
        }
    }
    Class FileDirInvalid extends DefaultOnConfiguration.FileValidationResult {
        init := {}
        __New(_filePath, _fileDir:="", _init:="") {
            super.__New(_filePath, _fileDir)
        }
    }
    Class FileDirValid extends DefaultOnConfiguration.FileValidationResult {
        __New(_filePath, _fileDir:="") {
            super.__New(_filePath, _fileDir)
        }
    }
    Class FileInvalid extends DefaultOnConfiguration.FileValidationResult {
        init := {}
        __New(_filePath, _fileDir:="", _init:="") {
            super.__New(_filePath, _fileDir)
            this.init := (!!_init) ? _init : {}
        }
    }
    Class FileValid extends DefaultOnConfiguration.FileValidationResult {
        init := {}
        __New(_filePath, _fileDir:="", _init:="") {
            super.__New(_filePath, _fileDir)
            this.init := (!!_init) ? _init : {}
        }
    }
}
(CONF:=(DefaultOnConfiguration)).Validate(True)
/* @var {DefaultOnConfiguration.Conf.IniGeneral} */
iGENERAL := CONF.config.LiteralIniGeneral()
/* @var {DefaultOnConfiguration.Conf.IniPaths} */
iPATHS := CONF.config.LiteralIniPaths()
/* @var {DefaultOnConfiguration.Conf.IniEnabled} */
iENABLED := CONF.config.LiteralIniEnabled()
/* @var {DefaultOnConfiguration.Conf.IniInstalls} */
iINSTALLS := CONF.config.LiteralIniInstalls()
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  FUCK CORTANA ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
FuckCortana(*) {
    if ProcessExist("Cortana.exe")
        ProcessClose("Cortana.exe")
}
if !!(iENABLED.CloseCortana)
    SetTimer FuckCortana, iGENERAL.CloseCortanaInterval
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  BETTER CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
if !ProcessExist("BCV2.exe") and !!iENABLED.BCV2 {
    Run(iPATHS.BCV2Exe)
}
ExitBCB(ExitReason, ExitCode) {
    if (ExitReason!="Reload") and !!ProcessExist("BCV2.exe")
        Run(iPATHS.BCV2Exe " DoExit")
}
if !!iENABLED.BCV2
    OnExit ExitBCB
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; SCRITCH NOTES ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
#Include *i %A_ScriptDir%\ScinSkratch\Scritch.ahk
;
if (!!FileExist(A_ScriptDir "\ScinSkratch\Scritch.ahk") and !!iENABLED.Scritch) {
    ScritchResourcePath := A_ScriptDir "\ScinSkratch"
    NotesApp := ScritchGui(ScritchResourcePath, startHidden := True)
    Hotkey "<#v", (*) => NotesApp.ToggleGui()
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  COMMENTS FORMATTING ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\FormatComment>
;
if !!iENABLED.FormatComment {
    _subl_text_main_rgx := "\s.*Sublime\sText.+\(UNREGISTERED\)"
    _vsc_text_main_rgx := ".*Visual\sStudio\sCode"
    SetTitleMatchMode "Regex"
    SetTitleMatchMode "Slow"
    HotIf (*) => (WinActive("i)\.ahk" _vsc_text_main_rgx)
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
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  CLICK TO COPY|CUT|PASTE ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
iGENERAL.X1NoCopy := False
; Kick it all off
; $XButton1::
OnX1Down()
{
    ; Two XButton1 Up or Downs in <iGENERAL.X1Delay> ms Sends <LCtrl+C>, cancels sending XButton1
    if InStr(A_PriorHotkey, "XButton1") and (A_TimeSincePriorHotkey < iGENERAL.X1Delay) and !iGENERAL.X1NoCopy {
        iGENERAL.X1NoCopy := True
        Send("{LCtrl Down}c{LCtrl Up}")
        SetTimer(SendXButton1, 0)
        Return
    }
    ; XButton2->XButton1 Searches AutohHotkey V2 Docs
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < iGENERAL.X1Delay)
        Return SearchV2DocsFromClipboard() SetTimer(SendXButton1, 0)

    ; Otherwise set timer to send XButton1 after <iGENERAL.X1Delay> ms
    SetTimer SendXButton1, -iGENERAL.X1Delay
    iGENERAL.X1NoCopy := False
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
if !!iENABLED.MouseHotkeys {
    Hotkey "$XButton1", (*)=>OnX1Down()
    Hotkey "$XButton1 Up", (*)=>""
    ; if right after XButton1 Up or Down ...SendPaste() | SendCut()
    HotIf (*) => ( InStr(A_PriorHotkey, "XButton1") 
                        and (A_TimeSincePriorHotkey < iGENERAL.X1Delay) 
                        and !iGENERAL.X1NoCopy )
    Hotkey("LButton", SendPaste)
    Hotkey("RButton", SendCut)
    HotIf
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; XBUTTON2 ALT-TAB-ESQUE ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
iGENERAL.X2IsDown := False
; $XButton2::
OnX2Down(*)
{
    iGENERAL.X2IsDown := True
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < iGENERAL.X2Delay)
        Return SearchFirefoxFromClipboard() . SetTimer(SendXButton2, 0)
    SetTimer(SendXButton2, -iGENERAL.X2Delay)
}
; $XButton2 Up::
; {
;     iGENERAL.X2IsDown := False
; }
SendXButton2(*) {
    SetTimer(,0)
    Return Send("{XButton2}")
}
if !!iENABLED.SearchFirefox
    Hotkey "LWin & AppsKey", (*)=>SearchFirefoxFromClipboard()
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
if !!iENABLED.MouseHotkeys {
    HotKey "$XButton2", (*)=>OnX2Down()
    Hotkey "$XButton2 Up", (*)=>(iGENERAL.X2IsDown:=False)
    ; if right after XButton1 Up or Down ...SendPaste() | SendCut()
    HotIf (*) => InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < iGENERAL.X2Delay)
    Hotkey("LButton", ActivateZIndex3)
    Hotkey("RButton", ActivateZIndex4)
    HotIf
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ;  Horizontal Scrolling (relies on <iGENERAL.X2IsDown> variable) ; ; ; ; ; ; ; ; 
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; BROKEN ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; #HotIf !!iGENERAL.X2IsDown
; WheelUp::WheelLeft
; WheelDown::WheelRight
; #HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  MOVE & SIZE WINDOWS ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\WinSizePos>
;
if !!iENABLED.WinSizePos {
    Hotkey "#b", (*)=> SizeWindow()
    Hotkey "#s", (*)=> SizeWindowHalf()
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ;  SEARCH AHKV2 DOCS FROM CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
#Include <Utils\SearchV2Docs>
;
if !!iENABLED.SearchV2
    Hotkey "#z", (*)=> SearchV2DocsFromClipboard()
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; Volume Change On Shell Tray Scroll ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\VolumeChangeGUI>
(VolChangeGui)
;
#MaxThreadsBuffer True
if !!iENABLED.VolumeChange {
    HotIf (*)=> !!((MouseGetPos(,, &_targetWin), WinGetClass("ahk_id " _targetWin))="Shell_TrayWnd")
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
}
#MaxThreadsBuffer False
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Alt+Shift+Drag Window Rect ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
#Include <Utils\DllCoords>
if !!iENABLED.AltShiftWinDrag
    (AltShiftDragWindowRect).InitHotkeys()
Class AltShiftDragWindowRect {
    Static isMoving := False
         , isSizing := False
         , home := { hwnd: -0x000001,
                     mouse: { x: -1, y: -1 },
                     win:   { x: -1, y: -1, w: -1, h: -1 } }
         , sizeMin := { w: 100, h: 100 }
    Static InitHotkeys() {
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
#Include <Utils\WinTransparency>
;
(WinTransparency)
;
if !!iENABLED.Transparency {
    Hotkey "#t" , (*)=>WinTransparency.StepActive("Up")
    Hotkey "#g" , (*)=>WinTransparency.StepActive("Down")
    Hotkey "!#g", (*)=>WinTransparency.ToggleActive()
    Hotkey "!#b", (*)=>WinTransparency.PromptSetActive()
    Hotkey "!#r", (*)=>WinTransparency.ResetActive()
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Shift+Delete Sans Cutting ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;
if !!iENABLED.ShiftDelete
    Hotkey "$+Delete", (*)=> OnShiftDelete()
OnShiftDelete(*)
{
    B_Clipboard := A_Clipboard
    SendEvent "{LShift Down}{Delete}{LShift Up}"
    A_Clipboard := B_Clipboard
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Tab Switching ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
OnWinLeft(*)
{
    Send "{LAlt Down}{RAlt}{Tab}{LAlt Up}"
}
OnWinRight(*)
{
    Send "{LAlt Down}{RAlt}{LShift Down}{Tab}{LShift Up}{LAlt Up}"
}
if !!iENABLED.TabSwitcher {
    Hotkey "#Left", (*)=>OnWinLeft()
    Hotkey "#Right", (*)=>OnWinRight()
}
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


Hotkey "^#e", (*)=> OpenEnvironmentVars()
OpenEnvironmentVars(){
    Try
        Run "`"" iPATHS.AhkUIA "`"" A_Space iPATHS.OpenEnvVars "`""
    Catch Error as err
        MsgBox A_ThisFunc "::`n" err.Extra
}

Hotkey "#F7", (*) => ExitApp() ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
