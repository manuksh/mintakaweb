/* ============================================================
   Mintaka LLC — main.js
   Shared scripts: navbar scroll, scroll-reveal, contact form
   ============================================================ */

'use strict';

/* ---------- Navbar: add shadow on scroll ---------- */
(function () {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      navbar.style.boxShadow = '0 4px 24px rgba(0,180,255,0.12)';
    } else {
      navbar.style.boxShadow = 'none';
    }
  });
})();

/* ---------- Scroll-reveal ---------- */
(function () {
  const targets = document.querySelectorAll('.reveal');
  if (!targets.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry, i) => {
        if (entry.isIntersecting) {
          setTimeout(() => {
            entry.target.classList.add('visible');
          }, i * 80);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12 }
  );

  targets.forEach((el) => observer.observe(el));
})();

/* ---------- Email obfuscation (anti-scraping) ---------- */
(function () {
  const emailLink = document.getElementById('contactEmailLink');
  const emailText = document.getElementById('contactEmailText');
  if (!emailLink || !emailText) return;

  // Build email from parts so it's not in the HTML source
  const parts = ['info', '@', 'mintaka', '-', 'ai', '.', 'com'];
  const email = parts.join('');
  emailLink.href = 'mail' + 'to:' + email;
  emailText.textContent = email;
})();

/* ---------- Contact form validation ---------- */
(function () {
  const form = document.getElementById('contactForm');
  if (!form) return;

  const successAlert = document.getElementById('formSuccess');
  const submitBtn = document.getElementById('submitBtn');

  // Rate limiting: prevent resubmission within 30 seconds
  let lastSubmitTime = 0;
  const COOLDOWN_MS = 30000;

  // Generate CAPTCHA numbers
  let captchaAnswer = 0;
  function generateCaptcha() {
    const num1 = Math.floor(Math.random() * 10) + 1;
    const num2 = Math.floor(Math.random() * 10) + 1;
    captchaAnswer = num1 + num2;
    document.getElementById('captchaNum1').textContent = num1;
    document.getElementById('captchaNum2').textContent = num2;
    const captchaInput = form.querySelector('#captcha');
    if (captchaInput) captchaInput.value = '';
  }
  generateCaptcha();

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    e.stopPropagation();

    // Reset previous invalid states
    form.querySelectorAll('.form-control').forEach((el) => {
      el.classList.remove('is-invalid');
    });

    let valid = true;

    // Honeypot check: if filled, silently reject (bot detected)
    const honeypot = form.querySelector('#website');
    if (honeypot && honeypot.value.trim() !== '') {
      // Silently reject — bot detected
      return;
    }

    // Rate limiting check
    const now = Date.now();
    if (now - lastSubmitTime < COOLDOWN_MS) {
      const remainingSec = Math.ceil((COOLDOWN_MS - (now - lastSubmitTime)) / 1000);
      alert('Please wait ' + remainingSec + ' seconds before submitting again.');
      return;
    }

    // Name
    const name = form.querySelector('#name');
    if (!name.value.trim()) {
      name.classList.add('is-invalid');
      valid = false;
    }

    // Email
    const email = form.querySelector('#email');
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email.value.trim() || !emailRegex.test(email.value.trim())) {
      email.classList.add('is-invalid');
      valid = false;
    }

    // Message
    const message = form.querySelector('#message');
    if (!message.value.trim()) {
      message.classList.add('is-invalid');
      valid = false;
    }

    // CAPTCHA validation
    const captchaInput = form.querySelector('#captcha');
    const captchaValue = parseInt(captchaInput.value, 10);
    if (isNaN(captchaValue) || captchaValue !== captchaAnswer) {
      captchaInput.classList.add('is-invalid');
      valid = false;
      generateCaptcha(); // Generate new numbers on failure
    }

    if (valid) {
      // Record submission time for rate limiting
      lastSubmitTime = Date.now();

      // Disable button temporarily
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>Sent!';

      // Show success alert
      if (successAlert) {
        successAlert.classList.remove('d-none');
        successAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }

      // Reset form and generate new CAPTCHA
      form.reset();
      form.classList.remove('was-validated');
      generateCaptcha();

      // Re-enable button after cooldown
      setTimeout(() => {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="bi bi-send-fill me-2"></i>Send Message';
      }, COOLDOWN_MS);
    }
  });
})();

/* ---------- Active nav link highlighting ---------- */
(function () {
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-link').forEach((link) => {
    const href = link.getAttribute('href');
    if (href === currentPage || (currentPage === '' && href === 'index.html')) {
      link.classList.add('active');
      link.setAttribute('aria-current', 'page');
    }
  });
})();
