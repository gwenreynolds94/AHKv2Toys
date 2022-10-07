#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DBT.ahk

Class ScritchGui {
    ;* Instance Variables
    ;

    ;
    sWindowName := "Scritches"
        ;
        ;
        ;*  Gui Options
        ;
        , iWidth        := 750
        , iHeight       := 450
        , iXPosition    := A_ScreenWidth/2 - this.iWidth/2
        , iYPosition    := A_ScreenHeight/2 - this.iHeight/2
        , sGuiOptsNew   := "-Caption +AlwaysOnTop"
        , sGuiOpts      := "w" this.iWidth      " "
                         . "h" this.iHeight     " "
                         . "x" this.iXPosition  " "
                         . "y" this.iYPosition
        , sGuiFontName  := "Fira Code"
        , sGuiFontOpts  := ""
        ;
        ;
        ;*  BtnSubmit Options
        ;
        , iBtnBoxHeight := 50
        ;
        ;
        ;*  Tree Options
        ;
        , iTreeHeight   := this.iHeight - this.iBtnBoxHeight
        , iTreeWidth    := 200
        , iTreeRows     := 20
        ; , sTreeOpts     := "r20 x0 y0 w200 h" this.iHeight
        , sTreeOpts     := "r" this.iTreeRows  " "
                         . "x" 0               " "
                         . "y" 0               " "
                         . "w" this.iTreeWidth " "
                         . "h" this.iTreeHeight
        , sTreeRecentlySelected := ""
        ;
        ;
        ;*  Edit Options
        ;
        , iEditHeight   := this.iHeight
        , iEditWidth    := this.iWidth - this.iTreeWidth
        , sEditOpts     := "WantTab"            " "
                         . "w" this.iEditWidth  " "
                         . "h" this.iEditHeight " "
                         . "y" 0
        , sEditPHText   := "Lorem Ipsum SAMPLE L>%@>%:@:<%@<%%}#$^%$%*(&)"
    
    __New() {
        ScritchEventSink.cGuiParentClass := this
        ; Instance of helper class to 
        ;      store, get, and set info about note files
        this.oNotes := ScritchNotes()

        ; Main gui object
        gGui := Gui( this.sGuiOptsNew ;
                   , this.sWindowName ;
                   , ScritchEventSink )
                   ;__________________;

        ; Set main gui font 
        gGui.SetFont( this.sGuiFontOpts ;
                    , this.sGuiFontName )
                    ;___________________;

        ; Set main gui margin 
        gGui.MarginX := gGui.MarginY := 0

        ; Treeview representing a log of all notes 
        gTree := gGui.Add( "TreeView"     ;
                         , this.sTreeOpts )
                         ;________________;
        gTree.OnEvent "ItemSelect", "Tree_ItemSelect"

        ; Add items to Treeview representing notes 
        mTreeItems := Map()
        for oNote in this.oNotes.aNotes {
            if !mTreeItems.Has(oNote.sCategory)
                mTreeItems[oNote.sCategory] := 
                    Map("Head", gTree.Add(oNote.sCategory))
            mTreeItems[oNote.sCategory][oNote.sFileNameNoExt] :=
                gTree.Add(
                    oNote.sTimestamp, mTreeItems[oNote.sCategory]["Head"])
        }

        ; Hidden Default Submit button handling
        ;      <Enter>/<^s>/Click events and its event registration
        gBtnSubmit := gGui.Add( "Button"         ;
                              , "Hidden Default" ;
                              , "&ScritchSubmit" )
                              ;__________________;

        ; Hidden Destroy Gui button handling 
        ;       <^d>/Click events and its event registration
        gBtnDestroy := gGui.Add( "Button"          ;
                               , "Hidden"          ;
                               , "Scritch&Destroy" )
                               ;___________________;

        gBtnSubmit.OnEvent "Click", "BtnSubmit_Click"
        gBtnDestroy.OnEvent  "Click", "BtnDestroy_Click"

        gEdit := gGui.Add( "Edit"           ;
                         , this.sEditOpts   ;
                         , this.sEditPHText )
                         ;__________________;

        this.gGui       := gGui
        this.gTree      := gTree
        this.mTreeItems := mTreeItems
        this.gBtnSubmit := gBtnSubmit
        this.gEdit      := gEdit

        this.gGui.Show "w" this.iWidth " "
                     . "h" this.iHeight
        ControlSend "{Right}{Right}", this.gTree, this.gGui

        
        HotIf (*)=> this.gGui.Hwnd = WinExist("A") and this.gEdit.Focused
        Hotkey "<^Tab", ObjBindMethod(this, "OverrideEditTabFunction")
        HotIf
    }

    OverrideEditTabFunction(*) {
        this.gTree.Focus
    }
}



Class ScritchEventSink {
    static cGuiParentClass := {}
    static BtnSubmit_Click(gCtrl, *) {
        stdo "{ScritchGui.gBtnSubmit} <Click> event triggered"
            , "ClassNN: " gCtrl.ClassNN
            , "Hwnd: " gCtrl.Hwnd
            , "Type: " gCtrl.Type
            , "Name: " gCtrl.Name
    }
    static BtnDestroy_Click(gCtrl, *) {
        gCtrl.Gui.Hide
        gCtrl.Gui.Destroy
        ExitApp
    }
    static Tree_ItemSelect(gCtrl, sItem, *) {
        stdo sItem
           , "`t" gCtrl.GetText(sItem)
           , "`t" this.cGuiParentClass.sTreeRecentlySelected
        ; if selected item is a timestamp, 
        ;       i.e. starts with 2 digits and a backslash
        if gCtrl.GetText(sItem) ~= "\d\d/\.*"
            stdo "Matched"
        ; sets recently selected item
        this.cGuiParentClass.sTreeRecentlySelected := sItem
    }
}

Class ScritchConf {
    __Get(sName, aParams) {

    }

    __Set(sName, aParams, vValue) {

    }
}

Class ScritchNotes {
    sNotesDir := A_ScriptDir "\scritches"
    sNotesConf := A_ScriptDir "\notes.conf"
    aNotes := []
    
    __New() {
        if not InStr(FileExist(this.sNotesDir), "D")
            DirCreate this.sNotesDir
        Loop Files (this.sNotesDir "\*.note") {
            sTimestamp := ParseTimestampFromFileName(A_LoopFileName)
            oNote := ScritchNotes.Note(A_LoopFileName, sTimestamp)
            this.aNotes.Push oNote
        }
        this.UpdateConf
    }

    UpdateNote(oNote:="", sContent:="", sTimestamp:="") {
        if !oNote and !sTimestamp
            Return 0
        if !oNote and sTimestamp
            for ooNote in this.aNotes
                if ooNote.sTimestamp = sTimestamp
                    oNote := ooNote
        oNoteFile := FileOpen(this.sNotesDir "\" oNote.sFileName, "w")
        oNoteFile.Write(sContent)
        oNoteFile.Close
        Return oNote.sFileName
    }

    UpdateConf() {
        if (FileExist(this.sNotesConf) ~= "A|N")
            FileDelete this.sNotesConf
        for oNote in this.aNotes {
            sSection := oNote.sFileNameNoExt
            IniWrite oNote.sTimestamp, this.sNotesConf, sSection, "Timestamp"
            IniWrite oNote.sCategory, this.sNotesConf, sSection, "Category"
        }
    }

    NewNote() {
        oNewNote := ScritchNotes.Note()
        this.aNotes.Push oNewNote
        stdo this.sNotesDir "\" oNewNote.sFileName
        FileAppend "", this.sNotesDir "\" oNewNote.sFileName
        this.UpdateConf
    }

    Class Note {
        sFileName      := ""
        sFileNameNoExt := ""
        sTimestamp     := ""
        sCategory      := ""
        __New(sFileName:="", sTimestamp:="", sCategory := "") {
            if !sFileName or !sTimestamp
                this.New
            else this.sFileName      := sFileName
               , this.sTimestamp     := sTimestamp
               , this.sCategory      := "General"
               , this.sFileNameNoExt := StrSplit(sFileName, ".")[1]
        }
        New() {
            this.sCategory := "General"
            oTimestamp := GetLocalTime()
            for sName in oTimestamp.OwnProps() {
                if StrLen(oTimestamp.%sName%) = 1
                    oTimestamp.%sName% := "0" oTimestamp.%sName%
            }
            this.sTimestamp := oTimestamp.sYear "/" 
                             . oTimestamp.sMonth "/"
                             . oTimestamp.sDay
                             . " "
                             . oTimestamp.sHour ":"
                             . oTimestamp.sMinute ":"
                             . oTimestamp.sSecond "."
                             . oTimestamp.sMilliseconds
            this.sFileNameNoExt  := oTimestamp.sYear
                                  . oTimestamp.sMonth
                                  . oTimestamp.sDay
                                  . oTimestamp.sHour
                                  . oTimestamp.sMinute
                                  . oTimestamp.sSecond
                                  . oTimestamp.sMilliseconds
            this.sFileName := this.sFileNameNoExt ".note"
        }
    }
}

/**
 * `ParseTimestampFromFileName(sFileName) -> {String}`
 * -----------------------------------------------------------------------------
 * -----------------------------------------------------------------------------
 * @param {String} sFileName - FileName property of Note instance
 *                             to be split every 2 characters
 * 
 *      sFileName String Format ->
 *      ... "{year}{month}{day}{hour}{minute}{second}{milliseconds}.note"
 * -----------------------------------------------------------------------------
 * @return {String} - Returns timestamp
 * 
 *      Return String Format ->
 *      ... "22/12/31 24:60:60.99"
 * -----------------------------------------------------------------------------
 * */
ParseTimestampFromFileName(sFileName) {
    /** @var {Array[String]} aFN - Variable name abbreviated 
     *                             due to repetetive usage */
    aFN := []
    Loop 7 {
        aFN.Push SubStr(sFileName, (A_Index*2 - 1), 2)
    }
    Return aFN[1] "/" aFN[2] "/" aFN[3] 
         . " "
         . aFN[4] ":" aFN[5] ":" aFN[6] "." aFN[7]
}

GetLocalTime() {
    pSYSTEMTIME := Buffer(8*2)
    DllCall "GetLocalTime", "Ptr", pSYSTEMTIME
    Return {        sYear: SubStr(NumGet(pSYSTEMTIME, 0*2, "UShort"), 3, 2),
                   sMonth: NumGet(pSYSTEMTIME, 1*2, "UShort"),
               sDayofweek: NumGet(pSYSTEMTIME, 2*2, "UShort"),
                     sDay: NumGet(pSYSTEMTIME, 3*2, "UShort"),
                    sHour: NumGet(pSYSTEMTIME, 4*2, "UShort"),
                  sMinute: NumGet(pSYSTEMTIME, 5*2, "UShort"),
                  sSecond: NumGet(pSYSTEMTIME, 6*2, "UShort"),
            sMilliseconds: (
                Integer(Round("0." NumGet(pSYSTEMTIME, 7*2, "UShort"), 2) * 100)
            )
    }
}









; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;  DEBUG FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
_Debug_ClearNotes() {
    if FileExist(A_ScriptDir "\scritches\*.note") ~= "A|N"
        FileDelete A_ScriptDir "\scritches\*.note"
    if FileExist(A_ScriptDir "\notes.conf") ~= "A|N"
        FileDelete A_ScriptDir "\notes.conf"
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
_Debug_AddNotes(oScritchNotes) {
    oScritchNotes.NewNote()
    Sleep 10
    oScritchNotes.NewNote()
    Sleep 10
    oScritchNotes.NewNote()
    for oNote in oScritchNotes.aNotes {
        sNote := ""
        Loop A_Index {
            sNote .= "Lorem Ipsum `n"
        }
        oScritchNotes.UpdateNote oNote, sNote
    }
    oScritchNotes.UpdateNote , "loremloremloremloremlorem", oScritchNotes.aNotes[1].sTimestamp
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
_Debug_LoopNoteInfo(oScritchNotes) {
    for tNote in oScritchNotes.aNotes
        stdo tNote.sFileName, "`t" tNote.sTimestamp, "`t" tNote.sCategory
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;  DEBUG FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  IF DEBUGGING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
if A_ScriptName = "Scritch.ahk" {
    _Debug_ClearNotes
    testScritchNotes := ScritchNotes()
    _Debug_AddNotes(testScritchNotes)
    _Debug_LoopNoteInfo(testScritchNotes)
    testScritchGui := ScritchGui()
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  IF DEBUGGING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
