workspace "Talent Arena" "System Design for a livestream platform" {

    model {
        user = person "User" "Watches live streams and interacts with the platform"
        streamer = person "Streamer" "Broadcasts live video streams"

        databaseService = softwareSystem "Database System" "Stores user, subscription, and stream metadata" {
            tags "Database"
            userDB = container "User DB" "User records" {
                tags "Database"
            }
            subscriptionDB = container "subscription DB" "User Subscription information" {
                tags "Database"
            }
            streamDB = container "Stream DB" "Streaming information" {
                tags "Database"
            }
            chatDB = container "Chat information Database" {
                tags "Database"
            }
        }
        rs = softwareSystem "Livestream System" "Livestream platform" {
            liveStreaming = container "Livestreaming App" "Handles video ingestion and real-time delivery"
            contentDelivery = container CDN "Network (CDN): Distributes live video streams efficiently"
            chatService = container "chat Service" "Provides real-time interactions using Web Sockets"
            userManagament = container "User Management" "Handles login, subscriptions, and payments"
            paymentService = container "Payment Service" "Processes donations, ad revenue, and subscriptions"
            videoStorage = container "Video Storage" "Stores past streams for replay"
            recommendationEngine = container "Recommendation Engine" "Suggests streams based on user activity"

            apiGateway = container "API Gateway" "Handles authentication, routing, and rate limiting"

            user -> apiGateway "Sends request"
            user -> contentDelivery "Fetches video streams from closest CDN node"
            user -> chatservice "Sends/receives chat messages"
            user -> videoStorage "Requests VOD playback"
            streamer -> apiGateway "Starts live stream"

            apiGateway -> liveStreaming "Routes streaming requests"
            apiGateway -> chatservice "Routes chat messages"

            chatService -> chatDB "store chat history"
            chatService -> userManagament "Gets user info"
            paymentService -> subscriptionDB "Updates user subscription status"
            liveStreaming -> recommendationEngine "suggest content"
            liveStreaming -> streamDB "get stream info"
            liveStreaming -> contentDelivery "Distributes encoded video streams"
            liveStreaming -> chatService "Allows instant messaging"
            liveStreaming -> userManagament "Manage Users"
            liveStreaming -> videoStorage "Archives completed streams for VOD playback"
            userManagament -> paymentService "process user payments"
            videoStorage -> contentDelivery "Caches and delivers VODs"

            userManagament -> userDB "Manages user info"
        }

        oauth = softwareSystem "Authentication System" "Third-party system for user authentication"
        paymentSystem = softwareSystem "Payment System" "Third-party System integration" {
            container "Paypal" "Paypal payment gateway"
            container "Stripe" "Stripe payment gateway"
        }

        apiGateway -> userDB "Fetches user and stream metadata"
        userManagament -> oauth "Perform third-party authentication"
        paymentService -> paymentSystem "Handles external payment options"

        prod = deploymentEnvironment "Production Deployment" {
            serviceWest = deploymentGroup "Service instance 1"
            serviceEast = deploymentGroup "Service instance 2"
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud Map"

                deploymentNode "VPC" {
                    tags "Amazon Web Services - Virtual private cloud VPC"

                    apiGatewayInfra = infrastructureNode "API Gateway" {
                        tags "Amazon Web Services - API Gateway"
                    }
                    cdn = infrastructureNode "AWS CDN" "Amazon CloudFront" {
                        tags "Amazon Web Services - CloudFront"
                    }
                    cognito = infrastructureNode "Cognito" "User authentication" {
                        tags "Amazon Web Services - Cognito"
                    }
                    elasticCacheRedis = infrastructureNode "ElastiCache Redis" "chat message queue" {
                        tags "Amazon Web Services - ElastiCache For Redis"
                    }
                    fraudDetector = infrastructureNode "Fraud Detector" "Amazon Rekognition" {
                        tags "Amazon Web Services - Fraud Detector"
                    }
                    mediaConvert = infrastructureNode "MediaConvert" "Multimedia conversion" {
                        tags "Amazon Web Services - Elemental MediaConvert"
                    }
                    route53 = infrastructureNode "Route 53" {
                        tags "Amazon Web Services - Route 53"
                    }
                    kinesis = infrastructureNode "Kinesis" "Video streaming" {
                        tags "Amazon Web Services - Kinesis Video Streams"
                    }
                    kinesisData = infrastructureNode "Kinesis Data Stream" "Data streaming" {
                        tags "Amazon Web Services - Kinesis Data Streams"
                    }
                    paymentLambda = infrastructureNode "Payment Service" {
                        tags "Amazon Web Services - Lambda"
                    }
                    rekognition = infrastructureNode "Rekognition" "spam filter system" {
                        tags "Amazon Web Services - Rekognition"
                    }
                    sagemaker = infrastructureNode "SageMaker" "Machine learning model training and inference" {
                        tags "Amazon Web Services - SageMaker"
                    }
                    s3 = infrastructureNode "Storage" "AWS - S3" {
                        tags "Amazon Web Services - Simple Storage Service"
                    }
                    globalAccelerator = infrastructureNode "AWS Global Accelerator" "ensures users connect to the closest region"{
                        tags "Amazon Web Services - Global Accelerator"
                    }

                    deploymentNode "eu-west-2" {
                        description "AWS - Europe Zone"
                        technology "AWS"
                        tags "Amazon Web Services - Region"

                        deploymentNode "EC2 - User Service" {
                            tags "Amazon Web Services - EC2"
                            userInstance = containerInstance userManagament

                        }
                        deploymentNode "EC2 - Recommendation Engine" {
                            tags "Amazon Web Services - EC2"
                            recomendationInstance = containerInstance recommendationEngine
                        }
                        deploymentNode "Amazon - Auto Scaling Groups" "Manages elastic EC2 configuration" {
                            tags "Amazon Web Services - Application Auto Scaling"

                            deploymentNode "EC2 - LiveStreaming" "This EC2 instance is part of an Auto Scaling Group" {
                                tags "Amazon Web Services - EC2"
                                softwareSystemInstance rs
                                liveStreaminAppInstance = containerInstance liveStreaming

                            }
                            deploymentNode "EC2 - Chat Service" "This EC2 instance is part of an Auto Scaling Group" {
                                tags "Amazon Web Services - EC2"
                                softwareSystemInstance rs
                                chatServiceInstance = containerInstance chatService
                            }
                        }

                        group "Databases - West Region " {
                            mysqlNode = deploymentNode "MySQL" {
                                tags "Amazon Web Services - RDS MySQL instance"
                                userDBInstance = infrastructureNode "user DB" "MySQL" {
                                    tags "Amazon Web Services - RDS MySQL instance"
                                }
                                subscriptionDBInstance = infrastructureNode "subscription DB" {
                                    tags "Amazon Web Services - RDS MySQL instance"
                                }
                                streamDBInstance = infrastructureNode "stream DB" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                                chatDBInstance = infrastructureNode "Chat DB" "PostgreSQL" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                                recommendationDBInstance = infrastructureNode "Recommendation DB" "PostgreSQL" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                                transactionDBInstance = infrastructureNode "Transaction DB" "PostgreSQL" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                            }
                        }

                        elbWest = infrastructureNode "Elastic Load Balancer" {
                            description "Automatically distributes incoming application traffic."
                            tags "Amazon Web Services - Elastic Load Balancing"
                        }

                        globalAccelerator -> elbWest "send user request to"
                        chatServiceInstance -> rekognition "spam filter system"
                        chatServiceInstance -> elasticCacheRedis "Chat queue"
                        elbWest -> chatServiceInstance
                        elbWest -> liveStreaminAppInstance
                        liveStreaminAppInstance -> cdn "Load static resources"
                        liveStreaminAppInstance -> kinesis "video streaming"
                        liveStreaminAppInstance -> kinesisData "user activity tracking"
                        liveStreaminAppInstance -> mediaConvert "Caches and delivers VODs"
                        liveStreaminAppInstance -> streamDBInstance "Caches and delivers VODs"
                        mediaConvert -> s3 "Multimedia conversion"
                        recomendationInstance -> sagemaker "Trains and runs recommendation models"
                        rekognition -> chatDBInstance "spam filter system"
                        elbWest -> apiGatewayInfra "redirects user requests to the API gateway"
                        sagemaker -> recommendationDBInstance "Stores user recommendations"
                        userInstance -> fraudDetector "Process payment frauds"
                        userInstance -> cognito "User authentication"
                        fraudDetector -> paymentLambda "process user payments"
                        fraudDetector -> transactionDBInstance "Store transaction logs"
                        userInstance -> subscriptionDBInstance "Updates user subscription status"
                        userInstance -> userDBInstance "Manages user info"
                    }
                    deploymentNode "eu-east-1" {
                        description "AWS - US East"
                        technology "AWS"
                        tags "Amazon Web Services - Region"

                        elbEast = infrastructureNode "Elastic Load Balancer" {
                            description "Automatically distributes incoming application traffic."
                            tags "Amazon Web Services - Elastic Load Balancing"
                        }


                        group "Databases - West Region " {
                            mysqlNodeEast = deploymentNode "MySQL" {
                                tags "Amazon Web Services - RDS MySQL instance"
                                userDBInstanceEast = infrastructureNode "user DB" "MySQL" {
                                    tags "Amazon Web Services - RDS MySQL instance"
                                }
                                subscriptionDBInstanceEast = infrastructureNode "subscription DB" {
                                    tags "Amazon Web Services - RDS MySQL instance"
                                }
                                streamDBInstanceEast = infrastructureNode "stream DB" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                                chatDBInstanceEast = infrastructureNode "Chat DB" "PostgreSQL" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                                recommendationDBInstanceEast = infrastructureNode "Recommendation DB" "PostgreSQL" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                                transactionDBInstanceEast = infrastructureNode "Transaction DB" "PostgreSQL" {
                                    tags "Amazon Web Services - DynamoDB"
                                }
                            }
                        }

                        deploymentNode "EC2 - User Service" {
                            tags "Amazon Web Services - EC2"
                            userManagementEast = containerInstance userManagament serviceEast

                        }
                        deploymentNode "EC2 - Recommendation Engine" {
                            tags "Amazon Web Services - EC2"
                            recommendationEast = containerInstance recommendationEngine serviceEast
                        }
                        deploymentNode "Amazon - Auto Scaling Groups" "Manages elastic EC2 configuration" {
                            tags "Amazon Web Services - Application Auto Scaling"

                            deploymentNode "EC2 - LiveStreaming" "This EC2 instance is part of an Auto Scaling Group" {
                                tags "Amazon Web Services - EC2"
                                softwareSystemInstance rs
                                liveStreamingEast = containerInstance liveStreaming serviceEast

                            }
                            deploymentNode "EC2 - Chat Service" "This EC2 instance is part of an Auto Scaling Group" {
                                tags "Amazon Web Services - EC2"
                                softwareSystemInstance rs
                                chatServiceEast = containerInstance chatService serviceEast
                            }
                        }

                        globalAccelerator -> elbEast "send user request to"
                        elbEast -> chatServiceEast
                        elbEast -> liveStreamingEast
                        userManagementEast -> cognito "User authentication"
                        userManagementEast -> subscriptionDBInstanceEast "Updates user subscription status"
                        userManagementEast -> subscriptionDBInstanceEast "Manages user info"
                        userManagementEast -> fraudDetector "Process payment frauds"
                        userManagementEast -> userDBInstanceEast "Manages user info"
                        elbEast -> apiGatewayInfra "redirects user requests to the API gateway"
                        recommendationEast -> sagemaker "Trains and runs recommendation models"
                        sagemaker -> recommendationDBInstanceEast "Stores user recommendations"
                        liveStreamingEast -> cdn "Load static resources"
                        liveStreamingEast -> kinesis "video streaming"
                        liveStreamingEast -> kinesisData "user activity tracking"
                        liveStreamingEast -> mediaConvert "Caches and delivers VODs"
                        liveStreamingEast -> streamDBInstanceEast "Caches and delivers VODs"
                        chatServiceEast -> rekognition "spam filter system"
                        chatServiceEast -> elasticCacheRedis "Chat queue"
                        fraudDetector -> transactionDBInstanceEast "Store transaction logs"
                        rekognition -> chatDBInstanceEast "spam filter system"
                    }

                    route53 -> apiGatewayInfra "redirects user requests to the API gateway"
                    apiGatewayInfra -> globalAccelerator "send user request to"
                }

            }
        }
    }

    views {
        theme default
        themes https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2022.04.30/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json

        systemContext rs "SystemContextView" {
            description "High-level view of the reconciliation system architecture."
            include *
        }

        container rs livestream "Livestream component view" {
            include *
        }

        container databaseService database "System Databases" {
            include *
        }

        deployment rs prod "Production" {
            title "Production deployment on AWS"
            include *
        }

        branding {
            logo images/logo.png
        }

        styles {

            element "Container" {
                shape roundedbox
            }

            element "Database" {
                shape cylinder
            }
        }
    }
}
