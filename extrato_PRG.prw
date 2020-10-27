
/*/{Protheus.doc} FSWR006
Rotina para Auditoria de Fontes de uma pasta x RPO
@author A.Effting
@since 16/08/2018
@version P12 R17
@param
@return
/*/

#include "Protheus.ch"

#Define xCtrl chr(13)+chr(10)

User Function extratoPRG()

Local cArquivo := ''
Local cSrcPAD  := ''
Local aFontes := {}
Local aInfo := {}

If !U_INDEV000()
   Return
Endif
  

cArquivo := "extrato_customizacoes_ambiente_"+Alltrim(GetEnvServer())+".xrpo


SET DATE TO BRITISH 
SET CENTURY OFF 


/*
aFontes[i] = nome do fonte
*/
/*
aInfo[n,1] = Nome do fonte
aInfo[n,2] = Linguagem do fonte
aInfo[n,3] = Modo de compilação
aInfo[n,3] = Data da ultima compilacao
*/

cPath := cGetFile("",OemToAnsi("Path...DIR.SVN"),,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT)

aFontes := GetSrcArray("*")

If Empty(cPath)
	Return
Endif             

aSrcPad := {}

nHandle := MsfCreate(cPath+"\"+cArquivo,0)

If (nHandle <= 0)
    Aviso("TXT","Falha na criação do arquivo TXT.",{"Ok"},1)
Endif

//--Regua
//procRegua(Len(aDir))
           

nFontRPO := 0

For i := 1 To Len(aFontes)

	conout("B "+aFontes[i])

	//--Pega informações do fonte e retorna um vetor
	aInfo := GetAPOInfo(aFontes[i])
    

//    FWMsgRun(,{|oSay| AllWaysTrue() }, " Gravando ", allTrim(aInfo[1]) )

	//--Incrementa regua
//	incProc()

	//--Verifica se é funcao de usuario (BILD_USER)
	If aInfo[3] == "BUILD_USER"
	   fWrite(nHandle,"PERSONALIZADO|"+DtoC(aInfo[4])+"|"+allTrim(aInfo[1])+xCtrl)
	    nFontRPO++
	Endif
	
	
Next i

dDtBuild := StoD(SubStr(GetBuild(),14))

fWrite(nHandle,'AMBIENTE     : '+GetEnvServer()+xCtrl)
fWrite(nHandle,'RPO VERSAO   : '+GetRPORelease()+xCtrl)
fWrite(nHandle,'BUILD VERSAO : '+GetBuild()+xCtrl)
fWrite(nHandle,'DATA  VERSAO : '+Dtoc(dDtBuild)+xCtrl)
fWrite(nHandle,'DATA EXTRACAO: '+Dtoc(Date())+xCtrl)
fWrite(nHandle,'HORA EXTRACAO: '+Time()+xCtrl)
fWrite(nHandle,'TOTAL FONTES : '+Str(nFontRPO)+xCtrl)

//--fecha arquivo txt
fClose(nHandle)

Aviso("OK","Concluido.",{"Ok"},1)

Return