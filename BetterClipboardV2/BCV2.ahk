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
BCB_CONF_PATH := A_AppData "\BetterClipboard\BCB.ini"

/** @type {String} Path to directory storing clipboard entries */
BCB_CLIPS_DIR := A_AppData "\BetterClipboard\clips"


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
    !! DEBUGGING ! REMOVE !
        !! DEBUGGING ! REMOVE !
            !! DEBUGGING ! REMOVE !
                !! DEBUGGING ! REMOVE !
                    !! DEBUGGING ! REMOVE !
*/
F8::ExitApp         ; !! DEBUGGING ! REMOVE !
/*
                    !! DEBUGGING ! REMOVE !
                !! DEBUGGING ! REMOVE !
            !! DEBUGGING ! REMOVE !
        !! DEBUGGING ! REMOVE !
    !! DEBUGGING ! REMOVE !
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
                IniWrite 1   , BCB_CONF_PATH, "Index", "Current"
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
    _WRAPMODES := Map( "none"  , SC_WRAP_NONE         ; 0
                     , "word"  , SC_WRAP_WORD         ; 1
                     , "char"  , SC_WRAP_CHAR         ; 2
                     , "white" , SC_WRAP_WHITESPACE ) ; 3
    /** @prop {Map} _TECHMODES Dictionary of Scintilla technology modes */
    _TECHMODES := Map( "default"  , SC_TECHNOLOGY_DEFAULT             ; 0
                     , "dw"       , SC_TECHNOLOGY_DIRECTWRITE         ; 1
                     , "dw_retain", SC_TECHNOLOGY_DIRECTWRITERETAIN   ; 2
                     , "dw_dc"    , SC_TECHNOLOGY_DIRECTWRITEDC     ) ; 3
    /** @prop {Map} _VIRTSPACEOPTS Dictionary of Scintilla virtual space bit flags */
    _VIRTSPACEOPTS := Map( "none"  , SCVS_NONE                   ; 0
                         , "rect"  , SCVS_RECTANGULARSELECTION   ; 1
                         , "user"  , SCVS_USERACCESSIBLE         ; 2
                         , "nowrap", SCVS_NOWRAPLINESTART      ) ; 4

    /** @prop {Boolean} _MultiSelect */
    _MultiSelect := False

    /**
     * @prop {Method} Send
     * @param {Integer} _msg Message to send to the Scintilla control
     * @param {Integer} _wp wParam
     * @param {Integer} _lp lParam
     */
    Send := {}

    /** @prop {Method} Redo A method to send a redo message to the Scintilla control */
    Redo := {}

    /** @prop {BCBEdit.Selection} Selection */
    Selection := {}
    /** @prop {BCBEdit.WhiteSpace} WhiteSpace */
    WhiteSpace := {}
    /** @prop {BCBEdit.Caret} Caret */
    Caret := {}

    /**
     * @param {Gui} _gui A reference to the parent Gui object
     * @param {String} _options A string containing options for the edit control
     */
    __New(_gui, _options:="") {
        this.ctrl := _gui.SciAdd(_options)
        this.gui := _gui
        this.Send := (_this, _msg, _wp:=0, _lp:=0) =>
                                            this.ctrl.Send(_msg, _wp, _lp)
        this.Redo := (*)=> this.Send(SCI_REDO)
        this.Selection := BCBEdit.Selection(this)
        this.WhiteSpace := BCBEdit.WhiteSpace(this)
        this.Caret := BCBEdit.Caret(this)
        this.SetShortcuts()
    }

    ; Enable keyboard shortcuts for the Scintilla control, handled by Scintilla
    SetShortcuts(*) {
        ; keyDefinition := keyCode + (keyMod << 16)
        ctrlPgDn := SCK_NEXT  + (SCMOD_CTRL << 16)
        ctrlPgUp := SCK_PRIOR + (SCMOD_CTRL << 16)
        altDn := SCK_DOWN + (SCMOD_ALT << 16)
        altUp := SCK_UP + (SCMOD_ALT << 16)
        this.Send(SCI_ASSIGNCMDKEY, ctrlPgDn, SCI_PAGEDOWN) ; Ctrl+PgDn => PageDown
        this.Send(SCI_ASSIGNCMDKEY, ctrlPgUp, SCI_PAGEUP)   ; Ctrl+PgUp => PageUp
        ; Alt+Down => Move selected lines down
        this.Send(SCI_ASSIGNCMDKEY, altDn, SCI_MOVESELECTEDLINESDOWN)
        ; Alt+Up => Move selected lines up
        this.Send(SCI_ASSIGNCMDKEY, altUp, SCI_MOVESELECTEDLINESUP)
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

    /** @prop {Boolean} ScrollPastEnd
     *
     * Get and set ability to scroll past the last line
     */
    ScrollPastEnd {
        Get => this.Send(SCI_GETENDATLASTLINE)
        Set => this.Send(SCI_SETENDATLASTLINE, !!Value)
    }

    /** @prop {Boolean} MultipleSelection */
    MultipleSelection {
        Get => this.Send(SCI_GETMULTIPLESELECTION)
        Set => this.Send(SCI_SETMULTIPLESELECTION, !!(Value))
    }

    /** @prop {Boolean} AdditionalSelectionTyping */
    AdditionalSelectionTyping {
        Get => this.Send(SCI_GETADDITIONALSELECTIONTYPING)
        Set => this.Send(SCI_SETADDITIONALSELECTIONTYPING, !!(Value))
    }

    /** @prop {Boolean} MultiPaste */
    MultiPaste {
        Get => this.Send(SCI_GETMULTIPASTE)
        Set => this.Send(SCI_SETMULTIPASTE, !!(Value))
    }

    /**
     * @prop {Hex Color} Background
     *
     * A **6-8** digit **(A)RGB** hex color as a string or integer defining the color of
     * the control's background
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
     * A **6-8** digit **(A)RGB** hex color as a string or integer defining the color of
     * the control's foreground text
     */
    Foreground {
        Get => this.Send(SCI_STYLEGETFORE, STYLE_DEFAULT)
        Set {
            _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
            this.Send(SCI_STYLESETFORE, STYLE_DEFAULT, _col)
            this.Send(SCI_STYLECLEARALL)
        }
    }

    ; </> /**
    ; </>  * @prop {Hex Color} Caret
    ; </>  *
    ; </>  * A **6-8** digit **(A)RGB** hex color as a string or integer defining the color of
    ; </>  * the control's caret
    ; </>  */
    ; </> Caret {
    ; </>     Get => this.Send(SCI_GETCARETFORE)
    ; </>     Set {
    ; </>         _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
    ; </>         this.Send(SCI_SETCARETFORE, _col)
    ; </>         this.Send(SCI_STYLECLEARALL)
    ; </>     }
    ; </> }

    /**
     * @prop {String} Technology
     *
     * This value can be any key in `BCBEdit()._TECHMODES`
     *
     *      BCBEdit()._TECHMODES := Map(
     *           "default"  , SC_TECHNOLOGY_DEFAULT           := 0,
     *           "dw"       , SC_TECHNOLOGY_DIRECTWRITE       := 1,
     *           "dw_retain", SC_TECHNOLOGY_DIRECTWRITERETAIN := 2,
     *           "dw_dc"    , SC_TECHNOLOGY_DIRECTWRITEDC     := 3
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
     * This value can be any key in `BCBEdit()._WRAPMODES`
     *
     *      BCBEdit()._WRAPMODES := Map(
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

    ;<`>    Class WhiteSpace {
    ;<`>        /** @prop {BCBEdit} p The parent `BCBEdit` instance to interact with */
    ;<`>        p := {}
    ;<`>
    ;<`>        /**
    ;<`>          * @param {BCBEdit} _BCBEdit The instance of `BCBEdit` to interact with
    ;<`>          */
    ;<`>        __New(_BCBEdit) {
    ;<`>            this.p := _BCBEdit
    ;<`>        }
    ;<`>    }

    Class Caret {
        /** @prop {BCBEdit} p The parent `BCBEdit` instance to interact with */
        p := {}

        /** @prop {Map} _STICKYMODES */
        _STICKYMODES := Map( "off"       , SC_CARETSTICKY_OFF           ; 0
                           , "on"        , SC_CARETSTICKY_ON            ; 1
                           , "whitespace", SC_CARETSTICKY_WHITESPACE  ) ; 2
    
        /**
          * @param {BCBEdit} _BCBEdit The instance of `BCBEdit` to interact with
          */
        __New(_BCBEdit) {
            this.p := _BCBEdit
        }

        /**
         * @prop {Hex Color} Foreground
         *
         * An **8** digit **ARGB** hex color as a string or integer defining the color of
         * the caret foreground
         */
        Foreground {
            Get => this.p.Send(SCI_GETELEMENTCOLOUR, SC_ELEMENT_CARET)
            Set {
                _col := (Type(Value)="String") ? Integer("0x" Value) : Value
                this.p.Send(SCI_SETELEMENTCOLOUR, SC_ELEMENT_CARET, _col)
            }
        }

        /**
         * @prop {Hex Color} LineBackground
         * 
         * An **8** digit **ARGB** hex color as a string or integer defining the color of
         * the background of the line the caret is on
         */
        LineBackground {
            Get => this.p.Send(SCI_GETELEMENTCOLOUR, SC_ELEMENT_CARET_LINE_BACK)
            Set {
                _col := (Type(Value)="String") ? Integer("0x" Value) : Value
                this.p.Send(SCI_SETELEMENTCOLOUR, SC_ELEMENT_CARET_LINE_BACK, _col)
            }
        }

        /**
         * @prop {String} Sticky
         * 
         * This value can be any of the keys in `BCBEdit.Caret()._STICKYMODES`
         * 
         *      BCBEdit.Caret()._STICKYMODES := Map(
         *          "off"       , SC_CARETSTICKY_OFF        := 0,
         *          "on"        , SC_CARETSTICKY_ON         := 1,
         *          "whitespace", SC_CARETSTICKY_WHITESPACE := 2
         *      )
         */
        Sticky {
            Get {
                _stickymode := this.p.Send(SCI_GETCARETSTICKY)
                for mdName, mdVal in this._STICKYMODES
                    if (mdVal=_stickymode)
                        Return mdName
            }
            Set {
                for mdName, mdVal in this._STICKYMODES
                    if (mdName=Value)
                        this.p.Send(SCI_SETCARETSTICKY, mdVal)
            }
        }

        /** @prop {Integer} Width 
         * 
         * Get and set the width in pixels of the caret
         */
        Width {
            Get => this.p.Send(SCI_GETCARETWIDTH)
            Set => this.p.Send(SCI_SETCARETWIDTH, Value)
        }

        /** @prop {Boolean} FrameDraw
         * 
         * Toggle the appearance of a frame around the caret line (not filling it in)
         */
        FrameDraw {
            Get => this.p.Send(SCI_GETCARETLINEFRAME)
            Set => this.p.Send(SCI_SETCARETLINEFRAME, !!(Value))
        }
    }

    Class WhiteSpace {
        /** @prop {BCBEdit} p The parent `BCBEdit` instance to interact with */
        p := {}

        /** @prop {Boolean} _UseIndents */
        _UseIndents := False

        /** @prop {Map} _VISMODES */
        _VISMODES := Map( "always_off"  , SCWS_INVISIBLE             ; 0
                        , "always_on"   , SCWS_VISIBLEALWAYS         ; 1
                        , "after_indent", SCWS_VISIBLEAFTERINDENT    ; 2
                        , "only_indent" , SCWS_VISIBLEONLYININDENT ) ; 3
        /** @prop {Map} _TABMODES */
        _TABMODES := Map( "arrow" , SCTD_LONGARROW   ; 0
                        , "strike", SCTD_STRIKEOUT ) ; 1

        /**
         * @param {BCBEdit} _BCBEdit 
         * 
         * The instance of `BCBEdit` to interact with
         */
        __New(_BCBEdit) {
            this.p := _BCBEdit
        }

        /**
         * @prop {Hex Color} Foreground
         *
         * An **8** digit **ARGB** hex color as a string or integer defining the color of
         * the control's whitespace foreground
         */
        Foreground {
            Get => this.p.Send(SCI_GETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE)
            Set {
                _col := (Type(Value)="String") ? Integer("0x" Value) : Value
                this.p.Send(SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, _col)
            }
        }

        /**
         * @prop {String} Visibility
         * 
         * This value can be any key in `BCBEdit.WhiteSpace()._VISMODES`
         * 
         *      BCBEdit.WhiteSpace()._VISMODES := Map(
         *          "always_off"  , SCWS_INVISIBLE           := 0,
         *          "always_on"   , SCWS_VISIBLEALWAYS       := 1,
         *          "after_indent", SCWS_VISIBLEAFTERINDENT  := 2,
         *          "only_indent" , SCWS_VISIBLEONLYININDENT := 3
         *      )
         */
        Visibility {
            Get {
                _vis := this.p.Send(SCI_GETVIEWWS)
                for visName, visVal in this._VISMODES
                    if (_vis=visVal)
                        Return visName
            }
            Set {
                for visName, visVal in this._VISMODES
                    if (visName=Value)
                        this.p.Send(SCI_SETVIEWWS, visVal)
            }
        }

        /**
         * @prop {String} TabStyle
         * 
         * This value can be either of the keys in `BCBEdit.WhiteSpace()._TABMODES`
         * 
         *      BCBEdit.WhiteSpace()._TABMODES := Map(
         *          "arrow" , SCTD_LONGARROW := 0,  ; Default
         *          "strike", SCTD_STRIKEOUT := 1
         *      )
         */
        TabStyle{
            Get {
                _tabmode := this.p.Send(SCI_GETTABDRAWMODE)
                for mdName, mdVal in this._TABMODES
                    if (mdVal=_tabmode)
                        Return mdName
            }
            Set {
                for mdName, mdVal in this._TABMODES
                    if (mdName=Value)
                        this.p.Send(SCI_SETTABDRAWMODE, mdVal)
            }
        }

        /**
         * @prop {Integer} TabWidth
         * 
         * Get and set the size of the tabs used in the control
         */
        TabWidth {
            Get => this.p.Send(SCI_GETTABWIDTH)
            Set => this.p.Send(SCI_SETTABWIDTH, Value)
        }

        /**
         * @prop {Boolean} UseTabs
         * 
         * Toggle whether the control uses tabs or spaces
         */
        UseTabs {
            Get => this.p.Send(SCI_GETUSETABS)
            Set => this.p.Send(SCI_SETUSETABS, !!(Value))
        }

        /** @prop {Boolean} UseIndents
         * 
         * Toggle whether the tab and backspace keys insert/delete characters or
         * indent/unindent the current line
         */
        UseIndents {
            Get => this._UseIndents
            Set {
                this._UseIndents := !!(Value)
                this.p.Send(SCI_SETTABINDENTS, this._UseIndents)
                this.p.Send(SCI_SETBACKSPACEUNINDENTS, this._UseIndents)
            }
        }

        /**
         * @prop {Integer} Size
         * 
         * Get and set the size of the whitespace markers in the control
         */
        Size {
            Get => this.p.Send(SCI_GETWHITESPACESIZE)
            Set => this.p.Send(SCI_SETWHITESPACESIZE, Value)
        }
    }

    Class Selection {
        /** @prop {BCBEdit} p The parent `BCBEdit` instance to interact with */
        p := {}

        /**
         * @param {BCBEdit} _BCBEdit The instance of `BCBEdit` to interact with
         */
        __New(_BCBEdit) {
            this.p := _BCBEdit
        }

        /**
         * @prop {Hex Color} Background
         *
         * An **6-8** digit **(A)RGB** hex color as a string or integer defining the color
         * of the selection background
         */
        Background {
            Get => this.p.Send(SCI_GETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK)
            Set {
                _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
                this.p.Send(SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK, _col)
            }
        }

        /**
         * @prop {Hex Color} Foreground
         *
         * An **6-8** digit **(A)RGB** hex color as a string or integer defining the color
         * of the selection foreground
         */
        Foreground {
            Get => this.p.Send(SCI_GETELEMENTCOLOUR, SC_ELEMENT_SELECTION_TEXT)
            Set {
                _col := (Type(Value) = "String") ? Integer("0x" Value) : Value
                this.p.Send(SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_TEXT, _col)
            }
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
        bg:        "080e09",    ;  RGB
        fg:        "b6ffb1",    ;  RGB
        border:    "53864f",    ;  RGB
        indexbg:   "2a392b",    ;  RGB
        indexfg:   "5a8b5e",    ;  RGB
        caret:   "c0fafffa",    ; ARGB
        caretln: "101a3020",    ; ARGB
        selbg:   "aa579261",    ; ARGB
        selfg:   "ff001000",    ; ARGB
        whitefg: "5595d58a"     ; ARGB
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
        this.edit.Font := this.fontName
        this.edit.WrapMode := "word"
        this.edit.Technology := "dw"
        this.edit.MarginWidth := 0
        this.edit.MultipleSelection := True
        this.edit.AdditionalSelectionTyping := True
        this.edit.MultiPaste := True
        this.edit.ScrollBar := False
        this.edit.ScrollPastEnd := False
        this.edit.Background := this.colors.bg
        this.edit.Foreground := this.colors.fg
        this.edit.Selection.Background := this.colors.selbg
        this.edit.Selection.Foreground := this.colors.selfg
        this.edit.WhiteSpace.Visibility := "always_on"
        this.edit.WhiteSpace.Foreground := this.colors.whitefg
        this.edit.WhiteSpace.TabWidth := 4
        this.edit.WhiteSpace.UseTabs := False
        this.edit.WhiteSpace.UseIndents := True
        this.edit.WhiteSpace.Size := 2
        ; this.edit.WhiteSpace.TabStyle := "strike"
        this.edit.Caret.Foreground := this.colors.caret
        this.edit.Caret.LineBackground := this.colors.caretln
        this.edit.Caret.Sticky := "on"
        this.edit.Caret.Width := 2
        ; this.edit.Caret.FrameDraw := True

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
        Hotkey("^+z", ObjBindMethod(this.edit, "Redo"))
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