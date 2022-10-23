#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

if A_ScriptName="BCINSTALL.ahk" {
    BuildFileStructure(
        [
            _root    := A_AppData "\GwenReynoldsApps"
            , _app   := _root "\BetterClipboard"
            , _clips := _app "\clips"
            , _conf  := _app "\conf"
        ],[
            _clips "\99=12=31==23=59=59=99==Sun.clip"
            , _conf "\BetterClipboard.conf"
        ]
    )
}

BuildFileStructure(folderList:=[], fileList:=[]) {
    oRES := { success: [], failure: [] }

    for fd in folderList
        ValidateFolder fd
    for fi in fileList
        ValidateFile fi

    ValidateFolder(sPath) {
        SplitPath sPath, &fName, &fDir
        if !InStr(DirExist(sPath), "D") and InStr(DirExist(fDir), "D")
            DirCreate sPath
        Return sPath
    }
    ValidateFile(sPath) {
        SplitPath sPath, &fName, &fDir
        if !(FileExist(sPath)~="A|D") and InStr(DirExist(fDir), "D")
            FileAppend("", sPath)
        Return sPath
    }

    Return oRES
}