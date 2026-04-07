# SearXNG setup guide

This guide covers the deployment of **SearXNG** for private metasearch and its integration with **Local LLMs** to replicate "AI Search Mode" (similar to Brave AI or Google AI Overviews) without compromising privacy.

-----

## 1\. Core Concepts & Comparison

### **What is SearXNG?**

SearXNG is a privacy-respecting metasearch engine. It aggregates results from 70+ engines (Google, Bing, DuckDuckGo, etc.) without storing user data or sharing your IP with the source engines.

### **Why Local AI Integration?**

By connecting SearXNG to a local LLM (via Ollama and Open WebUI), you create a **RAG (Retrieval-Augmented Generation)** pipeline. The AI "reads" the top search results from your private instance and provides a cited summary.

### **Deployment Comparison**

| Feature | Public Instance | Docker (Recommended) | Manual Install |
| :--- | :--- | :--- | :--- |
| **Privacy** | Trust-based | **Total Control** | Total Control |
| **Setup Effort** | None | Low (Scriptable) | High (Dependency hell) |
| **AI Integration** | Difficult/Limited | **Seamless** | Possible but complex |
| **Updates** | Automatic | `docker pull` | Manual git merge |

-----

## 2\. Infrastructure Setup (Docker Compose)

This configuration sets up the search engine, the Redis cache, and the AI frontend in one unified stack.

### **Directory Structure**

```bash
mkdir -p ~/search-stack/searxng
cd ~/search-stack
```

### **`docker-compose.yaml`**

```yaml
services:
  # The Database for caching and rate-limiting
  redis:
    image: docker.io/library/redis:7-alpine
    container_name: redis
    command: redis-server --save "" --appendonly no
    networks: [search-net]
    restart: always

  # The Search Engine
  searxng:
    image: docker.io/searxng/searxng:latest
    container_name: searxng
    networks: [search-net]
    ports: ["8080:8080"]
    volumes:
      - ./searxng:/etc/searxng:rw
    environment:
      - SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml
    depends_on: [redis]
    restart: always

  # The AI Frontend (AI Mode Interface)
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports: ["3000:8080"]
    extra_hosts: ["host.docker.internal:host-gateway"]
    environment:
      - OLLAMA_BASE_URL=http://host.docker.internal:11434
      - ENABLE_SEARCH=True
      - SEARCH_ENGINE=searxng
      - SEARXNG_QUERY_URL=http://searxng:8080/search?q=<query>
    networks: [search-net]
    restart: always

networks:
  search-net:
```

-----

## 3\. Configuration: `settings.yml`

Create `~/search-stack/searxng/settings.yml`. **Note:** You must generate a secret key using `openssl rand -hex 32` before starting.

```yaml
use_default_settings: true

server:
  secret_key: "REPLACE_WITH_YOUR_GENERATED_KEY"
  port: 8080
  bind_address: "0.0.0.0"
  base_url: http://localhost:8080/
  image_proxy: true # Proxies images through your server for privacy

search:
  safe_search: 0
  autocomplete: "duckduckgo"
  formats:
    - html
    - json # CRITICAL: Required for AI integration

ui:
  default_theme: simple
  center_alignment: true
  theme_args:
    simple_style: auto # Auto Light/Dark mode

redis:
  url: redis://redis:6379/0

engines:
  - name: google
    engine: google
    use_mobile_ui: true
  - name: brave
    engine: brave
  - name: arch linux wiki
    engine: archlinux
    shortcut: al
  - name: github
    engine: github
    shortcut: gh
```

-----

## 4\. Enabling "AI Search Mode"

1.  **Start the Stack:** Run `docker-compose up -d`.
2.  **Ensure Ollama is Running:** If Ollama is on your host Fedora/Arch machine, ensure it listens on all interfaces (check `OLLAMA_HOST` env var).
3.  **Configure Open WebUI:**
      * Navigate to `http://localhost:3000`.
      * Go to **Settings \> Web Search**.
      * Set Engine to `SearXNG`.
      * Set URL to `http://searxng:8080/search?q=<query>`.
4.  **Usage:** In the chat box, toggle the "Web Search" icon. Every query will now pull results from your SearXNG instance and provide a summarized AI answer with citations.

-----

## 5\. Advanced Workflows

  * **Custom Shortcuts:** Use `!al <query>` in the search bar to jump directly to the Arch Wiki, or `!gh <query>` for GitHub.
  * **JSON API usage:** You can query your search engine via CLI:
    `curl "http://localhost:8080/search?q=fedora+linux&format=json"`
  * **Maintenance:** To update the entire stack:
    ```bash
    docker-compose pull
    docker-compose up -d
    ```

-----

## 6\. References & Hyperlinks

### **Official Documentation**

  * **[SearXNG Settings Docs](https://www.google.com/search?q=https://docs.searxng.org/admin/settings/settings.html):** Comprehensive key-value reference.
  * **[SearXNG Engine List](https://docs.searxng.org/admin/settings/settings_engines.html):** Guide to configuring all 70+ supported engines.
  * **[Open WebUI Search Integration](https://www.google.com/search?q=https://docs.openwebui.com/features/web-search/):** How to tune the RAG/AI search parameters.

### **Tools & Community**

  * **[Searx.space](https://searx.space/):** List of public instances (useful for testing engine speeds).
  * **[Ollama Library](https://ollama.com/library):** Find models optimized for RAG (like `qwen2.5` or `llama3.2`).
  * **[Caddy Server](https://caddyserver.com/docs/):** Recommended if you decide to expose this to a public URL with automatic SSL.

### **Advanced Reading**

  * **[Privacy Guides: Search Engines](https://www.google.com/search?q=https://www.privacyguides.org/en/tools/search-engines/):** Why metasearch is superior to standard engines.
  * **[Search Engine Aggregation Logic](https://github.com/searxng/searxng/tree/master/searx/engines):** Dive into the Python source code for how each engine is scraped.