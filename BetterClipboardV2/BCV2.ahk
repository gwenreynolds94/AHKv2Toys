#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetWorkingDir A_ScriptDir
TraySetIcon("BCB.ico")

#Include ..\Lib
#Include SciLib\SciConstants.ahk
#Include SciLib\SciLoad.ahk

/** @type {String} Path to Scintilla.dll */
SCI_DLL_PATH := "..\Lib\SciLib\Scintilla.dll"

/** @type {String} Path to BetterClipboard configuration file */
BCB_CONF_PATH := A_ScriptDir "\BCB.ini"

/** @type {String} Path to directory storing clipboard entries */
BCB_CLIPS_DIR := A_ScriptDir "\clips"


/**
 * @param {Pointer} SciPtr A pointer to the Scintilla DLL library. Upon variable
 *      initialization, the method *`SciAdd`* is added to the global Gui class for the
 *      creation of a Scintilla control with a custom **`Send`** method for sending
 *      direct messages via DLL calls.
 */
SciPtr := SciLoad(SCI_DLL_PATH)

; Free Scintilla.dll library
OnExit (*) => SciFree(SciPtr)

/**
 * @var {BCBApp} App
 *
 * Initializi
 */
App := BCBApp()

/*
    ! DEBUGGING ! REMOVE !
        ! DEBUGGING ! REMOVE !
            ! DEBUGGING ! REMOVE !
                ! DEBUGGING ! REMOVE !
                    ! DEBUGGING ! REMOVE !
*/
F8::ExitApp
/*
                    ! DEBUGGING ! REMOVE !
                ! DEBUGGING ! REMOVE !
            ! DEBUGGING ! REMOVE !
        ! DEBUGGING ! REMOVE !
    ! DEBUGGING ! REMOVE !
*/


/**
 * Helper class for setting/getting keys in configuration file as defined by
 *      **`BCB_CONF_PATH`** global variable.
 *
 *  The class makes use of static **`__Get`** and **`__Set`** to retrieve and store
 *      existing and non-existing values.
 */
Class BCBConf {
    static __New() {
        ; Create configuration file as per BCB_CONF_PATH if the file does not exist and
        ; the file's directory does exist. If neither exist, exit the application
        if !(FileExist(BCB_CONF_PATH) ~= "A|N") {
            SplitPath BCB_CONF_PATH,, &conf_dir
            if DirExist(conf_dir) {
                IniWrite 0   , BCB_CONF_PATH, "Index", "Current"
                IniWrite 9999, BCB_CONF_PATH, "Index", "Max"
            } else {
                MsgBox( "Neither file or directory of given path to "
                      . "configuration file could be found."          )
                ExitApp
            }
        }
    }

    /**
     * @prop {Any} Index Get and set keys of the Index section in the configuration
     *                   file by passing the key name as the property parameter
     */
    static Index[Param] {
        Get => IniRead(BCB_CONF_PATH, "Index", Param)
        Set => IniWrite(Value, BCB_CONF_PATH, "Index", Param)
    }
}


; A class to help manage the indicator gui for the currently shown index
Class BCBIndexGui {
    /** @prop {Boolean} active */
    active := False

    /** @prop {Gui} gui */
    gui := {}
    /** @prop {Gui.Text} text */
    text := {}
    /** @prop {Gui} parentgui */
    parentgui := {}

    /** @prop {Integer} width */
    width := 100
    /** @prop {Integer} height */
    height := 48

    /** @prop {Integer} fadeSteps Number of transparency steps in fade animation */
    fadeSteps := 10
    /** @prop {Integer} fadeRest Ticks between transparency steps in fade animation */
    fadeRest := 1
    /** @prop {Integer} opacity 0-255 */
    opacity := 125
    /** @prop {Integer} currentOp Current gui opacity [1-255] */
    currentOp := 0

    /** @prop {String} fontOpts */
    fontOpts := "s28"
    /** @prop {String} fontName */
    fontName := "JetBrains Mono"

    /** @prop {Integer} timeout */
    timeout := 1000
    /** @prop {Func} hideGuiBF */
    hideGuiBF := {}

    /**
     * @param {Gui} _parentgui A reference to the main window Gui object
     * @param {Object} _colors A reference to an object containing color info containing
     *                         one or more of the following properties:
     *
     *      _colors := {
     *          indexbg: "0A1BEF"   ; 6-digit hex color as string
     *          indexfg: "320FBA"   ; 6-digit hex color as string
     *      }
     */
    __New(_parentgui, _colors:="") {
        this.parentgui := _parentgui
        this.gui := Gui("-Caption +ToolWindow +AlwaysOnTop")
        this.gui.MarginX := this.gui.MarginY := 0
        if IsObject(_colors) {
            if _colors.HasProp("indexbg")
                this.gui.BackColor := _colors.indexbg
            if _colors.HasProp("indexfg")
                this.fontOpts .= " c" _colors.indexfg
        }
        this.gui.SetFont(this.fontOpts, this.fontName)
        textOpts := "w" this.width " h" this.height " Center"
        this.text := this.gui.Add("Text", textOpts, 9999)
        this.gui.Show("NA x" A_ScreenWidth)
        WinSetTransColor(this.gui.BackColor " " 0, this.gui)
        this.MatchParentGuiPos()
        this.gui.Show("Hide")
        this.hideGuiBF := ObjBindMethod(this, "HideGui")
    }

    ; Show and fade in the index gui
    ShowGui(*) {
        static fadeAmt := this.opacity / this.fadeSteps
        this.active := True
        this.gui.Show("NA")
        ; Fade in the index gui
        FadeIn(*) {
            if !(this.active) {
                SetTimer(, 0)
            } else {
                newTrans := Round(this.currentOp + fadeAmt)
                if (newTrans >= (this.opacity-1)) {
                    SetTimer(, 0)
                    WinSetTransColor(this.gui.BackColor " " this.opacity, this.gui)
                    this.currentOp := this.opacity
                } else {
                    WinSetTransColor(this.gui.BackColor " " newTrans, this.gui)
                    this.currentOp := newTrans
                }
            }
        }
        SetTimer(FadeIn, this.fadeRest)
    }

    ; Fade out and hide the index gui
    HideGui(*) {
        static fadeAmt := this.opacity / this.fadeSteps
        this.active := False
        ; Fade out the index gui
        FadeOut(*) {
            if (this.active) {
                SetTimer(, 0)
            } else {
                newTrans := Round(this.currentOp - fadeAmt)
                if (newTrans <= 1) {
                    SetTimer(, 0)
                    WinSetTransColor(this.gui.BackColor " " 0, this.gui)
                    this.currentOp := 0
                    this.gui.Hide()
                } else {
                    WinSetTransColor(this.gui.BackColor " " newTrans, this.gui)
                    this.currentOp := newTrans
                }
            }
        }
        SetTimer(FadeOut, this.fadeRest)
    }

    ; Start a timer to hide the index gui after a delay of so many milliseconds as
    ; defined by `BCBIndexGui.timeout`
    StartTimeout(*) {
        hideGuiBF := this.hideGuiBF
        SetTimer(hideGuiBF, -this.timeout)
    }

    ; Cancel a timer previously set using `BCBIndexGui.StartTimeout`
    StopTimeout(*) {
        hideGuiBF := this.hideGuiBF
        SetTimer(hideGuiBF, 0)
    }

    ; Immediately hide the index gui with no fade effect, interrupting any fade effect
    ; currently in progress
    HideGuiImmediately(*) {
        this.active := False
        WinSetTransColor(this.gui.BackColor " " 0, this.gui)
        this.currentOp := 0
        this.gui.Hide()
    }

    ; Set the position of the index gui to rest against the lower right corner of the
    ; parent gui using a `SetWindowPos` DLL call
    MatchParentGuiPos() {
        static uFlags := (SWP_NOACTIVATE:=0x0010)|(SWP_NOSIZE:=0x0001)
        this.parentGui.GetPos(&px, &py, &pw, &ph)
        newPosX := px+pw-this.width
        newPosY := py+ph-this.height
        DllCall("SetWindowPos", "Ptr", this.gui.Hwnd
                              , "Ptr", -1
                              , "Int", newPosX, "Int", newPosY
                              , "Int", 0, "Int", 0
                              , "UInt", uFlags)
    }
}


; A class to help manage a custom Scintilla edit control
Class BCBEdit {
    /** @prop {Map} _WRAPMODES Dictionary of Scintilla wrap modes */
    _WRAPMODES := Map( "none"  , SC_WRAP_NONE
                     , "word"  , SC_WRAP_WORD
                     , "char"  , SC_WRAP_CHAR
                     , "white" , SC_WRAP_WHITESPACE )
    /** @prop {Map} _TECHMODES Dictionary of Scintilla Technology modes */
    _TECHMODES := Map( "default" , SC_TECHNOLOGY_DEFAULT
                     , "dw"      , SC_TECHNOLOGY_DIRECTWRITE
                     , "dwretain", SC_TECHNOLOGY_DIRECTWRITERETAIN
                     , "dwdc"    , SC_TECHNOLOGY_DIRECTWRITEDC     )

    /**
     * @param {Gui} _gui A reference to the parent Gui object
     * @param {String} _options A string containing options for the edit control
     */
    __New(_gui, _options:="") {
        this.ctrl := _gui.SciAdd(_options)
        this.gui := _gui
        this.Send := (_this, _msg, _wp:=0, _lp:=0) =>
                                            this.ctrl.Send(_msg, _wp, _lp)
    }

    /**
     * @prop {String} Text
     *
     * Get and set the contents of the Scintilla control
     */
    Text {
        Get {
            nLen := this.Send(SCI_GETLENGTH)
            buf := Buffer(nLen+1)
            this.Send(SCI_GETTEXT, nLen, buf.Ptr)
            Return StrGet(buf,,"UTF-8")
        }
        Set {
            str_size := StrPut(Value, "UTF-8")
            buf := Buffer(str_size, 0)
            StrPut(Value, buf, "UTF-8")
            this.Send(SCI_SETTEXT,, buf.Ptr)
        }
    }

    /**
     * @prop {String} Technology
     *
     * This value can be any key in `BCBEdit._TECHMODES`
     *
     *      BCBEdit._TECHMODES := Map(
     *           "default" , SC_TECHNOLOGY_DEFAULT           := 0,
     *           "dw"      , SC_TECHNOLOGY_DIRECTWRITE       := 1,
     *           "dwretain", SC_TECHNOLOGY_DIRECTWRITERETAIN := 2,
     *           "dwdc"    , SC_TECHNOLOGY_DIRECTWRITEDC     := 3
     *      )
     */
    Technology {
        Get {
            _tech := this.Send(SCI_GETTECHNOLOGY)
            for techname, techval in this._TECHMODES
                if (_tech = techval)
                    Return techname
        }
        Set {
            for techname, techval in this._TECHMODES
                if (techname = StrLower(Value))
                    this.Send(SCI_SETTECHNOLOGY, techval)
        }
    }

    /**
     * @prop {String} WrapMode
     *
     * This value can be any key in `BCBEdit._WRAPMODES`
     *
     *      BCBEdit._WRAPMODES := Map(
     *          "none",  SC_WRAP_NONE       := 0,
     *          "word",  SC_WRAP_WORD       := 1,
     *          "char",  SC_WRAP_CHAR       := 2,
     *          "white", SC_WRAP_WHITESPACE := 3
     *      )
     */
    WrapMode {
        Get {
            _wrap := this.Send(SCI_GETWRAPMODE)
            for wpname, wpval in this._WRAPMODES
                if (_wrap = wpval)
                    Return wpname
        }
        Set {
            for wpname, wpval in this._WRAPMODES
                if (wpname = Value)
                    this.Send(SCI_SETWRAPMODE, wpval)
        }
    }

    /**
     * @prop {String} Font
     *
     * Get and set the name of the font to be displayed
     */
    Font {
        Get {
            nLen := this.Send(SCI_STYLEGETFONT, STYLE_DEFAULT)
            buf := Buffer(nLen+1, 0)
            this.Send(SCI_STYLEGETFONT, STYLE_DEFAULT, buf.Ptr)
            Return StrGet(buf,,"UTF-8")
        }
        Set {
            strSize := StrPut(Value, "UTF-8")
            buf := Buffer(strSize, 0)
            StrPut(Value, buf, "UTF-8")
            this.Send(SCI_STYLESETFONT, STYLE_DEFAULT, buf.Ptr)
            this.Send(SCI_STYLECLEARALL)
        }
    }

    /**
     * @prop {Integer} MarginWidth
     *
     * Get and set width in pixels of margin 1
     */
    MarginWidth {
        Get => this.Send(SCI_GETMARGINWIDTHN, 1)
        Set => this.Send(SCI_SETMARGINWIDTHN, 1, Value)
    }

    /**
     * @prop {Boolean} ScrollBar
     *
     * Get and set vertical scrollbar visibility
     */
    ScrollBar {
        Get => this.Send(SCI_GETVSCROLLBAR)
        Set => this.Send(SCI_SETVSCROLLBAR)
    }

    /**
     * @prop {Hex Color} Background
     *
     * A 6-8 digit (A)RGB hex color as a string or integer defining the color of the
     * control's background
     */
    Background {
        Get => this.Send(SCI_STYLEGETBACK, STYLE_DEFAULT)
        Set {
            _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
            this.Send(SCI_STYLESETBACK, STYLE_DEFAULT, _col)
            this.Send(SCI_STYLECLEARALL)
        }
    }

    /**
     * @prop {Hex Color} Foreground
     *
     * A 6-8 digit (A)RGB hex color as a string or integer defining the color of the
     * control's foreground text
     */
    Foreground {
        Get => this.Send(SCI_STYLEGETFORE, STYLE_DEFAULT)
        Set {
            _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
            this.Send(SCI_STYLESETFORE, STYLE_DEFAULT, _col)
            this.Send(SCI_STYLECLEARALL)
        }
    }

    /**
     * @prop {Hex Color} Caret
     *
     * A 6-8 digit (A)RGB hex color as a string or integer defining the color of the
     * control's caret
     */
    Caret {
        Get => this.Send(SCI_GETCARETFORE)
        Set {
            _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
            this.Send(SCI_SETCARETFORE, _col)
            this.Send(SCI_STYLECLEARALL)
        }
    }

    /**
     * @param {Object} colors
     *
     * Function takes an object with one or more of the following properties which
     *  should equate to 6 or 8 digit (A)RGB hex digits as a string.
     *
     *      colors.fg = "80FF0000"  ; Red at 50% Alpha
     *      colors.bg = "0000FF"    ; Blue at 100% Alpha
     *      colors.caret = "DDFFEE" ; Pale green at 100% Alpha
     */
    SetColors(colors) {
        if IsObject(colors) {
            if colors.HasProp("bg")
                this.Background := colors.bg
            if colors.HasProp("fg")
                this.Foreground := colors.fg
            if colors.HasProp("caret")
                this.Caret := colors.caret
        }
    }
}

; `BCBApp` starts the **BetterClipboard** application upon the intialization
; of a new instance
Class BCBApp {
    /** @prop {Boolean} active */
    active := False
    /** @prop {Boolean} updatingClip */
    updatingClip := False

    /** @prop {Gui} gui */
    gui := {}
    /** @prop {BCBEdit} edit */
    edit := {}
    /** @prop {BCBIndexGui} idxGui */
    idxGui := {}

    /** @prop {Object} colors */
    colors := {
        bg: "080e09",
        fg: "b6ffb1",
        caret: "b6ffb1",
        border : "53864f",
        indexbg: "2a392b",
        indexfg: "5a8b5e"
    }
    /** @prop {String} fontName */
    fontName := "Fira Code"

    /** @prop {Integer} fadeSteps Number of transparency steps in fade animation */
    fadeSteps := 5
    /** @prop {Integer} fadeRest Ticks between transparency steps in fade animation */
    fadeRest := 1
    /** @prop {Integer} opacity 0-255 */
    opacity := 225
    /** @prop {Integer} currentOp Current gui opacity [1-255] */
    currentOp := 0

    /** @prop {Integer} indexDuration */
    indexDuration := 500
    /** @prop {Integer} shownIndex */
    shownIndex := 0
    /** @prop {Integer} maxIndex */
    maxIndex := 0
    /** @prop {Integer} curIndex */
    curIndex := 0

    __New() {
        this.shownIndex := this.curIndex := BCBConf.Index["Current"]
        this.maxIndex := BCBConf.Index["Max"]
        this.InitClipsDir()

        this.gui := Gui("-Caption +ToolWindow +AlwaysOnTop","BetterClipboard", this)
        this.gui.OnEvent("Close", "Gui_OnClose")
        this.gui.MarginX := this.gui.MarginY := 3
        this.gui.BackColor := this.colors.border

        this.edit := BCBEdit(this.gui, "w700 h400")
        this.edit.Background := this.colors.bg
        this.edit.Foreground := this.colors.fg
        this.edit.Caret := this.colors.caret
        this.edit.WrapMode := "word"
        this.edit.Technology := "dw"
        this.edit.Font := this.fontName
        this.edit.MarginWidth := 0
        this.edit.ScrollBar := False

        this.gui.Show("NA x" A_ScreenWidth)
        WinSetTransparent(0, this.gui)
        this.gui.Show("Hide Center")

        this.idxGui := BCBIndexGui(this.gui, this.colors)

        this.SetClip(this.shownIndex)
        this.InitHotkeys()
        OnClipboardChange(ObjBindMethod(this, "ClipChange"))
    }

    /** @param {Integer} _index */
    SetClip(_index) {
        this.edit.Text := FileRead(BCB_CLIPS_DIR "\" _index ".clip")
        this.idxGui.text.Value := _index
        this.shownIndex := _index
    }

    PrevClip(*) {
        newIndex := this.shownIndex - 1
        if (newIndex <= 0)
            newIndex := this.curIndex
        if (FileExist(BCB_CLIPS_DIR "\" newIndex ".clip") ~= "A|N")
            this.SetClip(newIndex)
        this.idxGui.ShowGui()
        this.idxGui.StartTimeout()
    }

    NextClip(*) {
        newIndex := this.shownIndex + 1
        if (FileExist(BCB_CLIPS_DIR "\" newIndex ".clip") ~= "A|N")
            this.SetClip(newIndex)
        else
            this.SetClip(1)
        this.idxGui.ShowGui()
        this.idxGui.StartTimeout()
    }

    NewClip() {
        newIndex := this.curIndex + 1
        if (newIndex > this.maxIndex)
            newIndex := 1
        if (FileExist(BCB_CLIPS_DIR "\" newIndex ".clip") ~= "A|N")
            FileDelete(BCB_CLIPS_DIR "\" newIndex ".clip")
        FileAppend(A_Clipboard, BCB_CLIPS_DIR "\" newIndex ".clip")
        BCBConf.Index["Current"] := this.curIndex := newIndex
    }

    ClipChange(type) {
        static CB_EMPTY := 0, CB_TEXT := 1, CB_NON_TEXT := 2
        if (type=CB_TEXT) {
            this.NewClip()
            if this.updatingClip
                this.SetClip(this.curIndex), this.updatingClip := False
        }
    }

    UpdateClipboardFromEdit(*) {
        this.updatingClip := True
        A_Clipboard := this.edit.Text
    }

    InitHotkeys() {
        HotIf (*) => this.active
        Hotkey("<#c", ObjBindMethod(this, "HideGui"))
        Hotkey("PgDn", ObjBindMethod(this, "PrevClip"))
        Hotkey("PgUp", ObjBindMethod(this, "NextClip"))
        Hotkey("<^Enter", ObjBindMethod(this, "UpdateClipboardFromEdit"))
        HotIf (*) => !(this.active)
        Hotkey("<#c", ObjBindMethod(this, "ShowGui"))
        HotIf()
    }

    InitClipsDir() {
        if !(DirExist(BCB_CLIPS_DIR)) {
            SplitPath(BCB_CLIPS_DIR,, &parentDir)
            if !(DirExist(parentDir)) {
                MsgBox("The path as determined by 'BCB_CLIPS_DIR' is not "
                     . "a valid directory and could not be created.")
                ExitApp()
            } else {
                DirCreate(BCB_CLIPS_DIR)
            }
        }
        fileCount := 0
        Loop Files, BCB_CLIPS_DIR "\*.clip"
            fileCount++
        if !(fileCount) {
            FileAppend(A_Clipboard, BCB_CLIPS_DIR "\1.clip")
            BCBConf.Index["Current"] := this.curIndex := 1
        } else if ((this.curIndex <= 0) or (this.curIndex > this.maxIndex)) {
            if (FileExist(BCB_CLIPS_DIR "\1.clip"))
                FileDelete(BCB_CLIPS_DIR "\1.clip")
            FileAppend(A_Clipboard, BCB_CLIPS_DIR "\1.clip")
            BCBConf.Index["Current"] := this.curIndex := 1
        } else if !(FileExist(BCB_CLIPS_DIR "\" this.curIndex ".clip") ~= "A|N") {
            FileAppend(A_Clipboard, BCB_CLIPS_DIR "\" this.curIndex ".clip")
        }
    }

    ShowGui(*) {
        static fadeAmt := this.opacity / this.fadeSteps
        this.active := True
        this.gui.Show()
        this.SetClip(this.curIndex)
        FadeIn(*) {
            if !(this.active) {
                SetTimer(, 0)
            } else {
                newTrans := Round(this.currentOp + fadeAmt)
                if (newTrans >= (this.opacity-1)) {
                    SetTimer(, 0)
                    WinSetTransparent(this.opacity, this.gui)
                    this.currentOp := this.opacity
                    this.idxGui.ShowGui()
                    this.idxGui.StartTimeout()
                } else {
                    WinSetTransparent(newTrans, this.gui)
                    this.currentOp := newTrans
                }
            }
        }
        SetTimer(FadeIn, this.fadeRest)
    }

    HideGui(*) {
        static fadeAmt := this.opacity / this.fadeSteps
        this.active := False
        FadeOut(*) {
            if (this.active) {
                SetTimer(, 0)
            } else {
                newTrans := Round(this.currentOp - fadeAmt)
                if (newTrans <= 1) {
                    SetTimer(, 0)
                    WinSetTransparent(0, this.gui)
                    this.currentOp := 0
                    this.gui.Hide()
                } else {
                    WinSetTransparent(newTrans, this.gui)
                    this.currentOp := newTrans
                }
            }
        }
        this.idxGui.StopTimeout()
        this.idxGui.HideGuiImmediately()
        SetTimer(FadeOut, this.fadeRest)
    }

    Gui_OnClose(guiObj, *) {
        ExitApp
    }
}