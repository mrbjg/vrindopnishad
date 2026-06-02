require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL;
const supabaseKey = process.env.REACT_APP_SUPABASE_ANON_KEY;

console.log("Supabase URL present:", !!supabaseUrl, "key present:", !!supabaseKey);
console.log("Supabase URL value:", supabaseUrl);

const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
  console.log("Querying Supabase count...");
  try {
    const { count, error } = await supabase
      .from('content')
      .select('*', { count: 'exact', head: true });

    if (error) {
      console.error("Postgrest Error Code:", error.code);
      console.error("Postgrest Error Message:", error.message);
      console.error("Postgrest Error Details:", error.details);
      console.error("Postgrest Error Hint:", error.hint);
      throw error;
    }
    console.log("Supabase Total content count:", count);
    
    // Fetch top 5
    const { data, error: err2 } = await supabase
      .from('content')
      .select('id, title, category, slug, author')
      .limit(5);
    if (err2) throw err2;
    console.log("Sample rows:");
    console.log(data);
  } catch (e) {
    console.error("Failed to query Supabase:", JSON.stringify(e, null, 2), e);
  }
}

run();
