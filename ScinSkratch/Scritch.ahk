#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force


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
        , iXPosition    := Integer(A_ScreenWidth/2 - this.iWidth/2)
        , iYPosition    := Integer(A_ScreenHeight/2 - this.iHeight/2)
        , sGuiOptsNew   := "-Caption +AlwaysOnTop"
        , sGuiOpts      := "w" this.iWidth      " "
                         . "h" this.iHeight     " "
                         . "x" this.iXPosition  " "
                         . "y" this.iYPosition
        , sGuiHideOpts  := this.sGuiOpts " Hide"
        , sGuiFontName  := "FiraCode NFM"
        , sGuiFontOpts  := "s9"
        ; , sGuiBG        := "ce1cae4"
        , sGuiBG        := "cffccdd"
        , fWinOpacity   := 0.65
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
        ;
        ;* BGGui/BGPic Options
        , fBGOpacity   := 0.7
        , iBGPicWidth  := this.iWidth
        , iBGPicHeight := this.iHeight
        , iBGPicXPos   := 0
        , iBGPicYPos   := 0
        , sBGPicOpts   := "x" this.iBGPicXPos  " "
                        . "y" this.iBGPicYPos  " "
                        . "w" this.iBGPicWidth " "
                        . "h" this.iBGPicHeight
        ; ----------------------------------------------------------------------
    __New(sScritchWorkingDir, startHidden:=False) {
        ; VALIDATE WORKING DIR
        if !InStr(FileExist(sScritchWorkingDir), "D") {
            SplitPath(sScritchWorkingDir,, &sDirDaddy)
            if InStr(FileExist(sDirDaddy), "D")
                DirCreate sScritchWorkingDir
        }
        this.sScritchWorkingDir := sScritchWorkingDir
        ; SET EVENTSINK GUI REFERENCE
        ;
        ScritchEventSink.cGuiParentClass := this  ; Share static reference to
        ;                                           instance with event sink
        ; ----------------------------------------------------------------------
        ; SET NOTE MANAGER AND CONF MANAGER
        ;
        this.oNotes := ScritchNotes(sScritchWorkingDir)  ; Create helper for managing notes/files
        this.oConf  := ScritchConf(sScritchWorkingDir)   ; Create helper for Scritch.conf
        ; ----------------------------------------------------------------------
        ;
        ; GUI SETUP
        ; ----------------------------------------------------------------------
        ;   MAIN GUI
        ;           .=================.
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
        ;   BACKGROUND PICTURE
        gBGGui := Gui( this.sGuiOptsNew
                     , this.sWindowName "BG" )
        if !IsFile(sScritchWorkingDir "\bg.png")
            Download "https://www.transparenttextures.com/patterns/"
                   . "45-degree-fabric-light.png"
                   , sScritchWorkingDir "\bg.png"
        gBGPic := gBGGui.Add( "Picture"
                            , this.sBGPicOpts
                            , sScritchWorkingDir "\bg.png")
        ; ----------------------------------------------------------------------
        ;   TREEVIEW
        ;                 .===============.
        gTree := gGui.Add( "TreeView"     ;   Saves notes in edit and pushes
                         , this.sTreeOpts ) ; notes to edit based on selection
        ;            .---|===============/    events
        gTree.OnEvent "ItemSelect"      ; <ItemSelect>
                    , "Tree_ItemSelect" ; registration
        ;           '+-----------------'
        ; ----------------------------------------------------------------------
        ;   TREEVIEW ITEMS
        ;
        mTreeItems := Map()                      ; Add items to Treeview
        if !this.oConf.Config["Groups"]
            this.oConf.Config["Groups"] := "General"
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
        ;
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
        ;   DESTROY BUTTON
        ;                       .==================.
        gBtnDestroy := gGui.Add( "Button"          ;   Hidden button used to
                               , "Hidden"          ;   save note and destroy Gui
                               , "Scritch&Destroy" ) ; on {!d} trigger
        ;                   ___/=================|'
        gBtnDestroy.OnEvent  "Click"             ; <Click>
                           , "BtnDestroy_Click"  ; registration
        ;                  '--------------------'
        ; ----------------------------------------------------------------------
        ;   EDIT CONTROL
        ;                 .=================.
        gEdit := gGui.Add( "Edit"           ; Edit control for editing notes
                         , this.sEditOpts   ;
                         , this.sEditPHText )
        ;                '================='
        ; ----------------------------------------------------------------------
        ; STORE GUI IN INSTANCE
        ;
        this.gGui         := gGui
        this.gBGGui       := gBGGui
        this.gTree        := gTree
        this.mTreeItems   := mTreeItems
        this.gTreeCtxMenu := gTreeCtxMenu
        this.gBtnDestroy  := gBtnDestroy
        this.gEdit        := gEdit
        ; ----------------------------------------------------------------------
        ; SHOW GUI
        ;
        if startHidden {
            sHiddenOpts := RegExReplace(
                this.sGuiOpts   ; from gui options
              , "(?<=x)\d+"     ; find x{XPos}
              , A_ScreenWidth   ; replace {XPos} with screen width
            )
            this.gBGGui.Show sHiddenOpts " NA"
            this.gGui.Show   sHiddenOpts " NA"
            WinSetTransparent(Round(this.fBGOpacity*255), this.sWindowName "BG")
            WinSetTransparent(Round(this.fWinOpacity*255), this.sWindowName)
            this.gBGGui.Opt("+Owner")
            this.gGui.Opt( "+Owner" this.gBGGui.Hwnd )
            this.gBGGui.Show this.sGuiOpts " Hide"
            this.gGui.Show this.sGuiOpts " Hide"
            for gCtrl in this.gBGGui
                gCtrl.Redraw
            for gCtrl in this.gGui
                gCtrl.Redraw
        } else {
            this.gBGGui.Show this.sGuiOpts
            this.gGui.Show this.sGuiOpts
            WinSetTransparent(Round(this.fBGOpacity*255), this.sWindowName "BG")
            WinSetTransparent(Round(this.fWinOpacity*255), this.sWindowName)
            ControlSend "{Right}{Right}", this.gTree, this.gGui
            this.gBGGui.Opt("+Owner")
            this.gGui.Opt( "+Owner" this.gBGGui.Hwnd )
        }
        ; ----------------------------------------------------------------------
        ; REGISTER HOTKEYS
        ;
        HotIf (*)=> this.gGui.Hwnd = WinExist("A") and this.gEdit.Focused
        Hotkey "<^Tab", ObjBindMethod(this, "EditCtrlTab")
        Hotkey "<^Enter", ObjBindMethod(this, "EditCtrlEnter")
        HotIf
        ; ----------------------------------------------------------------------
    }

    ; Allow tab navigation in addition to typing
    ;     the tab character while focused on the edit control
    EditCtrlTab(*) {
        this.gTree.Focus
    }

    ; Quickly save and close current note/gui
    EditCtrlEnter(*) {
        sTimestamp := this.gTree.GetText(this.gTree.GetSelection())
        for oNote in this.oNotes.aNotes
            if oNote.sTimestamp = sTimestamp
                this.SaveEditToNote oNote
        this.gBGGui.Hide
        this.gGui.Hide
    }

    ; Save content of edit control to note file, overwriting it
    SaveEditToNote(oNote) {
        oNoteFile := FileOpen(this.oNotes.sNotesDir "\" oNote.sFileName, "w")
        oNoteFile.Write this.gEdit.Value
        oNoteFile.Close
    }

    ; Toggle gui window visibility
    ToggleGui(*) {
        if WinActive("ahk_id " this.gGui.Hwnd) {
            sCurrentSelection := this.gTree.GetText(this.gTree.GetSelection())
            for oNote in this.oNotes.aNotes
                if (sCurrentSelection = oNote.sTimestamp)
                    this.SaveEditToNote oNote
            this.gBGGui.Hide
            this.gGui.Hide
        } else {
            this.gBGGui.Show
            this.gGui.Show
            ControlSend "{Right}{Right}", this.gTree, this.gGui
        }
    }

    ; Create new note from TreeView Menu
    MenuNewNote(sItem, iItem, oMenu)     {  ; Create Note if selection in group
        sItemID     := this.sTreeCtxMenuTargetItem
        sItemName   := this.gTree.GetText(sItemID)
        sItemParent := this.gTree.GetParent(sItemID)
        for sGroupName, mGroup in this.mTreeItems
            if sItemName = sGroupName
                sItemParent := this.mTreeItems[sGroupName]["Head"]
        sItemParentName := this.gTree.GetText(sItemParent)
        oNewNote := this.oNotes.NewNote( , , sItemParentName)
        this.mTreeItems[oNewNote.sGroup][oNewNote.sFileNameNoExt] :=
                this.gTree.Add(
                    oNewNote.sTimestamp
                  , this.mTreeItems[oNewNote.sGroup]["Head"])

    }
    ; Delete note from TreeView Menu
    MenuDeleteNote(sItem, iItem, oMenu)  {  ; Delete Note if note selected
        sItemID := this.sTreeCtxMenuTargetItem
        sItemName := this.gTree.GetText(sItemID)
        for oNote in this.oNotes.aNotes
            if oNote.sTimestamp = sItemName {
                this.oNotes.DeleteNote oNote.sTimestamp
                Break
            }
        this.gTree.Delete sItemID
    }
    ; Create new group from TreeView Menu
    MenuNewGroup(sItem, iItem, oMenu)    {  ; Create Group > Unconditional
        this.gGui.Opt("-AlwaysOnTop")
        sNewGroupInput := InputBox("Enter New Group Name: ", "New Group"
                                 , "w" 200 " h" 100, "New Group")
        this.gGui.Opt("+AlwaysOnTop")
        if sNewGroupInput.Result = "OK"
                and (sNewGroupInput.Value ~= "^[a-zA-Z0-9_\-\s]+$") {
            sGroup := sNewGroupInput.Value
            this.oConf.Config["Groups"] .= "|" sGroup
            this.mTreeItems[sGroup] := Map("Head", this.gTree.Add(sGroup))
        }
    }
    ; Delete group from TreeView Menu
    MenuDeleteGroup(sItem, iItem, oMenu) {  ; Delete Group if group selected
        sGroupID   := this.sTreeCtxMenuTargetItem
        sGroupName := this.gTree.GetText(sGroupID)
        if MsgBox("Are you sure you want to delete this group!?`n-> " sGroupName
                , "Delete " sGroupName
                , "Owner" this.gGui.Hwnd " "
                . 0x4 | 0x30 | 0x100 | 0x1000) = "No"
            Return 0
        aGroups := StrSplit(this.oConf.Config["Groups"], "|")
        for iIndex, sGroup in aGroups
            if sGroupName = sGroup
                aGroups.RemoveAt iIndex
        sGroupConfValue := ""
        for sGroup in aGroups {
            sGroupConfValue .= sGroup
            if A_Index != aGroups.Length
                sGroupConfValue .= "|"
        }
        this.oConf.Config["Groups"] := sGroupConfValue
        this.gTree.Delete(sGroupID)
        for sItemName, sItemID in this.mTreeItems[sGroupName]
            if sItemName != "Head"
                this.mTreeItems["General"][sItemName] :=
                    this.gTree.Add(ParseTimestampFromFileName(sItemName)
                                 , this.mTreeItems["General"]["Head"])
        this.mTreeItems.Delete(sGroupName)
        this.oNotes.MergeGroup(sGroupName, "General")
        Return sGroupName
    }
}


Class ScritchEventSink {
    static cGuiParentClass := {}
    ;   GUI <_CLOSE_>
    static Gui_Close(gMainObj, *) {
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "^\d\d/.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        ; cGui.gBGGui.Destroy
        ; gMainObj.Destroy
        ExitApp
    }
    ;   BTNDESTROY <_CLICK_>
    static BtnDestroy_Click(gCtrl, *) {
        cGui := this.cGuiParentClass
        selectedText := cGui.gTree.GetText(cGui.gTree.GetSelection())
        if selectedText ~= "^\d\d/.*"
            for oNote in cGui.oNotes.aNotes
                if selectedText = oNote.sTimestamp
                    cGui.SaveEditToNote oNote
        cGui.gBGGui.Hide
        gCtrl.Gui.Hide
        ; cGui.gBGGui.Destroy
        ; gCtrl.Gui.Destroy
        ExitApp
    }
    ;   TREE <_ITEMSELECT_>
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
    ;   TREE <_CONTEXTMENU_>
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
    sNotesDir := "\scritches"
    sNotesConf := "\notes.conf"
    aNotes := []

    __New(sScritchWorkingDir) {
        this.sNotesConf := sScritchWorkingDir this.sNotesConf
        this.sNotesDir  := sScritchWorkingDir this.sNotesDir
        if not InStr(FileExist(this.sNotesDir), "D")
            DirCreate this.sNotesDir
        Loop Files (this.sNotesDir "\*.note") {
            sTimestamp := ParseTimestampFromFileName(A_LoopFileName)
            sGroup := IniRead(this.sNotesConf
                            , StrSplit(A_LoopFileName, ".")[1]
                            , "Group", "General")
            oNote := ScritchNotes.Note(A_LoopFileName, sTimestamp, sGroup)
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
        notePath := this.sNotesDir "\" oNote.sFileName
        noteExists := FileExist(notePath)
        if noteExists
            FileDelete notePath
        FileAppend(sContent, notePath, "UTF-8")
        ;oNoteFile := FileOpen(notePath, "w", "utf-8")
        ;oNoteFile.Write(sContent)
        ;oNoteFile.Close
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

    NewNote(sFileName:="", sTimestamp:="", sGroup:="") {
        oNewNote := ScritchNotes.Note(sFileName, sTimestamp, sGroup)
        this.aNotes.Push oNewNote
        FileAppend "", this.sNotesDir "\" oNewNote.sFileName, "UTF-8"
        this.UpdateConf
        Return oNewNote
    }

    MergeGroup(sDissolvedGroup, sAppendedGroup) {
        for oNote in this.aNotes
            if oNote.sGroup = sDissolvedGroup {
                oNote.sGroup := sAppendedGroup
                IniWrite oNote.sGroup, this.sNotesConf
                       , oNote.sFileNameNoExt, "Group"
            }
    }

    DeleteNote(sTimestamp:="") {
        for iIndex, oNote in this.aNotes
            if oNote.sTimestamp = sTimestamp {
                FileDelete this.sNotesDir "\" oNote.sFileName
                IniDelete this.sNotesConf, oNote.sFileNameNoExt
                this.aNotes.RemoveAt iIndex
            }
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
    static sScritchWorkingDir := ""
    __New(sScritchWorkingDir) {
        ScritchConf.sScritchWorkingDir := sScritchWorkingDir
        if !IsFile(sScritchWorkingDir "\Scritch.conf")
            FileAppend "", sScritchWorkingDir "\Scritch.conf", "UTF-8"
        if IniRead(sScritchWorkingDir "\Scritch.conf", "Config", "Groups", 0) = 0
            IniWrite("General", sScritchWorkingDir "\Scritch.conf", "Config", "Groups")
    }

    __Get(sName, aParams) {
        for vParam in aParams
            if IsAlnum(vParam)
                Return IniRead(ScritchConf.sScritchWorkingDir "\Scritch.conf", sName, vParam, 0)
    }

    __Set(sName, aParams, vValue) {
        for vParam in aParams
            if IsAlnum(StrReplace(vParam, A_Space, "")) and !IsObject(vValue) {
                ; FileAppend vValue "`n`t" ScritchConf.sScritchWorkingDir "\Scritch.conf" "`n`t" sName "`n`t" vParam, "*"
                IniWrite vValue, ScritchConf.sScritchWorkingDir "\Scritch.conf", sName, vParam
                Return IniRead(ScritchConf.sScritchWorkingDir "\Scritch.conf", sName, vParam, 0)
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
_Debug_ClearNotes(sScritchWorkingDir) {
    if IsFile(sScritchWorkingDir "\scritches\*.note")
        FileDelete sScritchWorkingDir "\scritches\*.note"
    if IsFile(sScritchWorkingDir "\notes.conf")
        FileDelete sScritchWorkingDir "\notes.conf"
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
        FileAppend tNote.sFileName       "`n"
                 . "`t" tNote.sTimestamp "`n"
                 . "`t" tNote.sGroup     "`n"
                 , "*"
                 , "UTF-8"
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

    testScritchGui := ScritchGui(A_ScriptDir, True)
    Hotkey "<#v", ObjBindMethod(testScritchGui, "ToggleGui")
}
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  IF DEBUGGING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
