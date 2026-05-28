# Website Requirements — Mintaka LLC
## FPGA/ASIC Design & Verification Company Website

---

## 1. Project Overview

**Company name:** Mintaka LLC  
**Tagline:** "Expert FPGA & ASIC Design Services"  
**Language:** English  
**Technology stack:** HTML5, CSS3, JavaScript (ES6+), **Bootstrap 5**  
**Goal:** A professional multi-page company website for an FPGA/ASIC design and verification engineering team.

---

## 2. Site Structure — Pages

The website is **multi-page** (separate HTML files per section):

| Page | File | Description |
|------|------|-------------|
| Home / Hero | `index.html` | Landing page with hero banner, company name, tagline, CTA |
| Services | `services.html` | Detailed list of offered engineering services |
| Projects | `projects.html` | Portfolio of past FPGA/ASIC projects |
| Contact | `contact.html` | Contact form for visitor inquiries |

---

## 3. Visual Design

**Style:** Dark tech / futuristic  
- Dark background (near-black, e.g. `#0a0e1a`) — override Bootstrap's default `body` background  
- Neon / electric-blue accent color (e.g. `#00b4ff`) — override Bootstrap's `primary` color via CSS variables  
- Google Fonts: **Orbitron** for headings, **Inter** for body text  
- Subtle circuit-board or grid CSS background pattern  
- Glowing hover effects on Bootstrap cards and buttons (custom CSS `box-shadow`)  
- Smooth CSS transitions on all interactive elements  

**Responsive:** Fully responsive via Bootstrap 5's grid system (xs → xl breakpoints).

---

## 4. Navigation

**Bootstrap component:** `navbar navbar-expand-lg navbar-dark`

- Fixed to top (`fixed-top`) across all pages  
- Left: Mintaka logo (img, height ~40px, white/inverted)  
- Right: nav links — Home | Services | Projects | Contact  
- Active page uses Bootstrap `.active` class on the nav link  
- Mobile: Bootstrap hamburger toggler (`navbar-toggler`) collapses into offcanvas or dropdown menu  
- Background: semi-transparent dark with `backdrop-filter: blur` for glassmorphism effect  

---

## 5. Pages — Detailed Requirements

### 5.1 Home / Hero (`index.html`)

**Bootstrap components used:** `container`, `row`, `col`, `btn`, `display-*` headings

- Full-viewport hero section (`min-height: 100vh`) with dark background  
- Company logo centered, height ~120px (white/inverted version)  
- Company name: **Mintaka LLC** — Bootstrap `display-1` heading  
- Tagline: **"Expert FPGA & ASIC Design Services"** — Bootstrap `lead` class  
- Two CTA buttons using Bootstrap `btn btn-primary` and `btn btn-outline-light`:  
  - "Get in Touch" → `contact.html`  
  - "Our Services" → `services.html`  
- Brief intro paragraph (2–3 sentences) about the company  
- Optional: animated CSS grid/particle background behind the hero content  

### 5.2 Services (`services.html`)

**Bootstrap components used:** `card`, `card-body`, `row row-cols-1 row-cols-md-2 row-cols-lg-4`, `badge`, `container`

Four service cards in a responsive Bootstrap grid:

1. **RTL Design (VHDL / Verilog / SystemVerilog)**  
   Design of digital logic at register-transfer level. Icon: `bi-cpu` (Bootstrap Icons)

2. **Functional Verification (UVM / SystemVerilog)**  
   Testbench development, coverage-driven verification, UVM methodology. Icon: `bi-shield-check`

3. **FPGA Prototyping**  
   Rapid prototyping on Xilinx/AMD and Intel/Altera FPGA platforms. Icon: `bi-grid-3x3-gap`

4. **Synthesis & Timing Closure**  
   Logic synthesis, place-and-route, STA, timing constraints. Icon: `bi-diagram-3`

**Vendors & Tools section** — Bootstrap `badge` components (text only, styled as chips):
- Xilinx / AMD — Vivado, Vitis  
- Intel / Altera — Quartus Prime  
- Synopsys / Cadence — Design Compiler, Genus, Innovus, VCS, Xcelium  

Card styling: dark background (`bg-dark`), custom glowing blue border on hover, Bootstrap `h-100` for equal height.

### 5.3 Projects / Portfolio (`projects.html`)

**Bootstrap components used:** `card`, `badge`, `row row-cols-1 row-cols-md-3`, `g-4` gutter

Minimum 3 placeholder project cards. Each card contains:
- Project title (`card-title`)  
- Short description (`card-text`) — technology used, problem solved  
- Tags using Bootstrap `badge bg-primary` / `badge bg-secondary` (e.g. `FPGA`, `UVM`, `Zynq`, `ASIC`)  
- Status badge: `badge bg-success` for "Completed", `badge bg-warning` for "Ongoing"  
- Hover effect: custom CSS `transform: translateY(-4px)` + blue `box-shadow` glow  

### 5.4 Contact (`contact.html`)

**Bootstrap components used:** `form-control`, `form-label`, `btn btn-primary`, `alert`, `container`, `row`, `col-md-8 offset-md-2`

Form fields (all required):
1. **Name** — `<input type="text" class="form-control">`  
2. **Email** — `<input type="email" class="form-control">`  
3. **Message** — `<textarea class="form-control" rows="5">`  

- Submit button: Bootstrap `btn btn-primary w-100`  
- Validation: Bootstrap 5 built-in HTML5 validation + `was-validated` class toggled via JS  
- On successful submit: show Bootstrap `alert alert-success` dismissible message  
- Static company email displayed below the form  

---

## 6. Shared Components

- **Navbar** — Bootstrap `navbar` component, identical across all pages  
- **Footer** — Bootstrap `container` with company name, copyright, optional LinkedIn icon (`bi-linkedin`)  
- **CSS custom properties** — defined in `:root` in `style.css` to override Bootstrap's default color tokens:
  ```css
  :root {
    --bs-primary: #00b4ff;
    --bs-body-bg: #0a0e1a;
    --bs-body-color: #e0e8f0;
    --bs-card-bg: #111827;
    --bs-border-color: #1e2d45;
  }
  ```
- **Shared stylesheet** — `css/style.css` loaded after Bootstrap CDN on every page  
- **Shared script** — `js/main.js` for form validation and any custom interactions  

---

## 7. CDN Links (to include in every HTML `<head>`)

```html
<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

<!-- Google Fonts: Orbitron + Inter -->
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@300;400;600&display=swap" rel="stylesheet">

<!-- Custom styles (always AFTER Bootstrap) -->
<link href="css/style.css" rel="stylesheet">
```

```html
<!-- Bootstrap 5 JS Bundle (before </body>) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Custom scripts -->
<script src="js/main.js"></script>
```

---

## 8. File Structure

```
mintakaam/
├── index.html          # Home / Hero page
├── services.html       # Services page
├── projects.html       # Projects / Portfolio page
├── contact.html        # Contact page
├── css/
│   └── style.css       # Custom styles (loaded after Bootstrap CDN)
├── js/
│   └── main.js         # Custom JS (form validation, interactions)
└── assets/
    ├── images/
    │   └── logo.png    # Mintaka logo (place manually)
    └── icons/          # Any additional SVG assets
```

---

## 9. Bootstrap 5 — Key Classes Reference

| Element | Bootstrap Class(es) |
|---|---|
| Page layout wrapper | `container` / `container-fluid` |
| Responsive grid | `row`, `col-*`, `col-md-*` |
| Navigation bar | `navbar navbar-expand-lg navbar-dark fixed-top` |
| Nav items | `nav-item`, `nav-link`, `active` |
| Hero section | Custom CSS + `d-flex align-items-center justify-content-center` |
| Service cards | `card h-100 bg-dark border-0` |
| Project cards | `card h-100` + custom glow hover |
| Badges / tags | `badge bg-primary`, `badge bg-success` |
| CTA buttons | `btn btn-primary`, `btn btn-outline-light` |
| Contact form | `form-control`, `form-label`, `was-validated` |
| Success alert | `alert alert-success alert-dismissible fade show` |
| Footer | `footer py-4 text-center` |

---

## 10. Branding & Logo

**Logo provided:** Yes — `assets/images/logo.png`

**Logo description:**  
- Periodic-table element style: square border frame  
- Large "AI" lettermark at the top (bold, serif-style)  
- "MINTAKA" wordmark centered at the bottom  
- Original colors: dark navy (`#0d1f3c`) on cream/off-white (`#f5f0e8`)  
- On the dark website, render in white using `filter: invert(1) brightness(2)` or provide a separate white variant  

**Logo usage:**
- Navbar: `<img src="assets/images/logo.png" height="40" class="logo-invert">` as `navbar-brand`  
- Hero section: centered, height ~120px  
- Favicon: generate `favicon.ico` from the logo  

---

## 11. Content Placeholders

Items to be replaced before launch:

- [ ] Place logo file at `assets/images/logo.png`  
- [ ] Real project descriptions and titles in `projects.html`  
- [ ] Company contact email address in `contact.html`  
- [ ] Company LinkedIn / social media URL in footer  
- [ ] Favicon (`favicon.ico`) generated from logo  

---

*Requirements captured: 2026-05-28*  
*Based on client Q&A session with Mintaka LLC.*  
*Logo provided by client: periodic-table style "AI MINTAKA" mark, navy on cream.*  
*Stack updated to Bootstrap 5 per client request.*
