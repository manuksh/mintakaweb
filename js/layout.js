(() => {
  const path = window.location.pathname.replace(/\\/g, '/');
  const isArticleDetail = /\/articles\/[^/]+\/[^/]+\.html$/i.test(path);
  const prefix = isArticleDetail ? '../../' : '';
  const file = path.split('/').pop() || 'index.html';

  const activePage = isArticleDetail
    ? 'articles.html'
    : file === 'sdr-lib.html'
      ? 'projects.html'
      : file;

  const items = [
    ['index.html', 'Home'],
    ['services.html', 'Services'],
    ['projects.html', 'Projects'],
    ['articles.html', 'Articles'],
    ['about.html', 'About'],
    ['contact.html', 'Contact'],
  ];

  const nav = document.querySelector('nav.navbar');
  if (nav) {
    nav.setAttribute('aria-label', 'Main navigation');
    nav.className = 'navbar navbar-expand-lg fixed-top';
    nav.innerHTML = `
      <div class="container">
        <a class="navbar-brand brand-lockup" href="${prefix}index.html" aria-label="Mintaka home">
          <img class="brand-logo" src="${prefix}assets/images/mintaka-mark-white.png" alt="" />
          <span class="brand-copy">
            <span class="brand-name">Mintaka</span>
            <span class="brand-line">FPGA | Design | Verification</span>
          </span>
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse" data-bs-target="#mainNav"
                aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mainNav">
          <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1">
            ${items.map(([href, label]) => `
              <li class="nav-item">
                <a class="nav-link${activePage === href ? ' active' : ''}" href="${prefix}${href}">${label}</a>
              </li>
            `).join('')}
          </ul>
        </div>
      </div>
    `;
  }

  const footer = document.querySelector('footer.site-footer');
  if (footer) {
    footer.innerHTML = `
      <div class="container">
        <p class="footer-main-link mb-2">
          Powered by
          <a href="https://www.mintaka-ai.com" target="_blank" rel="noopener">Mintaka-AI</a>
        </p>
        <p class="mb-1">&copy; ${new Date().getFullYear()} Mintaka LLC. All rights reserved.</p>
        <p class="mb-0">
          <a href="https://www.linkedin.com/company/mintaka-ai" target="_blank" rel="noopener" aria-label="LinkedIn">
            <i class="bi bi-linkedin me-1"></i>LinkedIn
          </a>
        </p>
      </div>
    `;
  }
})();
