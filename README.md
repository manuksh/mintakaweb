# Mintaka AI — Corporate Website

Official website for **Mintaka AI** — an FPGA & ASIC design and verification company that deploys AI agents to help engineering teams verify faster, automate routine processes, and compress development cycles.

🌐 **Live site:** [www.mintaka-ai.com](https://www.mintaka-ai.com)

---

## Overview

This is a static multi-page website built with HTML5, CSS3, JavaScript, and Bootstrap 5. No frameworks, no build tools, no dependencies beyond CDN links — open any `.html` file in a browser and it works.

---

## Pages

| Page | File | Description |
|------|------|-------------|
| Home | `index.html` | Hero, Why Mintaka, How It Works |
| Services | `services.html` | RTL Design, Verification, FPGA Prototyping, Synthesis |
| Projects | `projects.html` | Portfolio of FPGA/ASIC engagements |
| Contact | `contact.html` | Contact form + company info |

---

## Tech Stack

- **HTML5** — semantic markup
- **Bootstrap 5.3** — grid, components, responsive layout (CDN)
- **Bootstrap Icons 1.11** — icon set (CDN)
- **Google Fonts** — Orbitron (headings) + Inter (body) (CDN)
- **Vanilla JavaScript** — form validation, scroll-reveal, navbar effects
- **SVG** — custom FPGA/waveform banner graphic

No npm. No build step. No bundler.

---

## Project Structure

```
mintakaam/
├── index.html          # Home page
├── services.html       # Services page
├── projects.html       # Projects / Portfolio page
├── contact.html        # Contact page
├── css/
│   └── style.css       # Custom theme (Bootstrap overrides, dark tech style)
├── js/
│   └── main.js         # Scroll-reveal, form validation, nav highlight
└── assets/
    └── images/
        ├── logo.png    # Mintaka AI logo
        └── banner.svg  # FPGA/waveform hero banner graphic
```

---

## Design

- **Style:** Dark tech / futuristic
- **Colors:** Near-black background `#0a0e1a`, electric-blue accent `#00b4ff`, teal highlight `#00ffcc`
- **Fonts:** Orbitron (geometric, techy headings) + Inter (clean body text)
- **Effects:** Circuit-board grid background, scroll-reveal animations, glow hover effects on cards
- **Responsive:** Mobile-first via Bootstrap 5 grid

---

## Running Locally

No setup required. Clone and open:

```bash
git clone https://github.com/mintaka-ai/mintakaam.git
cd mintakaam
open index.html        # macOS
start index.html       # Windows
xdg-open index.html   # Linux
```

Or serve with any static server:

```bash
npx serve .
# or
python -m http.server 8000
```

---

## Deployment

This is a fully static site — deploy anywhere:

- **GitHub Pages** — push to `main`, enable Pages in repo settings
- **Netlify / Vercel** — drag and drop the folder or connect the repo
- **Any web host** — upload files via FTP/SFTP

No server-side code. No environment variables.

---

## Contact

📧 [info@mintaka-ai.com](mailto:info@mintaka-ai.com)  
🔗 [linkedin.com/company/mintaka-ai](https://www.linkedin.com/company/mintaka-ai)  
🌐 [www.mintaka-ai.com](https://www.mintaka-ai.com)

---

© 2026 Mintaka AI. All rights reserved.
