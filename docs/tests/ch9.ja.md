<a id="clause-9-processes"></a>

# 第9章：プロセス

[English](ch9.md) / [日本語](ch9.ja.md)

[すべての章](README.ja.md) .テストは451本で、そのうち233本が生成されたものです。このページは、テストのメタデータから`tools/suite_catalog.py`が書きます。このページではなく、テストを編集してください。

初めて読む場合は、[実在テストを入力から期待値まで読み解く](../faq.md#q49-read-a-real-test)を参照してください。oracle欄は固定版による確認の記録です。[現在のビルドの合格を保証しない理由](../faq.md#q4-are-expected-outputs-copied-from-a-simulator)を確認してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_always_forms_repeat`](../../tests/ch9/test_always_forms_repeat.sv) |常に always_comb, always_latch, と always_ff は それぞれのトリガーを持って繰り返される 言語は プロセスの数に制限を設定しない| 9.2 9.2.2 | Icarus Verilog 13.0 ||
| [`test_ch9_extra_initial_always_no_order`](../../tests/ch9/test_ch9_extra_initial_always_no_order.sv) |initialとalwaysのプロセスは それぞれの間に暗黙の順序がない タイムゼロで実行を開始するので 最初のステートメントのどちらの順序でも受け入れられます| 9.2 | Icarus Verilog 13.0 ||
| [`test_ch9_extra_procedure_count`](../../tests/ch9/test_ch9_extra_procedure_count.sv) |128 initial 128 always プロセスはすべて時間ゼロで始まるため、言語はモジュールプロセスの数に小さな固定された制限を課さない。| 9.2 | Icarus Verilog 13.0 ||
| [`test_illegal_override_specifier_in_interface_class`](../../tests/ch9/test_illegal_override_specifier_in_interface_class.sv) |動的オーバーライド指定子は、interface classのメソッドには使用できない| 9.2 8.26 8.20 |規格のみ|規格違反の設計|
| [`test_illegal_override_specifier_on_module_function`](../../tests/ch9/test_illegal_override_specifier_on_module_function.sv) |動的オバーライド指定子はインターフェースクラスでないクラスのメソッドにのみ許可されます| 9.2 8.20 |規格のみ|規格違反の設計|
| [`test_structured_procedure_forms_and_subroutine_lifetimes`](../../tests/ch9/test_structured_procedure_forms_and_subroutine_lifetimes.sv) |initial は null 文を、各 always キーワードは文を、final は関数文を取り、task と function はクラス内で動的上書き指定子を、lifetime なし・static・automatic を ANSI または非 ANSI の本体で取る。lifetime がローカルの値を呼び出し間で保つかどうかを決める| 9.2 9.3.4 13.3.1 13.4.2 | Verilator 5.054 ||
| [`test_structured_procedure_kinds_each_run`](../../tests/ch9/test_structured_procedure_kinds_each_run.sv) |各種のプロセス 初期、常に、always_comb、always_latch、always_ff、最終、タスク、関数が実行され 結果を返します| 9.2 9.2.2.2 9.2.2.3 9.2.2.4 | Icarus Verilog 13.0 ||
| [`test_structured_procedures_enable_once_repeat_final`](../../tests/ch9/test_structured_procedures_enable_once_repeat_final.sv) |初期プロセスと常に実行されるプロセスは 時間 0 で始まり、初期プロセスは一度実行され、常に実行され るプロセスは $finish まで繰り返され、最終プロセスは終了時に一度実行されます。タスクと関数は呼び出されたときにのみ実行されます。| 9.2 9.2.1 9.2.2.1 9.2.3 | Icarus Verilog 13.0 ||
| [`test_syntax_structured_procedure_forms`](../../tests/ch9/test_syntax_structured_procedure_forms.sv) |A.6.2の初期、常に、always_comb , always_latch , always_ff、最終プロセスはそれぞれのボディを取って、それぞれの計算値をもって一度、繰り返し、あるいは最後に実行する。| 9.2 9.2.1 9.2.2.1 9.2.2.2 9.2.2.3 9.2.2.4 9.2.3 A.6.2 | Verilator 5.052 ||
| [`test_initial_block`](../../tests/ch9/test_initial_block.sv) |初期ブロックテスト| 9.2.1 | Icarus Verilog 13.0 ||
| [`test_initial_block_2`](../../tests/ch9/test_initial_block_2.sv) |初期ブロック実行| 9.2.1 | Icarus Verilog 13.0 ||
| [`test_initial_edge_cases`](../../tests/ch9/test_initial_edge_cases.sv) |初期ブロック端のケース| 9.2.1 | Icarus Verilog 13.0 ||
| [`test_initial_final`](../../tests/ch9/test_initial_final.sv) |初期・終了手続き| 9.2.1 9.2.3 | Icarus Verilog 13.0 ||
| [`test_always_at_signal_before_nonzero_delay`](../../tests/ch9/test_always_at_signal_before_nonzero_delay.sv) |変更が起こったときに起動し、遅延が終了する前に出力を更新する。| 9.2.2 9.4.2 | Icarus Verilog 13.0 ||
| [`test_always_body_event_control`](../../tests/ch9/test_always_body_event_control.sv) |常にプロセスは、ボディがイベント制御で始まる場合、すべてのイベントを計数します。| 9.2.2 9.4.2 15.5.1 | Icarus Verilog 13.0 ||
| [`test_always_parallel_block_finish`](../../tests/ch9/test_always_parallel_block_finish.sv) |ネストされた並列ブロックが最も遅いブランチを待つ間、過去の時間を常に繰り返す| 9.2.2.1 9.3.3 9.5 | Icarus Verilog 13.0 ||
| [`test_always_without_timing_control_never_advances_time`](../../tests/ch9/test_always_without_timing_control_never_advances_time.sv) |タイミング制御の無い always 手続きは、シミュレーション時刻を一度も進めずに文を繰り返すので、遅延したプロセスは決して実行されず、ループ内の $finish が時刻 0 でシミュレーションを終える| 9.2.2.1 |規格のみ||
| [`test_sequential_logic`](../../tests/ch9/test_sequential_logic.sv) |イベント制御を持つ常にプロセスのカウンタとレジスタ| 9.2.2.1 9.4.2 | Icarus Verilog 13.0 ||
| [`test_always_blocks`](../../tests/ch9/test_always_blocks.sv) |クロック生成| 9.2.2.2 9.2.2.4 | Icarus Verilog 13.0 ||
| [`test_always_comb`](../../tests/ch9/test_always_comb.sv) | always_comb | 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_2`](../../tests/ch9/test_always_comb_2.sv) |Always_comb テスト| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_3`](../../tests/ch9/test_always_comb_3.sv) | always_comb (§9.2.2.2) | 9.2.2.2 11.6.1 | Icarus Verilog 13.0 ||
| [`test_always_comb_4`](../../tests/ch9/test_always_comb_4.sv) |always_comb 入力に従って和と差を計算| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_5`](../../tests/ch9/test_always_comb_5.sv) |always_combは読み出した表現から感度を推定する| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_cascade_propagation`](../../tests/ch9/test_always_comb_cascade_propagation.sv) |always_comb カスケード連鎖伝搬| 9.2.2.2 4.4.2.3 | Icarus Verilog 13.0 ||
| [`test_always_comb_case_chain`](../../tests/ch9/test_always_comb_case_chain.sv) |always_comb always_combプロセスの連鎖| 9.2.2.2 12.5 | Icarus Verilog 13.0 ||
| [`test_always_comb_chain`](../../tests/ch9/test_always_comb_chain.sv) |入力変更後にalways_combブロックの連鎖が定着する| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_edge_cases`](../../tests/ch9/test_always_comb_edge_cases.sv) |Always_combエッジケース| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_independent_element_writers`](../../tests/ch9/test_always_comb_independent_element_writers.sv) |unpacked配列の1要素とベクトルの一部分をalways_combで書き込み、他の要素と部分を連続代入または別のalways_combで書き込むことができる。それぞれの最長の静的プレフィックスが重ならないためである。| 9.2.2.2 11.5.3 | Icarus Verilog 13.0 ||
| [`test_always_comb_latch`](../../tests/ch9/test_always_comb_latch.sv) |Always_comb /latch/ff テスト| 9.2.2.2 9.2.2.3 9.2.2.4 | Icarus Verilog 13.0 | x/z |
| [`test_always_comb_latch_ff`](../../tests/ch9/test_always_comb_latch_ff.sv) |always_comb , always_latchとalways_ffプロセス| 9.2.2.2 9.2.2.3 9.2.2.4 | Icarus Verilog 13.0 ||
| [`test_always_comb_perf`](../../tests/ch9/test_always_comb_perf.sv) |always_comb性能最適化テスト| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_reads_writes`](../../tests/ch9/test_always_comb_reads_writes.sv) |条件付き演算子を含む複数の読み書きを持つ always_comb| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_sens`](../../tests/ch9/test_always_comb_sens.sv) |always_comb感度| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_time_zero`](../../tests/ch9/test_always_comb_time_zero.sv) |always_comb は、すべての initial と always プロセスが開始された後、 time 0 で一度実行されます。always @* は変更を待ちます。| 9.2.2.2 9.2.2.2.2 | Icarus Verilog 13.0 ||
| [`test_barrel_shifter_edge_cases`](../../tests/ch9/test_barrel_shifter_edge_cases.sv) |バレルシフターエッジケース| 9.2.2.2 11.4.10 11.7 | Icarus Verilog 13.0 ||
| [`test_bcd_edge_cases`](../../tests/ch9/test_bcd_edge_cases.sv) |BCDエッジケース| 9.2.2.2 11.4.3 | Icarus Verilog 13.0 ||
| [`test_decoder4_edge_cases`](../../tests/ch9/test_decoder4_edge_cases.sv) |2 - to-4 デコーダエッジケース| 9.2.2.2 12.5 | Icarus Verilog 13.0 ||
| [`test_decoder_edge_cases`](../../tests/ch9/test_decoder_edge_cases.sv) |デコーダエッジケース| 9.2.2.2 11.5.1 | Icarus Verilog 13.0 ||
| [`test_demux_edge_cases`](../../tests/ch9/test_demux_edge_cases.sv) |DEMUXエッジケース| 9.2.2.2 12.5 | Icarus Verilog 13.0 ||
| [`test_dependency_chain`](../../tests/ch9/test_dependency_chain.sv) |always_combブロックの連鎖は、入力変更後に順番に更新される| 9.2.2.2 | Icarus Verilog 13.0 ||
| [`test_encoder_edge_cases`](../../tests/ch9/test_encoder_edge_cases.sv) |エンコーダエッジケース| 9.2.2.2 12.4 | Icarus Verilog 13.0 ||
| [`test_gray_edge_cases`](../../tests/ch9/test_gray_edge_cases.sv) |バイナリからグレイコードへと戻り、単一の bit プロパティを変更| 9.2.2.2 11.4.10 | Icarus Verilog 13.0 ||
| [`test_illegal_always_comb_other_writer`](../../tests/ch9/test_illegal_always_comb_other_writer.sv) |always_comb プロセスで割り当てられた変数は他のプロセスで書き込めません| 9.2.2.2 |規格のみ|規格違反の設計|
| [`test_mux4_edge_cases`](../../tests/ch9/test_mux4_edge_cases.sv) |4 - to-1 マルチプレクサエッジケース| 9.2.2.2 12.5 | Icarus Verilog 13.0 ||
| [`test_sensitivity_edge_cases`](../../tests/ch9/test_sensitivity_edge_cases.sv) |テスト: 感度リストエッジケース| 9.2.2.2 9.2.2.4 9.4.2 | Icarus Verilog 13.0 ||
| [`test_always_comb_class_object_args_only`](../../tests/ch9/test_always_comb_class_object_args_only.sv) |クラスオブジェクトのメソッドを呼び出し、そのメンバーを読み込む always_comb は、メンバーやハンドルに感度がなく、メソッドに渡された引数だけを感受的に読み込む。| 9.2.2.2.1 |規格のみ||
| [`test_always_comb_excluded_function_write`](../../tests/ch9/test_always_comb_excluded_function_write.sv) |always_comb が呼び出す関数が書き込む表現は 暗黙の感度から除外されます ブロックは入力変更ごとに一度実行されます| 9.2.2.2.1 | Icarus Verilog 13.0 ||
| [`test_always_comb_longest_static_prefix_and_locals`](../../tests/ch9/test_always_comb_longest_static_prefix_and_locals.sv) |always_comb bit は、ブロックまたは関数で宣言された変数ではなく、それとその関数が読み込むものの最長の静的なプレフィックスに感受的です。変数インデックスの場合は、全ての配列、定数の場合は、一つの［1］または要素です。| 9.2.2.2.1 9.2.2.2 11.5.3 |規格のみ||
| [`test_always_comb_qualified_function_calls`](../../tests/ch9/test_always_comb_qualified_function_calls.sv) |パッケージ関数、 :: で呼ばれた静的クラスメソッド、階層的名前で呼ばれた関数が読み込まれるかどうかに always_comb は感度を持ち、他の呼ばれた関数と同様に| 9.2.2.2.1 | Verilator 5.052 ||
| [`test_always_comb_reads_generate_scope_names`](../../tests/ch9/test_always_comb_reads_generate_scope_names.sv) |always_comb 生成ブロックのプロセスは、他の生成ブロックの階層的な名前を通して読み込んだ変数が変化したときに再実行されます。| 9.2.2.2.1 23.6 27.4 | Icarus Verilog 13.0 ||
| [`test_always_comb_sensitivity_exceptions`](../../tests/ch9/test_always_comb_sensitivity_exceptions.sv) |always_comb の暗黙感度は，それが書き込む変数，呼び出したタスクの内容，アサーションションアクションブロックの表現を省略するが，タスクの引数と直接アサーションションの表現を含む。| 9.2.2.2.1 9.2.2.2.2 16.3 |規格のみ||
| [`test_always_comb_timing_control_identifiers_not_sensitive`](../../tests/ch9/test_always_comb_timing_control_identifiers_not_sensitive.sv) |always_comb 内で非ブロッキング代入の intra-assignment の遅延・イベント・iff・repeat の制御にだけ現れる識別子は手続きを起こさず、右辺は起こす| 9.2.2.2.1 |規格のみ||
| [`test_always_comb_vs_always_star`](../../tests/ch9/test_always_comb_vs_always_star.sv) |always_comb は時間ゼロで実行され、常に@* とは異なり、呼び出された関数に読み込まれた変数に敏感です。| 9.2.2.2.2 9.2.2.2.1 9.4.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_always_comb_vs_star_assertion_in_function`](../../tests/ch9/test_always_comb_vs_star_assertion_in_function.sv) |always_comb で呼ばれた関数の直接的なアサーションの表現はその感度にあるが、同じ関数を常に@* で呼ぶと、その本体に書かれたアサーションにのみ感度がある。| 9.2.2.2.2 9.2.2.2.1 9.4.2.2 16.3 | Icarus Verilog 13.0 ||
| [`test_ch9_extra_star_multiple_writers`](../../tests/ch9/test_ch9_extra_star_multiple_writers.sv) |always_comb とは異なり、2つの always @* プロセスは同じ変数を書き込み、共有した入力が変化したときに両方とも実行できます。| 9.2.2.2.2 | Icarus Verilog 13.0 ||
| [`test_illegal_always_comb_delay`](../../tests/ch9/test_illegal_always_comb_delay.sv) |always_comb プロセスには遅延は含まれません| 9.2.2.2.2 9.2.2.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_comb_event_control`](../../tests/ch9/test_illegal_always_comb_event_control.sv) |always_comb プロセスはイベントコントロールを含められません| 9.2.2.2.2 9.2.2.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_comb_fork_join`](../../tests/ch9/test_illegal_always_comb_fork_join.sv) |always_comb プロセスはフォークジョイントを含められません| 9.2.2.2.2 9.3.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_comb_fork_statement`](../../tests/ch9/test_illegal_always_comb_fork_statement.sv) |always_combプロセスには fork-join_none 文は含まれません| 9.2.2.2.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_comb_wait`](../../tests/ch9/test_illegal_always_comb_wait.sv) |always_combプロセスは wait ステートメントを含めません| 9.2.2.2.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_always_latch`](../../tests/ch9/test_always_latch.sv) |Always_latch テスト| 9.2.2.3 | Icarus Verilog 13.0 ||
| [`test_always_latch_2`](../../tests/ch9/test_always_latch_2.sv) |always_latchは条件が false のときは出力を保持します| 9.2.2.3 | Icarus Verilog 13.0 ||
| [`test_always_latch_comb_in_interface`](../../tests/ch9/test_always_latch_comb_in_interface.sv) |always_latchとalways_combプロセスはモジュール内で実行されます。| 9.2.2.3 9.2.2.2 25.3 | Icarus Verilog 13.0 ||
| [`test_always_latch_edge_cases`](../../tests/ch9/test_always_latch_edge_cases.sv) |Always_latchエッジケース| 9.2.2.3 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_always_latch_delay`](../../tests/ch9/test_illegal_always_latch_delay.sv) |always_latch プロセスには遅延は含まれません| 9.2.2.3 9.2.2.2.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_latch_other_writer`](../../tests/ch9/test_illegal_always_latch_other_writer.sv) |always_latch プロセスで割り当てられた変数は他のプロセスで書き込めません| 9.2.2.3 9.2.2.2 |規格のみ|規格違反の設計|
| [`test_latch_edge_cases`](../../tests/ch9/test_latch_edge_cases.sv) |Dラッチでalways_latch : パスとホールド| 9.2.2.3 | Icarus Verilog 13.0 ||
| [`test_always_ff_async`](../../tests/ch9/test_always_ff_async.sv) |always_ff 非同期リセット| 9.2.2.4 4.7 | Icarus Verilog 13.0 ||
| [`test_always_ff_corner`](../../tests/ch9/test_always_ff_corner.sv) |always_ff 非同期と同期リセット、エンバート、カウンタ、シフトレジスタ| 9.2.2.4 4.7 | Icarus Verilog 13.0 | x/z |
| [`test_always_ff_edge_cases`](../../tests/ch9/test_always_ff_edge_cases.sv) |Always_ffエッジケース| 9.2.2.4 | Icarus Verilog 13.0 ||
| [`test_always_ff_simple`](../../tests/ch9/test_always_ff_simple.sv) |常に FF 単純テスト| 9.2.2.4 10.4.2 | Icarus Verilog 13.0 ||
| [`test_illegal_always_ff_delay`](../../tests/ch9/test_illegal_always_ff_delay.sv) |always_ff プロセスは遅延制御を含められません| 9.2.2.4 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_ff_no_event_control`](../../tests/ch9/test_illegal_always_ff_no_event_control.sv) |always_ffプロセスはイベント制御を含む必要がある。1つもないのは違法です| 9.2.2.4 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_ff_other_writer`](../../tests/ch9/test_illegal_always_ff_other_writer.sv) |always_ff プロセスで割り当てられた変数は他のプロセスで書き込めません| 9.2.2.4 9.2.2.2 |規格のみ|規格違反の設計|
| [`test_illegal_always_ff_two_event_controls`](../../tests/ch9/test_illegal_always_ff_two_event_controls.sv) |always_ff プロセスは、2 番目のイベント制御を含めることができません。| 9.2.2.4 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_always_ff_written_via_function`](../../tests/ch9/test_illegal_always_ff_written_via_function.sv) |プロセス always_ff が呼び出す関数によって割り当てられた変数は、他のプロセスによって書き込めません。| 9.2.2.4 |規格のみ|規格違反の設計|
| [`test_final`](../../tests/ch9/test_final.sv) |終了手続きは $finish の後に実行されます。連続的な代入を持つループを生成します| 9.2.3 27.4 | Icarus Verilog 13.0 ||
| [`test_final_block_2`](../../tests/ch9/test_final_block_2.sv) |ファイナルブロック実行| 9.2.3 | Icarus Verilog 13.0 ||
| [`test_final_blocks_sequential`](../../tests/ch9/test_final_blocks_sequential.sv) |最終手続きは最後のタイムステップの後に 順次実行される 任意の順序で 決定的な順序で それらの更新は どのブロックが最初に実行されるかを 決めることなく順序付けられます| 9.2.3 9.5 | Icarus Verilog 13.0 ||
| [`test_final_edge_cases`](../../tests/ch9/test_final_edge_cases.sv) |finalブロックの境界ケース| 9.2.3 | Icarus Verilog 13.0 ||
| [`test_final_finish_inside_final_ends_at_once`](../../tests/ch9/test_final_finish_inside_final_ends_at_once.sv) |終了手順の中で呼び出された $finish はシミュレーションを一旦終了させ、その終了手順の残りは実行されず、最終手順は二度と実行されません。| 9.2.3 | Icarus Verilog 13.0 ||
| [`test_final_vpi_control_finish_inside_final`](../../tests/ch9/test_final_vpi_control_finish_inside_final.sv) |vpi_control（vpiFinish , 0）は最終手続きの中のシステムタスクから呼び出されると一旦シミュレーションを終了し、残りの最終手続きは実行されず、再び実行されない。| 9.2.3 38.4 | Icarus Verilog 13.0 | VPI |
| [`test_illegal_final_procedure_delay`](../../tests/ch9/test_illegal_final_procedure_delay.sv) |終了手続きは 関数に許可された ステートメントしか含められません| 9.2.3 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_a6_4_statement_label_attributes_null`](../../tests/ch9/test_a6_4_statement_label_attributes_null.sv) |命令はブロック識別子プレフィックスと属性インスタンスを持つことができ、 null 命令は属性とセミコロンであり、命名された命令を無効にすると、その後の命令は停止します。| 9.3 9.6.2 A.6.4 | Verilator 5.052 ||
| [`test_block_statements_sequential_order_parallel_children`](../../tests/ch9/test_block_statements_sequential_order_parallel_children.sv) |始まり終わりブロックは 順番に それぞれのステートメントを実行し if と repeat の下で 1つのステートメントとして動作します ジョイン join_any または join_none を持つフォークブロックは それぞれの ステートメントを一緒に開始します| 9.3 9.3.1 9.3.2 | Icarus Verilog 13.0 ||
| [`test_syntax_sequential_and_parallel_block_forms`](../../tests/ch9/test_syntax_sequential_and_parallel_block_forms.sv) |宣言とヌルステートメントを持つ名前付きと名前なしの順序ブロック、および join、join_anyまたはjoin_noneで終わり、ラベルを持つ並列ブロックは、それらのステートメントを A.6.3のように順序付けます。| 9.3 9.3.1 9.3.2 9.3.3 A.6.3 A.6.4 | Icarus Verilog 13.0 ||
| [`test_begin_end`](../../tests/ch9/test_begin_end.sv) |順序ブロック| 9.3.1 | Icarus Verilog 13.0 ||
| [`test_begin_end_2`](../../tests/ch9/test_begin_end_2.sv) |テスト開始終了ブロック| 9.3.1 9.3.5 | Icarus Verilog 13.0 ||
| [`test_block_and_fork_grammar`](../../tests/ch9/test_block_and_fork_grammar.sv) |順序ブロックは 前のステートメントと 閉じる名前を宣言し 名前付きと名前なしのフォークブロックは ジョイン join_anyと join_noneと それらの終了ルールを取ります| 9.3.1 9.3.2 9.3.4 | Icarus Verilog 13.0 ||
| [`test_block_begin`](../../tests/ch9/test_block_begin.sv) |ブロックテストを開始| 9.3.1 12.4 | Icarus Verilog 13.0 ||
| [`test_block_item_declaration_kinds`](../../tests/ch9/test_block_item_declaration_kinds.sv) |順序ブロックと並列ブロックはブロック項目の宣言を受け入れます。データ宣言、localparam 、パラメータ、そして let 宣言で、それぞれの前に任意の数の属性インスタンスがある。| 9.3.1 9.3.2 11.12 A.2.8 | Verilator 5.052 ||
| [`test_block_scope_shadowing`](../../tests/ch9/test_block_scope_shadowing.sv) |異なるネストされた始末ブロックに同じ名前の変数| 9.3.1 6.21 23.9 | Icarus Verilog 13.0 ||
| [`test_scope_nba`](../../tests/ch9/test_scope_nba.sv) |NBA (非ブロック) 代入を持つブロックスコープ変数| 9.3.1 10.4.2 23.9 6.21 | Icarus Verilog 13.0 ||
| [`test_stmt_begin_end`](../../tests/ch9/test_stmt_begin_end.sv) |始末ブロックのテスト| 9.3.1 | Icarus Verilog 13.0 ||
| [`test_fork_automatic_declaration_per_iteration`](../../tests/ch9/test_fork_automatic_declaration_per_iteration.sv) |フォークブロックに宣言された自動変数は、 for、while、do-while ループの各スパウンドプロセスでその反復のループ値を取得します。| 9.3.2 6.21 | Verilator 5.052 ||
| [`test_fork_child_zero_delay`](../../tests/ch9/test_fork_child_zero_delay.sv) |#0 で始まるフォークブランチは、遅延なくブランチの後で実行されます。| 9.3.2 9.4.1 4.4.2.3 | Icarus Verilog 13.0 ||
| [`test_fork_join_block_timing`](../../tests/ch9/test_fork_join_block_timing.sv) |ジョインを持つネストされた順序ブロックと並列ブロックの開始と終了時間、join_anyとjoin_none| 9.3.2 9.3.3 | Icarus Verilog 13.0 ||
| [`test_illegal_fork_join_any_reads_ref_formal`](../../tests/ch9/test_illegal_fork_join_any_reads_ref_formal.sv) |フォーク-join_anyブロックの文は、包含タスクのref形式の引数を参照できません。| 9.3.2 |規格のみ|規格違反の設計|
| [`test_illegal_fork_join_none_reads_ref_formal`](../../tests/ch9/test_illegal_fork_join_none_reads_ref_formal.sv) |フォーク-join_noneブロックの文は、包含タスクのref形式の引数を参照できません。| 9.3.2 |規格のみ|規格違反の設計|
| [`test_illegal_function_contains_fork_join`](../../tests/ch9/test_illegal_function_contains_fork_join.sv) |関数はフォークジョイントブロックを含められません| 9.3.2 13.4 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_function_contains_fork_join_any`](../../tests/ch9/test_illegal_function_contains_fork_join_any.sv) |関数には fork-join_any ブロックは含まれません| 9.3.2 13.4 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_return_inside_fork`](../../tests/ch9/test_illegal_return_inside_fork.sv) |フォークジョイントブロック内の return 命令はコンパイルエラーです| 9.3.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_join_none_children_start_after_parent_blocks`](../../tests/ch9/test_join_none_children_start_after_parent_blocks.sv) |フォーク-join_none によって生成されたプロセスは、親ブロックがブロックされるまでは起動しません。したがって、その時点で静的ループ変数の値を見ることができます。| 9.3.2 | Icarus Verilog 13.0 ||
| [`test_ref_static_fork_join_none_after_return`](../../tests/ch9/test_ref_static_fork_join_none_after_return.sv) |fork-join_none で生成したプロセスはタスクが戻った後も ref static 引数を読み書きでき、その時点の呼び出し側の変数に到達するが、通常の ref 引数はそこでは fork ブロックの変数の初期化にしか使えない| 9.3.2 13.5.2 6.21 |規格のみ||
| [`test_block_variable_static_and_automatic_lifetimes`](../../tests/ch9/test_block_variable_static_and_automatic_lifetimes.sv) |static なブロック・task・function の中の lifetime 修飾の無い変数は入るたびに値を保ち、明示的に automatic の変数、automatic な task・function・ブロックの変数、クラスメソッドの変数、宣言した for ループ変数は入るたびに新しく、起動の間で共有されない| 9.3.4 6.21 | Verilator 5.054 ||
| [`test_ch9_extra_unnamed_block_scope`](../../tests/ch9/test_ch9_extra_unnamed_block_scope.sv) |順序ブロックの名前なしの範囲に属する変数は階層的な名前でアクセスできません| 9.3.4 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_end_name_differs_from_begin_name`](../../tests/ch9/test_illegal_end_name_differs_from_begin_name.sv) |ブロック名は ブロック名の後に付けられる| 9.3.4 9.3.1 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_generate_block_end_name_differs`](../../tests/ch9/test_illegal_generate_block_end_name_differs.sv) |生成ブロックの終わりの名前は ブロックの名前でなければなりません| 9.3.4 27.3 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_join_any_name_differs_from_fork_name`](../../tests/ch9/test_illegal_join_any_name_differs_from_fork_name.sv) |join_any の後のブロック名は フォークの後に与えられたブロックの名前でなければなりません| 9.3.4 9.3.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_join_name_differs_from_fork_name`](../../tests/ch9/test_illegal_join_name_differs_from_fork_name.sv) |ジョイン後のブロック名は フォーク後のブロック名でなければなりません| 9.3.4 9.3.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_join_none_name_differs_from_fork_name`](../../tests/ch9/test_illegal_join_none_name_differs_from_fork_name.sv) |join_none の後のブロック名は フォークの後に与えられたブロックの名前でなければなりません| 9.3.4 9.3.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_named_block_hier_write`](../../tests/ch9/test_named_block_hier_write.sv) |階層的に名前付けブロックの変数に書き込み、そしてその変数に対する強制| 9.3.4 23.6 10.4.2 10.6.2 | Icarus Verilog 13.0 ||
| [`test_named_block_scope_hierarchical`](../../tests/ch9/test_named_block_scope_hierarchical.sv) |名前付きブロック範囲階層的アクセス| 9.3.4 23.6 6.21 | Icarus Verilog 13.0 | x/z |
| [`test_named_blocks_scope_items_and_disable`](../../tests/ch9/test_named_blocks_scope_items_and_disable.sv) |名前付きbeginブロックと名前付きforkブロックは、それぞれスコープを作る。その変数、ローカルパラメータ、名前付きイベントには、別のプロセスからブロック名を介してアクセスでき、名前付きforkブロックは名前を指定してdisableできる。| 9.3.4 9.6.2 | Icarus Verilog 13.0 ||
| [`test_assertion_label`](../../tests/ch9/test_assertion_label.sv) |前のラベルを持つ並行アサーションは デザインの隣に 詳細に行われます| 9.3.5 | Verilator 5.052 ||
| [`test_generate_block_label_before_begin`](../../tests/ch9/test_generate_block_label_before_begin.sv) |ブロックの名前は ブロックの開始前に書かれたラベルで決められます ブロックの中で宣言されたアイテムは その名前を通して アクセスされます| 9.3.5 27.3 | Verilator 5.052 ||
| [`test_illegal_statement_label_and_block_name`](../../tests/ch9/test_illegal_statement_label_and_block_name.sv) |begin ブロックには 前にステートメントラベルと 後にブロック名が同時に存在できません| 9.3.5 9.3.4 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_statement_label_and_fork_name`](../../tests/ch9/test_illegal_statement_label_and_fork_name.sv) |フォークブロックには 前にステートメントラベルと後にブロック名が 両方ともできません| 9.3.5 9.3.4 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_statement_label_before_end`](../../tests/ch9/test_illegal_statement_label_before_end.sv) |文のラベルは 文ではない end の前に置けません| 9.3.5 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_statement_label_before_join`](../../tests/ch9/test_illegal_statement_label_before_join.sv) |ジョインの前にラベルを置くことはできません| 9.3.5 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_statement_label_before_join_any`](../../tests/ch9/test_illegal_statement_label_before_join_any.sv) |join_any の前に文のラベルを置くことはできません。| 9.3.5 | Verilator 5.052 |規格違反の設計|
| [`test_illegal_statement_label_before_join_none`](../../tests/ch9/test_illegal_statement_label_before_join_none.sv) |join_none の前に文のラベルを置くことはできません。| 9.3.5 | Verilator 5.052 |規格違反の設計|
| [`test_statement_labels_name_blocks`](../../tests/ch9/test_statement_labels_name_blocks.sv) |ブロックの名前は、キーワードの後のブロック名と同じように、beginまたはforkの前のラベルで指定されます。 forループのラベルは、宣言された変数を持つループの名前を指定します。 foreachループのラベル は、ループの暗黙のブロックの名前を指 定します。それぞれの名前で参照され 機能を停止できます| 9.3.5 9.3.4 9.6.2 |規格のみ||
| [`test_a6_5_event_trigger_forms`](../../tests/ch9/test_a6_5_event_trigger_forms.sv) |ブロッキングイベントトリガは即座にイベントを発生させ、遅延付きのノンブロッキングイベントトリガは、指定した時間単位数だけ後に発生させます。そのため、イベントを待つプロセスは、時刻1、5、11を記録します。| 9.4 15.5.2 15.5.3 A.6.5 |規格のみ||
| [`test_illegal_comma_event_expression_positional_actual`](../../tests/ch9/test_illegal_comma_event_expression_positional_actual.sv) |コンマで区切られた部分を持つイベント表現は 位置関数として渡されるため 括弧が必要です| 9.4 16.8.2 |規格のみ|規格違反の設計|
| [`test_syntax_star_event_controls`](../../tests/ch9/test_syntax_star_event_controls.sv) |"@*"と"@(*)"はそれぞれのシグナルを待ち、そのシグナルが変化したときにそのシグナルを実行します。| 9.4 9.4.2 A.6.5 | Icarus Verilog 13.0 ||
| [`test_syntax_timing_control_and_event_expressions`](../../tests/ch9/test_syntax_timing_control_and_event_expressions.sv) |遅延、イベント、繰り返しイベント制御は A.6.5 の前に置かれ、イベント表現はエッジ、iff、or、コンマ、括弧、パッケージまたは階層識別子を持つ形式でそれぞれのイベントで起動される。| 9.4 9.4.1 9.4.2 9.4.3 A.6.5 A.6.4 | Verilator 5.052 ||
| [`test_timing_control_delay_event_wait_forms`](../../tests/ch9/test_timing_control_delay_event_wait_forms.sv) |遅延制御の各形式、識別子・階層識別子・括弧付きの式による @、エッジと値変化の式、or・コンマ・括弧付きのイベント式、@* と @(*)、代入の中の遅延とイベントの制御、文付きと null 文の wait、wait fork は、それぞれ刺激が決める時刻に再開する| 9.4 | Icarus Verilog 13.0 ||
| [`test_timing_control_iff_sequence_cycle_wait_order_forms`](../../tests/ch9/test_timing_control_iff_sequence_cycle_wait_order_forms.sv) |パッケージスコープの識別子による @、ブロッキングと非ブロッキングの代入の中の repeat イベント制御、エッジの後とシーケンスインスタンスの後の iff、イベントとしてのシーケンスインスタンス、null 文付きと文付きのサイクル遅延、pass 文と fail 文を持つ wait_order は、それぞれ刺激が決める時刻に再開する| 9.4 |規格のみ||
| [`test_timing_controls_forms`](../../tests/ch9/test_timing_controls_forms.sv) |遅延、イベント、レベル感度の待ち制御は、繰り返し、エッジ、名前付きイベント、または/コンマ、括弧付きの形で、ステートメントを遅延させ、それぞれの条件が修正された時点で再開します。| 9.4 9.4.2 9.4.3 | Icarus Verilog 13.0 ||
| [`test_assign_delay_edge_cases`](../../tests/ch9/test_assign_delay_edge_cases.sv) |テスト：代入遅延エッジ事例| 9.4.1 9.4.2 9.4.5 | Icarus Verilog 13.0 ||
| [`test_ch9_extra_specparam_delay`](../../tests/ch9/test_ch9_extra_specparam_delay.sv) |プロセス遅延制御は specparam から値を取って その値で遅延時間を進める| 9.4.1 | Icarus Verilog 13.0 ||
| [`test_delay_negative_value_is_unsigned_time`](../../tests/ch9/test_delay_negative_value_is_unsigned_time.sv) |遅延制御の式が負の int の場合、その値を 64-bit の符号なし時間として解釈して待機します。このため #(-10) は 2 ** 64-10 で再開します。| 9.4.1 | Icarus Verilog 13.0 ||
| [`test_delay_x_z_value_is_zero_delay`](../../tests/ch9/test_delay_x_z_value_is_zero_delay.sv) |すべての x またはすべての z の表現を持つ遅延制御は # 0 のように待ちますが、時間を進めません| 9.4.1 4.4.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_timing_edge_cases`](../../tests/ch9/test_timing_edge_cases.sv) |タイミングエッジ事例テスト| 9.4.1 9.4.5 9.4.2 | Icarus Verilog 13.0 ||
| [`test_A_extra_event_expressions`](../../tests/ch9/test_A_extra_event_expressions.sv) |イベント式には、任意のエッジ指定とiff条件を伴う式、iff条件を伴うシーケンスインスタンス、or・コンマによる結合、括弧を使用できます。各形式で、それぞれのイベントによりプロセスが再開します。| 9.4.2 9.4.3 16.8 A.6.5 | Verilator 5.052 ||
| [`test_clocked_value_timing`](../../tests/ch9/test_clocked_value_timing.sv) |クロック付きの常に手順で更新される変数、各エッジの後に1時間単位読み込み| 9.4.2 10.4.2 | Icarus Verilog 13.0 ||
| [`test_clocking_sampled_event`](../../tests/ch9/test_clocking_sampled_event.sv) |クロックブロック入力または出力のイベント制御は、クロックイベントによってサンプルされた値を使用します、サンプルされていない信号ではありません。| 9.4.2 | Verilator 5.052 ||
| [`test_edge_detection`](../../tests/ch9/test_edge_detection.sv) |エッジ検出テスト| 9.4.2 10.4.2 | Icarus Verilog 13.0 ||
| [`test_edge_event_never_changes`](../../tests/ch9/test_edge_event_never_changes.sv) |9-2 の遷移においてのみ @(edge v) が再開されますが、初期 x を保持する変数に対しては決して再開されません。| 9.4.2 | Icarus Verilog 13.0 | x/z |
| [`test_edge_event_vector_lsb_only`](../../tests/ch9/test_edge_event_vector_lsb_only.sv) |posedge , negedgeと4 - bit bitベクトル上のエッジは最小有意値のみに従うが、普通のイベント制御はどんな変化にも起動する。| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_edge_matrix`](../../tests/imported/ch9/test_edge_matrix.sv) |posedge , negedge，エッジと変数の変化，0 , 1，xとzの間のすべての遷移，bit，ベクトルの最小有意値，上位ビットのみ，bit‐select，ネット，常に待ち，初期，自動タスク，フォーク| 9.4.2 9.4.2.3 |規格のみ|上部モジュール x/z|
| [`test_edge_table_all_scalar_transitions`](../../tests/ch9/test_edge_table_all_scalar_transitions.sv) |0 , 1, x, z の間の 16 のスカラー遷移は それぞれ posedge , negedge を起こし 端イベントは 表9-2のように 制御されます| 9.4.2 | Icarus Verilog 13.0 | x/z |
| [`test_event_chain_propagation`](../../tests/ch9/test_event_chain_propagation.sv) |常に@（信号）ブロックの連鎖が一つのタイムスロットに定着する| 9.4.2 4.4.2.2 | Icarus Verilog 13.0 ||
| [`test_event_control_on_expression`](../../tests/ch9/test_event_control_on_expression.sv) |演算子表現のイベント制御は、表現の値の変化を待ち、演算子の変化を待たない| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_event_control_posedge`](../../tests/ch9/test_event_control_posedge.sv) |初期ブロックで @(posedge clk) を待つ| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_event_ctrl`](../../tests/ch9/test_event_ctrl.sv) |イベント制御| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_event_method_dependency`](../../tests/ch9/test_event_method_dependency.sv) |関数や内蔵メソッドが使うオブジェクトメンバー、集合要素、動的サイズの変更は、それを読み取るイベントコントロールを起動させます。| 9.4.2 | Verilator 5.052 ||
| [`test_event_nested_struct_member`](../../tests/ch9/test_event_nested_struct_member.sv) |ネストされた packed 構造のメンバーに対するイベント制御は、そのメンバーの変更にのみ起動します。| 9.4.2 7.2.1 6.8 | Icarus Verilog 13.0 ||
| [`test_illegal_event_control_on_unpacked_array`](../../tests/ch9/test_illegal_event_control_on_unpacked_array.sv) |整数列 unpacked 上のイベント制御は不法である。イベント表現は特異値を返さなければならない。| 9.4.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_illegal_event_non_singular_method`](../../tests/ch9/test_illegal_event_non_singular_method.sv) |返すタイプが特異でない 非仮想オブジェクトメソッドは イベント制御に使えません| 9.4.2 |規格のみ|規格違反の設計|
| [`test_multi_sensitivity_list`](../../tests/ch9/test_multi_sensitivity_list.sv) |多信号感度リストテスト| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_sens_level`](../../tests/ch9/test_sens_level.sv) |レベル感度| 9.4.2 4.7 | Icarus Verilog 13.0 | x/z |
| [`test_sens_multi`](../../tests/ch9/test_sens_multi.sv) |多重感度| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_value_history_clocked`](../../tests/ch9/test_value_history_clocked.sv) |変数の前の値をクロックエッジを越えて一つのプロセスに保持| 9.4.2 | Icarus Verilog 13.0 ||
| [`test_zero_width_pulse_wakes_edge_control`](../../tests/ch9/test_zero_width_pulse_wakes_edge_control.sv) |時間ステップ内で 0 から 1 へと戻る変数は、 posedge と negedge の両方のイベント制御を起動します。| 9.4.2 4.3 | Icarus Verilog 13.0 ||
| [`test_event_or_iff`](../../tests/ch9/test_event_or_iff.sv) |または、コンマイベント演算子、イベントが発生したときにのみチェックされる iff 条件| 9.4.2.1 9.4.2.3 9.4.2 | Verilator 5.052 ||
| [`test_event_or_mixed_comma_forms`](../../tests/ch9/test_event_or_mixed_comma_forms.sv) |混合コンマや感度形式は同じ分離した入力遷移で起動します| 9.4.2.1 | Icarus Verilog 13.0 ||
| [`test_always_star_for_loop_ieee`](../../tests/ch9/test_always_star_for_loop_ieee.sv) |テスト: ループ変数の場合は NOT が感度リストにある必要があります| 9.4.2.2 | Icarus Verilog 13.0 ||
| [`test_implicit_event`](../../tests/ch9/test_implicit_event.sv) |@* のテスト (暗黙イベント制御) - IEEE 1800-2023 § 9.4.2.2| 9.4.2.2 | Icarus Verilog 13.0 ||
| [`test_star_sensitivity_contexts_and_exclusions`](../../tests/ch9/test_star_sensitivity_contexts_and_exclusions.sv) |文の中で読み込まれたすべてのネットと変数に対して感度が高く、右側では関数引数として、ケース表現とケース項目として、条件表現として、書き込まれた変数のインデックスとして、文がそれらを書き込んだ場合でも、@*は書き込まれただけの変数には感度が高くありません。| 9.4.2.2 | Icarus Verilog 13.0 ||
| [`test_star_timing_control_identifiers_excluded`](../../tests/ch9/test_star_timing_control_identifiers_excluded.sv) |@*文の中で、wait条件、遅延、イベント制御の内部にだけ現れる識別子は、@*のイベント式には含まれない。一方、その文が他の箇所で読み取る変数は含まれる。| 9.4.2.2 |規格のみ||
| [`test_illegal_automatic_variable_as_sequence_event_argument`](../../tests/ch9/test_illegal_automatic_variable_as_sequence_event_argument.sv) |イベント制御に使われる シーケンスの引数は 自動変数ではなく 静的でなければなりません| 9.4.2.4 16.8 | Verilator 5.052 |規格違反の設計|
| [`test_sequence_as_event_control`](../../tests/ch9/test_sequence_as_event_control.sv) |イベント制御として使用される名前付きシーケンスは、マッチの終了時にプロセスを再開します。| 9.4.2.4 16.8 | Verilator 5.052 ||
| [`test_sequence_event_nba_visibility`](../../tests/ch9/test_sequence_event_nba_visibility.sv) |シーケンスイベントを待つプロセスは 観測領域の後に再開します それで同じクロックエッジで ブロックしない更新が行われます| 9.4.2.4 | Verilator 5.052 ||
| [`test_ch9_extra_wait_forms`](../../tests/ch9/test_ch9_extra_wait_forms.sv) |wait (表現) は 文または null 文を受け取り、 wait fork は呼び出しプロセスの 子プロセスを待ちます| 9.4.3 9.6.1 | Icarus Verilog 13.0 ||
| [`test_wait_on_array_size`](../../tests/ch9/test_wait_on_array_size.sv) |キューおよび動的配列のsize()を待つwaitは、push_backまたはnew \[ \]によってサイズが変わると再開する| 9.4.3 7.10.2.7 7.5.1 | Icarus Verilog 13.0 ||
| [`test_wait_sequence_same_slot_twice`](../../tests/ch9/test_wait_sequence_same_slot_twice.sv) |既にトリガされたシーケンスの二度目の待ちは同じ時間ステップで完了します| 9.4.4 16.13.5 |規格のみ||
| [`test_wait_sequence_triggered`](../../tests/ch9/test_wait_sequence_triggered.sv) |命名されたシーケンスのトリガされたメソッドに対する wait ステートメントは、シーケンスが終点に到達する時間ステップでブロックを解除し、時間が進むと再び false になります。| 9.4.4 16.9.11 16.13.6 9.4.3 |規格のみ||
| [`test_a6_5_procedural_timing_control_statement`](../../tests/ch9/test_a6_5_procedural_timing_control_statement.sv) |サイクル遅延で始まる手続き文は、default clockingブロックのイベントを指定回数待ちます。そのため、3つの文は第1・第3・第4のposedgeで実行されます。| 9.4.5 14.11 A.6.5 | Verilator 5.052 ||
| [`test_intra_assignment_repeat_nonblocking`](../../tests/ch9/test_intra_assignment_repeat_nonblocking.sv) |非ブロッキング割当は，割当内の繰り返しイベント制御を持ち，実行時に右手の値を取って与えられたイベント数の後に割当る。カウントは一度評価され 0以下のカウントは待たずに割り当てられます| 9.4.5 10.4.2 | Icarus Verilog 13.0 ||
| [`test_intra_assignment_timing`](../../tests/imported/ch9/test_intra_assignment_timing.sv) |命令が実行されるときに，命令の右側を計算するために，アシスト内の遅延またはイベント制御を用いる。ブロッキングはコントロールに合致したときに割り当て、 ターゲットの要素を選択します。 遅延を持つノンブロッキングは、 ステートメントが NBA 領域で実行されると、 それ以降の数時間のステップで、 選択したターゲットを更新します。| 9.4.5 10.4.1 10.4.2 4.9.4 | Icarus Verilog 13.0 ||
| [`test_intra_event_blocking_saves_rhs`](../../tests/ch9/test_intra_event_blocking_saves_rhs.sv) |代入内イベント制御を持つブロッキング代入は、その文に到達したときに右辺を読み取り、イベントまでプロセスをブロックし、その後で初めて保存した値を書き込む。| 9.4.5 | Icarus Verilog 13.0 ||
| [`test_intra_repeat_count_not_positive_or_unknown`](../../tests/ch9/test_intra_repeat_count_not_positive_or_unknown.sv) |代入内のrepeatイベント制御は、回数がゼロ、負、x、zの場合、イベントを待たずに直ちに代入する。正の回数の場合は、その回数のイベントを待つ。| 9.4.5 |規格のみ| x/z |
| [`test_syntax_intra_assignment_timing_forms`](../../tests/ch9/test_syntax_intra_assignment_timing_forms.sv) |ブロックアサーションは、アサーション内の#遅延、#(表現)、イベント制御、繰り返しイベント制御および名前付きイベント制御を持ち、ブロックアッセーイは、各種制御を持たず、またはそれらを持たない。| 9.4.5 10.4.1 10.4.2 A.6.2 A.6.4 A.6.5 | Icarus Verilog 13.0 ||
| [`test_ch9_extra_continuous_thread`](../../tests/ch9/test_ch9_extra_continuous_thread.sv) |それぞれの連続的な代入は 独立して それぞれのソースを追跡し それらの連鎖は 次のタイムステップの前に 決定される 別々の連続的なスレッドがするように| 9.5 | Icarus Verilog 13.0 ||
| [`test_process_thread_kinds_and_final_process`](../../tests/ch9/test_process_thread_kinds_and_final_process.sv) |initial 手続きのすべてのインスタンス、各 always・ always_comb ・ always_latch ・ always_ff 手続き、fork-join・ join_any ・ join_none の各並列文、各動的プロセスはそれぞれ自分のスレッドで実行され、always 手続きは繰り返しの間 1 つのスレッドを保ち、final 手続きは 1 つのプロセスから実行される| 9.5 9.2.3 |規格のみ||
| [`test_process_threads_distinct`](../../tests/ch9/test_process_threads_distinct.sv) |各初期、常に、最終手続き、フォークの各並列命令、fork-join_noneによって開始された各プロセスは、それぞれ独自のスレッドとして実行されます。| 9.5 9.7 9.3.2 | Verilator 5.052 ||
| [`test_process_control_statement_forms`](../../tests/ch9/test_process_control_statement_forms.sv) |プロセス制御の各形式は 構文に従って実行されます 表現とステートメントまたは null ステートメントとともに待ち、 各種アクションブロックとともに フォークを待ち、 wait_order、 タスク、ブロック、フォークを無効にします| 9.6 15.5.4 |規格のみ||
| [`test_process_control_wait_disable_parentage`](../../tests/ch9/test_process_control_wait_disable_parentage.sv) |wait forkは自身のプロセスの子だけを待ちます。名前付きdisableは、無関係なプロセスやブロックの子からでもそのブロックを終了し、disable forkは自身のプロセスの子だけを終了します。| 9.6 9.6.1 9.6.2 9.6.3 | Icarus Verilog 13.0 ||
| [`test_syntax_disable_and_wait_forms`](../../tests/ch9/test_syntax_disable_and_wait_forms.sv) |タスク・名前付きブロック・forkのdisable、文または空文を伴うwait(expression)、wait forkにより、A.6.5と9.6が定めるプロセスだけを停止・待機させます。| 9.6 9.6.1 9.6.2 9.6.3 A.6.5 A.6.4 | Icarus Verilog 13.0 ||
| [`test_sim_ends_when_no_activity_remains`](../../tests/ch9/test_sim_ends_when_no_activity_remains.sv) |$finish がなければ、シミュレーションは最後のスケジュールされたイベントの後に自動的に終了します。alwaysプロセスがまだ来ないイベントを待っているにもかかわらず、最後のプロセスが実行されます。| 9.6.1 9.2.3 | Icarus Verilog 13.0 ||
| [`test_sim_ends_when_programs_finish`](../../tests/ch9/test_sim_ends_when_programs_finish.sv) |プログラムの最初の手順が終わったら シミュレーションは終了しますが、プログラムがフォークした子プロセスとモジュールプロセスはまだ待っています| 9.6.1 24.3 |規格のみ||
| [`test_wait_fork_disable_fork`](../../tests/ch9/test_wait_fork_disable_fork.sv) |wait fork は直接的な子プロセスのみを待ち、disable fork はすべての子プロセスを終了させます| 9.6.1 9.6.3 9.3.2 | Verilator 5.052 ||
| [`test_wait_fork_ignores_grandchildren`](../../tests/ch9/test_wait_fork_ignores_grandchildren.sv) |プロセスの直接の子プロセスだけを待つのです 子プロセスが始めたプロセスは待たないのです| 9.6.1 9.3.2 | Icarus Verilog 13.0 ||
| [`test_wait_fork_without_children`](../../tests/ch9/test_wait_fork_without_children.sv) |子プロセスがないプロセスの wait fork は他のプロセスが子プロセスを実行している間にも一度に続行されます| 9.6.1 | Icarus Verilog 13.0 ||
| [`test_disable_advanced`](../../tests/ch9/test_disable_advanced.sv) |ステートメントの高度なテストを無効にする| 9.6.2 12.8 | Icarus Verilog 13.0 ||
| [`test_disable_automatic_task_all_executions`](../../tests/ch9/test_disable_automatic_task_all_executions.sv) |自己無効化するタスクは それ自身のみを終了する returnとは違って それ自身の同時実行を終了する自動タスクの中のブロックを無効にすると 実行するたびにブロックが終了します| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_block`](../../tests/ch9/test_disable_block.sv) |disable 命令のテスト| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_block_not_executing_no_effect`](../../tests/ch9/test_disable_block_not_executing_no_effect.sv) |ブロックの名前を変更しても効果はありません。 次の実行は終了し、 変更プロセスは次のステートメントで続きます。| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_enclosing_task`](../../tests/ch9/test_disable_enclosing_task.sv) |呼び出したタスクを無効にするタスクは、両方のアクティベーションを終了し、外部タスクの呼び出し者が続行します。| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_named_block_with_forks`](../../tests/ch9/test_disable_named_block_with_forks.sv) |フォークが開始した名前付けブロックを終了させます...join_none とすると、ブロックの disable はその中のフォークされたプロセスを終了させます。| 9.6.2 9.3.2 | Icarus Verilog 13.0 ||
| [`test_disable_stmt_2`](../../tests/ch9/test_disable_stmt_2.sv) |ステートメントテストを無効にする| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_stmt_3`](../../tests/ch9/test_disable_stmt_3.sv) |命名ブロック、ネストブロック、ループを含むブロックを無効にします| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_stmt_edge_cases`](../../tests/ch9/test_disable_stmt_edge_cases.sv) |テスト: 文の端の大文字を無効にする| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_task_from_another_process`](../../tests/ch9/test_disable_task_from_another_process.sv) |タスクの名前で disable を実行すると、タスクの実行中の活性化はすべて終了し、各コールはその呼び出し後に再開されます。| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_wait`](../../tests/ch9/test_disable_wait.sv) |プロセス制御| 9.6.2 9.4.3 | Icarus Verilog 13.0 ||
| [`test_illegal_disable_function`](../../tests/ch9/test_illegal_disable_function.sv) |関数は無効化できませんが 関数内の名前付きブロックや タスク自体が無効化されます| 9.6.2 | Icarus Verilog 13.0 |規格違反の設計|
| [`test_named_block_disable`](../../tests/ch9/test_named_block_disable.sv) |名前付きブロックの無効化をテスト| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_stmt_disable`](../../tests/ch9/test_stmt_disable.sv) |disable 命令のテスト| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_stmt_disable_2`](../../tests/ch9/test_stmt_disable_2.sv) |ステートメントテストを無効にする| 9.6.2 | Icarus Verilog 13.0 ||
| [`test_task_disable`](../../tests/ch9/test_task_disable.sv) |タスク内の名前付きブロックを無効にするテスト| 9.6.2 13.3 | Verilator 5.052 ||
| [`test_task_disable_2`](../../tests/ch9/test_task_disable_2.sv) |タスクテストで無効にする| 9.6.2 13.3 | Verilator 5.052 ||
| [`test_disable_fork_dynamic_vs_named_static`](../../tests/ch9/test_disable_fork_dynamic_vs_named_static.sv) |disable forkは、別プロセスが同じコードを実行していても、呼出しプロセスが生成したプロセスだけを終了します。一方、名前付きブロックのdisableは、生成元にかかわらず、そのブロックを実行中の全プロセスで終了させます。| 9.6.3 9.6.2 | Icarus Verilog 13.0 ||
| [`test_disable_fork_ends_loops_and_class_tasks`](../../tests/ch9/test_disable_fork_ends_loops_and_class_tasks.sv) |クラスタスクを実行する子プロセスと while 内で待ち受ける子プロセスを終了させます| 9.6.3 9.3.2 | Icarus Verilog 13.0 ||
| [`test_illegal_class_extends_process`](../../tests/ch9/test_illegal_class_extends_process.sv) |内蔵されたクラスプロセスは拡張できません| 9.7 |規格のみ|規格違反の設計|
| [`test_illegal_new_process_object`](../../tests/ch9/test_illegal_new_process_object.sv) |プロセスオブジェクトは 新しいオブジェクトを作成できません| 9.7 |規格のみ|規格違反の設計|
| [`test_process_await_from_fork_child`](../../tests/ch9/test_process_await_from_fork_child.sv) |フォークによって開始されたプロセスで呼び出された await() は、待ち受けるプロセスが終了したとき、または既に終了した場合はすぐに返します。| 9.7 9.3.2 |規格のみ||
| [`test_process_class_control`](../../tests/ch9/test_process_class_control.sv) |プロセスクラス: self, status, kill| 9.7 | Verilator 5.052 ||
| [`test_process_kill_self`](../../tests/ch9/test_process_kill_self.sv) |プロセス自体が kill() を呼び出すと、他のプロセスによって 殺された場合と同様に、すぐに KILLED の状態で終了します。| 9.7 |規格のみ||
| [`test_process_kill_terminates_descendants`](../../tests/ch9/test_process_kill_terminates_descendants.sv) |kill()は、戻る前に対象プロセスと、そのプロセスがforkした子・孫プロセスを終了させる。また、既に完了したプロセスに対するkill()でも、実行中の子プロセスは終了する。| 9.7 |規格のみ||
| [`test_process_random_state`](../../tests/ch9/test_process_random_state.sv) |std::processのsrandom(seed)はプロセスの乱数状態を初期化し、同じseedで同じ列を再現します。get_randstate()は状態を文字列として返し、その文字列を渡すset_randstate()により、以後の値の列を再現できます。| 9.7 18.13.3 18.13.4 18.13.5 G.6 | Verilator 5.052 ||
| [`test_process_randstate_signatures`](../../tests/ch9/test_process_randstate_signatures.sv) |プロセスは int のシードを取って get_randstate を返し、 set_randstate はその文字列を使って次のランダムな値を再現します。| 9.7 | Verilator 5.052 ||
| [`test_process_resume_waiting_resensitizes`](../../tests/ch9/test_process_resume_waiting_resensitizes.sv) |プロセスを停止する場合は、 返す前に SUSPENDED にするために、 待ち条件と遅延を設定します。条件が既に真であれば、または遅延が過ぎた場合、一度に続けます。そうでなければ、次のイベントまたは遅延の元の終了時に続けます。| 9.7 |規格のみ||
| [`test_process_self_status_kill`](../../tests/ch9/test_process_self_status_kill.sv) |プロセスの状態を表示するには、std::process::self() は実行中のプロセスを返します。status() はプロセスの寿命に関して RUNNING , WAITING , FINISHED と KILLED を返します。state enumeration は G.6 が与える値 0 から 4 の順に5つの名前を持っています。kill() はプロ セスとその子プロセスを返す前に終了します。| 9.7 G.6 | Verilator 5.052 ||
| [`test_process_self_suspend_and_noop_controls`](../../tests/ch9/test_process_self_suspend_and_noop_controls.sv) |実行中のプロセスが RUNNING を報告し、自分自身をサスペンドすることができます。続けるには、resume() を使います。プロセスの停止、終了、または殺害の場合は suspend() 、停止されていない場合は resume() を使っても変更はありません。| 9.7 |規格のみ||
| [`test_process_suspend_resume_await`](../../tests/ch9/test_process_suspend_resume_await.sv) |プロセスクラス: await は他のプロセスが終了するのを待ち、遅延中に一時停止されたプロセスは再開後にのみ続行されます。| 9.7 |規格のみ||

<a id="generated-by-generatorscombination_eventspy"></a>

## `generators/combination_events.py`が生成

テスト4本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_combo_always_ff_computed_edge_capture`](../../tests/gen/ch9/test_gen_combo_always_ff_computed_edge_capture.sv) |Always_ff は計算されたエッジ表現の上昇遷移のみを捕捉します。| 9.2.2.4 9.4.2 10.4.2 | Icarus Verilog 13.0 ||
| [`test_gen_combo_iff_function_side_effect_accept`](../../tests/gen/ch9/test_gen_combo_iff_function_side_effect_accept.sv) |iff 関数は、ソースイベントに一度書き込み、ガードのみの変更には書き込みしません。| 9.4.2.3 9.4.2 13.4 |規格のみ||
| [`test_gen_combo_iff_function_side_effect_reject`](../../tests/gen/ch9/test_gen_combo_iff_function_side_effect_reject.sv) |iff 関数は、ソースイベントに一度書き込み、ガードのみの変更には書き込みしません。| 9.4.2.3 9.4.2 13.4 |規格のみ||
| [`test_gen_combo_named_fork_disable_waiters`](../../tests/gen/ch9/test_gen_combo_named_fork_disable_waiters.sv) |名前付きの disable はフォークの遅延したブランチとイベントを待つブランチのみを終了します| 9.6.2 9.3.2 9.3.4 15.5.2 | Icarus Verilog 13.0 ||

<a id="generated-by-generatorscombination_iopy"></a>

## `generators/combination_io.py`が生成

テスト6本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_comb_heap_sensitivity_dynamic_comb`](../../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_comb.sv) |暗黙感度はコンテナ置換，サイズ，選択値に従う。| 9.2.2.2.1 9.2.2.2 7.5.1 | Verilator 5.052 ||
| [`test_gen_comb_heap_sensitivity_dynamic_latch`](../../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_latch.sv) |暗黙感度はコンテナ置換，サイズ，選択値に従う。| 9.2.2.3 9.2.2.2.1 7.5.1 | Verilator 5.052 ||
| [`test_gen_comb_heap_sensitivity_dynamic_star`](../../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_star.sv) |暗黙感度はコンテナ置換，サイズ，選択値に従う。| 9.4.2.2 7.5.1 | Verilator 5.052 ||
| [`test_gen_comb_heap_sensitivity_queue_comb`](../../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_comb.sv) |暗黙感度はコンテナ置換，サイズ，選択値に従う。| 9.2.2.2.1 9.2.2.2 7.10 | Verilator 5.052 ||
| [`test_gen_comb_heap_sensitivity_queue_latch`](../../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_latch.sv) |暗黙感度はコンテナ置換，サイズ，選択値に従う。| 9.2.2.3 9.2.2.2.1 7.10 | Verilator 5.052 ||
| [`test_gen_comb_heap_sensitivity_queue_star`](../../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_star.sv) |暗黙感度はコンテナ置換，サイズ，選択値に従う。| 9.4.2.2 7.10 | Verilator 5.052 ||

<a id="generated-by-generatorsinteraction_delayvalpy"></a>

## `generators/interaction_delayval.py`が生成

テスト60本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_delayval_neg_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_neg_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 11.4.3 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_neg_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_neg_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 11.4.3 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_neg_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_neg_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 11.4.3 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_neg_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_neg_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 11.4.3 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_neg_stmt_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_neg_stmt_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 11.4.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_neg_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_neg_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 11.4.3 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_down_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_down_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_down_fork_zero_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_real_down_fork_zero_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_down_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_down_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_down_repeat_later_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_down_repeat_later_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_down_stmt_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_down_stmt_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_down_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_down_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_up_blocking_later_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_up_blocking_later_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_up_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_up_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_up_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_up_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_up_repeat_zero_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_real_up_repeat_zero_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_up_stmt_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_up_stmt_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_real_up_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_real_up_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.2 3.14.1 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_sized_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_sized_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_sized_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_sized_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_sized_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_sized_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_sized_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_sized_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_sized_stmt_later_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_sized_stmt_later_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_sized_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_sized_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_blocking_later_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_time_blocking_later_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fine_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_fine_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fine_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_fine_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fine_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_fine_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fine_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_fine_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fine_stmt_later_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_time_fine_stmt_later_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.1 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fine_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_fine_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.1 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_stmt_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_stmt_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_time_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_time_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.8 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_unsized_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_unsized_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_unsized_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_unsized_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_unsized_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_unsized_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_unsized_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_unsized_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_unsized_stmt_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_unsized_stmt_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_unsized_task_later_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_unsized_task_later_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 13.3 3.14.2.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_delayval_x_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_x_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_x_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_x_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_x_nba_later_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_x_nba_later_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_x_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_x_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_x_stmt_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_x_stmt_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_x_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_x_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 13.3 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_xpart_blocking_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_xpart_blocking_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_xpart_fork_later_unit`](../../tests/gen/ch9/test_gen_cross_delayval_xpart_fork_later_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_xpart_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_xpart_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_xpart_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_xpart_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_xpart_stmt_zero_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_xpart_stmt_zero_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_xpart_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_xpart_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 13.3 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_z_blocking_zero_tenth`](../../tests/gen/ch9/test_gen_cross_delayval_z_blocking_zero_tenth.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_z_fork_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_z_fork_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.3.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_z_nba_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_z_nba_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 9.4.5 10.4.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_z_repeat_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_z_repeat_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 12.7.2 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_z_stmt_later_unit`](../../tests/gen/ch9/test_gen_cross_delayval_z_stmt_later_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 3.14.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_delayval_z_task_zero_unit`](../../tests/gen/ch9/test_gen_cross_delayval_z_task_zero_unit.sv) |遅延はリテラルの値を時間の精度へ丸めた時間だけ待つ| 9.4.1 5.7.1 13.3 3.14.2.2 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorsinteraction_edgepy"></a>

## `generators/interaction_edge.py`が生成

テスト64本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_edge_w129_b_lsb_middle_0x_b`](../../tests/gen/ch9/test_gen_cross_edge_w129_b_lsb_middle_0x_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w129_b_reduce_or_low_x1_b`](../../tests/gen/ch9/test_gen_cross_edge_w129_b_reduce_or_low_x1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w129_b_vector_high_0x_b`](../../tests/gen/ch9/test_gen_cross_edge_w129_b_vector_high_0x_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w129_l_msb_middle_z0_b`](../../tests/gen/ch9/test_gen_cross_edge_w129_l_msb_middle_z0_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w129_l_vector_high_xz_n`](../../tests/gen/ch9/test_gen_cross_edge_w129_l_vector_high_xz_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w129_l_vector_low_11_b`](../../tests/gen/ch9/test_gen_cross_edge_w129_l_vector_low_11_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w1_b_lsb_low_00_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_00_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w1_b_lsb_low_01_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_01_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w1_b_lsb_low_0z_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_0z_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_lsb_low_11_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_11_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w1_b_lsb_low_1z_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_1z_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_lsb_low_x0_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_x0_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_lsb_low_x1_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_x1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_lsb_low_xx_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_lsb_low_xx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_0z_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_0z_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_10_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_10_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w1_b_reduce_or_low_11_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_11_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w1_b_reduce_or_low_1x_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_1x_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_xz_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_xz_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_z0_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_z0_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_z1_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_z1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_zx_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_zx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_reduce_or_low_zz_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_reduce_or_low_zz_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_vector_low_1x_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_vector_low_1x_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_vector_low_x1_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_vector_low_x1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_vector_low_z0_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_vector_low_z0_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_vector_low_z1_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_vector_low_z1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_b_vector_low_zx_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_b_vector_low_zx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_l_vector_low_0z_n`](../../tests/gen/ch9/test_gen_cross_edge_w1_l_vector_low_0z_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w1_l_vector_low_x0_b`](../../tests/gen/ch9/test_gen_cross_edge_w1_l_vector_low_x0_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_high_0z_n`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_high_0z_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_01_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_01_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w32_b_msb_low_0x_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_0x_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_10_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_10_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w32_b_msb_low_11_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_11_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w32_b_msb_low_1z_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_1z_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_x0_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_x0_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_xx_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_xx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_xz_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_xz_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_zx_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_zx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_msb_low_zz_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_msb_low_zz_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_reduce_or_low_xx_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_reduce_or_low_xx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_b_vector_middle_10_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_b_vector_middle_10_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w32_l_lsb_high_zx_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_l_lsb_high_zx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_l_msb_low_z1_b`](../../tests/gen/ch9/test_gen_cross_edge_w32_l_msb_low_z1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w32_l_reduce_or_middle_0x_n`](../../tests/gen/ch9/test_gen_cross_edge_w32_l_reduce_or_middle_0x_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w33_b_lsb_low_z1_n`](../../tests/gen/ch9/test_gen_cross_edge_w33_b_lsb_low_z1_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w33_b_reduce_or_high_1z_b`](../../tests/gen/ch9/test_gen_cross_edge_w33_b_reduce_or_high_1z_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w33_b_vector_middle_01_b`](../../tests/gen/ch9/test_gen_cross_edge_w33_b_vector_middle_01_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w33_l_lsb_low_10_b`](../../tests/gen/ch9/test_gen_cross_edge_w33_l_lsb_low_10_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w33_l_msb_middle_00_n`](../../tests/gen/ch9/test_gen_cross_edge_w33_l_msb_middle_00_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.5.1 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w33_l_vector_high_xx_b`](../../tests/gen/ch9/test_gen_cross_edge_w33_l_vector_high_xx_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w64_b_lsb_high_z0_n`](../../tests/gen/ch9/test_gen_cross_edge_w64_b_lsb_high_z0_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w64_b_lsb_middle_xz_n`](../../tests/gen/ch9/test_gen_cross_edge_w64_b_lsb_middle_xz_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w64_b_msb_low_1x_n`](../../tests/gen/ch9/test_gen_cross_edge_w64_b_msb_low_1x_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w64_l_lsb_high_zz_b`](../../tests/gen/ch9/test_gen_cross_edge_w64_l_lsb_high_zz_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w64_l_reduce_or_middle_01_b`](../../tests/gen/ch9/test_gen_cross_edge_w64_l_reduce_or_middle_01_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.4.9 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w64_l_vector_low_1z_b`](../../tests/gen/ch9/test_gen_cross_edge_w64_l_vector_low_1z_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w65_b_reduce_or_high_00_n`](../../tests/gen/ch9/test_gen_cross_edge_w65_b_reduce_or_high_00_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.4.9 | Icarus Verilog 13.0 ||
| [`test_gen_cross_edge_w65_b_reduce_or_low_x0_n`](../../tests/gen/ch9/test_gen_cross_edge_w65_b_reduce_or_low_x0_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 11.4.9 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w65_b_vector_middle_zz_n`](../../tests/gen/ch9/test_gen_cross_edge_w65_b_vector_middle_zz_n.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w65_l_lsb_low_1x_b`](../../tests/gen/ch9/test_gen_cross_edge_w65_l_lsb_low_1x_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w65_l_msb_high_x1_b`](../../tests/gen/ch9/test_gen_cross_edge_w65_l_msb_high_x1_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_edge_w65_l_vector_middle_00_b`](../../tests/gen/ch9/test_gen_cross_edge_w65_l_vector_middle_00_b.sv) |イベント制御はタイプ化されたX／Z遷移を分類し，表現変化のみを観察する。| 9.4.2 6.11.2 10.4.1 | Icarus Verilog 13.0 ||

<a id="generated-by-generatorsinteraction_iffpy"></a>

## `generators/interaction_iff.py`が生成

テスト27本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_iff_comma_mixed_change_second_xz_nba`](../../tests/gen/ch9/test_gen_cross_iff_comma_mixed_change_second_xz_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ| x/z |
| [`test_gen_cross_iff_comma_mixed_negedge_both_known_nba`](../../tests/gen/ch9/test_gen_cross_iff_comma_mixed_negedge_both_known_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ||
| [`test_gen_cross_iff_comma_mixed_negedge_first_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_mixed_negedge_first_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_comma_mixed_posedge_second_mixed_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_mixed_posedge_second_mixed_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_comma_named_change_both_mixed_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_named_change_both_mixed_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_comma_signals_change_first_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_signals_change_first_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_comma_signals_negedge_second_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_signals_negedge_second_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_comma_signals_posedge_both_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_signals_posedge_both_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_comma_signals_posedge_first_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_comma_signals_posedge_first_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_mixed_change_both_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_mixed_change_both_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_mixed_change_first_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_mixed_change_first_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_mixed_negedge_first_mixed_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_mixed_negedge_first_mixed_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_mixed_posedge_both_mixed_nba`](../../tests/gen/ch9/test_gen_cross_iff_or_mixed_posedge_both_mixed_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ| x/z |
| [`test_gen_cross_iff_or_mixed_posedge_second_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_mixed_posedge_second_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_or_named_change_both_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_both_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_or_named_change_both_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_both_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_named_change_first_known_nba`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_first_known_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ||
| [`test_gen_cross_iff_or_named_change_first_mixed_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_first_mixed_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_named_change_first_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_first_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_named_change_second_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_second_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_or_named_change_second_mixed_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_second_mixed_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_named_change_second_xz_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_named_change_second_xz_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_signals_change_both_mixed_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_signals_change_both_mixed_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 |規格のみ| x/z |
| [`test_gen_cross_iff_or_signals_change_second_mixed_nba`](../../tests/gen/ch9/test_gen_cross_iff_or_signals_change_second_mixed_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ| x/z |
| [`test_gen_cross_iff_or_signals_negedge_both_xz_nba`](../../tests/gen/ch9/test_gen_cross_iff_or_signals_negedge_both_xz_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ| x/z |
| [`test_gen_cross_iff_or_signals_negedge_second_known_blocking`](../../tests/gen/ch9/test_gen_cross_iff_or_signals_negedge_second_known_blocking.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.1 | Verilator 5.052 ||
| [`test_gen_cross_iff_or_signals_posedge_first_mixed_nba`](../../tests/gen/ch9/test_gen_cross_iff_or_signals_posedge_first_mixed_nba.sv) |イベント OR は選択した項目に iff を適用し、ガードのみの変更を無視します。| 9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 10.4.2 |規格のみ| x/z |

<a id="generated-by-generatorsinteraction_processpy"></a>

## `generators/interaction_process.py`が生成

テスト36本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_process_129_bit_known_comb_direct_module_z_zero`](../../tests/gen/ch9/test_gen_cross_process_129_bit_known_comb_direct_module_z_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_129_bit_x_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_129_bit_x_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_129_bit_z_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_129_bit_z_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_129_logic_known_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_129_logic_known_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_129_logic_x_comb_direct_module_one_one`](../../tests/gen/ch9/test_gen_cross_process_129_logic_x_comb_direct_module_one_one.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_129_logic_z_latch_function_interface_x_hold`](../../tests/gen/ch9/test_gen_cross_process_129_logic_z_latch_function_interface_x_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_1_bit_known_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_1_bit_known_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_1_bit_x_comb_direct_module_x_zero`](../../tests/gen/ch9/test_gen_cross_process_1_bit_x_comb_direct_module_x_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_1_bit_z_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_1_bit_z_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_1_logic_known_comb_direct_module_z_one`](../../tests/gen/ch9/test_gen_cross_process_1_logic_known_comb_direct_module_z_one.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_1_logic_x_comb_function_module_x_zero`](../../tests/gen/ch9/test_gen_cross_process_1_logic_x_comb_function_module_x_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_1_logic_z_latch_function_interface_one_hold`](../../tests/gen/ch9/test_gen_cross_process_1_logic_z_latch_function_interface_one_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_32_bit_known_comb_direct_module_one_zero`](../../tests/gen/ch9/test_gen_cross_process_32_bit_known_comb_direct_module_one_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_32_bit_x_comb_direct_interface_z_zero`](../../tests/gen/ch9/test_gen_cross_process_32_bit_x_comb_direct_interface_z_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_32_bit_z_comb_direct_module_x_one`](../../tests/gen/ch9/test_gen_cross_process_32_bit_z_comb_direct_module_x_one.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_32_logic_known_latch_function_module_zero_hold`](../../tests/gen/ch9/test_gen_cross_process_32_logic_known_latch_function_module_zero_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_32_logic_x_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_32_logic_x_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_32_logic_z_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_32_logic_z_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_33_bit_known_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_33_bit_known_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_33_bit_x_latch_direct_module_one_hold`](../../tests/gen/ch9/test_gen_cross_process_33_bit_x_latch_direct_module_one_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_33_bit_z_comb_function_interface_one_zero`](../../tests/gen/ch9/test_gen_cross_process_33_bit_z_comb_function_interface_one_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_33_logic_known_latch_direct_module_x_hold`](../../tests/gen/ch9/test_gen_cross_process_33_logic_known_latch_direct_module_x_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_33_logic_x_comb_function_module_zero_one`](../../tests/gen/ch9/test_gen_cross_process_33_logic_x_comb_function_module_zero_one.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_33_logic_z_latch_function_module_z_hold`](../../tests/gen/ch9/test_gen_cross_process_33_logic_z_latch_function_module_z_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_64_bit_known_comb_direct_module_x_zero`](../../tests/gen/ch9/test_gen_cross_process_64_bit_known_comb_direct_module_x_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_64_bit_x_comb_function_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_64_bit_x_comb_function_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_64_bit_z_latch_direct_module_z_hold`](../../tests/gen/ch9/test_gen_cross_process_64_bit_z_latch_direct_module_z_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_64_logic_known_comb_direct_interface_one_one`](../../tests/gen/ch9/test_gen_cross_process_64_logic_known_comb_direct_interface_one_one.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_64_logic_x_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_64_logic_x_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_64_logic_z_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_64_logic_z_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_65_bit_known_comb_direct_module_x_zero`](../../tests/gen/ch9/test_gen_cross_process_65_bit_known_comb_direct_module_x_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_65_bit_x_comb_direct_module_one_zero`](../../tests/gen/ch9/test_gen_cross_process_65_bit_x_comb_direct_module_one_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_65_bit_z_latch_direct_interface_zero_hold`](../../tests/gen/ch9/test_gen_cross_process_65_bit_z_latch_direct_interface_zero_hold.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_65_logic_known_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_65_logic_known_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 ||
| [`test_gen_cross_process_65_logic_x_comb_function_interface_z_one`](../../tests/gen/ch9/test_gen_cross_process_65_logic_x_comb_function_interface_z_one.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_process_65_logic_z_comb_direct_module_zero_zero`](../../tests/gen/ch9/test_gen_cross_process_65_logic_z_comb_direct_module_zero_zero.sv) |暗黙組合せとラッチ感度は，関数読み出しとインスタンス局所状態の保存を含む。| 9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2 | Icarus Verilog 13.0 | x/z |

<a id="generated-by-generatorsinteraction_waitpy"></a>

## `generators/interaction_wait.py`が生成

テスト36本。スイートのREADMEの"Generated tests"を参照してください。

|テスト|確認する内容|条項|期待出力を記録したリリース|注記|
| --- | --- | --- | --- | --- |
| [`test_gen_cross_wait_129_bit_known_queue_shrink_size_ready`](../../tests/gen/ch9/test_gen_cross_wait_129_bit_known_queue_shrink_size_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_129_bit_x_queue_grow_element_ready`](../../tests/gen/ch9/test_gen_cross_wait_129_bit_x_queue_grow_element_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_129_bit_z_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_129_bit_z_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_129_logic_known_dynamic_clear_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_129_logic_known_dynamic_clear_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_129_logic_x_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_129_logic_x_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_129_logic_z_dynamic_replace_both_waiting`](../../tests/gen/ch9/test_gen_cross_wait_129_logic_z_dynamic_replace_both_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_1_bit_known_queue_grow_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_1_bit_known_queue_grow_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Verilator 5.052 ||
| [`test_gen_cross_wait_1_bit_x_queue_replace_both_ready`](../../tests/gen/ch9/test_gen_cross_wait_1_bit_x_queue_replace_both_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_1_bit_z_dynamic_shrink_both_ready`](../../tests/gen/ch9/test_gen_cross_wait_1_bit_z_dynamic_shrink_both_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_1_logic_known_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_1_logic_known_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_1_logic_x_dynamic_clear_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_1_logic_x_dynamic_clear_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_1_logic_z_dynamic_grow_element_waiting`](../../tests/gen/ch9/test_gen_cross_wait_1_logic_z_dynamic_grow_element_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_32_bit_known_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_32_bit_known_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_32_bit_x_queue_grow_both_waiting`](../../tests/gen/ch9/test_gen_cross_wait_32_bit_x_queue_grow_both_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_32_bit_z_dynamic_shrink_element_ready`](../../tests/gen/ch9/test_gen_cross_wait_32_bit_z_dynamic_shrink_element_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_32_logic_known_queue_clear_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_32_logic_known_queue_clear_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_32_logic_x_dynamic_replace_element_waiting`](../../tests/gen/ch9/test_gen_cross_wait_32_logic_x_dynamic_replace_element_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_32_logic_z_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_32_logic_z_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_33_bit_known_dynamic_grow_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_33_bit_known_dynamic_grow_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Verilator 5.052 ||
| [`test_gen_cross_wait_33_bit_x_dynamic_create_size_ready`](../../tests/gen/ch9/test_gen_cross_wait_33_bit_x_dynamic_create_size_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_33_bit_z_queue_shrink_both_waiting`](../../tests/gen/ch9/test_gen_cross_wait_33_bit_z_queue_shrink_both_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_33_logic_known_dynamic_replace_element_waiting`](../../tests/gen/ch9/test_gen_cross_wait_33_logic_known_dynamic_replace_element_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_33_logic_x_dynamic_clear_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_33_logic_x_dynamic_clear_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_33_logic_z_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_33_logic_z_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_64_bit_known_queue_replace_element_ready`](../../tests/gen/ch9/test_gen_cross_wait_64_bit_known_queue_replace_element_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_64_bit_x_dynamic_shrink_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_64_bit_x_dynamic_shrink_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_64_bit_z_queue_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_64_bit_z_queue_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_64_logic_known_dynamic_grow_both_ready`](../../tests/gen/ch9/test_gen_cross_wait_64_logic_known_dynamic_grow_both_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_64_logic_x_dynamic_clear_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_64_logic_x_dynamic_clear_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_64_logic_z_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_64_logic_z_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_65_bit_known_dynamic_grow_size_ready`](../../tests/gen/ch9/test_gen_cross_wait_65_bit_known_dynamic_grow_size_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Verilator 5.052 ||
| [`test_gen_cross_wait_65_bit_x_dynamic_replace_both_waiting`](../../tests/gen/ch9/test_gen_cross_wait_65_bit_x_dynamic_replace_both_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_65_bit_z_dynamic_clear_size_ready`](../../tests/gen/ch9/test_gen_cross_wait_65_bit_z_dynamic_clear_size_ready.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
| [`test_gen_cross_wait_65_logic_known_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_65_logic_known_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 ||
| [`test_gen_cross_wait_65_logic_x_queue_shrink_element_waiting`](../../tests/gen/ch9/test_gen_cross_wait_65_logic_x_queue_shrink_element_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 |規格のみ| x/z |
| [`test_gen_cross_wait_65_logic_z_dynamic_create_size_waiting`](../../tests/gen/ch9/test_gen_cross_wait_65_logic_z_dynamic_create_size_waiting.sv) |タイプされたコンテナの変更に対しては続行を待ち、関係のないコンテナの変化は無視します| 9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7 | Icarus Verilog 13.0 | x/z |
