# Tavily: agent / RAG / CLI workflow (digest)

Aligns the **Tavily** skills (`tavily-search`, `tavily-research`, `tavily-best-practices`) with this **Kinoite workspace**. On hosts **without** the `tvly` binary, use the **API** (Python/JS) or the links below; store outputs under `../research/` or `../.firecrawl/`.

## Official

- [Best practices: search](https://docs.tavily.com/documentation/best-practices/best-practices-search)  
- [Search API reference](https://docs.tavily.com/documentation/api-reference/endpoint/search)  
- [Tavily GitHub: skills (tavily-best-practices)](https://github.com/tavily-ai/skills)  

## `search` (RAG, agents)

- **Query length:** under **~400 characters** — search-shaped, not a long prompt.  
- **Sub-queries:** break multi-topic work into **2–3** focused searches instead of one giant string.  
- **`max_results`:** default **5**; cap **~10–20** when you need breadth; very high values dilute signal.  
- **`search_depth`:** `ultra-fast` / `fast` / `basic` (default) / `advanced` — use **`advanced`** when you need the tightest evidence; pay attention to **credits/cost** in vendor docs.  
- **`include_domains` / `exclude_domains`:** pin to **Fedora**, **Flathub**, **Microsoft Learn (WSL)**, etc., when the question is not “broad web.”  
- **`include_raw_content` / chunks:** when building citations for `docs/`, one **`advanced`** call with **chunks** may replace a separate “extract this URL” step.  
- **`time_range`:** for “WSL2 systemd 2024+”-style questions, filter recency.  

## `extract` / `crawl` / `map`

- **`extract`:** 1–20 URLs per call; use for **known** spec pages (e.g. a single `learn.microsoft.com` WSL page).  
- **`crawl` / `map`:** site-wide discovery — use sparingly; set **depth/breadth** limits.  

## `research` (synthesis)

- **`model`:** `mini` vs `pro` vs `auto` — per **tavily-research** skill: “what is X” → `mini`; **compare X vs Y** → `pro`.  
- **Latency:** 30–120s — prefer **`--stream`** in CLI when available for visibility.  
- **Async:** `--no-wait` + `poll` for long runs in agent loops.  

## Map to this repo

| Question type | Suggested call |
|----------------|----------------|
| Fedora Kinoite install / rebase | `search` + `include_domains` → `fedoraproject.org`, `docs.fedoraproject.org` |
| WSL2 systemd, `.wslconfig` | `search` → `learn.microsoft.com` |
| Flathub app id | `search` or one **`extract`** on `flathub.org/apps/...` |

**CLI:** [Tavily CLI](https://tavily.com) (`tvly login` / `tvly search` / `tvly research`) — not required if API/agents are used. See `../docs/research-workflow-tavily-firecrawl.md` for Firecrawl and credit hygiene.
