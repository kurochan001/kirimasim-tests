# IEEE 1800-2023 動作カバレッジ集計

[全項目の詳細](behavior-coverage.md) / [管理手順](../coverage/README.md) / [解釈保留の根拠](../docs/requirement-extraction-notes.md)

## 全規格の要求台帳に対する暫定値

- テスト設計網羅率: **70.64%** (8702/12319)。
- 実行確認率: **39.39%** (4853/12319)。複数環境の成功の和集合。
- 分母には解釈保留と未対応も含みます。未実装・未対応を除外していません。
- 登録単位は要求の出現箇所・条件・初期の観測ケースであり、意味の重複整理前の暫定値です。
  全プログラム・全入力の組み合わせを試した割合や、単一シミュレータの規格適合率ではありません。

## 既存テストの集計状況

- 全 6658 本のうち、要求との対応を登録済みのテストは 4181 本。未登録は 2477 本です。
- 上記の網羅率は、刺激と期待結果を確認して要求との対応を登録した分だけを計上しています。
  未登録の既存テストも検証に役立ちますが、その貢献はまだ割合に反映できていません。
- 登録済み本数は少なくとも一つの要求との対応がある本数で、テスト全体のレビュー完了数ではありません。

- 複数テストで分担する要求は 544 行。各グループの全テストが同じ実行回で成功した場合だけ、要求全体の実行成功に数えます。

## 確定値

- 規格全動作のテスト設計網羅率: 未確定。
- 規格全動作の実行確認率: 未確定。
- 分母の承認: 未承認。計測状態: `provisional`。
- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定します。

## 残件

- 新鮮な成功証跡あり: 4853 行。
- 対応済み・成功証跡なし: 3849 行。
- テスト対応未確認（解釈保留以外）: 3596 行。
- 解釈保留: 21 行。

未対応は、既存テストが存在しないという判定ではありません。

## シミュレータ別の実行確認率

- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T22:03:58.531565+00:00 / `associative-count-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:04:02.952792+00:00 / `associative-count-refinement-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:04:02.961719+00:00 / `associative-count-refinement-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T21:57:27.232690+00:00 / `associative-gaps-20261023-icarus13.json`。
  失敗 0、既知不一致 23、未対応 0、未実行 8675、古い証跡 4、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 8/12319 (0.06%)。
  計測元: 2026-10-22T21:57:41.445007+00:00 / `associative-gaps-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 8675、古い証跡 4、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 8/12319 (0.06%)。
  計測元: 2026-10-22T21:57:41.445004+00:00 / `associative-gaps-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 8675、古い証跡 4、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T21:44:20.971033+00:00 / `associative-matching-20261023-icarus13.json`。
  失敗 0、既知不一致 36、未対応 0、未実行 8666、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 28/12319 (0.23%)。
  計測元: 2026-10-22T21:44:56.002490+00:00 / `associative-matching-20261023-verilator.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 8666、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-22T22:00:52.942221+00:00 / `associative-wildcard-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:00:56.310380+00:00 / `associative-wildcard-refinement-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 2/12319 (0.02%)。
  計測元: 2026-10-22T22:00:56.305806+00:00 / `associative-wildcard-refinement-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 5/12319 (0.04%)。
  計測元: 2026-10-25T15:05:38.835073+00:00 / `ch22-rehash-20261026-icarus13.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8697、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 3/12319 (0.02%)。
  計測元: 2026-10-25T15:05:47.728789+00:00 / `ch22-rehash-20261026-verilator-seed1.json`。
  失敗 0、既知不一致 3、未対応 0、未実行 8696、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 3/12319 (0.02%)。
  計測元: 2026-10-25T15:05:47.728454+00:00 / `ch22-rehash-20261026-verilator-seed73.json`。
  失敗 0、既知不一致 3、未対応 0、未実行 8696、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-25T15:43:02.687407+00:00 / `ch37-depth-20261026-icarus13.json`。
  失敗 0、既知不一致 11、未対応 0、未実行 8691、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-25T15:43:02.822987+00:00 / `ch37-depth-20261026-verilator-seed1.json`。
  失敗 0、既知不一致 11、未対応 0、未実行 8691、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-25T15:43:02.963097+00:00 / `ch37-depth-20261026-verilator-seed73.json`。
  失敗 0、既知不一致 11、未対応 0、未実行 8691、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 11/12319 (0.09%)。
  計測元: 2026-10-22T14:29:24.878016+00:00 / `citation-refinement-icarus.json`。
  失敗 0、既知不一致 12、未対応 0、未実行 8679、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 18/12319 (0.15%)。
  計測元: 2026-10-22T14:29:34.097194+00:00 / `citation-refinement-verilator.json`。
  失敗 0、既知不一致 5、未対応 0、未実行 8679、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 25/12319 (0.20%)。
  計測元: 2026-10-22T16:53:43.771888+00:00 / `expression-gaps-20261023-icarus13.json`。
  失敗 0、既知不一致 10、未対応 0、未実行 8667、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 34/12319 (0.28%)。
  計測元: 2026-10-22T16:53:54.690416+00:00 / `expression-gaps-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 8667、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 34/12319 (0.28%)。
  計測元: 2026-10-22T16:53:54.696860+00:00 / `expression-gaps-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 8667、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-24T01:44:29.848332+00:00 / `gap-refinement-20261024-icarus13.json`。
  失敗 0、既知不一致 6、未対応 0、未実行 8696、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-24T01:44:31.172684+00:00 / `gap-refinement-20261024-verilator-seed1.json`。
  失敗 0、既知不一致 6、未対応 0、未実行 8696、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-24T01:44:32.207355+00:00 / `gap-refinement-20261024-verilator-seed73.json`。
  失敗 0、既知不一致 6、未対応 0、未実行 8696、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 195/12319 (1.58%)。
  計測元: 2026-10-24T05:56:08.457193+00:00 / `gap-tests-2-20261024-icarus13.json`。
  失敗 0、既知不一致 551、未対応 0、未実行 7811、古い証跡 7、違法系の判定根拠未承認 138 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 329/12319 (2.67%)。
  計測元: 2026-10-24T05:56:23.114677+00:00 / `gap-tests-2-20261024-verilator-seed1.json`。
  失敗 0、既知不一致 478、未対応 0、未実行 7812、古い証跡 7、違法系の判定根拠未承認 76 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 329/12319 (2.67%)。
  計測元: 2026-10-24T05:56:36.426222+00:00 / `gap-tests-2-20261024-verilator-seed73.json`。
  失敗 0、既知不一致 478、未対応 0、未実行 7812、古い証跡 7、違法系の判定根拠未承認 76 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 612/12319 (4.97%)。
  計測元: 2026-10-24T01:26:42.087730+00:00 / `gap-tests-20261024-icarus13.json`。
  失敗 0、既知不一致 1336、未対応 0、未実行 6733、古い証跡 5、違法系の判定根拠未承認 16 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 348/12319 (2.82%)。
  計測元: 2026-10-24T01:27:09.178296+00:00 / `gap-tests-20261024-verilator-seed1.json`。
  失敗 0、既知不一致 1605、未対応 0、未実行 6735、古い証跡 6、違法系の判定根拠未承認 8 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 348/12319 (2.82%)。
  計測元: 2026-10-24T01:27:09.117749+00:00 / `gap-tests-20261024-verilator-seed73.json`。
  失敗 0、既知不一致 1605、未対応 0、未実行 6735、古い証跡 6、違法系の判定根拠未承認 8 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 192/12319 (1.56%)。
  計測元: 2026-10-25T14:32:08.355598+00:00 / `gap4-20261025-icarus13.json`。
  失敗 0、既知不一致 174、未対応 0、未実行 8329、古い証跡 0、違法系の判定根拠未承認 7 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 141/12319 (1.14%)。
  計測元: 2026-10-25T14:37:21.687753+00:00 / `gap4-20261025-verilator-seed1.json`。
  失敗 0、既知不一致 228、未対応 0、未実行 8330、古い証跡 0、違法系の判定根拠未承認 3 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 141/12319 (1.14%)。
  計測元: 2026-10-25T14:37:21.575982+00:00 / `gap4-20261025-verilator-seed73.json`。
  失敗 0、既知不一致 228、未対応 0、未実行 8330、古い証跡 0、違法系の判定根拠未承認 3 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 108/12319 (0.88%)。
  計測元: 2026-10-25T15:06:15.714744+00:00 / `gap5-20261026-icarus13.json`。
  失敗 0、既知不一致 218、未対応 0、未実行 8351、古い証跡 1、違法系の判定根拠未承認 24 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 71/12319 (0.58%)。
  計測元: 2026-10-25T15:09:17.553737+00:00 / `gap5-20261026-verilator-seed1.json`。
  失敗 0、既知不一致 267、未対応 0、未実行 8355、古い証跡 1、違法系の判定根拠未承認 8 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 71/12319 (0.58%)。
  計測元: 2026-10-25T15:09:17.656775+00:00 / `gap5-20261026-verilator-seed73.json`。
  失敗 0、既知不一致 267、未対応 0、未実行 8355、古い証跡 1、違法系の判定根拠未承認 8 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 117/12319 (0.95%)。
  計測元: 2026-10-25T15:38:02.072405+00:00 / `gap6-20261026-icarus13.json`。
  失敗 0、既知不一致 340、未対応 0、未実行 8238、古い証跡 0、違法系の判定根拠未承認 7 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 199/12319 (1.62%)。
  計測元: 2026-10-25T15:41:56.634097+00:00 / `gap6-20261026-verilator-seed1.json`。
  失敗 0、既知不一致 263、未対応 0、未実行 8238、古い証跡 0、違法系の判定根拠未承認 2 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 199/12319 (1.62%)。
  計測元: 2026-10-25T15:41:56.644312+00:00 / `gap6-20261026-verilator-seed73.json`。
  失敗 0、既知不一致 263、未対応 0、未実行 8238、古い証跡 0、違法系の判定根拠未承認 2 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 1/12319 (0.01%)。
  計測元: 2026-10-23T14:32:27.916089+00:00 / `header-vpi-tests-20261023-icarus13.json`。
  失敗 0、既知不一致 1277、未対応 0、未実行 7424、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 989/12319 (8.03%)。
  計測元: 2026-10-23T14:32:29.367284+00:00 / `header-vpi-tests-20261023-verilator-seed1.json`。
  失敗 0、既知不一致 289、未対応 0、未実行 7424、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 989/12319 (8.03%)。
  計測元: 2026-10-23T14:32:30.845293+00:00 / `header-vpi-tests-20261023-verilator-seed73.json`。
  失敗 0、既知不一致 289、未対応 0、未実行 7424、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 926/12319 (7.52%)。
  計測元: 2026-10-22T13:20:44.297997+00:00 / `icarus.json`。
  失敗 0、既知不一致 1803、未対応 0、未実行 5917、古い証跡 37、違法系の判定根拠未承認 19 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 497/12319 (4.03%)。
  計測元: 2026-10-23T20:48:05.640625+00:00 / `keyword-tests-20261024-icarus13.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8205、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-23T20:48:11.194190+00:00 / `keyword-tests-20261024-verilator-seed1.json`。
  失敗 0、既知不一致 4、未対応 0、未実行 8205、古い証跡 0、違法系の判定根拠未承認 493 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-23T20:48:16.559292+00:00 / `keyword-tests-20261024-verilator-seed73.json`。
  失敗 0、既知不一致 4、未対応 0、未実行 8205、古い証跡 0、違法系の判定根拠未承認 493 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-25T08:34:28.086983+00:00 / `oracle-refinement-20261025-icarus13.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 8687、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-25T08:34:28.290523+00:00 / `oracle-refinement-20261025-verilator-seed1.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 8687、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-25T08:34:28.496835+00:00 / `oracle-refinement-20261025-verilator-seed73.json`。
  失敗 0、既知不一致 15、未対応 0、未実行 8687、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-25T15:10:20.539124+00:00 / `p10-refinement-20261026-icarus13.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 8701、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-25T15:10:25.147557+00:00 / `p10-refinement-20261026-verilator-seed1.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 8701、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-25T15:10:29.594580+00:00 / `p10-refinement-20261026-verilator-seed73.json`。
  失敗 0、既知不一致 1、未対応 0、未実行 8701、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 0/12319 (0.00%)。
  計測元: 2026-10-24T23:12:32.819720+00:00 / `regex-refinement-20261025-icarus13.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-24T23:12:34.091987+00:00 / `regex-refinement-20261025-verilator-seed1.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 0/12319 (0.00%)。
  計測元: 2026-10-24T23:12:35.145250+00:00 / `regex-refinement-20261025-verilator-seed73.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 8700、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 14.0 (devel) (s20260301-411-gca6b8d376): 3/12319 (0.02%)。
  計測元: 2026-10-22T16:11:50.000804+00:00 / `subroutine-citation-refinement-20261023-icarus.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 8691、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 3/12319 (0.02%)。
  計測元: 2026-10-22T16:20:14.156213+00:00 / `subroutine-citation-refinement-20261023-icarus13.json`。
  失敗 0、既知不一致 8、未対応 0、未実行 8691、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 10/12319 (0.08%)。
  計測元: 2026-10-22T16:11:54.837539+00:00 / `subroutine-citation-refinement-20261023-verilator.json`。
  失敗 0、既知不一致 2、未対応 0、未実行 8690、古い証跡 0、違法系の判定根拠未承認 0 行。
- `icarus` / Icarus Verilog version 13.0 (stable) (v13_0-dirty): 4/12319 (0.03%)。
  計測元: 2026-10-22T16:23:03.322408+00:00 / `subroutine-initialization-group-20261023-icarus13.json`。
  失敗 0、既知不一致 0、未対応 0、未実行 8698、古い証跡 0、違法系の判定根拠未承認 0 行。
- `verilator` / Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905: 916/12319 (7.44%)。
  計測元: 2026-10-22T14:02:31.540002+00:00 / `verilator.json`。
  失敗 0、既知不一致 1804、未対応 0、未実行 5919、古い証跡 42、違法系の判定根拠未承認 21 行。
- 不採用の結果ファイル: 0 件。

## 章・附属書別（登録項目に対する割合）

- 1 Overview: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- 2 Normative references: 設計 0/2 (0.00%)、実行 0/2 (0.00%)、解釈保留 0 行。
- 3 Design and verification building blocks: 設計 111/146 (76.03%)、実行 103/146 (70.55%)、解釈保留 0 行。
- 4 Scheduling semantics: 設計 66/107 (61.68%)、実行 47/107 (43.93%)、解釈保留 0 行。
- 5 Lexical conventions: 設計 127/154 (82.47%)、実行 116/154 (75.32%)、解釈保留 0 行。
- 6 Data types: 設計 606/726 (83.47%)、実行 460/726 (63.36%)、解釈保留 0 行。
- 7 Aggregate data types: 設計 274/349 (78.51%)、実行 160/349 (45.85%)、解釈保留 0 行。
- 8 Classes: 設計 176/253 (69.57%)、実行 119/253 (47.04%)、解釈保留 0 行。
- 9 Processes: 設計 133/189 (70.37%)、実行 78/189 (41.27%)、解釈保留 2 行。
- 10 Assignment statements: 設計 125/156 (80.13%)、実行 63/156 (40.38%)、解釈保留 0 行。
- 11 Operators and expressions: 設計 399/461 (86.55%)、実行 332/461 (72.02%)、解釈保留 0 行。
- 12 Procedural programming statements: 設計 74/115 (64.35%)、実行 45/115 (39.13%)、解釈保留 0 行。
- 13 Tasks and functions (subroutines): 設計 87/121 (71.90%)、実行 69/121 (57.02%)、解釈保留 0 行。
- 14 Clocking blocks: 設計 49/87 (56.32%)、実行 35/87 (40.23%)、解釈保留 0 行。
- 15 Interprocess synchronization and communication: 設計 55/88 (62.50%)、実行 38/88 (43.18%)、解釈保留 0 行。
- 16 Assertions: 設計 393/555 (70.81%)、実行 50/555 (9.01%)、解釈保留 1 行。
- 17 Checkers: 設計 9/79 (11.39%)、実行 3/79 (3.80%)、解釈保留 0 行。
- 18 Constrained random value generation: 設計 188/320 (58.75%)、実行 75/320 (23.44%)、解釈保留 0 行。
- 19 Functional coverage: 設計 156/272 (57.35%)、実行 10/272 (3.68%)、解釈保留 2 行。
- 20 Utility system tasks and system functions: 設計 195/317 (61.51%)、実行 113/317 (35.65%)、解釈保留 1 行。
- 21 Input/output system tasks and system functions: 設計 271/384 (70.57%)、実行 156/384 (40.62%)、解釈保留 1 行。
- 22 Compiler directives: 設計 327/362 (90.33%)、実行 317/362 (87.57%)、解釈保留 0 行。
- 23 Modules and hierarchy: 設計 152/260 (58.46%)、実行 73/260 (28.08%)、解釈保留 0 行。
- 24 Programs: 設計 9/29 (31.03%)、実行 3/29 (10.34%)、解釈保留 0 行。
- 25 Interfaces: 設計 41/63 (65.08%)、実行 20/63 (31.75%)、解釈保留 2 行。
- 26 Packages: 設計 37/44 (84.09%)、実行 30/44 (68.18%)、解釈保留 0 行。
- 27 Generate constructs: 設計 24/32 (75.00%)、実行 18/32 (56.25%)、解釈保留 0 行。
- 28 Gate-level and switch-level modeling: 設計 353/384 (91.93%)、実行 269/384 (70.05%)、解釈保留 1 行。
- 29 User-defined primitives: 設計 47/52 (90.38%)、実行 36/52 (69.23%)、解釈保留 0 行。
- 30 Specify blocks: 設計 125/157 (79.62%)、実行 99/157 (63.06%)、解釈保留 0 行。
- 31 Timing checks: 設計 137/180 (76.11%)、実行 7/180 (3.89%)、解釈保留 1 行。
- 32 Backannotation using the standard delay format: 設計 114/131 (87.02%)、実行 64/131 (48.85%)、解釈保留 0 行。
- 33 Configuring the contents of a design: 設計 23/63 (36.51%)、実行 3/63 (4.76%)、解釈保留 2 行。
- 34 Protected envelopes: 設計 0/215 (0.00%)、実行 0/215 (0.00%)、解釈保留 1 行。
- 35 Direct programming interface: 設計 71/142 (50.00%)、実行 37/142 (26.06%)、解釈保留 0 行。
- 36 Programming language interface (PLI/VPI) overview: 設計 120/163 (73.62%)、実行 30/163 (18.40%)、解釈保留 0 行。
- 37 VPI object model diagrams: 設計 1508/1757 (85.83%)、実行 68/1757 (3.87%)、解釈保留 1 行。
- 38 VPI routine definitions: 設計 200/348 (57.47%)、実行 103/348 (29.60%)、解釈保留 0 行。
- 39 Assertion API: 設計 77/95 (81.05%)、実行 2/95 (2.11%)、解釈保留 1 行。
- 40 Code coverage control and API: 設計 55/128 (42.97%)、実行 34/128 (26.56%)、解釈保留 0 行。
- 41 Data read API: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- A Formal syntax: 設計 289/811 (35.64%)、実行 215/811 (26.51%)、解釈保留 2 行。
- B Keywords: 設計 248/248 (100.00%)、実行 248/248 (100.00%)、解釈保留 0 行。
- C Deprecation: 設計 0/20 (0.00%)、実行 0/20 (0.00%)、解釈保留 0 行。
- D Optional system tasks and system functions: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- E Optional compiler directives: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- F Formal semantics of concurrent assertions: 設計 0/253 (0.00%)、実行 0/253 (0.00%)、解釈保留 0 行。
- G Std package: 設計 13/32 (40.62%)、実行 11/32 (34.38%)、解釈保留 0 行。
- H DPI C layer: 設計 146/223 (65.47%)、実行 87/223 (39.01%)、解釈保留 1 行。
- I svdpi.h: 設計 77/147 (52.38%)、実行 77/147 (52.38%)、解釈保留 1 行。
- J Inclusion of foreign language code: 設計 0/16 (0.00%)、実行 0/16 (0.00%)、解釈保留 0 行。
- K vpi_user.h: 設計 508/544 (93.38%)、実行 507/544 (93.20%)、解釈保留 0 行。
- L vpi_compatibility.h: 設計 84/88 (95.45%)、実行 0/88 (0.00%)、解釈保留 0 行。
- M sv_vpi_user.h: 設計 405/412 (98.30%)、実行 405/412 (98.30%)、解釈保留 0 行。
- N Algorithm for probabilistic distribution functions: 設計 18/39 (46.15%)、実行 18/39 (46.15%)、解釈保留 1 行。
- O Encryption/decryption flow: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- P Glossary: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。
- Q Bibliography: 設計 対象項目なし、実行 対象項目なし、解釈保留 0 行。

## 分母と履歴

- 分母SHA-256: `574f40680b440c48af09b826e12eea6f459c9c16f41ae67b8a9a05fe3ab12d69`。
- 計測規則の版: 3。
- 履歴には分母の識別子、暫定値と確定値、環境別の状態内訳を保存します。
  分母が異なる回の割合を、そのまま改善・悪化として比較しません。
- この集計は保存済み実行証跡から再生成されます。上記の計測元時刻が実行時刻です。
