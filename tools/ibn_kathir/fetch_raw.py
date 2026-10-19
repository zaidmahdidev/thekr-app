"""Polite downloader: saves the raw HTML of one Shamela book page per file.

One request per second, identifies itself, resumes where it stopped.
"""
import os
import sys
import time
import urllib.request

BOOK = 932
FIRST = int(sys.argv[1])
LAST = int(sys.argv[2])
UA = 'Mozilla/5.0 (compatible; ThekrAppContentBot/1.0; personal use with site permission)'

os.makedirs('raw', exist_ok=True)

for page in range(FIRST, LAST + 1):
    path = f'raw/{page}.html'
    if os.path.exists(path):
        continue
    url = f'https://shamela.ws/book/{BOOK}/{page}'
    try:
        request = urllib.request.Request(url, headers={'User-Agent': UA})
        with urllib.request.urlopen(request, timeout=40) as response:
            body = response.read().decode('utf-8', errors='ignore')
    except Exception as error:  # noqa: BLE001
        print('ERR', page, error, flush=True)
        time.sleep(5)
        continue
    with open(path, 'w', encoding='utf-8') as f:
        f.write(body)
    if page % 25 == 0:
        print('saved up to', page, flush=True)
    time.sleep(1.0)

print('done', flush=True)
