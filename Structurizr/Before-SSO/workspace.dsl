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
        agent = person "MLS agent" "Licensed real estate listing representative."
        pmsuser = person "PMS user" "Manages property operations and tenant activities"
        iuser = person "internet user" "internet user with public, unauthenticated application access."

        yardi = softwareSystem "Yardi" "Property management and accounting software solution" "External PMS system"
        mri = softwareSystem "MRI" "Enterprise real estate management and analytics platform" "External PMS system"
        appfolio = softwareSystem "AppFolio" "Cloud-based property management and leasing software" "External PMS system"
        mls = softwareSystem "MLS" "Platform for sharing real estate listings" "External PMS system"
        dyn = softwareSystem "Dynamics" "SafeRent CRM"

        agent -> mls
        pmsuser -> yardi
        pmsuser -> appfolio
        pmsuser -> mri
        support -> dyn
        accmanager -> dyn

        srssystem = softwareSystem "SafeRent Platform" {
            description "Centralized system for rental screening and identity verification"

            group "SRS" {
                srsweb = container "SRS Web" {
                    technology ".NetFramework 4.8"
                    description "Role-based access, SSO integration"
                    tags "Core, Utility, Shared"

                }
                srsb2b = container "SRS B2B" {
                    technology ".NetFramework 4.8"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "Core, Utility, Shared"                    
                }
                srsdyn = container "Dynamics API" {
                    technology ".NET"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "Core, Utility, Shared"        
                }
                mp = container "SRS Monitoring Portal" {
                    technology ".NetFramework 4.8"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "Core, Utility, Shared"                    
                }
                mpf = container "SRS Monitoring SPA" {
                    technology "Angular 17"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "Core, Utility, Shared"                    
                }
                mpb = container "SRS Monitoring API" {
                    technology ".NET 8"
                    description "API to support MITS, MITS 2.5, RETS, IDX, ILS"
                    tags "Core, Utility, Shared"                    
                }
                regaccessdb = container "RegAccess users DB" {
                    technology "SQLServer"
                    description "Credentials, Permissions, Profiles"
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
                    description "MyRental entry point"
                    tags "Core, Utility, Shared"                    
                }
                dm = container "CBP Data" {
                    technology ".NET 8"
                    description "CBP Data management portal"
                    tags "Core, Utility, Shared"                    
                }
                crimsafeui = container "CBP processor" {
                    technology ".NET 8"
                    description "MyRental entry point"
                    tags "Core, Utility, Shared"                    
                }
                ts = container "Vendor Routing" {
                    technology ".NET 8"
                    description "MyRental entry point"
                    tags "Core, Utility, Shared"                    
                }
                mt = container "Transactions Monitoring Portal" {
                    technology ".NET 8"
                    description "MyRental entry point"
                    tags "Core, Utility, Shared"                    
                }
                osdb = container "BO users DB" {
                    technology "PostgreSQL"
                    description "Credentials, Permissions, Profiles"
                    tags "Database"
                }
            }

            srsweb -> regaccessdb "save credentials, permissions"
            appsmyrental -> regaccessdb "save  credentials, permissions"
            regaccessdb -> srsweb "get credentials, permissions"
            regaccessdb -> appsmyrental "get credentials, permissions"
            client -> srsweb
            customer -> appsmyrental
            sll -> appsmyrental
            support -> srsweb
            support -> mpf
            accmanager -> srsweb
            iuser -> mrkt
            pmsuser -> srsweb

            yardi -> srsb2b
            mri -> srsb2b
            appfolio -> srsb2b
            mls -> appsmyrental
            dyn -> srsdyn

            boportal -> pportal
            boportal -> dm
            boportal -> crimsafeui
            boportal -> ts
            boportal -> mt
            
            osdb -> boportal "get credentials, permissions"
            pportal -> osdb "save credentials, permissions"

            support -> boportal
            accmanager -> boportal
        }
    }

    views {
        systemcontext srssystem "SystemContext" {
            include *
            autolayout
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
