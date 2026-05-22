$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$output = Join-Path $PSScriptRoot 'PROJECT_DOCUMENTATION.docx'
$temp = Join-Path $PSScriptRoot '.project-docx-temp'
function Assert-WorkspaceChild([string] $path) {
  $root = (Resolve-Path -LiteralPath $PSScriptRoot).Path
  $full = [System.IO.Path]::GetFullPath($path)
  if (-not $full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to change a path outside the project root: $full"
  }
}

Assert-WorkspaceChild $temp
if (Test-Path $temp) {
  Remove-Item -LiteralPath $temp -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $temp '_rels') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $temp 'docProps') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $temp 'word\_rels') | Out-Null

function Escape-Xml([string] $value) {
  return [System.Security.SecurityElement]::Escape($value)
}

function Para([string] $text, [string] $style = '') {
  $safe = Escape-Xml $text
  $styleXml = if ($style) { "<w:pPr><w:pStyle w:val=`"$style`"/></w:pPr>" } else { '' }
  return "<w:p>$styleXml<w:r><w:t xml:space=`"preserve`">$safe</w:t></w:r></w:p>"
}

function Lines([string[]] $items) {
  return ($items | ForEach-Object { Para $_ }) -join "`n"
}

$body = @()
$body += Para 'NewsVision AI' 'Title'
$body += Para 'Complete Project Documentation' 'Subtitle'
$body += Para 'Generated from the repository code and structure' 'Subtitle'
$body += Para 'Project type: React/Vite client and Express/Mongoose API'
$body += '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

$body += Para 'Abstract' 'Heading1'
$body += Para 'NewsVision AI is a real-time news analysis application. Its client presents headline feeds, article analysis tools, authentication, saved articles, analytics, and a fake-news quiz. Its server refreshes news from configured providers or a built-in fallback feed, analyzes articles with local heuristics or optional transformer pipelines, exposes REST APIs, emits Socket.IO updates, and uses MongoDB when configured with an in-memory development fallback.'

$body += Para 'Introduction' 'Heading1'
$body += Para 'The project combines a browser newsroom with server-side aggregation and article analysis. The codebase is organized as npm workspaces: a React client under client and an Express server under server. The server owns routing, data models, article enrichment, authentication, and refresh scheduling; the client owns navigation, presentation, protected saved-article UI, and API consumption.'

$body += Para 'Problem Statement' 'Heading1'
$body += Para 'Readers must move between raw news feeds, topic searches, credibility cues, summaries, and saved reading lists. This project addresses that problem by placing live headlines and interpretive analysis widgets behind a single API and client interface while retaining a local fallback mode when external providers or MongoDB are not available.'

$body += Para 'Objectives' 'Heading1'
$body += Lines @(
  '1. Aggregate news from NewsAPI or GNews when keys are configured and serve fallback headlines otherwise.',
  '2. Enrich articles with summaries, key points, keywords, and sentiment.',
  '3. Provide live analytics and realtime update events.',
  '4. Support registration, login, bookmarks, and tracked reading interests.',
  '5. Expose advanced article tools for explanation, reality signals, debate prompts, predictions, emotions, comparisons, timelines, and a fake-news game.'
)

$body += Para 'Scope' 'Heading1'
$body += Para 'The implemented scope includes REST endpoints, Socket.IO feed updates, a React interface, optional MongoDB persistence, fallback local data, optional Hugging Face model loading, and Docker packaging. The current code does not implement a backend password reset flow or an automated test suite.'

$body += Para 'Literature Review' 'Heading1'
$body += Para 'The codebase applies established web application components that are visible in its manifests and source: React and Vite for component rendering and development builds, Express for HTTP routing, Socket.IO for pushed updates, Mongoose for MongoDB schemas, JWT and bcryptjs for account tokens and password hashing, and optional Hugging Face Transformers for summarization and sentiment pipelines. It also uses deterministic heuristic services for credibility, prediction, debate, and emotion outputs when an external model is not involved.'

$body += Para 'System Architecture' 'Heading1'
$body += Lines @(
  'Browser UI: React pages, reusable analysis components, auth/theme contexts, Axios API client, Socket.IO client.',
  'HTTP/API layer: Express app, security middleware, route modules, validation, JWT protection, error middleware.',
  'Service layer: news refresh, AI enrichment, analytics, comparison, explanation, reality meter, prediction, debate, emotions, game, user interests.',
  'Data layer: Mongoose models for MongoDB plus memoryStore fallback for selected development flows.',
  'External inputs: NewsAPI and GNews when API keys exist; optional Hugging Face transformer pipelines when enabled.'
)

$body += Para 'Workflow Diagram' 'Heading1'
$body += Lines @(
  '[Browser] -> [React Axios request] -> [Express /api route]',
  '                                      |',
  '                                      v',
  '                            [Controller + service]',
  '                         /        |              \',
  '            [News providers] [AI heuristics] [MongoDB or memory]',
  '                         \        |              /',
  '                                      v',
  '                           [JSON response to UI]',
  '',
  '[Scheduler] -> [refreshNews + computeAnalytics] -> [Socket.IO news:update] -> [Browser feed]'
)

$body += Para 'Database Schema' 'Heading1'
$body += Lines @(
  'Article: title, description, content, author, category, source, url, imageUrl, publishedAt, sentiment, sentimentScore, summary, keyPoints, keywords, timestamps.',
  'User: name, email, password hash, savedArticles references, interests.openedArticles, interests.categories, interests.topics, interests.keywords, timestamps.',
  'Analytics: positive, negative, neutral percentages, trends, keywords, categories, activeNewsCount, timestamps.',
  'Question: headline, answer, explanation, level, timestamps.',
  'UserScore: userName, score, level, timestamps.',
  'Achievement: userName, title, timestamps.'
)

$body += Para 'ER Diagram Explanation' 'Heading1'
$body += Lines @(
  '[User] 1 ---- * [Article] through User.savedArticles ObjectId references.',
  '[Question] is read by the fake-news game and graded into answer responses.',
  '[UserScore] records leaderboard totals by userName and current level.',
  '[Achievement] records earned titles by userName.',
  '[Analytics] stores computed feed snapshots when MongoDB is connected.',
  'The interests subdocument is embedded in User rather than modeled as a separate collection.'
)

$body += Para 'API Documentation' 'Heading1'
$body += Lines @(
  'Health: GET /api/health.',
  'Authentication: POST /api/auth/register and POST /api/auth/login.',
  'News: GET /api/news/getnews, /search, /compare, /category/:category, /timeline/:id, and /:id.',
  'AI: POST /api/ai/summarize, /sentiment, /explain, /reality; GET /api/ai/trending.',
  'User JWT routes: GET /api/user/profile, /bookmarks, /interests; POST /api/user/bookmarks, /interests; DELETE /api/user/bookmarks/:articleId.',
  'Advanced tools: POST /api/predictions, /api/debate, and /api/emotion.',
  'Game: GET /api/fakenews-game and /leaderboard; POST /api/fakenews-game/answer.',
  'Detailed request, response, auth, and error shapes are documented in API_DOCUMENTATION.md.'
)

$body += Para 'Module Descriptions' 'Heading1'
$body += Lines @(
  'client/src/pages: Dashboard, category, article detail, AI analysis, login, register, forgot-password, and saved-articles screens.',
  'client/src/components: feed cards, layout, analytics widgets, and article analysis widgets.',
  'client/src/services/api.js: Axios endpoints and bearer-token injection.',
  'server/src/routes and controllers: route mapping and response handlers.',
  'server/src/services/newsService.js and scheduler.js: provider refresh, fallback feed, caching, persistence choice, and realtime broadcasts.',
  'server/src/services/aiService.js: article summarization, key points, keyword extraction, and sentiment analysis.',
  'server/src/models: MongoDB schema definitions.',
  'server/src/middleware: auth protection, auth input validation, not-found, and error handling.'
)

$body += Para 'Features Implemented' 'Heading1'
$body += Lines @(
  'Live feed, top headline dashboard, category browsing, search, and pagination.',
  'Article view with AI summary, keywords, source metadata, related articles, and outbound source link.',
  'Analytics panel and scheduled realtime news updates.',
  'AI analysis form for pasted text.',
  'Registration, login, bearer-token client storage, saved articles, and user interests.',
  'Reality meter, explanation modes, story timeline, comparison view, predictions, debate outputs, emotion heat map, and fake-news battle UI.'
)

$body += Para 'Screenshots With Descriptions' 'Heading1'
$body += Para 'No PNG, JPG, GIF, WebP, or AVIF screenshot files were found in the tracked project source scan. The README includes a screenshots section and a future screenshots/ reference pattern without claiming files that are absent.'
$body += Lines @(
  'Dashboard screenshot target: top headline edition, article cards, live status, and analytics panel.',
  'Article detail screenshot target: advanced AI desk widgets and story metadata.',
  'AI analysis screenshot target: pasted-text summary and sentiment output.',
  'Authentication screenshot target: login or registration page.',
  'Saved articles screenshot target: protected reading list.'
)

$body += Para 'Testing' 'Heading1'
$body += Para 'No automated test files or test script were found in the project manifests or source scan. The repository exposes npm run lint for the client and npm run build for the client production build. API setup can be smoke checked through GET /api/health after starting the development server.'

$body += Para 'Advantages' 'Heading1'
$body += Lines @(
  'Local fallback operation reduces setup friction.',
  'Provider-backed and persisted modes share one API surface.',
  'Article analysis features are split into small service modules.',
  'JWT-protected user routes isolate bookmark and interest data actions.',
  'Docker and npm workspace scripts provide multiple run paths.'
)

$body += Para 'Limitations' 'Heading1'
$body += Lines @(
  'Fallback articles and heuristic analysis are not equivalent to verified reporting or model-backed analysis.',
  'Password reset UI is present but no reset endpoint is implemented.',
  'Automated tests are absent.',
  'Socket.IO client listens for news:category:update while the current scheduler emits news:update.',
  'Persisted article history depends on both MongoDB connectivity and PERSIST_NEWS=true.'
)

$body += Para 'Future Scope' 'Heading1'
$body += Lines @(
  'Add backend and frontend tests and contract checks for API response shapes.',
  'Implement password recovery and stronger validation for advanced tool inputs.',
  'Store richer article history for comparison and timeline use cases.',
  'Add screenshot assets and release documentation.',
  'Add provider monitoring and model/pipeline observability.'
)

$body += Para 'Conclusion' 'Heading1'
$body += Para 'NewsVision AI already forms a complete local newsroom workflow: feeds enter through provider or fallback services, articles are enriched and delivered through REST and realtime channels, and the client layers analysis and saved-reading flows over that API. The documentation set captures the code-visible runtime, API, data model, and current limits without changing project functionality.'

$body += Para 'References' 'Heading1'
$body += Lines @(
  'Repository package.json, client/package.json, and server/package.json.',
  'server/src/app.js and server/src/index.js.',
  'server/src/routes, server/src/controllers, server/src/services, server/src/models, and server/src/middleware.',
  'client/src/App.jsx, client/src/pages, client/src/components, client/src/hooks/useNews.js, and client/src/services/api.js.',
  'Dockerfile, docker-compose.yml, and .env.example.'
)

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $($body -join "`n")
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720" w:header="360" w:footer="360"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:rPr><w:b/><w:sz w:val="44"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:rPr><w:sz w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="Heading 1"/><w:pPr><w:spacing w:before="240" w:after="100"/></w:pPr><w:rPr><w:b/><w:sz w:val="30"/></w:rPr></w:style>
</w:styles>
'@

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
'@

$rootRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
'@

$documentRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
'@

$coreXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:title>NewsVision AI Project Documentation</dc:title>
  <dc:creator>Codex</dc:creator>
</cp:coreProperties>
'@

$appXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
  <Application>Codex</Application>
</Properties>
'@

Set-Content -LiteralPath (Join-Path $temp '[Content_Types].xml') -Value $contentTypes -Encoding utf8
Set-Content -LiteralPath (Join-Path $temp '_rels\.rels') -Value $rootRels -Encoding utf8
Set-Content -LiteralPath (Join-Path $temp 'word\document.xml') -Value $documentXml -Encoding utf8
Set-Content -LiteralPath (Join-Path $temp 'word\styles.xml') -Value $stylesXml -Encoding utf8
Set-Content -LiteralPath (Join-Path $temp 'word\_rels\document.xml.rels') -Value $documentRels -Encoding utf8
Set-Content -LiteralPath (Join-Path $temp 'docProps\core.xml') -Value $coreXml -Encoding utf8
Set-Content -LiteralPath (Join-Path $temp 'docProps\app.xml') -Value $appXml -Encoding utf8

if (Test-Path $output) {
  Remove-Item -LiteralPath $output -Force
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($temp, $output)
Remove-Item -LiteralPath $temp -Recurse -Force
