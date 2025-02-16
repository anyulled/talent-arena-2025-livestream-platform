# ADR-003: Managing High Concurrent Users & Scalability

Date: 2025-03-05

## Status

Accepted

## Context

Millions of users may watch a stream simultaneously,
requiring efficient load balancing and fault tolerance.

## Decision

* Adopt Microservices Architecture for scalability.
* Use Auto-scaling EC2 instances and containerized services (EKS, ECS).
* Store user sessions and metadata in Amazon DynamoDB for quick lookups.
* Implement multi-region failover strategy using Route 53.

## Consequences

* ✅ High availability and fault tolerance.
* ✅ Ability to scale services independently.
* ❌ More complex deployment and monitoring.