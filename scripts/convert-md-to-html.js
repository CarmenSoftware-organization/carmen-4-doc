#!/usr/bin/env node

/**
 * Convert all markdown files to HTML while preserving mermaid diagrams
 */

const fs = require('fs');
const path = require('path');
const { marked } = require('marked');

// Paths
const DOCS_DIR = path.join(__dirname, '..', 'docs');
const PUBLIC_DIR = path.join(__dirname, '..', 'public', 'docs');

// Configure marked with custom renderer for mermaid
const renderer = new marked.Renderer();

// Override code block rendering to preserve mermaid
renderer.code = function(code, language) {
    if (language === 'mermaid') {
        return `<div class="mermaid">${code}</div>`;
    }
    const escaped = code
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
    return `<pre><code class="language-${language || 'text'}">${escaped}</code></pre>`;
};

marked.setOptions({
    renderer: renderer,
    breaks: true,
    gfm: true,
    headerIds: true,
    mangle: false
});

// HTML template
function createHTMLTemplate(title, content) {
    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - Carmen.NET Documentation</title>
    <link rel="stylesheet" href="/public/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #212121;
            background: #f5f5f5;
            padding: 0;
            margin: 0;
        }
        .doc-container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .doc-header {
            border-bottom: 2px solid #1976D2;
            padding-bottom: 16px;
            margin-bottom: 32px;
        }
        .doc-header h1 {
            margin: 0;
            color: #1976D2;
        }
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #1976D2;
            text-decoration: none;
            margin-bottom: 16px;
            font-weight: 600;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        .doc-content h1 {
            font-size: 2.5em;
            margin-top: 0;
            margin-bottom: 0.5em;
            color: #1f2937;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 0.3em;
        }
        .doc-content h2 {
            font-size: 2em;
            margin-top: 1.5em;
            margin-bottom: 0.5em;
            color: #1f2937;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 0.3em;
        }
        .doc-content h3 {
            font-size: 1.5em;
            margin-top: 1.2em;
            margin-bottom: 0.5em;
            color: #374151;
        }
        .doc-content h4 {
            font-size: 1.25em;
            margin-top: 1em;
            margin-bottom: 0.5em;
            color: #4b5563;
        }
        .doc-content p {
            line-height: 1.7;
            margin-bottom: 1em;
            color: #374151;
        }
        .doc-content ul, .doc-content ol {
            margin-bottom: 1em;
            padding-left: 2em;
        }
        .doc-content li {
            margin-bottom: 0.5em;
            line-height: 1.7;
        }
        .doc-content code {
            background: #f3f4f6;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            color: #e11d48;
        }
        .doc-content pre {
            background: #1f2937;
            color: #f9fafb;
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
            margin-bottom: 1em;
        }
        .doc-content pre code {
            background: none;
            padding: 0;
            color: #f9fafb;
        }
        .doc-content table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 1em;
        }
        .doc-content th, .doc-content td {
            border: 1px solid #e5e7eb;
            padding: 12px;
            text-align: left;
        }
        .doc-content th {
            background: #f9fafb;
            font-weight: 600;
        }
        .doc-content blockquote {
            border-left: 4px solid #3b82f6;
            padding-left: 16px;
            margin-left: 0;
            color: #6b7280;
            font-style: italic;
        }
        .doc-content a {
            color: #3b82f6;
            text-decoration: none;
        }
        .doc-content a:hover {
            text-decoration: underline;
        }
        .doc-content img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 1em 0;
        }
        .mermaid {
            background: #f9fafb;
            padding: 20px;
            border-radius: 8px;
            margin: 1em 0;
            text-align: center;
            overflow-x: auto;
        }
        .mermaid svg {
            max-width: 100%;
            height: auto;
        }
        @media (max-width: 768px) {
            .doc-container {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="doc-container">
        <a href="/public/index.html" class="back-link">
            <i class="fas fa-arrow-left"></i>
            Back to Documentation
        </a>
        <div class="doc-header">
            <h1>${title}</h1>
        </div>
        <div class="doc-content">
            ${content}
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script>
        // Initialize Mermaid
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
        });

        // Render all mermaid diagrams
        document.addEventListener('DOMContentLoaded', function() {
            const mermaidElements = document.querySelectorAll('.mermaid');
            console.log('Found ' + mermaidElements.length + ' mermaid diagrams');

            mermaidElements.forEach((element, index) => {
                element.id = 'mermaid-' + index;
            });

            if (mermaidElements.length > 0) {
                mermaid.run();
            }
        });
    </script>
</body>
</html>`;
}

// Get all markdown files recursively
function getMarkdownFiles(dir, fileList = []) {
    const files = fs.readdirSync(dir);

    files.forEach(file => {
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);

        if (stat.isDirectory()) {
            getMarkdownFiles(filePath, fileList);
        } else if (path.extname(file) === '.md') {
            fileList.push(filePath);
        }
    });

    return fileList;
}

// Convert single markdown file to HTML
function convertMarkdownFile(mdPath) {
    try {
        // Read markdown content
        const markdown = fs.readFileSync(mdPath, 'utf-8');

        // Get relative path from docs dir
        const relativePath = path.relative(DOCS_DIR, mdPath);
        const outputPath = path.join(PUBLIC_DIR, relativePath.replace('.md', '.html'));

        // Extract title from first # heading or use filename
        const titleMatch = markdown.match(/^#\s+(.+)$/m);
        const title = titleMatch ? titleMatch[1] : path.basename(mdPath, '.md');

        // Convert markdown to HTML
        const htmlContent = marked.parse(markdown);

        // Wrap in template
        const fullHTML = createHTMLTemplate(title, htmlContent);

        // Create output directory if it doesn't exist
        const outputDir = path.dirname(outputPath);
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }

        // Write HTML file
        fs.writeFileSync(outputPath, fullHTML, 'utf-8');

        console.log(`✅ Converted: ${relativePath} → ${path.relative(PUBLIC_DIR, outputPath)}`);
        return true;
    } catch (error) {
        console.error(`❌ Error converting ${mdPath}:`, error.message);
        return false;
    }
}

// Main conversion function
function convertAllMarkdown() {
    console.log('🚀 Starting markdown to HTML conversion...\n');

    // Create public/docs directory if it doesn't exist
    if (!fs.existsSync(PUBLIC_DIR)) {
        fs.mkdirSync(PUBLIC_DIR, { recursive: true });
    }

    // Get all markdown files
    const markdownFiles = getMarkdownFiles(DOCS_DIR);
    console.log(`📄 Found ${markdownFiles.length} markdown files\n`);

    // Convert each file
    let successCount = 0;
    let failCount = 0;

    markdownFiles.forEach(mdPath => {
        if (convertMarkdownFile(mdPath)) {
            successCount++;
        } else {
            failCount++;
        }
    });

    console.log('\n✨ Conversion complete!');
    console.log(`✅ Success: ${successCount} files`);
    if (failCount > 0) {
        console.log(`❌ Failed: ${failCount} files`);
    }
}

// Run conversion
convertAllMarkdown();
