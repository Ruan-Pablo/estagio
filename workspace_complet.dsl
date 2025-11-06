workspace {

    model {
        user_aluno = person "Aluno" {
            description "Estudante que acessa o sistema para solicitar o auxílio."
        }

        user_servidor = person "Servidor" {
            description "Servidor da equipe de assistência estudantil que gerencia as solicitações."
        }

        sigaa = softwareSystem "SIGAA" {
            description "Sistema acadêmico da UFC utilizado para validar matrícula dos estudantes."
            tags "External"
        }

        sistema = softwareSystem "Sistema Integrado a Assistência Estudantil" {
            description "Plataforma web para gerenciamento e solicitação do auxílio emergencial."

            web_app = container "Aplicação Web" {
                technology "React / HTML + CSS"
                description "Interface web acessada por alunos e servidores."
                tags "WebApp"

                loginPage = component "LoginPage" {
                    description "Tela de login com campos de acesso."
                    technology "React Component"
                }

                solicitacaoForm = component "SolicitacaoForm" {
                    description "Formulário para solicitar o auxílio, incluindo upload de documentos."
                    technology "React Component"
                }

                statusViewPage = component "StatusViewPage" {
                    description "Tela que exibe o status atual da solicitação do aluno."
                    technology "React Component"
                }

                authServiceFrontend = component "AuthService (Frontend)" {
                    description "Lida com a autenticação no frontend e envia dados para o backend."
                    technology "JavaScript Service"
                }

                solicitacaoServiceFrontend = component "SolicitacaoService (Frontend)" {
                    description "Envia solicitações e recebe dados da API Backend."
                    technology "JavaScript Service"
                }

                user_aluno -> loginPage "Acessa para fazer login"
                user_aluno -> solicitacaoForm "Envia a solicitação"
                user_aluno -> statusViewPage "Consulta o status"

                loginPage -> authServiceFrontend "Chama"
                solicitacaoForm -> solicitacaoServiceFrontend "Chama"
                statusViewPage -> solicitacaoServiceFrontend "Consulta dados"
            }

            api_backend = container "API Backend" {
                technology "Node.js / Express"
                description "Processa autenticação e regras de negócio."

                authController = component "AuthController" {
                    description "Recebe requisições de login e autentica usuários."
                    technology "Express Controller"
                }

                solicitacaoController = component "SolicitacaoController" {
                    description "Gerencia o recebimento e envio de dados das solicitações."
                    technology "Express Controller"
                }

                solicitacaoService = component "SolicitacaoService" {
                    description "Contém as regras de negócio da solicitação."
                    technology "JavaScript Service"
                }

                solicitacaoRepository = component "SolicitacaoRepository" {
                    description "Realiza operações de acesso ao banco de dados."
                    technology "PostgreSQL via ORM"
                }

                authServiceFrontend -> authController "Realiza login"
                solicitacaoServiceFrontend -> solicitacaoController "Envia e consulta dados"

                solicitacaoController -> solicitacaoService "Encaminha dados"
                solicitacaoService -> solicitacaoRepository "Grava e consulta dados"
                api_backend -> sigaa "Valida matrícula do aluno"
            }

            banco_dados = container "Banco de Dados" {
                technology "PostgreSQL"
                description "Armazena os dados de usuários, solicitações e status."
                tags "Database"
            }

            user_aluno -> web_app "Acessa via navegador"
            user_servidor -> web_app "Acessa via navegador"

            web_app -> api_backend "Envia dados de login"
            api_backend -> banco_dados "Consulta e valida credenciais"
        }
    }

    views {
        systemContext sistema {
            include *
            autolayout lr
            title "Contexto Geral – Sistema de Solicitação do Auxílio Emergencial"
        }

        container sistema {
            include *
            autolayout lr
            title "Visão de Contêineres – Sistema de Solicitação"
        }

        component web_app {
            include *
            autolayout lr
            title "Componentes da Aplicação Web (Frontend)"
        }

        component api_backend {
            include *
            autolayout lr
            title "Componentes da API Backend"
        }

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }

            element "Container" {
                shape RoundedBox
                background #1168bd
                color #ffffff
            }

            element "Component" {
                shape Box
                background #438dd5
                color #ffffff
            }

            element "WebApp" {
                shape WebBrowser
            }

            element "Database" {
                shape Cylinder
            }

            element "SoftwareSystem" {
                background #999999
                color #ffffff
            }

            element "External" {
                background #cccccc
                color #000000
                border Dashed
            }
        }
    }
}
