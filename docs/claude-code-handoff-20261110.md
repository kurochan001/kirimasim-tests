<a id="handoff-2026-11-10"></a>

# 引き継ぎ 2026-11-10

[English](claude-code-handoff-20261110.en.md) / [日本語](claude-code-handoff-20261110.md)

2026-11-09の外部レビューへの対応と、その後の判断を引き継ぐ資料です。
数値は`0370f9d4`の時点のものです。最新値は[生成した集計概要](behavior-coverage-summary.md)を、各回の詳細は[履歴](history.ja.md)を参照してください。

<a id="state"></a>

## 現在の状態

- 要求カバレッジ（テスト設計）は90.14%（11,086/12,298）です。
- 実行確認率は、第三者が再現できるIcarus Verilog・Verilator・SymbiYosysの結果で51.12%（6,287/12,298）です。これを主の値として示します。
- Ghostを含む実行確認率は78.00%（9,592/12,298）です。

| コミット | 内容 |
| --- | --- |
| `9eab9bf2`〜`829671c2` | 外部レビューの6項目。Ghostを除く実行確認率、レビュー候補の一覧、規格のみのテストの見直し、4・14・24・25・33・40章の対応付けとテスト、2023年版の新機能のテスト、ランナーのないシミュレータを履歴から外す変更 |
| `03fcaf19` | NightlyのLyraのビルドを`lyra-build`ジョブに分け、テストにジョブの6時間をすべて使えるようにした |
| `6f4bc48b` | 新しいテストでのVerilator 5.052との差18本を[差異一覧](simulator-differences.ja.md#tests-added-20261109)に追加 |
| `3d4f871a` | `tools/differences_status.py`がバッククォートを含むコードを読めるようにした。一覧の12本が報告に入る |
| `d1bc6396` | README・FAQ Q16・集計で、Ghostを除く実行確認率を先に示す |
| `908d00f9` | 実行時エラーの5要求（15.3.2〜15.3.4、25.7.4、25.9）を通常の要求にし、テストに対応付けた |
| `0370f9d4` | 固定版slangの参考判定（[slangによる参考判定](slang-reference.md)）。どこにも数えない |

kirimasimには、今回見つかった差をIssue #116〜#120として報告しました。

<a id="next-nightly"></a>

## 最初に確かめること

2026-11-10のNightlyは、Lyraのビルドを別のジョブに分けてから最初の実行です。次の点を確かめます。

- `lyra-build`と`lyra`の両ジョブが時間内に成功したか
- 各シミュレータの一致数が、前回からどう変わったか
- `results`ブランチに、レビュー候補の一覧（`review-candidates.md`）が出たか
- 差異一覧の報告（`differences-on-master.md`）に、新しく拾われた12本が入ったか

<a id="open-decisions"></a>

## 判断を待っていること

- `ch3/test_compilation_unit_shared_across_files`の扱い。どのファイルを1つのコンパイル単位にするかは、3.12.1でツールに任されています。しかしテストは、その片方を規則として扱っています。案は二つです。
  - 前提とする使い方をテストに書き、ランナーがそれを選べるようにする
  - 通常の実行から外す
- slangが拒否した規格に合うテストのうち、判断がつかない4本: `ch17/test_checker_always_statement_kinds`、`ch18/test_inline_local_scope_binding`、`ch22/test_ifdef_directive_names_not_defined`、`ch33/test_duplicate_cell_last_definition_wins`
- 次の2組を調べるか。slangへの報告は1件ずつ判断します。
  - slangが規格より厳しい48本
  - 規格違反なのにslangもkirimasimも受理した48本

<a id="deferred"></a>

## 決まっていて、後で行うこと

- 要求を観測しているのに条項を引用していない既存テスト約13本: 次にGhostの結果を保存し直すときに、引用を足します。引用を足すとテストの入力のハッシュが変わり、保存済みの結果が古くなるためです。
- VCDのテスト: 保留します。slangの次に取りかかります。
- `results`ブランチの履歴: 書き換えません。
- slangの版: kirimasimの固定に合わせます。kirimasimが固定を変えたら、ドライバーをビルドし直し、日付付きの記録を新しく作ります。

<a id="rules"></a>

## 作業の決まり

- 期待値は規格の条項から決め、シミュレータの出力を写しません。
- 商用シミュレータは実行も比較もしません。GPL/LGPLの実装（Icarus Verilog・Verilatorなど）のソースは読まず、写しません。
- 文書は日英を同時に更新します。そのあと`tools/documentation_languages.py`を`--update`、`--record`、`--check`の順に実行します。
- コミットは項目ごとに分けます。Checkが通ったことを確かめてから、次を`main`に反映します。
- メタデータ、集計方法、`results`ブランチの扱いを変える変更は、案を示して承認を得てから行います。
- 生成テストは生成器を直します。生成済みのファイルは直接編集しません。
- 期待値を直したテストには、理由と引用した条項を、テストのコメントと履歴に残します。
- `:spec_check: ai`は、人が照合するまで変えません。
- 要求の契約（種類など）を変えたら、`tools/behavior_coverage.py --update --write-baseline --reason "..."`で基準を書き直します。
