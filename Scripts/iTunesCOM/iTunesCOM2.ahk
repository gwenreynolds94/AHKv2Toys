#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include "..\Lib\DBT.ahk"

/** 
 ** Enumerate playlists
 ** Select playlist to manipulate
 ** Enumerate playlist tracks
 ** Select track(s)
 ** Add tracks to a custom currently playing queue structure
 ** Create playlist from custom structure
 ** Delete tracks from structure and/or playlist
 ** 
 */

 Null := 0

Class ITPlaylistKind {
            /** @prop {ITPlaylistKindUnknown}    Unknown    Unknown playlist kind.                  */
    static  Unknown    :=(
            0             )
            /** @prop {ITPlaylistKindLibrary}    Library    Library playlist (IITLibraryPlaylist).  */
          , Library    :=(
            1             )
            /** @prop {ITPlaylistKindUser}       User       User playlist (IITUserPlaylist).        */
          , User       :=(
            2             )
            /** @prop {ITPlaylistKindCD}         CD         CD playlist (IITAudioCDPlaylist).       */
          , CD         :=(
            3             )
            /** @prop {ITPlaylistKindDevice}     Device     Device playlist.                        */
          , Device     :=(
            4             )
            /** @prop {ITPlaylistKindRadioTuner} RadioTuner Radio tuner playlist.                   */
          , RadioTuner :=(
            5             )     
}

Class iTunesWrapper {
    /** @prop {Map[String, iTunesWrapper.iPlaylist]} userPlaylists */
    userPlaylists := Map()

    /** @param {iTunesApp} iApplication */
    __New(iApplication) {
        this.app := iApplication
        for pl in this.app.LibrarySource.Playlists
            if (pl.Kind = ITPlaylistKind.User) 
                    and !(pl.Name ~= ("(Audiobooks)|(Movies)|(Music)"
                                    . "|(Music\sVideos)|(Podcasts)|(TV\sShows)"))
                this.userPlaylists[pl.Name] := iTunesWrapper.iPlaylist(pl)
    }
    /** @prop {ITObject} COM*/
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
        /** @prop {Map[String|Integer, iTunesWrapper.iTrack]} Tracks */
        Tracks := Map()

        __New(IITTrackCollection, iPlaylist_parent:=Null) {
            ;! accept a single parameter instead {iTrackSource} and extract
            ;!  ...tracks according to the type of object passed
            iTrackSource := {}
            if Type(iTrackSource) = "ComObject" {
                if ComObjType(iTrackSource) = "IITTrackCollection" {

                } else if ComObjType(iTrackSource) = "IITUserPlaylist" {

                }
            } else if Type(iTrackSource) = "Map" {
                iTrackSource.__Enum().Call(&_k, &_v)
                if _v is iTunesWrapper.iTrack {

                }
            }
            this.Playlist   := iPlaylist_parent
            this.Count      := IITTrackCollection.Count
            for track in IITTrackCollection
                this.tracks[track.PlayOrderIndex] := iTunesWrapper.iTrack(track)
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
}


Class Test {
    __New() {
        /** @var {iTunesApp} iApp*/
        iApp := ComObject("iTunes.Application")
        this.iApp := iApp
        ; ipl_RightNow    := iTunes.userPlaylists["RightNow"]
        ; com_RightNow    := iTunes.COM[ipl_RightNow]
        ; itl_RightNow    := iTunesWrapper.iTrackList(com_RightNow.Tracks, ipl_RightNow)
        iTunes    := iTunesWrapper(this.iApp)
        ; this.iApp.SoundVolume := 75
        ; stdo ComObjType(iTunes.COM[iTunes.userPlaylists["ForMornin"]].Tracks, "Name")

        iApp.SoundVolume := 50

        ; iTunes.userPlaylists.__Enum().Call(&upK, &upV)
        ; stdo upK
        ; ComObjConnect(this.iApp, Test.iEventSink)
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
    ComObjConnect(testing.iApp)
    global testing := {}
}

F7::ExitApp