# ADR-002: Scaling Real-Time Chat Service

Date: 2025-03-05

## Status

Accepted

## Context

Live chat is a key feature of engagement,
requiring real-time messaging for millions of concurrent users.

## Decision

* Use WebSockets with Redis Pub/Sub for real-time bidirectional communication.
* Implement chat message sharding by channel ID to distribute the load.
* Deploy eventual consistency model for non-critical messages.
* Integrate AI-based chat moderation (AWS Rekognition, Perspective API) to filter spam.

## Consequences

* ✅ Scales efficiently with minimal lag.
* ✅ Enables chat moderation and spam filtering.
* ❌ Eventual consistency may cause slight message delay in edge cases.