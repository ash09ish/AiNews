# NewsVision AI API Documentation

The Express app mounts REST APIs under `/api`. JSON is used for request and response bodies. Protected endpoints expect:

```http
Authorization: Bearer <jwt>
```

Unless a controller returns a more specific result, API failures pass through the error middleware as:

```json
{
  "message": "Error message",
  "stack": "Development-only stack trace"
}
```

`stack` is omitted when `NODE_ENV=production`. Unknown API paths return `404` with a route-not-found message. The app rate limiter applies to requests globally.

## Common Shapes

An analyzed article returned by news endpoints is shaped from provider, fallback, or persisted data:

```json
{
  "_id": "article-id",
  "title": "Headline",
  "description": "Short description",
  "content": "Article content",
  "author": "Author",
  "category": "technology",
  "source": "NewsAPI",
  "provider": "NewsAPI",
  "url": "https://example.test/story",
  "imageUrl": "https://example.test/image.jpg",
  "publishedAt": "2026-05-22T00:00:00.000Z",
  "summary": "Summary",
  "keyPoints": ["Point"],
  "keywords": ["keyword"],
  "sentiment": "neutral",
  "sentimentScore": 0
}
```

News list responses use:

```json
{
  "items": [],
  "total": 0,
  "page": 1,
  "pages": 1,
  "live": {
    "fetchedAt": "2026-05-22T00:00:00.000Z",
    "mode": "fallback",
    "persisted": false,
    "providerErrors": []
  }
}
```

## Health

### `GET /api/health`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | None |
| Response body | `{ "status": "ok", "service": "NewsVision AI", "timestamp": "<ISO timestamp>" }` |
| Error responses | Global `404` or `500` behavior if middleware/server fails |

## Authentication

### `POST /api/auth/register`

| Field | Details |
| --- | --- |
| Request body | `{ "name": "Reader", "email": "reader@example.test", "password": "minimum-eight-characters" }` |
| Authentication | None |
| Response body | `201` with `{ "token": "<jwt>", "user": { "id": "...", "name": "Reader", "email": "reader@example.test", "savedArticles": [] } }` |
| Error responses | `400` for short name, invalid email, or short password; `409` when email is already registered; `500` on unexpected failure |

### `POST /api/auth/login`

| Field | Details |
| --- | --- |
| Request body | `{ "email": "reader@example.test", "password": "password" }` |
| Authentication | None |
| Response body | `200` with `{ "token": "<jwt>", "user": { "id": "...", "name": "Reader", "email": "reader@example.test", "savedArticles": [] } }` |
| Error responses | `400` when email/password input fails validation; `401` for invalid credentials; `500` on unexpected failure |

## News

News list endpoints accept `page` and `limit`. Search uses `q`. Category feeds also use the route category. `persisted` list behavior depends on `PERSIST_NEWS` and MongoDB connection state.

### `GET /api/news/getnews`

| Field | Details |
| --- | --- |
| Endpoint URL | `/api/news/getnews?page=1&limit=12&category=technology&q=chip` |
| Request type | `GET` |
| Request body | None |
| Response body | News list response |
| Authentication requirements | None |
| Error responses | `500` if refresh/list processing fails |

### `GET /api/news/search`

| Field | Details |
| --- | --- |
| Endpoint URL | `/api/news/search?q=policy&page=1&limit=12` |
| Request type | `GET` |
| Request body | None |
| Response body | News list response |
| Authentication requirements | None |
| Error responses | `500` if refresh/list processing fails |

### `GET /api/news/compare`

| Field | Details |
| --- | --- |
| Endpoint URL | `/api/news/compare?id=<article-id>` |
| Request type | `GET` |
| Request body | None |
| Response body | `{ "yesterday": "...", "today": "...", "reason": "...", "changedSignals": [] }` |
| Authentication requirements | None |
| Error responses | `404` when the requested article cannot be found; `500` on unexpected failure |

### `GET /api/news/category/:category`

| Field | Details |
| --- | --- |
| Endpoint URL | `/api/news/category/technology?page=1&limit=12` |
| Request type | `GET` |
| Request body | None |
| Response body | News list response |
| Authentication requirements | None |
| Error responses | `500` if refresh/list processing fails |

### `GET /api/news/timeline/:id`

| Field | Details |
| --- | --- |
| Endpoint URL | `/api/news/timeline/<article-id>` |
| Request type | `GET` |
| Request body | None |
| Response body | `{ "articleId": "...", "items": [{ "day": 1, "label": "Event started", "note": "...", "date": "<ISO timestamp>" }] }` |
| Authentication requirements | None |
| Error responses | `404` when the article cannot be found; `500` on unexpected failure |

### `GET /api/news/:id`

| Field | Details |
| --- | --- |
| Endpoint URL | `/api/news/<article-id>` |
| Request type | `GET` |
| Request body | None |
| Response body | One analyzed article |
| Authentication requirements | None |
| Error responses | `404` when the article cannot be found; `500` on unexpected failure |

## AI Analysis

### `POST /api/ai/summarize`

| Field | Details |
| --- | --- |
| Request body | `{ "text": "Article text to summarize." }` |
| Authentication | None |
| Response body | `{ "summary": "...", "keyPoints": ["..."] }` |
| Error responses | `400` with `{ "message": "Text is required" }`; `500` on unexpected failure |

### `POST /api/ai/sentiment`

| Field | Details |
| --- | --- |
| Request body | `{ "text": "Article text to analyze." }` |
| Authentication | None |
| Response body | `{ "sentiment": "positive", "score": 0.231 }` where sentiment is positive, negative, or neutral |
| Error responses | `400` with `{ "message": "Text is required" }`; `500` on unexpected failure |

### `POST /api/ai/explain`

| Field | Details |
| --- | --- |
| Request body | `{ "article": { "title": "...", "summary": "..." }, "mode": "child" }`; implemented modes are `child`, `student`, and `expert` |
| Authentication | None |
| Response body | `{ "mode": "child", "explanation": "..." }` |
| Error responses | `400` with `{ "message": "Article is required" }` |

### `POST /api/ai/reality`

| Field | Details |
| --- | --- |
| Request body | `{ "article": { "title": "...", "description": "...", "source": "...", "url": "..." } }` |
| Authentication | None |
| Response body | `{ "politicalLeaning": "Neutral", "confidence": 70, "reliability": { "score": 54, "label": "Medium" }, "sensationalism": { "score": 0, "label": "Low", "signals": [] }, "bias": { "leaning": "Neutral", "score": 0, "label": "Low" } }` |
| Error responses | `400` with `{ "message": "Article is required" }` |

### `GET /api/ai/trending`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | None |
| Response body | `{ "positive": 0, "negative": 0, "neutral": 100, "trends": [], "keywords": [], "categories": [], "activeNewsCount": 0 }` |
| Error responses | `500` when article refresh or analytics computation fails |

## User

Every user route is protected by the JWT middleware.

### `GET /api/user/profile`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | Bearer JWT |
| Response body | `{ "id": "...", "name": "Reader", "email": "reader@example.test", "savedArticles": [] }` |
| Error responses | `401` when the token is missing, invalid, expired, or references no user |

### `GET /api/user/bookmarks`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | Bearer JWT |
| Response body | Array of saved articles |
| Error responses | `401` for auth failures; `500` on unexpected failure |

### `POST /api/user/bookmarks`

| Field | Details |
| --- | --- |
| Request body | `{ "articleId": "<article-id>" }` |
| Authentication | Bearer JWT |
| Response body | `201` with `{ "message": "Article saved" }` |
| Error responses | `401` for auth failures; `404` when the article cannot be found; `500` on unexpected failure |

### `DELETE /api/user/bookmarks/:articleId`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | Bearer JWT |
| Response body | `{ "message": "Article removed" }` |
| Error responses | `401` for auth failures; `500` on unexpected failure |

### `GET /api/user/interests`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | Bearer JWT |
| Response body | `{ "openedArticles": [], "categories": [], "topics": [], "keywords": [], "graph": [] }` |
| Error responses | `401` for auth failures; `500` on unexpected failure |

### `POST /api/user/interests`

| Field | Details |
| --- | --- |
| Request body | `{ "articleId": "<article-id>" }` |
| Authentication | Bearer JWT |
| Response body | Interest payload with updated article, category, topic, keyword, and graph entries |
| Error responses | `401` for auth failures; `404` when the article cannot be found; `500` on unexpected failure |

## Advanced Article Tools

### `POST /api/predictions`

| Field | Details |
| --- | --- |
| Request body | `{ "article": { "title": "...", "description": "..." } }` |
| Authentication | None |
| Response body | `{ "event": "...", "confidence": 63, "outcomes": [{ "label": "Continues", "probability": 52 }] }` |
| Error responses | `400` with `{ "message": "Article is required" }` |

### `POST /api/debate`

| Field | Details |
| --- | --- |
| Request body | `{ "article": { "category": "technology", "author": "..." } }` |
| Authentication | None |
| Response body | `{ "counterarguments": [], "missingFactors": [], "alternativeViewpoints": [] }` |
| Error responses | `400` with `{ "message": "Article is required" }` |

### `POST /api/emotion`

| Field | Details |
| --- | --- |
| Request body | `{ "article": { "title": "...", "description": "...", "content": "..." } }` |
| Authentication | None |
| Response body | `[{ "label": "fear", "value": 25 }, { "label": "hope", "value": 25 }, { "label": "anger", "value": 25 }, { "label": "excitement", "value": 25 }]` |
| Error responses | `400` with `{ "message": "Article is required" }` |

## Fake-News Game

### `GET /api/fakenews-game`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | None |
| Response body | Question prompt without answer or explanation, such as `{ "_id": "...", "headline": "...", "level": "Beginner" }` |
| Error responses | `500` on unexpected failure |

### `POST /api/fakenews-game/answer`

| Field | Details |
| --- | --- |
| Request body | `{ "questionId": "<question-id>", "selection": "Fake", "userName": "Guest" }` |
| Authentication | None |
| Response body | `{ "correct": true, "points": 10, "answer": "Fake", "explanation": "...", "level": "Beginner" }` |
| Error responses | `400` when question or selection is missing; `404` when the question cannot be found; `500` on unexpected failure |

### `GET /api/fakenews-game/leaderboard`

| Field | Details |
| --- | --- |
| Request body | None |
| Authentication | None |
| Response body | Array of up to five score records shaped like `{ "userName": "Guest", "score": 10, "level": "Beginner" }` |
| Error responses | `500` on unexpected failure |

## Realtime Channel

The Socket.IO server shares the HTTP server port.

| Event | Direction | Payload |
| --- | --- | --- |
| `connected` | Server to client | `{ "message": "NewsVision AI realtime channel ready" }` |
| `news:update` | Server to client | `{ "articles": [], "analytics": {}, "live": { "fetchedAt": "...", "mode": "...", "persisted": false, "providerErrors": [] } }` |

The client listens for `news:category:update`, but the current server scheduler only emits `news:update`.
