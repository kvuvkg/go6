Set include=d:\clip\include
Set Lib=d:\clip\lib

erase %1.exe
clipper %1 /B/N
if not errorlevel 1 rtlink file %1, d:\clip\lib\ftools1 lib ftoolsx, ftools1, fproplus
erase %1.obj