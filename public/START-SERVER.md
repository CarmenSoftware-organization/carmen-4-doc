# How to Start the Documentation Website

⚠️ **IMPORTANT**: You MUST use a local web server. Opening `index.html` directly with `file://` protocol will NOT work because:
- Browsers block local file fetching via JavaScript (CORS policy)
- The Markdown loader needs to fetch `.md` files from the `../docs/` directory

## Quick Start (Choose One Method)

⚠️ **IMPORTANT**: Run the server from the **parent directory** (carmen-4-doc), NOT from docs-site!

### Option 1: Python (Recommended - Usually Pre-installed)

```bash
cd /Users/peak/Documents/GitHub/carmen-4-doc
python3 -m http.server 8000
```

Then open: **http://localhost:8000/docs-site/**

### Option 2: Node.js (If you have npm installed)

```bash
cd /Users/peak/Documents/GitHub/carmen-4-doc
npx http-server -p 8000
```

Then open: **http://localhost:8000/docs-site/**

### Option 3: PHP (If you have PHP installed)

```bash
cd /Users/peak/Documents/GitHub/carmen-4-doc
php -S localhost:8000
```

Then open: **http://localhost:8000/docs-site/**

### Option 4: VS Code Live Server Extension

1. Open `/Users/peak/Documents/GitHub/carmen-4-doc/docs-site` in VS Code
2. Right-click on `index.html`
3. Select "Open with Live Server"

## What Works Now

✅ **All documentation links point to `.md` files**
✅ **Markdown is rendered dynamically in a modal**
✅ **Mermaid diagrams render automatically**
✅ **Search functionality works**
✅ **Responsive design for mobile/tablet/desktop**

## Troubleshooting

### "Failed to Load Documentation" Error
- Make sure you're using a local server (not `file://`)
- Check that the `../docs/` directory exists relative to `docs-site/`
- Open browser console (F12) to see detailed errors

### Mermaid Diagrams Not Rendering
- Check browser console for errors
- Verify the code block uses ` ```mermaid ` syntax
- Some complex diagrams may take a moment to render

### Search Not Working
- JavaScript might be disabled - check browser settings
- Clear browser cache and reload

## Browser Console

Press **F12** to open developer tools and check for errors if something isn't working.

## Stopping the Server

Press **Ctrl+C** in the terminal where the server is running.
