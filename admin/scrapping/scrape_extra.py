
import asyncio
import json
import os
import nest_asyncio
from requests_html import AsyncHTMLSession
import time

nest_asyncio.apply()

async def scrape_saints(session):
    print("Scraping Saints...")
    try:
        r = await session.get('https://www.brajrasik.org/hi/rasik-saints')
        print("Rendering and scrolling (Saints)...")
        await r.html.arender(scrolldown=50, sleep=1, timeout=60, keep_page=True)
        
        saints = []
        items = r.html.find('h4')
        print(f"Found {len(items)} h4 items.")
        
        for h4 in items:
            a = h4.find('a', first=True)
            if a:
                name = a.text.strip()
                link = list(a.absolute_links)[0] if a.absolute_links else ""
                saints.append({
                    "name": name,
                    "link": link,
                    "description": "",
                    "category": "Saint"
                })
                
        print(f"Extracted {len(saints)} saints.")
        return saints
    except Exception as e:
        print(f"Error scraping saints: {e}")
        return []

async def scrape_dham(session):
    print("Scraping Dham...")
    try:
        r = await session.get('https://www.brajrasik.org/hi/dham')
        print("Rendering and scrolling (Dham)...")
        await r.html.arender(scrolldown=50, sleep=1, timeout=60, keep_page=True)
        
        dhams = []
        items = r.html.find('h4')
        print(f"Found {len(items)} items on Dham page.")
        
        for h4 in items:
            a = h4.find('a', first=True)
            if a:
                name = a.text.strip()
                link = list(a.absolute_links)[0] if a.absolute_links else ""
                dhams.append({
                    "name": name,
                    "link": link,
                    "description": "",
                    "category": "Dham"
                })
        
        print(f"Extracted {len(dhams)} dham places.")
        return dhams
    except Exception as e:
        print(f"Error scraping dham: {e}")
        return []

async def main():
    session = AsyncHTMLSession()
    all_data = []
    
    saints = await scrape_saints(session)
    all_data.extend(saints)
    
    dhams = await scrape_dham(session)
    all_data.extend(dhams)
    
    await session.close()
    
    output_file = "/Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/brajrasik_extra.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)
    
    print(f"Saved {len(all_data)} items to {output_file}")

if __name__ == "__main__":
    asyncio.run(main())
