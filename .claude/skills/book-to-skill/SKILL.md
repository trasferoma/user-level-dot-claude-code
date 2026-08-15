---
name: book-to-skill
description: "Converts books and documents (PDF, EPUB, DOCX, HTML, Markdown, plain text, RTF, MOBI/AZW with Calibre) into structured agent skills, extracting frameworks, mental models, principles, techniques, and anti-patterns. Use when the user wants to study a document through Amp or Claude Code, apply an author's frameworks while working, or build a reusable knowledge base from a file."
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
argument-hint: <path-to-document> [skill-name-slug]
---

# Book-to-Skill Converter

Transform written knowledge into actionable agent skills by extracting structure — not producing summaries.

Portable across Amp skill directories (`.agents/skills`, `~/.config/agents/skills`, `~/.config/amp/skills`) and Claude Code skill directories (`~/.claude/skills`, `.claude/skills`). Requires Python 3 on PATH for text extraction.

## Philosophy

Books contain crystallized expertise: frameworks, principles, and techniques that took years to develop. This skill extracts that knowledge into a format Amp, Claude Code, or another compatible agent can leverage repeatedly.

**Extract structure, not summaries.** A skill isn't a book report. It's a toolkit of:
- Named frameworks (mental models with clear application)
- Actionable principles (rules that guide decisions)
- Techniques (step-by-step methods)
- Anti-patterns (what to avoid and why)
- Voice calibration (how the author thinks and communicates)

**Preserve the author's precision.** Frameworks often have specific names for reasons. "The 5 Whys" isn't interchangeable with "ask why multiple times." Capture the exact formulation.

**Layer depth appropriately.** Simple books → simple skills. Complex books with 10+ frameworks → skills with reference files and on-demand chapters.

---

## Modes of Operation

Three paths available. Route based on what the user asks:

### 1. Full Conversion (Default)
**Trigger:** User provides a supported document path without special instructions
**Action:** Run all steps below (Steps 0–9)
**Output:** Complete skill with SKILL.md, chapters/, glossary, patterns, cheatsheet

### 2. Analyze Only
**Trigger:** User says "analyze", "just extract", or "I want to review before generating"
**Action:** Run Steps 0–3, then produce a structured extraction report (frameworks, principles, techniques found). Stop — do NOT generate skill files.
**Output:** Analysis report for user review

### 3. Generate from Prior Analysis
**Trigger:** User has existing analysis notes or previously ran analyze-only
**Action:** Skip Steps 0–3, use the provided analysis as input, run Steps 4–9
**Output:** Skill files from the provided analysis

---

## Skill Locations

This converter can run from multiple skill systems. When looking for this converter's helper script or writing the generated book skill, prefer these locations in order:

1. Amp project-local skills: `.agents/skills/`
2. Amp global skills: `~/.config/agents/skills/`
3. Amp legacy global skills: `~/.config/amp/skills/`
4. Claude Code skills: `~/.claude/skills/`

Generated skills should default to `~/.config/agents/skills/` for Amp unless the user asks for project-local or Claude Code output.

---

## Step 0 — Out-of-scope check

If the argument is NOT a path to a supported document file, stop and respond:
> "book-to-skill requires a supported document path. Usage: `book-to-skill /path/to/book.pdf [skill-name]`, `book-to-skill /path/to/book.epub [skill-name]`, or another supported format such as `.docx`, `.md`, `.txt`, `.html`, `.rtf`, `.mobi`, or `.azw3`."

Throughout the workflow, treat the first argument as `BOOK_PATH` and the optional second argument as `SKILL_NAME`.

---

## Step 1 — Validate input

```bash
test -f "$BOOK_PATH" && echo "FILE_OK" || echo "FILE_NOT_FOUND: $BOOK_PATH"
case "${BOOK_PATH##*.}" in
  pdf|PDF|epub|EPUB|docx|DOCX|txt|TXT|md|MD|markdown|MARKDOWN|rst|RST|adoc|ADOC|asciidoc|ASCIIDOC|html|HTML|htm|HTM|rtf|RTF|mobi|MOBI|azw|AZW|azw3|AZW3) echo "FORMAT_OK" ;;
  *) echo "FORMAT_UNKNOWN" ;;
esac
```

Check the file extension (`.pdf`, `.epub`, `.docx`, `.txt`, `.md`, `.markdown`, `.rst`, `.adoc`, `.html`, `.htm`, `.rtf`, `.mobi`, `.azw`, `.azw3`) or magic bytes (`%PDF` or `PK` zip header for EPUB/DOCX).

If the file is not found or the format is not supported, stop with a clear error message listing supported formats.

---

## Step 1.5 — Identify book type

Before extracting, ask the user:

> "What kind of content does this book have? This helps me choose the best extraction method.
>
> 1. **Technical** — has code blocks, tables, formulas, diagrams (e.g. programming books, academic papers, architecture guides)
> 2. **Text-heavy** — mostly prose, few or no tables/code (e.g. management, productivity, narrative non-fiction)
> 3. **Not sure** — I'll use the fast method and warn you if quality seems limited"

Store the answer as `BOOK_TYPE`:
- Option 1 → `BOOK_TYPE=technical`
- Option 2 → `BOOK_TYPE=text`
- Option 3 → `BOOK_TYPE=text`

**If `BOOK_TYPE=technical`**, inform the user before proceeding:
> "📐 Technical mode selected — using Docling for structure-aware extraction (tables, code blocks, formulas preserved as markdown). This takes ~1.5s per page, so expect a few minutes for longer books. Starting now…"

**If `BOOK_TYPE=text`**, inform:
> "📄 Text mode selected — using the fastest suitable extractor for this file type. Plain text/Markdown/HTML are usually ready in seconds; PDFs use pdftotext when available."

---

## Step 2 — Extract text from the source document

Run the extraction script, passing the book type:

```bash
SCRIPT_PATH="${CLAUDE_SKILL_DIR}/scripts/extract.py"

if [ ! -f "$SCRIPT_PATH" ]; then
  # Fallback for agents that don't expose CLAUDE_SKILL_DIR (e.g. Amp).
  for candidate in \
    ".agents/skills/book-to-skill/scripts/extract.py" \
    "$HOME/.config/agents/skills/book-to-skill/scripts/extract.py" \
    "$HOME/.config/amp/skills/book-to-skill/scripts/extract.py"
  do
    if [ -f "$candidate" ]; then
      SCRIPT_PATH="$candidate"
      break
    fi
  done
fi

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "Could not find scripts/extract.py for book-to-skill" >&2
  exit 1
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  PYTHON_BIN="python"
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "Python 3 is required but neither python3 nor python is on PATH." >&2
  echo "Install Python 3, or set PYTHON_BIN to its full path." >&2
  exit 1
fi

"$PYTHON_BIN" "$SCRIPT_PATH" "$BOOK_PATH" --mode <BOOK_TYPE> --install-missing ask
```

Before extraction, the script checks optional Python packages needed for the detected format. If a better extractor is missing, it prompts the user with the available fallback, for example:

> "DOCX extraction uses python-docx if installed, otherwise a stdlib ZIP/XML parser. Missing package(s) detected. Do you want to install? y=install, n=fallback"

Use `--install-missing yes` to install missing Python packages without prompting, `--install-missing no` or `--no-install-missing` to always use fallbacks, or `BOOK_SKILL_INSTALL_MISSING=yes|no|ask` to set the behavior by environment variable. Non-interactive sessions default to fallback unless install mode is explicitly `yes`.

- PDF `--mode technical` → uses Docling (layout-aware, preserves tables and code blocks as markdown)
- PDF `--mode text` → uses pdftotext → PyPDF2 → pdfminer fallback chain (fast, plain text)
- EPUB → uses ebooklib + BeautifulSoup4, then stdlib ZIP/HTML fallback
- DOCX → uses python-docx, then stdlib ZIP/XML fallback
- TXT/Markdown/reStructuredText/AsciiDoc → reads directly as text
- HTML → uses BeautifulSoup4, then stdlib HTML fallback
- RTF → uses striprtf, then a basic regex fallback
- MOBI/AZW/AZW3 → uses Calibre `ebook-convert` when installed. Calibre is an external app, not a pip package, so the script reports how to install it if missing.

This creates:
- `<tempdir>/book_skill_work/full_text.txt` — full extracted text
- `<tempdir>/book_skill_work/metadata.json` — title, estimated pages, token count, size, extraction_mode

Read the `output_text` path in `<tempdir>/book_skill_work/metadata.json` to understand what was extracted. The extractor uses the platform temp directory by default and supports `BOOK_SKILL_WORKDIR` if an explicit work directory is needed.

---

## Step 2.5 — Pre-flight cost estimate

Read `<tempdir>/book_skill_work/metadata.json` and present the user with an estimate **before doing any generation**:

```
📖 Source detected: <filename> (<format>)
📄 Pages/Spine items/Sections: ~<N> | Words: ~<N> | Source tokens: ~<N>K

💰 Estimated token cost (Full Conversion):
   Input  (book reading + prompts): ~<N>K tokens
   Output (skill files generated):  ~<N>K tokens
   Total:                           ~<N>K tokens

   Reference prices (as of 2025):
   Claude Sonnet 4.5 → ~$<X> USD
   Claude Haiku 4.5  → ~$<X> USD

   ⏱  Estimated time: ~<N> minutes

📁 Files to be generated:
   SKILL.md + <N> chapter files + glossary + patterns + cheatsheet

➡  Proceed with Full Conversion? (or type "analyze only" to preview first)
```

**How to estimate:**
- Input tokens ≈ `estimated_tokens` from metadata × 1.3 (prompts overhead per chapter pass)
- Output tokens ≈ chapters × 1,000 + 4,000 (SKILL.md) + 4,500 (glossary + patterns + cheatsheet)
- Price: Sonnet input=$3/MTok output=$15/MTok — Haiku input=$0.80/MTok output=$4/MTok

Wait for the user to confirm before proceeding. If they say "analyze only", switch to Mode 2.

---

## Step 2.6 — REPL-style access for large books (> 50k tokens)

Inspired by the Recursive Language Model (RLM) paradigm: treat `full_text.txt` as a queryable corpus, not a single read. Loading the whole file into context burns budget you will need later for generation.

For books over ~50k tokens, prefer programmatic probes over `Read(full_text.txt)` without bounds:

```bash
# Size check before any Read
wc -w "$FULL_TEXT_PATH"

# Find chapter offsets without loading the whole file
grep -n -E "^\s*(Chapter|CHAPTER)\s+[0-9]+" "$FULL_TEXT_PATH" | head -40

# Pull only the chapter you need (lines start..end inclusive)
sed -n '<start>,<end>p' "$FULL_TEXT_PATH"

# Verify a framework is actually mentioned before claiming it in SKILL.md
grep -c -i "westrum\|dora" "$FULL_TEXT_PATH"

# Targeted Read with offset/limit avoids dumping the full file
# Read(file_path=full_text.txt, offset=<line>, limit=<lines>)
```

Use this approach for Step 3 (structure analysis), Step 7 (per-chapter summaries), and Step 8 (glossary / patterns extraction). On books under 50k tokens, a single `Read` is fine.

Why this matters: a 200-page book is ~75k tokens. Re-reading it once per chapter (28 passes) costs ~2M input tokens; using grep + sed to pull only relevant slices keeps generation cost proportional to the output, not the source.

---

## Step 3 — Analyze book structure

Read the first 8,000 characters of the extracted `full_text.txt` to identify:
- Book **title** and **author(s)**
- **Chapter structure** (look for "Chapter N", "PART I", numbered headings, table of contents)
- **Core themes** and subject domain
- Approximate number of chapters

Then read the Table of Contents section if present to map all chapters.

**If mode is "Analyze Only":** produce the extraction report now and stop. Structure:
```
## Extraction Report — <Title>

### Author's Core Frameworks
- **<Framework Name>**: <what it is and when to apply>

### Key Principles
- <Principle>: <actionable rule>

### Techniques & Methods
- <Technique>: <step-by-step or how-to>

### Anti-patterns
- <What to avoid>: <why>

### Suggested Skill Name
`{author-lastname}-{core-concept}` — e.g. `cialdini-influence`

### Chapters Detected
| # | Title | Main Frameworks |
```

---

## Step 4 — Ask purpose (Full Conversion only)

Before generating, ask the user:

> "What should this skill help you do? (Pick one or more)
> 1. Apply the author's frameworks while working
> 2. Think with the author's mental models
> 3. Reference specific chapters and concepts
> 4. All of the above"

Use the answer to weight what gets highlighted in the SKILL.md Core section.

---

## Step 5 — Determine skill name

If `SKILL_NAME` was provided, use it as the skill slug.
Otherwise, propose two options and let the user choose:
- **By author-concept**: `{author-lastname}-{core-concept}` (e.g. `cialdini-influence`, `meadows-systems`)
- **By title**: lowercase hyphens from book title (e.g. `designing-data-intensive-apps`)

Default to author-concept format if the book has a strong methodological identity.

Choose the destination skill root:
- **Amp default**: `~/.config/agents/skills`
- **Amp project-local**: `.agents/skills` when the user explicitly wants the generated book skill scoped to the current workspace
- **Amp legacy**: `~/.config/amp/skills` if that is the user's existing global skill location
- **Claude Code**: `~/.claude/skills` if the user explicitly asks for Claude Code output

Set `SKILLS_HOME` to the selected root and check that `$SKILLS_HOME/<skill_name>/` does NOT already exist.
If it does, append `-2` or ask the user before overwriting.

---

## Step 6 — Create skill directory structure

```bash
mkdir -p "$SKILLS_HOME/<skill_name>/chapters"
```

---

## Step 7 — Generate chapter summaries

**TOKEN BUDGET RULE — CRITICAL:**
- Each chapter summary file: **800–1,200 tokens** (dense, not verbose)
- Files are loaded on-demand — they are NOT capped per se, but keep them useful and tight

For EACH chapter/major section identified in Step 3:

Read the corresponding section of the extracted `full_text.txt` (use character offsets or grep for chapter headings).

Create `$SKILLS_HOME/<skill_name>/chapters/ch<NN>-<slug>.md`.

**Use the chapter summary template in [reference/templates.md](reference/templates.md).** It carries the full section structure and the per-`BOOK_TYPE` emphasis rules.

---

## Step 8 — Generate supporting files

Create three files alongside the chapters. **Templates and formats: [reference/templates.md](reference/templates.md).**

| File | Content | Budget |
|------|---------|--------|
| `glossary.md` | every significant term, alphabetical | 1,500 tokens |
| `patterns.md` | techniques, design patterns, algorithms | 2,000 tokens |
| `cheatsheet.md` | decision tables and quick-reference rules | 1,000 tokens |

---

## Step 9 — Generate the master SKILL.md

**CRITICAL TOKEN BUDGET: Keep SKILL.md body under 4,000 tokens.**
Compaction truncates from the END — put the most important content FIRST.

Create `$SKILLS_HOME/<skill_name>/SKILL.md` from the **master template in [reference/templates.md](reference/templates.md)**.

Non-negotiable properties of the generated skill:
- `description` names the book, the author, and the topics that should trigger it — plus an explicit "Use when…" clause
- Core Frameworks section first, chapter and topic indexes after: compaction truncates from the end
- Chapter files linked one level deep from the generated SKILL.md, never chained through each other
- No generation date: it is time-sensitive information that ages the skill for no benefit

---

## Step 10 — Cleanup and report

```bash
PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  PYTHON_BIN="python"
fi

"$PYTHON_BIN" - <<'PY'
import os
import shutil
import tempfile
from pathlib import Path
shutil.rmtree(
    os.environ.get("BOOK_SKILL_WORKDIR", Path(tempfile.gettempdir()) / "book_skill_work"),
    ignore_errors=True,
)
PY
```

Then report to the user:

```
✅ Skill created: $SKILLS_HOME/<skill_name>/

📚 Book: <Full Title> — <Author>
📄 Pages: ~<N> | Chapters: <N>

Files generated:
  SKILL.md         — core frameworks + index   (~X tokens)
  chapters/        — <N> chapter summaries     (~X tokens each, ~X total)
  glossary.md      — key terms                 (~X tokens)
  patterns.md      — techniques & patterns     (~X tokens)
  cheatsheet.md    — quick reference           (~X tokens)
  ─────────────────────────────────────────────────────
  Total skill size: ~X tokens (loaded on-demand, not all at once)

💡 Tip: check your agent's session cost/usage command to see actual token usage.

Usage:
  Ask for <skill_name>                  → load core frameworks
  Ask <skill_name> about <topic>        → find and explain a topic
  Ask <skill_name> for ch<N>            → dive into a specific chapter
```

---

## Quality Rules

1. **Extract structure, not summaries** — capture named frameworks, exact formulations, anti-patterns; not chapter recaps
2. **Preserve the author's precision** — "The 5 Whys" ≠ "ask why multiple times"; keep exact naming
3. **Density over completeness** — a 1,000-token summary beats a 10,000-token excerpt
4. **Practitioner voice** — write "Use X when Y", not "The book explains X"
5. **Front-load SKILL.md** — compaction keeps the first 5,000 tokens; most important content comes first
6. **Chapter files are on-demand** — they don't count against skill budget until loaded
7. **Never copy raw book text** — always synthesize, summarize, extract signal
8. **Topic index is critical** — it's how the agent navigates to the right chapter file
