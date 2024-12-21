@echo off

del bin\fisch_bgfx.exe
cd _build\make
make
cd ..\..\bin
fisch_bgfx
cd ..
