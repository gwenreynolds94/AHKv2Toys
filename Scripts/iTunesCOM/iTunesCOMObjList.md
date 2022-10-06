## **IITrack**
**IID**     `{4cb0915d-1e54-4727-baf3-ce6cc9a225a1}`

----
Represents a track.

A track represents a song in a single playlist. A song may be in more than one playlist, in which case it would be represented by multiple tracks.

----
- You can retrieve the currently targeted (playing) track using **IiTunes**::*CurrentTrack()*.

- Typically, an **IITrack** is accessed through an **IITTrackCollection**.


- You can retrieve all the tracks defined for a playlist using **IITPlaylist**::*Tracks()*.

- You can retrieve the currently selected track or tracks using **IiTunes**::*SelectedTracks().*

----
      Name              MemberType        Definition
      ---------------   ---------------   ---------------
      AddArtworkFromFile Method           IITArtwork AddArtworkFromFile (string)  
      Delete             Method           void Delete ()  
      GetITObjectIDs     Method           void GetITObjectIDs (int, int, int, int)  
      Play               Method           void Play ()  
      Album              Property         string Album () {get} {set}  
      Artist             Property         string Artist () {get} {set}  
      Artwork            Property         IITArtworkCollection Artwork () {get}  
      BitRate            Property         int BitRate () {get}  
      BPM                Property         int BPM () {get} {set}  
      Comment            Property         string Comment () {get} {set}  
      Compilation        Property         bool Compilation () {get} {set}  
      Composer           Property         string Composer () {get} {set}  
      DateAdded          Property         Date DateAdded () {get}  
      DiscCount          Property         int DiscCount () {get} {set}  
      DiscNumber         Property         int DiscNumber () {get} {set}  
      Duration           Property         int Duration () {get}  
      Enabled            Property         bool Enabled () {get} {set}  
      EQ                 Property         string EQ () {get} {set}  
      Finish             Property         int Finish () {get} {set}  
      Genre              Property         string Genre () {get} {set}  
      Grouping           Property         string Grouping () {get} {set}  
      Index              Property         int Index () {get}  
      Kind               Property         ITTrackKind Kind () {get}  
      KindAsString       Property         string KindAsString () {get}  
      ModificationDate   Property         Date ModificationDate () {get}  
      Name               Property         string Name () {get} {set}  
      PlayedCount        Property         int PlayedCount () {get} {set}  
      PlayedDate         Property         Date PlayedDate () {get} {set}  
      Playlist           Property         IITPlaylist Playlist () {get}  
      playlistID         Property         int playlistID () {get}  
      PlayOrderIndex     Property         int PlayOrderIndex () {get}  
      Rating             Property         int Rating () {get} {set}  
      SampleRate         Property         int SampleRate () {get}  
      Size               Property         int Size () {get}  
      sourceID           Property         int sourceID () {get}  
      Start              Property         int Start () {get} {set}  
      Time               Property         string Time () {get}  
      TrackCount         Property         int TrackCount () {get} {set}  
      TrackDatabaseID    Property         int TrackDatabaseID () {get}  
      trackID            Property         int trackID () {get}  
      TrackNumber        Property         int TrackNumber () {get} {set}  
      VolumeAdjustment   Property         int VolumeAdjustment () {get} {set}  
      Year               Property         int Year () {get} {set}  


## **ITPlaylistSearchField enum**
Specifies the fields in each track that will be searched by IITPlaylist::Search().

----
      Names                               Values
      ---------------                     ---------------
      ITPlaylistSearchFieldAll            0 ...Search all fields of each track.
      ITPlaylistSearchFieldVisible        1 ...Search only the fields with columns that are currently visible in the display for the playlist.
      ITPlaylistSearchFieldArtists        2 ...Search only the artist field of each track (IITTrack::Artist).
      ITPlaylistSearchFieldAlbums         3 ...Search only the album field of each track (IITTrack::Album).
      ITPlaylistSearchFieldComposers      4 ...Search only the composer field of each track (IITTrack::Composer).
      ITPlaylistSearchFieldSongNames      5 ...Search only the song name field of each track (IITTrack::Name). 

## **ITPlaylistKind enum**
Specifies the playlist kind. 

----
      Names                         Values
      ---------------               ---------------
      ITPlaylistKindUnknown         0 ...Unknown playlist kind.
      ITPlaylistKindLibrary         1 ...Library playlist (IITLibraryPlaylist).
      ITPlaylistKindUser            2 ...User playlist (IITUserPlaylist).
      ITPlaylistKindCD              3 ...CD playlist (IITAudioCDPlaylist).
      ITPlaylistKindDevice          4 ...Device playlist.
      ITPlaylistKindRadioTuner      5 ...Radio tuner playlist.

##  **ITCOMDisabledReason enum**
Specifies the reason the COM interface is being disabled.

----
      Names                         Values
      ---------------               ---------------
      ITCOMDisabledReasonOther      0 ...COM interface is being disabled for some other reason.
      ITCOMDisabledReasonDialog     1 ...COM interface is being disabled because a modal dialog is being displayed    
      ITCOMDisabledReasonQuitting   2 ...COM interface is being disabled because iTunes is quitting. 