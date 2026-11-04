<a id="model-based-random-cross-comparisons"></a>

# モデルに基づくランダムクロス比較

[English](random-cross-verification.en.md)

Checkの固定クロス検証に加え、Nightlyで件数制限付きのランダム比較を行います。
同じ刺激をSystemVerilogの設計とPythonの参照モデルへ与え、規格で一意に定まる出力を照合します。
固定回帰のケース、oracle、有限モデルの分母は維持します。ランダム実行の本数や成功を、
固定スイートのテスト数・章間マトリクスの合格数・要求カバレッジへ加算しません。

2026-11-04（日本時間）に確認した[`9926160a`のCheck・Nightly](nightly-results.md#latest-verified-checkpoint)は、ともに成功しました。
Nightlyの13プロファイルはkirimasim `9113955914d8`・seed `41743702063`で**96件すべて有効なPASS**です。
プロファイル追加はいったん13個で区切り、[重点探索と独立検算](#thirteen-profile-stabilization)で検証を深めます。

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
現在の13プロファイルが扱わない機能も自動的には探索しません。
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

現在対応しているのは、次の13プロファイルです。既存の有限モデル全体を任意の入力に対応させたものではありません。

- `expression_context`：幅・符号・代入先の幅・加減乗算を組み合わせ、任意の既知の入力ビット列を比較します。
  既存の`generators/interaction_expr.py`の参照関数を使います。
- `division_context`：自然幅と代入先の幅での商・剰余を比較します。
  `generators/interaction_divide.py`の参照関数を使い、符号付きの商は0方向へ切り捨てます。
  このプロファイルの入力は既知値で、除数は0以外です。ゼロ除算とX/Z入力は固定回帰に残します。
- `packed_write_sequence`：パック配列の昇順／降順、`+:`／`-:`、bit／logicを組み合わせます。
  ケースごとに選択幅を固定し、範囲内の位置、書込み値、読出しと書込みの操作列を変えます。
  全体のビット列を毎回観測して、選択していないビットの保持とX/Zの2状態変換も照合します。

- `conditional_context`：条件演算子`?:`の両分岐に任意の4状態ビット列を与え、符号、代入先の幅（±1ビットを含む）、bit／logicを交差します。
  条件0/1は一方の分岐を選び、条件X/Zは文脈幅へ拡張した後にビット単位でマージします。
  同じZ同士もXとなり、切詰めとbitへの変換はその後に行います。元の分岐値と条件も表示します。
  両分岐の元の幅は同じで、幅1のnarrowは生成しません。
- `package_change_sequence`：幅、bit／logic、修飾名／ワイルドカードimport／明示import、スカラー／固定配列、
  ブロッキング／NBA、全体／最下位ビットのイベント感度、論理等価／等価性のwait条件を交差します。
  共有変数・隣接要素・対照packageの初期値と書込み列を変え、二つの観測モジュールと独立した対照を読みます。
  関数内の外部参照に対するalways_comb感度、通知回数・時刻・通知時の全体値、現在のwait条件と保持した起床履歴を比較します。
  機構と規格の根拠は[固定クロスの設計](interaction-verification.md#package-change-observers)を共有し、固定8操作だけに限定しません。

- `shift_context`：任意の4状態ビット列に、`<<`／`>>`／`<<<`／`>>>`を適用します。
  左オペランドの符号、代入先の幅（±1ビット）、bit／logic、シフト量の幅8/32/65ビットと符号を交差します。
  0/1・元の幅と評価幅の前後・全1・ランダム値・部分的なX/Zを含むシフト量を生成します。
  代入文脈による拡張後にシフトし、算術右シフトでは符号ビットのX/Zも複製します。
  シフト量は自己決定で、signed宣言の全1も大きな非負の量として扱い、式の符号・幅へ伝播させません。
  X/Zを含む量は結果を全Xにし、その後に切詰めとbit変換を行います。
  IEEE 1800-2023の11.4.10・11.6.1・11.8.1/2・6.11.2に基づきます。
- `cast_pipeline`：サイズキャスト、signed／unsigned、型付きbit／logicキャストの中間値を観測します。
  元の符号、キャスト幅の±1ビット、元の幅+2ビットの代入先、後続演算の有無、bit／logicを交差します。
  signing castは幅を変えず、型付きキャストの型はunsignedです。幅1のnarrowは除外します。
  後続演算は符号付き2ビットの正の1を加える範囲に限定し、型付きbitへの変換が演算より前に起きることを照合します。
  実入力・キャスト結果・最終値を分けて表示し、IEEE 1800-2023の6.24.1・6.11.2・11.6.1・11.8.1/2に基づきます。

- `streaming_context`：左右のストリーム方向、pack／unpack、正のスライス幅、3ビットのタグの有無、bit／logicを交差します。
  任意の入力・タグを使い、1/2/3/4/7/8/16/17/32/33ビットや入力幅の前後のスライス幅を選びます。
  端の部分ブロックをパディングせずに並べ替え、unpackにはpackの逆置換を適用します。
  入出力の全体幅は同じで、IEEE 1800-2023の11.4.14.1/2/3・6.11.2に基づきます。
  動的配列、with指定、サイズ不一致による拡張や切詰めは対象外です。
- `concat_assignment_sequence`：連結左辺への書込み列で、全体幅2/32/33/64/65/129と任意の正幅の二分割を交差します。
  RHSの幅±1ビットと符号、各項のbit／logic、項の符号、ブロッキング／NBAを組み合わせます。
  初期値、入力値、予約直後に変更するRHSの値、操作順、繰返し書込みを保存します。
  RHSを連結全体の幅へ合わせてから分割・各項の変換を行い、直後と次時刻の値、符号拡張した項、unsignedの連結読出しを照合します。
  IEEE 1800-2023の11.4.12・10.7・10.4.1/2・6.11.2・11.8.1/2に基づきます。
  代入先は別々の静的な全体変数で、重複左辺・部分選択・複数writerの競合は対象外です。

- `comparison_context`：関係演算子4種、論理等価／不等価、等価性／非等価性、ワイルドカード等価／不等価の計10種を扱います。
  両オペランドの符号、RHSの幅±1ビット、代入先の幅1/7/33/65/130ビットを交差します。
  任意の4状態入力に、約1/4のRHSを左辺から幅合わせして作る入力も混ぜます。
  比較の共通幅・符号はオペランドから決め、unsignedの1ビット結果をlogic／bitの代入先へ別々に拡張します。
  既知の不一致による論理等価の確定と、右辺だけのX/Zワイルドカードを照合し、IEEE 1800-2023の11.4.4/5/6・11.6.1・11.8.2・6.11.2に基づきます。
- `packed_logic_context`：各入力で6種の単項リダクションと論理否定を全て観測します。
  入力のbit／logicと符号、直接参照／任意の連続部分選択／既知0または1の付加、出力のbit／logicと幅を交差します。
  入力のbit変換を式の形成より前に行い、既知0がANDを、既知1がORを確定することと、XORへの未知値伝播を照合します。
  1ビットのunsigned結果を拡張してから出力のbit変換を行い、IEEE 1800-2023の11.4.9・11.4.7・11.6.1・11.8.1・6.11.2に基づきます。
  二項論理演算、短絡評価の副作用、範囲外の部分選択は対象外です。

- `array_reduction_context`：固定配列／動的配列／キューの1～5要素を、sum／product／and／or／xorで集約します。
  要素の幅・符号・bit／logic、withなし／幅+1／int／integerの変換を交差し、実際の要素数、供給値と格納値、戻り値・拡張値・式の幅を観測します。
  要素型への変換、with式の変換、戻り型の幅での演算、代入先への拡張の順に照合します。広い代入先だけでは集約中の桁あふれを防げません。
  要素数1ではwith変換後の単一要素を返し、ZをXへ変える余分な演算を加えません。IEEE 1800-2023の7.12.3・6.24.1・11.8.2・6.11.2に基づきます。
- `unpacked_array_copy_sequence`：同じ要素型の固定配列同士で、全体／任意の合法な部分コピーと、コピー元・コピー先の個別更新を組み合わせます。
  要素数1～5、非ゼロの昇順／降順添字、要素幅・符号・bit／logicを交差します。
  開始位置は宣言順の位置で保存し、生成時に実際の添字へ写像します。配列全体と拡張読出しを毎回表示して、コピー範囲外の保持と値コピーの独立性を照合します。
  最初はコピー、2操作目があればコピーした元要素を更新し、以降はコピー／更新／繰返しを生成します。初期値と全操作の順序を保持します。
  IEEE 1800-2023の7.6・7.4.6・6.11.2・11.8.2に基づき、異なる要素型、重複する同一配列内のコピー、動的配列のコピーは対象外です。

原則の幅は1・32・33・64・65・129で、連結代入の全体幅は最小2です。算術式のオペランドと代入先にはモデルが許す±1ビットの差も含めます。
算術値は一様なランダム値と0・1・型の端点などを混ぜます。書込み・条件演算子・package・シフト・キャスト・ストリーミング・連結代入・比較・リダクション・配列操作のプロファイルではX/Zも生成します。
各プロファイルをほぼ同数ずつ割り当て、順番と合法なパラメータをseedで選びます。
packed_write_sequenceの先頭は書込み、2操作目があれば読出しとし、以降は読出し／書込みを選びます。
同じ組合せが再び選ばれることはあります。ランダム抽出を2因子・3因子網羅の保証には使いません。

packageは時刻零に初期化、時刻1に待機を登録し、最初の書込みを時刻5に置きます。単一writerが5刻みで更新し、直後の書込み対象と1刻み後の観測結果を分けます。初期値がゼロならwaitは時刻1に完了し、その後の起床履歴を上書きしません。操作列は最初に共有変数を書き、途中は共有変数・隣接要素・対照の更新と約1/4の同値再書込みを混ぜ、最後は共有変数を既知ゼロへ戻して進行を確認します。操作数1なら、この最後の書込みだけです。

範囲外・可変の監視添字、空コンテナ、独立writer同士の競合や任意の並行スケジューリング、クラス、制約ソルバ、`randomize()`自体は今回の対象外です。
複数解のある乱数生成を確認するときは、生成値の完全一致ではなく制約の充足を判定する別の検査が必要です。

2026-11-03の最初の追加では、既定の割当てを3から5プロファイルへ変えました。当時の96件は上記の最初の5種類に20/19/19/19/19件を割り当て、以前の各32件より各既存プロファイルの抽出数を減らしました。総件数と反復数を保って探索する機構を広げた変更で、既定の同じseedから生成する刺激列も変わりました。
続くシフトとキャストの追加時点では7プロファイルで、96件は従来5種類が各14件、新しい2種類が各13件でした。この時点で各既存プロファイルの抽出数は減り、既定の刺激列も5種類の時から変わりました。総件数・反復数・並列数・時間制限は維持しました。
ストリーミングと連結代入を加えた時点では9プロファイルで、96件は最初の6種類が各11件、残る3種類が各10件でした。総件数・反復数・並列数・時間制限を保って探索対象を増やし、既定の刺激列を変更した記録です。
比較とリダクションの追加時点では11プロファイルで、96件は最初の8種類が各9件、残る3種類が各8件でした。総件数・反復数・並列数・時間制限を維持して探索対象を広げ、既定の刺激列を変更した記録です。
配列操作を加えた現在は13プロファイルです。既定96件は上記の最初の5種類が各8件、残る8種類が各7件です。既存プロファイルごとの抽出数は減りますが、総件数・反復数・並列数・時間制限は維持します。既定の同じseedから生成する刺激列は変わります。
直前の11種類を再生成する場合は、既存9種類の指定に`comparison_context packed_logic_context`を加えて`--models`へ渡します。この明示指定の乱数列・分布・生成結果は維持しています。
直前の9種類を再生成する場合は`--models expression_context division_context packed_write_sequence conditional_context package_change_sequence shift_context cast_pipeline streaming_context concat_assignment_sequence`を指定します。この明示指定の乱数列・分布・生成結果は維持しています。
直前の7種類を再生成する場合は`--models expression_context division_context packed_write_sequence conditional_context package_change_sequence shift_context cast_pipeline`を指定します。この明示指定の乱数列・分布・生成結果は維持しています。
直前の5種類を再生成する場合は`--models expression_context division_context packed_write_sequence conditional_context package_change_sequence`を指定します。この明示指定では、旧3種類の明示指定と同様に従来の乱数列・分布・生成結果を維持しています。
旧割当てを再生成する場合は`--models expression_context division_context packed_write_sequence`を指定します。
保存済み刺激の再実行には再生成を使わず、これまでどおり`--replay`を使ってください。manifestの形式と旧ケースのmaterialize結果は維持し、コード変更は既存のハッシュと期待値ドリフトの記録で区別します。

```sh
# 配列リダクションとコピー列だけを探索する。直前に最新mainを取得・ビルドする。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --seed 731 --models array_reduction_context unpacked_array_copy_sequence \
  --cases 96 --vectors 8 --jobs 4 --timeout 5 --time-budget 120 \
  --output my-results/array-profiles-731
```

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

以下の日時付きの節は、導入時のローカル確認とその制限を保持しています。
過去の件数や「正式CI未実行」は当時の確認時点の記録であり、現在の正式結果は次の節に分けて記載します。

<a id="formal-thirteen-profile-checkpoint"></a>

### 13プロファイルの正式確認（2026-11-04 日本時間に照合）

suite `9926160a`の[Check 41718590448](https://github.com/kurochan001/kirimasim-tests/actions/runs/41718590448)と
[Nightly 41743702063](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063)は、ともに成功しました。
Nightlyのランダム比較はseed／run ID `41743702063`・attempt 1で、96件すべてを実際に実行しています。
投入判定は`always_execute`です。先行5プロファイルは各8件、残る8プロファイルは各7件で、13個すべてを含みます。
証跡は有効・完了で、fail・known・unsupported・not_run・staleはいずれも0件です。

別途取得・再ビルドしたランダム比較のバイナリは、kirimasim `9113955914d878437074f0e3b86a8dca38438080`・GNU 13.3.0です。
SHA-256は`b348f74d38baa8da4e0d9fdb87c40966b3f6397328408bb340aec477a47f3852`です。
[確認記録](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json)に、workflowのseedと区別したビルド情報、
artifactのハッシュ、全96件の保存SV・期待値・出力の照合、配列14件・package 8件の保存SVの独立解釈を記載しています。
これらの照合は既存証跡を読み直したもので、シミュレータを再実行していません。他のプロファイルは、この限定構文の検算器による独立解釈の対象外です。
再現には実行の`random-cross-kirimasim` artifactを`--replay`で使い、seedから再生成しません。
この結果を固定件数へ加算したり、[固定suiteの判定](nightly-results.md#latest-verified-checkpoint)に置き換えたりはしません。

先行する`e8d991a9`の実行と元の証跡は、[前回の確認](nightly-results.md#previous-verified-checkpoint)に保持しています。

<a id="thirteen-profile-stabilization"></a>

### 13プロファイルの安定化と重点探索（2026-11-03）

プロファイルの追加はいったん区切り、正式Check／Nightlyを継続し、重点領域の追加探索、独立検算と失敗の固定回帰化を優先します。
既定96件・各8ベクトル／操作とプロファイルの割当ては変更せず、追加探索だけで深さを確保します。
[重点探索の保存記録](../coverage/interaction-qualification/random-stabilization-20261103.json)では、
配列リダクション、配列コピー列、package変更列、パック部分書込み列の4プロファイルを各3シード（1/731/20261103）、
各96件・32ベクトル／操作で実行しました。直前に取得・構成・ビルドしたkirimasim `d73d8922dfa2`で計1,152件が全PASSです。
各ジョブは実際に実行し、投入管理の履歴も保存しています。省略を今回のPASSとして数えていません。

[独立した配列SV検算器](../tools/qualify_random_arrays.py)を追加しました。生成器のパラメータ・操作列・参照関数を使わず、
保存SVの宣言・添字方向・代入・部分コピー・withキャスト・リダクション・表示式から出力を求めます。
既存の文字列リテラルデコーダだけを共有し、型・幅・符号、配列の値コピー、単要素を含む集約は別実装です。
この検算は配列576件に一致し、既存の[package用検算器](../tools/qualify_pkgwatch.py)も288件で一致しました。
合計864件の実際の保存プログラムを照合しています。パック部分書込み288件は既存参照との実行比較で、今回の配列／package検算器の対象には含めません。
検算器は生成する限定構文を扱い、未知の式・別プロセス・範囲外の配列を拒否します。一般的なSystemVerilog処理系ではありません。

元の不一致記録と固定回帰は保持します。今回の追加探索では新しい差異は見つからず、固定回帰への追加は発生していません。
差異が出た場合は、保存manifestと同じSV・期待値・stdout/stderrから再現し、規格・参照・runner・処理系を切り分け、
確認できた機構を既存の固定回帰へ取り込みます。入力・期待値を弱めてPASSへ変更しません。
ローカルの完全な資料は`my-results/random-stabilization-20261103/`に保存し、固定suite・章別表・要求カバレッジへ加算しません。

ツール回帰901件と整合性13項目が全PASSです。独立検算器の7件には、保存SVの解釈中に生成器・参照関数を呼ぶと失敗する検査、実際の宣言・代入変更による検出、未知の構文の拒否を含めています。日英115組とローカルリンク53,301件も確認しました。これらは安定化時点のローカル検査です。その後の[正式確認](#formal-thirteen-profile-checkpoint)はsuiteとビルドのrevisionを添えて別に記録しています。

```sh
# 直前に最新mainを取得・ビルドする。出力先には新しいディレクトリを使う。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --models array_reduction_context --seed 731 --cases 96 --vectors 32 \
  --jobs 4 --timeout 5 --time-budget 120 \
  --explore --history my-results/deep-history.sqlite3 --output my-results/deep-array-731
python3 tools/qualify_random_arrays.py my-results/deep-array-731 \
  --output my-results/deep-array-independent-new.json
python3 -m unittest discover -s tools -p test_qualify_random_arrays.py
```

<a id="thirteen-profile-validation"></a>

### 配列リダクション・コピー列の追加と検証（2026-11-03）

[13プロファイルの検証記録](../coverage/interaction-qualification/random-cross-thirteen-profiles.json)と
[保存済み96ケース](../coverage/interaction-qualification/random-cross-thirteen-profiles-manifest.json)を追加しました。
直前に上流mainを取得・構成・ビルドしたkirimasim `d73d8922dfa2`で、seed 1/731/20261103の混在各96件と、
新プロファイルの最大32ベクトル／操作各32件、計352件が全PASSです。本体コードは変更していません。
従来3・5・7・9・11種類の明示指定時のmanifest・SV・期待値は、各3シードの変更前ハッシュに一致します。
新しい各1件の保存replayも元のバイト列と一致し、参照ドリフトなしでPASSしました。

参照モデルは固定配列リダクション全合法行の両背景、固定配列コピー全合法行の両入力段階と照合しています。
任意の既知値の独立した整数計算、4状態のビットごとの二項演算表、単要素のX/Z、桁あふれとwith変換の順序も確認しました。
コピー列では宣言順に対応する異方向の添字、範囲外の保持、コピー元・コピー先更新の独立性、符号拡張を観測します。
空配列の結果はこのプロファイルで定義せず、要素数0は生成しません。

導入時には、3要素用の集約関数を単要素へ直接適用するとZをXへ変える参照差が5件ありました。
7.12.3の要素値を集約する定義と、同じメソッドを要素式の演算列で説明する18.5.7.2を確認し、
先頭要素から実際の二項演算だけを畳み込む参照へ修正しました。これはkirimasim本体の修正ではありません。
元の失敗manifest・SV・期待値・出力・参照コードは`my-results/random-array-singleton-reference-20261103/`に保持しています。
同じ保存SV5件を現在の参照で実行するとPASSし、SVの変更なし・期待値変更ありを全件で記録します。
既定の保存期待値でのreplayは5件ともstale・pass 0で、元の失敗を成功へ書き換えません。監査のハッシュと件数は上記検証記録に収録しています。

同じ保存刺激の対照4件はkirimasimで全PASSです。固定Icarus 13.0は4件ともコンパイル段階のknown、
固定Verilator 5.052は既知値2件PASS・X/Zを必要とする2件unsupportedです。固定版oracleへの自動登録はありません。
実際のSV変更4件（集約の戻り幅の誤変更、単要素への余分な演算、コピー元位置の誤対応、部分コピーのガード破壊）も、正常終了後の出力差として全て検出しました。
完全なローカル実行資料は`my-results/random-array-20261103/`に保存し、固定suite・章間表・要求カバレッジの件数へ加算しません。

関連144件を含むツール回帰894件と整合性13項目が全PASSです。Checkと同じ生成・単一ケースreplayのCLI、新プロファイルの明示指定、日英115組、ローカルリンク53,293件も確認しました。この導入時点ではGitHubの正式Check・Nightlyは未実行でした。現在の正式結果は上の確認節を参照してください。

```sh
# 実行直前に最新mainを取得・ビルドし、保存刺激を再実行する。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-thirteen-profiles-manifest.json \
  --output my-results/thirteen-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="eleven-profile-validation"></a>

### 比較・リダクションの追加と検証（2026-11-03）

[11プロファイルの検証記録](../coverage/interaction-qualification/random-cross-eleven-profiles.json)と
[保存済み96ケース](../coverage/interaction-qualification/random-cross-eleven-profiles-manifest.json)を追加しました。
直前に上流mainを取得・構成・ビルドしたkirimasim `d73d8922dfa2`で、seed 1/731/20261103の混在各96件と、
新プロファイルの最大32ベクトル各32件、計352件が全PASSです。本体コードは変更していません。
従来3・5・7・9種類の明示指定時のmanifest・SV・期待値は、各3シードの変更前ハッシュに一致します。
新しい各1件の保存replayも元のバイト列と一致し、参照ドリフトなしでPASSしました。

参照モデルは固定比較モデルの全合法行・各4入力と、固定リダクションモデルの全合法行・既知基準入力で照合しています。
任意の既知値による独立した整数比較、1ビットの等価系真理値表、長さ1～4の全4状態入力列を別の畳み込みで求めたリダクションも照合しました。
右辺だけのワイルドカード、既知不一致と未知値、AND/ORの制御値、部分選択と入力bit変換の順序、
signed入力からunsignedの1ビット結果を130ビットへ拡張する例も確認しています。
リダクションでは各ベクトルに7演算の観測があり、別々の固定テストとして件数へ加算しません。

同じ保存刺激の対照4件はkirimasimと固定Icarus 13.0で全PASSです。固定Verilator 5.052は既知値2件PASS・X/Zを必要とする2件unsupportedです。
全シミュレータで全件成功とは扱わず、固定版oracleへ自動登録しません。
実際のSV変更4件（オペランドの符号変更、ワイルドカードの左右交換、早すぎる入力のbit変換、1ビット結果の誤った符号拡張）も、正常終了後の出力差として全て検出しました。
検証記録には実際の対照manifestを収録し、完全なローカル実行資料は`my-results/random-predicate-20261103/`に保存しています。
元の入力・期待値・失敗出力を保持し、固定suite・章間表・要求カバレッジの件数へ加算しません。

関連128件を含むツール回帰878件と整合性13項目が全PASSです。Checkと同じ生成・単一ケースreplayのCLI、新プロファイルの明示指定、日英115組、ローカルリンク53,289件も確認しました。この導入時点ではGitHubの正式Check・Nightlyは未実行でした。現在の正式結果は上の確認節を参照してください。

```sh
# 実行直前に最新mainを取得・ビルドし、保存刺激を再実行する。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-eleven-profiles-manifest.json \
  --output my-results/eleven-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="nine-profile-validation"></a>

### ストリーミング・連結代入の追加と検証（2026-11-03）

[9プロファイルの検証記録](../coverage/interaction-qualification/random-cross-nine-profiles.json)と
[保存済み96ケース](../coverage/interaction-qualification/random-cross-nine-profiles-manifest.json)を追加しました。
直前に上流mainを取得・構成・ビルドしたkirimasim `d73d8922dfa2`で、seed 1/731/20261103の混在各96件と、
新プロファイルの最大32ベクトル／操作各32件、計352件が全PASSです。本体コードは変更していません。
従来3・5・7種類の明示指定時のmanifest・SV・期待値は、各3シードの変更前ハッシュに一致します。
新しい各1件の保存replayも元のバイト列と一致し、参照ドリフトなしでPASSしました。

参照モデルは固定ストリーミング全合法行、固定連結代入全合法行の両入力段階、任意の連結分割と既知値の整数計算で照合しています。
ストリーミングは長さ1～132の値を別のブロック分解・復元方式でも照合し、往復一致だけに頼りません。
部分ブロックのpackとunpackが異なる手計算例、NBA前の過去状態とRHS変更後の保持値、混在するbit/logic変換と項の符号拡張も確認しています。
実際のSV変更4件（ストリーム方向、逆置換の欠落、連結代入の早すぎる更新、項のbit変換の欠落）を、正常終了後の出力差として全て検出しました。

同じ保存刺激を使う対照5件はkirimasimで全PASSです。固定Icarus 13.0は1 pass・4 knownで、
ストリーミング3件のコンパイル拒否と、連結のbit項にZが残る1件を保持します。
固定Verilator 5.052は2 pass・1 known・2 unsupportedで、部分ブロックのunpackがpackの置換になる1件と、X/Zを必要とする2件を成功へ変換しません。
固定版oracleへの自動登録はなく、入力・期待値を差異に合わせて弱めていません。
検証記録には対照の実際のmanifestも収録し、完全なローカル実行資料は`my-results/random-struct-20261103/`に保存しています。
固定suite・章間表・要求カバレッジの件数へ加算せず、正式Check／Nightlyの実行とは区別します。

関連112件を含むツール回帰862件と整合性13項目が全PASSです。Checkと同じ生成・単一ケースreplayのCLI、新プロファイルの明示指定、日英115組、ローカルリンク53,285件も確認しました。この導入時点ではGitHubの正式Check・Nightlyは未実行でした。現在の正式結果は上の確認節を参照してください。

```sh
# 実行直前に最新mainを取得・ビルドし、保存刺激を再実行する。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-nine-profiles-manifest.json \
  --output my-results/nine-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="seven-profile-validation"></a>

### シフト・キャストの追加と検証（2026-11-03）

[7プロファイルの検証記録](../coverage/interaction-qualification/random-cross-seven-profiles.json)と
[保存済み96ケース](../coverage/interaction-qualification/random-cross-seven-profiles-manifest.json)を追加しました。
直前に上流mainを取得・構成・ビルドしたkirimasim `d73d8922dfa2`で、seed 1/731/20261103の混在各96件と、
新プロファイルの最大32ベクトル各32件、計352件が全PASSです。本体コードは変更していません。
従来3種類に加え、従来5種類を明示指定した場合のmanifest・SV・期待値も3シードの変更前ハッシュに一致します。
新しいケースのreplayは各1件がPASSし、元のSV・期待値とバイト一致、参照ドリフトなしです。

参照モデルは固定のシフト・キャスト全合法行との一致に加え、任意の既知値を使う独立した整数計算と照合しました。
評価幅を先に決める左シフト、65ビット全1のシフト量、X/Zを複製する算術右シフト、未知のシフト量、
キャストの符号保持と型付きbit変換が加算より前に起きる境界も手計算例で確認しています。
実際のSVを変更した4件（算術右シフトを論理右シフトへ変更、シフト量の無視、キャストの符号変更、
bit変換の遅延）は正常終了後の出力差として全て検出しました。元の入力・期待値・失敗出力を保持します。

同じ保存刺激を使う4件の公開ツール比較は、kirimasimが全PASS、固定Icarus 13.0が全PASS、
固定Verilator 5.052は既知値2件PASS・X/Zを必要とする2件unsupportedです。
全シミュレータで全件成功とは扱わず、固定版oracleへ自動登録しません。
実行資料は`my-results/random-bits-20261103/`に保存し、固定suite・章間表・要求カバレッジへ加算しません。

関連96件を含むツール回帰846件と整合性13項目が全PASSです。Checkと同じ生成・単一ケースreplayのCLI、新プロファイルの明示指定、日英115組、ローカルリンク53,277件も確認しました。この導入時点ではGitHubの正式Check・Nightlyは未実行でした。現在の正式結果は上の確認節を参照してください。

```sh
# 実行直前に最新mainを取得・ビルドし、保存済み刺激を再実行する。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-seven-profiles-manifest.json \
  --output my-results/seven-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="five-profile-validation"></a>

### 5プロファイルへの拡張と検証（2026-11-03）

[新しい検証記録](../coverage/interaction-qualification/random-cross-five-profiles.json)と
[5プロファイルの保存済み96ケース](../coverage/interaction-qualification/random-cross-five-profiles-manifest.json)を追加しました。
実行直前に取得・構成・ビルドした上流main `d73d8922dfa2`で、seed 1/731/20261103の混在各96件と、
新プロファイルを最大32ベクトル／操作で各32件、計352件が全PASSです。本体コードは変更していません。
旧3プロファイルのmanifest・SV・期待値は、明示指定して3シードの従来ハッシュとの一致を維持しています。
新しいpackage操作列は216件の実際の生成済みSVを独立した[固定クロスの解釈器](../tools/qualify_pkgwatch.py)で読み、
順方向・逆方向の観測プロセス処理の両方で一致しました。条件演算子は固定モデルの全境界行、1ビットの全入力対、
文脈拡張・Z/Zマージ・bit変換の手計算例も単体テストで確認しています。

新しい2プロファイル各1件の保存replayは元のSV・期待値とバイト一致し、参照ドリフトなしでPASSしました。
別の保存済み4ケースはkirimasimで全PASS、固定Verilator 5.052で既知値2件PASS・X/Zを必要とする2件unsupported、
固定Icarus 13.0で1件PASS・3件knownです。Icarusのknownは条件のX/Zマージ1件とpackageのコンパイル拒否2件で、
出力や診断はローカルの元artifactに残しています。全シミュレータ成功とは扱わず、固定版oracleへ自動登録しません。
誤った条件分岐、関数のpackage参照先、早すぎるwait、通知回数の欠落という実際のSV変更4件も、正常終了後の出力差として検出しました。
元の失敗・期待値は保持します。ローカルartifactは`my-results/random-profiles-20261103/`です。

関連80件を含むツール回帰830件と整合性13項目が全PASSです。Checkと同じ生成・単一ケースreplayのCLI、および新プロファイルの明示指定も確認しました。日英115組とローカルリンク53,273件は整合しています。固定suite・章間表・要求カバレッジの件数はランダム追加によって増やしていません。この導入時点では正式GitHub Check・Nightlyは未実行でした。現在の正式結果は上の確認節を参照してください。

```sh
# 公開した保存刺激を使う。実行直前に最新mainを取得・ビルドする。
python3 tools/run_random_cross.py \
  --kirimasim /path/to/latest-build/kirimasim --commit VERIFIED_FULL_COMMIT \
  --replay coverage/interaction-qualification/random-cross-five-profiles-manifest.json \
  --output my-results/five-profiles-saved-replay
python3 -m unittest discover -s tools -p 'test_random_cross*.py'
```

<a id="exploration-admission"></a>

## 追加探索の投入管理

固定回帰と正式Nightlyは再実行し、**完全に同じ条件で完了した追加探索ジョブ**だけを
重複投入から省く方針です。幅・符号・パラメータ・値・操作を生成対象から恒久除外しません。
既存3・5・7・9・11プロファイルを同じ順序で明示指定した場合の乱数列と分布、全体の上限は維持しています。操作順、繰返し書込み、初期状態も
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
