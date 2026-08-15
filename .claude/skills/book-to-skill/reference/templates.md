# Output templates for book-to-skill

## Contents
- Chapter summary template (Step 7)
- Supporting files: glossary, patterns, cheatsheet (Step 8)
- Master SKILL.md template (Step 9)

---

## Chapter summary template (Step 7)

One file per chapter at `$SKILLS_HOME/<skill_name>/chapters/ch<NN>-<slug>.md`.

Adapt emphasis to `BOOK_TYPE`:
- `technical` → prioritize "Code Examples", "Reference Tables", "Commands & APIs"; preserve exact syntax
- `text` → prioritize "Frameworks Introduced", "Mental Models", "Key Takeaways"; omit empty technical sections

````markdown
# Chapter N: <Full Title>

## Core Idea
<1–2 sentences: the single most important thing this chapter teaches>

## Frameworks Introduced
- **<Framework Name>**: <exact formulation — preserve the author's naming>
  - When to use: <specific situation>
  - How: <steps or criteria>

## Key Concepts
- **<Term>**: <precise definition in 1 sentence>
(5–10 most important terms from this chapter)

## Mental Models
<2–4 frameworks or thinking tools. Write as "Use X when Y" or "Think of X as Y">

## Anti-patterns
- **<What to avoid>**: <why it fails>

## Code Examples *(technical books only — omit if BOOK_TYPE=text)*
<!-- Copy the most instructive snippet from the chapter. Preserve indentation exactly. -->
```<language>
<key code example from this chapter>
```
- **What it demonstrates**: <one line>

## Reference Tables *(technical books only — omit if BOOK_TYPE=text)*
<!-- Reproduce any comparison matrix, parameter table, or decision table in markdown. -->

## Key Takeaways
1. <Actionable insight>
2. <Actionable insight>
3. <Actionable insight>
(3–7 takeaways a practitioner must remember)

## Connects To
- **Ch N**: <why this chapter relates>
- **<Concept>**: <external concept or standard it connects with>
````

---

## Supporting files (Step 8)

### glossary.md
`$SKILLS_HOME/<skill_name>/glossary.md`
- Every significant term from the book, alphabetically sorted
- Format: `**Term** — definition (Ch N)`
- Max 1,500 tokens

### patterns.md
`$SKILLS_HOME/<skill_name>/patterns.md`
- All concrete techniques, design patterns, algorithms from the book
- Format: `## Pattern Name` then `**When to use**:` / `**How**:` / `**Trade-offs**:`
- Max 2,000 tokens

### cheatsheet.md
`$SKILLS_HOME/<skill_name>/cheatsheet.md`
- Decision tables, comparison matrices, quick-reference rules
- The content you'd want on a single printed page
- Max 1,000 tokens

---

## Master SKILL.md template (Step 9)

Keep the generated body under 4,000 tokens. Compaction truncates from the END, so the most important content goes FIRST.

````markdown
---
name: <skill_name>
description: "Knowledge base from \"<Full Title>\" by <Author(s)>. Use when applying <author>'s frameworks for <key topics, 3–6 terms>, studying the book, or referencing its concepts."
allowed-tools:
  - Read
  - Grep
argument-hint: [topic, framework name, or chapter number]
---

# <Full Title>
**Author**: <Author(s)> | **Pages**: ~<N> | **Chapters**: <N>

## How to Use This Skill

- **Without arguments** — load core frameworks for reference
- **With a topic** — ask about an indexed topic; the relevant chapter gets read
- **With chapter** — ask for `ch05` to load that specific chapter
- **Browse** — ask "what chapters do you have?" to see the full index

When you ask about a topic not covered in Core Frameworks below, the relevant
chapter file is read before answering.

---

## Core Frameworks & Mental Models
<!-- ~2,000 tokens: the author's most important named frameworks and principles.
     Preserve exact names. Write as "Use X when Y", "Prefer X over Y because Z".
     This is a toolkit, not a summary. -->

<generate the most critical frameworks and insights here>

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-<slug>.md) | <Title> | <framework1>, <framework2> |
| [ch02](chapters/ch02-<slug>.md) | <Title> | <framework1>, <framework2> |

## Topic Index

<!-- Alphabetical. Major terms/frameworks → chapter(s) that cover them. -->
- **<Term>** → ch<N>[, ch<N>]

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions
- [patterns.md](patterns.md) — all techniques and design patterns
- [cheatsheet.md](cheatsheet.md) — quick reference tables and decision guides

---

## Scope & Limits

This skill covers the book content only. For hands-on implementation in your codebase,
combine with project-specific tools. For topics beyond this book, check related skills
or ask the agent directly.
````

> Do not put a generation date in the produced SKILL.md: it is time-sensitive information that ages the skill without adding value.
