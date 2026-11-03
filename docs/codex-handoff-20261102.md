<a id="handoff-interaction-verification-and-model-based-random-comparisons-2026-11-02"></a>

# 引き継ぎ：クロス検証とモデルに基づくランダム比較（2026-11-02）

[English](codex-handoff-20261102.en.md) / [日本語](codex-handoff-20261102.md)

この資料は`kirimasim-tests`の作業を引き継ぐためのものです。コマンドは、このリポジトリのルートで実行します。
以下の数値は基点コミットの記録です。再開時にはGitHubの状態と最新コミットを確認してください。

その後の状態は[2026-11-04の確認済み状態](nightly-results.md#latest-verified-checkpoint)、
[現在のクロス検証の優先事項](cross-verification-followup.md)、[13プロファイルの安定化](random-cross-verification.md#thirteen-profile-stabilization)を参照してください。
現在の件数・着手状況はそちらを優先し、以下は当時の基点の記録として保持します。

<a id="1-baseline-and-current-request"></a>

## 1. 基点と今回の依頼

- ブランチは`main`、基点は`3894c997f9662b96869c4e8c78d5470edbf4dca7`（モデルに基づくランダム比較の導入）です。
  資料作成前に`git fetch origin main`を実行し、`HEAD...origin/main`の差分が`0 / 0`、作業ツリーがクリーンであることを確認しました。
- 今回の依頼は引き継ぎ資料の作成です。この資料・READMEのリンク・資料一覧の変更は、作成時点では未コミットです。
  commit・pushは別途依頼されたときに行います。
- 直前の「READMEのP1進捗表を復活」という依頼は、ユーザーが別リポジトリとの取り違えとして取り消しました。
  その依頼によるファイル変更はありません。復活作業を再開しないでください。
- [2026-10-31の引き継ぎ](codex-handoff-20261031.md)は過去の経緯を保存したものです。
  古い件数、未着手という記述、ブランチやIssueの状態を現在の状態として扱わないでください。

<a id="2-current-verification-scope-and-evidence"></a>

## 2. 現在の検証規模と証跡

- 通常スイートは**10,289件**、うち生成テストは**3,852件・74生成器**です。
- 有限クロスモデルは**65モデル・2,539選択ケース・96章対**、全選択ケースのPASSを保存証跡で確認できるものは**47モデル**です。
- 章対の仕分けは、重複を除く820対について**M96 / E10 / C5 / N117 / R592**です。
  `M`は登録済みモデル、`E`は既存テストの根拠あり、`C`は追加設計候補、`N`は対象外、`R`は未精査・後回しです。
  登録済みP1候補はすべてモデル化していますが、全章対の検証完了やシミュレータの実装完了を意味しません。
- 要求カバレッジは設計**10,983 / 12,298（89.31%）**、実行確認**9,539 / 12,298（77.57%）**です。
  実行確認はIcarus Verilog・Verilator・SymbiYosys・Ghostの保存証跡の和集合で、kirimasim単独の値ではありません。
- 有限クロス全件の保存実行は[kirimasim `80859f34`](../coverage/interaction-results/cross65-kirimasim-80859f34.json)の
  **2,207 pass・326 unsupported・既存6 fail**です。6件は`inside`／`case inside`の幅・符号の差異2件と、configのパラメータリセット4件です。
  この版を現在の上流最新版と表現しないでください。
- 後述の`866abf4d`によるランダム比較は、有限クロス2,539件を再実行した結果ではありません。
  `known`、`unsupported`、補助対照の成功、計画上のt-way網羅を、元の選択ケースのPASSへ読み替えないでください。

件数の確認先は[README](../README.ja.md)、[生成器カタログ](generators.ja.md)、
[クロス計画と保存実行](interaction-coverage.md)、[章間マトリクスとCSV](chapter-cross-matrix.md)、
[0セルの仕分け](chapter-cross-triage.md)です。モデルと章対は`coverage/chapter-interactions.json`、
候補と照合根拠は`coverage/chapter-cross-triage.json`で管理しています。

<a id="3-recent-finite-interaction-additions"></a>

## 3. 直近の有限クロス追加

設計思想・追加手順は[考え方と実践手順](interaction-verification-method.md)、
モデルごとの規格根拠・対照・実行条件は[設計と検証記録](interaction-verification.md)にあります。
全組合せの列挙ではなく、合法条件を定めた因子モデルに対し、2因子網羅、必要な3因子網羅、境界ケースを選択します。
低次の組合せ網羅と、誤りを観測できる期待値・対照を併せて確認する方針です。

- `92fcd234`：強度表示（31件、第21章×第28章）、クラス内virtual interface（13件、第8章×第25章）、
  clockingイベントの`iff`（12件、第9章×第14章）を追加しました。
  `80859f34`では強度表示31件がPASS、残る2モデルは未対応です。
  clockingの固定Verilator確認はスカラ4件とベクタ8件で結果が異なり、ベクタ用補助式の成功を元の8件の成功には数えていません。
- `a9c4d924`：連想配列と配列問い合わせ（18件、第7章×第20章）を追加しました。
  固定Icarusは全件ビルド拒否、固定Verilatorは全件出力差異、kirimasim `80859f34`は全件未対応です。
  期待値は規格から決定しています。独立計算216行とPython参照モデルの変異6件は確認しましたが、
  シミュレータ上の正常対照・SV故障注入の成功ではありません。
- `9543b49b`：配列縮約と制約（13件、第7章×第18章）を追加しました。
  固定版では元の13件の一致を確認できず、`80859f34`も全件未対応です。
  独立計算192行と、固定配列用の補助正常対照4件・SV故障注入7件を確認しました。
  補助対照の観測式に付けた要素型キャストを、元のテストや期待値へ逆輸入していません。
  動的配列のサイズ保持まで実行確認できたという意味でもありません。

後二者の機械可読記録は`coverage/interaction-qualification/assocquery*.json`と
`coverage/interaction-qualification/randreduce*.json`、補助対照の実行手順は`tools/qualify_randreduce.py`にあります。
既存テスト・期待値・oracle・過去の実行記録は保持しています。

<a id="4-new-random-comparison-feature"></a>

## 4. 新しいランダム比較機能

基点`3894c997`で導入しました。[利用手順と判定規則](random-cross-verification.md)を先に読んでください。
中心となるファイルは`tools/random_cross_models.py`、`tools/run_random_cross.py`、`tools/test_random_cross.py`です。

- `expression_context`：式の幅・符号・代入先幅と加減乗算。`generators/interaction_expr.py`の参照計算を再利用します。
- `division_context`：商・剰余の自然幅と代入先幅、符号付きの0方向への切り捨て。
  `generators/interaction_divide.py`を使い、入力は既知値、除数は非ゼロです。
- `packed_write_sequence`：packed配列の昇順／降順、`+:`／`-:`、bit／logic、合法な位置・データ・read/write列。
  X/Zと未選択ビットの保持も、ベクトル全体を管理する参照モデルで比較します。

これは65モデルすべてのランダム化ではありません。クラス、制約ソルバ、`randomize()`、並行スケジューリング、
範囲外添字などは対象外です。複数解のある制約は、出力の完全一致とは別の適合判定が必要です。
ランダムサンプルの成功数は、固定テスト件数・章間表・要求カバレッジへ加算しません。

Nightlyの既定値は96ケース×8ベクトル／操作、4並列、1件5秒、比較全体120秒です。
上限は256ケース×32、8並列、1件30秒、全体600秒です。追加ステップ全体にはビルドを含め15分の上限があります。
比較CLIは、全件が有効な`pass`のときだけ終了コード0です。
`fail`、`unsupported`、`not_run`、`stale`は成功に数えません。`--generate-only`の終了コード0は生成成功だけを表します。

seedだけでなく実入力・操作列を`manifest.json`に保存し、SV・期待値・stdout/stderr・終了コード・ソースとバイナリのハッシュを記録します。
再現には`--replay`を使います。出力先は新規または空のディレクトリが必要です。
自動的な反例縮小は未実装です。

<a id="locally-verified-scope"></a>

### ローカルで確認済みの範囲

[妥当性確認の記録](../coverage/interaction-qualification/random-cross.json)と
[保存した96ケースのmanifest](../coverage/interaction-qualification/random-cross-manifest.json)を参照してください。

- 実行直前に取得・ビルドしたkirimasim `866abf4d86d11130a9946b79ea5fd19e2913b19c`で、
  seed 1は96件、seed 73は96件、seed 20261102は256件、合計**448件PASS**です。
- 保存刺激からの1件再現はPASSで、SVと期待値は元とバイト単位で同一です。
  正常対照1件はPASS、SVの加算を減算へ変えた変異1件は正常終了のまま出力差異として検出しました。これらは448件と別枠です。
- 固定Icarus 13.0でも各プロファイル4件、合計12件が一致しました。
- 導入時のツール単体テストは**653件PASS（従来622＋新規31）**、整合性検査13項目が成功しました。
  この結果を、この引き継ぎ資料の作成時に全件再実行したという意味にはしないでください。
- 保存記録のテストリポジトリ版は`9543b49b`＋未コミット変更です。記録内のソースハッシュで導入したコードを特定しています。
  後から実行履歴のコミット欄を`3894c997`へ書き換えないでください。

<a id="5-ci-status-and-how-to-check-it"></a>

## 5. CIの状態と確認方法

<!-- handoff-ci-snapshot:begin -->
外部状態の確認：2026-11-02 06:18 JST。

- 基点`3894c997`の[Check（41350297782）](https://github.com/kurochan001/kirimasim-tests/actions/runs/41350297782)は**成功**しました。
  `icarus`・`verilator`・`readme`の3ジョブすべてが成功しています。この資料の未コミット変更は対象に含みません。
- 直近の[Nightly成功（41248878297）](https://github.com/kurochan001/kirimasim-tests/actions/runs/41248878297)は
  `7cf35321ce1bb18e059facfab4ddead871d94358`を対象とし、2026-11-01 11:36 JSTに完了しました。
  基点より前の実行で、新しいランダム比較ステップのGitHub上での成功証跡にはなりません。
<!-- handoff-ci-snapshot:end -->

Checkには生成・manifest再現・ツール単体テストを追加しました。最新版kirimasimによるランダム実行はNightlyの担当です。
Nightlyは固定スイートの実行後、上流mainをもう一度取得・ビルドしてからランダム比較を行います。
seedはGitHub run IDです。再試行でも上流版が変われば実行版は変わるため、版と刺激を両方確認してください。
ランダム比較は1件でも非PASSならステップ失敗、固定回帰のratchetは別判定です。
再現用artifactは`random-cross-kirimasim`で、公開用`results-*`とは別に保存します。

```sh
git status --short --branch
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
gh run list --workflow check.yml --limit 5
gh run list --workflow nightly.yml --limit 5
gh run view RUN_ID --json status,conclusion,jobs
```

<a id="6-recommended-order-when-resuming"></a>

## 6. 再開時の優先順

1. 基点のCheck成功を確認済み。再開時には後続コミットのCheckと、新しいNightlyがあればテスト側SHA・シミュレータ側SHA・ランダム比較のartifactを確認する。
   古いNightlyやローカル448件の結果だけで、最新NightlyをPASSと報告しない。
2. [#45](https://github.com/kurochan001/kirimasim-tests/issues/45)（covergroup遷移の括弧とカンマ）、
   [#46](https://github.com/kurochan001/kirimasim-tests/issues/46)（ブロック変数初期化と寿命）、
   [#47](https://github.com/kurochan001/kirimasim-tests/issues/47)（nullを保持する変数の`$cast`）はOPENです。
   今回は状態と指摘対象を確認しただけで、規格照合や修正は行っていません。規格・現在のテスト・期待値を自分で照合する。
3. [#40〜#44の照合と修正](issues-40-44-review-20261031.md)は実施済みですが、GitHubでは5件ともOPENです。
   未着手としてやり直さず、修正後の状態と残る実装上の制約を確認する。
   [#24](https://github.com/kurochan001/kirimasim-tests/issues/24)、
   [#27](https://github.com/kurochan001/kirimasim-tests/issues/27)、
   [#28](https://github.com/kurochan001/kirimasim-tests/issues/28)もOPENです。
   過去の修正と残件が混在するため、Issue本文の全件を未修正とはみなさない。Issue投稿・クローズは今回行っていません。
4. クロス追加を再開するなら、[仕分け台帳](../coverage/chapter-cross-triage.json)のE/Cと未精査Rから、
   観測可能な共有状態・境界を選ぶ。例えば第11章×第18章の`dist`と式の優先順位、
   第16章×第27章のgenerateと`default disable iff`は次の照合候補です。既存根拠のあるテストも、モデル化は別途必要です。
5. ランダム比較を広げるなら、実入力・操作列に対する独立した期待値を計算できるプロファイルから追加する。
   固定期待値の順番を変えるだけのものや、Verilator初期値seedだけの変更をランダム刺激の検証と呼ばない。
6. 有限クロスの既存6不一致や実装改善を確認するには、最新の本体を取得・ビルドして全件を新しいファイル名で保存する。
   今回は本体の実装を変更していません。期待値変更で不一致を隠さない。

<a id="7-policies-and-working-environment"></a>

## 7. 守る方針と作業環境

- 日本語で進捗と結果を簡潔に報告し、長い作業中も状況を共有する。ドキュメントは日英を同時に更新する。
- シミュレータ実行の直前に上流最新コミットを取得し、その版をビルドする。`--commit`と`--version`の一致だけでは上流の最新性を証明できない。
  Icarus 13.0・Verilator 5.052は固定oracle確認の例外です。2状態の固定Verilator確認はseed 1・73で行う。
- 既存テスト、期待値、oracle、履歴証跡を保持する。GPL/LGPLシミュレータの実装ソースを読まない。他プロジェクトの再現コードをコピーしない。
- 商用シミュレータは実行・比較せず、第三者の出力・診断も挙動解析や期待値・実装判断へ使わない。
  Issue本文・コメント・添付・外部リンクにも入れない。[FAQの方針](faq.md#8-商用シミュレータでの確認状況)を参照する。
  規約の一般的な禁止範囲を断定しない。Ghostの実名・版・実行環境は公開しない。
- Icarus・Verilatorとの差異は上流へ報告せず、[固定版の差異記録](simulator-differences.ja.md)へ記載する。
  kirimasimとLyraの結果を混同しない。規格本文・非公開資料・個人情報・ホームの絶対パスを公開ファイルへ入れない。
- 隣の`../kirimasim`には別作業の文書変更があります。直接編集・リセットしない。
  本体を変更する場合はそのリポジトリの指示を読み、隔離したworktreeを使う。
- このホストの実行用worktreeは`/tmp/kirimasim-cross56-source`、ビルド先は`/tmp/kirimasim-cross56-build`です。
  ローカルの完全なランダム実行記録は`my-results/random-cross-validation-20261102-1/`配下にあります。
  いずれもホスト依存・非追跡のため、存在と版を再確認する。PATHのIcarusは14の場合があり、固定13として扱わない。
- `RTK.md`の参照先はホームの`.claude/RTK.md`です。RTKのメタコマンド以外は通常のコマンドを使う運用です。

<a id="8-replay-and-documentation-updates"></a>

## 8. 再現と文書更新の手順

シミュレータの最新取得・ビルドと実行版の記録は、[ローカル実行手順](random-cross-verification.md#run-locally)に従ってください。
取得・ビルド後に、保存済み刺激を別ディレクトリへ再現できます。

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-manifest.json \
  --output my-results/random-cross-handoff-replay
```

実行せず生成だけ確認する場合：

```sh
python3 tools/run_random_cross.py --generate-only --seed 731 --cases 12 \
  --output my-results/random-cross-handoff-generated
```

日英の手書き文書を両方更新し、新規文書なら`docs/languages.json`へ対を登録してから、次を順番に実行します。
`--record`は翻訳を行うコマンドではなく、両言語の変更を確認した後に指紋を更新するコマンドです。

```sh
python3 tools/documentation_languages.py --update
python3 tools/documentation_languages.py --record
python3 tools/documentation_languages.py --check
python3 tools/suite_stats.py --check
git diff --check
```

モデルやツールを変更した場合は、影響に応じて`generators/generate.py --check`、
`tools/interaction_coverage.py --check`、章間表・仕分け・要求対応の整合性検査、ツール単体テストも実行します。
文書だけの変更を、新しいシミュレータ実行証跡として扱わないでください。

本資料の作成時には、日英114組の整合、ローカルリンク52,135件、英語本文の未翻訳残り、READMEの集計、差分の空白を検査し、すべて成功しました。
