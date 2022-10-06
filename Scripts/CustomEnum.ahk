#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>

Class Enumera {
    __New(values_in*) {
        this.values := values_in
    }
    __Enum(NumberOfVars) {
        i := this.values.Length
        EnumerateElements(&element) {
            if i = 0
                Return False
            element := this.values[i]
            i--
            Return True
        }
        Return EnumerateElements.Bind()
    }
}

something := Enumera("a", "b", "c", "d" ,"e", "f")
for a in something
    stdo a