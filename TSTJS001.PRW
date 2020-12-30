/*//#########################################################################################
Projeto : DM Consultoria
Modulo  : Todos
Fonte   : TSTJS001
Chamado : .
*///#########################################################################################
#INCLUDE 'TOTVS.CH'

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSTJS001

@description  Exemplo de Json carregando em tela

@author Diego Donatti Moura
@since 03/05/2020
@version 12.1.25

/*/
//--------------------------------------------------------------------------------------------
User Function TSTJS001()
    Local oJson := JsonObject():New()
    Local nX    := 0
    Local nTotal:= 10

    oJson["itens"] := {}
    For nX := 1 To nTotal
        aAdd(oJson["itens"],JsonObject():New())
        oJson["itens"][nX]["item"] 		:= nX
        oJson["itens"][nX]["codigo"] 	:= StrZero(nX,6)
        oJson["itens"][nX]["descricao"] := "DESCRICAO " + cValToChar(nX) + " DE " + cValToChar(nTotal)
    Next nX

    //Montando Tela
    oModal:= FWDialogModal():New()
    oModal:SetEscClose(.T.)
    oModal:setTitle("Consulta")
    oModal:setSubTitle("Operações x Operador")
    oModal:setSize(300, 400)
    oModal:enableAllClient()
    oModal:createDialog()
    oModal:addCloseButton(nil,"Fechar")

    oContainer:=TPanel():New( ,,,oModal:getPanelMain() )
    oContainer:Align:=CONTROL_ALIGN_ALLCLIENT

    oFWLayer:= FWLayer():New()
    oFWLayer:Init(oContainer,.F.,.F.)
    oFWLayer:addLine('LIN1' ,100,.F.)
    oFWLayer:addCollumn('COL1' ,100,.F.,'LIN1')
    oFWLayer:addWindow('COL1','WIN1','Filtro' ,100/*nPercHeight*/,/*lEnable*/,/*lFixed*/, /*bAction*/,'LIN1',/*bGotFocus*/ )

    oWin01 := oFWLayer:getWinPanel('COL1','WIN1','LIN1')

    oBrowse:= FWBrowse():New(oWin01)
    oBrowse:SetDataArray()
    oBrowse:SetArray(oJson["itens"])


    If Len(oJson["itens"]) > 0

        aStruct:= oJson["itens"][1]:GetProperties()

        For nX:= 1 To Len(aStruct)

            oColumn:= FWBrwColumn():New()
            oColumn:SetData(&("{||oJson['itens'][oBrowse:nAT]['"+aStruct[nX]+"']}"))
            oColumn:SetTitle(aStruct[nX])
            oColumn:SetSize(3)
            oBrowse:SetColumns({oColumn})

        Next nX

    EndIf

    oBrowse:DisableReport()
    oBrowse:DisableLocate()
    oBrowse:DisableFilter()
    oBrowse:DisableConfig()
    oBrowse:DisableSaveConfig()
    oBrowse:DisableSeek()

    oBrowse:Activate()
    oModal:Activate()

Return