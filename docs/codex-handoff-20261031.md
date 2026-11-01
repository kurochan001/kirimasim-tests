<a id="codex-handoff-test-corrections-and-interaction-verification-2026-10-31"></a>

# Codexへの引き継ぎ：テスト側指摘の対応とクロス検証（2026-10-31）

[English](codex-handoff-20261031.en.md) / [日本語](codex-handoff-20261031.md)

追記：連想配列問い合わせ追加後の現況は64モデル・2,526件・95章対です。[最新の概要](interaction-verification.md#保存実行の概要)と[README](../README.ja.md)を参照してください。以下の件数・実行記録は、各節に示した追加時点の履歴として読みます。

外部状態の確認：2026-10-30 21:05 UTC（10-31 06:05 JST）。 ローカル状態・クロス検証・文書の更新：2026-11-01 JST。Issueなど外部状態の確認日は上記のままです。 GitHub Actionsと公開Nightlyの再確認日は2026-11-01 JSTです。 この資料は`kirimasim-tests`の作業を引き継ぐためのものです。 コマンドは、断りがなければ`kirimasim-tests`リポジトリのルートで実行します。

前の担当者の資料も残っています。範囲が重なるので、両方読んでください。

- [機能間クロス検証の引き継ぎ（2026-10-30）](claude-code-handoff-20261030-cross-verification.md)： クロスのモデル追加手順、保存実行、insideの不一致の調査。
- [要求カバレッジの引き継ぎ（2026-10-28）](handover-20261028.md)：要求台帳と分母の考え方。
- [履歴](history.ja.md)：以前の測定値と作業記録。READMEには現時点の情報だけを書きます。

<a id="1-what-to-understand-first"></a>

## 1. 最初に把握すること

- 直近のテスト追加の基点はmainの`7cf35321`です。mailboxとclassハンドルの36件に続き、 イベント変数の再結合と待機のクロス27件を追加しています（計63件）。 追加内容は生成器・テスト・保存実行・関連資料と合わせてコミットしています。 コミット・pushの状態は`git status`、`git log -1`と`git rev-parse origin/main`で照合してください。 シミュレータ本体は変更していません。kirimasimの実行用worktreeは上流main `ddf48e2b0436`へ合わせてビルドしました。 GitHub Check・Nightlyとローカル検査は、対象コミットと実行範囲を分けて確認します。 ローカル検査はツール単体552件・整合性11項目が成功し、メタデータは新規問題0件（既知395件）です。 各モデルの[設計と検証記録](interaction-verification.md)に確認範囲と限界を記載しています。
- 確認済みの[Nightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886)はスイート`73af6e95`の9,203本が対象で、 5環境とpublishが成功しました。これは現mainより前の記録です。 各ランナーはformalの268本を除く8,935本を対象にしています。 [公開時の記録と版](nightly-results.md#確認例2026年10月31日の公開)を参照してください。
- スイートは**10,105件、生成3,668件**。機能間クロスの短時間実行は**55モデル・2,355件**です。
- 実行直前の上流を確認したkirimasim `ddf48e2b0436`で、全クロスは **2,170 pass・179 unsupported・既存6 fail**です。イベント再結合の27件はイベント値の操作が未対応で、 mailboxの36件はすべて型未対応です。従来2,328件の入力ハッシュと結果区分は同じです。 クラスメソッドは18 pass・18 unsupportedです。 固定Verilatorでは既知値のtyped 11件が両seedで一致し、typeless 1件はknown、4状態24件は対象外です。 イベント再結合は固定Icarus/Verilatorも全27件がビルド失敗でknown、固定oracleは追加していません。 kirimasimの構文・意味解析は全27件が成功し、独立参照モデルは合法648行で一致しています。 第6章×第15章・第8章×第15章を登録し、章対は86対、全選択ケースPASSは46モデルです。 [イベント再結合の設計と保存実行](interaction-verification.md#イベント変数の再結合と登録済み待機の保持)を参照してください。
- 要求カバレッジは、テスト設計**89.31%（10,983/12,298）**、実行確認**77.57%（9,539/12,298）**です。 実行確認はIcarus Verilog 13.0・Verilator 5.052・SymbiYosys・Ghostの保存証跡の和集合です。 今回のクロステストには新しい要求対応を登録しておらず、要求の分母・確認率は維持しています。
- 計画上の網羅、Checkの成功、テストの一致数、要求カバレッジは別の指標です。混ぜないでください。

<a id="2-users-policy-and-precautions-during-operation"></a>

## 2. ユーザーの方針と作業上の注意

- **日本語で簡潔に進捗と結果を伝える。** 長い検証中も状況を共有する。
- mainへのcommit・pushは依頼されたときだけ行う。検証してから反映する流れで作業してきた。
- シミュレータを実行するときは、その直前に最新コミットを取得・確認し、その版をビルドする。 古いビルドをそのまま使わない。ビルド版と上流コミットの一致を記録する。
- **kirimasimとLyraは別のシミュレータ。** kirimasimの結果をLyraの結果として報告しない。
- Icarus 13.0・Verilator 5.052は固定oracleの確認用。開発版の一致をこれら固定版のoracleへ 読み替えない。Verilatorの確認では2状態テストをseed 1・73で別々に実行する。
- 既存テスト・期待値・oracle・過去の実行証跡を保持する。未対応を成功の期待値にしない。 合格率のために合法な因子を削らない。
- Icarus・VerilatorなどGPL/LGPLの実装ソースを読まない。他プロジェクトの再現コードをコピーしない。 規格、独立計算、実行結果から検証する。
- 商用SystemVerilogシミュレータでは確認しておらず、今後も実行・比較や、その出力・診断からの 挙動解析は行わない。第三者の商用実行結果も期待値の作成・実装判断へ流用しない。 結果の非公開だけで契約上の問題を避けられるとは扱わず、公開規格と独立した参照モデルを根拠にする。 契約ごとの禁止範囲の断定とは区別する。[FAQの方針と公開契約の例](faq.md#8-商用シミュレータでの確認状況)を参照。
- Issue本文・コメント・添付・画像・波形・外部リンクにも商用シミュレータの出力・診断を持ち込まない。 匿名化した抜粋・要約や第三者の結果も対象。報告は規格の条項番号と自作の再現例を根拠にする。 [投稿方針](faq.md#q45-issueに商用シミュレータの出力診断を載せてもよいですか)と日英のIssueフォームを案内する。
- Icarus・Verilatorとの差異は上流へ報告せず、[固定版の差異一覧](simulator-differences.ja.md)へ記録する。
- 規格本文・図表の転載、ホームの絶対パス、個人情報、非公開資料を公開ファイルへ入れない。 Ghostは公開前のシミュレータの仮名で、実名・版・実行プロファイル・パスは公開しない。
- コメント行を`Verilator`という語で始めない（Verilatorが指令と解釈する）。 `tools/lint_metadata.py`が`verilator-comment`として検出する。
- Icarus・Verilatorのoracleが付いていないテストの不一致は、ランナーがknownとして数え、failにしない。
- 本体（`../kirimasim`）を変更する場合は、そのリポジトリのCLAUDE.mdを読む。 「意味は一か所で決める」「症状の形で分岐しない」「仕組みのマトリクステストを生成器で作る」 「pushの前に`tools/local_ci.py`」などの規則がある。別セッションが作業中なので、 チェックアウトを直接触らず、隔離した作業ツリーを作る。

<a id="3--work-completed-on-2026-10-31-f0908394"></a>

## 3. 2026-10-31に完了した作業（`f0908394`）

Ghostの全件実行（別リポジトリの監査）が「テスト側の問題」と分類した432件と、 個別指摘の#36〜#39を、IEEE 1800-2023と照らして見直しました。約90件のテストを修正し、 規格どおりのテストは据え置きました。

- **直した主な類型**
  - 合法のテストに含まれる不正な構文（非ANSI引数の既定値、refを継いだリテラル実引数、 bin添字への`binsof`、struct変数を上位スコープ名にした階層参照、変数ポートへのinterconnect、 `buf`への3値遅延、`##1`の後のプロパティ、縮退したシーケンス、`; else`の空動作など）。
  - 規格が結果を定めない競合（UDP遅延の変化時刻と同時刻の観測、programの暗黙`$finish`が 報告より先に来る形、時刻0の継続代入と`@(v)`の競合）。
  - 期待値の誤り（`%h`でintは8桁、ビットストリーム型のクラス、Annex Nが定める 非正の平均への警告と0、`always a`が毎tickで試行を始めること）。
  - VPIの`vpi_get_str()`の共有バッファ（38.11）を前提にしていないCコード11件。
  - Verilator専用の期待出力しかなかった21件に、規格から導いた共通の期待出力を付与。
  - 診断の正規表現を、20.10が様式をツールに委ねる範囲へ緩和（severityと`file:line`を 同じ行でも次の行でも、順序も問わない）。
- **oracleの取り消し**：未対応の構文で拒否しているだけの不正テスト7件から`iverilog@13.0`を外した （README「期待出力の決め方」の規則）。同種の問題はch8などにも残り、 `coverage/test-matching-reviews.json`の`oracle_issue`に記録がある。
- **#22**：`tools/run_ghost.py`も`:type: formal`を除くようにし、`tools/test_runner_selection.py`と READMEを合わせた。
- **#29〜#35**：Ghostの未実装操作の一覧で、テストの不具合ではないため説明を付けて閉じた。
- **リアクティブ順序**：未マージだったブランチのテスト修正を当て直した（4.5。 Icarus 13.0が5回とも再現したので`iverilog@13.0`を登録）。
- **証跡**：入力が変わった108件をIcarus 13.0、2状態101件をVerilator 5.052のseed 1・73で実行し、 `coverage/results/issues-20261031-*.json`に保存した。oracle付きの対象はすべて一致。
- **要求の対応付け**：変更したテストに関わる全件をレビューし直した。成り立たなくなった3件 （37.25のpacked array typespec、37.46のnet bitのload、I.3のack）を根拠から外し、 理由を`coverage/behavior-baseline.json`に記録した。
- `tools/sva_reference/fixtures/m4_deferred.json`の指紋を1件更新（ch16のテスト改修に伴う）。

<a id="simulator-implementation-kirimasim"></a>

### 本体（kirimasim）側

- inside・case insideの集合要素の符号拡張の不具合を修正。11.8.1・11.8.2に従い、 配列要素を共通型の符号で拡張するよう、`src/front/lower_expr.cpp`の一か所 （`Lowerer::memberMatch`）に集約した。
- ブランチ`fix/inside-array-element-extension`（`e2912de7`）をpush済み。PRは作っておらず、 mainには入れていない。基点は`745388cd`で、確認時の上流mainは`83e89bf5`なので、 取り込む前に上流へ合わせ直す必要がある。
- 仕組みのマトリクステストを生成器（`tools/gen_inside_member_matrix.py`）で追加。 `tools/local_ci.py`は全項目通過。
- この修正で、クロス1,426件の不一致2件が解消する（修正前1,368 pass・2 fail、 修正後1,370 pass・0 fail、未対応56件は同じ）。**この結果はまだ保存証跡にしていない。** 上流に入った後、最新mainをビルドして`coverage/interaction-results/cross29-kirimasim-<commit>.json` を新しい名前で保存してください。

<a id="4-outstanding-work"></a>

## 4. 未着手の課題

<a id="41-new-individual-reports-4044"></a>

### 4.1 新しい個別指摘 #40〜#44

追記：引き継ぎ後の照合と修正内容、保存した実行結果は [Issue #40〜#44 の照合記録](issues-40-44-review-20261031.md)に記載しています。 以下は引き継ぎ時点の未検証の指摘と作業手順です。

いずれも「テスト1件の期待値や刺激が規格に反する」という指摘で、条項と該当行が示されています。 **内容は未検証です。** 指摘を事実として扱わず、条項本文とテストを自分で照合してください。

|Issue| 対象 | 指摘の要点（未検証） |
| --- | --- | --- |
| [#40](https://github.com/kurochan001/kirimasim-tests/issues/40) | `ch14/test_syntax_clocking_drive_forms` | 1ビットの`d`に2〜5を期待している（10.7の左辺幅への切り詰め） |
| [#41](https://github.com/kurochan001/kirimasim-tests/issues/41) | `ch11/test_A_extra_specparam_range` | localparamにspecparamを含む定数式を代入している（6.20.5） |
| [#42](https://github.com/kurochan001/kirimasim-tests/issues/42) | `ch14/test_clocking_default_skew` | Re-NBAでの更新前に新しい値を読む期待値（14.16）。同趣旨の`test_clocking_future_drive_in_re_nba`と両立しない |
| [#43](https://github.com/kurochan001/kirimasim-tests/issues/43) | `ch37/test_vpi_immediate_assertion_parts` | ラベルのない呼出し文を`vpiName`で特定している（37.60 detail 1はNULL） |
| [#44](https://github.com/kurochan001/kirimasim-tests/issues/44) | `ch4/test_pli_phase_chain_after_nba_and_end_write` | `cbReadWriteSynch`がNBA更新の後に起きることを要求している（38.36.2はどちらでもよい） |

進め方は#36〜#39と同じです。

1. 条項本文を`tools/requirement_source.py --show`で読み、テストとその`.expected`を読む。
2. スイート内に同じ規則を反対に解釈したテストがないか探す（#42は指摘自身が挙げている）。 自己矛盾があれば、どちらの読み方でも同じ結果になる刺激にするか、理由を書いて片方を直す。
3. 直したら、入力が変わるので固定版を再実行し、oracleの維持／取り消しを判断する。
4. 要求の対応付け（`coverage/behaviors.json`、`coverage/test-matching-reviews.json`）の 指紋・証拠・観測文を更新する。手順は§6.3。

<a id="42-open-issues-requiring-a-decision"></a>

### 4.2 開いたままのIssue（判断が必要）

- [#24](https://github.com/kurochan001/kirimasim-tests/issues/24)： `ch35/test_35_rest_noncontext_export_error`。noncontext importからexportを呼ぶ動作は 規格が予測不能・未定義としているため、共通の期待出力・終了コード・メッセージが導けない。 期待値は1ツールの文言のまま。**作り直すか廃止するかの判断が必要。**
- [#27](https://github.com/kurochan001/kirimasim-tests/issues/27)：
  - `ch35/test_35_rest_deprecated_dpi_diagnostic`。35.5.4は警告でもエラーでもよいとしており、 テスト形式は「どちらでもよい」を表せない。形式かランナー規則の追加が必要。
  - 不正設計の判定が`file:line:`を1行に求める点。規格は診断の様式を定めない。 `tools/suite_results.py`の`judge_illegal`を、`file:line`の直後が非単語文字でもよいように 緩める案がある。影響範囲が広いので、先に方針を決めてから一括で変える。
- [#28](https://github.com/kurochan001/kirimasim-tests/issues/28)：
  - `generators/scheduling.py`の`assign_wait`系14件。時刻0の継続代入の評価と`@(v)`の開始が 競合し、規格はどちらの順序も許す。生成器側の修正が必要（生成済みファイルは直接編集しない）。
  - 読み方が分かれるテスト：ポートの強制変換（23.3.3.1、23.3.3.7）、コンパイル単位の割り当て （3.12.1）、configの`use`節の形（A.1.5の文法と33.4.3の例が食い違う）、 bin内のx/z（19.5.4と19.5.7 b)3）、チェッカー出力の空接続（17.3）、 上書きのないparameterのparam assign、programからinterfaceへの関係（37.9と37.10 d3）、 `$coverage_*`のスコープにinterface instanceやpackageを許すか（40.3.2.1）。

<a id="43-other-remaining-work"></a>

### 4.3 その他の残件

- **Ghostの結果の復帰（対応済み）**：上流mainの`80f19e33`で保存した [2026-10-31のGhost全件結果](../coverage/results/ghost-local-20261031.json)を取り込み、要求カバレッジを再集計しました。 続く上流mainの`bfa43fea`で[strict LRMの全件結果](../coverage/results/ghost-local-20261031-strict.json)も取り込み、 この取り込み時点の実行確認率は77.47%（9,527/12,298）でした。現在値は§1を参照してください。 これは保存済みの各シミュレータの成功の和集合で、kirimasim単独の値ではありません。 取り込みの規則は[Nightlyの説明](nightly-results.md)と`coverage/README.md`を参照。 上流mainの`a3edb14a`による既存テストの変数・タスクの寿命指定の修正と、 [修正分のGhost実行](../coverage/results/test-fixes-20261031-ghost.json)・固定版の実行・要求対応も取り込み済みです。 クロスの選択1,988件の入力ハッシュと結果は変わりません。
- **Ghost側に残る問題**（テスト側ではない。記録のみ）：既定モードで警告にとどまる検査、 診断の位置を別行や`(file:line)`で出す形式、`$finish(2)`の統計やカバレッジの注記を 標準出力に混ぜる点、未対応診断にseverity語がない点。実行プロファイルの整備で解決するものもある。
- **slang**（kirimasim・Lyra・Ghostが共有）：set expression内のcoverpoint名を 19.5.1.2の本文に反してエラーにする。未報告。
- **slangへのストリーミングの不具合の報告案**：`../kirimasim-tests-work/slang-issue-streaming-20261028/`。 前回出した[slang #2072](https://github.com/MikePopoloski/slang/issues/2072)が処理されてから出す。 確認時はまだOPEN。kirimasim-testsへのリンクは付けない。
- **クロスの次の候補**：task引数の添字変更と復帰時の可視性、キュー要素の参照寿命、 イベントORと`iff`の因子モデル化。手順は [考え方と実践手順](interaction-verification-method.md)§5。 追記：イベントORと`iff`は30番目のモデルとして27件を追加済み。 [モデルの設計と実行記録](interaction-verification.md#イベントorと項ごとのiff条件)を参照。 キュー参照寿命も31番目のモデルとして60件を追加済み。 [設計と実行記録](interaction-verification.md#キュー要素への参照と要素の寿命)を参照。 task引数の添字変更と可視性は、input/ref/const refについて32番目のモデルとして36件を追加済み。 [設計と実行記録](interaction-verification.md#引数の結合と呼出し後の添字変更)を参照。 output/inoutの復帰先の評価時点、動的配列・連想配列の参照寿命、異なるエッジ種別のイベントORは 引き続き候補です。規格の読み方が分かれる条件は、期待値を一方へ寄せず先に照合してください。 クロッキング入力のサンプリングは33番目のモデルとして36件を追加済みです。 [設計・最新ビルドの結果・固定oracle・故障注入](interaction-verification.md#クロッキング入力のサンプリングと参照経路)を参照。 33モデル・1,585選択ケースとなり、最新照合版`55ce80b9d5bc`で新規24 pass・12 unsupported、 全体は1,521 pass・62 unsupported・既存2 failです。`#0`とvirtual modportは未対応を保持しています。 次の章対候補は[0セルの仕分け](chapter-cross-triage.md)を参照してください。 アサーションのサンプル/action観測とコンテナwaitも34・35番目のモデルとして各36件を追加済みです。 [アサーション](interaction-verification.md#アサーションのサンプル値とactionのライブ値)は最新照合版 `3a31b060c158`で36 unsupported、[コンテナwait](interaction-verification.md#コンテナ変更とwaitの起床)は36 passです。 この時点では35モデル・1,657選択ケース、全体は1,557 pass・98 unsupported・既存2 fail、通常スイート9,407件でした。 concurrent assertionの実装が進んだら再実行してください。固定VerilatorのNBA同時更新時のライブ値の差異も記録しています。 クラスメソッドの呼出し先・再帰・input/ref/const refも36番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#クラスメソッドの呼出し先と再帰引数)を参照してください。 この時点では36モデル・1,693選択ケース、通常スイート9,443件でした。最新照合版`3a31b060c158`では 新規36件がクラス型の未対応で、全体は1,557 pass・134 unsupported・既存2 failです。 第6章×第8章・第8章×第13章を有限モデルへ登録し、章対は49対になりました。 クラス型・継承の実装が進んだら保存実行を更新してください。固定版での成功をkirimasimの成功に加算しません。 ループからの関数returnとインスタンス/packageの状態も、37番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#ループからの関数returnと状態の共有範囲)を参照してください。 この時点では37モデル・1,729選択ケース、通常スイート9,479件でした。最新照合版`3a31b060c158`で新規36件は すべてPASS、全体は1,593 pass・134 unsupported・既存2 failです。従来1,693件の入力と結果は同じです。 第12章×第13章・第13章×第26章を登録し、章対は51対、全選択ケースPASSのモデルは31になりました。 ループ代入の更新順序とmodule/interfaceの独立性も、38番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#ループ代入の更新順序とインスタンスの独立性)を参照してください。 この時点では38モデル・1,765選択ケース、通常スイート9,515件でした。最新照合版`95eefebeb952`で新規36件は すべてPASS、全体は1,629 pass・134 unsupported・既存2 failです。従来1,729件の入力と結果は同じです。 第10章×第12章・第10章×第25章を登録し、章対は53対、全選択ケースPASSのモデルは32になりました。 comb/latchの暗黙の感度と保持も、39番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#暗黙の感度リストとラッチ保持)を参照してください。 この時点では39モデル・1,801選択ケース、通常スイート9,551件でした。最新照合版`95eefebeb952`で新規36件は すべてPASS、全体は1,665 pass・134 unsupported・既存2 failです。従来1,765件の入力と結果は同じです。 第9章×第25章・第13章×第25章を登録し、章対は55対、全選択ケースPASSのモデルは33になりました。 固定Verilatorは既知値7件で時刻0の評価カウンタが期待1から512へ達する差異を両seedで再現したため、 このモデルにはVerilatorのoracleを登録していません。Icarus 13.0は36件すべて一致しています。 generate階層とpackage/局所宣言の型・定数の名前探索も、40番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#generate階層でのpackageと局所宣言の名前探索)を参照してください。 この時点では40モデル・1,837選択ケース、通常スイート9,587件でした。最新照合版`4b58e29f8c94`で新規36件は すべてPASS、全体は1,701 pass・134 unsupported・既存2 failです。従来1,801件の入力と結果は同じです。 第10/23/26章×第27章を登録し、章対は58対、全選択ケースPASSのモデルは34になりました。 デフォルト引数の評価と階層呼出しも、41番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#デフォルト引数と階層呼出しのスコープ)を参照してください。 この時点では41モデル・1,873選択ケース、通常スイート9,623件でした。最新照合版`4b58e29f8c94`で新規36件は すべてPASS、全体は1,737 pass・134 unsupported・既存2 failです。従来1,837件の入力と結果は同じです。 第13章×第23章・第23章×第25章を登録し、章対は60対、全選択ケースPASSのモデルは35になりました。 固定Icarusは36件、固定Verilatorは既知値12件が両seedで一致しています。 イベント引数を介したmodule/interface/packageの同期も、42番目のモデルとして13件を追加しました。 [設計と実行記録](interaction-verification.md#イベント引数によるスコープ間の同期)を参照してください。 この時点では42モデル・1,886選択ケース、通常スイート9,636件でした。最新照合版`4b58e29f8c94`で新規13件は すべてPASS、全体は1,750 pass・134 unsupported・既存2 failです。従来1,873件の入力と結果は同じです。 第4/13/25/26章×第15章を新しく登録し、章対は64対、全選択ケースPASSのモデルは36になりました。 固定Verilatorはref＋通常トリガの3件が両seedで一致し、10件は期待した時点で起床しない差異を保存しています。 固定Icarusは13件ともビルドできません。イベント変数の再結合は最新kirimasimでも未対応で、候補のまま残しています。 連続代入の遅延と短パルス除去も、43番目のモデルとして63件を追加しました。 [設計と実行記録](interaction-verification.md#連続代入の遅延と短パルスの除去)を参照してください。 この時点では43モデル・1,949選択ケース、通常スイート9,699件でした。最新照合版`4b58e29f8c94`で新規63件は すべてPASS、全体は1,813 pass・134 unsupported・既存2 failです。従来1,886件の入力と結果は同じです。 第10章×第28章・第6章×第28章を登録し、章対は66対、全選択ケースPASSのモデルは37になりました。 固定Icarusは57件が一致、6件の差異を期待値を維持して保存しています。固定Verilatorは既知値21件中17件が両seedで一致し、幅65/129の4件はビルドできません。 package importとワイルドカードポート接続も、44番目のモデルとして39件を追加しました。 [設計と実行記録](interaction-verification.md#packageのimportとワイルドカードポート接続)を参照してください。 この時点では44モデル・1,988選択ケース、通常スイート9,738件でした。最新照合版`4b58e29f8c94`で新規39件は すべてPASS、全体は1,852 pass・134 unsupported・既存2 failです。従来1,949件の入力と結果は同じです。 第23章×第26章を登録し、章対は67対、全選択ケースPASSのモデルは38になりました。 固定Icarusは38件が一致し、wildcard importから`.p`を結合できない1件のビルド失敗を保存しています。 固定Verilatorは既知値13件とも両seedで不一致で、対照などの全1既定値が0になる差異を記録しています。 型と範囲を組み合わせたメモリファイル入出力も、45番目のモデルとして36件を追加しました。 [設計と実行記録](interaction-verification.md#型と範囲を組み合わせたメモリファイル入出力)を参照してください。 この時点では45モデル・2,024選択ケース、通常スイート9,774件でした。最新照合版`4b58e29f8c94`で新規36件は すべてPASS、全体は1,888 pass・134 unsupported・既存2 failです。従来1,988件の入力と結果は同じです。 第6章×第21章を登録し、章対は68対、全選択ケースPASSのモデルは39になりました。 固定Icarusは35件一致・65ビットbit列挙型1件でコンパイラ内のアサーション失敗、 固定Verilatorは既知値12件中11件が両seedで一致・逆方向読込みの1件で不一致です。 書込みと読込みの誤りが相殺される場合を独立入力側で検出する方法も、実践手順へ追記しました。

  program終了と子孫プロセスの取消しも、46番目のモデルとして18件を追加しました。 [設計と実行記録](interaction-verification.md#program終了と子孫プロセスの取消し)を参照してください。 この時点では46モデル・2,042選択ケース、通常スイート9,792件でした。最新照合版`4b58e29f8c94`で新規18件は すべてPASS、全体は1,906 pass・134 unsupported・既存2 failです。従来2,024件の入力と結果は同じです。 第9章×第24章・第15章×第24章を登録し、章対は70対、全選択ケースPASSのモデルは40になりました。 固定Icarusは自然終了6件が不一致・$exitの12件は未定義、固定Verilatorは両seedとも18件が module内のprogram宣言の未対応でビルドできません。期待値は維持し、診断を保存しています。 取消しの検査に開始前後の進捗と、同じ待機条件を持つ独立した対照を組み合わせる方法を実践手順へ追記しました。 テスト側mainはGhostの最新全件結果を保存した`efd160c4`まで取り込み、前回の未コミット変更も維持しています。

  default_nettypeとポートnetの解決も、47番目のモデルとして40件を追加しました。 [設計と実行記録](interaction-verification.md#default_nettypeとポートnetの解決)を参照してください。 この時点では47モデル・2,082選択ケース、通常スイート9,832件でした。最新照合版`4b58e29f8c94`で新規40件は すべてPASS、全体は1,946 pass・134 unsupported・既存2 failです。従来2,042件の入力と結果は同じです。 第6章×第22章・第22章×第23章を登録し、章対は72対、全選択ケースPASSのモデルは41になりました。 固定Icarusはwire/triの14件が一致し、wired-AND/ORの26件は差異を保存しています。 全件が4状態テストのため固定Verilatorは対象0件で、両seedともシミュレーションを起動していません。 指示の適用対象・明示指定による例外・設定を戻した後の対象を同じ刺激で比較する方法を実践手順へ追記しました。

  2026-11-01にはgenerateで生成したinterfaceとmodport接続を、48番目のモデルとして36件追加しました。 [設計と実行記録](interaction-verification.md#generateで生成したinterfaceとmodport接続)を参照してください。 この時点では48モデル・2,118選択ケース、通常スイート9,868件でした。最新照合版`4b58e29f8c94`で新規36件は すべてPASS、全体は1,982 pass・134 unsupported・既存2 failです。従来2,082件の入力と結果は同じです。 第25章×第27章・第6章×第25章を登録し、章対は74対、全選択ケースPASSのモデルは42になりました。 固定Icarusは36件ともinterfaceポート宣言の構文エラーでビルドできません。 固定Verilatorは既知値12件が両seedで一致し、X/Zの24件は確認対象外です。 13回の既知刺激で選択側・対照側の780個のビット位置を識別し、接続先のタグも照合する方法を実践手順へ追記しました。

  同日にprogramのイベント領域と非ブロッキング代入を、49番目のモデルとして36件追加しました。 [設計と実行記録](interaction-verification.md#programのイベント領域と非ブロッキング代入)を参照してください。 この時点では49モデル・2,154選択ケース、通常スイート9,904件です。最新照合版`4b58e29f8c94`で新規36件は すべてPASS、全体は2,018 pass・134 unsupported・既存2 failです。従来2,118件の入力と結果は同じです。 第4/6/10章×第24章を登録し、章対は77対、全選択ケースPASSのモデルは43になりました。 固定Icarusは36件、固定Verilatorは既知値12件が両seedで不一致です。X/Zの24件はVerilatorの対象外です。 1ビット対照で予約回数が進んでも通知時の段値が旧値である出力と、後のスナップショットを別途保存しました。 予約回数と実データの完了を区別して観測する方法も実践手順へ追記しました。

  同日にconfigのパラメータ設定とgenerateの形状を、50番目のモデルとして41件追加しました。 [設計と実行記録](interaction-verification.md#configのパラメータ設定とgenerateの形状)を参照してください。 この時点では50モデル・2,195選択ケース、通常スイート9,945件です。最新照合版`4b58e29f8c94`で新規41件は 37 pass・4 fail、全体は2,055 pass・134 unsupported・6 fail（既存2件＋新規4件）です。 従来2,154件の入力と結果は同じです。第23章×第33章・第27章×第33章を登録し、章対は79対になりました。 新モデルは未完了のため全選択ケースPASSは43モデルのままです。固定Icarus・Verilator両seedは全41件をビルド時に拒否しました。 次の実装調査候補は、defparamとconfigの`use #()`の併用で既定値へのリセットが効かない差異です。 同じ値を4個の明示した空括弧でリセットすると一致する最小比較を、故障注入JSONへソース・出力・終了コード付きで保存しました。 失敗を隠す期待値変更や対象からの除外は行っていません。実装内部の原因調査とIssue登録は未実施です。

  同日にUDPの配列接続と駆動強度を、51番目のモデルとして25件追加しました。 [設計と実行記録](interaction-verification.md#udpの配列接続と駆動強度の解決)を参照してください。 この時点では51モデル・2,220選択ケース、通常スイート9,970件です。最新照合版`4b58e29f8c94`で新規25件は すべてPASS、全体は2,080 pass・134 unsupported・既存6 failです。従来2,195件の入力と結果は同じです。 第28章×第29章を登録し、章対は80対、全選択ケースPASSは44モデルになりました。 固定Icarusは1件が一致し、その1件だけへoracleを登録して最終生成物で実行し直しました。24件はビルド時の拒否です。 全件が4状態テストのためVerilatorは対象0件です。単独/競合/解放の比較方法と、観測しない個別インスタンス添字の範囲も資料へ記載しました。

  同日にgenerateで生成した逐次UDPの状態と入力変換を、52番目のモデルとして36件追加しました。 [設計と実行記録](interaction-verification.md#generateで生成した逐次udpの状態と入力変換)を参照してください。 この時点では52モデル・2,256選択ケース、通常スイート10,006件です。全体回帰直前の上流更新に合わせて `3550d77474f1`をビルドし直し、新規36件はすべてPASSしました。全体は2,134 pass・116 unsupported・既存6 failです。 従来2,220件の入力は同じで、既存クラスメソッドの18件がunsupportedからpassへ改善しました。 同モデルの残る18件はまだunsupportedです。従来の保存実行のファイルと集計は変更していません。 第27章×第29章・第6章×第29章を登録し、章対は82対、全選択ケースPASSは45モデルになりました。 固定Icarusは全36件、固定Verilatorは対象2件が両seedで一致しました。4状態の34件はVerilatorの対象外です。 入力が変わる間の保持、対照を後で動かす確認、未知入力前の全1準備、258個の位置履歴の識別を実践手順へ記載しました。

  同日にinterfaceヘッダのimportとpackage関数の型変換を、53番目のモデルとして36件追加しました。 [設計と実行記録](interaction-verification.md#interfaceヘッダのimportとpackage関数の型変換)を参照してください。 この追加時点では53モデル・2,292選択ケース、通常スイート10,042件でした。全体回帰前に上流mainの更新を検出して `4fb5f6b1aec8`をビルドし直し、新規36件はすべてPASSしました。全体は2,170 pass・116 unsupported・既存6 failです。 従来2,256件の入力と結果分類は同じです。第25章×第26章・第6章×第26章を登録し、章対は84対になりました。 全選択ケースPASSは46モデルです。固定Icarusは全36件、固定Verilatorは対象12件が両seedで一致しました。 4状態の24件はVerilatorの対象外です。型変換を迂回する故障は既知入力55行を通過し、最初の未知入力で検出できました。 宣言側と呼出し側のスコープを区別する比較と、中間値・未知値による処理順序の観測を実践手順へ追記しています。

<a id="5-execution-environment"></a>

## 5. 実行環境

<a id="51-simulators"></a>

### 5.1 シミュレータ

| シミュレータ | 用途 | 場所・条件 |
| --- | --- | --- |
| Icarus Verilog 13.0 | 固定oracleの確認 | `../kirimasim-tests-work/50percent-20261023/iverilog13/bin`（版を確認する） |
| Verilator 5.052 | 固定oracleの確認 | `PATH`上。2状態テストのみ、seed 1・73 |
| kirimasim | 最新実装の検証 | `../kirimasim-tests-work/cross30-event-iff-core`（確認時のビルドは`ddf48e2b0436`。実行直前に上流を取得してビルドし直す） |
| Lyra | 比較 | x86-64 Linuxのみ。`run_lyra.py --commit`に実際のコミットを渡す |
| Ghost | 比較（公開前） | 非公開のビルドと実行プロファイルが必要。リポジトリ外に置く（README「Ghost」） |
| SymbiYosys | formalの268件 | `tools/run_sby.py`。`:formal_case:`で検証ケースを指定 |

規格資料は`../IEEE_1800-2023_SystemVerilog`です。

```sh
python3 tools/requirement_source.py --source ../IEEE_1800-2023_SystemVerilog \
  --show 11.4.13 16.12.22 A.8.6
```

<a id="52-runners"></a>

### 5.2 ランナー

```sh
python3 tools/run_icarus.py --iverilog-bin DIR [-j N] [--json FILE] [TEST ...]
python3 tools/run_verilator.py --all --seed 1 [-j N] [--json FILE] [TEST ...]
python3 tools/run_kirimasim.py --kirimasim BIN [-j N] [--json FILE] [TEST ...]
python3 tools/run_ghost.py --simulator BIN --profile PRIVATE.json --include DIR [TEST ...]
python3 tools/run_sby.py --sby "$SBY_BIN" --json FILE
```

シミュレーション用ランナーは`:type: formal`を除き、フォーマル検証用の`run_sby.py`はformalを選びます。 `--json`を付けた結果だけが証跡になります。 `zsh`では変数が空白で分かれないため、テスト一覧は配列などで渡してください。 一覧が空なら実行を止めます。位置引数なしでは通常の全件選択になるためです。

<a id="6-updating-and-checking-changes"></a>

## 6. 変更後の更新・確認手順

<a id="61-checks-the-ci-scope"></a>

### 6.1 検査（CIと同じ範囲）

```sh
python3 -m unittest discover -s tools -p 'test_*.py'
python3 generators/generate.py --check
python3 tools/interaction_coverage.py --check
python3 tools/chapter_cross_matrix.py --check
python3 tools/chapter_cross_triage.py --check
python3 tools/combination_gaps.py --check
python3 tools/suite_stats.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check --minimum-tests 2
python3 tools/behavior_coverage.py --check --require-source-reviewed
python3 tools/requirement_matching.py --check
python3 tools/lint_metadata.py
python3 tools/generator_catalog.py --check
python3 tools/documentation_languages.py --check
git diff --check
```

元の29モデルの引き継ぎ時点ではツール単体539件、その後の55モデル追加時点では552件が成功しています。ドキュメントの日英対応後の検査対象は582件です。件数はツール追加に伴って変わるため、その時点の実行結果を確認してください。各レポートは`--update`で再生成します（`coverage_depth.py`は`--minimum-tests 2`、`behavior_coverage.py`は`--require-source-reviewed`を付けます）。生成テストの更新は`python3 generators/generate.py`です。文書一覧は`documentation_languages.py --update`で更新し、手書き文書の両言語を確認した後に同ツールの`--record`で指紋を記録します。

<a id="62-after-correcting-a-test"></a>

### 6.2 テストを直したときの順序

1. 条項を根拠に最小限の修正をする。コメントに条項と理由を自分の言葉で書く （規格本文の転載はしない。コメントは80桁、コードは100桁）。
2. `python3 tools/lint_metadata.py`で新規の問題が0件であることを確認する。
3. 入力が変わるので、`:oracle:`に`iverilog@13.0`や`verilator@5.052`があるテストは そのリリースで再実行する（Verilatorは両seed）。再現しなくなったトークンは外し、理由を書く。 新しいトークンの追加はレビューが必要。
4. 証跡を`coverage/results/`へ新しい名前で保存する。過去のJSONを上書きしない。
5. §6.3の対応付けを更新し、§6.1の更新と検査を実行する。

<a id="63-updating-requirement-mappings"></a>

### 6.3 要求の対応付けの更新

テストの入力が変わると、`coverage/behaviors.json`の`requirements[*].checks[*]`と `coverage/test-matching-reviews.json`の`reviews[*]`が古くなります（`inputs_sha256`の不一致）。

- 古くなった記録を探す：`inputs_sha256`と`suite_results.input_digest(Path(test))`を比べる。
- 変更後のテストでも観測が成り立つなら、`inputs_sha256`・`reviewed_on`・`reviewer`を更新し、 `evidence[*].contains`が今のファイルの部分文字列であることを確かめる（移動した行、 書き換えた正規表現、ずれた行番号に貼り直す）。
- 観測の内容が変わったなら`observation`も書き直す。既存の記述の言語と調子に合わせる。
- 成り立たなくなった記録は、根拠から外すか保留にする。外すと `behavior_coverage.py --check`が「coverage regression」で止まるので、 `--write-baseline --reason "..."`で理由を残す（理由は英語の1段落。既存の記録を参照）。
- 分担している要求（collective witness）の構成が変わった場合も基準の更新が必要。
- `coverage/combination-gaps.json`の`bindings[*].inputs_sha256`も同じ仕組みで古くなる。 `combination_gaps.py --update`が検出する。

**注意**：指紋だけを現在値へ書き換えて済ませない。刺激・観測・期待値・条項を読み直してから更新する。

<a id="7-reading-list"></a>

## 7. 読む資料

- [検証ガイド・保存実行の概要](interaction-verification.md)：登録モデルの定義、制約、対象外、 モデル別の確認記録。
- [考え方と実践手順](interaction-verification-method.md)：因子モデルの作り方、 読み方が分かれる場合の扱い、追加手順。
- [クロス検証レポート](interaction-coverage.md)：計画と実行の集計（自動生成）。
- [固定版の差異一覧](simulator-differences.ja.md)：Icarus 13.0・Verilator 5.052と規格の差。
- [補助証跡](../coverage/interaction-qualification/README.md)：最小例、故障注入、ビルド指紋。
- [要求カバレッジ集計](behavior-coverage-summary.md)・[台帳と手順](../coverage/README.md)。
- [テストカタログ](tests/README.ja.md)・[条項一覧](tests/clauses.ja.md)・ [条項別テスト数](coverage-depth.ja.md)（いずれも自動生成）。
- [FAQ](faq.md)・[用語集](glossary.md)。
- README（[日本語](../README.ja.md)／[英語](../README.md)）の「テストの形式」「メタデータ」 「合否の判定方法」「期待出力の決め方」「変更への参加」。
- [履歴](history.ja.md)：以前の測定値。READMEの数値を履歴の値へ読み替えない。

<a id="8-checks-when-resuming"></a>

## 8. 再開時の確認

```sh
git status --short --branch
git fetch origin
git log -5 --oneline
git rev-list --left-right --count HEAD...origin/main

git -C ../kirimasim status --short --branch
git -C ../kirimasim fetch origin
git -C ../kirimasim log -5 --oneline
git worktree list
```

本体には別セッションの作業と未pushのコミットがある場合があります。確認してから作業範囲を決め、 必要なら隔離した作業ツリーを作ってください。

<a id="example-starting-instruction-for-codex"></a>

## Codexへ渡す開始指示の例

```text
このリポジトリの docs/codex-handoff-20261031.md を読み、記録と現在のGit・CI・
隣接kirimasimの状態の差分を確認してください。
既存の期待値・oracle・履歴を保持し、シミュレータは実行直前に確認した最新コミットから
ビルドします。計画の網羅、実行の充足、Check/Nightly、要求カバレッジを区別してください。
この後のユーザー指示に沿って作業し、検証結果と残件を日本語で報告してください。
```

<a id="9-maintaining-bilingual-documentation"></a>

## 9. 日英ドキュメントの保守

[資料一覧](README.ja.md)から日英の各ページを参照できます。READMEには現在の構成・数値・実行手順を置き、過去の測定と作業経緯は履歴または日付付き資料へ記載します。手書き資料は両言語を同時に更新し、意味・数値・コマンドを確認してから指紋を記録します。生成レポート・カタログ・章間CSVも同じ元データから両言語を更新します。

手順と翻訳データの来歴は[翻訳の保守ガイド](../tools/doc_locales/README.ja.md)を参照してください。文書の日英対応では、シミュレータの実行、テスト入力・期待値・過去の実行証跡の変更は行っていません。
