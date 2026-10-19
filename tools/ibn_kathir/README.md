# Ibn Kathir stories pipeline (draft, NOT used by the app yet)

Source: Shamela book 932, "قصص الأنبياء من البداية والنهاية" (Ibn Kathir, ed. Mustafa Abd al-Wahid).
Downloaded with the site owners' permission (as stated by the project owner), one request per second.

1. `python fetch_raw.py 18 882`  downloads the raw HTML of each page into `raw/` (not committed).
2. `python parse_raw.py`         extracts the author's paragraphs (editor footnotes excluded) into `flat2.json`.
3. `python build_stories.py`     selects/filters paragraphs per prophet into `stories.json`.

`stories.json` is a DRAFT. The automatic filter (drops chains of transmission and Israelite reports)
is not good enough to publish: some prophets come out empty, others start with genealogy.
Each story must be curated and reviewed by a scholar before it goes into `prophets_data.dart`.
