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
        ; ----------------------------------------------------------------------
        ;
        ;*  Main Gui Options
        ;
        , iWidth        := 900
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
        , sGuiBG        := "ce1cae4"
        , fWinOpacity   := 0.75
        ; ----------------------------------------------------------------------
        ;
        ;*  Tree Options
        ;
        , iTreeHeight   := this.iHeight
        , iTreeWidth    := 200
        , iTreeRows     := 20
        , sTreeBG       := this.sGuiBG
        , sTreeOpts     := "r" this.iTreeRows    " "
                         . "x" 0                 " "
                         . "y" 0                 " "
                         . "w" this.iTreeWidth   " "
                         . "h" this.iTreeHeight  " "
                         . "Background" this.sTreeBG
        , sTreeRecentlySelected := ""
        , sTreeRecentlySelectedText := ""
        , sTreeCtxMenuTargetItem := ""
        ; ----------------------------------------------------------------------
        ;
        ;*  Edit Options
        ;
        , iEditHeight   := this.iHeight
        , iEditWidth    := this.iWidth - this.iTreeWidth
        , sEditBG       := this.sGuiBG
        , sEditOpts     := "WantTab"             " "
                         . "w" this.iEditWidth   " "
                         . "h" this.iEditHeight  " "
                         . "y" 0                 " "
                         . "Background" this.sEditBG
        , sEditPHText   := ""
        ; ----------------------------------------------------------------------
    __New() {
        ScritchEventSink.cGuiParentClass := this  ; Share static reference to 
        ;                                           instance with event sink
        this.oNotes := ScritchNotes()  ; Create helper for managing notes/files
        this.oConf  := ScritchConf()   ; Create helper for Scritch.conf

        ; GUI SETUP
        ; ----------------------------------------------------------------------
        ;   MAIN GUI.=================.
        gGui := Gui( this.sGuiOptsNew ;
                   , this.sWindowName ;
                   , ScritchEventSink )
        ;          :=============|==='
        gGui.OnEvent "Close"     ; <Close>   
                   , "Gui_Close" ; registration 
        ;          '-|-----------\______
        gGui.SetFont( this.sGuiFontOpts ; Set main gui font 
                    , this.sGuiFontName )
        ;           '------------------'
        gGui.MarginX := gGui.MarginY := 0  ; Set Gui X and Y margins
        ; ----------------------------------------------------------------------
        ;   TREEVIEW      .===============.
        gTree := gGui.Add( "TreeView"     ;   Saves notes in edit and pushes
                         , this.sTreeOpts ) ; notes to edit based on selection
        ;            .---|===============/    events
        gTree.OnEvent "ItemSelect"      ; <ItemSelect>
                    , "Tree_ItemSelect" ; registration
        ;           '+-----------------'                 
        ; ----------------------------------------------------------------------
        ;   TREEVIEW ITEMS 
        mTreeItems := Map()                      ; Add items to Treeview
        aGroups := StrSplit(this.oConf.Config["Groups"], "|")
        for sGroup in aGroups
            mTreeItems[sGroup] := Map("Head", gTree.Add(sGroup))
        for oNote in this.oNotes.aNotes {        ; representing notes to edit
            mTreeItems[oNote.sGroup][oNote.sFileNameNoExt] :=
                gTree.Add(
                    oNote.sTimestamp, mTreeItems[oNote.sGroup]["Head"])
        }
        ; ----------------------------------------------------------------------
        ;   TREEVIEW CONTEXT MENU
        gTreeCtxMenu := Menu()
        gTreeCtxMenu.Add("New Note", ObjBindMethod(this, "MenuNewNote"))
        gTreeCtxMenu.Add("Delete Note", ObjBindMethod(this, "MenuDeleteNote"))
        gTreeCtxMenu.Add
        gTreeCtxMenu.Add("New Group", ObjBindMethod(this, "MenuNewGroup"))
        gTreeCtxMenu.Add("Delete Group", ObjBindMethod(this, "MenuDeleteGroup"))
        ;           .--------------------.
        gTree.OnEvent "ContextMenu"      ; <ContextMenu>
                    , "Tree_ContextMenu" ; registration
        ;           '-------------------'
        ; ----------------------------------------------------------------------
        ;   SUBMIT BUTTON      .=================.
        gBtnSubmit := gGui.Add( "Button"         ;   Hidden submit button 
                              , "Hidden Default" ;   triggered on {!s} always,
                              , "&ScritchSubmit" ) ; and {Enter} if edit control
        ;                  __/===============|=='   is not active
        gBtnSubmit.OnEvent "Click"           ; <Click>
                         , "BtnSubmit_Click" ; registration
        ;                '------------------'            
        ; ----------------------------------------------------------------------
        ;   DESTROY BUTTON      .==================.
        gBtnDestroy := gGui.Add( "Button"          ;   Hidden button used to
                               , "Hidden"          ;   save note and destroy Gui
                               , "Scritch&Destroy" ) ; on {!d} trigger
        ;                   ___/=================|'
        gBtnDestroy.OnEvent  "Click"             ; <Click>
                           , "BtnDestroy_Click"  ; registration
        ;                  '--------------------'
        ; ----------------------------------------------------------------------
        ;   EDIT CONTROL  .=================.
        gEdit := gGui.Add( "Edit"           ; Edit control for editing notes
                         , this.sEditOpts   ;
                         , this.sEditPHText )
        ;                '================='
        ; ----------------------------------------------------------------------
        ; STORE GUI IN INSTANCE
        this.gGui         := gGui
        this.gTree        := gTree
        this.mTreeItems   := mTreeItems
        this.gTreeCtxMenu := gTreeCtxMenu
        this.gBtnSubmit   := gBtnSubmit
        this.gBtnDestroy  := gBtnDestroy
        this.gEdit        := gEdit
        ; ----------------------------------------------------------------------
        ; SHOW GUI
        this.gGui.Show "w" this.iWidth " "
                     . "h" this.iHeight
        ; ----------------------------------------------------------------------
        ; SET GUI TRANSPARENCY
        WinSetTransparent(Round(this.fWinOpacity*255), this.sWindowName)
        ; ----------------------------------------------------------------------
        ; SELECT FIRST ITEM IN TREEVIEW
        ControlSend "{Right}{Right}", this.gTree, this.gGui
        ; ----------------------------------------------------------------------
        ; REGISTER HOTKEYS
        HotIf (*)=> this.gGui.Hwnd = WinExist("A") and this.gEdit.Focused
        Hotkey "<^Tab", ObjBindMethod(this, "EditCtrlTab")
        Hotkey "<^Enter", ObjBindMethod(this, "EditCtrlEnter")
        HotIf
    }

    EditCtrlTab(*) {
        this.gTree.Focus
    }

    EditCtrlEnter(*) {
        sTimestamp := this.gTree.GetText(this.gTree.GetSelection())
        for oNote in this.oNotes.aNotes
            if oNote.sTimestamp = sTimestamp
                this.SaveEditToNote oNote
        this.gGui.Hide
    }

    SaveEditToNote(oNote) {
        oNoteFile := FileOpen(this.oNotes.sNotesDir "\" oNote.sFileName, "w")
        oNoteFile.Write this.gEdit.Value
        oNoteFile.Close
    }

    ToggleGui(*) {
        if WinActive("ahk_id " this.gGui.Hwnd)
            this.gGui.Hide
        else this.gGui.Show
    }
    
    ; MENU HANDLER METHODS
    MenuNewNote(sItem, iItem, oMenu)     {  ; Create Note if selection in group

    }
    MenuDeleteNote(sItem, iItem, oMenu)  {  ; Delete Note if note selected

    }
    MenuNewGroup(sItem, iItem, oMenu)    {  ; Create Group > Unconditional
        sNewGroupInput := InputBox("Enter New Group Name: ", "New Group"
                                 , "w" 200 " h" 100 "-Caption", "New Group")
        if sNewGroupInput.Result = "OK" 
                and (sNewGroupInput.Value ~= "^[a-zA-Z0-9_\-\s]+$") {
            this.oConf.Config["Groups"] .= "|" sNewGroupInput.Value
        }
    }
    MenuDeleteGroup(sItem, iItem, oMenu) {  ; Delete Group if group selected

    }
}


Class ScritchEventSink {
    static cGuiParentClass := {}
    ;   GUI <CLOSE>
    static Gui_Close(gMainObj, *) {
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "^\d\d/.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        gMainObj.Destroy
        ExitApp
    }
    ;   BTNSUBMIT <CLICK>
    static BtnSubmit_Click(gCtrl, *) {
        stdo "{ScritchGui.gBtnSubmit} <Click> event triggered"
            , "ClassNN: " gCtrl.ClassNN
            , "Hwnd:    " gCtrl.Hwnd
            , "Type:    " gCtrl.Type
            , "Name:    " gCtrl.Name
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "^\d\d/.*"
            for oNote in cgui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote

    }
    ;   BTNDESTROY <CLICK>
    static BtnDestroy_Click(gCtrl, *) {
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "^\d\d/.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        gCtrl.Gui.Hide
        gCtrl.Gui.Destroy
        ExitApp
    }
    ;   TREE <ITEMSELECT>
    static Tree_ItemSelect(gCtrl, sItem, *) {
        cGui := this.cGuiParentClass
        selectedText := gCtrl.GetText(sItem)
        recentlySelectedText := cGui.sTreeRecentlySelectedText
        cGui := this.cGuiParentClass
        ; if recently selected item is a timestamp, 
        ;       i.e. starts with 2 digits and a backslash
        if recentlySelectedText ~= "^\d\d/.*"
            for oNote in cGui.oNotes.aNotes
                if recentlySelectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        ; if selected item is a timestamp, 
        ;       i.e. starts with 2 digits and a backslash
        if selectedText ~= "^\d\d/.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.gEdit.Value := 
                            FileRead(cGui.oNotes.sNotesDir "\" oNote.sFileName)
        ; sets recently selected item
        cGui.sTreeRecentlySelected := selectedText
        cGui.sTreeRecentlySelectedText := selectedText
    }
    ;   TREE <CONTEXTMENU>
    static Tree_ContextMenu(gCtrl, sItem, *) {
        cGui := this.cGuiParentClass
        gCtxMenu := cGui.gTreeCtxMenu
        cGui.sTreeCtxMenuTargetItem := sItem
        isGroupName := False
        for sGroupName, oGroup in cGui.mTreeItems
            if oGroup["Head"] = sItem
                isGroupName := True
        if !isGroupName {
            gCtxMenu.Disable "Delete Group"
            if sItem {
                gCtxMenu.Enable "New Note"
                gCtxMenu.Enable "Delete Note"
            } else {
                gCtxMenu.Disable "New Note"
                gCtxMenu.Disable "Delete Note"
            }
        } else {
            gCtxMenu.Disable "Delete Note"
            gCtxMenu.Enable "Delete Group"
            gCtxMenu.Enable "New Note"
        }
        gCtxMenu.Show
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
        if IsFile(this.sNotesConf)
            FileDelete this.sNotesConf
        for oNote in this.aNotes {
            sSection := oNote.sFileNameNoExt
            IniWrite oNote.sTimestamp, this.sNotesConf, sSection, "Timestamp"
            IniWrite oNote.sGroup, this.sNotesConf, sSection, "Group"
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
        sGroup         := ""
        __New(sFileName:="", sTimestamp:="", sGroup := "") {
            if !sFileName or !sTimestamp
                this.New
            else this.sFileName      := sFileName
               , this.sTimestamp     := sTimestamp
               , this.sFileNameNoExt := StrSplit(sFileName, ".")[1]
            this.sGroup := sGroup ? sGroup : "General"
        }
        New() {
            this.sGroup := "General"
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



Class ScritchConf {
    __New() {
        if !IsFile(A_ScriptDir "\Scritch.conf")
            FileAppend "", A_ScriptDir "\Scritch.conf"
        if IniRead(A_ScriptDir "\Scritch.conf", "Config", "Groups", 0) = 0
            IniWrite("General", A_ScriptDir "\Scritch.conf", "Config", "Groups")
    }

    __Get(sName, aParams) {
        for vParam in aParams
            if IsAlnum(vParam)
                Return IniRead(A_ScriptDir "\Scritch.conf", sName, vParam, 0)
    }

    __Set(sName, aParams, vValue) {
        stdo "Name: " sName, "`tParam1: " aParams[1], "`tValue: " vValue
        for vParam in aParams
            if IsAlnum(StrReplace(vParam, A_Space, "")) and !IsObject(vValue) {
                IniWrite vValue, A_ScriptDir "\Scritch.conf", sName, vParam
                Return IniRead(A_ScriptDir "\Scritch.conf", sName, vParam, 0)
            }
        Return 0
    }
}


ParseTimestampFromFileName(sFileName) {
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

IsFile(sFilePath) {
    if (sExists := FileExist(sFilePath)) and (InStr(sExists, "A") 
                                           or InStr(sExists, "N"))
        Return True
    else Return False
}


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;  DEBUG FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
_Debug_ClearNotes() {
    if IsFile(A_ScriptDir "\scritches\*.note")
        FileDelete A_ScriptDir "\scritches\*.note"
    if IsFile(A_ScriptDir "\notes.conf")
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
        stdo tNote.sFileName, "`t" tNote.sTimestamp, "`t" tNote.sGroup
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;  DEBUG FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  IF DEBUGGING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
if A_ScriptName = "Scritch.ahk" {
    ; _Debug_ClearNotes
    ; testScritchNotes := ScritchNotes()
    ; _Debug_AddNotes(testScritchNotes)
    ; _Debug_LoopNoteInfo(testScritchNotes)
    testScritchGui := ScritchGui()
    Hotkey "<#v", ObjBindMethod(testScritchGui, "ToggleGui")
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  IF DEBUGGING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
