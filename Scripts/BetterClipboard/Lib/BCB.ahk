
if A_ScriptName="BC_ManageConf.ahk" {
    conf := BCB_Config
    FileAppend conf.MaxIndex "`n" conf.CurIndex, "*"
}

; Getter/Setter class for keys in **BetterClipboard.conf**
Class BCB_Config {
    Static __New() {
        this.MaxIndex := (this.MaxIndex) ? this.MaxIndex : 9999
        this.CurIndex := (this.CurIndex) ? this.CurIndex : 1
    }
    /** @prop {String} confPath Path to **BetterClipboard.conf** */
    Static confPath => A_AppData
                    . "\GwenReynoldsApps\BetterClipboard\conf\BetterClipboard.conf"
    /** @prop {Int} MaxIndex Get/Set `MaxIndex` key in **BetterClipboard.conf** */
    Static MaxIndex {
        Get {
            Return IniRead(this.confPath, "Config", "MaxIndex", 0)
        }
        Set {
            if IsInteger(Value)
                IniWrite Value, this.confPath, "Config", "MaxIndex"
        }
    }
    /** @prop {Int} CurIndex Get/Set `CurIndex` key in **BetterClipboard.conf** */
    Static CurIndex {
        Get {
            Return IniRead(this.confPath, "Config", "CurIndex", 0)
        }
        Set {
            if IsInteger(Value)
                IniWrite Value, this.confPath, "Config", "CurIndex"
        }
    }
}

if A_ScriptName="BC_ManageConf.ahk" {
    BCB_BuildFileStructure(
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

/**
 * @param {`Array[String]`} folderList  
 *      Pass a list of directories to create.
 *      Will always attempt to create directories in the order passed.
 * @param {`Array[String]`} fileList
 *      Pass a list of files to create
 * @return {`{success:Int, failure:Int}`}
 */
BCB_BuildFileStructure(folderList:=[], fileList:=[]) {
    oRES := { success: [], failure: [] }

    for fd in folderList
        ValidateFolder fd
    for fi in fileList
        ValidateFile fi

    /** @param {String} sPath Path to folder 
      * @return {String} Returns sPath unmodified */
    ValidateFolder(sPath) {
        SplitPath sPath, &fName, &fDir
        if !InStr(DirExist(sPath), "D") and InStr(DirExist(fDir), "D")
            DirCreate sPath
        Return sPath
    }
    /** @param {String} sPath Path to file
      * @return {String} Returns sPath unmodified */
    ValidateFile(sPath) {
        SplitPath sPath, &fName, &fDir
        if !(FileExist(sPath)~="A|D") and InStr(DirExist(fDir), "D")
            FileAppend("", sPath)
        Return sPath
    }

    Return oRES
}

BCB_WriteNewClip(_index) {
    static file_suffix := ".clip"
         , clips_path := A_AppData "\GwenReynoldsApps\BetterClipboard\clips"
    new_file_name := _index . file_suffix
    new_file_path := clips_path "\" new_file_name
    if (FileExist(new_file_path) ~= "A|N")
        FileDelete(new_file_path)
    FileAppend A_Clipboard, new_file_path
}

BCB_GetClip(_index) {
    static file_suffix := ".clip"
         , clips_path := A_AppData "\GwenReynoldsApps\BetterClipboard\clips"
    file_name := _index . file_suffix
    file_path := clips_path "\" file_name
    if (FileExist(file_path) ~= "A|N")
        Return FileRead(file_path)
    else
        Return ""
}