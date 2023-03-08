#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

; #Include <DEBUG\DBT>
#Include <Utils\SearchV2Docs>
#Include <Utils\VolumeChangeGUI>
; #Include <Utils\DllCoords>
#Include <Utils\WinTransparency>
; #Include <Utils\WinSizePos>
#Include <Utils\FormatComment>
#Include *i %A_ScriptDir%\ScinSkratch\Scritch.ahk

; #Include <GdipLib\Gdip_Custom>

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Configuration ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

Class DefaultOnConfiguration {
    Static     config := {}
        ,    Validate := {}
        ,    CONF_DIR := A_ScriptDir "\DOsrc"
        ,   CONF_NAME := "DOConfig.conf"

    Static __New() {
        this.Validate := (_this, _ini)=> _this.Conf.Validate(_ini)
    }

    Static TryInstallFiles() {
        if !FileExist("")
            FileInstall "", ""
    }

    Class Defaults {
        /** ### General Configuration
         * ~~~
         * X1Delay              := 325
         * X2Delay              := 325
         * X1NoCopy             := False
         * X2IsDown             := False
         * CloseCortanaInterval := 1000*5
         * ~~~
         */
        Class CONF_GENERAL {
            X1Delay              := 325
            X2Delay              := 325
            X1NoCopy             := False
            X2IsDown             := False
            CloseCortanaInterval := 1000*5
        }
        /** ### Paths Configuration
         * ~~~
         * BCV2Exe              := A_ScriptDir "\BetterClipboardV2\BCV2.exe"
         * ScritchAhk           := A_ScriptDir "\ScinSkratch\Scritch.ahk"
         * AhkUIA               := "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
         * AhkCodeTemp          := A_Temp "\A_TempCode.ahk"
         * OpenEnvVars          := A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
         * ~~~
         */
        Class CONF_PATHS {
            BCV2Exe              := A_ScriptDir "\BetterClipboardV2\BCV2.exe"
            ScritchAhk           := A_ScriptDir "\ScinSkratch\Scritch.ahk"
            AhkUIA               := "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
            AhkCodeTemp          := A_Temp "\A_TempCode.ahk"
            OpenEnvVars          := A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
        }
        /** ### Enabled Features
         * ~~~
         * CloseCortana    := True, BCV2          := True
         * Scritch         := True, FormatComment := True
         * TabSwitcher     := True, Transparency  := True
         * AltShiftWinDrag := True, VolumeChange  := True
         * WinSizePos      := True, SearchV2      := True
         * MouseHotkeys    := True, SearchFirefox := True
         * ShiftDelete     := True
         * ~~~
         */
        Class CONF_ENABLED {
            CloseCortana         := True
            BCV2                 := True
            Scritch              := True
            FormatComment        := True
            TabSwitcher          := True
            Transparency         := True
            AltShiftWinDrag      := True
            VolumeChange         := True
            WinSizePos           := True
            SearchV2             := True
            MouseHotkeys         := True
            SearchFirefox        := True
            ShiftDelete          := True
        }
        /** ### Handling file installations
         * ~~~
         * [[this => DefaultConfiguration.Conf]]
         * ~~~
         * ` `***`Script to be run with UIAccess`***`-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`
         * ~~~
         * OpenEnvVars["Source"] := A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk"
         * OpenEnvVars[ "Dest" ] := this.CONF_DIR "\OpenEnvironmentVars.ahk"
         * ~~~
         * ` `***`AHK .exe to run scripts with UIAccess`***`-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-`
         * ~~~
         * UIA64["Source"] := "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
         * UIA64[ "Dest" ] := this.CONF_DIR "\AutoHotkey64_UIA.exe"
         * ~~~
         * ` `***`BetterClipboardV2 .exe to run`***`-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-`
         * ~~~
         * BCV2["Source"] := A_ScriptDir "\BetterClipboardV2\BCV2.exe"
         * BCV2[ "Dest" ] := this.CONF_DIR "\BCV2.exe"
         * ~~~
         */
        Class CONF_INSTALLS {
            OpenEnvVars := Map( "Source", A_ScriptDir "\Lib\Utils\UIA\OpenEnvironmentVars.ahk",         ;
                                "Dest"  , DefaultOnConfiguration.CONF_DIR "\OpenEnvironmentVars.ahk" )  ;
            UIA64 := Map( "Source", "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe",              ;
                          "Dest"  , DefaultOnConfiguration.CONF_DIR "\AutoHotkey64_UIA.exe" ) ;         ;
            BCV2 := Map( "Source", A_ScriptDir "\BetterClipboardV2\BCV2.exe",                 ;         ;
                         "Dest"  , DefaultOnConfiguration.CONF_DIR "\BCV2.exe") ;             ;         ;
        }
    }

    Class Conf {
        Static  CONF_DIR      := DefaultOnConfiguration.CONF_DIR
            ,   CONF_INI      := DefaultOnConfiguration.CONF_NAME
            ,   CONF_INI_FP   := this.CONF_DIR "\" this.CONF_INI
            ,   CONF_GENERAL  := DefaultOnConfiguration.Defaults.CONF_GENERAL()
            ,   CONF_PATHS    := DefaultOnConfiguration.Defaults.CONF_PATHS()
            ,   CONF_ENABLED  := DefaultOnConfiguration.Defaults.CONF_ENABLED()
            ,   CONF_INSTALLS := DefaultOnConfiguration.Defaults.CONF_INSTALLS()
            ,   IniGeneral    := {}
            ,   IniPaths      := {}
            ,   IniEnabled    := {}
            ,   IniInstalls   := {}

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

        ; @return {DefaultOnConfiguration.Defaults.CONF_GENERAL}
        Static LiteralIniGeneral() {
            _clone := DefaultOnConfiguration.Defaults.CONF_GENERAL()
            for _k, _v in _clone.OwnProps()
                if ((i_v:=this.IniGeneral.%(_k)%)!="null")
                    _clone.%(_k)% := i_v
            Return _clone
        }

        ; @return {DefaultOnConfiguration.Defaults.CONF_PATHS}
        Static LiteralIniPaths() {
            _clone := DefaultOnConfiguration.Defaults.CONF_PATHS()
            for _k, _v in this.CONF_PATHS.OwnProps()
                if ((i_v:=this.IniPaths.%(_k)%)!="null")
                    _clone.%(_k)% := i_v
            Return _clone
        }

        Static LiteralIniEnabled() {
            _clone := DefaultOnConfiguration.Defaults.CONF_ENABLED()
            for _k, _v in this.CONF_ENABLED.OwnProps()
                if ((i_v:=this.IniEnabled.%(_k)%)!="null")
                    _clone.%(_k)% := i_v
            Return _clone
        }

        Static LiteralIniInstalls() {
            _clone := DefaultOnConfiguration.Defaults.CONF_INSTALLS()
            for _id, _paths in this.CONF_INSTALLS.OwnProps() {
                _src:=this.IniInstalls.%(_id)%["Source"]
                _dst:=this.IniInstalls.%(_id)%["Dest"]
                if (_src!="null" and _dst!="null")
                    _clone.%(_id)% := { Source: _src, Dest: _dst }
            }
            Return _clone
        }

        ; @prop {Boolean} CONF_INI_EXISTS
        Static CONF_INI_EXISTS => !!(FileExist(this.CONF_INI_FP)~="A|N")

        ; @prop {Boolean} CONF_DIR_EXISTS
        Static CONF_DIR_EXISTS => !!(DirExist(this.CONF_DIR))

        Static Validate(_ini:=True) {
            IniValidate() {
                _iniSections := Map( "General" , Map("existing", Map(), "new", Map())
                                   , "Paths"   , Map("existing", Map(), "new", Map())
                                   , "Enabled" , Map("existing", Map(), "new", Map())
                                   , "Installs", Map("existing", Map(), "new", Map()) )
                for _k, _v in this.CONF_GENERAL.OwnProps() {
                    _ini_v := this.IniGeneral.%(_k)%
                    if !!(_ini_v="null")
                        this.IniGeneral.%(_k)% :=
                            _iniSections["General"]["new"][_k] := _v
                    else _iniSections["General"]["existing"][_k] := _ini_v
                }
                for _k, _v in this.CONF_PATHS.OwnProps() {
                    _ini_v := this.IniPaths.%(_k)%
                    if !!(_ini_v="null")
                        this.IniPaths.%(_k)% :=
                            _iniSections["Paths"]["new"][_k] := _v
                    else _iniSections["Paths"]["existing"][_k] := _ini_v
                }
                for _k, _v in this.CONF_ENABLED.OwnProps() {
                    _ini_v := this.IniEnabled.%(_k)%
                    if !!(_ini_v="null")
                        this.IniEnabled.%(_k)% :=
                            _iniSections["Enabled"]["new"][_k] := _v
                    else _iniSections["Enabled"]["existing"][_k] := _ini_v
                }
                for _id, _paths in this.CONF_INSTALLS.OwnProps() {
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
                    initRes := IniValidate()
                    if (!!FileExist(fp))
                        initRes.__Class := "ValidConf"
                    else initRes.__Class := "InvalidConf"
                    return initRes
                } else if (!FileExist(dp)) {
                    retVal := Map(), retVal.__Class := "InvalidDir"
                    Return DOConf.FileDirInvalid(fp, dp)
                }
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
                      , init: Map("unset", True) }
            retval.init := (!!IsObject(retVal.file) && !!ObjHasOwnProp(retVal.file, "init")) ?
                            retVal.file.init : (_ini) ? IniValidate()
                                : Map("unset", True)
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
CONF:=(DefaultOnConfiguration)
CONF.Validate(True)

/**
 * @var {DefaultOnConfiguration.Defaults.CONF_GENERAL} iGENERAL
 */
iGENERAL := DefaultOnConfiguration.Conf.LiteralIniGeneral()

/**
 * @var {DefaultOnConfiguration.Defaults.CONF_PATHS} iPATHS
 */
iPATHS := DefaultOnConfiguration.Conf.LiteralIniPaths()

/**
 * @var {DefaultOnConfiguration.Defaults.CONF_ENABLED} iENABLED
 */
iENABLED := DefaultOnConfiguration.Conf.LiteralIniEnabled()

/**
 * @var {DefaultOnConfiguration.Defaults.CONF_INSTALLS} iINSTALLS
 */
iINSTALLS := DefaultOnConfiguration.Conf.LiteralIniInstalls()
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

JKQuickToast(_msg, _title, _timeout_ms) {
    HideTrayTip(*) {
        TrayTip
        if SubStr(A_OSVersion, 1, 3) = "10." {
            A_IconHidden := True
            SetTimer(
                        (*) => (A_IconHidden := False),
                        -200
                    )
        }
    }
    Try {
        _msg_str := String(_msg)
        _title_str := String(_title)
        _timeout_ms_int := Integer(_timeout_ms) * -1
        _types_are_valid := True
    } Catch Error as type_err {
        _types_are_valid := False
    }
    if _types_are_valid {
        TrayTip(
                    _msg_str,
                    _title_str
               )
        SetTimer(
                    (*)=>HideTrayTip(),
                    _timeout_ms_int
                )
    } else {
        TrayTip(
                    "The passed parameters did not have the correct types",
                    "Could not display specified toast message"
               )
        SetTimer(
                    (*)=>HideTrayTip(),
                    -4000
                )
    }
}

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  FUCK CORTANA ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
FuckCortana(*) {
    if ProcessExist("Cortana.exe")
        ProcessClose("Cortana.exe")
}
if !!(iENABLED.CloseCortana)
    SetTimer FuckCortana, iGENERAL.CloseCortanaInterval
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  BETTER CLIPBOARD ; ; ; ; ; ; ; ; ; ; ; ; ; ;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; SCRITCH NOTES ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;
if (!!FileExist(A_ScriptDir "\ScinSkratch\Scritch.ahk") and !!iENABLED.Scritch) {
    ScritchResourcePath := A_ScriptDir "\ScinSkratch"
    NotesApp := ScritchGui(ScritchResourcePath, startHidden := True)
    Hotkey "<#v", (*) => NotesApp.ToggleGui()
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  COMMENTS FORMATTING ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  CLICK TO COPY|CUT|PASTE ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; XBUTTON2 ALT-TAB-ESQUE ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
iGENERAL.X2IsDown := False
; $XButton2::
OnX2Down(*)
{
    iGENERAL.X2IsDown := True
    if InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < iGENERAL.X2Delay)
        Return SearchBrowserFromClipboard() . SetTimer(SendXButton2, 0)
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
    Hotkey "LWin & AppsKey", (*)=>SearchBrowserFromClipboard()
SearchBrowserFromClipboard(*) {
    SetTimer(SendXButton2, 0)
    SetTitleMatchMode "RegEx"
    if !((wTitle := WinExist("ahk_exe \w+fox.exe$")) and brsr := "fire")
        if !((wTitle := WinExist("ahk_exe i).+maxthon.*")) and brsr := "max")
            Return 0
    SetTitleMatchMode 2
    wIDstr := ("ahk_id " wTitle)
    WinGetPos , , &wWidth
    if (wWidth < 701 and brsr == "fire")
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
    WinActivate WinGetList()[3+3]
    DetectHiddenWindows True
}
; Activate window 2 z-orders down
ActivateZIndex4(*) {
    SetTimer(SendXButton2, 0)
    DetectHiddenWindows False
    WinActivate WinGetList()[4+3]
    DetectHiddenWindows True
}
if !!iENABLED.MouseHotkeys {
    HotKey "$XButton2", (*)=>OnX2Down()
    Hotkey "$XButton2 Up", (*)=>(iGENERAL.X2IsDown:=False)
    ; if right after XButton1 Up or Down ...SendPaste() | SendCut()
    HotIf (*) => !!(InStr(A_PriorHotkey, "XButton2") and (A_TimeSincePriorHotkey < iGENERAL.X2Delay))
    Hotkey("LButton", ActivateZIndex3)
    Hotkey("RButton", ActivateZIndex4)
    HotIf
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ;  Horizontal Scrolling (relies on <iGENERAL.X2IsDown> variable) ; ; ; ;
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; BROKEN ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; #HotIf !!iGENERAL.X2IsDown
; WheelUp::WheelLeft
; WheelDown::WheelRight
; #HotIf
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;  MOVE & SIZE WINDOWS ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
;
if !!iENABLED.WinSizePos {
    Hotkey "#b", (*)=> WinUtil.Sizer.SizeWindow()
    Hotkey "#s", (*)=> WinUtil.Sizer.SizeWindowHalf()
    ; Hotkey "#b", (*)=> SizeWindow()
    ; Hotkey "#s", (*)=> SizeWindowHalf()
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ;  SEARCH AHKV2 DOCS FROM CLIPBOARD ; ; ; ; ; ; ; ; ; ;
;
;
if !!iENABLED.SearchV2
    Hotkey "#z", (*)=> SearchV2DocsFromClipboard()
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; Volume Change On Shell Tray Scroll ; ; ; ; ; ; ; ; ; ; ; ;
;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Alt+Shift+Drag Window Rect ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
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
        Hotkey "!+LButton", ObjBindMethod(this, "HalfWindow")
        HotIf (*)=> (!(this.isSizing) and !((A_PriorHotkey="!+RButton") and (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+RButton", ObjBindMethod(this, "StartSizing")
        HotIf (*)=> (!(this.isSizing) and !!((A_PriorHotkey="!+RButton") and (A_TimeSincePriorHotkey < 300)))
        Hotkey "!+RButton", ObjBindMethod(this, "FitWindow")
        HotIf (*)=> (!(this.isSizing) and !((A_PriorHotkey="!+MButton") and (A_TimeSincePriorHotkey < 300)))
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
            if !(GetKeyState("RButton", "P"))
                SetTimer(,0), this.isSizing := False, PostMessage(0x1666,0,,, "ahk_id " this.home.hwnd)
            else {
                mouseNow := WinVector.DLLUtil.DllMouseGetPos()
                mouseDelta := { x: mouseNow.x - this.home.mouse.x,
                                y: mouseNow.y - this.home.mouse.y }
                winSizeNew := {
                    w: ((_w:=this.home.win.w+mouseDelta.x) > this.sizeMin.w) ? _w : this.sizeMin.w,
                    h: ((_h:=this.home.win.h+mouseDelta.y) > this.sizeMin.h) ? _h : this.sizeMin.h
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
        WinUtil.Sizer.SizeWindow(this.home.hwnd)
    }
    Static HalfWindow(*) {
        MouseGetPos(,,&_aHwnd)
        this.home.hwnd := _aHwnd
        WinUtil.Sizer.SizeWindowHalf(this.home.hwnd)
    }
}
;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Adjust Window Transparency ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Shift+Delete Sans Cutting ; ; ; ; ; ; ; ; ; ; ; ;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; Tab Switching ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
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
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:

; Windows applications *really* don't like it when their caption is removed,
; so this really doesn't have much use at all.
; ToggleWindowCaption() {
;     Static WS_CAPTION := 0x00C00000, GWL_STYLE := -16
;     aHwnd := WinExist("A")
;     wStyle := DllCall("GetWindowLongPtrW", "Ptr", aHwnd, "Int", GWL_STYLE)

;     DetectHiddenWindows 2

;     QuickTip(msg) {
;         Tooltip msg
;         SetTimer (*)=>ToolTip(), 1000
;     }

;     if (wStyle & WS_CAPTION) {
;         QuickTip(wStyle ": Has Caption")
;         wStyle &= ~WS_CAPTION
;         DllCall("SetWindowLongPtrW", "Ptr", aHwnd, "Int", GWL_STYLE, "Int", wStyle)
;         WinRedraw "ahk_id " aHwnd
;     } else {
;         QuickTip(wStyle ": No Caption")
;         wStyle &= WS_CAPTION
;         DllCall("SetWindowLongPtrW", "Ptr", aHwnd, "Int", GWL_STYLE, "Int", wStyle)
;         WinRedraw "ahk_id " aHwnd
;     }
; }
; Hotkey "#F8", (*)=> ToggleWindowCaption()

:*:insertdtime::
{
    SendInput FormatTime(, "M/d/yyyy HH:mm")
}
:*:insertdate::
{
    SendInput FormatTime(, "M/d/yyyy")
}
:*:inserttime::
{
    SendInput FormatTime(, "HH:mm")
}
; :*:ahkdore::
; {
;     Reload
; }


Hotkey "^#e", (*)=> OpenEnvironmentVars()
OpenEnvironmentVars(){
    Try
        Run "`"" iPATHS.AhkUIA "`"" A_Space "`"" iPATHS.OpenEnvVars "`""
    Catch Error as err
        MsgBox A_ThisFunc "::`n" err.Extra
}

; --- Wezterm Config ----------------------------------------------------------
; -----------------------------------------------------------------------------

#HotIf WinActive("ahk_exe wezterm-gui.exe")
*CapsLock::
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
*CapsLock Up::Return
#HotIf


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
    living_windows := WinGetList( "ahk_class " (IsSet(_class) ? _class :
        (slaughtered := WinGetClass("ahk_id " WinExist("A")))))
    death_total := 0
    for target in living_windows
        if WinExist("ahk_id " target)
            WinClose target, death_total += 1
    JKQuickToast(
        ("[ " String(slaughtered ? slaughtered : _class) " ] R.I.P.")
      , "Death Total: " String(death_total)
      , 5000
    )
}


#Include <Utils\BindUtil\BindUtil>
#Include <Utils\WinUtil\WinUtil>


Class LinkObj {
    Static DefaultBrowser := "Maxthon.exe"
    name := "", address := "", boundlaunch := {}
    __New(_name, _address) {
        this.name := _name
        this.address := _address
        this.boundlaunch := ObjBindMethod(this, "Launch")
    }

    Launch(*) {
        Run (
            LinkObj.DefaultBrowser . " `"" . this.address . "`""
        )
    }
}

/**
 * @class
 */
Class WebLinkLeader extends LeaderKeys {

    /** @prop {Map<String,LinkObj} */
    _links := Map()


    /**
     * @param {any} _leader
     * @param {number} _timeout
     */
    __New(_leader, _timeout:=2000) {
        super.__New(_leader, _timeout)
    }

    Link[_name, _key:=""] {
        Get => this._links.Has(_name) ? this._links[_name] : False
        Set {
            _new_link := LinkObj(_name, Value)
            this._links[_name] := _new_link
            if not _key
                return "unset"
            this.MapKey(_key, _new_link.boundlaunch)
            return "set"
        }
    }
}

/**
 * @class
 */
Class WinNavLeader extends LeaderKeys {

    _excluded_classes := Map(
        "ApplicationManager_ImmersiveShellWindow", "ahk_class ",
        "Internet Explorer_Hidden",                "ahk_class ",
        "EdgeUiInputWndClass",                     "ahk_class ",
        "Shell_TrayWnd",                           "ahk_class ",
        "WorkerW",                                 "ahk_class ",
        "Progman",                                 "ahk_class "
    )

    increments := WinVector.Coordinates(20, 20, 30, 30)
    default_increment_muls := WinVector.Coordinates(1, 1, 1, 1)
    working_coords := WinVector.Coordinates()

    /**
     * @param {string} _leader
     * @param {number} _timeout
     */
    __New(_leader, _timeout:= 6666) {
        super.__New(_leader, _timeout)
    }


    PrevWin[look_behind:=1] {
        Get {
            look_index := look_behind + 1
            _wl := WinGetList()
            _wlnw := []
            for _i, _hwnd in _wl {
                _wClass := WinGetClass("ahk_id " _hwnd)
                if not this._excluded_classes.Has(_wClass)
                    _wlnw.Push _hwnd
            }
            return ((look_behind+1) > _wlnw.Length) ? _wlnw[_wlnw.Length] : _wlnw[look_behind+1]
        }
    }

    ActivatePrevWin(look_behind := 1) {
        WinActivate(this.PrevWin[look_behind])
    }

    /**
     * @param {Boolean|wVector.Coordinates} increment_muls
     * @param {Integer} _hwnd
     */
    IncrementWinDimensions(increment_muls:=False, _hwnd:=0x0) {
        _hwnd := _hwnd ? _hwnd : WinExist("A")
        increment_muls := increment_muls ? increment_muls : this.default_increment_muls
        _increments := this.increments.Mul(&increment_muls, False)
        WinGetPos &_x, &_y, &_w, &_h, "ahk_id " _hwnd
        this.working_coords.Reset(_x, _y, _w, _h).Add(&_increments)
        WinMove((this.working_coords.Flat[("ahk_id " _hwnd)])*)
    }
}

 /**
 **STUB - Testing a custom type for {x,y,w,h} objects
 * @returns {Object.<String,Integer>} RawCoord
 * @returns {Integer} RawCoord.x
 * @returns {Integer} RawCoord.y
 * @returns {Integer} RawCoord.w
 * @returns {Integer} RawCoord.h
*/
WYWH_Factory(x, y, w, h) {
    return {
        x: x,
        y: y,
        w: w,
        h: h
    }
}

HWND_generate(_hwnd) {

}


;;TODO - Setup window management functions for  {WindowFairy} class
Class WindowFairy extends KeyTable {

    default_increment := 26,
    _coords           := WinVector.Coordinates(),
    _coords_ready := False

    /**
     *
     * @param {string} _timeout
     * @param {any} default_increment
     * @returns {WindowFairy}
     */
    __New(_timeout := "none", default_increment?) {
        super.__New(_timeout)
    }

    ActivationCallback() {
        ; ...
    }

    Cycle(count:=1) {
        target_window := WinUtil.PrevWindow[count]
        WinActivate("ahk_id " target_window)
    }

    Coords[raw_coords?] {
        Get {
            raw_coords := IsSet(raw_coords) ? raw_coords : False
            if (not this._coords_ready) and raw_coords
            _coords_raw := [
                raw_coords.HasProp("x") ? raw_coords.x : 0,
                raw_coords.HasProp("y") ? raw_coords.y : 0,
                raw_coords.HasProp("w") ? raw_coords.w : 0,
                raw_coords.HasProp("h") ? raw_coords.h : 0
            ]
            this._coords := WinVector.Coordinates(_coords_raw*)
            return this._coords
        }
    }

    AdjustCoordsRelative(
        /** @param {RawCoord} units */
        units,
        /** @param {Integer?} */
        hWnd?
    ) {
        units := {
            x: units.x ? units.x : 0,
            y: units.y ? units.y : 0,
            w: units.w ? units.w : 0,
            h: units.h ? units.h : 0
        }
    }
}

;--- ctrl_comma_leader.MapKey("m", (*)=>( MsgBox("message...") ))
;--- ctrl_comma_leader.MapKey("b", (*)=>( SearchBrowserFromClipboard() ))
;--- ctrl_comma_leader.MapKey("h", (*)=>( KillHelpWindows() ))
;--- ctrl_comma_leader.Enabled := True


win_grid_keys := KeyTable("none")
wgk := win_grid_keys
;--- wgk.MapKey("Pause",       (*)=>( TiledWindows.ExpandActiveY()     ))
;--- wgk.MapKey("Insert",      (*)=>( TiledWindows.ExpandActiveY(True) ))
;--- wgk.MapKey("PrintScreen", (*)=>( TiledWindows.TileActiveClass()   ))
wgk.MapKey( "#Insert", (*)=>( TriggerReload() ) )


/** @var {WinNavLeader} win_nav_leader */
win_nav_leader := WinNavLeader("F24", 30 * 1000)
win_nav_leader.MapKey("RShift", (*) => (
    win_nav_leader.ActivatePrevWin(),
    win_nav_leader.Deactivate()
))
/**
 * @typedef {Object} windir
 * @property {InputCoords} left
 * @property {InputCoords} down
 * @property {InputCoords} up
 * @property {InputCoords} right
 */
windir := {}
windir.left  := WinVector.Coordinates((-1), 0  , 0, 0)
windir.down  := WinVector.Coordinates(0   , 1  , 0, 0)
windir.up    := WinVector.Coordinates(0   ,(-1), 0, 0)
windir.right := WinVector.Coordinates(1   , 0  , 0, 0)




win_nav_leader.MapKey("Left", (*)=>(
    win_nav_leader.IncrementWinDimensions(windir.left)
))
win_nav_leader.MapKey("Right", (*)=>(
    win_nav_leader.IncrementWinDimensions(windir.right)
))
win_nav_leader.MapKey("Up", (*)=>(
    win_nav_leader.IncrementWinDimensions(windir.up)
))
win_nav_leader.MapKey("Down", (*)=>(
    win_nav_leader.IncrementWinDimensions(windir.down)
))

#/::
{
    _status := !win_nav_leader.Active
    win_nav_leader.Active := _status
}


weblink_leader := WebLinkLeader("RAlt & CapsLock", 2000)
weblink_leader.Link["emmylua", "e"] :=
                    "https://github.com/LuaLS/lua-language-server/wiki/Annotations"

weblink_leader.link["textnow", "t"] :=
                    "https://www.textnow.com/"

weblink_leader.Link["reddit", "r"] :=
                    "reddit.com"

weblink_leader.Link["fancyconver", "!f"] :=
                    "https://textfancy.com/font-converter/"

weblink_leader.Link["fancyedit", "+f"] :=
                    "https://textpaint.net/"

weblink_leader.Link["ddg", "d"] :=
                    "duckduckgo.com"

;--- weblink_leader.Link["ascii"      ,  "f"] := "https://textfancy.com/keyboard/"
;--- https://textheads.com/

weblink_leader.Enabled := True



RAlt_Apps_leader := LeaderKeys("RAlt & AppsKey")

RAlt_Apps_leader.MapKey(
    "m", (*) => (Msgbox("Testing!"))
)

RAlt_Apps_leader.MapKey("h", (*) => ( KillHelpWindows() ))
RAlt_Apps_leader.MapKey("k", (*) => ( KillWindowClass() ))

RAlt_Apps_leader.MapKey(
    "Right", (*) => (WinActivate(
        "ahk_id " WinGetList(
            "ahk_class " WinGetClass(
                "ahk_id " WinExist("A")
            )
        )[2]
    ))
)

RAlt_Apps_leader.Enabled := True


LeaderFairy := KeyTable("none")


ScrollLock::
{
    win_grid_keys.Active := !win_grid_keys.Active
    JKQuickTip( "WinGridKeys <> " .
              ( (win_grid_keys.Active) ? "ENABLED" : "DISABLED" ),
              ( 1500 ))
}



;|- ctrl_comma_leader.BindKey("w", (*)=>(
;|-         win_grid_keys.Active["max"] := !win_grid_keys.Active
;|-     ))

;|- win_jay_leader := LeaderKeys("#j")
;|- win_jay_leader.BindKey("j", (*)=>(ToolTip("#j[j]")))
;|- win_jay_leader.Enabled := True

TriggerReload(*)
{
    JKQuickToast(
        "Reloading DefaultOn.ahk",
        "Reloading...",
        1500
    )
    SetTimer(
        (*)=>Reload(),
        -2000
    )
}

Hotkey( "#F12", (*)=>TriggerReload() )
Hotkey( "#F7", (*)=>ExitApp() )



