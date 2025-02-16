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
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud Map"

                deploymentNode "VPC" {
                    tags "Amazon Web Services - Virtual private cloud VPC"

                    region = deploymentNode "eu-west-2" {
                        description "AWS - Europe Zone"
                        technology "AWS"
                        tags "Amazon Web Services - Region"

                        apiGatewayInfra = infrastructureNode "API Gateway" {
                            tags "Amazon Web Services - API Gateway"
                        }
                        elb = infrastructureNode "Elastic Load Balancer" {
                            description "Automatically distributes incoming application traffic."
                            tags "Amazon Web Services - Elastic Load Balancing"
                        }
                        cdn = infrastructureNode "AWS CDN" "Amazon CloudFront" {
                            tags "Amazon Web Services - CloudFront"
                        }
                        cognito = infrastructureNode "Cognito" "User authentication" {
                            tags "Amazon Web Services - Cognito"
                        }
                        elasticCacheRedis = infrastructureNode "ElastiCache Redis" "chat message queue"{
                            tags "Amazon Web Services - ElastiCache Redis"
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

                        group "Databases" {
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

                        apiGatewayInfra -> elb "send user request to"
                        chatServiceInstance -> rekognition "spam filter system"
                        chatServiceInstance -> elasticCacheRedis "Chat queue"
                        elb -> chatServiceInstance
                        elb -> liveStreaminAppInstance
                        liveStreaminAppInstance -> cdn "Load static resources"
                        liveStreaminAppInstance -> kinesis "video streaming"
                        liveStreaminAppInstance -> kinesisData "user activity tracking"
                        liveStreaminAppInstance -> mediaConvert "Caches and delivers VODs"
                        liveStreaminAppInstance -> streamDBInstance "Caches and delivers VODs"
                        mediaConvert -> s3 "Multimedia conversion"
                        recomendationInstance -> sagemaker "Trains and runs recommendation models"
                        rekognition -> chatDBInstance "spam filter system"
                        route53 -> apiGatewayInfra "redirects user requests to the API gateway"
                        sagemaker -> recommendationDBInstance "Stores user recommendations"
                        userInstance -> fraudDetector "Process payment frauds"
                        fraudDetector -> paymentLambda "process user payments"
                        fraudDetector -> transactionDBInstance "Store transaction logs"
                        userInstance -> subscriptionDBInstance "Updates user subscription status"
                        userInstance -> userDBInstance "Manages user info"
                    }
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
