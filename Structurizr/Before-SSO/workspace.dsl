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

        pmsuser -> yardi "verifies identity, Forms"
        pmsuser -> appfolio "verifies identity, Forms"
        pmsuser -> mri "verifies identity, Okta"
        support -> dyn "verifies identity, SRS Azure"
        accmanager -> dyn "verifies identity, SRS Azure"

        srssystem = softwareSystem "SafeRent Platform" {
            description "Centralized system for rental screening and identity verification"

            group "SRS" {
                srsweb = container "SRS Web" {
                    technology ".NetFramework 4.8"
                    description "Forms authentication, Role-based access on top of .Net Access DB"
                    tags "SRSWeb"

                }
                srsb2b = container "SRS B2B" {
                    technology ".NetFramework 4.8"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "SRSWeb"                    
                }
                srsdyn = container "Dynamics API" {
                    technology ".NET"
                    description "Internal API to export transactions, clients, billing info"
                    tags "Dynamics"        
                }
                mp = container "SRS Monitoring Portal" {
                    technology ".NetFramework 4.8"
                    description "SRSWeb instance for internal users"
                    tags "MP"                    
                }
                mpf = container "SRS Monitoring SPA" {
                    technology "Angular 17"
                    description "Web UI"
                    tags "MP"                    
                }
                mpb = container "SRS Monitoring API" {
                    technology ".NET 8"
                    description "API to provide transactions details"
                    tags "Core, Utility, Shared"                    
                }
                regaccessdb = container "RegAccess users DB" {
                    technology "SQLServer"
                    description "Credentials, Permissions, Profiles, ASP.NET Sessions"
                    tags "Database"
                }
            }

            group "MyRental" {
                mrkt = container "Markening Portal" {
                    technology ".NET 8"
                    description "MyRental entry point"
                    tags "Core, Utility, Shared"                    
                }
                appsmyrental = container "MyRental" {
                    technology ".NetFramework 4.8"
                    description "MyRental screening portal"
                    tags "Core, Utility, Shared"      
                }
            }

            group "BackOffice" {
                boportal = container "Backoffice portal" {
                    technology ".NET 8"
                    description "Backoffice entry point"
                    tags "Core, Utility, Shared"                    
                }
                pportal = container "Permissions Manager" {
                    technology ".NET 8"
                    description "Admin portal for centralized user and access management to backoffice apps"
                    tags "Core, Utility, Shared"                    
                }
                dm = container "CBP Data" {
                    technology ".NET 8"
                    description "CBP Data management portal"
                    tags "Core, Utility, Shared"                    
                }
                crimsafeui = container "CBP processor" {
                    technology ".NET 8"
                    description "Criminal data processor"
                    tags "Core, Utility, Shared"                    
                }
                ts = container "Vendor Routing" {
                    technology ".NET 8"
                    description "Set data vendors parameters, priority, properties mapping"
                    tags "Core, Utility, Shared"                    
                }
                mt = container "Transactions Monitoring Portal" {
                    technology ".NET 8"
                    description "CCredit/Crim bureaus row data tracer"
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

            boportal -> pportal "verifies identity, SPA token"
            boportal -> dm "verifies identity, SPA token"
            boportal -> crimsafeui "verifies identity, SPA token"
            boportal -> ts "verifies identity, SPA token"
            boportal -> mt "verifies identity, SPA token"
            
            osdb -> boportal "gets credentials, permissions"
            pportal -> osdb "persists credentials, permissions"

            support -> boportal "verifies identity Forms, validates access, MR"
            accmanager -> boportal "verifies identity Forms, validates access, MR"

            mlsagent -> mls "verifies identity, SAML"
            mlsagent -> mrkt "public access"
        }
    }

    views {
        systemcontext srssystem "SystemContext" {
            include *
        }
        
        container srssystem "ContainerDiagram" {
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
        }
    
        theme https://static.structurizr.com/themes/microsoft-azure-2021.01.26/theme.json
    }
}
