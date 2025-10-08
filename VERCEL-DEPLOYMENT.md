# Vercel Deployment Guide - Carmen.NET Documentation

Complete guide for deploying Carmen.NET documentation to Vercel.

---

## Prerequisites

1. **GitHub Account**: Your repository should be on GitHub
2. **Vercel Account**: Sign up at https://vercel.com (free tier available)
3. **Repository Access**: Ensure your repo is accessible

---

## Quick Deployment Steps

### Option 1: Deploy via Vercel Dashboard (Recommended)

**Step 1: Import Project**
1. Go to https://vercel.com/new
2. Click "Import Git Repository"
3. Select your GitHub repository: `carmen-4-doc`
4. Click "Import"

**Step 2: Configure Project**
```
Framework Preset: Other
Root Directory: ./
Build Command: npm run build
Output Directory: public
Install Command: npm install
```

**Step 3: Environment Variables** (Optional)
- No environment variables required for this static site

**Step 4: Deploy**
1. Click "Deploy"
2. Wait 1-2 minutes for build completion
3. Your site will be live at: `https://carmen-4-doc.vercel.app`

---

### Option 2: Deploy via Vercel CLI

**Step 1: Install Vercel CLI**
```bash
npm install -g vercel
```

**Step 2: Login to Vercel**
```bash
vercel login
```

**Step 3: Deploy from Project Root**
```bash
# First deployment
vercel

# Follow prompts:
# - Set up and deploy? Yes
# - Which scope? [Your account]
# - Link to existing project? No
# - Project name? carmen-4-doc
# - Directory? ./
# - Override settings? No

# Production deployment
vercel --prod
```

---

## Vercel Configuration Overview

### `vercel.json`
```json
{
  "version": 2,
  "name": "carmen-net-docs",
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "public"
      }
    }
  ]
}
```

**Key Settings**:
- **distDir**: `public` - Serves pre-built HTML from public directory
- **Build Command**: `npm run build` - Converts markdown to HTML
- **Static Build**: Uses `@vercel/static-build` for optimal performance

---

## Build Process

**What Happens During Deployment**:

1. **Install Dependencies**
   ```bash
   npm install
   # Installs marked@^11.0.0
   ```

2. **Run Build Command**
   ```bash
   npm run build
   # Executes: node scripts/convert-md-to-html.js
   # Converts 71 markdown files to HTML
   # Processes Mermaid diagrams
   # Outputs to public/docs/
   ```

3. **Deploy Static Files**
   - Serves everything from `public/` directory
   - Includes: HTML, CSS, JS, assets
   - CDN distribution for global access

---

## Project Structure for Deployment

```
carmen-4-doc/
├── public/                    # ✅ DEPLOYED
│   ├── index.html            # Main landing page
│   ├── css/                  # Stylesheets
│   ├── js/                   # JavaScript
│   ├── docs/                 # Generated HTML docs
│   └── assets/               # Images, icons
├── docs/                      # ❌ NOT DEPLOYED (source only)
│   └── *.md                  # Markdown source files
├── scripts/                   # ❌ NOT DEPLOYED
│   └── convert-md-to-html.js # Build script
├── package.json              # ✅ Used for build
├── vercel.json               # ✅ Vercel config
└── .vercelignore             # ✅ Exclude rules
```

---

## Custom Domain Setup (Optional)

**Step 1: Add Domain in Vercel**
1. Go to Project Settings → Domains
2. Add your custom domain (e.g., `docs.carmen-erp.com`)
3. Follow DNS configuration instructions

**Step 2: Update DNS Records**
```
Type: CNAME
Name: docs (or @)
Value: cname.vercel-dns.com
```

**Step 3: Wait for DNS Propagation**
- Usually 5-30 minutes
- Vercel auto-provisions SSL certificate

---

## Deployment URLs

**Preview Deployments**:
- Every git push creates a preview URL
- Format: `https://carmen-4-doc-<hash>-<username>.vercel.app`
- Perfect for testing before production

**Production Deployment**:
- Main branch auto-deploys to production
- URL: `https://carmen-4-doc.vercel.app`
- Or your custom domain

---

## Continuous Deployment

**Automatic Deployments**:
- **Push to main**: Deploys to production
- **Pull requests**: Creates preview deployments
- **All branches**: Preview URLs for testing

**Manual Deployments**:
```bash
# Deploy current directory
vercel

# Deploy to production
vercel --prod

# Deploy specific branch
git checkout feature-branch
vercel
```

---

## Updating Documentation

### Local Development Workflow

**Step 1: Edit Markdown Files**
```bash
# Edit files in docs/ directory
vim docs/system-overview.md
```

**Step 2: Convert to HTML Locally**
```bash
npm run convert
```

**Step 3: Test Locally**
```bash
npm run serve
# Opens http://localhost:8000
```

**Step 4: Commit & Push**
```bash
git add .
git commit -m "docs: update system overview"
git push origin main
```

**Step 5: Auto-Deploy**
- Vercel detects push
- Runs `npm run build`
- Deploys to production (1-2 minutes)

---

## Troubleshooting

### Build Fails

**Issue**: Build command fails
```
Error: Cannot find module 'marked'
```

**Solution**: Ensure dependencies are in `package.json`
```json
{
  "dependencies": {
    "marked": "^11.0.0"
  }
}
```

---

### Mermaid Diagrams Not Rendering

**Issue**: Diagrams show as text instead of graphics

**Solution**: Check HTML includes Mermaid.js CDN
```html
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({ startOnLoad: true });
</script>
```

---

### 404 Errors on Routes

**Issue**: `/docs/system-overview.html` returns 404

**Solution**: Check `vercel.json` routes configuration
```json
{
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/public/$1"
    }
  ]
}
```

---

### Build Takes Too Long

**Issue**: Build exceeds 10 minutes (Vercel timeout)

**Optimization**:
1. Reduce number of files processed
2. Cache node_modules
3. Use incremental builds

```json
{
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "public",
        "cache": true
      }
    }
  ]
}
```

---

## Performance Optimization

### Vercel Edge Network

**Automatic Features**:
- ✅ Global CDN distribution
- ✅ Gzip/Brotli compression
- ✅ HTTP/2 & HTTP/3
- ✅ SSL certificate auto-renewal
- ✅ DDoS protection

### Custom Headers (Already Configured)

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-XSS-Protection", "value": "1; mode=block" }
      ]
    },
    {
      "source": "/docs/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=3600, must-revalidate" }
      ]
    }
  ]
}
```

**Benefits**:
- Security headers for XSS protection
- 1-hour cache for documentation pages
- Instant page loads on repeat visits

---

## Monitoring & Analytics

### Vercel Analytics (Optional - Paid)

**Enable in Dashboard**:
1. Go to Project Settings
2. Click "Analytics"
3. Enable Web Analytics

**Features**:
- Page view tracking
- Performance metrics
- User location data
- Real-time traffic

### Custom Analytics

**Add Google Analytics** (Optional):
Edit `public/index.html`:
```html
<head>
  <!-- Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'GA_MEASUREMENT_ID');
  </script>
</head>
```

---

## Cost Estimates

### Vercel Pricing

**Hobby Plan (Free)**:
- ✅ Unlimited deployments
- ✅ 100 GB bandwidth/month
- ✅ Automatic HTTPS
- ✅ Custom domains
- ✅ Preview deployments
- **Perfect for documentation sites**

**Pro Plan ($20/month)**:
- 1 TB bandwidth/month
- Team collaboration
- Password protection
- Analytics
- Priority support

**Recommendation**: Hobby plan is sufficient for this documentation site

---

## Security Considerations

### Already Implemented

**Security Headers**:
- ✅ X-Content-Type-Options: nosniff
- ✅ X-Frame-Options: DENY
- ✅ X-XSS-Protection: enabled

**SSL/TLS**:
- ✅ Automatic HTTPS
- ✅ SSL certificate auto-renewal
- ✅ TLS 1.3 support

**DDoS Protection**:
- ✅ Vercel Edge Network protection
- ✅ Rate limiting
- ✅ Geographic distribution

### Additional Security (Optional)

**Password Protection** (Pro plan only):
```json
{
  "version": 2,
  "build": {
    "env": {
      "PASSWORD_PROTECT": "true"
    }
  }
}
```

---

## Backup & Version Control

**Git-Based Versioning**:
- Every deployment linked to git commit
- Easy rollback to previous versions
- Full audit trail

**Rollback to Previous Version**:
1. Go to Deployments tab in Vercel
2. Find successful deployment
3. Click "..." → "Promote to Production"

---

## Support & Resources

**Vercel Documentation**:
- https://vercel.com/docs
- https://vercel.com/docs/deployments/overview

**Community Support**:
- Vercel Discord: https://vercel.com/discord
- GitHub Discussions: https://github.com/vercel/vercel/discussions

**Status Page**:
- https://www.vercel-status.com/

---

## Quick Reference Commands

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy (preview)
vercel

# Deploy (production)
vercel --prod

# Check deployment status
vercel ls

# View logs
vercel logs [deployment-url]

# Link local project to Vercel project
vercel link

# Remove deployment
vercel rm [deployment-url]
```

---

## Post-Deployment Checklist

After first deployment, verify:

- [ ] Site loads at Vercel URL
- [ ] Index page displays correctly
- [ ] Navigation works
- [ ] Documentation pages accessible
- [ ] Mermaid diagrams render
- [ ] Search functionality works
- [ ] Mobile responsive
- [ ] CSS/JS loading correctly
- [ ] No console errors
- [ ] All links working
- [ ] Custom domain configured (if applicable)
- [ ] Analytics tracking (if enabled)

---

## Next Steps

**After Successful Deployment**:

1. **Share the URL** with your team
2. **Set up custom domain** (optional)
3. **Enable analytics** (optional)
4. **Configure branch protection** on GitHub
5. **Document update workflow** for team members
6. **Monitor performance** and traffic

**Ongoing Maintenance**:
- Update documentation regularly
- Monitor build logs for errors
- Review analytics monthly
- Update dependencies quarterly

---

## Estimated Timeline

**First Deployment**: 15-30 minutes
1. Vercel account setup: 5 minutes
2. Repository connection: 2 minutes
3. Project configuration: 3 minutes
4. Initial build & deploy: 5 minutes
5. Testing & verification: 10 minutes

**Subsequent Deployments**: 2-3 minutes (automatic)

---

**Status**: ✅ Ready for deployment
**Last Updated**: 2025-10-08
**Vercel Configuration**: Complete
**Build Script**: Tested and working
**Total Documentation Pages**: 71 HTML files
