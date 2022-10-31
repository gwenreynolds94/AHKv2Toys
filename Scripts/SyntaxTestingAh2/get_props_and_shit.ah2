#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>

aOb := "Any|Array|BoundFunc|Buffer|Class|ClipboardAll|Closure|ComObjArray" "|"
       . "ComObject|ComValueRef|ComValue|Enumerator|Error|File|Float|Func" "|"
        .      "Gui|IndexError|InputHook|Integer|Map|MemberError" "|" ; |KeyError
         .    "MemoryError|MenuBar|Menu|MethodError|Number|Object|OSError" "|"
          .    "Primitive|PropertyError|RegExMatchInfo|String|TargetError" "|"
           .  "TimeoutError|TypeError|ValueError|VarRef|ZeroDivisionError"

arOb := StrSplit(aOb, "|")
for itm in arOb
    for prp in %itm%.OwnProps() {
        if (prp="Prototype")
            for pp in %itm%.%prp%.OwnProps()
                stdo pp
        stdo prp
    }