#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\..\Lib\DEBUG\DBT.ahk

FSO := ComObject("Scripting.FileSystemObject")

GetDriveFreeSpace True
WriteToTempFile

WriteToTempFile() {
    perf := PerfCounter()
    perf.StartTimer()
    tempTXT := FSO.CreateTextFile(FSO.BuildPath(A_ScriptDir, FSO.GetTempName()))
    lineCount := 1111111
    Loop lineCount {
        tempTXT.WriteLine("lorem ipsum bullshit")
    }
    tempTXT.Close()
    stdo "FileSystemObject Write Test: " perf.StopTimer()/1000 " seconds"
    perf.StartTimer()
    tempPath := A_ScriptDir "\" FSO.GetTempName()
    FileAppend "", tempPath
    fileObj := FileOpen(tempPath, "w")
    Loop lineCount {
        fileObj.WriteLine "lorem ipsum bullshit"
    }
    fileObj.Close()
    stdo "AHK FileObject Write Test: " perf.StopTimer()/1000 " seconds"
    perf.StartTimer()
    GENERIC_WRITE := 0x40000000
    CREATE_ALWAYS := 2
    hFile := DllCall("CreateFile", "Str", tempPathB:=A_ScriptDir "\" FSO.GetTempName()
                    , "UInt", GENERIC_WRITE, "UInt", 0, "Ptr", 0, "UInt", CREATE_ALWAYS
                    , "UInt", 0, "Ptr", 0, "PTr")
    strToWrite:="lorem ipsum bullshit"
    Loop lineCount {
        strWritten .= strToWrite "`n"
    }
    strSize := StrLen(strWritten)*2
    DllCall("WriteFile", "Ptr", hFile, "Str", strWritten, "UInt", strSize
          , "UIntP", &bytesWritten:=0, "Ptr", 0)
    DllCall("CloseHandle", "Ptr", hFile)
    stdo "DllCall CreateFile/WriteFile Test " perf.StopTimer()/1000 " seconds"
    Loop Files A_ScriptDir "\*.tmp" {
        FileDelete A_LoopFileFullPath
    }
}

GetDriveFreeSpace(print:=False) {
    drives := Map()
    for drive in FSO.Drives {
        free      := drive.FreeSpace
        freeGB    := free/1024/1024/1024
        freeMBrem := (freeGB-(freeGBFloor:=Floor(freeGB)))*1024
        freeKBrem := (freeMBrem-(freeMBremFloor:=Floor(freeMBrem)))*1024
        drives[drive.DriveLetter] := {
            GB: freeGB
          , MB: free/1024/1024
          , KB: free/1024
          , Bytes: free
          , formatted: {
                GB: freeGBFloor
              , MB: freeMBremFloor
              , KB: Floor(freeKBrem)
          }
        }
        if print
            for prop in drives[drive.DriveLetter].OwnProps()
                if IsObject(drives[drive.DriveLetter].%prop%) {
                    stdo drive.DriveLetter ">" prop ":"
                    for subprop in drives[drive.DriveLetter].%prop%.OwnProps()
                        stdo "`t" subprop ": " 
                           . drives[drive.DriveLetter].%prop%.%subprop%
                    stdo ""
                } else stdo drive.DriveLetter ">" prop ":"
                          , drives[drive.DriveLetter].%prop%, ""
    }
    Return drives
}
