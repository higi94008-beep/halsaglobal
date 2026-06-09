// ─────────────────────────────────────────────
//  HalsaGlobal — Frontend JS
// ─────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {

  // ── NAVBAR SCROLL ──
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 20);
  }, { passive: true });

  // ── MOBILE HAMBURGER ──
  const hamburger = document.getElementById('hamburger');
  const navLinks  = document.getElementById('navLinks');
  hamburger?.addEventListener('click', () => {
    navLinks.classList.toggle('open');
    const open = navLinks.classList.contains('open');
    hamburger.setAttribute('aria-expanded', open);
    hamburger.querySelectorAll('span').forEach((s, i) => {
      if (open) {
        if (i === 0) s.style.transform = 'rotate(45deg) translate(5px, 5px)';
        if (i === 1) s.style.opacity = '0';
        if (i === 2) s.style.transform = 'rotate(-45deg) translate(5px, -5px)';
      } else {
        s.style.transform = '';
        s.style.opacity = '';
      }
    });
  });

  // Close mobile menu on outside click
  document.addEventListener('click', (e) => {
    if (navLinks.classList.contains('open') &&
        !navLinks.contains(e.target) &&
        !hamburger.contains(e.target)) {
      navLinks.classList.remove('open');
      hamburger.querySelectorAll('span').forEach(s => {
        s.style.transform = '';
        s.style.opacity = '';
      });
    }
  });

  // ── SCROLL-TO-ANCHOR SMOOTH ──
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const target = document.querySelector(a.getAttribute('href'));
      if (target) {
        e.preventDefault();
        const offset = 88; // navbar height
        const top = target.getBoundingClientRect().top + window.scrollY - offset;
        window.scrollTo({ top, behavior: 'smooth' });
        if (navLinks.classList.contains('open')) {
          navLinks.classList.remove('open');
        }
      }
    });
  });

  // ── FADE-IN OBSERVER ──
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12 }
  );

  // Attach fade-in to major sections
  const fadeTargets = [
    '.service-card',
    '.industry-card',
    '.testimonial-card',
    '.cs-card',
    '.process-step',
    '.why-inner',
    '.section-header',
  ];
  document.querySelectorAll(fadeTargets.join(', ')).forEach((el, i) => {
    el.classList.add('fade-in');
    el.style.transitionDelay = `${(i % 4) * 0.08}s`;
    observer.observe(el);
  });

  // ── CONTACT FORM ──
  const form = document.getElementById('contactForm');
  form?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = form.querySelector('button[type="submit"]');
    btn.textContent = 'Sending...';
    btn.disabled = true;

    const data = Object.fromEntries(new FormData(form));

    try {
      const res = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (res.ok) {
        form.closest('.contact-form-wrap').innerHTML = `
          <div class="form-success">
            <div class="success-icon">✅</div>
            <h3>We'll be in touch shortly!</h3>
            <p>Thanks, <strong>${data.firstName}</strong>. A certified consultant will reach out within 24 hours to schedule your free consultation.</p>
          </div>
        `;
      } else {
        throw new Error('Server error');
      }
    } catch {
      btn.textContent = 'Schedule Free Consultation';
      btn.disabled = false;
      showToast('Something went wrong. Please try again or email us directly.', 'error');
    }
  });

  // ── TOAST NOTIFICATIONS ──
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.style.cssText = `
      position: fixed; bottom: 24px; right: 24px; z-index: 9999;
      background: ${type === 'error' ? '#FF4444' : '#0057FF'};
      color: white; padding: 14px 22px; border-radius: 10px;
      font-size: 0.9rem; font-weight: 500; max-width: 380px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
      animation: slideIn 0.3s ease;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 4500);
  }

  // ── ANIMATED COUNTER ──
  function animateCounter(el, target, suffix = '') {
    const duration = 1800;
    const start = performance.now();
    const updateCounter = (now) => {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const value = Math.round(eased * target);
      el.textContent = value + suffix;
      if (progress < 1) requestAnimationFrame(updateCounter);
    };
    requestAnimationFrame(updateCounter);
  }

  // Trigger counters when stats come into view
  const statsObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const nums = entry.target.querySelectorAll('.stat-num');
          nums.forEach(num => {
            const text = num.textContent;
            const match = text.match(/^(\d+)(.*)$/);
            if (match) {
              animateCounter(num, parseInt(match[1]), match[2]);
            }
          });
          statsObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.5 }
  );
  document.querySelectorAll('.hero-stats').forEach(el => statsObserver.observe(el));

  // ── ACTIVE NAV HIGHLIGHT ──
  const sections = document.querySelectorAll('section[id]');
  const navItems = document.querySelectorAll('.nav-links .nav-item > a[href^="#"]');
  const activateNav = () => {
    const scrollPos = window.scrollY + 100;
    sections.forEach(section => {
      if (scrollPos >= section.offsetTop && scrollPos < section.offsetTop + section.offsetHeight) {
        navItems.forEach(item => {
          item.style.color = item.getAttribute('href') === `#${section.id}` ? 'var(--blue)' : '';
        });
      }
    });
  };
  window.addEventListener('scroll', activateNav, { passive: true });
});

// ── CSS ANIMATION FOR TOAST ──
const style = document.createElement('style');
style.textContent = `
  @keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to   { transform: translateX(0);   opacity: 1; }
  }
`;
document.head.appendChild(style);
