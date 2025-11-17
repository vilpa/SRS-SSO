workspace "NewAccount integration" "C4 Model for Client onboarding Integration" {

/*
container <name> [description] [technology] [tags] {
    ...
}
*/
    model {
        /* Web users */
        client = person "Client" "Member user accessing and managing applications"
        accmanager = person "Account Manager" "Client relationship and account representative"
        support = person "Support" "SafeRent Solutions support team assisting clients"

        /* external software system */
        srssystem = softwareSystem "SafeRent Platform" {
            description "Centralized system for rental screening and identity verification"
            tags "Existing System"
        }
        
        dyn = softwareSystem "Dynamics" "SafeRent CRM supporting onboarding records and workflows" "Existing System"
        slack = softwareSystem "Slack" "Real-time communication and notification channel" "Existing System"
        auth0 = softwareSystem "EntraID" "Centralized authentication service for secure user access" "Existing System"
        aam = softwareSystem "AAM" "Internal app storing client account settings and configuration" "Existing System"

        nasystem = softwareSystem "NewAccount Platform" {
            description "Onboarding platform automating client setup and workflows"

            group "SPA" {
                newaccount_spa = container "NewAccount SPA" {
                    technology "Angular 17"
                    description "Web application"
                    tags "Web Browser"
                }
            }

            group "API" {                
                newaccount_api = container "NewAccount API" {
                    technology ".NET, Web API"
                    description "API to provide transactions details"
                    tags "Core"                    

                    // === Controllers (API entrypoints) ===
                    apimodule = component "AccountOnboardingController" "Handles end-to-end client onboarding flows" "ASP.NET Web API Controller" "Controller,Module:Onboarding"
                    
                    // === Application / Domain Services ===
                    accountOnboardingService  = component "AccountOnboardingService"  "Orchestrates onboarding: Dynamics + AAM + SRS + Slack" "C# Service" "Service,Module:Onboarding"
                    accountSyncService        = component "AccountSyncService"        "Coordinates push/pull/sync with Dynamics 365" "C# Service" "Service,Module:AccountSync"
                    dynamicsAccountService    = component "DynamicsAccountService"    "Business logic and mapping for Dynamics accounts" "C# Service" "Service,Module:AccountSync"
                    accountSettingsService    = component "AccountSettingsService"    "Business logic for account settings via AAM/local DB" "C# Service" "Service,Module:AccountSettings"
                    srsAccountService         = component "SrsAccountService"         "Business logic for updating and validating SRS data" "C# Service" "Service,Module:SrsIntegration"
                    notificationService       = component "NotificationService"       "Builds and sends Slack notifications for key events" "C# Service" "Service,Module:Notifications"
                    accountEventService       = component "AccountEventService"       "Publishes internal/domain account events" "C# Service" "Service,Module:Platform"

                    authenticationComponent = component "AuthenticationComponent" "Validates JWT tokens and authorization" "Middleware" "CrossCutting,Module:Platform"
                    observabilityComponent  = component "ObservabilityComponent"  "Central logging/metrics/tracing for integrations" "Library" "CrossCutting,Module:Platform"
                }

                opodb = container "Opportunity Schema" {
                    technology "Postgre SQL"
                    description "Documents JSON, Rules, Logs"
                    tags "Database"
                }

                regisdb = container "Regis Schema" {
                    technology "Postgre SQL"
                    description "Account, Billing settings"
                    tags "Database"
                }

                rabbitmq = container "Queue" {
                    technology "MassTransit [RabbitMQ]"
                    description "Message broker enabling reliable asynchronous system communication"
                    tags "Queue"
                }
            }

            client -> newaccount_spa "provides initial info, screening parameters"
            accmanager -> newaccount_spa "verifies clients data, approves requests"
            support -> newaccount_spa "verifies clients data, resolves data issues"

            support -> dyn "tracks clients activities"
            accmanager -> dyn "mnages clients info"

            client -> srssystem "manages subaccounts, parameters"
            accmanager -> auth0 "authentication"
            support -> auth0 "authentication"

            auth0 -> newaccount_spa "generates tokens"

            newaccount_spa -> apimodule "calls onboarding APIs"

            dyn -> apimodule "pushes updates"
            accountOnboardingService -> opodb "persists clients data"
            accountSettingsService -> regisdb "persists clients data"

            accountEventService -> rabbitmq "notifies consumers, multicast"

            dynamicsAccountService -> dyn "syncs CRM data"
            notificationService -> slack "posts Slack messages"
            newaccount_api -> aam "syncs account settings"
            newaccount_api -> srssystem "syncs SRS accounts"

            apimodule -> accountOnboardingService "orchestrates onboarding"
            apimodule -> accountSyncService "triggers sync operations"
            apimodule -> dynamicsAccountService "manages CRM mapping"
            apimodule -> accountSettingsService "manages account settings"
            apimodule -> srsAccountService "manages SRS integration"
            apimodule -> notificationService "requests notifications"
            apimodule -> accountEventService "publishes domain events"
            apimodule -> authenticationComponent "enforces authentication"

            accountOnboardingService -> rabbitmq "publishes onboarding events"
            accountSyncService -> rabbitmq "publishes sync events"
            dynamicsAccountService -> rabbitmq "publishes CRM events"
            accountSettingsService -> rabbitmq "publishes settings events"
            srsAccountService -> rabbitmq "publishes SRS events"
            
            authenticationComponent -> srssystem "validates SRS access"
            authenticationComponent -> auth0 "validates tokens"
        }
    }


    views {
        systemcontext nasystem "SystemContext" {
            include *
        }
        
        container nasystem "ContainerDiagram" {
            include *
        }

        component newaccount_api "NewAccount_API_Components_by_Module" {
            include *
            /*
            group "Onboarding" {
                include element.tag=="Module:Onboarding"
            }
            group "Account Sync" {
                include element.tag=="Module:AccountSync"
            }
            group "Account Settings" {
                include element.tag=="Module:AccountSettings"
            }
            group "SRS Integration" {
                include element.tag=="Module:SrsIntegration"
            }
            group "Notifications" {
                include element.tag=="Module:Notifications"
            }
            group "Integration Infrastructure" {
                include element.tag=="Module:IntegrationInfrastructure"
            }
            group "Platform / Shared Kernel" {
                include element.tag=="Module:Platform"
            }

            autoLayout lr
            */
        }
        
        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
                background #08427b
            }
            element "Customer" {
                background #08427b
            }
            element "Bank Staff" {
                background #999999
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
            element "KeyVault" {
                background #1168bd
                color #ffffff
                shape Folder
            }
            element "Queue" {
                shape Pipe
            }
        }
    
        theme https://static.structurizr.com/themes/microsoft-azure-2021.01.26/theme.json
    }
}
