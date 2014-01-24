#include "inkey.ch"
//////////////////////////////////////////////////////////////////////////
Function PrnNalogG()
Local ColorOld := SetColor(), NortonOld,i,;
      nKey, nRow, ch_ := chr(13)+chr(10),;
      GetList := {},;
      CursorOld := setCursor(1)
Local cFile := sset[112][2]+"NN"

BEGIN SEQUENCE
aSposob := {}
Sposob->(DbGoTop())
While !Sposob->(eof())
  aadd(aSposob,{Sposob->Sposob,Sposob->NaimSpos})
  Sposob->(DbSkip(1))
End
Ferase( cFile+".dbf")
DbCreate(cFile,{ {"Naim",   "C",30,00},;   // Наименование продукта
                 {"EdIzm",  "C",07,00},;   // Единица измерения
                 {"Kolvo",  "N",15,04},;   // Количество
                 {"Cena",   "N",15,06},;   // Цена
                 {"Summa",  "N",15,02},;   // сумма
                 {"Gr",     "N",01,00},;   // Графа
                 {"Kol",    "N",02,00} } ) // Колонка
use (cFile) new alias Work
ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32])
S_Open_M(01,01,22,77)
@ 07,01 say repl("─",MaxCol()-1)
@ 08,01 say " Наименование поставки        │Ед.изм.│Р│К │"
@ 09,01 say repl("─",MaxCol()-1)
for i := 10 to MaxRow()-3
  @ i,44 say "│"
Next
@ MaxRow()-2,01 say repl("─",MaxCol()-1)
NortonOld := DeskTop:Norton()
While .t.
 DeskTop:Norton := NortonOld
 SetCursor(1)
 obj := Nil
 SetCursor(1)
 DbSelectArea("Work")
 Set Index to
 Ferase( cFile+".Ntx")
 Zap
 Scroll(01,01,06,MaxCol()-1)
 Scroll(10,01,MaxRow()-3,43)
 Scroll(10,45,MaxRow()-3,MaxCol()-1)
 @ MaxRow()-1,01 say padc("ESC - Выход из программы",MaxCol()-1)
 nNumDocum := nGod := 0
 dData := date()
 @ 01,01 say "N док." get nNumDocum Pict "999999" valid nNumdocum > 0
 @ 01,15 say "год" get nGod Pict "9999" valid nGod > 1996
 read
 if LastKey() == K_ESC ; exit ; End
 @ MaxRow()-1,01 say padc("ESC - Отказ",MaxCol()-1)
 nEnt := 0
 @ 01,25 say "Укажите код организации" get nEnt pict "9999" ;
                                       valid VedEnt(@nEnt,01,25)
 read
 if LastKey()==K_ESC ; loop ; End
 cKodNalog := xKodNalog := S_Ent->KodNalog
 cKodSvid  := xKodSvid  := S_Ent->KodSvid
 cNaim     := S_Ent->Naim
 cAdres    := xAdres    := S_Ent->Adres
 @ 02,01 say "Дата" Get dData pict "@d" valid !Empty(dData)
 read
 if LastKey()==K_ESC ; loop ; End
 if !NalNakl->(DbSeek(str(nGod,4)))
    NalNakl->(DbAppend())
    NalNakl->God := nGod
 End
 nRecno    := NalNakl->(Recno())
 nNomNakl  := NalNakl->NomNakl + 1
 @ 03,01 say "Порядковый N" get nNomNakl pict "9999999999" valid nNomNakl > 0
 read
 if LastKey()==K_ESC ; loop ; End
 if nNomNakl > NalNakl->NomNakl
   NalNakl->(DbGoto(nRecno))
   NalNakl->NomNakl := nNomNakl
 End
 @ 01,25 Get cNaim  valid !Empty(cNaim)
 @ 02,25 Get cAdres valid !Empty(cAdres)
 read
 if LastKey()==K_ESC ; loop ; End
 xCustom := space(20)
 dCustom := ctod("")
 dDataOtg:= dData
 @ 03,26 say "ИННП" get cKodNalog
 @ 03,44 say "ИСП"  get cKodSvid
 @ 04,01 say "Договор" get xCustom
 @ 04,30 say "от" get dCustom pict "@d"
 @ 04,51 say "Дата отгрузки" get dDataOtg pict "@d" valid !Empty(dDataOtg)
 read
 if LastKey()==K_ESC ; loop ; End
 i := SeekSpos(aSposob)
 cForma := aSposob[i][2]
 nForma := aSposob[i][1]
 cCustom  := padr(alltrim(xCustom)+" от "+dtoc(dCustom)+" г.",30)
 @ 05,01 say "Форма приведенных расчетов" get cForma valid !Empty(cForma)
 read
 if LastKey()==K_ESC ; loop ; End
 if ( ( Empty(xKodNalog)  .and. !Empty(cKodNalog) ) .or. ;
      ( Empty(xAdres)     .and. !Empty(cAdres) )    .or. ;
      ( Empty(xKodSvid)  .and. !Empty(xKodSvid) ) )
    S_Ent->KodNalog := cKodNalog
    S_Ent->KodSvid  := cKodSvid
    S_Ent->Adres    := cAdres
 End
 cKodNalog := iif(empty(cKodNalog),repl("X",12),cKodNalog)
 cKodSvid  := iif(empty(cKodSvid), repl("X",8), cKodSvid)
 nSummaKrb := nSummaNdc := 0
 @ 06,01 say "Сумма "+str(nSummaKrb,15,2)
 @ 06,25 say "НДС "+str(nSummaNdc,15,2)
 Work->(DbGoTop())
 obj := TBrowseDb(10,01,MaxRow()-3,43)
 obj:AddColumn(TbColumnNew("",{|| Work->Naim+"│"+;
                                 Work->EdIzm+"│"+;
                                 str(Work->Gr,1)+"│"+;
                                 str(Work->Kol,2) } ))
 @ 13,47 say "Цена"
 @ 14,47 say "Кол-во"
 @ 15,47 say "Сумма "
 Setcursor(0)
 oNortonNew( {{"3Удалить","4Регистр","5Коррек"}} )
 While .t.
  Work->(DbGoTop())
  While .t.
    nKey := 0
    While ( !obj:Stabilize() )
       if ( nKey := S_Inkey() ) != 0 ; exit ; end
    end
    nRow := Row()
    @ 13,54 say Work->Cena  pict "99999999.999999"
    @ 14,54 say Work->Kolvo pict "9999999999.9999"
    @ 15,54 say Work->Summa pict "999999999999.99"
    if nKey == 0 ; nKey := S_Inkey(0) ; end
    if nKey == K_ESC ; exit ; end
    if Obj:Stable
      do case
         case nKey == K_F3
              Work->(DbGoTop())
              FreshOrder(obj)
         case nKey == K_F4
           nKol   := 7
           Obj:DeHilite()
           While .t.
                Scroll(10,01,MaxRow()-3,43,-1)
                Setcursor(1)
                cNaimProd := space(30)
                cEdIzm    := space(7)
                nSumma := nKolvo := nCena  := 0
                nGr    := 1
                @ 10,40 get nGr pict "9" valid nGr >= 1 .and. nGr <= 6 .and. nGr <> 5
                @ 10,42 get nKol pict "99" range 7,10
                read
                if LastKey() == K_ESC ; exit ; End
                if nGr == 1
                  @ 10,01 get cNaimProd
                  @ 10,32 get cEdIzm
                  @ 13,54 get nCena  pict "99999999.999999"
                  @ 14,54 get nKolvo pict "9999999999.9999"
                  read
                  if LastKey() == K_ESC ; exit ; End
                elseif nGr == 2
                  cNaimProd := padr("Трансп.-заготов. расходы",30)
                  cEdIzm    := "грн.   "
                elseif nGr == 3
                  cNaimProd := padr("Возвратная тара",30)
                  cEdIzm    := "грн.   "
                elseif nGr == 4
                  cNaimProd := padr("Скидка/надбавка",30)
                  cEdIzm    := "грн.   "
                elseif nGr == 6
                  cNaimProd := padr("Н Д С ",30)
                  cEdIzm    := "грн.   "
                End
                @ 10,01 say cNaimProd
                @ 10,32 say cEdIzm
                nSumma := iif(nKolvo*nCena==0,nSumma,NEW_ROUND(nKolvo*nCena,2))
                @ 15,54 get nSumma pict "999999999999.99"
                read
                if LastKey() == K_ESC ; exit ; End
                Work->(DbAppend())
                Work->Gr := nGr
                Work->Kol:= nKol
                Work->Summa := nSumma
                Work->Kolvo := nKolvo
                Work->Cena  := nCena
                Work->EdIzm := cEdIzm
                Work->Naim  := cNaimProd
                nSummaKrb += nSumma
                if Work->Gr == 6
                   nSummaNdc += nSumma
                End
                @ 06,07 say nSummaKrb pict "999999999999.99"
                @ 06,29 say nSummaNdc pict "999999999999.99"
           End
           Work->(DbGoTop())
           FreshOrder(obj)
           Setcursor(0)
         case nKey == K_F5
             Setcursor(1)
             BEGIN SEQUENCE
             nGr := Work->Gr
             nKol:= Work->Kol
             nSummaOld := nSumma := Work->Summa
             nKolvo := Work->Kolvo
             nCena  := Work->Cena
             cNaimProd := Work->Naim
             cEdIzm    := Work->EdIzm
             Obj:DeHilite()
             @ nRow,01 get cNaimProd
             @ nRow,32 get cEdIzm
             @ nRow,40 get nGr pict "9" range 1,6
             @ nRow,42 get nKol pict "99" range 7,10
             @ 13,54 get nCena  pict "99999999.999999"
             @ 14,54 get nKolvo pict "9999999999.9999"
             read
             if LastKey() == K_ESC ; break ; End
             nSumma := iif(nKolvo*nCena==0,nSumma,NEW_ROUND(nKolvo*nCena,2))
             @ 15,54 get nSumma pict "999999999999.99"
             read
             if LastKey() == K_ESC ; break ; End
             Work->Gr := nGr
             Work->Kol:= nKol
             Work->Summa := nSumma
             Work->Kolvo := nKolvo
             Work->Cena  := nCena
             Work->EdIzm := cEdIzm
             Work->Naim  := cNaimProd
             nSummaKrb += ( - nSummaOld + nSumma )
             if Work->Gr == 6
                nSummaNdc += ( - nSummaOld + nSumma )
             End
             @ 06,07 say nSummaKrb pict "999999999999.99"
             @ 06,29 say nSummaNdc pict "999999999999.99"
             END SEQUENCE
             FreshOrder(obj)
             Setcursor(0)
         Other
           ApplyKey(nKey,Obj)
      End
    End
  End
  Setcursor(1)
  nKey := 0
  Work->(DbGoTop())
  While !Work->(eof())
    if Empty(Work->Gr) .or. Empty(Work->Kol)
      nKey++
    End
    Work->(DbSkip(1))
  End
  if nKey > 0
    S_Err({"Внимание!","Вы не закончили работу"})
    loop
  End
  @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
  While .t.
    nFio := 1
    @ MaxRow()-1,01 say "Укажите код исполнителя" get nFio pict "99" range 1,4
    read
    if !NalNakl->(DbSeek(str(nFio,4)))
       S_Err({"Отсутствует исполнитель"})
       loop
    End
    cFio := NalNakl->Fio
    Exit
  End
  Exit
 End
 @ MaxRow()-1,30 get cFio valid !Empty(cFio)
 read
 Index on str(Gr,1)+str(Kol,2) to ( cFile+".Cdx")
 @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
 nRow := 1
 @ MaxRow()-1,01 say "Укажите количество экземпляров" get nRow pict "9" range 0,4
 read
 if nRow > 0
   @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
   @ MaxRow()-1,01 say "    Приложение имеется?"
   @ MaxRow()-1,26 prompt " Нет "
   @ MaxRow()-1,32 prompt " Да  "
   Menu to obj
   @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1)
   SPrnNakl(cFile,nNomNakl,nNumDocum,cNaim,cKodNalog,cAdres,;
            cKodSvid,cCustom,cForma,cFio,obj,nRow)
 End
/************************************************************
 @ MaxRow()-1,01 say padc("Еще одну секундочку",MaxCol()-1)
 Work->(DbGoTop())
 nGodNakl := year(dData)
 nSum01 := nSum02 := nSum03 := nSum04 := nSum06 := nGr := 0
 if DopInfo->(DbSeek(str(nNomNakl,10)+str(nGodNakl,4)))
   While DopInfo->GodNakl == nGodNakl .and. DopInfo->NomNakl == nNomNakl .and. ;
         !DopInfo->(eof())
      if M_Rlock(20,"DopInfo")
        DopInfo->(DbDelete())
        DopInfo->(DbUnlock())
      End
      DopInfo->(DbSkip(1))
   End
 End
 While !Work->(eof())
   nSum01 += iif(Work->Gr == 1,Work->Summa,0)
   nSum02 += iif(Work->Gr == 2,Work->Summa,0)
   nSum03 += iif(Work->Gr == 3,Work->Summa,0)
   nSum04 += iif(Work->Gr == 4,Work->Summa,0)
   nSum06 += iif(Work->Gr == 6,Work->Summa,0)
   if Work->Gr == 1
      nGr := iif(empty(nGr),Work->Kol,nGr)
      if M_Append(20,"DopInfo")
       DopInfo->GodNakl := nGodNakl
       DopInfo->NomNakl := nNomNakl
       DopInfo->KodProd := Work->Kod
       DopInfo->Kolvo   := Work->Kolvo
       DopInfo->CenaGrv := Work->Cena
       DopInfo->SummaGrv:= Work->Summa
       DopInfo->(DbUnlock())
      End
   End
   Work->(DbSkip(1))
 End
 if !NalInfo->(DbSeek(str(nNomNakl,10)+str(nGodNakl,4))) .And. M_Append(20,"NalInfo")
    NalInfo->GodNakl:= nGodNakl
    NalInfo->NomNakl:= nNomNakl
    NalInfo->(DbUnlock())
 End
 if M_Rlock(20,"NalInfo")
    NalInfo->Data_V := dData
    NalInfo->NumDocum := nNumDocum
    NalInfo->God      := nGod
    NalInfo->EntPl    := nEnt
    NalInfo->Custom   := xCustom
    NalInfo->DataCust := dCustom
    NalInfo->FormRas  := nForma
    NalInfo->Fio      := nFio
    NalInfo->DataOtg  := dDataOtg
    NalInfo->Pgr      := nGr
    NalInfo->Sum01    := nSum01
    NalInfo->Sum02    := nSum02
    NalInfo->Sum03    := nSum03
    NalInfo->Sum04    := nSum04
    NalInfo->Sum06    := nSum06
    NalInfo->(DbUnlock())
 End
************************************************/
End
S_wCloseSl(S_RanDom()%22+1)
DeskTop:Norton := NortonOld
END SEQUENCE
SetColor(ColorOld)
SetCursor(CursorOld)
Ferase( cFile+".dbf")
Ferase( cFile+".Cdx")
Ferase( cFile+".txt")
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
Static function M_Tprn(File,KolEkz)
Local Obj := oFileNew(File,0), cLine, i, nPrint := 0

BEGIN SEQUENCE
//Set Device to print
//S_SetPrn(160,1,160,  ,  , 1)
//prow()+1,00 say chr(15)
Obj:Open()
For i := 1 to KolEkz
/**************
  l1 := iif(i<>1,"X"," ")
  l2 := iif(i<>2,"X"," ")
  l3 := iif(i<>3,"X"," ")
  S_Sprn("--------------------------------------"+chr(13)+chr(10),,.t.)
  S_Sprn("|Оригинал(выдается покупателю)    |"+l1+" |"+chr(13)+chr(10),,.t.)
  S_Sprn("--------------------------------------                   Н А Л О Г О В А Я   Н А К Л А Д Н А Я"+chr(13)+chr(10),,.t.)
  S_Sprn("|Копия(остаётся у продовца)       |"+l2+" |"+chr(13)+chr(10),,.t.)
  S_Sprn("--------------------------------------"+chr(13)+chr(10),,.t.)
  S_Sprn("                                   "+l3+"  "+chr(13)+chr(10),,.t.)
  S_Sprn("                                      "+chr(13)+chr(10),,.t.)
*************/
  obj:Seek(0,0)
  While ( !Obj:eof() .and. nPrint == 0 )
    cLine := obj:ReadLn(256) ;  cLine := left(cLine,Len(cLine)-1)
    nPrint := S_Sprn(cLine+chr(13)+chr(10),,.t.)
//      @ prow()+1,00 say cLine
  end
Next
END SEQUENCE
//Set Device to Screen
obj:close()
Return ( .t. )
////////////////////////////////////////////////////////////////////////
Static func SPrnNakl(cFile,nNomNakl,nNumDocum,cNaim,cKodNalog,cAdres,;
                     cKodSvid,cCustom,cForma,cFio,Obj,nRow)
Local cDir, cBux, nKey, i, l1, l2, l3, n7, n8, n9, n10, n11
Local m7, m8, m9, m10, m11, o7, o8, o9, o10, o11, p7, p8, p9, p10, p11
Local q7, q8, q9, q10, q11, w7, w8, w9, w10, w11, e7, e8, e9, e10, e11
Local r7, r8, r9, r10, r11
Local Set4 := Set(4,"dd.mm.yy")

 NalNakl->(DbSeek(str(100,4)))
 cDir := NalNakl->Fio
 NalNakl->(DbSeek(str(200,4)))
 cBux := NalNakl->Fio
 Set(20,"PRINT")
 Set(24,cFile+".Txt")
 @ prow()+1,00 say chr(15)
// @ prow()+1,00 say chr(27)+chr(38)+chr(107)+chr(055)+ chr(83)
 BEGIN SEQUENCE
 Work->(DbGoTop())
 l1 := " " // iif(i_<>1,"X"," ")
 l2 := " " // iif(i_<>2,"X"," ")
 l3 := " " // iif(i_<>3,"X"," ")
 @ prow()+1,00 say "--------------------------------------"
 @ prow()+1,00 say "|Оригинал(выдается покупателю)    |"+l1+" |"
 @ prow()+1,00 say "--------------------------------------                   Н А Л О Г О В А Я   Н А К Л А Д Н А Я"
 @ prow()+1,00 say "|Копия(остаётся у продовца)       |"+l2+" |"
 @ prow()+1,00 say "--------------------------------------"
 @ prow()+1,00 say "                                   "+l3+"  "
 @ prow()+1,00 say "                                      "
 @ prow()+1,00 say " "
 @ prow()+1,00 say "Дата выписка налоговой накладной "+dtoc(dData)+"                                       Порядковый номер "+alltrim(str(nNomNakl,10))+"-"+alltrim(str(nNumDocum,6))
 @ prow()+1,00 say "           ПРОДАВЕЦ                                                                    ПОКУПАТЕЛЬ"
 @ prow()+1,00 say [ Первомайское КПУВКХ                                                ]+alltrim(cNaim)
 nKey := ""
 for i := 1 to len(cKodNalog)
   nKey += Substr(cKodNalog,i,1)+" "
 Next
 @ prow()+1,00 say "   2 2 7 1 4 2 7 2 0 2 8 0                                                     "+nKey
 @ prow()+1,00 say "Местонохождение г. Первомайский Харьковской обл.                          Местонохождение "+alltrim(cAdres)
 @ prow()+1,00 say "Номер телефона (05748) 3-34-41                                            Номер телефона ___________________"
 @ prow()+1,00 say "Номер свидетельства о регистрации  ------------                           Номер свидетельства о регистрации  ------------"
 @ prow()+1,00 say "плательщика налога на добавленную  | 28167035 |                           плательщика налога на добавленную  | "+cKodSvid+" |"
 @ prow()+1,00 say "стоимость (продавца)               ------------                           стоимость (покупателя)             ------------"
 @ prow()+1,00 say "Условие продажи "+cCustom
 @ prow()+1,00 say "Форма проведенных расчетов "+cForma
 @ prow()+1,00 say "---------------------------------------------------------------------------------------------------------------------------------------"
 @ prow()+1,00 say "   |  Дата  |                              |       |               |               |Обьем продажи  без учета НДС,          |Общая сумма"
 @ prow()+1,00 say "   |отгрузки|     Номенклатура             | Едини-|  Количество   |Цена продажи   |подлежащий налогообложению по поставкам| средств,  "
 @ prow()+1,00 say "Раз|выполнен|       поставки               | ца    |   обьем       |единицы продук-|---------------------------------------|подлежащая "
 @ prow()+1,00 say "дел|предост.|        товаров               |измере |               |ции без учета  |         |0%(реализ|         |Освобож. | уплате    "
 @ prow()+1,00 say "   |(оплаты)|      (работ,услуг)           |ния    |               |    НДС        |   20%   |на тамож.|   0%    | от НДС  |           "
 @ prow()+1,00 say "   |товаров |                              |товара |               |               |         |территор.|(Экспорт)| (ст.5)  |           "
 @ prow()+1,00 say "   |услуг   |                              |       |               |               |         | Украины)|         |         |           "
 @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
 @ prow()+1,00 say " 1 |  2     |            3                 |   4   |      5        |       6       |   7     |   8     |   9     |   10    |   11      "
 @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    i := n7 := n8 := n9 := n10 := 0
    While !Work->(eof()) .and. Work->Gr == 1
      @ prow()+1,00 say str(++i,3)+"|"+dtoc(dData)+"|"+Work->Naim+"|"+;
        Work->EdIzm+"|"+str(Work->Kolvo,15,4)+"|"+str(Work->Cena,15,6)+"|"+;
        iif(Work->Kol==7, str(Work->Summa,09,2),space(9))+"|"+;
        iif(Work->Kol==8, str(Work->Summa,09,2),space(9))+"|"+;
        iif(Work->Kol==9, str(Work->Summa,09,2),space(9))+"|"+;
        iif(Work->Kol==10,str(Work->Summa,09,2),space(9))+"|"
      n7  += iif(Work->Kol==7, Work->Summa,0)
      n8  += iif(Work->Kol==8, Work->Summa,0)
      n9  += iif(Work->Kol==9, Work->Summa,0)
      n10 += iif(Work->Kol==10,Work->Summa,0)
      Work->(DbSkip(1))
    End
    n11 := n7 + n8 + n9 + n10
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    @ prow()+1,00 say "   | Всего по разделу I                    |       |               |               |"+;
      iif(n7==0, space(09),str(n7,09,2))+ "|"+;
      iif(n8==0, space(09),str(n8,09,2))+ "|"+;
      iif(n9==0, space(09),str(n9,09,2))+ "|"+;
      iif(n10==0,space(09),str(n10,09,2))+"|"+;
      str(n11,09,2)
    m7 := m8 := m9 := m10 := 0
    While !Work->(eof()) .and. Work->Gr == 2
      m7  += iif(Work->Kol==7, Work->Summa,0)
      m8  += iif(Work->Kol==8, Work->Summa,0)
      m9  += iif(Work->Kol==9, Work->Summa,0)
      m10 += iif(Work->Kol==10,Work->Summa,0)
      Work->(DbSkip(1))
    End
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    m11 := m7 + m8 + m9 + m10
    @ prow()+1,00 say "II | Товарно-транспортные расходы          |       |               |               |"+;
      iif(m7==0, space(09),str(m7,09,2))+ "|"+;
      iif(m8==0, space(09),str(m8,09,2))+ "|"+;
      iif(m9==0, space(09),str(m9,09,2))+ "|"+;
      iif(m10==0,space(09),str(m10,09,2))+"|"+;
      str(m11,09,2)
    o11 := 0
    While !Work->(eof()) .and. Work->Gr == 3
      o11 += Work->Summa
      Work->(DbSkip(1))
    End
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    @ prow()+1,00 say "III| Возвратная (залоговая) тара           |   X   |       X       |       X       |    X    |   X     |   X     |    X    |"+;
      str(o11,09,2)
    p7 := p8 := p9 := p10 := 0
    q7 := q8 := q9 := q10 := 0
    While !Work->(eof()) .and. Work->Gr == 4
     if Work->Summa >= 0
       p7  += iif(Work->Kol==7, Work->Summa,0)
       p8  += iif(Work->Kol==8, Work->Summa,0)
       p9  += iif(Work->Kol==9, Work->Summa,0)
       p10 += iif(Work->Kol==10,Work->Summa,0)
     else
       q7  += iif(Work->Kol==7, Work->Summa,0)
       q8  += iif(Work->Kol==8, Work->Summa,0)
       q9  += iif(Work->Kol==9, Work->Summa,0)
       q10 += iif(Work->Kol==10,Work->Summa,0)
     End
      Work->(DbSkip(1))
    End
    p11 := p7 + p8 + p9 + p10
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    @ prow()+1,00 say " IV| Предоставлено       | надбавка (+)    |       |               |               |"+;
      iif(p7==0, space(09),str(p7,09,2))+ "|"+;
      iif(p8==0, space(09),str(p8,09,2))+ "|"+;
      iif(p9==0, space(09),str(p9,09,2))+ "|"+;
      iif(p10==0,space(09),str(p10,09,2))+"|"+;
      str(p11,09,2)
    q11 := q7 + q8 + q9 + q10
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    @ prow()+1,00 say "   |                     | скидка (-)      |       |               |               |"+;
      iif(q7==0, space(09),str(q7,09,2))+ "|"+;
      iif(q8==0, space(09),str(q8,09,2))+ "|"+;
      iif(q9==0, space(09),str(q9,09,2))+ "|"+;
      iif(q10==0,space(09),str(q10,09,2))+"|"+;
      str(q11,09,2)
     @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
     w7 := n7 + m7 + p7 + q7
     w8 := n8 + m8 + p8 + q8
     w9 := n9 + m9 + p9 + q9
     w10 := n10 + m10 + p10 + q10
     w11 := n11 + m11 + p11 + q11
     @ prow()+1,00 say " V | Всего по разделам I + II +- IV        |       |               |               |"+;
        iif(w7==0, space(09),str(w7,09,2))+ "|"+;
        iif(w8==0, space(09),str(w8,09,2))+ "|"+;
        iif(w9==0, space(09),str(w9,09,2))+ "|"+;
        iif(w10==0,space(09),str(w10,09,2))+"|"+;
        str(w11,09,2)
    e7 := e8 := e9 := e10 := 0
    While !Work->(eof()) .and. Work->Gr == 6
      e7  += iif(Work->Kol==7, Work->Summa,0)
      e8  += iif(Work->Kol==8, Work->Summa,0)
      e9  += iif(Work->Kol==9, Work->Summa,0)
      e10 += iif(Work->Kol==10,Work->Summa,0)
      Work->(DbSkip(1))
    End
    e11 := e7 + e8+ e9 + e10
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    @ prow()+1,00 say "VI | Налог на добавленную стоимость        |       |               |               |"+;
      iif(e7==0, space(09),str(e7,09,2))+ "|"+;
      iif(e8==0, space(09),str(e8,09,2))+ "|"+;
      iif(e9==0, space(09),str(e9,09,2))+ "|"+;
      iif(e10==0,space(09),str(e10,09,2))+"|"+;
      str(e11,09,2)
    r7 := w7 + e7
    r8 := w8 + e8
    r9 := w9 + e9
    r10:= w10+ e10
    r11:= w11+ e11
    @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
    @ prow()+1,00 say "VII| Общая сумма с НДС                     |       |               |               |"+;
      iif(r7==0, space(09),str(r7,09,2))+ "|"+;
      iif(r8==0, space(09),str(r8,09,2))+ "|"+;
      iif(r9==0, space(09),str(r9,09,2))+ "|"+;
      iif(r10==0,space(09),str(r10,09,2))+"|"+;
      str(r11,09,2)
 @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
 @ prow()+1,00 say " "
 @ prow()+1,00 say "Суммы НДС, начисленные (уплаченные) в связи с продажей товаров (работ,услуг), указанных в этой накладной, указаны верно и соответствуют "
 @ prow()+1,00 say " сумме налоговых обязательств продавца и включены в книгу учета продажи ____________________"+alltrim(cFio)
 @ prow()+1,00 say " "
 @ prow()+1,00 say "                                   "+alltrim(cDir)
 @ prow()+1,00 say " "
 @ prow()+1,00 say "                                      "+alltrim(cBux)+"                                      м.п. "
 @ prow()+1,00 say " "
 @ prow()+1,00 say "                                                                           "
 if Obj == 2
    @ prow()+1,00 say " "
   @ prow()+1,00 say "  Приложение N 1 к этой накладной получил __________________________________________________________________"
   @ prow()+1,00 say "                                                 (дата получения, подпись должностного лица покупателя)"
 End
 @ prow()+1,00 say chr(12)
 @ prow()+1,00 say ""
 END SEQUENCE
 Set(24,"")
 Set(20,"SCREEN")
// if S_Err({"Вывести "," накладную на экран?","% Нет ; Да ;"})==2
//    S_Lview(cFile+".Txt",01,01,22,75)
// end
// if S_Err({"Вывести","накладную на печать?","% Да ; Нет ;"})==1
    M_Tprn(cFile+".Txt",nRow)
// end
Set(4,Set4)
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function SeekSpos(aDok)
Local  ColorOld  := SetColor(Sset[4]+","+sset[1]+",,,"+sset[4])
Local  CurSorOld := SetCursor(0), obj, nKey
Private nRow_ := 1

S_Open_M(03,48,min(03+03+len(aDok),22),74,Sset[4],Sset[1])
@ 01,01 say padc("Форма расчета",MaxCol()-1) color Sset[86]
@ 02,01 say repl("─",MaxCol()-1)
obj := TBrowseDb(03,01,MaxRow()-1,MaxCol()-1)
obj:AddColumn(TbColumnNew("", ABrowseBlock(aDok) ))
obj:GoTopBlock    := { || nRow_ := 1 }
obj:GoBottomBlock := { || nRow_ := len(aDok) }
obj:SkipBlock := { |nSkip| nSkip := ASkipTest(aDok, nRow_, nSkip),    ;
                           nRow_ += nSkip,                            ;
                           nSkip                                      }
While ( .t. )
  nKey := 0
  While ( !obj:Stabilize() )
    if ( nKey := S_Inkey() ) != 0 ; exit ; end
  end
  if nKey == 0 ; nKey := S_InKey(0)  ; end
  if nKey == K_ENTER ; exit ; end
  if obj:Stable  ; ApplyKey(nKey,obj) ; End
end
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(CurSorOld)
Return ( nRow_ )
/////////////////////////////////////////////////////////////////////
static func ABrowseBlock( a )
return ( { || a[nRow_][2] } )
////////////////////////////////////////////////////////////////////////////
static func ASkipTest( a, nCurrent, nSkip )
if ( nCurrent + nSkip < 1 )
   return ( -nCurrent + 1 )
 elseif ( nCurrent + nSkip > len(a) )
   return ( len(a) - nCurrent )
endif
return (nSkip)
/////////////////////////////////////////////////////////////////////////////
Function PrnNalCh()
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32])
Local CursorOld := SetCursor(1), Set4 := Set(4,"dd.mm.yy")

aSposob := {}
Sposob->(DbGoTop())
While !Sposob->(eof())
  aadd(aSposob,{Sposob->Sposob,Sposob->NaimSpos})
  Sposob->(DbSkip(1))
End
S_Open_M(03,03,13,45)
@ MaxRow()-2,01 say repl("─",MaxCol()-1)
While .t.
 Scroll(01,01,MaxRow()-3,MaxCol()-1)
 @ MaxRow()-1,01 say padc("ESC - конец работы",MaxCol()-1)
 SetCursor(1)
 nNomCh  := 0
 nKolEkz := 2
 @ 01,01 say "Укажите N счет-фактуры" get nNomCh Pict "999999" valid nNomCh > 0
 read
 if LastKey() == K_ESC ; exit ; End
 if !Fakt->(DbSeek(str(nNomCh,6)))
    S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop
 End
 nNomNakl := nNomCh
 i := SeekSpos(aSposob)
 cForma := aSposob[i][2]
 @ 02,01 say "        количество экземплыров" get nKolEkz Pict "99" valid nKolEkz > 0
 @ 03,01 say "        номер накладной" get nNomNakl pict "999999" valid nNomNakl > 0
 @ 04,01 say "Форма расчета" get cForma valid !Empty(cForma)
 Read
 if LastKey()==K_ESC ; Loop ; End
 cFio := "               "
 While .t.
  nFio := 1
  @ 05,01 say "Укажите код исполнителя" get nFio pict "99" range 1,4
    read
    if !NalNakl->(DbSeek(str(nFio,4)))
       S_Err({"Отсутствует исполнитель"})
       loop
    End
    cFio := NalNakl->Fio
    Exit
 End
 dData     := Fakt->DataCh
 @ 06,06 get cFio
 @ 07,01 say "Дата выписки накладной" get dData pict "@d" valid !Empty(dData)
 read
 if LastKey()==K_ESC ; Loop ; End
 S_Ent->(DbSeek(str(Fakt->Ent,4)))
 cKodNalog := S_Ent->KodNalog
 cKodSvid  := S_Ent->KodSvid
 cNaim     := S_Ent->Naim
 cAdres    := S_Ent->Adres
 cNaim2     := S_Ent->Naim2
 cAdres2    := S_Ent->Adres2
 cCustom   := S_Ent->Dogovor
 dCustom   := S_Ent->DataDog
 cTel   := S_Ent->Tel
 BEGIN SEQUENCE
 Set(20,"PRINT")
 For i_ := 1 to nKolEkz
  Fakt->(DbSeek(str(nNomCh,6)))
  @ prow()+1,00 say chr(15)
  l1 := " " // iif(i_<>1,"X"," ")
  l2 := " " // iif(i_<>2,"X"," ")
  l3 := " " // iif(i_<>3,"X"," ")
  @ prow()+1,00 say "--------------------------------------"
  @ prow()+1,00 say "|Оригинал(выдается покупателю)    |"+l1+" |"
  @ prow()+1,00 say "--------------------------------------                   Н А Л О Г О В А Я   Н А К Л А Д Н А Я"
  @ prow()+1,00 say "|Копия(остаётся у продaвца)       |"+l2+" |"
  @ prow()+1,00 say "--------------------------------------"
  @ prow()+1,00 say "                                   "+l3+"  "
  @ prow()+1,00 say "                                      "
  @ prow()+1,00 say " "
  @ prow()+1,00 say "Дата выписка налоговой накладной "+dtoc(dData)+"                                       Порядковый номер "+alltrim(str(nNomNakl,6))
  @ prow()+1,00 say "           ПРОДАВЕЦ                                                                    ПОКУПАТЕЛЬ"
  @ prow()+1,00 say [ Первомайское КПУВКХ                                                      ]+alltrim(cNaim)
  @ prow()+1,00 say [                                                                          ]+alltrim(cNaim2)
  nKey := ""
  for i := 1 to len(cKodNalog)
    nKey += Substr(cKodNalog,i,1)+" "
  Next
  @ prow()+1,00 say "   2 2 7 1 4 2 7 2 0 2 8 0                                                     "+nKey
  @ prow()+1,00 say "Местонохождение  Харьковской обл.г. Первомайский                          Местонохождение "+alltrim(cAdres)
  @ prow()+1,00 say " ул Комарова 1                                                                            "+alltrim(cAdres2)
  @ prow()+1,00 say "Номер телефона (05748) 3-34-41                                            Номер телефона  "+alltrim(cTel)
  @ prow()+1,00 say "Номер свидетельства о регистрации  ------------                           Номер свидетельства о регистрации  ------------"
  @ prow()+1,00 say "плательщика налога на добавленную  | 28167035 |                           плательщика налога на добавленную  | "+cKodSvid+" |"
  @ prow()+1,00 say "стоимость (продавца)               ------------                           стоимость (покупателя)             ------------"
  @ prow()+1,00 say "Условие поставки"+alltrim(cCustom)+" от "+dtoc(dCustom)
  @ prow()+1,00 say "Форма проведенных расчетов "+cForma
  @ prow()+1,00 say "---------------------------------------------------------------------------------------------------------------------------------------"
  @ prow()+1,00 say "   |  Дата   |                             |       |               |               |Обьем поставки база (налогообложения)  |Общая сумма"
  @ prow()+1,00 say "   |отгрузки |    Номенклатура             | Едини-|  Количество   |Цена поставки  |   без учет НДС подлежащий             | средств,  "
  @ prow()+1,00 say "Раз|выполнен |      поставки               | ца    |   обьем       |единицы продук-|  налогообложению по поставкам         |подлежащая "
  @ prow()+1,00 say "дел|поставки |       товаров               |измере |               |ции без учета  |         |0%(реализ|         |Освобож. | уплате    "
  @ prow()+1,00 say "   |(оплаты)*|     (услуг) продовца        |ния    |               |    НДС        |   20%   |на тамож.|   0%    | от НДС  |           "
  @ prow()+1,00 say "   |товаров  |                             |товара |               |               |         |территор.|(Экспорт)|         |           "
  @ prow()+1,00 say "   |(услуг)  |                             |       |               |               |         | Украины)|         |         |           "
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " 1 |  2     |            3                 |   4   |      5        |       6       |   7     |   8     |   9     |   10    |   11      "
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  nNdc := nNpp := nVsego := 0
  While Fakt->NomChF == nNomCh .and. !Fakt->(eof())
    if i_ == 1
      Fakt->Sposob := cForma
      Fakt->Data   := dData
    End
     @ prow()+1,00 say str(++nNpp,3)+"|"+dtoc(dData)+"|"+Fakt->Naim+"|"+;
         Fakt->EdIzm+"|"+str(Fakt->Kolvo,15,4)+"|"+str(Fakt->Cena,15,6)+"|"+;
         str((Fakt->Summa-Fakt->Ndc),09,2)+"|"+;
         space(9)+"|"+;
         space(9)+"|"+;
         space(9)+"|"
     nNdc   += Fakt->Ndc
     nVsego +=( Fakt->Summa-Fakt->Ndc)
     Fakt->(DbSkip(1))
  End
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "   | Всего по разделу I                    |       |               |               |"+;
       str(nVsego,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nVsego,09,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "II | Товарно-транспортные расходы          |       |               |               |"+;
       "         |         |         |         |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "III| Возвратная (залоговая) тара           |   X   |       X       |       X       |"+;
       "    X    |   X     |   X     |    X    |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " IV| Предоставлено       | надбавка (+)    |       |               |               |"+;
       "         |         |         |         |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "   |                     | скидка (-)      |       |               |               |"+;
       "         |         |         |         |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " V | Всего по разделам I + II +- IV        |       |               |               |"+;
       str(nVsego,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nVsego,09,2)

//       "                |         |         |"+str(nVsego,9,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "VI | Налог на добавленную стоимость        |       |               |               |"+;
       str(nNdc,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nNdc,09,2)

//       "         |         |         |         |"+str(nNdc,9,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "VII| Общая сумма с НДС                     |       |               |               |"+;
       str(nVsego+nNdc,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nVsego+nNdc,09,2)


//       "         |         |         |         |"+str(nVsego+nNdc,9,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " "
  @ prow()+1,00 say "Суммы НДС, начисленные (уплаченные) в связи с поставкаю товаров (услуг), указанных в этой накладной, указаны верно и соответствуют "
  @ prow()+1,00 say " сумме налоговых обязательств продавца и включены в реестр полученных и выданных налоговых накладных "
  @ prow()+1,00 say "                                                _________________" +cFio
  @ prow()+1,00 say "                                  "
  @ prow()+1,00 say " "
  @ prow()+1,00 say "                                                                                                      м.п.           "
  @ prow()+1,00 say "*"
  @ prow()+1,00 say " Дата оплаты ставится в случае предоплаты поставки,на которую выписывается налоговая накладная;для бартехных операций -дата оприходова- "
  @ prow()+1,00 say "ния товаров ранее полученных в счет оплаты поставки;дата ранее полученых услуг в оплату в оплату поставки; для операций по поставке"
  @ prow()+1,00 say "товаров (услуг) по кассовому методу соответственно Закона Украины  О налоге на добавленную стоимость.                            "
//@ prow()+1,00 say "О налоге на добавленную стоимость   "
  @ prow()+1,00 say " "
 Next
 @ prow()+1,00 say chr(12)
 @ prow()+1,00 say ""
 END SEQUENCE
 Set(20,"SCREEN")
End
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(CurSorOld)
Set(4,Set4)
Return ( Nil )
////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////
Function PrnNalChYk()
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32])
Local CursorOld := SetCursor(1), Set4 := Set(4,"dd.mm.yy")

aSposob := {}
Sposob->(DbGoTop())
While !Sposob->(eof())
  aadd(aSposob,{Sposob->Sposob,Sposob->NaimSpos})
  Sposob->(DbSkip(1))
End
S_Open_M(03,03,13,45)
@ MaxRow()-2,01 say repl("─",MaxCol()-1)
While .t.
 Scroll(01,01,MaxRow()-3,MaxCol()-1)
 @ MaxRow()-1,01 say padc("ESC - конец работы",MaxCol()-1)
 SetCursor(1)
 nNomCh  := 0
 nKolEkz := 2
 @ 01,01 say "Укажите N счет-фактуры" get nNomCh Pict "999999" valid nNomCh > 0
 read
 if LastKey() == K_ESC ; exit ; End
 if !Fakt->(DbSeek(str(nNomCh,6)))
    S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop
 End
 nNomNakl := nNomCh
 i := SeekSpos(aSposob)
 cForma := aSposob[i][2]
 @ 02,01 say "        количество экземплыров" get nKolEkz Pict "99" valid nKolEkz > 0
 @ 03,01 say "        номер накладной" get nNomNakl pict "999999" valid nNomNakl > 0
 @ 04,01 say "Форма расчета" get cForma valid !Empty(cForma)
 Read
 if LastKey()==K_ESC ; Loop ; End
 cFio := "               "
 While .t.
  nFio := 1
  @ 05,01 say "Укажите код исполнителя" get nFio pict "99" range 1,4
    read
    if !NalNakl->(DbSeek(str(nFio,4)))
       S_Err({"Отсутствует исполнитель"})
       loop
    End
    cFio := NalNakl->Fio
    Exit
 End
 dData     := Fakt->DataCh
 @ 06,06 get cFio
 @ 07,01 say "Дата выписки накладной" get dData pict "@d" valid !Empty(dData)
 read
 if LastKey()==K_ESC ; Loop ; End
 S_Ent->(DbSeek(str(Fakt->Ent,4)))
 cKodNalog := S_Ent->KodNalog
 cKodSvid  := S_Ent->KodSvid
 cNaim     := S_Ent->Naim
 cAdres    := S_Ent->Adres
 cNaim2     := S_Ent->Naim2
 cAdres2    := S_Ent->Adres2
 cCustom   := S_Ent->Dogovor
 dCustom   := S_Ent->DataDog
 cTel   := S_Ent->Tel
 BEGIN SEQUENCE
 Set(20,"PRINT")
 For i_ := 1 to nKolEkz
  Fakt->(DbSeek(str(nNomCh,6)))
  @ prow()+1,00 say chr(15)
  l1 := " " // iif(i_<>1,"X"," ")
  l2 := " " // iif(i_<>2,"X"," ")
  l3 := " " // iif(i_<>3,"X"," ")
  @ prow()+1,00 say "--------------------------------------"
  @ prow()+1,00 say "|Оригiнал(выдаэться покупцю   )   |"+l1+" |"
  @ prow()+1,00 say "--------------------------------------                   П Д А Т К О В А     Н А К Л А Д Н А  "
  @ prow()+1,00 say "|Копiя(залишаэться у продaвця)    |"+l2+" |"
  @ prow()+1,00 say "--------------------------------------"
  @ prow()+1,00 say "                                   "+l3+"  "
  @ prow()+1,00 say "                                      "
  @ prow()+1,00 say " "
  @ prow()+1,00 say "Дата виписки податквоi накладноi "+dtoc(dData)+"                                       Порядковий номер "+alltrim(str(nNomNakl,6))
  @ prow()+1,00 say "           ПРОДАВЕЦЬ                                                                   ПОКУПЕЦЬ  "
  @ prow()+1,00 say [ Первомайское КПУВКХ                                                      ]+alltrim(cNaim)
  @ prow()+1,00 say [                                                                          ]+alltrim(cNaim2)
  nKey := ""
  for i := 1 to len(cKodNalog)
    nKey += Substr(cKodNalog,i,1)+" "
  Next
  @ prow()+1,00 say "   2 2 7 1 4 2 7 2 0 2 8 0                                                     "+nKey
  @ prow()+1,00 say "Мiсцезнаходження Харьковской обл.г. Первомайский                          Мiсцезнаходження"+alltrim(cAdres)
  @ prow()+1,00 say " ул Комарова 1                                                                            "+alltrim(cAdres2)
  @ prow()+1,00 say "Номер телефону (05748) 3-34-41                                            Номер телефону  "+alltrim(cTel)
  @ prow()+1,00 say "Номер свiдоцтва про   реэстрацiю   ------------                           Номер свiдоцтва про   реэстрацiю   ------------"
  @ prow()+1,00 say "платника П Д В                     | 28167035 |                           платника   П Д В                   | "+cKodSvid+" |"
  @ prow()+1,00 say "          (продавця)               ------------                                     (покупця   )             ------------"
  @ prow()+1,00 say "Умова   поставки"+alltrim(cCustom)+" от "+dtoc(dCustom)
  @ prow()+1,00 say "Форма проведених розрахункiв"+cForma
  @ prow()+1,00 say "---------------------------------------------------------------------------------------------------------------------------------------"
  @ prow()+1,00 say "   |  Дата   |                             |       |               |               |Обсяги поставки (база оподаткування)   |Згальна    "
  @ prow()+1,00 say "   |вiдвантаж|    Номенклатура             | Одини-|  Кiлькiсть    |Цiна поставки  |   без урахування шо пiдлягають        | сума      "
  @ prow()+1,00 say "Роз|виконання|      поставки               | ця    |   обьэм       |одиницi продук-|  оподаткуванню   за ставками          |коштiв, що "
  @ prow()+1,00 say "дiл|поставки |       товарiв               |вимiру |               |цii без ураху- |         |0%(реалiз|         |Звiльнен.| пiдлягаэ  "
  @ prow()+1,00 say "   |(оплати)*|     (послуг) продавця       |       |               |вання ПДВ      |   20%   |на мит.  |   0%    | вiд ПДВ |           "
  @ prow()+1,00 say "   |товарiв  |                             |товару |               |               |         |терит.   |(експорт)|         |           "
  @ prow()+1,00 say "   |(послуг) |                             |       |               |               |         | Украiни)|         |         |           "
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " 1 |  2     |            3                 |   4   |      5        |       6       |   7     |   8     |   9     |   10    |   11      "
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  nNdc := nNpp := nVsego := 0
  While Fakt->NomChF == nNomCh .and. !Fakt->(eof())
    if i_ == 1
      Fakt->Sposob := cForma
      Fakt->Data   := dData
    End
     @ prow()+1,00 say str(++nNpp,3)+"|"+dtoc(dData)+"|"+Fakt->Naim+"|"+;
         Fakt->EdIzm+"|"+str(Fakt->Kolvo,15,4)+"|"+str(Fakt->Cena,15,6)+"|"+;
         str((Fakt->Summa-Fakt->Ndc),09,2)+"|"+;
         space(9)+"|"+;
         space(9)+"|"+;
         space(9)+"|"
     nNdc   += Fakt->Ndc
     nVsego +=( Fakt->Summa-Fakt->Ndc)
     Fakt->(DbSkip(1))
  End
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "   | Усього по роздiлу 1                   |       |               |               |"+;
       str(nVsego,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nVsego,09,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "II | Товарно-транспортиi витрати           |       |               |               |"+;
       "         |         |         |         |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "III| Зворотна   (заставна ) тара           |   X   |       X       |       X       |"+;
       "    X    |   X     |   X     |    X    |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " IV| Надано              | надбавка (+)    |       |               |               |"+;
       "         |         |         |         |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "   |                     | знижка (-)      |       |               |               |"+;
       "         |         |         |         |"
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " V | Усього по роздiлах I + II + IV        |       |               |               |"+;
       str(nVsego,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nVsego,09,2)

//       "                |         |         |"+str(nVsego,9,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "VI | Податок на додану вартiсть            |       |               |               |"+;
       str(nNdc,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nNdc,09,2)

//       "         |         |         |         |"+str(nNdc,9,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say "VII| Загальна сума з ПДВ                   |       |               |               |"+;
       str(nVsego+nNdc,09,2)+ "|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       space(09)+"|"+;
       str(nVsego+nNdc,09,2)


//       "         |         |         |         |"+str(nVsego+nNdc,9,2)
  @ prow()+1,00 say "-------------------------------------------------------------------------------------------------------------------------------------- "
  @ prow()+1,00 say " "
  @ prow()+1,00 say "Суми ПДВ , нарахованi  (сплаченi  ) у зв'язку поставкою товарiв (послуг),зазначених у цiй накладнiй,визначенi правильно вiдповiдають"
  @ prow()+1,00 say " сумi податкових зобов язань  продавця i включенi до реэстру отриманих та виданих податкових накладних "
  @ prow()+1,00 say "                                                _________________" +cFio
  @ prow()+1,00 say "                                  "
  @ prow()+1,00 say " "
  @ prow()+1,00 say "                                                                                                      м.п.           "
  @ prow()+1,00 say "*"
  @ prow()+1,00 say " Дата оплати ставиться у разi попередньо оплати поставки,на яку виписуэться податкова накладна ;для бартехних операцiй -дата оприбуткуван"
  @ prow()+1,00 say "ня товарiв попереньо одержаних в счет оплату поставки;дата попереднього одержання послуг в оплату поставки; для операцiй з поставки"
  @ prow()+1,00 say "товарiв (послуг) за касовим методом вiповiдно до Закону Украiни Про податок на додану вартiсть.                            "
  @ prow()+1,00 say " "
 Next
 @ prow()+1,00 say chr(12)
 @ prow()+1,00 say ""
 END SEQUENCE
 Set(20,"SCREEN")
End
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(CurSorOld)
Set(4,Set4)
Return ( Nil )
////////////////////////////////////////////////////////////////////////

 

