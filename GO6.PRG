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
sset[102] := "�����"
sset[100] := date()
S_SetDelay(15) 
SetColor(sset[86] := "n/w")
S_Cls("�")
@ 00,00 say space(80)
@ 23,00 say space(80)
@ 00,38 say sset[102]
VvodData()
@ 00,64 say "�६�:"
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
  @ 23,00 say padc("����� �� "+S_cMonth(data)+" ����� "+str(year(data),4)+" �.",80) color sset[86]
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
/* ������� ����� ��������� ��쥪�                  o()  */ 
oMenMain := oMen
While .T.
  if !S_IswShad()  ; S_wSetShad("w/n") ; end
  Key := m_inkey(0)
  do Case
     case oMen == oMenMain .and. key == K_ESC
       S_Beep()
       if S_Err({16,28,"�������� ࠡ���?","% ��� ;  �� ; "}) == 2
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

    // ���� 0    >>>>>>>>>>>>>>> ������� <<<<<<<<<<<<<<<
    omen0:=oMenuNew( 2, 2, .F.     ,;
                   {"  ���� ������   ",;
                    "  ��������  ",;
                    "  � � �   ",;
                    "  ��ࢨ�  ",;
                    "  ��x��   "})
    oprompt1:=oPromptNew(24,0,80)
    oprompt1:Color := {"n/w","n/w"}
    omen0:Prompt:=oPrompt1
    omen0:addPrompt(1,"���� ����歮� ���ଠ樨 � ���� ������")
    omen0:addPrompt(2,"��ନ஢���� � ����� �������⥩")
    omen0:addPrompt(3,"������� ����⨢�� �ࠢ�筮� ���ଠ樨 �����")
    omen0:addPrompt(4,"�����⨥ �����  ������� ��  ����� ��  ��������  ���������")
    omen0:addPrompt(5,"��室 �� �ணࠬ��")
    omen0:block(5,{||Mquit()})
    i := 0
    // ���� 1    >>>>>>>>>>>>>>> ���� ������ <<<<<<<<<<<<<<<
    omen1:=oMenuNew()

    omen1:add("�㬬� �� ��⠬ ������")
    omen1:addPrompt(++i,"������� �㬬 ��� �ନ஢���� �������� ������ � ������������� �� �������")
    omen1:block(i,{||VedPrixod()})

    omen1:add("�㬬� �� ��⠬ ������")
    omen1:addPrompt(++i,"������� �㬬 ��� �ନ஢���� �������� ������ � ������������� �� �������")
    omen1:block(i,{||VedRasxod()})

    omen1:add("���⪨ �� ��砫� �����")
    omen1:addPrompt(++i,"������� ���⪮� �� �������� ������ � ������������")
    omen1:block(i,{||VedOst()})

    omen1:add("���⥦��� ����祭��")
    omen1:addPrompt(++i,"��ନ஢���� � ����� ���⥦���� ����祭��")
    omen1:block(i,{||PlPor()})

//    omen1:add("���⥦��� ���祭��5")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���⥦���� ����祭��5")
//    omen1:block(i,{||PlPor1()})

//    omen1:add("���⥦��� ���祭��6")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���⥦���� ����祭��6")
//    omen1:block(i,{||PlPor2()})

//    omen1:add("���⥦��� ���祭��7")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���⥦���� ����祭��7")
//    omen1:block(i,{||PlPor3()})

//    omen1:add("���⥦��� ���祭��2856  ")
//    omen1:addPrompt(++i,"��ନ� � ����� ���⥦���� ����� 2856")
//    omen1:block(i,{||PlPor28()})

//    omen1:add("���⥦��� ���祭��28562  ")
//    omen1:addPrompt(++i,"��ନ� � ����� ���⥦���� ����� 28562")
//    omen1:block(i,{||PlPor282()})

//    omen1:add("���⥦��� ���祭�� ykrcib  ")
//    omen1:addPrompt(++i,"��ନ� � ����� ���⥦���� ����� ykrcib2")
//    omen1:block(i,{||PlPory()})

    omen1:add("��������� ���������")
    omen1:addPrompt(++i,"��ନ஢���� � ����� ��������� ���������")
    omen1:block(i,{||PrnNalogG()})

    omen1:add("���-䠪���")
    omen1:addPrompt(++i,"��ନ஢���� � ����� ���-䠪����")
    omen1:block(i,{||ChFaktU()})

//    omen1:add("���-䠪���6")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���-䠪����6")
//    omen1:block(i,{||ChFakt1()})

//    omen1:add("���-䠪���7")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���-䠪����7")
//    omen1:block(i,{||ChFakt2()})

//    omen1:add("���-䠪���Y")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���-䠪����7")
//    omen1:block(i,{||ChFakt4()})

//    omen1:add("���-䠪���M")
//    omen1:addPrompt(++i,"��ନ஢���� � ����� ���-䠪����M")
//    omen1:block(i,{||ChFakt5()})


    omen1:add("��������� ��������� �� ���-䠪����")
    omen1:addPrompt(++i,"��ନ஢���� � ����� ��������� ���������")
    omen1:block(i,{||PrnNalCh()})

    omen1:add("��������� ��������� �� ���-䠪���� Ykp ")
    omen1:addPrompt(++i,"��ନ஢���� � ����� ��������� ��������� Ykpai")
    omen1:block(i,{||PrnNalChYk()})

    omen1:add("����� ���")
    omen1:addPrompt(++i," ����� ���")
    omen1:block(i,{||akt()})

    omen1:add("����� ��� �/�")
    omen1:addPrompt(++i," ����� ��� 宧����")
    omen1:block(i,{||aktHr()})

//    omen1:add("����� ���Y")
//    omen1:addPrompt(++i," ����� ��Y")
//    omen1:block(i,{||akt4()})
    
//    omen1:add("����� ���M")
//    omen1:addPrompt(++i," ����� ��M")
//    omen1:block(i,{||akt5()})

//    omen1:add("����� ���1")
//    omen1:addPrompt(++i," ����� ��")
//    omen1:block(i,{||akt1()})

//    omen1:add("����� ���2")
//    omen1:addPrompt(++i," ����� ��")
//    omen1:block(i,{||akt2()})

    omen1:Prompt:=oPrompt1
    omen0:addSub(1,omen1)

    i := 0
    // ���� 2    >>>>>>>>>>>>>>> ��ନ஢���� � ����� �������⥩ <<<<<<<<<<<<<<<
    omen2:=oMenuNew()

    omen2:add("��������� �� ��室�")
    omen2:addPrompt(++i,"��ନ஢���� � ����� �������� �� ��室� ")
    omen2:block(i,{||VedomPrix()})

    omen2:add("��ନ஢���� ��������")
    omen2:addPrompt(++i,"��ନ஢���� � ����� ��������")
    omen2:block(i,{||VedRas()})

    omen2:add("����� ��������")
    omen2:addPrompt(++i,"��ᬮ�� � ����� ��������")
    omen2:block(i,{||PrnVedRas()})

    omen2:add("������� ��������� �� ��室�")
    omen2:addPrompt(++i,"��ᬮ�� � ����� ������� �������� �� ��室�")
    omen2:block(i,{||VedomGod()})

    omen2:add("��������� ���⪮� �� ����� �����")
    omen2:addPrompt(++i,"��ନ஢���� � ����� �������� ���⪮� �� ����� �����")
    omen2:block(i,{||VedDolg()})

    omen2:add("��������� ���⪮� �� ��砫� �����")
    omen2:addPrompt(++i,"��ନ஢���� � ����� �������� ���⪮� �� ��砫� �����")
    omen2:block(i,{||VedOstN()})

    omen2:add("����� ��� �த���")
    omen2:addPrompt(++i,"��ନ஢���� � ����� ����� ��� �த���")
    omen2:block(i,{||PrnBook()})

    omen2:add("॥��� ��⮢")
    omen2:addPrompt(++i,"��ନ஢���� � ����� ॥��� ��⮢ ")
    omen2:block(i,{||VedomPrix1()})

    omen2:add("॥��� ��⮢ �����")
    omen2:addPrompt(++i,"��ନ஢���� � ����� ॥��� ��⮢ ")
    omen2:block(i,{||VedomPrix2()})

    omen2:Prompt:=oPrompt1
    omen0:addSub(2,omen2)
            
    i := 0
    // ���� 3    >>>>>>>>>>>>>>> � � � <<<<<<<<<<<<<<<
    omen3:=oMenuNew()

    omen3:add("��ࠢ�筨� ��㯯 �࣠����権")
    omen3:addPrompt(++i,"������� �ࠢ�筨�� ��㯯 �࣠����権")
    omen3:block(i,{||VedGr()})

    omen3:add("��ࠢ�筨� �࣠����権")
    omen3:addPrompt(++i,"������� �ࠢ�筨�� �࣠����権")
    omen3:block(i,{||VedEnt()})

    omen3:add("��ࠢ�筨� ��⮢")
    omen3:addPrompt(++i,"������� �ࠢ�筨�� ��⮢")
    omen3:block(i,{||VedChet()})

    omen3:add("������")
    omen3:addPrompt(++i,"������� 業����")
    omen3:block(i,{||VedPrice()})

    omen3:add("��ࠢ�筨� ������ �।�����")
    omen3:addPrompt(++i,"������� �ࠢ�筨�� ������ �।�����")
    omen3:block(i,{||VedBank()})
   
    omen3:Prompt:=oPrompt1
    omen0:addSub(3,omen3)

    i := 0
    // ���� 4    >>>>>>>>>>>>>>> ������ <<<<<<<<<<<<<<<
    omen4:=oMenuNew()
    omen4:add("�����⨥ ����� ")
    omen4:addPrompt(++i,"�믮������ ��楤��� �� ���室� �� ᫥���騩 �����")
    omen4:block(i,{||CloseMes()})

    omen4:add("����㧪� ����� ")
    omen4:addPrompt(++i,"����㧪� ����� � ���� �� ��娢�, ��� ⥪�饣�! ��頥� ⥪�騥 Prixod, Rashod!")
    omen4:block(i,{||LoadMes()})

    omen4:add("����� �� �� ��᪥�� ")
    omen4:addPrompt(++i,"ᮧ����� ���客�� ����� �� �� ��᪥�")
    omen4:block(i,{||CopyDb()})

    omen4:add("������஢���� � ������� �� ")
    omen4:addPrompt(++i,"������஢���� � ᦠ⨥ ���� ������")
    omen4:block(i,{||DbPack()})

    omen4:add("��������")
    omen4:addPrompt(++i,"��������")
    omen4:block(i,{ | |S_Calc() })

    omen4:add("���������")
    omen4:addPrompt(++i,"���������")
    omen4:block(i, { |x| x := Set(4,"dd.mm.yy"),;
                              S_Calend(3,50),;
                              Set(4,x) } )
                              
    omen4:add("����� ���� ")
    omen4:addPrompt(++i,"����� ����")
    omen4:block(i,{||VvodData()})

    omen4:add("�����⮢�� 䠩�� ��ᯮ�� � 1�")
    omen4:addPrompt(++i,"��ନ஢���� 䠩�� ��� ��ᯮ�� � 1�")
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
    S_Sys({" ������ "," ���뢠� ���� ������ "," ������� �������� "})
    BEGIN SEQUENCE
        //       ��ࠢ�筨� ��㯯 �࣠����権
        if !File(cDir+"S_GR.DBF")
           fErase(cDir+"S_GR.NTX")
           DbCreate(cDir+"S_GR",{ {"Tip", "N",01,00},;   // ��� ��㯯�
                                  {"Naim","C",25,00}})   // ������������
        end
        use (cDir+"S_GR") new
        if !File(cDir+"S_GR.NTX")
           Index on str(Tip,1) to (cdir+"S_GR")
        End
        Set Index to (cDir+"S_GR")
        Set Index to (cDir+"S_GR")
        //       ��ࠢ�筨� ������ �।�����
        if !File(cDir+"S_BANK.DBF")
           fErase(cDir+"S_BANK.NTX")
           DbCreate(cDir+"S_BANK",{ {"ID", "N",03,00},;     // ID �����
                                    {"MFO",  "C",09,00},;   // ���
                                    {"SCHET","C",14,00},;   // ���
                                    {"NAIM","C",35,00},;    // ������������
                                    {"NAIM2","C",35,00}})   // ������������ 2
        end
        use (cDir+"S_BANK") new
        if !File(cDir+"S_BANK.NTX")
           Index on str(ID,3) to (cdir+"S_BANK")
        End
        Set Index to (cDir+"S_BANK")
        Set Index to (cDir+"S_BANK")
        //       ��ࠢ�筨� �࣠����権
        if !File(cDir+"S_ENT.DBF")
           fErase(cDir+"S_ENT.NTX")
           DbCreate(cDir+"S_ENT",{ {"Ent",  "N",04,00},;   // ��� �࣠����樨
                                   {"Naim", "C",35,00},;   // ������������
                                   {"Adres","C",35,00},;   // ����
                                   {"Okpo", "C",11,00},;   // ��� ����
                                   {"Mfo",  "C",09,00},;   // ���
                                   {"Schet","C",14,00},;   // ���
                                   {"Tip",  "N",01,00},;   // ���
                                   {"KodNalog","C",12,00},;   // 
                                   {"KodSvid", "C",08,00},;   // 
                                   {"Dogovor", "C",10,00},;   // 
                                   {"DataDog", "D",08,00},;   // 
                                   {"Bank", "C",35,00} })  // ������������ �����
        end
        use (cDir+"S_ENT") new
        if !File(cDir+"S_ENT.NTX")
           Index on str(Ent,4) to (cdir+"S_ENT")
        End
        Set Index to (cDir+"S_ENT")
        Set Index to (cDir+"S_ENT")
        //  ��ࠢ�筨� ��⮢
        if !File(cDir+"S_CHET.DBF")
           fErase(cDir+"S_CHET.NTX")
           DbCreate(cDir+"S_CHET",{ {"Chet",  "N",04,00},;   // ��� ���
                                    {"Naim",  "C",30,00}})   // ������������
        end
        use (cDir+"S_CHET") new
        if !File(cDir+"S_CHET.NTX")
           Index on str(Chet,4,0) to (cdir+"S_CHET")
        End
        Set Index to (cDir+"S_CHET")
        Set Index to (cDir+"S_CHET")
        //  ������
        if !File(cDir+"S_PRICE.DBF")
           fErase(cDir+"S_PRICE.NTX")
           DbCreate(cDir+"S_PRICE",{ {"Chet",  "N",04,00},;   // ��� ���
                                     {"Tip",   "N",01,00},;   // ���
                                     {"Cena","N",12,06},;   // ����
                                     {"Ndc", "N",12,06},;   // % ���
                                     {"Fec", "N",12,06} })  // % ���
        end
        use (cDir+"S_PRICE") new
        if !File(cDir+"S_PRICE.NTX")
           Index on str(Chet,4,0)+str(Tip,1) to (cdir+"S_PRICE")
        End
        Set Index to (cDir+"S_PRICE")
        Set Index to (cDir+"S_PRICE")
        //  ���⪨ �� �������� ������ � �������������
        if !File(cDir+"OSTATOK.DBF")
           fErase(cDir+"OSTATOK.NTX")
           DbCreate(cDir+"OSTATOK",{ {"Ent",  "N",04,00},;   // ��� �࣠����樨
                                     {"Summa","N",13,02} })  // �㬬� ���⪠
        end
        use (cDir+"OSTATOK") new
        if !File(cDir+"OSTATOK.NTX")
           Index on str(Ent,4) to (cdir+"OSTATOK")
        End
        Set Index to (cDir+"OSTATOK")
        Set Index to (cDir+"OSTATOK")
        if !ostatok->(DbSeek(str(0,4)))
           i := ctod("")
           S_Get({07,02,"������ ���� ��砫� ��ᯫ��樨 ����� ","i","@d"})
           if !empty(i)
              Ostatok->(DbAppend())
              Ostatok->Ent := 0   ;  Ostatok->Summa := val(dtos(S_Bom(i)))
           End
        End
        //  ���� �������� ������ � ������������� �� �������
        if !File(cDir+"PRIXOD.DBF")
           fErase(cDir+"PRIXOD.NTX")
           DbCreate(cDir+"PRIXOD",{ {"Ent",  "N",04,00},;   // ��� �࣠����樨
                                    {"Chet", "N",04,00},;   // ���
                                    {"Npp",  "N",05,00},;   // N ���
                                    {"Kolvo","N",10,00},;   // ������⢮
                                    {"Cena", "N",12,06},;   // ����
                                    {"Sum",  "N",13,02},;   // �㬬� ��� ���
                                    {"Ndc",  "N",13,02},;   // ���
                                    {"Fec",  "N",13,02},;   // ���
                                    {"SumBank","N",13,02},; // �㬬� �� �����
                                    {"Summa","N",13,02} })  // �㬬� � ���
        end
        use (cDir+"PRIXOD") new
        if !File(cDir+"PRIXOD.NTX")
           Index on str(Ent,4)+str(Chet,4,0) to (cdir+"PRIXOD")
        End
        Set Index to (cDir+"PRIXOD")
        Set Index to (cDir+"PRIXOD")
        //  ���� �������� ������ � ������������� �� �������
        if !File(cDir+"RASXOD.DBF")
           fErase(cDir+"RASXOD.NTX")
           DbCreate(cDir+"RASXOD",{ {"Ent",  "N",04,00},;   // ��� �࣠����樨
                                    {"Chet", "N",04,00},;   // ���
                                    {"Summa","N",13,02} })  // �㬬� 
        end
        use (cDir+"RASXOD") new
        if !File(cDir+"RASXXOD.NTX")
           Index on str(Ent,4)+str(Chet,4,0) to (cdir+"RASXOD")
        End
        Set Index to (cDir+"RASXOD")
        Set Index to (cDir+"RASXOD")
        //  ���� ��������� ���������
        if !File(cDir+"PLPOR.DBF")
           fErase(cDir+"PLPOR.NTX")
           DbCreate(cDir+"PLPOR",{ {"PlPor",  "N",06,00},;   // �����
                                   {"GodPor", "N",04,00},;   // ���
                                   {"DataPor","D",08,00},;   // ���
                                   {"BankPor","N",03,00},;   // ID �����
                                   {"EntPor", "N",04,00},;   // ��� �࣠����樨
                                   {"SumPor", "N",15,02},;   // �㬬�
                                   {"Text1",  "C",45,00},;   // �����
                                   {"Text2",  "C",45,00},;   // �����
                                   {"Ndc",    "N",15,02} })  // �㬬� ���
        end
        use (cDir+"PlPor") new
        if !File(cDir+"PlPor.NTX")
           Index on str(GodPor,4)+str(PlPor,6) to (cdir+"PLPOR")
        End
        Set Index to (cDir+"PLPOR")
        Set Index to (cDir+"PLPOR")
        //
        //  ��ࠢ�筨� ᯮᮡ��
        if !File(cDir+"Sposob.DBF")
           fErase(cDir+"Sposob.NTX")
           DbCreate(cDir+"Sposob",{ {"Sposob",  "N",02,00},;   // ��� 
                                    {"NaimSpos","C",25,00} })  // ������������
        end
        use (cDir+"Sposob") new
        if !File(cDir+"Sposob.NTX")
           Index on str(Sposob,2) to (cdir+"Sposob")
        End
        Set Index to (cDir+"Sposob")
        Set Index to (cDir+"Sposob")
        //  ���� ���������
        if !File(cDir+"NalNakl.DBF")
           fErase(cDir+"NalNakl.NTX")
           DbCreate(cDir+"NalNakl",{ {"God",    "N",04,00},;   // ���
                                     {"NomNakl","N",10,00},;   // ����� ���������
                                     {"Fio",    "C",30,00} })  // 
        end
        use (cDir+"NalNakl") new
        if !File(cDir+"NalNakl.NTX")
           Index on str(God,4)+str(NomNakl,10) to (cdir+"NalNakl")
        End
        Set Index to (cDir+"NalNakl")
        Set Index to (cDir+"NalNakl")
        //  ���� ��� 䠪����
        if !File(cDir+"Fakt.DBF")
           fErase(cDir+"FaktN.NTX")
           fErase(cDir+"FaktD.NTX")
           DbCreate(cDir+"Fakt",{ {"NomChF", "N",06,00},;   // �����
                                  {"Data",   "D",08,00},;   // ��� ���������
                                  {"DataCh", "D",08,00},;   // ��� ��
                                  {"Bank",   "N",03,00},;   // ID �����
                                  {"Ent",    "N",04,00},;   // �࣠������
                                  {"EdIzm",  "C",07,00},;   // �� ���
                                  {"Kolvo",  "N",10,00},;   // ���-��
                                  {"Cena",   "N",12,06},;   // ����
                                  {"Naim",   "C",30,00},;   // ������������
                                  {"Summa",  "N",15,02},;   // �㬬�
                                  {"Ndc",    "N",15,02},;   // ���
                                  {"Chet",   "N",04,00},;   // ���
                                  {"Fec",    "N",13,02},;   // ���
                                  {"SumBank","N",13,02},;   // �㬬� �� �����
                                  {"Sposob", "C",25,00} })  // ᯮᮡ
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
    @ 01,01 say "���  ������������ �࣠����樨        ���⮪"
    @ 02,01 say Repl([�],MaxCol()-1)
    @ MaxRow()-2,01 say Repl([�],MaxCol()-1)
    @ MaxRow()-1,01 say padc("2��� 3� 4ॣ 5���� 6���� 7���� 9०��",MaxCol()-1) color sset[5]
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
           Case nKey == K_F9  // ����� ������
                nRegim := if(nRegim==1,2,1) 
                @ 00,(MaxCol()-1)/2 say "["+aRegim[nRegim]+"]" color sset[2]
           Case nKey == K_F2  // �����
                nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
                @ MaxRow()-1,01 say padc("������ �� ������ � �㬠���",MaxCol()-1) color sset[5]
                nRow := Ostatok->(Recno())
                Ostatok->(DbGoTop())
                nSumma := Ostatok->Summa
                Ostatok->(DbSkip(1))
                Set Device to Print
                @ prow()+1,01 say padc("��ᯥ�⪠",51)
                @ prow()+1,01 say padc("���⪮� �������� ���� � ���ॡ�⥫ﬨ",51)
                @ prow()+1,01 say padc(" �� "+str(nSumma,9),51)
                @ prow()+1,01 say repl("-",51)
                @ prow()+1,01 say "���  ������������ �࣠����樨        ���⮪"
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
           Case nKey == K_F6  // ���� �� �����
                SetCursor(1)
                nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
                @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
                nRow := 0
                @ MaxRow()-1,03 say "������ ���" get nRow pict "9999" valid nRow > 0
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
           Case nKey == K_F7  // ���� �� ������������
                SetCursor(1)
                nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
                @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
                nRow := space(30)
                @ MaxRow()-1,01 say "--->" get nRow
                read
                if LastKey() <> K_ESC
                   DbSelectArea("S_Ent")
                   if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
                      S_Err({" ������ �� �����㦥�� "})
                      DbSelectArea("Ostatok")
                   else
                      nSumma := S_Ent->Ent
                      DbSelectArea("Ostatok")
                      if !Ostatok->(DbSeek(str(nSumma)))
                         S_Err({" ������ �� �����㦥�� "})
                         S_Beep(1)  ;  tb:GoBottom()
                      End
                   end
                end
                SetCursor(0)
                RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)            
                FreshOrder(tb)
           case nKey == K_F3  // ��������
               if Ostatok->(Recno()) # 0 .and. Ostatok->Ent > 0 .and. ;
                  S_Err({S_wRow()+1,S_wCol()+2,,;
                 "�� ����⢨⥫쭮","������ 㤠���� ������",;
                 "� �� �������� �� �⮬?","% �� ; ��� ;"}) == 1 
                     Ostatok->(DbDelete())   ;   nDelete++
                     Ostatok->(DbSkip(1))
                     if Ostatok->(eof()) ; Ostatok->(DbGoBottom()) ; end
               end
               FreshOrder(tb)
           case nKey == K_F4  // ���������
               tb:DeHilite()
               nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
               @ MaxRow()-1,01 say padc("��⠢��� �����",MaxCol()-1) color sset[5]
               While ( .t. )
                 Scroll(03,01,MaxRow()-3,MaxCol()-1,-1)
                 nEnt := 0
                 @ 03,01 get nEnt Pict "9999" valid VedEnt(@nEnt,03,06)
                 read
                 if LastKey() == K_ESC ; Exit ; End
                 if Ostatok->(DbSeek(str(nEnt,4)))
                    @ 03,06 say padc(" ������ ������� �����⥫쭥�",30) Color sset[5]
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
           case nKey == K_F5  .and. Ostatok->Ent > 0  // �����஢��
               tb:DeHilite()
               nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
               SetCursor(1)
               @ MaxRow()-1,01 say padc("���४���� ���⮪",MaxCol()-1) color sset[5]
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
    @ MaxRow()-1,5 say "������ �������..."
    Inkey(0)
    S_wCloseSl(S_RanDom()%22+1)
    SetColor(ColorOld)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static function CopyDb()
    Local ColorOld := SetColor(COLOR_BAZA),;
          aFile := {"Prixod","Ostatok","S_Ent","S_Chet","Rasxod","S_Gr"}, i
    S_Err({"��⠢� ��᪥�� � ��᪮��� � ������ �������"})
    S_Open_M(10,03,20,30,,sset[2])
    @ MaxRow()-1,02 say "���� ��᪥��"
    S_FileDel("a:\*.*")
    Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
    for i := 1 to Len(aFile)
        Dbselectarea(aFile[i])
        @ MaxRow()-1,02 say aFile[i]+" ---> �������"
        copy to ("a:\"+aFile[i])
        @ MaxRow()-1,23 say "Ok!"
        Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
    next
    My_Char()
    @ MaxRow()-1,5 say "������ �������..."
    Inkey(0)
    S_wCloseSl(S_RanDom()%22+1)
    SetColor(ColorOld)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
static Function VvodData()      //  ���� ���� � ���
    Local dData := date(),;
          ColorOld := SetColor(sset[32]+","+sset[2]),;
          GetList := {}, WindowOld := S_wSelect()
    S_Open_M(12,38,14,65,sset[32],sset[2])
    @ 01,01 say "������ ����" get dData Pict "@d" valid !empty(dData)
    read
    S_wCloseSl(S_RanDom()%22+1)
    SetColor("n/w")
    S_wSelect(0)
    @ 00,01 say padc( {"����ᥭ�","�������쭨�","��୨�","�।�","��⢥�",;
              "��⭨�","�㡡��"}[dow(ddata)]+" "+str(day(ddata),2)+" "+;
              S_cMonth(dData,.t.)+" "+str(year(ddata),4)+" ����",35)
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
    S_Sys({"����⪠ �����஢�� �����",;
           "���� ������ 䠩�� "+alias()+" �����஢���",;
           "��� �⪠�� �� ����� ������ ESC"})
    BEGIN SEQUENCE
        While ( lForever .or. nSeconds > 0 )
           if inkey(.5) == K_ESC
             S_Sys()
             S_Err({"@�������� !!!","���뢠��� ����樨","�� ��襩 ���樠⨢�"})
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
        S_Err({"@�������� !!!","�६� �������� ��⥪��","���뢠��� ����樨"})
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
       S_Sys({"���� ������ ������㯭� ��� ࠡ���",;
              "� ��� �/��� ���ᥭ�� � ��� ���������",;
              "��� ���뢠��� ����樨 ������ ESC"})
       While ( lForever .or. nWaitSeconds > 0 )
         (Alias)->(DbAppend())
         if !Neterr()  ; S_Sys() ; break ;  end
         if inkey(.5) == K_ESC
            S_Sys()
            S_Err({"@�������� !!!","���뢠��� ����樨","�� ��襩 ���樠⨢�"})
            lRet := .f.
            break
          end
         nWaitSeconds -= 0.5
       end
       S_Sys()
       S_Err({"@��������!","�६� �������� ��⥪��","���뢠��� ����樨"})
       lRet := .f.
    END SEQUENCE
return ( lRet )
//////////////////////////////////////////////////////////////////////////
Static Function CloseMes()  // �����⨥ ����� �� ��室�
    Local nLastRec, nRecno, cDir := sset[112][1], i, dData

    if !File(cDir+"OstNew.Dbf") 
      S_Err({02,"�� �� ��ନ஢��� ���������",;
                "������ � �������������",;
                "% ������ Enter ��� �த�������;"})
      Return ( Nil )
    End
    nRecno := Alltrim(str(Ostatok->Summa,10))
    dData := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
    if S_Err({02,,"�� ����⢨⥫쭮 ������ ᤥ����",;
                  " �����⨥ ����� "+S_cMonth(dData),;
                  " � �� �������� �� �⮬",;
                  "%    ���   ;   ��  ;"}) == 1
      Return ( Nil )
    End
    BEGIN SEQUENCE
        S_Sys({"�������..."," �����⢫�� ���室 �� ���� �����"})
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
          S_Err({"Ok!"," �� ��⮢� ","% ������ ENTER ��� �த������� ;"})
        End
        if ostatok->(DbSeek(str(0,4)))
          nRecno := Alltrim(str(Ostatok->Summa,10))
          nRecno := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
          nLastRec := S_wSelect()
          S_wSelect(0)
          @ 23,00 say padc("����� �� "+S_cMonth(nRecno)+" ����� "+str(year(nRecno),4)+" �.",80) color sset[86]
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
        S_Err({02,"��� 䠩��� � ��娢���",;
        "% ������ Enter ��� �த�������;"})
        Return ( Nil )
    ENDIF  
    IF S_Err({02,;
             "��������!",;
             "�� ������ ����㧨� ��� ⥪�騩, 㪠����� ���� �����",; 
             "�� ����⢨⥫쭮 ������ ����㧨�� ����� �� ��娢�",;
             "� �� �������� �� �⮬?","% �� ; ��� ;"}) == 2
             RETURN(nil)
    ENDIF		 
    // ����訢��� ����
    S_Open_M(12,38,14,65,sset[32],sset[2])
    @ 01,01 say "������ ����" get dDate Pict "@d" valid !empty(dDate)
    read
    S_wCloseSl(S_RanDom()%22+1)
    SetColor("n/w")
    S_wSelect(0)
    S_wSelect(WindowOld)
    SetColor(ColorOld)
    cDate = dtos(dDate)
    // ����뢠�� ���� �� ���� ���� �����
    dDate=ctod("01."+Substr(cDate,5,2)+"."+Substr(cDate,1,4)) // ��ࢠ� ��� ����������� �����.
    cDate = dtos(dDate) // ��ࢠ� ��� ����������� ����� ��� ��ப� � �ଠ� YYYYMMDD.
//    S_Err({"cDate: "+cDate})
// ��頥� ���⪨
    DbSelectArea("Ostatok")
    __DbZap()
    Ostatok->(Dbappend())
    Ostatok->Ent := 0
    Ostatok->Summa := val(cDate)
    Reindex
// ����㦠�� ��室
    // �饬 ����� ��� ����㧪�
    use (cDir+"aRasx") new alias aRasx
    while (!aRasx->(eof()) .and. aRasx->data < dDate)
        aRasx->(Dbskip(1))
    end	
    // �⮨� �� ��ࢮ� ����� �㦭��� ����� ��� ����� 䠩��
    DbSelectArea("Rasxod")
    __DbZap()
    Reindex
    // ����㦠�� ��室
    while (!aRasx->(eof()) .and. aRasx->data == dDate)
        Rasxod->(DbAppend())
        For i := 1 to Rasxod->(fCount())
            Rasxod->(FieldPut(i,aRasx->(FieldGet(i))))
        Next
        aRasx->(Dbskip(1))
    end
    aRasx->(DbCloseArea())
// ����㦠�� ��室
    // �饬 ����� ��� ����㧪�
    use (cDir+"aPrix") new alias aPrix
    while (!aPrix->(eof()) .and. aPrix->data < dDate)
        aPrix->(Dbskip(1))
    end	
    // �⮨� �� ��ࢮ� ����� �㦭��� ����� ��� ����� 䠩��
    DbSelectArea("Prixod")
    __DbZap()
    Reindex
    // ����㦠�� ��室
    while (!aPrix->(eof()) .and. aPrix->data == dDate)
        Prixod->(DbAppend())
        For i := 1 to Prixod->(fCount())
            Prixod->(FieldPut(i,aPrix->(FieldGet(i))))
        Next
        aPrix->(Dbskip(1))
    end
    aPrix->(DbCloseArea())
    S_Err({"Ok!"," �� ��⮢� ","% ������ ENTER ��� �த������� ;"})
    if ostatok->(DbSeek(str(0,4)))
        nRecno := Alltrim(str(Ostatok->Summa,10))
        nRecno := ctod(Substr(nRecno,7,2)+"."+Substr(nRecno,5,2)+"."+Substr(nRecno,1,4))
        nLastRec := S_wSelect()
        S_wSelect(0)
        @ 23,00 say padc("����� �� "+S_cMonth(nRecno)+" ����� "+str(year(nRecno),4)+" �.",80) color sset[86]
        S_wSelect(nLastrec)
    End
RETURN( nil )

