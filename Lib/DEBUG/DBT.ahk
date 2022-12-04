

stdo(msg*) {
    msg_out := ""
    nest_level := 0
    indent_str := indent_default := " | "
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
            If out_string := ComObjType(out_item, "Name")
                Return TryStringOut(out_string)
            indent_str_pre := indent_str
            indent_str := "=|="
            If out_item.HasOwnProp("Prototype")
                out_string := TryStringOut("<" out_item.Prototype.__Class ">")
            Else out_string := TryStringOut("<" out_item.__Class ">")
            indent_str := indent_str_pre

            if (out_item.__Class="Enumerator") {
                nest_level++
                for _key, _value in out_item {
                    out_string .= TryStringOut(_key)
                    nest_level++
                    out_string .=  TryStringOut(_value)
                    nest_level--
                }
                nest_level--
            } else For item in ObjGetBase(out_item).OwnProps() {
                nest_level++
                if (item="OwnProps") {
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
                } else 
                    Try {
                        out_string .= TryStringOut(item ": " out_item.%item%)
                    } Catch {
                        out_string .= TryStringOut(item)
                    }
                nest_level--
            }
            ; indent_str := indent_default
            Return out_string
        } Else {
            Return
        }
    }
    TryEnumOut(out_item) {
        
    }
    for itm in msg {
        nest_level := 0
        indent_str := indent_default
        msg_out .= TryStringOut(itm)
    }
    FileAppend msg_out, "*"
}

TryString(_AsString) {
    Try {
        Return {Valid: True, Value: String(_AsString)}
    } Catch {
        Return {Valid: False, Value: False}
    }
}

TryInt(_AsInt) {
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


Class PerfCounter {
    start := 0
    laps := []
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