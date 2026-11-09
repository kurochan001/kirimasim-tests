<a id="slang-reference"></a>

# slangによる参考判定

[English](slang-reference.en.md) / [日本語](slang-reference.md)

[シミュレータと規格の差異](simulator-differences.ja.md) / [Nightlyの結果](nightly-results.md) / [履歴](history.ja.md)

`tools/run_slang.py`は、スイートのテストにslangのドライバーを実行します。
ドライバーは、kirimasimが固定しているslangのコミットからビルドします。
判定は原因の切り分けのための参考で、どこにも数えません。

<a id="purpose-and-limits"></a>

## 目的と限界

用途は二つです。

- kirimasimの不具合がslangにあるのか、kirimasimにあるのかを見分けること。kirimasimはslangで設計を展開し、その後に独自の検査をして実行します。
- slangが拒否する規格に合うテストを、テストの誤りの候補として見つけること。

限界は次のとおりです。

- kirimasimとLyraはどちらもslangを前段に使います。このためslangが期待値を単独で確かめることはなく、oracleではありません。`:oracle:`、カバレッジの数値、Nightlyのワークフロー、resultsブランチ、READMEのどれにも入れません。
- 規格違反のテストは、`:expected_stderr_regex:`が示す行にslangがエラーを出せば「指定行で拒否」です。ほかのランナーと同じく、理由は比べません。例えば`ch21/test_illegal_dumpports_duplicate_scope`は25行目で拒否されますが、理由はスコープの重複ではなく、`m`を値として使っていることです。
- 規格に合うテストの「エラーなし」は、slangがエラーなしで展開できたことだけを意味します。slangはシミュレーションをしません。
- slangは`:vpi_c:`のCコードを読み込みません。そのコードが`$vt_...`などのシステムタスクを登録するので、slangはVPIテストの大半を拒否します。ツールはこれらに印を付け、集計でも別にします。
- オプションはkirimasimの前段（`src/front/front.cpp`）と同じです。kirimasimはさらに、`--top`がないとき最初のconfigを最上位に選び、slangの後に独自の検査をします。このため、kirimasimが拒否するものをslang単体では受理することがあります。
- slangのコミットはkirimasimの固定に合わせます。kirimasimが固定を変えたら、新しいコミットをビルドし、日付付きの記録を新しく作ります。Lyraが使うslangのコミットは確かめていません。

<a id="build-the-pinned-driver"></a>

## 固定版ドライバーのビルド

kirimasimはslangをライブラリとしてだけビルドする（`SLANG_INCLUDE_TOOLS=OFF`）ので、そのビルドにドライバーはありません。
ドライバーはslangの`slang_driver`ターゲット（出力は`bin/slang`）です。
kirimasimの`dev`ビルドが取得済みのソースからビルドします。ネットワークは使いません。

```sh
K=<build/devのあるkirimasimのチェックアウト>
D=$K/build/dev/_deps
grep -A3 'FetchContent_Declare(' $K/cmake/Dependencies.cmake | grep GIT_TAG   # 固定のコミット
git -C $D/slang-src rev-parse HEAD                                            # 同じであること
cmake -S $D/slang-src -B slang-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DSLANG_INCLUDE_TOOLS=ON -DSLANG_INCLUDE_TESTS=OFF -DSLANG_INCLUDE_INSTALL=OFF \
  -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=NEVER -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_FMT=$D/fmt-src -DFETCHCONTENT_SOURCE_DIR_BOOST_REGEX=$D/boost_regex-src \
  -DFETCHCONTENT_SOURCE_DIR_MIMALLOC=$D/mimalloc-src -DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=$D/tomlplusplus-src
ninja -C slang-build slang_driver
```

18コアのMacで、構成に約3秒、ビルドに96秒かかります。
`slang --version`は`slang version 12.1.0+0`としか出さないので、コミットはツールに渡します。

<a id="run-the-tool"></a>

## ツールの実行

```sh
python3 tools/run_slang.py --slang slang-build/bin/slang \
  --commit 6fbb158f156436a1cb4d0ce9de5373a416a05d4c -j 12 \
  --json coverage/slang/slang-6fbb158f-20261109.json
```

- テストを指定しなければ、ほかのランナーと同じく`:type: formal`以外のすべてのテストを実行します。
- slangには`--std=1800-2023 -Wno-error=index-oob -Wno-error=string-int-concat -Wno-error=string-in-constraint --threads 1 -q`を渡します。`:files:`のソースはテストの前に、includeのディレクトリと`:incdirs:`は`-I`、`:defines:`は`-D`、`:top_module:`は`--top`で渡します。`:args:`は使いません。
- 規格違反のテストは`suite_results.judge_illegal`で判定し、`rejected_at_line`、`rejected_elsewhere`、`accepted`のどれかになります。規格に合うテストは`clean`か`rejected`で、slangの最初のエラーを残します。`:vpi_c:`のあるテストには`"vpi": true`を付けます。
- 記録には、slangのコミット、スイートのコミット、日時、オプション、ツールのハッシュ、テストごとの判定・最初のエラー・入力の指紋が入ります。ファイル名はリポジトリからの相対です。
- 記録は`coverage/results/`ではなく`coverage/slang/`に置きます。カバレッジのツールは`coverage/results/*.json`をすべてシミュレータの結果として読み、`coverage/slang/`を読むツールはありません。
- Nightlyのワークフローはこのツールを実行しません。`tools/results_history.py`は履歴に結果のあるシミュレータだけを描き、slangの結果は履歴にありません。
- スイート全体で、入力の指紋を含めて`-j 12`で約95秒です。

<a id="results-of-2026-11-09"></a>

## 2026-11-09の結果

slang `6fbb158f156436a1cb4d0ce9de5373a416a05d4c`（kirimasim `2b05349e`（2026-11-08）の固定）を、スイートのコミット`6f4bc48b`で実行しました。
記録は[`coverage/slang/slang-6fbb158f-20261109.json`](../coverage/slang/slang-6fbb158f-20261109.json)です。
時間切れや異常終了のテストはありません。

<a id="illegal-tests"></a>

### 規格違反のテスト

| 判定 | 本数 |
| --- | ---: |
| 指定行で拒否 | 1,833 |
| 別の場所で拒否 | 0 |
| 受理 | 143 |
| 計 | 1,976 |

受理した143本のうち、43本はIcarus Verilog 13.0かVerilator 5.052のoracleがあり、100本は規格のみです。

<a id="legal-tests"></a>

### 規格に合うテスト

| テスト | エラーなし | 拒否 | 計 |
| --- | ---: | ---: | ---: |
| `:vpi_c:`なし | 9,472 | 53 | 9,525 |
| `:vpi_c:`あり | 148 | 351 | 499 |

- 拒否したVPIテスト351本のうち348本は、Cコードが登録するシステムタスクで止まります（`$vt_...` 343本、`$depth_...` 4本、`$Depth$probe_7` 1本）。
- 残る3本は見直していません。`ch37/test_vpi_interconnect_net_type_size`（下の仕分けと同じ、パック次元のあるinterconnect）、`ch37/test_vpi_io_decl_scope_typespec_ports`（virtual interfaceのポート）、`ch37/test_vpi_variable_driver_load_arrays`（forceの対象）です。
- ほかの53本は[下で](#triage-of-legal-tests-that-slang-rejects)仕分けました。

<a id="illegal-tests-and-kirimasim-2b05349e"></a>

### 規格違反のテストとkirimasim 2b05349e

同じ1,976本を、kirimasim `2b05349e`の`dev`ビルドで`tools/run_kirimasim.py`により実行しました。

| slang | kirimasim pass | kirimasim fail | kirimasim unsupported |
| --- | ---: | ---: | ---: |
| 指定行で拒否 | 1,829 | 2 | 2 |
| 受理 | 7 | 48 | 88 |

- slangが拒否し、kirimasimがfail（2本）：kirimasimが終了コード2ではなく3で終わるので、不具合はslangの後にあります。`ch18/test_illegal_unique_tolerance_range`と`ch33/test_illegal_config_cell_library_liblist`です。
- slangが拒否し、kirimasimがunsupported（2本）：kirimasimは`:vpi_c:`のCコードを読み込めません。`ch36/test_36_extra_systf_name_dollar`と`ch36/test_36_extra_timing_check_not_systf`です。
- slangが受理し、kirimasimがpass（7本）：kirimasim独自の検査です。`ch4/test_illegal_final_deferred_action_schedules_event`、`ch8/test_illegal_const_property_assigned_twice`、`ch8/test_illegal_instance_constant_assigned_twice`、`ch16/test_illegal_final_deferred_postponed_call`、`ch20/test_illegal_bits_function_dynamic_return`、`ch20/test_illegal_timeformat_unit_out_of_range`、`ch33/test_illegal_config_parameter_wildcard_import`です。
- slangもkirimasimも受理（48本）：slangの見落としをkirimasimが引き継いだ候補です。12本はIcarusかVerilatorのoracleがあります（\*印）。一覧は下の表です。
- slangが受理し、kirimasimがunsupported（88本、うちoracle付き30本）：kirimasimが構文をまだ扱えません。独自の検査がなければ、対応したときにこれらを受理します。

| 章 | slangもkirimasimも受理 |
| --- | --- |
| ch5 | `test_illegal_method_implicit_variable_without_parentheses`、`test_illegal_string_hex_escape_z_digit`、`test_illegal_string_octal_escape_z_digit` |
| ch6 | `test_illegal_chandle_event_control`、`test_illegal_initial_block_variable_initializer_no_keyword`、`test_illegal_net_type_reg_in_port_declaration`、`test_illegal_static_task_variable_initializer_no_keyword`、`test_illegal_type_operator_dynamic_array_element`\*、`test_illegal_type_parameter_scope_prefix_in_variable` |
| ch7 | `test_illegal_dynamic_new_nonblocking_assignment`\*、`test_illegal_union_holding_struct_member_default` |
| ch8 | `test_illegal_interface_method_default_not_constant`、`test_illegal_interface_typedef_scope_prefix_in_variable_declaration`\*、`test_illegal_type_parameter_scope_prefix_in_variable_declaration` |
| ch10 | `test_illegal_force_mixed_driven_variable` |
| ch11 | `test_illegal_unsized_constant_in_concatenation`\* |
| ch12 | `test_illegal_for_type_reference_without_var`\* |
| ch13 | `test_illegal_constant_function_call_in_constant_context` |
| ch16 | `test_illegal_deferred_assertion_const_ref_dynamic_actual` |
| ch19 | `test_illegal_cg_function_side_effect`、`test_illegal_cg_outer_constant`、`test_illegal_cg_ref_formal_expression`、`test_illegal_cg_ref_formal_variable` |
| ch20 | `test_illegal_isunbounded_variable` |
| ch21 | `test_illegal_display_strength_vector_net` |
| ch22 | `test_illegal_begin_keywords_without_end`、`test_illegal_directive_split_across_lines`\*、`test_illegal_include_absolute_path_in_angle_brackets`\*、`test_illegal_include_line_trailing_code`\*、`test_illegal_line_directive_trailing_comment` |
| ch23 | `test_illegal_defparam_array_sibling_instance`、`test_illegal_no_top_level_module`、`test_illegal_scope_duplicate_in_unselected_generate`\* |
| ch24 | `test_illegal_anonymous_program_hierarchical_reference`、`test_illegal_module_calls_program_task` |
| ch25 | `test_illegal_generic_interface_port_dot_name`、`test_illegal_interface_port_actual_through_generate_block`、`test_illegal_interface_port_actual_through_instance_array`、`test_illegal_modport_import_default_argument_without_prototype`、`test_illegal_modport_import_named_binding_without_prototype`、`test_illegal_modport_prototype_unnamed_named_binding` |
| ch26 | `test_illegal_package_imported_before_compiled`\* |
| ch33 | `test_illegal_config_constant_function`\*、`test_illegal_config_generate_scope_path`\*、`test_illegal_config_hierarchical_name_in_expression`、`test_illegal_config_index_not_literal`、`test_illegal_config_instance_array_path`、`test_illegal_config_package_binding` |

<a id="triage-of-legal-tests-that-slang-rejects"></a>

## slangが拒否する規格に合うテストの仕分け

slangが拒否する`:vpi_c:`なしの規格に合うテスト53本を、IEEE 1800-2023と照らしました。
仕分けはAI（Claude）が行い、テストは変えていません。

| 判定 | 本数 |
| --- | ---: |
| テストの誤り | 1 |
| slangが規格より厳しい | 48 |
| 不明 | 4 |

- kirimasim `2b05349e`は53本のどれもpassしません。45本はslangと同じ最初のエラーでfailし、DPIの8本はCコードを読み込めないのでunsupportedです。
- 固定版シミュレータの保存済みの結果では、12本がpassします。`:oracle:`にIcarus Verilog 13.0かVerilator 5.052がある12本です。Icarusが8本、Verilatorが8本をpassし、そのうち4本は両方でpassします。表の最後の列にそれを示します。数えるのは、入力が今と同じ保存済みの結果だけです。
- 「slangが規格より厳しい」の行は、slangへの報告の候補です。報告はしていません。

| テスト | 判定 | 根拠 | 理由 | 固定版でpass |
| --- | --- | --- | --- | --- |
| `ch3/test_compilation_unit_shared_across_files` | テストの誤り | 3.12.1 | どのファイルが1つのコンパイル単位になるかはツールが決めます。ツールは両方の使い方を用意する必要があり、slangの既定（kirimasimも同じ）はファイルごとに1単位です。テストは1単位の使い方を規則として扱っています。直し方：3.12.1のa)の使い方が必要だとテストに書き、ランナーがそれを選べるようにする（slangには`--single-unit`があります）か、通常の実行から外します。 | Icarus・Verilator |
| `ch3/test_declaration_across_file_boundary` | slangが厳しい | 3.12.1 | ファイルの終わりで完結しない宣言は、続くファイルに続きます。 | Icarus |
| `ch5/test_string_literal_cast_justification` | slangが厳しい | 5.9 | 文字列リテラルを非パック配列にキャストすると、代入と同じ規則（左詰め）に従います。 | なし |
| `ch6/test_a2_1_3_interconnect_declaration_identifiers`<br>`ch6/test_interconnect_and_net_port_types` | slangが厳しい | 6.6.8、23.3.3.7.1、A.2.1.3 | interconnectはパック次元を持てます。ポート接続では、相手のネットの型のネットに統合されます。 | なし |
| `ch6/test_nettype_alias_resolution_and_empty_drivers`<br>`ch6/test_nettype_declarations_and_user_nets`<br>`ch6/test_nettype_rename_matches` | slangが厳しい | 6.6.7、6.22.6 | nettype宣言の2つ目の形は、既存のnettypeに解決関数ごと別の名前を付けます。別名のnettypeは元のnettypeと一致します。 | なし |
| `ch6/test_nettype_resolution` | slangが厳しい | 6.6.7、10.6.2 | force文はユーザー定義nettypeのネットの値を上書きできます。上と同じく、解決関数付きの別名もslangは拒否します。 | なし |
| `ch6/test_user_nettype_resolution_forms` | slangが厳しい | 10.3、6.6.7 | 左辺で禁じられるのは、nettypeのデータ型の中への選択です。そのようなネットの配列の要素は、ネット全体です。解決関数付きの別名もslangは拒否します。 | なし |
| `ch7/test_assoc_narrow_prev_next_overflow`<br>`ch7/test_assoc_traversal_narrow_index` | slangが厳しい | 7.9.8 | 小さい整数型の添字引数は認められます。メソッドは-1を返し、値を切り詰めます。 | なし |
| `ch11/test_expr_timescale_constants` | slangが厳しい | 11.2.1、20.4.1 | 定数の引数を持つ20.4の時間単位の関数は、定数システム関数呼出しです。 | なし |
| `ch11/test_stream_item_order_struct_union_object_assoc`<br>`ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects` | slangが厳しい | 11.4.14.1、11.4.14.3 | 構造体はメンバーごと、タグなし共用体は最初のメンバー、オブジェクトはデータメンバーごとにストリームされます。unpackはnullのハンドルを飛ばします。 | なし |
| `ch13/test_ref_static_accepted_actuals` | slangが厳しい | 13.5.2 | ref staticの引数には、モジュールの構造体のメンバーのような、静的な寿命のメンバーを渡せます。 | なし |
| `ch14/test_default_clocking_nested_module_scope` | slangが厳しい | 14.12 | 既定のクロッキングの範囲は、入れ子のモジュールを含みます。 | なし |
| `ch16/test_named_sequence_scopes_and_instances` | slangが厳しい | 16.8（Syntax 16-8） | シーケンス式の後のセミコロンは省略できます（`sequence_expr [ ; ]`）。 | なし |
| `ch17/test_checker_always_statement_kinds` | 不明 | 17.5、17.7、12.7.1 | 17.5はループ文を認めますが、forの中で宣言した変数は自動の寿命を持ち（12.7.1）、チェッカー本体の変数は静的でなければなりません（17.7）。直すなら：ループ変数をチェッカー本体で宣言します。 | Verilator |
| `ch17/test_checker_covergroup_sample` | slangが厳しい | 17.6、17.5 | チェッカーのcovergroupは、`sample()`メソッドの手続き的な呼出しで起動できます。チェッカーの手続きはサブルーチンを呼べます。 | Verilator |
| `ch18/test_inline_local_scope_binding` | 不明 | 18.7.1 | `local::obj`が`obj`のクラスの範囲に結び付くという最後の規則は、クラスのメンバーとも（テスト）、ハンドルそのものとも（slang）読めます。直すなら：`local::r`の確認を別のテストに移し、ほかの4つの確認がこの読み方に依存しないようにします。 | なし |
| `ch19/test_19_rest_set_visibility` | slangが厳しい | 19.5.1.2 | covergroupの中で宣言した識別子は、set式からは見えません。 | なし |
| `ch19/test_cg_inheritance_args_and_cross` | slangが厳しい | 19.4.1 | 派生covergroupの同じ名前のcrossは、基底のcrossに代わります。 | なし |
| `ch20/test_array_query_default_dimension_integer_result`<br>`ch20/test_array_query_invalid_dimension_all_x`<br>`ch20/test_array_query_types_and_invalid` | slangが厳しい | 20.7 | 次元が範囲外のとき、配列の問い合わせ関数は`'x`を返します。 | Icarus（`test_array_query_invalid_dimension_all_x`） |
| `ch21/test_evcd_dumpports_files_defaults_and_control_scope`<br>`ch21/test_evcd_dumpportslimit_named_by_variables`<br>`ch21/test_fopen_name_and_type_forms`<br>`ch21/test_plusargs_key_from_variable`<br>`ch21/test_vcd_dumpvars_all_filename_start` | slangが厳しい | 21.3.1、21.6、21.7.1.1、21.7.3.1、21.7.3.3、21.7.3.4 | ファイル名、ファイルの種類、plusargの文字列は、文字を保持する整数型の値でも構いません。 | Icarus・Verilator（`test_fopen_name_and_type_forms`）<br>Icarus・Verilator（`test_plusargs_key_from_variable`）<br>Icarus（`test_vcd_dumpvars_all_filename_start`） |
| `ch21/test_fread_unpacked_struct_union` | slangが厳しい | 21.3.4.4 | `$fread`は、非パック構造体をメンバーごとに、非パック共用体を最初のメンバーで読みます。 | なし |
| `ch22/test_ifdef_directive_names_not_defined` | 不明 | 22.6、Annex B | 指示子の名前は未定義として扱われますが、`include`は予約語でもあり、条件は識別子です。直すなら：`undefineall`のような予約語でない指示子の名前を使います。 | なし |
| `ch23/test_23_extra_uwire_dominates`<br>`ch23/test_23_extra_uwire_warn`<br>`ch23/test_port_collapse_trireg_and_uwire_cells`<br>`ch23/test_port_collapse_uwire_external_delay`<br>`ch23/test_port_collapse_uwire_supply`<br>`ch23/test_port_collapse_wand_uwire_warning`<br>`ch23/test_port_collapse_wor_uwire_warning` | slangが厳しい | 6.6.2、23.3.3.6、23.3.3.7 | uwireはinoutポートにでき、inoutポートにもつなげます。エラーになるのは複数の駆動とスイッチの双方向端子で、ネットを統合しないポートは警告です。 | Verilator（`test_port_collapse_uwire_external_delay`）<br>Icarus・Verilator（`test_port_collapse_uwire_supply`） |
| `ch23/test_defparam_block_task_function_parameters` | slangが厳しい | 23.10.2、6.20.1 | 名前付きブロック、タスク、関数のパラメータは、defparamでだけ変えられます。localparamになるのは、パラメータポートリストを持つ設計要素に直接あるパラメータだけです。 | Icarus |
| `ch23/test_interconnect_primitive_broadcast_input`<br>`ch23/test_interconnect_primitive_terminal`<br>`ch23/test_interconnect_terminal_wire_resolution` | slangが厳しい | 6.6.8、23.3.3.7.2 | interconnectはネットポートと端子の接続を表します。プリミティブやUDPの端子では、スカラーのwireとして扱われます。 | なし |
| `ch33/test_duplicate_cell_last_definition_wins` | 不明 | 33.3.1.1、3.13 | 規格が食い違います。33.3.1.1は最後のセルを残して警告するとし、3.13のa)はモジュール名を再び使うことを禁じます。直すなら：このスイートの方針どおり個別の規則を残し、3.13のa)に触れるコメントを足します。 | なし |
| `ch35/test_dpi_dynamic_array_actual`<br>`gen/ch35/test_gen_cross_dpi_array_queue_inout_1_positive_descending_resize`<br>`gen/ch35/test_gen_cross_dpi_array_queue_inout_3_positive_ascending_resize`<br>`gen/ch35/test_gen_cross_dpi_array_queue_inout_5_positive_ascending_stable`<br>`gen/ch35/test_gen_cross_dpi_array_queue_input_1_mixed_ascending_stable`<br>`gen/ch35/test_gen_cross_dpi_array_queue_input_3_mixed_descending_stable`<br>`gen/ch35/test_gen_cross_dpi_array_queue_input_5_positive_ascending_resize` | slangが厳しい | 7.7、35.6.1.1 | 動的配列とキューの仮引数の規則は、DPIのオープン配列にも当てはまります。動的配列とキューを除くのは、出力のオープン配列だけです。slangは、SystemVerilogで書いた関数への同じ呼出しは受理します。 | なし |
| `ch35/test_dpi_enum_base_type_representation` | slangが厳しい | 35.5.5、35.5.6、H.7.3 | 列挙型は基底の型として扱われ、35.5.5の小さい値かどうかは基底の型で決まります。35.5.5の一覧は列挙型を挙げていません。 | Verilator |
