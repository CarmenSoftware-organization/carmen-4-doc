// ===== Documentation Site JavaScript =====

// Search functionality
const searchData = [
    // Executive
    { title: "Executive Summary", description: "System overview for C-level executives", url: "docs/executive/executive-summary.html", category: "Executive" },
    { title: "ROI Analysis", description: "Financial business case with 122% ROI", url: "docs/executive/roi-analysis.html", category: "Executive" },
    { title: "Modernization Recommendations", description: "3-phase modernization roadmap", url: "docs/executive/modernization-recommendations.html", category: "Executive" },

    // Architecture
    { title: "System Architecture", description: "Complete system architecture documentation", url: "docs/architecture/system-architecture.html", category: "Architecture" },
    { title: "Architecture Decision Records", description: "15 key architectural decisions", url: "docs/architecture/architecture-decision-records.html", category: "Architecture" },
    { title: "Technology Stack", description: "Complete technology stack deep-dive", url: "docs/architecture/technology-stack.html", category: "Architecture" },
    { title: "Security Architecture", description: "Security model and authentication", url: "docs/architecture/security-architecture.html", category: "Architecture" },
    { title: "Integration Architecture", description: "Integration patterns and external systems", url: "docs/architecture/integration-architecture.html", category: "Architecture" },

    // Requirements
    { title: "Functional Requirements", description: "1,500+ business rules across 11 modules", url: "docs/requirements/functional-requirements.html", category: "Requirements" },
    { title: "Requirements Validation", description: "Source code validation of AP/AR requirements", url: "docs/requirements/requirements-validation-report.html", category: "Requirements" },
    { title: "Asset & Income Requirements", description: "Asset Management and Income Module requirements (85 API endpoints)", url: "docs/requirements/asset-income-requirements.html", category: "Requirements" },
    { title: "Permission Matrix", description: "114 permissions and 15 roles", url: "docs/requirements/permission-matrix.html", category: "Requirements" },
    { title: "Data Dictionary", description: "80+ entity definitions", url: "docs/requirements/data-dictionary.html", category: "Requirements" },

    // Development
    { title: "Developer Onboarding Guide", description: "Get productive in < 2 days", url: "docs/development/developer-onboarding-guide.html", category: "Development" },
    { title: "Code Structure Guide", description: "Solution structure and naming conventions", url: "docs/development/code-structure-guide.html", category: "Development" },
    { title: "Design Patterns Guide", description: "10+ architectural patterns", url: "docs/development/design-patterns-guide.html", category: "Development" },
    { title: "Database Schema Guide", description: "80+ tables with ERD diagrams", url: "docs/development/database-schema-guide.html", category: "Development" },
    { title: "Testing Guide", description: "Unit, integration, and E2E testing", url: "docs/development/testing-guide.html", category: "Development" },

    // API
    { title: "API Reference", description: "351 API endpoints documentation", url: "docs/api/api-reference.html", category: "API" },
    { title: "Authentication Guide", description: "JWT authentication and permissions", url: "docs/api/authentication-guide.html", category: "API" },
    { title: "Integration Guide", description: "API integration scenarios", url: "docs/api/integration-guide.html", category: "API" },
    { title: "Error Handling Guide", description: "Error codes and troubleshooting", url: "docs/api/error-handling-guide.html", category: "API" },

    // Workflows
    { title: "Business Process Flows", description: "P2P, PMS-to-Cash, R2R processes", url: "docs/workflows/business-process-flows.html", category: "Workflows" },
    { title: "Process Flow Validation", description: "Source code validation of all business processes", url: "docs/workflows/process-flow-validation.html", category: "Workflows" },
    { title: "AP Invoice Workflow", description: "AP invoice lifecycle", url: "docs/workflows/ap-invoice-workflow.html", category: "Workflows" },
    { title: "AP Payment Workflow", description: "Payment processing workflow", url: "docs/workflows/ap-payment-workflow.html", category: "Workflows" },
    { title: "AR Invoice Workflow", description: "AR billing workflow", url: "docs/workflows/ar-invoice-workflow.html", category: "Workflows" },
    { title: "AR Receipt Workflow", description: "Receipt application workflow", url: "docs/workflows/ar-receipt-workflow.html", category: "Workflows" },
    { title: "GL Period Close Workflow", description: "Month-end close process", url: "docs/workflows/gl-period-close-workflow.html", category: "Workflows" },
    { title: "Asset Disposal Workflow", description: "Asset disposal lifecycle", url: "docs/workflows/asset-disposal-workflow.html", category: "Workflows" },
    { title: "Approval Workflows", description: "Approval hierarchies and thresholds", url: "docs/workflows/approval-workflows.html", category: "Workflows" },
    { title: "Tax Calculation Rules", description: "VAT and WHT calculations", url: "docs/workflows/tax-calculation-rules.html", category: "Workflows" },

    // UI/UX
    { title: "UI Component Inventory", description: "40+ React/TypeScript components", url: "docs/ui-ux/ui-component-inventory.html", category: "UI/UX" },
    { title: "Screen Flow Diagrams", description: "15+ user journey flows", url: "docs/ui-ux/screen-flow-diagrams.html", category: "UI/UX" },

    // Database
    { title: "Master ERD", description: "Complete database overview", url: "docs/database/erd-master-overview.html", category: "Database" },
    { title: "AP Module ERD", description: "Accounts Payable ERD", url: "docs/database/erd-ap-module.html", category: "Database" },
    { title: "AR Module ERD", description: "Accounts Receivable ERD", url: "docs/database/erd-ar-module.html", category: "Database" },
    { title: "GL Module ERD", description: "General Ledger ERD", url: "docs/database/erd-gl-module.html", category: "Database" },
    { title: "Asset Module ERD", description: "Asset Management ERD", url: "docs/database/erd-asset-module.html", category: "Database" },
    { title: "Income Module ERD", description: "Income Module ERD", url: "docs/database/erd-income-module.html", category: "Database" },

    // Validation
    { title: "Validation Report", description: "Phase 6 validation results (100% pass)", url: "docs/validation-report.html", category: "Validation" },
    { title: "Traceability Matrix", description: "100% code-to-doc coverage", url: "docs/traceability-matrix.html", category: "Validation" },
    { title: "Diagram Quality Report", description: "65+ diagrams validated", url: "docs/diagram-quality-report.html", category: "Validation" },
];

// DOM Elements
const searchToggle = document.getElementById('searchToggle');
const searchModal = document.getElementById('searchModal');
const searchClose = document.getElementById('searchClose');
const searchInput = document.getElementById('searchInput');
const searchResults = document.getElementById('searchResults');
const mobileMenuToggle = document.getElementById('mobileMenuToggle');
const sidebar = document.getElementById('sidebar');

// Search Modal
searchToggle.addEventListener('click', () => {
    searchModal.classList.add('active');
    searchInput.focus();
});

searchClose.addEventListener('click', () => {
    searchModal.classList.remove('active');
    searchInput.value = '';
    searchResults.innerHTML = '';
});

// Close modal on background click
searchModal.addEventListener('click', (e) => {
    if (e.target === searchModal) {
        searchModal.classList.remove('active');
        searchInput.value = '';
        searchResults.innerHTML = '';
    }
});

// Close modal on Escape key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && searchModal.classList.contains('active')) {
        searchModal.classList.remove('active');
        searchInput.value = '';
        searchResults.innerHTML = '';
    }
});

// Search functionality
searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();

    if (query.length < 2) {
        searchResults.innerHTML = '<p style="text-align: center; color: var(--text-secondary); padding: 20px;">Type at least 2 characters to search...</p>';
        return;
    }

    const results = searchData.filter(item => {
        return item.title.toLowerCase().includes(query) ||
               item.description.toLowerCase().includes(query) ||
               item.category.toLowerCase().includes(query);
    });

    if (results.length === 0) {
        searchResults.innerHTML = '<p style="text-align: center; color: var(--text-secondary); padding: 20px;">No results found.</p>';
        return;
    }

    searchResults.innerHTML = results.map(item => `
        <a href="${item.url}" class="search-result-item">
            <div class="search-result-title">${highlightMatch(item.title, query)}</div>
            <div class="search-result-description">${item.category} • ${highlightMatch(item.description, query)}</div>
        </a>
    `).join('');
});

// Highlight search matches
function highlightMatch(text, query) {
    const regex = new RegExp(`(${query})`, 'gi');
    return text.replace(regex, '<strong style="color: var(--primary-color);">$1</strong>');
}

// Mobile menu toggle
mobileMenuToggle.addEventListener('click', () => {
    sidebar.classList.toggle('mobile-active');
});

// Close mobile menu on link click
document.querySelectorAll('.sidebar-menu a').forEach(link => {
    link.addEventListener('click', () => {
        sidebar.classList.remove('mobile-active');
    });
});

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Navigation highlighting
const navLinks = document.querySelectorAll('.nav-link');
const sections = document.querySelectorAll('.content-section');

navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('href').substring(1);

        // Remove active class from all links and sections
        navLinks.forEach(l => l.classList.remove('active'));
        sections.forEach(s => s.classList.remove('active'));

        // Add active class to clicked link
        link.classList.add('active');

        // Show target section
        const targetSection = document.getElementById(targetId);
        if (targetSection) {
            targetSection.classList.add('active');
        }

        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });
});

// Active sidebar link highlighting
function updateActiveSidebarLink() {
    const currentPath = window.location.pathname;
    document.querySelectorAll('.sidebar-menu a').forEach(link => {
        if (link.getAttribute('href') === currentPath ||
            currentPath.includes(link.getAttribute('href'))) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    updateActiveSidebarLink();

    // Add keyboard shortcut for search (Ctrl/Cmd + K)
    document.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            searchModal.classList.add('active');
            searchInput.focus();
        }
    });
});

// Copy code button for code blocks (if any)
document.querySelectorAll('pre code').forEach((block) => {
    const button = document.createElement('button');
    button.className = 'copy-code-btn';
    button.textContent = 'Copy';
    button.addEventListener('click', () => {
        navigator.clipboard.writeText(block.textContent);
        button.textContent = 'Copied!';
        setTimeout(() => {
            button.textContent = 'Copy';
        }, 2000);
    });
    block.parentElement.style.position = 'relative';
    block.parentElement.appendChild(button);
});

// Add dark mode toggle (future enhancement)
function toggleDarkMode() {
    document.body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
}

// Check for saved dark mode preference
if (localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
}

// Analytics (placeholder for future integration)
function trackPageView(page) {
    console.log('Page view:', page);
    // Add Google Analytics or other tracking here
}

// Track initial page load
trackPageView(window.location.pathname);

// Back to top button
const backToTopButton = document.createElement('button');
backToTopButton.className = 'back-to-top';
backToTopButton.innerHTML = '<i class="fas fa-arrow-up"></i>';
backToTopButton.style.cssText = `
    position: fixed;
    bottom: 32px;
    right: 32px;
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: var(--primary-color);
    color: white;
    border: none;
    cursor: pointer;
    display: none;
    align-items: center;
    justify-content: center;
    box-shadow: var(--shadow-lg);
    transition: var(--transition);
    z-index: 999;
`;

document.body.appendChild(backToTopButton);

// Show/hide back to top button
window.addEventListener('scroll', () => {
    if (window.pageYOffset > 300) {
        backToTopButton.style.display = 'flex';
    } else {
        backToTopButton.style.display = 'none';
    }
});

backToTopButton.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
});

// Print functionality
function printPage() {
    window.print();
}

// Export search results
function exportSearchResults(results) {
    const csv = results.map(r => `"${r.title}","${r.category}","${r.url}"`).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'search-results.csv';
    a.click();
}

console.log('Carmen.NET Documentation Site loaded successfully!');
console.log('Press Ctrl/Cmd + K to search');
