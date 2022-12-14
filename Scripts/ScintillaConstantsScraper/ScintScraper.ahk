#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\..\Lib\
#Include DEBUG\DBT.ahk

indexHTML := "https://docs.rs/scintilla-sys/4.0.3/scintilla_sys/index.html"

; after running Selenium Basic install as administrator
; ... the COM object will become available ->
; ... http://florentbr.github.io/SeleniumBasic/
ffdrive := ComObject("Selenium.IEDriver")

ffdrive.Get(indexHTML)

constants := ffdrive.FindElementsByClass("constant", 60, ComValue(0xB, True))
urls := []

Loop 1151 {
      urls.Push constants[A_Index].Attribute("href")
}

Loop 1151 {
      ffdrive.Get(urls[A_Index])
      constElement := ffdrive.FindElementByClass("const")
      constElementHTML := constElement.Attribute("innerHTML")
      RegExMatch constElementHTML, "(?<=const\s)\b\w+\b", &constElementRGXMatch
      constName := constElementRGXMatch[0]
      constValue := constElement.FindElementsByTag("code")[2].Attribute("innerHTML")
      FileAppend constName "`t" constValue "`n", "ScintillaConstants.txt"
}