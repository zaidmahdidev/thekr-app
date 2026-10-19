"""Builds the prophets' stories from Ibn Kathir's text (Shamela book 932).

Keeps Ibn Kathir's own narration and the Quranic passages he quotes, and drops
paragraphs that rely on chains of transmission or on Israelite reports, which
he himself marks as unreliable. Output: stories.json (+ a review report).
"""
import json
import re

flat = json.load(open('flat2.json', encoding='utf-8'))

# id -> (name, [(start, end), ...], max_chars)   indexes are paragraph indexes
SECTIONS = {
    '1': ('آدم', [(0, 240), (459, 579)], 14000),
    '2': ('إدريس', [(612, 639)], 8000),
    '3': ('نوح', [(640, 995)], 16000),
    '4': ('هود', [(996, 996), (1015, 1097)], 14000),
    '5': ('صالح', [(1172, 1316)], 12000),
    '6': ('إبراهيم', [(1345, 2072)], 18000),
    '7': ('لوط', [(2073, 2207)], 12000),
    '8': ('إسماعيل', [(1614, 1711), (2347, 2383)], 12000),
    '9': ('إسحاق', [(2384, 2478)], 8000),
    '10': ('يعقوب', [(2479, 2499)], 8000),
    '11': ('يوسف', [(2500, 2963)], 18000),
    '12': ('أيوب', [(2964, 3053)], 10000),
    '13': ('شعيب', [(2208, 2342)], 12000),
    '14': ('موسى', [(3315, 4691)], 22000),
    '17': ('داود', [(5211, 5379)], 14000),
    '18': ('سليمان', [(5380, 5639)], 14000),
    '21': ('يونس', [(3196, 3313)], 12000),
    '22': ('زكريا', [(5839, 5939)], 9000),
    '23': ('يحيى', [(5939, 6020)], 9000),
    '24': ('عيسى', [(6021, 6800)], 20000),
}

N = lambda s: s
EXCLUDE = re.compile(
    r'(حدثنا|اخبرنا|حدثني|اخبرني|ابن جرير|ابن اسحاق|ابن اسحق|محمد بن اسحاق|وهب|كعب الاحبار|'
    r'السدي|اهل الكتاب|التوراه|الاسرائيليات|اسرائيلي|ابن ابي حاتم|ابن عساكر|ابن عبد الحكم|'
    r'ابن قتيبه|الثعلبي|الزمخشري|عن ابن عباس|قال ابن عباس|عن ابن مسعود|قال ابن مسعود|'
    r'مقاتل|الكلبي|قتاده|عكرمه|مجاهد|الحسن البصري|زعم|يقال ان|وقيل|وقد قيل|قال بعضهم|'
    r'يعنون|وعندهم|عندهم|في كتابهم|في الكتب المتقدمه)'
)
CROSS_REF = re.compile(r'(في التفسير|في موضعه|في مواضعه|في موضعها|كما سياتي|كما سيأتي|كما تقدم|كما قدمنا)')
MANUAL_START = {'4'}
OFF_TOPIC = re.compile(r'(الدهريه|الدوريه|الزنادقه|الفلاسفه)')
QURAN_START = re.compile(r'(قال الله تعالي|قال تعالي|كما قال تعالي|قال الله عز وجل|وقال الله تعالي|وقال تعالي)')
TERMINAL = tuple('.!؟:"»*)') + ('...',)


def norm(s):
    s = re.sub(r'[ً-ٰٟۖ-ۭـ]', '', s)
    s = s.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا').replace('ى', 'ي').replace('ة', 'ه')
    return re.sub(r'\s+', ' ', s)


def tidy(text):
    text = re.sub(r'\(\s*[٠-٩0-9]+\s*\)', '', text)  # footnote marks (١)
    text = re.sub(r'"\s*[٠-٩0-9]+\s*"', '', text)  # genealogy numbers " ٢٥٠ "
    text = text.replace('[', '').replace(']', '')  # editor's additions: keep text
    text = text.replace(' * ', ' ۝ ').replace('* * *', '').replace('*', ' ')
    # straight quotes -> « »
    out, opened = [], False
    for ch in text:
        if ch == '"':
            out.append('»' if opened else '«')
            opened = not opened
        else:
            out.append(ch)
    text = ''.join(out)
    text = re.sub(r'\s+([،,.؟!:؛»])', r'\1', text)
    text = re.sub(r'«\s+', '«', text)
    return re.sub(r'[ \t]+', ' ', text).strip()


HEADING = re.compile(r'^(ذكر|قصه|باب|فصل|خبر|صفه)')


def is_heading(item):
    n = item['n']
    return len(n) < 140 and bool(HEADING.match(n)) and not n.endswith(('.', ':', '؟'))


def merge_page_breaks(paragraphs):
    """Shamela cuts paragraphs at page ends and inside long quotes: rejoin them.

    A real paragraph of Ibn Kathir always ends with a full stop, colon or a
    closing quote, so an unfinished one belongs to the next paragraph.
    """
    merged = []
    for item in paragraphs:
        if merged:
            prev = merged[-1]
            unfinished = not prev['text'].rstrip().endswith(TERMINAL)
            if unfinished and not is_heading(prev) and not is_heading(item):
                prev['text'] = prev['text'].rstrip() + ' ' + item['text'].lstrip()
                prev['n'] = norm(prev['text'])
                continue
        merged.append(dict(item))
    return merged


def build(spans, max_chars, manual=False):
    paragraphs = []
    for a, b in spans:
        paragraphs.extend(flat[a:b])
    paragraphs = merge_page_breaks(paragraphs)

    kept, dropped = [], 0
    total = 0
    started = False
    for item in paragraphs:
        n = item['n']
        if is_heading(item):
            if not started and not kept:
                kept.append(tidy(item['text']))  # the title
            elif started:
                kept.append(tidy(item['text']))
            continue
        if len(n) < 6 or EXCLUDE.search(n) or (len(n) < 170 and CROSS_REF.search(n)):
            dropped += 1
            continue
        if OFF_TOPIC.search(n):
            dropped += 1
            continue
        if not started and manual:
            started = True
        if not started:
            # The story proper starts where Ibn Kathir first quotes the Quran
            # about the prophet (before it come genealogies and tribe notes).
            if not QURAN_START.search(n):
                dropped += 1
                continue
            started = True
        text = tidy(item['text'])
        if len(text) < 15:
            continue
        if total + len(text) > max_chars and kept:
            break
        kept.append(text)
        total += len(text)
    return kept, dropped, len(paragraphs)


result = {}
for pid, (name, spans, cap) in SECTIONS.items():
    kept, dropped, count = build(spans, cap, pid in MANUAL_START)
    result[pid] = {
        'name': name,
        'paragraphs': kept,
        'chars': sum(len(t) for t in kept),
        'dropped': dropped,
        'source_paragraphs': count,
    }
    print(pid, name, 'kept', len(kept), 'dropped', dropped, 'of', count, 'chars', result[pid]['chars'])

json.dump(result, open('stories.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
