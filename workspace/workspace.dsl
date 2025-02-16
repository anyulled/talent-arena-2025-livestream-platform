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

            apiGateway -> paymentService "Processes payments and subscriptions"

            chatService -> chatDB "store chat history"
            chatService -> userManagament "Gets user info"
            paymentService -> subscriptionDB "Updates user subscription status"
            liveStreaming -> recommendationEngine "suggest content"
            liveStreaming -> streamDB "get stream info"
            liveStreaming -> contentDelivery "Distributes encoded video streams"
            liveStreaming -> chatService "Allows instant messaging"
            liveStreaming -> userManagament "Manage Users"
            liveStreaming -> videoStorage "Archives completed streams for VOD playback"
            liveStreaming -> paymentService "process user payments"
            videoStorage -> contentDelivery "Caches and delivers VODs"

            userManagament -> userDB "Manages user info"
        }

        oauth = softwareSystem "Authentication System" "Third-party system for user authentication"
        paymentSystem = softwareSystem "Payment System" "Third-party System integration"

        apiGateway -> userDB "Fetches user and stream metadata"
        userManagament -> oauth "Perform third-party authentication"
        paymentService -> paymentSystem "Handles external payment options"

        prod = deploymentEnvironment "Production Deployment" {
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud Map"
                region = deploymentNode "eu-west-2" {
                    description "AWS - Europe Zone"
                    technology "AWS"
                    tags "Amazon Web Services - Region"

                    route53 = infrastructureNode "Route 53" {
                        tags "Amazon Web Services - Route 53"
                    }

                    apiGatewayInfra = infrastructureNode "API Gateway" {
                        tags "Amazon Web Services - API Gateway"
                    }

                    kinesis = infrastructureNode "Kinesis" "Video streaming" {
                        tags "Amazon Web Services - Kinesis Video Streams"
                    }
                    sagemaker = infrastructureNode "SageMaker" "Machine learning model training and inference" {
                        tags "Amazon Web Services - SageMaker"
                    }

                    elb = infrastructureNode "Elastic Load Balancer" {
                        description "Automatically distributes incoming application traffic."
                        tags "Amazon Web Services - Elastic Load Balancing"
                    }
                    cdn = infrastructureNode "AWS CDN" "Amazon CloudFront" {
                        tags "Amazon Web Services - CloudFront"
                    }
                    s3 = infrastructureNode "Storage" "AWS - S3" {
                        tags "Amazon Web Services - Simple Storage Service"
                    }
                    mediaConvert = infrastructureNode "MediaConvert" "Multimedia conversion" {
                        tags "Amazon Web Services - Elemental MediaConvert"
                    }
                    rekognition = infrastructureNode "Rekognition" "spam filter system" {
                        tags "Amazon Web Services - Rekognition"
                    }
                    paymentLambda = infrastructureNode "Payment Service" {
                        tags "Amazon Web Services - Lambda"
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
                        #tags "Amazon Web Services - RDS"

                        mysqlNode = deploymentNode "MySQL" {
                            tags "Amazon Web Services - RDS MySQL instance"
                            userDBInstance = infrastructureNode "user DB" "MySQL" {
                                tags "Amazon Web Services - RDS MySQL instance"
                            }
                            subscriptinDBInstance = infrastructureNode "subscription DB" {
                                tags "Amazon Web Services - RDS MySQL instance"
                            }
                            streamDBInstance = infrastructureNode "stream DB" {
                                tags "Amazon Web Services - DynamoDB"
                            }
                            chatDBInstance = infrastructureNode "Chat DB" "PostgreSQL" {
                                tags "Amazon Web Services - DynamoDB"
                            }
                        }
                    }

                    route53 -> apiGatewayInfra "redirects user requests to the API gateway"
                    apiGatewayInfra -> elb "send user request to"
                    liveStreaminAppInstance -> paymentLambda "process user payments"
                    liveStreaminAppInstance -> kinesis "video streaming"
                    liveStreaminAppInstance -> cdn "Load static resources"
                    liveStreaminAppInstance -> mediaConvert "Caches and delivers VODs"
                    mediaConvert -> s3 "Multimedia conversion"
                    chatServiceInstance -> rekognition "spam filter system"
                    elb -> chatServiceInstance
                    elb -> liveStreaminAppInstance
                    recomendationInstance -> sagemaker "Trains and runs recommendation models"

                    sagemaker -> chatDBInstance "Stores user recommendations"
                    userInstance -> userDBInstance "Manages user info"
                    liveStreaminAppInstance -> streamDBInstance "Caches and delivers VODs"
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
