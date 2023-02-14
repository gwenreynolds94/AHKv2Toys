
Tooltip.On := {
    Call: (_this, _daddy, _msg:="", _dur:=False) => (
        Tooltip(_msg),
        (!!_dur and IsInteger(_dur)) ? (SetTimer((*)=>Tooltip(), _dur), True) : False
    )
}
Tooltip.Off := {
    Call: (_this, _daddy, _delay:=1000) => (SetTimer((*)=>Tooltip(), _delay))
}

Class WinTransparency {
    Static activeWindows := Map()

    /**
     * @param {String | Number} _direction
     * 
     *      ( ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
     *        ; "Up" | "Down" | (-)n | (+)n ;
     *             _direction ~= "i)up"   | ; +1 step  
     *             _direction ~= "i)down" | ; -1 step  
     *             _direction ~= "-?[0-9]+" ; +1 step <- positive, 
     *      ) ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; -1 step <- negative
     */
    Static StepActive(_direction:="Down") {
        this.StepWindow(_direction)
    }

    Static StepWindow(_direction, _wTitle:="A") {
        _WT:=WinTransparency
        if !(_WT.activeWindows.Has(activeHwnd:=WinExist(_wTitle)))
            _WT.activeWindows[activeHwnd] := _WT.WinItem(activeHwnd)
        ; @type {WinTransparency.WinItem}
        activeWinItem := _WT.activeWindows[activeHwnd]
        if (!activeWinItem.enabled)
            Return
        activeWinItem.Step(_direction)
        ToolTip.On(activeWinItem.CurrentStep ": " activeWinItem.Transparency, 1000)
    }

    /**
     * @param {Float} _transparency
     * 
     *          Integer(_transparency) >=   0 
     *      and Integer(_transparency) <= 255
     */
    Static SetActive(_transparency:=255) {
        this.SetWindow(_transparency)
    }

    Static SetWindow(_transparency:=255, _wTitle:="A") {
        transInt:=Integer(_transparency)
        transNew := (transInt <   0) ? (0) :        ; <   0 -> 0
                        (transInt > 255) ? (255) :  ; > 255 -> 255
                            (transInt)              ;  else -> _transparency
        _WT:=WinTransparency
        if !(_WT.activeWindows.Has(activeHwnd:=WinExist(_wTitle)))
            _WT.activeWindows[activeHwnd] := _WT.WinItem(activeHwnd)
        ; @type {WinTransparency.WinItem}
        activeWinItem := _WT.activeWindows[activeHwnd]
        if (!activeWinItem.enabled)
            Return
        nearest := activeWinItem.NearestStep[_transparency]
        newStepOffset := (nearest.dist>0) ? (1) : 
                         (nearest.dist<0) ? (0) : -1
        newStep := nearest.step + newStepOffset
        if (newStepOffset>=0)
            activeWinItem.AddStep(newStep, _transparency)
        else newStep += 1
        activeWinItem.CurrentStep := newStep
    }

    Static ToggleActive() {
        this.ToggleWindow()
    }

    Static ToggleWindow(_wTitle:="A", _force:="") {
        _WT:=WinTransparency
        if !(_WT.activeWindows.Has(activeHwnd:=WinExist(_wTitle)))
            _WT.activeWindows[activeHwnd] := _WT.WinItem(activeHwnd)
        ; @type {WinTransparency.WinItem}
        activeWinItem := _WT.activeWindows[activeHwnd]
        activeWinItem.Toggle(_force)
    }

    Static PromptSetActive() {
        this.PromptSetWindow()
    }

    Static PromptSetWindow(_wTitle:="A") {
        _WT:=WinTransparency
        if !(_WT.activeWindows.Has(activeHwnd:=WinExist(_wTitle)))
            _WT.activeWindows[activeHwnd] := _WT.WinItem(activeHwnd)
        ; @type {WinTransparency.WinItem}
        activeWinItem := _WT.activeWindows[activeHwnd]
        _input := InputBox("Enter a transparency level from 0 to 255"
                         , "Set Transparency", "y0 h100 w250").Value
        if (IsInteger(_input) and (_input >= 0) and (_input <= 255))
            this.SetWindow(_input, _wTitle)
    }

    Static ResetActive() {
        this.ResetWindow()
    }

    Static ResetWindow(_wTitle:="A") {
        _WT:=WinTransparency
        if !(_WT.activeWindows.Has(activeHwnd:=WinExist(_wTitle)))
            _WT.activeWindows[activeHwnd] := _WT.WinItem(activeHwnd)
        ; @type {WinTransparency.WinItem}
        activeWinItem := _WT.activeWindows[activeHwnd]
        activeWinItem.ResetTransparencyValues()
    }

    Class WinItem {
        Static DefaultTransparencyValues := Map(
            1, 100, 
            2, 170, 
            3, 210, 
            4, 245, 
            5, 255
        )
        hwnd := 0x00000
        winTitle := ""
        class := ""
        title := ""
        /* @prop {Map} transparencyValues */
        transparencyValues := Map(
            1, 100, 
            2, 170, 
            3, 210, 
            4, 245, 
            5, 255
        )
        _CurrentStep := this.transparencyValues.Count
        cycleSteps := True
        enabled := True
        __New(_hwnd) {
            this.hwnd := _hwnd
            this.winTitle := "ahk_id " this.hwnd
            this.class := WinGetClass(this.winTitle)
            this.title := WinGetTitle(this.winTitle)
        }

        Transparency {
            Get => WinGetTransparent(this.winTitle)
            Set => (WinSetTransparent(Value, this.winTitle), Value)
        }

        StepCount => this.transparencyValues.Count
        CurrentStep {
            Get => this._CurrentStep
            Set { 
                if (!!IsInteger(Value) and (Value>=1) and (Value<=this.StepCount)) {
                    this._CurrentStep:=Value
                    this.Transparency := this.transparencyValues[this._CurrentStep]
                } else Tooltip.On(Value " is not a valid transparency step", 1000)
            }
        }
        NearestStep[_transparency] {
            Get {
                nearest := {
                    step: 1,
                    dist: Abs(_transparency-this.transparencyValues[1])
                }
                Loop this.StepCount-1 {
                    _step := A_Index+1
                    _dist := Abs(_transparency - this.transparencyValues[_step])
                    nearest := (_dist < nearest.dist) ? { step: _step, dist: _dist } : nearest
                }
                nearest.dist := _transparency - this.transparencyValues[nearest.step]
                Return nearest
            }
        }

        ResetTransparencyValues() {
            this.transparencyValues := WinTransparency.WinItem.DefaultTransparencyValues
            this.CurrentStep := this.StepCount
            Tooltip.On("(Reset): " this.CurrentStep ": " this.transparencyValues[this.CurrentStep], 1000)
        }

        AddStep(_step, _trans) {
            Loop (startCount:=this.StepCount)-_step+1 {
                _s := startCount-A_Index+1
                this.transparencyValues[_s+1] := this.transparencyValues[_s]
            }
            this.transparencyValues[_step] := _trans
        }

        /**
         * @param {String | Number} _direction
         * 
         *      _direction := "Up"
         *      _direction := "Down"
         *      _direction := -1
         *      _direction := 1
         * 
         *      ; _direction can be a String that reads "Up" or "Down" --- or it can be 
         *      ; an positive/negative Number raising/lowering transparency respectively. 
         *  ----
         * 
         *  ### If ***`WinItem().cycleSteps`*** equates to ***`True`***...
         * 
         * When a step **`down`** is called while the 
         *      **`lowest`** level is active, the **`highest`** level will be set 
         *      as the **`current`** level
         * 
         * Likewise a step **`up`** from the 
         *      **`highest`** level set the **`current`** level to the 
         *      **`lowest`** level
         */
        Step(_direction:="Down") {
            if !!(IsAlpha(_direction)) {
                stepDelta := (_direction="up") ? 1 : ( (_direction="down") ? -1 : 0 )
            } else if !!(IsNumber(_direction)) {
                stepDelta := (_direction>0) ? 1 : ( (_direction<0) ? -1 : 0 )
            }
            newStep := Integer(this.currentStep + stepDelta)
            if !!(newStep < 1)
                newStep := (!!this.cycleSteps) ? this.StepCount : this.currentStep
            else if !!(newStep > this.StepCount)
                newStep := (!!this.cycleSteps) ? 1 : this.currentStep
            this.CurrentStep := newStep
        }
        /**
         * @param {String | Number} _force
         * 
         *      _force := "On"  ;     "On" >-< On
         *      _force := "Off" ;    "Off" >-< Off
         *      _force := 1     ; non-zero >-< On
         *      _force := 0     ;     zero >-< Off
         */
       Toggle(_force:="") {
            wasEnabled := this.enabled
            this.enabled := !this.enabled
            if (!!_force and !!IsAlpha(_force) and (_force~="i)^force\s*\w+$"))
                this.enabled := (_force~="i)\son$") ? (True) : 
                                (_force~="i)\soff$") ? (False) : this.enabled
            else if (!!_force and !!IsNumber(_force))
                this.enabled := (_force!=0) ? (True) : (False)
            if (wasEnabled!=this.enabled) 
                this.Transparency := (!!this.enabled) ? this.transparencyValues[this._CurrentStep] : 255
        }
    }
    
}

; WinT:=WinTransparency
; ^+!a::WinT.StepActive("Down")
; ^+!q::WinT.StepActive("Down"),WinT.StepActive("Down")
; ^+!s::WinT.StepActive("Up")
; ^+!w::WinT.StepActive("Up"),WinT.StepActive("Up")
; ^+!d::WinT.ToggleActive()
; ^+!e::WinT.PromptSetActive()
; ^+!r::WinT.ResetActive()