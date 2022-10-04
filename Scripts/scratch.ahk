obj := Map("abc", Map())
ano := Map("ther", "you")
obj["abc"][ano["ther"]] := "no"
FileAppend obj["abc"]["you"], "*"