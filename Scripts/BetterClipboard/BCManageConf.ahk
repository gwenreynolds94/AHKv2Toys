
if A_ScriptName="BCManageConf.ahk" {
    conf := BC_Config
    stdo conf.MaxIndex "`n" conf.CurIndex
}

Class BC_Config {
    Static confPath := 
        A_AppData "\GwenReynoldsApps\BetterClipboard\conf\BetterClipboard.conf"
    Static __New() {
        this.MaxIndex := (this.MaxIndex) ? this.MaxIndex : 9999
        this.CurIndex := (this.CurIndex) ? this.CurIndex : 1
    }
    Static MaxIndex {
        Get {
            Return IniRead(this.confPath, "Config", "MaxIndex", 0)
        }
        Set {
            if IsInteger(Value)
                IniWrite Value, this.confPath, "Config", "MaxIndex"
        }
    }
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
