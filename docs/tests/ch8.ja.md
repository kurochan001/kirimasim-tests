<a id="clause-8-classes"></a>

# 8 条項: クラス

[English](ch8.md) / [日本語](ch8.ja.md)

[すべての章](README.ja.md) .411 90 のテストを生成した。テストのメタデータから `tools/suite_catalog.py` がこのページを書きました。テストを編集しろ このページじゃない

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_class_handle_argument_directions`](../../tests/ch8/test_class_handle_argument_directions.sv) |クラス変数はオブジェクトのハンドルを持ち、プロパティとメソッドを持ち、オブジェクトが入力、出力、inout、refの引数として渡されると、そのハンドルを渡す。オブジェクトのコピーではありません。| 8.2 6.15 | Verilator 5.052 ||
| [`test_class_objects_handles_and_polymorphism`](../../tests/ch8/test_class_objects_handles_and_polymorphism.sv) |クラスオブジェクトは動的に生成され、ハンドルを通してアクセスされ、オーバーライドはベースハンドルを通じて送信され、構造変数はクラスハンドルと異なります。| 8.2 8.4 8.28 | Verilator 5.052 ||
| [`test_class_objects_in_array_of_handles`](../../tests/ch8/test_class_objects_in_array_of_handles.sv) |クラス変数は null で始まり、 new でランタイムで作成されたオブジェクトのハンドルを持つ。ハンドルをコピーすると オブジェクトを共有し メソッドはハンドルを通して呼び出されます| 8.2 6.15 | Verilator 5.052 ||
| [`test_class_array_property_nonzero_range`](../../tests/ch8/test_class_array_property_nonzero_range.sv) |クラスの固定サイズ配列プロパティは、0 から始まらない範囲のすべての要素を保持します。| 8.3 7.4.5 20.7 | Verilator 5.052 ||
| [`test_class_basics`](../../tests/ch8/test_class_basics.sv) |章8：クラス| 8.3 8.4 8.12 | Icarus Verilog 13.0 ||
| [`test_class_declaration_grammar_forms`](../../tests/ch8/test_class_declaration_grammar_forms.sv) |クラス構文はパラメータ付き仮想クラスと最終クラス、構造子引数付き拡張、実装リストと終了ラベル、各種クラスの項目とその定義子、クラス内外で宣言された構造子とその前の宣言、メソッドとプロトタイプの:initial、:extends、:finalの指定子を認めます。| 8.3 8.17 8.20 8.24 8.26 | Verilator 5.052 ||
| [`test_class_item_qualifiers_and_constraints`](../../tests/ch8/test_class_item_qualifiers_and_constraints.sv) |許可される各種修飾子を1つずつ付けた、識別子で参照するクラス項目。local randプロパティとrandcプロパティ、constプロパティ、staticプロパティ、static制約、派生クラスでオーバーライドするvirtualメソッド、および仮想クラスで宣言して派生クラスで定義するpure virtualメソッドを含む。括弧付きの配列組み込みメソッド呼出しを対象とする制約も含めて乱数化します。また、nullは定数一次式です。| 8.3 8.6 8.8 8.21 18.5 18.7 A.9.3 A.8.4 A.10 | Verilator 5.052 ||
| [`test_illegal_class_method_virtual_twice`](../../tests/ch8/test_illegal_class_method_virtual_twice.sv) |仮想限定符はクラスメソッド宣言に一度しか現れません| 8.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_class_property_protected_and_local`](../../tests/ch8/test_illegal_class_property_protected_and_local.sv) |クラスプロパティ宣言は 保護された限定詞と ローカル限定詞を両方持つことはできません| 8.3 |標準のみ|違法なデザインだ|
| [`test_illegal_class_property_rand_and_randc`](../../tests/ch8/test_illegal_class_property_rand_and_randc.sv) |クラスプロパティ宣言は rand と randc 限定詞を両方持つことはできません| 8.3 |標準のみ|違法なデザインだ|
| [`test_illegal_class_property_static_twice`](../../tests/ch8/test_illegal_class_property_static_twice.sv) |静的限定語はクラスのプロパティ宣言に一度しか現れません| 8.3 |標準のみ|違法なデザインだ|
| [`test_illegal_constructor_default_twice`](../../tests/ch8/test_illegal_constructor_default_twice.sv) |デフォルトキーワードはクラス構造子引数リストに 1回しか出現できません| 8.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_override_specifier_in_interface_class`](../../tests/ch8/test_illegal_override_specifier_in_interface_class.sv) |:initial のような動的なオバーライド指定子はインターフェースクラスのメソッドに許可されていません。| 8.3 |標準のみ|違法なデザインだ|
| [`test_illegal_override_specifier_outside_class`](../../tests/ch8/test_illegal_override_specifier_outside_class.sv) |:final のような動的なオバーライド指定子は クラスの外で宣言された関数には許可されません| 8.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_pure_constraint_final`](../../tests/ch8/test_illegal_pure_constraint_final.sv) |純粋な制約は最終的な特定者で宣言できません| 8.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_pure_virtual_method_final`](../../tests/ch8/test_illegal_pure_virtual_method_final.sv) |純粋な仮想メソッドは最終仕様で宣言できません| 8.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_syntax_class_and_interface_class_headers`](../../tests/ch8/test_syntax_class_and_interface_class_headers.sv) |クラスヘッダには最終指定子、パラメータポートリスト、構造子引数と実装リストで拡張される、インタフェースクラスヘッダはパラメータポ ートリスト、インタフェースのクラスタイプの拡張リスト、typedef , localparam、パラメータ、空で属性付きの純粋仮想アイテムが含まれます。| 8.3 8.13 8.26.1 A.1.2 A.1.9 | Verilator 5.052 ||
| [`test_block_scoped_class_handles`](../../tests/ch8/test_block_scoped_class_handles.sv) |クラスハンドルは始点ブロックで宣言され、1つはモジュールレベルのハンドルを隠します。| 8.4 23.9 9.3.1 | Icarus Verilog 13.0 ||
| [`test_class_basic`](../../tests/ch8/test_class_basic.sv) |クラス基礎テスト| 8.4 8.6 | Icarus Verilog 13.0 ||
| [`test_class_basic_2`](../../tests/ch8/test_class_basic_2.sv) |クラス構造子、属性とメソッド、独立したインスタンス| 8.4 8.7 | Icarus Verilog 13.0 ||
| [`test_class_basic_edge_cases`](../../tests/ch8/test_class_basic_edge_cases.sv) |クラス基本エッジケース| 8.4 8.6 8.7 | Icarus Verilog 13.0 ||
| [`test_class_compare`](../../tests/ch8/test_class_compare.sv) |テスト:クラス比較| 8.4 8.5 8.6 | Verilator 5.052 ||
| [`test_class_component_tree`](../../tests/ch8/test_class_component_tree.sv) |親から階層的な名前を構築するクラスオブジェクトの木| 8.4 8.5 7.10 | Verilator 5.052 ||
| [`test_class_edge`](../../tests/ch8/test_class_edge.sv) |クラス：構成、メソッド、ローカルメンバー、継承| 8.4 8.6 8.13 8.18 | Icarus Verilog 13.0 ||
| [`test_class_enum_property_accessors`](../../tests/ch8/test_class_enum_property_accessors.sv) |64 - bitベクトルの固定サイズのバイト配列を持つオブジェクトのメソッドは，その属性を読み書きし，任意の順序で明示的な値を持つエナジーは，intに変換すると符号を保持する。| 8.4 8.5 8.6 6.19 7.4 | Verilator 5.052 ||
| [`test_class_handle_alias_and_polymorphism`](../../tests/ch8/test_class_handle_alias_and_polymorphism.sv) |クラスハンドルは共有オブジェクトを参照し、アイデンティティで比較し、抽象的なベースを通して仮想的に送信し、ダウンキャストをサポートします。| 8.4 8.28 | Verilator 5.052 ||
| [`test_class_handle_arrays_lookup`](../../tests/ch8/test_class_handle_arrays_lookup.sv) |2つのコンテナがクラスハンドルの固定サイズ配列に保持するオブジェクトは、コピーされず共有される。文字列プロパティの比較で見つけられ、一方のコンテナのメソッドによる変更は他方にも見える| 8.4 8.7 7.4 6.16 | Verilator 5.052 ||
| [`test_class_handle_default_null_and_case_equality`](../../tests/ch8/test_class_handle_default_null_and_case_equality.sv) |クラスハンドルとチャンドルは null で始まります。 and === と!== は同じオブジェクトに対して as == と!= を返します。同じ内容の異なるオブジェクトと null は同じ結果を返します。| 8.4 6.14 | Verilator 5.052 ||
| [`test_class_null_comparison`](../../tests/ch8/test_class_null_comparison.sv) |クラスハンドル: デフォルトは null で、null と比較して代入によってコピーされます。| 8.4 8.12 | Icarus Verilog 13.0 ||
| [`test_class_null_handle`](../../tests/ch8/test_class_null_handle.sv) |テスト: ヌルハンドル検出 (使用前にハンドルがヌルかどうかチェック)| 8.4 | Verilator 5.052 ||
| [`test_class_object`](../../tests/ch8/test_class_object.sv) |テストクラスオブジェクト| 8.4 8.7 | Icarus Verilog 13.0 ||
| [`test_class_prop_assign`](../../tests/ch8/test_class_prop_assign.sv) |テスト：クラスのプロパティへの代入| 8.4 8.5 8.9 | Verilator 5.052 ||
| [`test_class_register_block`](../../tests/ch8/test_class_register_block.sv) |レジスタのブロックをモデル化するクラス。読み込み、書き込み、リセット| 8.4 8.5 12.5 | Verilator 5.052 ||
| [`test_class_simple`](../../tests/ch8/test_class_simple.sv) |クラス単純テスト| 8.4 8.6 | Icarus Verilog 13.0 ||
| [`test_edge_case_classes`](../../tests/ch8/test_edge_case_classes.sv) |クラス演算のコーナーケーステスト| 8.4 8.9 8.16 8.20 | Verilator 5.052 ||
| [`test_edge_class_null_handle`](../../tests/ch8/test_edge_class_null_handle.sv) |クラスハンドルと null| 8.4 8.8 | Icarus Verilog 13.0 ||
| [`test_illegal_chandle_dereference`](../../tests/ch8/test_illegal_chandle_dereference.sv) |チャンドルはクラスハンドルとして 参照できません| 8.4 |標準のみ|違法なデザインだ|
| [`test_illegal_chandle_increment`](../../tests/ch8/test_illegal_chandle_increment.sv) |チャンドルはCポインタのように増加できません| 8.4 |標準のみ|違法なデザインだ|
| [`test_illegal_class_handle_assigned_unrelated_class`](../../tests/ch8/test_illegal_class_handle_assigned_unrelated_class.sv) |クラスのオブジェクトを指定するには、 クラスのオプションを指定する必要があります。関連のないクラスのオブジェクトはエラーです| 8.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_class_handle_equality_unrelated_classes`](../../tests/ch8/test_illegal_class_handle_equality_unrelated_classes.sv) |with == と比較したハンドルは、 それぞれのクラスが他のクラスと代入が互換性のあるクラスでなければなりません。関係のないクラスのハンドルは比較できません| 8.4 |標準のみ|違法なデザインだ|
| [`test_illegal_class_handle_equality_with_int`](../../tests/ch8/test_illegal_class_handle_equality_with_int.sv) |クラスオブジェクトと比較するときは、 with == を使って int ではなく、他のクラスオブジェクトまたは null と比較する必要があります。| 8.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_class_handle_increment`](../../tests/ch8/test_illegal_class_handle_increment.sv) |オブジェクトハンドルは C ポインタのように増加できません| 8.4 |標準のみ|違法なデザインだ|
| [`test_illegal_class_handle_relational_operator`](../../tests/ch8/test_illegal_class_handle_relational_operator.sv) |関係演算子 &lt; はオブジェクトハンドルに有効な演算子の一つではありません| 8.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_handle_arithmetic`](../../tests/ch8/test_illegal_handle_arithmetic.sv) |オブジェクトハンドルは増分のような算術演算をサポートしていません| 8.4 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_handle_cast_to_chandle`](../../tests/ch8/test_illegal_handle_cast_to_chandle.sv) |クラスオブジェクトハンドルはチャンドルにキャストできません| 8.4 |標準のみ|違法なデザインだ|
| [`test_illegal_unrelated_handle_compare`](../../tests/ch8/test_illegal_unrelated_handle_compare.sv) |関連のないクラスのオブジェクトハンドルは 等しさのために比較できません| 8.4 |標準のみ|違法なデザインだ|
| [`test_member_access_chain`](../../tests/ch8/test_member_access_chain.sv) |テスト連鎖メンバーアクセス| 8.4 7.2.1 | Verilator 5.052 ||
| [`test_member_access_class`](../../tests/ch8/test_member_access_class.sv) |クラスメンバーアクセスのテスト| 8.4 8.5 8.6 | Verilator 5.052 ||
| [`test_nested_member_access_2`](../../tests/ch8/test_nested_member_access_2.sv) |ネストされたメンバーアクセスのテスト| 8.4 8.5 8.6 | Verilator 5.052 ||
| [`test_null_check`](../../tests/ch8/test_null_check.sv) |ヌルオブジェクトの扱いテスト| 8.4 | Verilator 5.052 ||
| [`test_null_empty_corner`](../../tests/ch8/test_null_empty_corner.sv) |空の配列、デフォルト値、nullハンドルをテストします。| 8.4 7.5 7.10 7.8 6.16 | Verilator 5.052 ||
| [`test_null_expr`](../../tests/ch8/test_null_expr.sv) |テスト null 表現| 8.4 | Icarus Verilog 13.0 ||
| [`test_null_handle`](../../tests/ch8/test_null_handle.sv) |ヌルクラスハンドル操作エッジケース| 8.4 8.15 | Verilator 5.052 ||
| [`test_class_enum_and_parameters_via_handle_and_scope`](../../tests/ch8/test_class_enum_and_parameters_via_handle_and_scope.sv) |enum 定数はクラスのスコープと同様にオブジェクトハンドルを通して到達されます。クラスパラメータとローカルパラメータはハンドルを通じて公開され読み取れます。クラススコープを通じて定数表現となります。| 8.5 8.18 8.23 | Verilator 5.052 ||
| [`test_class_member_access`](../../tests/ch8/test_class_member_access.sv) |IEEE 1800-2023 § 8 のテスト: クラスメンバーアクセス| 8.5 8.6 8.13 | Icarus Verilog 13.0 ||
| [`test_class_prop`](../../tests/ch8/test_class_prop.sv) |クラスのプロパティテスト| 8.5 8.7 | Icarus Verilog 13.0 ||
| [`test_class_property`](../../tests/ch8/test_class_property.sv) |テストクラスのプロパティ| 8.5 8.18 | Icarus Verilog 13.0 ||
| [`test_class_scope`](../../tests/ch8/test_class_scope.sv) |テストクラスメソッドの範囲| 8.5 8.9 8.10 8.20 8.23 | Verilator 5.052 ||
| [`test_illegal_type_parameter_through_class_handle`](../../tests/ch8/test_illegal_type_parameter_through_class_handle.sv) |クラスのタイプパラメータはクラスハンドルを通じて アクセスできませんが、値パラメータは| 8.5 8.25 | Verilator 5.052 |違法なデザインだ|
| [`test_nested_member_access`](../../tests/ch8/test_nested_member_access.sv) |テストケース: ネストされたクラスメンバーアクセス| 8.5 8.4 | Verilator 5.052 ||
| [`test_syntax_class_item_kinds`](../../tests/ch8/test_syntax_class_item_kinds.sv) |属性、メソッド、制約、ネストされたクラス、インタフェースクラス、covergroup の前に属性を持つクラス項目;プロパティは、rand、randc、static、protected、local、const、parameter、localparam で構成されます。両方の形態の制約を外部制約ブロックで完成した制約プロトタイプ| 8.5 8.6 8.18 18.5 18.5.1 A.1.9 | Verilator 5.052 ||
| [`test_class_method`](../../tests/ch8/test_class_method.sv) |クラスメソッドは、デフォルトの構成引数を持って、プロパティを読み込み変更します。| 8.6 8.7 | Icarus Verilog 13.0 ||
| [`test_class_method_2`](../../tests/ch8/test_class_method_2.sv) |クラスメソッドテスト| 8.6 | Icarus Verilog 13.0 ||
| [`test_class_method_calls`](../../tests/ch8/test_class_method_calls.sv) |クラスメソッドテスト| 8.6 | Icarus Verilog 13.0 ||
| [`test_class_method_control_flow`](../../tests/ch8/test_class_method_control_flow.sv) |ループ、ネスト if-else、case ステートメントから返すクラスメソッド| 8.6 13.4.1 12.8 | Icarus Verilog 13.0 ||
| [`test_class_methods`](../../tests/ch8/test_class_methods.sv) |クラスメソッド、構造子デフォルト引数、継承メソッド| 8.6 8.7 8.13 | Icarus Verilog 13.0 ||
| [`test_class_methods_2`](../../tests/ch8/test_class_methods_2.sv) |クラスのインスタンス化、メソッド、構造化をテスト| 8.6 8.7 | Verilator 5.052 ||
| [`test_illegal_class_method_static_lifetime`](../../tests/ch8/test_illegal_class_method_static_lifetime.sv) |静的なメソッドとは異なり 静的な寿命を持つクラスメソッドは宣言できません| 8.6 8.10 | Verilator 5.052 |違法なデザインだ|
| [`test_method_class`](../../tests/ch8/test_method_class.sv) |クラスメソッドテスト| 8.6 8.7 13.5.3 | Icarus Verilog 13.0 ||
| [`test_syntax_class_method_kinds`](../../tests/ch8/test_syntax_class_method_kinds.sv) |task、function、コンストラクタの前にメソッド修飾子を付けたクラスメソッド。ブロック項目宣言、super.new呼出し、終了ラベルを持つコンストラクタ宣言、クラス外で定義を完成させるコンストラクタプロトタイプ、ブロック外で定義するexternのtask／functionプロトタイプ、および派生クラスで実装するpure virtualのtask／functionプロトタイプを含む。| 8.6 8.7 8.14 8.21 8.24 A.1.9 | Verilator 5.052 ||
| [`test_class_construct`](../../tests/ch8/test_class_construct.sv) |クラスコンストラクタテスト| 8.7 | Icarus Verilog 13.0 ||
| [`test_class_constructor_this_and_super_order`](../../tests/ch8/test_class_constructor_this_and_super_order.sv) |これは現在のオブジェクトのプロパティを選択し、 super.new はサブクラスのボディの前に実行され、コンストラクタはシミュレーション時間を消費しません。| 8.7 8.11 8.15 8.17 | Icarus Verilog 13.0 ||
| [`test_class_local_and_protected_constructors`](../../tests/ch8/test_class_local_and_protected_constructors.sv) |コンストラクタをlocalとして宣言すると、そのクラスのstaticメソッドから呼び出せる。protectedとして宣言すると、派生クラスのコンストラクタからsuper.newで呼び出せる。| 8.7 8.18 | Verilator 5.052 ||
| [`test_class_new`](../../tests/ch8/test_class_new.sv) |クラスコンストラクタテスト| 8.7 13.5.3 | Verilator 5.052 ||
| [`test_class_new_args`](../../tests/ch8/test_class_new_args.sv) |テスト: 様々な引数タイプを持つクラス構造子| 8.7 13.5.3 | Verilator 5.052 ||
| [`test_class_property_init_after_base_constructor`](../../tests/ch8/test_class_property_init_after_base_constructor.sv) |クラスのプロパティは、ベース構造子が返ってきて、 構造子の残りが実行される前に、 宣言された初期値またはデフォルト値を取得します。| 8.7 8.15 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_static_constructor`](../../tests/ch8/test_illegal_static_constructor.sv) |コンストラクタは静的に宣言できません| 8.7 8.10 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_virtual_constructor`](../../tests/ch8/test_illegal_virtual_constructor.sv) |コンストラクタは仮想的に宣言できません| 8.7 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_property_initializer_after_super_new`](../../tests/ch8/test_property_initializer_after_super_new.sv) |派生クラスのプロパティの初期化子は、ベースクラスの構造子の後で、派生クラスの構造者の残りの部分の前で実行されます。| 8.7 8.17 | Icarus Verilog 13.0 ||
| [`test_syntax_class_new_assignment_targets`](../../tests/ch8/test_syntax_class_new_assignment_targets.sv) |クラス new の代入を プレーンハンドル、this.メンバー、クラススコープの静的メンバー、パッケージスコープの変数、選択された配列要素にブロックします。 new(args)、タイプされた D::new (args)、浅いコピー new h を使用します。| 8.7 8.8 8.9 8.11 8.12 A.6.2 | Verilator 5.052 ||
| [`test_a1_9_constructor_arguments_and_parameter_class_item`](../../tests/ch8/test_a1_9_constructor_arguments_and_parameter_class_item.sv) |クラス構造子はコンマで区切られた tf-port 項目をデフォルト値で受け取り、クラスのパラメータ宣言は localparam である。| 8.8 8.25 A.1.9 A.10 | Verilator 5.052 ||
| [`test_class_typed_constructor_forms_and_specializations`](../../tests/ch8/test_class_typed_constructor_forms_and_specializations.sv) |構造子コールはオプションの引数を持ち、そのクラスのオブジェクトを構築するためのクラスの範囲が前にある。またはパラメータ化されたクラスの特化のための表現が続く。| 8.8 8.12 8.25.1 | Verilator 5.052 ||
| [`test_illegal_shallow_copy_of_non_handle`](../../tests/ch8/test_illegal_shallow_copy_of_non_handle.sv) |浅いコピーの new の後の表現は オブジェクトハンドルでなければなりません| 8.8 8.12 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_typed_new_not_assignment_compatible`](../../tests/ch8/test_illegal_typed_new_not_assignment_compatible.sv) |タイプされたコンストラクタコールのクラスは ターゲットとの代入が互換性がある必要があります| 8.8 8.16 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_typed_constructor_into_base_handle`](../../tests/ch8/test_typed_constructor_into_base_handle.sv) |型付けされた構造子は、ベースハンドルに直接派生オブジェクトをビルドします。| 8.8 | Verilator 5.052 ||
| [`test_class_scope_access`](../../tests/ch8/test_class_scope_access.sv) |静的クラス属性テスト| 8.9 8.10 8.23 | Verilator 5.052 ||
| [`test_class_singleton`](../../tests/ch8/test_class_singleton.sv) |テスト: シングルトンパターン| 8.9 8.10 8.7 | Verilator 5.052 ||
| [`test_class_static`](../../tests/ch8/test_class_static.sv) |構成されたオブジェクトを数える静的クラスプロパティ、静的メソッドを通して読み込む| 8.9 8.10 | Verilator 5.052 ||
| [`test_class_static_2`](../../tests/ch8/test_class_static_2.sv) |テスト：staticプロパティ、staticメソッド、インスタンス間の共有状態| 8.9 8.10 | Verilator 5.052 ||
| [`test_class_static_corner`](../../tests/ch8/test_class_static_corner.sv) |静的な属性、メソッド、クラスレベルの状態をテスト| 8.9 8.10 8.23 | Verilator 5.052 ||
| [`test_class_static_members`](../../tests/ch8/test_class_static_members.sv) |静的クラス属性テスト| 8.9 8.10 | Icarus Verilog 13.0 ||
| [`test_foreach_static_members`](../../tests/ch8/test_foreach_static_members.sv) |静的キュー、動的配列、連想配列メンバーを通しての反復テスト| 8.9 8.10 12.7.3 7.10 7.8 | Verilator 5.052 ||
| [`test_class_factory`](../../tests/ch8/test_class_factory.sv) |テスト: 工場パターン| 8.10 8.21 8.20 | Verilator 5.052 ||
| [`test_class_static_method`](../../tests/ch8/test_class_static_method.sv) |テスト: 静的クラスメソッド| 8.10 8.9 | Verilator 5.052 ||
| [`test_illegal_static_method_uses_property`](../../tests/ch8/test_illegal_static_method_uses_property.sv) |静的メソッドはそのクラスの非静的なプロパティを使用できません。| 8.10 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_static_virtual_method`](../../tests/ch8/test_illegal_static_virtual_method.sv) |静的クラスメソッドは仮想的に宣言できません| 8.10 | Verilator 5.052 |違法なデザインだ|
| [`test_method_static`](../../tests/ch8/test_method_static.sv) |静的手法テスト| 8.10 8.9 | Verilator 5.052 ||
| [`test_static_method_through_null_handle`](../../tests/ch8/test_static_method_through_null_handle.sv) |静的メソッドと静的プロパティは、 null のクラスハンドルを通して使用できます。| 8.10 8.9 8.4 | Verilator 5.052 ||
| [`test_class_this`](../../tests/ch8/test_class_this.sv) |テスト: このキーワードの使用| 8.11 8.4 | Verilator 5.052 ||
| [`test_class_this_selects_invoking_object_members`](../../tests/ch8/test_class_this_selects_invoking_object_members.sv) |これはメソッドが呼び出されたオブジェクトのハンドルであり、 this.name は引数またはローカル変数が同じ名前のとき、そのオブジェクトのプロパティ、値パラメータまたはメソッドを選択します。| 8.11 8.5 | Verilator 5.052 ||
| [`test_class_this_super`](../../tests/ch8/test_class_this_super.sv) |これとスーパーキーワードは| 8.11 8.15 | Verilator 5.052 ||
| [`test_illegal_this_in_static_method`](../../tests/ch8/test_illegal_this_in_static_method.sv) |このハンドルは静的なクラスメソッドでは使えません| 8.11 8.10 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_type_this_outside_class`](../../tests/ch8/test_illegal_type_this_outside_class.sv) |type(this) はクラスの外で使えません| 8.11 6.23 | Verilator 5.052 |違法なデザインだ|
| [`test_this_and_super_in_out_of_block_methods`](../../tests/ch8/test_this_and_super_in_out_of_block_methods.sv) |クラス宣言やブロック外のメソッド宣言 (コンストラクタと2つの関数) の中で使われる this、super、this.super は、同名の引数や派生属性の代わりに、現在のオブジェクトまたはそのベースクラスのプロパティを選択します。| 8.11 8.15 8.24 A.8.4 A.10 | Verilator 5.052 ||
| [`test_this_expr`](../../tests/ch8/test_this_expr.sv) |この表現をテスト| 8.11 | Icarus Verilog 13.0 ||
| [`test_type_this`](../../tests/ch8/test_type_this.sv) |type(this) はサブクラスの中に含まれる クラスのタイプであり、サブクラスの名前を与えます| 8.11 6.23 |標準のみ||
| [`test_assign_class`](../../tests/ch8/test_assign_class.sv) |クラス代入テスト| 8.12 8.4 | Icarus Verilog 13.0 ||
| [`test_class_copy`](../../tests/ch8/test_class_copy.sv) |8.13 のクラスコピー (§)| 8.12 | Verilator 5.052 ||
| [`test_class_copy_2`](../../tests/ch8/test_class_copy_2.sv) |テスト: クラスコピー法| 8.12 8.7 | Verilator 5.052 ||
| [`test_class_copy_3`](../../tests/ch8/test_class_copy_3.sv) |値と固定サイズの配列メンバーをコピーするユーザ作成のコピーメソッド| 8.12 8.7 | Verilator 5.052 ||
| [`test_class_copy_corner`](../../tests/ch8/test_class_copy_corner.sv) |浅いコピー、深いコピー、クローンパターンをテスト| 8.12 8.21 | Verilator 5.052 ||
| [`test_class_shallow_copy_covergroup_handles`](../../tests/ch8/test_class_shallow_copy_covergroup_handles.sv) |shallow copy は covergroup オブジェクトにハンドルを持つプロパティをコピーします。 つまり、両方のオブジェクトが covergroup を共有しますが、埋め込み covergroup のハンドルをコピー中に null にします。| 8.12 19.4 | Verilator 5.052 ||
| [`test_class_shallow_copy_members_type_no_constructor`](../../tests/ch8/test_class_shallow_copy_members_type_no_constructor.sv) |ハンドルに続くnewは、コンストラクタや宣言時初期化式を実行せず、変換元の動的クラスの別オブジェクトを作る。すべてのプロパティをコピーし、ハンドルのプロパティが参照するオブジェクトは共有する| 8.12 | Verilator 5.052 ||
| [`test_class_shallow_copy_random_state`](../../tests/ch8/test_class_shallow_copy_random_state.sv) |シャローコピーはランダムナンバー生成器の状態、 rand_modeとconstraint_modeの設定、 ソースオブジェクトの randcサイクルを引き継ぎ、 両方のオブジェクトを同じ値にランダム化します。| 8.12 18.4.2 18.8 18.9 | Verilator 5.052 ||
| [`test_copy_obj`](../../tests/ch8/test_copy_obj.sv) |テストオブジェクトのコピー| 8.12 | Icarus Verilog 13.0 ||
| [`test_illegal_typed_constructor_shallow_copy`](../../tests/ch8/test_illegal_typed_constructor_shallow_copy.sv) |タイプされた構造子コールは浅いコピーには使えません| 8.12 8.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_shallow_copy_array_properties`](../../tests/ch8/test_shallow_copy_array_properties.sv) |newによるシャローコピーは、動的配列、キュー、および固定サイズ配列のプロパティの要素をコピーする| 8.12 7.5 7.10 | Verilator 5.052 ||
| [`test_shallow_copy_operand_handle_forms`](../../tests/ch8/test_shallow_copy_operand_handle_forms.sv) |シャローコピーのオペランドは，クラス変数，関数コール，配列要素，他のオブジェクトのプロパティなどのオブジェクトハンドルに値を値付ける表現である。それぞれのコピーはハンドルが指定したオブジェクトの プロパティを持つ新しいオブジェクトです| 8.12 A.2.4 A.10 | Verilator 5.052 ||
| [`test_class_extends`](../../tests/ch8/test_class_extends.sv) |テストクラス拡張| 8.13 8.20 8.22 |標準のみ||
| [`test_class_extends_2`](../../tests/ch8/test_class_extends_2.sv) |テスト: クラス継承が拡張| 8.13 8.14 8.20 8.22 | Verilator 5.052 ||
| [`test_class_inherit`](../../tests/ch8/test_class_inherit.sv) |テスト: extends, super.new, メソッドオーバーライド, 親参照| 8.13 8.15 8.20 | Verilator 5.052 ||
| [`test_class_inherit_edge_cases`](../../tests/ch8/test_class_inherit_edge_cases.sv) |テスト: クラス継承エッジケース| 8.13 8.15 6.8 | Icarus Verilog 13.0 ||
| [`test_class_inheritance`](../../tests/ch8/test_class_inheritance.sv) |テストクラス継承| 8.13 8.20 8.22 |標準のみ||
| [`test_class_inheritance_2`](../../tests/ch8/test_class_inheritance_2.sv) |仮想メソッドのオーバーライドをベースクラスハンドルを通して見る| 8.13 8.20 | Verilator 5.052 ||
| [`test_class_inheritance_3`](../../tests/ch8/test_class_inheritance_3.sv) |テスト: クラス拡張、スーパーコール、仮想メソッド| 8.13 8.15 8.20 | Verilator 5.052 ||
| [`test_class_inheritance_corner`](../../tests/ch8/test_class_inheritance_corner.sv) |単一レベルと多重レベルの継承、メソッドのオーバーライド、スーパーバイザをテストします。| 8.13 8.15 8.20 8.21 | Verilator 5.052 ||
| [`test_class_inheritance_virtual_super`](../../tests/ch8/test_class_inheritance_virtual_super.sv) |クラス継承、スーパー、仮想メソッドのオーバーライド| 8.13 8.15 8.20 |標準のみ||
| [`test_class_multilevel_inheritance`](../../tests/ch8/test_class_multilevel_inheritance.sv) |多重レベル継承明示的に super.new () を呼び出さないコンストラクタ| 8.13 8.17 | Icarus Verilog 13.0 ||
| [`test_final_class_and_method`](../../tests/ch8/test_final_class_and_method.sv) |:final で宣言されたクラスは他のクラスを拡張して使用することができ、 :final で 宣言されたメソッドは他のメソッドと同様に継承され呼び出されます。| 8.13 8.20 | Verilator 5.052 ||
| [`test_illegal_class_extends_two_classes`](../../tests/ch8/test_illegal_class_extends_two_classes.sv) |クラスは単一のベースクラスを拡張します2つのクラスを拡張するのは違法です| 8.13 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_final_class_extended`](../../tests/ch8/test_illegal_final_class_extended.sv) |:final と宣言されたクラスは拡張できません| 8.13 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_final_class_extends`](../../tests/ch8/test_illegal_final_class_extends.sv) |決定宣言されたクラスは 延長できません| 8.13 | Verilator 5.052 |違法なデザインだ|
| [`test_lrm_class_inheritance_8`](../../tests/ch8/test_lrm_class_inheritance_8.sv) |クラス継承と多型のエッジケース| 8.13 8.15 8.20 8.21 | Verilator 5.052 ||
| [`test_base_handle_redeclared_members_and_virtual_dispatch`](../../tests/ch8/test_base_handle_redeclared_members_and_virtual_dispatch.sv) |クラスハンドルを導出オブジェクトに渡すと、再宣言されたプロパティと非仮想メソッドはベースクラスに解決され、仮想メソッドだけが導出されたオバーライドを呼び出す。| 8.14 8.20 | Verilator 5.052 ||
| [`test_class_super`](../../tests/ch8/test_class_super.sv) |テスト: super キーワードの使用| 8.15 8.20 8.13 | Icarus Verilog 13.0 ||
| [`test_class_super_hidden_members_and_implicit_super_new`](../../tests/ch8/test_class_super_hidden_members_and_implicit_super_new.sv) |すべてのプロパティ、メソッド、値パラメータ、 ローカルパラメータをベースクラスにアクセスします。 派生クラスが隠し、ベースが継承するものも含まれます。 super.new がない構造子は、ベース構造子のデフォルトの引数を使って挿入されます。| 8.15 8.7 | Verilator 5.052 ||
| [`test_constructor_default_argument`](../../tests/ch8/test_constructor_default_argument.sv) |派生クラス構造子の引数リストにおけるデフォルトキーワードは、スーパークラス構造子における引数の順序、タイプ、デフォルト値を表し、一度だけ出現する。引数のないコールは デフォルトのスーパークラスを取得し 引数のあるコールは その順番で返します| 8.15 8.16 A.10 |標準のみ||
| [`test_illegal_super_new_not_first`](../../tests/ch8/test_illegal_super_new_not_first.sv) |コンストラクタの最初のステートメントに super.new を呼び出す必要があります。| 8.15 8.17 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_super_super_member`](../../tests/ch8/test_illegal_super_super_member.sv) |スーパーはクラス1レベルまでしか 達成できないsuper.super 以上のクラスに到達するのは違法です| 8.15 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_cast_class`](../../tests/ch8/test_cast_class.sv) |クラスのキャストのテスト| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_cast_complex_patterns`](../../tests/ch8/test_cast_complex_patterns.sv) |複雑なネストパターンを持つ $cast| 8.16 6.24.2 7.5 | Verilator 5.052 ||
| [`test_class_cast`](../../tests/ch8/test_class_cast.sv) |テスト：クラスキャスト$cast| 8.16 6.24.2 8.20 | Verilator 5.052 ||
| [`test_class_cast_edge_cases`](../../tests/ch8/test_class_cast_edge_cases.sv) |試験：クラスキャストエッジケース| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_class_cast_forms_null_and_failures`](../../tests/ch8/test_class_cast_forms_null_and_failures.sv) |クラスハンドルの$castを、格納先を先頭にして関数またはタスクとして呼ぶと、アップキャスト、派生オブジェクトを指すハンドルのダウンキャスト、リテラルnullでは成功して代入する。それ以外では、無関係なクラスのnullハンドルも含め、関数形式は0で失敗し、代入しない| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_class_cast_task_failure_reports_error`](../../tests/ch8/test_class_cast_task_failure_reports_error.sv) |ターゲットクラスではなくベースクラスのオブジェクトを参照するクラスハンドル上のタスクとして呼び出された $cast はランタイムエラーで失敗しました| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_dynamic_cast`](../../tests/ch8/test_dynamic_cast.sv) |配役・キャスティング| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_illegal_base_handle_assigned_to_derived`](../../tests/ch8/test_illegal_base_handle_assigned_to_derived.sv) |クラスハンドルはサブクラス変数に直接割り当てられませんが、$castは割り当てられます。| 8.16 6.24.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_system_cast`](../../tests/ch8/test_system_cast.sv) |テスト$cast：動的な型キャスト| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_type_check`](../../tests/ch8/test_type_check.sv) |タイプチェックテスト| 8.16 6.24.2 | Verilator 5.052 ||
| [`test_class_constructor_default_argument_expansion`](../../tests/ch8/test_class_constructor_default_argument_expansion.sv) |派生クラスのコンストラクタ引数リスト内のdefaultは、順序・方向・型・名前・既定値を含む基底コンストラクタの引数リスト全体を表します。その直後の引数はlogic型のinputになり、super.newを持たないコンストラクタにはsuper.new (default)が入ります。| 8.17 |標準のみ||
| [`test_illegal_constructor_default_name_conflict`](../../tests/ch8/test_illegal_constructor_default_name_conflict.sv) |明示的な構成引数はデフォルトが使われるときは スーパークラス構成引数と名前を共有できません| 8.17 |標準のみ|違法なデザインだ|
| [`test_illegal_constructor_default_outside_subclass`](../../tests/ch8/test_illegal_constructor_default_outside_subclass.sv) |標準の構造子引数キーワードはサブクラスでのみ有効です| 8.17 |標準のみ|違法なデザインだ|
| [`test_illegal_constructor_default_repeated`](../../tests/ch8/test_illegal_constructor_default_repeated.sv) |構成引数リストにはデフォルトキーワードが二度と含まれない| 8.17 |標準のみ|違法なデザインだ|
| [`test_illegal_default_depends_on_local_member`](../../tests/ch8/test_illegal_default_depends_on_local_member.sv) |ローカルメンバーを参照するデフォルト表現は 違法です| 8.17 |標準のみ|違法なデザインだ|
| [`test_illegal_extends_default_without_default_argument`](../../tests/ch8/test_illegal_extends_default_without_default_argument.sv) |extends(default)を使う場合、ユーザーのコンストラクタ引数リストにdefaultが必要である| 8.17 |標準のみ|違法なデザインだ|
| [`test_illegal_super_default_without_expansion`](../../tests/ch8/test_illegal_super_default_without_expansion.sv) |構成子引数リストがデフォルトを使用しない場合は super.new (デフォルト) は不正です。| 8.17 |標準のみ|違法なデザインだ|
| [`test_illegal_super_new_default_without_default`](../../tests/ch8/test_illegal_super_new_default_without_default.sv) |super.new (デフォルト) は構成子の引数リストにデフォルトを必要とします。| 8.17 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_super_new_with_extends_arguments`](../../tests/ch8/test_illegal_super_new_with_extends_arguments.sv) |クラスの構成要素は super.new を呼び出す必要がありません| 8.17 | Verilator 5.052 |違法なデザインだ|
| [`test_super_new_default`](../../tests/ch8/test_super_new_default.sv) |構成要素の引数リストのデフォルトは、スーパークラス構成要素の 引数を受け取り、super.new (デフォルト) はそれらを渡し、default と拡張すると、暗黙的な構成要素に同じ引数を与えます。| 8.17 8.15 |標準のみ||
| [`test_class_local_protected_access_and_modifier_order`](../../tests/ch8/test_class_local_protected_access_and_modifier_order.sv) |ローカルメンバーはそのクラスのメソッドにより使用されます。 また、他のインスタンスで継承メソッドを通して、プロテクトされたメンバーはサブクラスにより使用されます、 ローカル、プロテクト、静的、コンスト、仮想の修飾子は任意の順序で書くことができます。| 8.18 | Verilator 5.052 ||
| [`test_illegal_local_member_outside`](../../tests/ch8/test_illegal_local_member_outside.sv) |ローカルクラスのプロパティはクラスの外からアクセスできません| 8.18 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_local_protected_member`](../../tests/ch8/test_illegal_local_protected_member.sv) |メンバーは 地元と保護を兼ねてはいけません| 8.18 |標準のみ|違法なデザインだ|
| [`test_class_const_global_and_instance_properties`](../../tests/ch8/test_class_const_global_and_instance_properties.sv) |constクラスプロパティは、宣言時に値を指定すればグローバル定数で、staticにもできる。コンストラクタで1回代入する場合は、各オブジェクトに固有の値を持つインスタンス定数となる| 8.19 | Verilator 5.052 ||
| [`test_class_const_properties`](../../tests/ch8/test_class_const_properties.sv) |定数は、定義の中で値を取る。| 8.19 8.9 | Verilator 5.052 ||
| [`test_illegal_const_property_assigned_twice`](../../tests/ch8/test_illegal_const_property_assigned_twice.sv) |初期化子のない const クラスのプロパティは コンストラクタで一度だけ割り当てられます| 8.19 |標準のみ|違法なデザインだ|
| [`test_illegal_const_static_instance_constant`](../../tests/ch8/test_illegal_const_static_instance_constant.sv) |初期値がない const クラスのプロパティであるインスタンス定数は 静的に宣言できません| 8.19 8.9 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_global_constant_assigned_in_constructor`](../../tests/ch8/test_illegal_global_constant_assigned_in_constructor.sv) |初期値を持つクラス定数は、構成子においても割り当てることができません。| 8.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_instance_constant_assigned_in_method`](../../tests/ch8/test_illegal_instance_constant_assigned_in_method.sv) |クラスのインスタンス定数へ代入できるのは、コンストラクタ内だけである| 8.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_instance_constant_assigned_twice`](../../tests/ch8/test_illegal_instance_constant_assigned_twice.sv) |コンストラクタにインスタンス定数を 1回だけ代入ることができ、 2回目の代入は違法です| 8.19 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_static_instance_const_member`](../../tests/ch8/test_illegal_static_instance_const_member.sv) |インスタンス定数クラスのプロパティは静的に宣言できません| 8.19 |標準のみ|違法なデザインだ|
| [`test_illegal_static_instance_constant`](../../tests/ch8/test_illegal_static_instance_constant.sv) |クラスのインスタンス定数は静的に宣言できません| 8.19 8.9 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_callback_basic`](../../tests/ch8/test_callback_basic.sv) |クラスと仮想メソッドから構築されたユーザが書いたコールバックパターン| 8.20 8.10 7.10 | Verilator 5.052 ||
| [`test_callback_chain`](../../tests/ch8/test_callback_chain.sv) |ユーザが書いた複数のコールバックをベースクラスハンドルを通して順番に呼び出す| 8.20 7.10 | Verilator 5.052 ||
| [`test_callback_enable_disable`](../../tests/ch8/test_callback_enable_disable.sv) |ユーザが書いたコールバックオブジェクトを有効/無効にする| 8.20 7.10 | Verilator 5.052 ||
| [`test_class_polymorphic_access`](../../tests/ch8/test_class_polymorphic_access.sv) |派生オブジェクトへのベースクラスハンドルを通して呼び出す仮想メソッド| 8.20 8.22 | Verilator 5.052 ||
| [`test_class_polymorphism`](../../tests/ch8/test_class_polymorphism.sv) |クラス多型（§ 8.20）| 8.20 | Verilator 5.052 ||
| [`test_class_polymorphism_2`](../../tests/ch8/test_class_polymorphism_2.sv) |クラス多型性テスト| 8.20 8.22 | Verilator 5.052 ||
| [`test_class_virtual_dispatch_and_initial`](../../tests/ch8/test_class_virtual_dispatch_and_initial.sv) |仮想ベースメソッドは最近のオバーライドに ディスパッチされます 非仮想メソッドの初期オバーライドは静的に残ります| 8.20 8.26 |標準のみ||
| [`test_class_virtual_edge_cases`](../../tests/ch8/test_class_virtual_edge_cases.sv) |テスト：クラス仮想手法エッジケース| 8.20 | Verilator 5.052 ||
| [`test_class_virtual_override_of_nonvirtual_and_initial`](../../tests/ch8/test_class_virtual_override_of_nonvirtual_and_initial.sv) |仮想メソッドは非仮想メソッドを上書きし、キーワードなしの後の上書きでも仮想であり、上書きは仮想メソッドのプロトタイプに従い、:initialで宣言されたメソッドはそれによって仮想化されないので、その非仮想上書きはハンドルタイプによって選択されます。| 8.20 | Verilator 5.052 ||
| [`test_class_virtual_param`](../../tests/ch8/test_class_virtual_param.sv) |仮想メソッドオーバーライドとタイプパラメータを持つパラメータ化クラス| 8.20 8.25 | Verilator 5.052 ||
| [`test_illegal_extends_nonvirtual_method`](../../tests/ch8/test_illegal_extends_nonvirtual_method.sv) |extends とマークされたメソッドはベースクラスの仮想メソッドを上書きしなければなりません| 8.20 |標準のみ|違法なデザインだ|
| [`test_illegal_final_method_overridden`](../../tests/ch8/test_illegal_final_method_overridden.sv) |:final で宣言されたメソッドはサブクラスで上書きできません。| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_final_pure_virtual`](../../tests/ch8/test_illegal_final_pure_virtual.sv) |純粋な仮想メソッドは宣言できません:final| 8.20 8.21 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_initial_method_overrides_pure_virtual`](../../tests/ch8/test_illegal_initial_method_overrides_pure_virtual.sv) |:initial と宣言されたメソッドは 抽象ベースクラスの 純粋仮想メソッドを上書きすることもできません| 8.20 8.21 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_initial_method_overrides_virtual`](../../tests/ch8/test_illegal_initial_method_overrides_virtual.sv) |:initial と宣言されたメソッドは ベースクラスの仮想メソッドを上書きできません| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_method_extends_without_base`](../../tests/ch8/test_illegal_method_extends_without_base.sv) |:extends で宣言されたメソッドはベースクラスの仮想メソッドを上書きしなければなりません。| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_method_initial_and_extends`](../../tests/ch8/test_illegal_method_initial_and_extends.sv) |:initialと:extendsの両方を宣言できません。| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_method_initial_overrides`](../../tests/ch8/test_illegal_method_initial_overrides.sv) |:initial で宣言されたメソッドは仮想メソッドを上書きできません。| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_method_initial_with_extends_specifier`](../../tests/ch8/test_illegal_method_initial_with_extends_specifier.sv) |:initialと:extendsは同時に使えませんが、:finalはどちらかの後に付けることができます。| 8.20 8.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_nonvirtual_final_method_overridden`](../../tests/ch8/test_illegal_nonvirtual_final_method_overridden.sv) |:final を宣言したメソッドは 仮想ではないサブクラスでも 上書きできません| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_override_argument_type_mismatch`](../../tests/ch8/test_illegal_override_argument_type_mismatch.sv) |仮想関数のオバーライドは 基本プロトタイプの引数タイプを持たなければなりません| 8.20 |標準のみ|違法なデザインだ|
| [`test_illegal_override_default_presence`](../../tests/ch8/test_illegal_override_default_presence.sv) |仮想のオバーライドは プロトタイプが持っているデフォルト表現を 必ず持つ必要があります| 8.20 |標準のみ|違法なデザインだ|
| [`test_illegal_override_return_type_mismatch`](../../tests/ch8/test_illegal_override_return_type_mismatch.sv) |仮想関数のオバーライドは 対応するタイプまたは派生クラスタイプを返さなければなりません| 8.20 |標準のみ|違法なデザインだ|
| [`test_illegal_pure_virtual_final`](../../tests/ch8/test_illegal_pure_virtual_final.sv) |純粋な仮想手法は 決定的とは言えません| 8.20 |標準のみ|違法なデザインだ|
| [`test_illegal_virtual_final_method_overridden_in_subclass`](../../tests/ch8/test_illegal_virtual_final_method_overridden_in_subclass.sv) |:final で宣言された仮想メソッドはサブクラスで上書きできません。 2レベル下のクラスでも、virtual というキーワードがない場合は| 8.20 | Verilator 5.052 |違法なデザインだ|
| [`test_method_initial_extends`](../../tests/ch8/test_method_initial_extends.sv) |:initial で宣言されたメソッドはメソッドを開始し、他のメソッドを上書きしません。 :extends で宣言された メソッドは仮想メソッドを上 書きし、自身が仮想です。| 8.20 | Verilator 5.052 ||
| [`test_method_virtual`](../../tests/ch8/test_method_virtual.sv) |仮想手法テスト| 8.20 8.15 | Verilator 5.052 ||
| [`test_virt_method`](../../tests/ch8/test_virt_method.sv) |仮想メソッドをテスト| 8.20 8.14 | Verilator 5.052 ||
| [`test_virtual_method`](../../tests/ch8/test_virtual_method.sv) |テスト仮想メソッド| 8.20 | Verilator 5.052 ||
| [`test_abstract_class_basic`](../../tests/ch8/test_abstract_class_basic.sv) |二つの派生クラスで実装された純粋仮想メソッドを持つ抽象クラス| 8.21 8.20 | Verilator 5.052 ||
| [`test_abstract_class_chain_and_handle_array`](../../tests/ch8/test_abstract_class_chain_and_handle_array.sv) |具象クラスを拡張して、pure virtualメソッドを追加したり、メソッドをpureとして上書きしたりする抽象（virtual）クラスを定義できます。抽象クラスから抽象クラスも派生でき、抽象クラス型の変数・配列は派生クラスのオブジェクトを保持できます。| 8.21 8.22 | Verilator 5.052 ||
| [`test_class_abstract`](../../tests/ch8/test_class_abstract.sv) |8.21 の抽象クラス| 8.21 | Verilator 5.052 ||
| [`test_class_abstract_2`](../../tests/ch8/test_class_abstract_2.sv) |抽象クラスの使用| 8.21 8.20 8.9 | Verilator 5.052 ||
| [`test_class_virtual`](../../tests/ch8/test_class_virtual.sv) |テスト: 仮想クラス宣言| 8.21 8.20 | Verilator 5.052 ||
| [`test_class_virtual_2`](../../tests/ch8/test_class_virtual_2.sv) |テスト：仮想クラス（抽象化）、仮想手法、ベースハンドルを介した多型| 8.21 8.20 | Verilator 5.052 ||
| [`test_illegal_abstract_class_new`](../../tests/ch8/test_illegal_abstract_class_new.sv) |抽象 (仮想) クラスのオブジェクトは構築できません| 8.21 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_concrete_class_missing_pure_method`](../../tests/ch8/test_illegal_concrete_class_missing_pure_method.sv) |抽象クラスから派生した非抽象クラスは それが継承するすべての純粋仮想メソッドを実装しなければなりません| 8.21 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_class_scope_base_members_from_derived`](../../tests/ch8/test_class_scope_base_members_from_derived.sv) |派生クラスの内部では、base_class::name はベースクラスの公開と保護されたプロパティとメソッドを選択します。派生クラスが隠しているものも含めて| 8.23 |標準のみ||
| [`test_class_scope_nested_class_and_static_access`](../../tests/ch8/test_class_scope_nested_class_and_static_access.sv) |クラスの範囲演算子は静的なプロパティを読み書きし、静的なメソッドを呼び出し、enum 定数、typedefs、ネストされたクラスとパラメータを名付け、クラスの外部から静的なイベントをトリガーします。ネストされたクラスは、外部クラスの静的なメンバーを限定なしに使用し、ハンドルを通してローカルメンバーを使用します。| 8.23 | Verilator 5.052 ||
| [`test_illegal_forward_class_scope_prefix_in_variable_declaration`](../../tests/ch8/test_illegal_forward_class_scope_prefix_in_variable_declaration.sv) |まだ不完全な前向きクラスをスコープ解像度演算子で選択したタイプは、typedef 、タイプ演算子またはタイプパラメータ代入でのみ使用できます。| 8.23 8.27 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_interface_typedef_scope_prefix_in_variable_declaration`](../../tests/ch8/test_illegal_interface_typedef_scope_prefix_in_variable_declaration.sv) |クラスタイプをインタフェースベースの typedef で与えられた場合、スコープ解像度演算子を持つタイプは typedef 、タイプ演算子またはタイプパラメータ代入でのみ使用できます。| 8.23 6.18 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_nested_class_unqualified_outer_property`](../../tests/ch8/test_illegal_nested_class_unqualified_outer_property.sv) |内包クラスは外部クラスの暗黙のハンドルを持たないので、ハンドルなしで非静的な外部プロパティを名付けることはできません。| 8.23 |標準のみ|違法なデザインだ|
| [`test_illegal_scope_prefix_is_class_variable`](../../tests/ch8/test_illegal_scope_prefix_is_class_variable.sv) |左のオペランドはクラス変数ではありません| 8.23 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_scope_prefix_typedef_not_class`](../../tests/ch8/test_illegal_scope_prefix_typedef_not_class.sv) |typedef covergroup の名前は、スコープ解決演算子がクラスまたはタイプに解決する前に必要です。| 8.23 6.18 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_type_parameter_scope_prefix_in_variable_declaration`](../../tests/ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration.sv) |型パラメータプレフィックスに scope resolution 演算子を付けて選択した型は typedef 型演算子または型パラメータ代入にのみ使用できます| 8.23 6.20.3 |標準のみ|違法なデザインだ|
| [`test_nested_class_access`](../../tests/ch8/test_nested_class_access.sv) |クラス内で宣言したクラスは、外部からスコープ解決演算子で利用できます。外側クラスのstatic・localメンバを使用でき、非staticメンバにはハンドル経由でアクセスします。また、2つの外側クラスがそれぞれ同名の入れ子クラスを持つこともできます。| 8.23 8.18 | Verilator 5.052 ||
| [`test_class_extern`](../../tests/ch8/test_class_extern.sv) |テスト: 外部メソッド宣言| 8.24 8.20 | Verilator 5.052 ||
| [`test_extern_method_class_type_visibility`](../../tests/ch8/test_extern_method_class_type_visibility.sv) |ブロック外メソッドはそのクラスのすべての宣言を見る。クラス型の後に宣言されたプロトタイプは、同名の外部型ではなく、そのクラス型を使用する。| 8.24 | Verilator 5.052 ||
| [`test_extern_method_prototype_qualifiers`](../../tests/ch8/test_extern_method_prototype_qualifiers.sv) |外部プロトタイプは全ての引数と仮想、保護、ローカル、最終限定詞を持ちますが、 ブロック外のボディはクラスの名前を付けて、それらを省略します| 8.24 | Verilator 5.052 ||
| [`test_extern_method_scoped_return_type`](../../tests/ch8/test_extern_method_scoped_return_type.sv) |ブロック外のメソッドは、返り型としてクラス typedef を使い、プロトタイプデフォルトを省略できる。| 8.24 |標準のみ||
| [`test_illegal_extern_argument_type_mismatch`](../../tests/ch8/test_illegal_extern_argument_type_mismatch.sv) |ブロック外のメソッド宣言の引数タイプは プロトタイプと一致しなければなりません| 8.24 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_extern_body_before_class`](../../tests/ch8/test_illegal_extern_body_before_class.sv) |ブロック外のメソッドの宣言は それぞれのクラスの宣言に従う必要があります| 8.24 8.27 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_extern_body_outside_class_scope`](../../tests/ch8/test_illegal_extern_body_outside_class_scope.sv) |ブロック外のメソッド宣言は クラス宣言の範囲内にある必要があります| 8.24 27.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_extern_default_differs_from_prototype`](../../tests/ch8/test_illegal_extern_default_differs_from_prototype.sv) |ブロック外のメソッド宣言で繰り返されるデフォルトの引数値は プロトタイプと同じでなければなりません| 8.24 |標準のみ|違法なデザインだ|
| [`test_illegal_extern_default_not_in_prototype`](../../tests/ch8/test_illegal_extern_default_not_in_prototype.sv) |ブロック外のメソッド宣言は、そのプロトタイプが持たないデフォルトの引数値を追加できません。| 8.24 |標準のみ|違法なデザインだ|
| [`test_illegal_extern_header_mismatch`](../../tests/ch8/test_illegal_extern_header_mismatch.sv) |外部メソッドボディは プロトタイプの引数タイプを繰り返さなければなりません| 8.24 |標準のみ|違法なデザインだ|
| [`test_illegal_extern_method_two_bodies`](../../tests/ch8/test_illegal_extern_method_two_bodies.sv) |外部メソッドは 1つ以上のブロック外宣言を持つことができません| 8.24 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_extern_return_type_mismatch`](../../tests/ch8/test_illegal_extern_return_type_mismatch.sv) |ブロック外のメソッド宣言の返すタイプは プロトタイプと一致しなければなりません| 8.24 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_extern_return_type_without_class_scope`](../../tests/ch8/test_illegal_extern_return_type_without_class_scope.sv) |返すタイプがクラスで宣言されているブロック外メソッドは クラスのスコープでそのタイプを名付けなければなりません| 8.24 |標準のみ|違法なデザインだ|
| [`test_illegal_extern_type_name_resolves_differently`](../../tests/ch8/test_illegal_extern_type_name_resolves_differently.sv) |ブロック外のメソッドヘッダの識別子は プロトタイプの宣言と同じに解決しなければなりません| 8.24 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_class_bounded_fifo`](../../tests/ch8/test_class_bounded_fifo.sv) |try_putとtry_getのサイズ制限を持つパラメータ化クラスFIFO| 8.25 7.10 13.5.2 | Verilator 5.052 ||
| [`test_class_param`](../../tests/ch8/test_class_param.sv) |テスト: パラメータ化されたクラス| 8.25 | Verilator 5.052 ||
| [`test_class_param_2`](../../tests/ch8/test_class_param_2.sv) |テスト：パラメータ化されたクラス、異なるタイプのインスタンス化| 8.25 | Verilator 5.052 ||
| [`test_class_typed_param`](../../tests/ch8/test_class_typed_param.sv) |テスト: クラスにパラメータを入力| 8.25 8.25.1 | Verilator 5.052 ||
| [`test_comb_param_class`](../../tests/ch8/test_comb_param_class.sv) |テスト:パラメータ化されたクラス特化| 8.25 | Verilator 5.052 ||
| [`test_generic_fifo`](../../tests/ch8/test_generic_fifo.sv) |パラメータ化クラス基本テスト| 8.25 7.10 | Verilator 5.052 ||
| [`test_illegal_parameterized_class_without_default_specialization`](../../tests/ch8/test_illegal_parameterized_class_without_default_specialization.sv) |標準のないパラメータを持つパラメータ化されたクラスの 単純な名前は 専門化を意味しません| 8.25 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_type_parameter_base_not_class`](../../tests/ch8/test_illegal_type_parameter_base_not_class.sv) |型パラメータをベースクラスとして使うと 詳細化後にクラスタイプに解決しなければなりません| 8.25 8.13 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_typedef_base_not_class`](../../tests/ch8/test_illegal_typedef_base_not_class.sv) |typedef の名前をベースクラスとして使うときは クラスタイプに解決しなければなりません| 8.25 8.13 6.18 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_param_class`](../../tests/ch8/test_param_class.sv) |テストパラメータ化クラス| 8.25 | Verilator 5.052 ||
| [`test_param_class_extends_param_class`](../../tests/ch8/test_param_class_extends_param_class.sv) |クラスは、デフォルトのパラメータ、 明示的なパラメータ、 自身に依存するパラメータ、またはタイプパラメータで与えられたベースクラスを使って、他のパラメータ化されたクラスを拡張できます。| 8.25 20.6.2 | Verilator 5.052 ||
| [`test_param_class_inheritance`](../../tests/ch8/test_param_class_inheritance.sv) |パラメータ化されたクラス| 8.25 8.13 | Verilator 5.052 ||
| [`test_param_class_multiple_params`](../../tests/ch8/test_param_class_multiple_params.sv) |パラメータ化されたクラス| 8.25 | Verilator 5.052 ||
| [`test_param_class_nested`](../../tests/ch8/test_param_class_nested.sv) |パラメータ化されたクラス| 8.25 6.18 | Verilator 5.052 ||
| [`test_param_class_package_vs_module_instance_specializations`](../../tests/ch8/test_param_class_package_vs_module_instance_specializations.sv) |パッケージに宣言されたジェネリッククラスの 特化はどこでも同じタイプですが ジェネリッククラ스を宣言したモジュールの 各インスタンスは 独自のクラスを持ち それぞれの特化は独自です| 8.25 |標準のみ||
| [`test_param_class_specialization_identity_and_statics`](../../tests/ch8/test_param_class_specialization_identity_and_statics.sv) |クラスパラメータは位置または名前で上書きされる 適合するタイプと同じ値のパラメータセットは同じ特化を選択する 装飾なしのクラス名はデフォルトの特化です 各特化は独自の静的変数を持ち、パラメータ化されていないベースクラスは1つを共有します タイプパラメータは構造やクラスも含めて任意のタイプを取得します| 8.25 6.22.1 | Verilator 5.052 ||
| [`test_parameterized_class_static_per_specialization`](../../tests/ch8/test_parameterized_class_static_per_specialization.sv) |パラメータ付きクラスの各特殊化は、コンストラクタから更新する場合も含め、それぞれ固有のstaticプロパティを持つ| 8.25 8.9 | Verilator 5.052 ||
| [`test_extern_method_class_scope_current_specialization`](../../tests/ch8/test_extern_method_class_scope_current_specialization.sv) |ブロック外のブロックのボディにあるパラメータ化されたクラスのメソッドの場合、 :: の前の無装飾クラス名は、メソッドを実行する特化のパラメータを指定します。デフォルトの特化ではありません。| 8.25.1 8.24 | Verilator 5.052 ||
| [`test_illegal_unadorned_class_scope_type_parameter_outside`](../../tests/ch8/test_illegal_unadorned_class_scope_type_parameter_outside.sv) |パラメータ化されたクラスの外では、装飾なしのクラス名は、タイプパラメータのスコープ解析演算子の前置きにはなりません。| 8.25.1 8.25 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_unadorned_class_scope_value_parameter_outside`](../../tests/ch8/test_illegal_unadorned_class_scope_value_parameter_outside.sv) |パラメータ化されたクラスの外では、装飾なしのクラス名は、値パラメータのスコープ解析演算子の前置きにはなりません。| 8.25.1 8.25 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_constraint_block`](../../tests/ch8/test_illegal_interface_class_constraint_block.sv) |インターフェースクラスには制約ブロックは含まれません| 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_holds_covergroup`](../../tests/ch8/test_illegal_interface_class_holds_covergroup.sv) |クラスは covergroup を含めません| 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_method_with_body`](../../tests/ch8/test_illegal_interface_class_method_with_body.sv) |インターフェースクラスには ボディがないメソッドは含まれません| 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_nested_class`](../../tests/ch8/test_illegal_interface_class_nested_class.sv) |インターフェースクラスはネストされたクラスを含めることができません| 8.26 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_class_nested_in_interface_class`](../../tests/ch8/test_illegal_interface_class_nested_in_interface_class.sv) |インターフェースクラスは他のインターフェースクラスにネストできません| 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_property`](../../tests/ch8/test_illegal_interface_class_property.sv) |インターフェースクラスには プロパティが含まれません| 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_matching_methods_without_implements`](../../tests/ch8/test_illegal_matching_methods_without_implements.sv) |インターフェースクラスのメソッドを持つが、実装と名付けていないクラスは、実装しません。| 8.26 8.22 | Verilator 5.052 |違法なデザインだ|
| [`test_interface_class`](../../tests/ch8/test_interface_class.sv) |インターフェースクラスは2つのクラスで実装され、インターフェースクラスハンドルを通して呼び出されます。| 8.26 | Verilator 5.052 ||
| [`test_interface_class_implemented_by_subclass`](../../tests/ch8/test_interface_class_implemented_by_subclass.sv) |$cast はインタフェースクラスのハンドルであり、インタフェースのオブジェクトを指定することで、インタフェースを実装するクラスのサブクラスは、インタフェースオブジェクトを実装します。| 8.26 8.26.5 | Verilator 5.052 ||
| [`test_interface_class_implements`](../../tests/ch8/test_interface_class_implements.sv) |二つのパラメータ化されたインタフェースクラスを実装したクラスで、それぞれのインタフェースクラ스タイプのハンドルを通して使用されます。| 8.26 8.26.1 8.26.2 | Verilator 5.052 ||
| [`test_interface_class_inherited_virtual_implementation`](../../tests/ch8/test_interface_class_inherited_virtual_implementation.sv) |実装するクラスは、インタフェースメソッドの実装を、そのベースクラスから継承した仮想メソッドから、メソッド自体を宣言することなく取得できます。| 8.26 8.26.2 |標準のみ||
| [`test_interface_class_methods`](../../tests/ch8/test_interface_class_methods.sv) |インタフェースクラスメソッド実装テスト| 8.26 | Verilator 5.052 ||
| [`test_interface_class_multiple_extends_hiding_conflicts`](../../tests/ch8/test_interface_class_multiple_extends_hiding_conflicts.sv) |2つのパラメータ化されたインタフェースクラスを拡張するインタフェースクラ スは、それらのタイプ、パラメータ、純粋な仮想メソッドを継承し、継承された typedef を自分のもので隠し、両方から継承されたパラメータを上書きし、両方から 継承されたメソッドを再宣言し、共通のベースから両方が到達できるパラメータのコピーを1つ保持します。| 8.26 8.26.1 8.26.6.1 8.26.6.2 8.26.6.3 |標準のみ||
| [`test_interface_class_types_inherited_by_extends_only`](../../tests/ch8/test_interface_class_types_inherited_by_extends_only.sv) |別のinterface classをextendsするinterface classは、そのtypedefとパラメータを継承する。一方、それをimplementsするクラスは継承しないため、そのクラス内の同名参照は外側のモジュールの宣言を見つける。| 8.26 8.26.3 |標準のみ||
| [`test_interface_impl`](../../tests/ch8/test_interface_impl.sv) |テスト: インターフェースクラスの実装| 8.26 8.26.2 | Verilator 5.052 ||
| [`test_interface_simple_2`](../../tests/ch8/test_interface_simple_2.sv) |IEEE 1800-2023チャンネルの簡単なインタフェースクラステストを行った。8.26| 8.26 | Verilator 5.052 ||
| [`test_virtual_class_interface_prototype_forms`](../../tests/ch8/test_virtual_class_interface_prototype_forms.sv) |仮想クラスはインタフェースクラスを実装し、仮想メソッドを定義することで、純粋なプロトタイプを再宣言することで、仮想メソードを継承することで、または純粋な仮想プロトタイプを継承することで各インタフェースメソッドを満たし、その非抽象的サブクラスは、それが欠けているボディを提供します。| 8.26 8.26.2 8.26.7 8.21 |標準のみ||
| [`test_interface_class_shared_method_implementation`](../../tests/ch8/test_interface_class_shared_method_implementation.sv) |2つのインタフェイスクラスからの純粋仮想手法のマッチングを満足する実装を示した。| 8.26.1 8.26.6.1 | Verilator 5.052 ||
| [`test_class_extends_inherits_implements_does_not`](../../tests/ch8/test_class_extends_inherits_implements_does_not.sv) |クラスをextendsし、interface classをimplementsするクラスは、extendsしたクラスのプロパティとメソッドを継承するが、interface classからは何も継承しない。interface classのメソッドは実装する必要があり、そのtypedefとパラメータにはクラススコープ演算子を使う場合だけアクセスできる。| 8.26.2 8.26 | Verilator 5.052 ||
| [`test_illegal_class_extends_interface_class`](../../tests/ch8/test_illegal_class_extends_interface_class.sv) |クラスはインターフェースクラスを拡張できません実行しなければなりません| 8.26.2 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_class_extends_two_base_classes`](../../tests/ch8/test_illegal_class_extends_two_base_classes.sv) |クラスは複数のインターフェースクラスを実装しても 最大で1つのクラスを拡張できます| 8.26.2 8.13 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_class_implements_noninterface_class`](../../tests/ch8/test_illegal_class_implements_noninterface_class.sv) |クラスはインターフェースクラスでないクラスを実装できません| 8.26.2 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_inherited_nonvirtual_method_for_interface`](../../tests/ch8/test_illegal_inherited_nonvirtual_method_for_interface.sv) |継承された非仮想メソッドは インターフェースクラスのメソッドを実装していません| 8.26.2 8.26 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_class_extends_class`](../../tests/ch8/test_illegal_interface_class_extends_class.sv) |インターフェースクラスは インターフェースクラ스でないクラスを拡張できません| 8.26.2 8.26 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_class_implements_class`](../../tests/ch8/test_illegal_interface_class_implements_class.sv) |インターフェースクラスはクラスや仮想クラスを実装できません| 8.26.2 8.26 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_implements_interface`](../../tests/ch8/test_illegal_interface_class_implements_interface.sv) |インターフェースクラスはインターフェースクラスを拡張できますが、実装することはできません。| 8.26.2 8.26 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_class_unqualified_type`](../../tests/ch8/test_illegal_interface_class_unqualified_type.sv) |インターフェースクラスを実装したクラスはその typedefs を継承しません。従って、クラスのスコープなしでは使用できません。| 8.26.3 | Verilator 5.052 |違法なデザインだ|
| [`test_interface_class_type_access`](../../tests/ch8/test_interface_class_type_access.sv) |クラスのパラメータとタイプ定義は、それを拡張するインタフェースクラスが継承するが、それを実装するクラスは継承しない。実装するクラスがそれらに到達するには、クラスの範囲解決演算子を使う。| 8.26.3 8.26.2 8.23 | Verilator 5.052 ||
| [`test_illegal_class_implements_type_parameter`](../../tests/ch8/test_illegal_class_implements_type_parameter.sv) |クラスはインタフェースクラスの値を持つタイプパラメータを実装できません。| 8.26.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_implements_forward_typedef`](../../tests/ch8/test_illegal_implements_forward_typedef.sv) |クラスは、その点で前方 typedef で宣言されただけのインタフェースクラスを実装できません。| 8.26.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_implements_type_parameter`](../../tests/ch8/test_illegal_implements_type_parameter.sv) |クラスはインターフェースクラスに解決した場合でも タイプパラメータを実装できません| 8.26.4 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_class_extends_type_parameter`](../../tests/ch8/test_illegal_interface_class_extends_type_parameter.sv) |インターフェースクラスは、パラメータがインターフェースクラスであっても、そのタイプパラメータを拡張できません。| 8.26.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_interface_extends_forward_typedef`](../../tests/ch8/test_illegal_interface_extends_forward_typedef.sv) |前方 typedef を通じてしか知られていないインタフェースクラスをインタフェースクラ スは拡張できません。| 8.26.4 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_interface_class_construction`](../../tests/ch8/test_illegal_interface_class_construction.sv) |インターフェースクラスハンドルはインターフェースクラスオブジェクトを構築できません| 8.26.5 | Verilator 5.052 |違法なデザインだ|
| [`test_interface_class_cast`](../../tests/ch8/test_interface_class_cast.sv) |インターフェースクラスハンドルとクラスハンドルの間の $cast は、オブジェクトが目的地型を実装している場合のみ成功します。| 8.26.5 8.16 8.26 8.20 |標準のみ||
| [`test_interface_class_null_handle_cast`](../../tests/ch8/test_interface_class_null_handle_cast.sv) |nullを保持するinterface classハンドルからの$castは、変換先型が変換元の静的な型に代入互換の場合だけ成功し、nullを代入する。目的物のランタイムチェックが必要なとき 失敗して 目的物は変わらない| 8.26.5 8.16 |標準のみ||
| [`test_illegal_interface_method_conflict_return_types`](../../tests/ch8/test_illegal_interface_method_conflict_return_types.sv) |1つのメソッドは 異なる返しタイプを持つ 同じ名前の2つのインタフェースメソッドを実装できません| 8.26.6.1 8.26.6 8.20 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_method_conflict_with_inherited`](../../tests/ch8/test_illegal_interface_method_conflict_with_inherited.sv) |実装するメソッドは 同じ名前の継承メソッドの有効なオバーライドでもなければなりません| 8.26.6.1 8.20 |標準のみ|違法なデザインだ|
| [`test_interface_class_diamond`](../../tests/ch8/test_interface_class_diamond.sv) |また，同じ名前のメソッドを複数のインタフェースクラスから得るメソッドを，拡張のダイアモンドを通して実装するメソッドもある。| 8.26.6.1 8.26.6.3 8.26.2 | Verilator 5.052 ||
| [`test_illegal_interface_class_parameter_conflict`](../../tests/ch8/test_illegal_interface_class_parameter_conflict.sv) |2 つのインタフェースクラスから同じ名前のパラメータを継承するインタフェースクラ スは、それ自身を宣言しなければなりません。| 8.26.6.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_interface_class_typedef_conflict`](../../tests/ch8/test_illegal_interface_class_typedef_conflict.sv) |2 つのインタフェースクラスから同じ typedef 名前を継承するインタフェースクラ スは、名前自体を宣言しないとエラーになります。| 8.26.6.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_interface_param_conflict`](../../tests/ch8/test_illegal_interface_param_conflict.sv) |2つの異なるインターフェースクラスから継承されたパラメータは、2つのパラメータが一致しても使用されない場合でも衝突します。| 8.26.6.2 |標準のみ|違法なデザインだ|
| [`test_interface_class_typedef_conflict_resolved`](../../tests/ch8/test_interface_class_typedef_conflict_resolved.sv) |2つのインターフェースクラスから同じ typedef 名前を継承するインターフェースクラ スは、その名前自体を宣言することで衝突を解決します。| 8.26.6.2 8.26.3 8.26.6 |標準のみ||
| [`test_illegal_interface_specialization_conflict`](../../tests/ch8/test_illegal_interface_specialization_conflict.sv) |1つのパラメータ化されたインターフェースクラスの 2つの特化は異なるタイプであるため、 それらのメソッド名は、一緒に継承されると衝突します| 8.26.6.3 |標準のみ|違法なデザインだ|
| [`test_interface_diamond_inherited_parameter`](../../tests/ch8/test_interface_diamond_inherited_parameter.sv) |ダイアモンドに沿って継承される同じインタフェースパラメータは単一の宣言である。| 8.26.6.3 | Verilator 5.052 ||
| [`test_illegal_virtual_class_leaves_interface_method_undeclared`](../../tests/ch8/test_illegal_virtual_class_leaves_interface_method_undeclared.sv) |インターフェースクラスを実装する仮想クラスは それぞれのメソッドを純粋に実装または再宣言しなければなりません| 8.26.7 8.26 |標準のみ|違法なデザインだ|
| [`test_interface_class_partial_virtual`](../../tests/ch8/test_interface_class_partial_virtual.sv) |仮想クラスはインタフェースクラスを部分的に実装し，残りの部分を純粋に宣言し，派生クラスでそれを完了させる。| 8.26.7 8.21 8.26.8 | Verilator 5.052 ||
| [`test_interface_partial_default_argument`](../../tests/ch8/test_interface_partial_default_argument.sv) |部分的仮想実装は，定数デフォルトを保持しながらサブクラスにおける残りのメソッドを完了できる。| 8.26.7 8.26.8 | Verilator 5.052 ||
| [`test_illegal_interface_method_default_not_constant`](../../tests/ch8/test_illegal_interface_method_default_not_constant.sv) |インターフェースクラスのメソッドのデフォルトの引数値は 定数表現でなければなりません| 8.26.8 |標準のみ|違法なデザインだ|
| [`test_illegal_constraint_mode_via_interface_handle`](../../tests/ch8/test_illegal_constraint_mode_via_interface_handle.sv) |constraint_mode はインタフェースクラスハンドルを通して呼び出せません| 8.26.9 |標準のみ|違法なデザインだ|
| [`test_illegal_interface_class_constraint`](../../tests/ch8/test_illegal_interface_class_constraint.sv) |インターフェースクラスは制約ブロックを宣言できません| 8.26.9 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_interface_class_covergroup`](../../tests/ch8/test_illegal_interface_class_covergroup.sv) |covergroup はインタフェースクラスで宣言できません| 8.26.9 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_rand_mode_via_interface_handle`](../../tests/ch8/test_illegal_rand_mode_via_interface_handle.sv) |rand_mode はインタフェースクラスハンドルを通して呼び出せません| 8.26.9 |標準のみ|違法なデザインだ|
| [`test_interface_class_randomize`](../../tests/ch8/test_interface_class_randomize.sv) |randomize() はインターフェースクラスハンドルを通して呼び出せます。クラスは pre_randomizeと post_randomizeのメソッドを内蔵しており、 2つのインターフェースクラスの間で名前の衝突がなく、クラスが上書きできるようになっています。| 8.26.9 18.6.2 18.6.1 |標準のみ||
| [`test_interface_handle_randomize_inline_state`](../../tests/ch8/test_interface_handle_randomize_inline_state.sv) |randomize() はインタフェースクラスハンドルを通して呼び出され、オブジェクトの制約条件下で参照するオブジェクトをランダム化します。このようなコールに対するインライン制約条件は、状態変数のみを名前付けることができ、 false のときはコールが失敗し、true のときは成功します。| 8.26.9 18.7 18.6.3 |標準のみ||
| [`test_class_typedef`](../../tests/ch8/test_class_typedef.sv) |テスト: typedef クラス前進宣言、相互参照| 8.27 | Verilator 5.052 ||
| [`test_forward_class_cycle_and_struct_value`](../../tests/ch8/test_forward_class_cycle_and_struct_value.sv) |前方クラス宣言は構造代入がその値をコピーする間にサイクリックハンドルを許可します。| 8.27 8.28 | Verilator 5.052 ||
| [`test_forward_class_typedef_parameterized`](../../tests/ch8/test_forward_class_typedef_parameterized.sv) |前向きクラス typedef は、後に位置と名前で特化されるパラメータポートリストを持つクラスを指します。| 8.27 8.5 | Verilator 5.052 ||
| [`test_illegal_forward_class_defined_in_other_scope`](../../tests/ch8/test_illegal_forward_class_defined_in_other_scope.sv) |前向きクラス宣言のクラスは 同じローカルスコープで定義されなければなりません| 8.27 6.18 | Verilator 5.052 |違法なデザインだ|
| [`test_class_vs_struct_assignment`](../../tests/ch8/test_class_vs_struct_assignment.sv) |クラスハンドルを割り当てると、1つのオブジェクトを共有しますが、構造を割り当てるとその値をコピーします。| 8.28 8.12 7.2 | Verilator 5.052 ||
| [`test_illegal_cast_class_handle_to_integral`](../../tests/ch8/test_illegal_cast_class_handle_to_integral.sv) |クラスハンドルは整数型に変換できません| 8.28 6.24.1 |標準のみ|違法なデザインだ|
| [`test_object_strongly_reachable`](../../tests/ch8/test_object_strongly_reachable.sv) |アクティブスコープのハンドルがオブジェクトを参照するか、またはそのメンバーに非ブロック代入が待ち受けている間、オブジェクトは強く到達可能に保たれ、弱い参照はクリアされません。| 8.29 8.30.3 |標準のみ||
| [`test_weak_reference_std_scope_and_strong_reachability`](../../tests/ch8/test_weak_reference_std_scope_and_strong_reachability.sv) |これは、stdがweak_referenceを宣言し、他のスコープが同じ名前のクラスを宣言する場合に、アクティブスコープのハンドルがその参照者を強く到達可能に保つことを意味します。| 8.29 8.30.1 |標準のみ||
| [`test_weak_reference_prototypes`](../../tests/ch8/test_weak_reference_prototypes.sv) |std::weak_referenceは、クラス型パラメータT、T型の参照対象を受け取るコンストラクタ、clear()で参照対象がnullにされるまでT型でその参照対象を返すget()、戻り値のないclear()、およびstaticのget_id(T)を持ちます。このstaticメソッドのlongint型の結果は、nullに対して0、オブジェクトに対して0以外であり、同じオブジェクトなら呼び出しのたびに同じ値となります。| 8.30 G.7 |標準のみ||
| [`test_illegal_weak_reference_non_class`](../../tests/ch8/test_illegal_weak_reference_non_class.sv) |weak_reference のパラメータはクラスタイプでなければなりません。| 8.30.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_weak_reference_scalar_type`](../../tests/ch8/test_illegal_weak_reference_scalar_type.sv) |weak_reference にはクラスタイプパラメータが必要です| 8.30.1 |標準のみ|違法なデザインだ|
| [`test_weak_reference_id_alias_after_clear`](../../tests/ch8/test_weak_reference_id_alias_after_clear.sv) |弱い包装をクリアすると、他の包装が残り、所有者が保持するオブジェクトのアイデンティティは変わりません。| 8.30.1 8.30.2 8.30.5 8.29 |標準のみ||
| [`test_weak_reference_get_clear`](../../tests/ch8/test_weak_reference_get_clear.sv) |weak_reference は get() からその参照を返しますが、 clear() が呼び出されるまでは返しません。その後 get() は null を返します。1つの物体に対する2つの弱い参照は 同じ参照を持つ異なる物体であり| 8.30.3 8.30.2 8.30.4 26.7 |標準のみ||
| [`test_weak_reference_wait_cleared`](../../tests/ch8/test_weak_reference_wait_cleared.sv) |weak_reference get() が null になるまで待つと、他のプロセスが参照をクリアすると再開します。| 8.30.3 8.30.4 9.4.3 |標準のみ||
| [`test_weak_reference_get_id`](../../tests/ch8/test_weak_reference_get_id.sv) |weak_reference の static get_id() はオブジェクトの null と非ゼロ値に対して 0 を返します。ハンドルの各クラスタイプを通して、各呼び出しで同じ値を返します。異なるオブジェクトに対しては異なります。| 8.30.5 7.8 |標準のみ||

<a id="generated-by-generatorsinteraction_class_arraypy"></a>

## 生成者: `generators/interaction_class_array.py`

18 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_class_array_dynamic_1_1_first_alias_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_dynamic_1_1_first_alias_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_dynamic_1_3_first_shallow_source_resize`](../../tests/gen/ch8/test_gen_cross_class_array_dynamic_1_3_first_shallow_source_resize.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_dynamic_33_1_last_shallow_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_dynamic_33_1_last_shallow_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_dynamic_33_3_first_alias_source_resize`](../../tests/gen/ch8/test_gen_cross_class_array_dynamic_33_3_first_alias_source_resize.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_dynamic_8_1_first_alias_copy_resize`](../../tests/gen/ch8/test_gen_cross_class_array_dynamic_8_1_first_alias_copy_resize.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_dynamic_8_3_last_shallow_copy_resize`](../../tests/gen/ch8/test_gen_cross_class_array_dynamic_8_3_last_shallow_copy_resize.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_fixed_1_1_last_shallow_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_fixed_1_1_last_shallow_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_fixed_1_3_first_alias_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_fixed_1_3_first_alias_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_fixed_33_1_first_alias_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_fixed_33_1_first_alias_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_fixed_33_3_last_shallow_copy_element`](../../tests/gen/ch8/test_gen_cross_class_array_fixed_33_3_last_shallow_copy_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_fixed_8_1_first_alias_copy_element`](../../tests/gen/ch8/test_gen_cross_class_array_fixed_8_1_first_alias_copy_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_fixed_8_1_first_shallow_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_fixed_8_1_first_shallow_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_queue_1_1_first_alias_source_resize`](../../tests/gen/ch8/test_gen_cross_class_array_queue_1_1_first_alias_source_resize.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_queue_1_3_first_shallow_copy_element`](../../tests/gen/ch8/test_gen_cross_class_array_queue_1_3_first_shallow_copy_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_queue_33_1_first_alias_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_queue_33_1_first_alias_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_queue_33_1_last_shallow_source_resize`](../../tests/gen/ch8/test_gen_cross_class_array_queue_33_1_last_shallow_source_resize.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_queue_8_1_first_shallow_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_queue_8_1_first_shallow_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_array_queue_8_3_last_alias_source_element`](../../tests/gen/ch8/test_gen_cross_class_array_queue_8_3_last_alias_source_element.sv) |クラスの浅いコピーで配列領域を独立させ、要素ハンドルの参照先を共有する| 8.12 8.8 7.6 7.5.1 7.10.2.5 7.10.2.7 6.11.2 | Verilator 5.052 ||

<a id="generated-by-generatorsinteraction_class_methodpy"></a>

## 生成者: `generators/interaction_class_method.py`

36 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_class_method_129_bit_known_base_nonvirtual_function_ref_1`](../../tests/gen/ch8/test_gen_cross_class_method_129_bit_known_base_nonvirtual_function_ref_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_129_bit_x_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_129_bit_x_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_129_bit_z_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_129_bit_z_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_129_logic_known_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_129_logic_known_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_class_method_129_logic_x_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_129_logic_x_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_129_logic_z_base_virtual_task_const_ref_3`](../../tests/gen/ch8/test_gen_cross_class_method_129_logic_z_base_virtual_task_const_ref_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_1_bit_known_direct_function_ref_3`](../../tests/gen/ch8/test_gen_cross_class_method_1_bit_known_direct_function_ref_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_1_bit_x_base_nonvirtual_task_input_3`](../../tests/gen/ch8/test_gen_cross_class_method_1_bit_x_base_nonvirtual_task_input_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_1_bit_z_base_virtual_task_ref_1`](../../tests/gen/ch8/test_gen_cross_class_method_1_bit_z_base_virtual_task_ref_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_1_logic_known_direct_function_ref_1`](../../tests/gen/ch8/test_gen_cross_class_method_1_logic_known_direct_function_ref_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_1_logic_x_direct_task_const_ref_0`](../../tests/gen/ch8/test_gen_cross_class_method_1_logic_x_direct_task_const_ref_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_1_logic_z_direct_function_const_ref_1`](../../tests/gen/ch8/test_gen_cross_class_method_1_logic_z_direct_function_const_ref_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_32_bit_known_base_virtual_function_const_ref_0`](../../tests/gen/ch8/test_gen_cross_class_method_32_bit_known_base_virtual_function_const_ref_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_32_bit_x_direct_function_const_ref_3`](../../tests/gen/ch8/test_gen_cross_class_method_32_bit_x_direct_function_const_ref_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_32_bit_z_base_virtual_function_input_1`](../../tests/gen/ch8/test_gen_cross_class_method_32_bit_z_base_virtual_function_input_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_32_logic_known_base_nonvirtual_task_ref_3`](../../tests/gen/ch8/test_gen_cross_class_method_32_logic_known_base_nonvirtual_task_ref_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_32_logic_x_base_nonvirtual_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_32_logic_x_base_nonvirtual_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_32_logic_z_base_nonvirtual_function_ref_0`](../../tests/gen/ch8/test_gen_cross_class_method_32_logic_z_base_nonvirtual_function_ref_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_33_bit_known_base_nonvirtual_function_const_ref_3`](../../tests/gen/ch8/test_gen_cross_class_method_33_bit_known_base_nonvirtual_function_const_ref_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_33_bit_x_base_virtual_function_ref_0`](../../tests/gen/ch8/test_gen_cross_class_method_33_bit_x_base_virtual_function_ref_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_33_bit_z_direct_function_input_3`](../../tests/gen/ch8/test_gen_cross_class_method_33_bit_z_direct_function_input_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_33_logic_known_base_nonvirtual_task_const_ref_1`](../../tests/gen/ch8/test_gen_cross_class_method_33_logic_known_base_nonvirtual_task_const_ref_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_33_logic_x_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_33_logic_x_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_33_logic_z_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_33_logic_z_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_64_bit_known_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_64_bit_known_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_class_method_64_bit_x_base_virtual_function_ref_3`](../../tests/gen/ch8/test_gen_cross_class_method_64_bit_x_base_virtual_function_ref_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_64_bit_z_base_nonvirtual_function_const_ref_0`](../../tests/gen/ch8/test_gen_cross_class_method_64_bit_z_base_nonvirtual_function_const_ref_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_64_logic_known_direct_task_input_1`](../../tests/gen/ch8/test_gen_cross_class_method_64_logic_known_direct_task_input_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_class_method_64_logic_x_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_64_logic_x_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_64_logic_z_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_64_logic_z_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_65_bit_known_base_virtual_task_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_65_bit_known_base_virtual_task_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_65_bit_x_base_virtual_function_const_ref_1`](../../tests/gen/ch8/test_gen_cross_class_method_65_bit_x_base_virtual_function_const_ref_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_65_bit_z_direct_task_ref_0`](../../tests/gen/ch8/test_gen_cross_class_method_65_bit_z_direct_task_ref_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_class_method_65_logic_known_base_virtual_function_input_3`](../../tests/gen/ch8/test_gen_cross_class_method_65_logic_known_base_virtual_function_input_3.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_class_method_65_logic_x_base_nonvirtual_function_input_1`](../../tests/gen/ch8/test_gen_cross_class_method_65_logic_x_base_nonvirtual_function_input_1.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_class_method_65_logic_z_direct_function_input_0`](../../tests/gen/ch8/test_gen_cross_class_method_65_logic_z_direct_function_input_0.sv) |クラス受信者の発送と自動再帰は値と参照引数の意味を保持する| 8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorsinteraction_class_selectpy"></a>

## 生成者: `generators/interaction_class_select.py`

36 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_classsel_129_bit_u_direct_conditional_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_129_bit_u_direct_conditional_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_129_bit_u_nonvirtual_case_known_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_129_bit_u_nonvirtual_case_known_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_129_bit_u_virtual_if_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_129_bit_u_virtual_if_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_129_logic_s_direct_case_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_129_logic_s_direct_case_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_129_logic_s_direct_if_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_129_logic_s_direct_if_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_129_logic_s_virtual_conditional_z_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_129_logic_s_virtual_conditional_z_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_1_bit_s_virtual_if_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_1_bit_s_virtual_if_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_1_bit_u_direct_if_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_1_bit_u_direct_if_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_1_bit_u_nonvirtual_conditional_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_1_bit_u_nonvirtual_conditional_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_1_logic_s_direct_case_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_1_logic_s_direct_case_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_1_logic_s_direct_conditional_x_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_1_logic_s_direct_conditional_x_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_1_logic_u_virtual_case_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_1_logic_u_virtual_case_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_32_bit_u_direct_case_z_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_32_bit_u_direct_case_z_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_32_bit_u_direct_conditional_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_32_bit_u_direct_conditional_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_32_bit_u_nonvirtual_if_x_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_32_bit_u_nonvirtual_if_x_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_32_logic_s_direct_conditional_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_32_logic_s_direct_conditional_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_32_logic_s_virtual_case_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_32_logic_s_virtual_case_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_32_logic_s_virtual_if_known_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_32_logic_s_virtual_if_known_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_33_bit_s_nonvirtual_if_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_33_bit_s_nonvirtual_if_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_33_bit_s_virtual_conditional_x_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_33_bit_s_virtual_conditional_x_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_33_bit_u_nonvirtual_if_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_33_bit_u_nonvirtual_if_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_33_logic_s_nonvirtual_case_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_33_logic_s_nonvirtual_case_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_33_logic_u_direct_case_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_33_logic_u_direct_case_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_33_logic_u_direct_conditional_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_33_logic_u_direct_conditional_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_64_bit_s_direct_conditional_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_64_bit_s_direct_conditional_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_64_bit_s_virtual_case_known_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_64_bit_s_virtual_case_known_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_64_bit_u_direct_case_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_64_bit_u_direct_case_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_64_logic_s_direct_if_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_64_logic_s_direct_if_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_64_logic_u_direct_if_x_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_64_logic_u_direct_if_x_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_64_logic_u_nonvirtual_conditional_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_64_logic_u_nonvirtual_conditional_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_65_bit_s_virtual_conditional_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_65_bit_s_virtual_conditional_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_65_bit_u_direct_case_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_65_bit_u_direct_case_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_65_bit_u_nonvirtual_conditional_z_rebind`](../../tests/gen/ch8/test_gen_cross_classsel_65_bit_u_nonvirtual_conditional_z_rebind.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_65_logic_s_direct_if_known_keep`](../../tests/gen/ch8/test_gen_cross_classsel_65_logic_s_direct_if_known_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 | Verilator 5.052 ||
| [`test_gen_cross_classsel_65_logic_s_nonvirtual_case_x_keep`](../../tests/gen/ch8/test_gen_cross_classsel_65_logic_s_nonvirtual_case_x_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
| [`test_gen_cross_classsel_65_logic_u_direct_if_z_keep`](../../tests/gen/ch8/test_gen_cross_classsel_65_logic_u_direct_if_z_keep.sv) |クラスの呼出し先と型付きの早期returnが、4値の条件選択と保持した参照先を維持する| 8.6 8.12 8.20 11.4.11 11.8.2 12.4 12.5 13.4.1 |標準のみ| x/z |
