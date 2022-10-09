

Class FancyArray extends Array {
    RemoveDuplicates() {

    }
    Reverse {
        Get {
            rev := []
            Loop this.Length {
                rev.Push this[this.Length-A_Index+1]
            }
            Return rev
        }
    }

    StdOut(Options:="") {
        If Options and InStr(Options, "Reverse")
            iter := this.Reverse
        Else iter := this
        For item in iter
            If A_Index = 0
                outString := item
            Else outString .= "`n" item
        FileAppend outString, "*"
    }

    RegExed[RegEx] {
        Get {
            RegExArray := []
            For item in this {
                isntString := False
                RegExedItem := {}
                Try {
                    item := String(item)
                    RegExMatch item, RegEx, &RegExResult
                    
                } Catch MethodError {
                    isntString := True
                }
            }
        }
    }
}

fancya := FancyArray("integer", "vitae", "justo", "eget", "magna", "fermentum", "iaculis", "eu", "non", "diam")
fancya.StdOut
fancya.StdOut "Reverse"