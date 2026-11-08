# クロス検証の不一致対応と次の優先順位

[English](cross-verification-followup.en.md) / [日本語](cross-verification-followup.md)

2026-11-06（日本時間）の更新です。2026-11-03の対応記録を保持し、固定回帰・正式Nightly・既存期待値・選択モデルを維持し、
既知の不一致の修正、未対応の整理、要精査の章対の確認の順に進めています。

現在の[全クロスのローカル選択](../coverage/interaction-results/cross110-kirimasim-f029ddd0-scopecaselit.json)は110モデル・4,416件で、最新のmainをビルドしたkirimasim `f029ddd0eee1`で実行しました。
3,915 pass・487 unsupported・14 failです。failはconfigの4件、`defparam`の4件と、生成ブロックのクラスでkirimasimが内部エラーになる6件です。[前回の全実行](../coverage/interaction-results/cross107-kirimasim-28c6c1a1-delaypkgesc.json)と比べて従来4,296件の入力と状態は不変です。
前回の126件は[`c229a05f`のCheck](https://github.com/kurochan001/kirimasim-tests/actions/runs/42435564931)で固定版比較が成功し、Nightlyでは未実行です。今回の120件も[`a9c8a8eb`のCheck](https://github.com/kurochan001/kirimasim-tests/actions/runs/42461618429)で固定版比較が成功し、Nightlyでは未実行です。

[基点67321079のCheck](https://github.com/kurochan001/kirimasim-tests/actions/runs/42120289584)は成功し、追加前の88モデルを含む固定版比較・静的検査を確認しました。
[同じ基点のNightly](https://github.com/kurochan001/kirimasim-tests/actions/runs/42136599265)もworkflowと全ジョブが成功しましたが、個別artifactは未照合です。その後の追加は両実行の対象外です。
以下の未コミットビルドは修正過程の記録であり、現在の上流の状態を示すものではありません。
kirimasim-testsのNightlyの1回の成功と、本体リポジトリの7連続Nightly条件は分けて扱います。

2026-11-04の固定suiteの確認時点で、第30章の通常のspecify条件テスト5件がunsupportedからPASSへ改善しました。
この5件は有限クロスの選択外です。選択内の状態依存specifyパス12件・SDF注釈6件の未対応は変わっていません。
[今回の確認記録](../coverage/interaction-qualification/formal-ci-9926160a-20261104.json)に5件の識別と固定入力の不変を記載しています。

<a id="triage-of-the-eleven-failures"></a>
<a id="不一致11件の切り分け"></a>

## 当初の不一致11件の切り分け

- **inside比較の2件：修正を取り込み、PASSを確認。** kirimasimの既存ブランチの
  `b16163c7`にあった修正と機構別matrixを、2026-11-03の取り込み時点のmain作業ツリーへ反映しました。
  配列要素を自身の符号ではなく比較の共通型の符号で拡張する規則です。
  規則の実装箇所は`Lowerer::memberMatch`と`Lowerer::propagate`で、通常のinside、
  配列要素、case insideが同じ経路を使います。新しいアルゴリズムを別に作ったものではありません。
- **遅延アサーションの5件：承認後に修正し、PASSを確認。** 2026-11-03に仕様修正案が
  承認され、pass/fail両wrapperが同じ文IDを持ち、その未成熟報告だけを消す処理を実装しました。
  兄弟報告・評価済み副作用・成熟済み履歴は保持します。本体の
  `docs/notes/deferred-label-cancellation.ja.md`に実装と範囲を記載しています。
- **configの4件：固定版slang側へ切り分け。** front・SIR・VMを使わないパラメータ問合せでも、
  41件中同じ4件が不一致でした。分離した依存の診断用パッチでは41件すべて一致しました。
  本番の依存とkirimasimにはそのパッチを適用していません。本体の
  `docs/notes/config-reset-dependency-gap.ja.md`に記録しています。

[元の全選択実行](../coverage/interaction-results/cross75-kirimasim-f3ea0379.json)は
2,245 pass・529 unsupported・11 failです。
[inside修正後の全選択実行](../coverage/interaction-results/cross75-kirimasim-26a3e5a3-insidefix.json)は
**2,247 pass・529 unsupported・9 fail**でした。全2,785件の入力fingerprintは不変で、
状態の変化は上記2件のfail→passだけです。[11件の全出力再現](../coverage/interaction-qualification/cross-failures-20261103.json)も保持します。

当時記録したinside修正版はローカルmain `26a3e5a3`に未コミットの修正を加えたビルドです。
upstream mainの公開済み修正ではありません。[版・修正元・ソース・バイナリの記録](../coverage/interaction-qualification/insidefix-build.json)を併読してください。
機構別matrixはinitial/task/always/forkの4入力で各120出力行を比較し、関連12検査がPASSしました。
本体の全local CIもPASSしました。正式Nightlyと7連続Nightlyの証拠を更新したものではありません。

その後、承認済みラベル取消しをupstream main `7654825d`＋ローカル変更へ実装し、
未改変のslang pinも更新済みの`d02b7cda`で確認しました。
[全選択の実行](../coverage/interaction-results/cross75-kirimasim-7654825d-labelcancel-final.json)は
**2,252 pass・529 unsupported・4 fail**です。inside修正時点から変わったのは
ラベル取消し5件のfail→passだけで、入力はすべて同じです。遅延報告31件は全PASSです。
[ビルド記録](../coverage/interaction-qualification/labelcancel-build.json)と
[元の5件の全出力再実行](../coverage/interaction-qualification/labelcancel-replays.json)で、
実際の実装とバイナリを識別しています。本体の新規suite20入力と絞った37検査がPASSです。
本体の全local CIは21項目すべてPASSです（dev・ASan・UBSanは各11,827件、releaseは11,828件）。正式Nightlyとは区別します。

## 未対応529件の機構別整理

[指紋付きの全529件と19機構の一覧](../coverage/interaction-qualification/unsupported-triage-20261103.json)を保存しました。
同一snapshotの分類であり、新しいskip一覧やPASSの集計ではありません。主な系統は次のとおりです。

- 並行アサーション99件・checker27件。
- randomize52件・covergroup33件。
- DPIのrunner実行前判定67件。実行して得た未対応診断とは区別します。
- イベント値45件・mailbox36件。
- 集合の配列要素26件・許容差範囲16件・集合要素の副作用8件。
- clockingのゼロskew18件・ガード12件・virtual interface19件。
- 型付き連想配列18件。
- クラス配列プロパティ11件・プロパティ参照6件・ref実引数18件。
- 状態依存specifyパス12件・SDF注釈6件。

最初に詳細契約を確認する実装候補はSDF注釈です。固定Icarus oracleが登録済みの3件を含み、
[今回のIcarus 13.0再実行](../coverage/interaction-results/cross-followup-sdf-icarus13.json)も3件一致でした。
残るincrementの3件はknownのままで、oracleや期待値は変更していません。
現行の本体specify契約はSDFを未対応と明記しているため、先に規格上の範囲と仕様修正案を確定します。
件数の多さや別シミュレータの多数決だけで実装順・正しさ・P1完了を決めません。

## 要精査の章対と追加テストの方針

当初の見直しでは要精査Rを2章対だけ確認し、その時点で590章対を未評価のまま残しました。

- **第13×16章：レビュー時はE、現在はM。** 既存の遅延アクション引数テストが、登録時の値渡しとNBA後の
  参照値を同じ入力・期待値で観測しています。元のソースと期待値を確認し、
  [最新ローカルビルドでも再実行](../coverage/interaction-results/cross-followup-subroutine-kirimasim-26a3e5a3-insidefix.json)しました。
  この単独再実行を有限モデルの章間登録や、ラベル取消し全体のPASSへは加算していません。
  続く[遅延報告引数モデル](interaction-verification.md#deferred-argument-capture)で、
  幅・符号・渡し方・仮引数幅・サブルーチン・報告キュー・更新方式を明示し、29件を追加しました。
  この追加時点の全2,814件の単一snapshotで追加29件がPASSし、第13×16章をMへ移しました。
- **第11×33章：C。** 設定式の幅・符号と生成形状を追加候補にしました。
  現行configモデルの名前解決・優先順位の確認を保ち、語境界、式の型・符号、
  演算・条件式を将来の独立因子として検討します。合法な式と正の寸法の確定、
  既知のconfigリセット不一致の修正を先に行います。

現在の仕分けはM189・E3・C2・N117・R509です。
[章対の根拠と指紋](chapter-cross-triage.md)を参照してください。
既存の回帰matrixを先に活用し、原因が確定した機構に境界・操作列・故障対照を追加します。
同じ目的の別runnerや、ランダム結果を固定要求カバレッジへ加算する仕組みは追加していません。

続く[列挙型とgenerateのモデル](interaction-verification.md#generated-enum-navigation)では、未精査だった第6章×第27章を確認してMへ登録しました。上流`7554bb47`の全2,850件の単一実行で追加36件がPASSし、configの4 failと529 unsupportedは不変です。その追加時点で要精査Rは589章対でした。この資料内の以前の件数は、それぞれ記録時点の値です。

続く[packageのNBAモデル](interaction-verification.md#package-nba-capture)では、未精査の第10章×第26章・第4章×第26章・第7章×第26章をMへ移しました。上流`7554bb47`の全2,886件の単一実行で追加36件がPASSし、既存configの不一致と未対応は不変です。配列の対応は24件で、全選択ケースPASSはモデル全体36件の合格を必要とします。その時点の要精査Rは586章対でした。

続く[package変更の観測モデル](interaction-verification.md#package-change-observers)で、未精査の第9章×第26章と第11章×第26章をMへ移しました。前者は全36件、後者はlogicのX/Zを扱う12件に対応します。既登録の第4章×第26章・第7章×第26章にも観測を追加しました。上流`a682e19e3238`の全2,922件の単一実行で追加36件がPASSし、従来2,886件の入力と状態分類は不変です。この追加時点で要精査Rは584章対で、残る章対すべてを検証済みとするものではありません。

2026-11-04の[クラスメソッド×packageのモデル](interaction-verification.md#class-method-package-lookup)で、未精査だった第8章×第26章をMへ移しました。
上流`9113955914d8`の全2,956件の単一実行で追加34件がPASSし、従来2,922件の入力・状態分類は不変です。
この追加時点では80モデル・115章対、全選択ケースPASSは53モデルで、2,423 pass・529 unsupported・configの4 failです。
この時点の要精査Rは583章対です。このローカル結果は正式Check・Nightlyと区別し、クラス×package全体の網羅を示すものではありません。

2026-11-05の[生成サブルーチンモデル](interaction-verification.md#generated-subroutine-binding)で、第13章×第27章・第7章×第27章をRからMへ移し、既存の第7章×第13章も補強しました。
上流`162222153c57`の全2,992件の単一実行で追加36件は全PASS、従来2,956件の入力ハッシュ・状態分類は不変です。
81モデル・117章対・全選択ケースPASS 54モデルで、要精査Rは581章対です。固定Icarusは全36件が一致し、
固定Verilatorのseed 1/73は各11 pass・25 knownです。符号付きtaskのcopy-outの差異とfunction対照を保持し、
この比較によって期待値・回帰ゲート・ランダムプロファイル・要求の対応付けは変更しません。

続く2026-11-05の[クラスの条件選択モデル](interaction-verification.md#class-conditional-return)で、第8章×第11章・第8章×第12章をRからMへ移しました。
上流`162222153c57`の全3,028件の単一実行で追加36件は全PASS、従来2,992件の入力・状態分類は不変です。
82モデル・119章対・全選択ケースPASSは55モデル、2,495 pass・529 unsupported・既存configの4 failです。
要精査Rは579章対です。合法1,296プログラムの独立解釈が一致し、正常対照5件・SVへの9故障で観測を検算しました。
固定Verilatorのseed 1/73は各12 pass・24 known、固定Icarusは全36件のクラスハンドル比較を拒否します。
X/Zの期待値と[knownの全出力再実行](../coverage/interaction-qualification/classsel-known-replays.json)を保持し、nativeのPASSや4値oracleとは分けます。

生成ループの追加で第12章×第27章・第9章×第27章を精査し、第7章×第27章も補強しました。合法6,912行から因子対293組・重点3因子160組・必須6件を保持する36件を選びました。
最新ビルド`50a897dee62a`の全3,064件の単一実行で追加36件は全PASS、従来3,028件の入力ハッシュ・分類は不変です。
83モデル・121章対・全選択ケースPASS 56モデル、仕分けはM121 / E3 / C2 / N117 / R577です。
Icarusは31入力に一致し、repeat回数1の5件は拒否を保持して、独立に解釈した回数3対照と分けています。
全6,912ソースの独立解釈が一致し、正常対照5件・実際のSVへの9故障で観測を検算しました。
基点19cd790aの正式Check・Nightlyとランダム96 PASSも確認しましたが、新しい有限ケースはローカル証跡です。
[設計と全記録](interaction-verification.md#generated-process-loop-transfer)を参照してください。

## interface配列問い合わせによる走査（2026-11-05）

[第7×25・20×25・13×20章のモデル](interaction-verification.md#interface-array-query-walk)を追加しました。
合法4,608通りから36件を選び、全行の独立検算と、正常対照5件・実行可能な9故障を確認しました。
最新取得・ビルドの`50a897dee62a`で全3,100件を一度に実行し、追加36件はparse成功・全PASS、従来3,064件の入力・分類は不変です。
固定IcarusはX/Zを含む全36件に一致し、固定Verilatorの既知値12件は両seedで一致しました。2値の偶然の一致を4値の確認やoracle登録に使いません。
要求対応付け・ランダム13プロファイル・既存回帰・本体コードは不変です。

- [書式付き読取りと部分書込み](interaction-verification.md#formatted-scan-partial-write)を第11×21章・第20×21章へ追加しました。
  代表化後の合法5,760行から36件を選び、因子対292組・重点3因子142組・必須6件を保持します。独立解釈と正常対照6件・実際の9故障を確認しました。
- 最新取得・ビルドの`6f5c69841228`による全3,172件の単一実行は、2,639 pass・529 unsupported・既存configの4 failです。
  追加36件はparse成功・全PASS、従来3,136件の入力・分類は不変です。86モデル・128章対・全選択ケースPASSは59モデル、M132・E3・C2・N117・R566です。
- 固定Icarusは17 pass・19 known、Verilator両seedは各3 pass・33 knownです。元の差と同一刺激のliteral対照を別に保持し、期待値・分類を弱めません。
  第11×21章の対応は部分選択24件、第20×21章は実行時書式12件で、モデル全体は全36件の同時成功を要求します。
- 固定suiteは10,922件、うち4,485件は95生成器による自動生成です。要求対応付け・既存回帰・本体コード・ランダム13プロファイルは不変です。
  今回の36件は正式Check・Nightlyでは未実行です。

## 時間スコープ・リテラル・ゲート配列（2026-11-07）

- これまでモデルのなかった第3章と第5章に、[時間スコープ](interaction-verification.md#time-scope-delay)と[リテラル](interaction-verification.md#literal-context-extension)のモデルを追加しました。[ゲート配列](interaction-verification.md#gate-array-connection)で第7・11・23・4章×第28章も精査しました。
- 第3章×第5・9・10・13・20・21・22・23・25・26章、第5章×第6・10・11・20・22章、第4・7・11・23章×第28章の19章対をRからMへ移しました。
- kirimasim `60c26d7c8113`の単一の全3,445件は2,912 pass・529 unsupported・既存configの4 failです。追加165件は全PASSです。92モデル・151章対・全選択ケースPASSは65モデルです。
- クラスのNBAと`$assertoff`も候補に調べましたが、kirimasimが未実装で固定版とも比較できないので見送りました。第8×10章と第16×20章は要精査のまま残ります。[実装を待つ候補](#models-waiting-for-kirimasim)に記録しました。
- リテラルの期待値を一度誤り、全合法行の実行で気づいて条文から直しました。[経緯](interaction-verification.md#literal-context-extension)を参照してください。

<a id="models-waiting-for-kirimasim"></a>

## kirimasimの実装を待つ候補

次の6件は、kirimasimが未実装なので見送りました。テストがまだないので、実装されても結果は変わらず、確認しなければ気づけません。
kirimasimの新しいビルドで全クロスを実行するときに下のプログラムを試し、`not implemented yet`が出なくなったらモデルや観測を追加します。
既存の未対応529件はテストがあり、実装されれば結果が変わるので、この一覧には入れません。
同じ理由で見送るものが増えたらここへ足し、追加を終えた項目は消します。状態は2026-11-08のkirimasim `33cee3fa2f0d`のもので、6件とも`f029ddd0eee1`から変わっていません。

期待値は規格から求め、[全合法行を一度実行](interaction-verification-method.md#run-every-legal-row-once)して確かめます。

### クラスプロパティへのNBA（第8×10章の新モデル）

10.4.2は、左辺のクラスハンドルと添字を右辺と同時に評価すると定めるので、更新先は予約時のオブジェクトです。
予約後にハンドルの付替えやnull代入、添字の変更を行い、代入内遅延も交えて、更新の前後で両方のオブジェクトを読みます。
固定Verilator 5.052は自動変数として拒否し、固定Icarus 13.0は試作で添字付きのプロパティを拒否しました。

```systemverilog
class C; logic [7:0] x; endclass
module top;
  C h = new;
  initial begin h.x <= 8'h5a; #1 $display("%h", h.x); $finish; end
endmodule
```

### アサーション制御（第16×20章の新モデル）

20.11のOffは待ち行列にある遅延アサーションの報告を残し、Killは消します。Lockは以後の変更を止め、PassOffとFailOffはアクションブロックを止めます。
制御の種類、アサーションの種類（単純、observed遅延、final遅延）、スコープと階層、待ち行列の報告に対する制御の順序を交差します。
固定Icarus 13.0は遅延アサーションを未対応とします。固定Verilator 5.052は未確認です。

```systemverilog
module top;
  initial begin $assertoff(0, top); a: assert (0); $asserton(0, top); $display("end"); $finish; end
endmodule
```

### packageの`$printtimescale`（`time_scope_delay`への観測の追加）

20.4.2は、現在のスコープの単位と精度の表示を定めています。
[`interaction_timescope.py`](../generators/interaction_timescope.py)のtaskで表示し、`VERSION`を上げて証跡を更新します。選択ケースの入力が変わるので、全クロスの再実行も必要です。

```systemverilog
package pk; timeunit 1ns / 1ps; task automatic t; $printtimescale; endtask endpackage
module top; timeunit 1ns / 1ps; initial begin pk::t; $finish; end endmodule
```

### 並行アサーション（`assertion_vector_query`への種類の追加）

`assert property`は、kirimasimが`statement 'ConcurrentAssertion'`を未実装とします。既存の`cross_assert`の36件も未対応です。
実装されたら、[`interaction_assertquery.py`](../generators/interaction_assertquery.py)のアサーションの種類に並行アサーションを加え、`VERSION`を上げて証跡を更新します。
固定Icarus 13.0は並行アサーションを未対応とし、固定Verilator 5.052は二値なのでxとzの行を比べられません。

```systemverilog
module top;
  logic [3:0] v = 4'b01x0; bit clk;
  a: assert property (@(posedge clk) $onehot(v)) $display("pass"); else $display("fail");
  initial begin #1 clk = 1; #1 $finish; end
endmodule
```

### サイクル遅延と同期駆動（第12×14章の新モデル）

kirimasimは`##`を`unsupported: timing control`、clockingの出力を`unsupported: output or inout clocking variable`として未実装とします。
14.11の`##N`は既定のclockingのイベントをN回待ち、`##0`は現在の時刻にそのイベントがまだないときだけ待ちます。14.16の同期駆動は、clockingのイベントに出力のskewを足した時刻に値を変えます。
`##0`・`##1`・`##(式)`を`for`・`repeat`・`fork`・taskの中で、クロックの時刻と時刻の間から始め、出力のskewと右辺の`##`を持つ同期駆動と交差します。
固定Icarus 13.0はclockingブロックを受け付けず、固定Verilator 5.052は下のプログラムで`a 5`・`b 15`・`o 9`を出します。

```systemverilog
module top;
  bit clk;
  logic [3:0] o;
  always #5 clk = ~clk;
  default clocking cb @(posedge clk);
    output #1 o;
  endclocking
  initial begin
    #3 ##0 $display("a %0t", $time);
    ##1 $display("b %0t", $time);
    cb.o <= ##2 4'd9;
    #30 $display("o %0d", o);
    $finish;
  end
endmodule
```

### 式に結び付けたclockingの入力（第7×14・11×14章の新モデル）

kirimasimは、連結を`unsupported: noncontiguous clocking source`、和・構造体のメンバー・配列の要素を`unsupported: clocking source without static packed storage`として未実装とします。
14.5では、clockingの信号を入力ポートへの接続として合法な式（部分選択や連結を含む）に結び付けられ、14.13はその式の値を採取します。
連結・部分選択・構造体のメンバー・配列の要素・階層名に結び付け、各部分をクロックの前後で変えて`@(cb)`の後に読みます。
固定Icarus 13.0はclockingブロックを受け付けず、固定Verilator 5.052は下のプログラムで`e`を出します。

```systemverilog
module top;
  bit clk;
  logic [3:0] a = 4'h1, b = 4'h2;
  clocking cb @(posedge clk);
    input #1step v = {a[1:0], b[1:0]};
  endclocking
  initial begin
    #1 clk = 1;
    #1 a = 4'h3; clk = 0;
    #1 clk = 1;
    @(cb) $display("%h", cb.v);
    $finish;
  end
endmodule
```

## マクロ展開・force/release・暗黙の感度（2026-11-07）

- [マクロ展開](interaction-verification.md#macro-expansion-context)、[force/release](interaction-verification.md#force-release-visibility)、[暗黙の感度](interaction-verification.md#implicit-sensitivity-update)のモデルを追加しました。
- 第7・8・9・10・11・12・13・20・21・25・26・27章×第22章、第10×20・10×21章、第4×6・4×7・4×11章の17章対をRからMへ移しました。
- kirimasim `97d5b0001e7c`の単一の全3,692件は3,159 pass・529 unsupported・既存configの4 failです。追加247件は全PASSです。95モデル・168章対・全選択ケースPASSは68モデルです。
- 全合法行10,469行でkirimasimの差は0件で、期待値の修正はありません。Icarusとの差はすべて条文に照らしてIcarus側の問題と判断しました。
- `$finish`後の`final`の見え方（第9×20章）は、保留中のNBAや同じ時刻の他のプロセスを規格が定めないので見送りました。kirimasimの未実装が理由ではありません。

## インタフェースの式・ループの制御・リテラルの表示（2026-11-07）

- [インタフェースのメンバ](interaction-verification.md#interface-member-expression)、[ループの制御とスケジューリング領域](interaction-verification.md#loop-control-scheduling)、[リテラルと表示の書式](interaction-verification.md#literal-format-display)のモデルを追加しました。
- 第11×25・12×25・4×12・12×21・5×21章の5章対をRからMへ移しました。
- kirimasim `6e32b04ed6ec`の単一の全3,887件は3,404 pass・479 unsupported・既存configの4 failです。追加195件は全PASSです。98モデル・173章対・全選択ケースPASSは74モデルです。
- 従来3,692件の入力は不変です。kirimasimの`inside`・範囲・`case inside`の実装で50件がunsupportedからPASSになり、`membership_container`・`membership_range`・`case_inside_selection`は全選択ケースPASSになりました。
- 全合法行4,883行でkirimasimの差は0件で、期待値の修正はありません。IcarusとVerilatorとの差は、すべて条文に照らして各シミュレータ側の問題と判断しました。
- [kirimasimの実装を待つ候補](#models-waiting-for-kirimasim)の3件は、`6e32b04ed6ec`でもまだ`not implemented yet`です。

## パラメータの上書き・アサーションのビットベクタ関数・リテラルの引数（2026-11-07）

- [パラメータの上書きと型](interaction-verification.md#parameter-override-type)、[アサーションの中のビットベクタ関数](interaction-verification.md#assertion-vector-query)、[リテラルの引数と変換](interaction-verification.md#literal-argument-conversion)のモデルを追加しました。
- 第11×23・7×23・16×20・5×13章の4章対をRからMへ移しました。
- kirimasim `eee8cd16ba1d`の単一の全4,023件は3,536 pass・479 unsupported・8 failです。追加136件のうち132件がPASSです。101モデル・177章対・全選択ケースPASSは76モデルです。
- 新しいfail 4件は、型も範囲もないか`signed`だけのパラメータを`defparam`で上書きする行です。kirimasimは型と範囲を`defparam`の前の値のまま残し、値を切り詰めます。
  全行では252行のうち24行で、固定Icarusは20行、固定Verilatorは`#()`と併用しない12行で規格どおりの期待値と一致します。期待値は変更していません。
- アサーションとリテラルの引数の全922行で、kirimasimの差は0件です。
- 並行アサーションはkirimasimが未実装なので、[実装を待つ候補](#models-waiting-for-kirimasim)に加えました。ほかの3件も`eee8cd16ba1d`でまだ未実装です。
- `eee8cd16ba1d`はシミュレータのソースが`6e32b04ed6ec`と同じで、従来3,887件の入力と状態は変わりません。

## 階層名によるプロセスの制御・%mの階層名・配列の問い合わせ関数とループ（2026-11-08）

- [階層名によるプロセスの制御](interaction-verification.md#hierarchical-process-control)、[%mの階層名](interaction-verification.md#hierarchical-name-display)、[配列の問い合わせ関数とループ](interaction-verification.md#array-query-loop)のモデルを追加しました。
- 第9×23・15×23・21×23・12×20章の4章対をRからMへ移しました。
- kirimasim `28c6c1a1cb83`の単一の全4,170件は3,683 pass・479 unsupported・8 failです。追加147件は全PASSです。104モデル・181章対・全選択ケースPASSは79モデルです。
- 全合法行869行でkirimasimの差は0件で、期待値の修正はありません。IcarusとVerilatorとの差は、二値のVerilatorがxを表せない6行を含め、条文に照らして各シミュレータ側の差と判断しました。
- `28c6c1a1cb83`はフロントエンドが`eee8cd16ba1d`から変わりましたが、従来4,023件の入力と状態は変わりません。`defparam`の4件もまだfailです。
- [実装を待つ候補](#models-waiting-for-kirimasim)の4件は、`28c6c1a1cb83`でもまだ`not implemented yet`です。

## 遅延の値の書き方・packageの名前の探索・エスケープした識別子（2026-11-08）

- [遅延の値の書き方](interaction-verification.md#delay-value-form)、[packageの名前の探索](interaction-verification.md#package-name-lookup)、[エスケープした識別子の結合](interaction-verification.md#escaped-name-binding)のモデルを追加しました。
- 第5×9・12×26・5×23・5×27章の4章対をRからMへ移しました。
- kirimasim `28c6c1a1cb83`の単一の全4,296件は3,809 pass・479 unsupported・8 failです。追加126件は全PASSです。107モデル・185章対・全選択ケースPASSは82モデルです。
- 全合法行496行でkirimasimの差は0件で、期待値の修正はありません。固定Icarus 13.0も全行で一致しました。Verilatorとの差は、xとzの遅延を二値で読む行とzの遅延の未対応だけです。
- packageの名前の探索では、26.3が不正とする28通りの組合せを除き、独立した解釈がそれらをエラーとすることを確かめました。

## moduleとgenerateブロックのクラス・case項目のリテラル・構造体リテラル（2026-11-08）

- [moduleとgenerateブロックで宣言したクラス](interaction-verification.md#scoped-class-declaration)、[case項目のリテラルの桁](interaction-verification.md#case-literal-wildcard)、[構造体リテラルのキー](interaction-verification.md#aggregate-literal-key)のモデルを追加しました。
- 第8×23・8×27・5×12・5×7章の4章対をRからMへ移しました。
- 最新のmainをビルドしたkirimasim `f029ddd0eee1`の単一の全4,416件は3,915 pass・487 unsupported・14 failです。追加120件のうち106件がPASSです。110モデル・189章対・全選択ケースPASSは83モデルです。
- 新しいfail 6件は、if・caseの生成ブロックのクラスが静的プロパティを持つ行です。インスタンスにならない分岐の、静的プロパティを持つクラスとその型の変数で、kirimasimが内部エラーになります。全240行では30行です。固定Verilator 5.052は全行で規格どおりの期待値と一致します。期待値は変更していません。
- 構造体リテラルのlocalparamの8件は、kirimasimが非パックの構造体のlocalparamを未実装なのでunsupportedです。
- case項目のリテラルの全312行で、kirimasimの差は0件です。
- `f029ddd0eee1`はslangの更新を含みますが、従来4,296件の入力と状態は変わりません。`defparam`の4件もまだfailです。
- サイクル遅延と同期駆動、式に結び付けたclockingの入力は、kirimasimが未実装なので[実装を待つ候補](#models-waiting-for-kirimasim)に加えました。ほかの4件も`f029ddd0eee1`でまだ`not implemented yet`です。
