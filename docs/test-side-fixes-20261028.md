# テスト側の失敗と Issue #6–#19 の修正（2026-10-28）

`docs/test-failure-triage-20261028.md` が判断を記録したテスト側の失敗を、
IEEE 1800-2023 の節に基づいて修正した記録です。ランナー側の #13 / #14 は
`docs/runner-selection-20261028.md` にあります。

## 1. 修正した Issue

| Issue | 対象 | 主な修正 |
|---:|---|---|
| #6 | checker 5本 | checker 変数を宣言時初期化にし、`initial` の代入を `assign` / `always_comb` / `always_ff` へ。`int acc;` を checker body へ移動 |
| #7 | deferred assertion 3本 | action の代入を checker body の `void` function 呼び出しに変更（16.4.1） |
| #8 | severity / clocking 5本 | 重大度語がファイル名・行番号の前後どちらでも一致する regex に変更 |
| #9 | `$readmemh` 1本 | 範囲外の start/finish は警告してメモリ不変、という規格どおりの期待値に変更。`:oracle: spec` |
| #10 | specparam / program / checker delay 3本 | specparam を generate 条件へ、program 信号は output port 経由、checker の delay 表示は `final` へ |
| #11 | VPI C 1本 | `vpi_printf` の `%s` を `%d` に修正 |
| #12 | VCD 3本 | `$var` の index range を任意とし、型・サイズは厳密に、range は「なし」または宣言どおりのみ許容 |
| #15 | grammar 6本 | `matches` を `cond_predicate` の合法形へ、`wildcard bins` の語順、`cell` 予約語の回避 |
| #16 | 9本 | multiclock を `|->` / `##0` へ、rand 制約、quoted include、modport、interface 内 module、`$bits` の packed union 化、`extern virtual` |
| #17 | 6本 | `$future_gclk` を property 式へ、`local` formal、virtual interface port、`out` → `output`、soft packed union |
| #18 | 4本 | 配列クエリから real / shortreal / event を削除（20.7 の対象外） |
| #19 | 1本 | 空マッチになる `1'b1[*]` を property から削除 |

合計 46 本のテストファイル（#11 は C のみ）を変更しました。テストの追加・削除は
していません。期待出力が変わったのは #9、#12、#16 の ch6、#17 の
`test_sequence_local_formal_assignment` です。それ以外は設計を合法形に直し、
同じ期待値を保っています。

## 2. 検証

- `python3 tools/lint_metadata.py`: 7,740 本、新規問題0件（既知396件）。
- Icarus Verilog 13.0（ローカルビルド）で変更した46本を実行:
  8本が pass、38本が known（`:oracle:` が 13.0 でない、または checker 等を
  Icarus が実装していないため）。失敗0。
- Verilator 5.052 で全7,472本を実行: Verilator oracle の2,171本がすべて pass。
  残り5,301本は known で、失敗0。
- grammar 系の #15 / #16 / #17 は、サブエージェントが pyslang 12.1.0
  `--std 1800-2023` でも構文・意味のエラーがないことを確認しました。
- #11 の実テストは sukimasim の VPI typedef 列挙で別の 139 終了が残ります。
  `%s` の修正箇所は解消済みで、simulator 側の既存不具合です。

## 3. 実行証跡とカバレッジ

変更したテストの入力ハッシュが変わるため、既存の実行証跡は stale になります。
変更した46本を Icarus 13.0 と Verilator 5.052 で再実行し、次の証跡を追加しました。

- `coverage/results/issues-20261028-icarus13.json`（46本）
- `coverage/results/issues-20261028-verilator.json`（全7,472本）

集計結果（`coverage/behavior-summary.json`）:

| 指標 | 修正前 | 修正後 |
|---|---:|---:|
| 登録行（分母） | 12,298 | 12,298 |
| 要求対応 | 10,980 | **10,979** |
| 未対応 | 1,318 | **1,319** |
| 実行確認 | 7,309 | **7,324** |
| 規格全体の設計率 | 89.28% | **89.27%** |
| 規格全体の実行率 | 59.43% | **59.55%** |
| 採用スナップショット | 39 | **41** |

要求対応が1行減ったのは、`SV2023-A.10-EXTRACT-FOOTNOTE-30`
（matches が `&&` / `||` より強く結合する）の対応を外したためです。
`matches` は `cond_pattern` であり式のオペランドになれないため、この主張を
合法なテストで表せません。実行確認は、追加した Verilator 全件実行の証跡により
差し引き15行増えています。Ghost の変更前証跡は、変更したテストについて stale
になった分があり、Ghost は再実行していません。

## 4. 台帳の来歴更新

テスト入力の変更に伴い、次の台帳を更新しました。

- `coverage/behaviors.json`: 118 check の `inputs_sha256`、40 の evidence
  アンカー、2 の observation を更新。A.10 の1対応を削除。
- `coverage/test-matching-reviews.json`: 16 review の `inputs_sha256` と
  2 の evidence アンカーを更新。`$readmemh` と sequence local formal の
  explanation を新しい観測に合わせて修正。
- `coverage/behavior-baseline.json`: 上記の変更理由を `reason` に記録。

`behaviors.json` の evidence アンカーは、変更後のテストに実在する文字列へ
置き換えました。対応の意味（観測対象）を変えたのは、上記の A.10、20.7 の
real 削除、6.24.1 の packed union 化、`$readmemh` の期待値変更だけです。

## 5. 残る限界

- #11 の simulator 側 VPI 不具合（typedef 列挙の 139 終了）は別問題です。
- ch16 の checker / SVA、ch25 の interface、ch6/ch7 の tagged/soft union は
  利用可能なシミュレータがなく、期待値は規格から導出した spec-only です。
- #16 の ch22 は angle-bracket include の探索位置が実装依存のため、
  quoted include + `:incdirs:` に変更しました。angle 形式自体の受理は
  このテストでは観測しません。
- #6 の `output int y2` は宣言時初期値6に統一し、旧テストの「5 から +1」は
  観測しません。出力ポートの宣言時初期値という形は保っています。
- 人間による独立レビューは依然として未実施です。

## 6. 関連

- [カバレッジギャップ調査と追加テスト候補](coverage-gap-recommendations-20261029.md)
