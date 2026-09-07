(() => {
  const path = window.location.pathname.replace(/\\/g, '/');
  const isArticleDetail = /\/articles\/[^/]+\/[^/]+\.html$/i.test(path);
  const prefix = isArticleDetail ? '../../' : '';
  const file = path.split('/').pop() || 'index.html';

  const activePage = isArticleDetail ? 'articles.html' : file;

  const items = [
    ['index.html', 'Home'],
    ['services.html', 'Services'],
    ['Projects', [
      ['orion.html', 'Orion'],
      ['sdr-lib.html', 'SDR-LIB'],
    ]],
    ['articles.html', 'Articles'],
    ['about.html', 'About'],
    ['contact.html', 'Contact'],
  ];

  const renderNavItem = ([href, label]) => `
            <li class="nav-item">
              <a class="nav-link${activePage === href ? ' active' : ''}" href="${prefix}${href}">${label}</a>
            </li>
          `;

  const renderNavDropdown = ([label, children]) => `
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle${children.some(([href]) => activePage === href) ? ' active' : ''}"
                 href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                ${label}<i class="bi bi-chevron-down ms-1" aria-hidden="true"></i>
              </a>
              <ul class="dropdown-menu">
                ${children.map(([href, childLabel]) => `
                  <li><a class="dropdown-item${activePage === href ? ' active' : ''}" href="${prefix}${href}">${childLabel}</a></li>
                `).join('')}
              </ul>
            </li>
          `;

  const navItemsHtml = items
    .map((item) => (Array.isArray(item[1]) ? renderNavDropdown(item) : renderNavItem(item)))
    .join('');

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
            <span class="brand-line">SDR | SatCom | Design &amp; Verification</span>
          </span>
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse" data-bs-target="#mainNav"
                aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mainNav">
          <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1">
            ${navItemsHtml}
          </ul>
        </div>
      </div>
    `;
  }

  const footer = document.querySelector('footer.site-footer');
  if (footer) {
    footer.innerHTML = `
      <div class="container">
        <div class="footer-grid">
          <div class="footer-brand">
            <a class="brand-lockup" href="${prefix}index.html" aria-label="Mintaka LLC home">
              <img class="brand-logo" src="${prefix}assets/images/mintaka-mark-white.png" alt="" />
              <span class="brand-copy">
                <span class="brand-name">Mintaka</span>
                <span class="brand-line">SDR | SatCom | Design &amp; Verification</span>
              </span>
            </a>
            <p class="footer-tagline">
              Expertise in Satellite Communications (SatCom), Software Defined Radio (SDR),
              FPGA, and SoC development.
            </p>
          </div>

          <div>
            <h6 class="footer-heading">Services</h6>
            <ul class="footer-links">
              <li><a href="${prefix}services.html">FPGA Design</a></li>
              <li><a href="${prefix}services.html">SDR Design</a></li>
              <li><a href="${prefix}services.html">Verification</a></li>
              <li><a href="${prefix}services.html">Board Bring-Up</a></li>
            </ul>
          </div>

          <div>
            <h6 class="footer-heading">Company</h6>
            <ul class="footer-links">
              <li><a href="${prefix}about.html">About</a></li>
              <li><a href="${prefix}orion.html">Orion</a></li>
              <li><a href="${prefix}articles.html">Articles</a></li>
              <li><a href="${prefix}contact.html">Contact</a></li>
            </ul>
          </div>

          <div>
            <h6 class="footer-heading">Connect</h6>
            <ul class="footer-links">
              <li><a href="${prefix}contact.html">Contact form</a></li>
              <li><a href="https://www.linkedin.com/company/mintaka-ai" target="_blank" rel="noopener">LinkedIn</a></li>
              <li><a href="https://www.mintaka-ai.com" target="_blank" rel="noopener">www.mintaka-ai.com</a></li>
            </ul>
          </div>
        </div>

        <div class="footer-bottom">
          <p>&copy; ${new Date().getFullYear()} Mintaka LLC. All rights reserved.</p>
          <p>Powered by <a href="https://www.mintaka-ai.com" target="_blank" rel="noopener">Mintaka-AI</a></p>
        </div>
      </div>
    `;
  }
})();
