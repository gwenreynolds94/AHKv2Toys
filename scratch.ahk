#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include <DEBUG\DBT>

/**

Tooltip.On := {
    Call: (_this, _daddy, _msg := "", _dur := False) => (
        Tooltip(_msg),
        (!!_dur and IsInteger(_dur)) ? (SetTimer((*) => Tooltip(), _dur), True) : False
            )
}
Tooltip.Off := {
    Call: (_this, _daddy, _delay := 1000) => (SetTimer((*) => Tooltip(), _delay))
}

Class Main {
    Class Conf {
        Class General {
            g000 := 000
            g111 := 111
            g222 := 222
            g333 := 333
        }
        Class Paths {
            p000 := 000
            p111 := 111
            p222 := 222
            p333 := 333
        }
        Class Enabled {
            e000 := 000
            e111 := 111
            e222 := 222
            e333 := 333
        }
        Class Installs {
            i000 := 000
            i111 := 111
            i222 := 222
            i333 := 333
        }
    }
}

*/

; RunForEachInArray(_runFunc, _arr) {
;     _out := Array()
;     for _i in _arr
;         _out.Push _runFunc(_i)
;     return _out
; }

; WinGetTitleList() {
;     _wmap := Map()
;     for _hwnd in WinGetList()
;         if A_Index < 4
;             _wmap[_hwnd] := WinGetTitle(_hwnd)
;     Return _wmap
; }


; WGL_ForEach(_parent, runFunc, runArgs:="") {
;     _parent.ForEachResult := {for: [], each: []}
;     for _i in _parent(runArgs)
;         _parent.ForEachResult.for.Push(_i), _parent.ForEachResult.each.Push(runFunc(_i))
;     Return _parent.ForEachResult
; }
; WinGetList.ForEach := WGL_ForEach
; WinGetList.ForEach((_hwnd)=>(WinGetTitle("ahk_id " _hwnd)))

; /**
;  * @param {Func} _wgl => WinGetList
;  * @param {Array} _arr => Store titles in an array
;  * @param {String} _str => Store titles in a newline delimited string
;  * @param {Array} _args => Variadic function arguments to pass to WinGetList
;  */
; WGL_Titles(_wgl, &_arr?, &_str?, _args*){
;     _wList := _wgl(_args*)
;     _A := []
;     _S := ""
;     LoadArray() {
;         for _hwnd in _wList
;             _A.Push WinGetTitle("ahk_id " _hwnd)
;     }
;     LoadString() {
;         for _item in (IsSet(_arr) ? (_A) : _wList)
;             _S .= IsSet(_arr) ? (_item "`n") : (WinGetTitle("ahk_id " _item) "`n")
;     }
;     if IsSet(_arr)
;         LoadArray(), _arr:=_A
;     if IsSet(_str)
;         LoadString(), _str:=_S
; }
; ; @prop {Func} Titles
; WinGetList.Titles := WGL_Titles
; WinGetList.Titles(&aria:=0, &sari:=0)
; dbgo aria, sari

; Class Win {
;     Static List := (wTitle, wText, notTitle, notText)=>WinGetList(wTitle, wText, notTitle, notText)
;     Static Class := (wTitle, wText, notTitle, notText)=>WinGetClass(wTitle, wText, notTitle, notText)
;     Static Title := (wTitle, wText, notTitle, notText)=>WinGetTitle(wTitle, wText, notTitle, notText)
;     Static PID := (wTitle, wText, notTitle, notText)=>WinGetPID(wTitle, wText, notTitle, notText)
;     Static PName := (wTitle, wText, notTitle, notText)=>WinGetProcessName(wTitle, wText, notTitle, notText)
;     Static PPath := (wTitle, wText, notTitle, notText)=>WinGetProcessPath(wTitle, wText, notTitle, notText)
;     Call() {
;
;     }
; }

; _gui:=Gui("+Resize")
; _gui.OnEvent("Close", (*)=>ExitApp())
; hGui := WinExist(_gui)
; pWndProc := CallbackCreate(UserWndProc)
; vSfx := "Ptr"
; 
; pWndProcOld := DllCall( "SetWindowLong" vSfx ;
                      ; , "Ptr", hGui          ;
                      ; , "Int" , -4           ;
                      ; , "Ptr" , pWndProc     ;
                      ; , "Ptr"                )
; 
; _text := _gui.Add("Text", "w500 h700", "Click fuckin somewhere")
; _gui.Show("x10 y10 w" A_ScreenWidth-20 " h" A_ScreenHeight-20)
; 
; UserWndProc(hWnd, uMsg, wParam, lParam) {
    ; global pWndProcOld
    ; if (uMsg = (WM_LBUTTONDOWN:=0x201))
        ; Tooltip.On( A_Now " " A_MSec " msg 0x201", 1000)
    ; else if (uMsg=(WM_SIZE := 0x0005)) {
        ; Tooltip.On( A_Now " " A_MSec " msg 0x0214 " (lParam & 0xFFFF) ", " (lparam>>16), 1000)
; 
    ; }
    ; if (uMsg = 0x5555)
        ; Tooltip.On( A_NOw  " " A_MSec " msg 0x5555", 1000)
    ; return DllCall( "CallWindowProc"
                  ; , "Ptr", pWndProcOld
                  ; , "Ptr", hWnd
                  ; ,"UInt", uMsg
                  ; ,"UPtr", wParam
                  ; , "Ptr", lParam )
; }
; 
; #F9::
; {
    ; DetectHiddenWindows "On"
    ; PostMessage 0x5555,,,, "ahk_id " hGui
; }

; Class LeaderKey {
    ; leader := ""
    ; , keys := Map()
    ; , enabled := False
    ; , bmeth := {}
    ; , timeout := 2000
; 
    ; /**
     ; * @param {String} _leader
     ; */
    ; __New(_leader:="#a") {
        ; this.leader := _leader
        ; this.bmeth.activate := ObjBindMethod(this, "ActivateLeader")
        ; this.bmeth.deactivate := ObjBindMethod(this, "DeactivateLeader")
        ; Hotkey this.leader, this.bmeth.activate
    ; }
; 
    ; ActivateLeader(*) {
        ; SetTimer this.bmeth.deactivate, (this.timeout*(-1))
        ; for k, a in this.keys {
            ; Hotkey k, a, "On"
        ; }
    ; }
; 
    ; DeactivateLeader(*) {
        ; for k, a in this.keys {
            ; Hotkey k, a, "Off"
        ; }
    ; }
; 
    ; BindKey(_key, _act) {
        ; this.keys[_key] := _act
    ; }
; }

; main_leader := LeaderKey()
; 
; IterLK(*) {
    ; stdo main_leader
; }
; 
; main_leader.BindKey(
    ; "h",
    ; IterLK
; )
 ; stdo "", "", main_leader
; 
; 

dbgo Gui()


F8:: ExitApp
; 
; 
; F10::
; {
    ; 
; }
