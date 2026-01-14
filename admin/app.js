/**
 * Vrindopnishad Admin Panel - JavaScript
 * Modern Supabase-powered CMS
 */

// ========================================
// Supabase Configuration
// ========================================

const SUPABASE_URL = 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_0YiM-Q8itRORUDdToracaQ_vzcrjUlC';

// Use shared auth logic if possible, or initialize local client
if (typeof supabase === 'undefined') {
    console.warn('Supabase not loaded');
} else {
    window.supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}
const supabaseClient = window.supabaseClient;

// ========================================
// State
// ========================================

let currentUser = null;
let allContent = [];
let categories = ['Shloka', 'Strotra', 'Mantra', 'Bhajan', 'Katha', 'Aarti', 'Chalisa'];
let importData = [];

// SECURITY: Only these emails can access the admin panel
const AUTHORIZED_ADMINS = [
    'admin@vrindopnishad.com',  // Main Owner
    'mdark4025@gmail.com',
    // Add other authorized emails here
];

// ========================================
// DOM Elements
// ========================================

const elements = {
    loginModal: document.getElementById('login-modal'),
    loginForm: document.getElementById('login-form'),
    logoutBtn: document.getElementById('logout-btn'),
    userName: document.getElementById('user-name'),
    navItems: document.querySelectorAll('.nav-item'),
    tabContents: document.querySelectorAll('.tab-content'),
    pageTitle: document.getElementById('page-title'),
    breadcrumbCurrent: document.getElementById('breadcrumb-current'),
    addContentForm: document.getElementById('add-content-form'),
    editModal: document.getElementById('edit-modal'),
    editContentForm: document.getElementById('edit-content-form'),
    closeModalBtn: document.getElementById('close-modal'),
    cancelEditBtn: document.getElementById('cancel-edit'),
    contentGrid: document.getElementById('content-grid'),
    recentContent: document.getElementById('recent-content'),
    filterCategory: document.getElementById('filter-category'),
    filterSearch: document.getElementById('filter-search'),
    importPreview: document.getElementById('import-preview'),
    previewBody: document.getElementById('preview-body'),
    previewCount: document.getElementById('preview-count'),
    confirmImport: document.getElementById('confirm-import'),
    cancelImport: document.getElementById('cancel-import'),
    csvImport: document.getElementById('csv-import'),
    jsonImport: document.getElementById('json-import'),
    csvFile: document.getElementById('csv-file'),
    jsonFile: document.getElementById('json-file'),
    imageDropZone: document.getElementById('image-drop-zone'),
    audioDropZone: document.getElementById('audio-drop-zone'),
    imageUpload: document.getElementById('image-upload'),
    audioUpload: document.getElementById('audio-upload'),
    clearFormBtn: document.getElementById('clear-form-btn'),
    toastContainer: document.getElementById('toast-container'),
    totalContent: document.getElementById('total-content'),
    totalCategories: document.getElementById('total-categories'),
    totalViews: document.getElementById('total-views'),
    totalFavorites: document.getElementById('total-favorites'),
    categoryList: document.getElementById('category-list'),
};

// ========================================
// Initialization
// ========================================

document.addEventListener('DOMContentLoaded', async () => {
    await checkAuth();
    setupEventListeners();
    setupDragAndDrop();
    setupPreview();

    // Default to shloka mode
    setEntryMode('shloka');

    // Re-initialize Lucide icons after dynamic content
    if (window.lucide) {
        lucide.createIcons();
    }
});

async function checkAuth() {
    const { data: { session } } = await supabaseClient.auth.getSession();

    if (session) {
        // Strict Whitelist Check
        if (AUTHORIZED_ADMINS.length > 0 && !AUTHORIZED_ADMINS.includes(session.user.email)) {
            showToast('Access Denied: Unrecognized Admin Email', 'error');
            await handleLogout();
            return;
        }

        currentUser = session.user;

        // Unlock the UI
        const appContainer = document.querySelector('.app');
        if (appContainer) appContainer.classList.remove('app-locked');

        elements.loginModal.classList.add('hidden');
        elements.userName.textContent = session.user.email?.split('@')[0] || 'Admin';
        await loadDashboard();
    } else {
        // Keep locked
        const appContainer = document.querySelector('.app');
        if (appContainer) appContainer.classList.add('app-locked');
        elements.loginModal.classList.remove('hidden');
    }
}

// ========================================
// Event Listeners
// ========================================

function setupEventListeners() {
    // Login
    elements.loginForm.addEventListener('submit', handleLogin);
    elements.logoutBtn.addEventListener('click', handleLogout);
    document.getElementById('google-login-btn')?.addEventListener('click', handleGoogleLogin);

    // Navigation
    elements.navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            switchTab(item.dataset.tab);
        });
    });

    // Add Content Form
    elements.addContentForm?.addEventListener('submit', handleAddContent);
    elements.clearFormBtn?.addEventListener('click', () => elements.addContentForm.reset());

    // Edit Modal
    elements.closeModalBtn?.addEventListener('click', closeEditModal);
    elements.cancelEditBtn?.addEventListener('click', closeEditModal);
    elements.editContentForm?.addEventListener('submit', handleEditContent);

    // Close modal on overlay click
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', () => {
            elements.editModal?.classList.add('hidden');
        });
    });

    // Filters
    elements.filterCategory?.addEventListener('change', filterContent);
    elements.filterSearch?.addEventListener('input', debounce(filterContent, 300));

    // Import
    elements.csvImport?.addEventListener('click', () => elements.csvFile.click());
    elements.jsonImport?.addEventListener('click', () => elements.jsonFile.click());
    elements.csvFile?.addEventListener('change', handleCSVUpload);
    elements.jsonFile?.addEventListener('change', handleJSONUpload);
    elements.confirmImport?.addEventListener('click', confirmImport);
    elements.cancelImport?.addEventListener('click', cancelImportPreview);

    // Template downloads
    document.getElementById('download-csv-template')?.addEventListener('click', downloadCSVTemplate);
    document.getElementById('download-json-template')?.addEventListener('click', downloadJSONTemplate);

    // Mobile menu
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.getElementById('sidebar-overlay');

    const toggleSidebar = () => {
        sidebar.classList.toggle('open');
        overlay.classList.toggle('active');
    };

    const closeSidebar = () => {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
    };

    document.getElementById('mobile-menu-btn')?.addEventListener('click', toggleSidebar);
    document.getElementById('sidebar-close-btn')?.addEventListener('click', closeSidebar);
    overlay?.addEventListener('click', closeSidebar);

    // Close sidebar when clicking nav items on mobile
    elements.navItems.forEach(item => {
        item.addEventListener('click', () => {
            if (window.innerWidth <= 768) {
                closeSidebar();
            }
        });
    });
}

function setupDragAndDrop() {
    if (elements.imageDropZone && elements.imageUpload) {
        setupDropZone(elements.imageDropZone, elements.imageUpload);
    }
    if (elements.audioDropZone && elements.audioUpload) {
        setupDropZone(elements.audioDropZone, elements.audioUpload);
    }
}

function setupDropZone(zone, input) {
    zone.addEventListener('click', () => input.click());

    zone.addEventListener('dragover', (e) => {
        e.preventDefault();
        zone.classList.add('dragover');
    });

    zone.addEventListener('dragleave', () => {
        zone.classList.remove('dragover');
    });

    zone.addEventListener('drop', (e) => {
        e.preventDefault();
        zone.classList.remove('dragover');
        const files = e.dataTransfer.files;
        if (files.length) {
            input.files = files;
            zone.querySelector('p').textContent = files[0].name;
        }
    });

    input.addEventListener('change', () => {
        if (input.files.length) {
            zone.querySelector('p').textContent = input.files[0].name;
            // Update preview if image
            if (bucket === 'images') {
                const reader = new FileReader();
                reader.onload = (e) => {
                    const preview = document.getElementById('live-preview');
                    if (preview) {
                        const img = document.createElement('img');
                        img.src = e.target.result;
                        img.style.maxWidth = '100%';
                        img.style.borderRadius = '8px';
                        img.style.marginTop = '10px';
                        // Remove old image preview
                        const oldImg = preview.querySelector('img');
                        if (oldImg) oldImg.remove();
                        preview.appendChild(img);
                    }
                };
                reader.readAsDataURL(input.files[0]);
            }
        }
    });
}

function setupPreview() {
    const previewInputs = [
        'title', 'sanskrit-text', 'hindi-meaning', 'translation', 'commentary', 'content-text'
    ];

    previewInputs.forEach(id => {
        const input = document.getElementById(id);
        if (input) {
            input.addEventListener('input', updateLivePreview);
        }
    });

    // Also watch for external image URL changes
    document.getElementById('image-url')?.addEventListener('input', updateLivePreview);
}

function updateLivePreview() {
    const preview = {
        title: document.getElementById('title')?.value || 'Title Preview',
        sanskrit: document.getElementById('sanskrit-text')?.value || '',
        content: document.getElementById('content-text')?.value || document.getElementById('commentary')?.value || 'Content will appear here...',
        image: document.getElementById('image-url')?.value || ''
    };

    const container = document.getElementById('live-preview');
    if (!container) return;

    container.querySelector('.preview-title').textContent = preview.title;

    const sanskritEl = container.querySelector('.preview-sanskrit');
    if (preview.sanskrit) {
        sanskritEl.textContent = preview.sanskrit;
        sanskritEl.style.display = 'block';
    } else {
        sanskritEl.style.display = 'none';
    }

    container.querySelector('.preview-content').textContent = preview.content;

    // Handle External Image Preview
    if (preview.image) {
        let img = container.querySelector('img');
        if (!img) {
            img = document.createElement('img');
            img.style.maxWidth = '100%';
            img.style.borderRadius = '8px';
            img.style.marginTop = '10px';
            container.appendChild(img);
        }
        img.src = preview.image;
    }
}

function setEntryMode(mode) {
    const form = document.getElementById('add-content-form');
    const buttons = document.querySelectorAll('.form-mode-selector button');

    if (!form) return;

    buttons.forEach(btn => {
        const isActive = btn.textContent.toLowerCase().includes(mode);
        btn.classList.toggle('active', isActive);
    });

    if (mode === 'shloka') {
        form.classList.add('mode-shloka');
        form.classList.remove('mode-general');
    } else {
        form.classList.add('mode-general');
        form.classList.remove('mode-shloka');
    }
}

window.setEntryMode = setEntryMode;

// ========================================
// Authentication
// ========================================

async function handleLogin(e) {
    e.preventDefault();

    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;

    try {
        const { data, error } = await supabaseClient.auth.signInWithPassword({
            email,
            password
        });

        if (error) throw error;

        currentUser = data.user;
        elements.loginModal.classList.add('hidden');
        elements.userName.textContent = data.user.email?.split('@')[0] || 'Admin';
        showToast('Welcome back!', 'success');
        await loadDashboard();
    } catch (error) {
        showToast(error.message, 'error');
    }
}

async function handleLogout() {
    await supabaseClient.auth.signOut();
    currentUser = null;

    // Relock UI
    const appContainer = document.querySelector('.app');
    if (appContainer) appContainer.classList.add('app-locked');

    elements.loginModal.classList.remove('hidden');
    showToast('Logged out', 'success');
}

async function handleGoogleLogin() {
    try {
        const { error } = await supabaseClient.auth.signInWithOAuth({
            provider: 'google',
            options: {
                redirectTo: window.location.origin + window.location.pathname
            }
        });

        if (error) throw error;
    } catch (error) {
        console.error('Google login error:', error);
        showToast(error.message || 'Failed to sign in with Google', 'error');
    }
}

// ========================================
// Navigation
// ========================================

function switchTab(tabId) {
    // Update nav items
    elements.navItems.forEach(item => {
        item.classList.toggle('active', item.dataset.tab === tabId);
    });

    // Update tab content
    elements.tabContents.forEach(tab => {
        tab.classList.toggle('active', tab.id === `${tabId}-tab`);
    });

    // Update page title
    const titles = {
        'dashboard': ['Dashboard', 'Overview'],
        'add-content': ['Add Content', 'Content'],
        'bulk-import': ['Bulk Import', 'Content'],
        'manage': ['All Content', 'Library'],
        'categories': ['Categories', 'Settings']
    };

    const [title, breadcrumb] = titles[tabId] || ['Dashboard', 'Overview'];
    elements.pageTitle.textContent = title;
    elements.breadcrumbCurrent.textContent = breadcrumb;

    // Load data for specific tabs
    if (tabId === 'manage') {
        loadContentGrid();
    } else if (tabId === 'categories') {
        loadCategories();
    }

    // Re-init icons
    if (window.lucide) {
        setTimeout(() => lucide.createIcons(), 50);
    }
}

// Make switchTab globally available
window.switchTab = switchTab;

// ========================================
// Dashboard
// ========================================

async function loadDashboard() {
    try {
        const { data: content, error } = await supabaseClient
            .from('content')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        allContent = content || [];

        // Update stats with animation
        animateValue(elements.totalContent, allContent.length);
        animateValue(elements.totalCategories, new Set(allContent.map(c => c.category)).size);
        animateValue(elements.totalViews, allContent.reduce((sum, c) => sum + (c.view_count || 0), 0));

        // Render recent content
        renderRecentContent(allContent.slice(0, 5));

        // Populate filter categories
        populateFilterCategories();

    } catch (error) {
        console.error('Error loading dashboard:', error);
        showToast('Error loading content', 'error');
    }
}

function animateValue(element, target) {
    if (!element) return;
    const duration = 500;
    const start = parseInt(element.textContent) || 0;
    const range = target - start;
    const startTime = performance.now();

    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        element.textContent = Math.round(start + range * eased);

        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }

    requestAnimationFrame(update);
}

function renderRecentContent(items) {
    if (!elements.recentContent) return;

    if (items.length === 0) {
        elements.recentContent.innerHTML = `
            <div class="empty-state">
                <i data-lucide="inbox"></i>
                <p>No content yet</p>
            </div>
        `;
    } else {
        elements.recentContent.innerHTML = items.map(item => `
            <div class="content-list-item">
                <div>
                    <div class="content-list-item-title">${item.title}</div>
                    <div class="content-list-item-meta">
                        <span class="content-card-category">${item.category}</span>
                        <span>${formatDate(item.created_at)}</span>
                    </div>
                </div>
            </div>
        `).join('');
    }

    if (window.lucide) lucide.createIcons();
}

function formatDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diff = now - date;

    if (diff < 60000) return 'Just now';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;

    return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
}

function populateFilterCategories() {
    if (!elements.filterCategory) return;

    const uniqueCategories = [...new Set(allContent.map(c => c.category))];
    elements.filterCategory.innerHTML = '<option value="">All Categories</option>' +
        uniqueCategories.map(cat => `<option value="${cat}">${cat}</option>`).join('');
}

// ========================================
// Add Content
// ========================================

async function handleAddContent(e) {
    e.preventDefault();

    const formData = new FormData(e.target);
    const content = {
        title: formData.get('title'),
        category: formData.get('category'),
        sanskrit_text: formData.get('sanskritText'),
        hindi_text: formData.get('hindiMeaning'),
        english_translation: formData.get('translation'),
        description: formData.get('commentary'),
        content_text: formData.get('contentText'),
        author: formData.get('author'),
        status: formData.get('status'),
        tags: formData.get('tags') ? formData.get('tags').split(',').map(t => t.trim()).filter(t => t) : [],
        image_url: formData.get('imageUrl') || null,
        audio_url: formData.get('audioUrl') || null
    };

    try {
        const { data, error } = await supabaseClient
            .from('content')
            .insert([content])
            .select()
            .single();

        if (error) throw error;

        // Handle file uploads
        const imageFile = elements.imageUpload?.files[0];
        const audioFile = elements.audioUpload?.files[0];

        if (imageFile) await uploadFile(data.id, imageFile, 'images');
        if (audioFile) await uploadFile(data.id, audioFile, 'audio');

        showToast('Content published successfully!', 'success');
        e.target.reset();

        // Reset file upload zones
        if (elements.imageDropZone) {
            elements.imageDropZone.querySelector('p').textContent = 'Drop image here';
        }
        if (elements.audioDropZone) {
            elements.audioDropZone.querySelector('p').textContent = 'Drop audio here';
        }

        await loadDashboard();

    } catch (error) {
        console.error('Error adding content:', error);
        showToast(error.message, 'error');
    }
}

async function uploadFile(contentId, file, bucket) {
    const fileExt = file.name.split('.').pop();
    const fileName = `${contentId}.${fileExt}`;

    const { error } = await supabaseClient.storage
        .from(bucket)
        .upload(fileName, file, { upsert: true });

    if (error) {
        console.error('Upload error:', error);
        return null;
    }

    const { data: urlData } = supabaseClient.storage.from(bucket).getPublicUrl(fileName);

    const updateField = bucket === 'images' ? 'image_url' : 'audio_url';
    await supabaseClient
        .from('content')
        .update({ [updateField]: urlData.publicUrl })
        .eq('id', contentId);

    return urlData.publicUrl;
}

// ========================================
// Manage Content
// ========================================

function loadContentGrid() {
    renderContentGrid(allContent);
}

function renderContentGrid(items) {
    if (!elements.contentGrid) return;

    if (items.length === 0) {
        elements.contentGrid.innerHTML = `
            <div class="empty-state-large">
                <i data-lucide="inbox"></i>
                <h4>No content found</h4>
                <p>Start by adding your first piece of sacred content</p>
                <button class="btn btn-primary" onclick="switchTab('add-content')">
                    <i data-lucide="plus"></i>
                    Add Content
                </button>
            </div>
        `;
    } else {
        elements.contentGrid.innerHTML = items.map(item => `
            <div class="content-card" data-id="${item.id}">
                <div class="content-card-header">
                    <div class="content-card-title">${item.title}</div>
                    <span class="content-card-category">${item.category}</span>
                </div>
                <div class="content-card-sanskrit">${item.sanskrit_text || '—'}</div>
                <div class="content-card-actions">
                    <button class="btn btn-secondary" onclick="openEditModal('${item.id}')">
                        <i data-lucide="edit-2"></i>
                        Edit
                    </button>
                    <button class="btn btn-danger" onclick="deleteContent('${item.id}')">
                        <i data-lucide="trash-2"></i>
                        Delete
                    </button>
                </div>
            </div>
        `).join('');
    }

    if (window.lucide) lucide.createIcons();
}

function filterContent() {
    const category = elements.filterCategory?.value || '';
    const search = (elements.filterSearch?.value || '').toLowerCase();

    let filtered = allContent;

    if (category) {
        filtered = filtered.filter(c => c.category === category);
    }

    if (search) {
        filtered = filtered.filter(c =>
            c.title.toLowerCase().includes(search) ||
            (c.sanskrit_text && c.sanskrit_text.toLowerCase().includes(search))
        );
    }

    renderContentGrid(filtered);
}

// ========================================
// Edit Content
// ========================================

function openEditModal(id) {
    const content = allContent.find(c => c.id === id);
    if (!content) return;

    document.getElementById('edit-id').value = content.id;
    document.getElementById('edit-title').value = content.title;
    document.getElementById('edit-category').value = content.category;
    document.getElementById('edit-sanskrit').value = content.sanskrit_text || '';
    document.getElementById('edit-hindi').value = content.hindi_text || '';
    document.getElementById('edit-translation').value = content.english_translation || '';
    document.getElementById('edit-commentary').value = content.description || '';
    document.getElementById('edit-author').value = content.author || '';
    document.getElementById('edit-status').value = content.status || 'published';
    document.getElementById('edit-tags').value = content.tags ? content.tags.join(', ') : '';
    document.getElementById('edit-content-text').value = content.content_text || '';
    document.getElementById('edit-image-url').value = content.image_url || '';
    document.getElementById('edit-audio-url').value = content.audio_url || '';

    elements.editModal.classList.remove('hidden');
    if (window.lucide) lucide.createIcons();
}

window.openEditModal = openEditModal;

function closeEditModal() {
    elements.editModal?.classList.add('hidden');
}

async function handleEditContent(e) {
    e.preventDefault();

    const id = document.getElementById('edit-id').value;
    const updates = {
        title: document.getElementById('edit-title').value,
        category: document.getElementById('edit-category').value,
        sanskrit_text: document.getElementById('edit-sanskrit').value,
        hindi_text: document.getElementById('edit-hindi').value,
        english_translation: document.getElementById('edit-translation').value,
        description: document.getElementById('edit-commentary').value,
        author: document.getElementById('edit-author').value,
        status: document.getElementById('edit-status').value,
        tags: document.getElementById('edit-tags').value ? document.getElementById('edit-tags').value.split(',').map(t => t.trim()).filter(t => t) : [],
        content_text: document.getElementById('edit-content-text').value,
        image_url: document.getElementById('edit-image-url').value || null,
        audio_url: document.getElementById('edit-audio-url').value || null,
    };

    try {
        const { error } = await supabaseClient
            .from('content')
            .update(updates)
            .eq('id', id);

        if (error) throw error;

        showToast('Content updated!', 'success');
        closeEditModal();
        await loadDashboard();
        loadContentGrid();

    } catch (error) {
        showToast(error.message, 'error');
    }
}

async function deleteContent(id) {
    if (!confirm('Are you sure you want to delete this content?')) return;

    try {
        const { error } = await supabaseClient
            .from('content')
            .delete()
            .eq('id', id);

        if (error) throw error;

        showToast('Content deleted', 'success');
        await loadDashboard();
        loadContentGrid();

    } catch (error) {
        showToast(error.message, 'error');
    }
}

window.deleteContent = deleteContent;

// ========================================
// Bulk Import
// ========================================

function handleCSVUpload(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
        const csv = e.target.result;
        const lines = csv.split('\n');
        const headers = lines[0].split(',').map(h => h.trim());

        importData = lines.slice(1).filter(line => line.trim()).map(line => {
            const values = line.split(',');
            const obj = {};
            headers.forEach((header, i) => {
                obj[header] = values[i]?.trim() || '';
            });
            return obj;
        });

        showImportPreview();
    };
    reader.readAsText(file);
}

function handleJSONUpload(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
        try {
            importData = JSON.parse(e.target.result);
            if (!Array.isArray(importData)) {
                importData = [importData];
            }
            showImportPreview();
        } catch (error) {
            showToast('Invalid JSON format', 'error');
        }
    };
    reader.readAsText(file);
}

function showImportPreview() {
    if (!elements.importPreview) return;

    elements.previewCount.textContent = importData.length;
    elements.previewBody.innerHTML = importData.map(item => `
        <tr>
            <td>${item.title || item.Title || '—'}</td>
            <td>${item.category || item.Category || '—'}</td>
            <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                ${item.sanskritText || item.sanskrit_text || '—'}
            </td>
            <td><span style="color: var(--green);">Ready</span></td>
        </tr>
    `).join('');

    elements.importPreview.classList.remove('hidden');
}

function cancelImportPreview() {
    elements.importPreview?.classList.add('hidden');
    importData = [];
    if (elements.csvFile) elements.csvFile.value = '';
    if (elements.jsonFile) elements.jsonFile.value = '';
}

async function confirmImport() {
    if (!importData.length) return;

    try {
        const contentToInsert = importData.map(item => ({
            title: item.title || item.Title,
            category: item.category || item.Category,
            sanskrit_text: item.sanskritText || item.sanskrit_text,
            hindi_text: item.hindiMeaning || item.hindi_text,
            english_translation: item.translation || item.english_translation,
            description: item.commentary || item.description,
            author: item.author || item.Author || '',
            status: item.status || item.Status || 'published',
            tags: item.tags ? (Array.isArray(item.tags) ? item.tags : item.tags.split(',').map(t => t.trim())) : [],
            content_text: item.content_text || item.contentText || '',
        }));

        const { error } = await supabaseClient
            .from('content')
            .insert(contentToInsert);

        if (error) throw error;

        showToast(`Imported ${importData.length} items!`, 'success');
        cancelImportPreview();
        await loadDashboard();

    } catch (error) {
        showToast(error.message, 'error');
    }
}

function downloadCSVTemplate() {
    const headers = 'title,category,sanskritText,hindiMeaning,translation,commentary';
    const example = 'Bhagavad Gita 2.47,Shloka,कर्मण्येवाधिकारस्ते...,तेरा कर्म करने में...,You have the right...,This is a key verse...';
    downloadFile(`${headers}\n${example}`, 'content-template.csv', 'text/csv');
}

function downloadJSONTemplate() {
    const template = [{
        title: 'Bhagavad Gita 2.47',
        category: 'Shloka',
        sanskritText: 'कर्मण्येवाधिकारस्ते...',
        hindiMeaning: 'तेरा कर्म करने में...',
        translation: 'You have the right...',
        commentary: 'This is a key verse...'
    }];
    downloadFile(JSON.stringify(template, null, 2), 'content-template.json', 'application/json');
}

function downloadFile(content, filename, type) {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
}

// Backup function
function downloadBackup() {
    if (allContent.length === 0) {
        showToast('No content to backup', 'warning');
        return;
    }
    downloadFile(JSON.stringify(allContent, null, 2), 'vrindopnishad-backup.json', 'application/json');
    showToast('Backup downloaded!', 'success');
}

window.downloadBackup = downloadBackup;

// ========================================
// Categories
// ========================================

function loadCategories() {
    if (!elements.categoryList) return;

    elements.categoryList.innerHTML = categories.map(cat => `
        <div class="category-tag">
            <i data-lucide="tag"></i>
            <span>${cat}</span>
        </div>
    `).join('');

    if (window.lucide) lucide.createIcons();
}

// ========================================
// Toast Notifications
// ========================================

function showToast(message, type = 'info') {
    const icons = {
        success: 'check-circle',
        error: 'x-circle',
        warning: 'alert-triangle',
        info: 'info'
    };

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <i data-lucide="${icons[type]}"></i>
        <span>${message}</span>
    `;

    elements.toastContainer?.appendChild(toast);
    if (window.lucide) lucide.createIcons();

    setTimeout(() => {
        toast.style.animation = 'toastSlide 0.3s reverse forwards';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

// ========================================
// Utilities
// ========================================

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}
