<a id="documentation"></a>

# ドキュメント一覧

[English](README.md) / [日本語](README.ja.md)

日英の資料を同じ章立て・内容で管理します。現在の数値と実行手順は[README](../README.ja.md)、過去の作業と測定は[履歴](history.ja.md)を参照してください。

コード・識別子・生の実行記録・ライセンス条文は原形を保ちます。生成資料も両言語を同時に更新します。

[章間マトリクス](chapter-cross-matrix.md)と[未登録章対の仕分け](chapter-cross-triage.md)からは、日英のCSVにも辿れます。

<a id="read-by-purpose"></a>

## 目的から読む

- 初めてテストを1本読む：[実在する短いテストの読み解き](faq.md#q49-read-a-real-test) → [テストカタログ](tests/README.ja.md)。
- Nightlyの結果を読む：[緑でもDifferが残る理由](faq.md#q11-why-can-nightly-be-green-with-differ-results) → [版・日時と結果の確認手順](nightly-results.md#read-a-result-row)。
- 何が検証済みか調べる：[設計と実行確認の違い](faq.md#q16-how-do-design-and-execution-coverage-differ) → [要求の集計](behavior-coverage-summary.md)／[章間表](chapter-cross-matrix.md)。

<a id="guides-and-technical-references"></a>

## ガイド・技術資料

| 資料 | 日本語 | English |
| --- | --- | --- |
| kirimasim-tests | [日本語](../README.ja.md) | [English](../README.md) |
| 規格要求のカバレッジを管理する | [日本語](../coverage/README.md) | [English](../coverage/README.en.md) |
| 機能間クロス検証の補助証跡 | [日本語](../coverage/interaction-qualification/README.md) | [English](../coverage/interaction-qualification/README.en.md) |
| 章間クロス検証マトリクス | [日本語](chapter-cross-matrix.md) | [English](chapter-cross-matrix.en.md) |
| クロス検証の不一致対応と次の優先順位 | [日本語](cross-verification-followup.md) | [English](cross-verification-followup.en.md) |
| kirimasim-testsのFAQ | [日本語](faq.md) | [English](faq.en.md) |
| kirimasim-testsの用語集 | [日本語](glossary.md) | [English](glossary.en.md) |
| 機能間クロス検証の考え方と実践手順 | [日本語](interaction-verification-method.md) | [English](interaction-verification-method.en.md) |
| 機能間クロス検証の導入 | [日本語](interaction-verification.md) | [English](interaction-verification.en.md) |
| Nightly resultsの更新時刻と見方 | [日本語](nightly-results.md) | [English](nightly-results.en.md) |
| IEEE 1800-2023 第34章（保護エンベロープ）215 要求の境界監査 | [日本語](protected-envelope-boundary.md) | [English](protected-envelope-boundary.en.md) |
| モデルに基づくランダムクロス比較 | [日本語](random-cross-verification.md) | [English](random-cross-verification.en.md) |
| IEEE 1800-2023 要求抽出の解釈・再検討記録 | [日本語](requirement-extraction-notes.md) | [English](requirement-extraction-notes.en.md) |
| IEEE 1800-2023 全要求の洗い出し結果 | [日本語](requirement-extraction.md) | [English](requirement-extraction.en.md) |
| IEEE 1800-2023のPDFから要求を抽出し、テストで検証する手順 | [日本語](requirements-to-tests-method.md) | [English](requirements-to-tests-method.en.md) |
| Icarus Verilog 13.0とVerilator 5.052が標準と異なる場合 | [日本語](simulator-differences.ja.md) | [English](simulator-differences.md) |
| ロジック設計の仕様書から検証項目とテストシナリオを作成する手順 | [日本語](spec-to-verification-method.md) | [English](spec-to-verification-method.en.md) |
| SVA参照評価器とフォーマル検証 | [日本語](sva-reference-formal-verification.md) | [English](sva-reference-formal-verification.en.md) |
| ドキュメントの翻訳データ | [日本語](../tools/doc_locales/README.ja.md) | [English](../tools/doc_locales/README.md) |
| マッチングキット | [日本語](../tools/matching_kit/README.ja.md) | [English](../tools/matching_kit/README.md) |
| 記号的フォーマル検査（2026-10-26。2026-10-29 を更新しました | [日本語](../tools/sva_reference/FORMAL_REVIEW.ja.md) | [English](../tools/sva_reference/FORMAL_REVIEW.md) |
| M3 2026-10-26 差異点検討 | [日本語](../tools/sva_reference/M3_REVIEW.ja.md) | [English](../tools/sva_reference/M3_REVIEW.md) |
| M4：シングルクロックサンプル関数（2026-10-26） | [日本語](../tools/sva_reference/M4_REVIEW.ja.md) | [English](../tools/sva_reference/M4_REVIEW.md) |
| SVA参照評価器とフォーマル検査 | [日本語](../tools/sva_reference/README.ja.md) | [English](../tools/sva_reference/README.md) |
| 期待値のレビュー候補 | [日本語](review-candidates.md) | [English](review-candidates.en.md) |
| slangによる参考判定 | [日本語](slang-reference.md) | [English](slang-reference.en.md) |

<a id="generated-reports-and-catalogs"></a>

## 自動生成レポート・カタログ

| 資料 | 日本語 | English |
| --- | --- | --- |
| IEEE 1800-2023 要求カバレッジ集計 | [日本語](behavior-coverage-summary.md) | [English](behavior-coverage-summary.en.md) |
| IEEE 1800-2023 要求カバレッジ | [日本語](behavior-coverage.md) | [English](behavior-coverage.en.md) |
| 章間クロスの0セルの仕分け | [日本語](chapter-cross-triage.md) | [English](chapter-cross-triage.en.md) |
| カバレッジの深さ | [日本語](coverage-depth.ja.md) | [English](coverage-depth.md) |
| 生成器カタログ | [日本語](generators.ja.md) | [English](generators.md) |
| 機能間クロスの計画と実行確認 | [日本語](interaction-coverage.md) | [English](interaction-coverage.en.md) |
| Issue #21：組合せ境界の回帰取り込み | [日本語](p1-combination-regressions-20261030.md) | [English](p1-combination-regressions-20261030.en.md) |
| 既存テストと規格要求の照合 | [日本語](test-requirement-matching.md) | [English](test-requirement-matching.en.md) |
| テストの一覧 | [日本語](tests/README.ja.md) | [English](tests/README.md) |
| 第10章：代入文 | [日本語](tests/ch10.ja.md) | [English](tests/ch10.md) |
| 第11章：演算子と式 | [日本語](tests/ch11.ja.md) | [English](tests/ch11.md) |
| 第12章：手続き型プログラミング文 | [日本語](tests/ch12.ja.md) | [English](tests/ch12.md) |
| 第13章：タスクと関数（サブルーチン） | [日本語](tests/ch13.ja.md) | [English](tests/ch13.md) |
| 第14章：クロッキングブロック | [日本語](tests/ch14.ja.md) | [English](tests/ch14.md) |
| 第15章：プロセス間の同期と通信 | [日本語](tests/ch15.ja.md) | [English](tests/ch15.md) |
| 第16章：アサーション | [日本語](tests/ch16.ja.md) | [English](tests/ch16.md) |
| 第17章：チェッカ | [日本語](tests/ch17.ja.md) | [English](tests/ch17.md) |
| 第18章：制約付きランダム値生成 | [日本語](tests/ch18.ja.md) | [English](tests/ch18.md) |
| 第19章：機能カバレッジ | [日本語](tests/ch19.ja.md) | [English](tests/ch19.md) |
| 第20章：ユーティリティのシステムタスクとシステム関数 | [日本語](tests/ch20.ja.md) | [English](tests/ch20.md) |
| 第21章：入出力のシステムタスクとシステム関数 | [日本語](tests/ch21.ja.md) | [English](tests/ch21.md) |
| 第22章：コンパイラ指示子 | [日本語](tests/ch22.ja.md) | [English](tests/ch22.md) |
| 第23章：モジュールと階層 | [日本語](tests/ch23.ja.md) | [English](tests/ch23.md) |
| 第24章：プログラム | [日本語](tests/ch24.ja.md) | [English](tests/ch24.md) |
| 第25章：インタフェース | [日本語](tests/ch25.ja.md) | [English](tests/ch25.md) |
| 第26章：パッケージ | [日本語](tests/ch26.ja.md) | [English](tests/ch26.md) |
| 第27章：generate構文 | [日本語](tests/ch27.ja.md) | [English](tests/ch27.md) |
| 第28章：ゲートレベルとスイッチレベルのモデリング | [日本語](tests/ch28.ja.md) | [English](tests/ch28.md) |
| 第29章：ユーザ定義プリミティブ | [日本語](tests/ch29.ja.md) | [English](tests/ch29.md) |
| 第3章：設計と検証の構成要素 | [日本語](tests/ch3.ja.md) | [English](tests/ch3.md) |
| 第30章：specifyブロック | [日本語](tests/ch30.ja.md) | [English](tests/ch30.md) |
| 第31章：タイミング検査 | [日本語](tests/ch31.ja.md) | [English](tests/ch31.md) |
| 第32章：標準遅延フォーマットによるバックアノテーション | [日本語](tests/ch32.ja.md) | [English](tests/ch32.md) |
| 第33章：デザインの内容の構成 | [日本語](tests/ch33.ja.md) | [English](tests/ch33.md) |
| 第34章：保護エンベロープ | [日本語](tests/ch34.ja.md) | [English](tests/ch34.md) |
| 第35章：ダイレクトプログラミングインタフェース | [日本語](tests/ch35.ja.md) | [English](tests/ch35.md) |
| 第36章：プログラミング言語インタフェース（PLI／VPI）の概要 | [日本語](tests/ch36.ja.md) | [English](tests/ch36.md) |
| 第37章：VPIのオブジェクトモデル図 | [日本語](tests/ch37.ja.md) | [English](tests/ch37.md) |
| 第38章：VPIのルーチン定義 | [日本語](tests/ch38.ja.md) | [English](tests/ch38.md) |
| 第39章：アサーションのAPI | [日本語](tests/ch39.ja.md) | [English](tests/ch39.md) |
| 第4章：スケジューリングの意味規則 | [日本語](tests/ch4.ja.md) | [English](tests/ch4.md) |
| 第40章：コードカバレッジの制御とAPI | [日本語](tests/ch40.ja.md) | [English](tests/ch40.md) |
| 第5章：字句規則 | [日本語](tests/ch5.ja.md) | [English](tests/ch5.md) |
| 第6章：データ型 | [日本語](tests/ch6.ja.md) | [English](tests/ch6.md) |
| 第7章：集合体データ型 | [日本語](tests/ch7.ja.md) | [English](tests/ch7.md) |
| 第8章：クラス | [日本語](tests/ch8.ja.md) | [English](tests/ch8.md) |
| 第9章：プロセス | [日本語](tests/ch9.ja.md) | [English](tests/ch9.md) |
| テストが引用する条項 | [日本語](tests/clauses.ja.md) | [English](tests/clauses.md) |

<a id="historical-records"></a>

## 過去の作業・測定記録

| 資料 | 日本語 | English |
| --- | --- | --- |
| 連想配列のレビューで不足していた観測へのテスト追加（2026-10-23） | [日本語](associative-gap-tests-20261023.md) | [English](associative-gap-tests-20261023.en.md) |
| Claude Codeへのハンドオフ：50%到達作業（2026-10-23開始、2026-10-24に50%到達） | [日本語](claude-code-handoff-20261023-50percent.md) | [English](claude-code-handoff-20261023-50percent.en.md) |
| Claude Codeへのハンドオフ（2026-10-23） | [日本語](claude-code-handoff-20261023.md) | [English](claude-code-handoff-20261023.en.md) |
| Claude Codeへの引き継ぎ：機能間クロス検証（2026-10-30） | [日本語](claude-code-handoff-20261030-cross-verification.md) | [English](claude-code-handoff-20261030-cross-verification.en.md) |
| Codexへの引き継ぎ：テスト側指摘の対応とクロス検証（2026-10-31） | [日本語](codex-handoff-20261031.md) | [English](codex-handoff-20261031.en.md) |
| 引き継ぎ：クロス検証とモデルに基づくランダム比較（2026-11-02） | [日本語](codex-handoff-20261102.md) | [English](codex-handoff-20261102.en.md) |
| カバレッジギャップ調査と追加テスト候補（2026-10-29） | [日本語](coverage-gap-recommendations-20261029.md) | [English](coverage-gap-recommendations-20261029.en.md) |
| 規格テストの補強（2026-10-22） | [日本語](coverage-strengthening-20261022.md) | [English](coverage-strengthening-20261022.en.md) |
| 分母レビュー 2026-10-28 | [日本語](denominator-review-20261028.md) | [English](denominator-review-20261028.en.md) |
| 既存テストの要求照合：20%超過の結果（2026-10-23） | [日本語](existing-test-matching-20percent-20261023.md) | [English](existing-test-matching-20percent-20261023.en.md) |
| 既存テストの要求照合：配列メソッド（2026-10-23） | [日本語](existing-test-matching-array-methods-20261023.md) | [English](existing-test-matching-array-methods-20261023.en.md) |
| 既存テストの要求照合：連想配列（2026-10-23） | [日本語](existing-test-matching-associative-arrays-20261023.md) | [English](existing-test-matching-associative-arrays-20261023.en.md) |
| 既存テストの要求照合：クラス・構築・メソッド（2026-10-23） | [日本語](existing-test-matching-classes-20261023.md) | [English](existing-test-matching-classes-20261023.en.md) |
| 既存テストの要求照合：制御文・ループ（2026-10-23） | [日本語](existing-test-matching-control-flow-20261023.md) | [English](existing-test-matching-control-flow-20261023.en.md) |
| 既存テストの要求照合：式・幅・符号・算術（2026-10-23） | [日本語](existing-test-matching-expressions-20261023.md) | [English](existing-test-matching-expressions-20261023.en.md) |
| 既存テストの要求照合：コンパイラ指令（2026-10-23） | [日本語](existing-test-matching-preprocessor-20261023.md) | [English](existing-test-matching-preprocessor-20261023.en.md) |
| 既存テストの要求照合で見つかった問題（2026-10-22開始、2026-10-23更新） | [日本語](existing-test-matching-review-20261022.md) | [English](existing-test-matching-review-20261022.en.md) |
| 既存テストの要求照合：代入系の続行結果（2026-10-23） | [日本語](existing-test-matching-review-20261023.md) | [English](existing-test-matching-review-20261023.en.md) |
| 既存テストの要求照合：サブルーチン（2026-10-23） | [日本語](existing-test-matching-subroutines-20261023.md) | [English](existing-test-matching-subroutines-20261023.en.md) |
| 未登録テストの照合：第1回（2026-10-25） | [日本語](existing-test-matching-unregistered-20261025.md) | [English](existing-test-matching-unregistered-20261025.en.md) |
| 既存テストの要求照合：VPIと10%到達（2026-10-23） | [日本語](existing-test-matching-vpi-20261023.md) | [English](existing-test-matching-vpi-20261023.en.md) |
| 式のレビューで不足していた観測へのテスト追加（2026-10-23） | [日本語](expression-gap-tests-20261023.md) | [English](expression-gap-tests-20261023.en.md) |
| kirimasim波形バックエンド（2026-10-29）に対するFSTテスト | [日本語](fst-tests-20261029.ja.md) | [English](fst-tests-20261029.md) |
| 未対応要求への新規テスト、2回目（2026-10-24） | [日本語](gap-tests-2-20261024.md) | [English](gap-tests-2-20261024.en.md) |
| 未対応要求への新規テスト（50%到達、2026-10-24） | [日本語](gap-tests-20261024.md) | [English](gap-tests-20261024.en.md) |
| 引き継ぎ 2026-10-28（2026-10-29更新） | [日本語](handover-20261028.md) | [English](handover-20261028.en.md) |
| 附属書ヘッダ・VPIテストの追加と既存テストの照合（2026-10-23） | [日本語](header-vpi-tests-and-matching-20261023.md) | [English](header-vpi-tests-and-matching-20261023.en.md) |
| 履歴 | [日本語](history.ja.md) | [English](history.md) |
| スイートの棚卸し、2026-10-21 | [日本語](inventory-20261021.ja.md) | [English](inventory-20261021.md) |
| Issue #40〜#44 の規格照合とテスト修正（2026-10-31） | [日本語](issues-40-44-review-20261031.md) | [English](issues-40-44-review-20261031.en.md) |
| 予約語の規格違反テストの生成（2026-10-24） | [日本語](keyword-tests-20261024.md) | [English](keyword-tests-20261024.en.md) |
| Lyra と一致しない「規格のみ」のテストの見直し（2026-10-25） | [日本語](lyra-disagreement-review-20261025.md) | [English](lyra-disagreement-review-20261025.en.md) |
| NightlyのDifferから見つかったテスト側の問題の修正 | [日本語](nightly-suite-corrections-20261027.md) | [English](nightly-suite-corrections-20261027.en.md) |
| P1「組合せの不足」の具体例（2026-10-30） | [日本語](p1-combination-gaps-20261030.md) | [English](p1-combination-gaps-20261030.en.md) |
| 品質監査 2026-10-27 | [日本語](quality-audit-20261027.md) | [English](quality-audit-20261027.en.md) |
| READMEから移した記録：2026-10-25〜2026-11-01 | [日本語](readme-records-20261101.ja.md) | [English](readme-records-20261101.md) |
| シミュレーションランナーの選択と分類（2026-10-28） | [日本語](runner-selection-20261028.md) | [English](runner-selection-20261028.en.md) |
| SVAフォーマル検証の拡張：境界値と実テストとの対応 | [日本語](sva-formal-expansion-20261026.md) | [English](sva-formal-expansion-20261026.en.md) |
| 全テスト内容レビュー（2026-10-22） | [日本語](test-content-review-20261022.md) | [English](test-content-review-20261022.en.md) |
| 修正後の再レビュー（2026-10-22） | [日本語](test-content-review-followup-20261022.md) | [English](test-content-review-followup-20261022.en.md) |
| テスト側失敗 40 本のトリアージ（2026-10-28） | [日本語](test-failure-triage-20261028.md) | [English](test-failure-triage-20261028.en.md) |
| テスト側の失敗と Issue #6–#19 の修正（2026-10-28） | [日本語](test-side-fixes-20261028.md) | [English](test-side-fixes-20261028.en.md) |
| Claude Codeへの引き継ぎ（2026-11-06） | [日本語](codex-handoff-20261106.md) | [English](codex-handoff-20261106.en.md) |
| Issue #45・#47 の規格照合とテスト修正（2026-11-07） | [日本語](issues-45-47-review-20261107.md) | [English](issues-45-47-review-20261107.en.md) |
| Issue #24・#27・#28 の判断とテスト修正（2026-11-07） | [日本語](issues-24-27-28-review-20261107.md) | [English](issues-24-27-28-review-20261107.en.md) |
| Issue #48〜#57 の判断とテスト修正（2026-11-07） | [日本語](issues-48-57-review-20261107.md) | [English](issues-48-57-review-20261107.en.md) |
| 「規格のみ」のテストの見直し（2026-11-09） | [日本語](spec-only-review-20261109.md) | [English](spec-only-review-20261109.en.md) |
| 33章と40章：規格が決める範囲、ツールに任せる範囲、テストできる要求（2026-11-09） | [日本語](clauses-33-40-testability-20261109.md) | [English](clauses-33-40-testability-20261109.en.md) |
| 引き継ぎ 2026-11-10 | [日本語](claude-code-handoff-20261110.md) | [English](claude-code-handoff-20261110.en.md) |
| Ghost 2026-11-11 実行の仕分け | [日本語](ghost-triage-20261111.md) | [English](ghost-triage-20261111.en.md) |
| 不正な設計のテストのoracleトークンの見直し（2026-11-12） | [日本語](oracle-token-review-20261112.md) | [English](oracle-token-review-20261112.en.md) |
| どのシミュレータでも合格しないテストの見直し（2026-11-12） | [日本語](pass-nowhere-review-20261112.md) | [English](pass-nowhere-review-20261112.en.md) |
| 引き継ぎ 2026-11-12 | [日本語](claude-code-handoff-20261112.md) | [English](claude-code-handoff-20261112.en.md) |
| Ghostだけが一致するテストの見直し：37章（2026-11-13） | [日本語](ghost-only-review-ch37-20261113.md) | [English](ghost-only-review-ch37-20261113.en.md) |
| Ghostだけが一致するテストの見直し：16章（2026-11-13） | [日本語](ghost-only-review-ch16-20261113.md) | [English](ghost-only-review-ch16-20261113.en.md) |
