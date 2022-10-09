#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include "..\Lib\DBT.ahk"


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

Class iTunesApplication {
    
}



OnExit RunOnExit
RunOnExit(*) {
    stdo "...Exiting " A_ScriptName
}
F7::ExitApp