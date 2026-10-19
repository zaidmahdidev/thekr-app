import html, json, re, os
PARA = re.compile(r'<p(?: class="([^"]*)")?>(.*?)</p>', re.S)
def clean(f):
    f = re.sub(r'<a href="#p\d+" class="btn_tag.*?</a>', '', f, flags=re.S)
    f = re.sub(r'<span[^>]*class="anchor"[^>]*></span>', '', f)
    f = re.sub(r'<span[^>]*id="p\d+"[^>]*></span>', '', f)
    f = re.sub(r'<br\s*/?>', '\n', f)
    f = re.sub(r'<[^>]+>', '', f)
    return html.unescape(f).strip()
flat = []
for pid in range(18, 883):
    path = f'raw/{pid}.html'
    if not os.path.exists(path):
        print('missing', pid); continue
    h = open(path, encoding='utf-8', errors='ignore').read()
    m = re.search(r'<div class="nass[^"]*" data-page-id="(\d+)" data-page-num="(\d+)">', h)
    if not m:
        print('no nass', pid); continue
    start = m.end()
    end = h.find('<div id="appended_pages"', start)
    block = h[start:end if end > 0 else None]
    for cls, body in PARA.findall(block):
        if cls and 'hamesh' in cls:
            continue
        t = clean(body)
        if t:
            flat.append({'pid': pid, 'num': int(m.group(2)), 'text': t})
json.dump(flat, open('flat2.json', 'w', encoding='utf-8'), ensure_ascii=False)
print(len(flat), sum(len(x['text']) for x in flat))
