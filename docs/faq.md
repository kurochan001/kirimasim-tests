<a id="kirimasim-tests-faq"></a>

# kirimasim-testsのFAQ

[English](faq.en.md) / [README](../README.ja.md)

テストの読み方、期待値の根拠、Nightly、網羅率、SVA・フォーマル検証、変更後の確認についてまとめています。用語の意味は[用語集](glossary.md)、全体像と実行手順は[README](../README.ja.md)を参照してください。

対象はkirimasim-testsです。シミュレータ本体の設計・導入や、一般的なLSI検証手法の説明は、それぞれの資料を参照してください。変動する最新件数は集計へリンクします。以下の数値例は、説明用か、日付・実行回を明記した保存記録です。

<a id="contents"></a>

## 目次

- [導入と実行](#1-導入と実行)
- [期待結果とメタデータ](#2-期待結果とメタデータ)
- [Nightlyと結果の見方](#3-nightlyと結果の見方)
- [要求とカバレッジ](#4-要求とカバレッジ)
- [SVAとフォーマル検証](#5-svaとフォーマル検証)
- [テストの修正と記録](#6-テストの修正と記録)
- [機能間クロス検証](#7-機能間クロス検証)
- [商用シミュレータでの確認状況](#8-商用シミュレータでの確認状況)
- [モデルに基づくランダム比較](#model-based-random-comparisons)

- [初めて読むための具体例](#10-reading-examples)

<a id="1-getting-started"></a>

## 1. 導入と実行

<a id="q1-what-does-this-repository-test"></a>

### Q1. このリポジトリは何を検査するものですか

SystemVerilogのシミュレータがIEEE 1800-2023の規定どおりに動くかを調べるテスト集です。小さな設計に入力を与え、出力や診断・終了条件を期待結果と比較します。名前にkirimasimが付いていますが、Icarus Verilog、Verilator、Lyra、Ghostのランナーと、SymbiYosysによるフォーマル検証のランナーもあります。製品RTLの機能を網羅的に検証するテストベンチや、シミュレータ本体を配布するリポジトリではありません。[全体説明](../README.ja.md)と[実行方法](../README.ja.md#running-the-suite)を参照してください。

<a id="q2-where-should-i-start"></a>

### Q2. どこから読み始めればよいですか

実行するなら[Running the suite](../README.ja.md#running-the-suite)、個別のテストを探すなら[テストカタログ](tests/README.ja.md)、結果を読むなら[Nightlyの見方](nightly-results.md)から始めてください。規格の要求からテスト・証跡までの対応を知りたい場合は[要求からテストへの手順](requirements-to-tests-method.md)に全体の流れがあります。

<a id="q3-can-i-run-just-one-test"></a>

### Q3. まず1本だけ実行できますか

ランナーにテストのパスを渡します。たとえばIcarus Verilog 13.0の`iverilog`と`vvp`があるディレクトリを`IVERILOG13_BIN`へ設定し、リポジトリのルートで次を実行します。

```sh
python3 tools/run_icarus.py --iverilog-bin "$IVERILOG13_BIN" \
  tests/ch10/test_declaration_initialization_is_not_driver.sv
```

ランナーにはPython 3.10以上が必要です。複数本の指定、並列数の`-j N`、記録先の`--json FILE`も使えます。シミュレータやCコードのビルドに必要なものはツールごとに異なります。全件を回す前に[各ランナーの前提条件](../README.ja.md#running-the-suite)を確認してください。

Icarus・Verilator・kirimasim・Lyra・Ghostは、明示指定でも`:type: formal`を除外します。その範囲で、テストを指定しない場合はIcarus・kirimasim・Lyra・Ghostが全件、Verilatorが`:oracle:`に`verilator@5.052`があるテストを選び、Verilatorの`--all`はformal以外の全件を選びます。formalは`:formal_case:`を指定したモデル検査で、`tools/run_sby.py`を使います。[SymbiYosysの実行方法](../README.ja.md#symbiyosys)を参照してください。

初めてコードを読む場合は、[Q49の実在テストの読み解き](#q49-read-a-real-test)で、入力・観測・期待値の順に確認できます。

<a id="2-expectations-and-metadata"></a>

## 2. 期待結果とメタデータ

<a id="q4-are-expected-outputs-copied-from-a-simulator"></a>

### Q4. 期待出力はシミュレータの結果をコピーして決めていますか

引用条文から先に期待結果を決め、固定バージョンシミュレータで確認できた場合にその版を`:oracle:`へ記録します。食い違ったときはテスト・規格解釈・実装のどこに原因があるか調べます。複数ツールが同じ値を出すことだけで正解を決めません。[期待値の決め方](../README.ja.md#where-the-expected-outputs-come-from)を参照してください。

出力比較では空行やツール固有の表示を除きますが、文字のある行の空白は詰めません。空白だけの違いでも不一致になる場合があります。[正規化処理](../tools/normalize_output.py)と各ランナーが除く表示を確認してください。

`:lrm:`は「どの規則を検査するか」、`:oracle:`は「どの規格照合・固定版で期待結果を確認したか」を記録します。後者のツール名は、現在の開発版の成功や、節全体の検証完了を意味しません。実際のヘッダと期待値の対応は[Q49](#q49-read-a-real-test)で確認できます。専用期待値がある場合は共通期待値より優先しますが、規格が許すツール依存の表示等に限り、理由を記録します。多数決で期待値を変える規則ではありません。

実際の[符号付きtask出力の差異](simulator-differences.ja.md#generated-subroutine-copyout)では、固定Verilatorの上位ビットが規格由来の符号拡張と異なりました。元の期待値を保持し、同じ期待値になるfunction対照と実出力を記録しています。ツールに合わせて期待値を緩める対応ではありません。

<a id="q5-is-a-test-with-only-oracle-spec-unreliable"></a>

### Q5. `:oracle: spec`だけなら、そのテストは信用できないのでしょうか

規格を根拠に期待結果を記録していますが、固定バージョンシミュレータでの確認は記録していない状態です。未対応機能やツール側の規格との差が理由になる場合があります。根拠の条文、テスト冒頭の説明、観測する条件、`:spec_check:`を確認してください。`spec`というラベル自体が期待値の無誤りを保証するものでもありません。[メタデータ](../README.ja.md#metadata)と[固定バージョンの相違点](simulator-differences.ja.md)に詳しく説明しています。

<a id="q6-why-distinguish-fixed-releases-from-nightly-development-versions"></a>

### Q6. 固定バージョンとNightlyの開発版は、なぜ分けるのですか

固定バージョンはoracleに記録した期待結果を継続して再現するため、開発版は機能追加や回帰を追うためです。`iverilog@13.0`の確認を別リリースへ読み替えたり、Nightlyで一致しただけでその固定バージョンの確認済みとしたりはしません。Verilator 5.052のoracle確認では、初期値の乱数seedを変えた実行も行います。[期待値の決め方](../README.ja.md#where-the-expected-outputs-come-from)と[ワークフロー](../README.ja.md#workflows)を参照してください。

<a id="q7-does-any-error-make-an-illegal-design-test-pass"></a>

### Q7. 規格違反のコードなら、何らかのエラーが出れば合格ですか

意図した規格違反を検出したかを確認します。先に別の構文誤りで止まった場合や、未対応機能として拒否された場合は、その規格違反を検査した証拠にはできません。診断が宣言・使用箇所・展開先のどこへ付くかも確認し、妥当な位置と必要な診断内容をパターンへ反映します。エラー位置だけでは誤って成功扱いすることもあるため、oracle登録には診断のレビューが必要です。[判定方法](../README.ja.md#how-a-test-is-judged)と[診断テストの修正例](nightly-suite-corrections-20261027.md)を参照してください。

<a id="q8-can-verilator-alone-confirm-fourstate-yes"></a>

### Q8. `:fourstate: yes`をVerilatorだけで確認できますか

このスイートでVerilatorの固定バージョンoracleに使うのは、X/Zに依存しないテストです。2値化した結果では、未知値や高インピーダンスを含む演算・分岐・ネットの振る舞いを同等に確認できません。`:fourstate:`と、実際に比較している値を確認してください。[メタデータ](../README.ja.md#metadata)と[Verilatorの実行条件](../README.ja.md#verilator)を参照してください。

<a id="3-reading-nightly-results"></a>

## 3. Nightlyと結果の見方

<a id="q9-what-do-match-differ-known-difference-and-unsupported-mean"></a>

### Q9. Match、Differ、Known difference、Unsupportedは何が違いますか

Matchは期待結果との一致、Differは判定条件の不一致です。Known differenceはIcarus・Verilatorの固定バージョンoracleがないテストの不一致を分ける区分で、成功には数えません。kirimasimでも、使える共通・専用の期待出力がなく、他ツール専用の期待出力だけがある場合はKnown differenceになります。Unsupportedはランナーが認識する未対応機能や実行できないテストの区分です。未対応と認識されないコンパイル失敗がDifferになる場合もあります。ランナーによって区分の条件が異なるので、同じ列名の件数だけで比較せず、[結果の定義](../README.ja.md#result-statuses)と個別ログを確認してください。

Matchには規格違反のコードを適切に拒否した結果も含みます。また、Icarus・Verilatorの端末の要約は、その固定バージョンoracleが付いたテストを分母にします。`--json`ではoracle未登録でも判定に一致すれば`pass`となり、Nightlyはその結果も数えます。`NOW MATCHES`はIcarusランナーがこの一致を知らせる表示で、oracleの自動認定ではありません。

表から原因へ進むには、まず行の日時・suite commit・シミュレータ版を確認し、[公開レポートの`latest/kirimasim.json`](https://github.com/kurochan001/kirimasim-tests/blob/results/latest/kirimasim.json)等でテストID別の区分を調べます。この公開JSONは区分の索引です。理由は同じworkflow runの`results-kirimasim` artifactにある`kirimasim.json`の`reason`と`kirimasim.log`で確認します。Ghostの非公開診断を求めたり投稿したりする手順には読み替えません。

<a id="q10-is-the-differ-count-the-simulators-bug-count"></a>

### Q10. Differの件数は、そのシミュレータのバグ数ですか

失敗したテストの本数です。1つの不具合が複数テストに現れる場合も、テストの期待値・規格適合性・診断条件に誤りがある場合もあります。規格と照合し、原因を切り分けてから不具合を報告します。[Nightlyから見つかったテスト側の修正例](nightly-suite-corrections-20261027.md)には、診断位置の問題と、本体側に残った不具合のIssueを分けて記録しています。

<a id="q11-why-can-nightly-be-green-with-differ-results"></a>

### Q11. Nightlyが緑なのにDifferが残るのはなぜですか

Nightlyは各シミュレータの対応状況を記録するため、全テストの一致を成功条件にはしていません。現在のkirimasimのratchetは、前回`pass`だったテストが今回`fail`になった場合に失敗します。新規テストや前回から失敗していたテストは、その条件だけでは回帰失敗になりません。固定バージョンoracleの維持や台帳の整合性は別のCheckワークフローで確認します。[ワークフロー](../README.ja.md#workflows)を参照してください。

この説明は固定スイートの集計です。追加の[ランダム比較](random-cross-verification.md)は全ケースの有効なPASSを要求し、未対応・時間切れも成功にはしません。専用artifactに再現資料を保存し、固定スイートの結果へ混ぜません。

現在のratchetでは、前回`pass`から今回`unsupported`への変化も失敗の対象外です。緑の表示に加え、結果区分の変化と個別ログを確認してください。

具体例は[2026-11-04に確認した保存レポート](nightly-results.md#checkpoint-9926160a)です。この回のkirimasim固定suiteは7,868 pass・2,403 unsupported・133 failで、Check・Nightlyは成功しています。これは当該回の規定ゲートが成功したという記録であり、133件が合格したことにはなりません。個別テストを判断するには[Q9の区分とログの確認先](#q9-what-do-match-differ-known-difference-and-unsupported-mean)へ進みます。

<a id="q12-what-percentage-does-by-chapter-show"></a>

### Q12. READMEのBy chapterの割合は何を表しますか

章別・環境別に、そのシミュレータの最新の保存結果に含まれる一致数を、その結果で記録されたテスト数で割った割合です。環境間で取得日・スイートのコミット・シミュレータの版が異なる場合があります。Known differenceとUnsupportedも分母に含み、未対応として実行を省略したCコード付きテストなども含みます。図には実行日とシミュレータの版があり、[公開レポート](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)にはsuite commitへのリンクがあります。この割合は規格要求の網羅率ではありません。[章別比較](../README.ja.md#by-chapter)を参照してください。

説明用に、ある章の保存結果が8 pass・1 known・1 unsupportedなら、表示は8/10＝80%です。unsupportedの1件を除いた8/9ではありません。この10件は「結果が登録されたテスト」であり、10件すべてがシミュレータ内部まで実行されたという意味ではありません。

<a id="q13-why-did-graphs-or-counts-not-change-after-a-main-push"></a>

### Q13. mainへpushしたのにグラフや件数が変わりません

mainの更新とNightly結果の公開は別の処理です。その変更を含む実行とpublishが完了して初めて図が更新されます。開始予定は毎日04:23 JSTですが、待機・開始遅延・ビルド時間で公開時刻は変わります。結果の時刻はUTC表示なのでJSTでは9時間を加えます。suite commitとテスト数、各ジョブとpublishの状態を確認してください。[更新時刻の説明](nightly-results.md)に確認手順があります。

<a id="q14-why-do-main-results-or-simulator-totals-differ"></a>

### Q14. `main`と`results`、または各シミュレータで集計が違うのはなぜですか

mainは現在のテスト・ツールと保存済み証跡、resultsはNightlyで公開した実行回を表します。対象コミット、ツール版、テスト数、記録の範囲が異なり得ます。また`latest/<simulator>.json`は環境ごとの最後の結果なので、結果を出す前にジョブが失敗すると更新元の実行回が揃わないことがあります。欠けた環境へ過去の成功を補って、その回の成功とは扱いません。[mainとNightlyの計測規則](../coverage/README.md#mainの集計とnightlyの集計)を参照してください。

<a id="4-requirements-and-coverage"></a>

## 4. 要求とカバレッジ

<a id="q15-is-the-nightly-match-rate-requirement-coverage"></a>

### Q15. Nightlyの一致率と要求カバレッジは同じですか

分母が異なります。Nightlyの一致率はテスト本数に対する割合です。要求カバレッジは、規格から抽出した要求・条件・観測の登録行に対し、レビュー済みの対応やパス結果の記録がある割合です。1本のテストが複数要求に対応する場合も、1要求を複数テストで分担する場合もあります。[集計概要](behavior-coverage-summary.md)と[計測規則](../coverage/README.md#計測の意味)を参照してください。

第19章のcovergroupを試すテストの件数とも異なります。covergroupはSVの機能カバレッジ機能そのものを試す対象で、そのbinのヒット数をこの要求台帳のPASS数へ転記する仕組みではありません。何を数える割合かを、指標名と対象集合で確認してください。

<a id="q16-how-do-design-and-execution-coverage-differ"></a>

### Q16. 要求カバレッジ（テスト設計）と実行確認率は何が違いますか

要求カバレッジ（テスト設計）は、要求の観測点を確認してテスト対応を登録できた割合です。実行確認率は、現在の入力・ランナーに対応する、採用可能なパス結果の記録がある割合です。説明用に要求100件のうち60件へ対応し、40件にパス結果の記録があれば、前者60%、後者40%となります。複数環境の成功の和集合は、1つのシミュレータの適合率ではありません。Ghostは非公開のビルドで、その結果は第三者が再現できないので、READMEと集計概要は、Ghostを除くIcarus Verilog・Verilator・SymbiYosysだけの実行確認率を主に示し、Ghostを含む全環境の和集合を並べて示します。SymbiYosysのformal検査は参照モデルとRTLモデルを比べるもので、シミュレータを実行しません。そのためREADMEと集計概要は、実行確認済みの要求のうち、シミュレータで確認した行数と、formalだけで確認した行数を分けて示します。実際の値と分母は[集計概要](behavior-coverage-summary.md)で確認してください。

規格違反テストでは構文未対応を誤って成功扱いする可能性があるため、固定バージョンoracleをレビュー済みのIcarus・Verilatorの結果だけを実行証拠に採用します。NightlyのMatch件数をそのまま実行確認済み要求の件数にはしません。

「実行した」だけでは分子へ入りません。説明用に、対応済み60要求のうち40要求に有効なPASS、10要求にfail、10要求にunsupportedがあるなら、実行確認済みは40要求です。ランナーが起動した件数やテストファイル数とは別です。集計上の「複数環境の成功の和集合」は、要求ごとに採用可能な成功があるという意味で、[一つのAND集合の部分成功を別実行から合成してよいわけではありません](#q19-can-partial-successes-from-different-simulators-satisfy-an-and-group)。

シミュレータ別の欄には、小範囲だけ実行した保存記録も並びます。計測元・版・未実行数を読み、低い割合を「そのツールでは残りが全て不正動作する」という意味にしないでください。

<a id="q17-do-two-tests-per-clause-cover-every-behavior"></a>

### Q17. 全節にテストが2本あれば、規格の全動作を網羅していますか

節の直接引用本数を満たしたという意味です。同じ節には複数の条件・分岐・例外があり、本数だけではどれを観測したかが分かりません。引用の分布は[条項別テスト数](coverage-depth.ja.md)、具体的な対応は[要求照合](test-requirement-matching.md)で確認します。未登録のテストも動作を検査している可能性がありますが、内容をレビューする前に要求網羅率へ加えません。

<a id="q18-when-is-coverage-confirmed-and-does-100-finish-verification"></a>

### Q18. 暫定値は、いつ確定値になりますか。100%なら検証完了ですか

規格資料の調査完了だけでは分母は確定しません。解釈保留、意味の重複、要求単位を整理し、分母を承認する必要があります。暫定100%も登録した単位の範囲の結果で、全プログラム・全入力の組合せを証明した意味にはなりません。分母の状態、未対応・保留・古い証跡、各テストの検出範囲も確認します。[分母と暫定値の扱い](../coverage/README.md#計測の意味)を参照してください。

現在の分母は12,305要求です。2026-10-28のAIレビューで12,298要求を承認し、2026-11-14に所有者の承認を得て、受理される形と拒否される形が混ざった7行を分けました。解釈保留は0件ですが、人による独立したレビュー・承認や全テストの内容レビュー完了を示すものではありません。[分母レビュー](denominator-review-20261028.md)に根拠と限界を記録しています。

<a id="q19-can-partial-successes-from-different-simulators-satisfy-an-and-group"></a>

### Q19. 複数シミュレータの成功を集めて、AND集合を合格にできますか

複合証拠の各グループは、同じ実行回・同じ環境で全メンバーが成功する必要があります。別ツールや別実行回の部分成功を寄せ集めて、そのグループを成功にはしません。代替グループがある場合は、いずれかのグループの全条件を満たせば採用できます。[`check_groups`の規則](../coverage/README.md#台帳と証跡)を参照してください。

<a id="5-sva-and-formal-verification"></a>

## 5. SVAとフォーマル検証

<a id="q20-does-the-sva-reference-evaluator-execute-original-sva-in-a-simulator"></a>

### Q20. SVA参照評価器は、シミュレータで元のSVAを実行するものですか

規格からシーケンス・プロパティ・サンプル値関数の意味をPythonで実装し、入力トレースから結果を計算します。対象は監査した単一クロック等の範囲です。フォーマル検査では評価器の計算を検証用回路へ変換し、別に書いたRTLモデルと比較します。Yosysが元の未対応SVAをそのまま読む構成ではありません。[図付きの全体ガイド](sva-reference-formal-verification.md)を参照してください。

説明用に`req |=> ack`を考えると、reqが一度も1にならないシミュレーションの入力では、応答ackを試さずに空虚成功となり得ます。したがって「失敗がない」だけで要求した応答を観測できたとは言えません。先行条件の到達をcover等で別に確認しますが、その到達例だけも全入力での正しさの証明にはなりません。[SVAの用語](glossary.md#5-sva-and-reference-evaluation)も参照してください。

<a id="q21-do-bmc-and-pdr-pass-mean-the-same-thing"></a>

### Q21. BMCとPDRは、どちらも同じPASSですか

BMCは指定した有限深度まで、PDRは対象の安全性について有限深度に限定しない証明です。このスイートのシーケンスPDRでは、固定した式・数値パラメータ・入力条件での一致を確認します。任意の式や整数パラメータへの一般化ではありません。また、有限入力を結果表に展開するモデルのソルバー深度と、意味論上のサンプル数も区別します。[結果と証明範囲の説明](sva-reference-formal-verification.md)を参照してください。

実際の`first_match_tie`は、同じtickに二つのシーケンスが終わる場合の一致数を比較します。`first_match_tie_bmc`のPASSは深度8まで、`first_match_tie_prove`のPASSは式とパラメータを固定したモデルに許した0/1入力系列について、長さの上限を置かない一致です。`first_match_tie_cover`のPASSは一致数2への到達例があるという意味です。`first_match_tie_mutant_bmc`のFAILは、二つの一致を一つに潰す意図的な誤りの反例です。[実レポートの4行と反例の読み方](sva-reference-formal-verification.md#read-the-results-of-the-correct-model-and-the-intentionally-wrong-model)を参照してください。

一般的なモードの定義は[SBYのoptionsリファレンス](https://symbiyosys.readthedocs.io/en/latest/reference.html#options-section)を参照してください。証明はモデルの入力・初期状態・仮定を前提とし、任意の4値SVAやシミュレータ全体を証明した記録ではありません。

<a id="q22-do-40-models-plus-111-cases-mean-151-proved-tests"></a>

### Q22. 40モデルと111ケースを足して、151本のテストを証明したのですか

この40モデルは初期セットの件数で、現在のカタログ全体の件数ではありません。テスト本数とモデル数は別で、基本セットと境界値拡張セットには重複があります。二つの件数を足して、異なる式や実テストの数にはしません。現行カタログ・各セット・実テストの出力照合の関係は、[結果の見方](sva-reference-formal-verification.md#結果の見方)で確認してください。

実テストとの対応付けも、0／1の条件からシーケンスの一致を求める部分式の範囲であり、アサーション全体・スケジューリング・表示までの証明ではありません。参照評価器との一致やモデル検査を`:oracle:`やシミュレータ実行確認率へ自動加算しません。[拡張の対象と対応付け](sva-formal-expansion-20261026.md)を参照してください。

<a id="q23-is-a-formal-fail-necessarily-a-problem"></a>

### Q23. フォーマル検証の結果にFAILがあるのは問題ではありませんか

意図的に誤りを入れた負例は、反例が見つかるFAILを期待しています。正しいモデルの失敗と分け、期待する結果、終了コード、反例・到達例の証跡を確認します。UNKNOWN・TIMEOUT・ERRORを成功へ含めるものではありません。保存済み結果への`--check-results`も、ソース等との対応を調べる処理で、ソルバーの再実行ではありません。[検査と再実行の手順](sva-reference-formal-verification.md#再実行)を参照してください。

<a id="6-changes-and-evidence"></a>

## 6. テストの修正と記録

<a id="q24-does-even-a-small-test-or-expectation-correction-require-a-rerun"></a>

### Q24. テストや期待値を少し直しただけでも、再実行が必要ですか

刺激・期待値・診断条件・関連ファイルが変わると、以前のパス結果の記録との入力ハッシュが合わなくなります。内容を規格と再照合し、対応・観測の根拠を見直したうえで、固定バージョンシミュレータの再実行を別の記録として保存します。ハッシュだけを現在値へ書き換えて、過去の実行を現在の成功にはしません。[台帳の更新手順](../coverage/README.md#日常の更新)と[修正記録の例](nightly-suite-corrections-20261027.md)を参照してください。

<a id="q25-may-i-change-only-an-expectation-under-testsgen"></a>

### Q25. `tests/gen/`の期待値だけを直してもよいですか

生成器と規格由来の参照モデルを修正し、再生成します。生成ファイルだけを直接変えると、再生成時に失われ、生成物の整合性検査でも差分になります。[生成テストの説明](../README.ja.md#generated-tests)に構成があり、次のコマンドで生成物との一致を確認できます。

```sh
python3 generators/generate.py --check
```

<a id="q26-how-are-ai-and-human-reviews-distinguished"></a>

### Q26. AIによる規格確認と、人によるレビューはどう区別していますか

`:spec_check: ai`と`human`で区別します。AIによる期待値の照合、別モデルとの一致、ツールの成功は、人による確認を意味しません。要求の対応や保留判断にもレビューの主体・日付・入力ハッシュを記録し、確認した範囲をたどれるようにしています。[メタデータ](../README.ja.md#metadata)と[照合の手順](requirements-to-tests-method.md)を参照してください。

<a id="q27-what-should-i-check-and-where-should-i-report-a-mismatch"></a>

### Q27. 不一致を見つけたら、何を確認し、どこへ報告しますか

スイートのコミット、シミュレータの版、テストと関連入力、引数、実出力・診断・終了コードを揃え、同じ条件で再現させます。引用条文と期待値、テストコードが規格に適合するか、診断判定も確認し、原因が分かる最小例へ絞ります。テストの誤りは[このスイートのIssue](https://github.com/kurochan001/kirimasim-tests/issues)で管理し、シミュレータ側の原因とは分けます。

このプロジェクトでは、Icarus・Verilatorの固定版との差異を[差異一覧](simulator-differences.ja.md)とテストのコメントへ記録し、上流への報告は行わない方針です。他の実装の課題も既存Issueと担当範囲を確認して扱い、レビューだけで外部へ自動投稿しません。記録には根拠となる節番号と自分の言葉での説明を付け、規格本文・図・例のコードは転載しません。[作業方針](codex-handoff-20261031.md#2-ユーザーの方針と作業上の注意)と[Contributing](../README.ja.md#contributing)を参照してください。

商用シミュレータの出力・診断は報告へ含めません。[Q45の投稿方針](#q45-issueに商用シミュレータの出力診断を載せてもよいですか)を確認してください。

<a id="7-feature-interactions"></a>

## 7. 機能間クロス検証

<a id="q28-why-not-simply-cross-every-feature"></a>

### Q28. どうして全機能を単純に掛け合わせないのですか

値・型・状態・時刻などが相互作用する小さなモデルへ分け、制約付きの2因子網羅を基本にします。
故障の起こり方に直結する3因子以上の群と、必須の境界ケースを別に保持します。
単独機能の合格だけでは分からない受渡し部分を狙いますが、任意の高次の不具合をすべて検出する
保証ではありません。[設計思想と追加手順](interaction-verification-method.md)を参照してください。

説明用に「幅＝8/33」「型＝bit/logic」「格納先＝scalar/array」という3因子を考えます。`(8,bit,scalar)`、`(8,logic,array)`、`(33,bit,array)`、`(33,logic,scalar)`の4行には、どの2因子を選んでも全4組が現れます。しかし`(33,logic,array)`の3因子同時条件はありません。したがって2因子100%は3因子の全8行の実行を意味しません。この同時条件が重要なら3因子群や必須ケースへ追加し、実行PASSの網羅は計画とは別に数えます。

<a id="q29-can-a-complete-plan-still-have-unsupported-or-failing-execution"></a>

### Q29. 計画上は網羅していても、未対応や不一致が残るのですか

計画は、選択したテストに対象の組合せと必須ケースが含まれることを示します。
実行の充足は、指定した実行で入力・期待値・ランナーのハッシュが一致した成功から判定します。
known・unsupported・fail・未実行・古い証跡は成功にしません。未対応を理由に合法な対象を
分母から除くこともしません。[保存実行の概要](interaction-verification.md#保存実行の概要)と
[モデル別レポート](interaction-coverage.md)で両者を分けて確認できます。

<a id="q30-does-a-successful-check-mean-every-cross-passed"></a>

### Q30. Checkが成功したら、全クロスが合格したことになりますか

固定oracle対象の継続確認や生成物・台帳の整合性などを確認した結果です。
`interaction_coverage.py --check`も、全クロスの実装合格を要求する検査ではありません。
実行の充足には`--model`と`--results`で範囲・記録を選び、`--require-pass`を使います。
これは保存したJSONを評価する処理で、シミュレータを起動しません。
[コマンドと証跡の役割](../coverage/README.md#機能間クロスの計画と証跡)を参照してください。

<a id="q31-how-do-saved-cross-runs-qualification-evidence-and-nightly-differ"></a>

### Q31. 保存クロス実行、補助証跡、Nightlyをどう区別しますか

`interaction-results/`は入力ハッシュ付きの回帰結果、`interaction-qualification/`は最小例・
故障注入・確認元の選別などの補助記録です。補助記録を合格数やテスト数へ加算しません。
Nightlyはその回のスイートと各ツールの版・対象範囲を持つ別の実行です。
「最新ビルド」と書かれた保存記録も、実行開始時に確認した版を示し、将来の上流更新へ自動追従する
意味ではありません。[補助証跡の説明](../coverage/interaction-qualification/README.md)と
[Nightlyの見方](nightly-results.md)を参照してください。

<a id="q32-can-i-sum-matrix-cells-to-get-the-cross-test-total"></a>

### Q32. 章間表の数字を合計すれば、クロステストの総数になりますか

[章間表](chapter-cross-matrix.md)の数字はモデル数です。上下対称なので、一つの章対が二つのマスに現れます。
また、一つのモデルを複数の章対へ対応付ける場合もあるため、マスを合計してモデル総数やテスト本数にはしません。
対角線は主題章ごとのモデル数で、その合計がモデル総数です。個々のテストは
[計画JSON](../coverage/interaction-summary.json)の`selection`、実行区分は明細CSVから確認できます。

<a id="q33-do-zero-cells-and-mecnr-indicate-missing-tests-or-passes"></a>

### Q33. 0セルやM・E・C・N・Rは、未検証や合格を表しますか

0は有限モデルへの対応付けがない状態で、テストが存在しないという意味ではありません。
`M`はモデル登録、`E`は既存テストの刺激・観測を照合済み、`C`は追加検証の設計候補、
`N`は現計画の対象外、`R`は後回し・要精査です。`E1`などの数字はモデル化を検討する優先度です。
これらは実行の合否を示しません。`E`には根拠のテスト、`C`には因子と観測の仮説があり、
`R`を低リスクとして除外しません。[分類と次の候補](chapter-cross-triage.md)を確認してください。

<a id="q34-are-complete-and-all-selected-tests-pass-the-same-judgment"></a>

### Q34. completeと、全選択ケースPASSのモデル数は同じ判定ですか

`interaction_coverage.py`の`complete`は、一つの保存実行の採用可能な成功で、モデルの全対象組合せと
必須ケースを満たしたという判定です。必須以外のテストに不一致があっても、他の成功テストで同じ
対象組合せを覆える場合があります。実行区分別の件数も併せて確認してください。

章間表の「全選択ケースPASS」は、短時間選択の全テストが同じ保存実行で成功することを要求します。
章対の`when`条件に該当するケースだけの成功を、モデル全体の成功へ読み替えません。
[実行集計の実装](../tools/interaction_coverage.py)と[章間表の規則](chapter-cross-matrix.md#実行結果の扱い)に対応しています。

<a id="q35-how-should-i-add-the-next-model"></a>

### Q35. 次のクロスモデルは、どのような順序で追加しますか

既存テストと0セルの根拠を確認し、二つの機能が同じ値・状態・時刻・参照先へ作用する場面を絞ります。
規格から因子・水準・合法条件・観測目標を定め、2因子に加えて必要な高次因子群と必須ケースを選びます。
ツールの未対応を合法条件に混ぜて対象を削りません。期待値は規格から計算し、別の表現・計算法による
独立モデルと照合します。生成器と同じ計算を呼び出すだけでは、共通の誤りを見逃します。

生成・故障注入・固定版確認・実行直前に上流を確認した開発版での回帰を行い、新しい証跡を保存します。
その後、章対の台帳と生成レポートを更新します。要求への対応は別途内容をレビューして登録します。
[追加手順とチェックリスト](interaction-verification-method.md)に具体的な順序があります。

<a id="q36-why-observe-guard-instances-and-intermediate-values"></a>

### Q36. 対照インスタンスと途中の値も、なぜ確認するのですか

最終値だけでは、二つの誤りが相殺されたり、誤って共通の状態を使ったりしても一致する場合があります。
設定を変える対象と既定値を保つ対照へ異なる刺激・タグを与え、変換前後・演算後・幅変更後を分けて比較します。
対照は保持だけで終えず、後から駆動して更新できることも確認します。X/Zの刺激の前に既知値を書き、
刺激の後に回復も観測すると、入力を取り込まない処理や、状態更新の停止を区別できます。
[interfaceの変換](interaction-verification.md#interfaceヘッダのimportとpackage関数の型変換)と
[逐次UDPの状態保持](interaction-verification.md#generateで生成した逐次udpの状態と入力変換)が具体例です。

<a id="q37-why-can-01-inputs-still-require-four-state-observation"></a>

### Q37. 入力が0/1だけなのに、fourstateがyesになるのはなぜですか

入力だけでなく、観測結果がX/Zに依存するかで決めます。複数ドライバの競合でnetがXになったり、
逐次UDPの初期状態がXのまま保持されたりする場合があります。したがって、既知入力のケースを
一律にVerilatorの比較対象へ入れません。初期値、更新前後、強度の表示など、実際の観測を確認します。
[UDPの配列と強度](interaction-verification.md#udpの配列接続と駆動強度の解決)と
[逐次UDP](interaction-verification.md#generateで生成した逐次udpの状態と入力変換)を参照してください。

<a id="q38-do-mutation-build-failures-or-crashes-count-as-detections"></a>

### Q38. 故障注入でコンパイル失敗やクラッシュが出れば、検出に数えますか

その結果だけでは、狙った動作差を観測できた証拠にはしません。正常対照が一致することを確認し、
誤った処理もビルド・実行でき、正常終了後の出力差として検出した記録と区別します。
例えばinterface importモデルでは、仮引数変換を迂回する故障が既知入力の55行には一致し、
最初の未知入力の56行目で不一致になりました。入力の種類と途中の観測が必要だった具体例です。
故障注入の件数は、生成テスト数や通常回帰のPASS数へ加算しません。
[設計・故障注入の記録](interaction-verification.md#interfaceヘッダのimportとpackage関数の型変換)を参照してください。

<a id="q39-do-matching-verilator-seeds-1-and-73-cover-every-random-condition"></a>

### Q39. Verilatorでseed 1と73が一致すれば、乱数条件をすべて確認済みですか

二つの実行条件で再現したという証拠です。すべての初期値や乱数系列を網羅した証明ではありません。
片方だけ一致した結果や、2状態の結果を4状態の確認へ読み替えず、各seedの実行を別々に保存します。
テストは規格が定める値を観測し、未初期化値や競合へ偶然依存していないかも確認します。
[固定版の確認方法](../README.ja.md#where-the-expected-outputs-come-from)を参照してください。
実際の入力値・操作列を生成する[件数制限付きランダム比較](random-cross-verification.md)は別の経路です。

<a id="q40-how-does-a-latest-commit-run-differ-from-checking-saved-results"></a>

### Q40. 最新コミットでの実行と、保存結果の再確認はどう違いますか

kirimasim・Lyraなどの開発版を新たに実行するときは、実行直前に上流先端を取得・確認し、
そのコミットのビルドと一致させて版を記録します。固定oracleのIcarus 13.0・Verilator 5.052は
固定したリリースを使います。保存JSONの読み直しはシミュレータの再実行ではなく、上流の将来の版への
確認済みを意味しません。過去の証跡はそのまま残し、新しい実行を別の保存先へ記録します。

GitHub Actionsでも、古い実行のRe-runは元のスイートのコミットを使います。最新mainを対象にする場合は
mainを指定して新しく起動し、suite commitと各シミュレータの版を結果から確認します。
[手動実行の説明](nightly-results.md#最新のmainで手動実行する)を参照してください。

<a id="q41-can-i-check-one-models-saved-results-without-running-a-simulator"></a>

### Q41. シミュレータを動かさず、1モデルの保存結果だけ確認できますか

リポジトリのルートで、対象モデルと結果JSONを明示します。次はinterface importモデルの
保存済み結果を評価する例です。入力・ランナーが変わっていなければ、対象組合せと必須ケースの充足を確認できます。

```sh
python3 tools/interaction_coverage.py --model interface_header_import \
  --results coverage/interaction-results/cross53-kirimasim-4fb5f6b1.json --require-pass
```

`--require-pass`は指定した各記録・各モデルの`complete`を要求します。複数記録の部分成功は合成しません。
テストのパスだけを確認する場合は`--list-tests --model interface_header_import`を使います。
パス一覧をランナーへ渡す際は、空でないことを確認してください。位置引数なしのランナーは
通常の全件選択になるため、空の一覧をそのまま渡すと意図した範囲になりません。

<a id="q42-does-a-spec-only-kirimasim-pass-change-the-oracle"></a>

### Q42. specだけのテストがkirimasimでPASSしたら、oracleも変更しますか

その実行で期待結果に一致したことを保存しますが、固定版oracleは自動追加しません。
固定版の未対応や出力差が残る場合は、規格に基づく共通期待値を維持して差異を記録します。
例えばconfigのモデルには、固定版が構文を拒否してもkirimasimで期待値と一致するケースがあります。
`spec`・固定版oracle・保存実行の`pass`はそれぞれ役割が異なります。
[期待値の方針](../README.ja.md#where-the-expected-outputs-come-from)と
[configモデルの結果](interaction-verification.md#configのパラメータ設定とgenerateの形状)を参照してください。

<a id="q43-do-documentation-only-edits-require-full-simulator-reruns"></a>

### Q43. 文書だけを直す場合も、全シミュレータの再実行が必要ですか

テスト・期待値・入力・ランナーを変えなければ、記述を保存記録と照合し、集計の整合性とリンクを確認します。
新しい実行を行っていないのに版・日時・PASS数を更新したり、過去のJSONを書き換えたりはしません。
刺激・期待値・ランナーも直した場合は、その変更が影響する範囲を別途再実行します。
ローカル検査の成功、GitHub Check、Nightlyの公開状況は対象コミットと範囲を添えて区別します。

<a id="8-commercial-simulators"></a>

## 8. 商用シミュレータでの確認状況

<a id="q44-has-the-suite-been-checked-with-commercial-simulators"></a>

### Q44. 商用シミュレータでも確認していますか

本プロジェクトでは、商用SystemVerilogシミュレータのライセンスを保有していません。
商用製品での確認は行っておらず、今後も本プロジェクトでは実行・比較を行わない方針です。
結果の公表制限や、他社製品の挙動解析・競合製品開発への利用に関する契約上の問題を避け、
規格に基づいて期待結果を独立に導くためです。結果を非公開にするだけで利用条件を満たすとは判断しません。
第三者が得た商用シミュレータの出力・診断も、期待値の作成や実装判断へ流用しません。

公開契約の例として、[Synopsys Cloud Service Agreement 2024](https://www.synopsys.com/cloud/service-agreement.html)の
§9.3.2・§9.3.5・§9.3.7には、リバースエンジニアリング、競合製品の開発・改良への利用、
ベンチマーク目的の利用・結果開示に関する禁止事項があります（2026-11-01確認）。
これは同日、ログインや製品ライセンス認証なしで本文を閲覧できる公開Webページを参照したものです。
公開契約文の閲覧と、製品の利用ライセンスの保有は別です。この例示は、本プロジェクトが当該契約を
締結していることや、当該契約が本プロジェクトへ適用されることを示すものではありません。

適用条件は製品・契約・法域によって異なり、通常の動作確認が常に禁止される、または
リバースエンジニアリングに当たるという断定ではありません。個別契約の解釈とは分けて、
このプロジェクトの運用方針を定めています。

期待結果はIEEE 1800-2023の引用条項と独立した参照モデルに基づいて定め、固定バージョンの
Icarus Verilog・Verilatorで確認できた範囲を`:oracle:`へ記録します。kirimasim・Lyra・Ghostなどの
保存結果も、記録した版と実行条件での結果です。商用シミュレータでの実行可否や期待結果との一致は未確認です。
確認方法は
[期待値の決め方](../README.ja.md#where-the-expected-outputs-come-from)と
[保存実行の概要](interaction-verification.md#保存実行の概要)を参照してください。

<a id="q45-may-i-post-commercial-simulator-output-or-diagnostics-in-an-issue"></a>

### Q45. Issueに商用シミュレータの出力・診断を載せてもよいですか

このプロジェクトでは受け付けません。Issue本文・コメントに加え、ログの添付、スクリーンショット、
波形、外部の貼付け先や実行環境へのリンクも対象です。製品名を伏せた抜粋・要約や、第三者の実行結果を
転載する形でも持ち込まないでください。報告のために商用シミュレータを実行するよう求めることもありません。

期待する動作は、IEEE 1800-2023の条項番号と自分の言葉による説明、自作の最小再現コードで示します。
実行結果を添える場合は、本プロジェクトの確認対象であるIcarus Verilog・Verilator・kirimasim・Lyra・SymbiYosys、
または公開用に整えたGhostの結果に限定し、使用した版とスイートのコミットを記録してください。
規格本文の転載や、Ghostの非公開情報・個人情報の掲載も避けます。

[Issueフォーム](../.github/ISSUE_TEMPLATE/report.yml)には投稿前の案内と必須の確認欄があります。
[フォーム選択の設定](../.github/ISSUE_TEMPLATE/config.yml)では、一般投稿者向けの空欄Issueを無効にします。
ただし、これらは内容を自動検査する仕組みではなく、管理者等の空欄投稿、API・CLIによる投稿、
投稿後のコメントや添付まで完全に防げるものではありません。
[GitHubのテンプレート設定の説明](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)も参照してください。
該当内容を見つけても転載・要約・期待値への取り込みは行わず、投稿者または管理者による対応を求めます。

<a id="model-based-random-comparisons"></a>

<a id="9-model-based-random-comparisons"></a>

## 9. モデルに基づくランダム比較

<a id="q46-can-existing-models-support-random-verification-comparisons"></a>

### Q46. モデルがあればランダム検証で比較できますか

固定クロスの代表ケースに加え、対応範囲内の入力値・初期状態・操作履歴を変えて、取りこぼした相互作用の反例を探します。
固定境界や組合せ網羅の回帰は維持し、見つけた失敗を再現・切り分けて固定回帰へ引き継ぐのが目的です。
同じ刺激を設計と参照モデルへ与えて比較できます。現在対応するのは算術式、除算／剰余、添字付き書込み列、条件演算子の文脈とX/Zマージ、package変数の変更通知、シフトの文脈とシフト量、キャスト後の変換・演算、ストリーミングのpack／unpack、連結左辺への代入列、比較演算、パック値のリダクション・論理否定、配列リダクション、配列のコピー・更新列の13プロファイルです。
任意の値・操作列に対応する参照計算を用意し、合法な範囲で生成します。すべての有限モデルが任意の入力を扱えるわけではありません。
乱数列の一致を確認する検査とも区別します。`randomize()`に複数解がある場合は、生成値の完全一致ではなく制約の充足を確認します。
[目的と役割分担](random-cross-verification.md#purpose-and-roles)、[検証の流れ](random-cross-verification.md#verification-process)、[対象と制限](random-cross-verification.md#scope)を参照してください。

一般的なRTL検証では、参照モデルが入力から期待動作を計算し、スコアボードが観測結果と照合します（[Accellera UVM 1.2 User’s Guide §1.1.4](https://www.accellera.org/images/downloads/standards/uvm/uvm_users_guide_1.2.pdf)）。このリポジトリはUVM環境の実装ではありませんが、役割は対応します。`random_cross_models.py`のPythonモデルが具体的な刺激と期待値を作り、生成したSVがその刺激をシミュレータへ与えて観測値を表示し、既存runnerの正規化・比較が照合を担当します。検査対象は製品RTLではなく、そのSVを実行するシミュレータの言語動作です。他シミュレータも同じSVを実行し、Pythonの期待値と個別に比較します。

説明用に、8ビットの初期値`8'hA5`の下位4ビットへ`4'h3`を書くと、期待値は`8'hA3`です。参照モデルは上位のAを保持して全8ビットを計算します。仮の実測値が`8'h03`なら下位4ビットは3でも上位が壊れているため不一致です。このため[packed_write_sequenceの生成・参照処理](../tools/random_cross_models.py)は操作後の全体と途中経過を観測します。これは説明用の値で、保存済み失敗を報告したものではありません。8ビットは手計算用で、現行プロファイルが生成する幅は[対象と生成方法](random-cross-verification.md#scope)を参照してください。ランダムなのは入力の選択であり、選ばれた入力への正解の計算規則までランダムにするわけではありません。

参照モデルにも誤りはあり得るため、規格・手計算の境界例・独立検算を併用します。スコアボード等の[用語](glossary.md#reference-model-and-scoreboard)と、[生成→照合→保存の操作手順](random-cross-verification.md#verification-process)を参照してください。

<a id="q47-how-do-i-reproduce-a-random-comparison-failure"></a>

### Q47. ランダム比較が失敗したら、どこから再現しますか

Nightlyの`random-cross-kirimasim` artifactを開き、`run.json`の判定・版・指紋と、該当ケースのSV・期待値・出力を確認します。
`manifest.json`には実際の入力と操作列があるため、`--replay`と`--case`で再抽選せず実行できます。
再実行時も直前に取得・ビルドした版を指定し、元の版との違いを記録します。seedだけで同じ刺激を保証しません。
不一致は参照モデルや観測の誤りでも起こるので、規格と照合して原因を切り分けます。未対応や未実行は合格にせず、期待値を変えて隠しません。
[保存形式と再現手順](random-cross-verification.md#replay)を参照してください。

replayは既定で保存済みSVと期待値を保持します。現在の参照コードで評価する場合だけ、`--reference-policy current`を明示し、
SV・期待値・参照コードのハッシュの変化を確認します。元の失敗証跡は保持し、再実行のPASSで消しません。

<a id="q48-should-random-profiles-keep-growing"></a>

### Q48. ランダム検証のプロファイルは、今後も増やし続けますか

現在は13個で追加をいったん区切っています。Nightlyは合計96件・各8ベクトル／操作の固定予算なので、
プロファイルを増やすほど1個当たりのサンプルが減ります。追加探索でシードや操作列の長さを変えること、
実際の保存SVの独立検算、確認済み不具合の固定回帰化を優先します。
[安定化の記録](random-cross-verification.md#thirteen-profile-stabilization)にはローカル1,152 PASSを保持し、
うち配列・packageの864件を独立解釈しています。残るパック書込み288件は既存の実行・参照比較です。
[正式確認](nightly-results.md#latest-verified-checkpoint)では、これとは別に`19cd790a`のNightlyで96 PASSを確認しました。
任意の`--explore`の投入管理は、完全に同じ条件で有効に完了したジョブだけを省略し、省略をPASSとは別に記録します。
固定回帰・正式Nightly・明示replayは再実行します。新しい相互作用を独立したモデルで扱う必要が具体化したときに、
合法範囲・規格由来の期待値・確認方法を決めてから追加を検討します。

<a id="10-reading-examples"></a>

## 10. 初めて読むための具体例

<a id="q49-read-a-real-test"></a>

### Q49. 実在する短いテストは、どの順に読めば期待値を説明できますか

[test_declaration_initialization_is_not_driver.sv](../tests/ch10/test_declaration_initialization_is_not_driver.sv)は、宣言時の初期化が、その後の入力変化に追従するドライバではないことを確認する24行のテストです。

1. **目的と規格。** 冒頭の`:description:`と説明コメントを読み、`:lrm: 1800-2023 10.5`の宣言時初期化を確認します。`:type: simulation`なので、このテストは標準出力を比較します。
2. **入力と操作。** `int source = 5;`に対し、`int captured = source + 2;`が一度だけ値を取り込みます。その後`initial`内で`source = 40;`に変えます。
3. **観測。** 最初の`$display`は`captured`を表示します。`#1`は1シミュレーション時間単位待ってから、同じ変数を再表示します。時間単位を明記していないので「1ns」と読み替えません。
4. **期待値。** 最初は5＋2＝7。その後も`captured`を代入し直していないため7です。40＋2＝42には追従しません。[ヘッダが参照する.expected](../tests/ch10/test_declaration_initialization_is_not_driver.expected)の全内容は次の2行です。

```text
entry=7
after_source_change=7
```

5. **合格条件。** テスト内に`PASS`という表示はありません。ランナーがこの2行を期待値と比較し、終了条件・診断の検査も満たすと`pass`です。このテストは追加の終了・診断フィールドを指定していません。表示が`after_source_change=42`なら不一致です。文字を含む行の空白や値は正規化で都合よく書き換えません。

`:expected_stdout: @test_declaration_initialization_is_not_driver.expected`の`@`は、同じディレクトリのファイルを読む指定です。`:oracle: spec iverilog@13.0 verilator@5.052`は、規格との照合と、その固定版での確認を記録します。現在の開発版の実行結果は別に確認します。`:spec_check: ai`は人のレビュー済みを意味しません。

Icarus 13.0の実行ファイルのディレクトリを`IVERILOG13_BIN`へ設定し、リポジトリのルートから実行できます。

```sh
python3 tools/run_icarus.py --iverilog-bin "$IVERILOG13_BIN" \
  tests/ch10/test_declaration_initialization_is_not_driver.sv
```

このテストのPASSで確認するのは、この入力・観測の宣言時初期化です。10.5の全条件を検査したという意味ではありません。別のテストを読む際も、[メタデータ](../README.ja.md#metadata)と[判定方法](../README.ja.md#how-a-test-is-judged)へ同じ順に当てはめます。

<a id="q50-sv-values-change-observations"></a>

### Q50. X/Z・状態型・幅・符号・NBAで、観測値はどう変わりますか

以下は自作の説明用コード片です。各片を別のブロックに置いた場合の表示を示し、実テストの期待値を変更する提案ではありません。規則の名前は[用語集](glossary.md#9-language-features-used-in-cross-tests)、テストの根拠は各`:lrm:`で確認します。

**X/Zとbit/logic。** Xは未知、Zは高インピーダンスを表す4値の要素です。自動的に「ランダムな0/1」と読むものではありません。bitへ代入するとX/Zが0へ変換されます。

```systemverilog
logic [3:0] four;
bit [3:0] two;
four = 4'b10xz;
two = four;
$display("four=%b two=%b", four, two);
$display("eq=%b case_eq=%b", four == four, four === four);
```

表示は`four=10xz two=1000`と`eq=x case_eq=1`です。`==`は未知を返し得ますが、`===`はX/Zも状態として比較します。演算子の置換は検査内容を変えるため、合格させる目的だけでは行いません。2値の実行で何を判断できないかは[Q8](#q8-can-verilator-alone-confirm-fourstate-yes)を参照してください。

**符号拡張。** 同じ4ビットの1111でも、signedは−1、unsignedは15です。8ビットへ広げると上位が変わります。

```systemverilog
logic signed [3:0] s;
logic [3:0] u;
logic [7:0] from_s, from_u;
s = 4'b1111; u = 4'b1111;
from_s = s; from_u = u;
$display("signed=%h unsigned=%h", from_s, from_u);
```

表示は`signed=ff unsigned=0f`です。代入先がunsignedでも、元のsigned値の符号拡張は観測に現れます。

**式の幅。** この加算では代入先の幅も式へ伝わります。小さい変数に一度格納した値を後で広げても、失った桁上がりは戻りません。

```systemverilog
logic [3:0] a, b, narrow;
logic [4:0] wide;
a = 4'hf; b = 4'h1;
narrow = a + b; wide = a + b;
$display("narrow=%0d wide=%0d", narrow, wide);
```

表示は`narrow=0 wide=16`です。「足し算は常に元の4ビット幅」とは判断できません。文脈・キャスト・演算子により規則が変わるため、[ランダム検証のexpression_context](random-cross-verification.md#scope)もこれを因子にしています。

**ノンブロッキング代入。** `<=`は右辺を評価して更新を予約します。同じプロセス内の次の表示までに、その更新が終わるとは限りません。

```systemverilog
int p, q;
p = 1; q = 2;
p <= q; q <= p;
$display("before p=%0d q=%0d", p, q);
#1 $display("after p=%0d q=%0d", p, q);
```

表示は`before p=1 q=2`、1時間単位後は`after p=2 q=1`です。`p = q; q = p;`というブロッキング代入なら、この順では両方2になります。`#0`をNBA完了待ちとは考えません。[実在する遅延NBAテスト](../tests/ch10/test_intra_assignment_delay_nba_concatenation.sv)は、Active・`#0`後では旧値、後続時刻では更新値を[期待出力](../tests/ch10/test_intra_assignment_delay_nba_concatenation.expected)に記録しています。
