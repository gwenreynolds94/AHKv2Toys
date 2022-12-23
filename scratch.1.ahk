;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk
#Include Utils\DllCoords.ahk

Tooltip.On := {
    Call: (_this, _daddy, _msg:="", _dur:=False) => (
        Tooltip(_msg),
        (!!_dur and IsInteger(_dur)) ? (SetTimer((*)=>Tooltip(), _dur), True) : False
    )
}
Tooltip.Off := {
    Call: (_this, _daddy, _delay:=1000) => (SetTimer((*)=>Tooltip(), _delay))
}


; if FileExist(A_Temp "\wlan.tmp")
    ; FileDelete(A_Temp "\wlan.tmp")
; RunWait A_ComSpec " /c netsh wlan show interfaces >> " A_Temp "\wlan.tmp",, "Hide"
; i_wlan := FileRead(A_Temp "\wlan.tmp")
; /* @type {RegExMatchInfo} */
; mt_ssid:=""
; FileDelete(A_Temp "\wlan.tmp")
; RegExMatch i_wlan, "mi)SSID\s*:\s*([^\r]+)", &mt_ssid

; i_ssid := RTrim( LTrim(mt_ssid[0]) )
; s_ssid := RegExReplace(i_ssid, "(^SSID\s*:\s*)(?=\S.+$)", '')
; dbgo s_ssid


someFunc := (*)=>("")
dbgo someFunc()
; dbgo Map
; dbgo RegExReplace(mapres, "m)(^(.\|(.{3})))")


F8::ExitApp
