@echo off

del deferred.exe

:: only on linux: -sanitize:memory -sanitize:thread
:: -sanitize:address
odin run src -out:deferred.exe  -vet-unused -vet-unused-variables -vet-unused-imports -vet-shadowing -vet-using-stmt  -debug
