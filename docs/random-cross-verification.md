<a id="model-based-random-cross-comparisons"></a>

# モデルに基づくランダムクロス比較

[English](random-cross-verification.en.md)

Checkの固定クロス検証に加え、Nightlyで件数制限付きのランダム比較を行います。
同じ刺激をSystemVerilogの設計とPythonの参照モデルへ与え、規格で一意に定まる出力を照合します。
固定回帰のケース、oracle、有限モデルの分母は維持します。ランダム実行の本数や成功を、
固定スイートのテスト数・章間マトリクスの合格数・要求カバレッジへ加算しません。

<a id="purpose-and-roles"></a>

## 目的と役割分担

目的は、固定クロスの代表ケースに加え、具体的な入力値・初期状態・操作履歴を変えて、
まだ観測していないデータ依存の不具合や機能間の相互作用の反例を探すことです。
例えば同じ幅・符号・添字方式でも、値が違えば桁あふれや符号拡張の結果が変わり、
同じ範囲へ書く順序が違えば、その後の読出しや非選択ビットの保持の確認結果も変わります。
見つけた失敗を再現可能な証拠として保存し、原因を確認したものを固定回帰へ引き継ぎます。

- **固定回帰・有限モデルのクロス検証**は、選択した因子の組合せと必須境界を毎回確認します。
  ランダム抽出で境界が選ばれることを期待して置き換えません。
- **このランダム比較**は、対応するプロファイル内で入力値や操作列を追加探索します。
  生成にはPythonの乱数を使い、シミュレータと参照モデルには同じ具体的な刺激を渡します。
  シミュレータ内の乱数列の一致や、`randomize()`の制約ソルバを検査する機能ではありません。
- **kirimasim本体の内部モデル比較・libFuzzer**は、値演算・schedulerやコンパイル処理などを
  本体側の基盤で検査します。本資料のSV入力による外部比較とは役割を分けて維持します。
  [本体の検証方針](https://github.com/kurochan001/kirimasim/blob/main/docs/VALIDATION.ja.md)を参照してください。

ランダム比較の成功は、全入力や全操作列の正しさ、全因子の組合せ網羅、未検出不具合がないことの証明にはなりません。
現在の3プロファイルが扱わない機能も自動的には探索しません。
生成分布はコードで定義したseed付き抽出です。カバレッジのフィードバックによる分布の自動調整は未実装です。
参照計算の一部は固定クロスの関数と共用するため、ランダムに繰り返すだけでは参照モデル自体の誤りを排除できません。
規格との照合、手計算した境界、[参照と実行基盤の回帰テスト](../tools/test_random_cross.py)を併用します。

<a id="verification-process"></a>

## 検証の流れ

1. **合法な条件を選ぶ。** 対応プロファイルにケースをほぼ同数ずつ割り当て、seedで順番と合法な
   パラメータを選びます。対象と制約は[生成器・参照モデル](../tools/random_cross_models.py)が定義します。
2. **値と操作履歴を具体化する。** 算術値の生成では、確率1/4で0・1・全ビット1・最上位ビットだけ1・
   その値から1を引いたビット列という境界候補から選び、それ以外は幅分の乱数ビットを使います。
   除数が0なら非零値へ引き直し、配列の位置は選択幅に応じた範囲内で選びます。
   書込み列は初期値・位置・データと操作順を生成し、X/Zも注入します。
   同じ選択範囲への「書込みA→読出し→書込みB→読出し」と逆順の列は別の刺激です。
3. **同じ刺激からSVと期待値を作る。** 算術結果や操作ごとの全体ビット列を規格由来の参照計算と
   照合できる形にします。最終値だけでなく途中の読出しと非選択ビットの保持も確認します。
4. **実行条件を記録して比較する。** 直前に取得・ビルドしたkirimasimと既存の正規化・判定処理を使います。
   オプションの他シミュレータ比較にも同じ保存済みSVを渡し、各ツールを期待値と個別に比較します。
   シミュレータ同士の一致や多数決だけで合格にはしません。
5. **保存して再現する。** seedに加え、実際の刺激・SV・期待値・出力・版・指紋を保存します。
   再現は[保存刺激のreplay](#immutable-replay)を使い、再抽選しません。
   未対応・時間切れ・未実行・古い証拠を成功として扱いません。
6. **失敗を固定回帰へ引き継ぐ。** 規格解釈・参照モデル・runner・シミュレータの問題を切り分け、
   確認した機構を[固定回帰候補](#failure-regression)へ反映します。再試行が成功しても元の失敗証拠を残します。

同じ幅・符号を過去に使ったことを理由に生成対象から外しません。
[重複管理](#exploration-admission)は任意の追加探索における完全同一ジョブの投入管理に限り、
固定回帰・正式Nightly・明示的なreplayは再実行します。

<a id="scope"></a>

<a id="scope-and-generation"></a>

## 対象と生成方法

現在対応しているのは、次の3プロファイルです。既存の有限モデル全体を任意の入力に対応させたものではありません。

- `expression_context`：幅・符号・代入先の幅・加減乗算を組み合わせ、任意の既知の入力ビット列を比較します。
  既存の`generators/interaction_expr.py`の参照関数を使います。
- `division_context`：自然幅と代入先の幅での商・剰余を比較します。
  `generators/interaction_divide.py`の参照関数を使い、符号付きの商は0方向へ切り捨てます。
  このプロファイルの入力は既知値で、除数は0以外です。ゼロ除算とX/Z入力は固定回帰に残します。
- `packed_write_sequence`：パック配列の昇順／降順、`+:`／`-:`、bit／logicを組み合わせます。
  ケースごとに選択幅を固定し、範囲内の位置、書込み値、読出しと書込みの操作列を変えます。
  全体のビット列を毎回観測して、選択していないビットの保持とX/Zの2状態変換も照合します。

幅は1・32・33・64・65・129を使い、算術式のオペランドと代入先にはモデルが許す±1ビットの差も含めます。
算術値は一様なランダム値と0・1・型の端点などを混ぜます。書込みプロファイルではX/Zも生成します。
各プロファイルをほぼ同数ずつ割り当て、順番と合法なパラメータをseedで選びます。
操作列の先頭は書込み、2操作目があれば読出しとし、以降は読出し／書込みを選びます。
同じ組合せが再び選ばれることはあります。ランダム抽出を2因子・3因子網羅の保証には使いません。

範囲外の添字、空コンテナ、並行スケジューリング、クラス、制約ソルバ、`randomize()`自体は今回の対象外です。
複数解のある乱数生成を確認するときは、生成値の完全一致ではなく制約の充足を判定する別の検査が必要です。

<a id="limits-and-verdicts"></a>

## 件数制限と判定

Nightlyの既定値は96ケース、各8ベクトル／操作、4並列、1ケース5秒、比較処理全体120秒です。
CLIの上限は256ケース、各32ベクトル／操作、8並列、1ケース30秒、全体600秒です。
全体の時間切れで着手できなかったケースは`not_run`、実行中の時間切れは`fail`にします。
ビルド時間はこの比較処理の制限とは別で、Nightlyの追加ステップ全体には15分の制限があります。

- `pass`：終了コード0、エラー診断なし、正規化した標準出力が期待値と一致。
- `fail`：出力差、非ゼロ終了、異常終了、エラー診断、実行時間切れなど。
- `known`：固定版oracleの登録がないIcarus／Verilatorでの不一致。passにはしません。
- `unsupported`：kirimasimが終了コード2と未対応の診断を返した。
- `not_run`：全体の時間制限までに着手できなかった。
- `stale`：実行中にSV・期待値・manifest・参照コード・実行ファイルが変化した。

全ケースが有効な`pass`の場合だけ、比較のCLIは終了コード0になります。
未対応や未実行を合格へ読み替えません。`--generate-only`の終了コード0は生成成功だけを意味し、
実行の`pass`は0件です。正常な標準出力が出ても、非ゼロ終了なら失敗です。

<a id="run-locally"></a>

<a id="run-a-latest-build-locally"></a>

## 最新ビルドで実行する

実行直前に上流mainを取得し、そのコミットをビルドしてください。既存の作業を保持するため、
シミュレータには専用のクリーンなチェックアウトを使います。次はそのディレクトリからの例です。

```sh
git fetch origin main
git switch --detach FETCH_HEAD
cmake --preset release
cmake --build --preset release
git rev-parse HEAD
build/release/src/driver/kirimasim --version
```

表示された完全なコミットと、そのバイナリのパスを指定して本リポジトリから実行します。

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/kirimasim/build/release/src/driver/kirimasim \
  --commit VERIFIED_FULL_COMMIT --seed 731 \
  --cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120 \
  --output my-results/random-cross-731
```

`--commit`は40桁のコミットを要求し、バイナリの`--version`が示すコミットと照合します。
この照合だけで上流の最新性が証明されるわけではありません。取得・ビルドは呼出し側の責任です。
出力先は新規または空のディレクトリに限ります。以前の証跡を上書きしません。

<a id="replay"></a>

<a id="replay-saved-stimuli"></a>

## 保存した刺激から再現する

出力先には`manifest.json`、`run.json`、日英の`report.md`／`report.ja.md`、`events.jsonl`と、
`cases/`内のSV・期待値・標準出力・標準エラーを保存します。
manifestにはseedだけでなく、実際の入力値と操作列をすべて記録します。
runにはスイートのコミットと参照コードの変更有無、生成器の版、コードのハッシュ、
シミュレータのコミット・版・バイナリ指紋、各入力と期待値のハッシュ、終了コードと判定を記録します。

同じseedでも生成器や実行環境の変更で同じ刺激になるとは限らないため、再現時はmanifestを使います。
再実行時も、その直前に取得・ビルドしたシミュレータのコミットを指定してください。

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay my-results/random-cross-731/manifest.json \
  --case case_0007 --output my-results/random-cross-731-replay
```

`--case`を省くと保存した全ケースを再実行します。再現時はseed・件数・モデルなどの生成オプションを併用できません。
再抽選せず、保存された刺激を使います。元artifact一式がある場合、既定ではそのSV・期待値を使い、現在の参照で作った内容との差を別に記録します。
現在の参照による期待値で実行するには`--reference-policy current`を明示します。
manifest単体では現在の参照から具体化し、過去のSV・期待値のバイト列は確認できません。
[参照変更の扱い](#immutable-replay)を参照してください。自動的な反例最小化は未実装です。

シミュレータを起動せずに刺激と期待値を確認することもできます。

```sh
python3 tools/run_random_cross.py --generate-only --seed 731 --cases 12 \
  --output my-results/random-cross-731-generated
```

<a id="ci"></a>

<a id="check-and-nightly-responsibilities"></a>

## CheckとNightlyの役割

[Check](../.github/workflows/check.yml)は、従来の固定回帰と整合性検査を維持します。
追加した検査は、生成・保存manifestからの1ケース再現・SVと期待値のバイト一致、およびツールの単体テストです。
Checkに最新kirimasimでのランダム実行を追加してはいません。

[Nightly](../.github/workflows/nightly.yml)のkirimasimジョブは、固定スイートの後に上流mainを再取得・ビルドし、
直後にランダム比較します。seedはGitHubのrun IDです。同じrunの再試行では同じ刺激を生成できますが、
上流版が変わっていればその版での新しい実行になります。
非PASSが一つでもあればステップを失敗させ、通常の固定回帰のratchetも別に確認します。

再現資料は`random-cross-kirimasim`という専用artifactに保存し、日英レポートのうち英語版をStep Summaryへ載せます。
このartifactは`results-*`という公開処理の取得対象に含めません。固定回帰の履歴・グラフ・要求カバレッジへ混ぜません。
保存結果やローカルでの成功は、GitHub上のNightly実行成功を意味しません。

<a id="validation"></a>

<a id="initial-validation"></a>

## 導入時の検証

実際の版・件数・seed・指紋と故障検出の記録は[補助証跡](../coverage/interaction-qualification/random-cross.json)を参照してください。
[保存した96ケースのmanifest](../coverage/interaction-qualification/random-cross-manifest.json)は、CLIの`--replay`で読み込めます。
固定スイートの合格数へは加算しません。通常の境界ケースと少数因子網羅は引き続き固定回帰で保持します。

<a id="exploration-admission"></a>

## 追加探索の投入管理

固定回帰と正式Nightlyは再実行し、**完全に同じ条件で完了した追加探索ジョブ**だけを
重複投入から省く方針です。幅・符号・パラメータ・値・操作を生成対象から恒久除外しません。
3プロファイルの乱数列・分布・上限は変更していません。操作順、繰返し書込み、初期状態も
入力なので、パラメータの組合せが等しくても同じ検証とは限りません。

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --seed 731 --explore --history my-results/exploration.sqlite3 \
  --output my-results/exploration-731-first
# 再投入は別の出力先へ。必ず実行する場合は --force を追加します。
```

標準ライブラリのSQLiteでジョブ全体の投入を排他管理します。実行中なら`in_flight`、
同じホストの所有プロセスが終了済みなら中断として再投入できます。PIDの開始時刻も照合します。
履歴DBはローカルで使ってください。生存を確認できない別ホストの所有権は自動で奪いません。
`--force`は意図的な並列再試行も可能にしますが、過去の結果は流用しません。中断資料は残し、
新規の出力先で再試行します。固定runnerは履歴DBを使いません。`--run-kind nightly`と
明示的な`--replay`は、探索オプションを併用しても省略しません。

必要な全シミュレータ・全ケースが終了コード0の有効なpassで完了した場合だけが対象です。
省略前に保存証拠の全ファイルを再照合します。最新の試行が失敗・中断・証拠不正なら、
それより前の成功へ戻りません。fail・known・unsupported・not_run・stale・起動失敗・
部分的な比較を再利用しません。重複／実行中の場合は`admission-only`のrunと日英レポートを
保存し、今回のpassは0件、実行結果は空にします。終了コードは**3が投入省略**、
**0が全比較成功（または生成のみの成功）**、**1が非pass**、**2が指定・準備の異常**です。
3を検証成功として扱わないでください。

入力と実行条件は別々に識別します。既存の`stimulus_sha256`はケースIDを含む意味を維持し、
追加の`content_sha256`だけがIDを除きます。操作列の全要素と順序は保持します。
ジョブ全体では管理IDも含め、SV・期待値のバイト列、artifactを基準にした既存の
`suite_results.input_digest`、既存の`runner_digest`、生成器・参照・正規化・adapterのコード指紋、
全シミュレータの実バイナリと依存物、版・コミット、各seed、制限・オプション・選択、
OS・Python・継承環境変数全体のハッシュまで保守的に照合します。環境変数の値は保存しません。
結果に無関係な環境変化でも再実行することがあります。出力先・履歴DB・forceは投入管理の指定です。

ネイティブ共有ライブラリは`otool`／`ldd`で調べ、macOSの共有キャッシュはOSの正確なbuildで
識別します。依存証拠が不十分なら必ず実行します。Icarusのバックエンド・設定やVerilatorの
C++ツールチェーンを含む完全な依存一覧には、繰返し指定の`--dependency FILE`と、
一覧の完全性を宣言する`--dependencies-complete`が必要です。依存物を特定せずに宣言しないでください。
外部比較のジョブは、一覧が完全でも必ず実行します。生成される実行物はコンパイル後にしか
同定できないため、投入時に以前と完全に同じ実行とは判断しません。一覧は由来の記録とstale検出に使います。
外部実装ソースを読む必要はありません。実行後も入力・コード・環境・実行物を照合し、変更はstaleにします。

<a id="immutable-replay"></a>

## 元の証拠を保持して参照変更を識別する

元の`run.json`と`cases/`を隣に保持した、**元artifactの**`manifest.json`を`--replay`へ渡します。
まず元の指紋を照合します。新artifactの`origin/`に元の証拠をコピーし、`current-reference/`に
現在の参照によるSV・期待値、`run.json.replay`に差分を記録します。既定では保存SV・期待値の
バイト列で実行し、現在の生成結果が違う場合は観測した状態を`observed_status`に残してstaleにします。
生成結果が同じでも、コード指紋の変更は別に表示します。

`--reference-policy current`を明示すると、保存刺激を現在の参照で評価します。元の証拠と差分は
保持し、元の失敗を修正・上書きしません。manifest単体からも再抽選なしで再現できますが、
`manifest_only`と表示し、過去のSV・期待値のバイト列は確認できません。失敗調査ではartifact全体を残してください。

<a id="saved-stimulus-comparison"></a>

## 保存した同じ刺激を他シミュレータで確認する

```sh
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay my-results/random-cross-731/manifest.json --case case_0007 \
  --icarus /path/to/icarus/bin/iverilog --verilator /path/to/verilator \
  --simulator-seed 1 --timeout 30 --time-budget 120 \
  --output my-results/random-cross-731-public-check
```

既存の`run_icarus.run`／`run_verilator.run`を、時間を制限した独立workerから呼びます。
保存SVのバイト列と元の補助ファイル参照をそのまま渡し、既存の期待値メタデータを優先します。
メタデータがない場合だけ保存済みの期待値ファイルを使い、刺激・期待値は再抽選しません。
コンパイル・実行コマンド、stdout/stderr（時間切れまでの部分出力を含む）、終了コードと実行物の
指紋を`comparisons/SIMULATOR/CASE/`へ残します。`builds`と`comparisons`でツールを区別し、
既存互換の`results`／`counts`はkirimasimの結果です。終了コード0には全ツールの個別成功が必要です。
シミュレータ固有期待値の優先順位とknownの分類を維持します。一致や多数決だけで正しさを判断せず、
規格由来のモデルと照合します。固定版oracleは自動登録しません。

パック配列の保存刺激にX/Zが一つでもあれば、bitへの変換も含めてVerilatorは保守的にunsupportedにします。
2値の結果から4値の動作を合格にしません。Verilatorの初期化seedは刺激seedと別に記録します。
各ツールの乱数列や制約解の一致は仮定しません。将来randomize()を扱う場合は、制約充足や状態保持を
検査します。Lyra／Ghostのrunnerと外部シミュレータの利用方針は維持し、今回のadapterはGhostを扱わず、
非公開のbuild・profile・診断を公開しません。過去の他ツール結果はその版・日時の観測であり、
今回のkirimasimのpassとして流用しません。

<a id="failure-regression"></a>

## 失敗を切り分けて機構別の固定回帰候補を作る

再試行がpassでも、元の失敗artifactは残します。まず規格解釈・参照モデル・runner・シミュレータの
どの問題かを分けます。言語仕様に関するシミュレータの問題を確認できた場合の例です。

```sh
python3 tools/promote_random_cross.py \
  --artifact my-results/FAILED_RUN --case case_0007 --simulator kirimasim \
  --classification simulator --confirmed --mechanism context_width \
  --chapter ch11 --lrm '1800-2023 11.8.2' \
  --explanation '確認した規格上の規則と、観測した違反を記載' \
  --output my-results/context-width-draft
```

元入力を検証し、`triage.json`と`tests/chNN`用の候補を作ります。HDL本体・期待値と由来を残し、
自動導入・期待値の緩和・oracle登録はしません。規格の根拠と機構をレビューしてから既存の章／generatorへ
反映し、metadata・generator・該当シミュレータで検証します。候補の`lint_problems`と標準出力に
書式の要修正箇所も示します。長いリテラルは、書換えによって失敗条件を消さないよう維持します。
レビューして書式を整えた後も不具合を再現できることを確認してから導入します。有効な記録のfail／knownで、現在の参照と
差がないものだけを候補にできます。pass／unsupported／not_run／staleは拒否します。
他の分類では切り分け資料だけを作ります。参照・runnerの問題は所有するPythonテストへ、本体内部の
値演算・scheduler・libFuzzerの問題はkirimasimのunit／機構別matrixへ追加します。
ツール検査用の模擬失敗から、新しい実シミュレータの不具合が確認されたとは判断しません。

正式Checkは固定Icarus 13.0／Verilator 5.052を、Nightlyは開発版を比較します。
ビルドキャッシュ・ccacheで減らすのはコンパイルであり、実行は省略しません。
Nightlyのrun ID・再試行番号と、直前のランダム用buildコミットを別に記録します。
同じNightlyでも、その前の固定スイートは以前のkirimasim版の場合があるため、固定結果自身の版を確認します。
`results_ratchet.py`のゲートは引き続きpass→failだけです。pass→unsupportedなどを黙って追加しません。
固定境界ケース、指紋付きのクロス実行証拠、固定履歴はそれぞれ維持します。
