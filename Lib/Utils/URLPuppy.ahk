#Include BuiltinsExtend.ahk


Class URLPuppy {
    static chars_encoded := Map(
        '\+', '%2B',
        '\,', '%2C',
        '\/', '%2F',
        '\\', '%5C',
        '\#', '%23',
        '\$', '%24',
        '\%', '%25',
        '\&', '%26',
        "\'", '%27',
        '\s', '+'
    )

    static Encode(_url) {
        for char, code in this.chars_encoded
            _url := _url.Replace(char, code)
        return _url
    }

    static BuildDDGSearch(_search) {
        return 'https://www.duckduckgo.com/?q=' URLPuppy.Encode(_search)
    }
}