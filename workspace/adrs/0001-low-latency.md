# ADR-001: Ensuring Low-Latency Live Streaming

Date: 2025-03-05

## Status

Accepted

## Context

Live-streaming requires minimal latency (<2 s) for real-time interactions,
especially for gaming, sports, and social content.

## Decision

* Use Adaptive Bitrate Streaming (ABR) with HLS (HTTP Live Streaming) and DASH (Dynamic Adaptive Streaming over HTTP).
* Deploy WebRTC for ultra-low-latency streaming (<500 ms) where required.
* Implement multi-CDN strategy (CloudFront, Akamai) to distribute video streams.
* Encode/transcode video at the edge to reduce processing delays.
* Optimize chunk size in LL-HLS (Low-Latency HLS) to enable faster delivery.

## Consequences

* ✅ Reduced stream buffering and lag.
* ✅ Improved scalability for high-viewership events.
* ❌ Increased infrastructure costs due to edge processing.