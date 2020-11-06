#include "protheus.ch"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} SX2JSON
Converte o dicionário do protheus para XML
@sample		SX2JSON()
@author		Alessandro Arnold
@since	    10/2017
@version 	P11
/*/
//-------------------------------------------------------------------
User Function SX2JSON

Local aArqSX :={}
Local cVersao := 'P12'
aAdd(aArqSX,{'SX2',1,'X2_CHAVE'}) 
//aAdd(aArqSX,{'SIX',1,'INDICE'}) 
//aAdd(aArqSX,{'SX3',2,'X3_ARQUIVO'}) 
//aAdd(aArqSX,{'SX7',1,'X7_CAMPO'}) 
//aAdd(aArqSX,{'SXA',1,'XA_ALIAS'}) 


//oRegua:=	MsNewProcess():New()
//oRegua:Activate()                   
//loRegua:SetRegua1(ProcRegua(Len(aArqSX)))
_cTabINI := Space(3)
_cTabFIM := Space(3)

Private aPergs     := {}
aRet := {}
	
aAdd( aPergs ,{1,"Tabela De :  ",_cTabIni ,"@!",'!Empty(mv_par01)','SM0','.T.',03,.T.})
aAdd( aPergs ,{1,"Tabela ate:  ",_cTabFIM ,"@!",'!Empty(mv_par02)','NNR','.T.',03,.T.})
If ParamBox(aPergs ,'',aRet)
   _cTabINI := Alltrim(aRet[1])
   _cTabFIM := Alltrim(aRet[2])
Else
   Return			                 
Endif


cPathExp := cGetFile(,OemToAnsi("Path...XRPO"),,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
	      
For nA := 1 to Len(aArqSX)
             
	cTabela := aArqSX[nA][01]
	nOrdem  := aArqSX[nA][02]                   
	cCond   := aArqSX[nA][03]
    
    cChvBusca := _cTabINI
	If cTabela $ 'SX3|SX7|'
	   If Substr(_cTabINI,1,1) == 'S'
	      cChvBusca := Substr(_cTabINI,2,2)+"_"
	   Endif	  
	Endif

//	oRegua:IncRegua1(cTabela)
	DbSelectArea(cTabela)
	DbSetOrder(nOrdem)                       
	DbSeek(cChvBusca)


    cChave  := &cCond
	//oRegua:SetRegua2(RecCount())
	aEstrutura := dbStruct()                                                                              
	Do While !Eof() .and. SUBSTR(cChave,1,3) <= _cTabFIM

       cChave   := &cCond
       cFamilia := Substr(cChave,1,3)

       FWMsgRun(,{|oSay| AllWaysTrue() }, " ATUALIZANDO ", cTabela+'-'+cChave)
                                                                                        	
       If Substr(cChave,1,3) < _cTabINI .or. Substr(cChave,1,3) > _cTabFIM  
          DbSkip()
   	    Loop
	   Endif

//	   cArquivo:= cVersao+'_'+cEmpAnt+'_'+cTabela+'_'+alltrim(cChave)+"_"+GetEnvServer()+".dic"   
	  //cArquivo:= cVersao+'_'+cEmpAnt+'_'+cTabela+'_'+alltrim(cChave)+".dic"   
      //cArquivo:= cVersao+'_'+cEmpAnt+'_'+cTabela+'_familia_'+'_'+alltrim(cFamilia)+"_"+GetEnvServer()+".json"   
	  cArquivo:= cVersao+'_'+cEmpAnt+'_'+cTabela+'_familia_'+'_'+alltrim(cFamilia)+"_"+GetEnvServer()+".json"   
	                               
	  nHandle := MsfCreate(cPathExp+cArquivo,0)
      If (nHandle <= 0)
          Aviso("TXT","Falha na criação do arquivo TXT.",{"Ok"},1)
      Endif

       //Do While !Eof() .and. &cCond == cChave
       oJson := JSonObject():w()
       oJson['1-Tabela'] := cTabela+CRLF
	   oJson['2-Chave']  := cChave+CRLF
	   oJson['3-Detalhes'] := JSonObject():New()

	   Do While !Eof() .and. substr(&cCond,1,3) == cFamilia
    	
     	   MsgRun(cTabela+" "+cChave, "Exportando"  , {||AllwaysTrue() })
           For nB := 1 to Len(aEstrutura)
    		   cCampo    := aEstrutura[nB][1] 
			   xConteudo := FieldGet(nB)
			   If aEstrutura[nB][2] == 'N'
			      xConteudo := Str(xConteudo)
			   Endif
			   If aEstrutura[nB][2] == 'D'
			      xConteudo := Ctod(xConteudo)
			   Endif
			   oJson['3-Detalhes'][aEstrutura[nB][1]] := xConteudo+CRLF
		   Next	
		   cJson := oJson:ToJson()
           fWrite(nHandle,cJson) 
		   DbSkip()
		Enddo
        fClose(nHandle)
		Alert('arquivo criado')
	Enddo
	
Next

Return
