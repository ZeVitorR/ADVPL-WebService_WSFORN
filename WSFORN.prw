#include "totvs.ch"
#include "restful.ch"
#include "topconn.ch"

WSRESTFUL WSFORN DESCRIPTION "WebService para consultar dos dados de fornecedores"

    WSDATA nome as STRING
    WSDATA cnpj  as STRING
    WSDATA codforn as STRING
    WSDATA num as STRING
    WSDATA filialforn as STRING

    WSMETHOD GET RAZAO; 
    DESCRIPTION "Retorna o CNPJ do fornecedor pela Razao."; 
    WSSYNTAX "/WSFORN/RAZAO";
    PATH "/RAZAO"

    WSMETHOD GET FORNECEDOR; 
    DESCRIPTION "Retorna informacoes do fornecedor pelo CNPJ."; 
    WSSYNTAX "/WSFORN/FORNECEDOR";
    PATH "/FORNECEDOR"

    WSMETHOD GET TITULO; 
    DESCRIPTION "Retorna informacoes do titulos a pagar do fornecedor."; 
    WSSYNTAX "/WSFORN/TITULO";
    PATH "/TITULO"
    
    WSMETHOD GET VERITIT; 
    DESCRIPTION "Retorna a informação se fornecedor tem titulo a vencer."; 
    WSSYNTAX "/WSFORN/VERITIT";
    PATH "/VERITIT"

END WSRESTFUL

WSMETHOD GET RAZAO WSRECEIVE nome1 WSSERVICE WSFORN

    // Variaveis.
    local   cNome    := self:nome
    local   oForne  := JSonObject():New()
    local   cResponse := ""
    local   nCount    := 1
    local   cAlias    := GetNextAlias()
    Local   aList     := {}
    Local   cquery    := ""


    cquery := " SELECT A2_COD, A2_NOME, A2_CGC,"
    cquery += "        A2_CEP, A2_MUN,  A2_EST,"
    cquery += "        A2_END, A2_BAIRRO"
    cquery += " FROM "  + RetSqlTab("SA2")
    cquery += " WHERE D_E_L_E_T_ = '' "
    cquery += "       AND A2_NOME LIKE '%"+cNome+"%' "
    cquery += " ORDER BY A2_NOME"

    TCQUERY cQuery New Alias (cALIAS)    

    // Posiciona no topo.
    (cAlias)->(DbGoTop())

    While !((cAlias)->(EOF()))
        aAdd(aList,JSonObject():New())
            aList[nCount][ 'CodFornece' ] := AllTrim((cAlias)->A2_COD)
            aList[nCount][ 'NomeForne' ]  := AllTrim((cAlias)->A2_NOME)
            aList[nCount][ 'CnpjForne' ]  := AllTrim((cAlias)->A2_CGC)
            aList[nCount][ 'CepForne' ]   := AllTrim((cAlias)->A2_CEP)
            aList[nCount][ 'Cidade' ]     := AllTrim((cAlias)->A2_MUN)
            aList[nCount][ 'Estado' ]     := AllTrim((cAlias)->A2_EST)
            aList[nCount][ 'Endereco' ]   := AllTrim((cAlias)->A2_END)
            aList[nCount][ 'Bairro' ]     := AllTrim((cAlias)->A2_BAIRRO)
        nCount++

        (cAlias)->(DBSKIP())
    end   

    (cAlias)->(DBCLOSEAREA())

    oForne["Fornecedor"] := aList

    // Json to String
    cResponse := oForne:toJson()

    // Define tipo de retorno.
    self:SetContentType('application/json')

    // Define resposta.
    self:SetResponse( EncodeUTF8( cResponse ) )

return .T.

WSMETHOD GET FORNECEDOR WSRECEIVE cnpj WSSERVICE WSFORN
    // Variaveis
    Local  cCNPJ   := iif(valtype(self:cnpj)=="U", "", self:cnpj)
    Local  oForne  := JSonObject():New()
    Local nCount := 1
    Local aList  := {}
    Local cAlias := GetNextAlias()

    
    BEGINSQL ALIAS cAlias
        SELECT SA2.A2_COD, SA2.A2_NOME, SA2.A2_CGC,
            SA2.A2_CEP, SA2.A2_MUN, SA2.A2_EST,
            SA2.A2_END, SA2.A2_BAIRRO
        FROM %table:SA2% SA2
        WHERE SA2.A2_CGC = %exp:cCNPJ%
        AND SA2.%notDel%
    ENDSQL
    //contando quantos registro vieram e armazeno na variavel nRegistros
    Count to nRegistros    
    (cAlias)->(dbGoTop())     
    While !((cAlias)->(EOF()))
        aAdd(aList,JSonObject():New())
            aList[nCount][ 'CodFornece' ] := AllTrim((cAlias)->A2_COD)
            aList[nCount][ 'NomeForne' ]  := AllTrim((cAlias)->A2_NOME)
            aList[nCount][ 'CnpjForne' ]  := AllTrim((cAlias)->A2_CGC)
            aList[nCount][ 'CepForne' ]   := AllTrim((cAlias)->A2_CEP)
            aList[nCount][ 'Cidade' ]     := AllTrim((cAlias)->A2_MUN)
            aList[nCount][ 'Estado' ]     := AllTrim((cAlias)->A2_EST)
            aList[nCount][ 'Endereco' ]   := AllTrim((cAlias)->A2_END)
            aList[nCount][ 'Bairro' ]     := AllTrim((cAlias)->A2_BAIRRO)
        nCount++
        (cAlias)->(DBSKIP())
    end
    (cAlias)->(DBCLOSEAREA())

    oForne["DadosFornecedor"] := aList
    
    // Json to String
    cResponse := oForne:toJson()

    // Define tipo de retorno.
    self:SetContentType('application/json')

    // Define resposta.
    self:SetResponse( EncodeUTF8( cResponse ) )

return .T.

WSMETHOD GET TITULO WSRECEIVE codforn WSSERVICE WSFORN

    // Variaveis.
    local   cCodforn  := self:codforn
    local   oForne    := JSonObject():New()
    local   cResponse := ""
    local   nCount    := 1
    local   cAlias    := GetNextAlias()
    Local   aList     := {}


    BEGINSQL ALIAS cAlias
        SELECT SE2.E2_NUM,  SE2.E2_FILIAL,
               SE2.E2_VALOR,SE2.E2_PREFIXO
        FROM %table:SE2% SE2
        WHERE SE2.E2_FORNECE = %exp:cCodforn%
        AND SE2.E2_BAIXA = ''
        AND SE2.%notDel%
    ENDSQL   

    // Posiciona no topo.
    (cAlias)->(DbGoTop())

    While !((cAlias)->(EOF()))
        aAdd(aList,JSonObject():New())
            aList[nCount][ 'Filial' ]  := AllTrim((cAlias)->E2_FILIAL)
            aList[nCount][ 'Prefixo' ]   := AllTrim((cAlias)->E2_PREFIXO)
            aList[nCount][ 'Num' ]        := AllTrim((cAlias)->E2_NUM)
            aList[nCount][ 'Valor' ]  := (cAlias)->E2_VALOR

        nCount++

        (cAlias)->(DBSKIP())
    end   

    (cAlias)->(DBCLOSEAREA())

    oForne["TitForn"] := aList

    // Json to String
    cResponse := oForne:toJson()

    // Define tipo de retorno.
    self:SetContentType('application/json')

    // Define resposta.
    self:SetResponse( EncodeUTF8( cResponse ) )

return .T.

WSMETHOD GET VERITIT WSRECEIVE codforn WSSERVICE WSFORN

    // Variaveis.
    local   cCodforn    := self:codforn
    local   oForne      := JSonObject():New()
    local   cResponse   := ""
    local   nCount      := 1
    local   cAlias      := GetNextAlias()
    Local   aList       := {}
    local   cData       := DTOS(LastDate(Date()))


    BEGINSQL ALIAS cAlias
        SELECT SE2.E2_NUM,  SE2.E2_FILIAL,
               SE2.E2_VALOR,SE2.E2_PREFIXO,
               SE2.E2_VENCREA,SE2.E2_FORNECE,
               SA2.A2_NOME
        FROM %table:SE2% SE2
        INNER JOIN %table:SA2% SA2 ON SA2.A2_COD = SE2.E2_FORNECE
        WHERE SE2.E2_BAIXA = ''
        AND SE2.E2_FORNECE = %exp:cCodforn%
        AND SE2.E2_VENCREA < %exp:cData%
        AND SE2.%notDel%
        ORDER BY SE2.E2_VENCREA
    ENDSQL   

    // Posiciona no topo.
    (cAlias)->(DbGoTop())
    
    While !((cAlias)->(EOF()))
        aAdd(aList,JSonObject():New())
            aList[nCount][ 'Filial' ]       := AllTrim((cAlias)->E2_FILIAL)
            aList[nCount][ 'Prefixo' ]      := AllTrim((cAlias)->E2_PREFIXO)
            aList[nCount][ 'Num' ]          := AllTrim((cAlias)->E2_NUM)
            aList[nCount][ 'Valor' ]        := (cAlias)->E2_VALOR
            aList[nCount][ 'VencReal' ]     := SUBSTR((cAlias)->E2_VENCREA   ,7,2)+'/'+SUBSTR((cAlias)->E2_VENCREA   ,5,2)+'/'+left((cAlias)->E2_VENCREA  ,4)
            aList[nCount][ 'Qtd' ]          := DateDiffDay(STOD((cAlias)->E2_VENCREA), Date())
            aList[nCount][ 'CodForn' ]      := AllTrim((cAlias)->E2_FORNECE)
            aList[nCount][ 'Fornecedor' ]   := AllTrim((cAlias)->A2_NOME)
            aList[nCount][ 'VencRealI' ]    := (cAlias)->E2_VENCREA
            aList[nCount][ 'data']          := cData
            if (cAlias)->E2_VENCREA > DTOS(Date())
                aList[nCount][ 'VeriVenc']  := 'Irá vencer'
            else
                aList[nCount][ 'VeriVenc']  := 'Venceu'
            endif
        nCount++

        (cAlias)->(DBSKIP())
    end   

    (cAlias)->(DBCLOSEAREA())

    oForne["TitForn"] := aList

    // Json to String
    cResponse := oForne:toJson()

    // Define tipo de retorno.
    self:SetContentType('application/json')

    // Define resposta.
    self:SetResponse( EncodeUTF8( cResponse ) )

return .T.
