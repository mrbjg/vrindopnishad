// Mock data for development without Firebase
export const mockContent = [
  {
    id: "mock-1",
    title: "Bhagavad Gita - Chapter 2, Verse 47",
    sanskrit_text: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।",
    hindi_text: "तुम्हें केवल कर्म करने का ही अधिकार है, कभी भी फल के बारे में नहीं।",
    english_text: "You have the right to work only, but never to its fruits.",
    english_translation: "Your duty is to act, but you have no right to be attached to the results of your action.",
    category: "shloka",
    description: "A fundamental teaching from the Bhagavad Gita about the importance of detachment from results.",
    audio_url: null,
    image_urls: [],
    video_urls: [],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: "mock-2",
    title: "The Meditative Mind",
    sanskrit_text: "मनः शांतिस्वरूपम्।",
    hindi_text: "मन ही शांति का स्वरूप है।",
    english_text: "The mind is the form of peace itself.",
    english_translation: "When the mind is calm and free from desires, it becomes one with the eternal peace.",
    category: "poem",
    description: "A beautiful poem about the nature of mind and meditation.",
    audio_url: null,
    image_urls: [],
    video_urls: [],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: "mock-3",
    title: "Gayatri Mantra Strotra",
    sanskrit_text: "ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं...",
    hindi_text: "हे सूर्य देव, आप सर्वश्रेष्ठ हैं...",
    english_text: "O Divine Sun, we meditate upon your glorious power...",
    english_translation: "We contemplate the supreme brilliance of the sun, the giver of all life and illumination.",
    category: "strotra",
    description: "The most sacred mantra in Hinduism, dedicated to the sun deity.",
    audio_url: null,
    image_urls: [],
    video_urls: [],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
];

export const mockCategories = [
  {
    id: "shloka",
    name: "Shlokas",
    description: "Sacred verses from Hindu scriptures"
  },
  {
    id: "strotra",
    name: "Strotras",
    description: "Devotional hymns and prayers"
  },
  {
    id: "poem",
    name: "Poems",
    description: "Spiritual and devotional poetry"
  }
];

export const mockApiService = {
  getAllContent: async (category = null) => {
    await new Promise(resolve => setTimeout(resolve, 300)); // Simulate API delay
    if (category) {
      return {
        success: true,
        content: mockContent.filter(c => c.category === category)
      };
    }
    return { success: true, content: mockContent };
  },

  getContentById: async (id) => {
    await new Promise(resolve => setTimeout(resolve, 300));
    const content = mockContent.find(c => c.id === id);
    if (!content) {
      throw new Error("Content not found");
    }
    return { success: true, content };
  },

  getCategories: async () => {
    await new Promise(resolve => setTimeout(resolve, 300));
    return { success: true, categories: mockCategories };
  },

  login: async (email, password) => {
    await new Promise(resolve => setTimeout(resolve, 500));
    if (email === "admin@vrindopnishad.com" && password === "admin123") {
      return {
        success: true,
        access_token: "mock-jwt-token-" + Date.now(),
        token_type: "bearer"
      };
    }
    throw new Error("Invalid credentials");
  },

  verifyToken: async () => {
    await new Promise(resolve => setTimeout(resolve, 200));
    return { valid: true };
  }
};
