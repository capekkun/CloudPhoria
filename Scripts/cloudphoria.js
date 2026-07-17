/* =============================================================
   CloudPhoria – Shared UI Behaviour
   Scripts/cloudphoria.js
   Handles sidebar, mobile menu, user dropdown, and
   keyboard accessibility for the shared application layout.
   No authentication, role, or database logic belongs here.
   ============================================================= */

(function () {
    'use strict';

    // Wait for the DOM to be ready before wiring up controls.
    document.addEventListener('DOMContentLoaded', function () {
        initSidebar();
        initUserMenu();
    });

    /* ----------------------------------------------------------
       Sidebar – mobile open/close
       ---------------------------------------------------------- */
    function initSidebar() {
        var sidebar  = document.getElementById('cpSidebar');
        var overlay  = document.getElementById('cpSidebarOverlay');
        var openBtn  = document.getElementById('cpSidebarToggle');
        var closeBtn = document.getElementById('cpSidebarClose');

        // If any element is missing the page does not need sidebar behaviour.
        if (!sidebar) { return; }

        // Open sidebar when the topbar hamburger button is clicked.
        if (openBtn) {
            openBtn.addEventListener('click', function () {
                openSidebar();
            });
        }

        // Close sidebar when the inline close button is clicked.
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                closeSidebar();
            });
        }

        // Close sidebar when the overlay behind it is clicked.
        if (overlay) {
            overlay.addEventListener('click', function () {
                closeSidebar();
            });
        }

        // Close sidebar when the Escape key is pressed.
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                if (sidebar.classList.contains('open')) {
                    closeSidebar();
                    // Return focus to the toggle button so keyboard users are not lost.
                    if (openBtn) { openBtn.focus(); }
                }
            }
        });

        // When the viewport grows back to desktop size, clear the
        // open/close state so the sidebar is always visible at large widths.
        window.addEventListener('resize', function () {
            if (window.innerWidth > 1024) {
                closeSidebar();
            }
        });

        function openSidebar() {
            sidebar.classList.add('open');
            if (overlay) { overlay.classList.add('active'); }
            // Announce expanded state for screen readers.
            if (openBtn) { openBtn.setAttribute('aria-expanded', 'true'); }
            // Move focus into the sidebar for keyboard navigation.
            if (closeBtn) { closeBtn.focus(); }
        }

        function closeSidebar() {
            sidebar.classList.remove('open');
            if (overlay) { overlay.classList.remove('active'); }
            if (openBtn) { openBtn.setAttribute('aria-expanded', 'false'); }
        }
    }

    /* ----------------------------------------------------------
       User menu dropdown (topbar)
       ---------------------------------------------------------- */
    function initUserMenu() {
        var toggle   = document.getElementById('cpUserMenuToggle');
        var dropdown = document.getElementById('cpUserDropdown');

        if (!toggle || !dropdown) { return; }

        // Toggle on button click.
        toggle.addEventListener('click', function (e) {
            e.stopPropagation();
            var isOpen = dropdown.classList.contains('open');
            if (isOpen) {
                closeUserMenu();
            } else {
                openUserMenu();
            }
        });

        // Close when clicking anywhere outside the menu.
        document.addEventListener('click', function () {
            closeUserMenu();
        });

        // Close on Escape key.
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                if (dropdown.classList.contains('open')) {
                    closeUserMenu();
                    toggle.focus();
                }
            }
        });

        function openUserMenu() {
            dropdown.classList.add('open');
            toggle.setAttribute('aria-expanded', 'true');
        }

        function closeUserMenu() {
            dropdown.classList.remove('open');
            toggle.setAttribute('aria-expanded', 'false');
        }
    }

})();
