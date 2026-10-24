# 全テスト内容レビュー（2026-10-22）

## 結果

**12件の問題群、重複を除いて24テストに修正が必要な点を確認した。**
規格上不正なコードを正常系としているもの、期待出力が刺激と合わないもの、
適合するVPI実装でも失敗するCコード、APIの失敗を合格にしてしまう判定がある。
既存オラクルとの一致だけでは見つからない問題を含む。

このレビューでテスト本体・期待値・メタデータは変更していない。

## 対象と方法

- 対象コミット: `c118d54d6be3e9bbc85ebf60c9b545caf4649739`。
  未コミット差分に限定せず、`tests/` の全3,801テストを対象にした。
- 内訳は正常系3,629件、エラーを要求する負例172件。生成テスト812件を含む。
- Icarusをオラクルとするもの2,526件、Verilatorをオラクルとするもの944件
  （両方に属するもの171件）、規格のみを根拠とするもの502件。
- メタデータ、期待出力、追加ソース、DPI/VPIのCコード208ファイル、
  生成器の期待値モデルと実行・判定方法を確認した。
- 全件にSystemVerilog 2023モードの構文・意味・手続き解析を実施した
  （pyslang 12.0.0、追加ソース・include・define・トップ指定を反映）。
  Cコード全208ファイルにも警告を有効にした構文チェックを実施した。
- 手作業では診断の出た箇所に加え、規格のみをオラクルとするテスト、
  スケジューリング、4状態、型・幅・符号、アサーション、チェッカー、
  タイミングチェック、SDF、DPI/VPI、カバレッジを重点的に規格と照合した。
- 診断はそのまま問題とはせず、以下の指摘は規格本文、刺激からの導出、
  または小さな再現例で裏付けた。全件の規格適合性を形式的に証明したものではない。

一次資料は指定された
[IEEE Std 1800-2023 PDF](../../IEEE_1800-2023_SystemVerilog/IEEE_Std_1800-2023_SystemVerilog.pdf)
と[同PDFの抽出テキスト](../../IEEE_1800-2023_SystemVerilog/out/lrm_pdftotext_layout.txt)
（どちらもリポジトリの外の資料ディレクトリ）。
以下の節番号はこの版に対応する。ページ番号を併記した箇所は冊子上の番号。

## 指摘

### F01: procedural assign/deassign の左辺にpart-selectを使っている

対象: [test_sched_procedural_assign_part_select.sv:28](../tests/ch4/test_sched_procedural_assign_part_select.sv#L28)、同36行。

`assign q[3:0] = d[3:0]` と `deassign q[3:0]` を合法な動作として扱い、
部分的な上書き抑制を期待している。しかし **10.6.1（p.257）** は、
procedural continuous assignmentの変数左辺にbit-select/part-selectを認めていない。
ここはnetに対する通常のcontinuous assignmentでもforce/releaseでもない。

**影響:** 適合実装がエラーにするコードを正常系として要求する。
Icarus 13.0とVerilator 5.052で期待値に一致しても、この制約は変わらない。
pyslangでも左辺の不正が検出された。

**修正案:** 部分選択を拒否すべき負例にする。正常系として上書き抑制を調べるなら、
独立した変数全体へのassign/deassignに置き換え、説明と期待値も更新する。

### F02: wildcard importの候補を、実際にimportされた名前として再exportしている

対象:

- [test_package_export_all.sv:28](../tests/ch26/test_package_export_all.sv#L28)
- [test_package_export_named_wildcard.sv:35](../tests/ch26/test_package_export_named_wildcard.sv#L35)

前者の`mid_pkg`は`import base_pkg::*; export *::*;`だけで、
`base_x`や`twice`を参照していない。後者の`ew_mid`も`ga`、`gb`、`gsum`を
参照しないまま`export ew_g::*;`を行っている。

**26.6（p.815）** のwildcard exportは、実際にimportされた宣言が対象であり、
未参照のimport候補を外部に公開しない。名前を指定したexportにはimportを
発生させる規則があるが、wildcard exportにその規則を適用することはできない。
したがって下流のモジュールでこれらの名前を使うコードは成立しない。
pyslangでも未宣言名になり、Verilatorの受理を規格上の正当性の根拠にはできない。

**修正案:** export元パッケージで必要な名前を明示的にimportしたうえで、
wildcard exportを試す。未参照候補が再exportされない負例も分けて用意する。
説明中の「26.5がexportの規定」という記述も26.6に直す。

### F03: outputで駆動される接続先変数に、宣言時の手続き的初期化がある

対象:

- [test_timeunit_program.sv:33](../tests/ch3/test_timeunit_program.sv#L33)
- [test_program_clocking_output.sv:36](../tests/ch24/test_program_clocking_output.sv#L36)
- [test_program_clocking_default_skew.sv:43](../tests/ch24/test_program_clocking_default_skew.sv#L43)
- [test_checker_output_actual.sv:33](../tests/ch17/test_checker_output_actual.sv#L33)

`logic q = 0`や`logic [1:0] qv = 0`で初期化した変数を、
program/checkerのoutputにも接続している。
**6.5（pp.90–91）** では変数宣言の初期化もprocedural assignmentとして数え、
output接続による暗黙のcontinuous assignmentとの混在をエラーとしている。
checker出力からactualへのcontinuous assignmentは **17.3** にも明記されている。

**影響:** 正常系で禁止された複数の駆動方式を混在させている。
特にprogramのclocking出力2件は、受け側を0で初期化しても、
未初期化の出力formalの値を0にすることにはならず、初回駆動前の期待値も成立しない。
pyslangでも混在の診断が出る。

**修正案:** 接続先の初期化を除き、必要な初期値は駆動元で与える。
checkerのケースは内部`delay`がすでに0で初期化されているため、
観測対象の`qv[1]`について受け側の初期化は不要。

### F04: programの終了で、モジュール側の観測より先にシミュレーションが終わる

対象:

- [test_timeunit_program.sv:27](../tests/ch3/test_timeunit_program.sv#L27)
- [test_coverage_control_program_scope.sv:24](../tests/ch40/test_coverage_control_program_scope.sv#L24)

**24.3（p.776）** は、programにinitialが存在する場合、全programのinitial由来の
スレッドが終了すると暗黙の`$finish`でシミュレーションを終了すると規定する。
モジュールに待機中のスレッドが残っていても、それを待つ規則ではない。

前者ではprogramの`#1`が10 nsなので10 nsでprogramが終わり、
モジュールの10.5 nsの`$display`に到達しない。
後者ではprogramが時刻2で終わり、モジュールの時刻5のcoverage照会に到達しない。

**修正案:** program内に必要な観測まで生存する手続きを置くか、観測自体を
program側で行う。前者はF03の修正も必要。

### F05: 予約語 `before` を変数名にしている

対象: [test_coverage_save_after_stop.sv:25](../tests/ch40/test_coverage_save_after_stop.sv#L25)、同33・39行。

`int stopped, before, after, saved, merged;`の`before`は、
**5.6およびAnnex B** のSystemVerilog予約語である。
escaped identifierでもないので、coverage APIを実装した処理系であっても構文エラーになる。
pyslangおよびVerilatorの構文診断でも確認した。

**修正案:** `value_before`などに変更する。API非対応による実行不能と、
ソース自体の構文エラーを区別する必要がある。

### F06: クロックを決定できない `expect` がある

対象: [test_vpi_statement_control_kinds.sv:38](../tests/ch37/test_vpi_statement_control_kinds.sv#L38)。

`expect (en);`に明示クロックがなく、default clockingも、
手続き的文脈から推論できるクロックもない。
**16.15(f)、16.17** に従うexpect propertyは、単一のleading clockを必要とする。
`expect`は即時assertionではない。

**影響:** VPIオブジェクトを調べるための正常系ソースが不正になる。
taskを一度も呼ばないことはクロック解決の制約を免除しない。
pyslangの手続き解析でもclockなしの診断が出る。

**修正案:** 例えば`expect (@(posedge en) en);`のように明示クロックを与える。
このtaskは呼ばれないため、これでも実行を発生させずexpectオブジェクトを用意できる。

### F07: checker 2が失敗するクロックエッジが、刺激に存在しない

対象: [test_checker_package_context.sv:64](../tests/ch17/test_checker_package_context.sv#L64)、
[期待出力](../tests/ch17/test_checker_package_context.expected)。

`fast_clk`のposedgeは6、18、30、42、54。
`fast_ok`が0なのは時刻31以上40未満なので、どのposedgeでも0がサンプルされない。
それにもかかわらず期待出力は`checker 2 at 42: sig low`を要求している。

**16.5.1、17.3、17.4** に従えば、42ではすでに`fast_ok`は1であり、
この失敗メッセージは出ない。reset解除時刻24によってこの点は変わらない。
checker 1の時刻15の失敗は刺激と整合する。

**修正案:** 42でchecker 2の失敗を確認する意図なら、`fast_ok`を1に戻す時刻を
42より後へ移す。現状の刺激を維持するなら期待出力のchecker 2の行を削除する。

### F08: `vpi_get_str()` の共有一時バッファを複数の文字列として保持している

対象Cファイル（それぞれ同名のSVテストに影響）:

- [test_vpi_module_binding_properties.c:27](../tests/ch33/test_vpi_module_binding_properties.c#L27)
- [test_vpi_assertion_objects.c:82](../tests/ch37/test_vpi_assertion_objects.c#L82)（110行以降も同様）
- [test_vpi_task_function_properties.c:65](../tests/ch37/test_vpi_task_function_properties.c#L65)
- [test_vpi_ref_obj_actual.c:44](../tests/ch37/test_vpi_ref_obj_actual.c#L44)
- [test_vpi_io_decl_ref_objs.c:55](../tests/ch37/test_vpi_io_decl_ref_objs.c#L55)（116行以降も同様）
- [test_vpi_virtual_interface_vars.c:44](../tests/ch37/test_vpi_virtual_interface_vars.c#L44)
- [test_vpi_iterators_time_queue_events.c:177](../tests/ch37/test_vpi_iterators_time_queue_events.c#L177)
- [test_vpi_nettype_declarations.c:44](../tests/ch37/test_vpi_nettype_declarations.c#L44)
- [test_vpi_typespec_relations.c:142](../tests/ch37/test_vpi_typespec_relations.c#L142)

**38.11（p.1097）** は、`vpi_get_str()`の戻り値が毎回共有する一時バッファに
置かれると規定し、後続呼出しの後にも使うならコピーするよう説明している。
上記には複数の戻りポインタを保存してから使う箇所、または同じ`printf`系の
引数に複数回の呼出しがある。`str()`や`name_of()`のラッパーもコピーをしていない。
C/C++の引数評価順を固定してもバッファの上書きは解決しない。

例えば最初のファイルはname、library、cell、configを取得した後でnameを比較する。
nameはすでに最後のconfig文字列に上書きされ得るため、正しく存在する`u`を見失う。
元のCファイルをそのままincludeし、4プロパティに1個の共有バッファを使う
VPIスタブを接続した再現では、期待する3行ではなく **`u not found`** が出た。

**影響:** 規格に沿って一時バッファを再利用するVPI実装を誤って不合格にする。
特定処理系が安定した別バッファを返すことで問題が隠れる可能性もある。

**修正案:** 各`vpi_get_str()`の結果を次の呼出しより先に所有する領域へコピーし、
コピー済み文字列だけで比較・整形する。1回の整形呼出し内に複数の借用結果を渡さない。

### F09: 再入するDPI exported taskの引数がstaticで共有される

対象: [test_dpi_import_task_reentrant_wait.sv:35](../tests/ch35/test_dpi_import_task_reentrant_wait.sv#L35)。

`task sv_wait_level(input int n); wait (level >= n); endtask`はmodule内の
static taskなので、並行呼出しで引数`n`を共有する（**13.3.1、13.3.2**）。
DPI imported taskの再入を認める **35.5.1.5** は、export先SV taskを
自動的にautomaticにする規則ではない。

時刻0に開始する`c_visit(1)`と`c_visit(2)`は、同じ`n`を1または2に上書きする。
したがって個別に時刻5と10で戻るという期待は保証されない。
同じtaskを純SVから、呼出し1を時刻0、呼出し2を時刻1に開始する再現では、
Icarus 13.0で **両方が時刻10に戻る** ことを確認した。

**修正案:** `task automatic sv_wait_level(input int n);`にする。
C側のstatic変数を共有しながらSV側の待機条件を独立させる、という本来の目的を保てる。

### F10: setup違反をクロックより前のデータ変更時刻で報告するとしている

対象: [test_sdf_separate_setup_hold.expected:1](../tests/ch32/test_sdf_separate_setup_hold.expected#L1)、
[ソースの説明・刺激](../tests/ch32/test_sdf_separate_setup_hold.sv#L13)。

SDFでsetup limitを4にし、dataが時刻7、referenceであるposedge clkが時刻10に発生する。
**31.3.1、Table 31-1（p.898）** ではdata eventがtimestamp event、
reference eventがtimecheck eventなので、違反を判定するのは時刻10である。
将来のreference eventがまだ発生していない時刻7にnotifierが変わるという期待は誤り。
SDFはlimitを変更し、判定イベントの役割を逆転させるものではない（**32.4.2**）。

**修正案:** 先頭行を`10: setup=1 hold=0`に変更し、
時刻7を「setup違反の報告時刻」とするコメントを直す。
時刻12のhold違反と最終notifier値はこの修正では変わらない。

### F11: RECREMのイベント順序と、独立したremoval checkへの注釈の期待が誤っている

対象: [test_sdf_recrem_limits.sv:13](../tests/ch32/test_sdf_recrem_limits.sv#L13)、
同27–28・46行、[期待出力](../tests/ch32/test_sdf_recrem_limits.expected)。

刺激は非同期制御相当の`d`が7/12、クロックが10に変わる構成で、
SDFは`(RECREM d (posedge clk) (4) (3))`。
ところがSVは`$recrem(posedge clk, d, ...)`と逆順になっている。
**31.3.6（pp.903–904）** のrecremは、非同期制御の解除を第1イベント、
クロックを第2イベントとする。規格中の`$recrem(posedge clear, posedge clk, ...)`と
`$recovery`/`$removal`の等価例でも確認できる。

さらに **32.4.2、Table 32-2（p.926）** は、RECREMを一致する`$recrem`だけでなく
`$recovery`と`$removal`へも注釈すると規定する。
「同じイベントの独立した`$removal`はlimit 1のまま」という説明・期待は成立しない。

**修正案:** 意図した刺激に合わせ、SVの両チェックを`(d, posedge clk, ...)`に直す。
同じイベントに対する`$removal`にもlimit 3が入るものとして期待値を作り直す。
この構成ならrecovery違反の判定は時刻10、removal違反は時刻12となり、
後者では独立したremoval notifierも変化する。
「注釈されないチェック」を対照にしたいなら別イベントのチェックを用いる。
メタデータの`31.4.6`も、recremを規定する`31.3.6`に修正する。

### F12: coverage制御がすべてERRORでも、全判定が合格する

対象: [test_coverage_definition_control.sv:68](../tests/ch40/test_coverage_definition_control.sv#L68)、
同80–94行。

`reset_u1 != SV_COV_OK || ...`、`stop_def != SV_COV_OK || ...`、
`start_u1 != SV_COV_OK || ...`という条件で、操作の失敗そのものが合格条件になる。
**40.3.2.1、Table 40-1** で`SV_COV_ERROR`は操作失敗を示す。
coverageが存在しない場合の`NOCOV`等と、API実装のエラーを区別できていない。

すべての`$coverage_control`、`$coverage_get`、`$coverage_get_max`を
`(-1)`（`SV_COV_ERROR`）に置き換え、その他の刺激と判定を残したコピーを実行すると、
Icarus 13.0で **期待される4行がすべて1のまま一致** した。
RESET/STOP/STARTやインスタンス選択を一切実装しないものでも、このテストは通る。
ソースコメントでも失敗時の含意としているが、テストの説明で掲げた動作を検証できない。

**修正案:** 各操作と照会の戻り値を検査し、ERRORを失敗にする。
NOCOV等を許す場合は未検証として明示的に区別し、正常に収集できる構成では
操作成功と実際のカバレッジ変化を必須にする。まず戻り値の妥当性を検査するだけでも、
この全ERRORの偽陽性を防げる。

## 実行した確認

- `tools/suite_stats.py --check`: 成功。
- `generators/generate.py --check`: 成功。
- `tools/suite_catalog.py --check`: 成功。
- `tools/coverage_depth.py --check`: 成功。
- `tools/lint_metadata.py`: 3,801件、**新規問題0、既知378、解消0**。
  既知の体裁上の問題は本レビューの12件に含めていない。
- Icarus Verilog 13.0: 全3,801件をランナーに渡し、オラクル対象は
  **2,526/2,526一致**。対象外1,275件は既知差分枠。
  対象外で実際に一致した50件を含めるとJSON上のpassは2,576件。
- Verilator 5.052: 全オラクル対象 **944/944一致**。
  Icarus、Verilatorとも既存オラクル対象の新たな不一致はなかったが、
  F01〜F04などの規格との食い違いを否定する結果ではない。
- pyslang 12.0.0: 全3,801件の解析が完了。
  未対応機能等に起因する診断もあるため、診断数を問題件数として扱っていない。
- C11構文チェック（`-Wall -Wextra -Wformat=2 -Wuninitialized`）:
  208ファイルでコンパイルエラー0。警告は未使用変数1件。
  F08はコンパイラの警告では検出されないAPIのバッファ寿命の問題。
- 追加再現: F08の共有バッファ、F09のstatic引数共有、F12の全ERROR時の偽陽性を確認。

主要な既存チェックの再実行コマンド（リポジトリルートで実行）:

```sh
python3 tools/suite_stats.py --check
python3 generators/generate.py --check
python3 tools/suite_catalog.py --check
python3 tools/coverage_depth.py --check
python3 tools/lint_metadata.py
python3 tools/run_icarus.py --iverilog-bin /opt/homebrew/Cellar/icarus-verilog/13.0/bin -j 6 --json /tmp/kirimasim-review-icarus.json
python3 tools/run_verilator.py -j 4 --json /tmp/kirimasim-review-verilator.json
```

## 診断と規格を照合して、指摘から除外した例

追加解析器が拒否したという理由だけでは規格違反と判断していない。例えば、
UDN全体へのforce/release（6.6.7）、幅の狭い連想配列の走査引数（7.9.8）、
nettypeの別名と型同一性（6.22.6）、interconnectのprimitive端子接続（23.3.3.7.2）、
configを含むソースからの構成選択（33.5.4）は、本文の許容規則を確認したため
今回の指摘に含めなかった。

規格のみを根拠とする502件は、2つの既存シミュレータで正常系の期待値を
独立に再現できたことを意味しない。特に高度なVPI、checker、SDF timing check、
coverage APIは、本文との照合と局所再現を中心に評価した。
