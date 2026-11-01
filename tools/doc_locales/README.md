<a id="ドキュメントの翻訳データ"></a>

# Documentation translation data

[日本語](README.ja.md) / [Document index](../../docs/README.md)

Repository Markdown documentation is paired in [`docs/languages.json`](../../docs/languages.json). Existing Japanese filenames remain valid and use an `.en.md` counterpart; existing English filenames use `.ja.md`. The root READMEs and history already use the latter convention. Each page links to its counterpart. Translated headings retain explicit anchors for the original headings so older fragment links keep working.

<a id="手書き文書の更新"></a>

## Updating handwritten documents

For a new document, create both language pages and add an entry to `docs/languages.json` with `en`, `ja`, `source`, `source_language` and `generated`. Identify the canonical source and whether a tool generates the pages. New generated families also need their exporter to publish and check both outputs.

Update both pages and review their meaning, commands, numbers and scope together. Then refresh the index and record their current fingerprints:

```sh
python3 tools/documentation_languages.py --update
python3 tools/documentation_languages.py --record
python3 tools/documentation_languages.py --check
```

`--record` records content identities after the pair was updated; it does not translate prose or certify semantic correctness. The check rejects missing pages, absent language links, unresolved placeholders, unregistered Markdown files and changed handwritten pairs. Generated report tools additionally check their own outputs. The README describes current status and commands; dated changes, measurements and past run counts belong in history or dated records.

<a id="生成文書の更新"></a>

## Updating generated documents

The existing report generators publish both language versions from the same canonical data. They use [`doc_localization.py`](../doc_localization.py), `en.json` and `ja.json`. CI performs no online translation, model download or inference.

The JSON dictionaries map protected source sentences to translated sentences. Code, paths, links, numeric values, versions, status identifiers and model IDs use placeholders. They are restored exactly; missing or inconsistent placeholders and missing translations fail rather than silently publishing an untranslated paragraph. Labels on links are translated separately, and links within a language point to that language's page. Language-switch links keep their explicit destination.

Treat dictionary entries as templates: a marker can carry different identifiers, numeric values or operators in different rows. Preserve the expression and do not infer a specific value or comparison direction that the unprotected source does not state.

When adding source prose, add its translation to the corresponding dictionary and review it in context. Keep every `ZXQPH<n>QXZ` placeholder exactly once, allowing reordering when grammar requires it. Update through the report generator and check both outputs. Do not edit generated reports directly. Technical identifiers, executable examples, raw evidence and legal license terms retain their original form.

The five chapter-matrix CSV exports in `coverage/` also have `.en.csv` counterparts. The exporter translates headers, chapter names and designated prose columns. Counts, category/status codes, factor values, input paths, raw expected output and execution provenance retain their original values. English guides link to the English CSV; Japanese guides link to the original CSV.

Nightly's `behavior_coverage.py` and `interaction_coverage.py` commands use `--bilingual-export` with `--source-url` to publish both languages outside the registered `main` paths. These exports reuse the corresponding document family's translations. Summary/detail links stay within the exported pair, while links to repository guides use the source commit and matching language. `results_history.py` generates its English/Japanese README, summary and chart labels directly from static strings. Both publication paths preserve the raw execution JSON and diagnostic text.

To obtain the exact dictionary keys for new prose, run this from the repository root and replace the example text. Marker numbers are local to each sentence; use the printed key and retain each marker once in its translation.

```python
import sys
sys.path.insert(0, "tools")
from doc_localization import protect, sentences

text = "Check all 27 cases with `a <= b`."
masked, literals = protect(text)
for key, original_ids in sentences(masked):
    print(key)
    print({f"ZXQPH{index}QXZ": literals[int(original[5:-3])]
           for index, original in enumerate(original_ids)})
```

<a id="翻訳の来歴と限界"></a>

## Translation provenance and limits

The FAQ, glossary, Nightly guide, interaction-method guide, entry-point editing and observation scopes of the 55 finite models were translated or reviewed directly during this change. Bulk drafts for the remaining documents used the locally executed [MADLAD-400-3B-MT model](https://huggingface.co/google/madlad400-3b-mt), revision `fa184c675da0b5c9e1c8694fccd4e12e2d422094`, whose model card identifies Apache-2.0 licensing. Translation software and weights are not runtime dependencies of this repository.

All handwritten translations received an AI context review against their source prose. Generated reports also received focused reviews of numeric/literal associations, negation, scheduling, observation scope and technical terminology.

When the source is truncated, mark the gap explicitly rather than inventing a continuation. This does not repair or change the original requirement registry or test metadata.

Translation coverage and structural checks do not establish error-free interpretation of every technical statement. Drafts require context review, especially negation, normative requirements, scheduling, proof scope and the distinction between planned and executed coverage. AI translation/review is not human approval. Correct both language pages when a translation defect is found, retaining the cited clauses and original execution evidence.
