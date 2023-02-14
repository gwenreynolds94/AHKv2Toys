#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: if current script ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
if (A_ScriptName="ConvertImageToIcon.ahk") {
    if !gdip_token:=Gdip_Startup() {
        MsgBox "Gdi+ failed to start."
        ExitApp
    }
    OnExit (*)=> Gdip_Shutdown(gdip_token)
    HotKey "F8", (*)=>ExitApp()
    itiGui := ITI_Gui()
    Gdip_Shutdown(gdip_token)
}
;:;:;:;:;:;:;:;:;:;:;:;:;:;: END if current script ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


ImageToIcon_Convert(sourceImg, targetIco:="") {
    SplitPath sourceImg,, &_fileInDirectory,, &_fileInName
    if targetIco
        SplitPath targetIco,, &_fileOutDirectory,, &_fileOutName
    else _fileOutDirectory:=_fileInDirectory, _fileOutName:=_fileInName
    if !(FileExist(sourceImg) ~= "A|N") {
        MsgBox sourceImg " did not point to a file."
        Return 0
    }
    if !InStr(FileExist(_fileOutDirectory), "D") {
        MsgBox "Could not retrieve a valid directory from: " _fileOutDirectory
        Return 0
    }
    _hBitmap := Gdip_CreateBitmapFromFile(sourceImg)
    _hIcon := Gdip_CreateHICONFromBitmap(_hBitmap)
    _result := Gdip_SaveHICONToFile( _hIcon
                                   , _fileOutDirectory "\" _fileOutName ".ico" )
    DestroyIcon(_hIcon)
    Gdip_DisposeImage(_hBitmap)
    Return _result
}

ImageToIcon_QuickPick() {
    originImg := FileSelect( 1,
            , "Choose Image To Convert"
            , "Images (*.png; *.jpg; *.jpeg; *.bmp"
              . "; *.gif; *.tiff; *.exif; *.wmf; *.emf)" )    
    if originImg {
        targetIco := FileSelect( 16,, "Choose Ico Destination")
        if targetIco
            Return ImageToIcon_Convert(originImg, targetIco)
        MsgBox "Invalid target path"
        Return 0
    }
    MsgBox "Invalid source path"
    Return 0
}

Class ITI_Gui {
    ; Gui Colors
    guiBrushes := [
        "lightPrimary",   0xFFCDE3C9
      , "lightSecondary", 0xFF95CD83
      , "lightTertiary",  0xFF82B571
      , "midPrimary",     0xFF89AC88
      , "midSecondary",   0xFF6FB964
      , "midTertiary",    0xFF779A76
      , "darkPrimary",    0xFF303C24
      , "darkSecondary",  0xFF444943
      , "darkTertiary",   0xFF495D45
    ]

    __New(cgDEF:="") {
        guiDEF := {
            w: 650, h: 150+50
          , fontOpts: "s8"
          , font: "Fira Code"
          , edge: { thickness: 6, color: "darkTertiary" }
          , color: "midPrimary"
          , bRadius: 25
          , padBM: 2
        }
        guiDEF.x := A_ScreenWidth/2  - guiDEF.w/2
        guiDEF.y := A_ScreenHeight/2 - guiDEF.h/2
        if IsObject(cgDEF) and HasProp(cgDEF, "w") and HasProp(cgDEF, "h")
            for DEFprop in cgDEF.OwnProps()
                guiDEF.%DEFprop% := cgDEF.%DEFprop%

        this.gui := Gui("-Caption +OwnDialogs")
        this.gui.BackColor := "444940"
        WinSetTransColor("444940", this.gui)
        this.gui.def := guiDEF
        this.gui.SetFont(this.gui.def.fontOpts, this.gui.def.font)
        this.gui.OnEvent("Close", ObjBindMethod(this, "Gui_Close"))

        this.bgImage := this.gui.Add( "Picture"
                                    , "x0 y0"            " "
                                    . "w" this.gui.def.w " "
                                    . "h" this.gui.def.h " "
                                    . "0xE")
        this.source := ITI_Gui.PathCtrls(
            this.gui, "Source"
            , [ 1
              , ""
              , "Choose Image To Convert"
              , "Images (*.png; *.jpg; *.jpeg; *.bmp"
                . "; *.gif; *.tiff; *.exif; *.wmf; *.emf)" ]
            , { x: 35
              , y: 36+50
              , w: 400
              , pad: 4
              , innerColor: "midPrimary"
              , outerColor: "midTertiary"
              , bRadius: 10
              , boxGap: 8
              , bThick: 3 }
            , { w: 100 }
        )
        this.target := ITI_Gui.PathCtrls(
            this.gui, "Target"
            , [ 16, "", "Choose .ico Destination", "Icons (*.ico)" ]
            , { x: this.gui.def.w-400-35-100-4
              , y: 94+50
              , w: 400
              , pad: 4
              , innerColor: "midPrimary"
              , outerColor: "midTertiary"
              , bRadius: 10
              , boxGap: 8
              , bThick: 3 }
            , { w: 100 }
        )

        this.gui.Show( "x" guiDEF.x  " y" guiDEF.y  " "
                     . "w" guiDEF.w  " h" guiDEF.h  " "
                     . "NA" )
        this.PaintGui()

        HotIf (*)=> WinActive("ahk_id " this.gui.Hwnd)
        Hotkey "Enter", ObjBindMethod(this, "ConvertImage")
        HotIf
    }
    Gui_Close(gObj) {
        ExitApp
    }
    ConvertImage(*) {
        if this.source.selected_file && this.target.selected_file
            if ImageToIcon_Convert( this.source.selected_file
                                  , this.target.selected_file )
                ExitApp
    }

    PaintGui() {
        def := this.gui.def

        pgBM := Gdip_CreateBitmap(def.w, def.h)
        gGfx := Gdip_GraphicsFromImage(pgBM)
        Gdip_SetSmoothingMode(gGfx, 0)
        brushes := ITI_Gui.Brushes( this.guiBrushes* )

        ; Main Outer Rect
        Gdip_FillRoundedRectangle( gGfx, brushes.%def.edge.color%
                                 , def.padBM, def.padBM
                                 , oW:=(def.w - def.padBM*2)
                                 , oH:=(def.h - def.padBM*2)
                                 , def.bRadius                    )
        Gdip_SetSmoothingMode(gGfx, 2)
        ; Main Inner Rect
        Gdip_FillRoundedRectangle( gGfx, brushes.%def.color%
                                 , def.padBM + def.edge.thickness
                                 , def.padBM + def.edge.thickness
                                 , oW - def.edge.thickness*2
                                 , oH - def.edge.thickness*2
                                 , def.bRadius                    )
        ; Source Edit/Btn Box
        seDEF := this.source.edit.def
        sbDEF := this.source.btn.def
        src   := {
            outer: {
                x: seDEF.x-seDEF.boxGap-seDEF.bThick
              , y: seDEF.y-seDEF.boxGap-seDEF.bThick
              , w: seDEF.w + sbDEF.w + seDEF.pad
                   + seDEF.boxGap*2 + seDEF.bThick*2
              , h: seDEF.h + seDEF.boxGap*2 + seDEF.bThick*2
            }
          , inner: {
                x: seDEF.x-seDEF.boxGap
              , y: seDEF.y-seDEF.boxGap
              , w: seDEF.w + sbDEF.w + seDEF.pad + seDEF.boxGap*2
              , h: seDEF.h + seDEF.boxGap*2
          }
        }
        Gdip_FillRoundedRectangle( gGfx, brushes.%seDEF.outerColor%
                                 , src.outer.x, src.outer.y
                                 , src.outer.w, src.outer.h
                                 , seDEF.bRadius)
        Gdip_FillRoundedRectangle( gGfx, brushes.%seDEF.innerColor%
                                 , src.inner.x, src.inner.y
                                 , src.inner.w, src.inner.h
                                 , seDEF.bRadius)

        ; Target Edit/Btn Box
        teDEF := this.target.edit.def
        tbDEF := this.target.btn.def
        tgt   := {
            outer: {
                x: teDEF.x-teDEF.boxGap-teDEF.bThick
              , y: teDEF.y-teDEF.boxGap-teDEF.bThick
              , w: teDEF.w + tbDEF.w + teDEF.pad
                   + teDEF.boxGap*2 + teDEF.bThick*2
              , h: teDEF.h + teDEF.boxGap*2 + teDEF.bThick*2
            }
          , inner: {
                x: teDEF.x-teDEF.boxGap
              , y: teDEF.y-teDEF.boxGap
              , w: teDEF.w + tbDEF.w + teDEF.pad + teDEF.boxGap*2
              , h: teDEF.h + teDEF.boxGap*2
          }
        }
        Gdip_FillRoundedRectangle( gGfx, brushes.%teDEF.outerColor%
                                 , tgt.outer.x, tgt.outer.y
                                 , tgt.outer.w, tgt.outer.h
                                 , teDEF.bRadius)
        Gdip_FillRoundedRectangle( gGfx, brushes.%teDEF.innerColor%
                                 , tgt.inner.x, tgt.inner.y
                                 , tgt.inner.w, tgt.inner.h
                                 , teDEF.bRadius)

        if !Gdip_FontFamilyCreate(titleFont:="JetBrains Mono")
            titleFont := "Arial"
        titleFontOptions := "x24 y28 w80p h30 cff526f49 r4 s20 Bold"
        Gdip_TextToGraphics( gGfx, "Convert Image to .ico"
                           , titleFontOptions, titleFont, def.w, def.h)
        
        hgBM := Gdip_CreateHBITMAPFromBitmap(pgBM)
        SetImage(this.bgImage.Hwnd, hgBM)

        brushes.BurnEm()
        Gdip_DeleteGraphics(gGfx)
        Gdip_DisposeImage(pgBM)
        DeleteObject(hgBM)

        for ctrl in this.gui
            ctrl.Redraw()
    }

    Class Brushes {
        _colorMap := 0, _brushNames := []
        __New(_palette*) {
            if Mod(_palette.Length, 2)
                _palette.Pop()
            if _palette.Length > 0
                this._colorMap := Map(_palette*)
            else Return
            this.CreateBrushes()
        }
        __Delete() {
            this.BurnEm()
        }
        NewBrush(_bName, _bColor) {
            this._brushNames.Push(_bName)
            this.%_bName% := Gdip_BrushCreateSolid(_bColor)
        }
        CreateBrushes() {
            for bName, bColor in this._colorMap
                this.NewBrush(bName, bColor)
        }
        BurnEm() {
            for bIndex, bName in this._brushNames
                Gdip_DeleteBrush(this.%bName%)
        }
    }

    Class PathCtrls {
        selected_file := ""
        __New(pGui, sName, fsOpts:=[], ceDEF:="", cbDEF:="") {
            editDEF := { x: 0
                       , y: 50
                       , w: 400
                       , h: 20
                       , pad: 4
                       , name: sName
                       , innerColor: "lightSecondary"
                       , outerColor: "lightPrimary"
                       , boxGap: 4
                       , bThick: 3
                       , bRadius: 5  }
            this.MergeDEFProp( editDEF, ceDEF
                             , "x", "y", "w", "h", "pad", "bRadius", "boxGap"
                             , "innerColor", "outerColor", "bThick" )

            btnDEF  := { x: 0
                       , y: editDEF.y
                       , w: 100
                       , h: editDEF.h
                       , pad: editDEF.pad
                       , name: sName
                       , innerColor: editDEF.innerColor
                       , outerColor: editDEF.outerColor
                       , boxGap: editDEF.boxGap
                       , bThick: editDEF.bThick
                       , bRadius: editDEF.bRadius }
            this.MergeDEFProp(btnDEF, cbDEF, "w", "h", "y")
            
            editDEF.x := pGui.def.w/2 - (editDEF.w+btnDEF.w+editDEF.pad)/2
            this.MergeDEFProp(editDEF, ceDEF, "x")

            btnDEF.x := editDEF.x + editDEF.w + editDEF.pad
            this.MergeDEFProp(btnDEF, cbDEF, "x")

            editOptStr := "x" editDEF.x " y" editDEF.y " "
                        . "w" editDEF.w " h" editDEF.h " "
                        . "-Wrap +ReadOnly -TabStop"   " "
                        . "v" sName "Edit"
            btnOptStr  := "x" btnDEF.x  " y" btnDEF.y  " "
                        . "w" btnDEF.w  " h" btnDEF.h  " "
                        . "-TabStop"                   " "
                        . "v" sName "Btn"

            this.fileSelectOpts := fsOpts
            this.edit := pGui.Add("Edit", editOptStr, "...")
            this.edit.def := editDEF
            this.btn  := pGui.Add("Button", btnOptStr, sName)
            this.btn.def  := btnDEF
            this.btn.OnEvent("Click", ObjBindMethod(this, "Btn_Click"))
        }
        Btn_Click(gCtrl, *) {
            this.selected_file := FileSelect(this.fileSelectOpts*)
            if this.selected_file
                this.edit.Value := this.selected_file
        }
        MergeDEFProp(ogDEF, newDEF, changeProps*) {
            if IsObject(newDEF)
                for _index, _prop in changeProps
                    if HasProp(newDEF, _prop)
                        ogDEF.%_prop% := newDEF.%_prop%
        }
    }
}


#Include ..\..\Lib\GdipLib\Gdip_Custom.ahk