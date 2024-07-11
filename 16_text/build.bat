@echo off

del text.exe

:: only on linux: -sanitize:memory -sanitize:thread
:: -sanitize:address
REM odin run src -out:text.exe  -vet-unused -vet-unused-variables -vet-unused-imports -vet-shadowing -vet-using-stmt  -debug
odin run src -out:text.exe  -vet-shadowing -vet-using-stmt  -debug
