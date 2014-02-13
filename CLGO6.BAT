Set include=d:\clip\include
Set Lib=d:\clip\lib
erase go6.exe
d:\clip\clipper go6 
d:\clip\clipper Ved 
d:\clip\clipper pubnsi
d:\clip\clipper PlPor6
d:\clip\clipper PrnNaklF
d:\clip\clipper i18n
d:\clip\clipper ndsnew
if not errorlevel 1 d:\clip\rtlink file go6,ved,pubnsi,plPor6,PrnNaklF,i18n,ndsnew,d:\clip\lib\ftools1 LIB ftoolsx,ftools1,fproplus
erase go6.obj
erase ved.obj
erase pubnsi.obj
erase plpor6.obj
erase prnNaklf.obj
erase i18n.obj
erase ndsnew.obj
