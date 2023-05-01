#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include *i <DEBUG\DBT>
#Include *i <Utils\WinUtil\WinUtil>
#Include *i <Utils\DetectComputer>

#Include *i ..\..\DEBUG\DBT.ahk
#Include *i WinVector.ahk
#Include *i WinUtil.ahk
#Include *i ..\DetectComputer.ahk

class WinCache {
    static _windows := Map()

    static __New() {

    }

    static Windows {
        get => this._windows
        set => this._windows := Value
    }

    Class WinItem {
        hwnd := 0x0
        pid := 0x0
        process := ''
        class := ''
        title := ''

        __New(_hwnd) {
            this.hwnd := _hwnd
            if WinExist(_hwnd)
                this.UpdateFromHwnd(_hwnd)
        }

        UpdateFromHwnd(_hwnd) {
            this.hwnd := _hwnd
            this.pid := WinGetPID()
            this.process := WinGetProcessName()
            this.class := WinGetClass()
            this.title := WinGetTitle()
        }

        IsBrowser {
            get => (0)
            set => (0)
        }

        Size[_src:='wingetpos'] {
            get {

            }
            set {

            }
        }

        Pos[_src:='wingetpos'] {
            get {

            }
            set {

            }
        }

        /**
         *
         * @param {string} _src < `winget(pos)?` `|` `real` `|` `super` >
         */
        SizePos[_src:='wingetpos'] {
            get {
                if not WinExist(this.hwnd)
                    throw TargetError('WinCache.WinItem.SizePos:: ' .
                                      'The window referenced by this WinItem ' .
                                      'instance does not exist')
                WinGetPos(&_x, &_y, &_w, &_h, this.hwnd)
                WinVector.DLLUtil.SuperficialCoordsFromReal(
                            &_super_size_pos:={}, this.hwnd)
                _ahk_size_pos := {x: _x, y: _y, w: _w, h: _h}
                if not _src
                    throw ValueError('WinCache.WinItem.SizePos:: _src must not be blank')
                else if _src ~= 'winget(pos)?|real'
                    return _ahk_size_pos
                else if _src ~= 'super'
                    return _super_size_pos
                else throw ValueError('WinCache.WinItem.SizePos:: _src is not valid')
            }
            set {
            }
        }
    }
}

#Include ..\..\DEBUG\DBT.ahk

__DEBUG() {
    _w := WinCache.WinItem(WinExist("A"))
    dbgo _w.SizePos
    dbgo _w.SizePos['dllsuper']
    dbgo _w.SizePos['dllreal']
}
F9::__DEBUG