import os
from supabase import create_client

def get_supabase_client():
    url = os.environ.get('REACT_APP_SUPABASE_URL') or os.environ.get('SUPABASE_URL')
    key = os.environ.get('REACT_APP_SUPABASE_ANON_KEY') or os.environ.get('SUPABASE_ANON_KEY')
    if not url or not key:
        raise ValueError("REACT_APP_SUPABASE_URL/SUPABASE_URL or REACT_APP_SUPABASE_ANON_KEY/SUPABASE_ANON_KEY not set in environment.")
    return create_client(url, key)
