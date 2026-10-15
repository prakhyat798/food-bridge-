/**
 * FoodBridge Global Aid Network — Interactive Controller & Realtime Web App
 * Connects directly to Supabase Cloud PostgreSQL & Mobile App State
 */

let modalSimRole = 'donor'; // 'donor', 'ngo', 'rider'
let modalSimStep = 1; // 0: posted, 1: matched, 2: inTransit, 3: delivered
let currentFeedFilter = 'all';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize role console details & phone screen
  updateRoleDetailsBox();
  renderModalPhoneScreen();

  // Load live Supabase donations immediately
  loadAndRenderFeed();

  // Establish Supabase Realtime WebSocket Listener
  initRealtimeSubscription((payload) => {
    handleRealtimeDonationEvent(payload);
  });

  // Fluid scroll animations & stats count-up
  initScrollRevealAnimations();
  initCountUpStats();

  // Initialize Interactive Leaflet Rescue Map
  initFoodBridgeMap();
});

// ─────────────────────────────────────────────────────────────
// Realtime Live Feed Controller
// ─────────────────────────────────────────────────────────────

async function loadAndRenderFeed() {
  const grid = document.getElementById('rescueFeedGrid');
  if (grid && (!FoodBridgeData.activeDonations || FoodBridgeData.activeDonations.length === 0)) {
    grid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 48px 0; color: var(--text-muted);">
        <div style="font-size: 2rem; margin-bottom: 12px; animation: spin 1s infinite linear;">🔄</div>
        <div>Connecting to Supabase Cloud and fetching active rescue missions...</div>
      </div>
    `;
  }

  const donations = await fetchLiveDonations();
  renderRescueFeed(currentFeedFilter);
  
  // Also sync the phone simulator with the freshest live donation if available
  if (donations && donations.length > 0) {
    updatePhoneSimFromLive(donations[0]);
  }
}

function handleRealtimeDonationEvent(payload) {
  if (payload.eventType === 'INSERT') {
    const item = payload.new;
    showToast(
      'New Surplus Food Alert 🍲',
      `"${item.food_name}" (${item.quantity} ${item.unit}) just posted to the network!`
    );
  } else if (payload.eventType === 'UPDATE') {
    const item = payload.new;
    const readableStatus = item.status === 'inTransit' ? 'In Transit' : item.status.toUpperCase();
    showToast(
      'Rescue Mission Updated 🛵',
      `"${item.food_name}" status updated to: ${readableStatus}`
    );
  }

  // Refetch latest from database and update grid
  fetchLiveDonations().then(() => {
    renderRescueFeed(currentFeedFilter);
  });
}

function renderRescueFeed(filter = 'all') {
  const grid = document.getElementById('rescueFeedGrid');
  if (!grid) return;

  const allItems = FoodBridgeData.activeDonations || [];

  // Update counters
  const countAll = allItems.length;
  const countPending = allItems.filter(d => d.status === 'pending').length;
  const countTransit = allItems.filter(d => d.status === 'inTransit' || d.status === 'in-transit').length;
  const countDelivered = allItems.filter(d => d.status === 'delivered').length;

  const countAllEl = document.getElementById('countAll');
  const countPendingEl = document.getElementById('countPending');
  const countTransitEl = document.getElementById('countTransit');
  const countDeliveredEl = document.getElementById('countDelivered');

  if (countAllEl) countAllEl.textContent = countAll;
  if (countPendingEl) countPendingEl.textContent = countPending;
  if (countTransitEl) countTransitEl.textContent = countTransit;
  if (countDeliveredEl) countDeliveredEl.textContent = countDelivered;

  // Filter items
  let filtered = allItems;
  if (filter === 'pending') {
    filtered = allItems.filter(d => d.status === 'pending');
  } else if (filter === 'inTransit') {
    filtered = allItems.filter(d => d.status === 'inTransit' || d.status === 'in-transit');
  } else if (filter === 'delivered') {
    filtered = allItems.filter(d => d.status === 'delivered');
  }

  if (filtered.length === 0) {
    grid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: #FFFFFF; border-radius: 16px; border: 1px dashed var(--border-light);">
        <div style="font-size: 2.2rem; margin-bottom: 12px;">🥗</div>
        <div style="font-size: 1.15rem; font-weight: 700; color: var(--text-dark); margin-bottom: 6px;">No Rescues in this Category</div>
        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 18px;">
          Be the first to pledge surplus meals and mobilize our courier fleet!
        </p>
        <button class="btn-pill-amber" onclick="openPledgeDonationModal()">+ PLEDGE SURPLUS FOOD</button>
      </div>
    `;
    return;
  }

  // Render cards with staggered spring cascade
  grid.innerHTML = filtered.map((d, idx) => {
    const isTransit = d.status === 'inTransit' || d.status === 'in-transit';
    const isDelivered = d.status === 'delivered';
    const isMatched = d.status === 'matched';
    const isPending = d.status === 'pending';

    let badgeClass = 'status-badge-pending';
    let badgeText = '⏳ Pending Match';
    if (isTransit) {
      badgeClass = 'status-badge-intransit';
      badgeText = '🛵 In Transit';
    } else if (isDelivered) {
      badgeClass = 'status-badge-delivered';
      badgeText = '✅ Rescued & Delivered';
    } else if (isMatched) {
      badgeClass = 'status-badge-matched';
      badgeText = '🤝 Matched with Shelter';
    }

    const categoryIcon = getCategoryIcon(d.category);
    const timeFormatted = formatTimeAgo(d.posted_at || d.created_at);
    const donorDisplay = d.donor_name || 'Community Donor';
    const destinationDisplay = d.matched_ngo ? d.matched_ngo : '📢 Broadcasted to All Nearby Shelters';
    const staggerDelay = Math.min(idx * 0.08, 0.6).toFixed(2);

    return `
      <div class="rescue-card" id="card-${d.id}" style="animation-delay: ${staggerDelay}s;">
        <div class="rescue-card-header">
          <span class="rescue-category-tag">${categoryIcon} ${escapeHtml(d.category || 'Surplus Food')}</span>
          <span class="rescue-status-pill ${badgeClass}">
            ${badgeText}
          </span>
        </div>

        <h3 class="rescue-card-title">${escapeHtml(d.food_name)}</h3>

        <div class="rescue-meta-row">
          <span class="rescue-meta-badge">⚖️ ${escapeHtml(d.quantity)} ${escapeHtml(d.unit || 'kg')}</span>
          <span class="rescue-meta-badge">🍽️ ${escapeHtml(String(d.servings || '1'))} Servings</span>
          ${d.is_urgent ? '<span class="rescue-meta-badge" style="background: rgba(239,68,68,0.1); color: #DC2626; border-color: rgba(239,68,68,0.3);">⚡ Urgent</span>' : ''}
        </div>

        <div class="rescue-destination-box">
          <div class="rescue-destination-label">Destination Shelter:</div>
          <div style="font-weight: 700; color: var(--text-dark); margin-top: 2px;">
            ${escapeHtml(destinationDisplay)}
          </div>
          ${d.rider_id ? `<div style="font-size: 0.76rem; color: #2563EB; margin-top: 4px;">🛵 Courier Assigned: <b>${escapeHtml(d.rider_id)}</b></div>` : ''}
        </div>

        <div class="rescue-card-footer">
          <span>🕒 ${timeFormatted}</span>
          <span style="font-weight: 600; color: var(--color-primary-teal);">📍 ${escapeHtml(donorDisplay)}</span>
        </div>
      </div>
    `;
  }).join('');
}

window.filterRescueFeed = function(filter, btnElement) {
  currentFeedFilter = filter;
  document.querySelectorAll('.filter-pill-btn').forEach(btn => btn.classList.remove('active'));
  if (btnElement) {
    btnElement.classList.add('active');
  }
  renderRescueFeed(filter);
};

// ─────────────────────────────────────────────────────────────
// Form Submission & Supabase Cloud Push
// ─────────────────────────────────────────────────────────────

window.handlePledgeSubmit = async function(e) {
  e.preventDefault();

  const foodNameInput = document.getElementById('pledgeFoodName');
  const quantityInput = document.getElementById('pledgeQuantity');
  const unitInput = document.getElementById('pledgeUnit');
  const categoryInput = document.getElementById('pledgeCategory');
  const servingsInput = document.getElementById('pledgeServings');
  const targetInput = document.getElementById('pledgeTarget');
  const urgentInput = document.getElementById('pledgeUrgent');
  const submitBtn = document.getElementById('pledgeSubmitBtn');

  const foodName = foodNameInput.value.trim();
  const quantity = quantityInput.value.trim();
  const unit = unitInput.value;
  const category = categoryInput.value;
  const servings = parseInt(servingsInput.value) || 1;
  const target = targetInput.value;
  const isUrgent = urgentInput.checked;

  if (!foodName || !quantity) {
    alert('Please fill in both the food name and quantity.');
    return;
  }

  // Update button to loading state
  if (submitBtn) {
    submitBtn.disabled = true;
    submitBtn.textContent = '🚀 DISPATCHING TO SUPABASE CLOUD & FLEET...';
  }

  const newDonationId = 'd_web_' + Date.now();
  const newDonation = {
    id: newDonationId,
    food_name: foodName,
    category: category,
    quantity: quantity,
    unit: unit,
    servings: servings,
    condition: 'Freshly Prepared',
    is_urgent: isUrgent,
    status: target ? 'matched' : 'pending',
    matched_ngo: target || null,
    donor_name: 'Web Donor Portal',
    posted_at: new Date().toISOString(),
    created_at: new Date().toISOString()
  };

  const result = await postDonation(newDonation);

  if (submitBtn) {
    submitBtn.disabled = false;
    submitBtn.textContent = 'CONFIRM & DISPATCH RESCUE TO MOBILE APP';
  }

  if (result.success) {
    closePledgeModal();
    document.getElementById('pledgeForm').reset();

    // Prepend locally so UI updates instantaneously
    FoodBridgeData.activeDonations.unshift(newDonation);
    renderRescueFeed(currentFeedFilter);

    // Show glowing confirmation toast
    showToast(
      'Donation Confirmed & Live! 🎉',
      `"${foodName}" is now active on Supabase Cloud and syncing to volunteer riders on the mobile app!`
    );

    // Scroll smoothly to live-feed section to see the new entry
    const feedSec = document.getElementById('live-feed');
    if (feedSec) {
      feedSec.scrollIntoView({ behavior: 'smooth' });
    }

    // Update phone simulator screen if donor view active
    updatePhoneSimFromLive(newDonation);
  } else {
    alert('Could not submit donation to Supabase. Check console logs or network connection.');
  }
};

// ─────────────────────────────────────────────────────────────
// Toast Notification Engine
// ─────────────────────────────────────────────────────────────

function showToast(title, message) {
  const container = document.getElementById('toastContainer');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'fb-toast';
  toast.innerHTML = `
    <div style="font-size: 1.5rem;">🍲</div>
    <div style="flex: 1;">
      <div class="fb-toast-title">${escapeHtml(title)}</div>
      <div class="fb-toast-msg">${escapeHtml(message)}</div>
    </div>
    <button onclick="this.parentElement.remove()" style="background: none; border: none; color: #9CA3AF; cursor: pointer; font-size: 1rem;">✕</button>
  `;

  container.appendChild(toast);

  // Auto remove after 4.5 seconds
  setTimeout(() => {
    if (toast.parentElement) {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(15px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }
  }, 4500);
}

// ─────────────────────────────────────────────────────────────
// Phone Simulator & Role Switcher
// ─────────────────────────────────────────────────────────────

let latestDonationCache = null;

function updatePhoneSimFromLive(donation) {
  if (donation) {
    latestDonationCache = donation;
    if (modalSimRole === 'donor') {
      renderModalPhoneScreen();
    }
  }
}

window.openAppSimulatorModal = function() {
  const modal = document.getElementById('appSimulatorModal');
  if (modal) modal.classList.add('open');
};

window.closeAppSimulatorModal = function() {
  const modal = document.getElementById('appSimulatorModal');
  if (modal) modal.classList.remove('open');
};

window.openPledgeDonationModal = function() {
  const modal = document.getElementById('pledgeModal');
  if (modal) modal.classList.add('open');
};

window.closePledgeModal = function() {
  const modal = document.getElementById('pledgeModal');
  if (modal) modal.classList.remove('open');
};

window.setModalSimRole = function(role) {
  modalSimRole = role;
  updateRoleDetailsBox();
  renderModalPhoneScreen();
};

function updateRoleDetailsBox() {
  const box = document.getElementById('simRoleDetailsBox');
  const roleTag = document.getElementById('simActiveRoleTag');
  if (!box) return;

  if (modalSimRole === 'donor') {
    if (roleTag) {
      roleTag.textContent = '● Donor Mode';
      roleTag.style.color = '#60A5FA';
    }
    box.innerHTML = `
      <b>💙 Food Donor Console:</b><br>
      Restaurants and food caterers create surplus donations in 3 steps. The intelligent routing system automatically pairs surplus batches with nearby community shelters.
      <ul style="margin: 8px 0 0 16px; color: var(--text-body);">
        <li>Sync: <b>Supabase Cloud PostgreSQL Active</b></li>
        <li>Shelf-life priority scoring: <b>High</b></li>
        <li>Current Karma Points: <b>98%</b></li>
      </ul>
    `;
  } else if (modalSimRole === 'ngo') {
    if (roleTag) {
      roleTag.textContent = '● NGO Mode';
      roleTag.style.color = '#34D399';
    }
    box.innerHTML = `
      <b>💚 NGO & Shelter Console:</b><br>
      Verified community centers publish urgent headcounts and receive incoming food matches without tedious manual outreach.
      <ul style="margin: 8px 0 0 16px; color: var(--text-body);">
        <li>Current Meal Need: <b>100 Servings</b></li>
        <li>Matched Kitchen: <b>The Harvest Kitchen</b></li>
        <li>Volunteer Rider: <b>Vikram (R-201) En Route</b></li>
      </ul>
    `;
  } else {
    if (roleTag) {
      roleTag.textContent = '● Rider Mode';
      roleTag.style.color = '#F59E0B';
    }
    box.innerHTML = `
      <b>💛 Volunteer Rider Console:</b><br>
      Volunteers accept hyper-local rescue missions, navigate with offline-ready OpenStreetMap tiles, and verify drop-offs with secure 4-digit OTP.
      <ul style="margin: 8px 0 0 16px; color: var(--text-body);">
        <li>Status: <b>ONLINE & Active</b></li>
        <li>Current Mission: <b>50 Meals (2.4 km)</b></li>
        <li>Security: <b>Pickup & Dropoff OTP Enabled</b></li>
      </ul>
    `;
  }
}

function renderModalPhoneScreen() {
  const container = document.getElementById('modalPhoneScreenContent');
  if (!container) return;

  const activeFoodName = latestDonationCache ? latestDonationCache.food_name : 'Warm Basmati Rice & Curry';
  const activeQuantity = latestDonationCache ? `${latestDonationCache.quantity} ${latestDonationCache.unit || 'kg'} (${latestDonationCache.servings || '30'} Portions)` : '50 Portions';
  const activeDestination = latestDonationCache && latestDonationCache.matched_ngo ? latestDonationCache.matched_ngo : 'Helping Hands Shelter';

  if (modalSimRole === 'donor') {
    container.innerHTML = `
      <div style="font-weight: 800; font-size: 1.15rem; margin-bottom: 2px;">Good Afternoon 👋</div>
      <div style="font-size: 0.8rem; color: #94A3B8; margin-bottom: 14px;">FoodBridge Donor Dashboard</div>

      <!-- Active Delivery Banner -->
      <div style="background: linear-gradient(135deg, rgba(37,99,235,0.3) 0%, rgba(16,185,129,0.2) 100%); border: 1px solid rgba(59,130,246,0.4); border-radius: 14px; padding: 14px; margin-bottom: 14px;">
        <div style="display: flex; justify-content: space-between; font-size: 0.72rem; font-weight: 700; margin-bottom: 4px;">
          <span style="color: #60A5FA;">● ${modalSimStep >= 3 ? 'DELIVERED' : 'IN TRANSIT'}</span>
          <span style="color: #CBD5E1;">ETA ${modalSimStep >= 3 ? 'Arrived' : '12 mins'}</span>
        </div>
        <div style="font-weight: 800; font-size: 0.95rem;">${escapeHtml(activeFoodName)}</div>
        <div style="font-size: 0.75rem; color: #94A3B8; margin-bottom: 10px;">${escapeHtml(activeQuantity)} · ${escapeHtml(activeDestination)}</div>
        
        <!-- Timeline Steps -->
        <div style="display: flex; justify-content: space-between; font-size: 0.68rem; color: #94A3B8;">
          <span style="color: #34D399;">✓ Posted</span>
          <span style="color: #34D399;">✓ Matched</span>
          <span style="color: ${modalSimStep >= 2 ? '#60A5FA' : '#64748B'}; font-weight: bold;">🛵 In Transit</span>
          <span style="color: ${modalSimStep >= 3 ? '#34D399' : '#64748B'};">${modalSimStep >= 3 ? '✓ Delivered' : '📍 Dropoff'}</span>
        </div>
      </div>

      <!-- Donor Stats Grid -->
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
        <div style="background: #1E293B; border-radius: 12px; padding: 12px;">
          <div style="font-size: 0.7rem; color: #94A3B8;">Meals Rescued</div>
          <div style="font-size: 1.25rem; font-weight: 800; color: #34D399;">184</div>
        </div>
        <div style="background: #1E293B; border-radius: 12px; padding: 12px;">
          <div style="font-size: 0.7rem; color: #94A3B8;">Karma Score</div>
          <div style="font-size: 1.25rem; font-weight: 800; color: #60A5FA;">4.9 ★</div>
        </div>
      </div>
    `;
  } else if (modalSimRole === 'ngo') {
    container.innerHTML = `
      <div style="font-weight: 800; font-size: 1.15rem; margin-bottom: 2px;">Helping Hands Foundation</div>
      <div style="font-size: 0.8rem; color: #94A3B8; margin-bottom: 14px;">NGO Shelter Console</div>

      <div style="background: linear-gradient(135deg, #107B65 0%, #064E3B 100%); border-radius: 14px; padding: 14px; margin-bottom: 14px;">
        <div style="font-size: 0.72rem; opacity: 0.85;">Shelter Capacity Requirement</div>
        <div style="font-size: 1.35rem; font-weight: 800; margin: 2px 0;">100 Meals Today</div>
        <div style="font-size: 0.75rem; opacity: 0.9;">1 Active Match En Route · Rider Vikram (R-201)</div>
      </div>

      <div style="background: #1E293B; border-radius: 12px; padding: 12px; border-left: 3px solid #10B981;">
        <div style="font-size: 0.72rem; color: #10B981; font-weight: bold;">INCOMING FOOD DELIVERY</div>
        <div style="font-weight: 700; font-size: 0.95rem;">${escapeHtml(activeFoodName)} (${escapeHtml(activeQuantity)})</div>
        <div style="font-size: 0.75rem; color: #94A3B8; margin-top: 2px;">Donor: Web Donor Portal · ETA 12 mins</div>
      </div>
    `;
  } else {
    container.innerHTML = `
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
        <div>
          <div style="font-weight: 800; font-size: 1.15rem;">Vikram S. (R-201)</div>
          <div style="font-size: 0.75rem; color: #94A3B8;">Volunteer Delivery Fleet</div>
        </div>
        <span style="font-size: 0.7rem; font-weight: 800; color: #10B981; background: rgba(16,185,129,0.15); padding: 4px 10px; border-radius: 9999px;">● ONLINE</span>
      </div>

      <!-- Mini Route Visualization -->
      <div style="background: #1E293B; border-radius: 14px; padding: 14px; margin-bottom: 12px;">
        <div style="font-size: 0.72rem; color: #F59E0B; font-weight: 700;">CURRENT RESCUE MISSION</div>
        <div style="font-weight: 800; font-size: 0.95rem; margin: 2px 0;">${escapeHtml(activeFoodName)}</div>
        <div style="font-size: 0.75rem; color: #CBD5E1;">Pickup: Web Donor Portal (1.2 km)</div>
        <div style="font-size: 0.75rem; color: #CBD5E1;">Dropoff: ${escapeHtml(activeDestination)} (3.4 km)</div>
        
        <div style="margin-top: 10px; padding-top: 8px; border-top: 1px solid rgba(255,255,255,0.08); display: flex; justify-content: space-between; font-size: 0.75rem;">
          <span>Security OTP: <b>Required</b></span>
          <span style="color: #60A5FA;">Demo Code: 4921</span>
        </div>
      </div>
    `;
  }
}

window.simulateActiveAction = function() {
  modalSimStep = (modalSimStep + 1) % 4;
  renderModalPhoneScreen();
  showToast('State Transition Applied', `Timeline step shifted to: ${modalSimStep === 3 ? 'Delivered' : modalSimStep === 2 ? 'In Transit' : modalSimStep === 1 ? 'Matched' : 'Posted'}`);
};

window.openProgramDetails = function(type) {
  const titles = {
    'anti-poverty': 'Anti-Poverty & Surplus Relief',
    'family': 'Family & Community Meal Support',
    'teen': 'Teen & Youth Volunteer Fleet'
  };
  alert(`📋 ${titles[type] || 'Program'}\n\nOur field coordinators distribute hot meals and nutritional support daily to families in need. Learn more by getting in touch or trying the mobile app.`);
};

window.setCategoryPillar = function(pillar, el) {
  document.querySelectorAll('.cat-nav-item').forEach(item => item.classList.remove('active'));
  if (el) el.classList.add('active');
};

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

function getCategoryIcon(cat) {
  if (!cat) return '🍲';
  const c = cat.toLowerCase();
  if (c.includes('cooked')) return '🍲';
  if (c.includes('raw') || c.includes('vegetable')) return '🥦';
  if (c.includes('bake') || c.includes('bread')) return '🥖';
  if (c.includes('pack')) return '📦';
  return '🥗';
}

function formatTimeAgo(isoString) {
  if (!isoString) return 'Just now';
  try {
    const diffMs = Date.now() - new Date(isoString).getTime();
    const diffSec = Math.floor(diffMs / 1000);
    if (diffSec < 60) return 'Just now';
    const diffMin = Math.floor(diffSec / 60);
    if (diffMin < 60) return `${diffMin}m ago`;
    const diffHour = Math.floor(diffMin / 60);
    if (diffHour < 24) return `${diffHour}h ago`;
    const diffDays = Math.floor(diffHour / 24);
    return `${diffDays}d ago`;
  } catch (e) {
    return 'Recently';
  }
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// ─────────────────────────────────────────────────────────────
// Fluid Scroll Reveal & Smooth Stats Count-Up
// ─────────────────────────────────────────────────────────────

function initScrollRevealAnimations() {
  const targets = document.querySelectorAll(
    '.program-card, .welcome-aid-box, .fundraiser-grid, .app-connect-bar, .section-title-center, .category-icon-nav'
  );

  targets.forEach(el => {
    el.classList.add('fade-up-init');
  });

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('fade-up-in');
        obs.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.12,
    rootMargin: '0px 0px -40px 0px'
  });

  targets.forEach(el => observer.observe(el));
}

function initCountUpStats() {
  const countElements = document.querySelectorAll('.fundraiser-meta-bar .count');
  if (!countElements.length) return;

  let hasAnimated = false;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && !hasAnimated) {
        hasAnimated = true;
        animateNumber(countElements[0], 0, 12840, 2000, '+');
        if (countElements[1]) {
          animateNumber(countElements[1], 0, 48, 1600, '');
        }
        observer.disconnect();
      }
    });
  }, { threshold: 0.3 });

  const container = document.querySelector('.fundraiser-meta-bar');
  if (container) observer.observe(container);
}

function animateNumber(element, start, end, duration, suffix = '') {
  let startTimestamp = null;
  const step = (timestamp) => {
    if (!startTimestamp) startTimestamp = timestamp;
    const progress = Math.min((timestamp - startTimestamp) / duration, 1);
    // Smooth easeOutExpo curve
    const ease = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
    const val = Math.floor(ease * (end - start) + start);
    element.textContent = val.toLocaleString() + suffix;
    if (progress < 1) {
      window.requestAnimationFrame(step);
    } else {
      element.textContent = end.toLocaleString() + suffix;
    }
  };
  window.requestAnimationFrame(step);
}

// ─────────────────────────────────────────────────────────────
// Interactive Leaflet Geospatial Rescue & Fleet Map
// ─────────────────────────────────────────────────────────────

let foodBridgeMap = null;
let mapMarkerObjects = [];
let mapTransitLine = null;

function initFoodBridgeMap() {
  const mapContainer = document.getElementById('leafletMap');
  if (!mapContainer || typeof L === 'undefined') {
    console.warn('[FoodBridge] Leaflet not loaded or container not found.');
    return;
  }

  // Initialize Leaflet Map centered on central Mumbai
  foodBridgeMap = L.map('leafletMap', {
    center: [19.0680, 72.8550],
    zoom: 13,
    scrollWheelZoom: false,
    zoomControl: true
  });

  // Clean OpenStreetMap Tile Layer (no watermark or API key required)
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19
  }).addTo(foodBridgeMap);

  // Plot custom pins
  renderMapMarkers('all');

  // Draw active transit route connecting The Harvest Kitchen -> Rider R-201 -> Helping Hands Foundation
  mapTransitLine = L.polyline([
    [19.0760, 72.8777],
    [19.0680, 72.8550],
    [19.0596, 72.8295]
  ], {
    color: '#E88A1A',
    weight: 4,
    dashArray: '8, 8',
    opacity: 0.9
  }).addTo(foodBridgeMap);
}

function renderMapMarkers(filterType = 'all') {
  if (!foodBridgeMap || typeof L === 'undefined') return;

  // Clear existing markers
  mapMarkerObjects.forEach(m => foodBridgeMap.removeLayer(m));
  mapMarkerObjects = [];

  const nodes = FoodBridgeData.mapNodes || [];
  const filtered = filterType === 'all' ? nodes : nodes.filter(n => n.type === filterType);

  filtered.forEach(node => {
    let pinClass = 'pin-donor';
    let iconChar = '🍲';
    let typeName = 'Surplus Food Donor';
    let tagColor = '#2563EB';

    if (node.type === 'ngo') {
      pinClass = 'pin-ngo';
      iconChar = '🏠';
      typeName = 'Partner Shelter / NGO';
      tagColor = '#10B981';
    } else if (node.type === 'rider') {
      pinClass = 'pin-rider';
      iconChar = '🛵';
      typeName = 'Active Volunteer Courier';
      tagColor = '#E88A1A';
    }

    const customIcon = L.divIcon({
      className: `custom-map-pin ${pinClass}`,
      html: iconChar,
      iconSize: [38, 38],
      iconAnchor: [19, 19],
      popupAnchor: [0, -19]
    });

    const popupHtml = `
      <div>
        <span class="popup-tag" style="background: ${tagColor}22; color: ${tagColor}; font-weight: 800;">${typeName}</span>
        <div class="popup-title">${escapeHtml(node.name)}</div>
        <div class="popup-desc" style="margin-top: 4px;"><b>Telemetry:</b> ${escapeHtml(node.label)}</div>
        <div class="popup-desc" style="color: #6B7280; font-size: 0.76rem; margin-top: 4px;">📍 ${escapeHtml(node.address || 'Mumbai')}</div>
        <button onclick="openAppSimulatorModal()" style="margin-top: 8px; width: 100%; padding: 6px; font-size: 0.72rem; font-weight: 700; background: var(--color-primary); color: #FFF; border-radius: 6px; cursor: pointer;">View in Mobile Console 📱</button>
      </div>
    `;

    const marker = L.marker([node.lat, node.lng], { icon: customIcon })
      .bindPopup(popupHtml)
      .addTo(foodBridgeMap);

    marker.nodeData = node;
    mapMarkerObjects.push(marker);
  });
}

window.filterMapNodes = function(type, btnEl) {
  document.querySelectorAll('.map-chip-btn').forEach(b => b.classList.remove('active'));
  if (btnEl) btnEl.classList.add('active');
  renderMapMarkers(type);
};

window.centerMapOnActiveMission = function() {
  if (!foodBridgeMap) return;
  // Recenter on Rider Vikram (R-201)
  foodBridgeMap.flyTo([19.0680, 72.8550], 15, {
    animate: true,
    duration: 1.2
  });

  // Find Rider marker and open popup
  setTimeout(() => {
    const riderMarker = mapMarkerObjects.find(m => m.nodeData && m.nodeData.id === 'm3');
    if (riderMarker) riderMarker.openPopup();
  }, 1200);
};
