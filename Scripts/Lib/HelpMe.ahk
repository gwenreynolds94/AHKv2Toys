#Include DBT.ahk


Class FancyArray extends Array {
    RemoveDuplicates() {

    }
    Reverse {
        get {
            rev := []
            Loop this.Length {
                rev.Push this[this.Length-A_Index+1]
            }
            Return rev
        }
    }
}

fancya := FancyArray("integer", "vitae", "justo", "eget", "magna", "fermentum", "iaculis", "eu", "non", "diam")
stdo(fancya*)
stdo(fancya.Reverse*)