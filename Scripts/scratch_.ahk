#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>

currentWinStation := DllCall("GetProcessWindowStation")
EnumDesktopsCallback := CallbackCreate(EnumDesktopProc)
DllCall("EnumDesktopsW", "Ptr", currentWinStation, "Ptr", EnumDesktopsCallback, "Ptr", 0)

EnumDesktopProc(desktopName, *) {
    MsgBox StrGet(desktopName)
}

EnumWinStationsCallback := CallbackCreate(EnumWindowStationProc)
DllCall("EnumWindowStationsW", "Ptr", EnumWinStationsCallback, "Ptr", 0)

EnumWindowStationProc(winStationName, *) {
    MsgBox StrGet(winStationName)
}

