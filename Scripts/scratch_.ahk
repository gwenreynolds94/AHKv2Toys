#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>

tstmap := Map("IntKeyOne", 1
            , "IntKeyTwo", 2
            , "ObjKeyOne", { ItemOne: "F!r$t !t3m"
                           , ItemTwo: "$3c0nd !t3m" }
            , "ObjKeyTwo", { AnotherItemOne: "4n0th3r F!r$t !i3m"
                           , AnotherItemTwo: "4n0th3r $3c0nd !t3m" })

tBuff := Buffer(16)
StrPut("something", tBuff.Ptr)
NumPut("UInt", 666, tBuff.Ptr+20)
StrPut("anothersomething", tBuff.Ptr+24)
stdo NumGet(tBuff.Ptr+20, "UInt")
stdo StrGet(tBuff.Ptr+24)
stdo tBuff.Size
VarSetStrCapacity &tBuff, -1
stdo StrGet(tBuff)

BufferToMap(oBuffer) {

}

; bytes 1-4 is a UInt, the number of first-level items
; byts 5-(4n+4), a sequence of in UInts to know where to look for those items
; 
MapToBuffer(oMap) {
    
}