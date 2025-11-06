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
                    tags "Controler", "FormaPadrao"
                    technology "Node.js, JWT, Bcrypt"
                    description "Gerencia o login e cadastro de aluno e assistente."
                }

                auth_service = component "AuthService" {
                    technology "Node.js, JWT, Bcrypt"
                    description "Implementa regras de autenticação, valida credenciais e gera tokens JWT."
                }

                auth_repository = component "AuthRepository" {
                    technology "PostgreSQL, Prisma ORM"
                    description "CRUD de credenciais de autenticação no banco de dados."
                }

                sigaa_service = component "SigaaService" {
                    technology "Node.js, Express"
                    description "Integra com a API do SIGAA para validar matrícula de alunos."
                }

                solicitacao_controller = component "SolicitacaoController" {
                    tag "Controler"
                    technology "Node.js, Express"
                    description "Recebe requisições REST relacionadas a solicitações (criar, consultar, atualizar, listar)."
                }

                solicitacao_service = component "SolicitacaoService" {
                    technology "Node.js, Express"
                    description "Gerencia a lógica de criação, atualização e validação das solicitações de auxílio."
                }

                solicitacao_repository = component "SolicitacaoRepository" {
                    technology "PostgreSQL, Prisma ORM"
                    description "Responsável por armazenar e recuperar solicitações de auxílio."
                }

                documento_controller = component "DocumentoController" {
                    tag "Controler"
                    technology "Node.js, Express"
                    description "Recebe requisições REST relacionadas ao cadastro e consulta de documentos do aluno."
                }

                documento_service = component "DocumentoService" {
                    technology "Node.js, Express"
                    description "Gerencia o armazenamento e utilização de documentos enviados pelos alunos."
                }

                documento_repository = component "DocumentoRepository" {
                    technology "PostgreSQL, Prisma ORM"
                    description "Armazena e recupera informações de documentos e dados de alunos."
                }

                notification_service = component "NotificationService" {
                    technology "Node.js, Express"
                    description "Gerencia o envio de notificações por e-mail utilizando o SMTP/API Gmail."
                }

                jwt_middleware = component "JWTMiddleware" {
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
            pessoa_aluno -> sistema_siae "Acessa para solicitar auxílios" "sync" "relation"
            pessoa_assistente -> sistema_siae "Acessa para avaliar solicitações" "sync" "relation"

            sistema_siae -> sistema_api_matricula "Valida matrícula do aluno" "sync" "relation"
            sistema_siae -> sistema_smtp "Envia solicitação de envio de notificação" "sync" "relation"
            sistema_smtp -> pessoa_aluno "Notifica status da solicitação" "sync" "relation"
            sistema_smtp -> pessoa_assistente "Notifica chegada de solicitação" "sync" "relation"

            /************************************
             * RELACIONAMENTOS ENTRE CONTAINERS *
             ************************************/
            pessoa_aluno -> login_page "Acessa a tela de login/cadastro" "sync" "relation"
            pessoa_aluno -> aluno_pages "Acessa páginas do aluno" "sync" "relation"
 
            pessoa_assistente -> login_page "Acessa a tela de login" "sync" "relation"
            pessoa_assistente -> assistente_page "Acessa páginas do assistente" "sync" "relation"

            login_page -> auth_controller "POST /login (realiza login)" "sync" "relation"
            aluno_pages -> solicitacao_controller "POST/GET /solicitacoes (criar/consultar solicitações)" "sync" "relation"
            aluno_pages -> documento_controller "POST /documentos (upload de documentos)" "sync" "relation"
            assistente_page -> solicitacao_controller "GET /solicitacoes (visualizar solicitações)" "sync" "relation"

            /**********************************
             * RELACIONAMENTOS ENTRE COMPONENTES *
             **********************************/
            auth_controller -> auth_service "Processa autenticação e cadastro" "sync" "relation"
            auth_service -> auth_repository "Leitura e gravação de credenciais" "sync" "relation"
            auth_service -> sigaa_service "Valida matrícula via API SIGAA" "sync" "relation"
            
            solicitacao_controller -> solicitacao_service "Envia dados de solicitação para processamento" "sync" "relation"
            solicitacao_service -> solicitacao_repository "Lê e grava solicitações no banco" "sync" "relation"
            solicitacao_service -> notification_service "Dispara e-mails de notificação" "sync" "relation"
            
            documento_controller -> documento_service "Gerencia upload e consulta de documentos" "sync" "relation"
            documento_service -> documento_repository "Armazena/recupera documentos" "sync" "relation"
            
            notification_service -> sistema_smtp "Envia notificações via Gmail" "async" "relation"
            jwt_middleware -> auth_service "Valida token JWT nas rotas protegidas" "sync" "relation"
            
            auth_repository -> banco_dados "Armazena dados de autenticação" "relation"
            solicitacao_repository -> banco_dados "Armazena dados de solicitações" "sync" "relation"
            documento_repository -> banco_dados "Armazena documentos" "sync" "relation"

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
            }
            
            element "FormaPadrao"{
                strokeWidth 10
            }
            
            element "Controler" {
                background "#DAE8FC"
                stroke "#6c8ebf"
            }
            element "Service"{
                background "#D5E8D4"
                stroke "#82B366"
            }
            element "Repository" {
                background "#FFE6CC"
                stroke "#D79B00"
            }
            
            element "External System" {
                background "#999999"
                color "#ffffff"
                shape roundedbox
            }
    
            element "Database" {
                shape cylinder
            }
            
            element "WebApp"{
                shape WebBrowser
            }
    
            relationship "relation" {
                color "#555555"
                thickness 2
                dashed false
                fontSize 20
            }
            relationship "async" {
                color "#555555"
                thickness 2
                dashed false
                fontSize 20
            }
        }
    
        theme default
    }
}
