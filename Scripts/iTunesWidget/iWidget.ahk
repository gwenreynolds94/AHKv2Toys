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
        ComObjConnect(this.app, iTunesApplication.iCOMEventSink)
    }
    __Delete() {
        ComObjConnect(this.app)
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
        static guiApp := {}
        static OnPlayerPlayEvent(IITTrack, iTunesApp) {
            this.guiApp.UpdateCurrentTrack
        }
    }
}

Class iWidgetGui {
    winName := "iTunes Widget"
        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Gui Options ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        , guiOpts   := "-Caption +AlwaysOnTop"
        , guiMargin := 10
        , guiColor := "7d94c3"
        , guiSize   := { 
                w: 300 + this.guiMargin*2
              , h: 420 + this.guiMargin*2
          }
        , guiShowOpts := "w" this.guiSize.w " "
                       . "h" this.guiSize.h
        ;:;:;:;:;:;:;:;:;:;:;:;:; Current Art Options ;:;:;:;:;:;:;:;:;:;:;:;:;:
        , currentArtSize := this.guiSize.w - this.guiMargin*2
        , currentArtPos := {
              x: this.guiSize.w/2 - this.currentArtSize/2
            , y: this.guiMargin
          }
        ;:;:;:;:;:;:;:;:;:;:;:; Player Controls Options ;:;:;:;:;:;:;:;:;:;:;:;:
        , controlBtnSize  := 24
        , controlAreaSize := {
              w: 200
            , h: this.controlBtnSize + this.guiMargin*2
          }
        , controlArea := { 
              x: this.guiSize.w/2 - this.controlAreaSize.w/2
            , y: this.guiSize.h - this.controlAreaSize.h - 2
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
        ;:;:;:;:;:;:;:;:;:;:;: Current Track Info Options ;:;:;:;:;:;:;:;:;:;:;:
        , currentTrackInfoLineHeight := 14
        , currentTrackNameDims := {
              x: 0
            , y: this.controlArea.y - this.currentTrackInfoLineHeight*3
            , w: this.guiSize.w
            , h: this.currentTrackInfoLineHeight
          }
        , currentTrackAlbumDims := {
              x: 0
            , y: this.currentTrackNameDims.y + this.currentTrackInfoLineHeight
            , w: this.guiSize.w
            , h: this.currentTrackInfoLineHeight
        }
        , currentTrackArtistDims := {
              x: 0
            , y: this.currentTrackAlbumDims.y + this.currentTrackInfoLineHeight
            , w: this.guiSize.w
            , h: this.currentTrackInfoLineHeight
        }
        ;:;:;:;:;:;:;:;:;:;:;:;:;:; Options Strings ;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        , currentArtOpts   := "x" this.currentArtPos.x " "
                            . "y" this.currentArtPos.y " "
                            . "w" this.currentArtSize  " "
                            . "h" this.currentArtSize
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
        , currentTrackNameOpts   := "x" this.currentTrackNameDims.x " "
                                  . "y" this.currentTrackNameDims.y " "
                                  . "w" this.currentTrackNameDims.w " "
                                  . "h" this.currentTrackNameDims.h " "
                                  . "Center 0x80"
        , currentTrackAlbumOpts  := "x" this.currentTrackAlbumDims.x " "
                                  . "y" this.currentTrackAlbumDims.y " "
                                  . "w" this.currentTrackAlbumDims.w " "
                                  . "h" this.currentTrackAlbumDims.h " "
                                  . "Center 0x80"
        , currentTrackArtistOpts := "x" this.currentTrackArtistDims.x " "
                                  . "y" this.currentTrackArtistDims.y " "
                                  . "w" this.currentTrackArtistDims.w " "
                                  . "h" this.currentTrackArtistDims.h " "
                                  . "Center 0x80"
        , currentTrackInfoFontOpts := "s8"
        , currentTrackInfoFontName := "Fira Code"
        , currentTrackNameFontOpts := this.currentTrackInfoFontOpts " bold"

    __New() {
        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Main Gui ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
        this.gui           := Gui(this.guiOpts, this.winName, iWidgetGui.iGuiEventSink)
        this.gui.MarginX   := this.gui.MarginY := 0
        this.gui.BackColor := this.guiColor

        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Current Art ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        this.currentArt := this.gui.Add("Picture"
                                      , this.currentArtOpts
                                      , A_ScriptDir "\resources\currentTrack.jpg")
        this.currentArt.OnEvent("Click", "CurrentArt_Click")

        ;:;:;:;:;:;:;:;:;:;:;:;:;: Current Track Info ;:;:;:;:;:;:;:;:;:;:;:;:;:
        this.currentTrackName   := this.gui.Add("Text"
                                              , this.currentTrackNameOpts, "")
        this.currentTrackAlbum  := this.gui.Add("Text"
                                              , this.currentTrackAlbumOpts, "")
        this.currentTrackArtist := this.gui.Add("Text"
                                              , this.currentTrackArtistOpts, "")
        this.currentTrackName.SetFont(this.currentTrackNameFontOpts
                                    , this.currentTrackInfoFontName)
        this.currentTrackAlbum.SetFont(this.currentTrackInfoFontOpts
                                     , this.currentTrackInfoFontName)
        this.currentTrackArtist.SetFont(this.currentTrackInfoFontOpts
                                      , this.currentTrackInfoFontName)
        
        ;:;:;:;:;:;:;:;:;:;:;:;:;:; Player Controls ;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        this.prevBtn      := this.gui.Add("Picture"
                                        , this.prevBtnOpts     
                                        , A_ScriptDir "\resources\highres\prev.png")
        this.playPauseBtn := this.gui.Add("Picture"
                                        , this.playPauseBtnOpts
                                        , A_ScriptDir "\resources\highres\playPause.png")
        this.nextBtn      := this.gui.Add("Picture"
                                        , this.nextBtnOpts     
                                        , A_ScriptDir "\resources\highres\next.png")

             this.prevBtn.OnEvent("Click", "PrevBtn_Click")
        this.playPauseBtn.OnEvent("Click", "PlayPauseBtn_Click")
             this.nextBtn.OnEvent("Click", "NextBtn_Click")

        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Show Gui ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
        this.gui.Show this.guiShowOpts

        ;:;:;:;:;:;:;:;: Initialize iTunesApplication instance ;:;:;:;:;:;:;:;:;
        ;:;:;:;:;:;:;:;: and static references for event sinks ;:;:;:;:;:;:;:;:;
        this.iTunes := iTunesApplication()
        iWidgetGui.iGuiEventSink.iTunes := this.iTunes
        iWidgetGui.iGuiEventSink.guiApp := this
        iTunesApplication.iCOMEventSink.guiApp := this

        ;:;:;:;:;:;:;:;:; Load track info and current artwork ;:;:;:;:;:;:;:;:;:
        this.UpdateCurrentTrack
    }

    ;:;:;:;:;:; Get and set name, album, and artist of current track ;:;:;:;:;:;
    SetCurrentTrackInfo() {
        currentTrackName := this.iTunes.app.CurrentTrack.Name
        currentTrackAlbum := this.iTunes.app.CurrentTrack.Album
        currentTrackArtist := this.iTunes.app.CurrentTrack.Artist
        if StrLen(currentTrackName) >= 39
            currentTrackName := SubStr(currentTrackName, 1, 36) "..."
        if StrLen(currentTrackAlbum) >= 39
            currentTrackAlbum := SubStr(currentTrackAlbum, 1, 36) "..."
        if StrLen(currentTrackArtist) >= 39
            currentTrackArtist := SubStr(currentTrackArtist, 1, 36) "..."
        this.currentTrackName.Value := currentTrackName
        this.currentTrackAlbum.Value := currentTrackAlbum
        this.currentTrackArtist.Value := currentTrackArtist
    }

    ;:;:;:;:;:;:;:;: Get and set current track info and artwork ;:;:;:;:;:;:;:;:
    UpdateCurrentTrack() {
        this.iTunes.SaveCurrentArtwork
        Sleep 25
        this.SetCurrentTrackInfo
        this.currentArt.Value := A_ScriptDir "\resources\currentTrack.jpg"
    }

    Show() {
        
    }

    Class iGuiEventSink {
        static iTunes := {}, guiApp := {}
        ;:;:;:;:;:;:;:;:;:;: Previous Track Player Control ;:;:;:;:;:;:;:;:;:;:;
        static PrevBtn_Click(gCtrl, *) {
            gCtrl.Value := A_ScriptDir "\resources\highres\prevClick.png"
            this.iTunes.Prev()
            this.guiApp.UpdateCurrentTrack
            gCtrl.Value := A_ScriptDir "\resources\highres\prev.png"
        }
        ;:;:;:;:;:;:;:;:;:;:;: Next Track Player Control ;:;:;:;:;:;:;:;:;:;:;:;
        static NextBtn_Click(gCtrl, *) {
            gCtrl.Value := A_ScriptDir "\resources\highres\nextClick.png"
            this.iTunes.Next()
            this.guiApp.UpdateCurrentTrack
            gCtrl.Value := A_ScriptDir "\resources\highres\next.png"
        }
        ;:;:;:;:;:;:;:;:;:;:;: Play/Pause Player Control ;:;:;:;:;:;:;:;:;:;:;:;
        static PlayPauseBtn_Click(gCtrl, *) {
            gCtrl.Value := A_ScriptDir "\resources\highres\playPauseClick.png"
            this.iTunes.PlayPause()
            this.guiApp.UpdateCurrentTrack
            gCtrl.Value := A_ScriptDir "\resources\highres\playPause.png"
        }
    }
}


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
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
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;