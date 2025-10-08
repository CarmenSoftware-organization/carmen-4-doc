// Markdown Loader for Carmen.NET Documentation
// Intercepts .md file links and renders them as HTML

(function() {
    'use strict';

    // Initialize Mermaid
    if (typeof mermaid !== 'undefined') {
        mermaid.initialize({
            startOnLoad: false,
            theme: 'default',
            securityLevel: 'loose',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            logLevel: 'error'
        });
    }

    // Configure marked.js for better rendering
    if (typeof marked !== 'undefined') {
        // Custom renderer for mermaid code blocks
        const renderer = new marked.Renderer();

        // Override code block rendering
        renderer.code = function(code, language) {
            // Check if it's a mermaid diagram
            if (language === 'mermaid') {
                // Return raw div without escaping
                return `<div class="mermaid">${code}</div>`;
            }
            // Default code block rendering
            const escaped = code
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
            return `<pre><code class="language-${language || 'text'}">${escaped}</code></pre>`;
        };

        // Set all options together
        marked.setOptions({
            renderer: renderer,
            breaks: true,
            gfm: true,
            headerIds: true,
            mangle: false
        });
    }

    // Markdown viewer modal
    let markdownModal = null;
    let markdownContent = null;
    let markdownClose = null;

    function createMarkdownModal() {
        if (markdownModal) return;

        markdownModal = document.createElement('div');
        markdownModal.className = 'markdown-modal';
        markdownModal.innerHTML = `
            <div class="markdown-modal-content">
                <div class="markdown-header">
                    <h2 class="markdown-title">Loading...</h2>
                    <button class="markdown-close" id="markdownClose">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="markdown-body" id="markdownBody">
                    <div class="markdown-loading">
                        <i class="fas fa-spinner fa-spin"></i>
                        <p>Loading documentation...</p>
                    </div>
                </div>
            </div>
        `;

        // Add styles
        const style = document.createElement('style');
        style.textContent = `
            .markdown-modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.8);
                z-index: 10000;
                overflow: auto;
                padding: 20px;
            }

            .markdown-modal.active {
                display: flex;
                align-items: flex-start;
                justify-content: center;
            }

            .markdown-modal-content {
                background: white;
                border-radius: 12px;
                max-width: 1200px;
                width: 100%;
                margin: 40px auto;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                max-height: calc(100vh - 80px);
                display: flex;
                flex-direction: column;
            }

            .markdown-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 24px 32px;
                border-bottom: 1px solid #e5e7eb;
                background: #f9fafb;
                border-radius: 12px 12px 0 0;
            }

            .markdown-title {
                margin: 0;
                font-size: 24px;
                color: #1f2937;
            }

            .markdown-close {
                background: none;
                border: none;
                font-size: 24px;
                cursor: pointer;
                color: #6b7280;
                transition: color 0.2s;
                padding: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .markdown-close:hover {
                color: #1f2937;
            }

            .markdown-body {
                padding: 32px;
                overflow-y: auto;
                flex: 1;
            }

            .markdown-loading {
                text-align: center;
                padding: 60px 20px;
                color: #6b7280;
            }

            .markdown-loading i {
                font-size: 48px;
                margin-bottom: 16px;
                color: #3b82f6;
            }

            .markdown-body h1 {
                font-size: 2.5em;
                margin-top: 0;
                margin-bottom: 0.5em;
                color: #1f2937;
                border-bottom: 2px solid #e5e7eb;
                padding-bottom: 0.3em;
            }

            .markdown-body h2 {
                font-size: 2em;
                margin-top: 1.5em;
                margin-bottom: 0.5em;
                color: #1f2937;
                border-bottom: 1px solid #e5e7eb;
                padding-bottom: 0.3em;
            }

            .markdown-body h3 {
                font-size: 1.5em;
                margin-top: 1.2em;
                margin-bottom: 0.5em;
                color: #374151;
            }

            .markdown-body h4 {
                font-size: 1.25em;
                margin-top: 1em;
                margin-bottom: 0.5em;
                color: #4b5563;
            }

            .markdown-body p {
                line-height: 1.7;
                margin-bottom: 1em;
                color: #374151;
            }

            .markdown-body ul, .markdown-body ol {
                margin-bottom: 1em;
                padding-left: 2em;
            }

            .markdown-body li {
                margin-bottom: 0.5em;
                line-height: 1.7;
            }

            .markdown-body code {
                background: #f3f4f6;
                padding: 2px 6px;
                border-radius: 4px;
                font-family: 'Courier New', monospace;
                font-size: 0.9em;
                color: #e11d48;
            }

            .markdown-body pre {
                background: #1f2937;
                color: #f9fafb;
                padding: 16px;
                border-radius: 8px;
                overflow-x: auto;
                margin-bottom: 1em;
            }

            .markdown-body pre code {
                background: none;
                padding: 0;
                color: #f9fafb;
            }

            .markdown-body table {
                border-collapse: collapse;
                width: 100%;
                margin-bottom: 1em;
            }

            .markdown-body th, .markdown-body td {
                border: 1px solid #e5e7eb;
                padding: 12px;
                text-align: left;
            }

            .markdown-body th {
                background: #f9fafb;
                font-weight: 600;
            }

            .markdown-body blockquote {
                border-left: 4px solid #3b82f6;
                padding-left: 16px;
                margin-left: 0;
                color: #6b7280;
                font-style: italic;
            }

            .markdown-body a {
                color: #3b82f6;
                text-decoration: none;
            }

            .markdown-body a:hover {
                text-decoration: underline;
            }

            .markdown-body img {
                max-width: 100%;
                height: auto;
                border-radius: 8px;
                margin: 1em 0;
            }

            .markdown-body .mermaid {
                background: #f9fafb;
                padding: 20px;
                border-radius: 8px;
                margin: 1em 0;
                text-align: center;
                overflow-x: auto;
            }

            .markdown-body .mermaid svg {
                max-width: 100%;
                height: auto;
            }

            @media (max-width: 768px) {
                .markdown-modal-content {
                    margin: 20px;
                    max-height: calc(100vh - 40px);
                }

                .markdown-header {
                    padding: 16px 20px;
                }

                .markdown-body {
                    padding: 20px;
                }

                .markdown-title {
                    font-size: 20px;
                }
            }
        `;

        document.head.appendChild(style);
        document.body.appendChild(markdownModal);

        markdownContent = document.getElementById('markdownBody');
        markdownClose = document.getElementById('markdownClose');

        // Close button
        markdownClose.addEventListener('click', closeMarkdownModal);

        // Close on background click
        markdownModal.addEventListener('click', (e) => {
            if (e.target === markdownModal) {
                closeMarkdownModal();
            }
        });

        // Close on Escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && markdownModal.classList.contains('active')) {
                closeMarkdownModal();
            }
        });
    }

    function openMarkdownModal() {
        if (markdownModal) {
            markdownModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
    }

    function closeMarkdownModal() {
        if (markdownModal) {
            markdownModal.classList.remove('active');
            document.body.style.overflow = '';

            // Clean up mermaid diagrams to prevent re-rendering issues
            if (markdownContent) {
                const mermaidElements = markdownContent.querySelectorAll('.mermaid');
                mermaidElements.forEach(element => {
                    // Remove any SVG that mermaid added
                    const svg = element.querySelector('svg');
                    if (svg) {
                        svg.remove();
                    }
                });
            }
        }
    }

    // Load and render markdown file
    async function loadMarkdownFile(url, title) {
        createMarkdownModal();
        openMarkdownModal();

        // Set title
        const titleElement = markdownModal.querySelector('.markdown-title');
        titleElement.textContent = title || 'Documentation';

        // Show loading
        markdownContent.innerHTML = `
            <div class="markdown-loading">
                <i class="fas fa-spinner fa-spin"></i>
                <p>Loading documentation...</p>
            </div>
        `;

        try {
            const response = await fetch(url);

            if (!response.ok) {
                throw new Error(`Failed to load: ${response.status} ${response.statusText}`);
            }

            const markdown = await response.text();

            // Convert markdown to HTML
            if (typeof marked !== 'undefined') {
                const html = marked.parse(markdown);
                markdownContent.innerHTML = html;

                // Render Mermaid diagrams
                if (typeof mermaid !== 'undefined') {
                    const mermaidElements = markdownContent.querySelectorAll('.mermaid');
                    console.log(`Found ${mermaidElements.length} mermaid diagrams`);

                    if (mermaidElements.length > 0) {
                        // Process each mermaid element
                        mermaidElements.forEach((element, index) => {
                            const id = `mermaid-diagram-${Date.now()}-${index}`;
                            element.id = id;
                            console.log(`Processing mermaid diagram: ${id}`);
                        });

                        // Use setTimeout to ensure DOM is ready
                        setTimeout(async () => {
                            try {
                                console.log('Initializing mermaid...');
                                await mermaid.run({
                                    nodes: mermaidElements
                                });
                                console.log('Mermaid rendering complete!');
                            } catch (err) {
                                console.error('Mermaid rendering error:', err);
                                // Fallback: try old init method
                                try {
                                    mermaid.init(undefined, mermaidElements);
                                } catch (err2) {
                                    console.error('Mermaid fallback error:', err2);
                                }
                            }
                        }, 100);
                    }
                }
            } else {
                // Fallback if marked.js not loaded
                markdownContent.innerHTML = `<pre>${markdown}</pre>`;
            }

            // Scroll to top
            markdownContent.scrollTop = 0;

        } catch (error) {
            markdownContent.innerHTML = `
                <div style="text-align: center; padding: 60px 20px; color: #ef4444;">
                    <i class="fas fa-exclamation-triangle" style="font-size: 48px; margin-bottom: 16px;"></i>
                    <h3>Failed to Load Documentation</h3>
                    <p>${error.message}</p>
                    <p style="color: #6b7280; font-size: 14px; margin-top: 16px;">
                        URL: ${url}
                    </p>
                </div>
            `;
        }
    }

    // Intercept clicks on .md links
    document.addEventListener('click', (e) => {
        const link = e.target.closest('a[href$=".md"]');

        if (link) {
            e.preventDefault();
            const url = link.getAttribute('href');
            const title = link.textContent.trim() || link.getAttribute('title') || 'Documentation';
            loadMarkdownFile(url, title);
        }
    });

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', createMarkdownModal);
    } else {
        createMarkdownModal();
    }

    console.log('Markdown loader initialized');
})();
