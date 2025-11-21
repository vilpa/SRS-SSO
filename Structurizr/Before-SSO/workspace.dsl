workspace "SRS before SSO" "C4 Model for Current Solution Architecture" {

/*
container <name> [description] [technology] [tags] {
    ...
}
*/
    model {
        client = person "Client" "Member user accessing and managing applications"
        sll = person "Small Landlord" "Independent property owners using MyRental for tenant screening"
        customer = person "Applicant" "Applicant or tenant undergoing screening"
        support = person "Support" "SafeRent Solutions support team assisting users"
        accmanager = person "Account Manager" "Client relationship and account representative"
        mlsagent = person "MLS agent" "Licensed real estate listing representative"
        pmsuser = person "PMS user" "Manages property operations and tenant activities"
        iuser = person "internet user" "internet user with public, unauthenticated application access"

        yardi = softwareSystem "Yardi" "Property management and accounting software solution" "External PMS system"
        mri = softwareSystem "MRI" "Enterprise real estate management and analytics platform" "External PMS system"
        appfolio = softwareSystem "AppFolio" "Cloud-based property management and leasing software" "External PMS system"
        mls = softwareSystem "MLS" "Platform for sharing real estate listings" "External PMS system"
        dyn = softwareSystem "Dynamics" "SafeRent CRM"
        eid = softwareSystem "Microsoft Entra ID" "SafeRentSolutions tenant" "Azure" 
        
        auth0 = softwareSystem "auth.saferentsolutions.com" "Authentication server"
        srsdomain = softwareSystem "residentscreening.net" "SRSWeb portal"
        clientbrowser = softwareSystem "Browser Cookie Storage" "Client Browser" "Web Browser"
        clientbrapp = softwareSystem "Browser Local Storage" "Client Browser" "Web Browser"
        clientbrwrk = softwareSystem "Browser Worker Storage" "Client Browser" "Web Browser"
        obdomain = softwareSystem "onlinebilling.saferentsolutions.com" "Billing portal"

        pmsuser -> yardi "verifies identity, Forms"
        pmsuser -> appfolio "verifies identity, Forms"
        pmsuser -> mri "verifies identity, Okta"
        support -> dyn "verifies identity, SRS Azure"
        accmanager -> dyn "verifies identity, SRS Azure"

        srssystem = softwareSystem "SafeRent Platform" {
            description "Centralized system for rental screening and identity verification"

            group "SRS" {
                srsweb = container "SRS Web" {
                    technology ".NetFramework 4.8, ASP.NET Forms"
                    description "Forms authentication, Role-based access on top of .Net Access DB"
                    tags "SRSWeb"

                }
                srsb2b = container "SRS B2B" {
                    technology ".NetFramework 4.8, ASP.NET, Web API"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "SRSWeb"                    
                }
                srsdyn = container "Dynamics API" {
                    technology ".NET, Web API"
                    description "Internal API to export transactions, clients, billing info"
                    tags "Dynamics"        
                }

                mpf = container "SRS Monitoring SPA" {
                    technology "Angular 17"
                    description "Web UI"
                    tags "Web Browser, MP"                    
                }
                mpb = container "SRS Monitoring API" {
                    technology ".NET, Web API"
                    description "API to provide transactions details"
                    tags "Core, Utility, Shared"                    
                }
                regaccessdb = container "RegAccess users DB" {
                    technology "SQLServer"
                    description "Credentials, Permissions, Profiles, ASP.NET Sessions"
                    tags "Database"
                }
            }

            mpf -> mpb "sends auth token"

            group "MyRental" {
                mrkt = container "Markening Portal" {
                    technology ".NetFramework 4.8, ASP.NET, MVC"
                    description "MyRental entry point"
                    tags "Core, Utility, Shared"                    
                }
                appsmyrental = container "MyRental" {
                    technology ".NetFramework 4.8, ASP.NET, MVC"
                    description "MyRental screening portal"
                    tags "Core, Utility, Shared"      
                }
            }

            group "BackOffice" {
                
                boportalui = container "Backoffice portal UI" {
                    technology "Angular 17"
                    description "Backoffice entry point"
                    tags "Web Browser"                    
                }
                boportal = container "Backoffice portal" {
                    technology ".NET 8"
                    description "Backoffice entry point"
                    tags "Core, Utility, Shared"                    
                }
                pportalui = container "Permissions Manager UI" {
                    technology "Angular 17"
                    description "Admin portal for centralized user and access management to backoffice apps"
                    tags "Web Browser"                    
                }
                pportal = container "Permissions Manager" {
                    technology ".NET 8"
                    description "Admin portal for centralized user and access management to backoffice apps"
                    tags "Core, Utility, Shared"                    
                }
                dmui = container "CBP Data UI" {
                    technology "Angular 17"
                    description "CBP Data management portal"
                    tags "Web Browser"                    
                }
                dm = container "CBP Data" {
                    technology ".NET 8"
                    description "CBP Data management portal"
                    tags "Core, Utility, Shared"                    
                }
                crimsafeuiui = container "CBP processor UI" {
                    technology "Angular 17"
                    description "Criminal data processor"
                    tags "Web Browser"                    
                }
                crimsafeui = container "CBP processor" {
                    technology ".NET 8"
                    description "Criminal data processor"
                    tags "Core, Utility, Shared"                    
                }
                tsui = container "Vendor Routing UI" {
                    technology "Angular 17"
                    description "Set data vendors parameters, priority, properties mapping"
                    tags "Web Browser"                    
                }
                ts = container "Vendor Routing" {
                    technology ".NET 8"
                    description "Set data vendors parameters, priority, properties mapping"
                    tags "Core, Utility, Shared"                    
                }
                mtui = container "Transactions Monitoring Portal UI" {
                    technology "Angular 17"
                    description "Credit/Crim bureaus row data tracer"
                    tags "Web Browser"                    
                }
                mt = container "Transactions Monitoring Portal" {
                    technology ".NET 8"
                    description "Credit/Crim bureaus row data tracer"
                    tags "Core, Utility, Shared"                    
                }
                osdb = container "BO users DB" {
                    technology "PostgreSQL"
                    description "Credentials, Permissions, Profiles"
                    tags "Database"
                }
            }

            srsweb -> regaccessdb "saves credentials, permissions"
            appsmyrental -> regaccessdb "saves credentials, permissions"
            regaccessdb -> srsweb "gets credentials, permissions"
            regaccessdb -> appsmyrental "gets credentials, permissions"
            regaccessdb -> mpb "gets credentials, permissions"
            regaccessdb -> srsb2b "gets credentials, permissions"
            client -> srsweb "verifies identity, Forms, validates access, SRS"
            customer -> appsmyrental "verifies identity, Forms, validates access, MR"
            sll -> appsmyrental "verifies identity, Forms, validates access, MR"
            support -> srsweb "verifies identity, Forms, validates access, SRS"
            support -> mpf "verifies identity, Forms, validates access, MP"
            accmanager -> srsweb "verifies identity, Forms, validates access, SRS"
            iuser -> mrkt "public access"
            pmsuser -> srsweb "verifies identity, Forms, validates access, SRS"

            yardi -> srsb2b "sends credentials, MITS XML"
            mri -> srsb2b "sends credentials, MITS XML"
            appfolio -> srsb2b "sends credentials, MITS XML"
            mls -> appsmyrental "verifies identity, SAML, validates access, MR"
            dyn -> srsdyn "verifies App identity, Azure M2M"

            boportalui -> pportalui "redirects with permissions"
            boportalui -> dmui "redirects with permissions"
            boportalui -> crimsafeuiui "redirects with permissions"
            boportalui -> tsui "redirects with permissions"
            boportalui -> mtui "redirects with permissions"
            boportal -> eid "validates token"

            pportalui -> pportal "gets local auth token"
            dmui -> dm "gets local auth token"
            crimsafeuiui -> crimsafeui "gets local auth token"
            tsui -> ts "gets local auth token"
            mtui -> mt "gets local auth token"
            
            osdb -> boportal "gets credentials, permissions"
            pportal -> osdb "persists credentials, permissions"

            support -> boportalui "sends id token"
            boportalui -> boportal "verifies identity, validates access"
            accmanager -> boportalui "sends id token"

            support -> eid "verifies identity, gets token"
            accmanager -> eid "verifies identity, gets token"

            mlsagent -> mls "verifies identity, SAML"
            mlsagent -> mrkt "public access"

            // Auth0
            client -> srsdomain
            srsdomain -> auth0
            auth0 -> auth0
            auth0 -> clientbrwrk
            auth0 -> srsdomain
            srsdomain -> srsdomain
            srsdomain -> clientbrowser

            client -> obdomain
            obdomain -> auth0
            auth0 -> obdomain
            obdomain -> obdomain
            obdomain -> clientbrapp
        }
    }

    views {
        systemcontext srssystem "SystemContext" {
            include *
            exclude auth0 srsdomain obdomain clientbrowser clientbrapp clientbrwrk
        }
       
        container srssystem "ContainerDiagram" {
            include *
            exclude auth0 srsdomain obdomain clientbrowser clientbrapp clientbrwrk client sll customer support accmanager mlsagent pmsuser iuser yardi mri appfolio mls dyn eid
        }
        
        dynamic srssystem {
            title "SSO flow Web Based Apps"
            
            client -> srsdomain "Browses to"
            srsdomain -> auth0 "Redirects to"
            auth0 -> auth0 "User logs in"
            auth0 -> clientbrwrk "Stores Cookie"
            auth0 -> srsdomain "Sends token and redirects"
            srsdomain -> srsdomain "Uses Token to Authenticate"
            srsdomain -> clientbrowser "Stores RS Cookie"

            client -> obdomain "Browses to"
            obdomain -> auth0 "Redirects to"
            auth0 -> auth0 "Cookie is available"
            auth0 -> obdomain "Sends token and redirects"
            obdomain -> obdomain "Uses Token to Authenticate"
            obdomain -> clientbrapp "Stores OB Cookie"

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
