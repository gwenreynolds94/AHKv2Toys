
#SingleInstance Force

wTitle := "System Properties"
wTitleEnv := "Environment Variables"

if !WinExist(wTitle) {
   Run "C:\Windows\System32\SystemPropertiesAdvanced.exe"
   WinWait(wTitle,, 5)
   WinActivate()
   wHwnd:=WinWaitActive(wTitle,, 5)
   (!!wHwnd) ? (ControlClick("Button7")) : (ExitApp())
} else {
   if !WinExist(wTitleEnv) {
       WinActivate(wTitle)
       wHwnd:=WinWaitActive(wTitle,, 5)
       (!!wHwnd) ? (ControlClick("Button7")) : (ExitApp())
   } else {
       WinClose(wTitleEnv)
       WinWaitClose()
       WinClose(wTitle)
   }
}

ExitApp()
