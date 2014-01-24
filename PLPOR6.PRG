#include "Inkey.ch"
///////////////////////////////////////////////////////////////////////////
Function PlPor() // формирование и печать платежных поручений
Local dData := year(sset[100]), nPlPor, i, nKolEkz, nSumma, nNdc,;
      ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {},cText1, cText2, dDataPor, aProp, nEnt, nLen
Local NaimMec := NaimMes2()
Local   pr:=0

S_Open_M(07,03,19,59,sset[32],sset[2])
While .t.
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ 10,01 say repl("─",MaxCol()-1)
  @ 11,01 say padc(" Минутку....",MaxCol()-1) color sset[15]
  if PlPor->(DbSeek(str(dData,4)))
     While !PlPor->(eof()) .and. PlPor->GodPor == dData
        nPlPor := PlPor->PlPor
        PlPor->(DbSkip(1))
     End
     nPlPor++
  else
     nPlPor := 0
  End
  @ 11,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  @ 01,02 say "No платежного поручения" get nPlPor pict "999999" valid nPlPor > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if PlPor->(DbSeek(str(dData,4)+str(nPlPor,6)))
     lAppend := .f.
     @ 10,01 say padc(" КОРРЕКТИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
  else
     @ 10,01 say padc(" РЕГИСТРИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
     lAppend := .t.
     PlPor->(DbGoBottom())
     PlPor->(DbSkip(1))
  End
  dDataPor  := PlPor->DataPor
  nEnt      := PlPor->EntPor
  nSumma    := PlPor->SumPor
  nNdc      := PlPor->Ndc
  cText1    := PlPor->Text1
  cText2    := PlPor->Text2
  cText3    := space(45)
  S_Ent->(DbSeek(str(nEnt,4)))
  @ 01,35 get pr pict "9"
  @ 01,33 say "от "+dtoc(dDataPor)+" г."
  @ 02,02 say "Организация "+str(nEnt,4)+" "+S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,02 say "Сумма "+str(nSumma,15,2)+" грв."
  @ 06,28 say "в т.ч. НДС "+str(nNdc,15,2)
  @ 07,02 say "За что "+cText1
  @ 08,02 say "       "+cText2
  ///////////////////////////////////  G E T /////////////////////////
  @ 01,36 get dDataPor pict "@d" valid !Empty(dDataPor)
  @ 02,14 get nEnt pict "9999" valid VedEnt(@nEnt,02,19)
  read
  if LastKey()==K_ESC ; Loop ; End
  @ 02,19 say S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,08 get nSumma pict "999999999999.99" valid nSumma > 0
  read
  if LastKey()==K_ESC ; Loop ; End
  nNdc := if(empty(nNdc),NEW_ROUND(nSumma*0.16667,2),nNdc)
  @ 06,39 get nNdc   pict "999999999999.99" valid nNdc < nSumma .and. nNdc >= 0
  @ 07,09 get cText1
  @ 08,09 get cText2
  @ 09,09 get cText3
  read
  if LastKey()==K_ESC ; Loop ; End
  nKolEkz := 2
  @ 11,01 say padc(" ",MaxCol()-1)
  @ 11,07 say "Укажите количество экземпляров--->" get nKolEkz pict "99"
  read
  if LastKey()<>K_ESC .and. nKolEkz > 0
     @ 11,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[15]
     BEGIN SEQUENCE
     nLen  := 65
     aProp := PropisSum(nSumma,58)
     set(20,"PRINT")
     set(24,"PlPor6.txt")
        if pr#0
     @ prow()+1,00 say "В рахунок невiдкладных потреб "
      endif
     @ Prow()+1,00 say "┌────────────────────────────────────────────────────────────────────────────┐"
     @ Prow()+1,00 say "│             ПЛАТIЖНЕ ДОРУЧЕННЯ N "+str(nPlPor,6)+ "               ┌─────────┐          │ "
     @ Prow()+1,00 say "│                                   ──────              │ 0401001 │          │ "
     @ Prow()+1,00 say "│            вiд <<"+str(day(ddataPor),2)+">>"+NaimMec[month(ddataPor)]+" "+str(year(ddataPor),4)+" р.               └─────────┘          │ "
     @ Prow()+1,00 say "│                     ──   ───────     ─              Одержано банком        │  "
     @ Prow()+1,00 say [│                                              << __>> _____________ 200_ р. │]
     @ Prow()+1,00 say "│Платник  Первомайське  КПУВКХ                                               │ "
     @ Prow()+1,00 say "│   ┌─────────┐                                                              │ "
     @ Prow()+1,00 say "│Код│22714272 │                                                              │ "
     @ Prow()+1,00 say "│   └─────────┘                                                              │  "
     @ Prow()+1,00 say "│ Банк платника                Код банку     ДЕБЕТ рах. N       СУМА         │  "
     @ Prow()+1,00 say "│                               ┌───────┐┌──────────────┬──────────────────┐ │"
     @ Prow()+1,00 say "│Харкiвське ГРУ     ,ПриватБанк'│ 351533││26002348700001│"+strtran(str(nSumma,12,2),".",",")+ "      │ │"
     @ Prow()+1,00 say "│ ──────────────────────────────└───────┘└──────────────┤                  │ │"
     @ Prow()+1,00 say "│ Одержувач " +S_Ent->Naim+ "         │                  │ │"
     @ Prow()+1,00 say "│      ┌───────────┐                      КРЕДИТ рах. N │                  │ │"
     @ Prow()+1,00 say "│ Код  │"+S_Ent->Okpo+ "│                     ┌──────────────┤                  │ │"
     @ Prow()+1,00 say "│      └───────────┘           Код банку │"+S_Ent->Schet+"│                  │ │   "
     @ Prow()+1,00 say "│Банк Одержувачa             ┌─────────┐ ┌──────────────┤                  │ │  "
     @ Prow()+1,00 say "│"+left(S_Ent->Bank,28)+"│"+S_Ent->Mfo+ "│ │              │                  │ │ "
     @ Prow()+1,00 say "│                            └─────────┘ └──────────────└─────────────────── │ "
     @ Prow()+1,00 say "│Сума словами "+aProp[1]+ "     │"
     for i := 2 to Len(aProp)
       @ Prow()+1,00 say "│             "+aProp[i]
     Next
     @ Prow()+1,00 say "│────────────────────────────────────────────────                            │ "
     @ Prow()+1,00 say "│Призначення платежу "+cText1+ "           │"
     @ Prow()+1,00 say "│                    "+cText2+ "           │"
     @ Prow()+1,00 say "│                    "+cText3+ "           │"
     @ Prow()+1,00 say "│                                                       ┌─────────┐          │"
     @ Prow()+1,00 say "│                                                       └─────────┘          │"

     if nNdc > 0
        @ Prow()+1,00 say "│ В тому числi ПДВ - "+str(nNdc,15,2)+ "                                         │"
     End
     @ Prow()+1,00 say "│ м.п.    пiдпис       ────────────           Проведено банком               │ "
     @ Prow()+1,00 say [│                                       <<__>> _____________ 200_ p.         │ ]
     @ Prow()+1,00 say "│                      ────────────            пiдпис банку                  │"
     @ Prow()+1,00 say "└────────────────────────────────────────────────────────────────────────────┘"
     @ Prow()+1,00 say "  "

     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("PlPor6.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE
  End
  if lAppend
     PlPor->(DbAppend())
     PlPor->GodPor:= dData
     PlPor->PlPor := nPlPor
  End
  PlPor->DataPor := dDataPor
  PlPor->EntPor  := nEnt
  PlPor->SumPor  := nSumma
  PlPor->Ndc     := nNdc
  PlPor->Text1   := cText1
  PlPor->Text2   := cText2
End
ferase("PlPor6.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )

///////////////////////////////////////////////////////////////////////////
Function PlPor1() // формирование и печать платежных поручений
Local dData := year(sset[100]), nPlPor, i, nKolEkz, nSumma, nNdc,;
      ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {},cText1, cText2, dDataPor, aProp, nEnt, nLen
Local NaimMec := NaimMes2()
Local   pr:=0

S_Open_M(07,03,19,59,sset[32],sset[2])
While .t.
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ 10,01 say repl("─",MaxCol()-1)
  @ 11,01 say padc(" Минутку....",MaxCol()-1) color sset[15]
  if PlPor->(DbSeek(str(dData,4)))
     While !PlPor->(eof()) .and. PlPor->GodPor == dData
        nPlPor := PlPor->PlPor
        PlPor->(DbSkip(1))
     End
     nPlPor++
  else
     nPlPor := 0
  End
  @ 11,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  @ 01,02 say "No платежного поручения" get nPlPor pict "999999" valid nPlPor > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if PlPor->(DbSeek(str(dData,4)+str(nPlPor,6)))
     lAppend := .f.
     @ 10,01 say padc(" КОРРЕКТИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
  else
     @ 10,01 say padc(" РЕГИСТРИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
     lAppend := .t.
     PlPor->(DbGoBottom())
     PlPor->(DbSkip(1))
  End
  dDataPor  := PlPor->DataPor
  nEnt      := PlPor->EntPor
  nSumma    := PlPor->SumPor
  nNdc      := PlPor->Ndc
  cText1    := PlPor->Text1
  cText2    := PlPor->Text2
  cText3    := space(45)
  S_Ent->(DbSeek(str(nEnt,4)))
  @ 01,35 get pr pict "9"
  @ 01,33 say "от "+dtoc(dDataPor)+" г."
  @ 02,02 say "Организация "+str(nEnt,4)+" "+S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,02 say "Сумма "+str(nSumma,15,2)+" грв."
  @ 06,28 say "в т.ч. НДС "+str(nNdc,15,2)
  @ 07,02 say "За что "+cText1
  @ 08,02 say "       "+cText2
  ///////////////////////////////////  G E T /////////////////////////
  @ 01,36 get dDataPor pict "@d" valid !Empty(dDataPor)
  @ 02,14 get nEnt pict "9999" valid VedEnt(@nEnt,02,19)
  read
  if LastKey()==K_ESC ; Loop ; End
  @ 02,19 say S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,08 get nSumma pict "999999999999.99" valid nSumma > 0
  read
  if LastKey()==K_ESC ; Loop ; End
  nNdc := if(empty(nNdc),NEW_ROUND(nSumma*0.16667,2),nNdc)
  @ 06,39 get nNdc   pict "999999999999.99" valid nNdc < nSumma .and. nNdc >= 0
  @ 07,09 get cText1
  @ 08,09 get cText2
  @ 09,09 get cText3
  read
  if LastKey()==K_ESC ; Loop ; End
  nKolEkz := 2
  @ 11,01 say padc(" ",MaxCol()-1)
  @ 11,07 say "Укажите количество экземпляров--->" get nKolEkz pict "99"
  read
  if LastKey()<>K_ESC .and. nKolEkz > 0
     @ 11,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[15]
     BEGIN SEQUENCE
     nLen  := 65
     aProp := PropisSum(nSumma,58)
     set(20,"PRINT")
     set(24,"PlPor6.txt")
        if pr#0
     @ prow()+1,00 say "В рахунок невiдкладных потреб "
      endif
     @ Prow()+1,00 say "┌────────────────────────────────────────────────────────────────────────────┐"
     @ Prow()+1,00 say "│             ПЛАТIЖНЕ ДОРУЧЕННЯ N "+str(nPlPor,6)+ "               ┌─────────┐          │ "
     @ Prow()+1,00 say "│                                   ──────              │ 0401001 │          │ "
     @ Prow()+1,00 say "│            вiд <<"+str(day(ddataPor),2)+">>"+NaimMec[month(ddataPor)]+" "+str(year(ddataPor),4)+" р.               └─────────┘          │ "
     @ Prow()+1,00 say "│                     ──   ───────     ─              Одержано банком        │  "
     @ Prow()+1,00 say [│                                              << __>> _____________ 200_ р. │]
     @ Prow()+1,00 say "│Платник  Первомайське  КПУВКХ                                               │ "
     @ Prow()+1,00 say "│   ┌─────────┐                                                              │ "
     @ Prow()+1,00 say "│Код│22714272 │                                                              │ "
     @ Prow()+1,00 say "│   └─────────┘                                                              │  "
     @ Prow()+1,00 say "│ Банк платника                Код банку     ДЕБЕТ рах. N       СУМА         │  "
     @ Prow()+1,00 say "│                               ┌───────┐┌──────────────┬──────────────────┐ │"
     @ Prow()+1,00 say "│Харкiвське ГРУ     ,ПриватБанк'│ 351533││26008348700005│"+strtran(str(nSumma,12,2),".",",")+ "      │ │"
     @ Prow()+1,00 say "│ ──────────────────────────────└───────┘└──────────────┤                  │ │"
     @ Prow()+1,00 say "│ Одержувач " +S_Ent->Naim+ "         │                  │ │"
     @ Prow()+1,00 say "│      ┌───────────┐                      КРЕДИТ рах. N │                  │ │"
     @ Prow()+1,00 say "│ Код  │"+S_Ent->Okpo+ "│                     ┌──────────────┤                  │ │"
     @ Prow()+1,00 say "│      └───────────┘           Код банку │"+S_Ent->Schet+"│                  │ │   "
     @ Prow()+1,00 say "│Банк Одержувачa             ┌─────────┐ ┌──────────────┤                  │ │  "
     @ Prow()+1,00 say "│"+left(S_Ent->Bank,28)+"│"+S_Ent->Mfo+ "│ │              │                  │ │ "
     @ Prow()+1,00 say "│                            └─────────┘ └──────────────└─────────────────── │ "
     @ Prow()+1,00 say "│Сума словами "+aProp[1]+ "     │"
     for i := 2 to Len(aProp)
       @ Prow()+1,00 say "│             "+aProp[i]
     Next
     @ Prow()+1,00 say "│────────────────────────────────────────────────                            │ "
     @ Prow()+1,00 say "│Призначення платежу "+cText1+ "           │"
     @ Prow()+1,00 say "│                    "+cText2+ "           │"
     @ Prow()+1,00 say "│                    "+cText3+ "           │"
     @ Prow()+1,00 say "│                                                       ┌─────────┐          │"
     @ Prow()+1,00 say "│                                                       └─────────┘          │"

     if nNdc > 0
        @ Prow()+1,00 say "│ В тому числi ПДВ - "+str(nNdc,15,2)+ "                                         │"
     End
     @ Prow()+1,00 say "│ м.п.    пiдпис       ────────────           Проведено банком               │ "
     @ Prow()+1,00 say [│                                       <<__>> _____________ 200_ p.         │ ]
     @ Prow()+1,00 say "│                      ────────────            пiдпис банку                  │"
     @ Prow()+1,00 say "└────────────────────────────────────────────────────────────────────────────┘"
     @ Prow()+1,00 say "  "

     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("PlPor6.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE
  End
  if lAppend
     PlPor->(DbAppend())
     PlPor->GodPor:= dData
     PlPor->PlPor := nPlPor
  End
  PlPor->DataPor := dDataPor
  PlPor->EntPor  := nEnt
  PlPor->SumPor  := nSumma
  PlPor->Ndc     := nNdc
  PlPor->Text1   := cText1
  PlPor->Text2   := cText2
End
ferase("PlPor6.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )

///////////////////////////////////////////////////////////////////////////
Function PlPor3() // формирование и печать платежных поручений
Local dData := year(sset[100]), nPlPor, i, nKolEkz, nSumma, nNdc,;
      ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {},cText1, cText2, dDataPor, aProp, nEnt, nLen
Local NaimMec := NaimMes2()
Local   pr:=0

S_Open_M(07,03,19,59,sset[32],sset[2])
While .t.
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ 10,01 say repl("─",MaxCol()-1)
  @ 11,01 say padc(" Минутку....",MaxCol()-1) color sset[15]
  if PlPor->(DbSeek(str(dData,4)))
     While !PlPor->(eof()) .and. PlPor->GodPor == dData
        nPlPor := PlPor->PlPor
        PlPor->(DbSkip(1))
     End
     nPlPor++
  else
     nPlPor := 0
  End
  @ 11,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  @ 01,02 say "No платежного поручения" get nPlPor pict "999999" valid nPlPor > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if PlPor->(DbSeek(str(dData,4)+str(nPlPor,6)))
     lAppend := .f.
     @ 10,01 say padc(" КОРРЕКТИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
  else
     @ 10,01 say padc(" РЕГИСТРИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
     lAppend := .t.
     PlPor->(DbGoBottom())
     PlPor->(DbSkip(1))
  End
  dDataPor  := PlPor->DataPor
  nEnt      := PlPor->EntPor
  nSumma    := PlPor->SumPor
  nNdc      := PlPor->Ndc
  cText1    := PlPor->Text1
  cText2    := PlPor->Text2
  cText3    := space(45)
  S_Ent->(DbSeek(str(nEnt,4)))
  @ 01,35 get pr pict "9"
  @ 01,33 say "от "+dtoc(dDataPor)+" г."
  @ 02,02 say "Организация "+str(nEnt,4)+" "+S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,02 say "Сумма "+str(nSumma,15,2)+" грв."
  @ 06,28 say "в т.ч. НДС "+str(nNdc,15,2)
  @ 07,02 say "За что "+cText1
  @ 08,02 say "       "+cText2
  ///////////////////////////////////  G E T /////////////////////////
  @ 01,36 get dDataPor pict "@d" valid !Empty(dDataPor)
  @ 02,14 get nEnt pict "9999" valid VedEnt(@nEnt,02,19)
  read
  if LastKey()==K_ESC ; Loop ; End
  @ 02,19 say S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,08 get nSumma pict "999999999999.99" valid nSumma > 0
  read
  if LastKey()==K_ESC ; Loop ; End
  nNdc := if(empty(nNdc),NEW_ROUND(nSumma*0.16667,2),nNdc)
  @ 06,39 get nNdc   pict "999999999999.99" valid nNdc < nSumma .and. nNdc >= 0
  @ 07,09 get cText1
  @ 08,09 get cText2
  @ 09,09 get cText3
  read
  if LastKey()==K_ESC ; Loop ; End
  nKolEkz := 2
  @ 11,01 say padc(" ",MaxCol()-1)
  @ 11,07 say "Укажите количество экземпляров--->" get nKolEkz pict "99"
  read
  if LastKey()<>K_ESC .and. nKolEkz > 0
     @ 11,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[15]
     BEGIN SEQUENCE
     nLen  := 65
     aProp := PropisSum(nSumma,58)
     set(20,"PRINT")
     set(24,"PlPor6.txt")
        if pr#0
     @ prow()+1,00 say "В рахунок невiдкладных потреб "
      endif
     @ Prow()+1,00 say "┌────────────────────────────────────────────────────────────────────────────┐"
     @ Prow()+1,00 say "│             ПЛАТIЖНЕ ДОРУЧЕННЯ N "+str(nPlPor,6)+ "               ┌─────────┐          │ "
     @ Prow()+1,00 say "│                                   ──────              │ 0401001 │          │ "
     @ Prow()+1,00 say "│            вiд <<"+str(day(ddataPor),2)+">>"+NaimMec[month(ddataPor)]+" "+str(year(ddataPor),4)+" р.               └─────────┘          │ "
     @ Prow()+1,00 say "│                     ──   ───────     ─              Одержано банком        │  "
     @ Prow()+1,00 say [│                                              << __>> _____________ 200_ р. │]
     @ Prow()+1,00 say "│Платник  Первомайське  КПУВКХ                                               │ "
     @ Prow()+1,00 say "│   ┌─────────┐                                                              │ "
     @ Prow()+1,00 say "│Код│22714272 │                                                              │ "
     @ Prow()+1,00 say "│   └─────────┘                                                              │  "
     @ Prow()+1,00 say "│ Банк платника                Код банку     ДЕБЕТ рах. N       СУМА         │  "
     @ Prow()+1,00 say "│                               ┌───────┐┌──────────────┬──────────────────┐ │"
     @ Prow()+1,00 say "│Харкiвське ГРУ     ,ПриватБанк'│ 351533││26063348700006│"+strtran(str(nSumma,12,2),".",",")+ "      │ │"
     @ Prow()+1,00 say "│ ──────────────────────────────└───────┘└──────────────┤                  │ │"
     @ Prow()+1,00 say "│ Одержувач " +S_Ent->Naim+ "         │                  │ │"
     @ Prow()+1,00 say "│      ┌───────────┐                      КРЕДИТ рах. N │                  │ │"
     @ Prow()+1,00 say "│ Код  │"+S_Ent->Okpo+ "│                     ┌──────────────┤                  │ │"
     @ Prow()+1,00 say "│      └───────────┘           Код банку │"+S_Ent->Schet+"│                  │ │   "
     @ Prow()+1,00 say "│Банк Одержувачa             ┌─────────┐ ┌──────────────┤                  │ │  "
     @ Prow()+1,00 say "│"+left(S_Ent->Bank,28)+"│"+S_Ent->Mfo+ "│ │              │                  │ │ "
     @ Prow()+1,00 say "│                            └─────────┘ └──────────────└─────────────────── │ "
     @ Prow()+1,00 say "│Сума словами "+aProp[1]+ "     │"
     for i := 2 to Len(aProp)
       @ Prow()+1,00 say "│             "+aProp[i]
     Next
     @ Prow()+1,00 say "│────────────────────────────────────────────────                            │ "
     @ Prow()+1,00 say "│Призначення платежу "+cText1+ "           │"
     @ Prow()+1,00 say "│                    "+cText2+ "           │"
     @ Prow()+1,00 say "│                    "+cText3+ "           │"
     @ Prow()+1,00 say "│                                                       ┌─────────┐          │"
     @ Prow()+1,00 say "│                                                       └─────────┘          │"

     @ Prow()+1,00 say "│ м.п.    пiдпис       ────────────           Проведено банком               │ "
     @ Prow()+1,00 say [│                                       <<__>> _____________ 200_ p.         │ ]
     @ Prow()+1,00 say "│                      ────────────            пiдпис банку                  │"
     @ Prow()+1,00 say "└────────────────────────────────────────────────────────────────────────────┘"
     @ Prow()+1,00 say "  "

     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("PlPor6.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE
  End
  if lAppend
     PlPor->(DbAppend())
     PlPor->GodPor:= dData
     PlPor->PlPor := nPlPor
  End
  PlPor->DataPor := dDataPor
  PlPor->EntPor  := nEnt
  PlPor->SumPor  := nSumma
  PlPor->Ndc     := nNdc
  PlPor->Text1   := cText1
  PlPor->Text2   := cText2
End
ferase("PlPor6.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
Function PlPor2() // формирование и печать платежных поручений
Local dData := year(sset[100]), nPlPor, i, nKolEkz, nSumma, nNdc,;
      ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {},cText1, cText2, dDataPor, aProp, nEnt, nLen
Local NaimMec := NaimMes2()
Local   pr:=0

S_Open_M(07,03,19,59,sset[32],sset[2])
While .t.
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ 10,01 say repl("─",MaxCol()-1)
  @ 11,01 say padc(" Минутку....",MaxCol()-1) color sset[15]
  if PlPor->(DbSeek(str(dData,4)))
     While !PlPor->(eof()) .and. PlPor->GodPor == dData
        nPlPor := PlPor->PlPor
        PlPor->(DbSkip(1))
     End
     nPlPor++
  else
     nPlPor := 0
  End
  @ 11,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  @ 01,02 say "No платежного поручения" get nPlPor pict "999999" valid nPlPor > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if PlPor->(DbSeek(str(dData,4)+str(nPlPor,6)))
     lAppend := .f.
     @ 10,01 say padc(" КОРРЕКТИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
  else
     @ 10,01 say padc(" РЕГИСТРИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
     lAppend := .t.
     PlPor->(DbGoBottom())
     PlPor->(DbSkip(1))
  End
  dDataPor  := PlPor->DataPor
  nEnt      := PlPor->EntPor
  nSumma    := PlPor->SumPor
  nNdc      := PlPor->Ndc
  cText1    := PlPor->Text1
  cText2    := PlPor->Text2
  cText3    := space(45)
  S_Ent->(DbSeek(str(nEnt,4)))
  @ 01,35 get pr pict "9"
  @ 01,33 say "от "+dtoc(dDataPor)+" г."
  @ 02,02 say "Организация "+str(nEnt,4)+" "+S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,02 say "Сумма "+str(nSumma,15,2)+" грв."
  @ 06,28 say "в т.ч. НДС "+str(nNdc,15,2)
  @ 07,02 say "За что "+cText1
  @ 08,02 say "       "+cText2
  ///////////////////////////////////  G E T /////////////////////////
  @ 01,36 get dDataPor pict "@d" valid !Empty(dDataPor)
  @ 02,14 get nEnt pict "9999" valid VedEnt(@nEnt,02,19)
  read
  if LastKey()==K_ESC ; Loop ; End
  @ 02,19 say S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,08 get nSumma pict "999999999999.99" valid nSumma > 0
  read
  if LastKey()==K_ESC ; Loop ; End
  nNdc := if(empty(nNdc),NEW_ROUND(nSumma*0.16667,2),nNdc)
  @ 06,39 get nNdc   pict "999999999999.99" valid nNdc < nSumma .and. nNdc >= 0
  @ 07,09 get cText1
  @ 08,09 get cText2
  @ 09,09 get cText3
  read
  if LastKey()==K_ESC ; Loop ; End
  nKolEkz := 2
  @ 11,01 say padc(" ",MaxCol()-1)
  @ 11,07 say "Укажите количество экземпляров--->" get nKolEkz pict "99"
  read
  if LastKey()<>K_ESC .and. nKolEkz > 0
     @ 11,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[15]
     BEGIN SEQUENCE
     nLen  := 65
     aProp := PropisSum(nSumma,58)
     set(20,"PRINT")
     set(24,"PlPor6.txt")
        if pr#0
     @ prow()+1,00 say "В рахунок невiдкладных потреб "
      endif
     @ Prow()+1,00 say "┌────────────────────────────────────────────────────────────────────────────┐"
     @ Prow()+1,00 say "│             ПЛАТIЖНЕ ДОРУЧЕННЯ N "+str(nPlPor,6)+ "               ┌─────────┐          │ "
     @ Prow()+1,00 say "│                                   ──────              │ 0401001 │          │ "
     @ Prow()+1,00 say "│            вiд <<"+str(day(ddataPor),2)+">>"+NaimMec[month(ddataPor)]+" "+str(year(ddataPor),4)+" р.               └─────────┘          │ "
     @ Prow()+1,00 say "│                     ──   ───────     ─              Одержано банком        │  "
     @ Prow()+1,00 say [│                                              << __>> _____________ 200_ р. │]
     @ Prow()+1,00 say "│Платник  Первомайське  КПУВКХ                                               │ "
     @ Prow()+1,00 say "│   ┌─────────┐                                                              │ "
     @ Prow()+1,00 say "│Код│22714272 │                                                              │ "
     @ Prow()+1,00 say "│   └─────────┘                                                              │  "
     @ Prow()+1,00 say "│ Банк платника                Код банку     ДЕБЕТ рах. N       СУМА         │  "
     @ Prow()+1,00 say "│                               ┌───────┐┌──────────────┬──────────────────┐ │"
     @ Prow()+1,00 say "│Харкiвське ГРУ     ,ПриватБанк'│ 351533││26007348700006│"+strtran(str(nSumma,12,2),".",",")+ "      │ │"
     @ Prow()+1,00 say "│ ──────────────────────────────└───────┘└──────────────┤                  │ │"
     @ Prow()+1,00 say "│ Одержувач " +S_Ent->Naim+ "         │                  │ │"
     @ Prow()+1,00 say "│      ┌───────────┐                      КРЕДИТ рах. N │                  │ │"
     @ Prow()+1,00 say "│ Код  │"+S_Ent->Okpo+ "│                     ┌──────────────┤                  │ │"
     @ Prow()+1,00 say "│      └───────────┘           Код банку │"+S_Ent->Schet+"│                  │ │   "
     @ Prow()+1,00 say "│Банк Одержувачa             ┌─────────┐ ┌──────────────┤                  │ │  "
     @ Prow()+1,00 say "│"+left(S_Ent->Bank,28)+"│"+S_Ent->Mfo+ "│ │              │                  │ │ "
     @ Prow()+1,00 say "│                            └─────────┘ └──────────────└─────────────────── │ "
     @ Prow()+1,00 say "│Сума словами "+aProp[1]+ "     │"
     for i := 2 to Len(aProp)
       @ Prow()+1,00 say "│             "+aProp[i]
     Next
     @ Prow()+1,00 say "│────────────────────────────────────────────────                            │ "
     @ Prow()+1,00 say "│Призначення платежу "+cText1+ "           │"
     @ Prow()+1,00 say "│                    "+cText2+ "           │"
     @ Prow()+1,00 say "│                    "+cText3+ "           │"
     @ Prow()+1,00 say "│                                                       ┌─────────┐          │"
     @ Prow()+1,00 say "│                                                       └─────────┘          │"

     if nNdc > 0
        @ Prow()+1,00 say "│ В тому числi ПДВ - "+str(nNdc,15,2)+ "                                         │"
     End
     @ Prow()+1,00 say "│ м.п.    пiдпис       ────────────           Проведено банком               │ "
     @ Prow()+1,00 say [│                                       <<__>> _____________ 200_ p.         │ ]
     @ Prow()+1,00 say "│                      ────────────            пiдпис банку                  │"
     @ Prow()+1,00 say "└────────────────────────────────────────────────────────────────────────────┘"
     @ Prow()+1,00 say "  "

     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("PlPor6.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE
  End
  if lAppend
     PlPor->(DbAppend())
     PlPor->GodPor:= dData
     PlPor->PlPor := nPlPor
  End
  PlPor->DataPor := dDataPor
  PlPor->EntPor  := nEnt
  PlPor->SumPor  := nSumma
  PlPor->Ndc     := nNdc
  PlPor->Text1   := cText1
  PlPor->Text2   := cText2
End
ferase("PlPor6.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )


///////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
Function PlPor282() // формирование и печать платежных поручений
Local dData := year(sset[100]), nPlPor, i, nKolEkz, nSumma, nNdc,;
      ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {},cText1, cText2, dDataPor, aProp, nEnt, nLen
Local NaimMec := NaimMes2()
Local   pr:=0

S_Open_M(07,03,19,59,sset[32],sset[2])
While .t.
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ 10,01 say repl("─",MaxCol()-1)
  @ 11,01 say padc(" Минутку....",MaxCol()-1) color sset[15]
  if PlPor->(DbSeek(str(dData,4)))
     While !PlPor->(eof()) .and. PlPor->GodPor == dData
        nPlPor := PlPor->PlPor
        PlPor->(DbSkip(1))
     End
     nPlPor++
  else
     nPlPor := 0
  End
  @ 11,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  @ 01,02 say "No платежного поручения" get nPlPor pict "999999" valid nPlPor > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if PlPor->(DbSeek(str(dData,4)+str(nPlPor,6)))
     lAppend := .f.
     @ 10,01 say padc(" КОРРЕКТИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
  else
     @ 10,01 say padc(" РЕГИСТРИРУЕМ ПОРУЧЕНИЕ",MaxCol()-1) color sset[15]
     lAppend := .t.
     PlPor->(DbGoBottom())
     PlPor->(DbSkip(1))
  End
  dDataPor  := PlPor->DataPor
  nEnt      := PlPor->EntPor
  nSumma    := PlPor->SumPor
  nNdc      := PlPor->Ndc
  cText1    := PlPor->Text1
  cText2    := PlPor->Text2
  cText3    := space(45)
  S_Ent->(DbSeek(str(nEnt,4)))
  @ 01,35 get pr pict "9"
  @ 01,33 say "от "+dtoc(dDataPor)+" г."
  @ 02,02 say "Организация "+str(nEnt,4)+" "+S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,02 say "Сумма "+str(nSumma,15,2)+" грв."
  @ 06,28 say "в т.ч. НДС "+str(nNdc,15,2)
  @ 07,02 say "За что "+cText1
  @ 08,02 say "       "+cText2
  ///////////////////////////////////  G E T /////////////////////////
  @ 01,36 get dDataPor pict "@d" valid !Empty(dDataPor)
  @ 02,14 get nEnt pict "9999" valid VedEnt(@nEnt,02,19)
  read
  if LastKey()==K_ESC ; Loop ; End
  @ 02,19 say S_Ent->Naim
  @ 03,14 say "МФО "+S_Ent->Mfo+" счет "+S_Ent->Schet
  @ 04,14 say "ОКПО "+S_Ent->Okpo
  @ 05,14 say "Банк "+S_Ent->Bank
  @ 06,08 get nSumma pict "999999999999.99" valid nSumma > 0
  read
  if LastKey()==K_ESC ; Loop ; End
  nNdc := if(empty(nNdc),NEW_ROUND(nSumma*0.16667,2),nNdc)
  @ 06,39 get nNdc   pict "999999999999.99" valid nNdc < nSumma .and. nNdc >= 0
  @ 07,09 get cText1
  @ 08,09 get cText2
  @ 09,09 get cText3
  read
  if LastKey()==K_ESC ; Loop ; End
  nKolEkz := 2
  @ 11,01 say padc(" ",MaxCol()-1)
  @ 11,07 say "Укажите количество экземпляров--->" get nKolEkz pict "99"
  read
  if LastKey()<>K_ESC .and. nKolEkz > 0
     @ 11,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[15]
     BEGIN SEQUENCE
     nLen  := 65
     aProp := PropisSum(nSumma,58)
     set(20,"PRINT")
     set(24,"PlPor6.txt")
        if pr#0
     @ prow()+1,00 say "В рахунок невiдкладных потреб "
      endif
     @ Prow()+1,00 say "┌────────────────────────────────────────────────────────────────────────────┐"
     @ Prow()+1,00 say "│             ПЛАТIЖНЕ ДОРУЧЕННЯ N "+str(nPlPor,6)+ "               ┌─────────┐          │ "
     @ Prow()+1,00 say "│                                   ──────              │ 0401001 │          │ "
     @ Prow()+1,00 say "│            вiд <<"+str(day(ddataPor),2)+">>"+NaimMec[month(ddataPor)]+" "+str(year(ddataPor),4)+" р.               └─────────┘          │ "
     @ Prow()+1,00 say "│                     ──   ───────     ─              Одержано банком        │  "
     @ Prow()+1,00 say [│                                              << __>> _____________ 200_ р. │]
     @ Prow()+1,00 say "│Платник  Первомайське  КПУВКХ                                               │ "
     @ Prow()+1,00 say "│   ┌─────────┐                                                              │ "
     @ Prow()+1,00 say "│Код│22714272 │                                                              │ "
     @ Prow()+1,00 say "│   └─────────┘                                                              │  "
     @ Prow()+1,00 say "│ Банк платника                Код банку     ДЕБЕТ рах. N       СУМА         │  "
     @ Prow()+1,00 say "│                               ┌───────┐ ┌─────────────┬──────────────────┐ │"
     @ Prow()+1,00 say "│ошадбанк 2856 в м.Первомайське │ 350017│ │ 25420301216 │"+strtran(str(nSumma,12,2),".",",")+ "      │ │"
     @ Prow()+1,00 say "│ ──────────────────────────────└───────┘ └─────────────┤                  │ │"
     @ Prow()+1,00 say "│ Одержувач " +S_Ent->Naim+ "         │                  │ │"
     @ Prow()+1,00 say "│      ┌───────────┐                      КРЕДИТ рах. N │                  │ │"
     @ Prow()+1,00 say "│ Код  │"+S_Ent->Okpo+ "│                     ┌──────────────┤                  │ │"
     @ Prow()+1,00 say "│      └───────────┘           Код банку │"+S_Ent->Schet+"│                  │ │   "
     @ Prow()+1,00 say "│Банк Одержувачa             ┌─────────┐ ┌──────────────┤                  │ │  "
     @ Prow()+1,00 say "│"+left(S_Ent->Bank,28)+"│"+S_Ent->Mfo+ "│ │              │                  │ │ "
     @ Prow()+1,00 say "│                            └─────────┘ └──────────────└─────────────────── │ "
     @ Prow()+1,00 say "│Сума словами "+aProp[1]+ "     │"
     for i := 2 to Len(aProp)
       @ Prow()+1,00 say "│             "+aProp[i]
     Next
     @ Prow()+1,00 say "│────────────────────────────────────────────────                            │ "
     @ Prow()+1,00 say "│Призначення платежу "+cText1+ "           │"
     @ Prow()+1,00 say "│                    "+cText2+ "           │"
     @ Prow()+1,00 say "│                    "+cText3+ "           │"
     @ Prow()+1,00 say "│                                                       ┌─────────┐          │"
//     @ Prow()+1,00 say "│                                                       │                  │"
     @ Prow()+1,00 say "│                                                       └─────────┘          │"

     if nNdc > 0
        @ Prow()+1,00 say "│ В тому числi ПДВ - "+str(nNdc,15,2)+ "                                         │"
     End
//     @ Prow()+1,00 say "│                                                                            │  "
     @ Prow()+1,00 say "│ м.п.    пiдпис       ────────────           Проведено банком               │ "
     @ Prow()+1,00 say [│                                       <<__>> _____________ 200_ p.         │ ]
//     @ Prow()+1,00 say "│                                                                            │"
     @ Prow()+1,00 say "│                      ────────────            пiдпис банку                  │"
//     @ Prow()+1,00 say "│                                                                            │"
     @ Prow()+1,00 say "└────────────────────────────────────────────────────────────────────────────┘"
     @ Prow()+1,00 say "  "

     @ Prow()+1,00 say repl("= ",nLen/2)
     @ prow()+1,00 say ""
     set(24,"")
     set(20,"SCREEN")
     for i := 1 to nKolEkz
        if S_TPRN("PlPor6.txt",,1) < 0 ; break ; End
     Next
     END SEQUENCE
  End
  if lAppend
     PlPor->(DbAppend())
     PlPor->GodPor:= dData
     PlPor->PlPor := nPlPor
  End
  PlPor->DataPor := dDataPor
  PlPor->EntPor  := nEnt
  PlPor->SumPor  := nSumma
  PlPor->Ndc     := nNdc
  PlPor->Text1   := cText1
  PlPor->Text2   := cText2
End
ferase("PlPor6.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )

Static function PropisSum(Sum,Dlina,Krb,Kop)
local Bank,Sumc,Prop,i,T,J,Kc,P,K,Adr,Baza, Ret := {}
Bank := "001одна 002двi 003три 004чотири 005п'ять "+;
        "006шiсть 007сiм 008вiсiм 009дев'ять 010десять "+;
        "011одинадцять 012дванадцять 013тринадцять "+;
        "014чотирнадцять 015п'ятнадцять 016шiстнадцять "+;
        "017сiмнадцять 018вiсiмнадцять 019девятнадцять "+;
        "020двадцять 030тридцять 040сорок 050п'ятдесят "+;
        "060шiстдесят 070сiмдесят 080вiсiмдесят "+;
        "090дев'яносто 100сто 200двiстi 300триста 400чотириста "+;
        "500п'ятьсот 600шiстьсот 700сiмсот 800вiсiмсот "+;
        "900дев'ятьсот   "
Dlina := iif(Dlina=NIL .or. Dlina=0,128,Dlina)
Krb := if(Krb==Nil,"грв. ",Krb)
Kop := if(Kop==Nil,"коп. ",Kop)
Sumc  := strzero(Sum,15,2)
if Sum=0
   Prop := "нуль "
 else
   Adr := "000"
   Prop := ""
   for i=1 to 4
      T := (I-1)*3
      Bank := stuff(Bank,4,11,iif(I=3,"одна 002двi","один 002два"))
      for J=1 to 3
        P := T+J
        Kc := substr(Sumc,P,1)
        K :=  val(KC)
        Adr := stuff(Adr,J,1,Kc)
        if ( Adr#"010" .or. J#2 ) .and. Adr#"000"
            P := at(Adr,Bank)
            P += 3
            Baza := substr(Bank,P,13)
            P := at(" ",Baza)
            Prop += substr(Baza,1,P)
            Adr :=  "000"
        end
     next
     do case
        case I=3 .and. Sum>=1000  .and. substr(Sumc,7,3)#"000"
           Prop += "тисяч"
           if K>0 .and. K<=4 .and. substr(Sumc,8,1)<>"1"
              Prop += substr("аiii",K,1)
           end
           Prop += " "
        case I=2 .and. Sum>=1000000 .and. substr(Sumc,4,3)#"000"
           Prop += "мiльйон"
           if K>=2 .and. K<=4 .and. substr(Sumc,5,1)#"1" .and. ;
                                                      substr(Sumc,6,1)#"0"
              Prop += "а"
            else
              if K>=5 .or. substr(Sumc,5,1)="1" .or. substr(Sumc,6,1)="0"
                 Prop += "iв"
              end
           end
           Prop += " "
        case I=1 .and. Sum>=1000000000
           Prop += "мiльярд"
           if K>=2 .and. K<=4 .and. substr(Sumc,2,1)#"1" .and. ;
                                                substr(Sumc,3,1)#"0"
              Prop += "а"
            else
              if K>=5 .or. substr(Sumc,2,1)="1" .or. substr(Sumc,3,1)="0"
                 Prop += "iв"
              end
           end
           Prop += " "
     endcase
  next
end
P := asc(Prop)
P := iif(P>=160 .and. P<=175,P-32,P-80)
Prop := stuff(Prop,1,1,chr(P))
Prop := left(Prop,len(Prop)-1)+"#"+Krb+" "+right(Sumc,2)+"#"+Kop
Bank := Adr := ""
While ( ( I := at(" ",Prop) ) # 0 )
   Adr := left(Prop,I)
   if len(Adr+Bank) < Dlina
      Bank += Adr
     else
      aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
      Bank := Adr
   end
   Prop := substr(Prop,I+1)
end
if Len(Bank+Prop) > Dlina
   aadd(Ret,Padr(StrTran(Bank,"#"," "),Dlina))
   Bank := ""
end
Bank += Prop
if len(Bank)>0
   aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
end
Return ( Ret )
//////////////////////////////////////////////////////////////////////////////
Function ChFakt() // формирование и печать счет-фактуры
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)

Local NaimMec := NaimMes("ru")

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
  nChFakt := Fakt->NomChF + 1
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от" get dDataCh pict "@d" valid !Empty(dDataCh)
      @ 03,02 say "за" get dData   pict "@d" valid !Empty(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      @ 05,02 say "Код организации" get nEnt pict "9999" valid VedEnt(@nEnt,06,02)
      read
      if LastKey() == K_ESC ; exit ; End
      if nKolEkz > 0
         if !Prixod->(DbSeek(str(nEnt,4)))
           S_Beep()
           @ MaxRow()-1,01 say padc(" Отсутствуют данные",MaxCol()-1) color sset[15]
           M_inkey(0)
           Loop
         End
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         S_Ent->(DbSeek(str(nEnt,4)))
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("С Ч Е Т - Ф А К Т У Р А  No "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАВЩИК: Первомайское КПУВКХ"
         @ Prow()+1,00 say "          счет 26008348700005 Код 22714272 МФО 351533"
         @ Prow()+1,00 say [ Харьковское ГРУ ,ПриватБанк '         ]
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПЛАТЕЛЬШИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "лс"+str(S_Ent->Ent,4)+"счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договор "+cDogovor+" от "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Ед.  | Количество |    Цена     | Наименование           |     Сумма    |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         aFakt := {}
         While Prixod->Ent == nEnt .and. !Prixod->(eof())
           @ prow()+1,00 say "м.куб "+str(Prixod->Kolvo,12)+" "+str(Prixod->Cena,9,6)+" "+;
             padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24)+" "+;
             str(Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,14,2)
           S_Price->(DbSeek(str(Prixod->Chet,4,0)+str(S_Ent->Tip,1)))
           if !Empty(Prixod->Ndc)
             @ prow()+1,00 say space(33)+padr("НДС "+;
               iif(S_Price->Ndc=0,"",str(S_Price->Ndc*100,4,1)+"%"),24)+" "+str(Prixod->Ndc,14,2)
           End
           if !Empty(Prixod->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС "+;
               iif(S_Price->Fec=0,"",str(S_Price->Fec*100,4,1)+"%"),24)+" "+str(Prixod->Fec,14,2)
           End
           if !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Prixod->SumBank,14,2)
           End
           if !Empty(Prixod->Ndc) .or. !Empty(Prixod->Fec) .or. !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Итого ",24)+" "+;
               str(Prixod->Summa,14,2)
           End
           nSumma += Prixod->Summa
           aadd(aFakt,{"м.куб ",Prixod->Kolvo,Prixod->Cena,;
                      padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24),;
                      Prixod->Summa,;
                      Prixod->Ndc,Prixod->Fec,Prixod->SumBank,Prixod->Chet})
           Prixod->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Всего за месяц ",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сумма к оплате: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                           Котовчихiн В.В."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гл. бухгалтер                         Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
         if Fakt->(DbSeek(Str(nChFakt,6)))
            While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
               Fakt->(DbDelete())
               Fakt->(DbSkip(1))
            End
         End
         For i := 1 to len(aFakt)
           Fakt->(DbAppend())
           Fakt->NomChF  := nChFakt
           Fakt->DataCh  := dDataCh
           Fakt->Data    := dData
           Fakt->Ent     := nEnt
           Fakt->EdIzm   := aFakt[i][1]
           Fakt->Kolvo   := aFakt[i][2]
           Fakt->Cena    := aFakt[i][3]
           Fakt->Naim    := aFakt[i][4]
           Fakt->Summa   := aFakt[i][5]
           Fakt->Ndc     := aFakt[i][6]
           Fakt->Fec     := aFakt[i][7]
           Fakt->SumBank := aFakt[i][8]
           Fakt->Chet    := aFakt[i][9]
         Next
      End
   else // Старая
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("С Ч Е Т - Ф А К Т У Р А  No "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАВЩИК: Первомайское КПУВКХ"
         @ Prow()+1,00 say "        счет 26008348700005 Код 22714272 МФО 351533"
         @ Prow()+1,00 say [Харьковское ГРУ ,ПриватБанк'         ]
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПЛАТЕЛЬШИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "лс"+str(S_Ent->Ent,4)+"счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
//         @ Prow()+1,00 say "             счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договор "+cDogovor+" от "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Ед.  | Количество |    Цена     | Наименование           |     Сумма    |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("НДС ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Итого ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Всего за месяц ",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сумма к оплате: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                  Котовчихiн В.В. "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гл. бухгалтер                Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function ChFakt1() // формирование и печать счет-фактуры
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)

Local NaimMec := NaimMes("ru")

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
  nChFakt := Fakt->NomChF + 1
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от" get dDataCh pict "@d" valid !Empty(dDataCh)
      @ 03,02 say "за" get dData   pict "@d" valid !Empty(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      @ 05,02 say "Код организации" get nEnt pict "9999" valid VedEnt(@nEnt,06,02)
      read
      if LastKey() == K_ESC ; exit ; End
      if nKolEkz > 0
         if !Prixod->(DbSeek(str(nEnt,4)))
           S_Beep()
           @ MaxRow()-1,01 say padc(" Отсутствуют данные",MaxCol()-1) color sset[15]
           M_inkey(0)
           Loop
         End
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         S_Ent->(DbSeek(str(nEnt,4)))
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "          р/р 26007300253580 Код 22714272 МФО 351823"
         @ Prow()+1,00 say "В ТВБТ 10020/0525 фiлii Харкiвського обласного"
         @ Prow()+1,00 say [ управлiння АТ,Ощадбанк'м Первомайський  ]
         @ Prow()+1,00 say " ПЛАТHИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
//       @ Prow()+1,00 say "             счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         aFakt := {}
         While Prixod->Ent == nEnt .and. !Prixod->(eof())
           @ prow()+1,00 say "м.куб "+str(Prixod->Kolvo,12)+" "+str(Prixod->Cena,9,6)+" "+;
             padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24)+" "+;
             str(Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,14,2)
           S_Price->(DbSeek(str(Prixod->Chet,4,0)+str(S_Ent->Tip,1)))
           if !Empty(Prixod->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ "+;
               iif(S_Price->Ndc=0,"",str(S_Price->Ndc*100,4,1)+"%"),24)+" "+str(Prixod->Ndc,14,2)
           End
           if !Empty(Prixod->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС "+;
               iif(S_Price->Fec=0,"",str(S_Price->Fec*100,4,1)+"%"),24)+" "+str(Prixod->Fec,14,2)
           End
           if !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Prixod->SumBank,14,2)
           End
           if !Empty(Prixod->Ndc) .or. !Empty(Prixod->Fec) .or. !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Всьoго ",24)+" "+;
               str(Prixod->Summa,14,2)
           End
           nSumma += Prixod->Summa
           aadd(aFakt,{"м.куб ",Prixod->Kolvo,Prixod->Cena,;
                      padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24),;
                      Prixod->Summa,;
                      Prixod->Ndc,Prixod->Fec,Prixod->SumBank,Prixod->Chet})
           Prixod->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                           Котовчихiн В.В."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                         Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
         if Fakt->(DbSeek(Str(nChFakt,6)))
            While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
               Fakt->(DbDelete())
               Fakt->(DbSkip(1))
            End
         End
         For i := 1 to len(aFakt)
           Fakt->(DbAppend())
           Fakt->NomChF  := nChFakt
           Fakt->DataCh  := dDataCh
           Fakt->Data    := dData
           Fakt->Ent     := nEnt
           Fakt->EdIzm   := aFakt[i][1]
           Fakt->Kolvo   := aFakt[i][2]
           Fakt->Cena    := aFakt[i][3]
           Fakt->Naim    := aFakt[i][4]
           Fakt->Summa   := aFakt[i][5]
           Fakt->Ndc     := aFakt[i][6]
           Fakt->Fec     := aFakt[i][7]
           Fakt->SumBank := aFakt[i][8]
           Fakt->Chet    := aFakt[i][9]
         Next
      End
   else // Старая
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "        р/р 26007300253580 Код 22714272 МФО 351823"
         @ Prow()+1,00 say "В ТВБТ 10020/0525 фiлii Харкiвського обласного"
         @ Prow()+1,00 say [ управлiння АТ,Ощадбанк'м Первомайський  ]
////  @ Prow()+1,00 say [Харьковское ГРУ ,ПриватБанк'         ]
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПЛАТНИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo  
///      @ Prow()+1,00 say "             счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть   |    Цiна     | Найменування           |     Сумма    |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всьoго ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                  Котовчихiн В.В. "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function ChFakt4() // формирование и печать счет-фактуры
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)

Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
  nChFakt := Fakt->NomChF + 1
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от" get dDataCh pict "@d" valid !Empty(dDataCh)
      @ 03,02 say "за" get dData   pict "@d" valid !Empty(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      @ 05,02 say "Код организации" get nEnt pict "9999" valid VedEnt(@nEnt,06,02)
      read
      if LastKey() == K_ESC ; exit ; End
      if nKolEkz > 0
         if !Prixod->(DbSeek(str(nEnt,4)))
           S_Beep()
           @ MaxRow()-1,01 say padc(" Отсутствуют данные",MaxCol()-1) color sset[15]
           M_inkey(0)
           Loop
         End
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         S_Ent->(DbSeek(str(nEnt,4)))
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "          р/р 26002036412001 Код 22714272 МФО 351005"
         @ Prow()+1,00 say "У ПАТ   УкрСиббанк                            "
         @ Prow()+1,00 say [                                         ]
         @ Prow()+1,00 say " ПЛАТHИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         aFakt := {}
         While Prixod->Ent == nEnt .and. !Prixod->(eof())
           @ prow()+1,00 say "м.куб "+str(Prixod->Kolvo,12)+" "+str(Prixod->Cena,9,6)+" "+;
             padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24)+" "+;
             str(Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,14,2)
           S_Price->(DbSeek(str(Prixod->Chet,4,0)+str(S_Ent->Tip,1)))
           if !Empty(Prixod->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ "+;
               iif(S_Price->Ndc=0,"",str(S_Price->Ndc*100,4,1)+"%"),24)+" "+str(Prixod->Ndc,14,2)
           End
           if !Empty(Prixod->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС "+;
               iif(S_Price->Fec=0,"",str(S_Price->Fec*100,4,1)+"%"),24)+" "+str(Prixod->Fec,14,2)
           End
           if !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Prixod->SumBank,14,2)
           End
           if !Empty(Prixod->Ndc) .or. !Empty(Prixod->Fec) .or. !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Всьoго ",24)+" "+;
               str(Prixod->Summa,14,2)
           End
           nSumma += Prixod->Summa
           aadd(aFakt,{"м.куб ",Prixod->Kolvo,Prixod->Cena,;
                      padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24),;
                      Prixod->Summa,;
                      Prixod->Ndc,Prixod->Fec,Prixod->SumBank,Prixod->Chet})
           Prixod->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                           Котовчихiн В.В."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                         Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
         if Fakt->(DbSeek(Str(nChFakt,6)))
            While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
               Fakt->(DbDelete())
               Fakt->(DbSkip(1))
            End
         End
         For i := 1 to len(aFakt)
           Fakt->(DbAppend())
           Fakt->NomChF  := nChFakt
           Fakt->DataCh  := dDataCh
           Fakt->Data    := dData
           Fakt->Ent     := nEnt
           Fakt->EdIzm   := aFakt[i][1]
           Fakt->Kolvo   := aFakt[i][2]
           Fakt->Cena    := aFakt[i][3]
           Fakt->Naim    := aFakt[i][4]
           Fakt->Summa   := aFakt[i][5]
           Fakt->Ndc     := aFakt[i][6]
           Fakt->Fec     := aFakt[i][7]
           Fakt->SumBank := aFakt[i][8]
           Fakt->Chet    := aFakt[i][9]
         Next
      End
   else // Старая
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "        р/р 26002036412001 Код 22714272 МФО 351005"
         @ Prow()+1,00 say "У ПАТ УкрСиббанк                              "
         @ Prow()+1,00 say [                                         ]
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПЛАТНИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo  
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть   |    Цiна     | Найменування           |     Сумма    |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всьoго ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                  Котовчнхiн В.В. "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function ChFakt5() // формирование и печать счет-фактуры
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)

Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
  nChFakt := Fakt->NomChF + 1
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от" get dDataCh pict "@d" valid !Empty(dDataCh)
      @ 03,02 say "за" get dData   pict "@d" valid !Empty(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      @ 05,02 say "Код организации" get nEnt pict "9999" valid VedEnt(@nEnt,06,02)
      read
      if LastKey() == K_ESC ; exit ; End
      if nKolEkz > 0
         if !Prixod->(DbSeek(str(nEnt,4)))
           S_Beep()
           @ MaxRow()-1,01 say padc(" Отсутствуют данные",MaxCol()-1) color sset[15]
           M_inkey(0)
           Loop
         End
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         S_Ent->(DbSeek(str(nEnt,4)))
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "          р/р 2600511060     Код 22714272 МФО 351629"
         @ Prow()+1,00 say "У ПАТ   Мегабанк                              "
         @ Prow()+1,00 say [                                         ]
         @ Prow()+1,00 say " ПЛАТHИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         aFakt := {}
         While Prixod->Ent == nEnt .and. !Prixod->(eof())
           @ prow()+1,00 say "м.куб "+str(Prixod->Kolvo,12)+" "+str(Prixod->Cena,9,6)+" "+;
             padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24)+" "+;
             str(Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,14,2)
           S_Price->(DbSeek(str(Prixod->Chet,4,0)+str(S_Ent->Tip,1)))
           if !Empty(Prixod->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ "+;
               iif(S_Price->Ndc=0,"",str(S_Price->Ndc*100,4,1)+"%"),24)+" "+str(Prixod->Ndc,14,2)
           End
           if !Empty(Prixod->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС "+;
               iif(S_Price->Fec=0,"",str(S_Price->Fec*100,4,1)+"%"),24)+" "+str(Prixod->Fec,14,2)
           End
           if !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Prixod->SumBank,14,2)
           End
           if !Empty(Prixod->Ndc) .or. !Empty(Prixod->Fec) .or. !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Всьoго ",24)+" "+;
               str(Prixod->Summa,14,2)
           End
           nSumma += Prixod->Summa
           aadd(aFakt,{"м.куб ",Prixod->Kolvo,Prixod->Cena,;
                      padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24),;
                      Prixod->Summa,;
                      Prixod->Ndc,Prixod->Fec,Prixod->SumBank,Prixod->Chet})
           Prixod->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                           Котовчихiн В.В."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                         Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
         if Fakt->(DbSeek(Str(nChFakt,6)))
            While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
               Fakt->(DbDelete())
               Fakt->(DbSkip(1))
            End
         End
         For i := 1 to len(aFakt)
           Fakt->(DbAppend())
           Fakt->NomChF  := nChFakt
           Fakt->DataCh  := dDataCh
           Fakt->Data    := dData
           Fakt->Ent     := nEnt
           Fakt->EdIzm   := aFakt[i][1]
           Fakt->Kolvo   := aFakt[i][2]
           Fakt->Cena    := aFakt[i][3]
           Fakt->Naim    := aFakt[i][4]
           Fakt->Summa   := aFakt[i][5]
           Fakt->Ndc     := aFakt[i][6]
           Fakt->Fec     := aFakt[i][7]
           Fakt->SumBank := aFakt[i][8]
           Fakt->Chet    := aFakt[i][9]
         Next
      End
   else // Старая
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "        р/р 2600511060     Код 22714272 МФО 351629"
         @ Prow()+1,00 say "У ПАТ Мегабанк                                "
         @ Prow()+1,00 say [                                         ]
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПЛАТНИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo  
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть   |    Цiна     | Найменування           |     Сумма    |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всьoго ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                  Котовчнхiн В.В. "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
Function ChFakt2() // формирование и печать счет-фактуры
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)

Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
  nChFakt := Fakt->NomChF + 1
  Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от" get dDataCh pict "@d" valid !Empty(dDataCh)
      @ 03,02 say "за" get dData   pict "@d" valid !Empty(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      @ 05,02 say "Код организации" get nEnt pict "9999" valid VedEnt(@nEnt,06,02)
      read
      if LastKey() == K_ESC ; exit ; End
      if nKolEkz > 0
         if !Prixod->(DbSeek(str(nEnt,4)))
           S_Beep()
           @ MaxRow()-1,01 say padc(" Отсутствуют данные",MaxCol()-1) color sset[15]
           M_inkey(0)
           Loop
         End
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         S_Ent->(DbSeek(str(nEnt,4)))
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "          р/р 26007348700006 Код 22714272 МФО 351533"
          @ Prow()+1,00 say [У Харкiвському ГРУ ПАОКБ ,ПриватБанк'         ]
         @ Prow()+1,00 say ""
         @ Prow()+1,00 say " ПЛАТHИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
//       @ Prow()+1,00 say "             счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         aFakt := {}
         While Prixod->Ent == nEnt .and. !Prixod->(eof())
           @ prow()+1,00 say "м.куб "+str(Prixod->Kolvo,12)+" "+str(Prixod->Cena,9,6)+" "+;
             padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24)+" "+;
             str(Prixod->Summa-Prixod->Ndc-Prixod->Fec-Prixod->SumBank,14,2)
           S_Price->(DbSeek(str(Prixod->Chet,4,0)+str(S_Ent->Tip,1)))
           if !Empty(Prixod->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ "+;
               iif(S_Price->Ndc=0,"",str(S_Price->Ndc*100,4,1)+"%"),24)+" "+str(Prixod->Ndc,14,2)
           End
           if !Empty(Prixod->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС "+;
               iif(S_Price->Fec=0,"",str(S_Price->Fec*100,4,1)+"%"),24)+" "+str(Prixod->Fec,14,2)
           End
           if !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Prixod->SumBank,14,2)
           End
           if !Empty(Prixod->Ndc) .or. !Empty(Prixod->Fec) .or. !Empty(Prixod->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Prixod->Summa,14,2)
           End
           nSumma += Prixod->Summa
           aadd(aFakt,{"м.куб ",Prixod->Kolvo,Prixod->Cena,;
                      padr(iNaim(Prixod->Chet)+" за "+cNaimMec,24),;
                      Prixod->Summa,;
                      Prixod->Ndc,Prixod->Fec,Prixod->SumBank,Prixod->Chet})
           Prixod->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                           Котовчихiн В.В."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                         Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
         if Fakt->(DbSeek(Str(nChFakt,6)))
            While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
               Fakt->(DbDelete())
               Fakt->(DbSkip(1))
            End
         End
         For i := 1 to len(aFakt)
           Fakt->(DbAppend())
           Fakt->NomChF  := nChFakt
           Fakt->DataCh  := dDataCh
           Fakt->Data    := dData
           Fakt->Ent     := nEnt
           Fakt->EdIzm   := aFakt[i][1]
           Fakt->Kolvo   := aFakt[i][2]
           Fakt->Cena    := aFakt[i][3]
           Fakt->Naim    := aFakt[i][4]
           Fakt->Summa   := aFakt[i][5]
           Fakt->Ndc     := aFakt[i][6]
           Fakt->Fec     := aFakt[i][7]
           Fakt->SumBank := aFakt[i][8]
           Fakt->Chet    := aFakt[i][9]
         Next
      End
   else // Старая
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say padc("Р А Х У Н О К - Ф А К Т У Р А  N "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say padc("вiд "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПОСТАЧАЛЬНИК: Первомайське КВУВКГ"
         @ Prow()+1,00 say "        р/р 26007348700006 Код 22714272 МФО 351533"
        @ Prow()+1,00 say [У Харкiвську ГРУ ПАОКБ ,ПриватБанк'         ]
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " ПЛАТНИК: "+S_Ent->Naim
         @ Prow()+1,00 say "             "+S_Ent->Naim2
         @ Prow()+1,00 say "о/р"+str(S_Ent->Ent,4)+"р/р "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo  
///      @ Prow()+1,00 say "             счет "+S_Ent->Schet+" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
         @ Prow()+1,00 say "             "+S_Ent->Bank
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " Договiр "+cDogovor+" вiд "+dtoc(dDataDog)
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Вимiр| Кiлькiсть   |    Цiна     | Найменування           |     Сумма    |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Начальник                  Котовчихiн В.В. "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say "  Гол. бухгалтер                Ужегова  Г.П."
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
////////////////////////////////////////////////////////
return ( Nil )
////////////////////////////////////////////////////////////////////////////

Static Function iNaim(nChet)
if nChet == 7031
   Return ( "Вода" )
elseif nChet == 7032
   Return ( "Стоки" )
End
Return ( "Прочие" )
//////////////////////////////////////////////////////////////////////////////
Static function PropisSum_(Sum,Dlina,Krb,Kop)
local Bank,Sumc,Prop,i,T,J,Kc,P,K,Adr,Baza, Ret := {}
Bank := "001одна 002двi 003три 004чoтири 005п'ять "+;
        "006шiсть 007сiм 008вiсiм 009дев'ять 010десять "+;
        "011одиннадцять 012дванадцять 013тринадцять "+;
        "014чотирнадцять 015п'ятнадцять 016шiстнадцять "+;
        "017сiмнадцять 018вiсiмнадцять 019дев'ятнадцять "+;
        "020двадцять 030тридцять 040сорок 050пя'тьдесят "+;
        "060шiстьдесят 070сiмдесят 080вiсiмдесят "+;
        "090дев'яносто 100сто 200двiстi 300триста 400чотириста "+;
        "500п'ятсот 600шiстсот 700сiмсот 800вiсiмсот "+;
        "900дев'ятьсот   "
Dlina := iif(Dlina=NIL .or. Dlina=0,128,Dlina)
Krb := if(Krb==Nil,"грн. ",Krb)
Kop := if(Kop==Nil,"коп. ",Kop)
Prop := ""
if Sum < 0
  Prop := "минус "
  Sum := -Sum
end
Sumc  := strzero(Sum,15,2)
if Sum=0
   Prop := "ноль "
 else
   Adr := "000"
   //Prop := ""
   for i=1 to 4
      T := (I-1)*3
      Bank := stuff(Bank,4,11,iif(I=3,"одна 002две","один 002два"))
      for J=1 to 3
        P := T+J
        Kc := substr(Sumc,P,1)
        K :=  val(KC)
        Adr := stuff(Adr,J,1,Kc)
        if ( Adr#"010" .or. J#2 ) .and. Adr#"000"
            P := at(Adr,Bank)
            P += 3
            Baza := substr(Bank,P,13)
            P := at(" ",Baza)
            Prop += substr(Baza,1,P)
            Adr :=  "000"
        end
     next
     do case
        case I=3 .and. Sum>=1000  .and. substr(Sumc,7,3)#"000"
           Prop += "тисяч"
           if K>0 .and. K<=4 .and. substr(Sumc,8,1)<>"1"
              Prop += substr("аиии",K,1)
           end
           Prop += " "
        case I=2 .and. Sum>=1000000 .and. substr(Sumc,4,3)#"000"
           Prop += "миллион"
           if K>=2 .and. K<=4 .and. substr(Sumc,5,1)#"1" .and. ;
                                                      substr(Sumc,6,1)#"0"
              Prop += "а"
            else
              if K>=5 .or. substr(Sumc,5,1)="1" .or. substr(Sumc,6,1)="0"
                 Prop += "ов"
              end
           end
           Prop += " "
        case I=1 .and. Sum>=1000000000
           Prop += "миллиард"
           if K>=2 .and. K<=4 .and. substr(Sumc,2,1)#"1" .and. ;
                                                substr(Sumc,3,1)#"0"
              Prop += "а"
            else
              if K>=5 .or. substr(Sumc,2,1)="1" .or. substr(Sumc,3,1)="0"
                 Prop += "ов"
              end
           end
           Prop += " "
     endcase
  next
end
P := asc(Prop)
P := iif(P>=160 .and. P<=175,P-32,P-80)
Prop := stuff(Prop,1,1,chr(P))
Prop := left(Prop,len(Prop)-1)+"#"+Krb+" "+right(Sumc,2)+"#"+Kop
Bank := Adr := ""
While ( ( I := at(" ",Prop) ) # 0 )
   Adr := left(Prop,I)
   if len(Adr+Bank) < Dlina
      Bank += Adr
     else
      aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
      Bank := Adr
   end
   Prop := substr(Prop,I+1)
end
if Len(Bank+Prop) > Dlina
   aadd(Ret,Padr(StrTran(Bank,"#"," "),Dlina))
   Bank := ""
end
Bank += Prop
if len(Bank)>0
   aadd(Ret,padr(StrTran(Bank,"#"," "),Dlina))
end
Return ( Ret )
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function akt() //  печать akta
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)
Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
     nChFakt := 1
 Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
 S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop   
    end // 
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
      ////   @ Prow()+1,00 say " "
****         @ Prow()+1,00 say padc(" А К Т   No "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say "                         А К Т    "   
 ******        @ Prow()+1,00 say " ПРИЙМАННЯ ВИКОНАНИХ РОБIT за " +Left(right(Fakt->Naim,22),10) + "2014.р "
      @ Prow()+1,00 say padc("  ВИКОНАНИХ РОБIT ДО РАХУНКУ N "+alltrim(str(nChFakt,6)),nLen)
      
    @ Prow()+1,00 say " м.Первомайський                              " +Left(right(Fakt->Naim,22),10) + "2014.р "
//      @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say "Ми,що нижче пiдписалися:представник виконавця в особi начальника "
         @ Prow()+1,00 say "Первомайського комунального виробничого управлiння водопрoвiдно  "
         @ Prow()+1,00 say "каналiзацiйного господарства Котовчихiн В.В з одного боку,та представника "
         @ Prow()+1,00 say "замовника в особi_____________________________________________________ " ////+S_Ent->Naim
         @ Prow()+1,00 say " _____________________________________________________________________ "////+S_Ent->Naim2
         @ Prow()+1,00 say "з другого боку,склали дiйсний акт в тому,що згiдно  "
          @ Prow()+1,00 say "з договором N "+cDogovor+" вiд "+dtoc(dDataDog)
           @ Prow()+1,00 say "Виконавцем були наданi такi послуги :"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Од.  | Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say "Замовник претензiй по об'ему якостi та срокам надання послуг не мае"
        @ Prow()+1,00 say " Виконавець:                       Замовник: "
        @ Prow()+1,00 say " Первомайське КВУВКГ             "   +S_Ent->Naim
        @ prow()+1,00 say "                                 "   +S_Ent->Naim2
        @ Prow()+1,00 say " рахунок 26007300253580          "    +"рахунок "+S_Ent->Schet
        @ Prow()+1,00 say " Код 22714272 МФО 351823         "    +" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
        @ Prow()+1,00 say [У ТВБТ 10020/0525 фiлii Харкiвського ]+S_Ent->Bank
        @ Prow()+1,00 say [обласного управлiння АТ ,Ощадбанка'  ]
        @ Prow()+1,00 say "IПН-227142720280 "
        @ Prow()+1,00 say "СВ-28167035 "
        @ Prow()+1,00 say "адреса: м.Первомайський "
        @ Prow()+1,00 say "вул Комарова,1 "
        @ Prow()+1,00 say " "
        @ Prow()+1,00 say "    М П                    Котовчихiн В.В             М П                "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
//End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function akt4() //  печать akta
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)
Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
     nChFakt := 1
 Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
 S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop   
    end // 
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
      ////   @ Prow()+1,00 say " "
****         @ Prow()+1,00 say padc(" А К Т   No "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say "                         А К Т    "   
 ******        @ Prow()+1,00 say " ПРИЙМАННЯ ВИКОНАНИХ РОБIT за " +Left(right(Fakt->Naim,22),10) + "2013.р "
      @ Prow()+1,00 say padc("  ВИКОНАНИХ РОБIT ДО РАХУНКУ N "+alltrim(str(nChFakt,6)),nLen)
      
    @ Prow()+1,00 say " м.Первомайський                              " +Left(right(Fakt->Naim,22),10) + "2013.р "
//      @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say "Ми,що нижче пiдписалися:представник виконавця в особi начальника "
         @ Prow()+1,00 say "Первомайського комунального виробничого управлiння водопрoвiдно  "
         @ Prow()+1,00 say "каналiзацiйного господарства Котовчихiн В.В з одного боку,та представника "
         @ Prow()+1,00 say "замовника в особi_____________________________________________________ " ////+S_Ent->Naim
         @ Prow()+1,00 say " _____________________________________________________________________ "////+S_Ent->Naim2
         @ Prow()+1,00 say "з другого боку,склали дiйсний акт в тому,що згiдно  "
          @ Prow()+1,00 say "з договором N "+cDogovor+" вiд "+dtoc(dDataDog)
           @ Prow()+1,00 say "Виконавцем були наданi такi послуги :"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Од.  | Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say "Замовник претензiй по об'ему якостi та срокам надання послуг не мае"
        @ Prow()+1,00 say " Виконавець:                       Замовник: "
        @ Prow()+1,00 say " Первомайське КВУВКГ             "   +S_Ent->Naim
        @ prow()+1,00 say "                                 "   +S_Ent->Naim2
        @ Prow()+1,00 say " рахунок 26002036412001          "    +"рахунок "+S_Ent->Schet
        @ Prow()+1,00 say " Код 22714272 МФО 351005         "    +" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
        @ Prow()+1,00 say [У ПАТ ,УкрСиббанк'                   ]+S_Ent->Bank
        @ Prow()+1,00 say [                                     ]
        @ Prow()+1,00 say "IПН-227142720280 "
        @ Prow()+1,00 say "СВ-28167035 "
        @ Prow()+1,00 say "адреса: м.Первомайський "
        @ Prow()+1,00 say "вул Комарова,1 "
        @ Prow()+1,00 say " "
        @ Prow()+1,00 say "    М П                    Котовчихiн В.В             М П                "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
//End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function akt5() //  печать akta
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)
Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
     nChFakt := 1
 Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
 S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop   
    end // 
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
      ////   @ Prow()+1,00 say " "
****         @ Prow()+1,00 say padc(" А К Т   No "+alltrim(str(nChFakt,6)),nLen)
         @ Prow()+1,00 say "                         А К Т    "   
 ******        @ Prow()+1,00 say " ПРИЙМАННЯ ВИКОНАНИХ РОБIT за " +Left(right(Fakt->Naim,22),10) + "2013.р "
      @ Prow()+1,00 say padc("  ВИКОНАНИХ РОБIT ДО РАХУНКУ N "+alltrim(str(nChFakt,6)),nLen)
      
    @ Prow()+1,00 say " м.Первомайський                              " +Left(right(Fakt->Naim,22),10) + "2013.р "
//      @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say "Ми,що нижче пiдписалися:представник виконавця в особi начальника "
         @ Prow()+1,00 say "Первомайського комунального виробничого управлiння водопрoвiдно  "
         @ Prow()+1,00 say "каналiзацiйного господарства Котовчихiн В.В з одного боку,та представника "
         @ Prow()+1,00 say "замовника в особi_____________________________________________________ " ////+S_Ent->Naim
         @ Prow()+1,00 say " _____________________________________________________________________ "////+S_Ent->Naim2
         @ Prow()+1,00 say "з другого боку,склали дiйсний акт в тому,що згiдно  "
          @ Prow()+1,00 say "з договором N "+cDogovor+" вiд "+dtoc(dDataDog)
           @ Prow()+1,00 say "Виконавцем були наданi такi послуги :"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Од.  | Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say "Замовник претензiй по об'ему якостi та срокам надання послуг не мае"
        @ Prow()+1,00 say " Виконавець:                       Замовник: "
        @ Prow()+1,00 say " Первомайське КВУВКГ             "   +S_Ent->Naim
        @ prow()+1,00 say "                                 "   +S_Ent->Naim2
        @ Prow()+1,00 say " рахунок 2600511060              "    +"рахунок "+S_Ent->Schet
        @ Prow()+1,00 say " Код 22714272 МФО 351629         "    +" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
        @ Prow()+1,00 say [У ПАТ ,Мегабанк  '                   ]+S_Ent->Bank
        @ Prow()+1,00 say [                                     ]
        @ Prow()+1,00 say "IПН-227142720280 "
        @ Prow()+1,00 say "СВ-28167035 "
        @ Prow()+1,00 say "адреса: м.Первомайський "
        @ Prow()+1,00 say "вул Комарова,1 "
        @ Prow()+1,00 say " "
        @ Prow()+1,00 say "    М П                    Котовчихiн В.В             М П                "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
//////////////////////////////////////////////////////////////////////////////
Function akt1() //  печать akta
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)
Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
     nChFakt := 1
 Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
 S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop   
    end // 
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
      ////   @ Prow()+1,00 say " "
         @ Prow()+1,00 say "                         А К Т    "   
      @ Prow()+1,00 say padc("  ВИКОНАНИХ РОБIT ДО РАХУНКУ N "+alltrim(str(nChFakt,6)),nLen)
      
    @ Prow()+1,00 say " м.Первомайський                           "    +str(day(ddatach),2)+" " +Left(right(Fakt->Naim,22),10) + "2013.р "
//      @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say "Ми,що нижче пiдписалися:представник виконавця в особi начальника "
         @ Prow()+1,00 say "Первомайського комунального виробничого управлiння водопровiдно  "
         @ Prow()+1,00 say "каналiзацiйного господарства Котовчихiн В.В з одного боку та,представника "
         @ Prow()+1,00 say "замовника в особi_____________________________________________________ " ////+S_Ent->Naim
         @ Prow()+1,00 say " _____________________________________________________________________ "////+S_Ent->Naim2
         @ Prow()+1,00 say "з другого боку,склали дiйсний акт в тому,що згiдно  "
          @ Prow()+1,00 say "  договором N "+cDogovor+" вiд "+dtoc(dDataDog)
           @ Prow()+1,00 say "Виконавцем були наданi такi послуги :"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Од.  | Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say "Замовник претензiй по об'ему якостi та срокам надання послуг не мае"
        @ Prow()+1,00 say " Виконавець:                       Замовник: "
        @ Prow()+1,00 say " Первомайське КВУВКГ             "   +S_Ent->Naim
        @ prow()+1,00 say "                                 "   +S_Ent->Naim2
        @ Prow()+1,00 say " счет 26007348700006              "    +"счет "+S_Ent->Schet
        @ Prow()+1,00 say " Код 22714272 МФО 351533         "    +" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
        @ Prow()+1,00 say [У Харьковском ГРУ                ]+S_Ent->Bank
        @ Prow()+1,00 say [ПАОКБ ,ПриватБанк'               ]
        @ Prow()+1,00 say "IПН-227142720280 "
        @ Prow()+1,00 say "СВ-28167035 "
        @ Prow()+1,00 say "адреса: м.Первомайський "
        @ Prow()+1,00 say "вул Комарова,1 "
        @ Prow()+1,00 say " "
        @ Prow()+1,00 say "    М П                    Котовчихiн В.В             М П                "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
***ferase("ChFakt.txt")
//////////////////////////////////////////////////////////////////////////////
Function akt2() //  печать akta
Local ColorOld := SetColor(sset[32]+","+sset[2]+",,,"+sset[32]),;
      GetList := {}, CursorOld := SetCursor(1)
Local NaimMec := NaimMes()

S_Open_M(07,03,15,41,sset[32],sset[2])
While .t.
  Fakt->(DbGoBottom())
     nChFakt := 1
 Scroll(01,01,MaxRow()-1,MaxCol()-1)
  @ MaxRow()-1,01 say padc(" ESC - конец работы",MaxCol()-1) color sset[15]
  nEnt := 0
  nKolEkz := 2
  @ 02,02 say "N счет-фактуры" get nChFakt pict "999999" valid nChFakt > 0
  read
  if LastKey() == K_ESC ; exit ; End
  if !(lFakt := Fakt->(Dbseek(str(nChFakt,6))))
 S_Beep(1)
    S_Err({"Данные отсутствуют"})
    Loop   
    end // 
      dDataCh := Fakt->DataCh
      dData   := Fakt->Data
      nEnt    := Fakt->Ent
      @ 02,24 say "от "+dtoc(dDataCh)
      @ 03,02 say "за "+dtoc(dData)
      @ 03,16 say "в кол-ве" get nKolEkz pict "99" valid nKolEkz >= 0
      read
      if LastKey() == K_ESC ; exit ; End
      S_Ent->(DbSeek(str(nEnt,4)))
      @ 05,02 say "Код организации "+str(nEnt,4)
      @ 06,02 say S_Ent->Naim
      if nKolEkz > 0
         @ MaxRow()-1,01 say padc(" Следите за печатью",MaxCol()-1) color sset[15]
         cNaimMec := NaimMec[Month(dData)]
         BEGIN SEQUENCE
         nLen  := 73
         nSumma:= 0
         cDogovor := S_Ent->Dogovor
         dDataDog := S_Ent->DataDog
         if Empty(cDogovor) .or. Empty(dDataDog)
            S_Open_M(16,07,18,42,sset[32],sset[2])
            @ 01,01 say "Договор" get cDogovor
            @ 01,20 say "от" get dDataDog pict "@d"
            read
            if LastKey() <> K_ESC
              S_Ent->Dogovor := cDogovor
              S_Ent->DataDog := dDataDog
            End
            S_wCloseSl(S_RanDom()%22+1)
         End
         set(20,"PRINT")
         set(24,"ChFakt.txt")
      ////   @ Prow()+1,00 say " "
         @ Prow()+1,00 say "                         А К Т    "   
      @ Prow()+1,00 say padc("  ВИКОНАНИХ РОБIT ДО РАХУНКУ N "+alltrim(str(nChFakt,6)),nLen)
    @ Prow()+1,00 say " м.Первомайський                              " +Left(right(Fakt->Naim,22),10) + "2013.р "      
////    @ Prow()+1,00 say " м.Первомайський                           "    +str(day(ddatach),2)+" " +Left(right(Fakt->Naim,22),10) + "2013.р "
//      @ Prow()+1,00 say padc("от "+dtoc(dDataCh),nLen)
         @ Prow()+1,00 say "Ми,що нижче пiдписалися:представник виконавця в особi начальника "
         @ Prow()+1,00 say "Первомайського комунального виробничого управлiння водопровiдно  "
         @ Prow()+1,00 say "каналiзацiйного господарства Котончихiн В.В з одного боку та,представника "
         @ Prow()+1,00 say "замовника в особi_____________________________________________________ " ////+S_Ent->Naim
         @ Prow()+1,00 say " _____________________________________________________________________ "////+S_Ent->Naim2
         @ Prow()+1,00 say "з другого боку,склали дiйсний акт в тому,що згiдно  "
          @ Prow()+1,00 say "  договором N "+cDogovor+" вiд "+dtoc(dDataDog)
           @ Prow()+1,00 say "Виконавцем були наданi такi послуги :"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         @ Prow()+1,00 say "Од.  | Кiлькiсть  |    Цiна     | Найменування           |     Сума     |"
         @ prow()+1,00 say "-------------------------------------------------------------------------"
         While Fakt->NomChF == nChFakt .and. !Fakt->(eof())
           @ prow()+1,00 say Left(Fakt->EdIzm,5)+" "+str(Fakt->Kolvo,12)+" "+str(Fakt->Cena,9,6)+" "+;
             Left(Fakt->Naim,22)+" "+;
             str(Fakt->Summa-Fakt->Ndc-Fakt->Fec-Fakt->SumBank,14,2)
           if !Empty(Fakt->Ndc)
             @ prow()+1,00 say space(33)+padr("ПДВ ",24)+" "+str(Fakt->Ndc,14,2)
           End
           if !Empty(Fakt->Fec)
             @ prow()+1,00 say space(33)+padr("ПРС ",24)+" "+str(Fakt->Fec,14,2)
           End
           if !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Услуги банка ",24)+" "+str(Fakt->SumBank,14,2)
           End
           if !Empty(Fakt->Ndc) .or. !Empty(Fakt->Fec) .or. !Empty(Fakt->SumBank)
             @ prow()+1,00 say space(33)+padr("Всього ",24)+" "+;
               str(Fakt->Summa,14,2)
           End
           nSumma += Fakt->Summa
           Fakt->(DbSkip(1))
         End
         @ prow()+1,00 say space(33)+padr("Разом за мiсяць",24)+" "+str(nSumma,14,2)
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         aProp := PropisSum_(nSumma,59)
         @ Prow()+1,00 say "Сума до сплати: "+aProp[1]
         for i := 2 to len(aProp)
           @ Prow()+1,00 say "                "+aProp[i]
         Next
         @ Prow()+1,00 say "Замовник претензiй по об'ему якостi та срокам надання послуг не мае"
        @ Prow()+1,00 say " Виконавець:                       Замовник: "
        @ Prow()+1,00 say " Первомайське КВУВКГ             "   +S_Ent->Naim
        @ prow()+1,00 say "                                 "   +S_Ent->Naim2
        @ Prow()+1,00 say " счет 26007348700006              "    +"счет "+S_Ent->Schet
        @ Prow()+1,00 say " Код 22714272 МФО 351533         "    +" Код "+S_Ent->Okpo+" МФО "+S_Ent->Mfo
        @ Prow()+1,00 say [У Харьковском ГРУ                ]+S_Ent->Bank
        @ Prow()+1,00 say [ПАОКБ ,ПриватБанк'               ]
        @ Prow()+1,00 say "IПН-227142720280 "
        @ Prow()+1,00 say "СВ-28167035 "
        @ Prow()+1,00 say "адреса: м.Первомайський "
        @ Prow()+1,00 say "вул Комарова,1 "
        @ Prow()+1,00 say " "
        @ Prow()+1,00 say "    М П                    Котовчихiн В.В             М П                "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say " "
         @ Prow()+1,00 say repl("= ",nLen/2)
         @ prow()+1,00 say ""
         set(24,"")
         set(20,"SCREEN")
         for i := 1 to nKolEkz
            if S_TPRN("ChFakt.txt",,1) < 0 ; break ; End
         Next
         END SEQUENCE
      End
   End
//End
***ferase("ChFakt.txt")
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
return ( Nil )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////