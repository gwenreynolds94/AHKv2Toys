
/**
 * This class implements an object-oriented interface for loading and saving
 * configuration files using the IniRead and IniWrite functions.
 *
 * The constructor (__New) can be used to set a custom filepath for the
 * configuration file, as well as a set of default values. The Validate method
 * can be used to check if a configuration file already exists and either create
 * a new file or just return "exists". The Sett method provides accessor methods
 * for each section and key in the file. The Ini method provides access to the
 * entire file in one call. The Setting and SettingSection classes provide static
 * methods to access sections and keys from the configuration file.
 *
 * Finally, the SectionEdit class provides a graphical interface for editing
 * a particular section of the file.
 */
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
        _value_type := {}

        _content := Map()

        /** @prop {Gui} _gui */
        _gui := {}

        /** @prop {Map} _guictrls <String, Gui.Control> */
        _guictrls := Map()

        /** @prop {Gui.Control} _gui_exit_btn */
        _gui_exit_btn := {}

        _item_width := 150

        methbound := {}

        /**
         * @param {ConfTool} _conftool
         * @param {String} _section
         * @param {"bool"|"string"} _value_type
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
                if this._value_type ~= "bool" {
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

        /** @param {Gui.Control} _guictrl */
        CheckBox_OnClick(_guictrl, *) {
            this._conftool.Ini.%(this._section)%.%(_guictrl.Text)% := _guictrl.Value
        }

        Show(*) {
            this._gui.Show()
        }

        Hide(*) {
            this._gui.Hide()
        }

    }

}

