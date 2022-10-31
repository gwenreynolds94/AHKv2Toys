

stdo(msg*) {
    msg_out := ""
    TryStringOut(out_item, isMapVal:=False) {
        Try {
            Return String(out_item) "`n"
        } Catch MethodError {
            Return TryArrayOut(out_item, isMapVal)
        }
    }
    TryArrayOut(out_item, isMapVal:=False) {
        If Type(out_item) = "Array" {
            out_string := ""
            For item in out_item {
                if isMapVal
                    out_string .= "`t"
                out_string .= TryStringOut(item)
            }
            Return out_string
        } Else Return TryMapOut(out_item)
    }
    TryMapOut(out_item) {
        If Type(out_item) = "Map"{
            out_string := ""
            For itemkey, itemval in out_item {
                out_string .= TryStringOut(itemkey)
                            . ">" TryStringOut(itemval, True)
            }
            Return out_string
        } Else Return TryObjectOut(out_item)
    }
    TryObjectOut(out_item) {
        If IsObject(out_item) {
            If out_string := ComObjType(out_item, "Name")
                Return out_string
            If out_item.HasOwnProp("Prototype")
                out_string := "<" out_item.Prototype.__Class ">`n"
            Else out_string := "<" out_item.__Class ">`n", out_item := ObjGetBase(out_item)
            For item in out_item.OwnProps()
                out_string .= "`t" item "`n"
            Return out_string
        } Else {
            Return
        }
    }
    for itm in msg {
        msg_out .= TryStringOut(itm)
    }
    FileAppend msg_out, "*"
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