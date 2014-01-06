#include "inkey.ch"
//////////////////////////////////////////////////////////////////////
// Формирование ведомости РАСЧЕТ С ПОТРЕБИТЕЛЯМИ
Function VedRas()
Local cLine := sset[112][2], Arr_Shet, Arr_Chet, i, j, nLastRec,;
      nSumma, nRecno, nPos, Pos_Skk, oFile, dDataRas, Itog
Private nPage := 0, nLine := 60
      
S_FileDel(cLine+"Work.*")
Arr_Shet := { {"Ent",  "N",04,00},;   // код организации
              {"Tip",  "N",01,00},;   // Тип организации
              {"Naim", "C",30,00},;   // наименование
              {"SND",  "N",13,02},;   // сальдо на начало ДЕБЕТ
              {"SNK",  "N",13,02},;   // сальдо на начало КРЕДИТ
              {"ITK",  "N",13,02},;   // ИТОГО по КРЕДИТУ
              {"ITD",  "N",13,02},;   // ИТОГО по КРЕДИТУ
              {"SKD",  "N",13,02},;   // сальдо на конец ДЕБЕТ
              {"SKK",  "N",13,02},;   // сальдо на конец КРЕДИТ
              {"Summa","N",13,02} }
Pos_Sdd := Len(Arr_Shet) + 1
for i := 1 to 10
  aadd(Arr_Shet,{"D"+alltrim(str(i,2)),"N",13,02}) // дебетовые счета
next
Pos_Skk := Len(Arr_Shet) + 1
for i := 1 to 10
  aadd(Arr_Shet,{"K"+alltrim(str(i,2)),"N",13,02}) // кредитовые счета
next
Dbcreate(cLine+"WORK",Arr_Shet)
use (cLine+"WORK") new
Index on str(Ent,4) to (cLine+"WORK")
nLastRec := Ostatok->(LastRec()) + Prixod->(LastRec()) + Rasxod->(LastRec())
nSumma := "[ Ожидайте...  Формирую рабочую базу ]"
S_Line_N(18,04,65,nLastRec,1)
@ 00,(MaxCol()-len(nSumma))/2 say nSumma
nRecno := 0
//    Переносим остатки в рабочую базу
Ostatok->(DbClearRel())
Ostatok->(DbSetRelation("S_Ent", {|| str(Ent,4) },"str(Ent,4)"))
if !Ostatok->(DbSeek(str(0,4)))  ;  return ( Nil ) ; end
nSumma := Alltrim(str(Ostatok->Summa,10))
dDataRas := ctod(Substr(nSumma,7,2)+"."+Substr(nSumma,5,2)+"."+Substr(nSumma,1,4))
Ostatok->(DbSkip(1))
While ( !Ostatok->(eof()) )
  Work->(Dbappend())
  Work->Ent := Ostatok->Ent
  Work->Tip  := S_Ent->Tip
  Work->Naim := S_Ent->Naim
  Work->Snd  := if(Ostatok->Summa>=0,Ostatok->Summa,0)
  Work->Snk  := if(Ostatok->Summa<0,-Ostatok->Summa,0)
  Work->Summa:= Ostatok->Summa
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Ostatok->(DbSkip(1))
End
Ostatok->(DbClearRel())
//    Переносим ПРИХОД в рабочую базу КРЕДИТ
Akk_Shet := {}
Prixod->(DbClearRel())
Prixod->(DbSetRelation("S_Ent", {|| str(Ent,4) },"str(Ent,4)"))
Prixod->(DbGoTop())
While ( !Prixod->(eof()) )
  if !Work->(DbSeek(str(Prixod->Ent,4)))
     Work->(DbAppend())
     Work->Ent  := Prixod->Ent
     Work->Naim := S_Ent->Naim
     Work->Tip  := S_Ent->Tip
  End
  if ( nPos := ascan(Akk_Shet, {|x| x[1] == Prixod->Chet }) ) == 0
       nPos := len(Akk_Shet)
       aadd(Akk_Shet,{Prixod->Chet,++nPos})
  End
  i := Work->(Pos_Skk + nPos )
  nSumma := Work->(FieldGet(i))
  Work->(FieldPut(i,nSumma+Prixod->Summa))
  Work->Summa += Prixod->Summa
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Prixod->(Dbskip(1))
End
Prixod->(DbClearRel())
//    Переносим РАСХОД в рабочую базу ДЕБЕТ
Add_Shet := {}
Rasxod->(DbClearRel())
Rasxod->(DbSetRelation("S_Ent", {|| str(Ent,4) },"str(Ent,4)"))
Rasxod->(DbGoTop())
While ( !Rasxod->(eof()) )
  if !Work->(DbSeek(str(Rasxod->Ent,4)))
     Work->(DbAppend())
     Work->Ent  := Rasxod->Ent
     Work->Naim := S_Ent->Naim
     Work->Tip  := S_Ent->Tip
  End
  if ( nPos := ascan(Add_Shet,{|x| x[1] == Rasxod->Chet }) ) == 0
       nPos := len(Add_Shet)
       aadd(Add_Shet,{Rasxod->Chet,++nPos})
  End
  i := Work->(Pos_Sdd + nPos )
  nSumma := Work->(FieldGet(i))
  Work->(FieldPut(i,nSumma+Rasxod->Summa))
  Work->Summa -= Rasxod->Summa
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Rasxod->(Dbskip(1))
End
Rasxod->(DbClearRel())
S_Line_N()
//  Остатки по ведомости РАСЧЕТ С ПОТРЕБИТЕЛЯМИ на следующий месяц
nLastRec := 2*Work->(LastRec())
nSumma := "[ Ожидайте...  Формирую ведомость ]"
S_Line_N(18,04,65,nLastRec,1)
@ 00,(MaxCol()-len(nSumma))/2 say nSumma
nRecno := 0
cLine := sset[112][1]
S_FileDel(cLine+"OSTNEW.*")
DbCreate(cLine+"OSTNEW",{ {"Ent",  "N",04,00},;   // код организации
                         {"Summa","N",13,02} })  // сумма остатка
use (cLine+"OSTNEW") new
Index on str(Ent,4) to (cLine+"OSTNEW")
if Ostatok->(DbSeek(str(0,4)))  // Вставляем фиктивную запись
   nSumma := Alltrim(str(Ostatok->Summa,10))
   nSumma := ctod(Substr(nSumma,7,2)+"."+Substr(nSumma,5,2)+"."+Substr(nSumma,1,4))
   nSumma := S_AddMon(nSumma,1)
   OstNew->(Dbappend())
   OstNew->Ent := 0
   OstNew->Summa := val(dtos(nSumma))
End
nPos_dd := Len(Add_Shet)
nPos_kk := Len(Akk_Shet)
Work->(DbGoTop())
While ( !Work->(eof()) )
  nDebet := nKredit := 0
  For i := 1 to nPos_dd
     nDebet += Work->(FieldGet( Pos_Sdd + Add_Shet[i][2] ))
  next
  For i := 1 to nPos_kk
     nKredit += Work->(FieldGet( Pos_Skk + Akk_Shet[i][2] ))
  next
  nSumma := ( -Work->Snk + Work->Snd ) + ( nDebet - nKredit )
  Work->Itk  := nKredit
  Work->Itd  := nDebet
//  Work->Skd  := if(nSumma>=0,nSumma,0)
//  Work->Skk  := if(nSumma<0,-nSumma,0)
  Work->Skd  := if(Work->Summa>=0,Work->Summa,0)
  Work->Skk  := if(Work->Summa<0,-Work->Summa,0)
  OstNew->(DbAppend())
  OstNew->Ent   := Work->Ent 
  OstNew->Summa := Work->Summa
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Work->(Dbskip(1))
End
//         ВСЕ ГОТОВО ----- Формируем наконец-то ведомость
S_FileDel(sset[112][2]+"p*.ved")
Add_Shet := aSort(Add_Shet,,,{|x,y| x[1]<y[1] })
Akk_Shet := aSort(Akk_Shet,,,{|x,y| x[1]<y[1] })
Arr_Chet := { ;
 { {|x| Work->Naim },{|x| 0 },2,{":"+space(30),":"+padc("Организация",30)} },;
 { {|x| str(Work->SnD,13,2) },{|x| Work->SnD },3,{":сальдо на нач",":  дебет      "} },;
 { {|x| str(Work->SnK,13,2) },{|x| Work->SnK },4,{"ало  месяца   ",":  кредит     "} } ;
             }
for i := 1 to nPos_kk // Кредит
 j := Pos_Skk + Akk_Shet[i][2]  // номер реквизита
 nSumma := ":"+padc(str(Akk_Shet[i][1],5,2),13)
 aadd(Arr_Chet,{ {|x| str(Work->(FieldGet(x)),13,2) },;
                 {|x| Work->(FieldGet(x)) },j,{ ":"+space(13),nSumma } } )
next
aadd(Arr_Chet,{ {|x| str(Work->Itk,13,2) },{|x| Work->Itk },5,{":  итого      ",": по приходу  "} } )
for i := 1 to nPos_dd // Дебет
 j := Pos_Sdd + Add_Shet[i][2]  // номер реквизита
 nSumma := ":"+padc(str(Add_Shet[i][1],5,2),13)
 aadd(Arr_Chet,{ {|x| str(Work->(FieldGet(x)),13,2) },;
                 {|x| Work->(FieldGet(x)) },j,{ ":"+space(13),nSumma } } )
next
aadd(Arr_Chet,{ {|x| str(Work->Itd,13,2) },{|x| Work->Itd },5,{":  итого      ",": по расходу  "} } )
aadd(Arr_Chet,{ {|x| str(Work->SKD,13,2) },{|x| Work->SKD },9,{":  сальдо на  ",":   дебет     "} } )
aadd(Arr_Chet,{ {|x| str(Work->SKK,13,2) },{|x| Work->SKK },10,{" конец месяца",":   кредит    "} } )
Akk_Shet := Add_Shet := Nil
nLine :=18  // 8??????????????????????????
i := 1
j := min(nLine, nPos := Len(Arr_Chet) ) 
oFile := {}
While ( i < nPos )
  aadd(oFile,{Nil,i,j})
  i := j + 1
  j += ( nLine + 1 )
  j := Min(j,nPos)
End
if i == nPos
  aadd(oFile,{Nil,nPos,nPos})
End
for i := 1 to len(oFile)
  oFile[i][1] := oFileNew()
  oFile[i][1]:Open(sset[112][2]+"p"+alltrim(str(i,2))+".ved")
next
Itog    := array(nPos)
ItogTip := array(nPos)
nPos := Len(oFile) 
afill(Itog,0)
//  Печатаем шапку
oFile[1][1]:WriteLn("   Ведомость расчета с поставщиками за холодную воду и канализацию ")
oFile[1][1]:WriteLn("               за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.")
oFile[1][1]:WriteLn("  ")
for i := 2 to nPos
  oFile[i][1]:WriteLn(" ")
  oFile[i][1]:WriteLn(" ")
  oFile[i][1]:WriteLn(" ")
next
nLine := 3
DbSelectArea("Work")
Set Index to
fErase(sset[112][2]+"Work.Ntx")
Index on str(Tip,1)+str(Ent,4) to (cLine+"WORK")
Work->(DbGoTop())
nnPp := 0
While ( !Work->(eof()) )
  nTip := Work->Tip
  S_Gr->(DbSeek(str(nTip,1)))
  afill(ItogTip,0)
  cLine := S_Gr->Naim
  TestShapka(oFile,Arr_Chet)
  for i := 1 to nPos
    oFile[i][1]:WriteLn(iif(i>1," ",cLine))
  Next
  While ( nTip == Work->Tip .and. !Work->(eof()) )
    TestShapka(oFile,Arr_Chet)
    nnPp++
    for i := 1 to nPos
      cLine := str(nnPp,3)+" "+str(Work->Ent,3)
      for j := oFile[i][2] to oFile[i][3]
        nSumma := Arr_Chet[j][3]
        cLine += ( " "+eval(Arr_Chet[j][1],nSumma) )
        Itog[j]    += eval(Arr_Chet[j][2],nSumma)
        ItogTip[j] += eval(Arr_Chet[j][2],nSumma)
      next
      oFile[i][1]:WriteLn(cLine)
    next
    nLine++
    S_Line_N(18,04,65,nLastRec,++nRecno)
    Work->(Dbskip(1))
  End
  for i := 1 to len(Itog)
      ItogTip[i] := str(ItogTip[i],13,2)
  next
  ItogTip[1] := space(30)
  for i := 1 to len(oFile)
    cLine := "---"+"-"+"---"
    for j := oFile[i][2] to oFile[i][3]
      cLine += repl("-",len(Arr_Chet[j][4][1])) 
    next
    oFile[i][1]:WriteLn(cLine)
   next
   for i := 1 to nPos         // Печать итогов по типу
    cLine := "   "+" "+"   "
    for j := oFile[i][2] to oFile[i][3]
      nSumma := Arr_Chet[j][3]
      cLine += ( " "+ItogTip[j] )
    next
    oFile[i][1]:WriteLn(cLine)
   next
   nLine += 2
End
for i := 1 to len(Itog)
    Itog[i] := str(Itog[i],13,2)
next
Itog[1] := space(30)
for i := 1 to len(oFile)
    cLine := "==="+"="+"==="
    for j := oFile[i][2] to oFile[i][3]
      cLine += repl("=",len(Arr_Chet[j][4][1])) 
    next
    oFile[i][1]:WriteLn(cLine)
next
for i := 1 to nPos         // Печать итогов
  cLine := "   "+" "+"   "
  for j := oFile[i][2] to oFile[i][3]
    nSumma := Arr_Chet[j][3]
    cLine += ( " "+Itog[j] )
  next
  oFile[i][1]:WriteLn(cLine)
next
nLine += 2
for i := 1 to len(oFile)   // Прогон до конца листа
   for j := nLine to 60
      oFile[i][1]:WriteLn(" ")
   next
next
for i := 1 to len(oFile)
  oFile[i][1]:close()
next
S_Line_N()
My_Char()
OstNew->(DbCloseArea())
Work->(DbCloseArea())
PrnVedRas()
S_FileDel(sset[112][2]+"Work.*")
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
static function TestShapka(oFile,Arr_Chet)
Local i,j,cLine1,cLine2,cLine3
if nLine > 58 .or. nPage == 0
  if nPage <> 0
    for i := 1 to len(oFile)
       for j := nLine to 60
          oFile[i][1]:WriteLn(" ")
       next
    next
    nLine := 0
  End
  nPage++
  for i := 1 to len(oFile)
    oFile[i][1]:WriteLn("                     Лист# "+str(nPage,3)+"      Ф-"+alltrim(str(i,2)) )
    cLine1 := "---"+"-"+"---"
    cLine2 := " N "+" "+"код"
    cline3 := "п/п"+" "+"орг"
    for j := oFile[i][2] to oFile[i][3]
      cLine1 += repl("-",len(Arr_Chet[j][4][1]))
      cLine2 += Arr_Chet[j][4][1]
      cLine3 += Arr_Chet[j][4][2]
    next
    oFile[i][1]:WriteLn(cLine1)
    oFile[i][1]:WriteLn(cLine2)
    oFile[i][1]:WriteLn(cLine3)
    oFile[i][1]:WriteLn(cLine1)
  next
  nLine += 5
End
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
function PrnVedRas()
Local KolVed := aDir(sset[112][2]+"p*.ved"), FileVed, cFile
Private NomVed
if KolVed == 0
  S_Err({"Ведомость не сформирована"})
  Return ( Nil )
End
FileVed := array(KolVed)
aDir(sset[112][2]+"p*.ved",FileVed)
While ( .t. )
   NomVed := 1
   S_Get({14,02,"Укажите номер фрагмента ведомости ("+alltrim(str(KolVed,2))+;
                ")","NomVed","99"})
   if LastKey() == K_ESC ; exit ; End
   if NomVed <= 0 .or. NomVed > KolVed ; loop ; end
   cFile := sset[112][2]+"p"+alltrim(str(NomVed,2))+".ved"
   ShowPrn(cFile,"Фрагмент вxдомости",77)
End
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function ShowPrn(File,Name,Line)
if File(File) .and. S_Err({"^Вывести ","^"+Name,"на экран?","% Нет ; Да ;"})==2
   S_Lview(File,01,01,22,Line+1)
end
if File(File) .and. S_Err({"^Вывести","^"+Name,"на печать?","% Да ; Нет ;"})==1
   M_Tprn(File,.f.,1)
end
Return ( Nil )
Static Function M_Tprn(File)
Local Obj := oFileNew(File,0), Size, nPrint := 0, cLine,;
      CurList := 1, i, BlockList := { | | .t. },;
      ColorOld := SetColor(),;
      ListList := "", ListNac := ListKon := 0
BEGIN SEQUENCE
if ( i := S_Err({05,03,"^Укажите","режим печати по листам",;
     "% Полный ; Диапазон ; Список ; "}) ) == 2
   S_Open_m(03,03,07,28,Sset[77],sset[77])
   SetColor(Sset[76]+","+sset[77]+",,,"+sset[76])
   @ 01,02 say "Начальный лист: " get ListNac pict "999999" valid ListNac > 0
   @ 02,02 say "Конечный лист:  " get ListKon pict "999999" valid ListKon>=ListNac
   read
   BlockList := { |x| x>=ListNac .and. x<=ListKon }
   S_wCloseSl(S_RanDom()%22+1)
   SetColor(ColorOld)
elseif i == 3
   S_Open_M(03,03,18,16,Sset[77],Sset[77])
   SetColor(Sset[76]+","+sset[77]+",,,"+sset[76])
   @ MaxRow()-4,01 say "Укажи-"
   @ MaxRow()-3,01 say " те   "
   @ MaxRow()-2,01 say "номер "
   @ MaxRow()-1,01 say "листа ->"
   While ( .t. )
      Scroll(01,09,MaxRow()-1,MaxCol()-1,1)
      ListNac := 0
      @ MaxRow()-1,09 get ListNac pict "999999" valid ListNac > 0
      read
      if LastKey() == 27 ; exit ; end
      ListList += str(ListNac,6)+"^"
   end
   S_wCloseSl(S_RanDom()%22+1)
   BlockList := { |x| str(x,6)+"^"$ListList }
   SetColor(ColorOld)
end
Obj:Open()
Size := Obj:Len()
obj:Seek(0,0)
S_Line_N(16,3,65,Size,1)
@ 01,06 say "Внимание..."
@ 01,40 say "Следите за печатью и бумагой"
cLine := [" По окончании будет подан звуковой сигнал "]
@ 00,(MaxCol()-len(cLine))/2 say cLine
While ( !Obj:eof() .and. nPrint == 0 )
  cLine := obj:ReadLn(256) ;  cLine := left(cLine,Len(cLine)-1)
  S_Line_N(16,3,65,Size,Obj:Tell())
  if ( i := S_AtNum("Лист#",cLine) ) # 0
      CurList := val(substr(cLine,i+6,6))
  end
  if eval(BlockList,CurList)
    nPrint := S_Sprn(cLine+chr(13)+chr(10),,.t.)
  end
end
S_Line_N()
END SEQUENCE
obj:close()
Return ( .t. )
/////////////////////////////////////////////////////////////////////////
// Формирование ведомости по ПРИХОДУ
Function VedomPrix()
Local cFile := sset[112][2]+"Work", nLastRec, nRecno, nTip
Local fKolvo, fSum, fNdc, fFec, fSumma, tKolvo, tSum, tNdc, tFec, tSumma
Local fSumBank, tSumBank, cSumBank, cKolvo, cSum, cNdc, cFec, cSumma
Private nLen := 150, nLine := 0, nPage := 0, nSizePage := 67
Private cChet, dDataRas, nList := 0

if !Ostatok->(DbSeek(str(0,4)))  ;  return ( Nil ) ; end
BEGIN SEQUENCE
tSumma := Alltrim(str(Ostatok->Summa,10))
dDataRas := ctod(Substr(tSumma,7,2)+"."+Substr(tSumma,5,2)+"."+Substr(tSumma,1,4))
ferase(cFile+".Dbf")
ferase(cFile+".Ntx")
DbCreate(cFile,{ {"Ent",  "N",04,00},;   // код организации
                 {"Tip",  "N",01,00},;   // Тип организации
                 {"Chet", "N",04,00},;  
                 {"Kolvo","N",10,00},;
                 {"Cena", "N",07,03},;
                 {"Sum",  "N",13,02},;
                 {"Ndc",  "N",13,02},;
                 {"Fec",  "N",13,02},;
                 {"Summa","N",13,02},;
                 {"SumBank","N",13,02},;
                 {"Npp",  "N",05,00}} )
use (cFile) new alias Work
Index on str(Chet,5,1)+str(Tip,1)+str(Ent,4) to (cFile)
nLastRec := Prixod->(LastRec())
tSumma := "[ Ожидайте...  Формирую рабочую базу ]"
S_Line_N(18,04,65,nLastRec,1)
@ 00,(MaxCol()-len(tSumma))/2 say tSumma
nRecno := 0
DbSelectArea("Prixod")
Set Relation to str(Ent,4) into S_ENT
Prixod->(DbGoTop())
While !Prixod->(eof())
   Work->(DbAppend())
   Work->Tip := S_Ent->Tip
   Work->Ent := Prixod->Ent
   Work->Chet:= Prixod->Chet
   Work->Kolvo := Prixod->Kolvo
   Work->Cena  := Prixod->Cena
   Work->Sum   := Prixod->Sum
   Work->Ndc   := Prixod->Ndc
   Work->Fec   := Prixod->Fec
   Work->Summa := Prixod->Summa
   Work->SumBank := Prixod->SumBank
   Work->Npp   := Prixod->Npp
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Prixod->(DbSkip(1))
End
S_Line_N()
Set relation to
DbSelectArea("Work")
Set Relation to str(Ent,4) into S_ENT
nLastRec := Work->(LastRec())
tSumma := "[ Ожидайте...  Формирую ведомость ]"
S_Line_N(18,04,65,nLastRec,1)
@ 00,(MaxCol()-len(tSumma))/2 say tSumma
Work->(DbGoTop())
fKolvo := fSum := fNdc := fFec := fSumma := nRecno := fSumBank := 0
Set(20,"PRINT")
Set(24,cFile+".Txt")
While !Work->(eof())
  cChet := Work->Chet
  cKolvo := cSum := cNdc := cFec := cSumma := cSumBank := 0
  S_Chet->(DbSeek(str(cChet,4,0)))
  nList := 0
  PutPrix(" ")
  While !Work->(eof()) .and. cChet == Work->Chet
    nTip := Work->Tip
    tKolvo := tSum := tNdc := tFec := tSumma := tSumBank := 0
    S_Gr->(DbSeek(str(nTip,1)))
    PutPrix( "     Группа N "+str(nTip,1)+" "+S_Gr->Naim )
    While !Work->(eof()) .and. nTip == Work->Tip .and. cChet == Work->Chet
      PutPrix( str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
        str(Work->Kolvo,15)+" "+str(Work->Cena,7,3)+" "+;
        str(Work->Sum,15,2)+" "+str(Work->Ndc,15,2)+" "+str(Work->Fec,15,2)+" "+;
        str(Work->SumBank,15,2)+" "+;        
        str(Work->Summa,15,2)+" "+str(Work->Npp,5) )
      tKolvo += Work->Kolvo
      tSum   += Work->Sum
      tNdc   += Work->Ndc
      tFec   += Work->Fec
      tSumma += Work->Summa
      tSumBank += Work->SumBank
      S_Line_N(18,04,65,nLastRec,++nRecno)
      Work->(DbSkip(1))
    End
    PutPrix( Repl("-",nLen) )
    PutPrix( "     "+padr("Итого по группе ",35)+" "+;
        str(tKolvo,15)+" "+space(7)+" "+;
        str(tSum,15,2)+" "+str(tNdc,15,2)+" "+str(tFec,15,2)+" "+;
        str(tSumBank,15,2)+" "+str(tSumma,15,2) )
    cKolvo += tKolvo
    cSum   += tSum
    cNdc   += tNdc
    cFec   += tFec
    cSumma += tSumma
    cSumBank += tSumBank
  End
  PutPrix( Repl("-",nLen) )
  PutPrix( "     "+padr("Итого по счету ",35)+" "+;
        str(cKolvo,15)+" "+space(7)+" "+;
        str(cSum,15,2)+" "+str(cNdc,15,2)+" "+str(cFec,15,2)+" "+;
        str(tSumBank,15,2)+" "+str(cSumma,15,2) )
  fKolvo += cKolvo
  fSum   += cSum
  fNdc   += cNdc
  fFec   += cFec
  fSumma += cSumma
  fSumBank += cSumBank
End
@ prow()+1,00 say Repl("=",nLen)
@ prow()+1,00 say "     "+padr("ВСЕГО по предприятию",35)+" "+;
    str(fKolvo,15)+" "+space(7)+" "+;
    str(fSum,15,2)+" "+str(fNdc,15,2)+" "+str(fFec,15,2)+" "+;
    str(fSumBank,15,2)+" "+str(fSumma,15,2)
@ prow()+1,00 say " "
@ prow()+1,00 say ""
Set(24,"")
Set(20,"SCREEN")
S_Line_N()
Work->(DbCloseArea())
ShowPrn(cFile+".Txt"," О Т Ч Е Т ",74)
END SEQUENCE
ferase(cFile+".Dbf")
ferase(cFile+".Ntx")
ferase(cFile+".Txt")
Return ( Nil )
/////////////////////////////////////////////////////////////////////////
Static Function PutPrix(cLine)
Local i
if nList == 0 .or. nPage == 0 .or. nLine > nSizePage
  if nLine > nSizePage
     for i := nLine to nSizePage+3
        @ prow()+1,00 say " "
     Next
     @ prow()+1,00 say repl(".",nLen)
     @ prow()+1,00 say " "
     nLine := 0
  End
  nList++
  @ prow()+1,00 say "No# "+str(++nPage,3)
  @ prow()+1,00 say " "
  @ prow()+1,00 say " "
  @ prow()+1,00 say " "
  @ prow()+1,00 say padc("О Т Ч Е Т",nLen)
  @ prow()+1,00 say padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen)
  @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
  @ prow()+1,00 say padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen)
  @ prow()+1,00 say " "
  @ prow()+1,00 say Repl("-",nLen)
  @ prow()+1,00 say "      Наименование организации               Количество      Цена          Сумма          Ндс             ФЭС          Услуги             Сумма    "
  @ prow()+1,00 say "                                                м. куб.                                                                 банка         к предъявлен."
  @ prow()+1,00 say Repl("-",nLen)
  nLine += 12
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
// Формирование ведомости по ПРИХОДУ годовая
Function VedomGod()
Local cFile := sset[112][2]+"Work", nLastRec, nRecno
Local cKol1,cKol2,cKol3,cKol4,cKol5,cKol6,cKol7,cKol8,cKol9,сL10,cKol11,cKol12
Local cSum1,cSum2,cSum3,cSum4,cSum5,cSum6,cSum7,cSum8,cSum9,сD10,cSum11,cSum12
Local nKol1,nKol2,nKol3,nKol4,nKol5,nKol6,nKol7,nKol8,nKol9,nKol10,nKol11,nKol12
Local nSum1,nSum2,nSum3,nSum4,nSum5,nSum6,nSum7,nSum8,nSum9,nSum10,nSum11,nSum12
Local fKol1,fKol2,fKol3,fKol4,fKol5,fKol6,fKol7,fKol8,fKol9,fKol10,fKol11,fKol12
Local fSum1,fSum2,fSum3,fSum4,fSum5,fSum6,fSum7,fSum8,fSum9,fSum10,fSum11,fSum12

Private nLen1 := 149, nLine := 0, nPage := 0, nSizePage := 67
Private cChet, dDataRas, oFile2, oFile3, oFile4, nList := 0
Private nLen2 := 179, nLen3 := 179, nLen4 := 179

if !Ostatok->(DbSeek(str(0,4)))  ;  return ( Nil ) ; end
BEGIN SEQUENCE
nRecno := Alltrim(str(Ostatok->Summa,10))
dDataRas := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
ferase(cFile+".Dbf")
ferase(cFile+".Ntx")
nRecno :={ {"Ent",  "N",04,00},;   // код организации
           {"Tip",  "N",01,00},;   // Тип организации
           {"Chet", "N",04,00} }   // счет
For i := 1 to 12
   nLastRec := alltrim(str(i,2))
   aadd(nRecno, {"K"+nLastRec,"N",10,00} )
   aadd(nRecno, {"S"+nLastRec,"N",15,02} )
Next
DbCreate(cFile,nRecno)
use (cFile) new alias Work
Index on str(Chet,4,0)+str(Tip,1)+str(Ent,4) to (cFile)
use ( sset[112][1]+"aPrix" ) new alias Arx
nLastRec := Arx->(LastRec())
nRecno := "[ Ожидайте...  Формирую рабочую базу ]"
S_Line_N(18,04,65,nLastRec,1)
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
DbSelectArea("Arx")
Set Relation to str(Ent,4) into S_ENT
Arx->(DbGoTop())
While !Arx->(eof())
   if !Work->(DbSeek(str(Arx->Chet,4,0)+str(S_Ent->Tip,1)+str(Arx->Ent,4)))
      Work->(DbAppend())
      Work->Tip   := S_Ent->Tip
      Work->Ent   := Arx->Ent
      Work->Chet  := Arx->Chet
   End
   i := alltrim(str(Month(Arx->Data),2))
   Work->&("K"+i) += Arx->Kolvo
   Work->&("S"+i) += Arx->Summa
   S_Line_N(18,04,65,nLastRec,++nRecno)
   Arx->(DbSkip(1))
End
S_Line_N()
Set relation to
DbSelectArea("Work")
Set Relation to str(Ent,4) into S_ENT
nLastRec := Work->(LastRec())
nRecno := "[ Ожидайте...  Формирую ведомость ]"
S_Line_N(18,04,65,nLastRec,1)
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Work->(DbGoTop())
fKol1 := fKol2 := fKol3 := fKol4  := fKol5  := fKol6  := 0
fKol7 := fKol8 := fKol9 := fKol10 := fKol11 := fKol12 := 0
fSum1 := fSum2 := fSum3 := fSum4  := fSum5  := fSum6  := 0
fSum7 := fSum8 := fSum9 := fSum10 := fSum11 := fSum12 := 0
ferase(cFile+"2.Txt") ; oFile2 := oFileNew()   ;   oFile2:Open(cFile+"2.txt")
ferase(cFile+"3.Txt") ; oFile3 := oFileNew()   ;   oFile3:Open(cFile+"3.txt")
ferase(cFile+"4.Txt") ; oFile4 := oFileNew()   ;   oFile4:Open(cFile+"4.txt")
Set(20,"PRINT")
Set(24,cFile+"1.Txt")
While !Work->(eof())
  cChet := Work->Chet
  cKol1 := cKol2 := cKol3 := cKol4  := cKol5  := cKol6  := 0
  cKol7 := cKol8 := cKol9 := cKol10 := cKol11 := cKol12 := 0
  cSum1 := cSum2 := cSum3 := cSum4  := cSum5  := cSum6  := 0
  cSum7 := cSum8 := cSum9 := cSum10 := cSum11 := cSum12 := 0
  S_Chet->(DbSeek(str(cChet,5,1)))
  nList := 0
  PutArx(" "," "," "," ")
  While !Work->(eof()) .and. cChet == Work->Chet
    nTip := Work->Tip
    nKol1 := nKol2 := nKol3 := nKol4  := nKol5  := nKol6  := 0
    nKol7 := nKol8 := nKol9 := nKol10 := nKol11 := nKol12 := 0
    nSum1 := nSum2 := nSum3 := nSum4  := nSum5  := nSum6  := 0
    nSum7 := nSum8 := nSum9 := nSum10 := nSum11 := nSum12 := 0
    S_Gr->(DbSeek(str(nTip,1)))
    PutArx( "     Группа N "+str(nTip,1)+" "+S_Gr->Naim,;
            "     Группа N "+str(nTip,1)+" "+S_Gr->Naim,;
            "     Группа N "+str(nTip,1)+" "+S_Gr->Naim,;
            "     Группа N "+str(nTip,1)+" "+S_Gr->Naim )
    While !Work->(eof()) .and. nTip == Work->Tip .and. cChet == Work->Chet
      PutArx( str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
              str(Work->K1,12)+" "+str(Work->s1,12,2)+" "+;
              str(Work->K2,12)+" "+str(Work->s2,12,2)+" "+;
              str(Work->K3,12)+" "+str(Work->s3,12,2)+" "+;
              str(Work->K1+Work->K2+Work->K3,14)+" "+;
              str(Work->s1+Work->s2+Work->s3,14,2),;
                str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
                str(Work->K4,12)+" "+str(Work->s4,12,2)+" "+;
                str(Work->K5,12)+" "+str(Work->s5,12,2)+" "+;
                str(Work->K6,12)+" "+str(Work->s6,12,2)+" "+;
                str(Work->K4+Work->K5+Work->K6,14)+" "+;
                str(Work->s4+Work->s5+Work->s6,14,2)+" "+;
                str(Work->K1+Work->K2+Work->K3+Work->K4+Work->K5+Work->K6,14)+" "+;
                str(Work->s1+Work->s2+Work->s3+Work->s4+Work->s5+Work->s6,14,2),;
              str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
              str(Work->K7,12)+" "+str(Work->s7,12,2)+" "+;
              str(Work->K8,12)+" "+str(Work->s8,12,2)+" "+;
              str(Work->K9,12)+" "+str(Work->s9,12,2)+" "+;
              str(Work->K7+Work->K8+Work->K9,14)+" "+;
              str(Work->s7+Work->s8+Work->s9,14,2)+" "+;
              str(Work->K1+Work->K2+Work->K3+Work->K4+Work->K5+Work->K6+Work->K7+Work->K8+Work->K9,14)+" "+;
              str(Work->s1+Work->s2+Work->s3+Work->s4+Work->s5+Work->s6+Work->s7+Work->s8+Work->s9,14,2),;
                str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
                str(Work->K10,12)+" "+str(Work->s10,12,2)+" "+;
                str(Work->K11,12)+" "+str(Work->s11,12,2)+" "+;
                str(Work->K12,12)+" "+str(Work->s12,12,2)+" "+;
                str(Work->K10+Work->K11+Work->K12,14)+" "+;
                str(Work->s10+Work->s11+Work->s12,14,2)+" "+;
                str(Work->K1+Work->K2+Work->K3+Work->K4+Work->K5+Work->K6+Work->K7+Work->K8+Work->K9+Work->K10+Work->K11+Work->K12,14)+" "+;
                str(Work->s1+Work->s2+Work->s3+Work->s4+Work->s5+Work->s6+Work->s7+Work->s8+Work->s9+Work->s10+Work->s11+Work->s12,14,2) )
      nKol1  += Work->K1   ;   nKol2  +=  Work->k2  ;  nKol3  += Work->k3
      nKol4  += Work->K4   ;   nKol5  +=  Work->k5  ;  nKol6  += Work->k6
      nKol7  += Work->K7   ;   nKol8  +=  Work->k8  ;  nKol9  += Work->k9
      nKol10 += Work->K10  ;   nKol11 +=  Work->k11 ;  nKol12 += Work->k12
      nSum1  += Work->s1   ;   nSum2  +=  Work->s2  ;  nSum3  += Work->s3
      nSum4  += Work->s4   ;   nSum5  +=  Work->s5  ;  nSum6  += Work->s6
      nSum7  += Work->s7   ;   nSum8  +=  Work->s8  ;  nSum9  += Work->s9
      nSum10 += Work->s10  ;   nSum11 +=  Work->s11 ;  nSum12 += Work->s12
      S_Line_N(18,04,65,nLastRec,++nRecno)
      Work->(DbSkip(1))
    End
    PutArx( Repl("-",nLen1),Repl("-",nLen2),Repl("-",nLen3),Repl("-",nLen4) )
    PutArx( "     "+padr("Всего по группе",35)+" "+;
        str(nKol1,12)+" "+str(nSum1,12,2)+" "+;
        str(nKol2,12)+" "+str(nSum2,12,2)+" "+;
        str(nKol3,12)+" "+str(nSum3,12,2)+" "+;
        str(nKol1+nKol2+nKol3,14)+" "+;
        str(nSum1+nSum2+nSum3,14,2),;
                "     "+padr("Всего по группе",35)+" "+;
                str(nKol4,12)+" "+str(nSum4,12,2)+" "+;
                str(nKol5,12)+" "+str(nSum5,12,2)+" "+;
                str(nKol6,12)+" "+str(nSum6,12,2)+" "+;
                str(nKol4+nKol5+nKol6,14)+" "+;
                str(nSum4+nSum5+nSum6,14,2)+" "+;
                str(nKol1+nKol2+nKol3+nKol4+nKol5+nKol6,14)+" "+;
                str(nSum1+nSum2+nSum3+nSum4+nSum5+nSum6,14,2),;
         "     "+padr("Всего по группе",35)+" "+;
         str(nKol7,12)+" "+str(nSum7,12,2)+" "+;
         str(nKol8,12)+" "+str(nSum8,12,2)+" "+;
         str(nKol9,12)+" "+str(nSum9,12,2)+" "+;
         str(nKol7+nKol8+nKol9,14)+" "+;
         str(nSum7+nSum8+nSum9,14,2)+" "+;
         str(nKol1+nKol2+nKol3+nKol4+nKol5+nKol6+nKol7+nKol8+nKol9,14)+" "+;
         str(nSum1+nSum2+nSum3+nSum4+nSum5+nSum6+nSum7+nSum8+nSum9,14,2),;
                "     "+padr("Всего по группе",35)+" "+;
                str(nKol10,12)+" "+str(nSum10,12,2)+" "+;
                str(nKol11,12)+" "+str(nSum11,12,2)+" "+;
                str(nKol12,12)+" "+str(nSum12,12,2)+" "+;
                str(nKol10+nKol11+nKol12,14)+" "+;
                str(nSum10+nSum11+nSum12,14,2)+" "+;
                str(nKol1+nKol2+nKol3+nKol4+nKol5+nKol6+nKol7+nKol8+nKol9+nKol10+nKol11+nKol12,14)+" "+;
                str(nSum1+nSum2+nSum3+nSum4+nSum5+nSum6+nSum7+nSum8+nSum9+nSum10+nSum11+nSum12,14,2) )
    cKol1 += nKol1   ;    cKol2 += nKol2    ;    cKol3 += nKol3    ;    cKol4 += nKol4
    cKol5 += nKol5   ;    cKol6 += nKol6    ;    cKol7 += nKol7    ;    cKol8 += nKol8
    cKol9 += nKol9   ;    cKol10+= nKol10   ;    cKol11+= nKol11   ;    cKol12+= nKol12
    cSum1 += nSum1   ;    cSum2 += nSum2    ;    cSum3 += nSum3    ;    cSum4 += nSum4
    cSum5 += nSum5   ;    cSum6 += nSum6    ;    cSum7 += nSum7    ;    cSum8 += nSum8
    cSum9 += nSum9   ;    cSum10+= nSum10   ;    cSum11+= nSum11   ;    cSum12+= nSum12
  End
  PutArx( Repl("-",nLen1),Repl("-",nLen2),Repl("-",nLen3),Repl("-",nLen4) )
  PutArx( "     "+padr("Всего по счету",35)+" "+;
        str(cKol1,12)+" "+str(cSum1,12,2)+" "+;
        str(cKol2,12)+" "+str(cSum2,12,2)+" "+;
        str(cKol3,12)+" "+str(cSum3,12,2)+" "+;
        str(cKol1+cKol2+cKol3,14)+" "+;
        str(cSum1+cSum2+cSum3,14,2),;
                "     "+padr("Всего по счету",35)+" "+;
                str(cKol4,12)+" "+str(cSum4,12,2)+" "+;
                str(cKol5,12)+" "+str(cSum5,12,2)+" "+;
                str(cKol6,12)+" "+str(cSum6,12,2)+" "+;
                str(cKol4+cKol5+cKol6,14)+" "+;
                str(cSum4+cSum5+cSum6,14,2)+" "+;
                str(cKol1+cKol2+cKol3+cKol4+cKol5+cKol6,14)+" "+;
                str(cSum1+cSum2+cSum3+cSum4+cSum5+cSum6,14,2),;
         "     "+padr("Всего по счету",35)+" "+;
         str(cKol7,12)+" "+str(cSum7,12,2)+" "+;
         str(cKol8,12)+" "+str(cSum8,12,2)+" "+;
         str(cKol9,12)+" "+str(cSum9,12,2)+" "+;
         str(cKol7+cKol8+cKol9,14)+" "+;
         str(cSum7+cSum8+cSum9,14,2)+" "+;
         str(cKol1+cKol2+cKol3+cKol4+cKol5+cKol6+cKol7+cKol8+cKol9,14)+" "+;
         str(cSum1+cSum2+cSum3+cSum4+cSum5+cSum6+cSum7+cSum8+cSum9,14,2),;
                "     "+padr("Всего по счету",35)+" "+;
                str(cKol10,12)+" "+str(cSum10,12,2)+" "+;
                str(cKol11,12)+" "+str(cSum11,12,2)+" "+;
                str(cKol12,12)+" "+str(cSum12,12,2)+" "+;
                str(cKol10+cKol11+cKol12,14)+" "+;
                str(cSum10+cSum11+cSum12,14,2)+" "+;
                str(cKol1+cKol2+cKol3+cKol4+cKol5+cKol6+cKol7+cKol8+cKol9+cKol10+cKol11+cKol12,14)+" "+;
                str(cSum1+cSum2+cSum3+cSum4+cSum5+cSum6+cSum7+cSum8+cSum9+cSum10+cSum11+cSum12,14,2) )
  fKol1 += cKol1   ;    fKol2 += cKol2    ;    fKol3 += cKol3    ;    fKol4 += cKol4
  fKol5 += cKol5   ;    fKol6 += cKol6    ;    fKol7 += cKol7    ;    fKol8 += cKol8
  fKol9 += cKol9   ;    fKol10+= cKol10   ;    fKol11+= cKol11   ;    fKol12+= cKol12
  fSum1 += cSum1   ;    fSum2 += cSum2    ;    fSum3 += cSum3    ;    fSum4 += cSum4
  fSum5 += cSum5   ;    fSum6 += cSum6    ;    fSum7 += cSum7    ;    fSum8 += cSum8
  fSum9 += cSum9   ;    fSum10+= cSum10   ;    fSum11+= cSum11   ;    fSum12+= cSum12
End
PutArx( Repl("-",nLen1),Repl("-",nLen2),Repl("-",nLen3),Repl("-",nLen4) )
@ prow()+1,00 say  "     "+padr("Всего по предприятию",35)+" "+;
        str(fKol1,12)+" "+str(fSum1,12,2)+" "+;
        str(fKol2,12)+" "+str(fSum2,12,2)+" "+;
        str(fKol3,12)+" "+str(fSum3,12,2)+" "+;
        str(fKol1+fKol2+fKol3,14)+" "+;
        str(nSum1+fSum2+fSum3,14,2) 
oFile2:WriteLn("     "+padr("Всего по предприятию",35)+" "+;
                str(fKol4,12)+" "+str(fSum4,12,2)+" "+;
                str(fKol5,12)+" "+str(fSum5,12,2)+" "+;
                str(fKol6,12)+" "+str(fSum6,12,2)+" "+;
                str(fKol4+fKol5+fKol6,14)+" "+;
                str(fSum4+fSum5+fSum6,14,2)+" "+;
                str(fKol1+fKol2+fKol3+fKol4+fKol5+fKol6,14)+" "+;
                str(fSum1+fSum2+fSum3+fSum4+fSum5+fSum6,14,2) )
oFile3:WriteLn("     "+padr("Всего по предприятию",35)+" "+;
         str(fKol7,12)+" "+str(fSum7,12,2)+" "+;
         str(fKol8,12)+" "+str(fSum8,12,2)+" "+;
         str(fKol9,12)+" "+str(fSum9,12,2)+" "+;
         str(fKol7+fKol8+fKol9,14)+" "+;
         str(fSum7+fSum8+fSum9,14,2)+" "+;
         str(fKol1+fKol2+fKol3+fKol4+fKol5+fKol6+fKol7+fKol8+fKol9,14)+" "+;
         str(fSum1+fSum2+fSum3+fSum4+fSum5+fSum6+fSum7+fSum8+fSum9,14,2) )
oFile4:WriteLn( "     "+padr("Всего по предприятию",35)+" "+;
                str(fKol10,12)+" "+str(fSum10,12,2)+" "+;
                str(fKol11,12)+" "+str(fSum11,12,2)+" "+;
                str(fKol12,12)+" "+str(fSum12,12,2)+" "+;
                str(fKol10+fKol11+fKol12,14)+" "+;
                str(fSum10+fSum11+fSum12,14,2)+" "+;
                str(fKol1+fKol2+fKol3+fKol4+fKol5+fKol6+fKol7+fKol8+fKol9+fKol10+fKol11+fKol12,14)+" "+;
                str(fSum1+fSum2+fSum3+fSum4+fSum5+fSum6+fSum7+fSum8+fSum9+fSum10+fSum11+fSum12,14,2) )
@ prow()+1,00 say " "
@ prow()+1,00 say ""
S_Line_N()
Work->(DbCloseArea())
Arx->(DbCloseArea())
Set(24,"")
Set(20,"SCREEN")
oFile2:WriteLn( " " ) ; oFile3:WriteLn( " " ) ; oFile4:WriteLn( " " ) 
oFile2:WriteLn( "" )  ; oFile3:WriteLn( "" )  ; oFile4:WriteLn( "" ) 
oFile2:Close()        ; oFile3:Close()        ; oFile4:Close()
ShowPrn(cFile+"1.Txt"," Ведомость за 1 квартал ",74)
ShowPrn(cFile+"2.Txt"," Ведомость за 2 квартал ",74)
ShowPrn(cFile+"3.Txt"," Ведомость за 3 квартал ",74)
ShowPrn(cFile+"4.Txt"," Ведомость за 4 квартал ",74)
END SEQUENCE
ferase(cFile+".Dbf")
ferase(cFile+".Ntx")
ferase(cFile+"1.Txt")
ferase(cFile+"2.Txt")
ferase(cFile+"3.Txt")
ferase(cFile+"4.Txt")
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
Static Function PutArx(cLine,cLine2,cLine3,cLine4)
Local i
if nList == 0 .or. nPage == 0 .or. nLine > nSizePage
  if nLine > nSizePage
     for i := nLine to nSizePage+3
        @ prow()+1,00 say " "
        oFile2:WriteLn( " " )
        oFile3:WriteLn( " " )
        oFile4:WriteLn( " " ) 
     Next
     @ prow()+1,00 say repl(".",nLen1)
     oFile2:WriteLn( repl(".",nLen2) )
     oFile3:WriteLn( repl(".",nLen3) )
     oFile4:WriteLn( repl(".",nLen4) ) 
     @ prow()+1,00 say " "
     oFile2:WriteLn( " " )
     oFile3:WriteLn( " " )
     oFile4:WriteLn( " " ) 
     nLine := 0
  End
  nList++
  @ prow()+1,00 say "No# "+str(++nPage,3)
  @ prow()+1,00 say chr(15)
  @ prow()+1,00 say " "
  @ prow()+1,00 say " "
  @ prow()+1,00 say " "
  @ prow()+1,00 say padc("О Т Ч Е Т",nLen1)
  @ prow()+1,00 say padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen1)
  @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen1)
  @ prow()+1,00 say padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen1)
  @ prow()+1,00 say " "
  @ prow()+1,00 say Repl("-",nLen1)
  @ prow()+1,00 say "                                        |        я н в а р ь      |      ф е в р а л ь      |         м а р т         |          I квартал          |"
  @ prow()+1,00 say "           Наименование организации     |-------------------------|-------------------------|-------------------------|-----------------------------|"
  @ prow()+1,00 say "                                        |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. | кол-во м.куб |  сумма грн.  |"
  @ prow()+1,00 say Repl("-",nLen1)
  //
  oFile2:WriteLn( "No# "+str(nPage,3) )
  oFile2:WriteLn( chr(15) )
  oFile2:WriteLn( " " )
  oFile2:WriteLn( " " )
  oFile2:WriteLn( " " )
  oFile2:WriteLn( padc("О Т Ч Е Т",nLen2) )
  oFile2:WriteLn( padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen2) )
  oFile2:WriteLn( padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen2) )
  oFile2:WriteLn( padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen2) )
  oFile2:WriteLn( " " )
  oFile2:WriteLn( Repl("-",nLen2) )
  oFile2:WriteLn( "                                        |        а п р е л ь      |         м  а  й         |        и ю н ь          |         II квартал          |    п о л у г о д и е        |" )
  oFile2:WriteLn( "           Наименование организации     |-------------------------|-------------------------|-------------------------|-----------------------------|-----------------------------|" )
  oFile2:WriteLn( "                                        |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. | кол-во м.куб |  сумма грн.  | кол-во м.куб |  сумма грн.  |" )
  oFile2:WriteLn( Repl("-",nLen2) )
  //
  oFile3:WriteLn( "No# "+str(nPage,3) )
  oFile3:WriteLn( chr(15) )
  oFile3:WriteLn( " " )
  oFile3:WriteLn( " " )
  oFile3:WriteLn( " " )
  oFile3:WriteLn( padc("О Т Ч Е Т",nLen3) )
  oFile3:WriteLn( padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen3) )
  oFile3:WriteLn( padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen3) )
  oFile3:WriteLn( padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen3) )
  oFile3:WriteLn( " " )
  oFile3:WriteLn( Repl("-",nLen3) )
  oFile3:WriteLn( "                                        |         и ю л ь         |        а в г у с т      |      с е н т я б р ь    |        III квартал          |       9  месяцев            |" )
  oFile3:WriteLn( "           Наименование организации     |-------------------------|-------------------------|-------------------------|-----------------------------|-----------------------------|" )
  oFile3:WriteLn( "                                        |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. | кол-во м.куб |  сумма грн.  | кол-во м.куб |  сумма грн.  |" )
  oFile3:WriteLn( Repl("-",nLen2) )
  //
  oFile4:WriteLn( "No# "+str(nPage,3) )
  oFile4:WriteLn( chr(15) )
  oFile4:WriteLn( " " )
  oFile4:WriteLn( " " )
  oFile4:WriteLn( " " )
  oFile4:WriteLn( padc("О Т Ч Е Т",nLen4) )
  oFile4:WriteLn( padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen4) )
  oFile4:WriteLn( padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen4) )
  oFile4:WriteLn( padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen4) )
  oFile4:WriteLn( " " )
  oFile4:WriteLn( Repl("-",nLen4) )
  oFile4:WriteLn( "                                        |       о к т я б р ь     |      н о я б р ь        |       д е к а б р ь     |         IV квартал          |          г о д              |" )
  oFile4:WriteLn( "           Наименование организации     |-------------------------|-------------------------|-------------------------|-----------------------------|-----------------------------|" )
  oFile4:WriteLn( "                                        |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. |кол-во м.куб| сумма грн. | кол-во м.куб |  сумма грн.  | кол-во м.куб |  сумма грн.  |" )
  oFile4:WriteLn( Repl("-",nLen4) )
  nLine += 15
End
@ prow()+1,00 say cLine
oFile2:WriteLn( cLine2 )
oFile3:WriteLn( cLine3 )
oFile4:WriteLn( cLine4 )
nLine++
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
