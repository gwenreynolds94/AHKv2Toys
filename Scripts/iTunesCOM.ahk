#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>


ITPlaylistSearchField := {      All:   0,
                            Visible:   1,
                            Artists:   2,
                             Albums:   3,
                          Composers:   4,
                          SongNames:   5, }

itunes := ComObject("iTunes.Application")
playlist := GetPlaylist("AveryTare", itunes)
playlist.PlayAll
itunes := ""

Class iPlaylist {
    __New(comPlaylist, comApp) {
        this.iTunesApp := comApp
        this.com := comPlaylist
        this.name := this.com.Name
        this.tracks := Map()
        for track in this.com.Tracks
            this.tracks[track.Name] := iTrackInfo(track, comApp)
    }
    PlayTrack(trackInfo) {
        this.GetTrack(trackInfo).Play()
    }
    PlayAll() {
        this.com.PlayFirstTrack()
    }
    PlayByPlayOrder(trackOrder) {
        this.GetTrackByPlayOrder(trackOrder).Play()
    }
    PlayByName(trackName) {
        this.GetTrackByName(trackName).Play()
    }
    GetTrackByPlayOrder(trackOrder) {
        Return this.com.Tracks.ItemByPlayOrder(trackOrder)
    }
    GetTrackByName(trackName) {
        Return this.com.Tracks.ItemByName(trackName)
    }
    GetTrackByTrackInfo(trackInfo) {
        if (trackInfo is iTrackInfo)
            Return this.com.Tracks.ItemByPersistentID(trackInfo.trackid.hi
                                                    , trackInfo.trackid.lo)
        Return 0
    }
    Shuffle {
        get => this.com.Shuffle
        set => this.com.Shuffle := ComValue(0xb, Value)
    }
}

Class iTrackInfo {
    __New(comTrack, comApp) {
        this.name := comTrack.Name
        this.album := comTrack.Album
        this.artist := comTrack.Artist
        this.playlistName := comTrack.Playlist.Name
        this.trackid := GetPersistentID(comTrack, comApp)
        this.playlistid := GetPersistentID(comTrack.Playlist, comApp)
    }
}

GetPlaylist(playlistName, comApp) {
    _playlist := comApp.LibrarySource.Playlists.ItemByName(playlistName)
    Return iPlaylist(_playlist, comApp)
}

GetPersistentID(IITObject, comApp) {
    idLo := comApp.ITObjectPersistentIDLow(IITObject)
    idHi := comApp.ITObjectPersistentIDHigh(IITObject)
    Return {lo: idLo, hi: idHi}
}
