#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\..\Lib\
#Include SciLib\SciConstants.ahk
#Include DEBUG\DBT.ahk


scint := DllCall("LoadLibrary", "Str", "Scintilla.dll", "Ptr")


mainGui := Gui("+Resize", "Main Window")
scintctrl := ScEdit(mainGui, "w300 h300")
scintctrl.MultipleSelection := True
scintctrl.Style.Background := 0xFFAAAA
scintctrl.Style.Selection.Background := 0xFF8888
scintctrl.Style.Caret.Line.Background := 0xFFBBBB

mainGui.Show()

OnExit FreeScintilla
FreeScintilla(*) {
    DllCall("FreeLibrary", "Ptr", scint)
}

F9::
{
    stdo scintctrl.Text
}

; Scendilla SCI_SETMULTIPLESELECTION, 1
; Scendilla SCI_SETADDITIONALSELECTIONTYPING, 1, 1 
; Scendilla SCI_SETMULTIPASTE, 1, 1
; 
; Scendilla SCI_SETWRAPMODE, 1

; 
; SendMessage 2573, 1, 5, scintctrl, "ahk_id " mainGui.HWND
; SendMessage 2573, 10, 15, scintctrl, "ahk_id " mainGui.HWND
; linelength := SendMessage(SCI_LINELENGTH,,, scintctrl, "ahk_id " mainGui.HWND)
; lineEnd := SendMessage(SCI_LINEEND,,, scintctrl, "ahk_id " mainGui.Hwnd)
; if MsgBox(linelength "`n" lineEnd
    ; ,, "t1")
    ; ExitApp


; You can also send messages to the Scintilla control with SendMessage each time
; but it can lead to poor performance on Windows. It would look like this ->
; ...SendMessage msg, wparam, lparam, ctrlWinTitle, guiWinTitle
Scendilla(msg, wparam:=0, lparam:=0, hwnd:="") {
    static init := False
         , DirectFunction := ""
         , DirectPointer  := ""
    if !init and hwnd {
        init := True
        DirectFunction := SendMessage(SCI_GETDIRECTFUNCTION, 0, 0,, "ahk_id " hwnd)
        DirectPointer  := SendMessage(SCI_GETDIRECTPOINTER, 0, 0,, "ahk_id " hwnd)
        Return
    } else if !init and !hwnd
        Return
    Return DllCall(DirectFunction
                , "UInt", DirectPointer
                , "Int", msg
                , "UInt", wparam
                , "UInt", lparam)
}

Class ScEdit {
    static WRAPMODES := Map("none", SC_WRAP_NONE
                          , "char", SC_WRAP_CHAR
                          , "whitespace", SC_WRAP_WHITESPACE
                          , "word", SC_WRAP_WORD)
    __New(guiParent, options:="") {
        this.ctrl := guiParent.Add("Custom", "ClassScintilla " options)
        Scendilla 0, 0, 0, this.ctrl.Hwnd
        this.Style := ScEdit.Style()
    }

    WordWrap {
        Get {
            mode := Scendilla(SCI_GETWRAPMODE)
            for modeName, modeInt in ScEdit.WRAPMODES
                if mode = modeInt
                    Return modeName
        }
        Set {
            if ScEdit.WRAPMODES.Has(StrLower(Value))
                Scendilla SCI_SETWRAPMODE, ScEdit.WRAPMODES[StrLower(Value)]
        }
    }

    MultipleSelection {
        Get => Scendilla(SCI_GETMULTIPLESELECTION)
        Set => Scendilla(SCI_SETMULTIPLESELECTION, Value)
    }

    Text {
        Get {
            nLen := Scendilla(SCI_GETLENGTH)
            buf := Buffer(nLen+1)
            Scendilla SCI_GETTEXT, nLen, buf.Ptr
            Return StrGet(buf,,"UTF-8")
        }
    }

    Class Style {
        __New() {
            this.Selection := ScEdit.Style.Selection()
            this.Caret := ScEdit.Style.Caret()
        }

        Background {
            Get => Scendilla(SCI_STYLEGETBACK)
            Set {
                Scendilla SCI_STYLESETBACK, STYLE_DEFAULT, Value
                Scendilla SCI_STYLECLEARALL
            }
        }

        Class Caret {
            __New() {
                this.Line := ScEdit.Style.Caret.Line()
            }
            Class Line {
                Background {
                    Get => Scendilla(SCI_GETELEMENTCOLOUR, SC_ELEMENT_CARET_LINE_BACK)
                    Set => Scendilla(SCI_SETELEMENTCOLOUR, SC_ELEMENT_CARET_LINE_BACK, Value)
                }
            }
        }
        
        Class Selection {
            Background {
                Get => Scendilla(SCI_GETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK)
                Set => Scendilla(SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK, Value)
            }
        }
    }

    __Get(Name, Params) {
        if StrLower(Name) = "ctrl"
            Return ScEdit.ctrl
        else Return ScEdit.ctrl.%Name%
    }

    __Set(Name, Params, Value) {
        if StrLower(Name) = "ctrl"
            Return ScEdit.ctrl := Value
        else Return ScEdit.ctrl.%Name% := Value
    }
}

F8::ExitApp