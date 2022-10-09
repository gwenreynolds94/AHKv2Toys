#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetMouseDelay -1

indexHTML := "https://docs.rs/scintilla-sys/4.0.3/scintilla_sys/index.html"

ffdrive := ComObject("Selenium.IEDriver")
ffdrive.Get(indexHTML)

constants := ffdrive.FindElementsByClass("constant", 60, ComValue(0xB, True))
urls := []
Loop 5 {
      urls.Push constants[A_Index].Attribute("href")
}

Loop 5 {
      ffdrive.Get(urls[A_Index])
      constElement := ffdrive.FindElementByClass("const")
      constElementHTML := constElement.Attribute("innerHTML")
      RegExMatch constElementHTML, "(?<=const\s)\b\w+\b", &constElementRGXMatch
      constName := constElementRGXMatch[0]
      constValue := constElement.FindElementsByTag("code")[2].Attribute("innerHTML")
      FileAppend "Name: " constName "`n`t" constValue, "*"
}