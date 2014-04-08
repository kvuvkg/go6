#Define COLOR_NSI sset[51]+","+sset[57]+",,,"+sset[51]
#Define COLOR_BAZA sset[32]+","+sset[2]+",,,"+sset[32]
#include "Inkey.ch"
/////////////////////////////////////////////////////////////////////
Local oMenMain, Omen, data
Set(4,"dd.mm.yyyy")
Set(26,.f.)       
Set(32,.f.)       
Set(11,.t.)  
Set(9,.f.)   
SetBlink(.t.)
sset[102] := "ПУВКХ"
sset[100] := date()
S_SetDelay(15) 
SetColor(sset[86] := "n/w")
S_Cls("░")
@ 00,00 say space(80)
@ 23,00 say space(80)
@ 00,38 say sset[102]
VvodData()
@ 00,64 say "Время:"
S_ShowTime(0,71,.F.,"n/w")
oMen := S_GetDrive("Go6.Exe")+s_GetPath("Go6.exe")+"Baza"
if !File(oMen+"\nul")  ;  S_MakeDir(oMen)  ;  end
sset[112] := {oMen+"\",Nil}
oMen := S_GetDrive("Go6.Exe")+s_GetPath("Go6.exe")+"Work"
if !File(oMen+"\nul")  ;  S_MakeDir(oMen)  ;  end
sset[112][2] := oMen+"\"
if !OpenBaza() ; Return ( Nil ) ; End
if ostatok->(DbSeek(str(0,4)))
  Data := Alltrim(str(Ostatok->Summa,10))
  Data := ctod(Substr(Data,7,2)+"."+Substr(Data,5,2)+"."+Substr(Data,1,4))
  @ 23,00 say padc("Расчет за "+S_cMonth(data)+" месяц "+str(year(data),4)+" г.",80) color sset[86]
End
oMen := MainMenu()
S_Nil_Key()
SetCursor(0)
S_SetKey(K_CTRL_F9, { |x| x := Set(4,"dd.mm.yy"),;
                          S_Calend(3,50),;
                          Set(4,x) } )
S_SetKey(K_CTRL_F10, { | |S_Calc() } )
BEGIN SEQUENCE
omen:refAll()
/* Сделать копию головного обьекта                  o()  */ 
oMenMain := oMen
While .T.
  if !S_IswShad()  ; S_wSetShad("w/n") ; end
  Key := m_inkey(0)
  do Case
     case oMen == oMenMain .and. key == K_ESC
       S_Beep()
       if S_Err({16,28,"Закончить работу?","% Нет ;  Да ; "}) == 2
           oMen:close()  ;  exit
        else
           loop
        end
  End
  oMen:work(key,@oMen)
End
END SEQUENCE
S_ShowTime() 
DbCloseAll()
return ( Nil )

*================================================================ MainMenu
Static Function MainMenu(data)
    Local oPrompt,omenu0,omenu1,omenu2,omenu3,i, omenu22, omenu23, omen4

    // МЕНЮ 0    >>>>>>>>>>>>>>> ГЛАВНОЕ <<<<<<<<<<<<<<<
    omen0:=oMenuNew( 2, 2, .F.     ,;
                   {"  Ввод данных   ",;
                    "  Ведомости  ",;
                    "  Н С И   ",;
                    "  Сервис  ",;
                    "  Выxод   "})
    oprompt1:=oPromptNew(24,0,80)
    oprompt1:Color := {"n/w","n/w"}
    omen0:Prompt:=oPrompt1
    omen0:addPrompt(1,"Ввод месяцной информации в базу данных")
    omen0:addPrompt(2,"Формирование и печать ведомостей")
    omen0:addPrompt(3,"Ведение номативно справочной информации задачи")
    omen0:addPrompt(4,"Закрытие месяца  Паковка БД  Копия БД  Калькулятор  Календарь")
    omen0:addPrompt(5,"Выход из программы")
    omen0:block(5,{||Mquit()})
    i := 0
    // МЕНЮ 1    >>>>>>>>>>>>>>> Ввод Данных <<<<<<<<<<<<<<<
    omen1:=oMenuNew()

    omen1:add("Суммы по счетам ПРИХОД")
    omen1:addPrompt(++i,"Ведение сумм для формирования ведомости РАСЧЕТ С ПОСТАВЩИКАМИВ по ПРИХОДУ")
    omen1:block(i,{||VedPrixod()})

    omen1:add("Суммы по счетам РАСХОД")
    omen1:addPrompt(++i,"Ведение сумм для формирования ведомости РАСЧЕТ С ПОСТАВЩИКАМИВ по РАСХОДУ")
    omen1:block(i,{||VedRasxod()})

    omen1:add("Остатки на начало месяца")
    omen1:addPrompt(++i,"Ведение остатков по ведомости РАСЧЕТ С ПОСТАВЩИКАМИ")
    omen1:block(i,{||VedOst()})

    omen1:add("Платежное поречение")
    omen1:addPrompt(++i,"Формирование и печать платежного поручения")
    omen1:block(i,{||PlPor()})

//    omen1:add("Платежное поречение5")
//    omen1:addPrompt(++i,"Формирование и печать платежного поручения5")
//    omen1:block(i,{||PlPor1()})

//    omen1:add("Платежное поречение6")
//    omen1:addPrompt(++i,"Формирование и печать платежного поручения6")
//    omen1:block(i,{||PlPor2()})

//    omen1:add("Платежное поречение7")
//    omen1:addPrompt(++i,"Формирование и печать платежного поручения7")
//    omen1:block(i,{||PlPor3()})

//    omen1:add("Платежное поречение2856  ")
//    omen1:addPrompt(++i,"Формир и печать платежного поруче 2856")
//    omen1:block(i,{||PlPor28()})

//    omen1:add("Платежное поречение28562  ")
//    omen1:addPrompt(++i,"Формир и печать платежного поруче 28562")
//    omen1:block(i,{||PlPor282()})

//    omen1:add("Платежное поречение ykrcib  ")
//    omen1:addPrompt(++i,"Формир и печать платежного поруче ykrcib2")
//    omen1:block(i,{||PlPory()})

    omen1:add("Налоговая накладная")
    omen1:addPrompt(++i,"Формирование и печать налоговой накладной")
    omen1:block(i,{||PrnNalogG()})

    omen1:add("Счет-фактура")
    omen1:addPrompt(++i,"Формирование и печать счет-фактуры")
    omen1:block(i,{||ChFaktU()})

    omen1:add("Счет-фактура6")
    omen1:addPrompt(++i,"Формирование и печать счет-фактуры6")
    omen1:block(i,{||ChFakt1()})

    omen1:add("Счет-фактура7")
    omen1:addPrompt(++i,"Формирование и печать счет-фактуры7")
    omen1:block(i,{||ChFakt2()})

    omen1:add("Счет-фактураY")
    omen1:addPrompt(++i,"Формирование и печать счет-фактуры7")
    omen1:block(i,{||ChFakt4()})

    omen1:add("Счет-фактураM")
    omen1:addPrompt(++i,"Формирование и печать счет-фактурыM")
    omen1:block(i,{||ChFakt5()})


    omen1:add("Налоговая накладная на счет-фактуру")
    omen1:addPrompt(++i,"Формирование и печать налоговой накладной")
    omen1:block(i,{||PrnNalCh()})

    omen1:add("Налоговая накладная на счет-фактуру Ykp ")
    omen1:addPrompt(++i,"Формирование и печать налоговой накладной Ykpai")
    omen1:block(i,{||PrnNalChYk()})

    omen1:add("печать акт")
    omen1:addPrompt(++i," печать ак")
    omen1:block(i,{||akt()})

    omen1:add("печать актY")
    omen1:addPrompt(++i," печать акY")

    omen1:block(i,{||akt4()})
    omen1:add("печать актM")
    omen1:addPrompt(++i," печать акM")
    omen1:block(i,{||akt5()})

    omen1:add("печать акт1")
    omen1:addPrompt(++i," печать ак")
    omen1:block(i,{||akt1()})
     omen1:add("печать акт2")

    omen1:addPrompt(++i," печать ак")
    omen1:block(i,{||akt2()})
    omen1:Prompt:=oPrompt1
    omen0:addSub(1,omen1)

    i := 0
    // МЕНЮ 2    >>>>>>>>>>>>>>> Формирование и печать ведомостей <<<<<<<<<<<<<<<
    omen2:=oMenuNew()

    omen2:add("Ведомость по приходу")
    omen2:addPrompt(++i,"Формирование и печать ведомости по приходу ")
    omen2:block(i,{||VedomPrix()})

    omen2:add("Формирование ведомости")
    omen2:addPrompt(++i,"Формирование и печать ведомости")
    omen2:block(i,{||VedRas()})

    omen2:add("Печать ведомости")
    omen2:addPrompt(++i,"Просмотр и печать ведомости")
    omen2:block(i,{||PrnVedRas()})

    omen2:add("Годовая ведомость по приходу")
    omen2:addPrompt(++i,"Просмотр и печать годовой ведомости по приходу")
    omen2:block(i,{||VedomGod()})

    omen2:add("Ведомость остатков на конец месяца")
    omen2:addPrompt(++i,"Формирование и печать ведомости остатков на конец месяца")
    omen2:block(i,{||VedDolg()})

    omen2:add("Ведомость остатков на начало месяца")
    omen2:addPrompt(++i,"Формирование и печать ведомости остатков на начало месяца")
    omen2:block(i,{||VedOstN()})

    omen2:add("Книга учета продажи")
    omen2:addPrompt(++i,"Формирование и печать книги учета продажи")
    omen2:block(i,{||PrnBook()})

    omen2:add("реестр счетов")
    omen2:addPrompt(++i,"Формирование и печать реестра счетов ")
    omen2:block(i,{||VedomPrix1()})

    omen2:add("реестр счетов налог")
    omen2:addPrompt(++i,"Формирование и печать реестра счетов ")
    omen2:block(i,{||VedomPrix2()})

    omen2:Prompt:=oPrompt1
    omen0:addSub(2,omen2)
            
    i := 0
    // МЕНЮ 3    >>>>>>>>>>>>>>> Н С И <<<<<<<<<<<<<<<
    omen3:=oMenuNew()

    omen3:add("Справочник групп организаций")
    omen3:addPrompt(++i,"Ведение справочника групп организаций")
    omen3:block(i,{||VedGr()})

    omen3:add("Справочник организаций")
    omen3:addPrompt(++i,"Ведение справочника организаций")
    omen3:block(i,{||VedEnt()})

    omen3:add("Справочник счетов")
    omen3:addPrompt(++i,"Ведение справочника счетов")
    omen3:block(i,{||VedChet()})

    omen3:add("Ценник")
    omen3:addPrompt(++i,"Ведение ценника")
    omen3:block(i,{||VedPrice()})

    omen3:add("Справочник банков предприятия")
    omen3:addPrompt(++i,"Ведение справочника банков предприятия")
    omen3:block(i,{||VedBank()})
   
    omen3:Prompt:=oPrompt1
    omen0:addSub(3,omen3)

    i := 0
    // МЕНЮ 4    >>>>>>>>>>>>>>> СЕРВИС <<<<<<<<<<<<<<<
    omen4:=oMenuNew()
    omen4:add("Закрытие месяца ")
    omen4:addPrompt(++i,"Выполнение процедуры по переходу на следующий месяц")
    omen4:block(i,{||CloseMes()})

    omen4:add("Загрузка месяца ")
    omen4:addPrompt(++i,"Загрузка месяца в базу из архива, как текущего! Очищает текущие Prixod, Rashod!")
    omen4:block(i,{||LoadMes()})

    omen4:add("Копия БД на дискету ")
    omen4:addPrompt(++i,"создание страховой копии БД да дискете")
    omen4:block(i,{||CopyDb()})

    omen4:add("Индексирование и паковка БД ")
    omen4:addPrompt(++i,"Индексирование и сжатие базы данных")
    omen4:block(i,{||DbPack()})

    omen4:add("Калькулятор")
    omen4:addPrompt(++i,"Калькулятор")
    omen4:block(i,{ | |S_Calc() })

    omen4:add("Календарь")
    omen4:addPrompt(++i,"Календарь")
    omen4:block(i, { |x| x := Set(4,"dd.mm.yy"),;
                              S_Calend(3,50),;
                              Set(4,x) } )
                              
    omen4:add("Смена даты ")
    omen4:addPrompt(++i,"Смена даты")
    omen4:block(i,{||VvodData()})

    omen4:add("Подготовка файла экспорта в 1С")
    omen4:addPrompt(++i,"Формирование файла для экспорта в 1С")
    omen4:block(i,{||Prepare1Cfile()})

    omen4:Prompt:=oPrompt1
    omen0:addSub(4,omen4)

return ( oMen0 )
    *==================================================================== MQuit
Static Function Mquit()
   __KeyBoard(Chr(K_ESC)+Chr(K_ESC))
Return ( Nil )
////////////////////////////////////////////////////////////////////////////
Static function OpenBaza()
    Local lRet := .f., cDir := sset[112][1], data
    Private i
    S_Sys({" Минутку "," Открываю базу данных "," Немного подождите "})
    BEGIN SEQUENCE
        //       Справочник групп организаций
        if !File(cDir+"S_GR.DBF")
           fErase(cDir+"S_GR.NTX")
           DbCreate(cDir+"S_GR",{ {"Tip", "N",01,00},;   // код группы
                                  {"Naim","C",25,00}})   // наименование
        end
        use (cDir+"S_GR") new
        if !File(cDir+"S_GR.NTX")
           Index on str(Tip,1) to (cdir+"S_GR")
        End
        Set Index to (cDir+"S_GR")
        Set Index to (cDir+"S_GR")
        //       Справочник банков предприятия
        if !File(cDir+"S_BANK.DBF")
           fErase(cDir+"S_BANK.NTX")
           DbCreate(cDir+"S_BANK",{ {"ID", "N",03,00},;     // ID банка
                                    {"MFO",  "C",09,00},;   // МФО
                                    {"SCHET","C",14,00},;   // счет
                                    {"NAIM","C",35,00}})    // наименование
        end
        use (cDir+"S_BANK") new
        if !File(cDir+"S_BANK.NTX")
           Index on str(ID,3) to (cdir+"S_BANK")
        End
        Set Index to (cDir+"S_BANK")
        Set Index to (cDir+"S_BANK")
        //       Справочник организаций
        if !File(cDir+"S_ENT.DBF")
           fErase(cDir+"S_ENT.NTX")
           DbCreate(cDir+"S_ENT",{ {"Ent",  "N",04,00},;   // код организации
                                   {"Naim", "C",35,00},;   // наименование
                                   {"Adres","C",35,00},;   // Адрес
                                   {"Okpo", "C",11,00},;   // код ОКПО
                                   {"Mfo",  "C",09,00},;   // МФО
                                   {"Schet","C",14,00},;   // счет
                                   {"Tip",  "N",01,00},;   // Пит
                                   {"KodNalog","C",12,00},;   // 
                                   {"KodSvid", "C",08,00},;   // 
                                   {"Dogovor", "C",10,00},;   // 
                                   {"DataDog", "D",08,00},;   // 
                                   {"Bank", "C",35,00} })  // наименование банка
        end
        use (cDir+"S_ENT") new
        if !File(cDir+"S_ENT.NTX")
           Index on str(Ent,4) to (cdir+"S_ENT")
        End
        Set Index to (cDir+"S_ENT")
        Set Index to (cDir+"S_ENT")
        //  Справочник счетов
        if !File(cDir+"S_CHET.DBF")
           fErase(cDir+"S_CHET.NTX")
           DbCreate(cDir+"S_CHET",{ {"Chet",  "N",04,00},;   // код счета
                                    {"Naim",  "C",30,00}})   // наименование
        end
        use (cDir+"S_CHET") new
        if !File(cDir+"S_CHET.NTX")
           Index on str(Chet,4,0) to (cdir+"S_CHET")
        End
        Set Index to (cDir+"S_CHET")
        Set Index to (cDir+"S_CHET")
        //  Ценник
        if !File(cDir+"S_PRICE.DBF")
           fErase(cDir+"S_PRICE.NTX")
           DbCreate(cDir+"S_PRICE",{ {"Chet",  "N",04,00},;   // код счета
                                     {"Tip",   "N",01,00},;   // Тип
                                     {"Cena","N",12,06},;   // Цена
                                     {"Ndc", "N",12,06},;   // % Ндс
                                     {"Fec", "N",12,06} })  // % ФЕС
        end
        use (cDir+"S_PRICE") new
        if !File(cDir+"S_PRICE.NTX")
           Index on str(Chet,4,0)+str(Tip,1) to (cdir+"S_PRICE")
        End
        Set Index to (cDir+"S_PRICE")
        Set Index to (cDir+"S_PRICE")
        //  Остатки по ведомости РАСЧЕТ С ПОТРЕБИТЕЛЯМИ
        if !File(cDir+"OSTATOK.DBF")
           fErase(cDir+"OSTATOK.NTX")
           DbCreate(cDir+"OSTATOK",{ {"Ent",  "N",04,00},;   // код организации
                                     {"Summa","N",13,02} })  // сумма остатка
        end
        use (cDir+"OSTATOK") new
        if !File(cDir+"OSTATOK.NTX")
           Index on str(Ent,4) to (cdir+"OSTATOK")
        End
        Set Index to (cDir+"OSTATOK")
        Set Index to (cDir+"OSTATOK")
        if !ostatok->(DbSeek(str(0,4)))
           i := ctod("")
           S_Get({07,02,"Укажите дату начала эксплуатации задачи ","i","@d"})
           if !empty(i)
              Ostatok->(DbAppend())
              Ostatok->Ent := 0   ;  Ostatok->Summa := val(dtos(S_Bom(i)))
           End
        End
        //  база ведомости РАСЧЕТ С ПОТРЕБИТЕЛЯМИ по ПРИХОДУ
        if !File(cDir+"PRIXOD.DBF")
           fErase(cDir+"PRIXOD.NTX")
           DbCreate(cDir+"PRIXOD",{ {"Ent",  "N",04,00},;   // код организации
                                    {"Chet", "N",04,00},;   // счет
                                    {"Npp",  "N",05,00},;   // N счета
                                    {"Kolvo","N",10,00},;   // Количество
                                    {"Cena", "N",12,06},;   // Цена
                                    {"Sum",  "N",13,02},;   // Сумма без Ндс
                                    {"Ndc",  "N",13,02},;   // Ндс
                                    {"Fec",  "N",13,02},;   // ФЕС
                                    {"SumBank","N",13,02},; // Сумма по банку
                                    {"Summa","N",13,02} })  // сумма с Ндс
        end
        use (cDir+"PRIXOD") new
        if !File(cDir+"PRIXOD.NTX")
           Index on str(Ent,4)+str(Chet,4,0) to (cdir+"PRIXOD")
        End
        Set Index to (cDir+"PRIXOD")
        Set Index to (cDir+"PRIXOD")
        //  база ведомости РАСЧЕТ С ПОТРЕБИТЕЛЯМИ по РАСХОДУ
        if !File(cDir+"RASXOD.DBF")
           fErase(cDir+"RASXOD.NTX")
           DbCreate(cDir+"RASXOD",{ {"Ent",  "N",04,00},;   // код организации
                                    {"Chet", "N",04,00},;   // счет
                                    {"Summa","N",13,02} })  // сумма 
        end
        use (cDir+"RASXOD") new
        if !File(cDir+"RASXXOD.NTX")
           Index on str(Ent,4)+str(Chet,4,0) to (cdir+"RASXOD")
        End
        Set Index to (cDir+"RASXOD")
        Set Index to (cDir+"RASXOD")
        //  база ПЛАТЕЖНЫХ ПОРУЧЕНИЙ
        if !File(cDir+"PLPOR.DBF")
           fErase(cDir+"PLPOR.NTX")
           DbCreate(cDir+"PLPOR",{ {"PlPor",  "N",06,00},;   // Номер
                                   {"GodPor", "N",04,00},;   // Год
                                   {"DataPor","D",08,00},;   // Дата
                                   {"BankPor","N",03,00},;   // ID банка
                                   {"EntPor", "N",04,00},;   // Код организации
                                   {"SumPor", "N",15,02},;   // Сумма
                                   {"Text1",  "C",45,00},;   // Текст
                                   {"Text2",  "C",45,00},;   // Текст
                                   {"Ndc",    "N",15,02} })  // сумма НДС
        end
        use (cDir+"PlPor") new
        if !File(cDir+"PlPor.NTX")
           Index on str(GodPor,4)+str(PlPor,6) to (cdir+"PLPOR")
        End
        Set Index to (cDir+"PLPOR")
        Set Index to (cDir+"PLPOR")
        //
        //  Справочник способов
        if !File(cDir+"Sposob.DBF")
           fErase(cDir+"Sposob.NTX")
           DbCreate(cDir+"Sposob",{ {"Sposob",  "N",02,00},;   // код 
                                    {"NaimSpos","C",25,00} })  // наименование
        end
        use (cDir+"Sposob") new
        if !File(cDir+"Sposob.NTX")
           Index on str(Sposob,2) to (cdir+"Sposob")
        End
        Set Index to (cDir+"Sposob")
        Set Index to (cDir+"Sposob")
        //  база накладной
        if !File(cDir+"NalNakl.DBF")
           fErase(cDir+"NalNakl.NTX")
           DbCreate(cDir+"NalNakl",{ {"God",    "N",04,00},;   // год
                                     {"NomNakl","N",10,00},;   // номер накладной
                                     {"Fio",    "C",30,00} })  // 
        end
        use (cDir+"NalNakl") new
        if !File(cDir+"NalNakl.NTX")
           Index on str(God,4)+str(NomNakl,10) to (cdir+"NalNakl")
        End
        Set Index to (cDir+"NalNakl")
        Set Index to (cDir+"NalNakl")
        //  база Сфет фактуры
        if !File(cDir+"Fakt.DBF")
           fErase(cDir+"FaktN.NTX")
           fErase(cDir+"FaktD.NTX")
           DbCreate(cDir+"Fakt",{ {"NomChF", "N",06,00},;   // номер
                                  {"Data",   "D",08,00},;   // Дата накладной
                                  {"DataCh", "D",08,00},;   // Дата СФ
                                  {"Bank",   "N",03,00},;   // ID банка
                                  {"Ent",    "N",04,00},;   // организация
                                  {"EdIzm",  "C",07,00},;   // ед изм
                                  {"Kolvo",  "N",10,00},;   // кол-во
                                  {"Cena",   "N",12,06},;   // Цена
                                  {"Naim",   "C",30,00},;   // наименование
                                  {"Summa",  "N",15,02},;   // сумма
                                  {"Ndc",    "N",15,02},;   // Ндс
                                  {"Chet",   "N",04,00},;   // счет
                                  {"Fec",    "N",13,02},;   // ФЕС
                                  {"SumBank","N",13,02},;   // Сумма по банку
                                  {"Sposob", "C",25,00} })  // способ
        end
        use (cDir+"Fakt") new
        if !File(cDir+"FaktN.NTX")
           Index on str(Fakt->NomChF,6) to (cdir+"FaktN")
        End
        if !File(cDir+"FaktD.NTX")
           Index on dtos(Fakt->Data)+str(Fakt->NomChF,6) to (cdir+"FaktD")
        End
        Set Index to (cDir+"FaktN"),(cDir+"FaktD")
        Set Index to (cDir+"FaktN"),(cDir+"FaktD")
        //
        DbCommitAll()
        lRet := .t.
    END SEQUENCE
    S_Beep(1)
    S_Sys()
Return ( lRet )
////////////////////////////////////////////////////////////////////////
Static Function VedOst()
    Local tb, ColorOld := SetColor(COLOR_BAZA),;
          SelectOld := Select(), nKey, nRow, SursorOld := SetCursor(0),;
          nEnt, nSumma, GetList := {}, nDelete := 0, nRegim := 1,;
          aRegim := {"+"," "}

    DbSelectArea("OSTATOK")
    Set relation to str(Ostatok->Ent,4) into S_ENT
    S_Open_M(02,05,22,55,,sset[2])
    @ 01,01 say "Код  Наименование организации        Остаток"
    @ 02,01 say Repl([─],MaxCol()-1)
    @ MaxRow()-2,01 say Repl([─],MaxCol()-1)
    @ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск 9режим",MaxCol()-1) color sset[5]
    tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
    tb:AddColumn(TbColumnNew("" ,{|| str(Ostatok->Ent,4)+" "+left(S_Ent->Naim,30)+" "+;
                                     str(Ostatok->Summa,13,2) } ))
    Ostatok->(DbGoTop())
    @ 00,(MaxCol()-1)/2 say "["+aRegim[nRegim]+"]" color sset[2]
    While ( .t. )
       nKey := 0
       While ( !tb:Stabilize() )
         if ( nKey := m_inkey() ) != 0 ; exit ; end
       end
       nRow := Row()
       if nKey == 0 ; nKey := m_inkey(0)  ; end
       if nKey == K_ESC ; exit ; end
       if tb:Stable
        do case
           Case nKey == K_F9  // Смена Режима
                nRegim := if(nRegim==1,2,1) 
                @ 00,(MaxCol()-1)/2 say "["+aRegim[nRegim]+"]" color sset[2]
           Case nKey == K_F2  // Печать
                nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
                @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
                nRow := Ostatok->(Recno())
                Ostatok->(DbGoTop())
                nSumma := Ostatok->Summa
                Ostatok->(DbSkip(1))
                Set Device to Print
                @ prow()+1,01 say padc("Распечатка",51)
                @ prow()+1,01 say padc("остатков Ведомости расчета с потребителями",51)
                @ prow()+1,01 say padc(" на "+str(nSumma,9),51)
                @ prow()+1,01 say repl("-",51)
                @ prow()+1,01 say "Код  Наименование организации        Остаток"
                @ prow()+1,01 say repl("-",51)
                While ( !Ostatok->(eof()) )
                  @ prow()+1,01 say str(Ostatok->Ent,4)+" "+S_Ent->Naim+" "+;
                                    str(Ostatok->Summa,13,2)
                  Ostatok->(DbSkip(1))
                End
                @ prow()+1,01 say repl("=",51)
                @ prow()+1,01 say ""
                Set Device to Screen
                RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
                Ostatok->(DbGoto(nRow))
           Case nKey == K_F6  // Поиск по ключу
                SetCursor(1)
                nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
                @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
                nRow := 0
                @ MaxRow()-1,03 say "Укажите код" get nRow pict "9999" valid nRow > 0
                read
                if LastKey() <> K_ESC
                   Ostatok->(DbSeek(str(nRow,4),.t.))
                   if Ostatok->(eof())
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
                      DbSelectArea("Ostatok")
                   else
                      nSumma := S_Ent->Ent
                      DbSelectArea("Ostatok")
                      if !Ostatok->(DbSeek(str(nSumma)))
                         S_Err({" Данных не обнаружено "})
                         S_Beep(1)  ;  tb:GoBottom()
                      End
                   end
                end
                SetCursor(0)
                RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
                FreshOrder(tb)
           case nKey == K_F3  // Удаление
               if Ostatok->(Recno()) # 0 .and. Ostatok->Ent > 0 .and. ;
                  S_Err({S_wRow()+1,S_wCol()+2,,;
                 "Вы действительно","желаите удалить запись",;
                 "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 
                     Ostatok->(DbDelete())   ;   nDelete++
                     Ostatok->(DbSkip(1))
                     if Ostatok->(eof()) ; Ostatok->(DbGoBottom()) ; end
               end
               FreshOrder(tb)
           case nKey == K_F4  // Регистрация
               tb:DeHilite()
               nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
               @ MaxRow()-1,01 say padc("Вставляйте записи",MaxCol()-1) color sset[5]
               While ( .t. )
                 Scroll(03,01,MaxRow()-3,MaxCol()-1,-1)
                 nEnt := 0
                 @ 03,01 get nEnt Pict "9999" valid VedEnt(@nEnt,03,06)
                 read
                 if LastKey() == K_ESC ; Exit ; End
                 if Ostatok->(DbSeek(str(nEnt,4)))
                    @ 03,06 say padc(" Запись имеется Внимательней",30) Color sset[5]
                 else
                    nSumma := 0
                    @ 03,37 get nSumma pict "9999999999.99"
                   read
                   if LastKey() <> K_ESC
                       Ostatok->(DbAppend())
                       Ostatok->Ent := nEnt  ;  Ostatok->Summa := nSumma
                   End
                End
               End
               SetCursor(0)
               RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
               FreshOrder(tb)
           case nKey == K_F5  .and. Ostatok->Ent > 0  // Корретировка
               tb:DeHilite()
               nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
               SetCursor(1)
               @ MaxRow()-1,01 say padc("Корректируйте остаток",MaxCol()-1) color sset[5]
               nSumma := if(nRegim==1,0,Ostatok->Summa)
               @ nRow,37 get nSumma pict "9999999999.99"
               read
               if LastKey() <> K_ESC
                  Ostatok->Summa := if(nRegim==1,Ostatok->Summa+nSumma,nSumma)
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
/////////////////////////////////////////////////////////////////////////////
Static Function DbPack()
    Local ColorOld := SetColor(COLOR_BAZA),;
          aFile := {"Prixod","Ostatok","S_Ent","S_Chet","Rasxod","S_GR"}, i
    S_Open_M(10,03,20,30,,sset[2])
    for i := 1 to len(aFile)
       Dbselectarea(aFile[i])
       @ MaxRow()-1,02 say aFile[i]
                                   Pack                
       @ MaxRow()-1,10 say "Pack"
                                  Reindex
       @ MaxRow()-1,15 say "Reindex"
       Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
    next
    My_Char()
    @ MaxRow()-1,5 say "Нажмите клавишу..."
    Inkey(0)
    S_wCloseSl(S_RanDom()%22+1)
    SetColor(ColorOld)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static function CopyDb()
    Local ColorOld := SetColor(COLOR_BAZA),;
          aFile := {"Prixod","Ostatok","S_Ent","S_Chet","Rasxod","S_Gr"}, i
    S_Err({"Вставте дискету в дисковод и нажмите клавишу"})
    S_Open_M(10,03,20,30,,sset[2])
    @ MaxRow()-1,02 say "Очищаю дискету"
    S_FileDel("a:\*.*")
    Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
    for i := 1 to Len(aFile)
        Dbselectarea(aFile[i])
        @ MaxRow()-1,02 say aFile[i]+" ---> копирую"
        copy to ("a:\"+aFile[i])
        @ MaxRow()-1,23 say "Ok!"
        Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
    next
    My_Char()
    @ MaxRow()-1,5 say "Нажмите клавишу..."
    Inkey(0)
    S_wCloseSl(S_RanDom()%22+1)
    SetColor(ColorOld)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
static Function VvodData()      //  Ввод даты в АРМ
    Local dData := date(),;
          ColorOld := SetColor(sset[32]+","+sset[2]),;
          GetList := {}, WindowOld := S_wSelect()
    S_Open_M(12,38,14,65,sset[32],sset[2])
    @ 01,01 say "Укажите дату" get dData Pict "@d" valid !empty(dData)
    read
    S_wCloseSl(S_RanDom()%22+1)
    SetColor("n/w")
    S_wSelect(0)
    @ 00,01 say padc( {"Воскресенье","Понедельник","Вторник","Среда","Четверг",;
              "Пятница","Суббота"}[dow(ddata)]+" "+str(day(ddata),2)+" "+;
              S_cMonth(dData,.t.)+" "+str(year(ddata),4)+" года",35)
    S_wSelect(WindowOld)
    sset[100] := dData
    SetColor(ColorOld)
return ( Nil )
//////////////////////////////////////////////////////////////////////////////
Function M_RLock( nSeconds,Alias )
    MemVar Sset
    local lForever
    nSeconds := iif(nSeconds==Nil,20,nSeconds)
    Alias := iif(Alias==Nil,Alias(),Alias)
    lForever := (nSeconds == 0)
    if (Alias)->(Rlock()) ;  return (.t.) ; end
    S_Sys({"Попытка блокировки записи",;
           "Ждите запись файла "+alias()+" блокирована",;
           "Для отказа от запроса нажмите ESC"})
    BEGIN SEQUENCE
        While ( lForever .or. nSeconds > 0 )
           if inkey(.5) == K_ESC
             S_Sys()
             S_Err({"@ВНИМАНИЕ !!!","Прерывание операции","По Вашей инициативе"})
             lret := .f.
             break
           end
           nSeconds -= 0.5
           if (Alias)->(Rlock())
              S_Sys() ; lRet := .t.
              break
           end
        end
        S_Sys()
        S_Err({"@ВНИМАНИЕ !!!","Время ожидания истекло","Прерывание операции"})
        lRet := .f.
    END SEQUENCE
return ( lRet )
///////////////////////////////////////////////////////////////////////
func M_Append(nWaitSeconds,Alias)
    MemVar Sset
    local lForever, lRet := .t.
    nWaitSeconds := iif(nWaitSeconds==Nil,20,nWaitSeconds)
    Alias := iif(Alias==Nil,Alias(),Alias)
    lForever := (nWaitSeconds == 0)
    BEGIN SEQUENCE
       (Alias)->(DbAppend())
       if !Neterr()  ; break ; end
       S_Sys({"База данных недоступна для работы",;
              "с ней и/или внесения в нее изменений",;
              "Для прерывания операции нажмите ESC"})
       While ( lForever .or. nWaitSeconds > 0 )
         (Alias)->(DbAppend())
         if !Neterr()  ; S_Sys() ; break ;  end
         if inkey(.5) == K_ESC
            S_Sys()
            S_Err({"@ВНИМАНИЕ !!!","Прерывание операции","По Вашей инициативе"})
            lRet := .f.
            break
          end
         nWaitSeconds -= 0.5
       end
       S_Sys()
       S_Err({"@ВНИМАНИЕ!","Время ожидания истекло","Прерывание операции"})
       lRet := .f.
    END SEQUENCE
return ( lRet )
//////////////////////////////////////////////////////////////////////////
Static Function CloseMes()  // закрытие месяца по приходу
    Local nLastRec, nRecno, cDir := sset[112][1], i, dData

    if !File(cDir+"OstNew.Dbf") 
      S_Err({02,"Вы не сформировали ведомость",;
                "РАСЧЕТ С ПОТРЕБИТЕЛЯМИ",;
                "% Нажмите Enter для продолжения;"})
      Return ( Nil )
    End
    nRecno := Alltrim(str(Ostatok->Summa,10))
    dData := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
    if S_Err({02,,"Вы действительно желаите сделать",;
                  " закрытие месяца "+S_cMonth(dData),;
                  " и не пожалеите об этом",;
                  "%    Нет   ;   Да  ;"}) == 1
      Return ( Nil )
    End
    BEGIN SEQUENCE
        S_Sys({"Ожидайте..."," Осуществляю переход на новый месяц"})
        // prixod ==> aPrix; Prixod.zap()
        DbSelectArea("Prixod")
        if !File(cDir+"aPrix.dbf")
         i := DbStruct()
         aadd(i,{"Data","D",08,00})
         DbCreate( (cDir+"aPrix"),i)
        End
        use (cDir+"aPrix") new alias Arx
        Prixod->(DbGoTop())
        While !Prixod->(eof())
          Arx->(DbAppend())
          For i := 1 to Prixod->(fCount())
             Arx->(FieldPut(i,Prixod->(FieldGet(i))))
          Next
          Arx->Data := dData
          Prixod->(DbSkip(1))
        End
        DbSelectArea("Prixod")
        __DbZap()
        Reindex
        Arx->(DbCloseArea())
        //////////////////////
        // Rasxod ==> aRasx; Rasxod.zap()
        DbSelectArea("Rasxod")
        if !File(cDir+"aRasx.dbf")
         i := DbStruct()
         aadd(i,{"Data","D",08,00})
         DbCreate( (cDir+"aRasx"),i)
        End
        use (cDir+"aRasx") new alias Arx
        Rasxod->(DbGoTop())
        While !Rasxod->(eof())
          Arx->(DbAppend())
          For i := 1 to Rasxod->(fCount())
             Arx->(FieldPut(i,Rasxod->(FieldGet(i))))
          Next
          Arx->Data := dData
          Rasxod->(DbSkip(1))
        End
        Arx->(DbCloseArea())
        DbSelectArea("Rasxod")
        __DbZap()
        Reindex
        //////////////////////////
        // OstNew ==> Ostatok; Rasxod.zap()
        Ostatok->(DbCloseArea())
        ferase(cDir+"OstaTok.dbf")
        ferase(cDir+"OstTok.ntx")
        nRecno := 0
        if S_FileMove( cDir+"OstNew.Dbf", cDir+"Ostatok.Dbf") == 0 
           use (cDir+"OSTATOK") new
           if !File(cDir+"OSTATOK.NTX")
              Index on str(Ent,4) to (cdir+"OSTATOK")
           End
           Set Index to (cDir+"OSTATOK")
           Set Index to (cDir+"OSTATOK")
           DbSelectArea("OstaTok")
           Reindex
           nRecno++
        End
        S_Sys()
        if nRecno == 1
          S_Err({"Ok!"," все готово ","% нажмите ENTER для продолжения ;"})
        End
        if ostatok->(DbSeek(str(0,4)))
          nRecno := Alltrim(str(Ostatok->Summa,10))
          nRecno := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
          nLastRec := S_wSelect()
          S_wSelect(0)
          @ 23,00 say padc("Расчет за "+S_cMonth(nRecno)+" месяц "+str(year(nRecno),4)+" г.",80) color sset[86]
          S_wSelect(nLastrec)
        End
        S_FileDel(sset[112][2]+"p*.ved")
        S_FileDel(sset[112][2]+"s*.ved")
    END SEQUENCE
Return ( Nil )
//////////////////////////////////////////////////////////////////////////////

STATIC FUNCTION LoadMes()
    MEMVAR Sset
    LOCAL dDate := date()
    LOCAL cDir := sset[112][1]
    LOCAL ColorOld := SetColor(sset[32]+","+sset[2])
    LOCAL GetList := {}
    LOCAL WindowOld := S_wSelect()
    LOCAL cDate, i, nRecno, nLastRec
    IF !File(cDir+"aRasx.dbf") .OR. !File(cDir+"aPrix.dbf")
        S_Err({02,"Нет файлов с архивами",;
        "% Нажмите Enter для продолжения;"})
        Return ( Nil )
    ENDIF  
    IF S_Err({02,;
             "Внимание!",;
             "Эта операция загрузит как текущий, указанный вами месяц",; 
             "Вы действительно желаете загрузить месяц из архива",;
             "и не пожалеете об этом?","% Да ; Нет ;"}) == 2
             RETURN(nil)
    ENDIF		 
    // Запрашиваем дату
    S_Open_M(12,38,14,65,sset[32],sset[2])
    @ 01,01 say "Укажите дату" get dDate Pict "@d" valid !empty(dDate)
    read
    S_wCloseSl(S_RanDom()%22+1)
    SetColor("n/w")
    S_wSelect(0)
    S_wSelect(WindowOld)
    SetColor(ColorOld)
    cDate = dtos(dDate)
    // Сбрасываем дату на первый день месяца
    dDate=ctod("01."+Substr(cDate,5,2)+"."+Substr(cDate,1,4)) // Первая дата заказанного месяца.
    cDate = dtos(dDate) // Первая дата заказанного месяца как строка в формате YYYYMMDD.
//    S_Err({"cDate: "+cDate})
// Очищаем остатки
    DbSelectArea("Ostatok")
    __DbZap()
    Ostatok->(Dbappend())
    Ostatok->Ent := 0
    Ostatok->Summa := val(cDate)
    Reindex
// Загружаем расход
    // Ищем данные для загрузки
    use (cDir+"aRasx") new alias aRasx
    while (!aRasx->(eof()) .and. aRasx->data < dDate)
        aRasx->(Dbskip(1))
    end	
    // Стоим на первой записи нужного месяца или конец файла
    DbSelectArea("Rasxod")
    __DbZap()
    Reindex
    // Загружаем расход
    while (!aRasx->(eof()) .and. aRasx->data == dDate)
        Rasxod->(DbAppend())
        For i := 1 to Rasxod->(fCount())
            Rasxod->(FieldPut(i,aRasx->(FieldGet(i))))
        Next
        aRasx->(Dbskip(1))
    end
    aRasx->(DbCloseArea())
// Загружаем приход
    // Ищем данные для загрузки
    use (cDir+"aPrix") new alias aPrix
    while (!aPrix->(eof()) .and. aPrix->data < dDate)
        aPrix->(Dbskip(1))
    end	
    // Стоим на первой записи нужного месяца или конец файла
    DbSelectArea("Prixod")
    __DbZap()
    Reindex
    // Загружаем приход
    while (!aPrix->(eof()) .and. aPrix->data == dDate)
        Prixod->(DbAppend())
        For i := 1 to Prixod->(fCount())
            Prixod->(FieldPut(i,aPrix->(FieldGet(i))))
        Next
        aPrix->(Dbskip(1))
    end
    aPrix->(DbCloseArea())
    S_Err({"Ok!"," все готово ","% нажмите ENTER для продолжения ;"})
    if ostatok->(DbSeek(str(0,4)))
        nRecno := Alltrim(str(Ostatok->Summa,10))
        nRecno := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
        nLastRec := S_wSelect()
        S_wSelect(0)
        @ 23,00 say padc("Расчет за "+S_cMonth(nRecno)+" месяц "+str(year(nRecno),4)+" г.",80) color sset[86]
        S_wSelect(nLastrec)
    End
RETURN( nil )

