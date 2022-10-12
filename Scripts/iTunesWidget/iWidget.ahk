#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib
#Include DBT.ahk

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END Directives ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:



;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
if A_ScriptName = "iWidget.ahk"
     ISMAIN := True
else ISMAIN := False
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;



;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: Constants ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
Null := 0

ITPlaylistKind := Map(
    "Unknown"       , 0     ; ITPlaylistKindUnknown
  , "Library"       , 1     ; ITPlaylistKindLibrary
  , "User"          , 2     ; ITPlaylistKindUser
  , "CD"            , 3     ; ITPlaylistKindCD
  , "Device"        , 4     ; ITPlaylistKindDevice
  , "RadioTuner"    , 5     ; ITPlaylistKindRadioTuner
)

ITArtworkFormat := Map(
    "Unknown"   , 0     ; ITArtworkFormatUnknown
  , "jpg"       , 1     ; ITArtworkFormatJPEG
  , "png"       , 2     ; ITArtworkFormatPNG
  , "bmp"       , 3     ; ITArtworkFormatBMP
)
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END Constants ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

Class iTunesApplication {
    /** @prop {iTunesApp} app - iTunes.Application ComObject */
    app := {}
    __New() {
        this.app := ComObject("iTunes.Application")
    }
    PlayPause() {
        this.app.PlayPause
    }
    Next() {
        this.app.NextTrack
    }
    Prev() {
        this.app.PreviousTrack
    }
    SaveCurrentArtwork() {
        Loop Files, A_Scriptdir "\resources\currentTrack.*" {
            FileDelete A_LoopFileFullPath
        }
        artwork := this.app.CurrentTrack.Artwork[1]
        for fmtName, fmtID in ITArtworkFormat
            if fmtID = artwork.Format
                artwork.SaveArtworkToFile A_ScriptDir "\resources\currentTrack." fmtName
    }
    Class iCOMEventSink {
        
    }
}

Class iWidgetGui {
    winName := "iTunes Widget"
        , guiOpts   := "-Caption +AlwaysOnTop"
        , guiMargin := 10
        , guiSize   := { 
                w: 300 + this.guiMargin*2
              , h: 200 + this.guiMargin*2
          }
        , guiShowOpts := "w" this.guiSize.w " "
                       . "h" this.guiSize.h
        , controlBtnSize  := 20
        , controlAreaSize := {
              w: 200
            , h: this.controlBtnSize + this.guiMargin*2
          }
        , controlArea := { 
              x: this.guiSize.w/2 - this.controlAreaSize.w/2
            , y: this.guiSize.h - this.controlAreaSize.h - this.guiMargin
            , w: this.controlAreaSize.w
            , h: this.controlAreaSize.h 
          }
        , controlGap  := (this.controlArea.w - this.controlBtnSize*3)/2
        , prevBtnDims := { 
                x: this.controlArea.x
              , y: this.controlArea.y + (this.controlArea.h/2) - (this.controlBtnSize/2)
              , w: this.controlBtnSize
              , h: this.controlBtnSize 
          }
        , playPauseBtnDims := { 
                x: this.prevBtnDims.x + this.prevBtnDims.w + this.controlGap
              , y: this.prevBtnDims.y
              , w: this.controlBtnSize
              , h: this.controlBtnSize 
          }
        , nextBtnDims := { 
                x: this.playPauseBtnDims.x + this.playPauseBtnDims.w + this.controlGap
              , y: this.playPauseBtnDims.y
              , w: this.controlBtnSize
              , h: this.controlBtnSize
          }
        , prevBtnOpts      := "x" this.prevBtnDims.x " "
                            . "y" this.prevBtnDims.y " "
                            . "w" this.prevBtnDims.w " "
                            . "h" this.prevBtnDims.h
        , playPauseBtnOpts := "x" this.playPauseBtnDims.x " "
                            . "y" this.playPauseBtnDims.y " "
                            . "w" this.playPauseBtnDims.w " "
                            . "h" this.playPauseBtnDims.h
        , nextBtnOpts      := "x" this.nextBtnDims.x " "
                            . "y" this.nextBtnDims.y " "
                            . "w" this.nextBtnDims.w " "
                            . "h" this.nextBtnDims.h

    __New() {
        this.gui          := Gui(this.guiOpts, this.winName, iWidgetGui.iGuiEventSink)
        this.gui.MarginX  := this.gui.MarginY := 0

        

        this.prevBtn      := this.gui.Add("Picture", this.prevBtnOpts     , A_ScriptDir "\resources\highres\prev.png")
        this.playPauseBtn := this.gui.Add("Picture", this.playPauseBtnOpts, A_ScriptDir "\resources\highres\playPause.png")
        this.nextBtn      := this.gui.Add("Picture", this.nextBtnOpts     , A_ScriptDir "\resources\highres\next.png")

        this.gui.Show this.guiShowOpts

        this.prevBtn.OnEvent("Click", "PrevBtn_Click")
        this.playPauseBtn.OnEvent("Click", "PlayPauseBtn_Click")
        this.nextBtn.OnEvent("Click", "NextBtn_Click")

        this.iTunes := iTunesApplication()
        iWidgetGui.iGuiEventSink.iTunes := this.iTunes
    }

    Show() {
    }

    Class iGuiEventSink {
        static iTunes := {}
        static PrevBtn_Click(gCtrl, *) {
            ; this.iTunes.Prev()
            this.iTunes.SaveCurrentArtwork
            gCtrl.Value := A_ScriptDir "\resources\highres\prevClick.png"
            SetTimer (*)=> gCtrl.Value := A_ScriptDir "\resources\highres\prev.png", -175
        }
        static NextBtn_Click(gCtrl, *) {
            this.iTunes.Next()
            gCtrl.Value := A_ScriptDir "\resources\highres\nextClick.png"
            SetTimer (*)=> gCtrl.Value := A_ScriptDir "\resources\highres\next.png", -175
        }
        static PlayPauseBtn_Click(gCtrl, *) {
            this.iTunes.PlayPause()
            gCtrl.Value := A_ScriptDir "\resources\highres\playPauseClick.png"
            SetTimer (*)=> gCtrl.Value := A_ScriptDir "\resources\highres\playPause.png", -175
        }
    }
}



if ISMAIN {

    ; iTunes := iTunesApplication()
    ; iTunes.app.PlayPause

    iGui := iWidgetGui()
    ; SetTimer (*)=> ExitApp(), 2000

    
    Hotkey "F8", (*)=> ExitApp()
    OnExit RunOnExit
    RunOnExit(*) {
        global iTunes := {}
        stdo "...Exiting " A_ScriptName
    }

}
