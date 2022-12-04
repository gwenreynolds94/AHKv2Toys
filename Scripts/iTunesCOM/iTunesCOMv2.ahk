#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\..\Lib\DEBUG\DBT.ahk


Null := 0
Class iNotFoundError extends TargetError {
    __New(msg, what:=-1) {
        super.__New(msg, what)
    }
}


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

Class iTunesWrapper {
    userPlaylists := Map()

    __New(iApplication) {
        this.app := iApplication
        for pl in this.app.LibrarySource.Playlists
            if (pl.Kind = ITPlaylistKind["User"]) 
                    and !(pl.Name ~= ("(Audiobooks)|(Movies)|(Music)"
                                    . "|(Music\sVideos)|(Podcasts)|(TV\sShows)"))
                this.userPlaylists[pl.Name] := iTunesWrapper.iPlaylist(pl)
    }

    COM[iObject] => this.app.GetITObjectByID(iObject.IDList*)

    Class iPlaylist {
        __New(IITPlaylist) {
            this.Name       := IITPlaylist.Name
            this.Kind       := IITPlaylist.Kind
            this.Duration   := IITPlaylist.Duration
            this.SourceID   := IITPlaylist.SourceID
            this.PlaylistID := IITPlaylist.PlaylistID
            this.IDList     := [this.SourceID, this.PlaylistID, 0, 0]
        }
    }

    Class iTrackList {
        Tracks := Map()

        __New(iTrackSource, iPlaylist_parent:=Null) {
            if Type(iTrackSource) = "ComObject" {
                if ComObjType(iTrackSource, "Name") = "IITTrackCollection" {
                    IITTrackCollection := iTrackSource
                } else if ComObjType(iTrackSource, "Name") = "IITUserPlaylist" {
                    IITTrackCollection := iTrackSource.Tracks
                } else {
                    stdo "When iTrackSource is a ComObject type, it must "
                       . "be either an IITTrackCollection or IITUserPlaylist."
                    Return 0
                }
                for track in IITTrackCollection
                    this.Tracks[track.PlayOrderIndex] := iTunesWrapper.iTrack(track)
            } else if Type(iTrackSource) = "Map" {
                iTrackSource.__Enum().Call(&_k, &_v)
                if _v is iTunesWrapper.iTrack {
                    for idx, track in iTrackSource
                        this.Tracks[idx] := track
                } else stdo "When iTrackSource is a Map type, it must contain iTracks"
            }
            this.Count := this.Tracks.Count
            this.Playlist   := iPlaylist_parent
        }
        SortTracks(sortBy:="name") {
            if (StrLower(sortBy) = "name") or (StrLower(sortBy) = "index") {
                _Tracks := Map()
                for _, track in this.Tracks
                    _Tracks[track.%sortBy%] := track
                this.Tracks := _Tracks
            }
        }
    }

    Class iTrack {
        __New(IITTrack) {
            this.Name   := IITTrack.Name
            this.Artist := IITTrack.Artist
            this.Album  := IITTrack.Album
            this.Index  := IITTrack.PlayOrderIndex
            this.SourceID        := IITTrack.SourceID
            this.PlaylistID      := IITTrack.PlaylistID
            this.TrackID         := IITTrack.TrackID
            this.TrackDatabaseID := IITTrack.TrackDatabaseID
                     this.IDList := [this.SourceID, this.PlaylistID
                                   , this.TrackID, this.TrackDatabaseID]
        }
    }

    PlayPlaylist(playlistName) {
        for pName, playlist in this.userPlaylists
            if SubStr(pName, 1, StrLen(playlistName)) = playlistName{
                this.COM[playlist].PlayFirstTrack()
                Return 1
            }
        for pName, playlist in this.userPlaylists
            if InStr(pName, playlistName){
                this.COM[playlist].PlayFirstTrack()
                Return 1
            }
        Return 0
    }

    PlayPause() {
        this.app.PlayPause
    }

    Play() {
        this.app.Play
    }

    Pause() {
        this.app.Pause
    }

    Next() {
        this.app.NextTrack
    }

    Prev() {
        this.app.PreviousTrack
    }

    Back() {
        this.app.BackTrack
    }

    SaveCurrentTrackArtwork(targetDir) {
        cTrack := this.app.CurrentTrack
        for art in cTrack.Artwork {
            artFormat := art.Format
            for fmt, fmtID in ITArtworkFormat {
                if artFormat and fmtID = artFormat
                    art.SaveArtworkToFile(targetDir "\" cTrack.TrackDatabaseID "." fmt)
            }
        }
    }

    SetShuffle(shouldShuffle:=True) {
        if (shouldShuffle = False) or (shouldShuffle = True)
            this.app.CurrentPlaylist.Shuffle := ComValue(0xB, shouldShuffle)
    }
}


Class Test {
    __New() {
        iApp := ComObject("iTunes.Application")
        iTunes    := iTunesWrapper(iApp)

        iTunes.Pause

        ; ComObjConnect(this.iApp, Test.iEventSink)
        ExitApp
    }
    Class iEventSink {
        static OnPlayerPlayEvent(IITTrack, CallerObj) {
            SetTimer (*)=>Tooltip(IITTrack.Name "`n" IITTrack.Artist "`n" 
                                . IITTrack.Album "`n" IITTrack.PlayOrderIndex "`n"
                                . IITTrack.Playlist.Name), -1000
            SetTimer (*)=>ToolTip(), -4000
        }
        static OnSoundVolumeChangedEvent(vol, CallerObj) {
            Tooltip "Volume: " vol
            SetTimer (*)=>ToolTip(), -4000
        }
        static OnCOMCallsDisabledEvent(reason, CallerObj) {
            MsgBox "COM calls have been disabled`nReason: " reason
        }
    }
}


if A_ScriptName = "iTunesCOM2.ahk" {
    testing := Test()
}
OnExit ClearCOMOnExit
ClearCOMOnExit(*) {
    ; ComObjConnect(testing.iApp)
    global testing := {}
}

F7::ExitApp