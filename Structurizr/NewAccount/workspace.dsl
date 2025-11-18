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

            newaccount_spa = container "NewAccount SPA" {
                technology "Angular 17"
                description "Web application"
                tags "Web Browser"
            }

            group "API" {                
                newaccount_api = container "NewAccount API" {
                    technology ".NET, Web API"
                    description "API to provide transactions details"
                    tags "Core"                    

                    // === Controllers (API entrypoints) ===
                    apimodule = component "AccountOnboardingController" "Handles end-to-end client onboarding flows" ".NET API" "Controller,Module:Onboarding"
                    
                    // === Application / Domain Services ===
                    accountOnboardingService  = component "AccountOnboarding Module"  "Orchestrates onboarding: Dynamics + AAM + SRS + Slack" "NET Libraries" "Service,Module:Onboarding"
                    accountSyncService        = component "AccountSync Module"        "Coordinates push/pull/sync with Dynamics 365" "NET Libraries" "Service,Module:AccountSync"
                    dynamicsAccountService    = component "DynamicsAccount Module"    "Business logic and mapping for Dynamics accounts" "NET Libraries" "Service,Module:AccountSync"
                    accountSettingsService    = component "AccountSettings Module"    "Business logic for account settings via AAM/local DB" "NET Libraries" "Service,Module:AccountSettings"
                    srsAccountService         = component "SrsAccount Module"         "Business logic for updating and validating SRS data" "NET Libraries" "Service,Module:SrsIntegration"
                    notificationService       = component "Notification Module"       "Builds and sends Slack notifications for key events" "NET Libraries" "Service,Module:Notifications"
                    accountEventService       = component "AccountEvent Module"       "Publishes internal/domain account events" "NET Libraries" "Service,Module:Platform"

                    authenticationComponent = component "AuthenticationComponent" "Validates JWT tokens and authorization" "NET Libraries" "CrossCutting,Module:Platform"
                    observabilityComponent  = component "ObservabilityComponent"  "Central logging/metrics/tracing for integrations" "NET Libraries" "CrossCutting,Module:Platform"
                }
            }

            rabbitmq = container "EventBus" {
                technology "MassTransit [RabbitMQ]"
                description "Message broker enabling reliable asynchronous system communication"
                tags "Queue"
            }
            
            group "PostgreSQLDB" {                    
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

        prod = deploymentEnvironment "Production" {  
            serviceInstance1 = deploymentGroup "Service instance 1" 
            serviceInstance2 = deploymentGroup "Service instance 2"

            pginst1 = deploymentGroup "PG instance 1" 
            pginst2 = deploymentGroup "PG instance 2"

            rbinst1 = deploymentGroup "RBMQ instance 1" 
            rbinst2 = deploymentGroup "RBMQ instance 2"


            gcpvpc = deploymentNode "Googl Cloud Platform VPC" {
                technology ""
                tag "NetArea, Google Cloud Platform - Virtual Private Cloud"

                group "project: s100-prj-plt-rbmq-3194" {
                    dpngrbmq = deploymentNode "RabbitMQ Group" {
                        
                        dpnrbmq1 = deploymentNode "vm-rbmq-01-us-west1" {
                            technology "\n"
                            containerInstance rabbitmq rbinst1                            
                        }

                        dpnrbmq2 = deploymentNode "vm-rbmq-02-us-west1" {
                            technology "\n"
                            containerInstance rabbitmq rbinst2                            
                        }
                    }
                }                

                group "project: s100-prj-db-postgres-9946" {
                    dpng = deploymentNode "Postgre SQL Group" {
                        
                        dpn1 = deploymentNode "srs-s000-s100-gce-vm-pgrs-11-us-west1" {
                            technology "PostgreSQL 16.8"
                            containerInstance opodb pginst2                            
                            containerInstance regisdb pginst2                            
                        }

                        dpn2 = deploymentNode "srs-s000-s100-gce-vm-pgrs-12-us-west1" {
                            technology "PostgreSQL 16.8"
                            containerInstance opodb pginst2                            
                            containerInstance regisdb pginst2
                        }
                    }
                }                
                
                group "project: s100-prj-new-acc-0285" {
                    igdnapi = deploymentNode "Instance Group" {
                        technology "srs-s000-s100-gce-ig-nacc-us-west1-a"
                        
                        s100nacc02 = deploymentNode "S100NACC02" {
                            technology "Windows Server 2022"
                            containerInstance newaccount_api serviceInstance1
                                infrastructureNode "HealthCheck" "srs-s000-s100-gce-hc-https-nacc-us-west1" "Infra" 
                        }

                        s100nacc01 = deploymentNode "S100NACC01" {
                            technology "Windows Server 2022"
                            containerInstance newaccount_api serviceInstance2
                                infrastructureNode "HealthCheck" "srs-s000-s100-gce-hc-https-nacc-us-west1" "Infra" 
                        }
                        -> dpng
                        -> dpngrbmq
                    }
                }

                group "srs-s000-prj-s-net-7248" {
                    ig = deploymentNode "..." {
                        tag "NetArea"
                        lb = infrastructureNode "Load Balancer" "Layer 7" "Google Cloud Platform - Cloud Load Balancing" "Google Cloud Platform - Cloud Load Balancing" {
                            -> s100nacc01
                            -> s100nacc02
                        }

                        psc = infrastructureNode "Private Service Connect" "X" "Private Service Connect" "Google Cloud Platform - Dedicated Interconnect" {
                            -> lb
                        }            
                    }
                }
            }

            apigeetp = deploymentNode "DNS resolution" {
                    technology "Apigee Tenant Project"    
                    tag "Google Cloud Platform - Cloud DNS" 
                    apigeei = infrastructureNode "Apigee Instance" "Tenant" "Google Cloud Platform - Apigee API Platform" "Google Cloud Platform - Apigee API Platform" {
                        -> psc
                    }       
            }

            cf = deploymentNode "Cloudflare" {
                    technology "https-s008-prd.saferentsolutions.com"     
                    cfi = infrastructureNode "Cloudflare Account" {
                        description "api.saferentsolutions.com"
                        -> apigeetp
                    }       
            }
            enduser = deploymentNode "..." {
                    tag "NetArea"
                    cfii = infrastructureNode "API consumer" {
                        tag "Person"
                        -> cfi
                    }      
            }
        }
    }


    views {
        systemcontext nasystem "SystemContext" {
            include *
        }
        
        container nasystem "ContainerDiagram" {
            include *
            exclude client accmanager support dyn slack auth0 aam srssystem

        }

        component newaccount_api "NewAccount_API_Components_by_Module" {
            include *
            exclude auth0
        }

        deployment * prod {
            include *
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
            element "NetArea" {
                description false
                metadata false
            }
        }
    
        theme https://static.structurizr.com/themes/google-cloud-platform-v1.5/theme.json
    }
}
