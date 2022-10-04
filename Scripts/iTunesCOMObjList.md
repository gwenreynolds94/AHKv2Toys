## **IITrack**
**IID**     `{4cb0915d-1e54-4727-baf3-ce6cc9a225a1}`

----
      Name              MemberType        Definition
----
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

----
      Enum Names                                Values
----      
      ITPlaylistSearchFieldAll                  0
      ITPlaylistSearchFieldVisible              1
      ITPlaylistSearchFieldArtists              2
      ITPlaylistSearchFieldAlbums               3
      ITPlaylistSearchFieldComposers            4
      ITPlaylistSearchFieldSongNames            5
