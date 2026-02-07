#!/bin/bash
cd /Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/scrapping/
python3 -m venv venv_extra
source venv_extra/bin/activate
pip install requests-html "lxml[html_clean]" nest_asyncio
python3 scrape_extra.py
