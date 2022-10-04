
DBT_LOAD() {

}

stdo(_msg*) {
    _msg_out := ""
    for _m in _msg {
        if IsObject(_m) {
            for _om in _m.OwnProps()
                _msg_out .= "<" _om ">`n"
        } else {
            _msg_out .= _m "`n"
        }
    }
    FileAppend _msg_out, "*"
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
    ToMilliseconds(&count) {
        Return count := count / this.frequency * 1000
    }
    GetCurrentCounter() {
        DllCall "QueryPerformanceCounter", "Int*", &counter := 0
        if this.ms
            this.ToMilliseconds(&counter)
        Return counter
    }
}