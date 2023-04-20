
Class VolChangeGui {
    ; @prop {Gui} gui
    Static gui := {}
        ; @prop {Gui.Control} prog
        , prog := {}
        ; @prop {Object} size
        , size := { w: 25, h: A_ScreenHeight }
        ; @prop {Object} pos
        , pos := { x: A_ScreenWidth - 25, y: 0 }
        ; @prop {Boolean} init
        , init := False
        ; @prop {Boolean} hidden
        , hidden := True
        ; @prop {BoundFunc} BFHide
        , BFHide := {}
        ; @prop {BoundFunc} BFAnimHide
        , BFAnimHide := {}
        ; @prop {Object} AW
        , AW := { ACTIVATE: 0x00020000             ; ;
                ,     HIDE: 0x00010000             ; ;
                ,    SLIDE: 0x00040000             ; ;
                ,    BLEND: 0x00080000             ; ;
                ,      HOR: { NEGATIVE: 0x00000002 ; ;
                            , POSITIVE: 0x00000001 } }
        ; @prop {Integer} AnimMS
        , AnimMS := 150
        , active_color := "C862d2d"
        , inactive_color := "C602d2d"
    Static __New() {
        this.gui := Gui("-Caption +Owner +AlwaysOnTop",
                        "AHKVolumeChangeGui")
        this.gui.MarginX := this.gui.MarginY := 0
        ; this.prog := this.gui.Add("Progress", "Smooth Vertical Range0-100 C0C2B27 BackgroundAAAAAA " .
        this.prog := this.gui.Add("Progress", "Smooth"           . " " .
                                              "Vertical"         . " " .
                                              "Range0-100"       . " " .
                                              "w" this.size.w    . " " .
                                              "h" this.size.h    . " " .
                                              "BackgroundAAAAAA" . " " .
                                              this.active_color)
        this.BFHide := ObjBindMethod(this, "Hide")
        this.BFAnimHide := ObjBindMethod(this, "AnimateHide")
    }
    Static Show() {
        this.prog.Value := Round(SoundGetVolume())
        this.UpdateMuteStatus()
        if (this.hidden) {
            _showParam := (this.init) ? "NA" : ("NA x" ((this.init:=True)*this.pos.x) " y" this.pos.y)
            this.gui.Show(_showParam)
            WinSetTransColor("AAAAAA 225", this.gui)
            this.hidden := False
        }
        ; SetTimer(this.BFHide, -1000)
        SetTimer(this.BFHide, -2000)
    }
    Static Hide(*) {
        this.gui.Hide()
        this.hidden := True
        SetTimer(,0)
    }
    Static UpdateMuteStatus(*) {
        if !!SoundGetMute()
            this.prog.Opt(this.inactive_color)
        else this.prog.Opt(this.active_color)
    }
    Static AnimateShow(*) {
        this.prog.Value := Round(SoundGetVolume())
        this.UpdateMuteStatus()
        if (this.hidden) {
            ; _showParam := (this.init) ? "NA" : ("NA x" ((this.init:=True)*this.pos.x) " y" this.pos.y)
            _showParam := "NA x" (this.pos.x) " y" this.pos.y
                        . ((this.init) ? " Hide" : (this.init:=True, ""))
            this.hidden := False
            this.gui.Show(_showParam)
            DllCall( "AnimateWindow", "Ptr", this.gui.Hwnd
                                    , "Int", this.AnimMS
                                    , "UInt", this.AW.ACTIVATE|this.AW.HOR.POSITIVE|this.AW.SLIDE )
            WinSetTransColor("AAAAAA 225", this.gui)
        }
        ; SetTimer(this.BFHide, -1000)
        SetTimer(this.BFAnimHide, -500)
    }
    Static AnimateHide(*) {
        SetTimer (*)=>(this.hidden:=True), -(this.AnimMS+50)
        DllCall( "AnimateWindow", "Ptr", this.gui.Hwnd
                                , "Int", this.AnimMS
                                , "UInt", this.AW.HIDE|this.AW.HOR.NEGATIVE|this.AW.SLIDE )
    }
}
