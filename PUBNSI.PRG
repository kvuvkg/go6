#Define COLOR_NSI sset[51]+","+sset[57]+",,,"+sset[51]
#Define COLOR_BAZA sset[32]+","+sset[2]+",,,"+sset[32]
#include "Inkey.ch"
/////////////////////////////////////////////////////////////////////////////
Function VedPrice()
Local tb, ColorOld, SelectOld := Select(), SursorOld,nKey, nRow, GetList := {}
Local nDelete := 0, nChet, nTip, nCena, nNdc, nFec

ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_Price")
Set Relation to str(Chet,5,2) into S_CHET,;
             to str(Tip,1) into S_GR
S_Open_M(03,32,22,68,,sset[2])
@ 01,01 say "Счет Тип       Цена   % Ндс % ФЭС"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-5,01 say Repl([─],MaxCol()-1)
@ MaxRow()-4,01 say "Счет"
@ MaxRow()-3,01 say "Тип орг."
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-6,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Price->Chet,4,0)+" "+str(S_Price->Tip,1)+" "+;
  str(S_Price->Cena,15,6)+" "+str(S_Price->Ndc,6,3)+" "+str(S_Price->Fec,6,3) }))
S_Price->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ MaxRow()-4,06 say S_Chet->Naim
   @ MaxRow()-3,11 say S_Gr->Naim
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Price->(Recno())
            S_Price->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",35)
            @ prow()+1,01 say padc("Ценник",35)
            @ prow()+1,01 say repl("-",35)
            @ prow()+1,01 say "Счет Тип       Цена   % Ндс % ФЭС"
            @ prow()+1,01 say repl("-",25)
            While ( !S_Price->(eof()) )
              @ prow()+1,01 say  str(S_Price->Chet,4,0)+" "+str(S_Price->Tip,1)+" "+;
                                 str(S_Price->Cena,15,6)+" "+str(S_Price->Ndc,6,3)+" "+;
                                 str(S_Price->Fec,6,3) 

              S_Price->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",35)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Gr->(DbGoto(nRow))
       case nKey == K_F3  // Удаление
           if S_Price->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 
                 S_Price->(DbDelete())   ; nDelete++
                 S_Price->(DbSkip(1))
                 if S_Price->(eof()) ; S_Price->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируйте запись",MaxCol()-1) color sset[5]
           BEGIN SEQUENCE
			   @ 03,01 say padc(" ",MaxCol()-1)
			   nChet := nTip := 0
			   SetCursor(1)
			   @ 03,01 get nChet pict "9999"  Valid VedChet(@nChet,MaxRow()-4,06)
			   @ 03,07 get nTip pict "9"  valid VedGr(@nTip,MaxRow()-3,11)
			   read
			   if LastKey() == K_ESC ; break ; End
			   if S_Price->(DbSeek(str(nChet,4,0)+str(nTip,1)))
				 S_Beep()
				 @ 03,09 say " Уже имеется"
				 M_Inkey(3)
				 break
			   End
			   nCena := nNdc := nFec := 0
			   @ 03,09 get nCena pict "9999999999.999999" valid nCena > 0
			   @ 03,26 get nNdc  pict "99.999" valid nNdc >= 0
			   @ 03,33 get nFec  pict "99.999" valid nFec >= 0
			   read
			   if LastKey() == K_ESC ; break ; End
			   S_Price->(DbAppend())
			   S_Price->Tip  := nTip
			   S_Price->Chet := nChet
			   S_Price->Cena := nCena
			   S_Price->Ndc  := nNdc
			   S_Price->Fec  := nFec
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[5]
           BEGIN SEQUENCE
			   SetCursor(1)
			   nCena := S_Price->Cena
			   nNdc  := S_Price->Ndc
			   nFec  := S_Price->Fec
			   @ nRow,09 get nCena pict "9999999999.999999" ////valid nCena > 0
			   @ nRow,26 get nNdc  pict "99.999"   /// valid nNdc >= 0
			   @ nRow,33 get nFec  pict "99.999"      valid nFec >= 0
			   read
			   if LastKey() == K_ESC ; break ; End
			   S_Price->Cena := nCena
			   S_Price->Ndc  := nNdc
			   S_Price->Fec  := nFec
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
Set Relation to
if nDelete > 0  ;  pack  ; End
Select(SelectOld)
Return ( .f. )
/////////////////////////////////////////////////////////////////////////////
Function VedGr(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld,nKey, nRow, GetList := {},;
      nDelete := 0

if nKod <> Nil .and. S_Gr->(DbSeek(Str(nKod,1)))
   @ Row,Col say left(S_Gr->Naim,25)
   Return ( .t. )
End
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_Gr")
S_Open_M(07,24,18,51,,sset[2])
@ 01,01 say "N  Наименование группы "
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-1,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Gr->Tip,1)+" "+S_Gr->Naim }))
S_Gr->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKod <> Nil .and. nKey == K_ENTER ; exit ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Gr->(Recno())
            S_Gr->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",27)
            @ prow()+1,01 say padc("справочника групп организаций",27)
            @ prow()+1,01 say repl("-",27)
            @ prow()+1,01 say "N  Наименование группы "
            @ prow()+1,01 say repl("-",27)
            While ( !S_Gr->(eof()) )
              @ prow()+1,01 say  str(S_Gr->Tip,1)+" "+S_Gr->Naim
              S_Gr->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",27)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Gr->(DbGoto(nRow))
       case nKey == K_F3  // Удаление
           if S_Ent->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаете удалить запись",;
             "и не пожалеете об этом?","% Да ; Нет ;"}) == 1 
                 S_Gr->(DbDelete())   ; nDelete++
                 S_Gr->(DbSkip(1))
                 if S_Gr->(eof()) ; S_Gr->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируйте запись",MaxCol()-1) color sset[5]
           BEGIN SEQUENCE
			   @ 03,01 say padc(" ",MaxCol()-1)
			   nRow := 0
			   SetCursor(1)
			   @ 03,01 get nRow pict "9" valid nRow > 0
			   if LastKey() == K_ESC ; break ; End
			   if S_Gr->(DbSeek(str(nRow,1)))
				 S_Beep()
				 @ 03,03 say "Внимательней Уже имеется"
				 M_Inkey(3)
				 break
			   End
			   cNaim := space(25)
			   @ 03,03 get cNaim valid !Empty(cNaim)
			   read
			   if LastKey() == K_ESC ; break ; End
			   S_Gr->(DbAppend())
			   S_Gr->tip  := nRow
			   S_Gr->Naim := cNaim
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[5]
           BEGIN SEQUENCE
			   SetCursor(1)
			   cNaim := S_Gr->Naim
			   @ nRow,03 get cNaim valid !Empty(cNaim)
			   read
			   if LastKey() == K_ESC ; break ; End
			   S_Gr->Naim := cNaim
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKod <> Nil .and.nKey == K_ENTER
   nKod := S_Gr->Tip
   @ Row,Col say left(S_Gr->Naim,25)
   if nDelete > 0  ;  pack  ; End
   Select(SelectOld)
   Return ( .t. )
End
if nDelete > 0  ;  pack  ; End
Select(SelectOld)
Return ( .f. )
/////////////////////////////////////////////////////////////////////////////
Function VedEnt(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld,nKey, nRow, GetList := {},;
      nDelete := 0

if nKod <> Nil .and. S_Ent->(DbSeek(Str(nKod,4)))
   @ Row,Col say left(S_Ent->Naim,30)
   Return ( .t. )
End
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_ENT")
S_Open_M(02,27,22,69,,sset[2])
@ 01,01 say "Код  Наименование организации"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск 8поиск",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Ent->Ent,4)+" "+S_Ent->Naim } ))
S_Ent->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKod <> Nil .and. nKey == K_ENTER ; exit ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Ent->(Recno())
            S_Ent->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",42)
            @ prow()+1,01 say padc("справочника организаций",42)
            @ prow()+1,01 say repl("-",42)
            @ prow()+1,01 say "Код  Наименование организации"
            @ prow()+1,01 say repl("-",42)
            While ( !S_Ent->(eof()) )
              @ prow()+1,01 say str(S_Ent->Ent,4)+" "+S_Ent->Naim
              S_Ent->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",42)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Ent->(DbGoto(nRow))
       Case nKey == K_F6  // Поиск по ключу
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := 0
            @ MaxRow()-1,03 say "Укажите код" get nRow pict "9999" valid nRow > 0
            read
            if LastKey() <> K_ESC
               S_Ent->(DbSeek(str(nRow,4),.t.))
               if S_Ent->(eof())
                  S_Beep(1)  ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F7  // Поиск по наименованию
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := space(30)
            @ MaxRow()-1,01 say "--->" get nRow
            read
            if LastKey() <> K_ESC
               if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
                  S_Beep(1) ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F8 // Поиск по р/с
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := space(14)
            @ MaxRow()-1,01 say "  Расчетный счет --->" get nRow
            read
            if LastKey() <> K_ESC
               if !S_Locate("Schet",Alltrim(S_Upper(nRow)))
                  S_Beep(1) ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       case nKey == K_F3  // Удаление
           if S_Ent->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаете удалить запись",;
             "и не пожалеете об этом?","% Да ; Нет ;"}) == 1 
                 S_Ent->(DbDelete())   ; nDelete++
                 S_Ent->(DbSkip(1))
                 if S_Ent->(eof()) ; S_Ent->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           EntRec(,nKod)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           EntRec(nRow,nKod)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKod <> Nil .and.nKey == K_ENTER
   nKod := S_Ent->Ent
   @ Row,Col say left(S_Ent->Naim,30)
   if nDelete > 0  ;  pack  ; End
   Select(SelectOld)
   Return ( .t. )
End
if nDelete > 0  ;  pack  ; End
Select(SelectOld)
Return ( .f. )
////////////////////////////////////////////////////////////////////////
Static function EntRec(nRow,nKod)
Local nEnt, cNaim,cNaim2,cAdres2, cOkpo, cMfo, cSchet, cBank, ColorOld, b, i
Local cKodNalog, cKodSvid, cDogovor, dDataDog, nTel
SetCursor(1)
ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
S_Open_M(07,02,23,53,,sset[2])
if nRow <> Nil
  S_Gr->(DbSeek(str(S_ent->Tip,1)))
  nEnt := S_Ent->Ent
  @ 01,08 say "Код организации "+str(nEnt,4)
  cNaim := S_Ent->Naim
  cAdres:= S_Ent->Adres
  cNaim2 := S_Ent->Naim2
  cAdres2:= S_Ent->Adres2
  cOkpo := S_Ent->Okpo
  cMfo  := S_Ent->Mfo
  cSchet:= S_Ent->Schet
  cBank := S_Ent->Bank
  cKodNalog := S_Ent->kodNalog
  cKodSvid  := S_Ent->kodSvid
  cDogovor  := S_Ent->Dogovor
  dDataDog  := S_Ent->DataDog
  nTip      := S_Ent->Tip
  cTel:= S_Ent->Tel
  @ 02,02 say "Наименование" get cNaim
  @ 03,02 say "Наименование2" get cNaim2
  @ 04,02 say "Адрес       " get cAdres
  @ 05,02 say "Адрес2       " get cAdres2
  @ 06,02 say "Код ОКПО" get cOkpo
  @ 07,02 say "МФО" get cMfo
  @ 08,02 say "счет" get cSchet
  @ 09,02 say "БАНК        " get cBank
  @ 10,02 say "ИНН" get cKodNalog
  @ 10,20 say "НС"  get cKodSvid
  @ 11,02 say "Группа организации" get nTip pict "9" valid VedGr(@nTip,09,24)
  @ 11,24 say S_Gr->Naim
  @ 12,02 say "Договор" get cDogovor
  @ 12,21 say " от " get dDataDog pict "@d"
  @ 13,02 say "TEL" get cTel
  read
  if LastKey() <> K_ESC
      S_Ent->Naim := cNaim
      S_Ent->Naim2:= cNaim2
      S_Ent->Okpo := cOkpo
      S_Ent->Mfo  := cMfo
      S_Ent->Schet:= cSchet
      S_Ent->Bank := cBank
      S_Ent->Tip  := nTip
      S_Ent->Adres:= cAdres
    S_Ent->Adres2:= cAdres2
      S_Ent->KodNalog := cKodNalog
      S_Ent->KodSvid  := cKodSvid
      S_Ent->Dogovor  := cDogovor
      S_Ent->DataDog  := dDataDog
      S_Ent->Tel  := cTel
  End
else
  BEGIN SEQUENCE
	  S_Ent->(DbGoBottom())
	  nEnt := S_Ent->Ent + 1
	  @ 01,08 say "Код организации" Get nEnt pict "9999" valid nEnt > 0
	  if LastKey() == K_ESC ; Break ; End
	  if S_Ent->(DbSeek(str(nEnt,4)))
		 @ 02,06 say padc(" Запись имеется ",33) Color sset[5]
		 inkey(0)
		 break
	  End
	  cNaim := S_Ent->Naim
	  cAdres:= S_Ent->Adres
	  cNaim2 := S_Ent->Naim2
	  cAdres2:= S_Ent->Adres2
	  cOkpo := S_Ent->Okpo
	  cMfo  := S_Ent->Mfo
	  cSchet:= S_Ent->Schet
	  cBank := S_Ent->Bank
	  cKodNalog := S_Ent->kodNalog
	  cKodSvid  := S_Ent->kodSvid
	  cDogovor  := S_Ent->Dogovor
	  dDataDog  := S_Ent->DataDog
	  nTip      := S_Ent->Tip
	  cTel:= S_Ent->Tel

	  @ 02,02 say "Наименование" get cNaim
	  @ 03,02 say "Наименование2" get cNaim2
	  @ 04,02 say "Адрес       " get cAdres
	  @ 05,02 say "Адрес       " get cAdres2
	  @ 06,02 say "Код ОКПО" get cOkpo
	  @ 07,02 say "МФО" get cMfo
	  @ 08,02 say "счет" get cSchet
	  @ 09,02 say "БАНК        " get cBank
	  @ 10,02 say "ИНН" get cKodNalog
	  @ 10,20 say "НС"  get cKodSvid
	  @ 11,02 say "Группа организации" get nTip pict "9" valid VedGr(@nTip,09,24)
	  @ 11,02 say "Договор" get cDogovor
	  @ 12,21 say " от " get dDataDog pict "@d"
	  @ 13,02 say "TEL" get cTel
	  read
	  if LastKey() == K_ESC ; Break ; End
	  S_Ent->(DbAppend())
	  S_Ent->Ent  := nEnt
	  S_Ent->Naim := cNaim
	  S_Ent->Naim2 := cNaim2
	  S_Ent->Okpo := cOkpo
	  S_Ent->Mfo  := cMfo
	  S_Ent->Schet:= cSchet
	  S_Ent->Bank := cBank
	  S_Ent->Tip  := nTip
	  S_Ent->Adres2:= cAdres2
	  S_Ent->Adres:= cAdres
	  S_Ent->KodNalog := cKodNalog
	  S_Ent->KodSvid  := cKodSvid
	  S_Ent->Dogovor  := cDogovor
	  S_Ent->DataDog  := dDataDog
	  S_Ent->Tel  := cTel
  END SEQUENCE
End
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(1)
Return ( nil )
/////////////////////////////////////////////////////////////////////////
Function VedChet(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld, nKey, nRow, GetList := {}
Local nDelete := 0
Local NortonOld := DeskTop:norton()

if nKod <> Nil .and. S_Chet->(DbSeek(Str(nKod,4,0)))
  if Row <> Nil
     @ Row,Col say S_Chet->Naim
  End
  Return ( .t. )
End
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_CHET")
S_Open_M(02,38,22,75,,sset[2])
@ 01,01 say "Код  Наименование счета"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Chet->Chet,4,0)+" "+S_Chet->Naim } ))
S_Chet->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKod <> Nil .and. nKey == K_ENTER ; exit ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Chet->(Recno())
            S_Chet->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",38)
            @ prow()+1,01 say padc("справочника счетов",38)
            @ prow()+1,01 say repl("-",38)
            @ prow()+1,01 say "Код  Наименование счета"
            @ prow()+1,01 say repl("-",38)
            While ( !S_Chet->(eof()) )
              @ prow()+1,01 say str(S_Chet->Chet,4,0)+" "+S_Chet->Naim
              S_Chet->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",38)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Chet->(DbGoto(nRow))
       Case nKey == K_F6  // Поиск по ключу
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := 0
            @ MaxRow()-1,03 say "Укажите счет" get nRow pict "9999" valid nRow > 0
            read
            if LastKey() <> K_ESC
               S_Chet->(DbSeek(str(nRow,4,0),.t.))
               if S_Chet->(eof())
                  S_Beep(1)  ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F7  // Поиск по наименованию
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := space(30)
            @ MaxRow()-1,01 say "--->" get nRow
            read
            if LastKey() <> K_ESC
               if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
                  S_Beep(1) ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       case nKey == K_F3  // Удаление
           if S_Chet->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаете удалить запись",;
             "и не пожалеете об этом?","% Да ; Нет ;"}) == 1 
                 S_Chet->(DbDelete())  ;  nDelete++
                 S_Chet->(DbSkip(1))
                 if S_Chet->(eof()) ; S_Chet->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           ChetRec(,nKod)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           ChetRec(nRow,nKod)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := Nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKod <> Nil .and.nKey == K_ENTER
   nKod := S_Chet->Chet
   if Row <> Nil
      @ Row,Col say S_Chet->Naim
   End
   if nDelete > 0  ;  pack  ; End
   Select(SelectOld)
   Return ( .t. )
End
if nDelete > 0  ;  pack  ; End
Select(SelectOld)
Return ( .f. )
////////////////////////////////////////////////////////////////////////
Static function ChetRec(nRow,nKod)
Local nChet, cNaim
      cSay := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
SetCursor(1)
if nRow <> Nil
  @ MaxRow()-1,01 say padc("Корректируйте наименование",MaxCol()-1) color sset[5]
  cNaim := S_Chet->Naim
  @ nRow,07 get cNaim
  read
  if LastKey() <> K_ESC 
      S_Chet->Naim := cNaim
  End
else
 @ MaxRow()-1,01 say padc("Вставляйте записи",MaxCol()-1) color sset[5]
 While ( .t. )
   Scroll(03,01,MaxRow()-3,MaxCol()-1,-1)
   nChet := 0
   @ 03,01 get nChet Pict "9999" valid nChet > 0
   read
   if LastKey() == K_ESC ; Exit ; End
   if S_Chet->(DbSeek(str(nChet,4,0)))
      @ 03,07 say padc(" Запись имеется ",30) Color sset[5]
      loop
   End
   cNaim := space(30)
   @ 03,07 get cNaim
   read
   if LastKey() <> K_ESC
      S_Chet->(DbAppend())
      S_Chet->Chet := nChet  ;  S_Chet->Naim := S_Upper(cNaim)
   End
   if nKod <> Nil ; exit ; End
 End
End
RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,cSay)
SetCursor(1)
Return ( nil )
///////////////////////////////////////////////////////////////////////////
Function ApplyKey(nKey,o)
Do case
   case nKey == K_DOWN       ;  o:Down()
   case nKey == K_UP         ;  o:Up()
   case nKey == K_RIGHT      ;  o:Right()
   case nKey == K_LEFT       ;  o:Left()
   case nKey == K_PGDN       ;  o:PageDown()
   case nKey == K_PGUP       ;  o:PageUp()
   case nKey == K_HOME       ;  o:Home()
   case nKey == K_END        ;  o:End()
   case nKey == K_CTRL_PGUP  ;  o:GoTop()
   case nKey == K_CTRL_PGDN  ;  o:GoBottom()
   case nKey == K_CTRL_LEFT  ;  o:PanLeft()
   case nKey == K_CTRL_RIGHT ;  o:PanRight()
   case nKey == K_CTRL_HOME  ;  o:PanHome()
   case nKey == K_CTRL_END   ;  o:PanEnd()
end
return ( Nil )
////////////////////////////////////////////////////////////////////////////
Function FreshOrder(o)
o:RefReshAll()
While ( !o:stabilize() ) ; end
return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Function M_inkey( nSecond )
local nKey  := if( nSecond == NIL, inkey(), inkey(nSecond) )
local bKeyBlock := setkey(nKey)
if bKeyBlock # NIL
   eval( bKeyBlock, procname(2), procline(2), readvar() )
end
return (nKey)
/////////////////////////////////////////////////////////////////////////////
Function My_Char()
aeval({ {523,2},{698,2},{880,2},{1046,4},{880,2},{1046,4}  },;
      { |x| tone(x[1], x[2])  } )
return ( Nil )
////////////////////////////////////////////////////////////////////////////
Function VedRasxod()  // Ввод расхода
	Local tb, ColorOld := SetColor(COLOR_BAZA),;
		  SelectOld := Select(), nKey, nRow, SursorOld := SetCursor(0),;
		  nEnt, nSumma, GetList := {}, nChet, nDelete := 0, nRegim := 1,;
		  aRegim := {"+"," "}

	DbSelectArea("Rasxod")
	Set relation to str(Rasxod->Ent,4) into S_ENT,;
				 to str(Rasxod->Chet,4,0) into S_CHET
	S_Open_M(01,01,22,62,,sset[2])
	@ 01,01 say "Код  Наименование организации        Счет      Сумма  "
	@ 02,01 say Repl([─],MaxCol()-1)
	@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
	@ MaxRow()-4,01 say Repl([─],MaxCol()-1)
	@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск ",MaxCol()-1) color sset[5]
	@ MaxRow()-3,01 say "Наименование счета"
	tb := TBrowseDb(03,01,MaxRow()-5,MaxCol()-1)
	tb:AddColumn(TbColumnNew("" ,{|| str(Rasxod->Ent,4)+" "+S_Ent->Naim+" "+;
								  str(Rasxod->Chet,4,0)+" "+str(Rasxod->Summa,13,2) } ))
	Rasxod->(DbGoTop())
	While ( .t. )
	   nKey := 0
	   While ( !tb:Stabilize() )
		 if ( nKey := m_inkey() ) != 0 ; exit ; end
	   end
	   nRow := Row()
	   @ MaxRow()-3,21 say S_Chet->Naim
	   if nKey == 0 ; nKey := m_inkey(0)  ; end
	   if nKey == K_ESC ; exit ; end
	   if tb:Stable
		do case
		   Case nKey == K_F2  // Печать
				nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
				@ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
				nRow := Rasxod->(Recno())
				Rasxod->(DbGoTop())
				Set Device to Print
				@ prow()+1,01 say padc("Распечатка",57)
				@ prow()+1,01 say padc("базы Ведомости расчета с потребителями",57)
				@ prow()+1,01 say repl("-",57)
				@ prow()+1,01 say "Код  Наименование организации        Счет      Сумма  "
				@ prow()+1,01 say repl("-",57)
				While ( !Rasxod->(eof()) )
				  @ prow()+1,01 say str(Rasxod->Ent,4)+" "+S_Ent->Naim+" "+;
									str(Rasxod->Chet,4,0)+" "+str(Rasxod->Summa,13,2)
				  Rasxod->(DbSkip(1))
				End
				@ prow()+1,01 say repl("=",55)
				@ prow()+1,01 say ""
				Set Device to Screen
				RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
				Rasxod->(DbGoto(nRow))
		   Case nKey == K_F6  // Поиск по ключу
				SetCursor(1)
				nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
				@ MaxRow()-1,01 say padc(" ",MaxCol()-1)
				nRow := 0
				@ MaxRow()-1,03 say "Укажите код" get nRow pict "9999" valid nRow > 0
				read
				if LastKey() <> K_ESC
				   Rasxod->(DbSeek(str(nRow,4),.t.))
				   if Rasxod->(eof())
					  S_Beep(1)  ;  tb:GoBottom()
				   end
				end
				SetCursor(0)
				RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
				FreshOrder(tb)
		   Case nKey == K_F7  // Поиск по наименованию
				SetCursor(1)
				nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
				@ MaxRow()-1,01 say padc(" ",MaxCol()-1)
				nRow := space(30)
				@ MaxRow()-1,01 say "--->" get nRow
				read
				if LastKey() <> K_ESC
				   DbSelectArea("S_Ent")
				   if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
					  S_Err({" Данных не обнаружено "})
					  DbSelectArea("Rasxod")
				   else
					  nSumma := S_Ent->Ent
					  DbSelectArea("Rasxod")
					  if !Rasxod->(DbSeek(str(nSumma)))
						 S_Err({" Данных не обнаружено "})
						 S_Beep(1)  ;  tb:GoBottom()
					  End
				   end
				end
				SetCursor(0)
				RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
				FreshOrder(tb)
		   case nKey == K_F3  // Удаление
			   if Rasxod->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
				 "Вы действительно","желаете удалить запись",;
				 "и не пожалеете об этом?","% Да ; Нет ;"}) == 1 
					 Rasxod->(DbDelete())   ;   nDelete++
					 Rasxod->(DbSkip(1))
					 if Rasxod->(eof()) ; Rasxod->(DbGoBottom()) ; end
			   end
			   FreshOrder(tb)
		   case nKey == K_F4  // Регистрация
			   tb:DeHilite()
			   nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
			   @ MaxRow()-1,01 say padc("Вставляйте записи",MaxCol()-1) color sset[5]
			   nEnt := 0
			   While ( .t. )
				 Scroll(03,01,MaxRow()-5,MaxCol()-1,-1)
				 @ 03,01 get nEnt Pict "9999" valid VedEnt(@nEnt,03,06)
				 read
				 if LastKey() == K_ESC ; Exit ; End
				 nSumma := nChet := 0
				 @ 03,42 get nChet pict "9999" Valid VedChet (@nChet,MaxRow()-3,21)
				 read
				 if LastKey() <> K_ESC
					if Rasxod->(DbSeek(str(nEnt,4)+str(nChet,4,0)))
						 @ 03,06 say padc(" Запись имеется Внимательней",30) Color sset[5]
					  else
						 @ 03,48 get nSumma pict "9999999999.99"
						 read
						 if LastKey() <> K_ESC
							 Rasxod->(DbAppend()) ;  Rasxod->Chet  := nChet
							 Rasxod->Ent := nEnt  ;  Rasxod->Summa := nSumma
						 End
					  End
				 End
			   End
			   SetCursor(0)
			   RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
			   FreshOrder(tb)
		   case nKey == K_F5  .and. Rasxod->Ent > 0  // Корретировка
			   tb:DeHilite()
			   nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
			   SetCursor(1)
			   @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[5]
			   nSumma := if(nRegim==1,0,Rasxod->Summa)
			   nChet  := Rasxod->Chet
			   @ nRow,42 get nChet pict "9999" Valid VedChet(@nChet,MaxRow()-3,21)
			   read
			   if LastKey() <> K_ESC
				  @ nRow,48 get nSumma pict "9999999999.99"
				  read
				  if LastKey() <> K_ESC
					 Rasxod->Summa := nSumma
					 Rasxod->Chet := nChet
				  End
			   End
			   SetCursor(0)
			   RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
			   FreshOrder(tb)
		   other
			   ApplyKey(nkey,tb)
		end  
	   end
	End
	tb := Nil
	S_wCloseSl(S_RanDom()%22+1)
	Set relation to
	if nDelete > 0  ;  pack  ; End
	SetColor(ColorOld)
	SetCursor(SursorOld)
	Select(SelectOld)
Return ( Nil )
////////////////////////////////////////////////////////////////////////
Function VedPrixod()  // Ввод Прихода
	Local tb, ColorOld := SetColor(COLOR_BAZA),;
		  SelectOld := Select(), nKey, nRow, SursorOld := SetCursor(0),;
		  nEnt, nSumma, GetList := {}, nChet, nDelete := 0, nRegim := 1,;
		  aRegim := {"+"," "}

	DbSelectArea("Prixod")
	Set relation to str(Prixod->Ent,4) into S_ENT,;
				 to str(Prixod->Chet,4,0) into S_CHET
	S_Open_M(01,01,22,56,,sset[2])
	@ 01,01 say "Код  Наименование организации          Сумма"
	@ 02,01 say Repl([─],MaxCol()-1)
	@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
	@ MaxRow()-4,01 say Repl([─],MaxCol()-1)
	@ MaxRow(),01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск ",MaxCol()-1) color sset[5]
	@ MaxRow()-3,01 say "Cчет ..... .............................. Док-т ....."
	@ MaxRow()-2,01 say "Количество .......... Цена ....... ..cум ............."
	@ MaxRow()-1,01 say "Ндс ............. ПРс ............. Банк ............."
	tb := TBrowseDb(03,01,MaxRow()-5,MaxCol()-1)
	tb:AddColumn(TbColumnNew("" ,{|| str(Prixod->Ent,4)+" "+S_Ent->Naim+" "+;
								  str(Prixod->Summa,13,2) } ))
	Prixod->(DbGoTop())
	While ( .t. )
	   nKey := 0
	   While ( !tb:Stabilize() )
		 if ( nKey := m_inkey() ) != 0 ; exit ; end
	   end
	   nRow := Row()
	   @ MaxRow()-3,06 say Prixod->Chet pict "9999"
	   @ MaxRow()-3,12 say S_Chet->Naim
	   @ MaxRow()-3,49 say Prixod->Npp pict "99999"
	   @ MaxRow()-2,12 say Prixod->Kolvo pict "9999999999"
	   @ MaxRow()-2,28 say Prixod->Cena  pict "999.999999"
	   @ MaxRow()-2,42 say Prixod->Sum   pict "9999999999.99"
	   @ MaxRow()-1,05 say Prixod->Ndc   pict "9999999999.99"
	   @ MaxRow()-1,23 say Prixod->Fec   pict "9999999999.99"
	   @ MaxRow()-1,42 say Prixod->SumBank pict "9999999999.99"
	   if nKey == 0 ; nKey := m_inkey(0)  ; end
	   if nKey == K_ESC ; exit ; end
	   if tb:Stable
		do case
		   Case nKey == K_F2  // Печать
				nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
				@ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
				nRow := Prixod->(Recno())
				Prixod->(DbGoTop())
				Set Device to Print
				@ prow()+1,01 say padc("Распечатка",57)
				@ prow()+1,01 say padc("базы Ведомости расчета с потребителями",57)
				@ prow()+1,01 say repl("-",57)
				@ prow()+1,01 say "Код  Наименование организации        Счет      Сумма  "
				@ prow()+1,01 say repl("-",57)
				While ( !Prixod->(eof()) )
				  @ prow()+1,01 say str(Prixod->Ent,4)+" "+S_Ent->Naim+" "+;
									str(Prixod->Chet,4,0)+" "+str(Prixod->Summa,13,2)
				  Prixod->(DbSkip(1))
				End
				@ prow()+1,01 say repl("=",55)
				@ prow()+1,01 say ""
				Set Device to Screen
				RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
				Prixod->(DbGoto(nRow))
		   Case nKey == K_F6  // Поиск по ключу
				SetCursor(1)
				nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
				@ MaxRow()-1,01 say padc(" ",MaxCol()-1)
				nRow := 0
				@ MaxRow()-1,03 say "Укажите код" get nRow pict "9999" valid nRow > 0
				read
				if LastKey() <> K_ESC
				   Prixod->(DbSeek(str(nRow,4),.t.))
				   if Prixod->(eof())
					  S_Beep(1)  ;  tb:GoBottom()
				   end
				end
				SetCursor(0)
				RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
				FreshOrder(tb)
		   Case nKey == K_F7  // Поиск по наименованию
				SetCursor(1)
				nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
				@ MaxRow()-1,01 say padc(" ",MaxCol()-1)
				nRow := space(30)
				@ MaxRow()-1,01 say "--->" get nRow
				read
				if LastKey() <> K_ESC
				   DbSelectArea("S_Ent")
				   if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
					  S_Err({" Данных не обнаружено "})
					  DbSelectArea(Prixod)
				   else
					  nSumma := S_Ent->Ent
					  DbSelectArea(Prixod)
					  if !Prixod->(DbSeek(str(nSumma)))
						 S_Err({" Данных не обнаружено "})
						 S_Beep(1)  ;  tb:GoBottom()
					  End
				   end
				end
				SetCursor(0)
				RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
				FreshOrder(tb)
		   case nKey == K_F3  // Удаление
			   if Prixod->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
				 "Вы действительно","желаете удалить запись",;
				 "и не пожалеете об этом?","% Да ; Нет ;"}) == 1 
					 Prixod->(DbDelete())   ;   nDelete++
					 Prixod->(DbSkip(1))
					 if Prixod->(eof()) ; Prixod->(DbGoBottom()) ; end
			   end
			   FreshOrder(tb)
		   case nKey == K_F4  // Регистрация
			   tb:DeHilite()
			   nKey := SaveScreen(MaxRow(),01,MaxRow(),MaxCol()-1)
			   @ MaxRow(),01 say padc("Вставляйте записи",MaxCol()-1) color sset[5]
			   nEnt := 0
			   While ( .t. )
			     // Запрашиваем код организации
				 Scroll(03,01,MaxRow()-5,MaxCol()-1,-1)
				 @ 03,01 get nEnt Pict "9999" valid VedEnt(@nEnt,03,06)
				 read
				 if LastKey() == K_ESC ; Exit ; End
				 S_Ent->(Dbseek(str(nEnt,4)))
				 nSumma := nChet := nSum := nNpp := nKolvo := 0
			     // Запрашиваем счет
				 @ MaxRow()-3,06 get nChet pict "9999" Valid VedChet(@nChet,MaxRow()-3,12)
				 read
				 if LastKey() == K_ESC ; Loop ; End
				 // Подтягиваем цену
				 S_Price->(DbSeek(str(nChet,4,0)+str(S_Ent->Tip,1)))
				 pNdc := S_Price->Ndc
				 pFec := S_Price->Fec
				 nCena:= S_Price->Cena
				 nBank:= 0
				 // Выводим/корркктируем цену, запрашиваем документ и количество
				 @ MaxRow()-3,49 get nNpp pict "99999" 
				 @ MaxRow()-2,12 get nKolvo pict "9999999999" 
				 @ MaxRow()-2,28 get nCena  pict "999.999999" 
				 read
				 if LastKey() == K_ESC ; Loop ; End
				 nSum := NEW_ROUND(nKolvo*nCena,2)
				 @ MaxRow()-2,42 get nSum   pict "9999999999.99"
				 read
				 if LastKey() == K_ESC ; Loop ; End
				 nNdc := NEW_ROUND(pNdc*nSum,2)
				 nFec := NEW_ROUND(pFec*nSum,2)
				 @ MaxRow()-1,05 get nNdc   pict "9999999999.99"
				 @ MaxRow()-1,23 get nFec   pict "9999999999.99"
				 read
				 if LastKey() == K_ESC ; Loop ; End
				 nSumma := nSum + nNdc + nFec
				 @ 03,42 get nSumma pict "9999999999.99"
				 read
				 if LastKey() == K_ESC ; Loop ; End
				 @ MaxRow()-1,42 get nBank pict "9.999" range 0,1
				 read
				 if LastKey() == K_ESC ; Loop ; End
				 Prixod->(DbAppend())
				 Prixod->Chet  := nChet
				 Prixod->Ent   := nEnt
				 Prixod->Sum   := nSum
				 Prixod->Kolvo := nKolvo
				 Prixod->Cena  := nCena
				 Prixod->Ndc   := nNdc
				 Prixod->Fec   := nFec
				 Prixod->Npp   := nNpp
				 Prixod->SumBank := NEW_ROUND(nSumma*nBank,2)
				 Prixod->Summa   := nSumma + Prixod->SumBank
			   End
			   SetCursor(0)
			   RestScreen(MaxRow(),01,MaxRow(),MaxCol()-1,nKey)            
			   FreshOrder(tb)
		   case nKey == K_F5  .and. Prixod->Ent > 0  // Корретировка
			   tb:DeHilite()
			   nKey := SaveScreen(MaxRow(),01,MaxRow(),MaxCol()-1)
			   SetCursor(1)
			   @ MaxRow(),01 say padc("Корректируйте данные",MaxCol()-1) color sset[5]
		   pNdc:=0.2
			   nSumma := Prixod->Summa
			   nSum   := Prixod->Sum
			   nKolvo := Prixod->Kolvo 
			   nCena  := Prixod->Cena
			   nNdc   := Prixod->Ndc 
			   nFec   := Prixod->Fec
			   nNpp   := Prixod->Npp
			   nChet  := Prixod->Chet 
			   nBank  := NEW_ROUND(Prixod->SumBank/Prixod->Summa,3)
			   S_Ent->(Dbseek(str(Prixod->Ent,4)))
			   BEGIN SEQUENCE
			   @ MaxRow()-3,06 get nChet pict "9999" Valid VedChet(@nChet,MaxRow()-3,12)
			   @ MaxRow()-3,49 get nNpp pict "99999" 
			   @ MaxRow()-2,12 get nKolvo pict "9999999999" 
			   @ MaxRow()-2,28 get nCena  pict "999.999999" 
			   read
			   if LastKey() == K_ESC ; break ; End
			   nSum := NEW_ROUND(nKolvo*nCena,2)
			   @ MaxRow()-2,42 get nSum   pict "9999999999.99"
			   read
			   if LastKey() == K_ESC ; break ; End
				nNdc := NEW_ROUND(pNdc*nSum,2)
			   @ MaxRow()-1,05 get nNdc   pict "9999999999.99"
			   @ MaxRow()-1,23 get nFec   pict "9999999999.99"
			   read
			   if LastKey() == K_ESC ; Break ; End
			   nSumma := nSum + nNdc + nFec
			   @ nRow,42 get nSumma pict "9999999999.99"
			   read
			   if LastKey() == K_ESC ; Break ; End
			   @ MaxRow()-1,42 get nBank pict "9.999" range 0,1
			   read
			   if LastKey() == K_ESC ; Break ; End
			   Prixod->Chet  := nChet
			   Prixod->Sum   := nSum
			   Prixod->Kolvo := nKolvo
			   Prixod->Cena  := nCena
			   Prixod->Ndc   := nNdc
			   Prixod->Fec   := nFec
			   Prixod->Npp   := nNpp
			   Prixod->SumBank := NEW_ROUND(nSumma*nBank,2)           
			   Prixod->Summa   := nSumma + Prixod->SumBank
			   END SEQUENCE
			   SetCursor(0)
			   RestScreen(MaxRow(),01,MaxRow(),MaxCol()-1,nKey)            
			   FreshOrder(tb)
		   other
			   ApplyKey(nkey,tb)
		end  
	   end
	End
	tb := Nil
	S_wCloseSl(S_RanDom()%22+1)
	Set relation to
	if nDelete > 0  ;  pack  ; End
	SetColor(ColorOld)
	SetCursor(SursorOld)
	Select(SelectOld)
Return ( Nil )
////////////////////////////////////////////////////////////////////////
