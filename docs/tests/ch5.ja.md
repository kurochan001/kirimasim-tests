<a id="clause-5-lexical-conventions"></a>

# 句 5 : 語彙規則

[English](ch5.md) / [日本語](ch5.ja.md)

[すべての章](README.ja.md) .346 248 のテストを生成した。テストのメタデータから `tools/suite_catalog.py` がこのページを書きました。テストを編集しろ このページじゃない

初めて読む場合は、[実在テストを入力から期待値まで読み解く](../faq.md#q49-read-a-real-test)を参照してください。oracle欄は固定版による確認の記録です。[現在のビルドの合格を保証しない理由](../faq.md#q4-are-expected-outputs-copied-from-a-simulator)を確認してください。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_lexical_comments_and_keyword_identifiers`](../../tests/ch5/test_lexical_comments_and_keyword_identifiers.sv) |コメントとスペースはトークンを分離しますが、エスクアードキーワードと大文字識別子は使えます。| 5.2 5.3 5.6.2 | Icarus Verilog 13.0 ||
| [`test_end_of_file_separates_tokens`](../../tests/ch5/test_end_of_file_separates_tokens.sv) |ソースファイルの終わりは空白であるため、トークンが終わった直後に新しい行が入らないファイルは完了し、最後のトークンは次のファイルの最初のトークンに入らない。| 5.3 | Icarus Verilog 13.0 |いくつかのファイル|
| [`test_free_format_layout`](../../tests/ch5/test_free_format_layout.sv) |空白、タブ、新しい行、フォームフィードで区切るだけで、文字列リテラル内の空白とタブは保持されます。| 5.3 5.2 5.9 | Icarus Verilog 13.0 ||
| [`test_white_space_kinds_separate_tokens`](../../tests/ch5/test_white_space_kinds_separate_tokens.sv) |空白、タブ、新しい行、フォームフィード、ファイルの終わりなどの各種の空白は、それ以外は1つのトークンを形成する2つのトークン を分離します。 つまり、 & &b は論理的な AND ではなく、縮小 AND を伴うビット単位の AND です。| 5.3 A.9.4 A.10 | Icarus Verilog 13.0 |いくつかのファイル|
| [`test_block_comment_not_nested`](../../tests/ch5/test_block_comment_not_nested.sv) |ブロックコメントはネストされません。最初の終了トークンは、より多くの開始トークンを持つブロックコメントを閉じます。一行のコメントトークンはブロックコメント内で意味を持たない。| 5.4 | Verilator 5.052 ||
| [`test_comment_forms`](../../tests/ch5/test_comment_forms.sv) |1 行とブロックコメント: ブロックコメントは最初の閉じる区切りで終わり、それぞれの形の区切りは互いに意味を持たない| 5.4 | Icarus Verilog 13.0 ||
| [`test_comment_text_and_end_forms`](../../tests/ch5/test_comment_text_and_end_forms.sv) |ブロックコメントには、最初の閉じ区切りまで任意の文字を含めることができ、空でも複数行にわたってもよい。1行コメントは内容の有無にかかわらず改行で終わり、次の行から再びソーステキストとなる。| 5.4 A.9.2 | Verilator 5.052 ||
| [`test_operator_token_lengths`](../../tests/ch5/test_operator_token_lengths.sv) |演算子は1，2，3文字のトークンである。単項演算子はオペランドの前、二項演算子は2つのオペランドの間に置きます。条件演算子は、3つのオペランドの間に2つの演算子文字を使います。| 5.5 11.3 11.4.10 11.4.5 11.4.6 | Icarus Verilog 13.0 ||
| [`test_operator_unary_binary_token_boundaries`](../../tests/ch5/test_operator_unary_binary_token_boundaries.sv) |隣接する一値演算子と二値演算子はそれぞれの役割を保持する| 5.5 | Icarus Verilog 13.0 ||
| [`test_A_extra_lexical_spaces`](../../tests/ch5/test_A_extra_lexical_spaces.sv) |単純識別子、システムタスク識別子、無基準無サイズリテラル、時間リテラルは埋め込みスペースなしで書かれます。 $b , $display , '0と10nsはそれぞれ1つのトークンです。| 5.6 5.7 5.9 A.10 | Icarus Verilog 13.0 ||
| [`test_identifier_1024_characters`](../../tests/ch5/test_identifier_1024_characters.sv) |識別子の長さを制限する実装は、1024 文字の名前を受け入れ、最後の文字のみが異なる場合はそれらを区別する。| 5.6 21.2.1.5 | Icarus Verilog 13.0 |いくつかのファイル|
| [`test_identifier_categories_in_declarations`](../../tests/ch5/test_identifier_categories_in_declarations.sv) |設計がmodule、インスタンス、net、変数、3方向すべてのポート、task、function、名前付きブロック、generateブロック、genvar、パラメータ、型、列挙値、構造体メンバー、interface、配列、動的配列、添字変数、仮引数に付ける名前は識別子であり、それぞれテストが値や効果を表示するオブジェクトを指す| 5.6 5.6.1 6.18 27.4 A.9.3 A.10 | Icarus Verilog 13.0 ||
| [`test_identifier_forms`](../../tests/ch5/test_identifier_forms.sv) |下線と大文字と小文字を混ぜた識別子を使い、ブロック名を生成します| 5.6 27.4 | Icarus Verilog 13.0 ||
| [`test_identifier_if_suffix`](../../tests/ch5/test_identifier_if_suffix.sv) |"if" "(" で終わる識別子は if キーワードではありません。| 5.6 5.6.2 | Icarus Verilog 13.0 ||
| [`test_identifier_leading_underscore`](../../tests/ch5/test_identifier_leading_underscore.sv) |_133_ や _1e5 のような下線で始まり、数字を含む識別子| 5.6 5.7.1 | Icarus Verilog 13.0 ||
| [`test_identifier_simple_escaped_and_system_name_forms`](../../tests/ch5/test_identifier_simple_escaped_and_system_name_forms.sv) |文字または下線で始まり、数字、下線、ドル記号を持つ単純な一文字識別子は大小分けされます。エスケープされた識別子は、 それらを終わらせる空白 (空白、タブ、新しい行) まで印刷可能な文字を保持し、単純な識別子と同じ文字で同じオブジェクトを名付けます。システムの関数名は文字と数字と下線とドル記号を含みます| 5.6 5.6.1 5.6.3 A.9.3 | Icarus Verilog 13.0 ||
| [`test_illegal_identifier_starts_with_digit`](../../tests/ch5/test_illegal_identifier_starts_with_digit.sv) |数字で始まる単純な識別子は拒否されます| 5.6 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_keyword_as_identifier`](../../tests/ch5/test_illegal_keyword_as_identifier.sv) |変数の名前として使用された予約キーワードは拒否されました| 5.6 5.6.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_lexical_identifiers`](../../tests/ch5/test_lexical_identifiers.sv) |テストの項目は，IEEE 1800-2023章，5.6章，識別子とキーワードである。| 5.6 | Icarus Verilog 13.0 ||
| [`test_simple_identifier_character_set`](../../tests/ch5/test_simple_identifier_character_set.sv) |単純識別子は文字、数字、ドル記号、下線で構成され、文字または下線で始まり、大小文字を区別し、他の文字で終わります。エスクアード識別子はその文字を保持します。| 5.6 5.6.1 | Icarus Verilog 13.0 ||
| [`test_escaped_identifier_character_domain`](../../tests/ch5/test_escaped_identifier_character_domain.sv) |標準の例の多文字名とエスクアードキーワードと同様に、長い名前の中に数字記号を含む、33から126までの印刷可能なASCII文字はすべてエスクアード識別子に表示される。| 5.6.1 | Icarus Verilog 13.0 ||
| [`test_escaped_identifier_comment_chars`](../../tests/ch5/test_escaped_identifier_comment_chars.sv) |コメントの区切り文字を含むエスクープされた識別子はコメントではなく名前であり、演算子の後ろにも表示されます。| 5.6.1 11.4.1 11.4.2 | Icarus Verilog 13.0 ||
| [`test_escaped_identifier_printable_and_keywords`](../../tests/ch5/test_escaped_identifier_printable_and_keywords.sv) |ASCII 文字はすべて印刷可能で、バックスラッシュと終わりの空白は名前の一部ではなく、単純なスペルと同じで、エスクープキーワードは通常の識別子です。| 5.6.1 | Verilator 5.052 ||
| [`test_escaped_identifier_with_dot`](../../tests/ch5/test_escaped_identifier_with_dot.sv) |点を含むエスクープ識別子は単一の単純な名前であり、同じ文字を持つ階層名とは異なります。| 5.6.1 23.6 | Icarus Verilog 13.0 ||
| [`test_illegal_system_name_space_after_dollar`](../../tests/ch5/test_illegal_system_name_space_after_dollar.sv) |システムタスクの名前とドル記号の間の空白は無視されます| 5.6.3 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_system_function_names_cell_reset_and_attributes`](../../tests/ch5/test_system_function_names_cell_reset_and_attributes.sv) |標記関数は，セルタグと数値インスタンス属性を検査する。| 5.6.3 22.10 37.83 38.37.1 |標準のみ| VPI |
| [`test_system_name_dollar_prefix_not_escaped`](../../tests/ch5/test_system_name_dollar_prefix_not_escaped.sv) |ユーザ名は、ユーザが指定した名前である。ユーザ名はユーザの名前と同じである。ユーザー名は、ユーザーが指定した名称である。ユー ザ名は、ユ ーザが指定する名前である。| 5.6.3 5.6.1 | Verilator 5.052 ||
| [`test_directive_effect_from_read_point`](../../tests/ch5/test_directive_effect_from_read_point.sv) |コンパイラ指令は、読み込まれたときに効果を発揮し、他の指令が変更するまで、コンパイラユニットの残りの部分に対して、モジュール境界を超えて保持されます。| 5.6.4 22.5.1 22.5.2 | Icarus Verilog 13.0 ||
| [`test_directive_redefinition_read_order`](../../tests/ch5/test_directive_redefinition_read_order.sv) |マクロの再定義は、後での使用に影響しますが、既に読まれた宣言には影響しません| 5.6.4 22.5.1 | Icarus Verilog 13.0 ||
| [`test_constants_edge_cases`](../../tests/ch5/test_constants_edge_cases.sv) |テスト: 定数エッジの場合| 5.7 | Icarus Verilog 13.0 ||
| [`test_ieee1800_2023_literal_edge`](../../tests/ch5/test_ieee1800_2023_literal_edge.sv) |文字の端の大文字| 5.7 5.7.1 5.7.2 5.9 6.11 6.16 10.7 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_based_value_embedded_space`](../../tests/ch5/test_illegal_based_value_embedded_space.sv) |基底リテラルの値の数字の内部のスペースは拒否されます| 5.7 5.7.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_decimal_number_embedded_space`](../../tests/ch5/test_illegal_decimal_number_embedded_space.sv) |小数点数の数字の内側のスペースは拒否されます| 5.7 5.7.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_number_embedded_space`](../../tests/ch5/test_illegal_real_number_embedded_space.sv) |実数の指数とマンチサの間の空白は拒否されます| 5.7 5.7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_time_literal_space_before_unit`](../../tests/ch5/test_illegal_time_literal_space_before_unit.sv) |時間リテラルの数字と単位の間の空白は無視されます| 5.7 5.8 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_unbased_unsized_literal_space`](../../tests/ch5/test_illegal_unbased_unsized_literal_space.sv) |基準のない無限リテラルのアポストロフと値の間の空白は無視されます| 5.7 5.7.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_number_grammar_every_base_digit_and_real_form`](../../tests/ch5/test_number_grammar_every_base_digit_and_real_form.sv) |各基数のサイズ指定あり／なしの整数リテラル、s／Sと基数文字の大文字／小文字、x・X・z・Z・?を含む全数字、最初の数字より後のアンダースコア、xまたはzの1桁だけの十進数、指数符号の有無を含む固定小数点／指数形式の実数、および基数・サイズ未指定リテラル| 5.7 5.7.1 5.7.2 A.8.7 | Icarus Verilog 13.0 | x/z |
| [`test_real_literal_syntax_forms`](../../tests/ch5/test_real_literal_syntax_forms.sv) |実数リテラルは、固定小数点形式、または小数部の有無を選べる十進仮数にe／Eと省略可能な符号付き指数を続けた形式で記述し、どちらもreal値となる| 5.7 5.7.2 | Icarus Verilog 13.0 ||
| [`test_based_literal_letters_and_tokens`](../../tests/ch5/test_based_literal_letters_and_tokens.sv) |基底文字、s 指定子、基底リテラルの十六進数数字は大小を区別しない。値の前に空白を入れ、サイズの後に空白を入れることができる。3 つのトークンはマクロから来ることができ、各基底はそれぞれ独自の数字を取る。| 5.7.1 5.7 | Icarus Verilog 13.0 | x/z |
| [`test_boundary_values`](../../tests/ch5/test_boundary_values.sv) |角の場合 - 境界値| 5.7.1 6.11 11.4.3 11.4.10 | Icarus Verilog 13.0 ||
| [`test_format_hex`](../../tests/ch5/test_format_hex.sv) |フォーマット Hex テスト| 5.7.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_illegal_based_literal_apostrophe_space`](../../tests/ch5/test_illegal_based_literal_apostrophe_space.sv) |基底リテラルのアポストロフと基底文字の間の空白は無視されます| 5.7.1 5.7 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_based_literal_sign_after_base`](../../tests/ch5/test_illegal_based_literal_sign_after_base.sv) |基礎形式と基礎リテラルの値の間のマイナス記号は拒否されます| 5.7.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_based_literal_signed_base_space`](../../tests/ch5/test_illegal_based_literal_signed_base_space.sv) |符号付き基底指定子の s と基底文字の間の空白は無視されます| 5.7.1 5.7 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_decimal_literal_digit_and_x`](../../tests/ch5/test_illegal_decimal_literal_digit_and_x.sv) |普通の数字と x の数字を混ぜた小数点リテラルは拒否されます| 5.7.1 | Icarus Verilog 13.0 |違法なデザイン x/z|
| [`test_illegal_decimal_literal_two_unknown_digits`](../../tests/ch5/test_illegal_decimal_literal_two_unknown_digits.sv) |未知の2桁の小数点リテラルを拒否| 5.7.1 | Icarus Verilog 13.0 |違法なデザイン x/z|
| [`test_int_literal_edge_cases`](../../tests/ch5/test_int_literal_edge_cases.sv) |テスト: 整数リテラルの端の場合| 5.7.1 | Icarus Verilog 13.0 ||
| [`test_lexical_numbers`](../../tests/ch5/test_lexical_numbers.sv) |章5.7：数字| 5.7.1 5.7.2 | Icarus Verilog 13.0 | x/z |
| [`test_literal_base`](../../tests/ch5/test_literal_base.sv) |文字ベース形式のテスト| 5.7.1 | Icarus Verilog 13.0 ||
| [`test_literal_corner`](../../tests/ch5/test_literal_corner.sv) |様々な文字形式と表現をテスト| 5.7.1 5.7.2 5.9 6.16 | Icarus Verilog 13.0 | x/z |
| [`test_literal_format`](../../tests/ch5/test_literal_format.sv) |文字形式テスト| 5.7.1 21.2.1.1 | Icarus Verilog 13.0 ||
| [`test_literal_unsized_width_and_sign_extension`](../../tests/ch5/test_literal_unsized_width_and_sign_extension.sv) |非サイズリテラルは少なくとも32ビットであり、値と符号が必要な限り多く、integerリテラルは符号付きlogicベクトル\[ n-1:0 \]、サイズ付き符号付きまたは負のリテラルは無符号または符号付きlogicターゲットに符号を拡張したものであり、単純小数点リテラルは一進符号を持つことができる。| 5.7.1 6.20.2 | Icarus Verilog 13.0 | x/z |
| [`test_literal_xz_digit_widths_and_padding`](../../tests/ch5/test_literal_xz_digit_widths_and_padding.sv) |x、z、?の1桁は、16進数では4ビット、8進数では3ビット、2進数では1ビットを設定する。xとzは大文字小文字を区別しない。指定された最左のbitがxまたはzのリテラルは、その値で埋められる。また、サイズを指定しない符号なしのリテラルは、文脈の幅までその値で拡張される。| 5.7.1 | Icarus Verilog 13.0 | x/z |
| [`test_literals_macros_specify`](../../tests/ch5/test_literals_macros_specify.sv) |基底リテラル、下線、実数と文字列リテラル、マクロ、specparam を使用する| 5.7.1 22.5.1 5.12 6.20.5 | Icarus Verilog 13.0 ||
| [`test_logic_literal_edge_cases`](../../tests/ch5/test_logic_literal_edge_cases.sv) |テスト: 論理リテラルエッジケース| 5.7.1 | Icarus Verilog 13.0 ||
| [`test_primary_literal_forms_number_time_unbased_string`](../../tests/ch5/test_primary_literal_forms_number_time_unbased_string.sv) |一次リテラルには、アンダースコアと符号を伴う2進・8進・10進・16進の数値、数値の直後に単位を置く時間リテラル、アポストロフの直後に0または1を置く基数・サイズなしリテラル、および文字列リテラルがあります。それぞれの値と幅を与えます 遅延時間の単位としては| 5.7.1 5.7.2 5.8 5.9 A.8.4 A.10 | Icarus Verilog 13.0 ||
| [`test_unbased_unsized_fill_and_self_width`](../../tests/ch5/test_unbased_unsized_fill_and_self_width.sv) |基準のない無限リテラルは、文脈に必要な bit 個の値を 0 , 1 、x または z に設定し、符号がなく、自己決定文脈において bit 個の値を持つ。| 5.7.1 | Icarus Verilog 13.0 | x/z |
| [`test_underscore_literal`](../../tests/ch5/test_underscore_literal.sv) |二進法、十六進法、十進リテラルの下線は値を変更しません| 5.7.1 | Icarus Verilog 13.0 ||
| [`test_unsized_fill_all_values`](../../tests/ch5/test_unsized_fill_all_values.sv) |単一の bit リテラル '0 , '1 , 'x と 'z は 8 - bit , 33 - bit と 65 - bit の文脈の bit を満たし、自分で決めた文脈では幅が 1 である。| 5.7.1 | Icarus Verilog 13.0 | x/z |
| [`test_unsized_fill_wide_part_select_nba`](../../tests/ch5/test_unsized_fill_wide_part_select_nba.sv) |ブロックしない代入において、'1 のようなサイズのないフィルリターナルは、32 ビットよりも広い部分選択の全幅を埋めます。| 5.7.1 11.6.1 10.4.2 11.5.1 | Icarus Verilog 13.0 ||
| [`test_unsized_wide_literal`](../../tests/ch5/test_unsized_wide_literal.sv) |32ビット以上が必要なサイズのない小数リテラルは、32ビットに切り離される代わりに、必要な幅を得る| 5.7.1 | Icarus Verilog 13.0 ||
| [`test_illegal_real_literal_exponent_no_leading_digit`](../../tests/ch5/test_illegal_real_literal_exponent_no_leading_digit.sv) |文字通りの意味です2e - 7 は小数点前の数字がないので拒否されます| 5.7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_literal_exponent_no_trailing_digit`](../../tests/ch5/test_illegal_real_literal_exponent_no_trailing_digit.sv) |文字通りの4ですE3 は小数点と指数の間に数字がないので、拒否されます| 5.7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_literal_no_leading_digit`](../../tests/ch5/test_illegal_real_literal_no_leading_digit.sv) |文字通りの意味です12 は小数点前の数字がないので拒否されます| 5.7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_real_literal_no_trailing_digit`](../../tests/ch5/test_illegal_real_literal_no_trailing_digit.sv) |実数字 9. は小数点後の数字がないので、拒否されます。| 5.7.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_real_literal_edge_cases`](../../tests/ch5/test_real_literal_edge_cases.sv) |テスト：実数リテラルの境界ケース| 5.7.2 6.12 | Icarus Verilog 13.0 ||
| [`test_real_literal_shortreal_cast`](../../tests/ch5/test_real_literal_shortreal_cast.sv) |実数リテラルを shortreal 型に変換する。これは IEEE 754 単精度に丸めます。| 5.7.2 6.24.1 6.12 |標準のみ||
| [`test_time_literal_every_unit`](../../tests/ch5/test_time_literal_every_unit.sv) |時間リテラルは integer または固定点数で、次に単位 fs、ps、ns、us、ms、s のいずれかが続き、その値は現在の時間単位にスケールされます。| 5.8 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_time_literal_scaled_to_unit`](../../tests/ch5/test_time_literal_scaled_to_unit.sv) |遅延のタイムリテラルはモジュールの時間単位にスケールされ、$time は時間を整数単位に丸めます。$realtime は分数を保持します。| 5.8 22.7 20.3.1 20.3.3 | Icarus Verilog 13.0 ||
| [`test_time_literal_scaling`](../../tests/ch5/test_time_literal_scaling.sv) |時間リテラルは、表現や遅延において、現在の時間単位にスケールした実値です。| 5.8 3.14.2.1 20.3.3 | Icarus Verilog 13.0 ||
| [`test_time_literal_units_and_fraction`](../../tests/ch5/test_time_literal_units_and_fraction.sv) |時間リテラルは、integer または固定点数値部分と、fs、ps、ns、us、ms、s の単位の一つを持ち、それぞれが現在の時間単位に変換されます。| 5.8 | Icarus Verilog 13.0 ||
| [`test_illegal_quoted_string_newline`](../../tests/ch5/test_illegal_quoted_string_newline.sv) |引用文字列にはエスクアプトされていない新しい行を含めることはできません| 5.9 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_lexical_strings`](../../tests/ch5/test_lexical_strings.sv) |章 5.9 : 文字列リテラル| 5.9 5.9.1 6.16 | Verilator 5.052 ||
| [`test_quoted_string_items_and_every_escape_form`](../../tests/ch5/test_quoted_string_items_and_every_escape_form.sv) |引用文字列は、バックスラッシュや直接のダブル引用以外の印刷可能な文字を含み、 Table 5-1 の文字の前のバックスラッシュ、他の文字の前、新しい行の前、1から3の八進数の数字の前、1から2の十六進数の数字を含む x の前のすべての形式のエスクープ文字列を含みます。| 5.9 5.9.1 A.8.8 | Icarus Verilog 13.0 ||
| [`test_string_literal_cast_justification`](../../tests/ch5/test_string_literal_cast_justification.sv) |文字列リテラルを packed 型の配列に変換すると、右に並べられ、 unpacked 型の配 列に変換する場合は、左に並べられます。| 5.9 6.24.1 |標準のみ||
| [`test_string_literal_no_length_limit`](../../tests/ch5/test_string_literal_no_length_limit.sv) |引用文字列リテラルは、1024-文字の最小識別子限界 5.6 より長い 2048 文字の一つで、その正確な長さと文字数で受け入れられます。| 5.9 | Icarus Verilog 13.0 ||
| [`test_string_literal_packed_bytes_and_compare`](../../tests/ch5/test_string_literal_packed_bytes_and_compare.sv) |packed バイトの配列に保存された文字列リテラルはフラットベクトルのエンコーディングを持ち、文字列オペランドと共に使用されたリテラルは文字列に変換され、文字ごとに比較されます。| 5.9 6.16 | Icarus Verilog 13.0 ||
| [`test_string_literal_to_unpacked_byte_array`](../../tests/ch5/test_string_literal_to_unpacked_byte_array.sv) |文字列リテラルは、バイトの unpacked 配列に割り当てられ、左の要素からそれを埋め込み、残りの部分を 0 で埋め込む。| 5.9 7.4 |標準のみ||
| [`test_triple_quoted_and_quoted_string_contents`](../../tests/ch5/test_triple_quoted_and_quoted_string_contents.sv) |文字列リテラルは引用符または三重引用符の文字列です。三重引用符の文字列では、改行と二重引用符を、その連続2文字も含め通常の文字として保持します。一方、バックスラッシュは、通常の引用符付き文字列と同じエスケープシーケンスを開始します。| 5.9 5.9.1 A.8.8 | Verilator 5.052 ||
| [`test_triple_quoted_string`](../../tests/ch5/test_triple_quoted_string.sv) |三重引用符文字列は新しい行と二重引用符を保持し、その中のエスケープした新しい行は行を続けます。| 5.9 5.9.1 | Verilator 5.052 ||
| [`test_illegal_string_hex_escape_z_digit`](../../tests/ch5/test_illegal_string_hex_escape_z_digit.sv) |2 番目の数字が z の文字列リテラルにおける 16 進数のエスケープシーケンスは拒否されます| 5.9.1 |標準のみ|違法なデザインだ|
| [`test_illegal_string_octal_escape_z_digit`](../../tests/ch5/test_illegal_string_octal_escape_z_digit.sv) |文字列リテラルの八進数エスクアールシーケンスは、2 番目の数字が z のときは拒否されます。| 5.9.1 |標準のみ|違法なデザインだ|
| [`test_string_backslash_newline_continuation`](../../tests/ch5/test_string_backslash_newline_continuation.sv) |改行の前のバックスラッシュは文字列リテラルを継続し、改行の前の2つのバックスラッシュは1文字のバックスラッシュになります。また、三重引用符の文字列でも、\"と\nのエスケープを引き続き解釈します。| 5.9.1 5.9 | Verilator 5.052 ||
| [`test_string_escape_character_codes`](../../tests/ch5/test_string_escape_character_codes.sv) |表 5-1 の各エスクープシーケンスは固定コードを持つ1文字を返します。八進数と十六進数のエスクープはそれぞれ3桁と2桁の数字しか取れません。他の文字のエスクープはその文字のみを保持します。| 5.9.1 5.9 | Icarus Verilog 13.0 ||
| [`test_illegal_struct_literal_flattened_array_elements`](../../tests/ch5/test_illegal_struct_literal_flattened_array_elements.sv) |各要素の括弧なしの全メンバー値をリストする構造の配列のリテラルは拒否されます。| 5.10 10.9.1 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_struct_literal_flattened_nested_member`](../../tests/ch5/test_illegal_struct_literal_flattened_nested_member.sv) |括弧を含まないネスト構造のメンバーをリストする構造リテラルは拒否されます。| 5.10 10.9.2 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_nested_literal_replication_members`](../../tests/ch5/test_nested_literal_replication_members.sv) |内蔵構造と配列リテラルは次元境界と名前付きメンバーを保持します| 5.10 5.11 | Verilator 5.052 ||
| [`test_array_literal_nesting`](../../tests/ch5/test_array_literal_nesting.sv) |次元ごとに一つの括弧レベルをネストする配列リテラル、1次元内で作用する複製、インデックスとデフォルトキーを持つキャストまたは代入からリテラルのタイプを取得する。| 5.11 10.9.1 10.8 | Verilator 5.052 ||
| [`test_attrib_module`](../../tests/ch5/test_attrib_module.sv) |テスト: モジュール属性| 5.12 | Icarus Verilog 13.0 | x/z |
| [`test_attrib_signal`](../../tests/ch5/test_attrib_signal.sv) |テスト: 信号属性| 5.12 | Icarus Verilog 13.0 ||
| [`test_attribute_instance_specifications`](../../tests/ch5/test_attribute_instance_specifications.sv) |属性インスタンスは，モジュール，ネット，変数，モジュールインスタンス，ポート接続，演算子，関数コールの前に，1つ以上のコンマで区切られた属性スペックを持つ。特性は属性名または値として定数表現を持つ名前であり、属性は値を変更しません| 5.12 A.9.1 | Icarus Verilog 13.0 ||
| [`test_attribute_latch_generate`](../../tests/ch5/test_attribute_latch_generate.sv) |変数 always_latch の属性と生成ループの変数| 5.12 9.2.2.3 27.4 | Icarus Verilog 13.0 ||
| [`test_attribute_prefix_positions`](../../tests/ch5/test_attribute_prefix_positions.sv) |属性のインスタンスはモジュール、宣言、モジュール項目、ステートメント、生成項目、ポート接続、ANSIポート宣言のプレフィックスとして受け入れられ、任意の属性名は値を変更しません。| 5.12 | Verilator 5.052 ||
| [`test_illegal_attribute_instance_nested`](../../tests/ch5/test_illegal_attribute_instance_nested.sv) |属性のインスタンスが他の属性のインスタンスの中に書かれた場合は拒否されます。| 5.12 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_illegal_attribute_value_contains_attribute`](../../tests/ch5/test_illegal_attribute_value_contains_attribute.sv) |属性のインスタンスを含む値表現を拒否する属性| 5.12 | Verilator 5.052 |違法なデザインだ|
| [`test_builtin_method_forms_after_mutation`](../../tests/ch5/test_builtin_method_forms_after_mutation.sv) |括弧付きと引数なしの内蔵メソッドの形式は同じ更新オブジェクトを観察します。| 5.13 | Verilator 5.052 ||
| [`test_builtin_method_optional_parens`](../../tests/ch5/test_builtin_method_optional_parens.sv) |引数なしで呼び出された内蔵メソッド、またはデフォルトの引数のみで呼び出されたメソッドは空の括弧を省略できます。| 5.13 7.5.2 7.9.1 6.16.1 6.19.5.3 7.10.2.3 | Verilator 5.052 ||
| [`test_illegal_method_implicit_variable_without_parentheses`](../../tests/ch5/test_illegal_method_implicit_variable_without_parentheses.sv) |結果が暗黙変数として選択された括弧のない内蔵メソッドコールは拒否されます。| 5.13 13.4.1 6.16 |標準のみ|違法なデザインだ|

<a id="generated-by-generatorskeywordspy"></a>

## 生成者: `generators/keywords.py`

248 テスト;見て "Generated tests" のスイートの README。

|テスト|チェックするもの|条項|予期した出力を記録|ノート|
| --- | --- | --- | --- | --- |
| [`test_gen_kw_2023_accept_on`](../../tests/gen/ch5/test_gen_kw_2023_accept_on.sv) |accept_on は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_alias`](../../tests/gen/ch5/test_gen_kw_2023_alias.sv) |変数名は begin_keywords "1800-2023" の下に予約されており、変数名を指定できません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_always`](../../tests/gen/ch5/test_gen_kw_2023_always.sv) |常に begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_always_comb`](../../tests/gen/ch5/test_gen_kw_2023_always_comb.sv) |always_comb は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_always_ff`](../../tests/gen/ch5/test_gen_kw_2023_always_ff.sv) |always_ff は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_always_latch`](../../tests/gen/ch5/test_gen_kw_2023_always_latch.sv) |always_latch は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_and`](../../tests/gen/ch5/test_gen_kw_2023_and.sv) |begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_assert`](../../tests/gen/ch5/test_gen_kw_2023_assert.sv) |assert は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_assign`](../../tests/gen/ch5/test_gen_kw_2023_assign.sv) |assign は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_assume`](../../tests/gen/ch5/test_gen_kw_2023_assume.sv) |仮定は begin_keywords "1800-2023" の下で予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_automatic`](../../tests/gen/ch5/test_gen_kw_2023_automatic.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_before`](../../tests/gen/ch5/test_gen_kw_2023_before.sv) |beforeはbegin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_begin`](../../tests/gen/ch5/test_gen_kw_2023_begin.sv) |begin は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_bind`](../../tests/gen/ch5/test_gen_kw_2023_bind.sv) |begin_keywords "1800-2023" の下にバインドが予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_bins`](../../tests/gen/ch5/test_gen_kw_2023_bins.sv) |bins は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_binsof`](../../tests/gen/ch5/test_gen_kw_2023_binsof.sv) |binsof は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_bit`](../../tests/gen/ch5/test_gen_kw_2023_bit.sv) |bit は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_break`](../../tests/gen/ch5/test_gen_kw_2023_break.sv) |break は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_buf`](../../tests/gen/ch5/test_gen_kw_2023_buf.sv) |buf は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_bufif0`](../../tests/gen/ch5/test_gen_kw_2023_bufif0.sv) |bufif0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_bufif1`](../../tests/gen/ch5/test_gen_kw_2023_bufif1.sv) |bufif1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_byte`](../../tests/gen/ch5/test_gen_kw_2023_byte.sv) |byte は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_case`](../../tests/gen/ch5/test_gen_kw_2023_case.sv) |begin_keywords "1800-2023" の下に case が用意されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_casex`](../../tests/gen/ch5/test_gen_kw_2023_casex.sv) |casex は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_casez`](../../tests/gen/ch5/test_gen_kw_2023_casez.sv) |casez は begin_keywords "1800-2023" の下で予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_cell`](../../tests/gen/ch5/test_gen_kw_2023_cell.sv) |begin_keywords "1800-2023" の下にセルが予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_chandle`](../../tests/gen/ch5/test_gen_kw_2023_chandle.sv) |チャンドルは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_checker`](../../tests/gen/ch5/test_gen_kw_2023_checker.sv) |チェッカーは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_class`](../../tests/gen/ch5/test_gen_kw_2023_class.sv) |クラスは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_clocking`](../../tests/gen/ch5/test_gen_kw_2023_clocking.sv) |begin_keywords "1800-2023" の下にクロックが予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_cmos`](../../tests/gen/ch5/test_gen_kw_2023_cmos.sv) |cmosは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_config`](../../tests/gen/ch5/test_gen_kw_2023_config.sv) |config は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_const`](../../tests/gen/ch5/test_gen_kw_2023_const.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_constraint`](../../tests/gen/ch5/test_gen_kw_2023_constraint.sv) |制約は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_context`](../../tests/gen/ch5/test_gen_kw_2023_context.sv) |コンテキストは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_continue`](../../tests/gen/ch5/test_gen_kw_2023_continue.sv) |continue は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_cover`](../../tests/gen/ch5/test_gen_kw_2023_cover.sv) |cover は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_covergroup`](../../tests/gen/ch5/test_gen_kw_2023_covergroup.sv) |covergroup は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_coverpoint`](../../tests/gen/ch5/test_gen_kw_2023_coverpoint.sv) |coverpoint は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_cross`](../../tests/gen/ch5/test_gen_kw_2023_cross.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_deassign`](../../tests/gen/ch5/test_gen_kw_2023_deassign.sv) |deassign は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_default`](../../tests/gen/ch5/test_gen_kw_2023_default.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_defparam`](../../tests/gen/ch5/test_gen_kw_2023_defparam.sv) |defparam は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_design`](../../tests/gen/ch5/test_gen_kw_2023_design.sv) |デザインは begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_disable`](../../tests/gen/ch5/test_gen_kw_2023_disable.sv) |disable は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_dist`](../../tests/gen/ch5/test_gen_kw_2023_dist.sv) |dist は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_do`](../../tests/gen/ch5/test_gen_kw_2023_do.sv) |do は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_edge`](../../tests/gen/ch5/test_gen_kw_2023_edge.sv) |edgeは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_else`](../../tests/gen/ch5/test_gen_kw_2023_else.sv) |else は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_end`](../../tests/gen/ch5/test_gen_kw_2023_end.sv) |end は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endcase`](../../tests/gen/ch5/test_gen_kw_2023_endcase.sv) |変数名は begin_keywords "1800-2023" の下で大文字が予約されており、変数名を指定できません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endchecker`](../../tests/gen/ch5/test_gen_kw_2023_endchecker.sv) |endchecker は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endclass`](../../tests/gen/ch5/test_gen_kw_2023_endclass.sv) |endclass は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endclocking`](../../tests/gen/ch5/test_gen_kw_2023_endclocking.sv) |endclocking は begin_keywords "1800-2023" で予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endconfig`](../../tests/gen/ch5/test_gen_kw_2023_endconfig.sv) |endconfig は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endfunction`](../../tests/gen/ch5/test_gen_kw_2023_endfunction.sv) |endfunction は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endgenerate`](../../tests/gen/ch5/test_gen_kw_2023_endgenerate.sv) |endgenerate は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endgroup`](../../tests/gen/ch5/test_gen_kw_2023_endgroup.sv) |endgroup は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endinterface`](../../tests/gen/ch5/test_gen_kw_2023_endinterface.sv) |endinterface は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endmodule`](../../tests/gen/ch5/test_gen_kw_2023_endmodule.sv) |endmodule は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endpackage`](../../tests/gen/ch5/test_gen_kw_2023_endpackage.sv) |endpackage は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endprimitive`](../../tests/gen/ch5/test_gen_kw_2023_endprimitive.sv) |endprimitive は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endprogram`](../../tests/gen/ch5/test_gen_kw_2023_endprogram.sv) |endprogram は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endproperty`](../../tests/gen/ch5/test_gen_kw_2023_endproperty.sv) |endproperty は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endsequence`](../../tests/gen/ch5/test_gen_kw_2023_endsequence.sv) |endsequence は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endspecify`](../../tests/gen/ch5/test_gen_kw_2023_endspecify.sv) |endspecify は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endtable`](../../tests/gen/ch5/test_gen_kw_2023_endtable.sv) |endtable は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_endtask`](../../tests/gen/ch5/test_gen_kw_2023_endtask.sv) |endtask は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_enum`](../../tests/gen/ch5/test_gen_kw_2023_enum.sv) |enum は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_event`](../../tests/gen/ch5/test_gen_kw_2023_event.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_eventually`](../../tests/gen/ch5/test_gen_kw_2023_eventually.sv) |begin_keywords "1800-2023" の下に予約され 変数の名前が付けられません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_expect`](../../tests/gen/ch5/test_gen_kw_2023_expect.sv) |expect は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_export`](../../tests/gen/ch5/test_gen_kw_2023_export.sv) |export は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_extends`](../../tests/gen/ch5/test_gen_kw_2023_extends.sv) |拡張は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_extern`](../../tests/gen/ch5/test_gen_kw_2023_extern.sv) |外部は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_final`](../../tests/gen/ch5/test_gen_kw_2023_final.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_first_match`](../../tests/gen/ch5/test_gen_kw_2023_first_match.sv) |first_match は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_for`](../../tests/gen/ch5/test_gen_kw_2023_for.sv) |for は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_force`](../../tests/gen/ch5/test_gen_kw_2023_force.sv) |force は begin_keywords "1800-2023" の下で予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_foreach`](../../tests/gen/ch5/test_gen_kw_2023_foreach.sv) |foreach は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_forever`](../../tests/gen/ch5/test_gen_kw_2023_forever.sv) |forever は begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_fork`](../../tests/gen/ch5/test_gen_kw_2023_fork.sv) |フォークは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_forkjoin`](../../tests/gen/ch5/test_gen_kw_2023_forkjoin.sv) |forkjoin は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_function`](../../tests/gen/ch5/test_gen_kw_2023_function.sv) |関数は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_generate`](../../tests/gen/ch5/test_gen_kw_2023_generate.sv) |generate は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_genvar`](../../tests/gen/ch5/test_gen_kw_2023_genvar.sv) |genvar は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_global`](../../tests/gen/ch5/test_gen_kw_2023_global.sv) |begin_keywords "1800-2023" の下にグローバルが予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_highz0`](../../tests/gen/ch5/test_gen_kw_2023_highz0.sv) |highz0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_highz1`](../../tests/gen/ch5/test_gen_kw_2023_highz1.sv) |highz1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_if`](../../tests/gen/ch5/test_gen_kw_2023_if.sv) |begin_keywords "1800-2023" の下に予約されていて 変数の名前が付けられない場合| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_iff`](../../tests/gen/ch5/test_gen_kw_2023_iff.sv) |iffは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_ifnone`](../../tests/gen/ch5/test_gen_kw_2023_ifnone.sv) |ifnoneは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_ignore_bins`](../../tests/gen/ch5/test_gen_kw_2023_ignore_bins.sv) |ignore_bins は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_illegal_bins`](../../tests/gen/ch5/test_gen_kw_2023_illegal_bins.sv) |illegal_bins は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_implements`](../../tests/gen/ch5/test_gen_kw_2023_implements.sv) |実装は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_implies`](../../tests/gen/ch5/test_gen_kw_2023_implies.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_import`](../../tests/gen/ch5/test_gen_kw_2023_import.sv) |import は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_incdir`](../../tests/gen/ch5/test_gen_kw_2023_incdir.sv) |begin_keywords "1800-2023" の下にincdirが予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_include`](../../tests/gen/ch5/test_gen_kw_2023_include.sv) |include は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_initial`](../../tests/gen/ch5/test_gen_kw_2023_initial.sv) |初期値は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_inout`](../../tests/gen/ch5/test_gen_kw_2023_inout.sv) |inout は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_input`](../../tests/gen/ch5/test_gen_kw_2023_input.sv) |入力は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_inside`](../../tests/gen/ch5/test_gen_kw_2023_inside.sv) |insideはbegin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_instance`](../../tests/gen/ch5/test_gen_kw_2023_instance.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_int`](../../tests/gen/ch5/test_gen_kw_2023_int.sv) |int は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_integer`](../../tests/gen/ch5/test_gen_kw_2023_integer.sv) |integer は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_interconnect`](../../tests/gen/ch5/test_gen_kw_2023_interconnect.sv) |互いに接続するときは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_interface`](../../tests/gen/ch5/test_gen_kw_2023_interface.sv) |begin_keywords "1800-2023" の下にインターフェースが予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_intersect`](../../tests/gen/ch5/test_gen_kw_2023_intersect.sv) |交差は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_join`](../../tests/gen/ch5/test_gen_kw_2023_join.sv) |join は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_join_any`](../../tests/gen/ch5/test_gen_kw_2023_join_any.sv) |join_any は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_join_none`](../../tests/gen/ch5/test_gen_kw_2023_join_none.sv) |join_none は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_large`](../../tests/gen/ch5/test_gen_kw_2023_large.sv) |largeはbegin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_let`](../../tests/gen/ch5/test_gen_kw_2023_let.sv) |let は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_liblist`](../../tests/gen/ch5/test_gen_kw_2023_liblist.sv) |liblist は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_library`](../../tests/gen/ch5/test_gen_kw_2023_library.sv) |ライブラリは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_local`](../../tests/gen/ch5/test_gen_kw_2023_local.sv) |ローカルは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_localparam`](../../tests/gen/ch5/test_gen_kw_2023_localparam.sv) |localparam は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_logic`](../../tests/gen/ch5/test_gen_kw_2023_logic.sv) |logic は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_longint`](../../tests/gen/ch5/test_gen_kw_2023_longint.sv) |longint は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_macromodule`](../../tests/gen/ch5/test_gen_kw_2023_macromodule.sv) |マクロモジュールは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_matches`](../../tests/gen/ch5/test_gen_kw_2023_matches.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_medium`](../../tests/gen/ch5/test_gen_kw_2023_medium.sv) |begin_keywords "1800-2023" の下にメディアが予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_modport`](../../tests/gen/ch5/test_gen_kw_2023_modport.sv) |modport は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_module`](../../tests/gen/ch5/test_gen_kw_2023_module.sv) |begin_keywords "1800-2023" の下にモジュールが予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_nand`](../../tests/gen/ch5/test_gen_kw_2023_nand.sv) |begin_keywords "1800-2023" の下で予約されている nand は変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_negedge`](../../tests/gen/ch5/test_gen_kw_2023_negedge.sv) |negedge は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_nettype`](../../tests/gen/ch5/test_gen_kw_2023_nettype.sv) |nettype は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_new`](../../tests/gen/ch5/test_gen_kw_2023_new.sv) |new は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_nexttime`](../../tests/gen/ch5/test_gen_kw_2023_nexttime.sv) |nexttime は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_nmos`](../../tests/gen/ch5/test_gen_kw_2023_nmos.sv) |nmosは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_nor`](../../tests/gen/ch5/test_gen_kw_2023_nor.sv) |begin_keywords "1800-2023" の下に予約されておらず 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_noshowcancelled`](../../tests/gen/ch5/test_gen_kw_2023_noshowcancelled.sv) |noshowcancelled は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_not`](../../tests/gen/ch5/test_gen_kw_2023_not.sv) |not は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_notif0`](../../tests/gen/ch5/test_gen_kw_2023_notif0.sv) |notif0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_notif1`](../../tests/gen/ch5/test_gen_kw_2023_notif1.sv) |notif1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_null`](../../tests/gen/ch5/test_gen_kw_2023_null.sv) |begin_keywords "1800-2023" の下に null が予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_or`](../../tests/gen/ch5/test_gen_kw_2023_or.sv) |または begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_output`](../../tests/gen/ch5/test_gen_kw_2023_output.sv) |出力は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_package`](../../tests/gen/ch5/test_gen_kw_2023_package.sv) |パッケージは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_packed`](../../tests/gen/ch5/test_gen_kw_2023_packed.sv) |packed は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_parameter`](../../tests/gen/ch5/test_gen_kw_2023_parameter.sv) |パラメータは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pmos`](../../tests/gen/ch5/test_gen_kw_2023_pmos.sv) |pmosは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_posedge`](../../tests/gen/ch5/test_gen_kw_2023_posedge.sv) |posedge は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_primitive`](../../tests/gen/ch5/test_gen_kw_2023_primitive.sv) |プリミティブは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_priority`](../../tests/gen/ch5/test_gen_kw_2023_priority.sv) |優先度は begin_keywords "1800-2023" で予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_program`](../../tests/gen/ch5/test_gen_kw_2023_program.sv) |プログラムは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_property`](../../tests/gen/ch5/test_gen_kw_2023_property.sv) |プロパティは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_protected`](../../tests/gen/ch5/test_gen_kw_2023_protected.sv) |保護された変数は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pull0`](../../tests/gen/ch5/test_gen_kw_2023_pull0.sv) |pull0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pull1`](../../tests/gen/ch5/test_gen_kw_2023_pull1.sv) |pull1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pulldown`](../../tests/gen/ch5/test_gen_kw_2023_pulldown.sv) |引数は begin_keywords "1800-2023" で予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pullup`](../../tests/gen/ch5/test_gen_kw_2023_pullup.sv) |引用は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pulsestyle_ondetect`](../../tests/gen/ch5/test_gen_kw_2023_pulsestyle_ondetect.sv) |pulsestyle_ondetect は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pulsestyle_onevent`](../../tests/gen/ch5/test_gen_kw_2023_pulsestyle_onevent.sv) |pulsestyle_onevent は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_pure`](../../tests/gen/ch5/test_gen_kw_2023_pure.sv) |純粋な値は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rand`](../../tests/gen/ch5/test_gen_kw_2023_rand.sv) |rand は begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_randc`](../../tests/gen/ch5/test_gen_kw_2023_randc.sv) |randc は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_randcase`](../../tests/gen/ch5/test_gen_kw_2023_randcase.sv) |randcase は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_randsequence`](../../tests/gen/ch5/test_gen_kw_2023_randsequence.sv) |randsequence は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rcmos`](../../tests/gen/ch5/test_gen_kw_2023_rcmos.sv) |rcmosは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_real`](../../tests/gen/ch5/test_gen_kw_2023_real.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_realtime`](../../tests/gen/ch5/test_gen_kw_2023_realtime.sv) |realtime は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_ref`](../../tests/gen/ch5/test_gen_kw_2023_ref.sv) |ref は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_reg`](../../tests/gen/ch5/test_gen_kw_2023_reg.sv) |reg は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_reject_on`](../../tests/gen/ch5/test_gen_kw_2023_reject_on.sv) |reject_on は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_release`](../../tests/gen/ch5/test_gen_kw_2023_release.sv) |begin_keywords "1800-2023" の下にリリースが予約されており、変数の名前を付けることができません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_repeat`](../../tests/gen/ch5/test_gen_kw_2023_repeat.sv) |繰り返しは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_restrict`](../../tests/gen/ch5/test_gen_kw_2023_restrict.sv) |begin_keywords "1800-2023" の下で予約されている restrict は変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_return`](../../tests/gen/ch5/test_gen_kw_2023_return.sv) |return は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rnmos`](../../tests/gen/ch5/test_gen_kw_2023_rnmos.sv) |rnmosは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rpmos`](../../tests/gen/ch5/test_gen_kw_2023_rpmos.sv) |rpmosは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rtran`](../../tests/gen/ch5/test_gen_kw_2023_rtran.sv) |rtran は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rtranif0`](../../tests/gen/ch5/test_gen_kw_2023_rtranif0.sv) |rtranif0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_rtranif1`](../../tests/gen/ch5/test_gen_kw_2023_rtranif1.sv) |rtranif1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_s_always`](../../tests/gen/ch5/test_gen_kw_2023_s_always.sv) |s_always は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_s_eventually`](../../tests/gen/ch5/test_gen_kw_2023_s_eventually.sv) |s_eventually は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_s_nexttime`](../../tests/gen/ch5/test_gen_kw_2023_s_nexttime.sv) |s_nexttime は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_s_until`](../../tests/gen/ch5/test_gen_kw_2023_s_until.sv) |s_until は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_s_until_with`](../../tests/gen/ch5/test_gen_kw_2023_s_until_with.sv) |s_until_with は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_scalared`](../../tests/gen/ch5/test_gen_kw_2023_scalared.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_sequence`](../../tests/gen/ch5/test_gen_kw_2023_sequence.sv) |シーケンスは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_shortint`](../../tests/gen/ch5/test_gen_kw_2023_shortint.sv) |shortint は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_shortreal`](../../tests/gen/ch5/test_gen_kw_2023_shortreal.sv) |shortreal は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_showcancelled`](../../tests/gen/ch5/test_gen_kw_2023_showcancelled.sv) |showcancelled は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_signed`](../../tests/gen/ch5/test_gen_kw_2023_signed.sv) |signed は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_small`](../../tests/gen/ch5/test_gen_kw_2023_small.sv) |smallはbegin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_soft`](../../tests/gen/ch5/test_gen_kw_2023_soft.sv) |ソフトは begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_solve`](../../tests/gen/ch5/test_gen_kw_2023_solve.sv) |ソルブは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_specify`](../../tests/gen/ch5/test_gen_kw_2023_specify.sv) |begin_keywords "1800-2023" の下に指定されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_specparam`](../../tests/gen/ch5/test_gen_kw_2023_specparam.sv) |specparam は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_static`](../../tests/gen/ch5/test_gen_kw_2023_static.sv) |staticはbegin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_string`](../../tests/gen/ch5/test_gen_kw_2023_string.sv) |文字列は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_strong`](../../tests/gen/ch5/test_gen_kw_2023_strong.sv) |強いは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_strong0`](../../tests/gen/ch5/test_gen_kw_2023_strong0.sv) |strong0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_strong1`](../../tests/gen/ch5/test_gen_kw_2023_strong1.sv) |strong1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_struct`](../../tests/gen/ch5/test_gen_kw_2023_struct.sv) |struct は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_super`](../../tests/gen/ch5/test_gen_kw_2023_super.sv) |super は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_supply0`](../../tests/gen/ch5/test_gen_kw_2023_supply0.sv) |supply0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_supply1`](../../tests/gen/ch5/test_gen_kw_2023_supply1.sv) |supply1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_sync_accept_on`](../../tests/gen/ch5/test_gen_kw_2023_sync_accept_on.sv) |sync_accept_on は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_sync_reject_on`](../../tests/gen/ch5/test_gen_kw_2023_sync_reject_on.sv) |sync_reject_on は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_table`](../../tests/gen/ch5/test_gen_kw_2023_table.sv) |テーブルは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tagged`](../../tests/gen/ch5/test_gen_kw_2023_tagged.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_task`](../../tests/gen/ch5/test_gen_kw_2023_task.sv) |タスクは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_this`](../../tests/gen/ch5/test_gen_kw_2023_this.sv) |これは begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_throughout`](../../tests/gen/ch5/test_gen_kw_2023_throughout.sv) |begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_time`](../../tests/gen/ch5/test_gen_kw_2023_time.sv) |時間は begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_timeprecision`](../../tests/gen/ch5/test_gen_kw_2023_timeprecision.sv) |timeprecision は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_timeunit`](../../tests/gen/ch5/test_gen_kw_2023_timeunit.sv) |timeunit は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tran`](../../tests/gen/ch5/test_gen_kw_2023_tran.sv) |tran は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tranif0`](../../tests/gen/ch5/test_gen_kw_2023_tranif0.sv) |tranif0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tranif1`](../../tests/gen/ch5/test_gen_kw_2023_tranif1.sv) |tranif1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tri`](../../tests/gen/ch5/test_gen_kw_2023_tri.sv) |triはbegin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tri0`](../../tests/gen/ch5/test_gen_kw_2023_tri0.sv) |tri0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_tri1`](../../tests/gen/ch5/test_gen_kw_2023_tri1.sv) |tri1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_triand`](../../tests/gen/ch5/test_gen_kw_2023_triand.sv) |triand は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_trior`](../../tests/gen/ch5/test_gen_kw_2023_trior.sv) |trior は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_trireg`](../../tests/gen/ch5/test_gen_kw_2023_trireg.sv) |trireg は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_type`](../../tests/gen/ch5/test_gen_kw_2023_type.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_typedef`](../../tests/gen/ch5/test_gen_kw_2023_typedef.sv) |typedef は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_union`](../../tests/gen/ch5/test_gen_kw_2023_union.sv) |ユニオンは begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_unique`](../../tests/gen/ch5/test_gen_kw_2023_unique.sv) |ユニークは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_unique0`](../../tests/gen/ch5/test_gen_kw_2023_unique0.sv) |unique0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_unsigned`](../../tests/gen/ch5/test_gen_kw_2023_unsigned.sv) |unsigned は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_until`](../../tests/gen/ch5/test_gen_kw_2023_until.sv) |begin_keywords "1800-2023" の下に予約されるまで 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_until_with`](../../tests/gen/ch5/test_gen_kw_2023_until_with.sv) |until_with は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_untyped`](../../tests/gen/ch5/test_gen_kw_2023_untyped.sv) |untyped は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_use`](../../tests/gen/ch5/test_gen_kw_2023_use.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_uwire`](../../tests/gen/ch5/test_gen_kw_2023_uwire.sv) |uwire は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_var`](../../tests/gen/ch5/test_gen_kw_2023_var.sv) |begin_keywords "1800-2023" の下にvarが予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_vectored`](../../tests/gen/ch5/test_gen_kw_2023_vectored.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_virtual`](../../tests/gen/ch5/test_gen_kw_2023_virtual.sv) |仮想は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_void`](../../tests/gen/ch5/test_gen_kw_2023_void.sv) |begin_keywords "1800-2023" の下にvoidが予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_wait`](../../tests/gen/ch5/test_gen_kw_2023_wait.sv) |wait は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_wait_order`](../../tests/gen/ch5/test_gen_kw_2023_wait_order.sv) |wait_order は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_wand`](../../tests/gen/ch5/test_gen_kw_2023_wand.sv) |ワンドは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_weak`](../../tests/gen/ch5/test_gen_kw_2023_weak.sv) |弱いは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_weak0`](../../tests/gen/ch5/test_gen_kw_2023_weak0.sv) |weak0 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_weak1`](../../tests/gen/ch5/test_gen_kw_2023_weak1.sv) |weak1 は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_while`](../../tests/gen/ch5/test_gen_kw_2023_while.sv) |begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることができません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_wildcard`](../../tests/gen/ch5/test_gen_kw_2023_wildcard.sv) |ワイドキャラクターは begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_wire`](../../tests/gen/ch5/test_gen_kw_2023_wire.sv) |wire は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_with`](../../tests/gen/ch5/test_gen_kw_2023_with.sv) |begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_within`](../../tests/gen/ch5/test_gen_kw_2023_within.sv) |begin_keywords "1800-2023" の下に予約されており 変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_wor`](../../tests/gen/ch5/test_gen_kw_2023_wor.sv) |wor は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_xnor`](../../tests/gen/ch5/test_gen_kw_2023_xnor.sv) |xnor は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
| [`test_gen_kw_2023_xor`](../../tests/gen/ch5/test_gen_kw_2023_xor.sv) |xor は begin_keywords "1800-2023" の下に予約されており、変数の名前を付けることはできません。| 5.6 B 22.14 | Icarus Verilog 13.0 |違法なデザインだ|
