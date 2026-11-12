<a id="pass-nowhere-review-2026-11-12"></a>

# どのシミュレータでも合格しないテストの見直し（2026-11-12）

[English](pass-nowhere-review-20261112.en.md) / [日本語](pass-nowhere-review-20261112.md)

どのシミュレータでも合格しないテストを見直しました。
この記録は、分かったこと、直したテスト、判断を待つものを示します。
期待結果はIEEE 1800-2023だけから決めます。
シミュレータの出力に合わせて期待結果を変えたものはありません。

<a id="what-was-reviewed"></a>

## 見直した対象

- プロジェクトが実行するどのシミュレータでも合格しないテストは148本です。対象のシミュレータは、固定版のIcarus Verilog 13.0とVerilator 5.052、kirimasim `7de185f776a1`、Nightlyのシミュレータです。Nightlyのシミュレータには、LyraとGhostが含まれます。
- 1回目のレビューは、すべてのテストと、テストが引用する節を読み、テストごとに判定を一つ付けました。
- 2回目の独立したレビューは、1回目が誤りまたは欠陥と判定したテストを対象にしました。期待結果を導き直し、修正の内容を確定しました。二つのレビューが違う点では、この記録は2回目に従います。
- どちらのレビューもAIによるものです。人による独立したレビューではありません。
- 解釈が分かれる17本を判定したのは、1回目のレビューだけです。

<a id="verdicts"></a>

## 判定

| 判定 | 本数 |
|---|---:|
| 期待結果は正しい | 91 |
| 期待結果が誤っている | 9 |
| テストに欠陥がある | 10 |
| 解釈が分かれる（二つの読み方がどちらも成り立つ） | 17 |
| どこでも実行できない | 21 |
| 合計 | 148 |

「どこでも実行できない」は、どのシミュレータにもその機能がなく、実行結果から何も分からないものです。
この場合も、期待結果をできる範囲で規格と照合しました。

<a id="corrected-tests"></a>

## 直したテスト

誤りまたは欠陥の19本のうち、17本を直しました。
148本の外にも同じ問題を持つテストが4本あり、一緒に直しました。変更したテストは21本です。
変更したテストには、何をなぜ直したかをコメントに書いています。

| テスト | 節 | 問題 | 修正 |
|---|---|---|---|
| `ch16/test_ch16_sim_multiclock_init` | 16.13.2、16.13.7、20.11 | テストは、後件の評価を75としていました。前件が10で成立した後、マルチクロックの`\|=>`は、それより後で最も近い2番目のクロックのチック、25に進みます。また、既定ではpass actionは空虚な成功でも実行されますが、期待出力にその行がありませんでした。 | 最初に`$assertvacuousoff`を呼び、`e`を20で1にしました。期待出力は`pass at 25`と`done`です。 |
| `ch16/test_ch16_sim_prop_inherited_eventually` | 20.11、16.14.8 | pass actionは、前件が偽のチックでも実行されます。期待出力にその行がありませんでした。 | 最初に`$assertvacuousoff`を呼びます。期待出力は同じです。 |
| `ch16/test_sequence_method_empty_matches` | 16.13.6、16.13.5 | 2番目のクロックは10、30、50でしか立ち上がらず、そこでは`b`が0でした。元のシーケンスに空でないマッチがなく、`matched`は一度も真になりません。 | 2番目のクロックを10単位時間ごとに立ち上げます。期待出力は同じです。 |
| `ch17/test_checker_assertion_placement` | 17.3、16.5.1 | 15のクロックで`d`は9ではなく4です。静的なconcurrent assertionの失敗は2回です。 | 期待出力は`static: concurrent=2 deferred=3`です。 |
| `ch19/test_covergroup_bins_and_range_forms` | 19.5 | カバレッジにdefault sequenceのbinを数えていました。default binは計算に入れません。 | 遷移のカバレッジの期待値は85.7（7個のbinのうち6個）です。 |
| `gen/ch35/test_gen_cross_dpi_array_*`のうち、1要素の動的配列・キューの4件 | 20.7、H.12.2 | `svIncrement`に1を期待していました。動的配列とキューの次元では常に-1です。 | 生成器と独立検算が-1を返すようにしました。[モデルの節](interaction-verification.md#dpi-open-arrayの形状と書戻し)を参照してください。 |
| `ch19/test_cg_illegal_transition_error`、`ch19/test_cg_illegal_cross_error` | 19.5.6、19.6.3 | 実行時エラーのメッセージに、テストのソース行を要求していました。規格はエラーの形式を定めていません。 | `ch19/test_cg_illegal_value_error`と同じく、メッセージにerrorがあることだけを照合します。2本目は148本の外のテストです。 |
| `ch18/test_constraint_function_cycle_runtime_error`（元の名前は`test_illegal_constraint_function_cycle`） | 18.5.11、18.9 | テストは、コンパイル時の拒否だけを認めていました。順序は`randomize()`の時点で有効な制約の間にあるので、エラーは実行時でも構いません。 | 実行時のテストにしました。先に制約を一つ無効にするので、循環は2回目の`randomize()`にだけあります。 |
| `ch35/test_a2_5_dpi_open_array_packed_dimension` | H.7.6、H.7.7、H.12.2、H.12.4 | Cコードは、バイト数を要素数として読み、unpacked次元の添字で要素を読んでいました。仮引数`logic []`にunpacked次元はありません。 | Cコードは次元0のサイズと境界を表示し、値を`svGetArrayPtr`で照合します。NULLポインタも認めます。 |
| `ch37/test_vpi_constraint_iteration` | 37.32 detail 9 | アプリケーションは、`vpiExtends`の結果からさらに別のリレーションをたどっていました。class typespecでは、結果が基底クラスのtypespecそのものです。 | 結果を直接反復します。期待出力は同じです。 |
| `ch37/test_vpi_class_specialization_types`、`ch37/test_vpi_nettype_net_parts`、`ch37/test_vpi_variable_driver_load_arrays`、`ch37/test_vpi_net_bits_constant_select` | Annex K、37.16 detail 10、37.17 detail 13・18 | アプリケーションは`vpiIndex`を`vpi_get`で読んでいました。`vpiIndex`はリレーションで、整数のプロパティではありません。 | 補助関数が、添字のオブジェクトを`vpi_iterate`または`vpi_handle`で取り、整数値を読みます。期待出力は同じです。後の3本は148本の外のテストです。 |
| `ch37/test_vpi_struct_and_tagged_patterns` | 37.72 | テストは、メンバーパターンすべての反復とその値、tagged patternのtypespecの型を要求していました。この節が示すのは図だけで、図はどちらも定めていません。 | 各リレーションでオブジェクトが得られるかどうかだけを表示します。 |
| `ch37/test_vpi_udp_table_primitive` | 37.36 detail 1 | テストは、空白のないテーブル行を要求していました。節は、行が逆コンパイルした文字列であることしか述べていません。 | 空白と末尾のセミコロンを除いて行を比べます。期待出力は同じです。 |
| `ch38/test_vpi_put_value_udp_array_errors` | 38.34 | プリミティブの出力イベントが残っている間に値を書き、同じプロセスの中で読んでいました。節はどちらの結果も定めていません。 | プリミティブが落ち着いた後の16で値を書き、17で読みます。エラーになる書込みは、UDPが既に持つ値を書きます。 |

<a id="left-for-a-decision"></a>

## 判断を待つ、欠陥のあるテスト2本

この2本は変更していません。

- `ch4/test_illegal_final_deferred_action_schedules_event`（4.4.2.9）。デザインは不正です。メッセージのパターンは、行に加えて、Postponed領域とイベントについての語も要求します。別の言い方をした正しい拒否は一致しません。修正案は、行番号を残して語の条件をなくします。READMEは語を要求するパターンを認めていて、不正な設計のテストのうち31本にそのような条件があるので、これは方針の問題です。
- `ch18/test_illegal_randsequence_negative_weight`（18.17.1）。重みは負でない値に評価されなければならず、評価されるのはその生成規則が選ばれたときです。これは実行時の条件で、規格はエラーを出すとは述べていません。エラーはスイートの読み方であるとコメントに書いて実行時のテストにするか、テストを削除するかです。

<a id="contested-tests"></a>

## 解釈が分かれるテスト

この17本を判定したのは、1回目のレビューだけです。どれも変更していません。
読み方Aは、テストの読み方です。

| テスト | 節 | 読み方A | 読み方B | 扱いの案 |
|---|---|---|---|---|
| `ch7/test_illegal_string_in_untagged_union` | 7.3 | stringは動的な型で、タグなしunionには入れられません。 | 用語集の動的な型の一覧に、stringはありません。 | 争いのないキューまたはchandleのメンバを使います。 |
| `ch7/test_illegal_unique_index_without_with_struct_elements`、`ch7/test_illegal_unique_without_with_struct_elements` | 7.12.1 | `with`節を省けるのは、要素の型に`<`、`>`、`==`がすべて定義されているときだけです。 | `unique`と`unique_index`は等しいかどうかだけを比べ、`==`はunpacked構造体に定義されています。 | どちらの結果も認めます。規則は`min`と`max`のテストに残ります。 |
| `ch11/test_illegal_stream_with_on_two_dimensional_array` | 11.4.14.4 | `with`の前の式は、1次元のunpacked配列に限られます。 | 文は「can be」と述べ、エラーを定めていません。 | 必須のエラーとして数えません。テストを取り下げるか、解釈が分かれると明記します。 |
| `ch19/test_cg_four_state_literal_wildcard_enum` | 19.5.4、19.5.7 | 19.5.4では、xやzを含むbinの値は`===`で数えます。 | 19.5.7では、その値は警告になり、binに加わりません。規格の中で食い違っています。 | コメントを付けたまま残すか、どちらの読み方でも同じになる内容だけを表示します。 |
| `ch21/test_illegal_value_plusargs_bad_format` | 21.6 | 有効な変換は一覧にあるものだけなので、`%q`は不正です。 | エラーは定められていません。一致する引数がなければ関数は0を返し、警告も出しません。 | 不正な設計のテストをやめるか、どちらの結果も認めます。 |
| `ch22/test_illegal_include_absolute_path_in_angle_brackets` | 22.4 | 絶対パスを書けるのは、二重引用符の形だけです。 | 文は「can」と述べ、エラーを定めていません。 | 必須のエラーとして数えません。 |
| `ch23/test_port_collapse_uwire_external_delay` | 23.3.3.7、28.16 | 二つのネットは一つにまとめられ、優先するネットの遅延を使います。 | まとめるかどうかは任意です。二つのネットを残すツールは、両方の遅延を適用します。 | 内側のネットの遅延をなくし、どちらの読み方でも同じ出力にします。 |
| `ch30/test_illegal_specify_edge_path_same_edge_and_condition` | 30.4.4.3 | 一つのエッジ依存パスに二つの遅延を与えるには、エッジか条件が違う必要があります。 | 文は、その条件のもとで「can be assigned」と述べ、エラーを定めていません。 | 必須のエラーとして数えません。同じ文に基づくテストがもう1本あります。 |
| `ch31/test_illegal_setuphold_negative_sum` | 31.3.3、31.9.1 | 負の制限値があるとき、setupとholdの和は正でなければなりません。 | 31.9.1は、そのような値に警告と補正を定めていて、拒否は定めていません。 | テストをやめるか、警告を認めます。 |
| `ch31/test_illegal_timing_condition_two_signals` | 31.7 | 条件の信号が二つ以上のときは、その論理をspecifyブロックの外でまとめます。 | 文法は`&&&`の後に任意の式を認め、エラーは定められていません。 | どちらの結果も認めるか、テストをやめます。 |
| `ch36/test_vpi_compatibility_1800v2017_mode`、`ch36/test_vpi_compatibility_1800v2023_mode` | 36.10.2、36.12.2.1、L.2 | 36.12.2.1はこのモードのシンボルを有効としていて、アプリケーションはスタートアップルーチンから表示します。 | 36.10.2は、そこで二つの登録ルーチンしか認めません。また、L.2に載っているヘッダは、このシンボルではコンパイルできません。 | シミュレーション開始のコールバックから表示します。L.2の問題は、規格の中の食い違いとして記録します。 |
| `ch37/test_vpi_class_relations_scope_typespec` | 37.31 detail 6、8.17 | extendsオブジェクトの`vpiArgument`は、`super.new(v)`の引数を返します。 | extendsオブジェクトはextends節を表し、そこに書いた引数だけを返します。 | どちらの読み方でも返る、extends節に書いた引数を使います。 |
| `ch37/test_vpi_program_interface_relations` | 37.9、37.10 detail 3 | programからは、そのポートにつながるinterfaceが得られ、`vpiInstance`でprogramに戻ります。 | `vpiInstance`は、interfaceを実体化しているインスタンス、つまりmoduleを返します。 | テストをやめるか、両方を認めます。 |
| `gen/ch21/test_gen_cross_litfmt_fill_b_display_param`、`gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65` | 6.20.2、5.7.1 | `localparam P = '1;`は、自己決定の`'1`の1ビットの値を持ちます。 | 6.20.2の最後の項目では、型のないパラメータで値にサイズがなければ、32ビット以上になります。 | 生成器が、そのようなパラメータの幅を固定しないようにします。 |

<a id="vacuous-success-scan"></a>

## 空虚な成功でのpass actionの確認

20.11では、制御タスクで止めない限り、pass actionは空虚な成功でも実行されます。
2回目のレビューは、これを忘れているテストがほかにないかを調べました。
pass actionを持ち、制御タスクを使わないテストのうち、含意を持つものは55本です。内訳は、手書きのテスト19本、disableのモデルの18件、programのアサーションのモデルの18件です。
忘れていたのは、上で直した2本だけでした。
42本は空虚な成功の行を既に期待していて、11本は前件が常に真であるか、pass actionが含意のないアサーションに付いています。

<a id="runs-and-figures"></a>

## 実行と数値

- 変更した21本と、同じ検査グループに入っている1本を、Icarus Verilog 13.0、Verilator 5.052（seed 1と73）、kirimasim `7de185f776a1`で実行しました。結果は`coverage/results/test-fixes-20261112-*.json`です。これまでと同じく、どのシミュレータでも1本も合格しません。固定版はどちらも22 known、kirimasimは22 unsupportedです。変更した21本の`:oracle:`はどれも`spec`だけなので、トークンは変わっていません。
- 要求カバレッジ（テスト設計）は、これまでと同じ90.14%（11,086/12,298）です。18.5.11の要求は種別がerrorで、台帳はこの種別の行に不正な設計のテストしか認めません。テストを実行時のテストにしたので、対応付けをいったん取り下げました（11,085）。所有者の承認を得て、2026-11-09の実行時エラーの要求5件と同じく通常の要求にし、実行時のテストに対応付けました。
- Ghostを除く実行確認率は、50.20%（6,174/12,298）のままです。Ghostとkirimasimの結果を加えると77.57%（9,540/12,298）で、これまでは9,542でした。37.16の要求2件が証跡を失いました。その要求のテスト`ch37/test_vpi_net_bits_constant_select`は、保存済みのGhostの実行で合格していましたが、Cコードを変更したので、その合格は数えられません。Ghostの結果を保存し直せば、また数えられます。
- Verilator 5.052は、直した18.5.11のテストを実行してもエラーを報告しません。Icarus Verilog 13.0は、動的配列の`$increment`に誤った値を返します。どちらも[差異の一覧](simulator-differences.ja.md#icarus-increment-dynamic-20261112)に記録しました。

<a id="open-points"></a>

## 残っている点

- 上の欠陥のあるテスト2本と、解釈が分かれる17本は、判断を待っています。
- 台帳では、37.72のstruct patternからメンバーパターンへのリレーションの行が「1対多」となっています。図は一本の矢印です。直したテストはどちらのアクセスルーチンも認めます。行の文は変更していません。
- 2回目のレビューが本文から導けず、そのままにした期待値が二つあります。open arrayのモデルで`svDimensions`がunpacked次元の数を返すことと、`ch37/test_vpi_constraint_iteration`でNULLルートからの反復が返す制約の数（4）です。
