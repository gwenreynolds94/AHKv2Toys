
Class ConfTool {

    fpath := ".\.ahkonf"
    defaults := Map()

    __New(_confpath:="", _defaults:="") {
        this.fpath := _confpath ? _confpath : this.fpath
        this.defaults := _defaults ? _defaults : this.defaults
    }

    Validate() {
        CreateDefaultFile() {
            for _sectname, _sect in this.defaults
                for _keyname, _keyvalue in _sect
                    this.Sett[_sectname, _keyname] := _keyvalue
        }
        if FileExist(this.fpath)
            return "exists"
        SplitPath this.fpath, &_fname, &_fdir
        _fdir := _fdir ? _fdir : "."
        if DirExist(_fdir) {
            CreateDefaultFile()
            return "file"
        } else {
            SplitPath _fdir, &_dname, &_ddir
            _ddir := _ddir ? _ddir : "."
            if DirExist(_ddir) {
                DirCreate(_fdir)
                CreateDefaultFile()
                return "dir"
            } else return ""
        }
    }

    Sett[_section, _key] {
        Get => IniRead(this.fpath, _section, _key, "")
        Set => IniWrite(Value, this.fpath, _section, _key)
    }

    Ini {
        Get {
            ConfTool.SettingSection.CurrentFilePath := this.fpath
            Return ConfTool.SettingSection()
        }
    }

    Class Setting {
        Static CurrentSection := "",
               CurrentFilePath := ""

        __Get(Key, Params) {
            Return IniRead(ConfTool.Setting.CurrentFilePath,
                            ConfTool.Setting.CurrentSection, Key, "")
        }

        __Set(Key, Params, Value) {
            IniWrite(Value, ConfTool.Setting.CurrentFilePath,
                            ConfTool.Setting.CurrentSection, Key)
        }
    }

    Class SettingSection {
        Static CurrentFilePath := ""

        __Get(Key, Params) {
            ConfTool.Setting.CurrentFilePath :=
                ConfTool.SettingSection.CurrentFilePath
            ConfTool.Setting.CurrentSection := Key
            Return ConfTool.Setting()
        }

        __Set(Key, Params, Value) {
            Return
        }
    }

    Class SectionEdit {

        /** @prop {ConfTool} _conftool */
        _conftool := ""

        /** @prop {String} _section */
        _section := "",

        /** @prop {"bool"|"string"} */
        _value_type := ""

        _content := Map()

        /** @prop {Gui} _gui */
        _gui := {}

        /** @prop {Map<String, Gui.Control>} _guictrls */
        _guictrls := Map()

        /** @prop {Gui.Control} _gui_exit_btn */
        _gui_exit_btn := {}

        _item_width := 150

        methbound := {}

        /**
         * @param {ConfTool} _conftool
         * @param {String} _section
         * @param {"bool" | "string"} _value_type
         */
        __New(_conftool, _section, _value_type:="bool") {
            this._conftool := _conftool
            this._section := _section
            this._value_type := _value_type
            this.methbound.show := ObjBindMethod(this, "Show")
            this.methbound.hide := ObjBindMethod(this, "Hide")
            this.SetupGui()
        }

        SetupGui() {
            this._gui := Gui("+AlwaysOnTop", "Edit" this._section "Gui", this)
            this.UpdateContent()
            ; this._gui.AddText("x0 y0 w" this._item_width, "Edit " this._section)
            for _key, _value in this._content {
                ; this._gui.AddText("xp+0 y+10 w" this._item_width, _key)
                if this._value_type = "bool" {
                    this._guictrls[_key] :=
                        this._gui.AddCheckbox("xp+0 y+10 w" this._item_width, _key)
                    this._guictrls[_key].Value := _value
                    this._guictrls[_key].OnEvent("Click", "CheckBox_OnClick")
                }
            }

            this._gui_exit_btn :=
                this._gui.AddButton("xp+0 y+10 w" this._item_width, "Close")
            this._gui_exit_btn.OnEvent("Click", "ExitButton_OnClick")

            /** @var {Menu} _tray */
            _tray := A_TrayMenu
            _tray.Add("Edit " this._section, this.methbound.show)
        }

        UpdateContent() {
            this._content.Clear()
            Loop Parse, IniRead(this._conftool.fpath, this._section), "`n", "`r" {
                RegExMatch A_LoopField, "([^=]+)=(.+)", &_re_match
                this._content[_re_match.1] := _re_match.2
            }
        }

        ExitButton_OnClick(*) {
            this.Hide()
        }

        CheckBox_OnClick(_guictrl, *) {
            Tooltip _guictrl.Value
            SetTimer (*)=>Tooltip(), -2000
        }

        Show(*) {
            this._gui.Show()
        }

        Hide(*) {
            this._gui.Hide()
        }

    }

}

; Class ConfTool {
;
;     ; _confpath := ""
;     ; _confcache := ""
;     fpath := ".\.ahkonf"
;     defaults := Map()
;
;     __New(_confpath:="", _defaults:="") {
;         ; this.ConfPath := _confpath ? _confpath : ConfTool.Default.ConfPath
;         this.fpath := _confpath ? _confpath : this.fpath
;         this.defaults := _defaults ? _defaults : this.defaults
;         ; this.cache := ConfTool.ConfCache()
;         ; ConfTool.ConfCache.ValidateInstance(this)
;
;     }
;
;     Validate() {
;         CreateDefaultFile() {
;             for _sectname, _sect in this.defaults
;                 for _keyname, _keyvalue in _sect
;                     this.Sett[_sectname, _keyname] := _keyvalue
;         }
;         if FileExist(this.fpath)
;             return "exists"
;         SplitPath this.fpath, &_fname, &_fdir
;         _fdir := _fdir ? _fdir : "."
;         if DirExist(_fdir) {
;             CreateDefaultFile()
;             return "file"
;         } else {
;             SplitPath _fdir, &_dname, &_ddir
;             _ddir := _ddir ? _ddir : "."
;             if DirExist(_ddir) {
;                 DirCreate(_fdir)
;                 CreateDefaultFile()
;                 return "dir"
;             } else return ""
;         }
;     }
;
;     ; ConfPath {
;     ;     Get => this._confpath
;     ;     Set => this._confpath := Value
;     ; }
;
; ;     cache {
; ;         Get => this._confcache
; ;         Set => this._confcache := Value
; ;     }
; ;
; ;     Cfg[_section, _key] {
; ;         Get => this.cache.%_section%[this, _key]
; ;         Set => this.cache.%_section%[this, _key] := Value
; ;     }
;
;     Sett[_section, _key] {
;         Get => IniRead(this.fpath, _section, _key, "")
;         Set => IniWrite(Value, this.fpath, _section, _key)
;     }
;
; ;     Class ConfCache {
; ;
; ;         /** @param {ConfTool} _instance */
; ;         Static ValidateInstance(_instance) {
; ;             I := _instance
; ;             if FileExist(I.ConfPath)
; ;                 return "exists"
; ;             SplitPath I.ConfPath, &_fname, &_fdir
; ;             _fdir := _fdir ? _fdir : "."
; ;             if DirExist(_fdir) {
; ;                 this.CreateConfig(I)
; ;                 return "newfile"
; ;             } else {
; ;                 SplitPath(_fdir, &_dname, &_ddir)
; ;                 _ddir := _ddir ? _ddir : "."
; ;                 if DirExist(_ddir) {
; ;                     DirCreate(_fdir)
; ;                     this.CreateConfig(I)
; ;                     return "newdir"
; ;                 } else return "baddir"
; ;             }
; ;         }
; ;
; ;         /** @param {ConfTool} _instance */
; ;         Static CreateConfig(_instance) {
; ;             I := _instance
; ;             for _section, _items in ConfTool.Default.ConfSections
; ;                 for _, _item in _items
; ;                     I.cache.%_section%[I, _item[1]] := _item[2]
; ;                     ; IniWrite(_item[2], I.ConfPath, _section, _item[1])
; ;         }
; ;
; ;         __Get(Key, Params) {
; ;             I := Params.Length ? Params[1] : false
; ;             if not I
; ;                 return "badinstance"
; ;             if Params.Length < 2
; ;                 return "nokey"
; ;             return IniRead(I.ConfPath, Key, Params[2], "")
; ;         }
; ;         __Set(Key, Params, Value) {
; ;             I := Params.Length ? Params[1] : false
; ;             if not I or Params.Length < 2
; ;                 return
; ;             IniWrite(Value, I.ConfPath, Key, Params[2])
; ;         }
; ;     }
;
;     ; Class Default {
;     ;     Static _ := ""
;     ;     ,   ConfPath := ".\.ahkconf"
;     ;     ,   Settings := Map(
;     ;             "Enabled", Map(
;     ;                 "All", 1
;     ;             )
;     ;         )
;     ;     ; ,   ConfSections := Map(
;     ;     ;         "Enabled", [
;     ;     ;             ["All", 1]
;     ;     ;         ]
;     ;     ;     )
;     ; }
; }



