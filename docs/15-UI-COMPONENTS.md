# 15. UI Components & Frontend System

This document covers the complete frontend layer of the WebCyber application:
the Jinja2 component system, all template pages, CSS architecture, and JavaScript behaviour.

---

## Overview

All UI is built with:

| Layer | Technology |
|-------|-----------|
| CSS framework | Tailwind CSS (CDN, JIT) with custom config |
| Fonts | Inter (UI), Plus Jakarta Sans (display headings), JetBrains Mono (code/mono) — Google Fonts |
| Markdown rendering | `mistune 3.x` via a custom `| markdown` Jinja2 filter |
| Icons | Inline SVG macros centralised in `components/icons.html` (Heroicons v2 style) |
| Forms | Flask-WTF fields passed to reusable Jinja2 macros |
| JS behaviour | `app/static/js/main.js` — vanilla JS, no frameworks |

---

## Directory Layout

```
app/
├── templates/
│   ├── base.html                  # Root layout, Tailwind config, font preload
│   ├── components/
│   │   ├── icons.html             # SVG icon macro library (30 macros)
│   │   ├── sidebar.html           # Collapsible sidebar navigation
│   │   ├── navbar.html            # Top navigation bar
│   │   ├── flash_messages.html    # Dismissible alert banners
│   │   ├── confirm_modal.html     # Global confirmation modal (danger / warning)
│   │   ├── form_input.html        # Reusable input + textarea macros
│   │   ├── button.html            # Button variant macros
│   │   └── card.html              # Content card macro
│   ├── auth/
│   │   ├── login.html
│   │   └── register.html
│   └── notes/
│       ├── list.html              # Notes dashboard
│       ├── view.html              # Single-note reader
│       ├── create.html            # New-note form
│       ├── edit.html              # Edit-note form
│       ├── archive.html           # Archived notes
│       └── trash.html             # Deleted notes
└── static/
    ├── css/style.css              # Custom layout system + utility overrides
    └── js/main.js                 # Sidebar, search, word counter, confirm modal
```

---

## base.html

The root layout every page extends via `{% extends 'base.html' %}`.

### Tailwind custom config (inline `tailwind.config`)

| Extension | Values |
|-----------|--------|
| Font families | `display` → Plus Jakarta Sans, `mono` → JetBrains Mono, `sans` → Inter |
| Extra font sizes | `2xs` (10px), `xs` (12px) … `4xl` (36px) with matching line-heights |
| Brand colours | `blue-550`, `blue-650` mid-stops for finer control |

### Sidebar-state flash prevention

An inline `<script>` runs **synchronously before first paint** to read `localStorage('sidebarCollapsed')` and add the `sidebar-collapsed` class to `<body>`. This prevents a visible layout shift on hard reload.

### Blocks exposed to child templates

| Block | Purpose |
|-------|---------|
| `extra_head` | Inject page-specific `<style>` or `<meta>` tags |
| `body` | Full page body content |

---

## Component: `icons.html`

Centralised SVG macro library. All icons are Heroicons v2 stroked outlines unless noted.

**Import pattern:**
```jinja2
{% from 'components/icons.html' import shield, plus, close %}
```

### Full macro list (30 macros)

| Macro | Icon | Notes |
|-------|------|-------|
| `shield` | Shield check | App logo / branding |
| `document` | Document text | Notes item |
| `plus` | Plus circle | Create action |
| `archive` | Archive box | Archive section |
| `trash` | Trash | Delete action |
| `logout` | Arrow right-on-rectangle | Sign out |
| `menu` | Bars 3 | Mobile hamburger |
| `collapse` | Bars 3 bottom-left | Sidebar collapse |
| `check` | Check (stroke) | Confirm / save |
| `edit` | Pencil-square | Edit action |
| `copy` | Clipboard | Copy content; accepts optional `id` attr |
| `back` | Arrow-left | Navigate back |
| `pin` | Map-pin (thumbtack) | Pinned-note indicator |
| `pin_filled` | Map-pin filled | Pinned state (active) |
| `eye` | Eye | View / read mode |
| `eye_slash` | Eye-slash | Hidden / password toggle |
| `search` | Magnifying glass | Search field |
| `tag` | Tag | Note category/tag |
| `clock` | Clock | Timestamps |
| `word_count` | Chart-bar | Word/char counter |
| `align_left` | Bars-3 left | Content alignment |
| `bookmark` | Bookmark | Save/favourite |
| `calendar` | Calendar | Date display |
| `restore` | Arrow-path | Restore from trash/archive |
| `download` | Arrow-down-to-line | Export / download file |
| `close` | X-mark | Dismiss overlays & alerts |
| `status_success` | Filled check-circle | Success flash message |
| `status_error` | Filled x-circle | Error flash message |
| `status_warning` | Filled triangle-warning | Warning flash message |
| `status_info` | Filled information-circle | Info flash message |

All macros accept a `cls` parameter for Tailwind size/colour overrides.
`copy` additionally accepts `id` to set an HTML `id` on the `<svg>`.

---

## Component: `sidebar.html`

Full-height left sidebar with collapsible behaviour.

### Features

- **Collapse / expand** — toggles the `sidebar-collapsed` class on `<body>`. State stored in `localStorage('sidebarCollapsed')` and restored before first paint (no FOUC).
- **Animated labels** — navigation link text (`<span class="sidebar-label">`) fades out via CSS opacity + max-width transition when collapsed.
- **Mobile drawer** — on screens `< lg`, the sidebar is off-canvas. Tapping the hamburger slides it in with a semi-transparent overlay (`#sidebar-overlay`).
- **Active state** — each nav link compares `request.endpoint` and applies `bg-blue-50 text-blue-700 font-semibold` to the current route.
- **User footer** — shows avatar initials, username, and email; collapses to avatar only in collapsed mode.

### Width variables (CSS custom properties)

| Variable | Value | State |
|----------|-------|-------|
| `--sb-w` | `256px` | Expanded |
| `--sb-w-sm` | `72px` | Collapsed |

---

## Component: `navbar.html`

Top bar rendered inside each page's `{% block body %}`.

### Features

- Displays the current page title from the `page_title` template variable.
- Optional CTA button via `navbar_cta_url` + `navbar_cta_label` template variables (e.g. "New Note" on the list page).
- Left side: mobile hamburger (triggers sidebar drawer) and desktop sidebar-collapse toggle.

---

## Component: `confirm_modal.html`

Global confirmation modal included once in `base.html`. Replaces all native `window.confirm()` calls across the app.

### Usage

Add `data-confirm` (and optionally `data-confirm-danger`) to any `<form>` or clickable element — no JS wiring needed per-use:

```jinja2
{# On a form (most common) #}
<form method="POST" action="…"
      data-confirm="Move this note to Trash?"
      data-confirm-danger="true">
  …
</form>

{# On a link or button #}
<a href="…" data-confirm="Are you sure?" data-confirm-danger="true">Delete</a>
```

### Visual modes

| `data-confirm-danger` | Icon background | Icon | OK button label | OK button colour |
|-----------------------|-----------------|------|-----------------|------------------|
| absent / `false` | `amber-50` | Triangle warning | "Confirm" | Amber |
| `true` | `rose-50` | × circle | "Yes, delete" | Rose |

### Behaviour

- Animated open (backdrop fade + panel scale-in) and close.
- Closes on **Escape** key or backdrop click.
- Focus moves to the OK button on open.
- On confirm, the matching form's `data-confirm` attribute is removed before `.submit()` is called (prevents re-trigger).
- For non-form elements (`<a>`, `<button>`) with `data-confirm`, the `href` navigation fires after confirm.

### Accessibility

- `role="dialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby`.

---

## Component: `flash_messages.html`

Dismissible alert banners for Flask `flash()` messages.

### Usage

```jinja2
{% include 'components/flash_messages.html' %}
```

### Categories → styles

| `flash(message, category=…)` | Background | Border | Icon |
|-----------------------------|-----------|--------|------|
| `'success'` | `green-50` | `green-200` | `status_success` |
| `'danger'` | `rose-50` | `rose-200` | `status_error` |
| `'warning'` | `amber-50` | `amber-200` | `status_warning` |
| *(any other / default)* | `cyan-50` | `cyan-200` | `status_info` |

### Accessibility

- Wrapper has `role="region" aria-label="Notifications"`.
- Each alert has `role="alert"` and `aria-live="polite"`.
- Dismiss button has `aria-label="Dismiss"`.

### Dismiss behaviour

```html
<button onclick="this.closest('[role=alert]').remove()">…</button>
```
Pure JS — no dependencies, no page reload.

---

## Component: `form_input.html`

Macros for WTForms fields with consistent labelling, validation, and accessibility.

### Import

```jinja2
{% from 'components/form_input.html' import render, render_textarea %}
```

### `render(field, label, type, placeholder, autocomplete, hint)`

Renders a `<label>` + `<input>` pair.

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `field` | WTForms field | — | `form.email`, `form.password`, etc. |
| `label` | string | — | Display label text |
| `type` | string | `'text'` | HTML input type |
| `placeholder` | string | `''` | Placeholder text |
| `autocomplete` | string | `''` | `autocomplete` attribute value |
| `hint` | string | `''` | Helper text shown below (hidden when errors present) |

**Validation state:**
- Normal: `border-gray-200 hover:border-gray-300 focus:ring-blue-500/20`
- Error: `border-rose-400 focus:ring-rose-500/20` + `aria-invalid="true"` + `aria-describedby` pointing to the error list

### `render_textarea(field, label, placeholder, rows, hint)`

Same as `render` but outputs a `<textarea>` with:
- A live **word / character counter** (`data-wc-words` and `data-wc-chars` data attributes, updated by `main.js`)
- `resize-y` to allow vertical resizing only

### Label style

Both macros use `text-xs font-semibold uppercase tracking-wider text-gray-500` — the overline/eyebrow convention used throughout the app.

---

## Component: `button.html`

Button variants as Jinja2 macros covering the full action hierarchy.

### Import

```jinja2
{% from 'components/button.html' import btn_primary, btn_secondary, btn_danger, btn_ghost, btn_icon %}
```

### Variants

| Macro | Visual | Use case |
|-------|--------|----------|
| `btn_primary(label, type, show_icon, extra)` | Solid blue, white text, shadow | Primary submit/save action |
| `btn_secondary(label, href, extra)` | Ghost outlined, gray text | Cancel / navigate back |
| `btn_danger(label, href, confirm_msg, extra)` | Rose outlined | Destructive actions — wraps a `<form POST>` with CSRF token; triggers the confirm modal via `data-confirm` |
| `btn_ghost(label, href, extra)` | Borderless, gray text | Low-emphasis secondary links |
| `btn_icon(icon_html, title, type, extra)` | 32×32 square icon button | Toolbar actions (copy, edit, etc.) |

---

## Component: `card.html`

Wrapper card for grouping related content.

### Import

```jinja2
{% from 'components/card.html' import card %}
```

### Usage

```jinja2
{# Basic #}
{% call card(title='Settings') %}
  ...content...
{% endcall %}

{# With header action link #}
{% call card(title='Recent Notes', action_label='View all', action_href=url_for('notes.list_notes')) %}
  ...content...
{% endcall %}

{# Flush — no body padding (for tables, code blocks) #}
{% call card(title='Results', pad='') %}
  ...content...
{% endcall %}
```

### Parameters

| Param | Default | Description |
|-------|---------|-------------|
| `title` | `''` | Card header title (header omitted if empty) |
| `subtitle` | `''` | Smaller text below the title |
| `action_label` | `''` | Optional right-aligned link label in header |
| `action_href` | `'#'` | URL for the header action link |
| `extra` | `''` | Extra Tailwind classes for the outer `<div>` |
| `pad` | `'px-6 py-6'` | Body padding — pass `''` for flush content |

---

## Page Templates

### Auth pages (`auth/`)

| File | Route | Description |
|------|-------|-------------|
| `login.html` | `GET/POST /auth/login` | Email + password sign-in form |
| `register.html` | `GET/POST /auth/register` | Username, email, password registration |

Both pages use a **centred two-column layout** (branding panel + form card) on desktop, collapsing to a single column on mobile. They use `render` macros from `form_input.html` and `btn_primary` from `button.html`.

### Notes pages (`notes/`)

| File | Route | Key features |
|------|-------|-------------|
| `list.html` | `GET /notes/` | Card grid, live client-side search, empty state, per-card ⋯ menu with **Download as .md / .txt** |
| `view.html` | `GET /notes/<id>` | Markdown-rendered body, pin badge, copy-to-clipboard, **Download as .md / .txt**, word/char stats, edit/delete actions |
| `create.html` | `GET/POST /notes/new` | Title + content textarea with live word counter |
| `edit.html` | `GET/POST /notes/<id>/edit` | Pre-filled form, same layout as create |
| `archive.html` | `GET /notes/archive` | Archived notes list with restore action |
| `trash.html` | `GET /notes/trash` | Soft-deleted notes; amber info strip warning about 30-day auto-purge; restore and permanent-delete actions |

---

## CSS Architecture (`style.css`)

### Custom properties

```css
:root {
  --sb-w:    256px;   /* sidebar expanded width  */
  --sb-w-sm:  72px;   /* sidebar collapsed width */
}
```

### Sidebar layout system

The main content area is offset by the sidebar width using `margin-left` on `.main-content`. On collapse, `.sidebar-collapsed .main-content` transitions to `--sb-w-sm`. Transitions use `cubic-bezier(0.4, 0, 0.2, 1)` (Material standard easing).

The `.no-transition` class is applied temporarily on page load to prevent transition flickers when restoring sidebar state from `localStorage`.

### `.sidebar-label` animation

Navigation labels fade out gracefully on sidebar collapse:
```css
.sidebar-collapsed .sidebar-label {
  opacity: 0;
  max-width: 0;
  overflow: hidden;
}
```

### Prose / markdown styles

`.prose` styles are applied to the note body rendered via the `| markdown` filter, covering: headings (h1–h6), paragraphs, links, `<code>`, `<pre>`, blockquotes, ordered/unordered lists, inline `<strong>` and `<em>`, and horizontal rules. All sized relative to the base `text-sm` scale.

### Custom scrollbar (WebKit)

Thin, rounded scrollbar on the sidebar and main content area using `::-webkit-scrollbar`, `::-webkit-scrollbar-track`, and `::-webkit-scrollbar-thumb`.

---

## Note Download Feature

Route: `GET /notes/<id>/export?fmt=<md|txt>`

Allows users to download any note as a file directly from the browser. Available in:
- The `⋯` dropdown on every note card in `list.html`
- The `⋯` dropdown in `view.html`

### Formats

| `?fmt=` | Filename | MIME type | Content |
|---------|----------|-----------|---------|
| `md` (default) | `Note title.md` | `text/markdown` | Raw Markdown with an HTML comment header containing created/updated timestamps |
| `txt` | `Note title.txt` | `text/plain` | Markdown syntax stripped (headings, bold, italic, code blocks, links, bullets, blockquotes) with a plain-text title underline and date header |

The note title is sanitised to a safe filename (special characters replaced with `_`, capped at 80 characters).

### Security

- Ownership check: `abort(404)` if the note does not belong to `current_user` — prevents IDOR.
- Markdown stripping for `.txt` uses stdlib `re` only — no extra dependencies.

---

## JavaScript (`main.js`)

All behaviour is initialised on `DOMContentLoaded` using three init functions.

### `initSidebar()`

| Behaviour | Mechanism |
|-----------|-----------|
| Collapse / expand sidebar | Toggles `sidebar-collapsed` on `<body>` |
| Persist state | `localStorage.setItem('sidebarCollapsed', …)` |
| Mobile overlay open | Adds `sidebar-mobile-open` to `<body>`, shows `#sidebar-overlay` |
| Mobile overlay close | Click on overlay removes the class |

### `initNoteSearch()`

Live search on the notes `list.html` page.

- Listens to `input` on `#note-search`.
- For each `.note-card`, compares the search term against the card's `data-title` and `data-body` attributes (lowercase).
- Hides non-matching cards instantly (no server round-trip).
- Shows a `#no-results` empty-state element when nothing matches.

### `initWordCount()`

Live word and character counter for all textareas using `data-wc-words` / `data-wc-chars` data attributes (set by the `render_textarea` macro).

- Splits on `/\s+/` to count words; uses `.length` for character count.
- Updates on `input` event.
- Also counts on page load so the display is correct for pre-filled edit forms.

### Confirm modal (IIFE)

Runs as a self-contained IIFE after `DOMContentLoaded`. Intercepts destructive actions app-wide.

| Behaviour | Mechanism |
|-----------|-----------|
| Intercept form submit | `document.addEventListener('submit', …, true)` — capture phase so it fires before the form submits |
| Intercept link/button click | `document.addEventListener('click', …, true)` — looks for closest `[data-confirm]` ancestor |
| Open animation | `backdrop opacity-0 → opacity-100`, `panel scale-95/opacity-0 → scale-100/opacity-100` via RAF |
| Close animation | Reverse transitions, then `hidden` class restored after 200 ms |
| Confirm action | Removes `data-confirm` from the form, calls `.submit()`; or calls `window.location.href` for links |
| Keyboard | `Escape` closes the modal |
| Backdrop click | Closes the modal |

---

## Security notes

- **CSRF** — all `POST` forms include `{{ csrf_token() }}` (Flask-WTF). The `btn_danger` macro and the confirm modal's form submission both preserve the CSRF token.
- **No `window.confirm()`** — the native browser dialog is replaced by the custom modal throughout the app, preventing inconsistent UX across browsers.
- **XSS** — Jinja2 auto-escapes all template variables by default. The `| markdown` filter output is marked `| safe` only after being processed by `mistune`, which sanitises HTML by default.
- **Inline JS data** — where JavaScript needs server-rendered data (e.g. the note body for copy-to-clipboard), the value is placed in a `<script type="application/json" id="…">` element and read via `JSON.parse(document.getElementById('…').textContent)`. This avoids injecting raw server strings into executable JS contexts.
