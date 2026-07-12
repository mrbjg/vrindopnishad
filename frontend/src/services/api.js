import { mockApiService } from './mockData';
import { auth, db, contentDb, dataConnect } from '../firebase';
import { getContentById as getDcContentById, getContentBySlug as getDcContentBySlug } from '../lib/dataconnect';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  onAuthStateChanged,
  signOut,
  sendPasswordResetEmail
} from 'firebase/auth';
import {
  collection,
  doc,
  getDocs,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  limit
} from 'firebase/firestore';
import { ref, get, child, set as dbSet, update as dbUpdate, remove as dbRemove, query as rtdbQuery, orderByChild, startAt } from 'firebase/database';
import { supabase } from '../lib/supabase';
import { transliterate } from '../utils/transliterate';
import { normalizeForFuzzy } from '../utils/hinglishSearch';

const DB_PROVIDER = process.env.REACT_APP_DATABASE_PROVIDER || 'firebase';


const USE_MOCK = process.env.REACT_APP_DEMO_MODE === 'true';
const CACHE_PREFIX = 'sv_cache_';
const CACHE_EXPIRY = 30 * 60 * 1000;


let memoryCachedItems = null;
let memoryLastUpdated = '1970-01-01T00:00:00.000Z';
let memoryCategoryCache = {};
let lastSyncTime = 0;

if (typeof window !== 'undefined') {
  const CURRENT_CACHE_VERSION = 'v4';
  const storedVersion = localStorage.getItem('vrindopnishad_cache_version');
  if (storedVersion !== CURRENT_CACHE_VERSION) {
    console.log(`[Cache-Reset] Version mismatch (stored: "${storedVersion}", current: "${CURRENT_CACHE_VERSION}"). Resetting LocalStorage cache...`);
    const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
    categories.forEach(cat => {
      localStorage.removeItem(`vrindopnishad_cache_${cat}`);
      localStorage.removeItem(`vrindopnishad_last_updated_${cat}`);
    });
    localStorage.removeItem('vrindopnishad_relations_cache');
    localStorage.setItem('vrindopnishad_cache_version', CURRENT_CACHE_VERSION);
  }
}

const contentMapById = new Map();
const contentMapBySlug = new Map();

const rebuildMemoryMaps = () => {
  const mergedItems = [];
  const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];

  categories.forEach(cat => {
    const catItems = memoryCategoryCache[cat];
    if (catItems && Array.isArray(catItems)) {
      mergedItems.push(...catItems);
    }
  });

  memoryCachedItems = ensureSorted(mergedItems);

  contentMapById.clear();
  contentMapBySlug.clear();

  memoryCachedItems.forEach(item => {
    if (!item) return;

    if (!item.category) {
      item.category = classifyItemCategory(item);
    }

    if (!item.slug || item.slug.startsWith('untitled')) {
      const titleSlug = generateSlug(item.title);
      if (titleSlug) {
        item.slug = titleSlug;
      }
    }

    if (item.id) {
      contentMapById.set(item.id.toString(), item);
    }
    if (item.slug) {
      contentMapBySlug.set(item.slug, item);
      contentMapBySlug.set(decodeURIComponent(item.slug), item);
    }
  });

  // Background Search Index Warming
  if (typeof window !== 'undefined') {
    const processQueue = (startIndex = 0) => {
      if (!memoryCachedItems) return;
      const batchSize = 30; // Keep frame times under 5ms to prevent UI stutters
      const endIndex = Math.min(startIndex + batchSize, memoryCachedItems.length);
      for (let i = startIndex; i < endIndex; i++) {
        const item = memoryCachedItems[i];
        if (item && !item._textHinglish) {
          try {
            const sansFirstLine = item.sanskrit_text ? item.sanskrit_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';
            const hindiFirstLine = item.hindi_text ? item.hindi_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';

            item._textDevanagari = [
              item.title,
              item.name,
              item.hindi_text,
              item.sanskrit_text,
              item.author,
              item.description,
              item.category,
              sansFirstLine,
              hindiFirstLine
            ].filter(Boolean).join(' ').toLowerCase();

            item._textHinglish = [
              item.hinglishName,
              transliterate(item.title || ''),
              transliterate(item.name || ''),
              transliterate(item.author || ''),
              transliterate(item.description || ''),
              transliterate(sansFirstLine),
              transliterate(hindiFirstLine),
              item.english_translation,
              item.english_text,
              item.slug,
              ...(item.tags || [])
            ].filter(Boolean).join(' ').toLowerCase();

            item._normalizedHinglish = normalizeForFuzzy(item._textHinglish);
          } catch (e) {
            console.error('Error precomputing search index:', e);
          }
        }
      }
      if (endIndex < memoryCachedItems.length) {
        const scheduler = window.requestIdleCallback || ((cb) => setTimeout(cb, 25));
        scheduler(() => processQueue(endIndex));
      }
    };

    // Defer start of warming slightly to let UI rendering complete
    setTimeout(() => processQueue(0), 150);
  }
};

const updateMemoryCache = (items) => {
  if (!items) return;
  // Backward compatibility helper
  const grouped = {};
  items.forEach(item => {
    const cat = classifyItemCategory(item);
    if (!grouped[cat]) grouped[cat] = [];
    grouped[cat].push(item);
  });
  Object.entries(grouped).forEach(([cat, catItems]) => {
    memoryCategoryCache[cat] = ensureSorted(catItems);
  });
  rebuildMemoryMaps();
};

const ensureSorted = (items) => {
  if (!items || !Array.isArray(items)) return [];
  items.forEach(item => {
    if (item && !item._created_time) {
      item._created_time = item.created_at ? new Date(item.created_at).getTime() : 0;
    }
  });
  return items.sort((a, b) => b._created_time - a._created_time);
};

if (typeof window !== 'undefined') {
  window.addEventListener('storage', (e) => {
    if (e.key && e.key.startsWith('vrindopnishad_cache_')) {
      const category = e.key.replace('vrindopnishad_cache_', '');
      try {
        const parsed = e.newValue ? ensureSorted(JSON.parse(e.newValue)) : null;
        if (parsed) {
          memoryCategoryCache[category] = parsed;
        } else {
          delete memoryCategoryCache[category];
        }
        rebuildMemoryMaps();
      } catch (err) {
        console.warn('Failed to parse segmented storage update:', err);
      }
    }
  });
}


const generateSlug = (text) => {
  if (!text) return '';
  const transliterated = transliterate(text);
  return transliterated
    .toString()
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/--+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '');
};

const normalizeFuzzyText = (text) => {
  if (!text) return '';
  return text.toLowerCase()
    .replace(/[^a-z0-9]/g, '')
    .replace(/aa/g, 'a')
    .replace(/ee/g, 'i')
    .replace(/oo/g, 'u')
    .replace(/w/g, 'v')
    .replace(/th/g, 't')
    .replace(/dh/g, 'd')
    .replace(/bh/g, 'b')
    .replace(/sh/g, 's')
    .replace(/kh/g, 'k')
    .replace(/gh/g, 'g')
    .replace(/jh/g, 'j')
    .replace(/ph/g, 'p')
    .replace(/ch/g, 'c');
};

const setCache = (key, data) => {
  try {
    localStorage.setItem(CACHE_PREFIX + key, JSON.stringify({
      timestamp: Date.now(),
      data: data
    }));
  } catch (e) { }
};

const getCache = (key) => {
  try {
    const cached = localStorage.getItem(CACHE_PREFIX + key);
    if (!cached) return null;
    const { timestamp, data } = JSON.parse(cached);
    if (Date.now() - timestamp > CACHE_EXPIRY) {
      localStorage.removeItem(CACHE_PREFIX + key);
      return null;
    }
    return data;
  } catch (e) { return null; }
};


function classifyItemCategory(item) {
  if (!item) return 'poem';
  const rawCat = (item.category || '').toLowerCase().trim();

  if (rawCat === 'saint' || rawCat === 'dham') {
    return rawCat;
  }

  if (rawCat === 'strotra' || rawCat === 'strotras' || rawCat === 'stotra' || rawCat === 'stotras') {
    return 'strotra';
  }
  if (rawCat === 'poem' || rawCat === 'poems' || rawCat === 'poetry') {
    return 'poem';
  }

  const title = (item.title || '').toLowerCase();
  const sanskrit = (item.sanskrit_text || '').toLowerCase();


  if (
    title.includes('स्तोत्र') || title.includes('strotra') || title.includes('stotra') ||
    title.includes('शतक') || title.includes('shatak') ||
    title.includes('अष्टक') || title.includes('ashtak') ||
    title.includes('महिमामृत') || title.includes('mahimamrit') ||
    title.includes('सुधानिधि') || title.includes('sudhanidhi') ||
    title.includes('सहस्रनाम') || title.includes('sahasranam') ||
    sanskrit.includes('स्तोत्र') || sanskrit.includes('strotra') || sanskrit.includes('stotra')
  ) {
    return 'strotra';
  }


  const hasSanskritText = sanskrit.trim().length > 10 &&
    (sanskrit.includes('॥') || sanskrit.includes('।') || sanskrit.includes('ॐ') || !/[a-z]{5,}/.test(sanskrit));

  const isScriptureBook = title.includes('gita') || title.includes('गीता') ||
    title.includes('upnishad') || title.includes('उपनिषद') ||
    title.includes('samhita') || title.includes('संहिता') ||
    title.includes('purana') || title.includes('पुराण') ||
    title.includes('shloka') || title.includes('श्लोक');

  if (isScriptureBook || hasSanskritText || rawCat === 'shloka' || rawCat === 'shlokas') {
    return 'shloka';
  }

  return 'poem';
}

const mapToAppModel = (item) => {
  if (!item) return null;
  return {
    id: item.id,
    title: item.title,
    sanskrit_text: item.sanskrit_text || item.sanskritText || '',
    hindi_text: item.hindi_text || item.hindiText || '',
    english_text: item.english_text || item.englishText || '',
    english_translation: item.english_translation || item.englishTranslation || '',
    category: item.category,
    description: item.description || '',
    content_text: item.content_text || item.contentText || '',
    tags: item.tags || [],
    status: (item.status || '').toLowerCase(),
    author: item.author || '',
    media_links: item.media_links || item.mediaLinks || [],
    audio_url: item.audio_url || item.audioUrl || '',
    image_urls: item.image_urls || item.imageUrls || [],
    video_urls: item.video_urls || item.videoUrls || [],
    slug: item.slug,
    created_at: item.created_at || item.createdAt,
    updated_at: item.updated_at || item.updatedAt
  };
};

const fetchCategoryBackup = async (category) => {
  try {
    const res = await fetch(`/data/content_backup_${category}.json`);
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    return await res.json();
  } catch (e) {
    console.warn(`Failed to fetch category backup for ${category}:`, e);
    return [];
  }
};

const fetchRelationsBackup = async () => {
  try {
    const res = await fetch('/data/relations_backup.json');
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    return await res.json();
  } catch (e) {
    console.warn("Failed to fetch relations backup:", e);
    return { sants: [], books: [], ragas: [], biographies: [] };
  }
};

export const apiService = {
  getCachedData: (key) => getCache(key),
  getMemoryCachedItems: () => memoryCachedItems,
  getMemoryCachedCategoryItems: (category) => {
    if (!category) return [];
    const targetCat = category.toLowerCase().trim();
    return memoryCategoryCache[targetCat] || [];
  },

  getRelations: async () => {
    if (typeof window === 'undefined') {
      return { sants: [], books: [], ragas: [], biographies: [] };
    }

    try {
      const cached = localStorage.getItem('vrindopnishad_relations_cache');
      if (cached) {
        return JSON.parse(cached);
      }
    } catch (e) {
      console.warn('Failed to parse relations cache:', e);
    }

    console.log('[Relations-Cache-Miss] Loading relations from backup file...');
    const relations = await fetchRelationsBackup();
    try {
      localStorage.setItem('vrindopnishad_relations_cache', JSON.stringify(relations));
    } catch (e) {
      console.warn('Failed to write relations to LocalStorage:', e);
    }
    return relations;
  },

  getAllContent: async (category = null, limit = 50) => {
    const targetCategories = category
      ? [category.toLowerCase().trim()]
      : ['shloka', 'strotra', 'poem', 'saint', 'dham'];

    let cacheUpdated = false;

    for (const cat of targetCategories) {
      if (!memoryCategoryCache[cat] || memoryCategoryCache[cat].length === 0) {
        // Try reading from LocalStorage
        try {
          const localCached = localStorage.getItem(`vrindopnishad_cache_${cat}`);
          if (localCached) {
            const parsed = JSON.parse(localCached);
            if (parsed && Array.isArray(parsed) && parsed.length > 0) {
              memoryCategoryCache[cat] = ensureSorted(parsed);
              cacheUpdated = true;
            }
          }
        } catch (e) {
          console.warn(`Failed to parse cache for ${cat}:`, e);
        }

        // If still not loaded, fetch backup file
        if (!memoryCategoryCache[cat] || memoryCategoryCache[cat].length === 0) {
          console.log(`[Cache-Miss] Loading initial dataset for [${cat}] from local backup...`);
          const backupItems = await fetchCategoryBackup(cat);
          if (backupItems && backupItems.length > 0) {
            memoryCategoryCache[cat] = ensureSorted(backupItems);
            cacheUpdated = true;

            // Determine last updated time for this category
            let maxTime = new Date('1970-01-01T00:00:00Z');
            backupItems.forEach(item => {
              if (item.updated_at) {
                const t = new Date(item.updated_at);
                if (t > maxTime) maxTime = t;
              }
            });

            try {
              localStorage.setItem(`vrindopnishad_cache_${cat}`, JSON.stringify(backupItems));
              localStorage.setItem(`vrindopnishad_last_updated_${cat}`, maxTime.toISOString());
            } catch (e) {
              console.warn(`Failed to save cache for category ${cat}:`, e);
            }
          }
        }
      }
    }

    if (cacheUpdated) {
      rebuildMemoryMaps();
    }

    // Prepare result array
    let resultItems = [];
    if (category) {
      resultItems = memoryCategoryCache[category.toLowerCase().trim()] || [];
    } else {
      resultItems = memoryCachedItems || [];
    }

    // Background Delta Sync
    if (!USE_MOCK && typeof window !== 'undefined') {
      const now = Date.now();
      if (now - lastSyncTime > 5 * 60 * 1000) {
        lastSyncTime = now;

        setTimeout(async () => {
          try {
            // Determine maximum updated timestamp among loaded categories
            let currentLastUpdated = '1970-01-01T00:00:00.000Z';
            targetCategories.forEach(cat => {
              const time = localStorage.getItem(`vrindopnishad_last_updated_${cat}`);
              if (time && time > currentLastUpdated) {
                currentLastUpdated = time;
              }
            });

            let updates = [];
            if (DB_PROVIDER === 'supabase') {
              console.log(`[Supabase-Sync] Fetching updates since: ${currentLastUpdated}...`);
              const { data: rawUpdates, error } = await supabase
                .from('content')
                .select('*')
                .gt('updated_at', currentLastUpdated);

              if (error) throw error;
              updates = (rawUpdates || []).map(mapToAppModel).filter(Boolean);
            } else {
              let hasUpdates = true;
              try {
                const metaRef = ref(contentDb, 'metadata/last_updated');
                const metaSnapshot = await get(metaRef);
                if (metaSnapshot.exists()) {
                  const serverLastUpdated = metaSnapshot.val();
                  if (serverLastUpdated && currentLastUpdated && serverLastUpdated <= currentLastUpdated) {
                    hasUpdates = false;
                  }
                }
              } catch (metaErr) {
                console.warn('[Delta-Sync/RTDB] Failed to read metadata last_updated:', metaErr);
              }

              if (!hasUpdates) {
                console.log('[Delta-Sync] Database is up to date (Checked via Metadata). 0 new items fetched.');
              } else {
                console.log(`[Delta-Sync/RTDB] Fetching content updates since ${currentLastUpdated}...`);
                const dbRef = ref(contentDb, 'content');
                let rawUpdates = [];

                try {
                  const q = rtdbQuery(dbRef, orderByChild('updated_at'), startAt(currentLastUpdated));
                  const snapshot = await get(q);
                  if (snapshot.exists()) {
                    const val = snapshot.val();
                    if (typeof val === 'object' && val !== null) {
                      rawUpdates = Object.entries(val).map(([key, item]) => {
                        if (item && typeof item === 'object') {
                          return { id: item.id || key, ...item };
                        }
                        return null;
                      }).filter(Boolean);
                    }
                  }
                } catch (queryErr) {
                  console.warn('[Delta-Sync/RTDB] Query failed, falling back to full download:', queryErr);
                  const snapshot = await get(dbRef);
                  if (snapshot.exists()) {
                    const val = snapshot.val();
                    if (Array.isArray(val)) {
                      rawUpdates = val.filter(Boolean);
                    } else if (typeof val === 'object') {
                      rawUpdates = Object.entries(val).map(([key, item]) => {
                        if (item && typeof item === 'object') {
                          return { id: item.id || key, ...item };
                        }
                        return null;
                      }).filter(Boolean);
                    }
                  }
                }

                if (currentLastUpdated && currentLastUpdated !== '1970-01-01T00:00:00.000Z') {
                  const lastTime = new Date(currentLastUpdated).getTime();
                  rawUpdates = rawUpdates.filter(item => {
                    const itemTime = item.updated_at ? new Date(item.updated_at).getTime() : 0;
                    return itemTime > lastTime;
                  });
                }

                updates = rawUpdates.map(mapToAppModel).filter(Boolean);
              }
            }

            if (updates.length > 0) {
              console.log(`[Delta-Sync] Found ${updates.length} new or updated items!`);

              // Group updates by category and distribute them
              const updatesByCat = {};
              updates.forEach(upd => {
                const cat = classifyItemCategory(upd);
                if (!updatesByCat[cat]) updatesByCat[cat] = [];
                updatesByCat[cat].push({
                  ...upd,
                  category: cat,
                  slug: upd.slug || generateSlug(upd.title)
                });
              });

              let anyUpdates = false;

              for (const [cat, catUpdates] of Object.entries(updatesByCat)) {
                // Only merge updates into categories that have been loaded
                if (memoryCategoryCache[cat]) {
                  const catItemsMap = new Map(memoryCategoryCache[cat].map(item => [item.id, item]));
                  catUpdates.forEach(upd => {
                    catItemsMap.set(upd.id, upd);
                  });

                  const updatedCatItems = ensureSorted(Array.from(catItemsMap.values()));
                  memoryCategoryCache[cat] = updatedCatItems;
                  anyUpdates = true;

                  let maxTime = new Date('1970-01-01T00:00:00Z');
                  const storedTime = localStorage.getItem(`vrindopnishad_last_updated_${cat}`);
                  if (storedTime) maxTime = new Date(storedTime);

                  catUpdates.forEach(upd => {
                    if (upd.updated_at) {
                      const t = new Date(upd.updated_at);
                      if (t > maxTime) maxTime = t;
                    }
                  });

                  try {
                    localStorage.setItem(`vrindopnishad_cache_${cat}`, JSON.stringify(updatedCatItems));
                    localStorage.setItem(`vrindopnishad_last_updated_${cat}`, maxTime.toISOString());
                  } catch (e) {
                    console.warn(`Failed to update cache for ${cat} in delta sync:`, e);
                  }
                }
              }

              if (anyUpdates) {
                rebuildMemoryMaps();
                // Dynamically update relations_backup cache in LocalStorage if it exists
                try {
                  const cachedRelations = localStorage.getItem('vrindopnishad_relations_cache');
                  if (cachedRelations && memoryCachedItems) {
                    const freshRelations = extractRelations(memoryCachedItems);
                    localStorage.setItem('vrindopnishad_relations_cache', JSON.stringify(freshRelations));
                  }
                } catch (relErr) {
                  console.warn('Failed to update relations cache in delta sync:', relErr);
                }

                window.dispatchEvent(new Event('storage'));
              }
            } else {
              console.log('[Delta-Sync] Database is up to date. 0 new items fetched.');
            }
          } catch (err) {
            console.warn('[Delta-Sync] Background delta sync failed:', err.message);
          }
        }, 2000);
      }
    }

    if (limit && limit < resultItems.length) {
      return resultItems.slice(0, limit);
    }
    return resultItems;
  },

  getContentById: async (id) => {
    const cacheKey = `id_${id}`;
    let cached = getCache(cacheKey);
    if (cached) return cached;

    const decodedId = decodeURIComponent(id);
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(decodedId);

    // 1. Try memory map first
    let matched = contentMapById.get(id.toString()) ||
      contentMapById.get(decodedId.toString()) ||
      contentMapBySlug.get(id) ||
      contentMapBySlug.get(decodedId);

    if (matched) {
      console.log(`[Cache-Hit] getContentById matched item ${id} in memory map.`);
      const cleanCategory = classifyItemCategory(matched);
      const data = {
        ...matched,
        category: cleanCategory,
        slug: matched.slug || generateSlug(matched.title)
      };
      setCache(cacheKey, data);
      return data;
    }

    if (USE_MOCK) {
      const data = await mockApiService.getContentById(id);
      setCache(cacheKey, data);
      return data;
    }

    // 2. Try fetching from live DB asynchronously
    let rawData = null;
    try {
      if (DB_PROVIDER === 'supabase') {
        console.log('[Supabase] Fetching content by ID/Slug:', decodedId);
        let query = supabase.from('content').select('*');
        if (isUuid) {
          query = query.eq('id', decodedId);
        } else {
          query = query.eq('slug', decodedId);
        }
        const { data, error } = await query.maybeSingle();
        if (!error && data) {
          rawData = data;
          const dataObj = mapToAppModel(rawData);
          const cleanCategory = classifyItemCategory(dataObj);
          const contentData = {
            ...dataObj,
            category: cleanCategory,
            slug: dataObj.slug || generateSlug(dataObj.title)
          };
          setCache(cacheKey, contentData);
          return contentData;
        }
      } else {
        console.log('[DataConnect-Client] Fetching live content for', decodedId);
        let result;
        if (isUuid) {
          result = await getDcContentById(dataConnect, { id: decodedId });
        } else {
          result = await getDcContentBySlug(dataConnect, { slug: decodedId });
        }
        if (result && result.data && result.data.content) {
          const mapped = mapToAppModel(result.data.content);
          const cleanCategory = classifyItemCategory(mapped);
          const found = {
            ...mapped,
            category: cleanCategory,
            slug: (mapped.slug && !mapped.slug.startsWith('untitled')) ? mapped.slug : generateSlug(mapped.title)
          };

          if (found.id) {
            contentMapById.set(found.id.toString(), found);
          }
          if (found.slug) {
            contentMapBySlug.set(found.slug, found);
            contentMapBySlug.set(decodeURIComponent(found.slug), found);
          }

          if (!memoryCategoryCache[found.category]) {
            memoryCategoryCache[found.category] = [];
          }
          if (!memoryCategoryCache[found.category].some(x => x.id === found.id)) {
            memoryCategoryCache[found.category].push(found);
            memoryCategoryCache[found.category] = ensureSorted(memoryCategoryCache[found.category]);
            try {
              localStorage.setItem(`vrindopnishad_cache_${found.category}`, JSON.stringify(memoryCategoryCache[found.category]));
            } catch (e) { }
          }

          setCache(cacheKey, found);
          return found;
        }
      }
    } catch (networkErr) {
      console.warn('[Cache-Miss] Live fetch failed, will try local cache:', networkErr);
    }

    // 3. Fallback to searching all LocalStorage category caches on-demand
    try {
      const categories = ['shloka', 'strotra', 'poem', 'saint', 'dham'];
      const decodedSlug = decodedId.toLowerCase();

      for (const cat of categories) {
        let catItems = memoryCategoryCache[cat];
        if (!catItems || catItems.length === 0) {
          const localCached = localStorage.getItem(`vrindopnishad_cache_${cat}`);
          if (localCached) {
            catItems = ensureSorted(JSON.parse(localCached));
            memoryCategoryCache[cat] = catItems;
          }
        }

        if (catItems && catItems.length > 0) {
          catItems.forEach(item => {
            if (item.id) contentMapById.set(item.id.toString(), item);
            if (item.slug) {
              contentMapBySlug.set(item.slug, item);
              contentMapBySlug.set(decodeURIComponent(item.slug), item);
            }
          });

          let found = contentMapById.get(decodedId) || contentMapBySlug.get(decodedId) || contentMapBySlug.get(decodedSlug);
          if (!found) {
            const normDecoded = normalizeFuzzyText(decodedSlug);
            found = catItems.find(item => {
              if (!item.slug) return false;
              const normItem = normalizeFuzzyText(item.slug);
              return normItem === normDecoded ||
                normItem.startsWith(normDecoded) ||
                normDecoded.startsWith(normItem);
            });
          }

          if (found) {
            setCache(cacheKey, found);
            return found;
          }
        }
      }

      // 4. Final resort: Load all content
      const allItems = await apiService.getAllContent();
      let found = contentMapById.get(decodedId) || contentMapBySlug.get(decodedId) || contentMapBySlug.get(decodedSlug);
      if (found) {
        setCache(cacheKey, found);
        return found;
      }
    } catch (fallbackErr) {
      console.error('Fallback content resolution failed:', fallbackErr);
    }

    throw new Error("Content not found in local cache or live database");
  },


  getCategories: async () => {

    return ['shloka', 'strotra', 'poem'];
  },


  createContent: async (contentData) => {
    try {
      const id = contentData.id || crypto.randomUUID();
      const slug = contentData.slug || generateSlug(contentData.title);

      if (DB_PROVIDER === 'supabase') {
        const payload = {
          id: id,
          title: contentData.title,
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category,
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'PUBLISHED').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug
        };
        const { data, error } = await supabase.from('content').insert([payload]).select().single();
        if (error) throw error;
        return mapToAppModel(data);
      } else {
        const payload = {
          id: id,
          title: contentData.title || '',
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category || '',
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'published').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        // Clean up undefined properties to avoid RTDB errors
        Object.keys(payload).forEach(key => {
          if (payload[key] === undefined) {
            delete payload[key];
          }
        });
        await dbSet(ref(contentDb, `content/${id}`), payload);
        try {
          await dbSet(ref(contentDb, 'metadata/last_updated'), payload.updated_at);
        } catch (metaErr) {
          console.warn('Failed to write metadata/last_updated:', metaErr);
        }
        return payload;
      }
    } catch (error) {
      console.error('Error creating content:', error);
      throw error;
    }
  },

  updateContent: async (id, contentData) => {
    try {
      const slug = contentData.slug || generateSlug(contentData.title);

      if (DB_PROVIDER === 'supabase') {
        const payload = {
          title: contentData.title,
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category,
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'PUBLISHED').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug
        };
        const { data, error } = await supabase.from('content').update(payload).eq('id', id).select().single();
        if (error) throw error;
        return mapToAppModel(data);
      } else {
        const payload = {
          title: contentData.title,
          sanskrit_text: contentData.sanskrit_text || '',
          hindi_text: contentData.hindi_text || '',
          english_text: contentData.english_text || '',
          english_translation: contentData.english_translation || '',
          category: contentData.category,
          description: contentData.description || '',
          content_text: contentData.content_text || '',
          tags: contentData.tags || [],
          status: (contentData.status || 'published').toLowerCase(),
          author: contentData.author || '',
          media_links: contentData.media_links || [],
          audio_url: contentData.audio_url || '',
          image_urls: contentData.image_urls || [],
          video_urls: contentData.video_urls || [],
          slug: slug,
          updated_at: new Date().toISOString()
        };
        // Clean up undefined properties to avoid RTDB errors
        Object.keys(payload).forEach(key => {
          if (payload[key] === undefined) {
            delete payload[key];
          }
        });
        await dbUpdate(ref(contentDb, `content/${id}`), payload);
        try {
          await dbSet(ref(contentDb, 'metadata/last_updated'), payload.updated_at);
        } catch (metaErr) {
          console.warn('Failed to write metadata/last_updated:', metaErr);
        }
        return { ...contentData, id, slug };
      }
    } catch (error) {
      console.error('Error updating content:', error);
      throw error;
    }
  },

  deleteContent: async (id) => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { error } = await supabase.from('content').delete().eq('id', id);
        if (error) throw error;
        return true;
      } else {
        await dbRemove(ref(contentDb, `content/${id}`));
        try {
          await dbSet(ref(contentDb, 'metadata/last_updated'), new Date().toISOString());
        } catch (metaErr) {
          console.warn('Failed to write metadata/last_updated during deletion:', metaErr);
        }
        return true;
      }
    } catch (error) {
      console.error('Error deleting content:', error);
      throw error;
    }
  },


  login: async (email, password) => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data, error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        return data.user;
      } else {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        return userCredential.user;
      }
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },

  signUp: async (email, password, fullName = '') => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              display_name: fullName
            }
          }
        });
        if (error) throw error;
        return data.user;
      } else {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        return userCredential.user;
      }
    } catch (error) {
      console.error('Sign up error:', error);
      throw error;
    }
  },

  signInWithGoogle: async () => {
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'google',
        });
        if (error) throw error;
        return data.user;
      } else {
        const provider = new GoogleAuthProvider();
        const userCredential = await signInWithPopup(auth, provider);
        return userCredential.user;
      }
    } catch (error) {
      console.error('Google sign in error:', error);
      throw error;
    }
  },

  verifyToken: async () => {
    if (USE_MOCK) {
      return mockApiService.verifyToken();
    }
    try {
      if (DB_PROVIDER === 'supabase') {
        const { data: { session }, error } = await supabase.auth.getSession();
        if (error || !session) throw new Error("No session found");
        return session;
      } else {
        if (!auth.currentUser) throw new Error("No user signed in");
        return await auth.currentUser.getIdTokenResult();
      }
    } catch (error) {
      console.error('Token verification error:', error);
      throw error;
    }
  },

  onAuthChanged: (callback) => {
    if (DB_PROVIDER === 'supabase') {
      const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
        callback(session?.user || null, session?.access_token || null);
      });
      return () => subscription.unsubscribe();
    } else {
      return onAuthStateChanged(auth, async (firebaseUser) => {
        if (firebaseUser) {
          try {
            const token = await firebaseUser.getIdToken();
            callback(firebaseUser, token);
          } catch (e) {
            callback(firebaseUser, null);
          }
        } else {
          callback(null, null);
        }
      });
    }
  },

  logout: async () => {
    if (DB_PROVIDER === 'supabase') {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
    } else {
      await signOut(auth);
    }
  },


  generateAudio: async (contentId, text, language, token) => {
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const axios = require('axios');
    await axios.post(
      `${backendUrl}/content/${contentId}/generate-audio`,
      { text, language },
      { headers }
    );
  },

  generateImage: async (contentId, prompt, token) => {
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const axios = require('axios');
    await axios.post(
      `${backendUrl}/content/${contentId}/generate-image`,
      { prompt },
      { headers }
    );
  },

  uploadFile: async (contentId, file, type, token) => {
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const formData = new FormData();
    formData.append('file', file);
    const axios = require('axios');
    await axios.post(
      `${backendUrl}/upload/${type}/${contentId}`,
      formData,
      { headers }
    );
  },

  resetPassword: async (email) => {
    if (DB_PROVIDER === 'supabase') {
      const { error } = await supabase.auth.resetPasswordForEmail(email);
      if (error) throw error;
    } else {
      await sendPasswordResetEmail(auth, email);
    }
  }
};

export const isDemoMode = USE_MOCK;
