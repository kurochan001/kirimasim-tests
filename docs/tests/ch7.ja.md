<a id="clause-7-aggregate-data-types"></a>

# 条項 7: 集計データタイプ

[English](ch7.md) / [日本語](ch7.ja.md)

[すべての章](README.ja.md) .772 304 のテストを生成した。テストのメタデータから `tools/suite_catalog.py` がこのページを書きました。テストを編集しろ このページじゃない

初めて読む場合は、[実在テストを入力から期待値まで読み解く](../faq.md#q49-read-a-real-test)を参照してください。oracle欄は固定版による確認の記録です。[現在のビルドの合格を保証しない理由](../faq.md#q4-are-expected-outputs-copied-from-a-simulator)を確認してください。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_assign_struct`](../../tests/ch7/test_assign_struct.sv) |構造代入のテスト| 7.2 10.9.2 | Verilator 5.052 ||
| [`test_assignment_forms`](../../tests/ch7/test_assignment_forms.sv) |任務形式はブロック，ノンブロック，フォース／リリース，連結，部分選択ターゲットである。| 7.2 7.3 7.4 9.2.2.4 10.4.2 10.6.2 11.4.12 11.5.1 | Icarus Verilog 13.0 ||
| [`test_ct_struct_class_pairs`](../../tests/ch7/test_ct_struct_class_pairs.sv) |T1: ClassInstance メンバーのアクセスと修正| 7.2 7.3 8.4 | Verilator 5.052 ||
| [`test_edge_struct_member_access`](../../tests/ch7/test_edge_struct_member_access.sv) |構造| 7.2 7.2.2 | Verilator 5.052 ||
| [`test_expr_struct`](../../tests/ch7/test_expr_struct.sv) |構造表現テスト| 7.2 7.2.1 10.9.2 | Verilator 5.052 ||
| [`test_ieee1800_2023_struct_union_corner`](../../tests/ch7/test_ieee1800_2023_struct_union_corner.sv) |構造/ユニオンコーナーケース| 7.2 7.2.1 7.3 7.3.1 10.9.2 | Verilator 5.052 ||
| [`test_illegal_rand_member_in_packed_struct`](../../tests/ch7/test_illegal_rand_member_in_packed_struct.sv) |packed構造のメンバーは rand 限定符を持つことができません。 unpacked構造のメンバだけが持つことができる限定符です。| 7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_rand_member_in_union`](../../tests/ch7/test_illegal_rand_member_in_union.sv) |組合のメンバーは rand を持つことができません unpacked 構造のメンバーだけが持つことができる| 7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_struct_c_style_tag`](../../tests/ch7/test_illegal_struct_c_style_tag.sv) |構造宣言は開括弧の前に C スタイルの構造タグを持たない| 7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_union_packed_dimension_without_qualifier`](../../tests/ch7/test_illegal_union_packed_dimension_without_qualifier.sv) |次元が packed のユニオンは packed またはソフトを宣言しなければなりません| 7.2 6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_unpacked_struct_packed_dimension`](../../tests/ch7/test_illegal_unpacked_struct_packed_dimension.sv) |次元が packed の構造は packed で宣言される必要があります| 7.2 6.8 |標準のみ|違法なデザインだ|
| [`test_illegal_void_member_in_struct`](../../tests/ch7/test_illegal_void_member_in_struct.sv) |構造メンバーは タイプボイドを持つことができない。 これは タグ付けされた組合のメンバーにのみ合法なのだ。| 7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_void_member_in_untagged_union`](../../tests/ch7/test_illegal_void_member_in_untagged_union.sv) |タイプヴォイドの組合員は タグ付けされた組合のみで合法です| 7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_member_access`](../../tests/ch7/test_member_access.sv) |メンバーアクセスのテスト| 7.2 7.4 | Icarus Verilog 13.0 ||
| [`test_member_access_2`](../../tests/ch7/test_member_access_2.sv) |クラスと構造のメンバーアクセスパターン| 7.2 8.5 8.13 | Verilator 5.052 ||
| [`test_member_access_3`](../../tests/ch7/test_member_access_3.sv) |テスト: 構造/クラスメンバーアクセス| 7.2 8.4 8.5 | Verilator 5.052 ||
| [`test_member_access_advanced`](../../tests/ch7/test_member_access_advanced.sv) |先進的なメンバーアクセスパターンのテスト| 7.2 7.3 8.5 | Verilator 5.052 ||
| [`test_member_access_patterns`](../../tests/ch7/test_member_access_patterns.sv) |メンバーアクセスパターンテスト| 7.2 7.4 7.10 6.16 | Icarus Verilog 13.0 ||
| [`test_member_access_struct_array`](../../tests/ch7/test_member_access_struct_array.sv) |unpacked 構造と固定サイズ配列の要素のメンバーアクセス| 7.2 7.4 | Verilator 5.052 ||
| [`test_member_ext`](../../tests/ch7/test_member_ext.sv) |テスト1：パック構造体への書き込み| 7.2 8.4 | Verilator 5.052 ||
| [`test_member_struct`](../../tests/ch7/test_member_struct.sv) |構造部材アクセスコーナー事例の試験| 7.2 7.2.1 | Verilator 5.052 ||
| [`test_operator_member`](../../tests/ch7/test_operator_member.sv) |メンバーアクセスオペレータテスト| 7.2 8.5 8.6 | Icarus Verilog 13.0 ||
| [`test_struct_access`](../../tests/ch7/test_struct_access.sv) |構造| 7.2 7.2.1 10.9.2 | Verilator 5.052 ||
| [`test_struct_and_class_members`](../../tests/ch7/test_struct_and_class_members.sv) |パック構造体のメンバ、およびクラスのプロパティとメソッド| 7.2 8.5 8.6 | Icarus Verilog 13.0 ||
| [`test_struct_assign`](../../tests/ch7/test_struct_assign.sv) |テスト: 構造フィールド代入| 7.2 10.9.2 | Verilator 5.052 ||
| [`test_struct_basic`](../../tests/ch7/test_struct_basic.sv) |構造基本テスト| 7.2 | Verilator 5.052 ||
| [`test_struct_basic_edge_cases`](../../tests/ch7/test_struct_basic_edge_cases.sv) |構造基本エッジケース| 7.2 10.9.2 11.2.2 | Verilator 5.052 ||
| [`test_struct_corner`](../../tests/ch7/test_struct_corner.sv) |テスト packed / unpacked 構造、ネストされた構造、構造演算| 7.2 7.2.1 7.2.2 10.9.2 | Verilator 5.052 ||
| [`test_struct_edge`](../../tests/ch7/test_struct_edge.sv) |テスト：構造運用エッジ事例| 7.2 7.2.1 11.4.5 | Verilator 5.052 ||
| [`test_struct_literal`](../../tests/ch7/test_struct_literal.sv) |構造文字テスト| 7.2 10.9.2 | Verilator 5.052 ||
| [`test_struct_member`](../../tests/ch7/test_struct_member.sv) |テスト構造メンバーアクセス| 7.2 | Verilator 5.052 ||
| [`test_struct_member_access`](../../tests/ch7/test_struct_member_access.sv) |構造部品アクセスのテスト| 7.2 7.2.1 7.4 | Verilator 5.052 ||
| [`test_struct_ops`](../../tests/ch7/test_struct_ops.sv) |アンパック構造部品代入、コピーと代入パターン| 7.2 10.9.2 | Verilator 5.052 ||
| [`test_struct_ops_2`](../../tests/ch7/test_struct_ops_2.sv) |構造演算のテスト| 7.2 7.2.1 10.9.2 | Verilator 5.052 ||
| [`test_struct_ops_edge_cases`](../../tests/ch7/test_struct_ops_edge_cases.sv) |テスト：構造操作エッジケース| 7.2 7.2.1 | Verilator 5.052 ||
| [`test_struct_types_edge_cases`](../../tests/ch7/test_struct_types_edge_cases.sv) |構造型エッジケースのテスト| 7.2 7.2.1 10.9.2 | Verilator 5.052 ||
| [`test_struct_union_edge_cases`](../../tests/ch7/test_struct_union_edge_cases.sv) |packedとunpacked構造，ユニオン，ネスティングの構造と結合エッジの場合について述べた。| 7.2 7.2.1 7.3 7.3.1 | Verilator 5.052 ||
| [`test_structs`](../../tests/ch7/test_structs.sv) |第7章 集計データ型| 7.2 7.2.1 | Verilator 5.052 ||
| [`test_structs_edge_cases`](../../tests/ch7/test_structs_edge_cases.sv) |テスト: 構造エッジケース| 7.2 7.2.1 10.9.2 | Verilator 5.052 ||
| [`test_unpacked_struct`](../../tests/ch7/test_unpacked_struct.sv) |アンパック構造テスト| 7.2 10.9.2 | Verilator 5.052 ||
| [`test_unpacked_struct_defaults_and_net_initializer`](../../tests/ch7/test_unpacked_struct_defaults_and_net_initializer.sv) |unpacked 構造はメンバー初期化子を保持し、 明示的な初期化子はそれらを上書きし、 タイプのネットはそれらを無視します。| 7.2 7.2.2 |標準のみ| x/z |
| [`test_cast_struct`](../../tests/ch7/test_cast_struct.sv) |構造キャストのテスト| 7.2.1 6.24.1 | Icarus Verilog 13.0 ||
| [`test_illegal_packed_struct_real_member`](../../tests/ch7/test_illegal_packed_struct_real_member.sv) |packed構造体は、realメンバーを持てない| 7.2.1 6.12 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_packed_struct_unpacked_member`](../../tests/ch7/test_illegal_packed_struct_unpacked_member.sv) |構造 packed には unpacked 配列のメンバーは含まれません。| 7.2.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_unpacked_struct_signed`](../../tests/ch7/test_illegal_unpacked_struct_signed.sv) |unpacked構造体には符号修飾子を付けることはできない。| 7.2.1 7.2 | Verilator 5.052 |違法なデザインだ|
| [`test_packed_array_member_access`](../../tests/ch7/test_packed_array_member_access.sv) |unpacked 配列の packed 構造のメンバーアクセス| 7.2.1 7.4 | Verilator 5.052 ||
| [`test_packed_struct`](../../tests/ch7/test_packed_struct.sv) |平面ベクトルに割り当てられた packed 構造| 7.2.1 | Icarus Verilog 13.0 ||
| [`test_packed_struct_assign`](../../tests/ch7/test_packed_struct_assign.sv) |パック構造体| 7.2.1 10.9.2 | Icarus Verilog 13.0 ||
| [`test_packed_struct_deep_select`](../../tests/ch7/test_packed_struct_deep_select.sv) |テスト: 4 -レベル深い packed 構造部品 + bit -範囲/bit -選択書き戻し| 7.2.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_packed_struct_edge_cases`](../../tests/ch7/test_packed_struct_edge_cases.sv) |テスト：パック構造体の境界ケース| 7.2.1 10.9.2 | Icarus Verilog 13.0 ||
| [`test_packed_struct_member_range_sign`](../../tests/ch7/test_packed_struct_member_range_sign.sv) |構造 packed のメンバーは、選択されたときに宣言された範囲と符号を保持します。| 7.2.1 6.9.1 6.24.1 | Icarus Verilog 13.0 ||
| [`test_packed_struct_state_and_whole_operations`](../../tests/ch7/test_packed_struct_state_and_whole_operations.sv) |すべてのメンバーが 2 つの状態を持つときだけ packed 構造は 2 つの 状態を持つベクトルであり、 2 つの成分を読み書きに変換し、 符号なしで全体演算に参加します。| 7.2.1 |標準のみ| x/z |
| [`test_packed_structs`](../../tests/ch7/test_packed_structs.sv) |テスト packed 構造| 7.2.1 | Icarus Verilog 13.0 ||
| [`test_struct_packed`](../../tests/ch7/test_struct_packed.sv) |テスト packed 構造| 7.2.1 10.9.2 | Icarus Verilog 13.0 ||
| [`test_struct_packed_2`](../../tests/ch7/test_struct_packed_2.sv) |パッケージされた構造 bit 操作| 7.2.1 | Icarus Verilog 13.0 ||
| [`test_struct_union`](../../tests/ch7/test_struct_union.sv) |パック構造体（§7.2）| 7.2.1 7.3.1 | Icarus Verilog 13.0 ||
| [`test_illegal_packed_struct_member_default`](../../tests/ch7/test_illegal_packed_struct_member_default.sv) |構造 packed のメンバーには 個々のデフォルトメンバー値が ありませんが、構造 unpacked のメンバーは 個々のデフォールトメンバー値を持ちます。| 7.2.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_struct_member_default_not_constant`](../../tests/ch7/test_illegal_struct_member_default_not_constant.sv) |構造要素のデフォルト値は定数表現でなければなりません変数はエラーです| 7.2.2 |標準のみ|違法なデザインだ|
| [`test_illegal_union_holding_struct_member_default`](../../tests/ch7/test_illegal_union_holding_struct_member_default.sv) |ユニオンを含む unpacked 構造のメンバーには 個々のデフォルトメンバー値がありません| 7.2.2 |標準のみ|違法なデザインだ|
| [`test_illegal_string_in_untagged_union`](../../tests/ch7/test_illegal_string_in_untagged_union.sv) |動的なタイプはタグ付けされたユニオンのみに属するが タグ付けされていないユニオンには属しません| 7.3 |標準のみ|違法なデザインだ|
| [`test_tagged_union_keywords_and_members`](../../tests/ch7/test_tagged_union_keywords_and_members.sv) |構造とユニオンのキーワードは，ボイドメンバとそのタグを通してのみ読み取れる値メンバを持つタグ付きユニオン，ソフトユニオン，構造内のpacked個の構造，属性を持つ構造メンバ，ランダム限定子，packed種類とunpacked種類の構造メンバである。| 7.3 7.3.2 7.2 A.2.2.1 |標準のみ||
| [`test_union_grammar_forms`](../../tests/ch7/test_union_grammar_forms.sv) |ユニオンは構造/ユニオンメンバー文法を使い ソフト、タグ、packed、サイン、packed次元の形をとります| 7.3 |標準のみ||
| [`test_unpacked_union_default_and_common_initial_sequence`](../../tests/ch7/test_unpacked_union_default_and_common_initial_sequence.sv) |ユニオン unpacked は最初のメンバーのデフォルトを取って 2 つのメンバー構造の共通の初期配列を検査します| 7.3 |標準のみ| x/z |
| [`test_illegal_hard_packed_union_sizes`](../../tests/ch7/test_illegal_hard_packed_union_sizes.sv) |ソフトなもののない packed ユニオンのメンバーは同じサイズでなければなりません。| 7.3.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_packed_union_real_member`](../../tests/ch7/test_illegal_packed_union_real_member.sv) |packed ユニオンには real のような非整数型のメンバーは 存在しません| 7.3.1 6.11.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_packed_nested_member_write`](../../tests/ch7/test_packed_nested_member_write.sv) |7.3：パックされた入れ子のメンバへの書き込みテスト| 7.3.1 7.2.1 | Icarus Verilog 13.0 ||
| [`test_packed_struct_union_dimensions_and_rand_member`](../../tests/ch7/test_packed_struct_union_dimensions_and_rand_member.sv) |packed次元の場合，構造キーワードはpacked次元のキーワードを必要とし，ユニオンキーワードはpacked次元のキーワーズを必要とする。packed構造のpacked配列と packedユニオンのpacked配列は それぞれ12ビットで タグユニオンにボイドメンバーが使われ unpacked構造のrandメンバーはランダム化されています| 7.3.1 7.3.2 A.10 |標準のみ||
| [`test_packed_union`](../../tests/ch7/test_packed_union.sv) |テスト packed ユニオン| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_packed_union_mixed_two_four_state`](../../tests/ch7/test_packed_union_mixed_two_four_state.sv) |packed州連合 2州 4州加盟 4州全体2 0 の状態メンバーを読み込むと x と z は 既知のビットに変換されます| 7.3.1 6.11.2 6.8 |標準のみ| x/z |
| [`test_packed_union_struct_member`](../../tests/ch7/test_packed_union_struct_member.sv) |構造部品とのパッケージ化ユニオン: 両方のビューを読み込み、書き込み| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_packed_union_whole_vector_sign_select`](../../tests/ch7/test_packed_union_whole_vector_sign_select.sv) |一次式として使うpacked共用体は、符号属性（既定はunsigned）に従って算術演算を行う単一ベクタです。そのビットは、\[ n-1 : 0 \]のベクタとして選択できます。| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_soft_packed_union`](../../tests/ch7/test_soft_packed_union.sv) |packed 軟合同のメンバは異なる大きさを持つことができる。組合は最大のものほど広く 各メンバーは低い位置にいる| 7.3.1 7.2.1 | Verilator 5.052 ||
| [`test_soft_packed_union_nested_layout`](../../tests/ch7/test_soft_packed_union_nested_layout.sv) |ソフトpackedユニオンのサイズと右に正しいレイアウトは、直接的に、またはpacked構造を通して、その中にネストされたソフトpackedユニオンにも適用されます。| 7.3.1 7.2.1 | Verilator 5.052 ||
| [`test_union_basic_edge_cases`](../../tests/ch7/test_union_basic_edge_cases.sv) |ユニオン基本辺の場合| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_union_edge`](../../tests/ch7/test_union_edge.sv) |試験：ユニオン操作端の場合| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_union_ops`](../../tests/ch7/test_union_ops.sv) |単語と半分の構造のpacked 結合| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_union_types`](../../tests/ch7/test_union_types.sv) |テストユニオン| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_union_types_edge_cases`](../../tests/ch7/test_union_types_edge_cases.sv) |試験：ユニオン型エッジケース| 7.3.1 | Icarus Verilog 13.0 ||
| [`test_illegal_packed_tagged_union_real_member`](../../tests/ch7/test_illegal_packed_tagged_union_real_member.sv) |packed packed タグ付けされたユニオンのメンバーは、大きさは異なるものの、必ずしも タイプが同じでなければなりません。実在のメンバーはエラーだ| 7.3.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_tagged_union_dynamic_and_chandle_members`](../../tests/ch7/test_tagged_union_dynamic_and_chandle_members.sv) |unpacked タグ付けされたユニオンは、動的タイプのメンバー (文字列、キュー、動的および連想配列、クラスハンドル) と、チャンドルタイプのメンバーを持ち、それらの値を保持します。| 7.3.2 11.9 |標準のみ||
| [`test_tagged_union_packed`](../../tests/ch7/test_tagged_union_packed.sv) |packed タグ付けのユニオンは、最も有意な端に最小の数のタグビットを持ち、各メンバーは右に並べられています。タグ付けの ユニオン表現は、タグとメンバーを一緒にセットし、現在のタグのメンバーはドット記法で読み書きできます。| 7.3.2 11.9 20.6.2 |標準のみ||
| [`test_tagged_union_packed_tag_width_layout`](../../tests/ch7/test_tagged_union_packed_tag_width_layout.sv) |packed タグ付けされたユニオンの幅は、そのメンバー名をコードする最小のタグビットと、最も幅の広いメンバーの幅と同じです。タグは上のビットにあり、各メンバーは下のビットにあります。そして、ネストされたタグ付けユニオンの内部のレイアウトは同じです。| 7.3.2 11.9 20.6.2 |標準のみ||
| [`test_array_access`](../../tests/ch7/test_array_access.sv) |変数のインデックスを always_comb に持つ unpacked 配列を読み込みます。| 7.4 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_array_assign`](../../tests/ch7/test_array_assign.sv) |要素の種類 2 -D, 3 -D, packed を含む unpacked の配列要素を割り当てる| 7.4 | Icarus Verilog 13.0 ||
| [`test_array_elem`](../../tests/ch7/test_array_elem.sv) |配列要素アクセステスト| 7.4 10.9.1 | Icarus Verilog 13.0 ||
| [`test_array_element_access`](../../tests/ch7/test_array_element_access.sv) |ループ中の 1 -D と 2 -D unpacked 配列要素の書き込みと読み込み| 7.4 | Icarus Verilog 13.0 ||
| [`test_array_element_assign`](../../tests/ch7/test_array_element_assign.sv) |配列要素代入のテスト| 7.4 | Icarus Verilog 13.0 ||
| [`test_array_index`](../../tests/ch7/test_array_index.sv) |配列インデックステスト| 7.4 | Icarus Verilog 13.0 ||
| [`test_array_index_basic`](../../tests/ch7/test_array_index_basic.sv) |テスト配列インデックス| 7.4 | Icarus Verilog 13.0 ||
| [`test_array_indexing`](../../tests/ch7/test_array_indexing.sv) |テスト: 配列要素アクセス \[ と \]| 7.4 7.5 7.8 7.10 11.5.1 | Verilator 5.052 ||
| [`test_array_init`](../../tests/ch7/test_array_init.sv) |配列初期化テスト| 7.4 10.9.1 20.7 | Verilator 5.052 ||
| [`test_array_loops_and_strings`](../../tests/ch7/test_array_loops_and_strings.sv) |配列ループ、フォーエイク、文字列長、連結| 7.4 12.7.3 6.16 | Icarus Verilog 13.0 ||
| [`test_array_select`](../../tests/ch7/test_array_select.sv) |テスト配列選択| 7.4 11.5.1 | Icarus Verilog 13.0 ||
| [`test_array_slicing_edge_cases`](../../tests/ch7/test_array_slicing_edge_cases.sv) |テスト: 配列スライシングエッジケース| 7.4 11.5.1 | Icarus Verilog 13.0 ||
| [`test_assign_index`](../../tests/ch7/test_assign_index.sv) |索引付き代入| 7.4 12.7.3 | Icarus Verilog 13.0 ||
| [`test_declaration_range_forms`](../../tests/ch7/test_declaration_range_forms.sv) |定数範囲によるパック次元、定数範囲および定数式による複数のunpacked次元、データ型およびアスタリスク添字による連想配列次元、上限の有無を含むキュー次元、動的配列のサイズ未指定次元、およびこれらから構成する変数次元。| 7.4 7.5 7.8 7.10 A.2.5 | Verilator 5.052 ||
| [`test_mem`](../../tests/ch7/test_mem.sv) |様々な配列タイプ| 7.4 7.5 7.8 7.10 | Verilator 5.052 ||
| [`test_memory_array_ops`](../../tests/ch7/test_memory_array_ops.sv) |様々なメモリと配列操作をテストします| 7.4 7.5 7.8 7.10 7.12 | Verilator 5.052 ||
| [`test_memory_edge_cases`](../../tests/ch7/test_memory_edge_cases.sv) |メモリと配列のエッジケース：初期化，境界，動的配列，キュー，連想配列| 7.4 7.5 7.8 7.10 | Verilator 5.052 ||
| [`test_unpacked_types_edge_cases`](../../tests/ch7/test_unpacked_types_edge_cases.sv) |テスト：アンパック型の境界ケース| 7.4 7.4.2 7.2 | Verilator 5.052 ||
| [`test_value_unpacked`](../../tests/ch7/test_value_unpacked.sv) |unpacked 配列値操作のテスト| 7.4 7.6 11.2.2 | Verilator 5.052 ||
| [`test_array_ranges_and_invalid_indices`](../../tests/ch7/test_array_ranges_and_invalid_indices.sv) |packed の範囲は降下、上昇、負のエンドポイントを受け入れます。unpacked のサイズは \[ 0:size-1 \] を意味します。無効なインデックスはテーブルの値を読み込み、何も書き込みません。| 7.4.1 7.4.2 7.4.5 |標準のみ| x/z |
| [`test_bit_select`](../../tests/ch7/test_bit_select.sv) |ビット選択とパート選択| 7.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_illegal_int_packed_dimension`](../../tests/ch7/test_illegal_int_packed_dimension.sv) |integer 型の予定された幅 ここでは int は packed の配列次元で宣言できません| 7.4.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_packed_array_of_real`](../../tests/ch7/test_illegal_packed_array_of_real.sv) |packed 配列には実数要素は含まれません| 7.4.1 6.12 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_packed_dimension_single_size`](../../tests/ch7/test_illegal_packed_dimension_single_size.sv) |次元 packed には 2つの境界を持つ範囲が必要です次元が unpacked の場合のみ \[ 8 \] のような単一のサイズが許可されます| 7.4.1 7.4.2 | Verilator 5.052 |違法なデザインだ|
| [`test_integer_atom_types_match_vector_types`](../../tests/ch7/test_integer_atom_types_match_vector_types.sv) |すべての integer 型は 予め定義された幅 n で packed 型と同じ状態、符号、単一次元 \[ n-1:0 \] を持ち、どちらかで異なるベクトル型はありません| 7.4.1 6.22.1 6.23 |標準のみ||
| [`test_mixed_packed`](../../tests/ch7/test_mixed_packed.sv) |混合 packed / unpacked 配列| 7.4.1 7.4.2 7.4.5 | Icarus Verilog 13.0 ||
| [`test_multidim_packed_vector`](../../tests/ch7/test_multidim_packed_vector.sv) |ネストされた生成ループから、bit が bit により駆動される二次元 packed ベクトル| 7.4.1 7.4.5 27.4 | Icarus Verilog 13.0 ||
| [`test_packed_2d`](../../tests/ch7/test_packed_2d.sv) |2D packed 配列| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_3d`](../../tests/ch7/test_packed_3d.sv) |3D packed 配列| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_48bit_arithmetic_and_integer_selects`](../../tests/ch7/test_packed_48bit_arithmetic_and_integer_selects.sv) |48 - bit packedベクトルは 48ビットでintegerの算術を行い integerのタイプは \[ n-1:0 \]のように 選択できる| 7.4.1 7.4.5 | Icarus Verilog 13.0 ||
| [`test_packed_arr`](../../tests/ch7/test_packed_arr.sv) |パッケージ配列テスト| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_array`](../../tests/ch7/test_packed_array.sv) |パッケージ配列テスト| 7.4.1 7.2.1 | Icarus Verilog 13.0 ||
| [`test_packed_array_2`](../../tests/ch7/test_packed_array_2.sv) |平面ベクトルに割り当てられた packed 配列| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_array_access`](../../tests/ch7/test_packed_array_access.sv) |パッケージ配列ビット/スライスアクセステスト| 7.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_packed_array_bitsel_write`](../../tests/ch7/test_packed_array_bitsel_write.sv) |ブロックとノンブロックは二次元packed配列の要素の1つのbitに書き込む| 7.4.1 7.4.5 11.5.1 10.4.2 | Icarus Verilog 13.0 ||
| [`test_packed_array_dims`](../../tests/ch7/test_packed_array_dims.sv) |パッケージ配列次元インデックスアクセステスト| 7.4.1 7.3.1 | Icarus Verilog 13.0 ||
| [`test_packed_array_edge_cases`](../../tests/ch7/test_packed_array_edge_cases.sv) |テスト: パッケージ配列エッジケース| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_array_element_width`](../../tests/ch7/test_packed_array_element_width.sv) |パッケージ配列要素幅テスト| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_array_whole_element_part_sign`](../../tests/ch7/test_packed_array_whole_element_part_sign.sv) |packed unpacked の配列は、その名前のタイプがサインされていない限り、その要素がサインされていない間は、全体としてサインされています。 part-select はサインされていませんが、サインされている配列はその要素に適用されます。| 7.4.1 7.4.6 | Icarus Verilog 13.0 ||
| [`test_packed_arrays`](../../tests/ch7/test_packed_arrays.sv) |第7章 集計データ型| 7.4.1 7.4.2 | Icarus Verilog 13.0 ||
| [`test_packed_assign`](../../tests/ch7/test_packed_assign.sv) |テスト: パッケージ配列/構造代入| 7.4.1 7.2.1 | Verilator 5.052 ||
| [`test_packed_basic`](../../tests/ch7/test_packed_basic.sv) |パッケージ配列の基本的なテスト| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_packed_dimension_constant_ranges`](../../tests/ch7/test_packed_dimension_constant_ranges.sv) |次元packedは括弧付きの定数範囲であり、その境界はリテラル、ローカルパラメータ、定数表現、上昇または下降、負であることができる。各次元はそれぞれ独自のインデックス空間である。| 7.4.1 A.2.5 | Icarus Verilog 13.0 ||
| [`test_packed_vector_65536_bits`](../../tests/ch7/test_packed_vector_65536_bits.sv) |ツールが許容する最小最大サイズである 65536 ビットの packed 配列を宣言し、両端で選択し、その全幅で算術的に使用できます。| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_value_packed`](../../tests/ch7/test_value_packed.sv) |packed 値演算のテスト| 7.4.1 | Icarus Verilog 13.0 ||
| [`test_widths_edge_cases`](../../tests/ch7/test_widths_edge_cases.sv) |テスト: ビット幅のエッジケース| 7.4.1 10.7 | Icarus Verilog 13.0 ||
| [`test_illegal_unpacked_range_x_bound`](../../tests/ch7/test_illegal_unpacked_range_x_bound.sv) |固定サイズの次元 unpacked の境界は x bit を含めない| 7.4.2 | Verilator 5.052 |違法なデザイン x/z|
| [`test_illegal_unpacked_range_z_bound`](../../tests/ch7/test_illegal_unpacked_range_z_bound.sv) |固定サイズの次元 unpacked の境界は z bit を含めない| 7.4.2 | Verilator 5.052 |違法なデザイン x/z|
| [`test_memory_array_access`](../../tests/ch7/test_memory_array_access.sv) |メモリ (unpacked 配列) 要素へのアクセスとコピー| 7.4.2 7.4.4 | Icarus Verilog 13.0 ||
| [`test_multidim_unpacked`](../../tests/ch7/test_multidim_unpacked.sv) |アンパック配列| 7.4.2 7.4.5 | Icarus Verilog 13.0 ||
| [`test_net_array_elements_and_whole_array_assign`](../../tests/ch7/test_net_array_elements_and_whole_array_assign.sv) |ネット配列の要素をベクトルネットとして連続代入、表現、ポート接続に用い、可変配列から全ネット配列を左から右に要素ごとに代入、逆にする。| 7.4.2 7.6 | Verilator 5.052 ||
| [`test_reg_memory`](../../tests/ch7/test_reg_memory.sv) |レギュラー配列メモリ操作| 7.4.2 | Icarus Verilog 13.0 ||
| [`test_unpack_arr`](../../tests/ch7/test_unpack_arr.sv) |アンパック配列のテスト| 7.4.2 | Icarus Verilog 13.0 ||
| [`test_unpacked_2d`](../../tests/ch7/test_unpacked_2d.sv) |2D unpacked 配列| 7.4.2 | Icarus Verilog 13.0 ||
| [`test_unpacked_3d`](../../tests/ch7/test_unpacked_3d.sv) |3D unpacked 配列| 7.4.2 | Icarus Verilog 13.0 ||
| [`test_unpacked_array_16777216_elements`](../../tests/ch7/test_unpacked_array_16777216_elements.sv) |unpacked 16777216 要素の配列が宣言され、その最初と最後の要素が書き込まれ、読み込まれます。| 7.4.2 | Icarus Verilog 13.0 ||
| [`test_memory_descending_word_indices`](../../tests/ch7/test_memory_descending_word_indices.sv) |packed ワードを独立に保持する負の降下指数を持つメモリ| 7.4.3 | Icarus Verilog 13.0 ||
| [`test_memory_words`](../../tests/ch7/test_memory_words.sv) |logic , bitまたはregの要素からなる一次元配列はメモリであり、各要素はそのアドレスによって書き込まれ読み込まれる単語であり、アドレスの後に単語の一部が選択できる。| 7.4.3 7.4.1 7.4.6 | Icarus Verilog 13.0 | x/z |
| [`test_copy_row_of_unpacked_struct_array`](../../tests/ch7/test_copy_row_of_unpacked_struct_array.sv) |二次元配列の unpacked 構造の行は、全体として読み書きできる配列である。| 7.4.4 7.6 | Verilator 5.052 ||
| [`test_multidim_typedef_stages_and_shared_declaration`](../../tests/ch7/test_multidim_typedef_stages_and_shared_declaration.sv) |packed次元とunpacked次元はtypedef次元を段階的に構築すると，typedef次元の次元をより速く変化するものとして保持し，1つのコンマ分離宣言の配列はデータ型とpacked次元を共有するが，unpacked次元は異なる。| 7.4.4 20.7 | Verilator 5.052 ||
| [`test_array_index_and_size_signatures`](../../tests/ch7/test_array_index_and_size_signatures.sv) |不正な配列添字の読取りは既定値を返し、書込みは行わない。警告は任意であり、動的配列のsizeは引数なしでintを返す| 7.4.5 7.5.2 | Icarus Verilog 13.0 ||
| [`test_array_index_wider_than_64_bits`](../../tests/ch7/test_array_index_wider_than_64_bits.sv) |unpacked 64 ビットより広い配列のインデックスは、その整数値で選択されます。| 7.4.5 11.4.10 |標準のみ||
| [`test_array_invalid_index_read_aggregates`](../../tests/ch7/test_array_invalid_index_read_aggregates.sv) |要素がキュー、動的または連想配列、固定サイズ配列、unpacked 構造、または無効なインデックスを持つ unpacked ユニオンの unpacked 配列を読むと、空の配列、デフォルト要素の配列、デフォールトメンバーの構造 (または初期代入)、最初のユニオンメンバーのデフォルトが返されます。| 7.4.5 |標準のみ| x/z |
| [`test_array_invalid_index_read_chandle`](../../tests/ch7/test_array_invalid_index_read_chandle.sv) |チャンドルの unpacked 配列を読み込むと、 C コードが非ヌルポインタに設定した範囲外のインデックスまたは x の bit を含むインデックスは null になります。| 7.4.5 6.14 |標準のみ| DPI, x/z |
| [`test_array_invalid_index_read_handles_real_string`](../../tests/ch7/test_array_invalid_index_read_handles_real_string.sv) |real、shortreal、string、class、interface class、event、仮想interfaceを要素とするunpacked配列を、範囲外またはxのbitを含む添字で読むと、0.0、空文字列、またはnullを返す| 7.4.5 |標準のみ| x/z |
| [`test_contassign_packed_element_of_unpacked`](../../tests/ch7/test_contassign_packed_element_of_unpacked.sv) |unpacked 配列の要素のpacked 要素に連続的に代入る| 7.4.5 6.5 10.3.2 | Icarus Verilog 13.0 ||
| [`test_illegal_part_select_variable_width`](../../tests/ch7/test_illegal_part_select_variable_width.sv) |選択した部分の幅は一定である必要があり 位置は可変です| 7.4.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_slice_of_two_dimensions`](../../tests/ch7/test_illegal_slice_of_two_dimensions.sv) |1つのスライスは配列の1次元にしか適用できません 他の次元は単一のインデックスを持つことができます| 7.4.5 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_slice_variable_width`](../../tests/ch7/test_illegal_slice_variable_width.sv) |unpacked 配列のスライスのサイズは一定でなければなりません| 7.4.5 | Verilator 5.052 |違法なデザインだ|
| [`test_multi_dim_assign`](../../tests/ch7/test_multi_dim_assign.sv) |テスト：多次元配列代入| 7.4.5 7.4.2 | Verilator 5.052 ||
| [`test_mux8_edge_cases`](../../tests/ch7/test_mux8_edge_cases.sv) |8 - to-1 マルチプレクサエッジケース| 7.4.5 10.3.2 | Icarus Verilog 13.0 ||
| [`test_packed_parameter_element_select`](../../tests/ch7/test_packed_parameter_element_select.sv) |localparam packed 次元のパラメータの要素は，それらの宣言した指数により，上昇または下降順に選択される。| 7.4.5 6.20.1 7.4.1 | Verilator 5.052 ||
| [`test_array_nba_part_select_index`](../../tests/ch7/test_array_nba_part_select_index.sv) |非ブロック代入を持つメモリに書き込まれ、ポインタの部分選択によってインデックスされる FIFO| 7.4.6 10.4.2 11.5.1 | Icarus Verilog 13.0 ||
| [`test_array_whole_slice_equality_operations`](../../tests/ch7/test_array_whole_slice_equality_operations.sv) |固定 unpacked , packed 、動的、キュー、連想配列は全体を読み書きし、 with == と!= を比較します。可変位置の定幅スライスはコピーされ、比較されます。 packed 配列のスライスは packed で、 unpacked 配列の スライスは unpacked です。| 7.4.6 7.4.5 | Verilator 5.052 ||
| [`test_illegal_associative_array_slice`](../../tests/ch7/test_illegal_associative_array_slice.sv) |連想配列はスライスできませんが 読み書きでき 要素ごとに比較できます| 7.4.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_unpacked_array_assigned_integer`](../../tests/ch7/test_illegal_unpacked_array_assigned_integer.sv) |integer は packed に割り当てられますが unpacked には割り当てられません| 7.4.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_unpacked_array_in_integer_expression`](../../tests/ch7/test_illegal_unpacked_array_in_integer_expression.sv) |packedの配列は表現の中でintegerとして使えますが unpackedの配列は使えません| 7.4.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_dyn_array_edge`](../../tests/ch7/test_dyn_array_edge.sv) |テスト：動的配列エッジケース| 7.5 7.5.1 7.5.2 7.5.3 | Verilator 5.052 ||
| [`test_dyn_array_edge_cases`](../../tests/ch7/test_dyn_array_edge_cases.sv) |テスト：動的配列エッジケース| 7.5 | Icarus Verilog 13.0 ||
| [`test_dyn_resize`](../../tests/ch7/test_dyn_resize.sv) |動的配列サイズ変更テスト| 7.5 7.5.1 7.5.3 | Verilator 5.052 ||
| [`test_dynamic_arr_edge_cases`](../../tests/ch7/test_dynamic_arr_edge_cases.sv) |動的配列エッジケース| 7.5 | Icarus Verilog 13.0 ||
| [`test_dynamic_array`](../../tests/ch7/test_dynamic_array.sv) |動的配列（§7.5）| 7.5 | Icarus Verilog 13.0 ||
| [`test_dynamic_array_2`](../../tests/ch7/test_dynamic_array_2.sv) |動的配列のnew \[ \]、コピーを伴うサイズ変更、size()、delete()| 7.5 | Icarus Verilog 13.0 ||
| [`test_dynamic_array_corner`](../../tests/ch7/test_dynamic_array_corner.sv) |動的な配列操作、サイズ変更、メソッドをテスト| 7.5 7.12 7.5.1 | Verilator 5.052 ||
| [`test_dynamic_array_edge_cases`](../../tests/ch7/test_dynamic_array_edge_cases.sv) |テスト：動的配列エッジケース| 7.5 7.5.1 7.5.2 7.5.3 | Icarus Verilog 13.0 | x/z |
| [`test_dynamic_array_methods`](../../tests/ch7/test_dynamic_array_methods.sv) |IEEE 1800-2023 §7.5-7.6のテスト：動的配列メソッド| 7.5 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_dynamic_array_ops`](../../tests/ch7/test_dynamic_array_ops.sv) |動的配列操作のテスト| 7.5 7.5.1 | Icarus Verilog 13.0 ||
| [`test_sv_dynamic_array`](../../tests/ch7/test_sv_dynamic_array.sv) |動的配列：new \[ \]、コピーを伴うサイズ変更、size()、delete()| 7.5 7.5.1 7.5.3 | Icarus Verilog 13.0 ||
| [`test_value_dynamic`](../../tests/ch7/test_value_dynamic.sv) |動的配列値演算のテスト| 7.5 7.5.1 7.5.3 | Verilator 5.052 ||
| [`test_dyn_array_basic`](../../tests/ch7/test_dyn_array_basic.sv) |動的配列基本テスト| 7.5.1 7.5.2 | Icarus Verilog 13.0 ||
| [`test_dyn_array_method`](../../tests/ch7/test_dyn_array_method.sv) |動的配列メソッドのテスト| 7.5.1 7.5.2 7.5.3 | Icarus Verilog 13.0 ||
| [`test_dyn_array_new`](../../tests/ch7/test_dyn_array_new.sv) |動的配列のnewのテスト| 7.5.1 | Icarus Verilog 13.0 ||
| [`test_dyn_array_ops`](../../tests/ch7/test_dyn_array_ops.sv) |動的配列操作テスト| 7.5.1 7.5.3 | Icarus Verilog 13.0 ||
| [`test_dynamic_array_edge`](../../tests/ch7/test_dynamic_array_edge.sv) |動的配列エッジケース| 7.5.1 7.5.2 7.5.3 7.6 | Icarus Verilog 13.0 ||
| [`test_dynamic_array_new_discards_data_and_references`](../../tests/ch7/test_dynamic_array_new_discards_data_and_references.sv) |動的配列をnew \[ \]でサイズ変更または再初期化すると、元の配列を初期化式に指定しない限り、データを破棄する。また、どの場合でも要素への参照は古い参照となる| 7.5.1 13.5.2 |標準のみ||
| [`test_dynamic_array_new_forms_order_and_size`](../../tests/ch7/test_dynamic_array_new_forms_order_and_size.sv) |動的配列を拡大する new \[ \] は、宣言またはブロック代入の動的配列のサイズを変更し、初期化前にそのサイズを評価し、左端の unpacked 次元が動的な識別子のみを動的配列にする。 size() は $size (配列、1 ) に等しい int であり、 delete() は配列を空にします。| 7.5.1 7.5 7.5.2 7.5.3 20.7 | Verilator 5.052 ||
| [`test_dynamic_array_queue_size`](../../tests/ch7/test_dynamic_array_queue_size.sv) |new \[ \]、サイズ変更、push_back、delete後の動的配列とキューのサイズ| 7.5.1 7.5.2 7.5.3 7.10.2 | Icarus Verilog 13.0 ||
| [`test_dynamic_resize`](../../tests/ch7/test_dynamic_resize.sv) |動的配列の新規作成、サイズ変更、削除操作| 7.5.1 | Icarus Verilog 13.0 ||
| [`test_edge_dynamic_array_resize`](../../tests/ch7/test_edge_dynamic_array_resize.sv) |動的配列のnew \[ \]とnew \[ \](old)によるサイズ変更。new \[ 0 \]も含む| 7.5.1 7.5.2 | Verilator 5.052 ||
| [`test_illegal_dynamic_new_initializer_other_element_type`](../../tests/ch7/test_illegal_dynamic_new_initializer_other_element_type.sv) |動的配列のnewコンストラクタの初期化式は、その動的配列へ代入互換な配列でなければならない。byte要素の配列は該当しないとされていますが、比較対象や後続条件は不明です。原文は「for an array of int」で途切れています。| 7.5.1 7.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_dynamic_new_nonblocking_assignment`](../../tests/ch7/test_illegal_dynamic_new_nonblocking_assignment.sv) |動的配列のnewコンストラクタは、宣言内代入またはブロッキング代入の右辺にはできるが、ノンブロッキング代入の右辺にはできない| 7.5.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_dynamic_new_to_fixed_array`](../../tests/ch7/test_illegal_dynamic_new_to_fixed_array.sv) |動的配列のnewコンストラクタは動的配列にだけ代入でき、固定サイズ配列には代入できない| 7.5.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_dynamic_new_to_slice`](../../tests/ch7/test_illegal_dynamic_new_to_slice.sv) |動的配列のnewコンストラクタの対象は、範囲選択を付けずに名前を指定した動的配列である。動的配列のスライスは許可されません| 7.5.1 | Verilator 5.052 |違法なデザインだ|
| [`test_syntax_dynamic_array_new_assignment`](../../tests/ch7/test_syntax_dynamic_array_new_assignment.sv) |new \[ size \]とnew \[ size \](init)を、動的配列変数および動的配列の配列要素へブロッキング代入すると、サイズと要素が設定される| 7.5.1 A.6.2 | Verilator 5.052 ||
| [`test_dynamic_array_and_queue_operations`](../../tests/ch7/test_dynamic_array_and_queue_operations.sv) |動的配列はnewでサイズを変更し、deleteで空にする。キューは代入するキューのサイズになり、上限付きキューでは上限を超える要素を捨てる| 7.5.2 7.5.3 7.10.1 7.10.2 7.10.2.2 7.10.2.3 7.10.2.6 7.10.2.7 | Icarus Verilog 13.0 ||
| [`test_dynamic_array_size_edge`](../../tests/ch7/test_dynamic_array_size_edge.sv) |動的配列サイズ() のエッジケースをテスト| 7.5.2 | Verilator 5.052 ||
| [`test_dyn_array_delete`](../../tests/ch7/test_dyn_array_delete.sv) |テスト動的配列削除| 7.5.3 | Icarus Verilog 13.0 ||
| [`test_array_assign_2`](../../tests/ch7/test_array_assign_2.sv) |テスト配列代入| 7.6 7.5 10.9.1 | Verilator 5.052 ||
| [`test_array_assign_resize_concat_source_slice_overlap`](../../tests/ch7/test_array_assign_resize_concat_source_slice_overlap.sv) |動的配列またはキューに代入ると、ソース要素の数に合わせてサイズを変更します。ソースはスライスとアイテムの unpacked 配列連結であり、スライスへの代入は1つの代入です。つまり、1つの配列内の重複コピーは古い値を移動します。| 7.6 10.10 |標準のみ||
| [`test_array_copy`](../../tests/ch7/test_array_copy.sv) |配列コピーテスト| 7.6 7.4 | Verilator 5.052 ||
| [`test_assign_array`](../../tests/ch7/test_assign_array.sv) |配列代入| 7.6 10.4.1 | Verilator 5.052 ||
| [`test_illegal_array_inner_dimension_size_mismatch`](../../tests/ch7/test_illegal_array_inner_dimension_size_mismatch.sv) |配列代入は 最も遅い次元の種類を変えることもできますが 速い次元は等価でなければなりません4 の要素は 3 の要素に移動できません| 7.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_array_unpacked_dimension_count_mismatch`](../../tests/ch7/test_illegal_array_unpacked_dimension_count_mismatch.sv) |unpacked 次元数が同じならば、配列は代入互換性があります。| 7.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_associative_array_from_dynamic_array`](../../tests/ch7/test_illegal_associative_array_from_dynamic_array.sv) |連想配列は 連想配列とのみ 代入が互換性がありますその対象へ動的配列を代入することはできない| 7.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_fixed_array_assignment_element_count`](../../tests/ch7/test_illegal_fixed_array_assignment_element_count.sv) |固定サイズの unpacked 配列に代入るには 同じ数の要素を持つソースが必要です| 7.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_fixed_array_element_type_not_equivalent`](../../tests/ch7/test_illegal_fixed_array_element_type_not_equivalent.sv) |これは、unpacked 配列が、それらの要素タイプが等価であればのみ代入互換性を持つことを意味します。byte 要素は int 配列に移動できません| 7.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_fixed_array_from_associative_array`](../../tests/ch7/test_illegal_fixed_array_from_associative_array.sv) |連想配列は 連想配列とのみ 代入が互換性があります固定サイズの配列に割り当てられない| 7.6 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_queue_element_type_not_equivalent`](../../tests/ch7/test_illegal_queue_element_type_not_equivalent.sv) |要素のタイプが等価であれば、キューは他の配列との代入が互換性があります。shortint 要素は int キューに移動できません| 7.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_slice_assignment_element_count`](../../tests/ch7/test_illegal_slice_assignment_element_count.sv) |unpacked 配列のスライスに代入るには、スライスと同じ要素数のソースが必要です。| 7.6 7.4.5 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_slice_element_type_not_equivalent`](../../tests/ch7/test_illegal_slice_element_type_not_equivalent.sv) |固定サイズの配列のスライスは 元素タイプが等しいときにのみ 他の配列と代入が互換性があります| 7.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_unpacked_array_from_packed_array`](../../tests/ch7/test_illegal_unpacked_array_from_packed_array.sv) |明示的なキャストなしに packed 配列を直接 unpacked 配列に割り当てることはできません| 7.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_array_args_by_value_ref`](../../tests/ch7/test_array_args_by_value_ref.sv) |値で渡された配列はコピーされます。動的配列、キュー、連想配列も同様です。ref 引数は呼び出し者の配列です。| 7.7 7.9.10 13.5.2 13.5.1 | Verilator 5.052 ||
| [`test_array_argument_fixed_dynamic_queue_compatibility`](../../tests/ch7/test_array_argument_fixed_dynamic_queue_compatibility.sv) |配列の実引数は配列代入の規則に従う。固定サイズの仮引数は、範囲が異なる固定配列や同サイズの動的配列／キューを受け取る。サイズ未指定の動的配列／キューの仮引数は、任意サイズの固定配列・動的配列・キューを受け取り、要素を左から右へ対応付ける| 7.7 7.6 |標準のみ||
| [`test_dpi_open_and_unsized_packed`](../../tests/ch7/test_dpi_open_and_unsized_packed.sv) |オープンなunpacked仮引数は、動的配列をそのサイズと範囲で受け取り、単一のサイズ未指定packed仮引数は、実引数の全幅を受け取る| 7.7 |標準のみ| DPI |
| [`test_illegal_dynamic_array_to_dpi_open_output`](../../tests/ch7/test_illegal_dynamic_array_to_dpi_open_output.sv) |サイズ未指定の次元とoutput方向を持つDPIのimport仮引数には、動的配列を実引数として渡せない| 7.7 |標準のみ|違法なデザインだ|
| [`test_2d_assoc_methods`](../../tests/ch7/test_2d_assoc_methods.sv) |テスト: 2D 連想配列メソッド (.exists,.first,.next,.delete)| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array`](../../tests/ch7/test_assoc_array.sv) |連想配列| 7.8 7.9.1 7.9.2 7.9.3 | Verilator 5.052 ||
| [`test_assoc_array_2`](../../tests/ch7/test_assoc_array_2.sv) |文字列と int キーを持つ連想配列: lookup, size, exists, delete| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array_assign`](../../tests/ch7/test_assoc_array_assign.sv) |テスト: 連想配列代入| 7.8 7.8.1 7.8.2 | Verilator 5.052 ||
| [`test_assoc_array_edge`](../../tests/ch7/test_assoc_array_edge.sv) |結合型配列エッジケース| 7.8 7.9 7.9.1 | Verilator 5.052 ||
| [`test_assoc_array_edge_2`](../../tests/ch7/test_assoc_array_edge_2.sv) |テスト：連想配列エッジケース| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array_edge_cases`](../../tests/ch7/test_assoc_array_edge_cases.sv) |結合型配列エッジケース| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array_edge_cases_2`](../../tests/ch7/test_assoc_array_edge_cases_2.sv) |テスト：連想配列エッジケース| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array_edge_cases_3`](../../tests/ch7/test_assoc_array_edge_cases_3.sv) |テスト：連想配列エッジケース| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array_extended`](../../tests/ch7/test_assoc_array_extended.sv) |テスト連想配列| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_array_iterate`](../../tests/ch7/test_assoc_array_iterate.sv) |連想配列反復のテスト| 7.8 7.9 7.9.4 7.9.5 | Verilator 5.052 ||
| [`test_assoc_array_methods`](../../tests/ch7/test_assoc_array_methods.sv) |IEEE 1800-2023 § 7.8 のテスト: 連想配列法| 7.8 7.9 7.9.1 7.9.2 7.9.3 7.9.4 7.9.5 7.9.6 7.9.7 | Verilator 5.052 ||
| [`test_assoc_array_ops`](../../tests/ch7/test_assoc_array_ops.sv) |連想配列演算テスト| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_basic`](../../tests/ch7/test_assoc_basic.sv) |連想配列基本テスト| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_int_key`](../../tests/ch7/test_assoc_int_key.sv) |int キーで連想配列をテスト| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_key`](../../tests/ch7/test_assoc_key.sv) |連想配列キーテスト| 7.8 | Verilator 5.052 ||
| [`test_assoc_ops`](../../tests/ch7/test_assoc_ops.sv) |連想配列演算テスト| 7.8 7.9 | Verilator 5.052 ||
| [`test_associative_array`](../../tests/ch7/test_associative_array.sv) |7.8 の関連付け行列| 7.8 7.9 | Verilator 5.052 ||
| [`test_associative_array_copy_order_and_delete`](../../tests/ch7/test_associative_array_copy_order_and_delete.sv) |関連性配列は全体をコピーして比較し、 符号 int の順序でインデックスをエナミーし、 欠けているエントリに対して Table 7-1 値を返し、 1 つまたは全てのエントリを削除します。| 7.8 7.8.5 7.9.2 |標準のみ| x/z |
| [`test_associative_array_corner`](../../tests/ch7/test_associative_array_corner.sv) |種々のインデックスタイプでの連想配列演算をテスト| 7.8 7.9 7.8.1 7.8.3 | Verilator 5.052 ||
| [`test_illegal_assoc_index_declares_enum`](../../tests/ch7/test_illegal_assoc_index_declares_enum.sv) |関連型配列のインデックスタイプは、自身で型を宣言できません。例えば、エナメル型は、| 7.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_assoc_index_declares_struct`](../../tests/ch7/test_illegal_assoc_index_declares_struct.sv) |関連型配列のインデックスタイプは、自分でタイプを宣言できません。例えば、packed構造タイプは、| 7.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_sv_assoc_array`](../../tests/ch7/test_sv_assoc_array.sv) |テスト: 連想配列: int map \[ string \], exists(), first(), next(), delete(), num()| 7.8 7.9 | Verilator 5.052 ||
| [`test_value_assoc`](../../tests/ch7/test_value_assoc.sv) |連想配列値演算のテスト| 7.8 7.9 | Verilator 5.052 ||
| [`test_assoc_wildcard_string_literal_bits`](../../tests/ch7/test_assoc_wildcard_string_literal_bits.sv) |文字列リテラルワイルドカードキーエリアス 等幅 packed 整数値| 7.8.1 | Verilator 5.052 |出口コード|
| [`test_assoc_wildcard_width_and_sign_aliases`](../../tests/ch7/test_assoc_wildcard_width_and_sign_aliases.sv) |ワイルドカードキーは前のゼロを正規化し、任意の幅の符号なしの値を保持します| 7.8.1 7.8 | Verilator 5.052 |出口コード|
| [`test_illegal_wildcard_array_find`](../../tests/ch7/test_illegal_wildcard_array_find.sv) |ワイルドカードインデックス型の関連付け式配列には find() のような値の配列を返す配列操作メソッドは許可されていません。| 7.8.1 7.12.1 |標準のみ|違法なデザインだ|
| [`test_illegal_wildcard_array_foreach`](../../tests/ch7/test_illegal_wildcard_array_foreach.sv) |ワイルドカード添字型の連想配列は、foreachループで使用できない| 7.8.1 12.7.3 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_wildcard_find_index`](../../tests/ch7/test_illegal_wildcard_find_index.sv) |ワイルドカード連想配列はインデックス値を返す配列メソッドを使えません| 7.8.1 7.12 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_wildcard_index_real`](../../tests/ch7/test_illegal_wildcard_index_real.sv) |ワードログインデックス型の連想配列のインデックスは 整数でなければなりません実際の指標は誤りで| 7.8.1 | Verilator 5.052 |違法なデザインだ|
| [`test_assoc_string_empty_and_reverse_order`](../../tests/ch7/test_assoc_string_empty_and_reverse_order.sv) |文字列の関連キーは空の文字列を含み、prev は逆の語彙順序を追従します。| 7.8.2 7.9.7 7.9.11 | Verilator 5.052 ||
| [`test_illegal_string_index_with_int`](../../tests/ch7/test_illegal_string_index_with_int.sv) |文字列インデックスを持つ連想配列は 文字列と文字列リテラルをインデックスとして受け入れますint のインデックスは タイプチェックエラーです| 7.8.2 |標準のみ|違法なデザインだ|
| [`test_assoc_class_key_order_is_stable`](../../tests/ch7/test_assoc_class_key_order_is_stable.sv) |固定の集合に対して、アドレス順序を指定せずにクラスキートラヴァースを繰り返す| 7.8.3 | Verilator 5.052 |出口コード|
| [`test_assoc_class_null_and_alias_keys`](../../tests/ch7/test_assoc_class_null_and_alias_keys.sv) |クラスインデックス付き連想配列は null を受け入れ、エイリアスは同じオブジェクトキーを識別します。| 7.8.3 | Verilator 5.052 ||
| [`test_illegal_class_index_with_other_class`](../../tests/ch7/test_illegal_class_index_with_other_class.sv) |クラスインデックスを持つ関連付け配列は、そのクラスまたは派生クラスのオブジェクトをインデックスとして取得します。関連のないクラスのオブジェクトが タイプチェックエラーです| 7.8.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_assoc_integral_index_cast_context`](../../tests/ch7/test_assoc_integral_index_cast_context.sv) |型付けされた索引は算術的な切り離しの前にキャスト幅と符号コンテキストを適用します| 7.8.4 |標準のみ|出口コード|
| [`test_assoc_signed_and_unsigned_key_order`](../../tests/ch7/test_assoc_signed_and_unsigned_key_order.sv) |同じ高 bit キーパターンは異なる符号付きと無符号のトラヴァース順序を持つ| 7.8.4 |標準のみ|出口コード|
| [`test_assoc_signed_boundary_order`](../../tests/ch7/test_assoc_signed_boundary_order.sv) |符号付き整数連想鍵はゼロを通って符号付き数値順序で反復する| 7.8.4 |標準のみ||
| [`test_associative_array_edge_cases`](../../tests/ch7/test_associative_array_edge_cases.sv) |結合型配列エッジケース| 7.8.4 7.9 | Verilator 5.052 ||
| [`test_illegal_integral_index_with_real`](../../tests/ch7/test_illegal_integral_index_with_real.sv) |整数インデックスを持つ連想配列のインデックス表現は index 型にキャストされますが real からの暗黙的なキャストは違法です| 7.8.4 |標準のみ|違法なデザインだ|
| [`test_illegal_integral_index_with_shortreal`](../../tests/ch7/test_illegal_integral_index_with_shortreal.sv) |整数インデックスを持つ連想配列のインデックス表現はインデックスタイプにキャストされますが、 shortreal からの暗黙的なキャストは違法です。| 7.8.4 |標準のみ|違法なデザインだ|
| [`test_assoc_composite_empty_null_key_order`](../../tests/ch7/test_assoc_composite_empty_null_key_order.sv) |空の文字列と複合キーのヌルハンドルは安定な順序で有効です| 7.8.5 | Verilator 5.052 |出口コード|
| [`test_assoc_foreach_struct_key`](../../tests/ch7/test_assoc_foreach_struct_key.sv) |構造キーを用いた連想配列 foreach をテスト| 7.8.5 12.7.3 | Verilator 5.052 ||
| [`test_illegal_assoc_real_member_key`](../../tests/ch7/test_illegal_assoc_real_member_key.sv) |連想配列の添字型は、realメンバーを含められない| 7.8.5 |標準のみ|違法なデザインだ|
| [`test_illegal_assoc_shortreal_index`](../../tests/ch7/test_illegal_assoc_shortreal_index.sv) |ashortreal は連想配列のインデックスタイプではありません| 7.8.5 |標準のみ|違法なデザインだ|
| [`test_illegal_assoc_union_real_key`](../../tests/ch7/test_illegal_assoc_union_real_key.sv) |連想配列の添字型を、realメンバーを含むunpacked共用体にはできない| 7.8.5 |標準のみ|違法なデザインだ|
| [`test_assoc_array_unknown_index`](../../tests/ch7/test_assoc_array_unknown_index.sv) |x または z ビットのインデックスは連想配列に対して無効です。read は要素のデフォルトタイプを返し、write は何もしません。| 7.8.6 7.4.5 |標準のみ| x/z |
| [`test_assoc_default_and_delete_silent`](../../tests/ch7/test_assoc_default_and_delete_silent.sv) |デフォルトと欠けているキーを削除すると、警告は出せず、新しいエントリも出ない| 7.8.6 7.9.11 7.9.2 | Verilator 5.052 |出口コード|
| [`test_assoc_invalid_write_reports_diagnostic`](../../tests/ch7/test_assoc_invalid_write_reports_diagnostic.sv) |無効な 4 状態キー書き込みを無視し、警告を表示します| 7.8.6 7.8.4 |標準のみ|出口コード x/z|
| [`test_assoc_missing_read_reports_diagnostic`](../../tests/ch7/test_assoc_missing_read_reports_diagnostic.sv) |読み取りが欠けた場合、警告と割り当てなしで四つの状態のデフォルトを返します。| 7.8.6 7.4.5 7.9.11 |標準のみ|出口コード x/z|
| [`test_assoc_missing_read_warning_and_index`](../../tests/ch7/test_assoc_missing_read_warning_and_index.sv) |欠けている連想読みと無効な x/z 指標が存在しない値を読み込み、エントリを追加せず、警告を出力します| 7.8.6 |標準のみ| x/z |
| [`test_assoc_unknown_write_does_not_allocate`](../../tests/ch7/test_assoc_unknown_write_does_not_allocate.sv) |未知の連想鍵を通して書き込むと、要素を作成することも、既知のエントリを破壊することもありません。| 7.8.6 7.8.4 |標準のみ| x/z |
| [`test_assoc_allocate_on_write`](../../tests/ch7/test_assoc_allocate_on_write.sv) |存在しない連想配列要素は、参照によって割り当てられたり渡されたときに割り当てられ、インクリメントまたはメンバー書き込みは、最初にデフォルトまたは初期値で割り当てられる。| 7.8.7 7.9.11 7.9.1 13.5.2 7.8 |標準のみ||
| [`test_assoc_allocate_on_write_types`](../../tests/ch7/test_assoc_allocate_on_write_types.sv) |存在しない関連性配列要素に書き込むときは、 まず、要素タイプのデフォルトまたは初期値またはネストされた配列を、 増分、メンバー書き込み、文字列連結、ref 引数に割り当てます。| 7.8.7 7.9.1 13.5.2 | Verilator 5.052 ||
| [`test_assoc_read_modify_defaults_without_ref`](../../tests/ch7/test_assoc_read_modify_defaults_without_ref.sv) |読み込み-修正-書き込みは ref サポートなしでユーザとタイプのデフォルトを使用します| 7.8.7 | Verilator 5.052 |出口コード|
| [`test_assoc_ref_allocates_before_callee_write`](../../tests/ch7/test_assoc_ref_allocates_before_callee_write.sv) |未知の ref actual は、書き込みをしない呼び出し先の前に割り当てられます。| 7.8.7 7.8 13.5.2 |標準のみ|出口コード|
| [`test_assoc_array_methods_basic`](../../tests/ch7/test_assoc_array_methods_basic.sv) |連想配列メソッド: exists/first/next/delete| 7.9 | Verilator 5.052 ||
| [`test_assoc_array_ops_2`](../../tests/ch7/test_assoc_array_ops_2.sv) |テスト: 連想配列が存在します。first, last, next, prev, delete 操作| 7.9 7.9.3 7.9.4 7.9.5 7.9.6 | Verilator 5.052 ||
| [`test_assoc_method_edge_cases`](../../tests/ch7/test_assoc_method_edge_cases.sv) |連想配列法のエッジケース| 7.9 | Verilator 5.052 ||
| [`test_assoc_count_expression_types`](../../tests/ch7/test_assoc_count_expression_types.sv) |計数法のタイプはトラヴァスル法のサポートに関係なくチェックされる| 7.9.1 20.6.1 20.6.2 | Verilator 5.052 |出口コード|
| [`test_assoc_method_expression_types`](../../tests/ch7/test_assoc_method_expression_types.sv) |結合メソッド表現のタイプは int であり、状態は正確な整数である。| 7.9.1 7.9.3 7.9.4 7.9.5 7.9.6 7.9.7 20.6.1 20.6.2 |標準のみ|出口コード|
| [`test_assoc_num`](../../tests/ch7/test_assoc_num.sv) |テスト: 連想配列数法| 7.9.1 | Verilator 5.052 ||
| [`test_assoc_delete`](../../tests/ch7/test_assoc_delete.sv) |テスト連想配列 delete| 7.9.2 | Verilator 5.052 ||
| [`test_assoc_delete_2`](../../tests/ch7/test_assoc_delete_2.sv) |テスト: 連想配列削除法| 7.9.2 | Verilator 5.052 ||
| [`test_assoc_delete_index_argument_forms`](../../tests/ch7/test_assoc_delete_index_argument_forms.sv) |関連性配列メソッド delete は、入力のオプション引数が配列のインデックスタイプを持つボイド関数です。 つまり、文字列、変換整数、クラスハンドルキーを取得し、引数がないとすべてのエントリを削除します。| 7.9.2 | Verilator 5.052 ||
| [`test_assoc_exists`](../../tests/ch7/test_assoc_exists.sv) |テスト連想配列が存在します| 7.9.3 | Verilator 5.052 ||
| [`test_assoc_exists_2`](../../tests/ch7/test_assoc_exists_2.sv) |テスト: 連想配列存在法| 7.9.3 | Verilator 5.052 ||
| [`test_exists_method`](../../tests/ch7/test_exists_method.sv) |exists() は int と文字列キーを持つ連想配列のメソッドです| 7.9.3 | Verilator 5.052 ||
| [`test_exists_method_2`](../../tests/ch7/test_exists_method_2.sv) |exists() メソッドの実装のテスト| 7.9.3 7.8.1 | Verilator 5.052 ||
| [`test_assoc_first`](../../tests/ch7/test_assoc_first.sv) |連想配列を先にテスト| 7.9.4 | Verilator 5.052 ||
| [`test_assoc_first_2`](../../tests/ch7/test_assoc_first_2.sv) |テスト: 連想配列第一法| 7.9.4 | Verilator 5.052 ||
| [`test_assoc_next`](../../tests/ch7/test_assoc_next.sv) |次の連想配列をテスト| 7.9.4 7.9.6 | Verilator 5.052 ||
| [`test_illegal_assoc_first_argument_type`](../../tests/ch7/test_illegal_assoc_first_argument_type.sv) |関連性配列トラヴァースメソッド first() の引数は配列のインデックスタイプと相容れなければなりません。文字列のインデックスの実変数はエラーです| 7.9.4 7.9.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_wildcard_array_first`](../../tests/ch7/test_illegal_wildcard_array_first.sv) |ワードカードインデックス型の連想配列に対しては first() のトラヴァースメソッドは許可されていません| 7.9.4 | Verilator 5.052 |違法なデザインだ|
| [`test_assoc_last`](../../tests/ch7/test_assoc_last.sv) |結合配列をテスト| 7.9.5 | Verilator 5.052 ||
| [`test_assoc_last_2`](../../tests/ch7/test_assoc_last_2.sv) |テスト: 連想配列最後のメソッド| 7.9.5 | Verilator 5.052 ||
| [`test_assoc_prev`](../../tests/ch7/test_assoc_prev.sv) |テスト連想配列 prev| 7.9.5 7.9.7 | Verilator 5.052 ||
| [`test_illegal_assoc_last_argument_type`](../../tests/ch7/test_illegal_assoc_last_argument_type.sv) |関連性配列トラヴァースメソッド last() の引数は配列のインデックスタイプと相容れなければなりません。文字列のインデックスの実変数はエラーです| 7.9.5 7.9.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_wildcard_array_last`](../../tests/ch7/test_illegal_wildcard_array_last.sv) |ワイルドカード添字型の連想配列では、走査メソッドlast()を使用できない| 7.9.5 | Verilator 5.052 |違法なデザインだ|
| [`test_assoc_array_iter_minimal`](../../tests/ch7/test_assoc_array_iter_minimal.sv) |連想配列 minimal: first/next/last/num/size| 7.9.6 7.9.4 7.9.5 | Verilator 5.052 ||
| [`test_assoc_next_2`](../../tests/ch7/test_assoc_next_2.sv) |テスト: 連想配列次のメソッド| 7.9.6 7.9.4 | Verilator 5.052 ||
| [`test_assoc_traversal_gaps_and_preserved_keys`](../../tests/ch7/test_assoc_traversal_gaps_and_preserved_keys.sv) |トラバーサルは欠けている入力キーを受け入れ、失敗時に引数を保持します。| 7.9.6 7.9.7 |標準のみ|出口コード|
| [`test_illegal_assoc_next_argument_type`](../../tests/ch7/test_illegal_assoc_next_argument_type.sv) |次の関連性配列トラヴァースメソッドの引数は配列のインデックスタイプと相容れます。文字列のインデックスの実変数はエラーです| 7.9.6 7.9.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_wildcard_array_next`](../../tests/ch7/test_illegal_wildcard_array_next.sv) |ワードカードインデックス型の連想配列に対しては、次の()のトラヴァースメソッドは許可されていません。| 7.9.6 | Verilator 5.052 |違法なデザインだ|
| [`test_assoc_prev_2`](../../tests/ch7/test_assoc_prev_2.sv) |テスト: 連想配列 prev メソッド| 7.9.7 7.9.5 | Verilator 5.052 ||
| [`test_illegal_assoc_prev_argument_type`](../../tests/ch7/test_illegal_assoc_prev_argument_type.sv) |関連性配列トラヴァースメソッド prev() の引数は配列のインデックスタイプと相容れなければなりません。文字列のインデックスの実変数はエラーです| 7.9.7 7.9.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_wildcard_array_prev`](../../tests/ch7/test_illegal_wildcard_array_prev.sv) |ワイルドカード添字型の連想配列では、走査メソッドprev()を使用できない| 7.9.7 | Verilator 5.052 |違法なデザインだ|
| [`test_assoc_narrow_prev_next_overflow`](../../tests/ch7/test_assoc_narrow_prev_next_overflow.sv) |発見されたキーが狭い出力インデックスに合わないときは次回と前回の報告を切り取りします| 7.9.8 7.9.6 7.9.7 |標準のみ||
| [`test_assoc_traversal_narrow_index`](../../tests/ch7/test_assoc_traversal_narrow_index.sv) |-1 を返し，キーの低ビットを保持する。| 7.9.8 7.9.4 7.9.5 |標準のみ||
| [`test_assoc_assignment_clears_and_detaches`](../../tests/ch7/test_assoc_assignment_clears_and_detaches.sv) |連想配列への代入は格納先の古いキーを除去し、値渡しは独立したローカルコピーを生成する| 7.9.9 7.9.10 | Verilator 5.052 ||
| [`test_assoc_assignment_copies_every_entry`](../../tests/ch7/test_assoc_assignment_copies_every_entry.sv) |全ての代入は古いエントリを削除し、すべてのスカラー値を独立にコピーします| 7.9.9 | Verilator 5.052 |出口コード|
| [`test_illegal_assoc_assign_different_index_type`](../../tests/ch7/test_illegal_assoc_assign_different_index_type.sv) |関連付け配列は同じインデックスタイプの関連付け配置にのみ割り当てられます。int でインデックスされたターゲットに対する文字列でインデックスされたソースはエラーです| 7.9.9 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_assoc_from_fixed_array`](../../tests/ch7/test_illegal_assoc_from_fixed_array.sv) |固定サイズの配列などの他の配列は 連想配列に割り当てられません| 7.9.9 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_dynamic_array_from_assoc`](../../tests/ch7/test_illegal_dynamic_array_from_assoc.sv) |連想配列は 動的配列などの他の配列に割り当てられません| 7.9.9 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_assoc_argument_different_index_type`](../../tests/ch7/test_illegal_assoc_argument_different_index_type.sv) |連想配列を渡せるのは、添字型が同じ連想配列の仮引数だけである| 7.9.10 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_assoc_to_dynamic_array_argument`](../../tests/ch7/test_illegal_assoc_to_dynamic_array_argument.sv) |連想配列は、動的配列など他の種類の配列の仮引数には渡せない| 7.9.10 |標準のみ|違法なデザインだ|
| [`test_illegal_dynamic_array_to_assoc_argument`](../../tests/ch7/test_illegal_dynamic_array_to_assoc_argument.sv) |動的配列など別の種類の配列は、連想配列の仮引数には渡せない| 7.9.10 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_assoc_array_literal_default`](../../tests/ch7/test_assoc_array_literal_default.sv) |関連性配列リテラルのデフォルト値と全体の関連性配列の代入| 7.9.11 7.9.9 7.9.1 | Verilator 5.052 ||
| [`test_assign_queue`](../../tests/ch7/test_assign_queue.sv) |キュー代入のテスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_builtin_methods_mixed`](../../tests/ch7/test_builtin_methods_mixed.sv) |キュー、動的配列、連想配列、文字列の内蔵メソッド| 7.10 7.5 7.9 6.16 | Verilator 5.052 ||
| [`test_comb_queue_ops`](../../tests/ch7/test_comb_queue_ops.sv) |キュー操作| 7.10 | Icarus Verilog 13.0 ||
| [`test_container_assign_pattern`](../../tests/ch7/test_container_assign_pattern.sv) |コンテナ代入パターンと型変換| 7.10 7.10.4 10.9.1 7.5.1 | Icarus Verilog 13.0 ||
| [`test_illegal_queue_bound_negative`](../../tests/ch7/test_illegal_queue_bound_negative.sv) |右端は正の数 integer でなければなりません。負の限界は違法です| 7.10 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_queue_bound_zero`](../../tests/ch7/test_illegal_queue_bound_zero.sv) |右端は正の数 integer でなければなりません。ゼロは違法だ| 7.10 |標準のみ|違法なデザインだ|
| [`test_queue_assign`](../../tests/ch7/test_queue_assign.sv) |テスト: キュー要素代入| 7.10 7.10.2 | Verilator 5.052 ||
| [`test_queue_basic`](../../tests/ch7/test_queue_basic.sv) |キューの基本的なテスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_basic_edge_cases`](../../tests/ch7/test_queue_basic_edge_cases.sv) |キュー基本エッジケース| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_dimension_and_array_operations`](../../tests/ch7/test_queue_dimension_and_array_operations.sv) |次元は \[ $ \] または \[ $:N \] で、N が最大の許容インデックスであり、キューは $ でのインデックス化、連結、スライシング、等価、その他の固定サイズ unpacked 配列の操作をサポートします。エレメント書き込み、固定配列への全体代入、foreach、配列メソッド、配列クエリなど。| 7.10 7.10.1 20.7 |標準のみ||
| [`test_queue_edge`](../../tests/ch7/test_queue_edge.sv) |テスト：キュー操作エッジケース| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_edge_2`](../../tests/ch7/test_queue_edge_2.sv) |キューエッジ事例| 7.10 7.10.1 7.10.2 | Verilator 5.052 ||
| [`test_queue_edge_cases`](../../tests/ch7/test_queue_edge_cases.sv) |テスト: キューエッジケース| 7.10 7.10.5 | Icarus Verilog 13.0 ||
| [`test_queue_edge_cases_2`](../../tests/ch7/test_queue_edge_cases_2.sv) |キュー操作エッジケース| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_edge_cases_3`](../../tests/ch7/test_queue_edge_cases_3.sv) |角のケース: キューエッジケース| 7.10 | Verilator 5.052 ||
| [`test_queue_insert`](../../tests/ch7/test_queue_insert.sv) |テストキュー挿入| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_method`](../../tests/ch7/test_queue_method.sv) |キューメソッドテスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods`](../../tests/ch7/test_queue_methods.sv) |IEEE 1800-2023 § 7.10 のテスト: キューメソッド| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_basic`](../../tests/ch7/test_queue_methods_basic.sv) |キューメソッドのテスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_bounded`](../../tests/ch7/test_queue_methods_bounded.sv) |キューのメソッド、リストからの代入、限定キュー| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_edge_cases`](../../tests/ch7/test_queue_methods_edge_cases.sv) |テスト: キューエッジの場合 - 空の演算、境界指数| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_sequence`](../../tests/ch7/test_queue_methods_sequence.sv) |キューメソッドコールの一連| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_operations`](../../tests/ch7/test_queue_operations.sv) |キュー操作テスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_ops`](../../tests/ch7/test_queue_ops.sv) |キュー操作のテスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_ops_adv_edge_cases`](../../tests/ch7/test_queue_ops_adv_edge_cases.sv) |テスト：キュー高度操作エッジケース| 7.10 7.10.2 7.10.5 | Verilator 5.052 ||
| [`test_queue_ops_edge_cases`](../../tests/ch7/test_queue_ops_edge_cases.sv) |テスト:キュー操作エッジケース| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_ordering`](../../tests/ch7/test_queue_ordering.sv) |テストキューの順序付け| 7.10 7.12.2 | Verilator 5.052 ||
| [`test_queue_push`](../../tests/ch7/test_queue_push.sv) |キュープッシュ/ポップテスト| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_push_pop`](../../tests/ch7/test_queue_push_pop.sv) |テストキュープッシュ/ポップ| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_size`](../../tests/ch7/test_queue_size.sv) |テストキューサイズ| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_sv_queue`](../../tests/ch7/test_sv_queue.sv) |キュー: push, pop, insert, delete と $ のインデックス| 7.10 7.10.2 | Icarus Verilog 13.0 ||
| [`test_value_queue_ops`](../../tests/ch7/test_value_queue_ops.sv) |キュー値操作のテスト| 7.10 7.10.2 | Verilator 5.052 ||
| [`test_queue_all_methods`](../../tests/ch7/test_queue_all_methods.sv) |引数なしでインデックスに push_back, push_front, insert, pop_front, pop_back, delete をサポートします| 7.10.1 | Icarus Verilog 13.0 ||
| [`test_queue_dollar_primary_in_selects`](../../tests/ch7/test_queue_dollar_primary_in_selects.sv) |読み書きのためのエレメントセレクト、$-1 のような表現、スライス、他のキューのインデックスにネストされた select の場合、キューの select の $ プライマリは、そのキューの最後のインデックスを表します。| 7.10.1 7.10 A.8.4 A.10 | Verilator 5.052 ||
| [`test_queue_invalid_index_read_defaults`](../../tests/ch7/test_queue_invalid_index_read_defaults.sv) |0未満、$より大きい、またはxかzのbitを含む添字でキューを読み取ると、要素型の存在しないエントリの値を返す。intでは0、logicではx、stringでは空文字列となる。| 7.10.1 7.4.5 | Icarus Verilog 13.0 | x/z |
| [`test_queue_invalid_index_write_ignored_warning`](../../tests/ch7/test_queue_invalid_index_write_ignored_warning.sv) |0以下、+1以上、xまたはzがbitのキューへの書き込みは無視され、ランタイム警告が出ます。\[から+1 \]までのキューへの 書き込みはエレメントを追加します。| 7.10.1 | Icarus Verilog 13.0 |出口コード x/z|
| [`test_queue_slice_bounds_clip_and_empty`](../../tests/ch7/test_queue_slice_bounds_clip_and_empty.sv) |クエーシングスライス Q \[ a:b \] は可変境界を持ち、a を 0 から 0 まで、b を $ から $ までクリップし、a \> b または a 境界が x または z bit を持つとき空であり、Q \[ n:n \] は Q \[ n \] だけを持ち、または n が範囲外のとき空です。| 7.10.1 |標準のみ| x/z |
| [`test_queue_write_at_size_appends`](../../tests/ch7/test_queue_write_at_size_appends.sv) |index size() でキュー要素を書き込むと、それを追加します。それ以上は何もしません。| 7.10.1 7.4.5 | Icarus Verilog 13.0 ||
| [`test_edge_queue_assoc`](../../tests/ch7/test_edge_queue_assoc.sv) |文字列キーを使って push/pop と連想配列 first(), delete(), exists() をキューに追加します。| 7.10.2 7.9.4 7.9.2 7.9.3 7.8.2 | Verilator 5.052 ||
| [`test_member_queue`](../../tests/ch7/test_member_queue.sv) |int 、 byte 、 文字列キューのキューメソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_delete_2`](../../tests/ch7/test_queue_delete_2.sv) |インデックスメソッドでキューを削除| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_insert_2`](../../tests/ch7/test_queue_insert_2.sv) |インデックスメソッドでキューを挿入| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_insert_delete`](../../tests/ch7/test_queue_insert_delete.sv) |キュープッシュ、ポップ、挿入、削除| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_2`](../../tests/ch7/test_queue_methods_2.sv) |キューメソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_3`](../../tests/ch7/test_queue_methods_3.sv) |キュー push_back 、 push_front 、 pop_front 、 pop_back| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_methods_4`](../../tests/ch7/test_queue_methods_4.sv) |キュー push_back 、 pop_front 、pop_back 、挿入、削除メソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_ops_2`](../../tests/ch7/test_queue_ops_2.sv) |リストから代入た後にキューをプッシュ、ポップ、挿入、削除します| 7.10.2 10.10 | Icarus Verilog 13.0 ||
| [`test_queue_pop_back`](../../tests/ch7/test_queue_pop_back.sv) |キュー pop_back メソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_pop_front`](../../tests/ch7/test_queue_pop_front.sv) |キュー pop_front メソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_push_back`](../../tests/ch7/test_queue_push_back.sv) |キュー push_back メソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_push_front`](../../tests/ch7/test_queue_push_front.sv) |キュー push_front メソッド| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_push_pop_2`](../../tests/ch7/test_queue_push_pop_2.sv) |キュー push_front 、 push_back 、 pop_front 、 pop_back| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_size_2`](../../tests/ch7/test_queue_size_2.sv) |キューサイズ法| 7.10.2 | Icarus Verilog 13.0 ||
| [`test_queue_size_method`](../../tests/ch7/test_queue_size_method.sv) |空のキューの場合、size() は 0 であり、プッシュ、インサート、削除、代入パターンの要素に従います。| 7.10.2.1 7.10.2.3 7.10.2.6 7.10 | Icarus Verilog 13.0 ||
| [`test_queue_insert_positions`](../../tests/ch7/test_queue_insert_positions.sv) |insert(index, item) はキューの最初、中、最後の位置にアイテムを置き、後の要素をシフトし、サイズに等しいインデックスを付け加えます。 int と文字列のキューの場合は、| 7.10.2.2 7.10.2.1 | Icarus Verilog 13.0 ||
| [`test_queue_method_edges`](../../tests/ch7/test_queue_method_edges.sv) |空のキューのサイズ、終わりに挿入、負のインデックス、大きすぎるインデックス、未知のインデックス、push_front、pop_front、pop_backを無視して挿入、終わりを削除する、または空のキューで存在しない要素の値を返す。| 7.10.2.2 7.10.2.1 7.10.2.4 7.10.2.5 7.10.2.6 7.4.5 |標準のみ| x/z |
| [`test_queue_method_prototypes_and_invalid_indices`](../../tests/ch7/test_queue_method_prototypes_and_invalid_indices.sv) |キューメソッドはそのプロトタイプに従う。size() は int を返す。insert() と delete() は integer の添字を取り、負、大きすぎる値、または x ビットを含む添字を無視する。insert()、push_front ()、push_back () は項目を要素型に変換し、pop_front () と pop_back () は要素型を返す。| 7.10.2.2 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.5 7.10.2.6 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_queue_delete`](../../tests/ch7/test_queue_delete.sv) |テストキューを削除| 7.10.2.3 7.10.4 | Icarus Verilog 13.0 ||
| [`test_queue_pop_front_order`](../../tests/ch7/test_queue_pop_front_order.sv) |文字列と int のキューの場合、pop_front () は最初の要素を削除して返し、他の要素をシフトします。キューが空になるときまで。| 7.10.2.4 7.10.2.1 | Icarus Verilog 13.0 ||
| [`test_queue_pop_back_order`](../../tests/ch7/test_queue_pop_back_order.sv) |文字列と int のキューの場合、pop_back () は最後の要素を削除して返し、他の要素を順番に残します。キューが空になるときまで。| 7.10.2.5 7.10.2.1 | Icarus Verilog 13.0 ||
| [`test_queue_size_wait_after_pop`](../../tests/ch7/test_queue_size_wait_after_pop.sv) |キューサイズの変更は、ポップがキューを空にしたときに待ちを解除します| 7.10.2.7 | Verilator 5.052 ||
| [`test_queue_ref_survives_unrelated_pop`](../../tests/ch7/test_queue_ref_survives_unrelated_pop.sv) |最後のキュー要素をポップすると、最初の要素へのリファレンスが保存されます。| 7.10.3 13.5.2 | Verilator 5.052 ||
| [`test_queue_reference_persistence`](../../tests/ch7/test_queue_reference_persistence.sv) |タスクが保持するキュー要素へのリファレンスは、他のメソッドがキューを変更したときにその要素に残り、要素が削除されたり、キュー全体が割り当てられたときに時代遅れになります。| 7.10.3 13.5.2 7.10.2 |標準のみ||
| [`test_queue_refs_outdated_by_bounded_push_and_assignment`](../../tests/ch7/test_queue_refs_outdated_by_bounded_push_and_assignment.sv) |と同じ値を与えるキュー代入は、 push_back は古い要素へのすべてのリファレンスを過去にするが、 push_back はそれらを保持し、 push_front はフルボウンデッドキューでは、最後に削除された要素へのリファレンスのみを過去にします。| 7.10.4 7.10.3 13.5.2 | Verilator 5.052 ||
| [`test_bounded_queue_assign_discards_beyond_bound`](../../tests/ch7/test_bounded_queue_assign_discards_beyond_bound.sv) |制限されたキューにより長いキュー値を割り当てると、エレメントは制限値まで保持され、それを超えるエレメントは警告と共に削除されます。| 7.10.5 7.10 7.10.4 |標準のみ|出口コード|
| [`test_bounded_queue_methods_discard_beyond_bound`](../../tests/ch7/test_bounded_queue_methods_discard_beyond_bound.sv) |push_back , push_front，\[，+1 \]の全ての有界キューに挿入と書き込みを行い，無限キューのように行い，警告を与えて，有界の上の要素をドラッグする。| 7.10.5 7.10 | Icarus Verilog 13.0 |出口コード|
| [`test_array_and_class_method_call_forms`](../../tests/ch7/test_array_and_class_method_call_forms.sv) |一次式・this・superに対する、メソッド名の後に属性インスタンスを伴うメソッド呼出し、および識別子またはunique/and/or/xorで指定する配列操作メソッドの呼出しを確認します。括弧の有無、イテレータ引数、with句、呼出し後の選択も対象です。| 7.12 7.12.1 7.12.3 8.11 8.15 A.8.2 | Verilator 5.052 ||
| [`test_array_method_corner`](../../tests/ch7/test_array_method_corner.sv) |検査検索、ソート、和、min、max、ユニークな方法| 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_array_method_index_argument`](../../tests/ch7/test_array_method_index_argument.sv) |次の例では，このメソッドを用いて，インデックスを指定した要素を指定する。| 7.12 7.12.4 7.12.1 |標準のみ||
| [`test_array_method_iterator_index_names_and_selects`](../../tests/ch7/test_array_method_iterator_index_names_and_selects.sv) |index は index のメソッドの名前を変更します。 index() は int または 連想インデックスタイプを返します。 結果に対する select とメソッドは with 条項またはコールに従います。| 7.12 7.12.1 7.12.4 |標準のみ||
| [`test_array_methods_2`](../../tests/ch7/test_array_methods_2.sv) |IEEE 1800-2023 § 7.12 のテスト: 配列操作法| 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_array_predicates`](../../tests/ch7/test_array_predicates.sv) |配列メソッドテスト| 7.12 7.5 7.10 | Icarus Verilog 13.0 ||
| [`test_comb_queue_methods_ext`](../../tests/ch7/test_comb_queue_methods_ext.sv) |テスト：拡張キューと配列法のエッジケース| 7.12 7.10.2 | Verilator 5.052 ||
| [`test_comb_queue_with_clause`](../../tests/ch7/test_comb_queue_with_clause.sv) |テスト: 'with' 条件を持つキューメソッド| 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_ieee1800_2023_array_method_corner`](../../tests/ch7/test_ieee1800_2023_array_method_corner.sv) |配列操作法| 7.12 7.12.1 7.12.2 7.12.3 7.10.2 7.9 | Verilator 5.052 ||
| [`test_illegal_array_method_with_braces`](../../tests/ch7/test_illegal_array_method_with_braces.sv) |配列操作のwith条件は 表現を括弧に入れます括弧はrandomize() で使われますが| 7.12 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_iterator_argument_without_with`](../../tests/ch7/test_illegal_iterator_argument_without_with.sv) |配列メソッドは with 節なしでは反復子の名前を付けられません。| 7.12 7.12.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_sort_iterator_without_with`](../../tests/ch7/test_illegal_sort_iterator_without_with.sv) |配列メソッドの反復引数には with 節が必要です| 7.12 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_member_access_deep`](../../tests/ch7/test_member_access_deep.sv) |8.5 クラスメンバーアクセス| 7.12 8.5 | Verilator 5.052 ||
| [`test_array_find`](../../tests/ch7/test_array_find.sv) |7.12.1 の配列位置決めメソッド| 7.12.1 | Verilator 5.052 ||
| [`test_array_find_2`](../../tests/ch7/test_array_find_2.sv) |テスト: 配列検索法| 7.12.1 | Verilator 5.052 ||
| [`test_array_find_first`](../../tests/ch7/test_array_find_first.sv) |テスト: 配列 find_first 法| 7.12.1 | Verilator 5.052 ||
| [`test_array_find_index`](../../tests/ch7/test_array_find_index.sv) |テスト: 配列 find_index 法| 7.12.1 | Verilator 5.052 ||
| [`test_array_find_last`](../../tests/ch7/test_array_find_last.sv) |テスト: 配列 find_last 法| 7.12.1 | Verilator 5.052 ||
| [`test_array_find_methods`](../../tests/ch7/test_array_find_methods.sv) |配列操作法| 7.12.1 | Verilator 5.052 ||
| [`test_array_locator`](../../tests/ch7/test_array_locator.sv) |配列位置決めメソッド| 7.12.1 | Verilator 5.052 ||
| [`test_array_locator_first_last_by_range_and_min_tie`](../../tests/ch7/test_array_locator_first_last_by_range_and_min_tie.sv) |find_firstとfind_lastは最も左端または最も右端のインデックスに最も近いマッチを選択します。下降範囲では最も高いまたは最も低いインデックスであり、連想配列では first() と last() に続きます。min() は複数の要素が同じ値を返す場合でも 1 つの要素を返します。| 7.12.1 |標準のみ||
| [`test_array_locator_methods`](../../tests/ch7/test_array_locator_methods.sv) |配列位置決めメソッド| 7.12.1 | Verilator 5.052 ||
| [`test_array_locator_methods_2`](../../tests/ch7/test_array_locator_methods_2.sv) |配列位置決め法のテスト| 7.12.1 | Verilator 5.052 ||
| [`test_array_max`](../../tests/ch7/test_array_max.sv) |テスト配列マックスメソッド| 7.12.1 | Verilator 5.052 ||
| [`test_array_method`](../../tests/ch7/test_array_method.sv) |固定サイズ int 配列の配列順序、位置指定子、ユニークメソッド| 7.12.1 7.12.2 | Verilator 5.052 ||
| [`test_array_methods`](../../tests/ch7/test_array_methods.sv) |固定サイズ配列の配列順序化，位置決め，縮小法| 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_array_methods_edge_cases`](../../tests/ch7/test_array_methods_edge_cases.sv) |配列操作法のエッジケース| 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_array_min`](../../tests/ch7/test_array_min.sv) |配列の最小値をテスト| 7.12.1 | Verilator 5.052 ||
| [`test_array_min_max`](../../tests/ch7/test_array_min_max.sv) |テスト配列 min/max 法| 7.12.1 | Verilator 5.052 ||
| [`test_array_reduction_methods_2`](../../tests/ch7/test_array_reduction_methods_2.sv) |配列操作法| 7.12.1 7.12.3 | Verilator 5.052 ||
| [`test_array_unique`](../../tests/ch7/test_array_unique.sv) |配列位置決めメソッド - unique()| 7.12.1 | Verilator 5.052 ||
| [`test_array_unique_2`](../../tests/ch7/test_array_unique_2.sv) |配列ユニークメソッドのテスト| 7.12.1 | Verilator 5.052 ||
| [`test_array_unique_methods`](../../tests/ch7/test_array_unique_methods.sv) |配列ユニークメソッド| 7.12.1 | Verilator 5.052 ||
| [`test_comb_array_reduce_sort`](../../tests/ch7/test_comb_array_reduce_sort.sv) |テスト：配列縮小法（和／積／及び／または／xor），シャッフル，ソート，ユニーク| 7.12.1 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_comb_dynarray_find`](../../tests/ch7/test_comb_dynarray_find.sv) |テスト：動的配列のfind_first／find_lastと検索メソッド| 7.12.1 | Verilator 5.052 ||
| [`test_comb_dynarray_locator`](../../tests/ch7/test_comb_dynarray_locator.sv) |テスト：動的配列の検索メソッド| 7.12.1 7.12.3 | Verilator 5.052 ||
| [`test_illegal_find_first_index_without_with`](../../tests/ch7/test_illegal_find_first_index_without_with.sv) |配列位置決めメソッド find_first_index() の with 項は必須です| 7.12.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_find_first_without_with`](../../tests/ch7/test_illegal_find_first_without_with.sv) |配列位置決めメソッド find_first() の with 項は必須です| 7.12.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_find_index_without_with`](../../tests/ch7/test_illegal_find_index_without_with.sv) |配列位置決めメソッド find_index() の with 項は必須です| 7.12.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_find_last_index_without_with`](../../tests/ch7/test_illegal_find_last_index_without_with.sv) |配列位置決めメソッド find_last_index() の with 項は必須です| 7.12.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_find_last_without_with`](../../tests/ch7/test_illegal_find_last_without_with.sv) |配列位置決めメソッド find_last() の with 項は必須です| 7.12.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_find_without_with`](../../tests/ch7/test_illegal_find_without_with.sv) |配列位置決めメソッド find() の with 項は必須です| 7.12.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_max_without_with_struct_elements`](../../tests/ch7/test_illegal_max_without_with_struct_elements.sv) |関係演算子が要素型に定義されている場合にのみ max() の with 条項を省略できます。unpacked構造の配列はそれを必要とします| 7.12.1 |標準のみ|違法なデザインだ|
| [`test_illegal_min_with_struct_expression`](../../tests/ch7/test_illegal_min_with_struct_expression.sv) |関係演算子は、その表現のタイプに対して定義される必要があります。unpacked 構造表現はエラーです| 7.12.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_min_without_with_struct_elements`](../../tests/ch7/test_illegal_min_without_with_struct_elements.sv) |関係演算子が要素型に定義されている場合にのみ min() の with 条項を省略できます。unpacked構造の配列はそれを必要とします| 7.12.1 |標準のみ|違法なデザインだ|
| [`test_illegal_unique_index_without_with_struct_elements`](../../tests/ch7/test_illegal_unique_index_without_with_struct_elements.sv) |unique_index() の with 条項は、関係演算子が要素タイプに定義されている場合のみ省略できます。unpacked構造の配列はそれを必要とします| 7.12.1 |標準のみ|違法なデザインだ|
| [`test_illegal_unique_without_with_struct_elements`](../../tests/ch7/test_illegal_unique_without_with_struct_elements.sv) |関係演算子が要素タイプに定義されている場合にのみ unique() の with 条項を省略できます。unpacked構造の配列はそれを必要とします| 7.12.1 |標準のみ|違法なデザインだ|
| [`test_illegal_wildcard_array_find_first_index`](../../tests/ch7/test_illegal_wildcard_array_find_first_index.sv) |ワイルドカード添字型の連想配列では、添字検索メソッドfind_first_index()を使用できない。| 7.12.1 7.8.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_wildcard_array_find_index`](../../tests/ch7/test_illegal_wildcard_array_find_index.sv) |ワイルドカード添字型の連想配列では、添字検索メソッドfind_index()を使用できない。| 7.12.1 7.8.1 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_wildcard_array_find_last_index`](../../tests/ch7/test_illegal_wildcard_array_find_last_index.sv) |ワイルドカード添字型の連想配列では、添字検索メソッドfind_last_index()を使用できない。| 7.12.1 7.8.1 | Verilator 5.052 |違法なデザインだ|
| [`test_member_array`](../../tests/ch7/test_member_array.sv) |テスト配列メソッドメンバーアクセス (.size,.findなど)| 7.12.1 7.12.3 7.5 7.10 | Verilator 5.052 ||
| [`test_array_ordering`](../../tests/ch7/test_array_ordering.sv) |テスト配列順序付け法| 7.12.2 | Verilator 5.052 ||
| [`test_array_ordering_methods`](../../tests/ch7/test_array_ordering_methods.sv) |配列操作法| 7.12.2 | Verilator 5.052 ||
| [`test_array_ordering_methods_and_index_queries`](../../tests/ch7/test_array_ordering_methods_and_index_queries.sv) |unpacked 配列を宣言通りにソート、rsort、逆順に並べ替えます。反復インデックスは最も遅い次元を先に数えます。| 7.12.2 7.12.4 |標準のみ||
| [`test_array_ordering_methods_with_and_iterator`](../../tests/ch7/test_array_ordering_methods_with_and_iterator.sv) |sort()・rsort()は、動的配列・固定配列・キューを、要素の値、またはitem・名前付きイテレータを使ったwith式で並べ替えます。reverse()は逆順にし、shuffle()は元の要素の置換になります。| 7.12.2 |標準のみ||
| [`test_array_reverse`](../../tests/ch7/test_array_reverse.sv) |配列の順序付けメソッド - reverse()| 7.12.2 | Verilator 5.052 ||
| [`test_array_reverse_2`](../../tests/ch7/test_array_reverse_2.sv) |配列逆法のテスト| 7.12.2 | Verilator 5.052 ||
| [`test_array_rsort`](../../tests/ch7/test_array_rsort.sv) |配列のソートメソッド - rsort()| 7.12.2 | Verilator 5.052 ||
| [`test_array_shuffle`](../../tests/ch7/test_array_shuffle.sv) |配列の順序付けメソッド - shuffle()| 7.12.2 | Verilator 5.052 ||
| [`test_array_shuffle_2`](../../tests/ch7/test_array_shuffle_2.sv) |配列シャッフル法のテスト| 7.12.2 7.12.3 | Verilator 5.052 ||
| [`test_array_sort`](../../tests/ch7/test_array_sort.sv) |配列のソートメソッド - sort()| 7.12.2 | Verilator 5.052 ||
| [`test_illegal_assoc_array_reverse`](../../tests/ch7/test_illegal_assoc_array_reverse.sv) |連想配列に逆順序化メソッド reverse() を適用できません| 7.12.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_assoc_array_rsort`](../../tests/ch7/test_illegal_assoc_array_rsort.sv) |ソートメソッド rsort() は連想配列に適用できません| 7.12.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_assoc_array_shuffle`](../../tests/ch7/test_illegal_assoc_array_shuffle.sv) |連想配列に shuffle() を適用できません| 7.12.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_assoc_array_sort`](../../tests/ch7/test_illegal_assoc_array_sort.sv) |ソートメソッド sort() は連想配列に適用できません| 7.12.2 | Verilator 5.052 |違法なデザインだ|
| [`test_illegal_rsort_with_struct_expression`](../../tests/ch7/test_illegal_rsort_with_struct_expression.sv) |rsort() は with 条項がないときは要素のタイプに関係演算子を必要とし、あるときは with 表現のタイプに関係 演算子を必 要とします。構造型がunpackedの表現を持つ a はエラーである| 7.12.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_rsort_without_with`](../../tests/ch7/test_illegal_rsort_without_with.sv) |rsort() は with 条項がないときは要素のタイプに関係演算子を必要とし、あるときは with 表現のタイプに関係 演算子を必 要とします。構造要素のタイプが unpacked で with 条件がないと エラーになります| 7.12.2 |標準のみ|違法なデザインだ|
| [`test_illegal_sort_with_struct_expression`](../../tests/ch7/test_illegal_sort_with_struct_expression.sv) |関係演算子は、with 条項がないときは要素のタイプ、あるときはその with 表現のタイプに関係する。構造型がunpackedの表現を持つ a はエラーである| 7.12.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_sort_without_with`](../../tests/ch7/test_illegal_sort_without_with.sv) |関係演算子は、with 条項がないときは要素のタイプ、あるときはその with 表現のタイプに関係する。構造要素のタイプが unpacked で with 条件がないと エラーになります| 7.12.2 |標準のみ|違法なデザインだ|
| [`test_real_queue_sort_min_max`](../../tests/ch7/test_real_queue_sort_min_max.sv) |realのキューに対するsort、rsort、min、maxは、要素の実数値を使って順序付ける| 7.12.2 7.12.1 | Verilator 5.052 ||
| [`test_reverse_order`](../../tests/ch7/test_reverse_order.sv) |逆は固定配列とキューの要素順序を逆にします| 7.12.2 | Verilator 5.052 ||
| [`test_sort_rsort_shuffle_reverse`](../../tests/ch7/test_sort_rsort_shuffle_reverse.sv) |7.10: 配列操作メソッド| 7.12.2 | Verilator 5.052 ||
| [`test_struct_array_sort`](../../tests/ch7/test_struct_array_sort.sv) |角の大文字: 構造配列ソート| 7.12.2 7.2 | Verilator 5.052 ||
| [`test_array_and`](../../tests/ch7/test_array_and.sv) |配列と還元法の試験| 7.12.3 | Verilator 5.052 ||
| [`test_array_and_or_xor`](../../tests/ch7/test_array_and_or_xor.sv) |テスト: 配列と/または/xOR法| 7.12.3 | Verilator 5.052 ||
| [`test_array_method_sum`](../../tests/ch7/test_array_method_sum.sv) |配列法の和積テスト| 7.12.3 | Verilator 5.052 ||
| [`test_array_or`](../../tests/ch7/test_array_or.sv) |配列法や還元法の試験| 7.12.3 | Verilator 5.052 ||
| [`test_array_product`](../../tests/ch7/test_array_product.sv) |配列積法のテスト| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduce`](../../tests/ch7/test_array_reduce.sv) |テスト配列縮小法| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduction`](../../tests/ch7/test_array_reduction.sv) |配列縮小法（§7.12.3）| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduction_2`](../../tests/ch7/test_array_reduction_2.sv) |テスト配列縮小法| 7.12.3 20.7 | Verilator 5.052 ||
| [`test_array_reduction_and`](../../tests/ch7/test_array_reduction_and.sv) |配列縮小法 -and()| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduction_and_or_xor_with`](../../tests/ch7/test_array_reduction_and_or_xor_with.sv) |また，and（），or（），xor（）の縮小法は，それぞれの要素に対して，縮小前にwith条件を適用する。| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduction_methods`](../../tests/ch7/test_array_reduction_methods.sv) |7.12.3 配列縮小と位置決め法のテスト| 7.12.3 7.12.1 7.5.2 | Verilator 5.052 ||
| [`test_array_reduction_or`](../../tests/ch7/test_array_reduction_or.sv) |配列縮小メソッド -or()| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduction_product`](../../tests/ch7/test_array_reduction_product.sv) |配列縮小法 - product()| 7.12.3 | Verilator 5.052 ||
| [`test_array_reduction_result_type_and_with_width`](../../tests/ch7/test_array_reduction_result_type_and_with_width.sv) |リダクションメソッドは、with句がなければ要素型、あればwith式の型の値を返します。そのため、広い変数へ代入しても要素幅で桁あふれし、with句内でキャストすれば、各オペランドを先に広げられます。| 7.12.3 |標準のみ||
| [`test_array_reduction_with_clause`](../../tests/ch7/test_array_reduction_with_clause.sv) |with 条件を用いた配列縮小法| 7.12.3 7.12.4 | Verilator 5.052 ||
| [`test_array_reduction_xor`](../../tests/ch7/test_array_reduction_xor.sv) |配列縮小メソッド - xor()| 7.12.3 | Verilator 5.052 ||
| [`test_array_sum`](../../tests/ch7/test_array_sum.sv) |配列和法のテスト| 7.12.3 | Verilator 5.052 ||
| [`test_array_xor`](../../tests/ch7/test_array_xor.sv) |配列xor減少法のテスト| 7.12.3 | Verilator 5.052 ||
| [`test_illegal_reduction_and_with_real_expression`](../../tests/ch7/test_illegal_reduction_and_with_real_expression.sv) |とは言え、with の場合は、 with 表現のタイプに対して、その操作を定義する必要があります。| 7.12.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_wildcard_index_method`](../../tests/ch7/test_illegal_wildcard_index_method.sv) |反復インデックス法は ワイルドカードインデックス連想配列では使えません| 7.12.4 7.8.1 |標準のみ|違法なデザインだ|
| [`test_array_map_method`](../../tests/ch7/test_array_map_method.sv) |配列メソッドmap()は、元と同じ範囲またはキーを持つ配列を返します。各要素はitemまたは名前付きイテレータとその添字を使ったwith式の値であり、その式の自己決定型を使用します。| 7.12.5 7.12 |標準のみ||
| [`test_illegal_map_without_with`](../../tests/ch7/test_illegal_map_without_with.sv) |map() は結果の各要素の値を返す with 節を必要とします| 7.12.5 | Verilator 5.052 |違法なデザインだ|
| [`test_map_result_to_same_array`](../../tests/ch7/test_map_result_to_same_array.sv) |map() の結果は呼び出された配列、動的配列、またはキューに割り当てられます。| 7.12.5 | Verilator 5.052 ||
| [`test_map_result_type_range_and_keys`](../../tests/ch7/test_map_result_type_range_and_keys.sv) |map() の結果は with 表現の自己決定型の要素、ソース配列の範囲、関連配列の場合はそのインデックスのセットを含む。| 7.12.5 |標準のみ||

<a id="generated-by-generatorsinteraction_arraypy"></a>

## 生成者: `generators/interaction_array.py`

36 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_array_w129_s_l_da_z_s`](../../tests/gen/ch7/test_gen_cross_array_w129_s_l_da_z_s.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w129_u_b_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w129_u_b_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w129_u_b_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w129_u_b_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w129_u_b_ad_k_w`](../../tests/gen/ch7/test_gen_cross_array_w129_u_b_ad_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w129_u_l_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w129_u_l_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w129_u_l_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w129_u_l_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w1_s_b_dd_x_w`](../../tests/gen/ch7/test_gen_cross_array_w1_s_b_dd_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w1_u_b_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w1_u_b_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w1_u_b_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w1_u_b_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w1_u_l_aa_k_s`](../../tests/gen/ch7/test_gen_cross_array_w1_u_l_aa_k_s.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w1_u_l_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w1_u_l_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w1_u_l_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w1_u_l_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w32_s_l_ad_x_s`](../../tests/gen/ch7/test_gen_cross_array_w32_s_l_ad_x_s.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w32_u_b_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w32_u_b_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w32_u_b_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w32_u_b_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w32_u_b_da_z_w`](../../tests/gen/ch7/test_gen_cross_array_w32_u_b_da_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w32_u_l_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w32_u_l_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w32_u_l_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w32_u_l_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w33_s_b_dd_k_w`](../../tests/gen/ch7/test_gen_cross_array_w33_s_b_dd_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w33_u_b_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w33_u_b_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w33_u_b_dd_z_s`](../../tests/gen/ch7/test_gen_cross_array_w33_u_b_dd_z_s.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w33_u_l_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w33_u_l_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w33_u_l_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w33_u_l_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w33_u_l_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w33_u_l_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w64_s_l_ad_z_w`](../../tests/gen/ch7/test_gen_cross_array_w64_s_l_ad_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w64_u_b_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w64_u_b_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w64_u_b_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w64_u_b_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w64_u_b_da_x_s`](../../tests/gen/ch7/test_gen_cross_array_w64_u_b_da_x_s.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w64_u_l_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w64_u_l_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w64_u_l_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w64_u_l_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w65_s_l_da_k_s`](../../tests/gen/ch7/test_gen_cross_array_w65_s_l_da_k_s.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w65_u_b_aa_k_w`](../../tests/gen/ch7/test_gen_cross_array_w65_u_b_aa_k_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 | Verilator 5.052 ||
| [`test_gen_cross_array_w65_u_b_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w65_u_b_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w65_u_b_ad_x_w`](../../tests/gen/ch7/test_gen_cross_array_w65_u_b_ad_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w65_u_l_aa_x_w`](../../tests/gen/ch7/test_gen_cross_array_w65_u_l_aa_x_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_array_w65_u_l_aa_z_w`](../../tests/gen/ch7/test_gen_cross_array_w65_u_l_aa_z_w.sv) |アンパックの配列コピーは宣言順序、値、スライスガードを保持します。| 7.6 7.4.6 6.11.2 11.8.2 |標準のみ| x/z |

<a id="generated-by-generatorsinteraction_methodpy"></a>

## 生成者: `generators/interaction_method.py`

72 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_method_w129_b_u_d_and_widen_known`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_d_and_widen_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w129_b_u_d_or_plain_known`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_d_or_plain_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w129_b_u_f_sum_int_high_x`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_int_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_b_u_f_sum_int_known`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_int_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w129_b_u_f_sum_integer_high_x`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_integer_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_b_u_f_sum_integer_high_z`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_integer_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_b_u_f_sum_integer_known`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_integer_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w129_b_u_f_sum_plain_high_z`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_plain_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_b_u_f_sum_widen_high_x`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_widen_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_b_u_f_sum_widen_high_z`](../../tests/gen/ch7/test_gen_cross_method_w129_b_u_f_sum_widen_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_l_s_q_xor_int_high_z`](../../tests/gen/ch7/test_gen_cross_method_w129_l_s_q_xor_int_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w129_l_u_f_product_plain_high_x`](../../tests/gen/ch7/test_gen_cross_method_w129_l_u_f_product_plain_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_b_s_f_and_int_high_z`](../../tests/gen/ch7/test_gen_cross_method_w1_b_s_f_and_int_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_b_u_d_product_integer_high_z`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_d_product_integer_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_b_u_d_product_plain_high_x`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_d_product_plain_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_b_u_d_sum_plain_known`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_d_sum_plain_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w1_b_u_d_xor_plain_high_z`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_d_xor_plain_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_b_u_f_and_widen_high_x`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_f_and_widen_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_b_u_f_product_int_known`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_f_product_int_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w1_b_u_f_product_integer_known`](../../tests/gen/ch7/test_gen_cross_method_w1_b_u_f_product_integer_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w1_l_u_d_sum_widen_high_z`](../../tests/gen/ch7/test_gen_cross_method_w1_l_u_d_sum_widen_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_l_u_f_or_int_high_x`](../../tests/gen/ch7/test_gen_cross_method_w1_l_u_f_or_int_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_l_u_f_or_integer_high_x`](../../tests/gen/ch7/test_gen_cross_method_w1_l_u_f_or_integer_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w1_l_u_q_sum_widen_known`](../../tests/gen/ch7/test_gen_cross_method_w1_l_u_q_sum_widen_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w32_b_s_d_sum_integer_high_z`](../../tests/gen/ch7/test_gen_cross_method_w32_b_s_d_sum_integer_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_d_and_integer_known`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_d_and_integer_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w32_b_u_d_or_integer_high_x`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_d_or_integer_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_d_or_widen_high_x`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_d_or_widen_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_d_sum_int_high_z`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_d_sum_int_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_d_xor_widen_high_z`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_d_xor_widen_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_f_sum_int_high_x`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_f_sum_int_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_q_or_plain_high_x`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_q_or_plain_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_b_u_q_sum_plain_known`](../../tests/gen/ch7/test_gen_cross_method_w32_b_u_q_sum_plain_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w32_l_u_f_and_plain_high_z`](../../tests/gen/ch7/test_gen_cross_method_w32_l_u_f_and_plain_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w32_l_u_f_product_widen_known`](../../tests/gen/ch7/test_gen_cross_method_w32_l_u_f_product_widen_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w32_l_u_f_xor_int_known`](../../tests/gen/ch7/test_gen_cross_method_w32_l_u_f_xor_int_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w33_b_s_f_or_widen_high_z`](../../tests/gen/ch7/test_gen_cross_method_w33_b_s_f_or_widen_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_b_s_q_product_int_high_z`](../../tests/gen/ch7/test_gen_cross_method_w33_b_s_q_product_int_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_b_u_d_and_int_high_x`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_d_and_int_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_b_u_d_product_int_known`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_d_product_int_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w33_b_u_d_xor_integer_known`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_d_xor_integer_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w33_b_u_f_xor_integer_high_x`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_f_xor_integer_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_b_u_q_and_widen_high_x`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_q_and_widen_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_b_u_q_product_plain_high_z`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_q_product_plain_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_b_u_q_product_widen_known`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_q_product_widen_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w33_b_u_q_sum_integer_high_z`](../../tests/gen/ch7/test_gen_cross_method_w33_b_u_q_sum_integer_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_l_u_d_and_plain_high_x`](../../tests/gen/ch7/test_gen_cross_method_w33_l_u_d_and_plain_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w33_l_u_f_sum_plain_known`](../../tests/gen/ch7/test_gen_cross_method_w33_l_u_f_sum_plain_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w64_b_s_q_and_plain_high_x`](../../tests/gen/ch7/test_gen_cross_method_w64_b_s_q_and_plain_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_b_u_d_xor_int_high_x`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_d_xor_int_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_b_u_f_sum_plain_high_z`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_f_sum_plain_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_b_u_f_xor_widen_known`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_f_xor_widen_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w64_b_u_q_and_int_high_z`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_q_and_int_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_b_u_q_and_integer_known`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_q_and_integer_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w64_b_u_q_or_integer_high_x`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_q_or_integer_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_b_u_q_or_widen_high_z`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_q_or_widen_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_b_u_q_xor_plain_known`](../../tests/gen/ch7/test_gen_cross_method_w64_b_u_q_xor_plain_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w64_l_u_d_or_int_known`](../../tests/gen/ch7/test_gen_cross_method_w64_l_u_d_or_int_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w64_l_u_f_sum_widen_high_x`](../../tests/gen/ch7/test_gen_cross_method_w64_l_u_f_sum_widen_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w64_l_u_q_product_integer_high_z`](../../tests/gen/ch7/test_gen_cross_method_w64_l_u_q_product_integer_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_d_product_widen_high_x`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_d_product_widen_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_f_sum_int_high_z`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_f_sum_int_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_f_sum_integer_high_z`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_f_sum_integer_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_f_sum_plain_known`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_f_sum_plain_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w65_b_u_f_sum_widen_high_z`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_f_sum_widen_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_q_or_int_known`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_q_or_int_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w65_b_u_q_sum_int_high_x`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_q_sum_int_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_q_xor_integer_high_x`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_q_xor_integer_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_b_u_q_xor_widen_known`](../../tests/gen/ch7/test_gen_cross_method_w65_b_u_q_xor_widen_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ||
| [`test_gen_cross_method_w65_l_s_f_and_integer_known`](../../tests/gen/ch7/test_gen_cross_method_w65_l_s_f_and_integer_known.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 | Verilator 5.052 ||
| [`test_gen_cross_method_w65_l_u_f_or_plain_high_z`](../../tests/gen/ch7/test_gen_cross_method_w65_l_u_f_or_plain_high_z.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |
| [`test_gen_cross_method_w65_l_u_f_xor_plain_high_x`](../../tests/gen/ch7/test_gen_cross_method_w65_l_u_f_xor_plain_high_x.sv) |固定の返り型で、配列の縮小は縮小する前に各要素を変換します。| 7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2 |標準のみ| x/z |

<a id="generated-by-generatorsinteraction_queuepy"></a>

## 生成者: `generators/interaction_queue.py`

48 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_queue_w129_b_s_c2_n0_pop_back_z`](../../tests/gen/ch7/test_gen_cross_queue_w129_b_s_c2_n0_pop_back_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.4.5 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_queue_w129_b_u_c2_n0_push_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w129_b_u_c2_n0_push_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w129_b_u_cu_n2_pop_front_x`](../../tests/gen/ch7/test_gen_cross_queue_w129_b_u_cu_n2_pop_front_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w129_l_s_c2_n0_insert_known`](../../tests/gen/ch7/test_gen_cross_queue_w129_l_s_c2_n0_insert_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_queue_w129_l_s_c3_n3_push_front_z`](../../tests/gen/ch7/test_gen_cross_queue_w129_l_s_c3_n3_push_front_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_queue_w129_l_u_c3_n0_write_end_x`](../../tests/gen/ch7/test_gen_cross_queue_w129_l_u_c3_n0_write_end_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w1_b_s_cu_n0_insert_x`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_s_cu_n0_insert_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w1_b_u_c2_n0_push_front_z`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c2_n0_push_front_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w1_b_u_c2_n2_push_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c2_n2_push_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n0_pop_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n0_pop_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.4.5 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_queue_w1_b_u_c3_n0_push_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n0_push_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n0_push_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n0_push_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n2_insert_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n2_insert_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n2_pop_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n2_pop_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n2_pop_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n2_pop_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n2_push_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n2_push_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n2_write_end_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n2_write_end_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n3_insert_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n3_insert_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n3_pop_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n3_pop_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_b_u_c3_n3_write_end_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_b_u_c3_n3_write_end_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w1_l_s_cu_n0_pop_front_z`](../../tests/gen/ch7/test_gen_cross_queue_w1_l_s_cu_n0_pop_front_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.4.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w1_l_s_cu_n2_push_back_x`](../../tests/gen/ch7/test_gen_cross_queue_w1_l_s_cu_n2_push_back_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_queue_w1_l_u_cu_n2_pop_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w1_l_u_cu_n2_pop_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w32_b_s_cu_n3_pop_back_x`](../../tests/gen/ch7/test_gen_cross_queue_w32_b_s_cu_n3_pop_back_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w32_b_u_c3_n3_push_back_z`](../../tests/gen/ch7/test_gen_cross_queue_w32_b_u_c3_n3_push_back_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w32_b_u_cu_n2_push_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w32_b_u_cu_n2_push_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w32_l_s_c2_n0_pop_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w32_l_s_c2_n0_pop_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.4.5 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w32_l_s_c2_n0_write_end_x`](../../tests/gen/ch7/test_gen_cross_queue_w32_l_s_c2_n0_write_end_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w32_l_u_cu_n2_insert_z`](../../tests/gen/ch7/test_gen_cross_queue_w32_l_u_cu_n2_insert_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.2.7 |標準のみ| x/z |
| [`test_gen_cross_queue_w33_b_s_cu_n3_insert_z`](../../tests/gen/ch7/test_gen_cross_queue_w33_b_s_cu_n3_insert_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w33_b_u_c2_n2_pop_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w33_b_u_c2_n2_pop_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w33_b_u_cu_n0_push_back_x`](../../tests/gen/ch7/test_gen_cross_queue_w33_b_u_cu_n0_push_back_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w33_l_s_cu_n0_pop_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w33_l_s_cu_n0_pop_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.4.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w33_l_u_c3_n2_push_front_x`](../../tests/gen/ch7/test_gen_cross_queue_w33_l_u_c3_n2_push_front_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_queue_w33_l_u_cu_n0_write_end_z`](../../tests/gen/ch7/test_gen_cross_queue_w33_l_u_cu_n0_write_end_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w64_b_s_cu_n0_push_front_known`](../../tests/gen/ch7/test_gen_cross_queue_w64_b_s_cu_n0_push_front_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w64_b_u_c2_n2_pop_back_z`](../../tests/gen/ch7/test_gen_cross_queue_w64_b_u_c2_n2_pop_back_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w64_b_u_cu_n3_write_end_x`](../../tests/gen/ch7/test_gen_cross_queue_w64_b_u_cu_n3_write_end_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w64_l_s_cu_n3_pop_front_x`](../../tests/gen/ch7/test_gen_cross_queue_w64_l_s_cu_n3_pop_front_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w64_l_s_cu_n3_push_back_z`](../../tests/gen/ch7/test_gen_cross_queue_w64_l_s_cu_n3_push_back_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 |標準のみ| x/z |
| [`test_gen_cross_queue_w64_l_u_c3_n0_insert_known`](../../tests/gen/ch7/test_gen_cross_queue_w64_l_u_c3_n0_insert_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_queue_w65_b_s_c2_n2_push_back_known`](../../tests/gen/ch7/test_gen_cross_queue_w65_b_s_c2_n2_push_back_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.7 7.10.1 6.11.2 11.8.2 7.10.5 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w65_b_s_cu_n3_push_front_x`](../../tests/gen/ch7/test_gen_cross_queue_w65_b_s_cu_n3_push_front_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.6 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w65_b_u_c2_n2_insert_x`](../../tests/gen/ch7/test_gen_cross_queue_w65_b_u_c2_n2_insert_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.2 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w65_b_u_c3_n0_pop_front_z`](../../tests/gen/ch7/test_gen_cross_queue_w65_b_u_c3_n0_pop_front_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.4 7.10.1 6.11.2 11.8.2 7.4.5 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_queue_w65_l_s_c2_n2_write_end_z`](../../tests/gen/ch7/test_gen_cross_queue_w65_l_s_c2_n2_write_end_z.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_queue_w65_l_s_cu_n2_write_end_known`](../../tests/gen/ch7/test_gen_cross_queue_w65_l_s_cu_n2_write_end_known.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.1 6.11.2 11.8.2 7.10.2.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_queue_w65_l_u_c3_n3_pop_back_x`](../../tests/gen/ch7/test_gen_cross_queue_w65_l_u_c3_n3_pop_back_x.sv) |キュー更新はタイプされた値、順序、容量、独立した値のコピーを保持します| 7.10.2.5 7.10.1 6.11.2 11.8.2 7.10.2.7 7.10.5 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorsinteraction_queue_refpy"></a>

## 生成者: `generators/interaction_queue_ref.py`

60 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_qref_w129_b_t_l_clear_known`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_t_l_clear_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w129_b_t_l_copy_known`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_t_l_copy_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w129_b_t_l_delete_other_known`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_t_l_delete_other_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w129_b_t_l_insert_known`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_t_l_insert_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w129_b_u_f_concat_z`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_u_f_concat_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w129_b_u_f_delete_held_x`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_u_f_delete_held_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w129_b_u_f_push_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w129_b_u_f_push_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ||
| [`test_gen_cross_qref_w129_l_t_l_push_front_z`](../../tests/gen/ch7/test_gen_cross_qref_w129_l_t_l_push_front_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w129_l_t_m_pop_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w129_l_t_m_pop_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w129_l_u_m_pop_back_x`](../../tests/gen/ch7/test_gen_cross_qref_w129_l_u_m_pop_back_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w1_b_t_f_clear_z`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_t_f_clear_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w1_b_t_f_pop_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_t_f_pop_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w1_b_t_m_concat_known`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_t_m_concat_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w1_b_t_m_push_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_t_m_push_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w1_b_u_l_delete_held_known`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_u_l_delete_held_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w1_b_u_l_pop_front_x`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_u_l_pop_front_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w1_b_u_m_push_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w1_b_u_m_push_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w1_l_t_f_copy_z`](../../tests/gen/ch7/test_gen_cross_qref_w1_l_t_f_copy_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w1_l_t_m_insert_x`](../../tests/gen/ch7/test_gen_cross_qref_w1_l_t_m_insert_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w1_l_u_l_delete_other_known`](../../tests/gen/ch7/test_gen_cross_qref_w1_l_u_l_delete_other_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w32_b_t_f_push_back_x`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_t_f_push_back_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w32_b_t_l_concat_known`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_t_l_concat_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w32_b_t_l_pop_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_t_l_pop_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w32_b_u_l_copy_known`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_u_l_copy_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ||
| [`test_gen_cross_qref_w32_b_u_l_insert_z`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_u_l_insert_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w32_b_u_m_delete_other_known`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_u_m_delete_other_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w32_b_u_m_pop_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w32_b_u_m_pop_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w32_l_u_f_push_front_x`](../../tests/gen/ch7/test_gen_cross_qref_w32_l_u_f_push_front_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w32_l_u_m_clear_known`](../../tests/gen/ch7/test_gen_cross_qref_w32_l_u_m_clear_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w32_l_u_m_delete_held_z`](../../tests/gen/ch7/test_gen_cross_qref_w32_l_u_m_delete_held_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w33_b_t_l_push_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_t_l_push_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w33_b_t_m_clear_known`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_t_m_clear_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w33_b_t_m_copy_known`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_t_m_copy_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w33_b_t_m_pop_back_x`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_t_m_pop_back_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w33_b_u_f_insert_known`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_u_f_insert_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ||
| [`test_gen_cross_qref_w33_b_u_f_pop_front_z`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_u_f_pop_front_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w33_b_u_l_push_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w33_b_u_l_push_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w33_l_t_l_delete_held_known`](../../tests/gen/ch7/test_gen_cross_qref_w33_l_t_l_delete_held_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w33_l_u_f_delete_other_x`](../../tests/gen/ch7/test_gen_cross_qref_w33_l_u_f_delete_other_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w33_l_u_m_concat_z`](../../tests/gen/ch7/test_gen_cross_qref_w33_l_u_m_concat_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w64_b_t_f_delete_held_known`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_t_f_delete_held_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w64_b_t_f_insert_known`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_t_f_insert_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w64_b_t_f_pop_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_t_f_pop_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w64_b_t_f_push_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_t_f_push_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w64_b_t_m_delete_other_z`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_t_m_delete_other_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ| x/z |
| [`test_gen_cross_qref_w64_b_u_l_concat_x`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_u_l_concat_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w64_b_u_m_push_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w64_b_u_m_push_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w64_l_u_f_copy_z`](../../tests/gen/ch7/test_gen_cross_qref_w64_l_u_f_copy_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w64_l_u_f_pop_back_known`](../../tests/gen/ch7/test_gen_cross_qref_w64_l_u_f_pop_back_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w64_l_u_l_clear_x`](../../tests/gen/ch7/test_gen_cross_qref_w64_l_u_l_clear_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w65_b_t_f_delete_other_known`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_t_f_delete_other_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w65_b_t_l_pop_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_t_l_pop_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w65_b_t_m_delete_held_known`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_t_m_delete_held_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 | Verilator 5.052 ||
| [`test_gen_cross_qref_w65_b_t_m_push_front_known`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_t_m_push_front_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w65_b_u_f_clear_known`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_u_f_clear_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 | Verilator 5.052 ||
| [`test_gen_cross_qref_w65_b_u_l_pop_back_z`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_u_l_pop_back_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w65_b_u_m_copy_x`](../../tests/gen/ch7/test_gen_cross_qref_w65_b_u_m_copy_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w65_l_t_f_concat_known`](../../tests/gen/ch7/test_gen_cross_qref_w65_l_t_f_concat_known.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 7.10.5 |標準のみ||
| [`test_gen_cross_qref_w65_l_u_l_push_back_z`](../../tests/gen/ch7/test_gen_cross_qref_w65_l_u_l_push_back_z.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |
| [`test_gen_cross_qref_w65_l_u_m_insert_x`](../../tests/gen/ch7/test_gen_cross_qref_w65_l_u_m_insert_x.sv) |キュー ref 引数は移動、削除、置換に関して要素のアイデンティティを保持します。| 7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2 |標準のみ| x/z |

<a id="generated-by-generatorsinteraction_resizepy"></a>

## 生成者: `generators/interaction_resize.py`

38 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_resize_w129_b_u_known_n0_1_reset`](../../tests/gen/ch7/test_gen_cross_resize_w129_b_u_known_n0_1_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w129_b_u_x_n2_0_copy`](../../tests/gen/ch7/test_gen_cross_resize_w129_b_u_x_n2_0_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w129_b_u_z_n2_0_copy`](../../tests/gen/ch7/test_gen_cross_resize_w129_b_u_z_n2_0_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w129_l_s_z_n3_4_self`](../../tests/gen/ch7/test_gen_cross_resize_w129_l_s_z_n3_4_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w129_l_u_known_n0_2_self`](../../tests/gen/ch7/test_gen_cross_resize_w129_l_u_known_n0_2_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w129_l_u_x_n2_0_copy`](../../tests/gen/ch7/test_gen_cross_resize_w129_l_u_x_n2_0_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w1_b_s_known_n0_4_self`](../../tests/gen/ch7/test_gen_cross_resize_w1_b_s_known_n0_4_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w1_b_u_known_n0_2_reset`](../../tests/gen/ch7/test_gen_cross_resize_w1_b_u_known_n0_2_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w1_b_u_known_n0_4_copy`](../../tests/gen/ch7/test_gen_cross_resize_w1_b_u_known_n0_4_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w1_b_u_x_n2_1_copy`](../../tests/gen/ch7/test_gen_cross_resize_w1_b_u_x_n2_1_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w1_b_u_z_n2_1_self`](../../tests/gen/ch7/test_gen_cross_resize_w1_b_u_z_n2_1_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w1_l_u_known_n3_0_copy`](../../tests/gen/ch7/test_gen_cross_resize_w1_l_u_known_n3_0_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w1_l_u_x_n2_2_copy`](../../tests/gen/ch7/test_gen_cross_resize_w1_l_u_x_n2_2_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w1_l_u_z_n3_0_reset`](../../tests/gen/ch7/test_gen_cross_resize_w1_l_u_z_n3_0_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w32_b_u_known_n0_0_copy`](../../tests/gen/ch7/test_gen_cross_resize_w32_b_u_known_n0_0_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w32_b_u_x_n3_2_self`](../../tests/gen/ch7/test_gen_cross_resize_w32_b_u_x_n3_2_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w32_b_u_z_n2_0_reset`](../../tests/gen/ch7/test_gen_cross_resize_w32_b_u_z_n2_0_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w32_l_s_known_n0_1_copy`](../../tests/gen/ch7/test_gen_cross_resize_w32_l_s_known_n0_1_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w32_l_u_x_n3_4_copy`](../../tests/gen/ch7/test_gen_cross_resize_w32_l_u_x_n3_4_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w32_l_u_z_n2_1_reset`](../../tests/gen/ch7/test_gen_cross_resize_w32_l_u_z_n2_1_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w33_b_s_known_n0_0_self`](../../tests/gen/ch7/test_gen_cross_resize_w33_b_s_known_n0_0_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w33_b_u_x_n2_2_self`](../../tests/gen/ch7/test_gen_cross_resize_w33_b_u_x_n2_2_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w33_b_u_z_n2_4_copy`](../../tests/gen/ch7/test_gen_cross_resize_w33_b_u_z_n2_4_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w33_l_s_known_n2_2_reset`](../../tests/gen/ch7/test_gen_cross_resize_w33_l_s_known_n2_2_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w33_l_u_x_n3_1_reset`](../../tests/gen/ch7/test_gen_cross_resize_w33_l_u_x_n3_1_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w33_l_u_z_n2_4_self`](../../tests/gen/ch7/test_gen_cross_resize_w33_l_u_z_n2_4_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w64_b_u_known_n0_2_copy`](../../tests/gen/ch7/test_gen_cross_resize_w64_b_u_known_n0_2_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w64_b_u_x_n3_0_self`](../../tests/gen/ch7/test_gen_cross_resize_w64_b_u_x_n3_0_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w64_b_u_z_n3_2_copy`](../../tests/gen/ch7/test_gen_cross_resize_w64_b_u_z_n3_2_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w64_l_s_x_n2_4_reset`](../../tests/gen/ch7/test_gen_cross_resize_w64_l_s_x_n2_4_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w64_l_u_known_n0_0_reset`](../../tests/gen/ch7/test_gen_cross_resize_w64_l_u_known_n0_0_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w64_l_u_z_n3_1_self`](../../tests/gen/ch7/test_gen_cross_resize_w64_l_u_z_n3_1_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w65_b_s_z_n3_2_reset`](../../tests/gen/ch7/test_gen_cross_resize_w65_b_s_z_n3_2_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w65_b_u_known_n0_4_reset`](../../tests/gen/ch7/test_gen_cross_resize_w65_b_u_known_n0_4_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_resize_w65_b_u_x_n3_1_copy`](../../tests/gen/ch7/test_gen_cross_resize_w65_b_u_x_n3_1_copy.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w65_l_u_known_n0_1_self`](../../tests/gen/ch7/test_gen_cross_resize_w65_l_u_known_n0_1_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w65_l_u_x_n2_0_self`](../../tests/gen/ch7/test_gen_cross_resize_w65_l_u_x_n2_0_self.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_resize_w65_l_u_z_n3_4_reset`](../../tests/gen/ch7/test_gen_cross_resize_w65_l_u_z_n3_4_reset.sv) |動的配列サイズ変更はプレフィックス、タイプデフォルト、独立したコピーを保持します| 7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorsinteraction_structpy"></a>

## 生成者: `generators/interaction_struct.py`

36 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_struct_w129_f_su_l_z_w_n`](../../tests/gen/ch7/test_gen_cross_struct_w129_f_su_l_z_w_n.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w129_f_uu_b_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w129_f_uu_b_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w129_f_uu_b_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w129_f_uu_b_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w129_f_uu_l_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w129_f_uu_l_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w129_f_uu_l_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w129_f_uu_l_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w129_l_us_b_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w129_l_us_b_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w1_f_us_l_z_m_n`](../../tests/gen/ch7/test_gen_cross_struct_w1_f_us_l_z_m_n.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w1_f_uu_b_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w1_f_uu_b_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w1_f_uu_l_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w1_f_uu_l_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w1_f_uu_l_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w1_f_uu_l_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w1_l_su_b_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w1_l_su_b_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w1_l_uu_b_k_w_b`](../../tests/gen/ch7/test_gen_cross_struct_w1_l_uu_b_k_w_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w32_f_ss_l_k_w_b`](../../tests/gen/ch7/test_gen_cross_struct_w32_f_ss_l_k_w_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w32_f_uu_b_k_m_n`](../../tests/gen/ch7/test_gen_cross_struct_w32_f_uu_b_k_m_n.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w32_f_uu_b_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w32_f_uu_b_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w32_f_uu_l_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w32_f_uu_l_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w32_f_uu_l_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w32_f_uu_l_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w32_l_uu_b_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w32_l_uu_b_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w33_f_ss_b_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w33_f_ss_b_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w33_f_uu_b_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w33_f_uu_b_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w33_f_uu_b_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w33_f_uu_b_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w33_f_uu_l_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w33_f_uu_l_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w33_f_uu_l_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w33_f_uu_l_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w33_l_uu_l_x_w_n`](../../tests/gen/ch7/test_gen_cross_struct_w33_l_uu_l_x_w_n.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w64_f_uu_b_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w64_f_uu_b_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w64_f_uu_b_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w64_f_uu_b_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w64_f_uu_l_k_w_n`](../../tests/gen/ch7/test_gen_cross_struct_w64_f_uu_l_k_w_n.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w64_f_uu_l_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w64_f_uu_l_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w64_f_uu_l_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w64_f_uu_l_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w64_l_ss_b_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w64_l_ss_b_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w65_f_su_b_k_w_b`](../../tests/gen/ch7/test_gen_cross_struct_w65_f_su_b_k_w_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w65_f_uu_b_x_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w65_f_uu_b_x_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w65_f_uu_b_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w65_f_uu_b_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w65_f_uu_l_k_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w65_f_uu_l_k_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_struct_w65_f_uu_l_z_m_b`](../../tests/gen/ch7/test_gen_cross_struct_w65_f_uu_l_z_m_b.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_struct_w65_l_us_l_x_m_n`](../../tests/gen/ch7/test_gen_cross_struct_w65_l_us_l_x_m_n.sv) |パッケージレイアウト、フィールド記号、整数/メンバー更新は値とタグを保持します| 7.2.1 10.4.1 10.4.2 11.8.1 11.8.2 6.11.2 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorswide_pathspy"></a>

## 生成者: `generators/wide_paths.py`

14 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_wide_select_w127_2state`](../../tests/gen/ch7/test_gen_wide_select_w127_2state.sv) |パート選択と packed 配列は 127 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w127_4state`](../../tests/gen/ch7/test_gen_wide_select_w127_4state.sv) |パート選択と packed 配列は 127 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w128_2state`](../../tests/gen/ch7/test_gen_wide_select_w128_2state.sv) |パート選択と packed 配列は 128 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w128_4state`](../../tests/gen/ch7/test_gen_wide_select_w128_4state.sv) |パート選択と packed 配列は 128 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w129_2state`](../../tests/gen/ch7/test_gen_wide_select_w129_2state.sv) |パート選択と packed 配列は 129 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w129_4state`](../../tests/gen/ch7/test_gen_wide_select_w129_4state.sv) |パート選択と packed 配列は 129 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w200_2state`](../../tests/gen/ch7/test_gen_wide_select_w200_2state.sv) |パート選択と packed 配列は 200 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w200_4state`](../../tests/gen/ch7/test_gen_wide_select_w200_4state.sv) |パート選択と packed 配列は 200 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w63_2state`](../../tests/gen/ch7/test_gen_wide_select_w63_2state.sv) |パート選択と packed 配列は 63 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w63_4state`](../../tests/gen/ch7/test_gen_wide_select_w63_4state.sv) |パート選択と packed 配列は 63 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w64_2state`](../../tests/gen/ch7/test_gen_wide_select_w64_2state.sv) |パート選択と packed 配列は 64 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w64_4state`](../../tests/gen/ch7/test_gen_wide_select_w64_4state.sv) |パート選択と packed 配列は 64 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w65_2state`](../../tests/gen/ch7/test_gen_wide_select_w65_2state.sv) |パート選択と packed 配列は 65 - bit 2 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Verilator 5.052 ||
| [`test_gen_wide_select_w65_4state`](../../tests/gen/ch7/test_gen_wide_select_w65_4state.sv) |パート選択と packed 配列は 65 - bit 4 状態値を選択します| 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
