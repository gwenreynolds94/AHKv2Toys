




s2do(_msg*) {
    _opts := Map()
    _opts["noprint"] := False
    msgstr := ""
    nestlvl := 0
    indstr := ind_def := " | "
    msglen := _msg.Length
    if msglen {
        msglast := _msg[_msg.Length]
        if (msglast is Object) and ObjHasOwnProp(msglast, "__opts") {
            for _opt, _val in _opts
                if ObjHasOwnProp(msglast.__opts, _opt)
                    _opts.%_opt% := msglast.%_opt%
            _msg.Pop()
        }
    }
    EvalIndent() {
        ind := ""
        Loop nestlvl
            ind .= indstr
        return ind
    }
    TryStringOut(out_item) {
        ind := EvalIndent()
        Try
            Return ind " " String(out_item) "`n"
        Catch MethodError
            Return TryArrayOut(out_item)
    }
    TryArrayOut(out_item) {
        If Type(out_item) = "Array" {
            indent_str_pre := indstr
            indstr := "-|-"
            out_string := TryStringOut("<Array>")
            indstr := indent_str_pre
            nestlvl++
            For item in out_item {
                out_string .= TryStringOut(item)
            }
            nestlvl--
            ; indent_str := indent_str_pre
            Return out_string
        } Else Return TryMapOut(out_item)
    }
    TryMapOut(out_item) {
        If (Type(out_item)="Map") {
            indent_str_pre := indstr
            indstr := "-|-"
            out_string := TryStringOut("<Map>")
            indstr := indent_str_pre
            nestlvl++
            For itemkey, itemval in out_item {
                out_string .= TryStringOut(itemkey)
                nestlvl++
                out_string .= TryStringOut(itemval)
                nestlvl--
            }
            nestlvl--
            ; indent_str := indent_str_pre
            Return out_string
        } Else Return TryObjectOut(out_item)
    }
    TryObjectOut(out_item) {
        If IsObject(out_item) {
            ; indent_str_pre := indent_str
            ; indent_str := "|- "
            If out_string := ComObjType(out_item, "Name")
                Return TryStringOut(out_string)
            indent_str_pre := indstr
            indstr := "=|="
            If ObjHasOwnProp(out_item, "Prototype")
                out_string := TryStringOut("<" out_item.Prototype.__Class ">")
            Else out_string := TryStringOut("<" out_item.__Class ">")
            indstr := indent_str_pre

            if (out_item.__Class = "Enumerator") {
                nestlvl++
                for _key, _value in out_item {
                    out_string .= TryStringOut(_key)
                    nestlvl++
                    out_string .= TryStringOut(_value)
                    nestlvl--
                }
                nestlvl--
            } else {
                For item in ObjGetBase(out_item).OwnProps() {
                    nestlvl++
                    if (item = "OwnProps") {
                        out_string .= TryStringOut(item)
                        for _itm in ObjOwnProps(out_item) {
                            nestlvl++
                            out_string .= TryStringOut(_itm)
                            nestlvl++
                            Try {
                                out_string .= TryStringOut(out_item.%_itm%)
                            }
                            nestlvl--, nestlvl--
                        }
                    } else {
                        Try {
                            out_string .= TryStringOut(item ": " out_item.%item%)
                        } Catch {
                            out_string .= TryStringOut(item)
                        }
                    }
                    nestlvl--
                }
            }

            ; indent_str := indent_default
            Return out_string
        } Else {
            Return
        }
    }
    for _itm in _msg {
        nestlvl := 0
        indstr := ind_def
        msgstr .= TryStringOut(_itm)
    }
    if _opts["noprint"]
        return msgstr
    FileAppend msgstr, "*"
    return msgstr
}


stdo(_msg*) {
    _def_opts := Map()
    _def_opts["noprint"] := False
    _msg_out := ""
    nest_level := 0
    indent_str := indent_default := " | "
    if _msg.Length {
        _last := _msg[_msg.Length]
        if type(_last) == "Object" and ObjHasOwnProp(_last, "__opts") {
            _new_opts := _last.__opts
            for _cfg, _setting in _def_opts {
                if ObjHasOwnProp(_new_opts, _cfg)
                    _def_opts[_cfg] := _new_opts.%_cfg%
            }
            _msg.Capacity := _msg.Length - 1
        }
    }
    TryStringOut(out_item) {
        indent := ""
        Loop nest_level
            indent .= indent_str
        Try {
            Return indent " " String(out_item) "`n"
        } Catch MethodError {
            Return TryArrayOut(out_item)
        }
    }
    TryArrayOut(out_item) {
        If Type(out_item) = "Array" {
            indent_str_pre := indent_str
            indent_str := "-|-"
            out_string := TryStringOut("<Array>")
            indent_str := indent_str_pre
            nest_level++
            For item in out_item {
                out_string .= TryStringOut(item)
            }
            nest_level--
            ; indent_str := indent_str_pre
            Return out_string
        } Else Return TryMapOut(out_item)
    }
    TryMapOut(out_item) {
        If (Type(out_item)="Map") {
            indent_str_pre := indent_str
            indent_str := "-|-"
            out_string := TryStringOut("<Map>")
            indent_str := indent_str_pre
            nest_level++
            For itemkey, itemval in out_item {
                out_string .= TryStringOut(itemkey)
                nest_level++
                out_string .= TryStringOut(itemval)
                nest_level--
            }
            nest_level--
            ; indent_str := indent_str_pre
            Return out_string
        } Else Return TryObjectOut(out_item)
    }
    TryObjectOut(out_item) {
        If IsObject(out_item) {
            ; indent_str_pre := indent_str
            ; indent_str := "|- "
            ; is_varref := !!(out_item is VarRef)
            ;     Return TryStringOut(%out_item%)

            If out_string := ComObjType(out_item, "Name")
                Return TryStringOut(out_string)
            indent_str_pre := indent_str
            indent_str := "=|="
            if (out_item is VarRef)
                Return TryStringOut(%out_item%)
            If ObjHasOwnProp(out_item, "Prototype")
                out_string := TryStringOut("<" out_item.Prototype.__Class ">")
            Else out_string := TryStringOut("<" out_item.__Class ">")
            indent_str := indent_str_pre

            if (out_item.__Class = "Enumerator") {
                nest_level++
                for _key, _value in out_item {
                    out_string .= TryStringOut(_key)
                    nest_level++
                    out_string .= TryStringOut(_value)
                    nest_level--
                }
                nest_level--
            } else {
                For item in ObjGetBase(out_item).OwnProps() {
                    nest_level++
                    if (item = "OwnProps") {
                        out_string .= TryStringOut(item)
                        for _itm in out_item.OwnProps() {
                            nest_level++
                            out_string .= TryStringOut(_itm)
                            nest_level++
                            Try {
                                out_string .= TryStringOut(out_item.%_itm%)
                            }
                            nest_level--, nest_level--
                        }
                    } else {
                        Try {
                            out_string .= TryStringOut(item ": " out_item.%item%)
                        } Catch {
                            out_string .= TryStringOut(item)
                        }
                    }
                    nest_level--
                }
            }

            ; indent_str := indent_default
            Return out_string
        } Else {
            Return
        }
    }
    for _itm in _msg {
        nest_level := 0
        indent_str := indent_default
        _msg_out .= TryStringOut(_itm)
    }
    if _def_opts["noprint"]
        return _msg_out
    FileAppend _msg_out, "*"
    return _msg_out
}

dbgo(_msg*) {
    _msg_out := ""
    nest_level := 0
    indent_str := indent_default := " | "
    TryStringOut(out_item) {
        indent := ""
        Loop nest_level
            indent .= !(A_Index-0) ? (indent_str) : (
                indent .= SubStr(indent_str, 2)
            ,"")
        Try {
            Return ((indent) ? indent " ": "") String(out_item) "`n"
        } Catch MethodError {
            Return TryArrayOut(out_item)
        }
    }
    TryArrayOut(out_item) {
        If Type(out_item) = "Array" {
            indent_str_pre := indent_str
            indent_str := "-|-"
            out_string := TryStringOut("<Array>")
            indent_str := indent_str_pre
            nest_level++
            For item in out_item {
                out_string .= TryStringOut(item)
            }
            nest_level--
            ; indent_str := indent_str_pre
            Return out_string
        } Else Return TryMapOut(out_item)
    }
    TryMapOut(out_item) {
        If (Type(out_item)="Map") {
            indent_str_pre := indent_str
            indent_str := "-|-"
            out_string := TryStringOut("<Map>")
            indent_str := indent_str_pre
            nest_level++
            For itemkey, itemval in out_item {
                out_string .= TryStringOut(itemkey)
                nest_level++
                out_string .= TryStringOut(itemval)
                nest_level--
            }
            nest_level--
            ; indent_str := indent_str_pre
            Return out_string
        } Else Return TryObjectOut(out_item)
    }
    TryObjectOut(out_item) {
        If IsObject(out_item) {
            _hasOwnProps := False
            _shownOwnProps := False
            _shownPrototype := False
            _baseHasOwnProps := False
            _isClass := (out_item is Class)
            Try (ObjGetBase(out_item).OwnProps()), _baseHasOwnProps := True
            Try (out_item.OwnProps()), _hasOwnProps := True
            ; indent_str_pre := indent_str
            ; indent_str := "|- "
            indent_str_pre := indent_str
            indent_str := "=|="

            If out_string := ComObjType(out_item, "Name")
                Return TryStringOut(out_string)

            If ObjHasOwnProp(out_item, "Prototype")
                out_string := TryStringOut(out_item.Prototype)
                ; out_string := TryStringOut("<" out_item.Prototype.__Class ">")
            out_string := TryStringOut("<" out_item.__Class ">-<Type=>" Type(out_item) ">")
            indent_str := indent_str_pre

            if (out_item.__Class="Enumerator") {
                nest_level++
                for _key, _value in out_item {
                    if (_key="__Class") {
                        Try out_string .= TryStringOut(_key ": <" _value ">")
                     } else
                        out_string .= TryStringOut(_key),
                        nest_level++,
                        out_string .=  TryStringOut(_value),
                        nest_level--
                }
                nest_level--
            } else if (Type(out_item)="Map") {
                nest_level++
                ( tmp_item := out_item.Clone() ), ( tmp_item.__Class := "Map_Prototype" )
                ( out_string .= TryStringOut("__Enum(2)") ), nest_level++
                For iname, ival in out_item
                    out_string .= TryStringOut(iname), nest_level++,
                    out_string .= TryStringOut(ival), nest_level--
                nest_level--
                out_string .= TryStringOut(tmp_item)
                nest_level--
            } else if (Type(out_item)="Map_Prototype") {
                nest_level++
                out_string .= TryStringOut(out_item)
                nest_level--
            } else if !!_baseHasOwnProps {
                For item in ObjGetBase(out_item).OwnProps() {
                    nest_level++
                    if (item="OwnProps") {
                        _shownOwnProps := True
                        out_string .= TryStringOut(item)
                        nest_level++
                        out_string .= TryStringOut(out_item.OwnProps())
                        nest_level--
                    }
                    else
                        Try {
                            out_string .= TryStringOut(item ((item="__Class") ? (": <" String(out_item.%item%) ">") : (": " String(out_item.%item%))))
                        } Catch {
                            if item = "Prototype" {
                                Try {
                                    out_string .= TryStringOut(item)
                                  , nest_level++
                                  , out_string .= TryStringOut(item.Prototype)
                                    ; out_string .= TryStringOut(item ": " out_item.%item%.__Class)
                                } Catch
                                    out_string .= TryStringOut(item)
                                nest_level--
                            } else out_string .= TryStringOut(item)
                        }
                    nest_level--
                }
                if ((!!_isClass or !_shownOwnProps) and !!_hasOwnProps)
                    Try
                        for _itm, _val in out_item.OwnProps()
                            nest_level++,
                            out_string .= TryStringOut(_itm),
                            nest_level++,
                            out_string .= TryStringOut(_val),
                            nest_level--, nest_level--
                if ObjGetBase(out_item) {
                    nest_level++
                    out_string .= TryStringOut("Base")
                    nest_level++
                    out_string .= TryStringOut(out_item.Base)
                    out_string .= TryStringOut("OwnProps")
                    nest_level++
                    out_string .= TryStringOut(out_item.Base.OwnProps())
                    nest_level--, nest_level--, nest_level--
                }
            } else {
                nest_level++
                Try
                    For _itm, _val in out_item
                        if (_itm="__Class")
                            out_string .= TryStringOut(_key ": <" _value ">")
                        else
                            out_string .= TryStringOut(_itm),
                            nest_level++,
                            out_string .= TryStringOut(_val),
                            nest_level--
                Catch
                    Try
                        For _itm, _val in out_item.OwnProps()
                            if (_itm="__Class")
                                out_string .= TryStringOut(_key ": <" _value ">")
                            else
                                out_string .= TryStringOut(_itm),
                                nest_level++,
                                out_string .= TryStringOut(_val),
                                nest_level--
                nest_level--

            }
            ; indent_str := indent_default
            Return out_string
        } Else Return
    }
    for _itm in _msg {
        nest_level := 0
        indent_str := indent_default
        _msg_out .= TryStringOut(_itm)
    }
    OutputDebug(_msg_out)
    Return _msg_out
}

_TryString(_AsString) {
    Try {
        Return {Valid: True, Value: String(_AsString)}
    } Catch {
        Return {Valid: False, Value: False}
    }
}

_TryInt(_AsInt) {
    Try {
        Return {Valid: True, Value: Integer(_AsInt)}
    } Catch {
        Return {Valid: False, Value: False}
    }
}

stdoplain(_msg*) {
    for _m in _msg
        FileAppend _m, "*"
}

/**
 * Upon initialization of a new instance, the tick frequency is fetched and stored -- so that the
 *      tick count can be divided by it upon retrieval and multiplied by 1000, resulting in
 *      a return value calculated in milliseconds.
 *
 * The counter will not start until *`this.Start()`* is called and will not stop until
 *      *`this.Stop()`* is called, which will return the tick count in ms.
 *
 * Calling *`this.Lap()`* will push the current tick count to *`this._laps[]`*.
 *
 * Lastly, the current tick count can be retrieved at any time using *`this.GetCurrentCounter()`*.
 *      By default, this value is passed through *`this.ToMilliseconds(&ms)`* before being returned,
 *      but you can set *`this.ms`* to ***False*** to change this behaviour.
 */
Class PerfCounter {
    start := 0
    _laps := []
    __New() {
        DllCall "QueryPerformanceFrequency", "Int*", &freq := 0
        this.frequency := freq
        this.ms := True
    }
    StartTimer() {
        this.start := this.GetCurrentCounter()
        this.laps := []
        this.laps.Push(this.start)
    }
    StopTimer() {
        this.end := this.GetCurrentCounter()
        this.laps.Push(this.end)
        Return this.end - this.start
    }
    Lap() {
        this.now := this.GetCurrentCounter()
        this.laps.Push(this.now)
        Return this.now-this.laps[this.laps.Length-1]
    }
    ToMilliseconds(&_p_count) {
        Return _p_count := _p_count / this.frequency * 1000
    }
    GetCurrentCounter() {
        DllCall "QueryPerformanceCounter", "Int*", &counter := 0
        if this.ms
            this.ToMilliseconds(&counter)
        Return counter
    }
}
