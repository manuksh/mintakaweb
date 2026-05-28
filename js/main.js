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

/* ---------- Contact form validation ---------- */
(function () {
  const form = document.getElementById('contactForm');
  if (!form) return;

  const successAlert = document.getElementById('formSuccess');

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    e.stopPropagation();

    // Reset previous invalid states
    form.querySelectorAll('.form-control').forEach((el) => {
      el.classList.remove('is-invalid');
    });

    let valid = true;

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

    if (valid) {
      // Show success alert
      if (successAlert) {
        successAlert.classList.remove('d-none');
        successAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }
      form.reset();
      form.classList.remove('was-validated');
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
