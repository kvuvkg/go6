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
                  {"SN",   "N",13,02},;   // сальдо на начало
                  {"ITK",  "N",13,02},;   // ИТОГО по КРЕДИТУ
                  {"ITD",  "N",13,02},;   // ИТОГО по КРЕДИТУ
                  {"SK",   "N",13,02} }   // сальдо на конец
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
      Work->Sn   := Ostatok->Summa
      Work->Sk   := Ostatok->Summa
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
      Work->Sk += Prixod->Summa
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
      Work->Sk -= Rasxod->Summa
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
      Work->Itk  := nKredit
      Work->Itd  := nDebet
      OstNew->(DbAppend())
      OstNew->Ent   := Work->Ent
      OstNew->Summa := Work->Sk
      S_Line_N(18,04,65,nLastRec,++nRecno)
      Work->(Dbskip(1))
    End
    //         ВСЕ ГОТОВО ----- Формируем наконец-то ведомость
    S_FileDel(sset[112][2]+"p*.ved")
    Add_Shet := aSort(Add_Shet,,,{|x,y| x[1]<y[1] })
    Akk_Shet := aSort(Akk_Shet,,,{|x,y| x[1]<y[1] })
    Arr_Chet := { ;
     { {|x| Work->Naim },{|x| 0 },3,{":"+space(30),":"+padc("Организация",30)} },;
     { {|x| str(Work->Sn,13,2) },{|x| Work->Sn },4,{"Сальдо на нача",":ло месяца    "} } ;
                 }
    for i := 1 to nPos_kk // Кредит
     j := Pos_Skk + Akk_Shet[i][2]  // номер реквизита
     nSumma := ":"+padc(str(Akk_Shet[i][1],4,0),13)
     aadd(Arr_Chet,{ {|x| str(Work->(FieldGet(x)),13,2) },;
                     {|x| Work->(FieldGet(x)) },j,{ ":"+space(13),nSumma } } )
    next
    aadd(Arr_Chet,{ {|x| str(Work->Itk,13,2) },{|x| Work->Itk },5,{":  итого      ",": по приходу  "} } )
    for i := 1 to nPos_dd // Дебет
     j := Pos_Sdd + Add_Shet[i][2]  // номер реквизита
     nSumma := ":"+padc(str(Add_Shet[i][1],4,0),13)
     aadd(Arr_Chet,{ {|x| str(Work->(FieldGet(x)),13,2) },;
                     {|x| Work->(FieldGet(x)) },j,{ ":"+space(13),nSumma } } )
    next
    aadd(Arr_Chet,{ {|x| str(Work->Itd,13,2) },{|x| Work->Itd },6,{":  итого      ",": по расходу  "} } )
    aadd(Arr_Chet,{ {|x| str(Work->SK,13,2) },{|x| Work->SK },  7,{":сальдо на ко ",":нец месяца   "} } )
    Akk_Shet := Add_Shet := Nil
    nLine := 300 // 8  // ??????????????????????????
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
          cLine := str(nnPp,3)+" "+str(Work->Ent,4)
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
Function ShowPrn(File,Name,Line)
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

static function _prepareFile(fileName, nLastRec)
    Local cFile, nRecno, cDir, lRet, cMsg
    
    cDir := sset[112][2]
    cFile := cDir+fileName
    lRet := .f.
    BEGIN SEQUENCE
        ferase(cFile+".Dbf")
        ferase(cFile+".Ntx")
        DbCreate(cFile,{ {"Ent",  "N",04,00},;   // код организации
                         {"Tip",  "N",01,00},;   // Тип организации
                         {"Chet", "N",04,00},;
                         {"Kolvo","N",10,00},;
                         {"Cena", "N",15,06},;
                         {"Sum",  "N",13,02},;
                         {"Ndc",  "N",13,02},;
                         {"Fec",  "N",13,02},;
                         {"Summa","N",13,02},;
                         {"SumBank","N",13,02},;
                         {"Npp",  "N",05,00}} )
        use (cFile) new alias Work
        Index on str(Chet,4,0)+str(Tip,1)+str(Ent,4) to (cFile)
        nLastRec := Prixod->(LastRec())
        cMsg := "[ Ожидайте...  Формирую рабочую базу ]"
        S_Line_N(18,04,65,nLastRec,1)
        @ 00,(MaxCol()-len(cMsg))/2 say cMsg
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
            if Work->Tip =1 .and. Work->Chet =7031.and.Work->Ent =7
                Work->Cena  := 0
                Work->Sum   := 0
                Work->Ndc   := 0
                Work->Fec   := 0
                Work->Summa := 0
                Work->SumBank :=0    
            endif
            if Work->Tip =1 .and. Work->Chet =7032.and.Work->Ent =7
                Work->Cena  := 0
                Work->Sum   := 0
                Work->Ndc   := 0
                Work->Fec   := 0
                Work->Summa := 0
                Work->SumBank :=0    
            endif
            if Work->Tip =1 .and. Work->Chet =7031.and.Work->Ent =77
                Work->Cena  := 0
                Work->Sum   := 0
                Work->Ndc   := 0
                Work->Fec   := 0
                Work->Summa := 0
                Work->SumBank :=0    
            endif
            if Work->Tip =1 .and. Work->Chet =7032.and.Work->Ent =77
                Work->Cena  := 0
                Work->Sum   := 0
                Work->Ndc   := 0
                Work->Fec   := 0
                Work->Summa := 0
                Work->SumBank :=0    
            endif
            S_Line_N(18,04,65,nLastRec,++nRecno)
            Prixod->(DbSkip(1))
        End // While
        S_Line_N()
        Set relation to
        DbSelectArea("Work")
        Set Relation to str(Ent,4) into S_ENT
        lRet := .t.
    END SEQUENCE
Return (lRet)

/////////////////////////////////////////////////////////////////////////
// Формирование ведомости по ПРИХОДУ
Function VedomPrix()
    Local cFile, nLastRec, nRecno, nTip
    Local fKolvo, fSum, fNdc, fFec, fSumma, tKolvo, tSum, tNdc, tFec, tSumma
    Local fSumBank, tSumBank, cSumBank, cKolvo, cSum, cNdc, cFec, cSumma
    Private nLen := 150, nStr := nLine := 0, nPage := 0, nSizePage := 67
    Private cChet, dDataRas, nList := 0, Delim := 0

    cDir = sset[112][2]
    cFile := cDir+"Work"
    cPrnFile = cDir+"VPrix.prn"
    ferase(cPrnFile)
    if !Ostatok->(DbSeek(str(0,4)))  ;  return ( Nil ) ; end
    tSumma := Alltrim(str(Ostatok->Summa,10))
    dDataRas := ctod(Substr(tSumma,7,2)+"."+Substr(tSumma,5,2)+"."+Substr(tSumma,1,4))
    If !_prepareFile("Work", @nLastRec)
        return (.f.)
    endIf
    BEGIN SEQUENCE
        tSumma := "[ Ожидайте...  Формирую ведомость ]"
        S_Line_N(18,04,65,nLastRec,1)
        @ 00,(MaxCol()-len(tSumma))/2 say tSumma
        Work->(DbGoTop())
        fKolvo := fSum := fNdc := fFec := fSumma := nRecno := fSumBank := 0
        Set(20,"PRINT")
        // Assign prn file
        Set(24,cPrnFile)
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
                        str(Work->Kolvo,15)+" "+str(Work->Cena,10,6)+" "+;
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
        ShowPrn(cPrnFile," О Т Ч Е Т ",74)
    END SEQUENCE
    ferase(cFile+".Dbf")
    ferase(cFile+".Ntx")
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
      if cChet != Delim
        Delim := cChet
        nPage := 0
      end
      nList++
      nPage++
      @ prow()+1,00 say " "
      @ prow()+1,00 say "Лист# "+str(++nStr,3)
      @ prow()+1,00 say " "
      @ prow()+1,00 say " "
      @ prow()+1,00 say " "

      if nPage == 1
        @ prow()+1,00 say "                                                                                                                    Утверждаю"
        @ prow()+1,00 say "                                                                                                                 начальник KПУВКХ"
        @ prow()+1,00 say padc("О Т Ч Е Т",nLen)
        @ prow()+1,00 say padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen)
        @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
        @ prow()+1,00 say padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen)
        @ prow()+1,00 say " "
        @ prow()+1,00 say Repl("-",nLen)
        @ prow()+1,00 say "      Наименование организации               Количество      Цена          Сумма          Ндс             ПРС          Услуги             Сумма    "
        @ prow()+1,00 say "                                                м. куб.                                                                 банка         к предъявлен."
        @ prow()+1,00 say Repl("-",nLen)
        nLine += 12
      end
    End
    @ prow()+1,00 say cLine
    nLine++
Return ( Nil )

//////////////////////////////////////////////////////////////////////////
Function Prepare1Cfile()
    S_Sys()
    S_Err({"@ВНИМАНИЕ!","Сейчас будет произведено формирование","файла для экспорта в 1С"})
    cDir = sset[112][2]
    cFile := cDir+"1Cfile"
    If !_prepareFile("1Cfile")
        return ( Nil )
    endIf
    Work->(DbCloseArea())
    S_Err({"@ВНИМАНИЕ!","Сформирован файл экспорта в 1С", cFile+".dbf"})
Return ( Nil )

/////////////////////////////////////////////////////////////////////////
// Формирование reectra
Function VedomPrix1()
    Local cFile := sset[112][2]+"Work", nLastRec, nRecno, nTip
    Local fKolvo, fSum, fNdc, fFec, fSumma, tKolvo, tSum, tNdc, tFec, tSumma
    Local fSumBank, tSumBank, cSumBank, cKolvo, cSum, cNdc, cFec, cSumma
    Private nLen := 150, nStr := nLine := 0, nPage := 0, nSizePage := 67
    Private cChet, dDataRas, nList := 0, Delim := 0

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
                         {"Cena", "N",15,06},;
                         {"Sum",  "N",13,02},;
                         {"Ndc",  "N",13,02},;
                         {"Fec",  "N",13,02},;
                         {"Summa","N",13,02},;
                         {"SumBank","N",13,02},;
                         {"Npp",  "N",05,00}} )
        use (cFile) new alias Work
        Index on str(Chet,4,0)+str(Tip,1)+str(Ent,4) to (cFile)
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
          PutPrix1(" ")
          While !Work->(eof()) .and. cChet == Work->Chet
            nTip := Work->Tip
            tKolvo := tSum := tNdc := tFec := tSumma := tSumBank := 0
            S_Gr->(DbSeek(str(nTip,1)))
            PutPrix1( "     Группа N "+str(nTip,1)+" "+S_Gr->Naim )
            While !Work->(eof()) .and. nTip == Work->Tip .and. cChet == Work->Chet
              PutPrix( str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
               str( Work->NPP,5)+":"+ str(Work->Summa,15,2)+":             :                         :         :           :  " )
              tKolvo += Work->Kolvo
              tSum   += Work->Sum
              tNdc   += Work->Ndc
              tFec   += Work->Fec
              tSumma += Work->Summa
              tSumBank += Work->SumBank
              S_Line_N(18,04,65,nLastRec,++nRecno)
              Work->(DbSkip(1))
              PutPrix1( Repl("-",nLen) )
            End
            PutPrix1( Repl("-",nLen) )
          ///  PutPrix1( "     "+padr("Итого по группе ",35)+" "+;
         ////       str(tKolvo,15)+" "+space(7)+" "+;
         ////       str(tSum,15,2)+" "+str(tNdc,15,2)+" "+str(tFec,15,2)+" "+;
         ////       str(tSumBank,15,2)+" "+str(tSumma,15,2) )
            cKolvo += tKolvo
            cSum   += tSum
            cNdc   += tNdc
            cFec   += tFec
            cSumma += tSumma
            cSumBank += tSumBank
          End
          PutPrix1( Repl("-",nLen) )
        //  PutPrix1( "     "+padr("Итого по счету ",35)+" "+;
        ///        str(cKolvo,15)+" "+space(7)+" "+;
        ///        str(cSum,15,2)+" "+str(cNdc,15,2)+" "+str(cFec,15,2)+" "+;
        ///        str(tSumBank,15,2)+" "+str(cSumma,15,2) )
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
Static Function PutPrix1(cLine)
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
      if cChet != Delim
        Delim := cChet
        nPage := 0
      end
      nList++
      nPage++
      @ prow()+1,00 say " "
      @ prow()+1,00 say "Лист# "+str(++nStr,3)
      @ prow()+1,00 say " "
      @ prow()+1,00 say " "
      @ prow()+1,00 say " "

      if nPage == 1
        @ prow()+1,00 say "                                                                                                                    Утверждаю"
        @ prow()+1,00 say "                                                                                                                 начальник KПУВКХ"
        @ prow()+1,00 say padc("Р Е Е С Т Р   ",nLen)
        @ prow()+1,00 say padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen)
        @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
        @ prow()+1,00 say padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen)
        @ prow()+1,00 say " "
        @ prow()+1,00 say Repl("-",nLen)
        @ prow()+1,00 say "      Наименование организации      Докум              Сумма        ДАТА                     Ф И О          Долж     Роспись        "
        @ prow()+1,00 say "                                                             .   получения                                                                                "
        @ prow()+1,00 say Repl("-",nLen)
        nLine += 12
      end
    End
    @ prow()+1,00 say cLine
    nLine++
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// Формирование reectra
Function VedomPrix2()
    Local cFile := sset[112][2]+"Work", nLastRec, nRecno, nTip
    Local fKolvo, fSum, fNdc, fFec, fSumma, tKolvo, tSum, tNdc, tFec, tSumma
    Local fSumBank, tSumBank, cSumBank, cKolvo, cSum, cNdc, cFec, cSumma
    Private nLen := 150, nStr := nLine := 0, nPage := 0, nSizePage := 67
    Private cChet, dDataRas, nList := 0, Delim := 0

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
                     {"Cena", "N",15,06},;
                     {"Sum",  "N",13,02},;
                     {"Ndc",  "N",13,02},;
                     {"Fec",  "N",13,02},;
                     {"Summa","N",13,02},;
                     {"SumBank","N",13,02},;
                     {"Npp",  "N",05,00}} )
    use (cFile) new alias Work
    Index on str(Chet,4,0)+str(Tip,1)+str(Ent,4) to (cFile)
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
      PutPrix2(" ")
      While !Work->(eof()) .and. cChet == Work->Chet
        nTip := Work->Tip
        tKolvo := tSum := tNdc := tFec := tSumma := tSumBank := 0
        S_Gr->(DbSeek(str(nTip,1)))
        PutPrix2( "     Группа N "+str(nTip,1)+" "+S_Gr->Naim )
        While !Work->(eof()) .and. nTip == Work->Tip .and. cChet == Work->Chet
          PutPrix2( str(Work->Ent,4)+" "+S_Ent->Naim+" "+;
         "        :"+ str(Work->Summa,15,2)+":             :                         :         :           :  " )
          tKolvo += Work->Kolvo
          tSum   += Work->Sum
          tNdc   += Work->Ndc
          tFec   += Work->Fec
          tSumma += Work->Summa
          tSumBank += Work->SumBank
          S_Line_N(18,04,65,nLastRec,++nRecno)
          Work->(DbSkip(1))
          PutPrix2( Repl("-",nLen) )
        End
        PutPrix2( Repl("-",nLen) )
      ///  PutPrix1( "     "+padr("Итого по группе ",35)+" "+;
     ////       str(tKolvo,15)+" "+space(7)+" "+;
     ////       str(tSum,15,2)+" "+str(tNdc,15,2)+" "+str(tFec,15,2)+" "+;
     ////       str(tSumBank,15,2)+" "+str(tSumma,15,2) )
        cKolvo += tKolvo
        cSum   += tSum
        cNdc   += tNdc
        cFec   += tFec
        cSumma += tSumma
        cSumBank += tSumBank
      End
      PutPrix2( Repl("-",nLen) )
    //  PutPrix1( "     "+padr("Итого по счету ",35)+" "+;
    ///        str(cKolvo,15)+" "+space(7)+" "+;
    ///        str(cSum,15,2)+" "+str(cNdc,15,2)+" "+str(cFec,15,2)+" "+;
    ///        str(tSumBank,15,2)+" "+str(cSumma,15,2) )
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
Static Function PutPrix2(cLine)
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
      if cChet != Delim
        Delim := cChet
        nPage := 0
      end
      nList++
      nPage++
      @ prow()+1,00 say " "
      @ prow()+1,00 say "Лист# "+str(++nStr,3)
      @ prow()+1,00 say " "
      @ prow()+1,00 say " "
      @ prow()+1,00 say " "

      if nPage == 1
        @ prow()+1,00 say "                                                                                                                    Утверждаю"
        @ prow()+1,00 say "                                                                                                                 начальник KПУВКХ"
        @ prow()+1,00 say padc("Р Е Е С Т Р налоговых наклодных   ",nLen)
        @ prow()+1,00 say padc("по ПЕРВОМАЙСКОМУ KПУВКХ",nLen)
        @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
        @ prow()+1,00 say padc("по счету "+str(cChet,4,0)+" "+S_Chet->Naim,nLen)
        @ prow()+1,00 say " "
        @ prow()+1,00 say Repl("-",nLen)
        @ prow()+1,00 say "      Наименование организации      Докум              Сумма        ДАТА                     Ф И О          Долж     Роспись        "
        @ prow()+1,00 say "                                                             .   получения                                                                                "
        @ prow()+1,00 say Repl("-",nLen)
        nLine += 12
      end
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
          S_Chet->(DbSeek(str(cChet,4,0)))
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
// Формирование Задолженности
Function VedDolg()
    Local cLine := sset[112][2], cFile := sset[112][2]+"Kred.txt", dDataRas
    Local nRecno, nLastRec, nSumma, fSumma := 0, nTip, nNpp := 0
    Private nPage := 0, nLine := 60, nLen := 55



    if !Ostatok->(DbSeek(str(0,4)))  ;  return ( Nil ) ; end
    nSumma := Alltrim(str(Ostatok->Summa,10))
    dDataRas := ctod(Substr(nSumma,7,2)+"."+Substr(nSumma,5,2)+"."+Substr(nSumma,1,4))
    if !File(sset[112][1]+"OstNew.Dbf")
       S_Err({"Вы не сформировали ведомость"})
       Return ( Nil )
    End
    S_FileDel(cLine+"Work.*")
    Dbcreate(cLine+"WORK",{ {"Ent", "N",04,00},;
                            {"Naim","C",30,00},;
                            {"Tip", "N",01,00},;
                            {"Summa", "N",15,02}} )
    use (cLine+"WORK") new 
    Index on str(Tip,1)+str(Ent,4) to (cLine+"WORK")
    use (sset[112][1]+"OstNew") new
    Set Relation to str(Ent,4) into S_ENT
    nLastRec := 2*OstNew->(LastRec())
    S_Line_N(16,3,65,nLastRec,1)
    @ 01,06 say "Внимание..."
    @ 01,40 say "Формирую ведомость"
    nRecno := [" По окончании будет подан звуковой сигнал "]
    @ 00,(MaxCol()-len(nRecno))/2 say nRecno
    OstNew->(DbGoTop())
    OstNew->(DbSkip(1))
    nRecno := 1
    While ( !OstNew->(eof()) )
      Work->(Dbappend())
      Work->Ent   := OstNew->Ent
      Work->Tip   := S_Ent->Tip
      Work->Naim  := S_Ent->Naim
      Work->Summa := OstNew->Summa
      S_Line_N(18,04,65,nLastRec,++nRecno)
      OstNew->(DbSkip(1))
    End
    OstNew->(DbCloseArea())
    Work->(DbGoTop())
    set(20,"PRINT")
    set(24,cFile)
    @ prow()+1,00 say " "
    @ prow()+1,00 say " Ведомость остатков на конец месяца"
    @ prow()+1,00 say " расчета с поставщиками за холодную воду и канализацию "
    @ prow()+1,00 say "     на "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г."
    @ prow()+1,00 say "  "
    nLine := 4
    While ( !Work->(eof()) )
      nTip := Work->Tip
      S_Gr->(DbSeek(str(nTip,1)))
      nSumma := 0
      TestDolg( S_Gr->Naim )
      While ( nTip == Work->Tip .and. !Work->(eof()) )
        TestDolg( str(++nnPp,3)+" "+str(Work->Ent,4)+" "+Work->Naim+" "+;
                  str(Work->Summa,15,2) )
        nSumma += Work->Summa
        S_Line_N(18,04,65,nLastRec,++nRecno)
        Work->(Dbskip(1))
      End
      fSumma += nSumma
      TestDolg( Repl("-",nLen) )
      TestDolg( "     "+"    "+space(30)+" "+str(nSumma,15,2) )
    End
    @ prow()+1,00 say repl("=",nLen)
    @ prow()+1,00 say "     "+"    "+space(30)+" "+str(fSumma,15,2) 
    @ prow()+1,00 say " "
    nLine += 3
    for j := nLine to 60
      @ prow()+1,00 say " "
    next
    @ prow()+1,00 say ""
    S_Line_N()
    set(24,"")
    set(20,"SCREEN")
    ShowPrn(cFile," Ведомость ",74)
    Work->(DbCloseArea())
    S_FileDel(cLine+"Work.*")
    fErase(cFile)
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static function TestDolg(cLine)
    Local i
    if nPage == 0 .or. nLine > 64
       if nLine > 64
         For i := nLine to 67
            @ prow()+1,00 say Padc(" ",nLen)
         Next
         @ prow()+1,00 say repl(".",nLen)
         nLine := 0
       End
       @ prow()+1,00 say padr(" Лист# "+str(++nPage,3),nLen)
       @ prow()+1,00 say repl("-",nLen)
       @ prow()+1,00 say " N |Код | Наименование                 | Сальдо на     "
       @ prow()+1,00 say "п/п|орг.| организации                  | конец месяца  "
       @ prow()+1,00 say repl("-",nLen)
       nLine += 5
    End
    @ prow()+1,00 say cLine
    nLine++
    Return ( Nil )
    ///////////////////////////////////////////////////////////////////////////
    Function PrnBook() // Печать книги продавца
    Local ColorOld := SetColor(), CursorOld := SetCursor(1)
    Local dDataNac := S_bom(date()), dDataKon := S_eom(date())
    Local cFile := sset[112][2]+"Prod"

    Private nPage := 1, nLine, oFile1, oFile2

    BEGIN SEQUENCE
        S_Open_m(11,08,15,50,Sset[77],sset[77])
        SetColor(Sset[76]+","+sset[77]+",,,"+sset[76])
        @ 01,01 say " Укажите период формирования ведомости:"
        @ 02,08 say "Начальная дата:" get dDataNac pict "@d" valid !Empty(dDataNac)
        @ 03,08 say "Конечная дата: " get dDataKon pict "@d" valid dDataKon >= dDataNac
        read
        S_wCloseSl(S_RanDom()%22+1)
        SetColor(ColorOld)
        if LastKey() == K_ESC ; break ; End
        Fakt->(DbSetOrder(2))
        Fakt->(DbGoTop())
        While !Fakt->(eof())
           if Fakt->Data >= dDataNac ; Exit ; End
           Fakt->(DbSkip(1))
        End
        if Fakt->(eof())
           S_Err({"Данные отсутствуют"})
           Break
        End
        oFile1 := oFileNew()
         oFile2 := oFileNew()
        oFile1:Open(cFile+"1.txt")
         oFile2:Open(cFile+"2.Txt")
        oFile1:WriteLn(chr(15))
         oFile2:WriteLn(chr(15))
        oFile1:Writeln("   Первомайское ПУВКХ ") 
         oFile2:Writeln(" ")
        oFile1:Writeln(" ")
         oFile2:Writeln(" ")
        oFile1:WriteLn(padc(" КНИГА УЧЕТА ПРОДАЖИ ТОВАРОВ  (РАБОТ, УСЛУГ)",170))
         oFile2:WriteLn("  ")
        if dDataNac = dDataKon
           oFile1:WriteLn(padc( "ЗА "+dtoc(dDataNac),170))
           oFile2:Writeln(" ")
        else
           oFile1:WriteLn(padc( "С "+dtoc(dDataNac)+" ПО "+dtoc(dDataKon),170))
           oFile2:Writeln(" ")
        end
        oFile1:Writeln("")
         oFile2:Writeln(" ")
        oFile1:Writeln(padr("  Лист# "+str(nPage,3),170))
         oFile2:Writeln(padr("  Лист# "+str(nPage,3),122))
        oFile1:Writeln("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
        oFile1:Writeln("|     |      |          |                                   |Индивидуаль-|Общий обьем про-|Обьем продажи товаров(работ, услуг), по которым не возникают налоговые обязательства)               |")
        oFile1:Writeln("|     |      |          |                                   |ный налого- |дажи товаров,ра-|----------------------------------------------------------------------------------------------------| ")
        oFile1:Writeln("|     |      |          |                                   |вый номер   |бот, услуг,вклю-|Общий обьем|                 продажа на таможенной территории Украины              |на экспорт,кроме|")
        oFile1:Writeln("|     |      |          |                                   |номер поку- |    чая НДС     |продажи то-|-----------------------------------------------------------------------|услуг,предусмот-|")
        oFile1:Writeln("|     |      |          |                                   |   теля     |     (7+15)     |варов,работ| Лицам,которые являются плательщи- | Лицам,которые не являются платель-|ренных последним|")
        oFile1:Writeln("|     |      |          |                                   |            |                |   услуг   |            ками налога            |            щиками налога          |абзацем подпункт|")
        oFile1:Writeln("|     |      |          |                                   |            |                |(8+9+10+11 |-----------------------------------|-----------------------------------|6.2.1, абзацами |")
        oFile1:Writeln("|  N  |номер |   дата   |     П о к у п а т е л ь           |            |                | +12+13+14)| По ставке |Освобожден-|Не являются| По ставке |Освобожден-|Не являются|вторым и третим |")
        oFile1:Writeln("| п/п |накла |  выписки |                                   |            |                |           |     0%    |ных от на- |объектамами|     0%    |ных от на- |объектамами|подпункта 6.2.4,|")
        oFile1:Writeln("|     |ной   |          |                                   |            |                |           |           |логобложе- |налогообло-|           |логобложе- |налогообло-|подпунктом 6.2.2|")
        oFile1:Writeln("|     |      |          |                                   |            |                |           |           |    ния    |  жения    |           |   ния     |  жения    |статьи 6,по ста-|")
        oFile1:Writeln("|     |      |          |                                   |            |                |           |           |  (ст.5)   |(пункт 3.2 |           |  (ст.5)   |(пункт 3.2 |    вке 0%      |")
        oFile1:Writeln("|     |      |          |                                   |            |                |           |           |           |  ст.3)    |           |           |  ст.3)    |                |")
        oFile1:Writeln("|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|")
        oFile1:Writeln("|  1  |  2   |     3    |                  4                |      5     |         6      |      7    |      8    |      9    |     10    |     11    |     12    |     13    |       14       |")
        oFile1:Writeln("|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|")
        //
        oFile2:Writeln("|----------------------------------------------------------------------------------------------------------------------------------------------------------")
        oFile2:Writeln("|      |       Объемы продажи товаров, работ, услуг, для которых   |        Объем проведенных корректив            |Проведение расчетов с продажи товаров |")
        oFile2:Writeln("|      |             предусмотрено налоговое обязательство         |                                               |              работ, услуг            |")
        oFile2:Writeln("|      |-----------------------------------------------------------------------------------------------------------|--------------------------------------|")
        oFile2:Writeln("|      |Общие объ- |   Продажа на таможенной территории Украины    |корректировка продажи  |корректировка с продажи|Форма расчета (бартер,на-|Дата прове- |")
        oFile2:Writeln("|      |емы продаж |-----------------------------------------------|товаров, услуг, которые|товаров, работ, услуг, |личные, оплата с расчет- |дения расче-|")
        oFile2:Writeln("|      | (16+17+   |  Плательщикам НДС     | Не плательщикам НДС   |облаг-ся по ставке 20% |для которых НДС не на- |ного счета и др.)        |    тов     |")
        oFile2:Writeln("|Номер |  18+19)   |-----------------------|-----------------------|                       |      числяется        |                         |            |")
        oFile2:Writeln("|накла |           | База обло-|  НДС по   | База обло-|  НДС по   |-----------------------------------------------|                         |            |")
        oFile2:Writeln("|дной  |           |   жения   |ставке 20% |   жения   |ставке 20% |База обло- | Сумма НДС |    База обложения     |                         |            |")
        oFile2:Writeln("|      |           |           |           |           |           |   жения   |           |-----------------------|                         |            |")
        oFile2:Writeln("|      |           |           |           |           |           |   (+,-)   |   (+,-)   | По ставке |Освобожден-|                         |            |")
        oFile2:Writeln("|      |           |           |           |           |           |           |           |     0%    |ные (ст.5) |                         |            |")
        oFile2:Writeln("|      |           |           |           |           |           |           |           |    (+,-)  |   (+,-)   |                         |            |")
        oFile2:Writeln("|------|--------------------------------------------------------------------------------------------------------------------------------------------------|")
        oFile2:Writeln("|      |     15    |     16    |    17     |     18    |    19     |     20    |     21    |     22    |     23    |           24            |     25     |")
        oFile2:Writeln("|---------------------------------------------------------------------------------------------------------------------------------------------------------|")
        nLine := 23
        S_Sys({"Минутку терпения","Формируется ведомость"})
        While Fakt->Data <= dDataKon .and. !Fakt->(eof())
           dData := Fakt->Data
           nData6 := nData15 := nData16 := nData17 := nPP := 0
           While Fakt->Data <= dDataKon .and. dData == Fakt->Data .and. !Fakt->(eof())
              nNomCf := Fakt->NomChF
              nNom6  := nNom15 := nNom16 := nNom17 := 0
              cForma := Fakt->Sposob
              dDataCh:= Fakt->Data
              S_Ent->(DbSeek(str(Fakt->Ent,4)))
              While nNomCf == Fakt->NomChF .and. Fakt->Data <= dDataKon .and. ;
                                             dData == Fakt->Data .and. !Fakt->(eof())
                  nNom6  += Fakt->Summa + Fakt->Ndc
                  nNom15 += Fakt->Summa + Fakt->Ndc
                  nNom16 += Fakt->Summa
                  nNom17 += Fakt->Ndc
                  Fakt->(DbSkip(1))
              End
              PutBook( str(++nPP,6)+" "+str(nNomCf,6)+" "+dtoc(dDataCh)+" "+;
                       S_Ent->Naim+" "+S_Ent->KodNalog+" "+str(nNom6,16,2)+" "+;
                       space(11)+" "+space(11)+" "+space(11)+" "+space(11)+" "+;
                       space(11)+" "+space(11)+" "+space(11)+" "+space(16),;
                         str(nNomCf,6)+" "+str(nNom15,11,2)+" "+str(nNom16,11,2)+" "+;
                         str(nNom17,11,2)+" "+space(11)+" "+space(11)+" "+;
                         space(11)+" "+space(11)+" "+space(11)+" "+space(11)+" "+;
                         " "+padr(cForma,25)+" "+Substr(dtoc(date()),4) )
               nData6  += nNom6
               nData15 += nNom15
               nData16 += nNom16
               nData17 += nNom17
           End
           oFile1:Writeln("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
           oFile1:Writeln( "    Итого за  "+dtoc(dData)+" "+;
                       Space(35)+" "+space(12)+" "+str(nData6,16,2)+" "+;
                       space(11)+" "+space(11)+" "+space(11)+" "+space(11)+" "+;
                       space(11)+" "+space(11)+" "+space(11)+" "+space(16) )
           oFile1:Writeln("  Исполнитель ")
           oFile1:Writeln("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
           //
           oFile2:Writeln("-----------------------------------------------------------------------------------------------------------------------------------------------------------")
           oFile2:Writeln( "      "+" "+str(nData15,11,2)+" "+str(nData16,11,2)+" "+;
                         str(nData17,11,2)+" "+space(11)+" "+space(11)+" "+;
                         space(11)+" "+space(11)+" "+space(11)+" "+space(11)+" "+;
                         space(25)+" "+space(10) )
           oFile2:Writeln(" ")
           oFile2:Writeln("-----------------------------------------------------------------------------------------------------------------------------------------------------------")
           nLine := 0
        End
        for i := 1 to 4
            oFile1:Writeln(" ")
            oFile2:Writeln(" ")
        next i
        S_Sys()
        oFile1:Close()
        oFile2:Close()
        ShowPrn((cFile+"1.txt"),"1-ю часть ведомости на экран",74)
        ShowPrn((cFile+"2.Txt"),"2-ю часть ведомости на экран",74)
    END SEQUENCE
    Fakt->(DbSetOrder(1))
    SetColor(ColorOld)
    SetCursor(CursorOld)
    fErase(cFile+"1.txt")
    fErase(cFile+"2.Txt")
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Static Function PutBook(cLine1,cLine2)
    Local i
    if nLine > 65 .or. nLine == 0
      if nLine > 0
        for i := nLine to 68
          oFile1:Writeln(" ")
          oFile2:Writeln(" ")
        End
        oFile1:Writeln(Repl(".",170))
        oFile2:Writeln(Repl(".",122))
      End
      ++nPage
      oFile1:Writeln(" ")
      oFile1:Writeln(padr("  Лист# "+str(nPage,3),170))
      oFile1:Writeln("|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|")
      oFile1:Writeln("|  1  |  2   |     3    |                  4                |      5     |         6      |      7    |      8    |      9    |     10    |     11    |     12    |     13    |       14       |")
      oFile1:Writeln("|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|")
      //
      oFile2:Writeln(" ")
      oFile2:Writeln(padr("  Лист# "+str(nPage,3),122))
      oFile2:Writeln("|------|--------------------------------------------------------------------------------------------------------------------------------------------------|")
      oFile2:Writeln("|      |     15    |     16    |    17     |     18    |    19     |     20    |     21    |     22    |     23    |           24            |     25     |")
      oFile2:Writeln("|---------------------------------------------------------------------------------------------------------------------------------------------------------|")
      nLine := 5
    end
    oFile1:Writeln(cLine1)
    oFile2:Writeln(cLine2)
    nLine++
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function VedOstN()
    Local cLine := sset[112][2], cFile := sset[112][2]+"OstN.txt", dDataRas
    Local nRecno, nLastRec, nSumma, fSumma := 0, nTip, nNpp := 0
    Private nPage := 0, nLine := 60, nLen := 55

    if !Ostatok->(DbSeek(str(0,4)))  ;  return ( Nil ) ; end
    nSumma := Alltrim(str(Ostatok->Summa,10))
    dDataRas := ctod(Substr(nSumma,7,2)+"."+Substr(nSumma,5,2)+"."+Substr(nSumma,1,4))
    S_FileDel(cLine+"Work.*")
    Dbcreate(cLine+"WORK",{ {"Ent", "N",04,00},;
                            {"Naim","C",30,00},;
                            {"Tip", "N",01,00},;
                            {"Summa", "N",15,02}} )
    use (cLine+"WORK") new
    Index on str(Tip,1)+str(Ent,4) to (cLine+"WORK")
    Set Relation to str(Ent,4) into S_ENT
    nLastRec := Ostatok->(LastRec()) - 1
    S_Line_N(16,3,65,nLastRec,1)
    @ 01,06 say "Внимание..."
    @ 01,40 say "Формирую ведомость"
    nRecno := [" По окончании будет подан звуковой сигнал "]
    @ 00,(MaxCol()-len(nRecno))/2 say nRecno
    Ostatok->(DbGoTop())
    Ostatok->(DbSkip(1))
    nRecno := 0
    While ( !Ostatok->(eof()) )
      S_Ent->(DbSeek(str(Ostatok->Ent,4)))
      Work->(Dbappend())
      Work->Ent   := Ostatok->Ent
      Work->Tip   := S_Ent->Tip
      Work->Naim  := S_Ent->Naim
      Work->Summa := Ostatok->Summa
      S_Line_N(18,04,65,nLastRec,++nRecno)
      Ostatok->(DbSkip(1))
    End
    S_Line_N()
    Work->(DbGoTop())
    set(20,"PRINT")
    set(24,cFile)
    @ prow()+1,00 say " "
    @ prow()+1,00 say " Ведомость остатков на начало месяца"
    @ prow()+1,00 say " расчета с поставщиками за холодную воду и канализацию "
    @ prow()+1,00 say "     на "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г."
    @ prow()+1,00 say "  "
    nLine := 4
    While ( !Work->(eof()) )
      nTip := Work->Tip
      S_Gr->(DbSeek(str(nTip,1)))
      nSumma := 0
      TestDolg( S_Gr->Naim )
      While ( nTip == Work->Tip .and. !Work->(eof()) )
        TestOstN( str(++nnPp,3)+" "+str(Work->Ent,4)+" "+Work->Naim+" "+;
                  str(Work->Summa,15,2) )
        nSumma += Work->Summa
        Work->(Dbskip(1))
      End
      fSumma += nSumma
      TestOstN( Repl("-",nLen) )
      TestOstN( "     "+"    "+space(30)+" "+str(nSumma,15,2) )
    End
    @ prow()+1,00 say repl("=",nLen)
    @ prow()+1,00 say "     "+"    "+space(30)+" "+str(fSumma,15,2)
    @ prow()+1,00 say " "
    nLine += 3
    for j := nLine to 60
      @ prow()+1,00 say " "
    next
    @ prow()+1,00 say ""
    set(24,"")
    set(20,"SCREEN")
    ShowPrn(cFile," Ведомость ",74)
    Work->(DbCloseArea())
    S_FileDel(cLine+"Work.*")
    fErase(cFile)
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static function TestOstN(cLine)
    Local i
    if nPage == 0 .or. nLine > 64
       if nLine > 64
         For i := nLine to 67
            @ prow()+1,00 say Padc(" ",nLen)
         Next
         @ prow()+1,00 say repl(".",nLen)
         nLine := 0
       End
       @ prow()+1,00 say padr(" Лист# "+str(++nPage,3),nLen)
       @ prow()+1,00 say repl("-",nLen)
       @ prow()+1,00 say " N |Код | Наименование                 | Сальдо на     "
       @ prow()+1,00 say "п/п|орг.| организации                  | начало месяца "
       @ prow()+1,00 say repl("-",nLen)
       nLine += 5
    End
    @ prow()+1,00 say cLine
    nLine++
Return ( Nil )
