@{
    Form = @{
        Title = 'Informações do Script de Restauração'
        labelCenteredText = 'EXECUTAR APENAS UMA VEZ POR USUÁRIO!!!!'
        Button = 'Iniciar'
        Button2 = 'Fechar'
    }

    Dialog = @{
        msgLicenseDefault = 'Não foi possível verificar a licença do Office ou do cliente Office.'
        msgLicenseE3 = 'Nenhum cliente Outlook compatível com sua licença (extensionattribute6: ''E3'')'
        msgLicenseE1 = 'Sua licença não é compatível com o cliente Outlook atualmente instalado (extensionattribute6: ''E1'')'
        msgLicenseMF1 = 'Sua nova conta não possui caixa de e-mail, nenhuma configuração do cliente Outlook é necessária (extensionattribute6: ''MF1'')'
        msgLicenseF3 = 'Sua licença não é compatível com o cliente Outlook, apenas com o Outlook Web (extensionattribute6: ''F3'')'
        StartProcess = 'Início do processo de restauração'
        StartOutlook = 'Clique em OK para iniciar o Outlook e conclua a configuração.'
        StartOutlook_title = 'Informação'
        StartOutlook2 = 'Siga as instruções do Outlook e clique em OK.'
        StartOutlook2_title = 'Configurar Outlook'
        StartOutlook3 = 'Quando os primeiros e-mails chegarem, feche o Outlook e clique em OK.'
        StartOutlook3_title = 'Fechar Outlook'
        StopOutlook = 'Outlook foi fechado. O script continuará.'
        WaitOutlook = 'Aguardando o fechamento do Outlook... Tempo decorrido: {0} segundos'
        ErrorOutlook = 'O Outlook não foi fechado dentro do tempo limite. O script continuará.'
        AfterOutlook = 'O script continua...'
        StartNavigator = 'Após clicar em "OK", Chrome e Edge serão abertos.'
        StartNavigator_title = 'Informação'
        StopNavigator_title = 'Fechar navegadores'
        StopNavigator = 'Certifique-se de que Chrome e Edge estejam abertos. Clique em OK para fechar.'
        CopyAITDESK = 'Copiando a pasta AITDESK'
        CopyAITDESK_Status = 'Em andamento...'
        CopyAITDESK_Success = 'Pasta AITDESK copiada com sucesso para {0}.'
        CopyAITDESK_Error = 'A pasta AITDESK não existe em {0}. O script continuará sem copiá-la.'
        CopyChrome_Success = 'Arquivo de Favoritos do Chrome copiado com sucesso.'
        CopyChrome_Error = 'O arquivo de Favoritos do Chrome público não existe.'
        CopyEdge_Success = 'Arquivo de Favoritos do Edge copiado com sucesso.'
        CopyEdge_Error = 'O arquivo de Favoritos do Edge público não existe.'
        NetworkDrive_Error = 'Erro: Formato de linha incorreto no arquivo {0}.'
        NetworkDrive_NotFound = 'Erro: O arquivo {0} não foi encontrado.'
        TryConnectPrinter = 'Tentando conectar a impressora {0}...'
        PrinterConnected = 'A impressora {0} foi conectada.'
        DefaultPrinterOK = 'A impressora {0} foi definida como padrão.'
        DefaultPrinterKO = 'A impressora {0} não foi encontrada entre as impressoras conectadas.'
        PrinterConnected_Error = 'Erro ao conectar a impressora {0}: {1}'
        PrinterBadRow = 'Linha mal formatada: {0}'
        RestorePrinterOK = 'As impressoras de rede foram restauradas com sucesso.'
        RestorePrinterKO = 'Nenhuma impressora de rede foi encontrada no arquivo.'
        RestorePrinterNotFound = 'O arquivo de backup das informações das impressoras de rede não foi encontrado.'
        SignaturesOK = 'A pasta {0} foi copiada com sucesso para {1}'
        SignaturesKO = 'A pasta de origem {0} não existe.'
        Stream_Autocomplete_NotFound = 'Nenhum arquivo Stream_Autocomplete encontrado na pasta {0}.'
        Stream_Autocomplete_NotFound2 = 'Nenhum arquivo Stream_Autocomplete encontrado na pasta RoamCache do usuário atual.'
        QuickLaunch_success = 'A pasta de Lançamento Rápido foi copiada com sucesso para {0}'
        QuickLaunch_success_NotFound = 'A pasta de origem {0} não existe.'
        OneDrive_Success = 'O atalho para OneDrive - ACCOR foi criado na área de trabalho.'
        OneDrive_AlreadyExist = 'O atalho para OneDrive - ACCOR já existe na área de trabalho.'
        OneDrive_NotFound = 'A pasta OneDrive - ACCOR não existe no local especificado.'
        AitDesk = 'O programa foi iniciado com sucesso: {0}'
        Aitdesk_Success = 'O atalho foi criado na área de trabalho: $shortcutPath'
        Aitdesk_Error = 'Erro ao criar o atalho: $_'
        Aitdesk_NotFound = 'O programa não foi encontrado no local indicado: {0}. O script continuará.'
        End_Message = 'A restauração foi concluída. Um arquivo de resumo foi criado na sua área de trabalho.'
        End_Title = 'Restauração concluída'
        End_Log = 'O usuário clicou em OK na janela de fim de restauração.'
    }
    
    RTF = @{
        Text = @"
{\rtf1\ansi
\qc {\b\fs28 Programa destinado a países de língua portuguesa.}\par \pard\par
Este software realizará as seguintes operações:\par
1. Iniciará a configuração do Outlook, siga as instruções na tela.\par
2. Abrirá os navegadores Chrome e Edge para criar os subdiretórios necessários para transferir seus favoritos.\par
3. Exibirá uma mensagem para fechar os navegadores. Clique em OK quando os dois navegadores estiverem abertos.\par
4. Restaurará os favoritos do Chrome e Edge.\par
5. Criará atalhos para as pastas públicas em suas próprias pastas.\par
6. Reconectará os drives de rede (Forum e outros).\par
7. Reconectará as impressoras de rede.\par
8. Restaurará as assinaturas de e-mails.\par
9. Restaurará o preenchimento automático do Outlook.\par
10. Restaurará a barra de Lançamento Rápido (Quick Launch).\par
11. Criará um atalho para o OneDrive na área de trabalho.\par
12. Reposicionará a pasta AitDesk no perfil do usuário.\par
13. Iniciará o software AccorDesktop (se disponível).\par
14. Criará um atalho para o AccorDesktop na área de trabalho (se existente). \par

\par \par
\qc {\b\fs28 Clique em 'Iniciar' para começar a restauração.}\par \pard
}
"@
    }

    function = @{
        writeLogError = 'Erro ao escrever no arquivo de log: {0}'
    }

    Step = @{
        Outlook = 'Passo {0}/{1}: Iniciando o Outlook'
        Browsers = 'Passo {0}/{1}: Iniciando os navegadores'
        AITDESK = 'Passo {0}/{1}: Configuração para AitDesk'
        Favorites = 'Passo {0}/{1}: Restaurando favoritos'
        Shortcut = 'Passo {0}/{1}: Configurando atalhos'
        networkDrive = 'Passo {0}/{1}: Restaurando drives de rede'
        networkprinter = 'Passo {0}/{1}: Restaurando impressoras de rede'
        Signatures = 'Passo {0}/{1}: Restaurando assinaturas'
        Stream_Autocomplete = 'Passo {0}/{1}: Restaurando preenchimento automático'
        QuickLaunch = 'Passo {0}/{1}: Restaurando a barra de Lançamento Rápido'
        ShortcutOD = 'Passo {0}/{1}: Configurando atalhos para OneDrive'
        LaunchAITDESK = 'Passo {0}/{1}: Iniciando AitDesk'
        endoverlay = 'Fim'
    }
    
    Path = @{
        logFile = 'RestauraçãoLog.txt'
        FavoritesChrome = 'Favoritos Chrome'
        FavoritesEdge = 'Favoritos Edge'
        network = 'Rede'
        FileNetWorkDrive = 'InformacoesDrivesRede.txt'
        FilePrinter = 'InformacoesImpressorasRede.txt'
        SignatureOutlook = 'Assinaturas Outlook'
        Stream_Autocomplete = 'Preenchimento automático Outlook'
        QuickLaunch = 'Lançamento Rápido'
    }
}
