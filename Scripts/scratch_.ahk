#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetMouseDelay -1

#Include <DBT>

ts := [ "abcdefghijklmnopqrstuvwxyz"
      , "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      , "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      , "------abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789______"
      , "------ abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 ______" ]

patterns := [ "[a-z]+"
            , "[a-zA-Z]+"
            , "^[a-zA-Z0-9]+$"
            , "[a-zA-Z0-9_\-]+"
            , "[a-zA-Z0-9_\-\s]+" ]


RegExMatch ts[2], patterns[2], &rMatch
stdo rMatch[0]
RegExMatch ts[4], patterns[5], &rMatch
stdo rMatch[0]
stdo (ts[3] ~= patterns[3])