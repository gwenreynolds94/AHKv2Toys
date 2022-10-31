#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\GdipTest\Gdip_Custom.ahk
#Include ..\Lib\DBT.ahk

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END Directives ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Gdip Startup ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
if !gtoken:=Gdip_Startup(){
    MsgBox "Gdi+ failed to start"
    ExitApp
}
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; END Gdip Startup ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
if A_ScriptName = "iWidget.ahk"
     ISMAIN := True
else ISMAIN := False
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;



;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: Constants ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
Null := 0

ITPlaylistSearchField := Map(
    "All"           , 0     ; ITPlaylistSearchFieldAll
  , "Visible"       , 1     ; ITPlaylistSearchFieldVisible
  , "Artists"       , 2     ; ITPlaylistSearchFieldArtists
  , "Albums"        , 3     ; ITPlaylistSearchFieldAlbums
  , "Composers"     , 4     ; ITPlaylistSearchFieldComposers
  , "SongNames"     , 5     ; ITPlaylistSearchFieldSongNames
)

ITPlaylistKind := Map(
    "Unknown"       , 0     ; ITPlaylistKindUnknown
  , "Library"       , 1     ; ITPlaylistKindLibrary
  , "User"          , 2     ; ITPlaylistKindUser
  , "CD"            , 3     ; ITPlaylistKindCD
  , "Device"        , 4     ; ITPlaylistKindDevice
  , "RadioTuner"    , 5     ; ITPlaylistKindRadioTuner
)

ITArtworkFormat := Map(
    "Unknown"       , 0     ; ITArtworkFormatUnknown
  , "jpg"           , 1     ; ITArtworkFormatJPEG
  , "png"           , 2     ; ITArtworkFormatPNG
  , "bmp"           , 3     ; ITArtworkFormatBMP
)

ITPlayerState := Map(
    "Stopped"        , 0    ; ITPlayerStateStopped
  , "Playing"        , 1    ; ITPlayerStatePlaying
  , "FastForward"    , 2    ; ITPlayerStateFastForward
  , "Rewind"         , 3    ; ITPlayerStateRewind
)
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END Constants ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

Class iTunesApplication {
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
        Loop Files, A_Scriptdir "\resources\images\currentTrack.*" {
            FileDelete A_LoopFileFullPath
        }
        artwork := this.app.CurrentTrack.Artwork[1]
        for fmtName, fmtID in ITArtworkFormat
            if fmtID = artwork.Format
                artwork.SaveArtworkToFile A_ScriptDir
                                            . "\resources\images\currentTrack."
                                            . fmtName
    }
    PlayerState {
        Get {
            currentState := this.app.PlayerState
            for pState, psCode in ITPlayerState
                if currentState=psCode
                    Return pState
        }
        Set {
            if IsAlpha(Value)
                Return this.app.PlayerState := ITPlayerState[Value]
            if IsNumber(Value)
                Return this.app.PlayerState := Value
        }
    }
    Volume {
        Get => this.app.SoundVolume
        Set => this.app.SoundVolume := Value
    }
    TrackPos {
        Get => this.app.PlayerPosition
        Set => this.app.PlayerPosition := Value
    }
    TrackProgress {
        Get => this.app.PlayerPosition / this.app.CurrentTrack.Duration
        Set => this.app.PlayerPosition := this.app.CurrentTrack.Duration*Value
    }
    CurrentTrack => this.app.CurrentTrack
    Class iCOMEventSink {
        static guiApp := {}
        static OnPlayerPlayEvent(IITTrack, iTunesApp) {
            stdo "<OnPlayerPlayEvent>"
            this.guiApp.UpdateCurrentTrack()
        }
        static OnSoundVolumeChangedEvent(newVolume, iTunesApp) {
            stdo "<OnSoundVolumeChangedEvent>"
            if (A_TickCount-this.guiApp.volumeKnobLastSlide) > 100
                this.guiApp.UpdateVolumeSlider(newVolume)
        }
    }
    Class iTrack {
        Name   := ""
        Album  := ""
        Artist := ""
        IDList := ""
        __New(IITTrack) {
            this.Name   := IITTrack.Name
            this.Album  := IITTrack.Album
            this.Artist := IITTrack.Artist
            ; The order of IDList is essential to be able to get COM property
            this.IDList := [ IITTrack.SourceID
                           , IITTrack.PlaylistID
                           , IITTrack.TrackID
                           , IITTrack.TrackDatabaseID ]
        }
        COM[iTunesApp] => iTunesApp.GetITObjectByID(this.IDList*)
    }
}

Class iWidgetGui {
    iTunesPath := "C:\Program Files\iTunes\iTunes.exe"
    winName := "iTunes Widget"
        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Gui Options ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        guiOpts     := "-Caption +AlwaysOnTop"
        guiMargin   := 10
        guiColor    := "b0d0f0"
        guiSize     := { w: 300 + this.guiMargin*2 ;
                       , h: 440 + this.guiMargin*2 }
        guiShowOpts := "w" this.guiSize.w " "
                     . "h" this.guiSize.h
        ;:;:;:;:;:;:;:;:;:;:;:;:; Current Art Options ;:;:;:;:;:;:;:;:;:;:;:;:;:
        currentArtSize := this.guiSize.w - this.guiMargin*2
        currentArtPos  := { x: this.guiSize.w/2      ;
                             - this.currentArtSize/2 ;
                          , y: this.guiMargin        }
        ;:;:;:;:;:;:;:;:;:;:;:; Player Controls Options ;:;:;:;:;:;:;:;:;:;:;:;:
        controlBtnSize  := 24
        controlAreaSize := { w: 200                                    ;
                           , h: this.controlBtnSize + this.guiMargin*2 }
        controlAreaPos  := { x: this.guiSize.w/2         ;
                              - this.controlAreaSize.w/2 ;
                           , y: this.guiSize.h           ;
                              - this.controlAreaSize.h   ;
                              - 2                        }
        controlGap  := (this.controlAreaSize.w - this.controlBtnSize*3)/2
        prevBtnDims := { x: this.controlAreaPos.x      ;
                       , y: this.controlAreaPos.y      ;
                          + (this.controlAreaSize.h/2) ;
                          - (this.controlBtnSize/2)    ;
                       , w: this.controlBtnSize        ;
                       , h: this.controlBtnSize        }
        playPauseBtnDims := { x: this.prevBtnDims.x  ;
                               + this.prevBtnDims.w  ;
                               + this.controlGap     ;
                            , y: this.prevBtnDims.y  ;
                            , w: this.controlBtnSize ;
                            , h: this.controlBtnSize }
        nextBtnDims := { x: this.playPauseBtnDims.x ;
                          + this.playPauseBtnDims.w ;
                          + this.controlGap         ;
                       , y: this.playPauseBtnDims.y ;
                       , w: this.controlBtnSize     ;
                       , h: this.controlBtnSize     }
        ;:;:;:;:;:;:;:;:;:;:;: Current Track Info Options ;:;:;:;:;:;:;:;:;:;:;:
        currentTrackInfoLineHeight := 14
        currentTrackNameDims   := { x: 0                                   ;
                                  , y: this.controlAreaPos.y               ;
                                       - this.currentTrackInfoLineHeight*3 ;
                                  , w: this.guiSize.w                      ;
                                  , h: this.currentTrackInfoLineHeight     }
        currentTrackAlbumDims  := { x: 0                                 ;
                                  , y: this.currentTrackNameDims.y       ;
                                       + this.currentTrackInfoLineHeight ;
                                  , w: this.guiSize.w                    ;
                                  , h: this.currentTrackInfoLineHeight   }
        currentTrackArtistDims := { x: 0                                 ;
                                  , y: this.currentTrackAlbumDims.y      ;
                                       + this.currentTrackInfoLineHeight ;
                                  , w: this.guiSize.w                    ;
                                  , h: this.currentTrackInfoLineHeight   }
        ;:;:;:;:;:;:;:;:;:;:;:;: Volume Slider Options ;:;:;:;:;:;:;:;:;:;:;:;:;
        volumeSliderColor     := 0xFF90B0D0
        volumeKnobColor       := 0xFFD0F0FF
        volumeSliderMargin    := 24
        volumeSliderThickness := 6
        volumeSliderSize := { w: this.guiSize.w - this.volumeSliderMargin*2 ;
                            , h: 24                                         }
        volumeSliderPos  := { x: this.volumeSliderMargin     ;
                            , y: this.currentTrackNameDims.y ; 
                               - this.volumeSliderSize.h - 4 }
        volumeKnobSize   := { w: 16, h: 12 }
        volumeKnobPos    := { x: this.volumeSliderPos.x      ;
                                 - this.volumeKnobSize.w/2   ;
                            , y: this.volumeSliderPos.y      ;
                                 + this.volumeSliderSize.h/2 ;
                                 - this.volumeKnobSize.h/2   }
        volumeKnobXMax      := this.volumeKnobPos.x+this.volumeSliderSize.w
        volumeKnobLastSlide := A_TickCount
        ;:;:;:;:;:;:;:;:;:;: Track Position Slider Options ;:;:;:;:;:;:;:;:;:;:;
        trackSliderPrimaryColor   := 0xFF90B0D0
        trackSliderSecondaryColor := 0xFF7090B0
        trackSliderMargin    := this.volumeSliderMargin
        trackSliderThickness := 12
        trackSliderSize := { w: this.guiSize.w - this.trackSliderMargin*2 ;
                           , h: 12                                        }
        trackSliderPos  := { x: this.trackSliderMargin                          ;
                           , y: this.volumeSliderPos.y - this.trackSliderSize.h }
        ;:;:;:;:;:;:;:;:;:;:;:;:;:; Options Strings ;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        currentArtOpts   := "x" this.currentArtPos.x    " "
                          . "y" this.currentArtPos.y    " "
                          . "w" this.currentArtSize     " "
                          . "h" this.currentArtSize   
        prevBtnOpts      := "x" this.prevBtnDims.x      " "
                          . "y" this.prevBtnDims.y      " "
                          . "w" this.prevBtnDims.w      " "
                          . "h" this.prevBtnDims.h
        playPauseBtnOpts := "x" this.playPauseBtnDims.x " "
                          . "y" this.playPauseBtnDims.y " "
                          . "w" this.playPauseBtnDims.w " "
                          . "h" this.playPauseBtnDims.h
        nextBtnOpts      := "x" this.nextBtnDims.x      " "
                          . "y" this.nextBtnDims.y      " "
                          . "w" this.nextBtnDims.w      " "
                          . "h" this.nextBtnDims.h
        currentTrackNameOpts   := "x" this.currentTrackNameDims.x   " "
                                . "y" this.currentTrackNameDims.y   " "
                                . "w" this.currentTrackNameDims.w   " "
                                . "h" this.currentTrackNameDims.h   " "
                                . "Center 0x80"
        currentTrackAlbumOpts  := "x" this.currentTrackAlbumDims.x  " "
                                . "y" this.currentTrackAlbumDims.y  " "
                                . "w" this.currentTrackAlbumDims.w  " "
                                . "h" this.currentTrackAlbumDims.h  " "
                                . "Center 0x80"
        currentTrackArtistOpts := "x" this.currentTrackArtistDims.x " "
                                . "y" this.currentTrackArtistDims.y " "
                                . "w" this.currentTrackArtistDims.w " "
                                . "h" this.currentTrackArtistDims.h " "
                                . "Center 0x80"
        currentTrackInfoFontOpts := "s8"
        currentTrackInfoFontName := "Fira Code"
        currentTrackNameFontOpts := this.currentTrackInfoFontOpts " bold"
        volumeSliderOpts := "x" this.volumeSliderPos.x  " "
                          . "y" this.volumeSliderPos.y  " "
                          . "w" this.volumeSliderSize.w " "
                          . "h" this.volumeSliderSize.h " "
                          . "0xE"
        volumeKnobOpts   := "x" this.volumeKnobPos.x    " "
                          . "y" this.volumeKnobPos.y    " "
                          . "w" this.volumeKnobSize.w   " "
                          . "h" this.volumeKnobSize.h   " "
                          . "0xE BackgroundTrans"
        trackSliderOpts  := "x" this.trackSliderPos.x   " "
                          . "y" this.trackSliderPos.y   " "
                          . "w" this.trackSliderSize.w  " "
                          . "h" this.trackSliderSize.h  " "
                          . "0xE BackgroundCCCCCC"
    __New() {
        ;:;:;:;:;:;:;:;: Initialize iTunesApplication instance ;:;:;:;:;:;:;:;:;
        ; ; ; ; ; ;      and static references for event sinks     ; ; ; ; ; ; ;
        this.iTunes := iTunesApplication()
        iWidgetGui.iGuiEventSink.iTunes := this.iTunes
        iWidgetGui.iGuiEventSink.guiApp := this
        iTunesApplication.iCOMEventSink.guiApp := this

        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Main Gui ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
        this.gui := Gui( this.guiOpts             ;
                       , this.winName             ;
                       , iWidgetGui.iGuiEventSink )
        this.gui.MarginX   := this.gui.MarginY := 0
        this.gui.BackColor := this.guiColor

        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Current Art ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        this.currentArt := this.gui.Add( "Picture"           ;
                                       , this.currentArtOpts ;
                                       , ""                  )
        this.currentArt.OnEvent("Click", "CurrentArt_Click")

        ;:;:;:;:;:;:;:;:;:;:;:;:;: Current Track Info ;:;:;:;:;:;:;:;:;:;:;:;:;:
        this.currentTrackName   := this.gui.Add( "Text"                      ;
                                               , this.currentTrackNameOpts   ;
                                               , ""                          )
        this.currentTrackAlbum  := this.gui.Add( "Text"                      ;
                                               , this.currentTrackAlbumOpts  ;
                                               , ""                          )
        this.currentTrackArtist := this.gui.Add( "Text"                      ;
                                               , this.currentTrackArtistOpts ;
                                               , ""                          )
        this.currentTrackName.SetFont(   this.currentTrackNameFontOpts  ;
                                       , this.currentTrackInfoFontName  )
        this.currentTrackAlbum.SetFont(  this.currentTrackInfoFontOpts  ;
                                       , this.currentTrackInfoFontName  )
        this.currentTrackArtist.SetFont( this.currentTrackInfoFontOpts  ;
                                       , this.currentTrackInfoFontName  )

        ;:;:;:;:;:;:;:;:;:;:;:;:;:;: Volume Slider ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
        this.volumeSlider := this.gui.Add( "Picture"             ;
                                         , this.volumeSliderOpts ;
                                         , ""                    )
        this.volumeKnob   := this.gui.Add( "Picture"             ;
                                         , this.volumeKnobOpts   ;
                                         , ""                    )
        this.volumeKnob.OnEvent("Click", "VolumeKnob_Click")

        ;:;:;:;:;:;:;:;:;:;:;:;: Track Position Slider ;:;:;:;:;:;:;:;:;:;:;:;:;
        this.trackPosSlider := this.gui.Add( "Picture"            ;
                                           , this.trackSliderOpts ;
                                           , ""                   )
        this.trackPosSlider.OnEvent("Click", "TrackPosSlider_Click")
        
        ;:;:;:;:;:;:;:;:;:;:;:;:;:; Player Controls ;:;:;:;:;:;:;:;:;:;:;:;:;:;:
        this.prevBtn      := this.gui.Add( "Picture"                           ;
                                         , this.prevBtnOpts                    ;
                                         , A_ScriptDir                         ;
                                           . "\resources\images\prev.png"      )
        this.playPauseBtn := this.gui.Add( "Picture"                           ;
                                         , this.playPauseBtnOpts               ;
                                         , A_ScriptDir                         ;
                                           . "\resources\images\playPause.png" )
        this.nextBtn      := this.gui.Add( "Picture"                           ;
                                         , this.nextBtnOpts                    ;
                                         , A_ScriptDir                         ;
                                           . "\resources\images\next.png"      )

             this.prevBtn.OnEvent("Click", "PrevBtn_Click")
        this.playPauseBtn.OnEvent("Click", "PlayPauseBtn_Click")
             this.nextBtn.OnEvent("Click", "NextBtn_Click")

        ;:;:;:;:;:;:;:;:;:; Show gui and paint Gdip controls ;:;:;:;:;:;:;:;:;:;
        this.gui.Show this.guiShowOpts

        this.PaintVolumeSlider(this.volumeSliderColor, this.volumeKnobColor)
        this.UpdateVolumeSlider(this.iTunes.app.SoundVolume)

        Try this.PaintTrackPositionSlider(this.iTunes.TrackProgress)
        Catch 
            this.PaintTrackPositionSlider(0)

        this.UpdateCurrentTrack()
    }

    ;:;:;:;:;:;:;:;:;:;:; Paint Play/Pause Button Control ;:;:;:;:;:;:;:;:;:;:;:
    PaintPlayPause(isPlaying:=True, secondaryColor:=0xFF7F7F7F) {

    }

    ;:;:;:;:;:;:;:;:;:;:;:; Paint Track Position Slider ;:;:;:;:;:;:;:;:;:;:;:;:
    PaintTrackPositionSlider(trackProg, primaryColor:=0xFF90B0D0
                                      , secondaryColor:=0xFF7090B0) {
        ;-;-;-;-;-;-;-;-;-;-;-;-     Create Brushes     ;-;-;-;-;-;-;-;-;-;-;-;-
        primaryBrush := Gdip_BrushCreateSolid(primaryColor)
        secondaryBrush := Gdip_BrushCreateSolid(secondaryColor)
        ;-;-;-;-;-;-;-;     Initialize bitmaps and graphics     ;-;-;-;-;-;-;-;-
        tpBitmap := Gdip_CreateBitmap( this.trackSliderSize.w ;
                                     , this.trackSliderSize.h )
        tpGraphics := Gdip_GraphicsFromImage(tpBitmap)
        Gdip_SetSmoothingMode(tpGraphics, 4)
        ;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Paint slider ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
        Gdip_FillRectangle( tpGraphics, secondaryBrush ;
                          , 0, 0                       ;
                          , this.trackSliderSize.w     ;
                          , this.trackSliderSize.h     )
        Gdip_FillRectangle( tpGraphics, primaryBrush         ;
                          , 0, 0                             ;
                          , this.trackSliderSize.w*trackProg ;
                          , this.trackSliderSize.h           )
        ;-;-;-;-;-;-     Create HBITMAPS and set control images     ;-;-;-;-;-;-
        tpHBITMAP := Gdip_CreateHBITMAPFromBitmap(tpBitmap)
        SetImage(this.trackPosSlider.Hwnd, tpHBITMAP)
        ;-;-;-;-;-;-;-;-;-     Dispose of Gdip resources     ;-;-;-;-;-;-;-;-;-;
        Gdip_DeleteBrush(primaryBrush)
        Gdip_DeleteBrush(secondaryBrush)
        Gdip_DeleteGraphics(tpGraphics)
        Gdip_DisposeImage(tpBitmap)
        DeleteObject(tpHBITMAP)
    }

    ;:;:;:;:;:;:;:;:;:;:;:;:;:; Paint Volume Slider ;:;:;:;:;:;:;:;:;:;:;:;:;:;:
    PaintVolumeSlider(sliderColor:=0xFF90B0D0, knobColor:=0xFFD0E0F0) {
        ;-;-;-;-;-;-;-;-;-;-;-;-     Create brushes     ;-;-;-;-;-;-;-;-;-;-;-;-
        sliderBrush := Gdip_BrushCreateSolid(sliderColor)
        knobBrush   := Gdip_BrushCreateSolid(knobColor)
        ;-;-;-;-;-;-;-;     Initialize bitmaps and graphics     ;-;-;-;-;-;-;-;-
        sliderBitmap := Gdip_CreateBitmap( this.volumeSliderSize.w ;
                                         , this.volumeSliderSize.h )
        knobBitmap   := Gdip_CreateBitmap( this.volumeKnobSize.w ;
                                         , this.volumeKnobSize.h )
        sliderGraphics := Gdip_GraphicsFromImage(sliderBitmap)
        knobGraphics   := Gdip_GraphicsFromImage(knobBitmap)
        Gdip_SetSmoothingMode(sliderGraphics, 4)
        Gdip_SetSmoothingMode(knobGraphics, 4)
        ;-;-;-;-;-;-;-;-;-;-     Paint slider and knob     ;-;-;-;-;-;-;-;-;-;-;
        Gdip_FillRoundedRectangle( sliderGraphics, sliderBrush    ;
                                 , 0                              ;
                                 , this.volumeSliderSize.h/2      ;
                                   - this.volumeSliderThickness/2 ;
                                 , this.volumeSliderSize.w        ;
                                 , this.volumeSliderThickness     ;
                                 , this.volumeSliderThickness/2   )
        Gdip_FillEllipse( knobGraphics, knobBrush ;
                        , 0, 0                    ;
                        , this.volumeKnobSize.w-1 ;
                        , this.volumeKnobSize.h-1 )
        ;-;-;-;-;-;-     Create HBITMAPS and set control images     ;-;-;-;-;-;-
        sliderHBITMAP := Gdip_CreateHBITMAPFromBitmap(sliderBitmap)
        knobHBITMAP   := Gdip_CreateHBITMAPFromBitmap(knobBitmap)
        SetImage(this.volumeSlider.Hwnd, sliderHBITMAP)
        SetImage(this.volumeKnob.Hwnd, knobHBITMAP)
        ;-;-;-;-;-     Delete brushes, graphics, images, bitmaps     ;-;-;-;-;-;
        Gdip_DeleteBrush(sliderBrush)
        Gdip_DeleteBrush(knobBrush)
        Gdip_DeleteGraphics(sliderGraphics)
        Gdip_DeleteGraphics(knobGraphics)
        Gdip_DisposeImage(sliderBitmap)
        Gdip_DisposeImage(knobBitmap)
        DeleteObject(sliderHBITMAP)
        DeleteObject(knobHBITMAP)
    }

    ;:;:;:;:;:;:;:;:;:;:;:;:;:; Update Volume Slider ;:;:;:;:;:;:;:;:;:;:;:;:;:;
    UpdateVolumeSlider(newVolume) {
        volumePercentage := newVolume/100
        newKnobX := this.volumeSliderSize.w*volumePercentage
                    + this.volumeKnobPos.x
        ControlMove(newKnobX,,,, this.volumeKnob)
    }

    ;:;:;:;:;:; Get and set name, album, and artist of current track ;:;:;:;:;:;
    SetCurrentTrackInfo() {
        currentTrackName   := this.iTunes.app.CurrentTrack.Name
        currentTrackAlbum  := this.iTunes.app.CurrentTrack.Album
        currentTrackArtist := this.iTunes.app.CurrentTrack.Artist
        if StrLen(currentTrackName) >= 39
            currentTrackName   := SubStr(currentTrackName, 1, 36) "..."
        if StrLen(currentTrackAlbum) >= 39
            currentTrackAlbum  := SubStr(currentTrackAlbum, 1, 36) "..."
        if StrLen(currentTrackArtist) >= 39
            currentTrackArtist := SubStr(currentTrackArtist, 1, 36) "..."
        this.currentTrackName.Value   := currentTrackName
        this.currentTrackAlbum.Value  := currentTrackAlbum
        this.currentTrackArtist.Value := currentTrackArtist
    }

    ;:;:;:;:;:;:;:;: Get and set current track info and artwork ;:;:;:;:;:;:;:;:
    UpdateCurrentTrack() {
        Try {
            this.iTunes.SaveCurrentArtwork
            Sleep 25
            this.SetCurrentTrackInfo
            this.currentArt.Value := A_ScriptDir 
                                     . "\resources\images\currentTrack.jpg"
        } Catch Error as err {
            stdo "No track playing " ; Will use placeholder info/image
            this.currentArt.Value := A_ScriptDir 
                                     . "\resources\images\placeholder.png"
            this.currentTrackName.Value   := 
            this.currentTrackAlbum.Value  := 
            this.currentTrackArtist.Value := ""
        }
    }
    ;:;:;:;:;:;:;:;:;:;:;:;:;:; Show/hide widget gui ;:;:;:;:;:;:;:;:;:;:;:;:;:;
    Show() {
        
    }

    ;:;:;:;:;:;:;:;:;:;:;:;: Event sink for widget gui ;:;:;:;:;:;:;:;:;:;:;:;:;
    Class iGuiEventSink {
        static iTunes := {}, guiApp := {}
        ;:;:;:;:;:;:;:;:;:;: Previous Track Player Control ;:;:;:;:;:;:;:;:;:;:;
        ; ; ; ; ; ; ; ; ; ; ; ; ; ;     <Click>     ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
        static PrevBtn_Click(gCtrl, *) {
            gCtrl.Value := A_ScriptDir "\resources\images\prevClick.png"
            Sleep 100
            gCtrl.Value := A_ScriptDir "\resources\images\prev.png"
            this.iTunes.Prev()
        }
        ;:;:;:;:;:;:;:;:;:;:;: Next Track Player Control ;:;:;:;:;:;:;:;:;:;:;:;
        ; ; ; ; ; ; ; ; ; ; ; ; ; ;     <Click>     ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
        static NextBtn_Click(gCtrl, *) {
            gCtrl.Value := A_ScriptDir "\resources\images\nextClick.png"
            Sleep 100
            gCtrl.Value := A_ScriptDir "\resources\images\next.png"
            this.iTunes.Next()
        }
        ;:;:;:;:;:;:;:;:;:;:;: Play/Pause Player Control ;:;:;:;:;:;:;:;:;:;:;:;
        ; ; ; ; ; ; ; ; ; ; ; ; ; ;     <Click>     ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
        static PlayPauseBtn_Click(gCtrl, *) {
            gCtrl.Value := A_ScriptDir "\resources\images\playPauseClick.png"
            Sleep 100
            gCtrl.Value := A_ScriptDir "\resources\images\playPause.png"
            this.iTunes.PlayPause()
        }
        ;:;:;:;:;:;:;:;:;:;:; Current Art Picture Control ;:;:;:;:;:;:;:;:;:;:;:
        ; ; ; ; ; ; ; ; ; ; ; ; ; ;     <Click>     ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
        static CurrentArt_Click(*) {

        }
        ;:;:;:;:;:;:;:;:;:;:;:;: Volume Knob Click/Drag ;:;:;:;:;:;:;:;:;:;:;:;:
        ; ; ; ; ; ; ; ; ; ; ; ; ; ;     <Click>     ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
        static VolumeKnob_Click(gCtrl, gInfo) {
            ControlGetPos &knobX,,,, gCtrl
            MouseGetPos &mouseX
            knobSpan := this.guiApp.volumeKnobXMax - this.guiApp.volumeKnobPos.x
            UpdateITunesVolume() {
                this.guiApp.volumeKnobLastSlide := A_TickCount
                ControlGetPos &currentKnobX,,,, gCtrl
                updatedVolume := Integer(
                    ((currentKnobX-this.guiApp.volumeKnobPos.x)/knobSpan) * 100
                )
                this.iTunes.app.SoundVolume := updatedVolume
            }
            UpdateKnobPos() {
                if !GetKeyState("LButton") {
                    SetTimer , 0
                    UpdateITunesVolume()
                } else {
                    MouseGetPos &newMouseX
                    newKnobX := newMouseX-mouseX+knobX
                    if newKnobX < this.guiApp.volumeKnobPos.x
                        ControlMove this.guiApp.volumeKnobPos.x,,,, gCtrl
                    else if newKnobX > this.guiApp.volumeKnobXMax
                        ControlMove this.guiApp.volumeKnobXMax,,,, gCtrl
                    else
                        ControlMove newKnobX,,,, gCtrl
                    UpdateITunesVolume()
                }
            }
            SetTimer UpdateKnobPos, 10
        }
        static TrackPosSlider_Click(gCtrl, gInfo) {

        }
    }
}


;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: Gdip Shutdown ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
OnExit ShutdownGdipOnExit
ShutdownGdipOnExit(*){
    Gdip_Shutdown gtoken
    stdo "...Shutting down Gdi+"
}
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END Gdip Shutdown ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;



;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
if ISMAIN {
    Hotkey "F8", (*)=> ExitApp()


    iGui := iWidgetGui()
    ; EucalpytusAveyTare := Map()
    ; for IITTrack in iGui.iTunes.app.LibraryPlaylist.Search("Eucalyptus", ITPlaylistSearchField["Albums"]) {
    ;     if IITTrack.Artist = "Avey Tare" {
    ;         EucalpytusAveyTare[IITTrack.TrackNumber] := iTunesApplication.iTrack(IITTrack)
    ;     }
    ; }
    ; EucalpytusAveyTare[1].COM[iGui.iTunes.app].Play()
    ; iGui.iTunes.PlayPause

    OnExit RunOnExit
    RunOnExit(*) {
        global iTunes := {}
        stdo "...Exiting " A_ScriptName
    }

}
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: END if ISMAIN ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;