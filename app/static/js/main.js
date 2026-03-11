/* WebCyber — UI scripts */

(function () {
  var SIDEBAR_KEY = 'wc_sidebar';
  var DESKTOP_BP  = 1024;

  function isDesktop() {
    return window.innerWidth >= DESKTOP_BP;
  }

  function applySidebarState() {
    var body = document.body;
    if (isDesktop()) {
      // Restore saved collapsed state on desktop
      if (localStorage.getItem(SIDEBAR_KEY) === 'collapsed') {
        body.classList.add('sidebar-collapsed');
      } else {
        body.classList.remove('sidebar-collapsed');
      }
    } else {
      // On mobile the collapsed class must never be active
      body.classList.remove('sidebar-collapsed');
    }
  }

  function initSidebar() {
    var body          = document.body;
    var desktopToggle = document.getElementById('sidebar-toggle');
    var mobileToggle  = document.getElementById('mobile-sidebar-toggle');
    var overlay       = document.getElementById('sidebar-overlay');

    applySidebarState();

    // Sync on viewport resize (e.g. desktop → mobile without refresh)
    var resizeTimer;
    window.addEventListener('resize', function () {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(function () {
        applySidebarState();
        // Close mobile drawer if resizing back to desktop
        if (isDesktop()) {
          body.classList.remove('mobile-sidebar-open');
        }
      }, 100);
    });

    if (desktopToggle) {
      desktopToggle.addEventListener('click', function () {
        body.classList.toggle('sidebar-collapsed');
        localStorage.setItem(
          SIDEBAR_KEY,
          body.classList.contains('sidebar-collapsed') ? 'collapsed' : 'expanded'
        );
      });
    }

    if (mobileToggle) {
      mobileToggle.addEventListener('click', function () {
        body.classList.toggle('mobile-sidebar-open');
      });
    }

    if (overlay) {
      overlay.addEventListener('click', function () {
        body.classList.remove('mobile-sidebar-open');
      });
    }
  }

  document.addEventListener('DOMContentLoaded', function () {
    initSidebar();
    initNoteSearch();
    initWordCount();
  });

})();

/* ── Note search ───────────────────────────────────────── */
function initNoteSearch() {
  var searchInput = document.getElementById('note-search');
  if (!searchInput) return;

  var cards    = document.querySelectorAll('[data-note-card]');
  var countEl  = document.getElementById('note-count');
  var emptyEl  = document.getElementById('search-empty');
  var total    = cards.length;

  searchInput.addEventListener('input', function () {
    var q = this.value.toLowerCase().trim();
    var visible = 0;

    cards.forEach(function (card) {
      var match = !q ||
        (card.dataset.title   || '').includes(q) ||
        (card.dataset.content || '').includes(q);
      card.style.display = match ? '' : 'none';
      if (match) visible++;
    });

    if (countEl) countEl.textContent = q ? (visible + ' of ' + total) : total;
    if (emptyEl) emptyEl.classList.toggle('hidden', !q || visible > 0);
  });
}

/* ── Word / char counter ──────────────────────────────── */
function initWordCount() {
  document.querySelectorAll('textarea').forEach(function (ta) {
    if (!ta.id) return;
    var wordEl = document.querySelector('[data-wc-words="' + ta.id + '"]');
    var charEl = document.querySelector('[data-wc-chars="' + ta.id + '"]');
    if (!wordEl || !charEl) return;

    function update() {
      var text = ta.value;
      charEl.textContent = text.length;
      wordEl.textContent = text.trim() ? text.trim().split(/\s+/).length : 0;
    }
    ta.addEventListener('input', update);
    update(); // populate count for pre-filled content on edit page
  });
}

/* ── Confirm modal ────────────────────────────────────── */
(function () {
  var modal     = document.getElementById('confirm-modal');
  var backdrop  = document.getElementById('confirm-backdrop');
  var panel     = document.getElementById('confirm-panel');
  var titleEl   = document.getElementById('confirm-modal-title');
  var bodyEl    = document.getElementById('confirm-modal-body');
  var iconWrap  = document.getElementById('confirm-icon-wrap');
  var okBtn     = document.getElementById('confirm-ok');
  var cancelBtn = document.getElementById('confirm-cancel');

  if (!modal) return;

  var pendingForm   = null;
  var pendingAction = null;

  /* Icons injected as inline SVG strings */
  var ICON_WARN = '<svg class="w-5 h-5 text-amber-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/></svg>';
  var ICON_DANGER = '<svg class="w-5 h-5 text-rose-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M15 9l-6 6M9 9l6 6"/></svg>';

  function open(message, isDanger, form, action) {
    pendingForm   = form   || null;
    pendingAction = action || null;

    var danger = isDanger === true || isDanger === 'true';

    titleEl.textContent = danger ? 'Are you sure?' : 'Confirm action';
    bodyEl.textContent  = message || 'Do you want to continue?';

    iconWrap.className = 'flex items-center justify-center w-10 h-10 rounded-full mb-4 mx-auto ' +
                         (danger ? 'bg-rose-50' : 'bg-amber-50');
    iconWrap.innerHTML = danger ? ICON_DANGER : ICON_WARN;

    okBtn.textContent  = danger ? 'Yes, delete' : 'Confirm';
    okBtn.className    = 'px-4 py-2 text-xs font-semibold text-white rounded-lg transition ' +
                         (danger ? 'bg-rose-600 hover:bg-rose-700' : 'bg-amber-500 hover:bg-amber-600');

    modal.classList.remove('hidden');
    modal.classList.add('flex');

    requestAnimationFrame(function () {
      backdrop.classList.remove('opacity-0');
      backdrop.classList.add('opacity-100');
      panel.classList.remove('scale-95', 'opacity-0');
      panel.classList.add('scale-100', 'opacity-100');
    });

    /* Trap focus on OK button */
    okBtn.focus();
  }

  function close() {
    backdrop.classList.remove('opacity-100');
    backdrop.classList.add('opacity-0');
    panel.classList.remove('scale-100', 'opacity-100');
    panel.classList.add('scale-95', 'opacity-0');
    setTimeout(function () {
      modal.classList.add('hidden');
      modal.classList.remove('flex');
      pendingForm   = null;
      pendingAction = null;
    }, 200);
  }

  /* Confirm → submit the form */
  okBtn.addEventListener('click', function () {
    if (pendingForm) {
      /* Remove the data-confirm attr so it won't re-trigger */
      pendingForm.removeAttribute('data-confirm');
      pendingForm.submit();
    } else if (typeof pendingAction === 'function') {
      pendingAction();
    }
    close();
  });

  cancelBtn.addEventListener('click', close);
  backdrop.addEventListener('click', close);

  /* Close on Escape */
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !modal.classList.contains('hidden')) close();
  });

  /* Intercept every form with data-confirm */
  document.addEventListener('submit', function (e) {
    var form = e.target;
    var msg  = form.getAttribute('data-confirm');
    if (!msg) return;
    e.preventDefault();
    var danger = form.getAttribute('data-confirm-danger');
    open(msg, danger, form, null);
  }, true);

  /* Intercept buttons/links with data-confirm (non-form) */
  document.addEventListener('click', function (e) {
    var el  = e.target.closest('[data-confirm]');
    if (!el || el.tagName === 'FORM') return;
    /* Skip if the element is inside a form — the form handler covers that */
    if (el.closest('form[data-confirm]')) return;
    e.preventDefault();
    var msg    = el.getAttribute('data-confirm');
    var danger = el.getAttribute('data-confirm-danger');
    var href   = el.getAttribute('href');
    open(msg, danger, null, href ? function () { window.location.href = href; } : null);
  }, true);
})();
