/**
 * FoodBridge Data Layer & Supabase Realtime Cloud Sync
 * Synchronizes with the FoodBridge Flutter Mobile App & Supabase Cloud PostgreSQL
 */

const SUPABASE_URL = 'https://fmklzxrcifshlljkrurt.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZta2x6eHJjaWZzaGxsamtydXJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4NzQyMzksImV4cCI6MjEwNzQ1MDIzOX0.SVIcl10vLNd0WdsR6qhQgp4spwmV075PsbhTgkJ2Hz0';

// Initialize Supabase Client if library loaded
let supabaseClient = null;
if (window.supabase && typeof window.supabase.createClient === 'function') {
  try {
    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    console.log('[FoodBridge] Supabase client initialized successfully.');
  } catch (err) {
    console.warn('[FoodBridge] Error initializing Supabase client:', err);
  }
}

const FoodBridgeData = {
  stats: {
    mealsRescued: 12840,
    ngosCount: 48,
    activeRiders: 124,
    co2OffsetKg: 5420,
    activeMissions: 14
  },

  ngos: [
    {
      id: 'ngo-1',
      name: 'Helping Hands Foundation',
      category: 'Cooked Meals',
      distance: '3.4 km',
      peopleNeeded: 100,
      requiredBy: 'Before 7:00 PM',
      urgency: 'High',
      verified: true,
      address: 'Plot 42, Bandra West, Mumbai',
      rating: 4.9
    },
    {
      id: 'ngo-2',
      name: 'City Orphanage & Care',
      category: 'Raw Ingredients',
      distance: '5.1 km',
      peopleNeeded: 40,
      requiredBy: 'Tomorrow Morning',
      urgency: 'Normal',
      verified: true,
      address: '12 Linking Road, Khar, Mumbai',
      rating: 4.8
    },
    {
      id: 'ngo-3',
      name: 'Community Kitchen East',
      category: 'Packaged Food',
      distance: '8.2 km',
      peopleNeeded: 80,
      requiredBy: 'Anytime this week',
      urgency: 'Low',
      verified: true,
      address: 'Sector 5, Chembur, Mumbai',
      rating: 4.7
    },
    {
      id: 'ngo-4',
      name: 'Food for All Trust',
      category: 'Cooked Meals',
      distance: '2.8 km',
      peopleNeeded: 65,
      requiredBy: 'Within 2 hours',
      urgency: 'High',
      verified: true,
      address: 'Shivaji Park, Dadar, Mumbai',
      rating: 5.0
    }
  ],

  activeDonations: [],

  riderJobs: [
    {
      id: 'j-301',
      title: '50 Cooked Meal Packets',
      donorName: 'The Harvest Kitchen',
      pickupDistance: '1.2 km',
      dropDistance: '4.5 km',
      dropNgo: 'Helping Hands Foundation',
      estTime: '22 mins',
      payout: '₹180',
      urgent: true
    },
    {
      id: 'j-302',
      title: '20 kg Fresh Farm Produce',
      donorName: 'Green Valley Grocers',
      pickupDistance: '3.0 km',
      dropDistance: '2.1 km',
      dropNgo: 'City Orphanage',
      estTime: '18 mins',
      payout: '₹140',
      urgent: false
    }
  ],

  mapNodes: [
    { id: 'm1', type: 'donor', name: 'The Harvest Kitchen', lat: 19.0760, lng: 72.8777, label: '50 Meals Ready', category: 'Cooked Meals', address: 'Bandra Kurla Complex, Mumbai' },
    { id: 'm2', type: 'ngo', name: 'Helping Hands Foundation', lat: 19.0596, lng: 72.8295, label: '100 People Shelter', category: 'Community Kitchen', address: 'Plot 42, Bandra West, Mumbai' },
    { id: 'm3', type: 'rider', name: 'Rider Vikram S. (R-201)', lat: 19.0680, lng: 72.8550, label: 'En Route to Shelter (ETA 12m)', category: 'Active Courier', address: 'SV Road, Khar' },
    { id: 'm4', type: 'donor', name: 'Grand Horizon Banquet', lat: 19.0880, lng: 72.8420, label: '120 Servings Event Surplus', category: 'Banquet Surplus', address: 'Santacruz West, Mumbai' },
    { id: 'm5', type: 'ngo', name: 'City Orphanage & Care', lat: 19.0620, lng: 72.8380, label: '40 Children Care Home', category: 'Orphanage', address: '12 Linking Road, Khar' },
    { id: 'm6', type: 'rider', name: 'Rider Amit K. (R-108)', lat: 19.0720, lng: 72.8350, label: 'Pickup in 8 mins', category: 'Active Courier', address: 'Near Bandra Station' }
  ]
};

// ─────────────────────────────────────────────────────────────
// Supabase Data Operations
// ─────────────────────────────────────────────────────────────

/**
 * Fetch all live donations from Supabase Cloud ordered by newest first
 */
async function fetchLiveDonations() {
  try {
    if (supabaseClient) {
      const { data, error } = await supabaseClient
        .from('donations')
        .select('*')
        .order('posted_at', { ascending: false });

      if (error) throw error;
      if (data && Array.isArray(data)) {
        FoodBridgeData.activeDonations = data;
        return data;
      }
    } else {
      // Direct REST fallback
      const response = await fetch(`${SUPABASE_URL}/rest/v1/donations?select=*&order=posted_at.desc`, {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        FoodBridgeData.activeDonations = data;
        return data;
      }
    }
  } catch (err) {
    console.error('[FoodBridge] Error fetching donations from Supabase:', err);
  }
  return FoodBridgeData.activeDonations;
}

/**
 * Post a new donation directly to Supabase Cloud
 */
async function postDonation(donationPayload) {
  try {
    if (supabaseClient) {
      const { data, error } = await supabaseClient
        .from('donations')
        .insert([donationPayload])
        .select();

      if (error) throw error;
      return { success: true, data };
    } else {
      // Direct REST API fallback
      const response = await fetch(`${SUPABASE_URL}/rest/v1/donations`, {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=representation'
        },
        body: JSON.stringify(donationPayload)
      });
      if (response.ok) {
        const data = await response.json();
        return { success: true, data };
      }
      const errText = await response.text();
      throw new Error(errText);
    }
  } catch (err) {
    console.error('[FoodBridge] Failed to post donation to Supabase:', err);
    return { success: false, error: err };
  }
}

/**
 * Subscribe to Supabase Realtime postgres_changes on table 'donations'
 */
function initRealtimeSubscription(onEventCallback) {
  if (!supabaseClient) {
    console.warn('[FoodBridge] Supabase client not available for Realtime subscription.');
    return null;
  }

  try {
    const channel = supabaseClient
      .channel('public:donations')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'donations' },
        (payload) => {
          console.log('[FoodBridge Realtime] Donation change event received:', payload);
          if (typeof onEventCallback === 'function') {
            onEventCallback(payload);
          }
        }
      )
      .subscribe((status) => {
        console.log('[FoodBridge Realtime] Channel status:', status);
        const statusEl = document.getElementById('liveSyncStatusText');
        const pulseEl = document.querySelector('.supabase-pulse');
        if (status === 'SUBSCRIBED') {
          if (statusEl) statusEl.textContent = 'Supabase Cloud Live (Realtime Connected)';
          if (pulseEl) pulseEl.style.backgroundColor = '#10B981';
        } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
          if (statusEl) statusEl.textContent = 'Supabase Cloud (REST Sync Mode)';
          if (pulseEl) pulseEl.style.backgroundColor = '#F59E0B';
        }
      });

    return channel;
  } catch (err) {
    console.warn('[FoodBridge] Realtime subscription init error:', err);
    return null;
  }
}
