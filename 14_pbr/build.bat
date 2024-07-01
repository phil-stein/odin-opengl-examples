@echo off

del pbr.exe

:: only on linux: -sanitize:memory -sanitize:thread
:: -sanitize:address
odin run src -out:pbr.exe  -vet-unused -vet-unused-variables -vet-unused-imports -vet-shadowing -vet-using-stmt  -debug
