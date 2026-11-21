# 日次・週次シミュレーション速度ベンチマーク

[English](daily-benchmark.md) / [日本語](daily-benchmark.ja.md)

独立した[Daily and weekly benchmarksワークフロー](../.github/workflows/benchmark.yml)で実行時間を測ります。機能テストのNightlyは言語の結果を確認します。速くても結果が誤っていれば、速度値には採用しません。既存の`nightly.yml`、機能判定、`results`ブランチ、過去の速度測定記録は維持します。

[最新の測定回と推移](https://github.com/kurochan001/kirimasim-tests/tree/benchmark-results#readme)・[Actionsとログ](https://github.com/kurochan001/kirimasim-tests/actions/workflows/benchmark.yml)。結果ブランチは最初の正式実行の公開時に作られます。失敗した回も表示し、完了した測定として扱いません。

## READMEの総合グラフ

READMEのグラフは、**Icarus Verilog 14.0 develの最新開発コミットを1**とする日次の所要時間比です。共通22種類と4値3種類、計25種類の各ケースについて`kirimasimの差分時間 / Icarus 14 develの差分時間`を求め、その**等重み幾何平均**を取ります。0.97ならこの集合で所要時間が3%短く、1.10なら10%長い意味です。速度そのものの倍率とは逆向きで、小さいほど高速です。25種類の値を直接平均し、共通22種類の平均と4値3種類の平均を半分ずつ重み付けすることはしません。用途全般を代表する数値ではなく、この固定集合の総合値です。

最新kirimasimとIcarusの`master`は準備開始時にそれぞれ一度だけ解決し、全工程で同じ完全SHAを使います。Icarusは実行ファイルが14.0 develを名乗ることも検査します。上流が15へ移行した場合は自動で14として比較せず、準備した版の見直しが必要です。両方が日々変わるので、グラフの変化をkirimasimだけの改善・悪化とは断定できません。固定基準版kirimasim・Icarus 13・Verilatorとの比較は詳細に残します。

JSTの各日で最後に開始した正式測定を採用し、同日再実行も生データはすべて保持します。最後の測定が失敗した場合、以前の成功値へ差し戻しません。25種類のどれかが不一致・失敗・タイムアウト・非正の差分・未完了なら、その日の総合値は欠測です。測定のない日も線を切ります。環境や定義の異なる系列も線でつなぎません。灰色の1は比較基準線で、未測定の時間を埋めたものではありません。凡例のlast validは系列の最後の有効値で、最新測定の成功を意味しません。

[グラフ](https://raw.githubusercontent.com/kurochan001/kirimasim-tests/benchmark-results/charts/daily-icarus14.svg)と[日別の採用測定・集計JSON](https://github.com/kurochan001/kirimasim-tests/blob/benchmark-results/headline.json)は結果ブランチで自動更新します。過去のIcarus 13の測定からIcarus 14の値を作ることはせず、新しい正式測定から始まります。

## 比較対象と固定した定義

[bench/daily.json](../bench/daily.json)は、共通の設定から**日次25種類・週次の大規模3種類**を選びます。日次は**従来の13種類すべて**を維持します。本体v0.1.0の独立した12種類と、このリポジトリの4値ケース1種類です。共通の12種類は`casez_struct`, `comb_chain`, `dyn_queue`, `fork_join`, `func_call`, `gate_udp`, `mem_rw`, `nba_burst`, `nba_shift`, `proc_wait`, `string_fmt`, `wide_arith`です。元のNと完全な期待出力を維持します。本体のソースは元の場所に置いたまま、`cfa2ccd75989c1ebb9ed63303271183377364cf0`に固定し、日々の最新ソースから選び直したり複製したりしません。

測定定義`daily-v4-icarus14`は共通22種類・4値3種類、`weekly-v2-icarus14`は共通3種類です。旧`daily-v1`（5種類）・`daily-v2-thirteen`（13種類）の保存済み結果は、それぞれ別系列で保全します。旧定義の総合値を拡張後の結果とは扱いません。レポートには定義名とケース数を表示します。日次・週次は識別情報、最新結果ファイル、表、グラフを分け、週次の公開で最新の日次結果が置き換わることはありません。

追加ケース`bench/fourstate_mix.sv`は、このリポジトリ内のハッシュで固定し、100万反復します。X/Z、case等価、未知値の検出を観測します。Verilatorは4値3種類ともコンパイル前に明示的に対象外とし、2値近似で省かれた処理を同じ仕事として速度比較しません。共通ケースは、選んだ全処理系で意味のそろう確定値を観測します。全SystemVerilog用途の総合性能を表す選定ではありません。

## 追加ケースと独立した期待値

日次に追加した12種類は、このリポジトリで作成した独自の設計です。

- `fifo_stream`：64語の同期FIFO。同時の送受信、満杯・空による待ち、データの順序、読み出した件数と残った語数を確認します。
- `uart_loopback`：別モジュールの送信器・受信器で開始ビット、8データビット、停止ビットを処理します。シミュレーションの1クロックを1ビットとし、データの順序、フレーム数、停止ビットの誤りを確認します。オーバーサンプリングや雑音の試験ではありません。
- `bus_fabric`：32語ずつのレジスタバンク4個をアドレスで選び、クロックに合わせて書き込み、異なるアドレスから読みます。独自の小さなレジスタバスで、特定のバス規格への適合を主張しません。
- `hierarchy_fanout`：入力の変化を128個の組合せリーフモジュールへ伝え、全出力をチェックサムに含めます。
- `event_fanout`：クロックに反応する256プロセスを疎に更新し、全プロセスの最終カウントを観測します。
- `clock_domains`：周期4・6・10の独立した3クロック。立ち上がり回数から期待値を求めます。クロックドメイン間の受け渡しの正しさを測るものではありません。
- `word_boundary`：64/65bitの値、回転、語境界をまたぐシフト、可変ビット選択を処理します。
- `wide_divide`：257bitの符号なし値を、変化する非ゼロの除数（1〜65,521を33bitの変数に格納）で割り、商と剰余を観測します。
- `packed_slice`：511bitの状態に対し、語境界をまたぐ32bitの可変部分選択を読み書きします。
- `memory_scatter`：32bit×32,768語（論理データ128KiB）。同じアドレスへの読み書きも含む、決定的で不規則なアクセスです。
- `fourstate_arith`：65bitの既知値・X・Zの演算と算術右シフト。全ビット不定になる件数と、既知の結果のチェックサムを確認します。
- `resolved_bus`：8bitの三状態バスを4ドライバーで駆動します。無駆動、同じ値、競合を切り替え、既知ビットのチェックサムと実際のX/Zビット数を確認します。

週次の大規模ケースは次の3種類です。

- `large_hierarchy`：5段の4分木で、クロックに反応するリーフ1,024個と内部ノード341個。リーフごとに更新条件を変え、根の集約結果を確認します。
- `large_memory`：32bit×262,144語（論理データ1MiB）へ、1反復あたり64語のストライド付きバーストアクセスを行い、バーストごとに1時間単位進めます。無時間進行の安全ガードは変更しません。論理データ量とシミュレータのRSSは別です。
- `stream_pipeline`：8段、32bit×32並列レーンのパイプライン。validの伝搬、全段共通のクロックイネーブルによる停止、最後の排出を含め、データのチェックサムと受け付けた件数を独立に確認します。

個別処理を測るケースに、小さなRTLシステムと大きな構造を加えます。全用途や完全なプロセッサの性能を代表するとは主張しません。クラスを用いた検証、アサーション・カバレッジの負荷、波形I/Oは日次・週次の定義に含みません。クラスと波形の出力は、それらとは別に[別枠](#別枠holdout報告のみ)で測り、報告だけします。

[`bench/reference_expanded.py`](../bench/reference_expanded.py)はシミュレータの出力を読まずに期待値を計算します。取引単位のFIFO、送信バイト列、平坦なメモリ、整数の剰余演算、クロック・イベントの回数の式、平坦なリーフ状態、データ単位のパイプライン変換、1bitずつの4値解決を使います。完全なNとn=1の期待値を設定とソースヘッダへ固定します。NはFIFOのサイクル数、バスの書き込み・読み出しの組数（1組2クロック）、パイプラインの入力サイクル数（その後に8サイクル排出）、UARTのフレーム数です。クロックは30時間単位の区画数で、時刻30N+1に観測します。ほかは記載した処理の反復数です。大規模ケースではn=1でも初期化やエラボレーションに時間がかかります。参照計算ソースのハッシュも記録し、測定中の変更を検出します。`spec_check: ai`はAIによる照合を表し、人の独立レビューとは区別します。

新しい処理量は正式測定前の正しさ確認で短すぎる実行を減らすよう選び、その後に固定しました。従来13種類の処理量・期待値は変更していません。事前確認を正式な速度の証拠には使いません。処理系ごと・日ごとにNを自動調整せず、短い値・ばらつきに近い値には注意を、ゼロ以下の差分には欠測を表示します。

処理系の識別情報は次の5種類です。

- **latest**：kirimasimの`main`。ビルド前に`benchmark_setup.py resolve`で一度だけ解決し、以後は同じ完全SHAを使います。
- **baseline**：kirimasim v0.1.0、タグの参照先は`cfa2ccd75989c1ebb9ed63303271183377364cf0`です。
- **icarus**：Icarus Verilog v13_0 / 13.0、`dfeee909ed9f20b4870dd93423156c0170c0e1ff`です。
- **icarus_devel**：Icarus Verilog 14.0 devel。`refs/heads/master`を各測定開始時に一度解決します。初回ビルド確認は`0b15315c14177986b98fcad2940c0c3f98fdc8f9`です。固定13版とは別の設置先・版・結果で管理します。
- **verilator**：Verilator v5.054、タグの参照先は`bbb60a403932a9f695cb6ff001ceb73de6ad9234`です。

タグと完全コミットは上流Gitで確認しました。準備処理は固定ソースを取得・ビルドするだけで、GPL実装の内容は読みません。基準版と比較OSSの固定値は自動更新しません。版表示、実行ファイルと付属実行ファイルのハッシュ、ビルド記録を、ケースや測定処理のハッシュとは別に保存します。

Lyraは初期構成には含めません。手元に実行ファイルや専用ランナーがなく、追加バックエンドのビルド環境を要求せず5処理系の比較を完成させるためです。固定した`tools/bench.py`のアダプターは`lyra`・`lyra_llvm`に対応しています。追加するときは、固定コミットと再現できるビルドを確認し、準備処理と版の検査、対応ケース、固定比較集合を登録してください。実行ファイルがない状態をゼロ秒にしてはいけません。

## 別枠（holdout、報告のみ）

[bench/holdout.json](../bench/holdout.json)は、日次・週次の集合が触れない9つの条件の定義`holdout-v1-icarus14`です。**別枠は測って報告するだけで、kirimasimの最適化の判断には使いません。** 値を目標にして調整せず、日次の総合値、`headline.json`、READMEの総合グラフにも入れません。

日次・週次の定義は変えていません。`bench/daily.json`、`tools/daily_benchmark.py`、`tools/benchmark_compare.py`、`tools/benchmark_history.py`、`tools/benchmark_setup.py`を変更しないので、日次・週次の系列は指紋を保ちます（`tools/test_holdout_benchmark.py`がハッシュを確かめます）。別枠は同じ5つの処理系、固定したアダプタ、同じ設定（n=1と完全なNの各5回、ウォームアップ1回、単一スレッド、600秒の上限）を使います。

| 条件 | 試す仕組み | N | 実行しない処理系 |
| --- | --- | ---: | --- |
| `class_pool` | 2つの派生クラスのオブジェクトを生成し、基底クラスのハンドルとしてキューに入れ、仮想メソッドで消費する（8、7.10） | 400,000 | Icarus 13.0と14.0 devel：クラスのハンドルのキューを受け付けない |
| `intf_modport` | 1つのinterfaceのmodportで結んだ送信側・受信側・監視側と、valid/readyのハンドシェイク（25） | 1,000,000 | Icarus 13.0：modportのポート宣言を構文解析できない |
| `real_filter` | `real`の2次IIRフィルタ。`$realtobits`で観測する（6.12、20.5） | 2,000,000 | — |
| `force_release` | ネットの`force`/`release`と変数の`assign`/`deassign`を毎回切り替える（10.6） | 1,500,000 | Icarus 13.0と14.0 devel：右辺を1回しか評価しない。10.6は評価し直すと定める |
| `delayed_nets` | 連続代入とゲートの立ち上がり・立ち下がり遅延と、慣性遅延で消えるパルス（10.3.3、28.16） | 400,000 | — |
| `specify_paths` | 立ち上がり・立ち下がり遅延を持つスカラーのmodule path、2入力のパス、既定のパルス除去（30.4、30.7） | 400,000 | Verilator：module pathの遅延を適用しない |
| `file_output` | `$sformatf`と`$fwrite`で作業ディレクトリのファイルに書き、`$fgets`で読み返す。標準出力には件数とチェックサムだけを出す（21.2、21.3） | 1,000,000 | — |
| `bus_fabric_vcd` | 変更しない`bench/bus_fabric.sv`の全信号をVCDファイルに書く | 100,000 | — |
| `bus_fabric_fst` | 同じ内容をFSTファイルに書く | 100,000 | Verilator（承認まで）：FSTの書き出しにLZ4の開発用ヘッダが要り、ワークフローはそれを入れていない |

連想配列を使う入力（`dynarray_assoc`）は作りませんでした。kirimasimの`docs/P1_SUPPORT.md`が連想配列を未実装としており、別枠の入力はそこで対応済みの形だけを使うためです。

[`bench/reference_holdout.py`](../bench/reference_holdout.py)は、シミュレータの出力を読まずに、各設計が試す規則から期待値を計算します。クラスとキューの順序、ハンドシェイクのサイクルモデル、積が正確なIEEE 754倍精度の加算（係数が2のべき乗なので、積和演算の融合で結果は変わりません）、10.6の上書きの規則、10.3.3の手順と表28-9、既定のパルス除去を伴うmodule pathの遅延、ファイルに書く正確な文字列です。波形の条件は`reference_expanded.py`の`bus_fabric`のモデルを使います。設計は規格が決めていない場合を避けます。立ち上がりと立ち下がりの遅延が違うのは、どの変化もそれより長く続く場合だけで、パルスの長さが遅延とちょうど同じになることはなく、遅延の境目で観測することもなく、パスのセルの2入力は遅延の時間内に続けて変わりません。完全なNとn=1の期待値は定義と各ソースの見出しに固定し、`--check`がそれらとソースのハッシュ、別枠のドライバのハッシュを確かめます。

波形の条件は、`bus_fabric`以下の全階層の変数とネットを記録します。メモリは4値VCD形式（21.7.2.1）と同じく除きます。kirimasimは`--wave=FILE`で、Icarus VerilogとVerilatorは変更しない設計と一緒に[`bench/holdout_waveform.sv`](../bench/holdout_waveform.sv)（`$dumpvars(0, bus_fabric)`）をコンパイルして記録します。FSTではvvpに`-fst`を付け、Verilatorは`--trace`か`--trace-fst`と、ふだんは記録するレジスタの配列を除く`--trace-max-array 1`を使います。Icarus Verilogはforループの変数とgenvarの値も記録します。各サンプルに波形ファイルの大きさ（`waveform_bytes`）を残し、中身は比べません。ほかに2つの条件が条件ごとのオプションを持ち、定義に記録しています。`specify_paths`はIcarus Verilogの`-gspecify`でコンパイルし（付けないとパスの遅延を無視します）、`file_output`は実行ごとにファイルを消します。実行が書くファイルは作業ディレクトリにだけ置き、消します。

Nは、手元のMac 1台での正しさの事前確認で、kirimasimの差分時間がそこでおよそ1.5〜2.5秒になるように選び、固定しました。事前確認の値は速度の証拠にしません。3つの比較の集合には、相手が実行できる条件だけを入れます。`holdout-icarus14`（7条件、Icarus 14 devel）、`holdout-regression`（9条件すべて、baseline）、`holdout-verilator`（7条件、Verilator）です。宣言した非対応は欠測として示し、ゼロにはしません。

別枠は週に1回、月曜03:47 UTC／12:47 JSTに、週次の後に同じconcurrency groupで実行します。定期実行は、人が最初の正式な別枠の測定を公開した後にだけ始まります（**Run workflow**で`profile=holdout`）。それまではgateジョブが飛ばします。記録はbenchmark-resultsの`holdout/runs/`、`holdout/history.json`、`latest-holdout.json`と、READMEの折りたたみの中の別の表です。表は公開のたびに`tools/holdout_history.py readme`が入れ直します。`tools/holdout_benchmark.py`は、変更しない日次のドライバを別枠の定義で動かします。条件ごとのオプションのない条件は、固定したアダプタのコマンドのとおりに実行します。定義は別枠のドライバのハッシュを記録するので、ドライバを変えると別枠の定義が変わります。

## 何の時間を測るか

正式測定は同じマシンで全コマンドを直列に実行します。処理系・ケースごとにn=1を1回ウォームアップし、n=1と元の完全なNを各5回測ります。処理系の順序はケース・反復ごとに逆転し、n=1とNの順序も反復ごとに逆転します。デザインのビルドはその実行前に終えます。全処理系のインストールは測定開始前に完了させます。期待値検査を省く`bench.py --n`モードや、無断で減らした処理量は使いません。

主指標は**処理量の増加に伴う差分時間**で、`median(T(N)) - median(T(1))`です。仕事が増えたときの実時間の差を示します。純粋なシミュレーションCPU時間ではなく、起動・解析・エラボレーションが完全に除かれたと保証する値でもありません。

- ウォームアップと全反復について、秒数、終了コード、タイムアウト、検証した結果行、RSSを保存し、中央値・最小・最大・MADも残します。MADは中央値からの距離の中央値で、ばらつきを表します。信頼区間ではありません。
- IcarusとVerilatorのデザインのコンパイル時間は別項目です。kirimasimは呼出しごとにソースを解釈するため、解析等をT(1)・T(N)に含み、別のデザインビルド欄は欠測です。本体のインストール・ビルド時間は来歴として保存し、デザインのビルド時間へ加算しません。
- kirimasimはrelease preset（`-O3 -DNDEBUG`、検査済み`-ffp-contract=off`、fast-mathなし）です。Icarusは`-g2012`と`vvp -n`です。Verilatorは既存の`--binary --timing`と生成C++の既定最適化を使い、`--threads 1 --build-jobs 1`を明示します。波形と追加のアサーション指定は無効です。波形・大量ログのI/Oを測るケースはありません。
- LinuxのRSSは既存アダプターの10ms間隔VmHWM観測を使います。短い実行では観測できない場合があり、終了直前の最大値まで保証しません。macOSはwait4のru_maxrssです。不明なRSSをゼロへ置き換えません。
- 差分が0.05秒未満、または観測したばらつきに近いときは雑音の注意を表示します。Nを自動的に増やしません。差分がゼロ以下や非有限値なら倍率を出しません。

完全なNの期待行は既存ヘッダを維持します。n=1の期待行は別途計算しています。`nba_shift`はリセット周期なので合計ゼロです。`mem_rw`は旧rdata=0・raddr=5と1回のLFSR更新です。`wide_arith`は256/128bitの剰余演算1回です。`comb_chain`は初期入力の値と、xorshiftを1回進めた入力の値を足します。X/Zケースには規格由来のスカラー参照`reference_fourstate_mix.py`があります。速い処理系の出力から期待値を作る方式ではありません。 追加8種類のn=1も元ソースの規則から計算します。デコーダの最初の命令はレジスタ13を変えるため、表示する3本は初期値のままです。キューは1要素の追加・排出で合計1、最初のfork/joinはa=1・b=1・c=1・d=0、4段の再帰mixはs=2・sum=1683697です。最初のLCGと多数決は610673f5、NBA1回の最終値は0、時刻3ではdelay-2のプロセスだけが起きて合計15255、最初の整形文字列のFNV-1aはdcc025c8です。固定Verilator5.054の実行条件でも、独自のactive領域と遅延後のNBA観測が一致したため、過去のINITIALDLYの挙動を決めつけず、`--timing`で`nba_burst`を比較に含めます。

## 結果と推移の読み方

比率はすべて**最新kirimasimの差分時間÷比較対象の差分時間**です。1未満なら最新kirimasimが速く、1超なら比較対象が速いことを示します。基準版との比較は性能の推移、Icarus・Verilatorとの比較はOSS間の比較です。同じ回に基準版も測ることは環境変動を判断する材料になりますが、その影響を完全に消せるわけではありません。

従来の幾何平均5集合は、対象ケースを変えずに残します。

- regression-common：共通12本すべての最新／基準版。
- regression-fourstate：`fourstate_mix`の最新／基準版。
- icarus-common：共通12本すべての最新／Icarus。
- icarus-fourstate：`fourstate_mix`の最新／Icarus。
- verilator-common：共通12本すべての最新／Verilator。

集合の全ケースに有効値が必要です。欠測・失敗・ゼロ以下の差分があれば、その集合の総合値を欠測にします。対象一覧と取得数／必要数を示し、その日に成功したものだけで平均し直しません。SVGグラフも欠測で線を切ります。総合値が欠測でも、個別の結果と失敗理由はJSONに残します。

追加の`expanded-*`の5集合は、日次の共通22本または4値3本を同じ比較相手で集計します。従来の`weekly-*`の3集合は、週次3本すべてを基準版・Icarus 13・Verilatorと比較します。`daily-overall-icarus14`は日次25本すべての総合値、`weekly-icarus14-common`は週次3本すべてをIcarus 14 develと比較します。それぞれ固定集合として別に表示し、週次を日次の平均へ混ぜません。

最新／基準版の総合値が1.15を超えた場合は説明上の注意です。機能テストを失敗させず、統計的有意性も主張しません。状態は`measured`（測定済み）、`unsupported`（宣言した非対応）、`output_mismatch`（出力不一致）、`build_failed`、`run_failed`、`timeout`、`incomparable`（比較不能）を区別します。コンパイラの異常を非対応と推測しません。ウォームアップや本測定の1回でも異常があれば、その処理系・ケースの値を採用しません。失敗した反復だけを捨てて中央値を作ることは禁止です。

系列の識別には、定義・設定・測定ドライバー・集計処理・固定アダプターのハッシュと、CPU・コア数・メモリ・OS・アーキテクチャ・コンパイラ・ランナーイメージ・反復数・設定を使います。異なる条件を同じ線につなぎません。最新の本体コミットは同じ系列内で変わります。標準ランナーは、これらの個人を識別しない情報が同じでも物理的に同一の機材とは限りません。**共有ランナーの参考値**として扱い、小さな日次変動だけで性能が変わったと断定しません。

## 手動実行とローカル実行

Actionsの**Daily and weekly benchmarks → Run workflow**で`profile=daily`・`weekly`・`holdout`のどれかと`mode=formal`を選びます。日次は**20:17 UTC／翌日05:17 JST**、週次は**日曜23:47 UTC／月曜08:47 JST**です。機能Nightlyは19:23 UTC／04:23 JSTのままです。両プロファイルは同じconcurrencyとローカルロックで排他し、予定時刻をずらすだけには依存しません。GitHub側の遅延もあるため実際の開始・終了時刻を保存します。測定ジョブの上限は準備を含め180分です。`mode=smoke`は日次の`wide_arith`・`fourstate_mix`・`fifo_stream`・`resolved_bus`、週次の`large_memory`を、固定した完全なNで1反復します。出力・処理回数・終了の検証は残し、正式な性能履歴には入れません。

同じCLIをmacOSとLinuxで使えます。Git、Python 3.10以上、本体が対応するC++23コンパイラ、CMake 3.28以上、Ninja、圧縮ライブラリの開発ファイル、OSSのビルドに必要な道具を用意してください。Ubuntuの導入一覧はワークフローにあります。Homebrewでは十分新しいbison・flexをPATHへ追加します。静かなマシンと新しい出力先を使ってください。

```sh
WORK=/path/to/private/benchmark-work
mkdir -p "$WORK"
python3 tools/benchmark_setup.py resolve --out "$WORK/plan.json"
python3 tools/benchmark_setup.py prepare --plan "$WORK/plan.json" \
  --root "$WORK/build" --install "$WORK/install" --out "$WORK/inventory.json" --jobs 2
python3 tools/daily_benchmark.py --profile daily --inventory "$WORK/inventory.json" \
  --environment fixed-local-profile --out "$WORK/run-001"
python3 tools/benchmark_history.py append --directory "$WORK/report" "$WORK/run-001/results.json"
```

週次は別の出力先で`--profile weekly`を指定し、準備済みのinventoryを共用できます。別枠は同じinventoryで専用のドライバを使い、`python3 tools/holdout_benchmark.py --inventory "$WORK/inventory.json" --out "$WORK/holdout-001"`と`python3 tools/holdout_history.py append --directory "$WORK/report" "$WORK/holdout-001/results.json"`を実行します。別枠のスモークは`--smoke --only real_filter file_output bus_fabric_vcd`を使えます。各測定回で両開発版の最新をそれぞれ一度だけ解決します。同じinventoryから日次・週次を続けて実行する場合は、意図的に同じSHAを使います。最新を更新するときはresolve・prepareをやり直してください。

日次スモークでは測定コマンドに`--smoke --only wide_arith fourstate_mix`を追加し、別の出力先を使います。週次スモークは`--profile weekly --smoke --only large_memory`です。`benchmark_history.py append`はスモークを意図的に拒否します。準備済みの実行ファイルを使う場合はinventoryの代わりに、固定したソースの`--benchmark-root`、解決済み完全SHAの`--latest-commit`と、`--tool latest=... --tool baseline=... --tool icarus=... --tool verilator=... --tool icarus_devel=...`と`--tool-commit icarus_devel=完全SHA`を指定できます。本体のSHA・版とOSSのリリース表示を確認します。外部から渡されたOSS実行ファイルにはソースからのビルド証明がないため、その制約を結果へ記録します。再現する正式インストールには準備処理の記録を使ってください。

同一ホストの準備・測定CLIは、共有の非待機ロックで重複を拒否します。同じ固定マシンを複数ユーザーやコンテナーが使う場合は、同じ`--lock`パスを指定してください。他のプログラムはこのロックを守らないため、運用側でも別のビルドやベンチマークを止める必要があります。ワークフローは準備から公開までconcurrencyで排他し、標準ランナーでは他のワークフローとVMも分かれます。時刻をずらすだけで排他したとは扱いません。

## 履歴・失敗・権限

`contents: write`は公開ジョブだけに付けます。mainの正式実行だけを**benchmark-results**へ追記し、通常のpushを使います。最初のブランチはmainの内容をコピーせず作ります。`runs/actions-RUN_ID-ATTEMPT.json`は書き換えません。同日の手動実行と再実行も別IDです。同じ内容の再取込みは何も壊さず、同じIDへ違う内容を登録すると拒否します。機能テストの履歴を変えず、日次サンプルをmainへコミットしません。公開ジョブだけを再試行するときは、元の測定のArtifactと測定IDを使います。新しいサンプルを測る場合は測定ジョブまたは全ジョブを再実行してください。

結果ブランチには小さな各回のJSON、索引、全体の最新回`latest.json`、日次の`latest-daily.json`、週次の`latest-weekly.json`、別枠の`latest-holdout.json`と`holdout/`（各回と索引。日次の履歴は読みません）、日英README、SVG、日別総合値`headline.json`を保存します。パスを伏せた全実行ログ・ビルドログはActions Artifactsで14日保存し、測定回のURLからたどれます。実行ファイルのパスを含むinventory、ソースツリー、ビルドフォルダはアップロードしません。途中で止まった測定や準備失敗は実行基盤の失敗として残し、総合値を欠測にします。取得済みのサンプルも保持します。アップロードや公開自体が失敗した場合は、そのジョブとArtifactsを確認してください。公開成功とは報告しません。

新しいSecretや未登録の専用ランナーは不要です。Actionsで既存の固定アクションを使用でき、公開ジョブにcontents権限を付けられること、ブランチ規則がbenchmark-resultsへの通常の追記を許すことが必要です。キャッシュのキーにはOS・アーキテクチャ・イメージ・コンパイラ・固定設定・準備処理のハッシュ・両開発版の解決済みSHAを含みます。ケース定義だけの変更では、同じプラットフォーム・コンパイラの過去の設置キャッシュも候補にできます。復元後もコミット・コンパイラ・設定・設置先・ビルド処理・インストール全ファイルのハッシュを照合し、一致しない処理系は作り直します。本体ビルドとキャッシュ転送が終わってから測定します。

ワークフローの前提パッケージ導入はUbuntu用です。固定Ubuntuランナーを使うか、他のOSではそのステップとコンパイラ・PATH設定を合わせてください。測定CLI自体はmacOS・Linuxに対応しています。後から固定のセルフホストマシンへ移す場合は、まず実機を登録し、個人を識別しない固定プロファイルを決めます。その後、測定ジョブの`runs-on`を実際の登録ラベルへ変更し、CLIの環境名も変えます。ワークフローとホストの共有ロック、専有運用、単一の直列ジョブを保ってください。PRトリガーや測定ジョブへの書込み認証情報は追加しません。新しい系列で基準測定を取り直し、標準Ubuntuや別のMac/Linuxの時間と混ぜません。

## 定義の更新と検証

固定版・ケース・N・期待行・設定・測定処理を変える場合は、定義の変更としてレビューします。タグが実在する完全コミットへ解決され、ビルドが通ることを確認し、ソース・アダプターのハッシュと規格から決めた期待値を理由付きで更新します。定義名も進めてください。条件の識別はハッシュが行いますが、定義名も読み手の助けになります。時間測定を通すために過去の測定ファイル、過去の速度記録、機能テストの期待値、本体の動作を書き換えてはいけません。

```sh
python3 -m unittest discover -s tools -p 'test_daily_benchmark.py'
python3 -m unittest discover -s tools -p 'test_benchmark*.py'
python3 -m unittest discover -s tools -p 'test_holdout_benchmark.py'
python3 bench/reference_expanded.py --check
python3 bench/reference_holdout.py --check
actionlint .github/workflows/benchmark.yml
```

自動テストでは全反復の採用条件、固定総合値、宣言した非対応、タイムアウト、ゼロ以下の差分、同日再実行の追記、系列の分離、レポート・SVG・欠測の線を確認します。全体チェックでは既存の機能基盤も検証します。実シミュレータのスモークと最初のActions公開は別に確認・報告します。ワークフローファイルがあるだけで日次稼働中とは扱いません。
