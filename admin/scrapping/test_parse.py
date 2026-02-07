from bs4 import BeautifulSoup
import json
import re

# Sample data from browser subagent
samples = [
  {
    "url": "https://www.brajrasik.org/articles/6986d5cc2c9d8600044fb8a0/chal-na-sakai-nij-thaur-tain-je-tan-hum-abhiram-shri-rasnidhi",
    "title": "CHAL NA SAKAI NIJ THAUR TAIN JE TAN HUM ABHIRAM - SHRI RASNIDHI",
    "html_content": "<div><strong>cala na sakai nija ṭhaura taiṃ, je tana druma abhirāma  <br>tahāṅ āi rasa varasivau, lājima tuhi ghanasyāma </strong><br><em>- śrī rasanidhi<br></em><br>O Cloud! Just as the trees stand helpless, unable to walk toward water, it is your duty to bring rain to them. Similarly, when a soul becomes tired of wandering through countless lives and fully surrenders, Lord Ghanshyam Himself draws near, shelters that soul, and showers it with divine nectarous grace.</div>"
  },
  {
    "url": "https://www.brajrasik.org/articles/698639d6c79f380004a87f8d/dhaike-jai-ji-jamuna-tire-shri-chhit-swami-ji-ki-vani-164",
    "title": "DHAIKE JAI JI JAMUNA TIRE - SHRI CHHIT SWAMI JI KI VANI (164)",
    "html_content": "<div>(rāga rāmakalī)<br><strong>dhāike jāi jī jamunā-tīre<br>tākī mahimā aba kahāṅ lauṃ baraniye, jāi parasata ati prema nīre (1)<br>nisidina keli karata manamohana, piyā lai ju bhakta kī saṃga bhīre <br>“chīta svāmī” giridharana śrīviṭhṭhala, ini-binu neku na dharata dhīre (2)</strong><br><em>- śrī chīta svāmī, śrī chīta svāmī jī kī vāṇī (164)<br></em><br>Run swiftly to the banks of the Yamunā. How far can her glory ever be described? The very touch of her sacred waters drenches the heart in divine love. [1]<br><br>There, day and night, Manmohana Śrī Kṛṣṇa performs sweet amorous pastimes with His beloved Śrī Rādhā, bestowing supreme rasa upon the devotees. Śrī Chīta Svāmī says — Giridhara Lāla and His devotees cannot remain peaceful even for a single moment without these Yamunā-bank pastimes. [2]</div>"
  },
  {
    "url": "https://www.brajrasik.org/articles/65eecb6ddcf95f0008c29772/biography-of-shri-abhayram-ji",
    "title": "BIOGRAPHY OF SHRI ABHAIRAM JI",
    "html_content": "<div><strong>Birth:</strong></div><div>The exact date of birth of Shri Abhairam Ji is not known, but based on internal evidence and family tradition, it is believed that he was born around 1830-1835 AD.<br><br></div><div><strong>Introduction:<br></strong>Shri Abhairam Ji was born into the Gauray Thakur (Kshatriya clan) caste. He lived in the Dusayat locality of Shri Vrindavan. He was seen as the head among the prominent landowners of that time. He was highly respected in gatherings of poets. Many of his verses are very dear to the residents of Vrindavan and are sung with great enthusiasm even today.</div>"
  }
]

def simulate_parse(sample):
    soup = BeautifulSoup(sample["html_content"], 'html.parser')
    data = {
        "url": sample["url"],
        "title": sample["title"].title(),
        "sanskrit_text": "",
        "author": "",
        "translation": "",
        "category": "General"
    }
    
    # Verse
    verse_tag = soup.find('strong')
    if verse_tag:
        data["sanskrit_text"] = verse_tag.get_text(strip=True)
    
    # Author
    author_tag = soup.find('em')
    if author_tag:
        data["author"] = author_tag.get_text(strip=True).replace('-', '').strip()
    
    # Translation/Content
    total_text = soup.get_text(separator="\n", strip=True)
    if data["author"] and data["author"] in total_text:
        data["translation"] = total_text.split(data["author"])[-1].strip()
    elif data["sanskrit_text"] and data["sanskrit_text"] in total_text:
        data["translation"] = total_text.split(data["sanskrit_text"])[-1].strip()
    else:
        data["translation"] = total_text

    # Category heuristic
    if "Biography" in data["title"]:
        data["category"] = "Katha"
    elif data["sanskrit_text"]:
        data["category"] = "Shloka"
    
    return data

results = [simulate_parse(s) for s in samples]
print(json.dumps(results, indent=2))
