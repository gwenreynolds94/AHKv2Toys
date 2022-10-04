
DBT_LOAD() {

}

stdo(_msg*) {
    _msg_out := ""
    for _m in _msg {
        if IsObject(_m) {
            for _om in _m.OwnProps() {
                _msg_out .= "<" _om ">`n"
            }
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
