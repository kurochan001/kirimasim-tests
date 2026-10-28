# 分母レビュー 2026-10-28

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

IEEE 1800-2023 の要求台帳を「意味的に一意な分母」として承認した記録です。
**AIによるレビューであり、独立した人間の承認ではありません。**

## 入力の同一性

- PDF: `IEEE_Std_1800-2023_SystemVerilog.pdf`
  - SHA-256 `43d042a2…d1a14`（`requirement-audit.json` の `pdf_sha256` と一致）
- 抽出テキスト: `lrm_pdftotext_layout.txt`
  - SHA-256 `ee84b2d1…56dc`（`text_sha256` と一致）
- 節: 1,740（normative 1,703、no_behavior 37）
- 登録行: 12,319 → **12,298**

## 1. 解釈の解決（21行・19論点）

| 分類 | 行数 | 内容 |
|---|---:|---|
| 本文で解決 | 11 | 節の規範文から一意に決まる |
| 方針選択 | 9 | 規範同士の衝突を、個別規則・shall優先で選択 |
| 残置 | 1 → 0 | 31.4.4 を「同時エッジは規格が禁止する前提違反」と限定して解決 |

主な選択:

- **9.3.4**: 「全変数 static」は既定格納の規則。6.21 の automatic を例外として残す。
- **9.4.2**: chandle の裸参照だけを 6.14 の例外とする。
- **16.13.2**: 強度は 16.12.2 の省略時規則（assert/assume は weak）。
- **19.5.7**: リテラルの4値ビンは 19.5.4 の `===`。式由来の x/z にのみ警告・除去。
- **19.11.1**: enum の分母は列挙値数（`auto_bin_max` で頭打ちにしない）。
- **20.4.3**: `units_number` が -15..2、`precision_number` は小数桁数。
- **28.12.2**: 曖昧同士は範囲結合を無条件適用。
- **33.4.3**: `use #()` を全パラメータ・リセットとして認める。
- **N.2**: 32ビット固定幅・mod 2^32。
- **31.4.4**: 異なる時刻のパルスだけを対象とし、同時エッジは precondition violation とする。

引用は抽出テキストへの部分一致で機械検証した。図（37.80 など）は PDF を
400dpi で描画して目視確認した。

## 2. 重複の統合（25候補）

| 判定 | 候補 | 行数 |
|---|---:|---:|
| 統合 | 21 | 21行削除、20行を更新 |
| 保持 | 4 | 5行（kind または出典が異なる） |
| 完全一致の保持 | 3組 | 6行（観測対象が異なる） |

- 統合は、同じ clause・同じ kind・同じ義務で、survivor の `source_spans` と
  `checks` に旧行の情報を移せる場合だけ行った。
- 初期行は `source_spans` を持たないため、失われる出典はない。
- 保持した例: `7.8.6`（boundary と normal が異なる）、`19.7 CROSS-RETAIN`
  （normal と error の合成）、`34.5.12.2` / `34.5.25.2`（暗号化と復号で義務が異なる）。
- `37.85` の完全一致2行は、`vpiRegArray` と `vpiMemory` の観測差を behavior に
  明記する残課題付きで保持した。

## 3. 出典の復元（92行）

| 判定 | 行数 |
|---|---:|
| ブロック単位の `source_spans` を復元 | 89 |
| 節単位のみ（ブロックが義務を定義しない） | 3 |

未解決の3行:

- `SV2023-6.24.3-ARRAY-TO-BITS`（固定サイズ unpacked 配列のパック順が本文にない）
- `SV2023-20.3.2-STIME-ROUNDING`（$stime への丸めの明示文がない）
- `SV2023-20.14.2-UNIFORM-SINGLETON`（等しい境界の singleton を定めるブロックがない）

この3行は削除せず、clause 単位の出典だけを持つ行として残した。分母の
「ブロック単位で一意」という主張からは除外される。

## 4. 承認

`coverage/behaviors.json` の `denominator_review`:

- `state`: `approved`
- `reviewer`: `DeepSeek V4.1 Flash (AI); not an independent human review`
- `reviewed_on`: `2026-10-28`
- 節の監査: **1,703 / 1,703**
- 登録行: **12,298**
- 確定値: **設計 89.28%（10,980 / 12,298）**
- 実行: **59.44%（7,310 / 12,298、Ghost含む）**／Ghost除外 **50.83%（6,251）**

## 5. 再現手順

```sh
python3 tools/behavior_coverage.py --update --require-source-reviewed \
  --write-baseline --reason 'denominator review'
python3 tools/requirement_matching.py --update
python3 tools/suite_stats.py --update
python3 tools/suite_catalog.py --update
python3 tools/coverage_depth.py --update
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 generators/generate.py --check
```

## 6. 限界

- 承認はAIレビューであり、人間の独立承認ではない。
- 3行はブロック単位の出典を持たない。
- 31.4.4 は同時エッジを precondition violation とする方針選択を含む。
- 4候補（5行）は統合せず保持した。うち `37.85` は witness の追加が残る。
- Ghost の証跡は並行作業で追加されたもので、本レビューの対象外。
