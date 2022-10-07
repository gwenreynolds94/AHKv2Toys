#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DBT.ahk

Class ScritchGui {
    ;
    ;* General Instance Variables
    oNotes := {}
    ;
    ;* Gui Options Instance Variables
    sWindowName := "Scritches"
        ;
        ;
        ;*  Main Gui Options
        ;
        , iWidth        := 750
        , iHeight       := 450
        , iXPosition    := A_ScreenWidth/2 - this.iWidth/2
        , iYPosition    := A_ScreenHeight/2 - this.iHeight/2
        , sGuiOptsNew   := "-Caption -AlwaysOnTop"
        , sGuiOpts      := "w" this.iWidth      " "
                         . "h" this.iHeight     " "
                         . "x" this.iXPosition  " "
                         . "y" this.iYPosition
        , sGuiFontName  := "Fira Code"
        , sGuiFontOpts  := ""
        ;
        ;
        ;*  Buttons Options
        ;
        , iBtnBoxHeight  := 30
        , iBtnBoxWidth   := 200
        , iBtnBoxPadding := 5
        , iBtnNewNoteXPos   := this.iBtnBoxPadding
        , iBtnNewNoteYPos   := this.iHeight 
                               - this.iBtnBoxHeight 
                               + this.iBtnBoxPadding
        , iBtnNewNoteHeight := this.iBtnBoxHeight - this.iBtnBoxPadding*2
        , iBtnNewNoteWidth  := this.iBtnBoxWidth/3 - this.iBtnBoxPadding*4
        ;
        ;
        ;*  Tree Options
        ;
        , iTreeHeight   := this.iHeight - this.iBtnBoxHeight
        , iTreeWidth    := this.iBtnBoxWidth
        , iTreeRows     := 20
        , sTreeOpts     := "r" this.iTreeRows  " "
                         . "x" 0               " "
                         . "y" 0               " "
                         . "w" this.iTreeWidth " "
                         . "h" this.iTreeHeight
        , sTreeRecentlySelected := ""
        , sTreeRecentlySelectedText := ""
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
        , sEditPHText   := ""
    
    __New() {
        ScritchEventSink.cGuiParentClass := this  ; Share static reference to 
        ;                                           instance with event sink
        this.oNotes := ScritchNotes()  ; Create helper for managing notes/files
        ;
        ; MAIN GUI  .=================.
        gGui := Gui( this.sGuiOptsNew ;
                   , this.sWindowName ;
                   , ScritchEventSink )
        ;          '=================='
        gGui.OnEvent "Close"     ; <Close>   
                   , "Gui_Close" ; registration 
        ;          '-,-----------\______
        gGui.SetFont( this.sGuiFontOpts ; Set main gui font 
                    , this.sGuiFontName )
        ;           '-------------------'
        ;
        gGui.MarginX := gGui.MarginY := 0   ; Set Gui X and Y margins
        ;
        ; TREEVIEW        .===============.
        gTree := gGui.Add( "TreeView"     ;   Saves notes in edit and pushes
                         , this.sTreeOpts ) ; notes to edit based on selection
        ;                '================'   events
        gTree.OnEvent "ItemSelect", "Tree_ItemSelect"  ; <ItemSelect>
        ;                                                registration
        ; TREEVIEW ITEMS 
        mTreeItems := Map()                      ; Add items to Treeview
        for oNote in this.oNotes.aNotes {        ; representing notes to edit
            if !mTreeItems.Has(oNote.sCategory)  ;
                mTreeItems[oNote.sCategory] :=   ;
                    Map("Head", gTree.Add(oNote.sCategory))
            mTreeItems[oNote.sCategory][oNote.sFileNameNoExt] :=
                gTree.Add(
                    oNote.sTimestamp, mTreeItems[oNote.sCategory]["Head"])
        }
        ;
        ;   SUBMIT BUTTON      .=================.
        gBtnSubmit := gGui.Add( "Button"         ;   Hidden submit button 
                              , "Hidden Default" ;   triggered on {!s} always,
                              , "&ScritchSubmit" ) ; and {Enter} if edit control
        ;                  __/==================='   is not active
        gBtnSubmit.OnEvent "Click"           ; <Click>
                         , "BtnSubmit_Click" ; registration
        ;                '-------------------'            
        ;
        ;   DESTROY BUTTON      .==================.
        gBtnDestroy := gGui.Add( "Button"          ;   Hidden button used to
                               , "Hidden"          ;   save note and destroy Gui
                               , "Scritch&Destroy" ) ; on {!d} trigger
        ;                   ___/==================='
        gBtnDestroy.OnEvent  "Click"             ; <Click>
                           , "BtnDestroy_Click"  ; registration
        ;                  '---------------------'
        ;
        ;   EDIT CONTROL  .=================.
        gEdit := gGui.Add( "Edit"           ; Edit control for editing notes
                         , this.sEditOpts   ;
                         , this.sEditPHText )
        ;                '=================='
        ;
        ;   NEW NOTE BUTTON     .=====================.
        gBtnNewNote := gGui.Add( "Button"             ;   Button to create a new
                               , this.iBtnNewNoteOpts ;   note, update stored
                               , "&New Note"          ) ; info, and create file
        ;                  ___/======================='
        gBtnNewNote.OnEvent "Click"            ; <Click>
                          , "BtnNewNote_Click" ; registration
        ;                 '--------------------'
        ;                                       
        ; STORE GUI IN INSTANCE
        this.gGui        := gGui
        this.gTree       := gTree
        this.mTreeItems  := mTreeItems
        this.gBtnSubmit  := gBtnSubmit
        this.gBtnDestroy := gBtnDestroy
        this.gEdit       := gEdit
        this.gBtnNewNote := gBtnNewNote
        ;
        ; SHOW GUI
        this.gGui.Show "w" this.iWidth " "
                     . "h" this.iHeight
        ;
        ; SELECT FIRST ITEM IN TREEVIEW
        ControlSend "{Right}{Right}", this.gTree, this.gGui
        ;
        ; REGISTER HOTKEYS
        HotIf (*)=> this.gGui.Hwnd = WinExist("A") and this.gEdit.Focused
        Hotkey "<^Tab", ObjBindMethod(this, "OverrideEditTabFunction")
        Hotkey "<^Enter", ObjBindMethod(this, "EditCtrlEnter")
        HotIf
    }

    OverrideEditTabFunction(*) {
        this.gTree.Focus
    }

    EditCtrlEnter(*) {
        sTimestamp := this.gTree.GetText(this.gTree.GetSelection())
        for oNote in this.oNotes.aNotes
            if oNote.sTimestamp = sTimestamp
                this.SaveEditToNote oNote
    }

    SaveEditToNote(oNote) {
        oNoteFile := FileOpen(this.oNotes.sNotesDir "\" oNote.sFileName, "w")
        oNoteFile.Write this.gEdit.Value
        oNoteFile.Close
    }
}



Class ScritchEventSink {
    static cGuiParentClass := {}
    static Gui_Close(gMainObj, *) {
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "\d\d/\.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        gMainObj.Destroy
        ExitApp
    }
    static BtnSubmit_Click(gCtrl, *) {
        stdo "{ScritchGui.gBtnSubmit} <Click> event triggered"
            , "ClassNN: " gCtrl.ClassNN
            , "Hwnd:    " gCtrl.Hwnd
            , "Type:    " gCtrl.Type
            , "Name:    " gCtrl.Name
    }
    static BtnDestroy_Click(gCtrl, *) {
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "\d\d/\.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        gCtrl.Gui.Hide
        gCtrl.Gui.Destroy
        ExitApp
    }
    static BtnNewNote_Click(gCtrl, *) {

    }
    static Tree_ItemSelect(gCtrl, sItem, *) {
        cGui := this.cGuiParentClass
        selectedText := gCtrl.GetText(sItem)
        recentlySelectedText := cGui.sTreeRecentlySelectedText
        cGui := this.cGuiParentClass
        ; if recently selected item is a timestamp, 
        ;       i.e. starts with 2 digits and a backslash
        if recentlySelectedText ~= "\d\d/\.*"
            for oNote in cGui.oNotes.aNotes
                if recentlySelectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        ; if selected item is a timestamp, 
        ;       i.e. starts with 2 digits and a backslash
        if selectedText ~= "\d\d/\.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.gEdit.Value := 
                            FileRead(cGui.oNotes.sNotesDir "\" oNote.sFileName)
        ; sets recently selected item
        cGui.sTreeRecentlySelected := selectedText
        cGui.sTreeRecentlySelectedText := selectedText
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
    oScritchNotes.UpdateNote , "loremloremloremloremlorem"
                             , oScritchNotes.aNotes[1].sTimestamp
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
