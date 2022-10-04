#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include "..\Lib\DBT.ahk"


Null := 0

Class iSearchField {
         /** @prop {ITPlaylistSearchFieldAll} All */
    static All   := (
          0          )      
          /** @prop {ITPlaylistSearchFieldVisible} Visible */
          , Visible := (
           1            )
           /** @prop {ITPlaylistSearchFieldArtists} Artists */
           , Artists :=  (
            2             )  
            /** @prop {ITPlaylistSearchFieldAlbums} Albums */
            , Albums   := (
             3             )
             /** @prop {ITPlaylistSearchFieldComposers} Composers */
             , Composers := (
              4              )
              /** @prop {ITPlaylistSearchFieldSongNames} SongNames */
              , SongNames := (
               5              )
}

iSearchField.All
iSearchField.Visible

Class iTrack {
    __New(IITTrack) {
        this.Name := IITTrack.Name
        this.Artist := IITTrack.Artist
        this.Album := IITTrack.Album
        this.idMap := Map("source",   IITTrack.SourceID
                          , "playlist", IITTrack.PlaylistID
                          , "track",    IITTrack.TrackID
                          , "database", IITTrack.TrackDatabaseID)
    }
    IDs[context:=Null] {
        get {
            if context
                Return this.idMap[context]
            Return [this.idMap["source"  ]
                  , this.idMap["playlist"]
                  , this.idMap["track"   ]
                  , this.idMap["database"]]
        }
    }
    COM[iTunesApp] {
        get => iTunesApp.GetITObjectByID(this.IDs*)
    }
}

Class iPlaylist {
    __New(varPlaylist, iApp:=Null) {
        if (Type(varPlaylist) = "String") and iApp
            this.obj := iApp.LibrarySource.Playlists.ItemByName(varPlaylist)
        else if IsObject(varPlaylist)
            this.obj := varPlaylist
    }
    __Item[songIdentity] {
        get {
            if IsInteger(songIdentity)
                Return this.obj.Tracks.ItemByPlayOrder(songIdentity)
            if Type(songIdentity) = "String"
                Return this.obj.Tracks.ItemByName(songIdentity)
        }
    }
}

Class iTrackList {
    __New(varTrackList) {
        this.obj := varTrackList
    }
    __Item[songIdentity] {
        get {
            if IsInteger(songIdentity)
                Return this.obj.ItemByPlayOrder(songIdentity)
            if Type(songIdentity) = "String"
                Return this.obj.ItemByName(songIdentity)
        }
    }
}

Class iTunesHandle {
    __New() {
        this.app := ComObject("iTunes.Application")
        this.playlistNames := []
        for pl in this.app.LibrarySource.Playlists
            this.playlistNames.Push(pl.Name)
    }
    __Item[playlistName] {
        get {
            for plname in this.playlistNames {
                if playlistName = plname
                    Return iPlaylist(playlistName, this.app)
            }
            Return iTrackList(this.app.LibraryPlaylist.Search(playlistName, iSearchField.Artists))
        }
    }
}

itunes := iTunesHandle()
itunes["Dr. Dog"]["Lonesome"].Play()

