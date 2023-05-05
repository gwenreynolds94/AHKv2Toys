#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <DEBUG\DBT>
#Include <Utils\BuiltinsExtend>

;
; browsers := [
;     'Maxthon.exe',
;     'waterfox.exe',
;     'firefox.exe',
;     'waterfox.exe'
;     'chrome.exe',
;     'msedge.exe',
;     'wezterm.exe',
;     'pwsh.exe'
; ]
;
; APATH := []
; loop parse EnvGet('PATH'), ';'
;     APATH.Push A_LoopField
;
; found := []
;
; for _b in browsers
;     for _p in APATH
;         if FileExist(_pp:=(RegExReplace(_p, '\\$') '\' _b))
;             found.Push _pp
;
; Try Run 'waterfox.exe'
; Catch error as werr
;     stdo werr.OwnProps()
;
; stdo found

stdo [1,2,43,5,6,24321,44].Extend([1,2,3,5], [666,777,888])
                          .Length

SetTimer ( ( * ) => ExitApp() ), -6666

F8:: ExitApp
