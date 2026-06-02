@{
    Form = @{
        Title = 'Informações do Script de Backup'
        labelCenteredText = 'EXECUTAR APENAS UMA VEZ POR COMPUTADOR!!!!'
        Button = 'Iniciar'
        progressFormText = 'Progresso do Backup'
    }
    
    RTF = @{
        Text = @"
{\rtf1\ansi

Este software realizará as seguintes operações:\par
\par
1. Copiar suas pastas Desktop, Documentos, Imagens, Vídeos, Downloads, Favoritos, Contatos e Aitdesk (se presente) do seu perfil de usuário para a pasta Pública.\par
2. Recuperação dos favoritos do Google Chrome e Microsoft Edge {\b\fs28 mas não as senhas.}\par
3. Recuperação das suas assinaturas de e-mail.\par
4. Recuperação das entradas de preenchimento automático do Outlook.\par
5. Recuperação das informações dos drives de rede e impressoras de rede.\par
6. Recuperação da pasta de lançamento rápido.\par
7. Criação de um atalho para FOLS (se disponível).\par
8. Criação de um atalho para o Outlook Web para a caixa de e-mail pessoal e caixas de e-mail delegadas.\par
9. Copiar a pasta inteira do OneDrive para a pasta Pública.\par
\par
Os documentos salvos estarão disponíveis para cada novo usuário.\par
\par
Clique em 'Iniciar' para iniciar o backup.\par
\par
{\b\fs18 PS: Durante o backup, duplicatas aparecerão na área de trabalho, o que é normal. Após a conexão com sua nova conta, restará apenas uma cópia de cada arquivo.}\par
\par
}
"@
    }
    
    ProgressMessage = @{
        progressText = 'Progresso: {0}%'
        ProgressMessageCopyFolder = 'Copiando a pasta: {0}'
        ProgressMessageCopythrow = 'Robocopy falhou com o código de saída {0}'
        ProgressMessageCopyError = 'Erro ao copiar {0} para {1}: {2}'
        ProgressMessageCopySucces = 'Sucesso ao copiar {0} para {1}'        
        ProgressMessageCopyFolderIgnore = 'A pasta {0} não existe e será ignorada.'
        ProgressMessageChrome = 'Recuperação dos favoritos do Chrome concluída.'
        ProgressMessageEdge = 'Recuperação dos favoritos do Edge concluída.'
        ProgressMessageSignature = 'Cópia da pasta de assinaturas do Outlook concluída.'
        ProgressMessageStream_Autocomplete = 'O arquivo {0} foi copiado para {1}'
        ProgressMessageStream_AutocompleteIgnore = 'Nenhum arquivo Stream_Autocomplete encontrado em {0}'        
        ProgressMessageNetworkDrive = 'Recuperação das informações dos drives de rede concluída.'
        ProgressMessageSavePrinters = 'A impressora {0} foi salva'
        ProgressMessagePrinters = 'As informações das impressoras de rede foram salvas com sucesso no arquivo: {0}'
        ProgressMessagePrintersError = 'Erro ao salvar as informações das impressoras de rede: {0}'
        ProgressMessagePrintersEnd = 'Recuperação das informações das impressoras de rede concluída.'        
        ProgressMessageQuickLaunch = 'A pasta de lançamento rápido foi copiada com sucesso.'
        ProgressMessageQuickLaunchIgnore = 'A pasta de lançamento rápido não foi encontrada em {0}.'
        ProgressMessageMainOutlook = 'O atalho principal do Outlook foi criado com sucesso na Área de Trabalho'
        ProgressMessageMainOutlookError = 'Erro ao criar o atalho principal do Outlook: {0}'
        ProgressMessageUsersOutlook = 'O atalho do Outlook para {0} foi criado com sucesso na Área de Trabalho'
        ProgressMessageUsersOutlookError = 'Erro ao criar o atalho do Outlook para $username: {0}'
        ProgressMessageVariableFLS1Found = 'Variável encontrada: {0}'
        ProgressMessageVariableFLS1Value = 'Valor da variável: {0}'
        ProgressMessageURLBuilded = 'URL construída: {0}'
        ProgressMessageURLPath = 'Caminho do atalho: {0}'
        ProgressMessageURLSuccess = 'O atalho da internet foi criado com sucesso no local: {0}'
        ProgressMessageURLInfo = 'URL do atalho: {0}'
        ProgressMessageURLError = 'Erro ao criar o atalho: {0}'
        ProgressMessageURLOK = 'O arquivo de atalho existe.'
        ProgressMessageURLKO = 'O arquivo de atalho não foi criado.'        
        ProgressMessageShortCutFols = 'O atalho da Internet para o Fols foi criado com sucesso no local: {0}'
        ProgressMessageNOVAR = 'Nenhuma variável de ambiente contendo ''-fls1'' foi encontrada em seu valor.'
        ProgressMessageLISTVAR = 'Variáveis de ambiente relevantes:'
        ProgressMessageVARNameValue = '{0} = {1}'
        ProgressMessageFolsNotFound = 'Não foi possível encontrar o nome do servidor FOLS.'
        ProgressMessageOneDrive = 'Cópia da pasta do OneDrive para a pasta Pública concluída.'
        ProgressMessageOneDriveKO = 'A pasta do OneDrive não foi encontrada.'
        ProgressMessageDiskSpaceCheckStart = 'Verificando o espaço em disco na unidade {0}...'
        ProgressMessageDiskSpaceInsufficient = 'Faltam {0} GB de espaço em disco para a cópia de segurança. Contacte o seu SPOC.'
        ProgressMessageDiskSpaceCheckError = 'Erro ao verificar o espaço em disco na unidade {0}. Certifique-se de que a unidade está disponível.'

        # Títulos das janelas
        TitleDiskSpaceError = "Erro na Verificação do Espaço em Disco"
    }

    Path = @{
        resumeFile = 'relatorio_backup.txt'
        excludeBackuplnk = 'Backup_perfil.lnk'
        excludeBackupexe = 'Backup_perfil.exe'
        FavoritesChrome = 'Favoritos Chrome'
        FavoritesEdge = 'Favoritos Edge'
        SignatureOutlook = 'Assinaturas Outlook'
        Stream_Autocomplete = 'Preenchimento automático Outlook'
        network = 'Rede'
        FileNetWorkDrive = 'InformacoesDrivesRede.txt'
        FilePrinter = 'InformacoesImpressorasRede.txt'
        QuickLaunch = 'Lançamento Rápido'
        OutlookPrincipal = 'Email Pessoal.lnk'
        OutlookPrincipal_Description = 'Atalho para o Outlook Principal'
        OutlookDelegue = 'Email_{0}.lnk'
        OutlookDelegue_Description = 'Atalho para o Outlook para {0}'
        RestoreShortcut = 'Restauracao_perfil.lnk'
        RestoreShortcut_Description = 'Iniciar o script de restauração do perfil'
    }
    
    PopUp = @{
        Text = 'Backup concluído.'    
    }    
}
