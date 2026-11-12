<a id="ghost-only-review-ch37-2026-11-13"></a>

# Ghostだけが一致するテストの見直し：37章（2026-11-13）

[English](ghost-only-review-ch37-20261113.en.md) / [日本語](ghost-only-review-ch37-20261113.md)

Ghostだけが期待値と一致し、ほかのどのツールも一致しないテストがあります。
こうしたテストの期待値は、独立に確かめられていません。
この記録は、そのうち37章（VPIのオブジェクトモデル）の193本を、IEEE 1800-2023と照らした結果です。
期待値は規格だけから判定し、シミュレータの出力は判定に使っていません。
この見直しでは、テストを変えていません。

<a id="what-was-reviewed"></a>

## 見直した対象

- 2026-11-12のNightlyで、Ghostだけが一致するテストは756本です。章ごとの本数は、37章が193本、16章が90本、32章が44本、38章が41本、39章が37本、40章が35本、31章が34本です。この記録は37章の193本を扱います。
- 二つのレビューが、互いの結果を見ずに、193本すべてを読みました。それぞれ、設計とCコードから出力を導き、期待出力と比べ、テストごとに判定を一つ付けました。
- 二つの判定が違うテストと、図の矢印に左右されるテストは、規格の図を見て決めました。レビューが使ったテキストでは、図の矢印の向きと本数が分からないためです。
- どのレビューもAIによるものです。人による独立したレビューではありません。

<a id="verdicts"></a>

## 判定

| 判定 | 本数 |
|---|---:|
| 期待値は正しい | 142 |
| 期待値が誤っている | 4 |
| テストに欠陥がある | 26 |
| 規格の不備に依存する | 4 |
| 読み方が割れる | 17 |
| 合計 | 193 |

二つのレビューは、125本で「正しい」と一致しました。
残りの68本のうち17本は、図を確かめた結果、正しいと決まりました。

<a id="wrong"></a>

## 期待値が誤っている4本

4本とも、ネットまたは変数のビットの型を`vpiBitSelect`と期待しています。二つのレビューが一致しました。

| テスト | 節 | 内容 |
|---|---|---|
| `ch37/test_vpi_constant_select` | 37.17、37.58、附属書K | logic変数のビット`v[3]`と`v[i]`の型を`vpiBitSelect`と期待しています。37.17では変数のビットはvar bit（`vpiVarBit`）です。37.58の図で、bit selectの親はvar select、integer var、time var、parameter、spec paramだけです。 |
| `ch37/test_vpi_simple_expr_uses` | 37.16、37.58、附属書K | ベクタネットのビット`v[1]`を`vpiBitSelect`と期待しています。37.16ではnet bit（`vpiNetBit`）です。最後の期待行が変わります。 |
| `ch37/test_vpi_statement_kinds` | 37.16、37.58、37.79 | forceとreleaseの左辺`w[1]`はベクタネットのビットで、net bitです。「bit-select」と表示する2行が変わります。 |
| `ch37/test_vpi_systf_argument_expressions` | 37.17、37.58、附属書K | `reg [7:0] r`のビット`r[1]`と`r[0]`はvar bit（`vpiRegBit`）です。`vpiBitSelect`と表示する2行が変わります。同じ章の`test_vpi_type_strings`は`r[2]`に`vpiRegBit`を期待しています。 |

<a id="flawed"></a>

## 欠陥がある26本

期待値の多くは規格のとおりですが、テストが規格で決まらないことに依存しているか、Cコードや設計が規格に沿っていません。

| テスト | 節 | 内容 |
|---|---|---|
| `ch37/test_vpi_case_loop_force_stmts` | 37.12、37.72 | ブロックの`vpiStmt`と`vpiCaseItem`の反復の結果を、並べ替えずに表示しています。規格はどちらの順序も定めていません。 |
| `ch37/test_vpi_prefix_has_actual` | 37.12、37.61 | 各行の順序が、並べ替えていない`vpiStmt`の反復の順序に依存します。値は正しいです。 |
| `ch37/test_vpi_property_sequence_exprs` | 37.56 | `vpiClockedSeq`の反復の結果を並べ替えずに表示しています。37.56は順序を定めていません。 |
| `ch37/test_vpi_class_internal_scopes` | 38.11、37.41 | `vpi_get_str`の結果を2つ、1回の呼出しの引数にしています。38.11では結果は1つのバッファに入ります。また、メソッドのスコープから`vpiClassTypespec`を引いていますが、37.41の図にその関係はありません。 |
| `ch37/test_vpi_interconnect_net_typespec` | 38.11 | `vpi_get_str`の結果を複数、1回の`vpi_printf`の引数にしています。オブジェクトモデルの期待値は37.24のとおりです。 |
| `ch37/test_vpi_io_direction_undefined` | 38.11、37.13 | `vpi_get_str`の結果を2つ、1回の呼出しの引数にしています。なお、37.13の詳細3の「undefined」を`vpiUndefined`（-1）と読むかどうかも割れます。 |
| `ch37/test_vpi_local_connectivity_ports` | 38.11、37.16 | `vpi_get_str`の結果を2つ、1回の呼出しの引数にしています。集合の内容は37.16の詳細17のとおりです。 |
| `ch37/test_vpi_frame_automatics_thread` | 37.43、37.44、38.11 | スレッドの`vpiOrigin`を実行中の文と期待していますが、37.44はその意味を定めていません。スコープでないinitialのブロックに親フレームを期待しています。`vpi_get_str`の結果を2つ同時に使っています。 |
| `ch37/test_vpi_relationships_and_tags` | 38.15 | `vpi_get_value`で得た文字列を、そのあとの`vpi_get_value`の呼出しのあとで表示しています。38.15では文字列のバッファは呼出しごとに上書きされます。 |
| `ch37/test_vpi_class_obj_id` | 38.6、38.7、37.32 | `vpiObjId`は64ビットのプロパティですが、`vpi_get`で読んでいます。特殊化のclass typespecの名前（ツール依存、37.32の詳細4）を表示しています。 |
| `ch37/test_vpi_class_definitions` | 37.32 | extendsから得たclass typespecの名前を`shape`と期待しています。この名前は規格で固定されていません（軽微）。 |
| `ch37/test_vpi_cont_assign_rhs_and_load` | 37.47 | スカラの連続代入に`vpiBit`の反復が1つ返ると期待しています。規格がビットを定めるのはベクタの代入だけです。cont assign bitに`vpiSize`を使っていますが、図にありません。 |
| `ch37/test_vpi_control_statement_child_relations` | 37.73、37.50 | expect文のプロパティを`vpiProperty`で引いています。37.73の関係にタグはなく、アクセスは`vpiPropertySpec`です。 |
| `ch37/test_vpi_handle_release_independence` | 38.36.1 | `cbValueChange`を、時刻の構造体を指定せずに登録しています。38.36.1は時刻の型の指定を求めています。 |
| `ch37/test_vpi_frames_threads_alloc` | 38.36.1 | `cbCreateObj`と`cbEndOfObject`を、値の構造体を指定せずに登録しています（軽微）。期待値は規格のとおりです。 |
| `ch37/test_vpi_net_array_members_parents` | 37.16 | `vpiPackedArrayMember`を、array net、logic net、integer netでも読み、0を期待しています。37.16の詳細2が定めるのは、packed配列の中の要素についてだけです。 |
| `ch37/test_vpi_ref_obj_actual_port_insts` | 37.14、37.10 | ポートに`vpiParent`を使ってインスタンスを得ています。37.14の`vpiParent`はport bitからportへの関係です。モジュールから`vpiTask`で反復していますが、37.10の関係はtask funcです。 |
| `ch37/test_vpi_scope_lifetimes` | 37.32、37.10 | class defnから`vpiClassTypespec`を`vpi_handle`で引いています。37.32の詳細10では反復です。パッケージを`::`なしの名前で探しています。 |
| `ch37/test_vpi_interface_modport_links` | 37.8 | interface tf declから`vpiTask`を`vpi_handle`で引いています。37.8の図は一対多で、`vpi_iterate`を使います。 |
| `ch37/test_vpi_interface_program` | 37.8、37.13 | 同じく`vpiTask`と`vpiFunction`を`vpi_handle`で引いています。modportのimport・exportがio declに含まれるかどうかも、37.13から決まりません。 |
| `ch37/test_vpi_system_call_decompile` | 37.42、37.59 | `vpiDecompile`の文字列を定数の書き方まで照合しています。規格が求めるのは機能的に等価な文字列で、定数の表記は定めていません。 |
| `ch37/test_vpi_variable_driver_load_arrays` | 10.6.2、37.21 | 変数のビット選択にforceを使っています（10.6.2が禁じています）。配列の行は37.21の詳細2の「should」に依存します。 |
| `ch37/test_vpi_property_instance_links` | 16.16 | アサーション`a2`にクロックがなく、default clockingも推論されるクロックもありません。16.16の規則fにより、設計が不正です。 |
| `ch37/test_vpi_module_relations` | 附属書E | `` `default_decay_time``を使っています。附属書Eは参考で、その指示文は規格の一部ではありません。 |
| `ch37/test_vpi_root_lookup_restrictions` | 37.10、26.7 | NULLからの`vpiInstance`の反復の件数を2と期待しています。組込みパッケージ`std`が含まれるかどうかを、規格は定めていません。 |
| `ch37/test_vpi_let_decl_body` | 37.57、37.58 | let本体の中の仮引数の参照に`vpiName`を期待しています。その参照がどのオブジェクトになるかを、規格は定めていません。 |

`vpi_get_str`の結果を2つ以上、1回の呼出しで使うCコードは、37章のほかのテストにもあります。
粗い検索では、37章のCファイル29本が該当しました。この29本は、次の見直しで確かめます。

<a id="standard-gap"></a>

## 規格の不備に依存する4本

37.10の図と詳細10、37.85の詳細6は、nettypeの宣言への反復を`vpiNetTypedef`というタグで示しています。
しかし、附属書Mのヘッダにこの定数がありません。あるのは`vpiNettypeDecl`と`vpiNetTypedefAlias`です。
次の4本は、代わりに`vpiNettypeDecl`で反復しています。この反復を規格は定めていません。
宣言に到達したあとの期待値は、37.23のとおりです。

- `ch37/test_vpi_nettype_declarations`
- `ch37/test_vpi_nettype_alias_chain_relations`
- `ch37/test_vpi_nettype_relations`
- `ch37/test_vpi_generate_nettype_typedef`

<a id="contested"></a>

## 読み方が割れる17本

規格の文が二つの読み方を許し、期待値はその一方に従っています。

| テスト | 節 | 割れる点 |
|---|---|---|
| `ch37/test_vpi_atomic_task_call_label` | 37.60、37.42 | 37.60の詳細1は、文の`vpiName`をラベルとします。37.42の図は、tf callに呼び出す名前の`vpiName`を置いています。 |
| `ch37/test_vpi_cont_assign_bits_delays` | 37.3.4、37.16 | 37.3.4の文はネットに`vpiDelay`を認めます。37.16の図には`vpiDelay`の関係がありません。 |
| `ch37/test_vpi_module_paths` | 37.39、附属書K | `vpiModPathHasIfNone`が真になるのが、ifnoneで宣言したパスか、ifnoneの既定を持つ条件付きパスか、決まりません。 |
| `ch37/test_vpi_prefix_allocation` | 37.61、37.3.7 | 37.61の詳細2はプレフィックスと同じ方式とし、37.3.7はクラスオブジェクトの一部を動的とします。テストのコメントもこの食い違いを記しています。 |
| `ch37/test_vpi_size_change_callback` | 37.17 | サイズ変更のコールバックの中で、文字列がまだ古い値かどうかが、37.17の詳細14から決まりません。 |
| `ch37/test_vpi_unbounded_const_ranges` | 37.52、A.2.10 | 先頭のクロックがproperty specに属するか、clocked propertyになるかで、最後の1行が変わります。 |
| `ch37/test_vpi_property_operator_kinds` | 37.52、A.2.10 | 同じ理由で、`p_clk`と`p_clk2`の2行が変わります。 |
| `ch37/test_vpi_attribute_value_types` | 5.12、38.15 | 文字列リテラルの属性の`vpiObjTypeVal`が、ベクタか文字列かで割れます。 |
| `ch37/test_vpi_interconnect_array_ranges` | 23.3.3.7.1、6.6.8 | どこにも接続しないinterconnectの配列が合法かどうかが割れます。 |
| `ch37/test_vpi_iterator_objects` | 37.2.2、38.38、38.40 | 最後のオブジェクトを返したあとの反復子がまだ有効かどうかで、解放の結果が変わります。 |
| `ch37/test_vpi_named_event_relations` | 37.27 | named eventの配列要素のフルネームに添字が入ることを、37.27は述べていません。ネットと変数には規定があります。 |
| `ch37/test_vpi_named_events` | 37.27 | 同じ理由で、要素の`vpiName`の`lane[1]`が決まりません。 |
| `ch37/test_vpi_net_driver_objects` | 37.16、37.47 | ネットのビットのドライバが、cont assign bitか、連続代入全体かが決まりません。 |
| `ch37/test_vpi_nettype_net_parts` | 37.16 | nettypeのネットの配列要素が`vpiNettypeNet`か`vpiNettypeNetSelect`かが、詳細11から決まりません。 |
| `ch37/test_vpi_select_objects_event_arrays` | 37.17、37.19 | 配列変数の要素がvar selectか、その型の変数かが、37.17の詳細7・18・26で割れます。 |
| `ch37/test_vpi_statement_control_kinds` | 37.60、9.3.5 | ラベル付きの文がそのままの文か、名前付きブロックになるかで、3行が変わります。 |
| `ch37/test_vpi_tf_call_kinds_relations` | 37.42、15.4 | mailboxのメソッドを組込みと見るか、パッケージ`std`のクラスの宣言されたメソッドと見るかで、1行が変わります。 |

<a id="figures"></a>

## 図で確かめたこと

次のテストは、どちらかのレビューが判定を保留または欠陥としました。図に関係が描かれているので、期待値は正しいと決めました。

| テスト（`ch37/test_vpi_`を省略） | 節 | 図に描かれていること |
|---|---|---|
| module_instance_relations、program_relations | 37.6、37.9 | instance arrayからinterface・programへ二重矢印があり、`vpiInterface`・`vpiProgram`で反復できます。 |
| gen_scope_data_items、gen_scope_instance_items | 37.85 | 各項目からgen scopeへ戻る矢印があります。 |
| scope_item_back_relations、process_kinds_relations | 37.12、37.63 | 各項目と文からscopeへ、文からprocessへ戻る矢印があります。 |
| typespec_instance_ranges、typespec_kinds_more | 37.25 | instanceからtypespecへの二重矢印と、enum constからenum typespecへ戻る矢印があります。 |
| constraint_expr_contents | 37.34 | dist itemからdistributionへ戻る矢印があります。 |
| tchk_relations_path_delays | 37.40 | tchk termからtchkへ戻る矢印があります。 |
| thread_parent_children_frame | 37.44 | threadとframeは一対一で、円からthreadへの二重矢印があります。 |
| clocking_decl_relations、clocking_edges_prefix | 37.48 | 各宣言からclocking blockへ戻る矢印があり、io declの`vpiOutputSkew`の先はexprです。 |
| virtual_interface_init_parent | 37.30 | param assignからinterface typespecへ戻る矢印があります。 |
| constraint_properties | 37.31 | 円からclass defnへの二重矢印があり、NULLから反復できます。 |
| union_net_tagged、struct_union_net_flags | 37.26 | taggedとsoftは、struct netとunion netを囲む枠の中にあります。 |

<a id="next"></a>

## このあとの扱い

- 誤りの4本と欠陥の26本は、次にGhostの結果を保存し直すときに直します。いま直すと、Ghostの保存済みの一致が数えられなくなるためです。
- 規格の不備の4本と、読み方が割れる17本は、判断を待ちます。
- 引用の節番号が違うテストが数本あります（連続代入を37.75、プリミティブを37.80とするものなど。正しくは37.47と37.35）。上の修正と一緒に直します。
- カバレッジの数字は変わりません。
