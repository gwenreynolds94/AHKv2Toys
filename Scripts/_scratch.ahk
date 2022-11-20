#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>


DoHickey() {
    if True and
            !False {
        FileAppend("(True and !False) is True", "*")
    }
}

/* 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  In condition statments,
    When a certain operator is the first character on the line,
    and a block begins after the statement on the same line,
    an "Unexpected '{'" error is thrown
   * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*/


; Error thrown ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

if True and
        ~False {        ; Unexpected '{'
    FileAppend(1, "*")
}

loop (True) .
        !(False) {      ; Unexpected '{'
    FileAppend(2, "*")
}

while True -
        !False {        ; Unexpected '{'
    FileAppend(3, "*")
}

foo := 666
if 500 <
        --foo {         ; Unexpected '{'
    FileAppend(4, "*")
}

; No errors thrown ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;

if True
        and !False {
    FileAppend(5, "*")
}

if True .
        False {
    FileAppend(6, "*")
}

loop True +
    !False 
{
    FileAppend(7, "*")
}

F7::DoHickey
F8::ExitApp