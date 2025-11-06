workspace "SIAE - Sistema Integrado à Assistência Estudantil" {

    model {

        /***********************
         * NÍVEL 1 - CONTEXTO *
         ***********************/
        pessoa_aluno = person "Aluno" {
            description "Estudante da UFC que necessita de auxílios estudantis para manter sua permanência na universidade."
        }

        pessoa_assistente = person "Assistente" {
            description "Membro da equipe de assistência estudantil responsável por avaliar e gerenciar as solicitações de auxílio."
        }

        sistema_api_matricula = softwareSystem "APIValidaMatricula" {
            description "API externa da UFC que valida a matrícula ativa do aluno durante o cadastro."
            tags "External System"
        }

        sistema_smtp = softwareSystem "SMTP/API Gmail" {
            description "Serviço externo utilizado para envio de notificações sobre o status das solicitações."
            tags "External System"
        }

        /*******************************
         * SISTEMA PRINCIPAL - SIAE
         *******************************/
        sistema_siae = softwareSystem "SIAE - Sistema Integrado à Assistência Estudantil" {
            description "Sistema que centraliza o processo de solicitação e avaliação de auxílios estudantis, além de facilitar a verificação de status."

            /************************
             * NÍVEL 2 - CONTAINERS *
             ************************/
            login_page = container "LoginPage" {
                tags "WebApp"
                technology "React, TypeScript, Axios"
                description "Tela acessada por alunos e assistentes para login e cadastro."
            }

            aluno_pages = container "AlunoPages" {
                tags "WebApp"
                technology "React, TypeScript, Axios"
                description "Interface de acesso do aluno para acompanhar status, enviar documentos e solicitar auxílios."
            }

            assistente_page = container "AssistentePage" {
                tags "WebApp"
                technology "React, TypeScript, Axios"
                description "Interface utilizada pelos assistentes para avaliar e gerenciar solicitações."
            }

            api_controller = container "APIController" {
                technology "Node.js, Express"
                description "Responsável por processar as requisições REST, orquestrando controladores e serviços internos."

                /************************
                 * NÍVEL 3 - COMPONENTES *
                 ************************/
                auth_controller = component "AuthController" {
                    tags "Controler"
                    technology "Node.js, JWT, Bcrypt"
                    description "Gerencia o login e cadastro de aluno e assistente."
                }

                auth_service = component "AuthService" {
                    tags "Service"
                    technology "Node.js, JWT, Bcrypt"
                    description "Implementa regras de autenticação, valida credenciais e gera tokens JWT."
                }

                auth_repository = component "AuthRepository" {
                    tags "Repository"
                    technology "PostgreSQL, Prisma ORM"
                    description "CRUD de credenciais de autenticação no banco de dados."
                }

                sigaa_service = component "SigaaService" {
                    tags "Service"
                    technology "Node.js, Express"
                    description "Integra com a API do SIGAA para validar matrícula de alunos."
                }

                solicitacao_controller = component "SolicitacaoController" {
                    tag "Controler"
                    technology "Node.js, Express"
                    description "Recebe requisições REST relacionadas a solicitações (criar, consultar, atualizar, listar)."
                }

                solicitacao_service = component "SolicitacaoService" {
                    tags "Service"
                    technology "Node.js, Express"
                    description "Gerencia a lógica de criação, atualização e validação das solicitações de auxílio."
                }

                solicitacao_repository = component "SolicitacaoRepository" {
                    tags "Repository"
                    technology "PostgreSQL, Prisma ORM"
                    description "Responsável por armazenar e recuperar solicitações de auxílio."
                }

                documento_controller = component "DocumentoController" {
                    tag "Controler"
                    technology "Node.js, Express"
                    description "Recebe requisições REST relacionadas ao cadastro e consulta de documentos do aluno."
                }

                documento_service = component "DocumentoService" {
                    tags "Service"
                    technology "Node.js, Express"
                    description "Gerencia o armazenamento e utilização de documentos enviados pelos alunos."
                }

                documento_repository = component "DocumentoRepository" {
                    tags "Repository"
                    technology "PostgreSQL, Prisma ORM"
                    description "Armazena e recupera informações de documentos e dados de alunos."
                }

                notification_service = component "NotificationService" {
                    tags "Service"
                    technology "Node.js, Express"
                    description "Gerencia o envio de notificações por e-mail utilizando o SMTP/API Gmail."
                }

                jwt_middleware = component "JWTMiddleware" {
                    tags "JWT"
                    technology "Node.js, JWT"
                    description "Middleware que intercepta e valida tokens JWT em rotas protegidas."
                }
            }

            banco_dados = container "Banco de Dados" {
                tag "Database"
                technology "PostgreSQL"
                description "Armazena informações de solicitações, documentos e autenticações."
            }

            /***********************
             * RELACIONAMENTOS DO SISTEMA
             ***********************/
            pessoa_aluno -> sistema_siae "Acessa para solicitar auxílios" "sync" 
            pessoa_assistente -> sistema_siae "Acessa para avaliar solicitações" "sync" 

            sistema_siae -> sistema_api_matricula "Valida matrícula do aluno" "sync" 
            sistema_siae -> sistema_smtp "Envia solicitação de envio de notificação" "sync" 
            sistema_smtp -> pessoa_aluno "Notifica status da solicitação" "sync" 
            sistema_smtp -> pessoa_assistente "Notifica chegada de solicitação" "sync" 

            /************************************
             * RELACIONAMENTOS ENTRE CONTAINERS *
             ************************************/
            pessoa_aluno -> login_page "Acessa a tela de login/cadastro" "sync" 
            pessoa_aluno -> aluno_pages "Acessa páginas do aluno" "sync" 
 
            pessoa_assistente -> login_page "Acessa a tela de login" "sync" 
            pessoa_assistente -> assistente_page "Acessa páginas do assistente" "sync" 

            login_page -> auth_controller "POST /login (realiza login)" "sync" 
            aluno_pages -> solicitacao_controller "POST/GET /solicitacoes (criar/consultar solicitações)" "sync" 
            aluno_pages -> documento_controller "POST /documentos (upload de documentos)" "sync" 
            assistente_page -> solicitacao_controller "GET /solicitacoes (visualizar solicitações)" "sync" 

            /**********************************
             * RELACIONAMENTOS ENTRE COMPONENTES *
             **********************************/
            auth_controller -> auth_service "Processa autenticação e cadastro" "sync" 
            auth_service -> auth_repository "Leitura e gravação de credenciais" "sync" 
            auth_service -> sigaa_service "Valida matrícula via API SIGAA" "sync" 
            
            solicitacao_controller -> solicitacao_service "Envia dados de solicitação para processamento" "sync" 
            solicitacao_service -> solicitacao_repository "Lê e grava solicitações no banco" "sync" 
            solicitacao_service -> notification_service "Dispara e-mails de notificação" "sync" 
            
            documento_controller -> documento_service "Gerencia upload e consulta de documentos" "sync" 
            documento_service -> documento_repository "Armazena/recupera documentos" "sync" 
            
            notification_service -> sistema_smtp "Envia notificações via Gmail" "async" "RelationshipAsync" 
            sigaa_service -> sistema_api_matricula "Solicita validação de matricula" "sync" 
            jwt_middleware -> auth_service "Valida token JWT nas rotas protegidas" "sync" 
            
            auth_repository -> banco_dados "Armazena dados de autenticação" "sync" 
            solicitacao_repository -> banco_dados "Armazena dados de solicitações" "sync" 
            documento_repository -> banco_dados "Armazena documentos" "sync" 

        }
    
    }

    /************************
     * VIEWS - Diagramas
     ************************/
    views {
        
        systemContext sistema_siae "C1_Context" {
            include *
            autolayout lr
        }

        container sistema_siae "C2_Containers" {
            include *
            autolayout lr
        }

        component api_controller "C3_Components" {
            include *
            autolayout lr
        }

            
        styles {
            element "Element" {
                color #0773af
                stroke #0773af
                strokeWidth 7
                shape roundedbox
            }
        
            element "Person" {
                shape person
            }
    
            element "Software System" {
                shape roundedbox
            }
            element "Container" {
                shape roundedbox
            }
            element "Component" {
                shape component
                width 550
            }
            element "JWT" {
                color "#9673a6"
                stroke "#9673a6"
            }

            #################################################################
            element "Controler" {
                # background "#DAE8FC"
                color "#4b6385"
                stroke "#4b6385"
            }
            element "Service"{
                # background "#D5E8D4"
                color "#6d9656"
                stroke "#6d9656"
                
            }
            element "Repository" {
                # background "#FFE6CC"
                color "#D79B00"
                stroke "#D79B00"
            }
            ################################################################# 
            element "External System" {
                # background "#999999"
                # color "#ffffff"
                shape roundedbox
                stroke "#999999"
                color "#999999"
            }
    
            element "Database" {
                shape cylinder
                color "#034926"
                stroke "#034926"
                strokeWidth 10
            }
            
            element "WebApp"{
                shape WebBrowser
            }
    
            relationship "RelationshipAsync" {
                dashed true
            }
            relationship "Relationship" {
                color "#555555"
                thickness 2
                dashed false
                fontSize 20
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}
