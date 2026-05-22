# NewsVision AI

NewsVision AI is a real-time news analysis workspace. The React client presents live news feeds, article details, AI-assisted reading tools, analytics, authentication, saved articles, and a fake-news quiz. The Express API aggregates provider or fallback news, analyzes articles, publishes Socket.IO refreshes, and can store data in MongoDB or use the in-memory development store when MongoDB is not configured.

## Features

- Live headline feed with search, category pages, pagination, provider status, and Socket.IO refreshes.
- Article detail page with summaries, keywords, timeline, comparison, explanation modes, reality meter, debate prompts, prediction view, emotion view, knowledge graph, and related articles.
- Text analysis page for summarization, key points, and sentiment.
- JWT registration/login and protected saved-article and interest endpoints.
- MongoDB-backed persistence for users, articles, analytics, quiz questions, scores, and achievements when configured.
- Fallback news feed and fallback NLP heuristics for local operation without news-provider keys or Hugging Face transformer pipelines.
- Fake-news game question, answer, and leaderboard APIs.

## Tech Stack

| Area | Implementation |
| --- | --- |
| Frontend | React 18, Vite, React Router, Tailwind CSS, Axios, Socket.IO Client, Chart.js, Framer Motion, Lucide React |
| Backend | Node.js ES modules, Express 4, Socket.IO, Axios |
| Data | MongoDB with Mongoose; in-memory development store fallback |
| AI/NLP | Local heuristic summarization/sentiment fallback and optional `@huggingface/transformers` pipelines |
| Security/middleware | JWT, bcryptjs, Helmet, CORS, rate limiting, mongo sanitize, compression |
| Packaging | npm workspaces, Dockerfile, Docker Compose |

## Installation

Prerequisites:

- Node.js `18.18.0` or newer.
- npm.
- Optional MongoDB instance or Docker if persisted data is needed.
- Optional NewsAPI or GNews key for external headlines.

Local setup:

```bash
git clone <repository-url>
cd NewsVisionAI
npm install
cp .env.example .env
```

On PowerShell, create the local environment file with:

```powershell
Copy-Item .env.example .env
```

The default template works as a development smoke setup. Without a reachable `MONGODB_URI`, the server logs that it is using the in-memory development store. Without provider API keys, the news service returns the built-in fallback feed.

## Environment Variables

| Variable | Required | Purpose |
| --- | --- | --- |
| `PORT` | No | Express and Socket.IO port. Defaults to `5000`. |
| `CLIENT_ORIGIN` | No | Main browser origin allowed by CORS. Defaults to `http://localhost:5173`. |
| `MONGODB_URI` | No | MongoDB connection string. Empty or unavailable values use the in-memory store. |
| `JWT_SECRET` | Recommended | JWT signing secret. Code falls back to a development secret if omitted. |
| `JWT_EXPIRES_IN` | No | JWT lifetime. Defaults to `7d`. |
| `NEWSAPI_BASE_URL` | No | NewsAPI base URL. Defaults to `https://newsapi.org/v2`. |
| `NEWSAPI_KEY` | No | NewsAPI top-headlines key. |
| `NEWS_PAGE_SIZE` | No | Page size requested from NewsAPI. Defaults to `20`. |
| `GNEWS_API_KEY` | No | GNews top-headlines key. |
| `NEWS_REFRESH_SECONDS` | No | Refresh interval for scheduled live updates; scheduler enforces at least 15 seconds. |
| `PERSIST_NEWS` | No | Set `true` to persist articles when MongoDB is connected. |
| `HF_ENABLE_TRANSFORMERS` | No | Set `true` to load optional Hugging Face summarization and sentiment pipelines. |
| `HF_SUMMARY_MODEL` | No | Optional summarization model override. |
| `HF_SENTIMENT_MODEL` | No | Optional sentiment model override. |
| `VITE_API_URL` | No | Client API base URL. Defaults to `http://localhost:5000/api`. |
| `VITE_SOCKET_URL` | No | Client Socket.IO server URL. Defaults to `http://localhost:5000`. |

## Running

Run client and server together in development:

```bash
npm run dev
```

- Client: `http://localhost:5173`
- API health check: `http://localhost:5000/api/health`

Build the client:

```bash
npm run build
```

Start the server after a client build:

```bash
npm run start
```

Run the configured client lint check:

```bash
npm run lint
```

Docker Compose starts MongoDB and the built application API on port `5000`:

```bash
docker compose up --build
```

## Folder Structure

```text
NewsVisionAI/
|-- client/
|   |-- src/components/       UI widgets for feeds and analysis tools
|   |-- src/context/          Auth and theme contexts
|   |-- src/hooks/            Live news hook
|   |-- src/pages/            Route-level React pages
|   `-- src/services/         Axios API client
|-- server/
|   |-- docs/                Existing server API summary
|   `-- src/
|       |-- config/          Database connection state
|       |-- controllers/     HTTP handlers
|       |-- middleware/      Auth, validation, and errors
|       |-- models/          Mongoose schemas
|       |-- routes/          Express route declarations
|       `-- services/        News, AI, analytics, game, and memory logic
|-- docker-compose.yml
|-- Dockerfile
|-- package.json             npm workspace scripts
|-- API_DOCUMENTATION.md
|-- PROJECT_DOCUMENTATION.docx
`-- .env.example
```

## Screenshots

No screenshot image files are tracked in the current source tree. If screenshots are added later, keep them under a `screenshots/` folder and reference them here, for example:

```md
![Dashboard](screenshots/dashboard.png)
```

Suggested capture targets from the implemented UI are the dashboard, article detail analysis desk, AI analysis page, login/register pages, and saved articles page.

## API Endpoints

All REST endpoints are prefixed with `/api`.

| Method | Endpoint | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/health` | No | Health response |
| `POST` | `/auth/register` | No | Register and return a JWT |
| `POST` | `/auth/login` | No | Login and return a JWT |
| `GET` | `/news/getnews` | No | List analyzed news |
| `GET` | `/news/search` | No | Search current/persisted news |
| `GET` | `/news/compare` | No | Compare an article with a same-category prior item |
| `GET` | `/news/category/:category` | No | Category feed |
| `GET` | `/news/timeline/:id` | No | Generated story timeline |
| `GET` | `/news/:id` | No | Article details |
| `POST` | `/ai/summarize` | No | Summarize text |
| `POST` | `/ai/sentiment` | No | Analyze text sentiment |
| `POST` | `/ai/explain` | No | Explain an article by mode |
| `POST` | `/ai/reality` | No | Reality-meter analysis |
| `GET` | `/ai/trending` | No | Feed analytics |
| `GET` | `/user/profile` | Bearer JWT | Current public user |
| `GET` | `/user/bookmarks` | Bearer JWT | Saved articles |
| `POST` | `/user/bookmarks` | Bearer JWT | Save an article |
| `DELETE` | `/user/bookmarks/:articleId` | Bearer JWT | Remove a saved article |
| `GET` | `/user/interests` | Bearer JWT | Interest graph |
| `POST` | `/user/interests` | Bearer JWT | Track interest for an article |
| `POST` | `/predictions` | No | Outcome estimate for an article |
| `POST` | `/debate` | No | Counterarguments for an article |
| `POST` | `/emotion` | No | Emotion distribution for an article |
| `GET` | `/fakenews-game` | No | Random quiz question |
| `POST` | `/fakenews-game/answer` | No | Grade a quiz answer |
| `GET` | `/fakenews-game/leaderboard` | No | Top quiz scores |

See `API_DOCUMENTATION.md` for request bodies, response shapes, authentication, and errors.

Socket.IO emits `connected` on connection and scheduled `news:update` payloads containing refreshed articles, analytics, and live-provider metadata.

## Future Improvements

- Add automated backend and frontend tests; the package scripts currently expose client linting but no test command.
- Add a real password reset workflow for the existing forgot-password screen.
- Add documented screenshot assets for the implemented views.
- Add API schema validation for more non-auth request bodies and query parameters.
- Add persistent refresh/history behavior for timelines and article comparisons beyond current generated/fallback logic.
