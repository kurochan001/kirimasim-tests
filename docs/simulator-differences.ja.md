<a id="where-icarus-verilog-130-and-verilator-5052-differ-from-the-standard"></a>

# Icarus Verilog 13.0とVerilator 5.052が標準と異なる場合

[English](simulator-differences.md) / [日本語](simulator-differences.ja.md)

スイートの期待出力はIEEE 1800-2023に従い、Icarus Verilog 13.0とVerilator 5.052で確認する（README内の"Where the expected outputs come from"を参照）。これらのリリースのいずれかが引用条項の要求と異なる結果を与えるか，または規格が違法とする設計を受け入れる場所を，それを示すテストと共に一覧表にした。

リリースがまったく対応せず、エラー、"sorry"、"unsupported"のメッセージで停止する構文は列挙していない。それらは、コンパイルできない既知の差異として表示される。Verilator の2状態シミュレータとしてのx，zおよび強度の欠如もリストされていない。構文未対応だけを理由にリリースが拒否する規格違反の設計も、同様に列挙しない。そのエラーがテストで指定した行にあればランナーは拒否として数えるが、`:oracle:`にそのリリースを記録しない理由を、テストのコメントに記述する。

これらはプロジェクトに報告されていない。[ナイトリーレポート](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)は両方の最新バージョン`master`を実行しており、開発バージョンが現在一致している既知の差異は、Icarus Verilogのための`NOW MATCHES`または新しい一致として表示されます。

新しいテストでそのような場所を見つけたら、ここに追加し、テストのコメントにも言ってください。[相互作用ガイド](interaction-verification.md)には、2026-10-30の複合シフトとmembership追加に対する出典の節、独立した検算、および保持した未対応ケースを記載している。その[保存された実行の要約](interaction-verification.md#保存実行の概要)は、それらの実行をCIおよびNightlyから分けている。固定リリースの観察は 後の開発ビルドについての主張ではありません

## Icarus Verilog 13.0

<a id="results"></a>

### 結果

|条項|Icarus Verilog 13.0 が何をするか|テスト|
| --- | --- | --- |
| 11.4.10, 6.11.2 |packed bit ストレージへの6つの選択された複合シフトに対して，X／Zカウントで，元のベクトルは保持される。bit に保存するとき，シフト結果は未知でなければならず，ゼロに変換する。|[cross26-icarus-13.json](../coverage/interaction-results/cross26-icarus-13.json)内の、bitを代入先としX／Zをシフト量とする6件の複合シフトケース。[129 - bit スカラーの場合](../tests/gen/ch11/test_gen_cross_compound_shift_w129_b_u_scalar_shl_z_c8_known.sv)を含む。|
| 11.4.1, 11.4.10 |符号bitがZである符号付き65-bit logic配列要素を65だけ算術右シフトすると、Zを複製せずゼロとなる。これは、以下の添字付きintへの複合代入で先に観測した内容を拡張する。| [test_gen_cross_compound_shift_w65_l_s_element_ashr_width_c65_z](../tests/gen/ch11/test_gen_cross_compound_shift_w65_l_s_element_ashr_width_c65_z.sv) |
| 20.9 |32ビットの倍数でない連結／複製引数の`$countones`は再実行やホスト間で異なる：9つの選択例は6つのローカル実行で異なり，12個はUbunto24.04で異なる（引数幅2 , 33と34）。これらの21はどれもIcarusオラクルを受け取らない。[補助証跡](../coverage/interaction-qualification/README.md) を参照。|21 `gen/ch20/test_gen_cross_query_*`のケースは `icarus_unstable`が`generators/interaction_query.py`で同定した|
| 23.3.3.8, 10.7 |`-ginterconnect`オプションを使うと、より広い入力ポートに接続された符号付き親値をゼロパッドする。変換元を符号拡張しなければならない。同じケースは`-ginterconnect`がない場合も一致する。| `gen/ch23/test_gen_cross_port_w32_i_s_w_k_l_n_a`, `gen/ch23/test_gen_cross_port_w33_i_s_w_x_b_p_n` |
| 11.4.11 |条件がxまたはzの場合、`?:`は両オペランドの同じbitがzの位置でzを返す。11-20 表は x を返します。| `gen/ch11/test_gen_xz_cond_07`, `_08`; `gen/ch11/test_gen_cross_cond_w129_ss_x_same_xz_w_l`, `gen/ch11/test_gen_cross_cond_w65_uu_z_same_xz_n_l` |
| 28.12.1, 28.12.4 |ワンド，ワー，トリアンド，トリオネットについては，ドライバの強さを無視し，その値をlogic関数と組み合わせて強い強さを与える。強いドライバが勝つ必要があり，同じ強さのドライバのみがその強さで組み合わされる。|`:oracle: spec`を伴う29 `gen/ch28/test_gen_strength_{wand,wor,triand,trior}_*`のテスト|
| 30.4.4.1, 32.4.1 |状態依存パスの条件が x または z のときは false とする。SDFファイルのCONDエントリでも、真として扱わなければならない。| `ch30/test_specify_condition_unknown_true`, `ch32/test_sdf_cond_unknown_true` |
| 28.14 |rcmosはstrongのドライブをstrongのまま伝える。rtranやrtranifのように pullに縮小させなければなりません| `ch28/test_rcmos_reduction` |
| 29.7 |逐次UDPインスタンスの遅延が初期値にも適用され、それまではxが見える。| `ch29/test_udp_initial_value_not_delayed` |
| 24.3 |プログラムの初期処理が終了すると，それらが分岐したスレッドは実行を続ける。それらはprogramとともに終了しなければならない。| `ch24/test_program_end_kills_descendants` |
| 24.5, 24.3.1 |プログラムのスレッドと、そこから呼び出されるモジュールのタスクは、Reactive領域ではなく、モジュールのプロセスとともにActive領域で実行されます。そのため、呼び出し時には同じタイムステップのノンブロッキング更新より前の変数が見え、再開するタイムステップでは、モジュール自身のプロセスより前に実行されます。| `ch24/test_program_calls_module_task` |
| 24.3.1 |programのプロセスには、そのタイムステップのノンブロッキング更新前の値が見える（Verilator 5.052も同様）。| `ch24/test_program_reactive_sees_nba`, `ch24/test_program_stimulus_after_clock_edge` |
| 10.6.1, 4.9.2 |`assign`（手続き的連続代入）は右辺を1回だけ評価するため、変数は後の変化に追従しない（この点に関する警告が出る）。Verilator 5.052 は同じことをします）。| `ch4/test_sched_procedural_assign_deassign` |
| 11.5.2, 7.4.5 |これは，無効なアドレスでの 2 状態メモリの読み込みにより，デフォルトの値 0 の代わりに x を返すことを意味する。| `ch11/test_memory_invalid_address_2state` |
| 22.5.3 |これは `` `undefineall `` を知らず、空のマクロとして扱うので、マクロは定義されているままにする。| `ch22/test_undefineall` |
| 32.5 |SDFファイルのINCREMENT遅延を、絶対遅延として適用する。| `ch32/test_sdf_increment_absolute` |
| 32.3 |DELAYFILEのTIMESCALEを無視し、設計の時間単位で遅延値を読み取る。| `ch32/test_sdf_timescale` |
| 32.4.1 |CONDエントリを持つモジュールパスの遅延を、specifyの指定値のままにする。| `ch32/test_sdf_cond_iopath` |
| 32.4.3 |SDFファイルのLABELセクションを読み取らない。| `ch32/test_sdf_label_specparam` |
| 32.9 |これは `$sdf_annotate` の最初の2つの引数のみを使用し、空のモジュールインスタンス引数を拒否する。| `ch32/test_sdf_mtm_spec`, `ch32/test_sdf_scale_factors` |
| 33 |これは、コンフィグ宣言をエラーなしにスキップするので、設計は設定されません。| `ch33/test_config_cell_use`, `ch33/test_config_cell_with_library`, `ch33/test_config_binding_nested`, `ch33/test_config_defparam_precedence`, `ch33/test_config_design_top`, `ch33/test_config_design_two_tops`, `ch33/test_config_instance_deep_path`, `ch33/test_config_instance_over_cell`, `ch33/test_config_instance_use`, `ch33/test_config_library_binding_format` |
| 31 |`$setup` , `$timeskew`と`$fullskew`のようなタイミングチェックをエラーなくスキップするので、その通知者は変わらない。|`ch31/test_timing_timeskew_flags`、`ch31/test_timing_timeskew_remain_active`、`ch31/test_timing_fullskew_event_based`、`ch31/test_timing_notifier_x_and_z`、および`:oracle: spec`、`ch32/test_sdf_recrem_limits`、`ch32/test_sdf_timing_check_limits`、`ch32/test_sdf_separate_setup_hold`、`ch32/test_sdf_width_period_limits`を持つ31章の他のテスト|
| 36.10.1, 38.36.2 |規格がエラーと定めるコールバックを`vpi_register_cb`が拒否しても、`vpi_chk_error`はエラーを報告しません。また、遅延0のcbAtStartOfSimTimeで内部アサーションにより停止します。| `ch36/test_vpi_chk_error_callbacks`, `ch36/test_vpi_chk_error_status` |
| 37.42 |アプリケーションが一度も読み出さないユーザー定義システムタスクの引数を評価します。このような引数を評価してはならない。| `ch36/test_vpi_systf_argument_on_demand` |
| 38.34 |`vpi_put_value` はすべてのスケジュールされたイベントを3つの遅延モードに保持します。慣性遅延は 待ち受けているものをキャンセルしなければならない| `ch38/test_vpi_put_value_delay_modes` |
| 38.36.1 |命名されたイベントに対する値変更コールバックは，値構造を得る。| `ch38/test_vpi_value_change_event` |
| 36.8.1 |ユーザー定義システム関数は、コンパイル時に戻り値の型を必要とする（`.sft`ファイルに記載）。これがない場合、手続きコード内の呼出しは32-bitの結果として扱われ、連続代入内の呼出しはコンパイルされず、最初の実数結果で停止する。| `ch36/test_vpi_systf_function_types`, `ch36/test_vpi_systf_function_in_continuous_assign` |
| 9.6.1, 9.6.3 |内部アサーションで終了する。| `ch9/test_wait_fork_disable_fork` |
| 7.10.2.4, 7.10.2.5, 7.4.5 |intの空キューに対する`pop_front()`と`pop_back()`がxを返し、その後int変数にもxが格納されます。表7-1では0となる。packed bit要素の空キューも、0の代わりにxを返す。| `ch7/test_queue_method_edges`; `gen/ch7/test_gen_cross_queue_w129_b_s_c2_n0_pop_back_z`, `gen/ch7/test_gen_cross_queue_w1_b_u_c3_n0_pop_back_known`, `gen/ch7/test_gen_cross_queue_w65_b_u_c3_n0_pop_front_z` |
| 7.10.2.2, 7.10.2.6, 7.10.2.7, 6.11.2 |packed logic要素のキューへ、より広い引数をpush／insertする選択ケース7件は、コンパイルは成功するが、実行時アサーション`value.size() == wid`で停止する。引数は、保存する前に要素タイプに変換されなければなりません。|[相互作用ガイド](interaction-verification.md)に記載されている 7つのアサーション事例は `gen/ch7/test_gen_cross_queue_w129_l_s_c2_n0_insert_known`を含みます|
| 20.17.2 |`$stacktrace` を関数として呼び出すと、コンパイラは内部アサーションで停止します。| `ch20/test_stacktrace_function` |
| 37.3.5 |`vpi_put_value` は，インデックスが副作用を持つシステムタスクの引数に対して，エラーを報告する代わりに内部のアサーションを停止する。| `ch37/test_vpi_put_value_side_effect` |
| 30.7.4.2 |showcancelled宣言が機能せず、負のパルスでxを表示する代わりに出力が変化しない。| `ch30/test_negative_pulse_cancelled` |
| 29.3.2 |出力をregと宣言した組合せUDPでは、エラーを報告せず、内部アサーションで停止する。| `ch29/test_illegal_udp_combinational_reg` |
| 6.21, 7.5 |ダイナミック配列の要素に対する連続的な代入は，エラーを報告する代わりに内部のアサーションで停止させる。| `ch6/test_illegal_dynamic_array_element_continuous` |
| 13.4.4 |join_none のフォークが遅延を伴うプロセスを生成する関数は、その関数が遅延を持っているかのように拒否されます。起動したプロセスには、タスクで許される任意の文を含められる。| `ch4/test_sched_fork_join_none_in_function` |
| 9.6.3 |タスク内のdisable forkは、呼出し元プロセスが呼出し前に起動したプロセスを終了させない。| `ch4/test_sched_disable_fork_in_called_task` |
| 21.2.1.3 |関数呼出しなどの式に対する`%h`は、最上位の桁が4ビット未満で、そのビットがすべてxの場合、xではなくXを出力する。同じ値の変数は x を出力します| `gen/ch13/test_gen_wide_subroutine_w65_4state` |
| 7.4.5, 11.5.1 |`m[i][7:0] = v`のように、可変添字で指定したpacked配列の要素の部分選択への書き込みを拒否し（"Array index expressions must be constant here"）、内部アサーションで停止します。|7 `gen/ch7/test_gen_wide_select_*_2state` テストを|
| 20.9 |`$countbits`は、`$countones`の検査後に、内部アサーションで実行を停止する（終了コード134）。| `ch20/test_countones_bits` |
| 6.16.12, 6.16.9 |負のintに対する`hextoa`は、マイナス符号と絶対値の桁を出力する（32'hDEADBEEFでは`-21524111`）。符号を読み取らない`atohex`の逆変換であるため、値の16進数の桁を出力しなければならない。| `ch6/test_string_hextoa` |
| 21.2.1.2 |`%h`のフィールド幅を指定すると、空白で埋める（8'habに対する`%4h`で`[  ab]`）。十進数以外では、先頭のゼロを常に表示する。| `ch21/test_display_format` |
| 16.3 |即時cover文は、式が真でも成功文を実行しない（Verilator 5.052も同様）。| `ch16/test_assert_immed_2` |
| 30.7.1 |`PATHPULSE$`を無視します。モジュールパスの遅延より短いパルスが、`PATHPULSE$`のreject/error限界に従えば伝播するかxになる場合でも、除去されます。| `ch30/test_specify_pulse_filtering`, `ch30/test_specify_pulsestyle_ondetect` |
| 36.3.2 |`$signed`または`$unsigned`として登録されたVPIアプリケーションは、組み込み関数を置き換えません。組み込み関数の結果は、sizetfルーチンが返す幅ではなく、引数の幅を保持します。| `ch36/test_vpi_systf_override_signed_width` |
| 37.3.5 |関数呼出しや`k++`など、副作用を持つシステムタスク引数への`vpi_get_value`は、副作用を含めて引数を再評価せず、毎回タスク呼出し時の値を返す。| `ch37/test_vpi_get_value_side_effects` |
| 37.20 |vpiMemoryとvpiMemoryWordの関係が、型vpiRegArrayとvpiRegではなく、型vpiMemoryとvpiMemoryWordのオブジェクトを返します。また、ワードのvpiIndexが配列の宣言範囲内の添字ではなく、0から数えた値になります。| `ch37/test_vpi_memory_word_objects` |
| 38.3 |`mem[j]`のような可変添字を使って要素またはbitを選ぶ引数について、`vpi_compare_objects`は、添字が選ぶ要素またはbitに対して0を返します。| `ch38/test_vpi_compare_objects_variable_select` |
| 38.22 |階層の異なるレベルにあるポートを持つ `vpi_handle_multi(vpiInterModPath, ...)` はパスを挿入できないと報告し、 NULL を返します。| `ch38/test_vpi_intermod_path_levels` |
| 38.4, 20.2 |診断レベル0は何も出力しない規定（表20-1）ですが、`vpi_control(vpiStop, 0)`が実行する`$stop`は、シミュレーション時刻付きのレポートを出力します。| `ch38/test_38_extra_control_stop` |

<a id="illegal-designs-that-it-accepts"></a>

### 受け入れる違法デザイン

|条項|デザイン|テスト|
| --- | --- | --- |
| 10.6.1 |変数の部分選択に対する手続き的assign文| `ch10/test_sched_procedural_assign_part_select` |
|9.2.2.2から9.2.2.4へ|always_ff、always_comb、always_latchの変数に、関数を介する場合も含め別のプロセスが書き込む| `ch9/test_illegal_always_ff_other_writer`, `ch9/test_illegal_always_comb_other_writer`, `ch9/test_illegal_always_latch_other_writer`, `ch9/test_illegal_always_ff_written_via_function` |
| 6.5 |変数として宣言され、モジュールによって割り当てられた入力ポート| `ch6/test_illegal_input_port_variable_assigned` |
| 25.5 |所属interfaceが宣言していない信号を指定するmodport| `ch25/test_illegal_modport_undeclared_name` |
| 8.10 |非静的なプロパティを読み込む静的メソッド| `ch8/test_illegal_static_method_uses_property` |
| 13.4 |関数の fork-join または fork-join_any を使って| `ch13/test_illegal_function_fork_join`, `ch13/test_illegal_function_fork_join_any` |
| 6.20.5 |値がspecifyパラメータを使用するパラメータ| `ch6/test_illegal_parameter_from_specparam` |
| 33.4.1.2, 33.4.1.4, 33.4.2 |2 つのデフォルト liblist 条項、ライブラリと liblist を含む cell 条項、他の config の階層内のインスタンスを名付ける instance 条項 (config 宣言をスキップ)| `ch33/test_illegal_config_two_default_liblists`, `ch33/test_illegal_config_cell_library_liblist`, `ch33/test_illegal_config_instance_inside_other_config` |
| 6.7.1 |net 型キーワードに `reg` ( `wire reg` ) が直接続く| `ch6/test_illegal_net_type_then_reg` |
| 23.10.4.2 |generateブロックのエラボレーション後に、階層名が別のパラメータへ解決されるdefparam| `ch23/test_illegal_defparam_early_resolution` |
| 30.7.4.2 |モジュールパスの後に置き、そのパスの出力を指定するshowcancelled宣言| `ch30/test_illegal_showcancelled_after_path` |
| 24.3, 24.5 |プログラムの変数を読み込むモジュールと、プログラムのタスクを呼び出すモジュール| `ch24/test_illegal_program_signal_from_module`, `ch24/test_illegal_module_calls_program_task` |
| 12.8 |fork-joinブロック内から、そのブロックを囲むループを終了するbreak| `ch12/test_illegal_break_in_fork_to_outer_loop` |
| 29.3.4, 29.6 |同じ入力に対して異なる出力を与える二つのエントリと、二つの入力に転移を与えるエントリを含むUDPテーブル| `ch29/test_illegal_udp_conflicting_entries`, `ch29/test_illegal_udp_two_transitions_in_entry` |
| 31.4.4, 31.4.5, 31.4.6 |基準イベントにエッジがない`$width`と`$period`、およびエッジ制御指定子を持つ`$nochange`（タイミングチェックをスキップする）| `ch31/test_illegal_width_reference_not_edge`, `ch31/test_illegal_period_reference_not_edge`, `ch31/test_illegal_nochange_edge_control` |

また，refポートや関数の出力引数をサポートせず，モジュールのインタフェースポートのmodポートを解析しないなど，誤り以外の理由で不正な設計を拒否する。

## Verilator 5.052

<a id="additional-array-reduction-constraint-checks-2026-11-02"></a>

### 配列リダクション制約の追加確認（2026-11-02）

§18.5.7.2・7.12.3の型と演算幅を確認する新規13件は、固定Verilator 5.052の両seedとも元の全出力が一致しません。
固定配列8件では通常のリダクションを広い観測変数へ代入した結果が狭幅に収まらず、動的配列5件では戻り値や診断を含む出力が異なります。
[seed 1](../coverage/interaction-results/cross65-randreduce-verilator5052-seed1.json)・
[seed 73](../coverage/interaction-results/cross65-randreduce-verilator5052-seed73.json)に版と入力ハッシュを保存しています。
元の期待値とspecを保持し、観測用代入だけへ要素型キャストを加えた固定配列の補助対照は別扱いにします。
[設計と補助対照の限界](interaction-verification.md#array-reduction-constraints-and-retention)を参照してください。


<a id="additional-associative-query-checks-2026-11-02"></a>

### 連想配列問い合わせの追加確認（2026-11-02）

§20.7の連想配列問い合わせで、新規18件は固定Verilator 5.052の両seedとも出力不一致です。
最初の空配列で`$right`が0、`$increment`が1となり、添字型の最大値と-1という期待値と異なります。
[seed 1](../coverage/interaction-results/cross64-assocquery-verilator5052-seed1.json)・
[seed 73](../coverage/interaction-results/cross64-assocquery-verilator5052-seed73.json)に実行版と入力ハッシュを保存しています。
固定版oracleは登録せず、合法な正例と規格に基づく期待値を保持しています。
固定Icarusのビルド拒否、独立計算、Python仕様モデル変異の確認範囲は[モデルの設計](interaction-verification.md#associative-array-domains-and-allocation)を参照してください。


<a id="results-1"></a>

### 結果

|条項|Verilator 5.052 が何をするか|テスト|
| --- | --- | --- |
| 35.6.1, 35.6.1.1, 35.6.2 | imported int仮引数へ渡す合法な65ビット配列要素のoutput/inout実引数4件が、両seedでビルド時のサイズ変換の内部エラーとなる。規格由来の変換・書戻しの期待値を維持し、固定oracleを付けない。 | `gen/ch35/test_gen_cross_dpi_nba_*_65_*`; [範囲と両seedの記録](interaction-verification.md#dpi-copyback-and-nba-capture) |
| 13.5.1, 13.5.2 |refとして渡した129 bit幅のbitベクトルのキュー要素と、const refとして渡した65 bit幅のbitベクトルの動的配列要素は、呼出し側が元の要素を変更した後も、呼出し開始時の値を示す。両方のシードで不一致となる。const ref と ref は呼び出し者の更新を観察しなければなりません。| `gen/ch13/test_gen_cross_bind_w129_b_known_ref_queue_same`, `gen/ch13/test_gen_cross_bind_w65_b_known_const_ref_dynamic_next` |
| 13.5.2 |型が等価なlogicベクトル要素をconst ref実引数として拒否する。33-bitのキュー要素と64-bitの固定配列要素は、両方のシードでref引数の型に関する診断を生じる。等価な型を持つ配列要素は、正当な実引数である。| `gen/ch13/test_gen_cross_bind_w33_l_known_const_ref_queue_invalid`, `gen/ch13/test_gen_cross_bind_w64_l_known_const_ref_fixed_same`; [モデルと保存実行](interaction-verification.md#引数の結合と呼出し後の添字変更) |
| 14.16, 4.4.2 |非ゼロ出力スキューを持つクロック出力に対して，将来の駆動時にアクティブ観測が既に新しい値を見る。ドライブは、そのActive領域での観測より後のRe-NBAで更新しなければならない。Postponed領域での観測では、新しい値が見える。両方の固定シードで、時刻8に不一致となる。| `ch14/test_clocking_default_skew`; [レビューと保存実行](issues-40-44-review-20261031.md) |
| 11.4.1, 11.5.1 |可変のpacked部分選択に対する2種類の複合シフト代入が添字関数を2回評価し、その次の添字と、選択していないビットまで変更します。左辺の添字は、1回だけ評価しなければならない。両方のシードは1つの代わりに2つの呼び出しを示します。[出力全体と故障対照](../coverage/interaction-qualification/20261030-compound-shift.json) が保存されます。| [33-bitの符号付き親のケース](../tests/gen/ch11/test_gen_cross_compound_shift_w33_l_s_part_ashr_last_c8_known.sv), [129 - bit 事例](../tests/gen/ch11/test_gen_cross_compound_shift_w129_b_u_part_shr_width_c8_known.sv) |
| 11.4.13, 11.4.6, 11.8.2 |128-bitの符号付き全1の検索値が、129-bitの符号なし全1・1の要素を明示列挙した集合に対し、1を返します。共通の符号なし型での比較では、検索値をゼロ拡張し、0としなければならない。両方のシードで、最後の入力フェーズが不一致となる。2-bitの符号付き`11`が、明示列挙と配列の集合の両方で、3-bitの符号なし要素`111`に対しても符号拡張されます（正しくは0の箇所で1）。| [test_gen_cross_inside_w129_n_su_b_list_n3_known](../tests/gen/ch11/test_gen_cross_inside_w129_n_su_b_list_n3_known.sv), [test_inside_array_set_mixed_sign_width](../tests/ch11/test_inside_array_set_mixed_sign_width.sv) |
| 11.4.13, 11.8.1, 11.8.2 |insideの集合が2-bitの符号付き要素を持つunpacked配列の場合、3-bitの符号なし検索値`111`が、`{11}`と`{01, 11}`に含まれると判定されます。同じ要素を個別に列挙すると、要素は`011`へゼロ拡張され、正しい0になります。両方のシードで同じ出力となる。[出力全体](../coverage/interaction-qualification/20261030-inside-fc4cc356.json)は保存されます。| [test_inside_array_set_mixed_sign_width](../tests/ch11/test_inside_array_set_mixed_sign_width.sv) |
| 11.4.13, 11.8.1, 11.8.2 |上限が`$`の範囲で、検索値が下限に一致しても0になります。2-bitの符号なし`01`または`11`が、1の1-bit `lo`を持つ`[lo:$]`や`[1'b1:$]`に含まれません。また、8-bitの符号なし`5`または`200`が、3の変数`lo`を持つ`[lo:$]`に含まれません。定数`[3:$]`なら正しい1になります。`$`側は、検索値の型が取り得るすべての値について成立する。8-bitの符号付き検索値-5が、10の8-bit符号なし`hi`を持つ`[$:hi]`に含まれると判定されますが、符号なし比較251 \<= 10は0です。一方、128-bitの符号付き検索値は、最下位以外が全1の129-bit符号なし`hi`を持つ`[$:hi]`に決して含まれません。本来、ゼロ拡張した検索値は常に範囲内です。関係演算子を同じ境界で書き出すと正しい結果が得られる。両方のシードで同じ出力となる。[プローブと出力は](../coverage/interaction-qualification/20261030-range.json)は保存されます。| [test_gen_cross_range_w1_w_uu_b_high_open_known_s](../tests/gen/ch11/test_gen_cross_range_w1_w_uu_b_high_open_known_s.sv), [test_gen_cross_range_w129_n_su_b_low_open_known_s](../tests/gen/ch11/test_gen_cross_range_w129_n_su_b_low_open_known_s.sv) |
| 12.5.4, 12.5 |通常のcase insideでは、最初の項目が一致しても第3項目のカウント関数を呼び出す（0が正しい場合の`probe=1`）。これは、一致後の項目評価について`ch12/test_case_inside_evaluation_order_by_qualifier`が記録している動作である。両方のシードで同じ出力となる。| [test_gen_cross_caseinside_w1_s_uu_b_list_known_pc](../tests/gen/ch12/test_gen_cross_caseinside_w1_s_uu_b_list_known_pc.sv) |
| 11.5.1 |昇順のbitベクトルに対する、変数添字による一部の範囲外選択が、読み取るとゼロ、書込みは無視するという必要な動作に従わない。両方の固定シードで不一致となる。負の範囲や、ワードサイズでないベクトルで境界の問題が現れる。| `gen/ch11/test_gen_cross_index_w129_z_a_b_u_before_known`, `gen/ch11/test_gen_cross_index_w64_n_a_b_u_after_known`, `gen/ch11/test_gen_cross_index_w65_n_a_b_s_before_known` |
| 7.10.5 |上限付きキューが満杯のときのpush／書込み操作は、内容は正しいが、必要なオーバーフロー警告が出ない。3要素で満杯のbitキューも、insertで4要素に増える。| `gen/ch7/test_gen_cross_queue_w1_b_u_c2_n2_push_front_known`, `gen/ch7/test_gen_cross_queue_w1_b_u_c3_n3_write_end_known`, `gen/ch7/test_gen_cross_queue_w65_b_s_c2_n2_push_back_known`; `gen/ch7/test_gen_cross_queue_w1_b_u_c3_n3_insert_known` |
| 7.12.3, 6.24.1, 11.8.2 |配列リダクションの一部の結果、拡張、または式の幅が異なる。符号なし1-bitの動的配列にある3個の1のsumが、`01`ではなく`11`へ拡張されます。33-bitのwith式を伴う32-bitの積も、広い代入先へ代入すると不一致となる。[相互作用ガイド](interaction-verification.md) では，7つの観測された出力差を列挙した。|`gen/ch7/test_gen_cross_method_w1_b_u_d_sum_plain_known` `gen/ch7/test_gen_cross_method_w32_l_u_f_product_widen_known` とガイドに記載されている他の5つのケース|
| 11.4.14.3 |スライス幅4で33ビットを左向きにストリーミングしてアンパックすると、パック時の置換の逆ではなく、パックと同じ置換になります。部分ブロックはこれらの置換を異にする。両方の固定シードで、同じ差異が生じる。| `gen/ch11/test_gen_cross_stream_w33_l_s4_p_unpack_b_k` |
| 16.12.11, 16.16.1 |手続きの外にある`always a`のassert propertyが、`a`を偽としてサンプルしたtickで1回だけ失敗します。各tickで評価試行が開始されるため、そのtickまでの3つのtickで開始した試行は、その時点でそれぞれ失敗しなければならない（25で3回失敗）。両方のシードで同じ出力となる。| `ch16/test_ch16_sim_prop_inherited_always` |
| 20.10 |`$error` は実行を停止します。エラーを報告したうえで、処理を続行しなければならない。ランナーは`+verilator+error+limit+1000000`を渡し、それによって処理が続行する。|`ch20/test_error_does_not_end_run` (そのオプションなし)|
| 20.10, 9.2.3 |`$fatal`で実行を終了すると、final手続きは実行されない。| `ch20/test_fatal_runs_final_procedures` |
| 4.4.2.3, 21.2.2, 21.2.3 |時刻0で、`$strobe`と`$monitor`は、`#0`後または非ブロッキング代入による書き込み前の値を示します。`$monitor` はインタフェースの変数の変更もミスします。|不一致となる45 `gen/ch4/test_gen_sched_*_{strobe,monitor}_*`のテスト、`ch4/test_sched_strobe_after_zero_delays_and_nba`、`ch4/test_sched_monitor_once_per_time_step`|
| 4.9.1, 4.4.2.3 |2回目の`#0`後も、連続代入の古い値を示す。| `ch4/test_sched_contassign_zero_delay` |
| 9.2.2.2.2 |`always @*` 0 で実行され、呼び出された関数の中で読み取るだけの変数の変更に対して起動されます。| `ch9/test_always_comb_vs_always_star` |
| 9.4.2 |0 の時点でイベントコントロールは一度起動するが，何も変化しない。| `ch9/test_event_nested_struct_member`, `ch12/test_foreach_index_shadows_outer`, `ch16/test_deferred_assertion_disable_inner_scope` |
| 11.4.4 |オペランドにxまたはzのbitを含む関係演算子が、xではなく既知ビットから1または0を返します。`4'b1x00 > 4'b0001`は1、`4'b001z <= 4'b1111`は1になります。| `ch11/test_relational_equality_wildcard_one_bit_results_extension` |
| 24.3.1 |programのプロセスには、そのタイムステップのノンブロッキング更新前の値が見える（Icarus Verilog 13.0と同様）。| `ch24/test_program_reactive_sees_nba`, `ch24/test_program_stimulus_after_clock_edge` |
| 24.7 |`$exit` はモジュールのプロセスから呼び出され、シミュレーションを終了します。無視しなければならない| `ch24/test_exit_outside_program_ignored` |
| 24.7 |programのtask内で`$exit`を呼び出すとtaskから戻り、initial手続きが続行する。programのすべてのinitial手続きを終了させなければならない。| `ch24/test_program_exit_in_task` |
| 24.7 |`$exit` をプログラムのフォークスレッドで呼び出すと、シミュレーション全体が終了します。そのprogramのinitial手続きだけを終了させなければならない。| `ch24/test_program_exit_from_fork` |
| 16.4, 16.4.2, 16.4.4 |Observed遅延アサーションのアクションブロックを、Reactive領域ではなく、アサーションの位置で直ちに実行する。そのため、const ref引数はノンブロッキング更新前の値を読み、flush点でもdisable文でも報告を取り消せない。| `ch4/test_sched_deferred_action_arguments`, `ch16/test_deferred_assertion_forked_processes`, `ch16/test_deferred_assertion_disable_inner_scope` |
| 15.5.1 |プロセスは `->>` でトリガされたイベントを待つが、起動しない。両方の固定シードで、event-OR／iffを使う名前付きケースと混合ソースのケースでも、生のイベントカウンタはゼロのままとなる。| `ch4/test_sched_nonblocking_event_trigger`, `gen/ch9/test_gen_cross_iff_or_named_change_first_known_nba`, `gen/ch9/test_gen_cross_iff_comma_mixed_negedge_both_known_nba` |
| 26.3 |名前の明示的なインポートは、他のパッケージから同じ名前を提供するワイルドカードインポートより優先されません。明示importを優先しなければならない。| `ch26/test_package_explicit_import_hides_wildcard` |
| 8.11, 6.23 |"Cannot use 'this' in a static method" は静的メソッドで type(this) を拒否します。type(this)は、クラス内のどこでも、そのクラス自身の型を表す。| `ch8/test_type_this` |
| 10.6.1, 4.9.2 |`assign`（手続き的連続代入）は、右辺の後続の変化に追従しない（Icarus Verilog 13.0と同様）。| `ch4/test_sched_procedural_assign_deassign` |
| 11.5.2, 7.4.5 |また，メモリの不正なアドレスは上位ビットを失い，別の要素が読み込まれ，書き込まれる。| `ch11/test_memory_invalid_address_2state` |
| 29.7, 29.8 |遅延付きの逐次UDPインスタンスは、遅延が経過する前に出力を変える。2つの遅延を持つと クロックの端で変化し どちらも使わない| `ch29/test_udp_initial_value_not_delayed`, `ch29/test_udp_instance_rise_fall_delay` |
| 14.16 |net上のクロッキング出力への同期ドライブがnetに伝わらない。ここでは、弱い1と競合する0、およびwand net上のドライブが該当する。| `ch14/test_clocking_output_net_driver` |
| 33.4.1.1, 33.5.4 |設計命令が2つのセルを名付けるコンフィグでは，他の非インスタンス化モジュールもトップレベルモジュールとする。| `ch33/test_config_design_two_tops` |
| 30 |specifyブロックのモジュールパス遅延をエラーなしで無視し、出力がその遅延なしで変化する。|`:oracle:`内の`iverilog@13.0`を伴う第30章のテスト。例えば`ch30/test_specify_path_rise_fall`。|
| 31 |タイミングチェックをエラーなしでスキップするため、notifierは一度も変化しない。|31章の`:oracle: spec`を持つテスト（`ch31/test_timing_recrem_windows`など）、および`ch32/test_sdf_recrem_limits`、`ch32/test_sdf_timing_check_limits`、`ch32/test_sdf_separate_setup_hold`、`ch32/test_sdf_width_period_limits`|
| 20.4.2 |`$printtimescale` は、括弧なしでデザイン要素の名前を出力します。| `ch20/test_printtimescale_other_module`, `ch3/test_timeunit_with_precision` |
| 21.2.3 |`$monitoron` は何も印刷しません。| `ch21/test_monitor_end_of_step` |
| 21.3.7 |`$ferror`は、エラーがないときに文字列へ"Undefined error: 0"を設定する。| `ch21/test_file_fflush_ferror` |
| 21.3.5 |ファイル終端から`$fseek`を実行すると、EOFを読み取り、誤った位置を報告する。| `ch21/test_file_seek_tell_rewind` |
| 35.5.6, H.7.4 |インポート関数のshortreal引数と戻り値が誤っている（0.0）。| `ch35/test_dpi_shortreal` |
| 18.5.12 |制約のガードによってnullハンドルの参照を防ぐことができない。| `ch18/test_constraint_guard_null` |
| 18.6.3 |ランダム化が失敗してもpost_randomizeを呼び出し、`std::randomize`へ渡した変数を変更する。| `ch18/test_randomize_failure_keeps_values` |
| 8.26.5 |あるinterface classのハンドルから別のinterface classのハンドルへのキャストが失敗する。| `ch8/test_interface_class_cast` |
| 19.5, 19.5.7 |coverpointの型へのキャストで保持できないビンの値が除外されず、サンプル値もcoverpointの型へ変換されないままビンと比較されます。| `ch19/test_cg_bins_value_resolution`, `ch19/test_cg_coverpoint_type_resolution` |
| 19.5.1 |固定数のビンは無視し，値ごとに1ビンを作成する。| `ch19/test_cg_fixed_count_bins` |
| 19.5.3 |enum coverpoint は自動ビン数を間違えます。| `ch19/test_cg_enum_auto_bins` |
| 19.5.5, 19.5.6 |無視された値と違法な値はビンに残り，自動ビンでも数えられる。トランジションビンは無視された または違法なトランジションを含むシーケンスを保持します| `ch19/test_cg_ignore_bins`, `ch19/test_cg_illegal_bins_removed`, `ch19/test_cg_auto_bins_illegal_ignore`, `ch19/test_cg_excluded_transitions` |
| 19.7 |`at_least`が無視され、ビンは1回のヒットでカバー済みとなる。| `ch19/test_cg_at_least` |
| 19.6, 19.11 |クロス、および重みを付けたcovergroupのカバレッジは、weightオプションを無視した、全ビンに対する割合となる。| `ch19/test_cg_cross_coverage`, `ch19/test_cg_item_weighted_average` |
| 19.8 |`stop()`の後もサンプリングが続き、`get_coverage`は両引数を0に設定する。| `ch19/test_cg_start_stop_counts` |
| 11.3.1 |shortrealをrealとして保持・計算するため、shortrealオペランドを含みrealオペランドを含まない式もrealの精度になります。16777216.0 + 1の結果は、shortrealでは保持できない16777217.0です。| `ch11/test_real_operand_result_types`, `ch11/test_shortreal_result_and_condition_types` |
| 7.10.3, 13.5.2 |キュー要素への参照が、要素自体ではなく位置に追従する。要素の削除後に参照を通じて書き込むと、その位置へ移った要素が変わる。キュー全体への代入後には、既にキューのものではないメモリを読み取る。両方の固定シードで、キュー参照のクロスモデルの移動・削除・全体代入後にも、9箇所の出力差が見られる。| `ch7/test_queue_reference_persistence`; [キュー参照ケースと保存実行](interaction-verification.md#キュー要素への参照と要素の寿命) |
| 7.10.3, 7.10.4, 13.5.2 |完全な有界キューの最後のワードへのホールド参照，連結代入，後の書き込みはSIGBUSで終わり，両方の固定種で出力がない。構築に成功しました。実装上の原因は未調査である。| `gen/ch7/test_gen_cross_qref_w32_b_t_l_concat_known`; [ブラックボックスの再チェック](../coverage/interaction-qualification/20261031-queue-ref-verilator.json) |
| 16.9.1 |`x throughout y ##1 z`を`(x throughout y) ##1 z`としてグループ化する。`##`はthroughoutより強く結合しなければならない。| `ch16/test_sequence_operator_precedence` |
| 20.4.1 |`$timeprecision`は引数を与えずに，設計要素の精度の代わりにシミュレーション精度を与える。| `ch20/test_timeunit_timeprecision_functions` |
| 20.7 |動的次元の後にある固定サイズ次元への`$size`は、0を返す。| `ch20/test_array_query_fixed_dimensions` |
| 21.2.1.6 |`%p`は、intメンバーを`'h`付きの16進数で、enumメンバーを名前ではなく数値で出力する。| `ch21/test_format_p_struct` |
| 28.3.3, 28.10 |遅延付きpullupにより、内部エラーで停止する。エラーがpullupの行を示すため、ランナーはテストで要求する拒否として数える。`:oracle:` `verilator@5.052` をリストしません。| `ch28/test_illegal_pullup_delay` |
| 6.6.3 |wand、wor、triand、triorのnetは、全ドライバのANDまたはORではなく、1つのドライバの値を取る（`1 & 0`は1、`0 \| 1`は0となる）。| `ch6/test_net_wand`, `ch6/test_net_wor`, `ch6/test_net_triand`, `ch6/test_net_trior`, `ch6/test_edge_wor_wand`, `ch6/test_net_resolution`, `ch6/test_net_types_resolution` |
| 20.5 |`$shortrealtobits`は0（0.0001では他のビット）を返し、`$bitstoshortreal`は0.0を返す。| `ch20/test_shortreal_ieee754`, `ch20/test_system_shortrealtobits`, `ch20/test_system_bitstoshortreal`, `ch20/test_real_bits_simple`, `ch20/test_real_literal_type`, `ch20/test_realtobits_bitstoreal`, `ch20/test_realtobits_corner_cases`, `ch20/test_math_special_values`, `ch20/test_type_conversion` |
| 20.8.2, 6.12 |定義域外の数学関数または`$bitstoreal`で生じたNaNが、表示はnanであるにもかかわらず自分自身と等しいと判定されます（`v != v`が偽になります）。実数は，そのNaNがすべての値に不等なCダブルである。| `ch20/test_math_special_values`, `ch20/test_math_advanced`, `ch20/test_math_hyperbolic_special_values`, `ch20/test_system_functions_edge`, `ch20/test_realtobits_bitstoreal` |
| 4.4.2.3, 4.5 |`#0`の直後では、その前の書込みで起床した連続代入とalways_combブロックは、まだ古い値を示す。アクティブ領域が空になったときにのみプロセスが再開されます。| `ch4/test_delta_cycle`, `ch4/test_ieee1800_2023_delta_convergence`, `ch9/test_always_comb_cascade_propagation` |
| 9.2.2.2, 4.4.2.3 |`a = 1; b = 2; #0; a = 3; b = 4; #1`の後、`a + b`のalways_combは3を保持する。`#0`の後の書込みでは起床しない。| `ch9/test_sensitivity_edge_cases` |
| 9.4.2.2 |これは、`always @*`ブロックが読み込んだ変数（カウンタ）を書き込むと、DIDNOTCONVERGE で実行を停止する。それ自身の書き込みは、それが待っている間ではなく、それが実行中に来るので、それらはそれを再び起動しない。| `ch9/test_implicit_event` |
| 21.3.4.3 |`$sscanf`はフィールド幅を無視し、`%4d%4d`は`12345678`全体を最初の変数へ読み込む。`%d`は、数値の一部として読むべきアンダースコアで停止する。| `ch21/test_scanf_comprehensive`, `ch21/test_numeric_edge_cases` |
| 6.16.9 |`atoi`は符号を読み取り、先頭の空白をスキップする（`"-9876"`は-9876、`"   42"`は42を返す）。先頭の数字とアンダースコアだけを読み取り、両方に0を返さなければならない。| `ch6/test_string_atoi`, `ch6/test_string_atoi_2` |
| 5.7.1 |2147483648以上のサイズ未指定の十進数に、その絶対値に必要なビットだけを割り当てて符号付きと解釈するため、負値となる。`1000000000000`は-99511627776を返し、2147483648のlongintは`2147483648`と等しくないと判定される。| `ch6/test_int_types_edge_cases`, `ch11/test_ieee1800_2023_arithmetic_edge` |
| 11.6.1, 11.6.2 |intに対する`INT_MIN / -1`は、0を返す。商2147483648を32ビットへ切り詰めた結果は-2147483648です。| `ch11/test_ieee1800_2023_arithmetic_edge` |
| 29.6 |クロックの立ち上がりで出力を反転する表を持つ逐次UDP（初期値0のTフリップフロップ）が、エッジ後も0を保持します。| `ch29/test_udp_seq` |
| 21.2.1.1 |`%E`と`%G`は小文字の`e`を書く。実数の書式はCの書式に従い、この場合`E`と出力しなければならない。| `ch21/test_format_advanced`, `ch21/test_format_float` |
| 16.3 |即時cover文は、式が真でも成功文を実行しない（Icarus Verilog 13.0と同様）。| `ch16/test_assert_immed_2` |
| 15.4.9 |"Class parameter type without default value" タイプパラメータなしで宣言されたメールボックスを拒否します。このmailboxは型指定なしである。| `ch15/test_mailbox_typeless_try_type_check` |
| 16.4.3, 9.2.2.2.1 |アクションブロックが変数を書き込む、手続きコード外の遅延アサーションは、DIDNOTCONVERGEで実行を停止させる。アクションブロックの式は感度に含まれないにもかかわらず、その書込みで再び起床する。| `ch16/test_static_deferred_assertion_always_comb` |
| 16.12.7, 16.9.8 |`a ##[1:3] b \|=> c`は、前件のいずれかのマッチ後に後件が成立すると成功する。`first_match`でも同様である。各マッチ後に成立する必要があり、`first_match`では最初のマッチ後に成立する必要がある。| `ch16/test_first_match_antecedent` |
| 16.12.14 |`not (accept_on (k) ...)` は k が評価を中止したときに通過します。abort はオペランドを true にするので 否定は失敗しなければなりません| `ch16/test_property_abort_nesting` |
| 18.5.13.1 |外部制約ブロックのソフト制約は，そのプロトタイプの順序ではなくブロックの順序でランク付けされる。| `ch18/test_soft_priority_layers` |
| 18.5.13.2 |`disable soft x` は，x を名前付けしない優先度の低いソフト制約をすべて除去する。| `ch18/test_disable_soft_direct_reference` |
| 18.5.8, 18.11 |引数を持つ `randomize()` は，リストに含まれていない rand のハンドルのオブジェクトをランダム化し，その制約を適用する。| `ch18/test_global_constraints_nested_inactive` |
| 18.5.7.1, 18.4 |`randomize() with { q.size() == 3; }`では、`q[0]`を3に設定し、`q`のサイズを以前のままにする。3になる必要があります| `ch18/test_foreach_dynamic_multidim_constraint` |
| 18.11.1 |`randomize()` 1 はランダム変数を持たないオブジェクトの制約条件が成り立たないときにも返します。0 を返さなければなりません| `ch18/test_randomize_checker_state_only` |
| 18.16 |randcaseの実行ごとに、randcase項目の重み式を2回評価します。評価は最大1回までです。| `ch18/test_randcase_weight_precision` |
| 35.6.1.1, H.7.6 |逆方向の範囲を持つ仮引数へ渡したunpacked配列（`int up[0:3]`から`int a[3:0]`）が、実引数の順序でCへ渡される。Cの要素0は`up[0]`となる。仮引数への実引数の代入は左から右の順なので、C側の要素0は`a[0]`、すなわち`up[3]`になる必要があります。| `ch35/test_dpi_wysiwyg_formal_types` |
| 35.5.3 |importの呼出し連鎖から呼んだexportが戻ると、連鎖のスコープが呼出し時のものへ戻らず、export中に設定されたスコープのままになる。| `ch35/test_dpi_context_call_chain` |
| 38.6, 37.17 |int、byte、longint変数の`vpiType`が、vpiIntVar、vpiByteVar、vpiLongIntVarではなくvpiLogicVarになります。vpiScalar 1 を持つ実変数;vpiTimeUnitとvpiTimePrecisionはモジュールとシミュレーションの時間単位以外の値を与える。| `ch38/test_vpi_get_property_values` |
| 38.35 |`vpi_put_value_array` は二次元配列上の他の要素からの値を別の順序で書き込む。| `ch38/test_vpi_put_value_array_order` |
| 38.36.1 |値変化コールバックの`s_cb_data`で渡される時刻が、現在時刻ではなく0になります。| `ch38/test_vpi_release_handle_keeps_object` |

<a id="illegal-designs-that-it-accepts-1"></a>

### 受け入れる違法デザイン

|条項|デザイン|テスト|
| --- | --- | --- |
| 10.6.1 |変数の部分選択に対する手続き的assign文| `ch10/test_sched_procedural_assign_part_select` |
|9.2.2.2から9.2.2.4へ|他のプロセスが書き込んだ always_ff 、 always_comb または always_latch の変数 (警告のみ、MULTIDRIVEN )| `ch9/test_illegal_always_ff_other_writer`, `ch9/test_illegal_always_comb_other_writer`, `ch9/test_illegal_always_latch_other_writer`, `ch9/test_illegal_always_ff_written_via_function` |
| 9.2.2.4 |遅延あるいは第二イベント制御を持つ always_ff| `ch9/test_illegal_always_ff_delay`, `ch9/test_illegal_always_ff_two_event_controls` |
| 6.6.2 |二つのドライバを持つuwireネット| `ch6/test_illegal_uwire_two_drivers` |
| 6.5 |変数の重なり合うビットに連続的に代入，出力ポートで駆動され他に代入られた変数| `ch6/test_illegal_overlapping_continuous_assigns`, `ch6/test_illegal_output_port_variable_also_assigned` |
| 26.3 |2 つのワイルドカードインポートが提供する名前へのリファレンス| `ch26/test_illegal_wildcard_import_conflict` |
| 13.5.2 |静的タスクまたは関数の ref 引数| `ch13/test_illegal_ref_in_static_task`, `ch13/test_illegal_ref_in_static_function` |
| 13.4 |連続代入で呼び出された出力引数を持つ関数| `ch13/test_illegal_function_in_continuous_assign_output` |
| 30.4.1, 30.4.5 |出力ポートを始点とするモジュールパス、入力ポートを終点とするパス、または幅の異なるベクトル間の並列パス| `ch30/test_illegal_specify_path_from_output`, `ch30/test_illegal_specify_path_to_input`, `ch30/test_illegal_specify_parallel_width_mismatch` |
| 33.4.1.2, 33.4.1.4 |2 つのデフォルト liblist 項と、ライブラリと liblist を含む cell 項| `ch33/test_illegal_config_two_default_liblists`, `ch33/test_illegal_config_cell_library_liblist` |
| 6.7.1 |net 型キーワードに `reg` ( `wire reg` ) が直接続く| `ch6/test_illegal_net_type_then_reg` |
| 6.22.2, 6.22.3 |unpacked 構造型の変数間の代入は、異なる宣言からの二つの変数の間で行われます。これらは等価ではありません。| `ch6/test_illegal_anonymous_struct_not_equivalent` |
| 23.10.4.2 |generateブロックのエラボレーション後に、階層名が別のパラメータへ解決されるdefparam| `ch23/test_illegal_defparam_early_resolution` |
| 8.26.4 |型パラメータ、またはinterface classの前方typedefをimplementsするクラス| `ch8/test_illegal_class_implements_type_parameter`, `ch8/test_illegal_implements_forward_typedef` |
| 8.26.6.2 |typedef 名前を2つのインタフェースクラスから継承し、それを宣言しないインタフェイスクラス| `ch8/test_illegal_interface_class_typedef_conflict` |
| 16.12.22 |`\|=>`の前件は、決してマッチしないシーケンスである。| `ch16/test_illegal_nonoverlapping_antecedent_no_match` |
| 20.7.1 |キュー次元を名付ける次元番号を持つ `$size`| `ch20/test_illegal_array_query_variable_dimension` |
| 20.10.1 |エラボレーション時の`$error`を、警告USERERRORとして報告する。ランナーが渡す`-Wno-fatal`を指定すると、シミュレーションが開始する。| `ch20/test_illegal_elaboration_error_task` |
| 25.6, 30.7.4.2 |モジュールパスの端子としてのrefポート、およびそのパスの後のshowcancelled宣言（specifyブロックを無視する）| `ch25/test_illegal_specify_ref_port_terminal`, `ch30/test_illegal_showcancelled_after_path` |
| 28.3.4 |名前のないゲートインスタンスの配列| `ch28/test_illegal_unnamed_gate_array` |
| 3.14.2.2 |モジュールの他の項目より後のtimeunit宣言、および最初の宣言と一致しない再宣言| `ch3/test_illegal_timeunit_after_item`, `ch3/test_illegal_timeunit_mismatch` |
| 17.5, 17.7.1 |checker内の通常のalways手続き、always_ff内のブロッキング代入、およびinitial手続き内のchecker変数への代入。階層的な名前でチェッカー変数を割り当てるモジュール| `ch17/test_illegal_checker_plain_always`, `ch17/test_illegal_checker_always_ff_blocking`, `ch17/test_illegal_checker_variable_initial_assignment`, `ch17/test_illegal_checker_variable_hierarchical_write` |
| 18.5.9 |randと宣言していないプロパティを指定するsolve-before制約| `ch18/test_illegal_solve_before_state_variable` |
| 24.3, 24.5 |プログラムの変数を読み込むモジュールと、プログラムのタスクを呼び出すモジュール| `ch24/test_illegal_program_signal_from_module`, `ch24/test_illegal_module_calls_program_task` |
| 29.3.1, 29.3.4, 29.7 |ベクトル入力を持つUDP、同一入力に対して異なる出力を与える2つのエントリを持つUDPテーブル、およびUDPのinitial文内の遅延。| `ch29/test_illegal_udp_vector_port`, `ch29/test_illegal_udp_conflicting_entries`, `ch29/test_illegal_udp_initial_delay` |
| 31.4.4, 31.4.5, 31.4.6 |基準イベントにエッジがない`$width`と`$period`、notifierがありthresholdがない`$width`、およびエッジ制御指定子を持つ`$nochange`（specifyブロックを無視する）| `ch31/test_illegal_width_reference_not_edge`, `ch31/test_illegal_period_reference_not_edge`, `ch31/test_illegal_width_notifier_without_threshold`, `ch31/test_illegal_nochange_edge_control` |
| 33.4 |パッケージ名を他のパッケージに結びつけるセル文| `ch33/test_illegal_config_package_binding` |
| 7.4.1 |realとして定義した型に付けたpacked次元| `ch7/test_illegal_packed_array_of_real` |
| 9.2.2.2.2, 9.2.2.3 |always_comb内の遅延・イベント制御・fork-join、およびalways_latch内の遅延| `ch9/test_illegal_always_comb_delay`, `ch9/test_illegal_always_comb_event_control`, `ch9/test_illegal_always_comb_fork_join`, `ch9/test_illegal_always_latch_delay` |
| 8.19 |コンストラクタ内で、初期値を持つクラス定数への代入、およびstaticと宣言したインスタンス定数| `ch8/test_illegal_global_constant_assigned_in_constructor`, `ch8/test_illegal_static_instance_constant` |
| 6.19 |enum 値はベースタイプより狭いサイズリテラルとして与えられます。| `ch6/test_illegal_enum_sized_literal_width` |
| 12.8 |fork-joinブロック内から、そのブロックを囲むループを終了するbreak| `ch12/test_illegal_break_in_fork_to_outer_loop` |
| 26.3 |ワイルドカードインポートで既に表示された名前のローカル宣言| `ch26/test_illegal_local_declaration_after_import` |
| 8.20 |:finalとして宣言したpure virtualメソッド| `ch8/test_illegal_final_pure_virtual` |
| 35.5.1.3, 35.5.4 |pureとして宣言したインポートタスク| `ch35/test_illegal_dpi_pure_import_task` |

<a id="cases-added-by-the-2026-10-22-depth-extension"></a>

## 2026-10-22の深さ拡張によって追加された事例

これらのケースは、以前は直接引用するテストが1本だけだった節の検証を強化する。期待結果は、リリース版での実行より前に導出した。未対応構文はソースコメントに記載し、独立したオラクルによる確認として扱わない。次のような観察可能な差異が残っている。

- Icarus 13.0は、最後の要素のpop時にキューサイズを待つwaitを起床させない（7.10.2.7）：[test_queue_size_wait_after_pop](../tests/ch7/test_queue_size_wait_after_pop.sv)。
- Icarus 13.0は型付きコンストラクタで派生オブジェクトを生成しますが、基底ハンドル経由では基底クラスのvirtualメソッドを呼びます（8.8、8.20）：[test_typed_constructor_into_base_handle](../tests/ch8/test_typed_constructor_into_base_handle.sv)。
- Icarus 13.0は、`undefineall`後もソースマクロの定義を保持する（22.5.3）：[test_undefineall_clears_nested_macro_expansion](../tests/ch22/test_undefineall_clears_nested_macro_expansion.sv)。
- Icarus 13.0は、引数なしの`$stacktrace`呼出しに値引数を指定することを受理する（20.17.2）：[test_illegal_stacktrace_argument](../tests/ch20/test_illegal_stacktrace_argument.sv)。
- 両リリースとも、入力に反応するモジュールのNBAの処理が完了する前に、programの継続代入による出力を伝播します（24.3.2）：[test_program_output_after_module_nba_chain](../tests/ch24/test_program_output_after_module_nba_chain.sv)。
- 5.052版は、符号付き連想配列のキーを、ゼロをまたいで符号なしの値として並べます（7.8.4）：[test_assoc_signed_boundary_order](../tests/ch7/test_assoc_signed_boundary_order.sv)。
- 5.052リリースは、realメンバーを含む連想配列のキー型（7.8.5）を受理する：[test_illegal_assoc_real_member_key](../tests/ch7/test_illegal_assoc_real_member_key.sv)。
- 5.052リリースは、内側の文字列連結を1つの文字列項目として保持せず、2つのキュー要素に展開する（10.10.3）：[test_unpacked_concat_typed_array_and_string_item](../tests/ch10/test_unpacked_concat_typed_array_and_string_item.sv)。
- 5.052リリースでは、ブロック外メソッド定義で正当に省略した場合に、プロトタイプの既定値が失われる（8.24）：[test_extern_method_scoped_return_type](../tests/ch8/test_extern_method_scoped_return_type.sv)。
- 5.052版は、混在するイベント感度のプロセスを、その後の4回の入力変化だけでなく時刻0でも実行します（9.4.2.1、6.8）：[test_event_or_mixed_comma_forms](../tests/ch9/test_event_or_mixed_comma_forms.sv)。
- 5.052版は、実引数が定数である仮引数を参照するチェッカーのcovergroupを受理します（17.6）：[test_illegal_checker_covergroup_constant_actual](../tests/ch17/test_illegal_checker_covergroup_constant_actual.sv)。
- 5.052版は、文字を押し戻した状態からシークすると異なる位置を観測し、入出力操作の成功後もエラー文字列を消去しません（21.3.5、21.3.7）：[test_fseek_cancels_ungetc_and_clears_error](../tests/ch21/test_fseek_cancels_ungetc_and_clears_error.sv)。
- 5.052版は、NBA更新後のアサーション成功アクションで、生の参照に対してサンプル済みの値を出力します（4.4.2.5、16.5.1）：[test_preponed_sample_observed_before_action](../tests/ch4/test_preponed_sample_observed_before_action.sv)。
- Icarus 13.0では、LABELのアノテーションは利用できない。5.052版は、新たな依存ラベル式とパルス境界のケースも含め、SDFのアノテーションを無視します（32.4.3、32.7）：[test_sdf_label_recomputes_delay_expression](../tests/ch32/test_sdf_label_recomputes_delay_expression.sv)、[test_sdf_pulse_limit_near_delay_boundary](../tests/ch32/test_sdf_pulse_limit_near_delay_boundary.sv)。

<a id="cases-added-after-the-2026-10-23-expression-review"></a>

## 2026-10-23の式レビュー後に追加したケース

- IEEE 11.7、6.24.1、20.7：Icarus 13.0は、`ch11/test_signed_system_cast_shape_and_value`と`ch6/test_size_cast_intermediate_context`内のキャスト式への配列問合せをコンパイル中に、セグメンテーション違反で停止する。固定サイズの整数型の式に対する問合せは正当である。Verilator 5.052 は両方のテストに一致します。
- IEEE 11.3.5：Icarus 13.0は、禁止されたオペランドを評価し、`ch11/test_short_circuit_suppresses_fatal_operand`内の`$fatal`を実行する。選択されたオペランドは呼び出し，副作用，ランタイムエラーを必要としない。Verilator 5.052 は 5 つの呼び出しをすべてスキップし、期待される出力と一致させます。
- IEEE 11.3.1および6.12：`ch11/test_shortreal_result_and_condition_types`では、Icarus 13.0とVerilator 5.052がshortrealをrealとして保持・計算するため、shortrealの結果もrealの値になります（16777216.0 + 1では16777217.0、3とshortreal 0.1の積では0.3000000000）。期待出力には、規格のshortrealの結果を維持する。どちらのリリースも このテストのオラクルとして記録されていません2026-10-28までは、realとshortrealが持たない`$bits`で型を取得していました（6.24.3、20.6.2）。

新しい`ch11/test_real_boolean_results_without_shortreal`は、realの論理／関係／inside演算の1-bit結果を切り出して確認する。shortrealへの対応を必要とせず、Verilator 5.052と一致する。Icarus 13.0は`inside`を支持しないと拒否コンパイルの失敗は 実行の成功の証拠ではありません

<a id="cases-added-after-the-2026-10-23-associative-array-review"></a>

## 2026-10-23 連想配列レビュー後に追加されたケース

IEEE 1800-2023 から導かれた期待値を新しいケースは保持する。Verilator 5.052（2026-09-05、vUNKNOWN-built20260905）では、初期値のseed 1と73の両方で15ケース中8ケースが一致しました。以下の7つの違いが残っている。いずれも実行成功には数えない。

- IEEE 7.9.3–7.9.7：`ch7/test_assoc_method_expression_types`は、各メソッド式について`int`を報告すべきところ、`exists()`に対して`logic[31:0]`、first/last/next/prevに対して`integer`を報告します。`ch7/test_assoc_count_expression_types` は数/サイズタイプとカウントに対応します。
- IEEE 7.9.6：`ch7/test_assoc_traversal_gaps_and_preserved_keys`は、既存キー10と30の間の存在しないキーからの`next()`に対して、ステータス0を返し、キー20を変更しない。これは、1 を返し、キー 30 を返す必要がある。
- IEEE 7.8.7：連想配列の要素を実引数とする`ch7/test_assoc_ref_allocates_before_callee_write`は、「Function/task ref argument is not of allowed type」で拒否される。テストは、呼出し先が読取りや書込みを行う前に、割当てを観測する。サポートされていない呼び出しは 割り当てを証明しません
- IEEE 7.8.4：`ch7/test_assoc_signed_and_unsigned_key_order`は、符号付き8-bitのキー0を、-128より先に走査する。符号付きの順序は、-128、-1、0でなければならない。
- IEEE 7.8.4：`ch7/test_assoc_integral_index_cast_context`は、8-bitの添字キャストの文脈で、`4'hf + 4'h1`をキー16ではなくキー0として評価する。
- IEEE 7.8.6および表7-1：`ch7/test_assoc_missing_read_reports_diagnostic`は、存在しない`integer`要素から`xxxxxxxx`ではなく、初期化された既知のbitパターンを読み出します（例：seed 1で`f7df13e4`）。この出力不一致だけでは，別々の警告チェックを確立できない。
- IEEE 7.8.6:`ch7/test_assoc_invalid_write_reports_diagnostic`は X を含むキーに対して 2 番目のエントリを作成します書き込みは警告と共に無視され、元の単一エントリが残される。

Icarus Verilog 13.0安定版（v13_0-dirty）は、連想配列またはunpacked構造体の未対応により、全15ケースでコンパイルに失敗します。これらの実際のコンパイル試みは、通過ではなく、既知の差として記録される。

すべての入力、変異検査、結果スナップショット、カバレッジの変更は[テスト追加報告](associative-gap-tests-20261023.md)を参照。最初の15ケースの実行と、その後のワイルドカード・件数確認を改良した1ケースの実行は、別のスナップショットとして保存しています。部分的な成功を1回の実行に統合しない。

<a id="cases-added-by-the-2026-10-23-header-and-vpi-model-tests"></a>

## 2026-10-23のヘッダテストとVPIのモデルテストで追加したケース

規定のCヘッダ（附属書I、K、L、M）の新規テストは、シミュレータが提供するヘッダの定数、型、インクルードガード、宣言を、附属書の規定と比較する。標準と異なるものを定義するヘッダがあります:

- IEEE H.10.1.2、I.3：Verilator 5.052のsvdpi.hは、規格がintの`~(-1 << (N))`と定める`SV_MASK(N)`を、符号なしintの`~(0xffffffffU << (N))`として定義しています。設定する下位ビットは同じである。`ch35/test_svdpi_h_sv_mask`は、マクロのテキストと型に0を出力するため、`:oracle:`にはシミュレータを記録していない。

これらのテストが示す他の差異は、上記のとおり未対応機能として除外する。Icarus Verilog 13.0 ' sのvpi_user.hとsv_vpi_user.hは、K.2およびM.2の855個の定数のうち218個を、すべて附属書どおりの値で定義しています。一方、K.2とM.2の宣言の大半がないため、定数テストでは行が欠け、宣言テストはこれに対してコンパイルできません。どちらのリリースもvpi_compatibility.hを提供しない（Verilatorのvpi_user.hのコピーでは、そのinclude行がコメントアウトされている）。そのため、6件の`ch36/test_vpi_compatibility_h_*`テストではルーチン名が未対応付けとなる。節37の新しいVPIテスト24件（`ch37/test_vpi_*`を同日に追加）は、Icarus Verilog 13.0 ' sのヘッダにない定数と、vpi_register_systfで登録したシステムタスクを使います。これらのシステムタスクは、Verilator 5.052から呼び出せません。1件はIcarus Verilog 13.0と一致し、残りは`:oracle: spec`を持つ。

<a id="cases-added-by-the-2026-10-24-keyword-tests"></a>

## 2026-10-24キーワードテストによって追加された事例

`generators/keywords.py`の生成テストは、各予約語を、その語が予約されている版の`begin_keywords`領域内で変数名として宣言します。両方のリリースが、496の493を宣言位置で拒否する。

- IEEE 5.6、附属書B、22.14.7：Verilator 5.052は、`global`を予約する`begin_keywords "1800-2023"`と`begin_keywords "1800-2009"`の下でも、その語を変数名として受理します。`gen/ch5/test_gen_kw_2023_global` , `gen/ch22/test_gen_kw_1800_2009_global`
- IEEE 5.6、22.14.2：Verilator 5.052は、`ifnone`を予約語とする`begin_keywords "1364-1995"`でも、変数名として受理する。`gen/ch22/test_gen_kw_1364_1995_ifnone`
- IEEE 22.14: Icarus Verilog 13.0は、バージョン文字列"1800-2017"と"1800-2023"を認識せず、無視する旨を出力して既定のキーワード集合を維持する。一方、22.14は両方を標準のバージョンとして列挙し、認識できないバージョンをエラーとする。既定のキーワード集合では附属書Bのすべてのキーワードを予約するため、248 `gen/ch5/test_gen_kw_2023_*`のテストは引き続き一致する。

<a id="cases-added-by-the-2026-10-24-gap-tests"></a>

## 2026-10-24 ギャップテストによって追加されたケース

[結果報告](gap-tests-20261024.md)に示すオープン要求に対して書かれたテストは，テスト作成者が保持し，独立した評価者によって検証されたノートから得られた以下の違いを示した。また，リリースが拒否する構造，内部故障，ヘッダ定数の欠落，VPIの関係，Verilatorの2状態値を除外した。

<a id="icarus-verilog-130-results"></a>

### Icarus Verilog 13.0: 結果

|条項|何をするのか|テスト|
| --- | --- | --- |
|6.16 ( 6-9 表 )|`string s_b = "b"`を伴う`s_b < "ab"`は1を返す（`s_b > "ab"`も1を返す）。| `ch6/test_string_comparison_operators_and_literals` |
| 6.11.3, 6.8 |`integer unsigned u = '1;`は、-1を`%0d`で表示する。integerのunsignedキーワードが無視される。| `ch6/test_integer_types_state_and_signing` |
| 6.12, 6.13 |`1.0 + 2.0 ** -30`で初期化したshortrealは、値を倍精度で保持するため、1.0と等しくないと判定されます。ただし`$shortrealtobits`の結果は3f800000です。| `ch6/test_shortreal_ieee754_single` |
| 6.10, 23.2.2.1, 22.8 |`` `default_nettype wand ``の下で、ポート宣言だけを持つ非ANSIポート（`output [3:0] y;`）の暗黙ネットがwireになります。2つのドライバ1101と0110は、x1xxへ解決されます。（連続代入、ポート接続、ゲート端子から生じる暗黙netはwandとなる。`ch6/test_implicit_net_scope_and_lookup`は一致する。）| `ch6/test_implicit_port_expression_nets` |
| 6.16.10 |文字列配列の要素への`s[i].atoreal()`は、すべての要素に0.0を返す（`"2.5e3xyz"`、`"3.75"`、…）。空の要素は空白として出力される。| `ch6/test_string_atoreal_scan_rules` |
| 6.19, 6.24.1 |`bit [4:0]` enumのenum値式`4'hf + 4'h1`を、5-bit基底型へのキャストの文脈（Q = 16、R = 17）ではなく、オペランドの4-bit幅（Q = 0、R = 1）で評価します。| `ch6/test_enum_encoding_cast_to_base` |
| 6.16, 6.20 |NUL文字（`"\0"`）を含むリテラルで初期化した`parameter string S`はそれらを保持する：`S.len()`は3の代わりに7であり、NUL文字を含む文字列の長さは削除される。| `ch6/test_param_literal_initializers_follow_type` |
| 7.3.1, 6.11.2 |4状態メンバも持つpacked共用体の2状態メンバ`bit [7:0] b2`を読み出すと、格納されたx/zビットが0へ変換されず（`10001001`、0、`10001010`）、そのまま返ります（`b2=1x0z10x1`、`$isunknown(m.b2)=1`、`b2+1=xxxxxxxx`）。b2の初回読取りも、`00000000`ではなく`xxxxxxxx`となる。| `ch7/test_packed_union_mixed_two_four_state` |
| 7.4.4 |`typedef tri_t row_t [0:3]; row_t tab [0:1];`では、typedefのunpacked次元が最も遅く変化する次元となり（`$size(tab,1)=4`、`$size(tab,2)=2`、`tab[1][2]`で範囲外と報告）、部分配列への代入`one_row = tab[1]`が拒否される。typedefによる次元は宣言側の次元より速く変化するため、tabは[0:1][0:3]になります。| `ch7/test_multidim_typedef_stages_and_shared_declaration` |
| 7.10.1 |境界が変数であるキュースライス`q[a:b]`は、すべての境界の組に対してキュー全体`size=5: 10 20 30 40 50`を返す。| `ch7/test_queue_slice_bounds_clip_and_empty` |
| 11.4.7, 11.3.5 |最初のオペランドが偽でも`->`の第2オペランドを評価する。`lhs(1'b0) -> rhs(1'b0)`がrhsを呼び出す（`nr=1`）。`&&`と `->` に対して，論理的に偽の第一オペランドは第二オペランドを評価しないことを意味する。| `ch11/test_logical_operands_evaluated_once_and_unknown_left` |
| 11.4.1, 11.4.10 |-16を格納した`int arr[4]`の要素に対する`arr[k] >>>= 2`は、ゼロを補ってシフトした1073741820になります。一方、int変数に対する`x >>>= 2`と`arr[1] = arr[1] >>> 2`は、-4になります。複合代入の意味は、二項演算子を使うブロッキング代入と同じです。また、符号付きオペランドの\>\>\>は、符号bitで埋めます。| `ch11/test_compound_assignment_index_evaluated_once` |
| 11.5.1 |2状態の`bit [7:0] b`に対するbit選択は、範囲外の添字（`b[i8]`、i8 = 8）またはxの添字でxを読み出します。また、全範囲が範囲外となる`q4 = b[i9 +: 4]`では、2状態の`bit [3:0] q4`にxが残ります（`xxxx`）。2状態値の不正な選択で、0を読み取る。|`ch11/test_vector_select_declared_bounds_direction_and_invalid` ;不正なbit型の`gen/ch11/test_gen_cross_index_*`のケース18件|
| 26.3 |`import lp::*;`より前に記述した`localparam int k_first = k;`は、import後に`k`を再度参照すると`lp::k`を返す（5）。後続の参照がない場合は、コンパイル単位の`k`（100）になります。参照より前のワイルドカード候補だけを使えるため、100でなければならない。| `ch26/test_package_lookup_reference_point` |
| 28.6 |また，StXを示す対照とデータ0または1を用いたnotif0とnotif1の図を示した。表28-5は、StHとStLで表示するH（データ0）とL（データ1）を規定しています。| `ch28/test_notif_gate_truth_table_all_inputs` |
| 28.7, 28.14 |ネットの唯一のドライバであるrnmosとrpmosが、出力をstrongの強度（St0、St1、StX）で表示し、表28-6がLまたはHと定める箇所でもStXを表示します。規格では、strongのデータをpullへ低下させる必要がある（Pu0、Pu1、PuX、PuL、PuH）。netに2つ目のzドライバがある場合、rnmosは正しい値を示すがrpmosは依然として正しくない。nmosとpmosは一致する。| `ch28/test_mos_switch_truth_tables` |
| 28.9, 28.14 |rcmosがstrongのデータをstrongのまま伝播します（St0、St1）。28.14ではpullへの低下が必要で、同じネットに接続したrnmos/rpmos対ではその結果になります。既知のrcmosの差異を、その対と比較しています。| `ch28/test_rcmos_switch_rnmos_rpmos_equivalence` |
| 28.8 |2つの遅延（d1、d2）を持つtranif0が、制御が1へ立ち上がりスイッチがオフになるとd1を、0へ立ち下がりオンになるとd2を使います。28.8は最初の遅延をターンオン遅延とし，次の遅延をターンのオフ遅延とする。tranif1は一致する（tests/ch28/test_pass_switch_control_delay_forms.sv）。| `ch28/test_tranif0_control_turn_on_off_delays` |
| 28.12.4 |強度が曖昧なドライバを持つwandとworで、650、65X、56X、56Xではなく、St0、St1、St0、StXになります。wiredネットで駆動強度を無視する既知の差異です。| `ch28/test_wired_logic_ambiguous_strength_combinations` |
| 30.5.1 |負のモジュールパス遅延（-3のspecparam、または1-6）がゼロとして扱われず、遅延なしで生じるべき出力変化が実行中に一度も現れない。| `ch30/test_specify_negative_path_delay` |
| 30.7.4.2 |showcancelledとpulsestyle_ondetectを無視します。負パルスにより、on-eventなら15、on-detectなら12から17までxになるべきところ、出力が1に留まります。| `ch30/test_showcancelled_negative_pulse_x` |
| 32.3 |対応するモジュールパスのないIOPATHエントリを、警告ではなく"SDF ERROR: Unable to match ModPath"として報告する。他のエントリに注釈を付けます| `ch32/test_sdf_unannotatable_entry_warning` |
| 36.5, 36.8.1 |sizetfが12を返すvpiSizedFuncは、32ビットを返す（"function result: 00000f01"）。Icarus はコンパイル時の.sft ファイルから幅を取りますが sizetf ではありません。他のすべての行は一致します。| `ch36/test_vpi_systf_task_function_places` |
| 37.39 |パス端子のvpi_get（vpiDirection）がvpiInput/vpiOutput以外の値を返し、vpi_handle（vpiModPath、path_term）がNULLを返します。パスのvpiModuleと、パスのvpi_get_delays／vpi_put_delaysは一致する。| `ch37/test_vpi_mod_path_relations_delays` |
| 37.41, 13.4 |関数に対するvpiFuncTypeが、integerではvpiSizedFunc、timeではvpiSizedSignedFuncを返します。37.41は、それらの値を規定していません。| `ch37/test_vpi_function_decl_type_range` |
| 38.3 |vpi_compare_objectsは、同じハンドルにだけ1を返す（jが範囲外のmem[j]も含む）。同じ要素への異なるハンドルには0を返す。例えば、j == kでのmem[j]とmem[k]、およびmem[j]とvpi_handle_by_index(mem, 0)である。| `ch38/test_vpi_compare_objects_current_object` |
| 38.15, K.2 |vpi_user.hは、s_vpi_vecvalのavalとbvalをPLI_UINT32ではなくPLI_INT32として宣言する（図38-8）。| `ch38/test_vpi_value_time_delay_structures` |
| 38.34 |vpiInertialDelayとvpiTransportDelayが予約済みイベントを除去せず、3モードすべてがvpiPureTransportDelayと同じ動作になります。| `ch38/test_vpi_put_value_delay_modes_queue` |
| 38.19 |vpi_handle_by_index（スカラー、0）はハンドルs[0]を返す。しかし、スカラーのbit選択は不正（11.5.1）であり、38.19はNULLを要求する。VPI モデルは、非使用変数も除外する。| `ch38/test_vpi_handle_by_name_scope_index` |
| 38.27, 38.25 |vpi_mcd_openまたは$fopenで開いているファイルにvpi_mcd_openを行うと、既存の記述子ではなく新しい記述子を返す。ファイルを開いていないチャネルに対するvpi_mcd_flushが0を返します。内部ではfflush(NULL)を呼びます。| `ch38/test_vpi_mcd_open_reuse` |

<a id="icarus-verilog-130-illegal-designs-that-it-accepts"></a>

### Icarus Verilog 13.0：受け入れる違法デザイン

|条項|何をするのか|テスト|
| --- | --- | --- |
| 6.21 |動的配列の要素へのノンブロッキング代入`da[1] <= 2;`を受理する。| `ch6/test_illegal_nonblocking_to_dynamic_array_element` |
| 7.4.1 |単一のサイズで指定したpacked次元`bit [8] octet;`を、エラーなしで受理する。packed次元には、`[ constant_expression : constant_expression ]`の範囲が必要である。| `ch7/test_illegal_packed_dimension_single_size` |
| 8.17 |拡張条件が既に構造子引数を与えているサブクラス（`extends base_c(5)`）において，明示的な `super.new(3)` を受け入れる。| `ch8/test_illegal_super_new_with_extends_arguments` |
| 29.7 |出力regではなく入力に代入するUDPのinitial文を受理する。| `ch29/test_illegal_udp_initial_assigns_input` |
| 30.4.2, 30.4.5, 30.4.6 |始点のリスト`(a, b => y)`または終点のリスト`(b => y, z)`を持つ並列モジュールパスを受理する。構文30-3では、並列接続の入力端子と出力端子は1つずつであり、30.4.5/30.4.6は、複数の始点または終点には完全接続を要求する。Verilator 5.052 も受け入れます。specifyパスを検査しない。）| `ch30/test_illegal_specify_parallel_multiple_sources`, `ch30/test_illegal_specify_parallel_multiple_destinations` |

<a id="verilator-5052-results"></a>

### Verilator 5.052: 結果

|条項|何をするのか|テスト|
| --- | --- | --- |
| 6.16.3 |`getc()`に、プロトタイプの符号付き`byte`（`byte`、-23）ではなく、符号なし型`bit[7:0]`を与える。`$typename`は`bit[7:0]`を出力し、文字8'he9に対する`s.getc(64'h1_0000_0002)`は233を出力する。| `ch6/test_string_getc_index_rules` |
| 6.16.9 |atoi／atohex／atooctは、Cのstrtolと同様に、先頭の空白をスキップして符号を解析する。`" 12".atoi()=12`、`"-12".atoi()=-12`、`"+12".atoi()=12`、`"-ff".atohex()=-255`、`"-7".atooct()=-7`。走査は先頭の数字とアンダースコアだけを取り込み、符号を解析しないため、これらはすべて0となる。| `ch6/test_string_ato_integer_scan_rules` |
| 6.19.5.3, 6.19.5.4 |列挙型のメンバでない値（{A = 1、B = 2、C = 3}に対する`t_t'(7)`）について、next()はA、prev()はB、next(2)はBを返します。また、logic [2:0] enumの`l_t'(3'd6)`に対し、next()とprev()はPを返します（001）。規格ではenumの既定初期値を返す。intの基底型では0、logicの基底型ではxxxとなる。（既定値0自体に対しては、prev()は0を返す。）| `ch6/test_enum_next_prev_from_non_member` |
| 6.19.5.5, 20.6.1 |`$typename(c.num())`は、num()プロトタイプの戻り値の型`int`ではなく`bit[31:0]`を出力する（値3と符号付き比較`c.num() - 5 < 0`は正しい）。| `ch6/test_enum_num_name_result_types` |
| 6.22.1 f, 7.4.2 |`int fa [0:3]`と`int fd [4]`に対する`type(fa) == type(fd)`は、0を返す。`[4]`が範囲[0:3]を宣言するため（7.4.2）、固定長配列の範囲と対応要素は同じになり、一致します（1）。| `ch6/test_type_matching_rules_by_type_compare` |
| 6.24.1, 20.6.1 |`bit [3:0] b`に対する`$typename(signed'(b))`と、`bit signed [3:0] bs`に対する`$typename(unsigned'(bs))`が、`logic[3:0]`になります。2状態オペランドの符号キャストが4状態ベクタになるため、本来その要素はbitです。サイズキャスト`8'(b)`は、規定どおり`bit[7:0]`になります。その`$typename`では、`signed`も欠落する（`$typename(bit signed [3:0])`は`bit[3:0]`）。Icarus Verilog 13.0 はデータ型の `$typename` を持たない。| `ch6/test_cast_size_sign_keep_state_domain` |
| 20.5, 6.24.1 |`$shortrealtobits`は32 - bit単一精度パターン（`c0200000` , `40580000`）の代わりに，64 - bit倍精度パターンを返す（-2.5に対して`$shortrealtobits(n)`印刷，`c004000000000000`に対して32 - bit変数割り当て，`$shortrealtobits(3.375)`に対して0を返す）。| `ch6/test_cast_shortreal_round_vs_bit_pattern` |
| 7.4.1, 6.22.1 e, 6.23 |幅が定義済みのinteger型と、対応するベクタ型との型参照の比較が、0になります（`type(byte) == type(bit signed [7:0])`。そのベクタのtypedefでも同様で、shortint、int、longint、integer、timeでも同様）。一方、`type(int) == type(int)`では1になります。規格ではこれらは合致する型であるため、比較結果は1となる。| `ch7/test_integer_atom_types_match_vector_types` |
|7.4.5 7-1 表|real、shortreal、string、class、interface class、virtual interfaceの要素を持つ固定unpacked配列を、範囲外の添字（[0:3]に対する7）またはxを含む添字bitで読むと、0.0、""、nullではなく、保存済みの要素の値（1.5、2.5、"full"、nullではないハンドル）が返されます。また、C++ビルドはイベント配列要素 (`cannot convert 'VlEvent' to 'IData'`) の reads/ `== null` 比較に失敗します。| `ch7/test_array_invalid_index_read_handles_real_string` |
|7.4.5 7-1 表|キュー、動的配列、連想配列、固定長配列、unpacked構造体、unpacked共用体を要素とする`[0:1]`配列を添字5または2'bx0で読み出すと、空配列、'x/'0の配列、メンバの既定値を持つ構造体（初期代入c = 9を含む）、共用体の先頭メンバの'xではなく、格納済みの要素（サイズ2/3/1、1,2,3、格納済みの構造体と共用体）を返します。| `ch7/test_array_invalid_index_read_aggregates` |
|7.4.5 7-1 表|C側で要素を非nullポインタに設定した`chandle ch [0:3]`を、添字7または2'b1xで読み出すと、nullではなく非nullのchandle（`null=0`）を返します。| `ch7/test_array_invalid_index_read_chandle` |
| 7.5.1, 13.5.2 |`d = new[3](d)`によって、タスクの`d[1]`への`ref int r`が古くなった後、タスク内の後続の書込み`r = 99`は、古い要素`5 6 7`だけでなく新しい配列`t=4: 5 99 7`を変更する。| `ch7/test_dynamic_array_new_discards_data_and_references` |
| 7.10.1 |q = {10,20,30,40,50}の場合、`q[5:5]`は`{}`ではなく`{50}`を返し、`q[-1:-1]`は`{}`ではなくキュー全体を返し、`q[1:3'b0z1]`は`{}`ではなく1要素を返す（zのbitを含む境界）。範囲内，クリップ，逆スライスは正しい。| `ch7/test_queue_slice_bounds_clip_and_empty` |
| 7.10.5 |満杯の`int bq[$:2]`への`insert(1, 9)`は、添字2を超えて押し出される要素を捨てず（`0 9 1`）、4要素に増やす（`0 9 1 2`）。push_back、push_front、および[$+1]への書込みでは、境界が正しく扱われる。| `ch7/test_bounded_queue_methods_discard_beyond_bound` |
| 7.10.5 |5要素の上限なしキューを`int bq[$:2]`へ代入すると、3要素`20 21 22`ではなく2要素`20 21`を保持する。連結代入は正しく境界付けられています。| `ch7/test_bounded_queue_assign_discards_beyond_bound` |
| 7.12.1, 7.8.4 |`int dn [4:1] = '{7,0,9,5}`では、find_first/find_first_indexが0で5、find_last/find_last_indexが3で7になります。期待値は、4で7、1で5です。`up [1:4]`の添字は0と3となる（期待値は1と4）。キー-5、0、3、10を持つ`int aa[int]`で、find_first/find_lastがfirst()/last()の順序（-5で6、10で4）ではなく、符号なしのキー順（3で8、-5で6）に従います。| `ch7/test_array_locator_first_last_by_range_and_min_tie` |
| 7.12.2 |`int b[$] = '{3, -1, 2}`に対するwith句のない`sort()`と`rsort()`が、符号付きintの関係演算子に従う順序（`-1 2 3`、`3 2 -1`）ではなく、符号なしの順序（`2 3 -1`、`-1 3 2`）で要素を並べます。with節を付けた場合、および文字列と構造体では、結果は正しい。| `ch7/test_array_ordering_methods_with_and_iterator` |
| 7.12.3 |リダクション結果の幅が、要素型またはwith式に従いません。`$bits(b.sum(v) with (int'(v)))`は8（期待値32）、{8'h0f、8'h0e}に対する`lo.sum with (item[3:0])`は`$bits` 8で29（期待値13、4）、`bit ba[4] = '{1,1,1,0}`に対する`ba.sum()`は3（期待値は1-bitの結果1）になります。int '() の和の値は正しい。| `ch7/test_array_reduction_result_type_and_with_width` |
| 8.23 |独自の非virtual `f`を宣言した派生クラスで、`base_c::f()`の呼出しがbase_cのメソッド（和124）ではなく、派生側の`f`（和224）を実行します。`base_c::pv` , `base_c::pub`と`base_c::ps`は正しくベースメンバを選択した。| `ch8/test_class_scope_base_members_from_derived` |
| 11.4.6 |異なるオブジェクトを指す2つのハンドル（interface classのハンドル`i1 !=? i3`、通常のclass `b1 !=? b2`でも同様）および異なる2つのchandle（`c1 !=? c2`）の`!=?`が、0になります。class、interface class、chandleのオペランドでは、ワイルドカード演算子は==と!=と同じasであるため、結果は1となる。| `ch11/test_equality_class_interface_chandle_handles` |
| 11.4.12.1 |繰り返し回数がゼロの複製ではオペランドを評価しません。Z = 0の`{{Z{next()}}, 4'hf}`でも、呼出し回数は0のままです。複製のオペランドは、繰り返し回数がゼロでも、厳密に1回評価します。| `ch11/test_concatenation_pattern_string_operand_and_replication_once` |
| 11.2.1, 20.4.1, 20.5 |localparam内の`$shortrealtobits(0.5)`は00000000を返し、同じ位置の`$bitstoshortreal`は0.0を返す。| `ch11/test_constant_system_function_calls_at_elaboration` |
| 20.2 |`$finish(0)`の後も呼出し元の手続きが続行し、実行終了前に`10: after $finish`を出力する。| `ch20/test_finish_ends_simulation` |
| 20.2, 24.7 |最初のprogramからの`$exit()`は、呼出し元の手続きの残りを実行した後（`5: p_first after $exit`）、シミュレーション全体を直ちに終了する（5）。| `ch20/test_exit_waits_for_programs` |
|19.5 19.5.2 19.7 (`ch19/test_cg_at_least` には既にリストされています)|`at_least`が無視され、各ビンは最初のヒットでカバー済みとなる（`value bin after 0, 1, 2: 100`）。| `ch19/test_cg_bin_hit_counts` |
| 27.5, 23.3.1 |`--top-module`を指定しないと、条件generate内で自分自身からしかインスタンス化されないモジュール`self_only`を、トップレベルのモジュールとしてエラボレーションし、そのinitial手続きを実行します（"self_only elaborated with D=2"）。自身のインスタンスを含むモジュールは、トップレベルモジュールではない。| `ch27/test_generate_recursive_module` |
| 26.6 |`import xt_base::w;`より前に`export xt_base::*;`を書いたpackageでは、`w`が可視になりません。`xt_early::w`をimportしたモジュールは、`xt_base::w`（2）ではなく、コンパイル単位の`w`（200）を取得します。exportは対応するimportより前に置ける。| `ch26/test_package_export_transitivity` |
| 26.6 |`export p::*`は、packageが一度も参照していないワイルドカードimportの候補もexportします。コンパイル単位で名前解決すべき箇所（500、700）で、`xw_pkgwild`経由では`xw_base::b`（2）、`xw_list`経由では`xw_other::c`（3）になります。| `ch26/test_package_export_wildcard_forms` |
| 26.5, 26.3 |`import so_e::*;`に続いて`import so_i::c;`があるモジュールで、非修飾の`c`がワイルドカードの候補`so_e::c`（4）を参照します。明示importを優先しなければならない（7）。| `ch26/test_package_search_order_cases` |
| 26.3 |局所の`z`の宣言より前にある`z`への参照が、コンパイル単位の`z`（300）ではなく、後方の局所宣言（30）へ結合します。また、ワイルドカードimportより前の`k`への参照も、`lp::k`（5）へ結合します。| `ch26/test_package_lookup_reference_point` |
| 29.5 |表の行`1 1 : 0 : 1`と`1 1 : 1 : 0`が現在状態に応じて次状態を選ぶレベルセンシティブな逐次UDPで、状態0からsが立ち上がり入力が1 1になると、1ではなく0になります。その箇所では現在状態の欄を使っていません。| `ch29/test_udp_level_sequential_next_state_by_current` |
| 29.8 |UDPインスタンスの遅延（`u_and2 #3`、`u_buf #(2, 4)`）を無視し、出力が直ちに変わる（逐次UDPについては上に記載）。ここでは組合せUDPについても記載）。| `ch29/test_udp_instance_delay_name_and_terminal_forms` |
| 36.10.1, 38.36.2 |時刻型vpiSuppressTimeによるcbAfterDelayの登録を受理します。38.36.2はエラーと定めていますが、vpi_chk_errorは0を返し、cbPLIErrorコールバックも発生しません。| `ch36/test_vpi_chk_error_pli_error_callback` |
| 38.36.2 |cbNextSimTimeコールバックのcb_data-\>timeには、現在のシミュレーション時刻30ではなく、登録時の要求の時刻フィールド2が渡される。| `ch38/test_vpi_time_callbacks_without_events` |
| 38.21, 38.36.2 |vpi_handle_by_nameは、空モジュールのインスタンスu_subにNULLを返す。また、vpi_register_cbはvpiScaledRealTimeを無視する（high／lowを遅延として読む）。| `ch38/test_vpi_time_callback_scaled_real` |
| 38.4, 20.2 |vpi_control（vpiFinish、0）は、ルーチンの実行中に'- :0: Verilog $finish'を出力します。ファイル名が空のためランナーはバナーとして除去しません。一方、$finish（0）は何も出力しません。| `ch38/test_vpi_control_finish_on_return` |
| 38.11 |vpi_get_str(vpiName)は、後で別のオブジェクトにvpi_get_strを呼び出しても変化しない文字列へのポインタを返す。すべての呼出しで共有する単一の一時バッファではない。| `ch38/test_vpi_string_buffers` |
| 38.34 |vpi_put_value は各遅延モードの遅延を無視し、一度に値を設定します。最後に入力したものが勝ちです。| `ch38/test_vpi_put_value_delay_modes_queue` |
| 38.34 |連続代入で駆動されるnetへのvpi_put_valueに、観測できる効果がない（netはドライバの値10を保持する）。| `ch38/test_vpi_put_value_net_deposit` |
| 38.34 |命名されたイベントに対する vpi_put_value は、これをトリガーしません。| `ch38/test_vpi_put_value_event_vector_scaled` |

<a id="verilator-5052-illegal-designs-that-it-accepts"></a>

### Verilator 5.052：受け入れる違法デザイン

|条項|何をするのか|テスト|
| --- | --- | --- |
| 6.5 |モジュール変数の宣言より前の行で、その変数への手続き的な書込みを受理する。| `ch6/test_illegal_variable_used_before_declaration` |
| 6.5, 23.3.3 |インスタンスのinoutポートへの変数接続を受理する。| `ch6/test_illegal_variable_actual_on_inout_port` |
| 6.5, 23.2.2.3 |`inout var logic p` を受け入れます。| `ch6/test_illegal_inout_port_declared_as_variable` |
| 6.5, 11.5.3 |`assign v[0] = ...`と`initial v[i] = ...`を同時に受理する（iは変数）。| `ch6/test_illegal_variable_index_prefix_mixed_writers` |
| 6.6.2 |uwireベクトルのbit 1を共有する2つの連続代入を受理する。| `ch6/test_illegal_uwire_overlapping_bit_drivers` |
| 6.12, 11.3.1 |実数の`r`を伴う`r & 1`と`r << 1`を受理する（警告のみ）。| `ch6/test_illegal_real_operand_bitwise_and`, `ch6/test_illegal_real_operand_shift` |
| 6.19 |階層名（インスタンスのlocalparamである`A = u.BASE`）を使うenumのname値を受理し、Aに4を与える。enum 値には階層的な名前は許可されていません。| `ch6/test_illegal_enum_value_hierarchical_name` |
| 6.19 |`enum logic signed [3:0] {LO = -7, HI = 8}`を受理し、HIを-8に切り捨てる。8は、符号付き4-bitの基底型の範囲外となり、エラーである。切り捨てるビット0が符号bit 1と異なるためである。| `ch6/test_illegal_enum_signed_value_out_of_range` |
| 6.21 |宣言`int count;`より前の行にある`initial count = 5;`を受理する。変数宣言は、その変数への単純名による参照より前になければならない。| `ch6/test_illegal_variable_referenced_before_declaration` |
| 6.21 |static task内とinitialブロック内で、初期化式を持ちながらstaticキーワードを付けていないstatic変数宣言を受理する。| `ch6/test_illegal_static_task_variable_initializer_no_keyword`, `ch6/test_illegal_initial_block_variable_initializer_no_keyword` |
| 6.21 |手続きブロックの外でクラスオブジェクトのメンバーを読む`assign w = h.value;`を受理する。| `ch6/test_illegal_continuous_assign_reads_class_member` |
| 6.21 |自動タスクの変数に `force av = 1;` を受け入れる。| `ch6/test_illegal_force_automatic_variable` |
| 7.12.3, 11.4.8 |with式のreal型にはand()のビット単位ANDが定義されていないにもかかわらず、int配列への`a.and with (real'(item))`を受理する。| `ch7/test_illegal_reduction_and_with_real_expression` |
| 8.19 |構成子の中で、インスタンス定数 (`const int k;` ) に二番目の代入を受け入れる。| `ch8/test_illegal_instance_constant_assigned_twice` |
| 8.19 |構成子に割り当てられた `const static int limit;`（静的に宣言されたインスタンス定数）を受け入れる。| `ch8/test_illegal_const_static_instance_constant` |
| 11.5.1 |`v[0:3]`を `logic [7:0] v`に受け入れ、設計を実行します。非インデックス形式の部分選択の最初の式は、2番目の式より上位のbitを指定しなければならないため、この設計は不正である。| `ch11/test_illegal_part_select_reversed_bounds` |
| 19.5.2 |`bins others[] = default sequence;` を受け入れます。| `ch19/test_illegal_cg_default_sequence_array` |
| 19.8.1 |`w`がオーバーライドしたsampleメソッドの仮引数である場合に、`option.weight = w;`を受理する。| `ch19/test_illegal_cg_sample_arg_in_option` |
| 28.3.5 |2つの範囲で2回宣言したゲートインスタンス配列名（`t_nand[0:1] (...), t_nand[2:3] (...)`）を、エラーなしで受理する。1つのインスタンス名には 1つの範囲しかありません。| `ch28/test_illegal_gate_array_split_range` |
| 26.3 |同じソースファイルに後で宣言されたパッケージをインポートするモジュールを受け入れます。packageは、importするスコープより先にコンパイルしなければならない。| `ch26/test_illegal_package_imported_before_compiled` |
| 26.3 |1つのスコープ内で2つの異なるパッケージからの`width`の明示的なインポートを受け入れる。| `ch26/test_illegal_package_explicit_import_two_packages` |
| 26.3 |これは、`width` を `width` を宣言するスコープに明示的にインポートすることを許可します。| `ch26/test_illegal_package_explicit_import_local_name` |
| 24.3, 3.14.2.2 |プログラムの最初のものと一致しない後の時間単位を受け入れ、プログラム項目の間で何も繰り返さない時間精度を受け入れます。| `ch24/test_illegal_program_timeunit_mismatch`, `ch24/test_illegal_program_timeprecision_after_item` |
| 29.3.6 |29.3.6が逐次UDPの出力欄だけに許可する`-`を、組合せUDPの表でも受理します。Icarus Verilog 13.0 は内部アサーションで停止する。| `ch29/test_illegal_udp_hyphen_combinational` |
| 29.7 |2つの代入を持つbegin-endブロックを、UDPのinitial文として受理する。| `ch29/test_illegal_udp_initial_block` |
| 35.5.4 |ref仮引数を持つimport宣言を受理する（C関数がないため、リンク段階だけが失敗する）。| `ch35/test_illegal_dpi_import_ref_formal` |
|35.5.4 (25 の脚注)|モジュールに `import "DPI-C" function :initial int c_f();` を受け入れる。| `ch35/test_illegal_dpi_import_override_specifier` |
| 35.5.2 |output引数を持つpureインポート関数を受理する。| `ch35/test_illegal_dpi_pure_function_output` |

<a id="both-releases-results"></a>

### 両リリースとも結果

|条項|何をするのか|テスト|
| --- | --- | --- |
| 26.3 |`import lv::y;`より前に書いた`y`への参照が、コンパイル単位の`y`（400）ではなく、`lv::y`（7）になります。明示importで名前が局所的に可視になるのは、そのimportより後だけです。Verilatorも、`w_first`を後方の局所`w`へ結合します（300ではなく30）。| `ch26/test_package_local_visibility` |

<a id="both-releases-illegal-designs-that-it-accepts"></a>

### 両方のリリース：受理される規格違反の設計

|条項|何をするのか|テスト|
| --- | --- | --- |
| 6.12, 11.3.1 |実数の`r`を伴う`r % 2.0`を受理する（Verilatorでは警告のみ）。| `ch6/test_illegal_real_operand_modulus` |
| 6.20.5 |両方とも、宣言より前の行にあるモジュール本体のspecparamへの参照（initialブロック内の`$display("%0d", tHold)`）を受理し、5を出力する。specifyブロックの外に宣言するspecparamは、参照する前に宣言しなければならない。| `ch6/test_illegal_specparam_used_before_declaration` |
| 6.21 |両方とも、動的配列の要素を読む連続代入`assign w = da[0];`を受理する。そのような参照は手続きブロックに限られています| `ch6/test_illegal_continuous_assign_reads_dynamic_element` |
| 27.4, 27.6 |両方とも、モジュールから名前なしのループgenerateブロックへの階層参照`genblk1[1].x`を受理する。そのような宣言は、そのブロックの階層内からだけ参照できる。genblk \<n\>は、外部インターフェース専用の名前である。| `ch27/test_illegal_generate_unnamed_loop_block_reference` |
| 29.3.4 |入力がすべてx、出力がx以外の組合せUDPエントリ`x x : 1;`を受理する（29.3.4はxを要求する）。| `ch29/test_illegal_udp_all_x_entry_not_x` |
| 29.3.6 |逐次UDPエントリの現在状態フィールドで、値の変化01を受理する。29-1 テーブルは (vw) を入力フィールドにのみ許可します。| `ch29/test_illegal_udp_value_change_in_state_field` |
| 29.7, 29.3 |UDP内の`initial q = 2;`を受理する。init_valは、1'b0、1'b1、1'bx（およびそれらの大文字表記）、1、0だけを許す。| `ch29/test_illegal_udp_initial_value_two` |
| 30.4.1 |`input var logic a` で宣言された入力ポート (変数) がソースのモジュールパスを受け入れます。30.4.1 はソースがネットであることを必要とします。| `ch30/test_illegal_specify_path_source_variable_port` |
| 33.4.1.1 |両方とも、設計命令が別のコンフィグを名付けたコンフィグを受け入れる。Icarus は config 宣言をスキップします。| `ch33/test_illegal_config_design_is_config` |

<a id="cases-added-by-the-2026-10-24-gap-tests-second-run"></a>

## 2026-10-24ギャップテストによる追加事例，第2回

未解決の要求に対するテストの2回目の実行（その[結果報告](gap-tests-2-20261024.md)を参照）では、以下の差異が見られた。これらも、作成者のメモから抽出し、独立したレビュー担当者が確認したものである。テストのほとんどは違法な設計であり，そのため，ほとんどの行はリリースが受け入れる設計である。上記と同じく、そのリリースが拒否する構文や未対応構文、別の理由による拒否、内部エラー、ヘッダー定数の欠落、Verilatorの2状態値は対象外です。

<a id="icarus-verilog-130-results-second-run"></a>

### Icarus Verilog 13.0: 結果 (2回目の実行)

|条項|何をするのか|テスト|
| --- | --- | --- |
| 6.16 |k = 32'h0000_4142でのString'(k)は、2つのゼロバイトを保持する（ABの前に空白を2つ出力する）。6.16は"\0"文字を削除し、"AB"となる。| `ch6/test_illegal_string_assigned_int_without_cast` |
| 8.14, 8.20 |派生オブジェクトを保持する基底クラスのハンドル経由でvirtualメソッドを呼ぶと、基底側が実行されます（b.virt_get()は54ではなく12を返します）。これはtest_typed_constructor_into_base_handleの 既存の差異と同じです| `ch8/test_base_handle_redeclared_members_and_virtual_dispatch` |
| 16.3 |即時`cover`文をスキップする。式は評価されず、式中の関数も一度も呼び出されず、式が真でも成功文は実行されない。| `ch16/test_immediate_cover_pass_statement` |
| 24.2, 4.4 |moduleと同時に起床するprogramのinitialを、moduleのActive領域の文より前、かつNBAの更新より前に実行する（b = 0を先に出力する）。| `ch24/test_program_reactive_region_after_nba` |
| 28.5 |入力が定数1'bzまたは未駆動ネットであるbufやnotの出力が、zになります。28-4 テーブルは x を返します（z を入力として持つ変数は x を返し、テストはそれを使用します）。| `ch3/test_builtin_primitive_categories` |
| 38.37 |vpi_user.hは、t_vpi_systf_dataのtfnameフィールドをPLI_BYTE8*ではなくconst char*として宣言する。| `ch38/test_vpi_systf_data_structure` |

<a id="icarus-verilog-130-illegal-designs-that-it-accepts-second-run"></a>

### Icarus Verilog 13.0：受理する違法デザイン（2回目）

|条項|何をするのか|テスト|
| --- | --- | --- |
| 3.12.1 |`import $unit::*;` を受け入れ、設計を実行します。コンパイルユニットスコープには名前がありませんのでインポートできません。| `ch3/test_illegal_unit_scope_import` |
| 5.9.1 |"\x4z"を受理する（\ x4を読み、その後zを読む）。zは、エスケープの数字にも、1桁の\xエスケープの後の文字にもなれない。| `ch5/test_illegal_string_hex_escape_z_digit` |
| 5.12 |値表現 `1 + (* inner *) 2` が属性のインスタンスを含む属性を受け入れる。| `ch5/test_illegal_attribute_value_contains_attribute` |
| 6.9.1 |xのbitを含むベクトル範囲の境界を受理する。| `ch6/test_illegal_vector_range_x_bound` |
| 6.9.1 |zビットを含むベクトル範囲の境界を受理する。| `ch6/test_illegal_vector_range_z_bound` |
| 6.9.1 |実数パラメータをベクトル範囲の境界として受け入れる。| `ch6/test_illegal_vector_range_real_bound` |
| 6.20.2, 6.22.3 |代入互換性のないintリテラルを、enum型パラメータの値として受理する。| `ch6/test_illegal_enum_parameter_assigned_int` |
| 6.20.2, 6.22.3 |enum型パラメータを上書きするintリテラルを受理する。| `ch6/test_illegal_enum_parameter_overridden_with_int` |
| 7.4.2 |xのbitを含むunpacked次元の境界を受理する。| `ch7/test_illegal_unpacked_range_x_bound` |
| 7.4.2 |zのbitを含むunpacked次元の境界を受理する。| `ch7/test_illegal_unpacked_range_z_bound` |
| 8.4 |無関係なクラスのハンドル同士のAccepts ==、およびクラスハンドルのインクリメントb++| `ch8/test_illegal_class_handle_equality_unrelated_classes`, `ch8/test_illegal_class_handle_increment` |
| 8.7 |`static function new()`と宣言したコンストラクタを受理する（正当な対照用呼出しを取り除いて確認）。| `ch8/test_illegal_static_constructor` |
| 8.7 |これは、`virtual function new()` と宣言されたコンストラクタを受け入れる。| `ch8/test_illegal_virtual_constructor` |
| 12.5 |1つのケースステートメントに2つのデフォルト項目を受け入れる。| `ch12/test_illegal_case_two_default_items` |
| 13.4.3 |生成ブロックに定義された関数の呼び出しを定数表現で受け入れます。| `ch13/test_illegal_constant_function_in_generate_block` |
| 22.2、22.7 |次の行の精度の `` `timescale `` 指令を受け入れます。| `ch22/test_illegal_directive_split_across_lines` |
| 22.14 |認識しない `` `begin_keywords `` バージョン指定子を受け入れ、警告のみを出します。| `ch22/test_illegal_begin_keywords_unknown_version` |
| 23.3.2.4 |1つのポートリストに.*を2回記述しても受理します。| `ch23/test_illegal_wildcard_port_connection_twice` |
| 23.10.2.2 |1つのパラメータ値の指定で、同じパラメータへの名前付き代入を2回記述しても受理します。| `ch23/test_illegal_named_parameter_assigned_twice` |
| 26.4 |プログラムヘッダに同じ値を受け入れます。| `ch26/test_illegal_program_header_import_without_port_list` |
| 26.6 |パッケージの名前を付けたエクスポートを受け入れます。エクスポートするパッケージはインポートしません。| `ch26/test_illegal_export_named_from_package_not_imported` |
| 30.4.4.3 |bit-select と part-select として目的地を参照するエッジ感度パスを受け入れます。| `ch30/test_illegal_specify_edge_path_part_and_bit_select` |
| 30.4.4.4 |エッジセンシティブなifnoneパスを受理する。| `ch30/test_illegal_ifnone_edge_sensitive_path` |

<a id="verilator-5052-results-second-run"></a>

### Verilator 5.052: 結果 (2回目の実行)

|条項|何をするのか|テスト|
| --- | --- | --- |
| 3.3, 30.4.1, 30.5.1 |specifyブロックのモジュールパス遅延を無視し、バッファ出力が立上り遅延3、立下り遅延5の後ではなく、直ちに入力へ追従する。| `ch3/test_module_contains_specify_block` |
| 3.14, 3.14.1 |遅延がモジュールの時間精度へ丸められない。1ns／1nsでの#1.26は1.26 ns待つ（期待値は1 ns）。10ns／1nsでは12.6 nsとなる（期待値は13 ns）。1us／10nsでの#0.0237と#0.0251は、それぞれ23.7 nsと25.1 nsとなる（期待値は20 nsと30 ns）。| `ch3/test_delay_scaled_by_unit_rounded_by_precision` |
|3.14.3、37.10（詳細7）、38.6|vpi_get（vpiTimeUnit、NULL）は、シミュレーションの時間単位（-13、-14、-15）ではなく、トップモジュールの時間精度-9を返します。NULLのvpiTimePrecisionは正しい。| `ch3/test_global_precision_from_timeprecision`, `ch3/test_global_precision_from_timescale`, `ch3/test_global_precision_from_timeunit_slash` |
| H.9.3 |svGetScopeFromNameは、DPIのimportとexportを宣言するgenerateブロックスコープの名前gb[0]に対して、NULLを返す（if generateのgbも同様）。| `ch35/test_dpi_context_scope_of_declaration` |
| H.9.3 |svPutUserDataは、NULLのユーザーデータポインタおよびNULLスコープについて、-1ではなく0を返します。| `ch35/test_dpi_put_user_data_error_result` |
| H.12.3, H.12.4, H.12.5 |4次元のオープン配列に4つの添字を渡したsvGetArrElemPtrとsvPutBitArrElemVecValが、どの要素にも到達しません（NULL、警告あり、書き込みなし）。添字が1個から3個の場合は機能する。| `ch35/test_dpi_open_array_variadic_indexing` |
| 12.4.2 |2つの条件が真の場合、関数内のunique ifのどの分岐も実行しない（f_if(1,1)は0となる）。| `ch12/test_unique_violation_in_function_comb_callers` |
| 12.5.4, 12.5, 12.5.3 |case insideの項目式を複数回評価し、一致した項目より後でも評価する（トレースはEabではなくEabcab）。unique caseは項目を2～3回評価する）| `ch12/test_case_inside_evaluation_order_by_qualifier` |
| 16.5, 16.12 |a_disのdisable条件が、クロックtickと同じ時間ステップの非ブロッキング代入で設定したdを参照しません。更新はObservedより前のNBA領域で起きますが、10の試行は無効化されず失敗します。サンプル値、クロックゲーティング、および即時アサーションとコンカレントアサーションの違いは、規格と一致する。| `ch16/test_assertion_observed_region_values` |
| 16.9.2, 16.7 |cover sequence：start ##1 a[*] ##1 bとa[*0:$]が、ゼロ回繰り返しの一致を見落とします（25）。start ##[*] bと##[0:$] bは、一致を一度も報告しません（期待値は15 25 45）。[+]、[*2]、##[+]は規格と一致します。| `ch16/test_sequence_repetition_and_delay_shorthands` |
| 16.9.3, 16.14.6, 16.14.1 |clk2のdefault clockingがあると、always @(posedge clk)内の$past(v)が、手続きから推論したクロックではなくdefault clockingを使用します。出力は1、3、5ではなく、2、4、6です。アクションブロック出力も同じタイムステップでalwaysプロセスのディスプレイの前に来る。| `ch16/test_sampled_function_clock_inference` |
| 16.12 |クロックティック間でだけ真となる disable iff 条件（時刻 238 と 239 で rst が high になり、225 から 245 までの試行の途中にある）は、その試行を無効化せず、試行は 245 で失敗する；Verilator は条件をティックでのみテストします。| `ch16/test_disable_iff_attempt_interval` |
| 24.2, 4.4 |プログラムのステートメントをモジュールステートメントのように実行します。プログラムは b = 0 を NBA の更新前に見ます。| `ch24/test_program_reactive_region_after_nba` |
| 25.3.2, 6.6.3 |2つのモジュールからinterfaceポートを介した連続代入で駆動されるinterfaceのwor netは、1つのドライバだけを採用する。31でd1 = 0、d0 = 1のとき、w = 0となる（期待値は1）。| `ch25/test_interface_port_default_ref_and_inout_access` |
| 33.2, 33.4.1.3 |top.m2.u_leafに対するインスタンスルールを、同じ親モジュールのすべてのインスタンスに適用する（m1.u_leafも含む）。| `ch33/test_config_binding_descends_through_children` |
| 35.5.3, H.9.2 |階層名を介して呼び出したcontextインポート（トップモジュールからのu2.c_where()。interfaceやgenerateブロック内のインポートも同様）は、宣言スコープではなく呼出し側のスコープで実行される。そのため、svSetScopeなしでは宣言スコープのエクスポートを見つけられない。| `ch35/test_dpi_context_scope_of_declaration` |
| 38.36.2 |vpi_register_cbは、時刻型がvpiSuppressTimeであるcbAfterDelayコールバックと、時刻ポインタがNULLであるコールバックに対して、ハンドルを返す（'failed registrations: 0 of 2'）。しかし、どちらもコールバックを生成すべきでないエラーである。| `ch38/test_vpi_pli_error_callback_counts_failed_calls` |

<a id="verilator-5052-illegal-designs-that-it-accepts-second-run"></a>

### Verilator 5.052：受理する違法デザイン（2回目）

|条項|何をするのか|テスト|
| --- | --- | --- |
| 3.11, 29.3 |ユーザ定義のプリミティブのボディ内にゲートインスタンスを受け入れる。| `ch3/test_illegal_udp_contains_gate_instance` |
| 3.12.1 |参照モジュールの後に宣言されたコンパイルユニット変数への単純名の参照を受け入れます。| `ch3/test_illegal_unit_scope_forward_reference` |
| 3.14 |`timeunit 10ps; timeprecision 100ps;`（精度が単位より粗い）を受け入れ，設計を実行する。| `ch3/test_illegal_timeprecision_coarser_than_timeunit` |
| 5.13, 13.4.1 |`s.toupper[0]` を受け入れます。これは括弧なしの内蔵メソッドコールであり、暗黙変数として使用されます。| `ch5/test_illegal_method_implicit_variable_without_parentheses` |
| 6.3.2 |連続代入なしにネット宣言でドライブ強度を受け入れる。| `ch6/test_illegal_drive_strength_without_assignment` |
| 6.7 |packed次元なしのwire scalaredを受理する。| `ch6/test_illegal_scalared_net_without_packed_dimension` |
| 6.7 |packed次元なしのwire vectoredを受理する。| `ch6/test_illegal_vectored_net_without_packed_dimension` |
| 6.16 |文字列複製の乗数として実変数を受け入れます。整数型でなければならない。| `ch6/test_illegal_string_replication_real_multiplier` |
| 6.18 |box_cが未完成の前方宣言型である間に、box_c::item_tで宣言した変数を受理します。| `ch6/test_illegal_forward_type_scope_prefix_in_variable` |
| 6.19.2 |個数が正でなければならないenumの名前範囲dead[0]を受理する。| `ch6/test_illegal_enum_name_range_zero_count` |
| 6.20.3 |C::item_t で宣言されたクラスプロパティを受け入れ、タイプパラメータ C で選択します。| `ch6/test_illegal_type_parameter_scope_prefix_in_variable` |
| 6.20.7 |$を値とするパラメータを、キュー選択q[P]とP + 1のオペランドとして受理する。| `ch6/test_illegal_dollar_parameter_in_ordinary_expression`, `ch6/test_illegal_dollar_parameter_in_queue_select` |
| 6.24.1 |real変数のサイズキャスト4'(r)を受理する。サイズキャストの式は、整数型でなければならない。| `ch6/test_illegal_size_cast_of_real` |
| 7.2, 6.8 |packedのないstructの後に付けたpacked次元を受理する。| `ch7/test_illegal_unpacked_struct_packed_dimension` |
| 7.2, 6.8 |packedでもsoftでもないunionの後にある、packed次元を受理します。| `ch7/test_illegal_union_packed_dimension_without_qualifier` |
| 7.2 |packed構造体とunpacked共用体のメンバーにrand修飾子を付けることを受理する。| `ch7/test_illegal_rand_member_in_packed_struct`, `ch7/test_illegal_rand_member_in_union` |
| 7.2.2 |unpacked 構造にユニオンメンバーを持つとき、メンバーのデフォルト値を受け入れます。| `ch7/test_illegal_union_holding_struct_member_default` |
| 7.3 |文字列メンバーをタグ付けされていないユニオンに受け入れます。| `ch7/test_illegal_string_in_untagged_union` |
| 7.4.6 |unpacked 配列を + のオペランドとして受け入れます。| `ch7/test_illegal_unpacked_array_in_integer_expression` |
| 7.8, 7.8.2, 7.8.4 |string添字配列に対するint添字、int添字配列に対するreal添字とshortreal添字、およびenumまたはpacked構造体を宣言する添字型を受理する。| `ch7/test_illegal_string_index_with_int` |
| 7.10 |キューの上限-1を受理する。| `ch7/test_illegal_queue_bound_negative` |
| 7.12.2 |unpacked構造体の配列に対するwith節なしのsort()と、with式itemがunpacked構造体型であるsort()を受理する。| `ch7/test_illegal_sort_with_struct_expression`, `ch7/test_illegal_sort_without_with` |
| 8.3 |virtual virtual、pure virtualメソッドの:final、interface classメソッドの:initial、およびクラス外関数の:finalを受理する。| `ch8/test_illegal_class_method_virtual_twice`, `ch8/test_illegal_override_specifier_in_interface_class`, `ch8/test_illegal_override_specifier_outside_class`, `ch8/test_illegal_pure_virtual_method_final`, `ch9/test_illegal_override_specifier_in_interface_class` |
| 8.4 |クラスハンドルとintの比較（by ==）、\<によるハンドル同士の比較、およびchandleのインクリメントを受理する。| `ch8/test_illegal_chandle_increment`, `ch8/test_illegal_class_handle_equality_with_int`, `ch8/test_illegal_class_handle_relational_operator` |
| 8.23 |T::nib_t で宣言されたクラスプロパティを受け入れ、タイプパラメータ T で選択されたタイプを受け入れます。| `ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration` |
| 8.24 |ブロック外ヘッダに付加されたデフォルトの引数を受け入れます。| `ch8/test_illegal_extern_default_not_in_prototype` |
| 8.24 |クラスの範囲限定子なしにクラスで宣言されたブロック外の返しタイプを受け入れる。| `ch8/test_illegal_extern_return_type_without_class_scope` |
| 8.26 |interface class内に宣言したクラスを受理する。| `ch8/test_illegal_interface_class_nested_class` |
| 8.26.2 |`interface class bad_if implements a_if;` を受け入れます。| `ch8/test_illegal_interface_class_implements_interface` |
| 8.26.2 |interfaceではないクラスをextendsするinterface classを受理する。| `ch8/test_illegal_interface_class_extends_class` |
| 8.26.6.1 |戻り値の型が異なる2つの同名interfaceメソッドを、1つのメソッドで実装することを受理する。| `ch8/test_illegal_interface_method_conflict_return_types` |
| 8.26.6.1, 8.20 |これは、同じ名前の継承された仮想メソッドの有効なオーバーライドではないインタフェースメソッドの実装を受け入れる。| `ch8/test_illegal_interface_method_conflict_with_inherited` |
| 8.26.7 |仮想クラスはインタフェースクラスを実装し、そのメソッドの一つを実装も再宣言もしない。| `ch8/test_illegal_virtual_class_leaves_interface_method_undeclared` |
| 8.26.8 |定数でないデフォルトの引数値（コンパイルユニット変数）をインタフェースクラスメソッドに受け入れます。| `ch8/test_illegal_interface_method_default_not_constant` |
| 9.7 |内蔵クラスプロセスを拡張するクラスを受け入れる。| `ch9/test_illegal_class_extends_process` |
| 9.7 |内蔵クラスプロセスの変数に対して new を受け入れる。| `ch9/test_illegal_new_process_object` |
| 10.2 |変数添字によるnetのbit選択への連続代入を受理する。| `ch10/test_illegal_continuous_assign_nonconstant_bit_select` |
| 10.3.2 |連続代入より後に宣言される変数への連続代入を受理する。| `ch10/test_illegal_continuous_assign_variable_declared_after` |
| 10.3.2, 6.5 |同じ変数に対する2つの連続代入を受理する。| `ch10/test_illegal_variable_two_continuous_assignments` |
| 10.6.2 |変数のbit選択に対するforceを受理する。| `ch10/test_illegal_force_variable_bit_select` |
| 10.10.3, 10.8 |代入パターンのdefault項目として、unpacked配列の連結{a1, b}を受理する。| `ch10/test_illegal_unpacked_concat_in_default_pattern_item` |
| 10.11 |ワンドネットのエイリアスをワーネットに受け入れる。| `ch10/test_illegal_alias_wand_to_wor` |
| 11.3.6 |イベント式内と、手続き的連続代入の右辺内の代入演算子を受理する。| `ch11/test_illegal_assignment_operator_in_event_expression`, `ch11/test_illegal_assignment_operator_in_procedural_assign` |
| 11.4.12 |連結内のサイズ未指定定数に対して、警告WIDTHCONCATだけを出す。| `ch11/test_illegal_unsized_constant_in_concatenation` |
| 11.4.12.1 |代入の左辺と出力ポート接続で複製を受理する。| `ch11/test_illegal_replication_on_assignment_lhs`, `ch11/test_illegal_replication_to_output_port` |
| 11.4.13 |inside範囲の境界としてクラスハンドルを受理する。| `ch11/test_illegal_inside_range_of_class_handles` |
| 11.4.14 |24-bitストリームから16-bit shortintへの代入と、ストリームからreal変数への代入を受理する。| `ch11/test_illegal_stream_into_narrower_fixed_target`, `ch11/test_illegal_stream_into_real_target` |
| 11.4.14.3 |real値をアンパック元として受理し、24-bitのアンパック先に対する16-bitの変換元も受理する。| `ch11/test_illegal_unpack_from_real_source`, `ch11/test_illegal_unpack_source_too_short` |
| 12.4.2 |修飾付きif-else-ifの連鎖のelse後に記述したunique／unique0／priorityキーワードを受理する。| `ch12/test_illegal_priority_if_second_else_unique_if`, `ch12/test_illegal_unique0_if_else_priority_if`, `ch12/test_illegal_unique_if_else_unique0_if` |
| 12.7.1 |既存の変数を割り当て、次にローカル変数を宣言するfor-loop初期化を受け入れる。| `ch12/test_illegal_for_init_declares_after_existing` |
|12.7（脚注18）、6.23|varなしで、型参照を使って宣言したforループ変数を受理する。| `ch12/test_illegal_for_type_reference_without_var` |
|12.7（脚注18）、6.23|タイプ参照とネットタイプキーワードもvarもないモジュールレベルの宣言を受け入れる。| `ch12/test_illegal_net_type_reference_without_net_type` |
| 13.3.2 |automatic taskの変数を式で読み取るforceを受理する。| `ch13/test_illegal_automatic_task_variable_in_force_expression` |
| 13.3.2 |ノンブロッキング代入の代入内イベント制御で、automatic taskの変数を受理する。| `ch13/test_illegal_automatic_task_variable_in_nonblocking_event` |
| 14.5 |クロッキング出力またはinout信号として、左辺値でない式（a + b、a & b）を受理する。| `ch14/test_illegal_clocking_inout_expression_not_lvalue`, `ch14/test_illegal_clocking_output_expression_not_lvalue` |
| 14.5, 11.3.6 |クロッキング入力の式内の代入演算子を受理する（ASSIGNEQEXPRの警告）。| `ch14/test_illegal_clocking_input_expression_with_assignment` |
| 14.16.2 |出力clockvarに関連付けられた変数への手続き的連続assignを受理する。| `ch14/test_illegal_clocking_output_variable_procedural_assign` |
| 14.16.2 |出力clockvarに関連付けられた変数へのforceを受理する。| `ch14/test_illegal_clocking_output_variable_force` |
| 16.8 |実際の引数で形成されたサイクルを受け入れます。実際の引数は、そのボディが最初のものをインスタンス化するシーケンスをインスタンス化します。| `ch16/test_illegal_sequence_cycle_through_instance_actual` |
| 16.9.2 |関連付けられたマッチアイテムを持つブール表現に適用された goto 繰り返しを受け入れます。| `ch16/test_illegal_repetition_goto_on_match_item` |
| 16.9.4 |グローバルクロッキングのない設計で$rising_gclkを受理する。| `ch16/test_illegal_global_clock_future_function_without_global_clocking` |
| 16.12 |プロパティのローカル変数を参照するdisable条件を受理する（int v = 0。disable iff (v != 0))。| `ch16/test_illegal_property_disable_iff_local_variable` |
| 16.12.2, 16.12.22 |空マッチを許すb[*0:2]を、後件のシーケンスプロパティとして受理する。| `ch16/test_illegal_plain_sequence_property_empty_match` |
| 22.4 |ファイル名の後に `` `include `` 行で宣言を受け入れます。| `ch22/test_illegal_include_line_trailing_code` |
| 22.7 |モジュール内で `` `timescale `` を受け入れる。| `ch22/test_illegal_timescale_inside_module` |
| 22.8 |モジュール内で `` `default_nettype `` を受け入れる。| `ch22/test_illegal_default_nettype_inside_module` |
| 23.2.2.2 |ネットタイプの出力ポートに初期化を受け入れる。| `ch23/test_illegal_ansi_output_net_port_initialized` |
| 23.2.2.2 |非 ANSI と ANSI のポート宣言を混ぜたポートリストを受け入れます。| `ch23/test_illegal_mixed_ansi_and_nonansi_ports` |
| 23.2.2.4 |ANSI ではない入力ポートの宣言に対してデフォルトの値を受け入れます。| `ch23/test_illegal_nonansi_input_port_default` |
| 23.2.4 |初めのものと一致しない繰り返しの時間精度を受け入れます。| `ch23/test_illegal_interface_timeprecision_repeat_mismatch` |
| 23.2.4 |最初のものと一致しない繰り返し時間単位を受け入れます。| `ch23/test_illegal_module_timeunit_repeat_mismatch` |
| 23.2.4 |パッケージの最初の項目でない時間単位を受け入れます。| `ch23/test_illegal_package_timeunit_item_without_previous` |
| 23.2.4 |プログラムの最初の項目でない時間単位を受け入れます。| `ch23/test_illegal_program_timeunit_item_without_previous` |
| 23.3.2.3 |モジュール内で後から宣言する変数への.name接続を受理する。| `ch23/test_illegal_implicit_name_port_declared_later` |
| 23.3.3.2 |変数の出力ポートに接続された変数に対する手続き的な代入を受け入れる。| `ch23/test_illegal_output_port_variable_procedural_write` |
| 23.3.3.2 |変数outputポートへ接続した連結内の変数への連続代入を受理する。| `ch23/test_illegal_output_port_concat_continuous_write` |
| 23.9 |出力ネットの名前を持つ buf インスタンスを受け入れます。| `ch23/test_illegal_scope_gate_named_as_output_net` |
| 23.10.2.2 |名前指定と位置指定のパラメータ代入を混在させた#(.A(5), 6)を受理する。| `ch23/test_illegal_parameter_assignment_named_then_ordered` |
| 23.10.2.2 |括弧なしの名前付きパラメータ代入.D を受け入れます。| `ch23/test_illegal_named_parameter_without_parentheses` |
| 23.11 |インターフェースにモジュールをバインドする事を許可します (インターフェースまたはチェッカーのインスタンスのみが許可されます)| `ch23/test_illegal_bind_module_into_interface` |
| 23.11 |タイプ名がバインドスコープとターゲットの両方で異なるタイプを意味するタイプパラメータオーバーライドを受け入れる。| `ch23/test_illegal_bind_type_override_not_matching` |
| 25.3 |インスタンス配列要素またはgenerateブロックを経由する、階層名を用いたinterfaceポート実引数を受理する。| `ch25/test_illegal_interface_port_actual_through_instance_array` |
| 25.7 |タスクを名前だけでインポートするmodportを通して、デフォルトの引数値に依存するコールを受け入れます。 (完全なプロトタイプが必要です)| `ch25/test_illegal_modport_import_default_argument_without_prototype` |
| 25.7 |タスクを名前だけでインポートする modport を通して、名前で結びつけられた引数を持つコールを受け入れます (完全なプロトタイプが必要です)| `ch25/test_illegal_modport_import_named_binding_without_prototype` |
| 25.7, 6.22.1 |宣言より引数が1つ少ないmodport importプロトタイプと、引数型bit signed [0:31]がintと合致しないプロトタイプを受理する。| `ch25/test_illegal_modport_prototype_argument_count` |
| 25.9 |本体外への階層参照を持つinterface、またはinterfaceポートを持つinterfaceに対する仮想interfaceを受理する。| `ch25/test_illegal_virtual_interface_with_outside_reference` |
| 25.9 |仮想インタフェースを通してコンポーネントを読み込む連続的な代入と，仮想インタフェイスを通してインタフェースネットに手続き的な割り当たりを受け入れる。| `ch25/test_illegal_virtual_interface_component_in_continuous_assign` |
| 26.2 |パッケージにネット宣言代入を受け入れます。| `ch26/test_illegal_package_net_declaration_assignment` |
| 26.5, 26.6 |表26-1のimport競合を受理する（他のpackageから既にimportした名前、またはローカル宣言した名前への明示import）。ワイルドカード参照後のローカル宣言または明示import）、および名前付きexportによって名前をimportした後のローカル宣言。| `ch26/test_illegal_export_named_imports_candidate`, `ch26/test_illegal_search_order_explicit_import_from_second_package` |
| 27.3 |これは、インタフェースの生成ブロックに buf ゲートインスタンスを受け入れる。| `ch27/test_illegal_generate_interface_block_gate` |
| 30.4.3, 30.4.4.4 |これは、ベクトルまたは部分選択目的地への平行エッジ感度パスと、エッジ感受的なifnoneパスを受け入れます。| `ch30/test_illegal_edge_parallel_path_vector_destination`, `ch30/test_illegal_ifnone_edge_sensitive_path` |
| 30.4.4.3 |同じエッジと条件を持つエッジセンシティブなパスの重複と、終点を部分選択およびbit選択で参照するパスを受理する。| `ch30/test_illegal_specify_edge_path_part_and_bit_select`, `ch30/test_illegal_specify_edge_path_same_edge_and_condition` |
| 31.2 |specifyブロック内の$display呼出しを受理する。| `ch31/test_illegal_system_task_in_specify_block` |

<a id="both-releases-results-second-run"></a>

### 両リリースの結果（2回目）

|条項|何をするのか|テスト|
| --- | --- | --- |
| 38.36.3, 20.10 |vlog_startup_routinesから登録したcbErrorコールバックは、$errorが生成する実行時エラー（'cbError calls: 0'）に対して一度も呼び出されない。どちらも登録を受け入れました| `ch38/test_vpi_error_callback_runtime_errors` |

<a id="both-releases-illegal-designs-that-it-accepts-second-run"></a>

### 両方のリリース：受理される規格違反の設計（2回目）

|条項|何をするのか|テスト|
| --- | --- | --- |
| 3.12.1 |両方とも、参照より後に宣言されたコンパイル単位変数に対する`$unit::name`を受理する。`$unit::` は前向き参照を追加しません。| `ch3/test_illegal_unit_prefix_forward_reference` |
| 3.14.2.3 |一つのモジュールが時間単位または時間精度を宣言し、他のモジュールがどのソースからも時間単位を持っていない場合にのみ警告します。3.14.2.3では、これはエラーとなる。| `ch3/test_illegal_time_unit_specified_only_in_some_elements` |
| 5.9.1 |"\1z"を受理する（\ 1を読み、その後zを読む）。zは、8進エスケープの数字にも、より短い8進エスケープの後の文字にもなれない。| `ch5/test_illegal_string_octal_escape_z_digit` |
| 6.16 |int 変数を文字列変数に割り当てたとき、キャストなしで受け入れます。| `ch6/test_illegal_string_assigned_int_without_cast` |
| 6.16 |文字列複製{2{s, k}}内のintオペランドを受理する。| `ch6/test_illegal_string_replication_int_operand` |
| 6.18 |最終定義が構造体である前方宣言enum typedef、generateブロック内でだけ定義した前方宣言typedef、最後まで定義しない前方宣言typedefを受理します。| `ch6/test_illegal_forward_enum_defined_as_struct`, `ch6/test_illegal_forward_typedef_defined_in_generate_block`, `ch6/test_illegal_forward_typedef_never_defined` |
| 7.10 |両方とも、正ではないキューの上限0を受理する。| `ch7/test_illegal_queue_bound_zero` |
| 8.3 |1つのプロパティ宣言内のprotected local、rand randc、static staticを受理する。| `ch8/test_illegal_class_property_protected_and_local`, `ch8/test_illegal_class_property_rand_and_randc`, `ch8/test_illegal_class_property_static_twice` |
| 10.6.2 |両方とも、連続代入と手続き代入がビット単位で混在して駆動する変数へのforceを受理する。| `ch10/test_illegal_force_mixed_driven_variable` |
| 13.3.2 |自動タスク変数の $dumpvars を受け入れます。| `ch13/test_illegal_automatic_task_variable_dumped` |
| 13.4.3 |ローカル宣言の範囲指定内で定数関数を呼び出す定数関数を受理する。| `ch13/test_illegal_constant_function_call_in_constant_context` |
| 13.4.3 |呼出しより後で宣言したパラメータを使って評価する定数関数呼出しを受理する。| `ch13/test_illegal_constant_function_parameter_after_call` |
| 13.4.3 |localparamの初期値内で、空のfork-join_noneを含む関数の呼出しを受理する。| `ch13/test_illegal_constant_function_contains_fork` |
| 13.5 |出力引数の実引数としてa + bを受理する（Icarusは"I give up on task port"を出力するが完了する）。| `ch13/test_illegal_output_argument_not_lvalue` |
| 22.12 |`` `line `` と同じ行のコメントを受け入れます。| `ch22/test_illegal_line_directive_trailing_comment` |
| 22.14 |対応する `` `end_keywords `` がない `` `begin_keywords `` を受け入れる。| `ch22/test_illegal_begin_keywords_without_end` |
| 22.14 |対応する`` `begin_keywords ``のない`` `end_keywords ``を受理する（Icarus Verilogでは警告のみ）。| `ch22/test_illegal_end_keywords_without_begin` |
| 22.14 |モジュールアイテム間で `` `begin_keywords `` を受け入れる。| `ch22/test_illegal_begin_keywords_inside_module` |
| 23.3.2.3, 23.3.3.7 |ワーネットとワンドポート間の.name接続を受け入れる（表 23-1 の警告ペア）が、.nameに対してはエラーである。| `ch23/test_illegal_implicit_name_port_dissimilar_net_types` |
| 25.3, 26.4 |パッケージインポートにパラメータポートリストもポートリストも付けられていない ANSI ヘッダを受け入れます。| `ch25/test_illegal_interface_header_import_without_port_list`, `ch26/test_illegal_module_header_import_without_port_list` |
| 26.2 |階層名によるモジュール変数の読取り、またはコンパイル単位スコープの項目の読取りを行うpackage関数を受理する。| `ch26/test_illegal_package_hierarchical_reference_to_module`, `ch26/test_illegal_package_refers_to_unit_scope_item` |
| 30.4.4.4 |同じモジュールパスに対して ifnone パスと無条件単純パスを受け入れます。| `ch30/test_illegal_specify_ifnone_with_unconditional_path` |
| 30.7.4.1 |パス宣言に既に表示されている出力に対してパルススタイル宣言を受け入れます。| `ch30/test_illegal_pulsestyle_ondetect_after_path`, `ch30/test_illegal_pulsestyle_onevent_after_path` |
| 31.7 |specifyブロック内で2つの条件付け信号を組み合わせるタイミングチェック条件を受理する。| `ch31/test_illegal_timing_condition_two_signals` |

<a id="a-test-whose-expected-output-followed-both-releases-rather-than-the-standard"></a>

## 標準ではなく両リリースに従う予期出力を持つテスト

Lyra（2026-10-24）とnvcとの比較から，期待出力が両リリースで記録されているが，引用条項やそのオラクルでないシミュレータに従わないテストが1つ見つかった。期待出力は現在、規格に従っている。`:oracle:`は`spec`だけであり、ロード時に警告を出してメモリを変更しないことが必要となる規格のケースを、テストに維持している。

|条項|テストの期待値と規格の規定|出力|テスト|
| --- | --- | --- | --- |
| 21.4, 21.4.3 |`logic [7:0] m[0:1][0:2]`に対する`$readmemh(file, m, 2, 5)`は、警告を出し、すべてのワードを`ee`のままにすることを期待する。21.4は、start_addrとfinish_addrをunpacked配列の最上位次元を表すアドレスに適用すると定め、21.4.3はアドレス項目が最上位次元のワードだけを指定すると定めています。そのため2と5は`[0:1]`の範囲外です。|Icarus Verilog 13.0と14.0、およびVerilator 5.052：`m[0][2]=11 ... m[1][2]=44`。これは以前の期待出力である。kirimasim : 範囲のアドレス 2 がメモリ外にあることを警告し、すべてのワードを `ee` に残す。Lyra 7e2c604b9ab2: `m[0][2]=ee`。nvcはテストを解析しません。| `ch21/test_readmemh_address_range` |

`:oracle: spec`を持ち、Lyraの結果が一致しなかった194テストの追加レビュー（2026-10-25）では、期待出力の新たな誤りは見つかりませんでした。ただし、Icarus VerilogとVerilatorの診断形式を要求する正規表現が2本にあり、修正済みです。[レビュー](lyra-disagreement-review-20261025.md) を参照してください。

<a id="icarus-stimulus-extraction-observation-2026-10-26"></a>

## Icarus 2026-10-26の刺激抽出観察を行った。

SVA参照モデルのM0実験中、Icarus Verilog 13.0安定版は、並行アサーション指令とそのアクションをすべて除去しても、`ch16/test_sequence_first_match`のコンパイルで異常終了しました。`function automatic string times(int q[$])`の残りのキュー引数は、`draw_eval_function_argument`内の内部アサーションに達した（`draw_ufunc.c`）。そのため、刺激だけを与えるIcarus実行では、他を変更せずに既存の報告コードを使うことができない。コンカレントアサーションの評価結果ではない。テストも期待出力も変更していません。[ `tools/sva_reference/README.md` ](../tools/sva_reference/README.ja.md) に実験とその範囲を記述した。

M3の期待値・説明の2件の修正をユーザーが承認した後、`ch16/test_property_implication_operator_forms`と`ch16/test_zero_repetition_no_sample`を、Icarus Verilog 13.0安定版、およびVerilator 5.052のseed 1・73で再実行しました。これは、Icarus がアサーション構文を拒否したためである。Verilatorは、それぞれfollowed-byのシーケンス前件と`[*0]`を拒否した。全6結果は出力の確認ではなく、`known`です。個別の実行は`coverage/results/sva-m3-corrections-20261026-*.json`として保存している。条文に基づく修正とその証跡は、[ `tools/sva_reference/M3_REVIEW.md` ](../tools/sva_reference/M3_REVIEW.ja.md)に記載している。

<a id="cases-added-by-the-2026-10-25-imported-tests"></a>

## 2026-10-25 の導入テストによって追加されたケース

<a id="icarus-verilog-130-results-imported-tests"></a>

### Icarus Verilog 13.0: 結果 (インポートされたテスト)

|条項|何をするのか|テスト|
| --- | --- | --- |
|23.3.3.7（表23-1）、28.12.4|ポートでwandまたはworとsupplyネットを接続すると、強度が異なっていてもwand/worのwiredなlogicを適用します。また、supply0とsupply1を接続すると両方のsupplyを保持してxになります。表23-1では、外側ネットの種類による1つのネットにする規定です。テストの合成対のうち6対は異なった。| `imported/ch23/test_net_port_merge_kinds` |

<a id="generate-default-disable-20261102"></a>

<a id="generate-and-default-disable-iff-2026-11-02"></a>

## generateとdefault disable iff（2026-11-02）

`generate_default_disable@1`の18選択ケースを固定版で実行しました。
[設計と確認範囲](interaction-verification.md#generate-default-disable-scopes)、
[Verilator seed 1](../coverage/interaction-results/cross66-gendisable-verilator5052-seed1.json)、
[seed 73](../coverage/interaction-results/cross66-gendisable-verilator5052-seed73.json)、
[Icarus 13.0](../coverage/interaction-results/cross66-gendisable-icarus13.json)に記録しています。

- Verilator 5.052：両seedで5件が一致し、13件が出力不一致です。クロック間だけの条件パルス6件と終了クロックのNBA6件では、module直下の対照のアクション回数から規格由来の期待値と異なります。局所defaultを使う開始前条件の1件では、一方の実体の局所条件を立てたとき、他方の実体の回数が異なります。実装内部の原因は未確認です。
- Icarus Verilog 13.0：全18件が並行アサーションなどの構文をビルド時に拒否し、出力の確認には至りません。

一致した5件だけに固定Verilatorのoracleを追加しました。残る13件は規格から決めた期待値を保持しています。
開始前条件の正常対照4件とSV故障注入6件の成功は、これらの13件を確認済みとする根拠ではありません。
固定版の差異としてこの資料に記録し、上流へのIssue投稿は行っていません。

<a id="distribution-precedence-20261103"></a>

<a id="distribution-and-operator-precedence-2026-11-03"></a>

## distと演算子の優先順位（2026-11-03）

`distribution_expression_binding@1`の31選択ケースを固定版で確認しました。
[設計と確認範囲](interaction-verification.md#distribution-expression-binding)、
[Verilator seed 1](../coverage/interaction-results/cross67-dist-verilator5052-seed1.json)、
[seed 73](../coverage/interaction-results/cross67-dist-verilator5052-seed73.json)、
[Icarus 13.0](../coverage/interaction-results/cross67-dist-icarus13.json)に記録しています。

- Verilator 5.052：両seedで正常系19件が一致し、成功と失敗を交互に行う12件は出力不一致です。全候補の合計重みがゼロでもrandomizeが1を返します。18.5.3は候補の合計重みゼロを禁止条件とするため、この場合の解はなく、期待出力は失敗と値保持です。内部実装の原因は未確認です。
- Icarus Verilog 13.0：全31件をビルド時に拒否し、出力の確認には至りません。

一致した19件だけに固定Verilatorのoracleを追加しました。元の失敗系の期待値と候補集合は変更していません。
独立した矛盾を追加した補助対照での失敗確認を、全重みゼロそのものの確認や初回失敗時の確認へ読み替えません。
単一値範囲と一意な解を使っており、多値範囲の確率比や分布の統計的な適合は未検証です。
固定版の差異としてこの資料に記録し、上流へのIssue投稿は行っていません。

<a id="aggregate-event-lifetime-2026-11-03"></a>

<a id="2026-11-03-aggregate-events-and-automatic-task-lifetime"></a>

## 2026-11-03：構造体内イベントと自動タスクの寿命

`aggregate_event_lifetime@1`の18件は、構造体の全体コピーと自動スコープの寿命を、別名解除・遅延した待機登録・複数呼出しで組み合わせます。
固定Verilator 5.052は両seedともイベント代入が未対応で全件ビルド拒否、固定Icarus 13.0も全件ビルド拒否でした。固定版oracleは追加していません。
kirimasim `50f1f77b8c94`は全件解析成功・イベント値操作未対応です。
独立モデルで全432行を検算していますが、シミュレータ上での正常対照・故障検出は未確認です。
[設計・生の証跡・限界](interaction-verification.md#aggregate-event-lifetime)を参照してください。商用シミュレータとの照合や外部Issueへの投稿は行っていません。

<a id="sv-dpi-array-queries-2026-11-03"></a>

<a id="2026-11-03-sv-and-dpi-c-array-queries"></a>

## 2026-11-03：SVとDPI-Cの配列問い合わせ

`sv_dpi_array_queries@1`の固定Verilator 5.052実行は両seedとも11 pass・8 knownです。
サイズ固定・正規化済みpackedの11件は一致します。オフセット付きpackedの2件では、Cの次元0が正規化範囲と異なります。
実引数`[4:7]`に対して期待値`[3:0]`と異なる端点・方向が出力されました。内部実装の原因は未確認です。
open packedの6件と固定Icarus 13.0の全19件はビルド拒否です。期待値を維持し、一致した11件だけにoracleを登録しました。
kirimasim `50f1f77b8c94`の解析は全件成功しますが、ランナーがCコード付きテストを実行前に未対応へ分類します。
[設計・対照・生の証跡](interaction-verification.md#sv-dpi-array-queries)を参照してください。

<a id="sdf-conditional-paths-2026-11-03"></a>

<a id="2026-11-03-conditional-specify-paths-and-sdf-annotation"></a>

## 2026-11-03：条件付きspecifyパスとSDF注釈

`sdf_conditional_paths@1`の固定Icarus 13.0実行は3 pass・15 knownです。
通常パス・ABSOLUTEは一致し、COND／CONDELSE／INCREMENTを含む行は、値・変化回数・時刻の出力が一致しません。
固定Verilator 5.052は両seedとも全18件が出力不一致です。通常パスで一致したIcarusの3件だけにoracleを追加しました。
元の正常対照3件とSV/SDFの6故障は固定Icarusで実行していますが、条件付き注釈と加算の実行確認ではありません。
kirimasim `2ffb5dddca04`では全18件が解析成功、実行で最初に報告される未対応は条件付きパス12件・$sdf_annotate 6件です。
[設計・対照・生の証跡](interaction-verification.md#sdf-conditional-paths)を参照してください。

<a id="checker-assertion-sampling-2026-11-03"></a>

<a id="2026-11-03-checker-and-module-reference-sampling"></a>

## 2026-11-03：checkerとmodule参照のサンプリング

`checker_assertion_sampling@1`の固定Verilator 5.052実行は両seedとも25 pass・2 knownです。
残る2件は、1ビットベクタ・同時刻NBA・明示クロックです。最初の周期ではPreponedで0をサンプルし、NBA更新後の生値は1の期待ですが、
checkerとmodule参照の両方が生値0を記録し、時刻16の最終データは1でした。内部実装の原因は未確認です。
二つの実装が一致するだけでは合格とせず、独立した仕様モデルと比較し、期待値を維持します。一致した25件だけにoracleを追加しました。
固定Icarus 13.0は全27件をビルド時に拒否します。kirimasim `2ffb5dddca04`は解析成功・checkerインスタンス未対応です。
[設計・正常対照・全出力の再現記録](interaction-verification.md#checker-assertion-sampling)を参照してください。

<a id="deferred-disable-reports-2026-11-03"></a>

<a id="2026-11-03-deferred-reports-and-disable-scopes"></a>

## 2026-11-03：遅延報告とdisableのスコープ

固定Verilator 5.052は`deferred_disable_reports@1`で両seedとも13 pass・18 knownです。
ラベル/最外取消し12件と、それ以外のpayload変更6件が不一致で、一致した13件だけにoracleを登録します。
元のpayload保持none/内側/taskの正常対照6件とSV故障7件は終了コード0で実行し、既知差3件は別に再現しました。
この対照だけではラベル取消し・最外キュー消去・Reactive実行時点を確認できません。
固定Icarus 13.0は23件ビルド拒否・8件出力不一致で、後者ではcoverアクションの回数・入力評価などが異なりました。

kirimasim `786c94bbeafb`は26 pass・新規5 failで、5件はすべて待機報告があるアサーションラベル取消しです。
全出力の再実行では、対象以外の出力と対象の引数評価回数は一致し、取消すべき対象報告だけが残りました。
正常対照4件はPASS、追加の対象報告なしcover対照は取消し成功の証拠には数えません。内部原因は未確認です。
期待値は保持します。[設計と実行出力](interaction-verification.md#deferred-disable-reports)を参照してください。
