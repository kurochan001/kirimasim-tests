<a id="inventory-of-the-suite-2026-10-21"></a>

# スイートの棚卸し、2026-10-21

[English](inventory-20261021.md) / [日本語](inventory-20261021.ja.md)

> 以下の件数、割合、未解決事項は、記録された各作業段階の状態を示す。
> [生成された動作集計](behavior-coverage-summary.md)と、
> 現行スイートと残りの仕事のための[更新されたハンドオフ](handover-20261028.md)。

0 拡張作業のフェーズ: すでにスイートにあるもの、何かを追加する前のもの。このファイル以外の何も変更されませんでした。件数は、コミット6177339時点の`main`のもの（テスト3403件）。

<a id="versions"></a>

## バージョン

|ツール|バージョン|
| --- | --- |
|`iverilog` `PATH` に|13.0ではなく、14.0（開発版）（s20260301-411-gca6b8d376）|
|オラクルに用いられたIcarus Verilog|13.0（安定）（v13_0）ホームブリューの13.0ケグ、`--iverilog-bin`でランナーに与えられる|
| `verilator` | 5.052 2026-09-05 |

`PATH`上の`iverilog`は開発版なので、README.mdの説明どおり、oracleの実行ごとに`--iverilog-bin`で13.0のディレクトリを指定します。

<a id="where-the-request-and-the-existing-conventions-differ"></a>

## 依頼と既存の慣習が異なる箇所

依頼と既存の慣習が異なる場合は、既存の慣習を優先することが依頼に明記されている。以下に、該当箇所と後続フェーズでの対応を示す。

|リクエスト|既存の慣習|プラン|
| --- | --- | --- |
|正規化された標準出力のみが評価されます。終了コードと標準エラー出力は判定しない。|`:expected_exit:`と`:expected_stderr_regex:`は、テストで指定されていれば既に判定する（README.md、"How a test is judged"）。|維持|
|`:type: elaboration`と`:should_fail_because:`を追加する。非ゼロの終了コードで合格となる|両方とも存在する（不正な設計121件）。拒否のエラーが`:expected_stderr_regex:`で指定した行を示した場合だけ合格となり、別の理由による拒否は合格にならない。|厳しいルールを守れ|
|`:expected_exit: 0 \| nonzero` を追加|存在する、`0`、`nonzero`または数字 (5テスト)|維持|
|`:plusargs:` を追加|plusargsは`:args:`で指定する（5件のテスト）。|`:args:` を保持;同じものに対して 2つ目のフィールドはありません|
|`:files:` を追加|存在する。テストより前にコンパイルするソースと、そのディレクトリをincludeディレクトリとして使うインクルードファイル（6件のテスト）。|維持|
|`:defines:`、`:incdirs:`、`:top_module:`を追加|存在しません|フェーズ1で追加|
|kirimasimの"unsupported"だけでは、拒否を期待するテストの合格にはならない|`tools/run_kirimasim.py`では既に対応済み|維持|
|check.yml はリリースが should-fail テストを拒否するかどうかをチェックします。|既に対応済み。`:oracle:`に`iverilog@13.0`または`verilator@5.052`を指定する不正な設計は、そこで指定した行で拒否されなければならない。|維持|
|すべての期待出力をIcarus VerilogとVerilatorの両方でCheckする|最初にIcarus Verilog 13.0を使い、失敗する箇所ではVerilator 5.052を使う。両方で実行したテストには、期待出力を生成するものをそれぞれ記録する。|新規テストで両方を実行し、既存の規則に従って記録する|
| `tests/ch04` |ディレクトリは先頭のゼロを除いた `tests/chNN` ( `tests/ch4` ) です| `tests/ch4` |
|`tools/gen_wide_tests.py`、出力は手書きテストと同じ場所|生成器は`generators/`に置き、`tests/gen/chNN/`を書き出し、`generators/oracles.txt`にオラクルを記録する。`width_sign`は、既に幅63～1000を確認している。|`generators/`内の新しい生成器。`width_sign`の処理と重複せずに`tests/gen/`を書き出す。|
|関数内にfork-join_noneは記述できない（3-2）。|IEEE 1800-2023 13.4.4は、関数内のfork-join_noneを許す。そこではfork-joinとfork-join_anyは不正である（`ch13/test_illegal_function_fork_join`）。|正当なfork-join_noneをテストする。条項が決めるのは|

<a id="ieee-1800-2023-features"></a>

## IEEE 1800-2023の機能

すべてのテストの、コメント外のコードを検索した。

|機能|テスト|どちら|
| --- | ---: | --- |
|トリプル引用符文字列 `"""` ( 5.9 )| 0 | — |
|式を伴う`` `ifdef ``（22.6）| 0 | — |
| `class :final` (8.13) | 0 | — |
|`:initial`、`:extends`、`:final`を持つメソッド（8.20）| 0 | — |
|配列メソッド `map()` ( 7.12.5 )| 2 | `ch7/test_array_map_method`, `ch7/test_map_result_to_same_array` |
|配列メソッドのインデックス引数 (7.12)| 0 | — |
| `rand real` (18.4.1) | 0 | — |
| `$timeunit`, `$timeprecision` (20.4.1) | 2 | `ch20/test_timeunit_timeprecision_functions`, `ch20/test_timeunit_unit_root` |
| `$stacktrace` (20.17.2) | 1 | `ch20/test_stacktrace_function` |
| `[a +/- b]` (11.4.13, 18.5.3, 19.5) | 0 | — |
| `[a +%- b]` (11.4.13, 18.5.3, 19.5) | 0 | — |
| `weak_reference` (8.30) | 5 | `ch8/test_illegal_weak_reference_non_class`, `ch8/test_object_strongly_reachable`, `ch8/test_weak_reference_get_clear`, `ch8/test_weak_reference_get_id`, `ch8/test_weak_reference_wait_cleared` |
| `type(this)` (8.11, 6.23) | 0 | — |
|dist内の`default :/`（18.5.3）| 0 | — |
| `super.new(default)` (8.17) | 0 | — |
| `union soft` (7.3.1) | 0 | — |
| covergroup `extends` (19.4.1) | 1 | `ch19/test_cg_embedded_inheritance` |

xとzを含む比較結果（11.4.4〜11.4.6）は、`xz_propagation`生成器と第11章の手書きテストで確認します。

<a id="illegal-designs-that-phase-3-1-asks-for"></a>

## フェーズ3-1で要求される規格違反の設計

|ルール|既存のテスト|
| --- | --- |
|ネットへの手続き的代入 (10.4)| `ch10/test_illegal_procedural_assign_to_net` |
|関数のタイミング制御 (13.4.4)| `ch13/test_illegal_function_delay`, `ch13/test_illegal_function_event_control` |
|静的サブルーティンのref引数 (13.5.2)| `ch13/test_illegal_ref_in_static_task` |
|抽象クラス (8.21) の `new`| `ch8/test_illegal_abstract_class_new` |
|`:final`クラスの継承（8.13）、`:final`メソッドのオーバーライド（8.20）、2023でのnew|なし|
|modportの方向（25.5）| `ch25/test_illegal_modport_input_written` |
|インポート名の衝突 (26.3)| `ch26/test_illegal_wildcard_import_conflict` |
|packed配列内のreal（7.4.1）|なし（実数メンバーを持つpacked構造体7.2.1は`ch7/test_illegal_packed_struct_real_member`）。|
|always_comb ( 9.2.2.2 ) の遅延|なし|
|always_ff の変数は他のプロセス (9.2.2.4) によって書かれました|さらに`ch9/test_illegal_always_ff_other_writer`と3|
|コンスト変数 (6.20.6) への代入| `ch6/test_illegal_const_assigned` |
|integerまたは別のenumからenumへの代入（6.19.3）| `ch6/test_illegal_enum_from_int`, `ch6/test_illegal_enum_from_other_enum` |
|`` `default_nettype none ``の下での未宣言net（22.8）| `ch22/test_illegal_default_nettype_none_assign`, `ch22/test_illegal_default_nettype_none_port` |

<a id="scheduling-items-of-phase-3-2"></a>

## フェーズ3-2のスケジューリング項目

手書きテストの説明に基づいて対応付けたもの。`scheduling`の生成テスト325件は、README.mdに列挙された書込み・読取り・配置の組合せを追加する。3-2フェーズでは，テストを追加する前に各項目を詳細に見る。

|項目|既存のテスト|
| --- | --- |
|Active、Inactive（`#0`）、NBA、Postponedの順|`ch4/test_edge_event_regions` `ch4/test_event_delta_cycles` `ch4/test_nba_after_zero_delay` `ch4/test_sched_strobe_after_nba` と生成器|
|ノンブロッキング更新の順序（10.4.2）、1つの変数への複数の更新|`ch4/test_array_element_noop_nba_keeps_override_order`、ch10のテスト、生成器|
|`$monitor` タイムステップごとに一度|`ch21/test_monitor_end_of_step`、生成器|
|連続で複数の `#0`| `ch4/test_event_delta_cycles`, `ch10/test_edge_delta_cycle_chain` |
|ノンブロッキング更新で起床するイベント制御| `ch4/test_sched_strobe_after_nba`, `ch10/test_nba_intra_assignment_event_control` |
|`wait`とノンブロッキング更新|少ない追加される予定です|
|always_ffからalways_combへの入力、1サイクル後| `ch9/test_always_comb_latch_ff` |
|Observed領域の遅延アサーション（`assert #0`）| `ch16/test_deferred_assertion_flush`, `ch16/test_deferred_assertion_per_process` |
|fork-join_noneの子プロセスは、親がブロックしてから開始する（9.3.2）。| `ch9/test_join_none_children_start_after_parent_blocks`, `ch9/test_fork_join_block_timing` |
|`disable fork`が終了させる対象（9.6.3）| `ch9/test_disable_fork_ends_loops_and_class_tasks`, `ch9/test_wait_fork_disable_fork` |
|関数のフォーク-join_none (13.4.4)|正当な使用についてはなし|
|ゼロ遅延のループで、`$time`が残る|なし|

<a id="tests-of-chapters-4-14-to-19-22-24-and-35"></a>

## 4章、14～19章、22章、24章、35章のテスト

これらの章で観測可能な動作を定めるすべての節は、テストから引用されている（[docs/tests/clauses.md](tests/clauses.ja.md)）。1本のテストからしか引用されていない節は、検証が最も手薄である。[docs/tests/](tests/README.ja.md)カタログには各テストの記述がある。

<a id="chapter-4"></a>

### 章 4

手書きテスト26件と生成テスト325件。対象範囲は27節で、すべて引用済み。そのうち14節は1本のテストだけから引用される。対象は4.4.1、4.4.2.1、4.4.2.5、4.4.2.7、4.4.2.8、4.4.3.2、4.4.3.4、4.4.3.9、4.4.3.10、4.9.1、4.9.2、4.9.3、4.9.5、4.9.7。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_nba_cross_module` | 4.3 10.4.2 4.6 |iverilog@13.0|
| `test_nba_cross_module_timing` | 4.3 |iverilog@13.0|
| `test_nba_port_propagation` | 4.3 10.4.2 4.9.6 10.3 |iverilog@13.0|
| `test_preponed_sampling` | 4.4.2.1 16.5.1 16.9.3 |verilator@5.052|
| `test_edge_event_regions` | 4.4.2.2 4.4.2.3 4.4.2.4 21.2.2 |iverilog@13.0 verilator@5.052|
| `test_delta_cycle` | 4.4.2.3 4.6 10.4.2 10.3.2 |iverilog@13.0|
| `test_delta_cycles` | 4.4.2.3 3.14.2.3 22.7 21.3.2 |iverilog@13.0|
| `test_delta_scheduler` | 4.4.2.3 9.2.2.2 10.4.2 |iverilog@13.0|
| `test_event_delta_cycles` | 4.4.2.3 4.7 9.4.1 |iverilog@13.0|
| `test_nba_after_zero_delay` | 4.4.2.3 4.4.2.4 10.4.2 |iverilog@13.0|
| `test_reactive_region_set_order` | 4.4.2.7 4.4.2.8 4.5 24.3 |標準のみ|
| `test_sched_strobe_after_nba` | 4.4.2.9 21.2.2 10.4.2 |iverilog@13.0 verilator@5.052|
| `test_pli_pre_active_write` | 4.4.3.2 4.10 38.36.2 38.34 |iverilog@13.0|
| `test_pli_read_write_synch_write` | 4.4.3.4 4.4.3.3 4.10 38.36.2 |iverilog@13.0|
| `test_pli_end_of_time_write` | 4.4.3.9 4.4.3.10 4.10 4.5 38.36.2 |iverilog@13.0|
| `test_ieee1800_2023_delta_convergence` | 4.5 4.4.2.3 10.3 |iverilog@13.0|
| `test_array_element_noop_nba_keeps_override_order` | 4.6 10.4.2 |iverilog@13.0|
| `test_port_complex_expr_extended` | 4.7 23.3.2 23.3.3 4.9.6 |iverilog@13.0|
| `test_range_select_lhs` | 4.9 11.5.1 |iverilog@13.0|
| `test_sched_contassign_zero_delay` | 4.9.1 4.4.2.2 4.4.2.3 10.3.2 |iverilog@13.0|
| `test_sched_procedural_assign_deassign` | 4.9.2 10.6.1 |標準のみ|
| `test_sched_intra_assignment_target` | 4.9.3 4.9.4 9.4.5 10.4.1 10.4.2 |iverilog@13.0|
| `test_switch_x_gate_resolution` | 4.9.5 28.8 28.12 |iverilog@13.0|
| `test_sched_subroutine_copy_out` | 4.9.7 13.3 13.5.1 13.5.2 |verilator@5.052|
| `test_pli_nba_synch_callback` | 4.10 4.4.3.3 38.36.2 |標準のみ|
| `test_pli_region_callbacks` | 4.10 4.4.3 38.36.2 |iverilog@13.0|

自動生成テスト325本（`tests/gen/ch4/`）は、`scheduling`生成器（README.md、"Generated tests"）によるものです。

<a id="chapter-14"></a>

### 章 14

29 手書きテスト対象は14条項で、すべて引用済みです。うち3条項はテストが1本だけです：14.7、14.9、14.15。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_clocking_blk_edge_cases` | 14.3 14.13 |verilator@5.052|
| `test_clocking_blocks` | 14.3 14.13 14.16 |verilator@5.052|
| `test_clocking_blocks_edge_cases` | 14.3 14.13 14.16 |verilator@5.052|
| `test_clocking_input` | 14.3 14.4 14.13 |verilator@5.052|
| `test_clocking_input_with_expression` | 14.3 14.13 |verilator@5.052|
| `test_clocking_ops` | 14.3 14.13 14.16 |verilator@5.052|
|`test_illegal_clocking_read_output_clockvar`（規格違反）| 14.3 |verilator@5.052|
|`test_illegal_clocking_write_input_clockvar`（規格違反）| 14.3 14.16 |verilator@5.052|
|`test_illegal_unnamed_clocking_not_default`（規格違反）| 14.3 14.12 |verilator@5.052|
| `test_clocking_input_output_skew` | 14.4 14.13 14.16 14.5 |verilator@5.052|
| `test_clocking_input_skew_fractional` | 14.4 14.3 3.14.2.2 |標準のみ|
| `test_clocking_multiple_blocks` | 14.6 14.5 14.4 14.13 |verilator@5.052|
| `test_clocking_interface_modport` | 14.9 25.5 14.16 14.10 |標準のみ|
| `test_clocking_event_cycle_delay` | 14.10 14.11 14.12 |verilator@5.052|
| `test_cycle_delay` | 14.11 14.12 |verilator@5.052|
| `test_cycle_delay_clocking` | 14.11 14.12 14.16 |verilator@5.052|
|`test_illegal_cycle_delay_intra_assignment`（規格違反）| 14.11 10.4 |verilator@5.052|
|`test_illegal_cycle_delay_without_default_clocking`（規格違反）| 14.11 14.12 |verilator@5.052|
|`test_illegal_clocking_two_default`（規格違反）| 14.12 |verilator@5.052|
| `test_global_clocking` | 14.14 |標準のみ|
|`test_illegal_two_global_clocking`（規格違反）| 14.14 |verilator@5.052|
| `test_clocking_synchronous_events` | 14.15 14.7 14.13 14.3 |標準のみ|
| `test_clocking_drive_between_edges` | 14.16 14.11 14.12 |verilator@5.052|
| `test_clocking_output_net_driver` | 14.16 14.16.2 6.6.1 |標準のみ|
|`test_illegal_clocking_blocking_write`（規格違反）| 14.16 |verilator@5.052|
|`test_illegal_clocking_drive_intra_delay`（規格違反）| 14.16 14.16.1 |verilator@5.052|
| `test_clocking_inout_drive_keeps_input` | 14.16.1 14.3 14.13 14.16 |verilator@5.052|
| `test_clocking_drive_last_wins` | 14.16.2 14.16.1 14.16 14.3 |verilator@5.052|
| `test_clocking_two_blocks_one_output` | 14.16.2 14.6 14.16 |verilator@5.052|

<a id="chapter-15"></a>

### 章 15

26 手書きテスト対象範囲は20節で、すべて引用済み。そのうち12節は1本のテストだけから引用される。対象は15.4.2、15.4.3、15.4.4、15.4.5、15.4.6、15.4.7、15.4.8、15.4.9、15.5.2、15.5.4、15.5.5.2、15.5.5.3。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_semaphore_basic` | 15.3 |verilator@5.052|
| `test_semaphore_edge` | 15.3 |verilator@5.052|
| `test_semaphore_edge_cases` | 15.3 |verilator@5.052|
| `test_semaphore_multiple` | 15.3 |verilator@5.052|
| `test_semaphore_new` | 15.3 15.3.1 |verilator@5.052|
| `test_semaphore_try_get` | 15.3 15.3.4 |verilator@5.052|
| `test_semaphore_blocking_keys` | 15.3.3 15.3.2 15.3.1 15.3.4 |verilator@5.052|
| `test_semaphore_fifo_order` | 15.3.3 15.3.1 15.3.2 |verilator@5.052|
| `test_mailbox_6` | 15.4 |verilator@5.052|
| `test_mailbox_basic` | 15.4 |verilator@5.052|
| `test_mailbox_basic_2` | 15.4 |verilator@5.052|
| `test_mailbox_bounded` | 15.4 |verilator@5.052|
| `test_mailbox_bounded_methods` | 15.4 15.4.1 15.4.2 15.4.4 15.4.6 15.4.7 15.4.8 |verilator@5.052|
| `test_mailbox_edge` | 15.4 |verilator@5.052|
| `test_mailbox_edge_cases` | 15.4 |verilator@5.052|
| `test_mailbox_edge_cases_2` | 15.4 |verilator@5.052|
| `test_mailbox_blocking_put_get` | 15.4.3 15.4.5 15.4.9 15.4.1 |verilator@5.052|
| `test_event_named` | 15.5 15.5.1 |verilator@5.052|
| `test_event_nonblocking_trigger` | 15.5.1 4.4.2.4 9.4 |標準のみ|
| `test_event_ordering` | 15.5.1 9.4.2 4.4.2.3 |iverilog@13.0|
| `test_hierarchical_event_trigger` | 15.5.1 15.5.3 23.6 |verilator@5.052|
| `test_event_triggered` | 15.5.3 |verilator@5.052|
| `test_event_triggered_same_step` | 15.5.3 15.5.2 15.5.1 |verilator@5.052|
| `test_wait_order` | 15.5.4 15.5.1 |標準のみ|
| `test_event_merge` | 15.5.5.1 15.5.5 15.5.1 |標準のみ|
| `test_event_null_compare` | 15.5.5.3 15.5.5.2 15.5.5.1 |標準のみ|

<a id="chapter-16"></a>

### 章 16

73 手書きテスト対象の66条項はすべて引用済みで、うち37条項を引用するテストは各1本のみです：16.4.3、16.4.4、16.4.5、16.5.2、16.9.1、16.9.2.1、16.9.8、16.9.10、16.11、16.12.1、16.12.3、16.12.4、16.12.5、16.12.6、16.12.8、16.12.9、16.12.10、16.12.11、16.12.12、16.12.13、16.12.14、16.12.15、16.12.16、16.12.17、16.12.19、16.13.2、16.13.3、16.13.5、16.13.7、16.14.4、16.14.5、16.14.6.2、16.14.6.3、16.14.6.4、16.14.8、16.17、16.18。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_assert_imm` | 16.3 |iverilog@13.0|
| `test_assert_imm_edge_cases` | 16.3 |iverilog@13.0|
| `test_assert_immed` | 16.3 |iverilog@13.0|
| `test_assert_immed_2` | 16.3 |標準のみ|
| `test_assert_immed_edge_cases` | 16.3 |iverilog@13.0|
| `test_assert_simple` | 16.3 |iverilog@13.0|
| `test_assertion_basic_edge_cases` | 16.3 |iverilog@13.0|
| `test_diag_assert` | 16.3 |iverilog@13.0|
| `test_immed_assert_edge_cases` | 16.3 |iverilog@13.0|
| `test_immediate_assert` | 16.3 |iverilog@13.0|
| `test_immediate_assert_assume` | 16.3 |iverilog@13.0|
| `test_immediate_assert_compound_expr` | 16.3 |iverilog@13.0|
| `test_immediate_assert_pass_action` | 16.3 |iverilog@13.0|
| `test_immediate_assert_value_checks` | 16.3 |iverilog@13.0|
| `test_immediate_assertions` | 16.3 |iverilog@13.0|
| `test_immediate_assertions_2` | 16.3 |標準のみ|
| `test_immediate_assume` | 16.3 |iverilog@13.0|
| `test_immediate_simple` | 16.3 |iverilog@13.0|
| `test_deferred_assertion_flush` | 16.4 16.4.1 16.4.2 16.4.3 16.4.4 16.3 24.3 |標準のみ|
| `test_deferred_assertion_per_process` | 16.4.5 16.4.2 16.4 |標準のみ|
| `test_assertion_clock_sampled_value` | 16.5.2 16.5.1 16.14.1 |verilator@5.052|
| `test_sequence_linear_and_ranges` | 16.7 16.14.3 16.9.2 |verilator@5.052|
| `test_sequence_formal_arguments` | 16.8 16.8.1 16.12.1 16.12.18 16.14.3 |標準のみ|
| `test_untyped_formal_arguments` | 16.8 16.12 11.12 16.14.3 |標準のみ|
| `test_sequence_local_formal_arguments` | 16.8.2 16.10 16.12.7 16.14.1 |標準のみ|
| `test_sequence_operator_precedence` | 16.9.1 16.9.7 16.9.5 16.9.9 |標準のみ|
| `test_sequence_consecutive_repetition` | 16.9.2 16.9.2.1 16.14.3 |標準のみ|
| `test_sequence_goto_nonconsecutive` | 16.9.2 16.14.3 |標準のみ|
| `test_comb_stable_multiinstance` | 16.9.3 |verilator@5.052|
| `test_past_deep_history` | 16.9.3 16.5.1 16.14.7 |verilator@5.052|
| `test_past_gating_expression` | 16.9.3 16.5.1 16.14.6 |標準のみ|
| `test_sampled_function` | 16.9.3 |verilator@5.052|
| `test_sampled_in_action_block` | 16.9.3 16.14.1 16.5.1 4.4.2 |標準のみ|
| `test_system_sampled` | 16.9.3 |verilator@5.052|
| `test_value_change_first_tick` | 16.9.3 16.5.1 16.14.6 6.8 |標準のみ|
| `test_value_change_functions_on_vectors` | 16.9.3 16.14.7 |verilator@5.052|
| `test_global_clocking_sampled_functions` | 16.9.4 16.9.3 14.14 16.14.1 16.14.3 |標準のみ|
| `test_sequence_and_or_intersect` | 16.9.5 16.9.6 16.9.7 16.14.3 |標準のみ|
| `test_sequence_first_match` | 16.9.8 16.9.7 16.14.3 |標準のみ|
| `test_sequence_throughout_within` | 16.9.9 16.9.10 16.9.6 16.14.3 |標準のみ|
| `test_sequence_instance_vs_triggered` | 16.9.11 16.13.6 16.7 |標準のみ|
| `test_sequence_local_variables` | 16.10 16.11 16.12.7 16.14.1 16.14.3 |標準のみ|
| `test_comb_assert_binary_ops` | 16.12 11.4.3 11.4.10 |verilator@5.052|
| `test_sva_array_bitselect` | 16.12 16.6 |verilator@5.052|
| `test_sva_cast_expression` | 16.12 6.24.1 |verilator@5.052|
| `test_sva_range_select` | 16.12 11.4.13 |verilator@5.052|
| `test_property_not_or_and` | 16.12.3 16.12.4 16.12.5 16.12.2 16.12.7 16.14.1 |標準のみ|
| `test_property_if_else_case` | 16.12.6 16.12.16 16.12.7 16.14.1 |verilator@5.052|
| `test_property_implies_iff_followed_by` | 16.12.8 16.12.9 16.12.7 16.14.1 |標準のみ|
| `test_property_nexttime_eventually` | 16.12.10 16.12.13 16.12.7 16.14.1 |標準のみ|
| `test_property_always_ranges` | 16.12.11 16.12.15 16.12.7 16.14.1 |verilator@5.052|
| `test_property_until` | 16.12.12 16.12.7 16.14.1 |verilator@5.052|
| `test_property_abort` | 16.12.14 16.5.1 16.12.7 16.14.1 |標準のみ|
| `test_recursive_properties` | 16.12.17 16.12.19 16.12.7 16.14.1 |標準のみ|
|`test_illegal_nonoverlapping_antecedent_no_match`（規格違反）| 16.12.22 16.12.7 16.9.6 |標準のみ|
|`test_illegal_overlapping_antecedent_empty_only`（規格違反）| 16.12.22 16.12.7 |標準のみ|
|`test_illegal_sequence_property_empty_match`（規格違反）| 16.12.22 16.12 |標準のみ|
| `test_multiclock_sequences` | 16.13.1 16.13.2 16.13.3 16.14.1 16.14.3 |標準のみ|
| `test_sequence_matched_across_clocks` | 16.13.5 16.13.6 16.14.3 |標準のみ|
| `test_sequence_triggered` | 16.13.6 9.4.2.4 9.4.3 24.3 16.14.3 |標準のみ|
| `test_sequence_local_variable_initialization` | 16.13.7 16.10 16.8 |標準のみ|
| `test_assertion_clocked_by_named_event` | 16.14.1 16.5 16.14.6 16.16 |verilator@5.052|
| `test_cover_disable_iff` | 16.14.3 16.12 16.15 |標準のみ|
| `test_cover_property_restrict` | 16.14.3 16.14.4 16.14.2 16.12.2 |標準のみ|
| `test_procedural_assertion_in_initial` | 16.14.6 16.14.5 16.14.1 |標準のみ|
| `test_procedural_concurrent_assertions` | 16.14.6 16.14.6.1 16.14.6.4 16.5.1 16.14.1 |標準のみ|
| `test_procedural_assertion_no_glitch` | 16.14.6.2 16.14.6.3 16.14.6 16.14.6.1 |標準のみ|
| `test_inferred_clock_disable` | 16.14.7 16.15 14.12 16.12 |標準のみ|
| `test_default_disable_iff` | 16.15 16.12 16.14.1 |verilator@5.052|
|`test_illegal_multiclock_two_leading_clocks`（規格違反）| 16.16.1 16.16 |標準のみ|
| `test_multiclock_leading_clock` | 16.16.1 16.13.1 16.16 |標準のみ|
| `test_expect_statement` | 16.17 |標準のみ|
| `test_clocking_block_assertions` | 16.18 14.3 14.4 16.5.1 16.14.1 |標準のみ|

<a id="chapter-17"></a>

### 章 17

20 手書きテスト対象範囲は9節で、すべて引用済み。そのうち4節は1本のテストだけから引用される。対象は17.4、17.6、17.7.2、17.7.3。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_checker_always_comb_output` | 17.2 17.5 17.7.1 17.3 |標準のみ|
| `test_checker_concurrent_assertion` | 17.2 17.3 16.14 14.12 |標準のみ|
| `test_checker_in_package` | 17.2 17.3 17.8 16.9.3 |標準のみ|
|`test_illegal_checker_module_instance`（規格違反）| 17.2 |verilator@5.052|
| `test_checker_port_connections` | 17.3 17.2 17.5 17.7.1 |標準のみ|
| `test_checker_procedural_instance` | 17.3 16.14.6 17.5 |標準のみ|
|`test_illegal_checker_in_checker_procedure`（規格違反）| 17.3 17.5 |標準のみ|
|`test_illegal_checker_in_fork`（規格違反）| 17.3 9.3.2 |標準のみ|
| `test_checker_context_inference` | 17.4 16.14.7 14.12 16.15 |標準のみ|
| `test_checker_always_ff_sampled` | 17.5 17.7 17.7.1 17.2 16.5.1 |標準のみ|
|`test_illegal_checker_plain_always`（規格違反）| 17.5 |標準のみ|
| `test_checker_covergroup` | 17.6 17.7.1 19.3 19.11.1 |標準のみ|
| `test_checker_free_variables_assigned` | 17.7 17.7.1 17.7.2 17.3 |標準のみ|
|`test_illegal_checker_net_declaration`（規格違反）| 17.7 17.2 |verilator@5.052|
|`test_illegal_checker_always_ff_blocking`（規格違反）| 17.7.1 17.5 |標準のみ|
|`test_illegal_checker_free_variable_continuous_assign`（規格違反）| 17.7.1 17.7 |標準のみ|
|`test_illegal_checker_variable_hierarchical_write`（規格違反）| 17.7.1 23.6 |標準のみ|
|`test_illegal_checker_variable_initial_assignment`（規格違反）| 17.7.1 17.5 |標準のみ|
| `test_checker_reactive_triggered` | 17.7.3 17.5 16.13.6 4.4.2.5 |標準のみ|
| `test_checker_default_arg_function` | 17.8 17.2 17.3 17.7.1 |標準のみ|

<a id="chapter-18"></a>

### 章 18

36 手書きテスト対象の44条項はすべて引用済みで、うち23条項を引用するテストは各1本のみです：18.3、18.4.1、18.5.1、18.5.2、18.5.4、18.5.5、18.5.7.1、18.5.7.2、18.5.8、18.5.11、18.5.12、18.5.13.1、18.5.13.2、18.7.1、18.10、18.11.1、18.12.1、18.14.3、18.15、18.16、18.17.2、18.17.3、18.17.5。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_randc_full_cycle` | 18.4.2 |verilator@5.052|
| `test_extern_constraint_function` | 18.5.1 18.5.11 |verilator@5.052|
| `test_constraint_inheritance_override` | 18.5.2 18.6.3 |verilator@5.052|
| `test_dist_zero_weight` | 18.5.3 |verilator@5.052|
| `test_constraint_unique` | 18.5.4 |verilator@5.052|
| `test_constraint_implication_ifelse` | 18.5.5 18.5.6 18.7 |verilator@5.052|
| `test_constraint_foreach_sum` | 18.5.7.1 18.5.7.2 |verilator@5.052|
| `test_global_constraints_rand_handles` | 18.5.8 18.4 18.6.1 |verilator@5.052|
|`test_illegal_solve_before_randc`（規格違反）| 18.5.9 18.4.2 |verilator@5.052|
|`test_illegal_solve_before_state_variable`（規格違反）| 18.5.9 |標準のみ|
| `test_solve_before_same_solutions` | 18.5.9 18.5.6 18.6.1 |verilator@5.052|
| `test_static_constraint_mode` | 18.5.10 18.9 |verilator@5.052|
| `test_constraint_guard_null` | 18.5.12 18.5.6 |標準のみ|
| `test_soft_constraint_priority` | 18.5.13.1 18.5.13.2 18.5.13 18.7 |verilator@5.052|
| `test_rand_constraints_hold` | 18.6.1 18.3 18.4.1 18.5 11.4.13 |verilator@5.052|
| `test_pre_post_randomize` | 18.6.2 18.4 |verilator@5.052|
| `test_randomize_failure_keeps_values` | 18.6.3 18.6.2 18.12 |標準のみ|
| `test_randomize_with_local_scope` | 18.7.1 18.7 |verilator@5.052|
|`test_illegal_rand_mode_non_random`（規格違反）| 18.8 |verilator@5.052|
| `test_rand_mode_array_element` | 18.8 18.4 8.9 |標準のみ|
| `test_rand_mode_constraint_mode` | 18.8 18.9 |verilator@5.052|
| `test_dist_weights_changed` | 18.10 18.5.3 18.5.6 |verilator@5.052|
| `test_randomize_argument_list` | 18.11 18.6.1 18.4 |verilator@5.052|
| `test_randomize_null_checker` | 18.11.1 18.11 |verilator@5.052|
| `test_std_randomize_with` | 18.12.1 18.12 |verilator@5.052|
| `test_urandom_seed_repeatable` | 18.13.1 18.14.2 7.4.6 |verilator@5.052|
| `test_urandom_range_bounds` | 18.13.2 18.13.1 |iverilog@13.0|
| `test_random_state_restore` | 18.13.4 18.13.5 18.13.3 18.14.3 18.13.2 |verilator@5.052|
| `test_thread_stability_fork` | 18.14.2 18.14.1 18.13.4 18.13.5 |verilator@5.052|
| `test_srandom_object_repeatable` | 18.15 18.13.3 18.14.1 |verilator@5.052|
| `test_randcase_zero_weight` | 18.16 |verilator@5.052|
| `test_randsequence` | 18.17 18.17.1 18.17.3 |verilator@5.052|
| `test_randsequence_control` | 18.17 18.17.2 18.17.4 18.17.6 18.17.7 |verilator@5.052|
| `test_randsequence_weights` | 18.17.1 18.17 18.17.4 |verilator@5.052|
| `test_rand_join_interleaving` | 18.17.5 18.17 |verilator@5.052|
| `test_randsequence_return_values` | 18.17.7 18.17 18.17.6 |標準のみ|

<a id="chapter-19"></a>

### 章 19

26 手書きテスト対象範囲は22節で、すべて引用済み。そのうち15節は1本のテストだけから引用される。対象は19.4.1、19.5.1.1、19.5.1.2、19.5.2、19.5.4、19.5.5、19.5.6、19.5.7、19.6.1.3、19.6.1.4、19.6.3、19.8.1、19.9、19.10、19.11.3。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_cg_clocking_event` | 19.3 19.11.1 |verilator@5.052|
| `test_cg_embedded_in_class` | 19.4 19.11.1 |verilator@5.052|
| `test_cg_embedded_inheritance` | 19.4.1 19.4 19.11 19.11.1 19.8 |標準のみ|
| `test_cg_iff_guard` | 19.5 19.11.1 |verilator@5.052|
| `test_cg_fixed_count_bins` | 19.5.1 19.11.1 |標準のみ|
| `test_cg_value_bins_default` | 19.5.1 19.5 19.11.1 19.8 |verilator@5.052|
| `test_cg_bins_with_set_expr` | 19.5.1.1 19.5.1.2 19.5.1 19.8 19.11.1 |標準のみ|
| `test_cg_transition_bins` | 19.5.2 19.11.1 |verilator@5.052|
| `test_cg_auto_bins_max` | 19.5.3 19.7 19.11.1 |verilator@5.052|
| `test_cg_enum_auto_bins` | 19.5.3 19.11.1 |標準のみ|
| `test_cg_wildcard_bins` | 19.5.4 19.11.1 |verilator@5.052|
| `test_cg_ignore_bins` | 19.5.5 19.11.1 |標準のみ|
| `test_cg_illegal_bins_removed` | 19.5.6 19.11.1 |標準のみ|
| `test_cg_bins_value_resolution` | 19.5.7 19.5 19.11.1 |標準のみ|
| `test_cg_cross_coverage` | 19.6 19.11.2 19.11 |標準のみ|
| `test_cg_cross_select_bins` | 19.6.1 19.6.1.1 19.6.2 19.11.2 19.8 |標準のみ|
| `test_cg_cross_with_expression` | 19.6.1.2 19.6.1 19.6.2 19.11.2 |標準のみ|
| `test_cg_cross_set_expression` | 19.6.1.4 19.6.1.3 19.6.1.2 19.11.2 |標準のみ|
| `test_cg_cross_illegal_excluded` | 19.6.3 19.6.1 19.11.2 |標準のみ|
| `test_cg_at_least` | 19.7 19.11.1 |標準のみ|
| `test_cg_start_stop_counts` | 19.8 19.11.1 |標準のみ|
| `test_cg_sample_arguments` | 19.8.1 19.8 19.11.1 |verilator@5.052|
| `test_get_coverage_weights` | 19.9 19.7.1 19.11 19.11.1 |標準のみ|
| `test_option_struct_members` | 19.10 19.7 19.7.1 |標準のみ|
| `test_cg_item_weighted_average` | 19.11 19.11.1 19.7 |標準のみ|
| `test_cg_type_coverage_merge` | 19.11.3 19.7 19.7.1 19.8 19.5.1 |標準のみ|

<a id="chapter-22"></a>

### 章 22

30 手書きテスト対象範囲は20節で、すべて引用済み。そのうち10節は1本のテストだけから引用される。対象は22.5.3、22.9、22.10、22.14.2、22.14.3、22.14.4、22.14.6、22.14.7、22.14.8、22.14.9。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_resetall_default_nettype` | 22.3 22.8 6.10 |iverilog@13.0 verilator@5.052|
| `test_include_file_declarations` | 22.4 |iverilog@13.0|
| `test_include_guard_twice` | 22.4 22.6 22.5.1 |iverilog@13.0|
| `test_include_guard_two_files` | 22.4 22.5.1 3.12.1 |iverilog@13.0|
| `test_include_nested` | 22.4 |iverilog@13.0|
| `test_compiler_directives` | 22.5.1 22.6 22.7 22.8 |iverilog@13.0|
| `test_compiler_directives_comprehensive` | 22.5.1 22.5.2 22.6 22.7 |iverilog@13.0|
| `test_conditional_compilation_2` | 22.5.1 22.6 |iverilog@13.0|
| `test_define_with_args` | 22.5.1 |iverilog@13.0|
| `test_directive_corner_cases` | 22.5.1 22.6 22.13 |iverilog@13.0|
| `test_directive_nested` | 22.5.1 22.6 |iverilog@13.0|
| `test_ieee_ch22_directives_edge` | 22.5.1 22.6 |iverilog@13.0|
| `test_macro_advanced` | 22.5.1 22.6 |iverilog@13.0|
| `test_macro_args` | 22.5.1 |iverilog@13.0|
| `test_macro_concat` | 22.5.1 |iverilog@13.0|
| `test_macro_redefine_string_literal` | 22.5.1 |iverilog@13.0|
| `test_undef` | 22.5.2 22.6 |iverilog@13.0|
| `test_undefineall` | 22.5.3 22.5.1 22.6 |verilator@5.052|
| `test_conditional_compilation` | 22.6 |iverilog@13.0|
| `test_ifdef_nested` | 22.6 |iverilog@13.0|
| `test_timescale_child_units_in_parent` | 22.7 3.14.2.3 20.3.1 |iverilog@13.0|
| `test_timescale_delay_rounded_to_precision` | 22.7 20.3.3 |iverilog@13.0|
|`test_illegal_default_nettype_none_assign`（規格違反）| 22.8 |iverilog@13.0|
|`test_illegal_default_nettype_none_port`（規格違反）| 22.8 6.10 |iverilog@13.0|
| `test_unconnected_drive` | 22.9 |iverilog@13.0|
| `test_vpi_celldefine` | 22.10 22.3 37.10 |iverilog@13.0|
| `test_pragma_unrecognized` | 22.11 |iverilog@13.0 verilator@5.052|
| `test_line_directive` | 22.12 22.13 |iverilog@13.0 verilator@5.052|
| `test_begin_keywords_1364_2005` | 22.14 22.14.5 |iverilog@13.0 verilator@5.052|
| `test_begin_keywords_versions` | 22.14 22.14.2 22.14.3 22.14.4 22.14.5 22.14.6 22.14.7 22.14.8 22.14.9 |iverilog@13.0 verilator@5.052|

<a id="chapter-24"></a>

### 章 24

18 手書きテスト対象範囲は6節で、すべて引用済み。そのうち1節は1本のテストだけから引用される。対象は24.3.2。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
|`test_illegal_anonymous_program_hierarchical_reference`（規格違反）| 24.3 24.6 |標準のみ|
|`test_illegal_program_always`（規格違反）| 24.3 |iverilog@13.0 verilator@5.052|
|`test_illegal_program_module_instance`（規格違反）| 24.3 |iverilog@13.0 verilator@5.052|
|`test_illegal_program_signal_from_module`（規格違反）| 24.3 23.6 |標準のみ|
| `test_program_automatic_lifetime` | 24.3 13.4.2 6.21 |iverilog@13.0 verilator@5.052|
| `test_program_comprehensive` | 24.3 24.2 4.4 |iverilog@13.0|
| `test_program_end_kills_descendants` | 24.3 9.2.3 |標準のみ|
| `test_program_hierarchical_reference_between_programs` | 24.3 24.5 23.6 |iverilog@13.0|
| `test_program_reactive` | 24.3 24.4 4.4 |iverilog@13.0|
| `test_program_variables` | 24.3 |iverilog@13.0|
| `test_program_reactive_sees_nba` | 24.3.1 4.4.1 4.4.2.6 |標準のみ|
| `test_program_port_reactive` | 24.3.2 24.3.1 4.5 |標準のみ|
| `test_program_stimulus_after_clock_edge` | 24.4 24.3.1 4.4.2.6 |標準のみ|
|`test_illegal_module_calls_program_task`（規格違反）| 24.5 24.3 |標準のみ|
| `test_program_calls_module_task` | 24.5 24.3.1 4.4.2.6 |標準のみ|
| `test_anonymous_program` | 24.6 24.3 3.12.1 |標準のみ|
| `test_exit_outside_program_ignored` | 24.7 24.3 |標準のみ|
| `test_program_exit` | 24.7 24.3 9.2.3 |標準のみ|

<a id="chapter-35"></a>

### 章 35

21 手書きテスト対象は17条項で、すべて引用済みです。うち8条項はテストが1本だけです：35.2.1、35.5.1.1、35.5.1.2、35.5.1.3、35.5.1.4、35.5.1.5、35.6.1.1、35.6.2。

|テスト| `:lrm:` |オラクル|
| --- | --- | --- |
| `test_dpi_one_function_two_imports` | 35.2.1 13.6 35.5.4 35.6 |verilator@5.052|
| `test_dpi_linkage_names` | 35.4 35.5.4 |verilator@5.052|
| `test_dpi_import_zero_time` | 35.5.1.1 35.5.1 10.3.2 4.4.2.3 |verilator@5.052|
| `test_dpi_pure_context_properties` | 35.5.1.3 35.5.2 35.5.3 35.7 |verilator@5.052|
| `test_dpi_chandle_foreign_memory` | 35.5.1.4 6.14 35.5.6 |verilator@5.052|
| `test_dpi_import_task_reentrant` | 35.5.1.5 35.8 35.5.3 |標準のみ|
| `test_dpi_pure_function` | 35.5.2 35.5.4 10.3 |verilator@5.052|
| `test_dpi_import_small_types` | 35.5.5 35.5.6 H.7.4 H.8.7 H.8.9 H.8.10 |verilator@5.052|
| `test_dpi_shortreal` | 35.5.6 H.7.4 H.8.7 H.8.9 6.12 |標準のみ|
| `test_dpi_sized_unpacked_array` | 35.5.6 H.7.6 H.8.7 |verilator@5.052|
| `test_dpi_unpacked_struct` | 35.5.6 H.7.8 H.8.7 |標準のみ|
| `test_dpi_unsigned_types` | 35.5.6 35.5.5 H.7.4 H.8.9 |verilator@5.052|
| `test_dpi_open_array` | 35.5.6.1 35.6.1.1 H.12.1 H.12.2 H.12.3 H.12.7 |verilator@5.052|
| `test_dpi_open_array_2d` | 35.5.6.1 H.12.2 H.12.3 H.7.6 |verilator@5.052|
| `test_dpi_import_output_inout` | 35.6.2 35.5.1.2 35.6.1 H.8.8 H.8.10 |verilator@5.052|
| `test_dpi_export_function` | 35.7 35.5.3 35.4 |verilator@5.052|
| `test_dpi_export_task_time` | 35.8 35.5.3 35.5.4 35.9 |標準のみ|
| `test_dpi_disable_import_task` | 35.9 35.8 35.5.3 |標準のみ|
| `test_dpi_packed_canonical` | H.7.7 H.8.4 H.11.5 35.5.6 |verilator@5.052|
| `test_dpi_context_scope` | H.9.3 35.5.3 H.9.2 |verilator@5.052|
| `test_dpi_logic_values` | H.10.1.1 H.10.1.2 H.7.7 H.8.8 |標準のみ|


<a id="tests-whose-expected-output-follows-the-standard-only"></a>

## 期待出力の根拠が規格のみのテスト

人によるレビュー対象：`:oracle: spec`だけのもの。すなわち、Icarus Verilog 13.0もVerilator 5.052も期待出力を生成しないもの。[docs/simulator-differences.md](simulator-differences.ja.md)と各テストのコメントにおいて，各リリースが異なる理由を説明した。

|章|テスト|名前|
| ---: | ---: | --- |
| 3 | 2 | `test_name_spaces`, `test_timeunit_precedence` |
| 4 | 3 | `test_pli_nba_synch_callback`, `test_reactive_region_set_order`, `test_sched_procedural_assign_deassign` |
| 5 | 1 | `test_string_literal_to_unpacked_byte_array` |
| 6 | 19 | `test_enum_default_and_invalid_index`, `test_enum_wider_than_64_bits_name`, `test_event_variable_alias_null`, `test_illegal_anonymous_struct_not_equivalent`, `test_illegal_interconnect_assigned`, `test_illegal_interconnect_data_type`, `test_illegal_net_type_then_reg`, `test_nettype_initial_value_resolution`, `test_nettype_rename_matches`, `test_nettype_resolution`, `test_shortreal_single_precision`, `test_string_conversion`, `test_string_edge`, `test_string_functions_comprehensive`, `test_string_getc_is_byte`, `test_string_ops_edge_cases`, `test_trireg_default_value_strength`, `test_trireg_holds_charge`, `test_type_operator_matching_types` |
| 7 | 8 | `test_array_index_wider_than_64_bits`, `test_array_map_method`, `test_assoc_allocate_on_write`, `test_assoc_array_unknown_index`, `test_assoc_traversal_narrow_index`, `test_queue_method_edges`, `test_queue_reference_persistence`, `test_tagged_union_packed` |
| 8 | 14 | `test_class_extends`, `test_class_inheritance`, `test_class_inheritance_virtual_super`, `test_illegal_class_implements_type_parameter`, `test_illegal_implements_forward_typedef`, `test_illegal_interface_class_typedef_conflict`, `test_illegal_weak_reference_non_class`, `test_interface_class_cast`, `test_interface_class_randomize`, `test_interface_class_typedef_conflict_resolved`, `test_object_strongly_reachable`, `test_weak_reference_get_clear`, `test_weak_reference_get_id`, `test_weak_reference_wait_cleared` |
| 9 | 9 | `test_always_comb_sensitivity_exceptions`, `test_illegal_always_comb_other_writer`, `test_illegal_always_ff_other_writer`, `test_illegal_always_ff_written_via_function`, `test_illegal_always_latch_other_writer`, `test_process_await_from_fork_child`, `test_process_kill_self`, `test_process_suspend_resume_await`, `test_wait_sequence_triggered` |
| 10 | 4 | `test_alias_part_select_and_ports`, `test_assignment_like_contexts`, `test_net_delay_port_driver_and_undriven`, `test_unpacked_array_concat_rules` |
| 11 | 5 | `test_inside_nested_unpacked_arrays`, `test_memory_invalid_address_2state`, `test_real_operand_result_types`, `gen/ch11/test_gen_xz_cond_07`, `gen/ch11/test_gen_xz_cond_08` |
| 12 | 1 | `test_pattern_matching` |
| 13 | 2 | `test_illegal_function_in_continuous_assign_output`, `test_illegal_ref_in_static_task` |
| 14 | 5 | `test_clocking_input_skew_fractional`, `test_clocking_interface_modport`, `test_clocking_output_net_driver`, `test_clocking_synchronous_events`, `test_global_clocking` |
| 15 | 4 | `test_event_merge`, `test_event_nonblocking_trigger`, `test_event_null_compare`, `test_wait_order` |
| 16 | 41 | `test_assert_immed_2`, `test_clocking_block_assertions`, `test_cover_disable_iff`, `test_cover_property_restrict`, `test_deferred_assertion_flush`, `test_deferred_assertion_per_process`, `test_expect_statement`, `test_global_clocking_sampled_functions`, `test_illegal_multiclock_two_leading_clocks`, `test_illegal_nonoverlapping_antecedent_no_match`, `test_illegal_overlapping_antecedent_empty_only`, `test_illegal_sequence_property_empty_match`, `test_immediate_assertions_2`, `test_inferred_clock_disable`, `test_multiclock_leading_clock`, `test_multiclock_sequences`, `test_past_gating_expression`, `test_procedural_assertion_in_initial`, `test_procedural_assertion_no_glitch`, `test_procedural_concurrent_assertions`, `test_property_abort`, `test_property_implies_iff_followed_by`, `test_property_nexttime_eventually`, `test_property_not_or_and`, `test_recursive_properties`, `test_sampled_in_action_block`, `test_sequence_and_or_intersect`, `test_sequence_consecutive_repetition`, `test_sequence_first_match`, `test_sequence_formal_arguments`, `test_sequence_goto_nonconsecutive`, `test_sequence_instance_vs_triggered`, `test_sequence_local_formal_arguments`, `test_sequence_local_variable_initialization`, `test_sequence_local_variables`, `test_sequence_matched_across_clocks`, `test_sequence_operator_precedence`, `test_sequence_throughout_within`, `test_sequence_triggered`, `test_untyped_formal_arguments`, `test_value_change_first_tick` |
| 17 | 18 | `test_checker_always_comb_output`, `test_checker_always_ff_sampled`, `test_checker_concurrent_assertion`, `test_checker_context_inference`, `test_checker_covergroup`, `test_checker_default_arg_function`, `test_checker_free_variables_assigned`, `test_checker_in_package`, `test_checker_port_connections`, `test_checker_procedural_instance`, `test_checker_reactive_triggered`, `test_illegal_checker_always_ff_blocking`, `test_illegal_checker_free_variable_continuous_assign`, `test_illegal_checker_in_checker_procedure`, `test_illegal_checker_in_fork`, `test_illegal_checker_plain_always`, `test_illegal_checker_variable_hierarchical_write`, `test_illegal_checker_variable_initial_assignment` |
| 18 | 5 | `test_constraint_guard_null`, `test_illegal_solve_before_state_variable`, `test_rand_mode_array_element`, `test_randomize_failure_keeps_values`, `test_randsequence_return_values` |
| 19 | 18 | `test_cg_at_least`, `test_cg_bins_value_resolution`, `test_cg_bins_with_set_expr`, `test_cg_cross_coverage`, `test_cg_cross_illegal_excluded`, `test_cg_cross_select_bins`, `test_cg_cross_set_expression`, `test_cg_cross_with_expression`, `test_cg_embedded_inheritance`, `test_cg_enum_auto_bins`, `test_cg_fixed_count_bins`, `test_cg_ignore_bins`, `test_cg_illegal_bins_removed`, `test_cg_item_weighted_average`, `test_cg_start_stop_counts`, `test_cg_type_coverage_merge`, `test_get_coverage_weights`, `test_option_struct_members` |
| 20 | 10 | `test_array_query_fixed_dimensions`, `test_assert_action_control_tasks`, `test_assertcontrol`, `test_assertion_control_levels_and_scopes`, `test_associative_array_query_functions`, `test_illegal_array_query_variable_dimension`, `test_pla_async_array_plane`, `test_system_call_null_command`, `test_timeunit_timeprecision_functions`, `test_timeunit_unit_root` |
| 21 | 4 | `test_display_format`, `test_format_p_struct`, `test_readmem_multidim_packed`, `test_vcd_dump_readback` |
| 23 | 8 | `test_empty_named_connection_ignores_default`, `test_extern_module`, `test_illegal_defparam_early_resolution`, `test_illegal_interface_port_unconnected`, `test_illegal_named_interface_port_other_type`, `test_interconnect_port_merge`, `test_interconnect_primitive_terminal`, `test_vpi_port_kind_defaults` |
| 24 | 11 | `test_anonymous_program`, `test_exit_outside_program_ignored`, `test_illegal_anonymous_program_hierarchical_reference`, `test_illegal_module_calls_program_task`, `test_illegal_program_signal_from_module`, `test_program_calls_module_task`, `test_program_end_kills_descendants`, `test_program_exit`, `test_program_port_reactive`, `test_program_reactive_sees_nba`, `test_program_stimulus_after_clock_edge` |
| 25 | 4 | `test_illegal_specify_ref_port_terminal`, `test_interface_specify_terminal`, `test_interface_task_export`, `test_modport_clocking_block` |
| 26 | 1 | `test_package_variable_wakes_processes` |
| 27 | 1 | `test_genvar_hierarchical_reference` |
| 28 | 34 | `test_rcmos_reduction`, `test_trireg_charge_decay`, `test_trireg_charge_strength`, `test_trireg_three_delay_form`, `test_wired_logic_strength`, `gen/ch28/test_gen_strength_triand_02`, `gen/ch28/test_gen_strength_triand_03`, `gen/ch28/test_gen_strength_triand_04`, `gen/ch28/test_gen_strength_triand_05`, `gen/ch28/test_gen_strength_triand_06`, `gen/ch28/test_gen_strength_triand_07`, `gen/ch28/test_gen_strength_triand_08`, `gen/ch28/test_gen_strength_trior_02`, `gen/ch28/test_gen_strength_trior_03`, `gen/ch28/test_gen_strength_trior_04`, `gen/ch28/test_gen_strength_trior_05`, `gen/ch28/test_gen_strength_trior_06`, `gen/ch28/test_gen_strength_trior_07`, `gen/ch28/test_gen_strength_trior_08`, `gen/ch28/test_gen_strength_wand_01`, `gen/ch28/test_gen_strength_wand_02`, `gen/ch28/test_gen_strength_wand_03`, `gen/ch28/test_gen_strength_wand_04`, `gen/ch28/test_gen_strength_wand_05`, `gen/ch28/test_gen_strength_wand_06`, `gen/ch28/test_gen_strength_wand_07`, `gen/ch28/test_gen_strength_wand_08`, `gen/ch28/test_gen_strength_wor_02`, `gen/ch28/test_gen_strength_wor_03`, `gen/ch28/test_gen_strength_wor_04`, `gen/ch28/test_gen_strength_wor_05`, `gen/ch28/test_gen_strength_wor_06`, `gen/ch28/test_gen_strength_wor_07`, `gen/ch28/test_gen_strength_wor_08` |
| 29 | 3 | `test_illegal_udp_conflicting_entries`, `test_udp_initial_value_not_delayed`, `test_udp_instance_array_delays` |
| 30 | 4 | `test_illegal_showcancelled_after_path`, `test_negative_pulse_cancelled`, `test_specify_condition_unknown_true`, `test_specify_pulse_filtering` |
| 31 | 18 | `test_illegal_nochange_edge_control`, `test_illegal_period_reference_not_edge`, `test_illegal_width_reference_not_edge`, `test_timing_conditioned_event`, `test_timing_edge_control_specifier`, `test_timing_fullskew_event_based`, `test_timing_nochange`, `test_timing_nochange_window_endpoints`, `test_timing_notifier_x_and_z`, `test_timing_recovery_removal_recrem`, `test_timing_recrem_windows`, `test_timing_setup_hold_notifier`, `test_timing_setuphold`, `test_timing_skew_checks`, `test_timing_timeskew_flags`, `test_timing_timeskew_remain_active`, `test_timing_vector_signal`, `test_timing_width_period_notifier` |
| 32 | 10 | `test_sdf_cond_iopath`, `test_sdf_device_all_paths`, `test_sdf_device_primitive_without_paths`, `test_sdf_increment_absolute`, `test_sdf_label_specparam`, `test_sdf_mtm_spec`, `test_sdf_port_delay`, `test_sdf_scale_factors`, `test_sdf_timing_check_limits`, `test_sdf_width_period_limits` |
| 33 | 14 | `test_config_defparam_precedence`, `test_config_design_top`, `test_config_design_two_tops`, `test_config_hierarchical`, `test_config_instance_deep_path`, `test_config_instance_use`, `test_config_library_binding_format`, `test_config_parameter_override`, `test_illegal_config_cell_library_liblist`, `test_illegal_config_hierarchical_name_in_expression`, `test_illegal_config_instance_inside_other_config`, `test_illegal_config_localparam_not_literal`, `test_illegal_config_package_binding`, `test_illegal_config_two_default_liblists` |
| 35 | 6 | `test_dpi_disable_import_task`, `test_dpi_export_task_time`, `test_dpi_import_task_reentrant`, `test_dpi_logic_values`, `test_dpi_shortreal`, `test_dpi_unpacked_struct` |
| 36 | 6 | `test_vpi_chk_error_callbacks`, `test_vpi_compiletf_sizetf`, `test_vpi_expression_operands`, `test_vpi_systf_argument_on_demand`, `test_vpi_systf_function_in_continuous_assign`, `test_vpi_systf_function_types` |
| 37 | 46 | `test_vpi_active_time_format`, `test_vpi_array_var`, `test_vpi_callback_objects`, `test_vpi_case_loop_force_stmts`, `test_vpi_class_definitions`, `test_vpi_class_obj_id`, `test_vpi_clocking_blocks`, `test_vpi_constant_select`, `test_vpi_constraint_items`, `test_vpi_cont_assign_drivers`, `test_vpi_delay_expressions`, `test_vpi_file_line`, `test_vpi_frames_and_threads`, `test_vpi_generate_scopes`, `test_vpi_instance_arrays`, `test_vpi_interconnect_elements`, `test_vpi_interface_program`, `test_vpi_interface_typespecs`, `test_vpi_is_protected_property`, `test_vpi_iterator_objects`, `test_vpi_let_expr_arguments`, `test_vpi_module_paths`, `test_vpi_module_relations`, `test_vpi_named_events`, `test_vpi_net_properties`, `test_vpi_nettype_declarations`, `test_vpi_packed_array_vars`, `test_vpi_parameters`, `test_vpi_ports`, `test_vpi_prefix_has_actual`, `test_vpi_process_statements`, `test_vpi_property_sequence_decls`, `test_vpi_property_sequence_exprs`, `test_vpi_put_value_side_effect`, `test_vpi_ref_obj_actual`, `test_vpi_relationships_and_tags`, `test_vpi_scopes`, `test_vpi_struct_typespecs`, `test_vpi_systf_argument_expressions`, `test_vpi_time_queue`, `test_vpi_timing_checks`, `test_vpi_type_strings`, `test_vpi_udp_definitions`, `test_vpi_variable_drivers_loads`, `test_vpi_variable_properties`, `test_vpi_virtual_interface_vars` |
| 38 | 8 | `test_vpi_gate_delays`, `test_vpi_get_cb_info`, `test_vpi_get_value_array`, `test_vpi_handle_by_multi_index`, `test_vpi_put_value_array`, `test_vpi_put_value_delay_modes`, `test_vpi_statement_callbacks`, `test_vpi_value_change_event` |
| 39 | 13 | `test_vpi_assertion_callback_scope_removal`, `test_vpi_assertion_callbacks`, `test_vpi_assertion_control`, `test_vpi_assertion_deferred_queue`, `test_vpi_assertion_gclk_future_callback`, `test_vpi_assertion_handles`, `test_vpi_assertion_immediate_callbacks`, `test_vpi_assertion_kill_reset`, `test_vpi_assertion_procedural_queue`, `test_vpi_assertion_step_callbacks`, `test_vpi_assertion_system_control`, `test_vpi_assertion_system_lock_reset`, `test_vpi_assertion_system_vacuous_actions` |
| 40 | 11 | `test_coverage_api_minimum_types`, `test_coverage_control_bad_arguments`, `test_coverage_control_results`, `test_coverage_get_values`, `test_coverage_reset_and_stop`, `test_coverage_root_hierarchy`, `test_coverage_save_merge`, `test_coverage_scope_sums`, `test_vpi_coverage_assertion`, `test_vpi_coverage_control`, `test_vpi_fsm_from_pragmas` |


<a id="plan-for-phases-1-to-4"></a>

## 段階計画1〜4

<a id="phase-1-runners"></a>

### フェーズ1：ランナー

- `tools/suite_results.py`に、`:defines:`（`NAME`または`NAME=VALUE`を空白区切り）、`:incdirs:`（テストからの相対ディレクトリ）、`:top_module:`を追加し、すべてのランナーで渡す。対象はIcarus Verilog `-D`、`-I`、`-s`。Verilator `-D` , `-I` , `--top-module` ;kirimasim `+define+`、`+incdir+`、`--top=`（そのCLI.mdに列挙）。`:args:` `:files:` `:expected_exit:` と違法な設計はそのまま残る。
- README.md： "Metadata" の新しいフィールドと、ランナーがそれらをどのように使うか。
- 新しい各フィールドに小さなテストを1本ずつ用意します。`:defines:`から得るマクロ値、`:incdirs:`経由で見つける`` `include ``、およびトップ候補が2つあり`:top_module:`で片方を選ぶ設計です。他のフィールドには既にテストがある。

<a id="phase-2-lint-and-template"></a>

### フェーズ 2 : リントとテンプレート

- check.ymlのreadmeジョブで実行する`tools/lint_metadata.py`：必須フィールド、許可値、先頭の章がディレクトリと一致する`1800-2023 N.N...`形式の`:lrm:`、`:tags:`、x/zリテラルを含む`:fourstate: no`、存在する空でないファイルを指す`:expected_stdout:`、`:type: elaboration`と`:expected_stderr_regex:`を伴う場合に限る`:should_fail_because:`、および機械的に検査できる"Contributing"の規則を確認します。後者は行長、Verilatorという語で始まるコメント行の禁止、時刻表示時の`` `timescale ``です。指摘された既存テストは一覧化するだけで、変更は行いません。
- `tools/new_test.py ch16 test_name --lrm "16.9.3"`はヘッダと空の`.expected`を書き込む。README.md "Contributing" はどのように使うかを示します。

<a id="phase-3-tests"></a>

### フェーズ3：テスト

- 3-1：規格違反の設計を少なくとも20本用意します。まずテストがない上記3規則（`:final`、packed配列内のreal、always_comb内の遅延）を対象とし、次に同種の他の規則を規格に基づいて追加します。kirimasim `tests/suite/` は予期されるエラーを含む不正なデザインを持っています。移植された場合は このスイートの形で書き換えられます
- 3-2：上記の`tests/ch4`項目に少なくとも30本のテストを用意します。特に、非ブロッキング更新を伴う`wait`、`#0`の連鎖、ゼロ遅延のループ、関数内のfork-join_noneを、いずれも規格が実行順序を定める条件で確認します。
- 3-3：`width_sign`が使わないパスを通して64ビット以上の値に対する`generators/`の生成器（関数結果，`?:`の両腕，refとutdateの引数，taskの引数，`+:` , `-:`と可変インデックスのパートセレクト，部分書き込み，連結と複製，64以上のシフト，比較，`%h` , `%b` , `%d` , `$bits`），2‐stateと4‐statE，符号付きと無符号付き，上部チャンクにxとzを持つ。`tests/gen/`内のおよそ40ファイル。再生成できるよう生成器も保持する。
- 3-4：上表で未使用の機能、すなわち三重引用符の文字列、`` `ifdef ``式、`:final`、`:initial`、`:extends`、配列メソッドのindex引数、`rand real`、`[a +/- b]`、`[a +%- b]`、`type(this)`、dist内の`default :/`、`super.new(default)`、`union soft`。それぞれに正常系テストを用意し、条項に規則がある場合は規格違反の設計も用意する。既にテストがある機能（`map()`、`$timeunit`、`$timeprecision`、`$stacktrace`、`weak_reference`、covergroup `extends`）には、まだテストのない節についてだけ追加する。
- 3-5：`:args:`のテスト（各フォーマット`$value$plusargs`，数マッチのうち最初，マッチしない場合0），`:defines:` , `:incdirs:` , `:files:`のテスト（パッケージとインタフェースが別々のファイルにある，数コンパイルユニットを持つ`$unit`，3.12.1，ツールがどのようにファイルをグループ化するかに依存しない），`:top_module:`のテスト（約10）を行った。

<a id="phase-4-nightly-ratchet-optional"></a>

### フェーズ4：Nightlyの回帰検知（任意）

nightly.yml内のジョブ。`results`ブランチ（`latest/kirimasim.json`）で前回の実行時に一致したkirimasimのテストが一致しなくなった場合に失敗する。新規テストと未対応テストはこの検査を失敗させず、前回の実行がない場合は検査をスキップする。

各フェーズでは、すべてのテストにIcarus VerilogとVerilatorのランナーを実行し、専用スクリプトでREADMEの表とカタログを更新して、1つのコミットにまとめる。依頼されるまでpushしない。

<a id="final-report"></a>

## 最終報告書

上記のフェーズは2026-10-21に、各ローカルコミットとして実施した。ce32c60（この棚卸し）、b82e845（フェーズ1）、5a86259（フェーズ2）、59d87b3、afc9988、78194e0、05507ef、87fbcac（フェーズ3-1～3-5）、66fa34f（フェーズ4）、およびこの報告を追加するコミットである。

<a id="tests-added"></a>

### 追加されたテスト

全136テストのうち、シミュレーション実行用が87本、`generators/wide_paths.py`による自動生成が49本です。規格違反の設計は47本です。オラクル列は`:oracle:`に従う。"both"は`iverilog@13.0 verilator@5.052`である。

|章|テスト|両方|Icarus Verilog 13.0のみ|Verilator 5.052のみ|標準のみ|規格違反の設計|生成|
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 4 | 30 | 24 | 2 | 2 | 2 |||
| 5 | 2 | 1 || 1 || 1 ||
| 6 | 11 | 1 | 8 | 2 || 4 | 7 |
| 7 | 19 | 1 | 8 | 8 | 2 | 3 | 14 |
| 8 | 16 | 2 | 1 | 8 | 5 | 12 ||
| 9 | 4 || 4 ||| 4 ||
| 11 | 15 || 14 || 1 || 14 |
| 12 | 1 |||| 1 | 1 ||
| 13 | 18 | 2 | 6 | 8 | 2 | 4 | 14 |
| 18 | 4 ||| 1 | 3 | 2 ||
| 21 | 2 | 2 ||||||
| 22 | 9 | 7 || 2 || 2 ||
| 23 | 2 | 2 ||||||
| 25 | 1 ||| 1 ||||
| 26 | 2 | 1 | 1 ||| 1 ||
|すべて| 136 | 43 | 44 | 33 | 16 | 34 | 49 |

表の規格違反設計は、フェーズ3-1（22）と3-4（12）のものである。テストに加えて、全ランナーへ3つのメタデータフィールド（`:defines:`、`:incdirs:`、`:top_module:`）、`tools/lint_baseline.txt`・`tools/new_test.py`・`tools/results_ratchet.py`を備える`tools/lint_metadata.py`、およびnightlyのkirimasimジョブのラチェット処理を追加しました。

<a id="where-the-work-followed-the-existing-conventions"></a>

### この作業で既存の慣習に従った箇所

ファイルの上部の表に加えて:

- 3フェーズは1つのコミットではなく，それぞれの部分に対して1つずつの5コミットとなった。
- フェーズ3-3は約40本ではなく、7系列それぞれ7種類の幅に対して、49ファイルを持ちます。
- フェーズ3-5では、21.6のテストで確認済みの内容は繰り返さなかった。対象は、`$value$plusargs`の各形式、最初の一致、不一致、および`$test$plusargs`の接頭辞一致である。ファイルをまたぐ`$unit`は、ファイルをコンパイル単位へまとめる方法が処理系依存（3.12.1）であり、スイートもそれに依存しないため対象外としました。
- `tools/lint_baseline.txt` にリストされていない問題に対してのみリントが失敗するので，ルールを破った既存のテストは変更されずに報告される。

<a id="where-icarus-verilog-130-and-verilator-5052-disagreed"></a>

### Icarus Verilog 13.0とVerilator 5.052が不一致となった箇所

両リリースで出力または判定まで実行できたテストのうち、結果が異なったもの。条文に従って判断し、docs/simulator-differences.mdに各箇所を列挙している。

|テスト| Icarus Verilog 13.0 | Verilator 5.052 |条項|
| --- | --- | --- | --- |
| `ch4/test_sched_strobe_after_zero_delays_and_nba` |標準に従って|`$strobe`はノンブロッキング更新前の値を表示する。| 21.2.2, 4.4.2.9 |
| `ch4/test_sched_monitor_once_per_time_step` |標準に従って|`$monitor` は `#0` の後に書き込まれる前の値を表示します。| 21.2.3, 4.4.2.9 |
| `ch4/test_sched_fork_join_none_in_function` |生成プロセスの遅延を拒否します|標準に従って| 13.4.4 |
| `ch4/test_sched_disable_fork_in_called_task` |タスク内のdisable forkは、呼出し元の子プロセスを終了させない|標準に従って| 9.6.3 |
| `ch8/test_type_this` |type(this)に未対応|静的メソッドで type(this) を拒否| 6.23, 8.11 |
| `gen/ch7/test_gen_wide_select_*_2state` |packed 配列の変数インデックスを通しての書き込みを拒否し、内部アサーションで停止します。|標準に従って| 7.4.5, 11.5.1 |
|`ch13/test_illegal_function_fork_join_any`、`ch12/test_illegal_break_in_fork_to_outer_loop`、その他次のリスト|そこでの記載どおりに受理または拒否する|||

さらに2件の不一致は、当初の記述のままではテストとして採用しなかった。`ch4/test_sched_deferred_action_arguments`では、最初の期待値が誤っていた。16.4によると、遅延アサーションのアクションブロックの値渡し引数は、アサーション式とともに評価される。テストを、その動作とconst ref引数を示すように書き直した。Verilatorはアクションブロックを直ちに実行し、Icarus Verilogは遅延アサーションに未対応である。ツールのオプションで定義されたマクロをソース内で再定義するテストは除外した。Icarus Verilog はソースの定義を保持し、Verilator（および kirimasim）はオプションの定義を保持する。規格はオプションをツールに委ねている。

<a id="illegal-designs-that-a-release-accepts"></a>

### リリース版が受理する規格違反の設計

- Icarus Verilog 13.0：`ch13/test_illegal_function_fork_join_any`と`ch12/test_illegal_break_in_fork_to_outer_loop`。`ch6/test_illegal_dynamic_array_element_continuous` に対する内部アサーションで停止します
- Verilator 5.052：`ch7/test_illegal_packed_array_of_real`、`ch9/test_illegal_always_comb_delay`、`ch9/test_illegal_always_comb_event_control`、`ch9/test_illegal_always_comb_fork_join`、`ch9/test_illegal_always_latch_delay`、`ch13/test_illegal_ref_in_static_function`、`ch8/test_illegal_global_constant_assigned_in_constructor`、`ch8/test_illegal_static_instance_constant`、`ch6/test_illegal_enum_sized_literal_width`、`ch12/test_illegal_break_in_fork_to_outer_loop`、`ch26/test_illegal_local_declaration_after_import`、`ch8/test_illegal_final_pure_virtual`。

Icarus Verilog 13.0の十二件の拒否は、未対応の構文に起因し、テストが指定する行で発生します（`:final`、`:initial`、`:extends`、`type(this)`、`static const`、ref引数、`` `ifdef ``式、制約、キューの`sum`、`super.new`内の`default`）。各テストのコメントにその点を記載しており、Checkワークフローでは現在、NOW MATCHES、38行として表示します。

<a id="existing-tests-that-the-lint-flags"></a>

### リントがフラグ付けする既存のテスト

`tools/lint_baseline.txt`は 378 の問題をリストしていますが、それらは変更されていません。

- 行幅：コメント行が80桁、またはコード行が100桁を超えるテスト368件。Contributingにその規則を定める前に作成したもの。
- fourstate：`ch5/test_operator_token_lengths`、`ch19/test_cg_wildcard_bins`、`ch20/test_pla_async_array_plane`、`ch37/test_vpi_case_loop_force_stmts`は、`:fourstate: no`と、x、z、`?`のいずれかのリテラルを持つ。
- 章：`ch35/test_dpi_context_scope`、`ch35/test_dpi_logic_values`、`ch35/test_dpi_packed_canonical`は最初に附属書Hの節を引用し、`ch36/test_vpi_systf_argument_on_demand`は第37章の節を引用する。
- timescale：`ch21/test_display_format_edge_cases`は時刻0の`%t`を出力し、`ch37/test_vpi_active_time_format`は`` `timescale ``なしで`$timeformat`を呼び出す。チェックはヒューリスティックで どちらの出力も時間単位に依存しないようです

<a id="tests-whose-expected-output-follows-the-standard-only-1"></a>

### 期待出力の根拠が規格のみのテスト

既存のものは上記の章別に列挙した。この作業では16を追加する。対象は`ch4/test_sched_deferred_action_arguments`、`ch4/test_sched_nonblocking_event_trigger`、`ch7/test_array_method_index_argument`、`ch7/test_illegal_iterator_argument_without_with`、`ch8/test_illegal_final_pure_virtual`、`ch8/test_illegal_static_instance_constant`、`ch8/test_illegal_super_new_default_without_default`、`ch8/test_super_new_default`、`ch8/test_type_this`、`ch11/test_inside_tolerance_ranges`、`ch12/test_illegal_break_in_fork_to_outer_loop`、`ch13/test_illegal_ref_in_static_function`、`ch18/test_dist_default_weight`、`ch18/test_illegal_dist_two_defaults`、`ch18/test_rand_real_constraint`、`gen/ch13/test_gen_wide_subroutine_w65_4state`。

<a id="kirimasim-on-the-new-tests"></a>

### 新しいテストのkirimasim

kirimasimのローカルビルド（コミット8b23f517c274）は、136のうち125件で一致する。8は未対応機能を使用し、3は結果が相違します。

- `ch13/test_illegal_function_fork_join_any`：kirimasimは、テストが指定する`fork`（22行）ではなく、`join_any`（25行）でエラーを報告します。テストをkirimasimの挙動に合わせる変更はしていません。エラー箇所は文を開始するforkであり、その後`ch13/test_illegal_function_fork_join`も、そのforkだけを指すように修正されました。kirimasimは、それについても`join`の位置で報告するため、もはや期待値と一致しない。kirimasim issue [#34](https://github.com/kurochan001/kirimasim/issues/34) はフォークで両方のエラーを要求します。
- `ch26/test_illegal_local_declaration_after_import`：kirimasimは、`limit`をimportする参照（行25）を報告する。26.3により、後のローカル宣言（行26）の方が不正となる。
- `ch21/test_plusargs_key_from_variable`：kirimasimは、21.6で許される、整数型変数によるplusarg文字列の指定を受け付けない。

<a id="versions-of-the-local-simulators"></a>

### ローカルシミュレータのバージョン

`PATH`上の`iverilog`は14.0（開発版）です。すべてのオラクル実行は、`--iverilog-bin`を通じてIcarus Verilog 13.0（安定版）（v13_0）を使用した。Verilatorは5.052 2026-09-05です。

<a id="tests-added-after-this-report"></a>

## この報告後に追加されたテスト

2026-10-22 に，上記の報告に続き，以下の試験を追加した。この報告の作業後にテスト数が最も少なかった章は、3、14、17、24、26、29、32、33、36、39、40である。その後の2つのコミットで、これらに19件のテストを追加した。`b43cfa4`（12件）と`3c2472f`（7件）である。その時点で、スイートには3699件のテストがあった。

|章|テスト|どちら|
| ---: | ---: | --- |
| 3 | 2 |`timeprecision`と`timeunit`の順序と `$unit`を通して共有される状態|
| 14 | 2 |既定のクロッキングスキューと、`iff`でゲートしたクロッキングイベント|
| 17 | 3 |`always_latch` とチェッカーの生成ループ、 関数のチェッカーの不正なインスタンス|
| 24 | 3 |タスク内の`$exit`、programインスタンスの状態とパラメータ、およびprogramのfinal手続き|
| 26 | 2 |`export *::*` とインタフェースヘッダのインポート|
| 29 | 1 |逐次UDPインスタンスの立上り遅延と立下り遅延|
| 32 | 2 |SDFファイルの`TIMESCALE`、および未知の`COND`条件|
| 33 | 1 |セルルールを上書きするインスタンスルール|
| 36 | 1 |program内およびfinal手続き内のユーザー定義システムタスク|
| 39 | 1 |cover propertyの`cbAssertionSuccess`コールバック|
| 40 | 1 |カバレッジ呼出しの対象スコープとしてのinterfaceインスタンス|

`:oracle:`時点で、Icarus Verilog 13.0がそのうち7件、Verilator 5.052（シード1と7）が7件を記録し、5件は規格のみを根拠としている。1件は規格違反の設計、2件はVPIのCコードを持ち、2件はxまたはzの値に依存する。

テストにより、リリース版が規格と異なる箇所が4つ見つかった。すべて[simulator-differences.md](simulator-differences.ja.md)に記載している。

- Verilator 5.052：タスク内で`$exit`を呼ぶと、プログラムのinitial手続きを終了せず、タスクから戻ります（24.7）。
- Verilator 5.052：遅延を2つ指定した逐次UDPインスタンスが、どちらの遅延も使わず、クロックエッジと同時に出力を変更します（29.8）。
- Icarus Verilog 13.0：SDFファイルの`TIMESCALE`を無視し、遅延値を設計側の時間単位で読み込みます（32.3）。
- Icarus Verilog 13.0: SDF `COND` エントリの未知の条件を false として扱います。30.4.4.1 32.4.1 のような条件は真である。

<a id="six-more-tests"></a>

### もう6つのテスト

3番目のコミット`b0994fd`で、テストの最も少ない章にさらに6件を追加した。その時点でスイートには3705件のテストがあった。Verilatorでは未初期化変数にランダムな初期値が与えられ、シード7で結果が変わったため、`0641d74`で`test_program_clocking_output`の出力ポートを初期化した。

|章|テスト|どちら|
| ---: | ---: | --- |
| 3 | 2 |コンパイル単位スコープでのimport、およびpackage内のクラスの時間単位|
| 24 | 1 |program内のクロッキングブロックとその出力スキュー|
| 36 | 1 |ユーザ定義のシステムタスクを always プロセスから呼び出す|
| 39 | 1 |cover propertyの各評価試行の`cbAssertionStart`コールバック|
| 40 | 1 |カバレッジ呼出しの対象スコープとしてのprogramインスタンス|

3章の2本のテストは、Icarus Verilog 13.0とVerilator 5.052の両方を列挙しています。第36章のテストはIcarus Verilog 13.0を、第24章のテストはVerilator 5.052を記録し、第39章と第40章のテストは規格のみを根拠としている。新たなシミュレータ間差異は見つかりませんでした。

<a id="five-more-tests"></a>

### もう5つのテスト

4番目のコミット`fea36a2`で、さらに5件のテストを追加した。その時点でスイートには3710件のテストがあった。

|章|テスト|どちら|
| ---: | ---: | --- |
| 3 | 1 |インターフェースのタスクの時間単位は|
| 24 | 1 |program内のクロッキングブロックの入力スキュー|
| 36 | 1 |クラスメソッドから呼び出されたユーザ定義システムタスク|
| 39 | 1 |VPIを通じて 即時アサーションの無効化|
| 40 | 1 |カバレッジ呼出しの対象スコープとしてのpackage|

3章のテストは、Icarus Verilog 13.0とVerilator 5.052の両方を列挙しています。第36章のテストはIcarus Verilog 13.0を、第24章のテストはVerilator 5.052を記録し、第39章と第40章のテストは規格のみを根拠としている。新たなシミュレータ間差異は見つかりませんでした。

<a id="three-more-tests"></a>

### もう3つのテスト

第5のコミット`4ff57d6`で、さらに3本のテストを追加しました。その時点でスイートには3713件のテストがあった。

|章|テスト|どちら|
| ---: | ---: | --- |
| 32 | 1 |SDFファイルの、別々の`SETUP`エントリと`HOLD`エントリ|
| 33 | 1 |パラメータの上書きを伴ってインスタンスを束縛するセルルール|
| 39 | 1 |即時assert、assume、cover文のVPIハンドル|

3件のいずれもIcarus Verilog 13.0またはVerilator 5.052では生成されないため、すべて規格のみを根拠としている。新たなシミュレータ間差異は見つかりませんでした。

<a id="three-further-tests"></a>

### さらに3つの試験

第6のコミット`c7d3edb`で、さらに3本のテストを追加しました。その時点でスイートには3716件のテストがあった。

|章|テスト|どちら|
| ---: | ---: | --- |
| 3 | 1 |プログラムの時間単位は|
| 39 | 1 |適合しないカバーに対する 失敗コールバックの欠如|
| 40 | 1 |停止後のカバレッジ保存|

Verilator 5.052は、第3章のテストを生成する。第39章と第40章のテストは、規格のみを根拠としている。新たなシミュレータ間差異は見つかりませんでした。

<a id="three-tests-of-sdf-vpi-and-coverage"></a>

### SDF、VPI、およびカバレッジの3つのテスト

7番目のコミット`f6b1fab`で、さらに3件のテストを追加した。その時点でスイートには3719件のテストがあった。

|章|テスト|どちら|
| ---: | ---: | --- |
| 32 | 1 |SDFファイルの`RECREM`エントリ|
| 36 | 1 |generateブロックから呼び出すユーザー定義システムタスク|
| 40 | 1 |`NOCOV` は インスタンスがないモジュールの定義に対する答えです|

Icarus Verilog 13.0は、第36章のテストを生成する。第32章と第40章のテストは、規格のみを根拠としている。新たなシミュレータ間差異は見つかりませんでした。

<a id="61-more-tests"></a>

### 61 もっとテスト

最後の61本を追加し、追加総数は100本（39 + 61）になりました。これらはテストが最も少ない章に追加した。

|章|テスト|どちら|
| ---: | ---: | --- |
| 3 | 7 |時間の単位と精度を 違法な粗い精度を含めて|
| 14 | 14 |クロッキングブロックの入力・出力・既定・エッジクロックの各スキュー|
| 17 | 6 |checkerのポート、always手続き、generateでのインスタンス、およびcontext|
| 24 | 6 |programのポート、initial／final手続き、クロッキング、および`$exit`|
| 26 | 6 |明示的なインポートとワイルドカードインポート、エクスポートとヘッダインポート|
| 29 | 12 |UDP 遅延、エッジ記号、初期値、テーブルマッチング|
| 36 | 5 |task、fork、startup、compiletfから呼び出すシステムタスク|
| 39 | 3 |アサーションのシステム制御、手続き的コールバック、およびインスタンスごとの制御|
| 40 | 2 |カバレッジのリセット／マージ、および定義またはインスタンスを指定した制御|

`:oracle:`時点で、Icarus Verilog 13.0がそのうち33件、Verilator 5.052が21件を記録し、7件は規格のみを根拠としている。2件は規格違反の設計である。テストにより、リリース版が異なる箇所がさらに3つ見つかった。すべて[simulator-differences.md](simulator-differences.ja.md)に記載している。Verilatorの明示importの優先順位（26.3）とprogramのforkからの`$exit`（24.7）、およびIcarus Verilogの名前付きワイルドカードexport（26.5）である。

<a id="12-second-tests-for-the-priority-queue"></a>

### 12 優先キューの第二テスト

深さレポートでは、テストが1件で期待値の根拠が規格のみの節を68件検出した。最初の追加分では、そのうち12件に2本目のテストを追加する。

|条項|新しいテスト|オラクル|
| ---: | --- | --- |
| 4.9.2 | `ch4/test_sched_procedural_assign_part_select` |どちらも|
| 7.8.7 | `ch7/test_assoc_allocate_on_write_types` | Verilator |
| 7.10.2.1 | `ch7/test_queue_size_method` |どちらも|
| 7.10.2.2 | `ch7/test_queue_insert_positions` |どちらも|
| 7.10.2.4 | `ch7/test_queue_pop_front_order` |どちらも|
| 7.10.2.5 | `ch7/test_queue_pop_back_order` |どちらも|
| 10.10.2 | `ch10/test_unpacked_concat_vector_string` |どちらも|
| 14.7 | `ch14/test_clocking_scope_names` | Verilator |
| 14.9 | `ch14/test_clocking_interface_plain_port` | Verilator |
| 14.15 | `ch14/test_clocking_event_controls` | Verilator |
| 21.4.3 | `ch21/test_readmemh_address_range` |どちらも|
| 33.7 | `ch33/test_config_binding_nested` | Verilator |

優先対象の条項数は68から55へ、テストが1本だけの条項数は191から177へ、規格のみを根拠とするテストしかない条項数は265から252へ減りました。両方のリリースをオラクルに持つテストは、164件から171件へ増加した。次のスライスは残りの 55 で続けるべきです

`%L` を必要とします。`ch33/test_config_binding_upper`で追加し、Verilatorで記録したため、その時点のスイートは3793件のテストとなった。

<a id="clause-text-corrections"></a>

### 条文の記述に基づく修正

IEEE 1800-2023 PDF の条項テキストを読み込んだところ、メタデータに3つの修正が見つかった。

- `3.11`は「階層の概観」であり，トップレベルモジュールの挙動ではない。`test_top_level_instances`を`ch23`へ移し、`23.3.1`を引用するようにした。また、`3.11`には再び`none`タグを付けた。これが、一試験計数が 178 ではなく 177 である理由の一つである。
- `37.69`は「繰り返し制御」である。それを引用するテストは正しく、現在は条項一覧にも含まれている。
- `21.7.1.1`～`21.7.1.4`と`21.7.1.6`は、`$dumpfile`、`$dumpvars`、`$dumpoff`／`$dumpon`、`$dumpall`、`$dumpflush`の制御を指し、VCDファイルの内容を指すものではない。これらは再び対象範囲に含まれる。`21.7.1.5`（`$dumplimit`）と、どのテストも読み取らないVCDの内容に関する節だけに、`dump`タグを残す。
- `21.7.2.1`～`21.7.2.3`と`21.7.5`は、`test_vcd_dump_readback`で実際に読み戻すVCDの内容に関する節なので、それらの`dump`タグも削除する。READMEでは、この4項目を対象範囲としている。
- `8.30.1`は概要だが、`weak_reference`の型パラメータがクラス型でなければならないとも定めており、これは動作上の要求である。その`none`タグを削除する。`25.3.3`は例とされているが、非ANSIポートリスト内の汎用interface参照が不正であることも定めている。その`none`タグも削除する。
- `25.7.2`と`25.7.3`はmodportsのタスクの例であり，動作ではなくタスクのエクスポートの例である。これらを引用した2つのテストは、代わりに25.5を引用している。
- `25.3.1`はinterfaceを含まない例であり、`34.5.x.1`は除外対象の節34の構文に関する下位節である。現在は両方とも条項一覧にあり、`none`と`excluded`のタグが付いている。

<a id="vpi-object-model-and-binding-properties"></a>

### VPI オブジェクトモデルとバインド属性

VPI文の11条項（37.55、37.62、37.66、37.67、37.70、37.71、37.73、37.74、37.77、37.78、37.83）と、33.7プロパティの`vpiLibrary`、`vpiCell`、`vpiConfig`を実行できるリリースはありません。これらは、根拠が規格のみの3件のテストで確認する。1件は文の型を列挙し、1件は属性オブジェクトを読み取り、1件はモジュールの3つのプロパティを読み取る。`tools/clauses.txt`に、その11条項を再掲しています。そのため、深さレポートでは、テストが1件で根拠が規格のみの節が新たに11件計上される。これらに2本目のテストを追加するには、VPI対応のシミュレータが必要である。

<a id="review-fixes-of-2026-10-22"></a>

### 2026-10-22のレビュー修正

[test-content-review-20261022.md](test-content-review-20261022.md)の内容レビューで、24本のテストから12件の問題が見つかりました。これらは修正済みである。

- F01：部分選択への手続き的assignは、現在`ch10/test_sched_procedural_assign_part_select`の規格違反設計としている。条項一覧とシミュレータ差異資料には、Icarus Verilog 13.0とVerilator 5.052がこれを受理すると記載されている。
- F02: 2つのパッケージエクスポートテストは、再エクスポートした名前を明示的にインポートします。両方のリリースで再現し、26.6を引用している。
- F03：プログラムおよびチェッカテストの出力駆動変数は，もはや宣言初期化子を持たない。
- F04：プログラムのテストでは、モジュール側の観測が終わるまで別のinitial手続きを動作させ、24.3の暗黙の終了で観測が打ち切られないようにしています。
- F05：カバレッジ保存テストで、予約語`before`を`value_before`へ改名する。
- F06：VPI文のテスト内のexpect文に、`@(posedge en)`クロックを明示しました。
- F07：contextテストの高速checkerは、42のエッジを過ぎるまで`fast_ok`を低値に保つ。
- F08：9本のVPIのCファイルは、38.11に従い、次の呼出し前に各`vpi_get_str()`の結果をコピーします。
- F09：再入可能なDPIテストのエクスポートした待機タスクは、automaticである。
- F10：setup違反は、データの変化7ではなく、基準エッジ10で報告される。
- F11：recremチェックは`(d, posedge clk, ...)`を使用し、RECREMエントリは別の`$removal`チェックにもアノテーションを適用する。期待するnotifierが更新される。
- F12：カバレッジ定義テストは、すべての制御と問合せから返る`SV_COV_ERROR`を拒否する。`SV_COV_NOCOV`と `SV_COV_PARTIAL`は許可されます。すべてERRORとする実装は、もはや合格できない。

[test-content-review-followup-20261022.md](test-content-review-followup-20261022.md)での追跡レビューでは、残る3点が見つかり、すべて修正した。

- R01：programのクロッキングを確認する2本のテストで、programのoutput仮引数に既定の初期値を与え、6でq = 0、8でq = 1を再び観測できるようにしました。
- R02：カバレッジ定義テストは、STARTからのNOCOV／PARTIALを受理し、ERRORの場合だけ失敗する。
- R03：比較の前に、両方のクエリ値がERRORでないことを検査します。定義全体の始点と終点もチェックされます

<a id="matching-rounds-of-2026-10-25-and-2026-10-26"></a>

### 2026-10-25と2026-10-26の対応付けラウンド

保留中の13バッチ（p01、p05、p07、p12、p09、p10、p13、p15、および附属書のa01-a05、g05、g08、g09、h01、h02）を独立に検証して取り込みました。1388件の提案のうち、1365件を受理し、23件を却下した。620 新しいテストを追加した。原記録では、マージ前に不具合のあるテスト18件を修正したとされています。列挙された内訳は17件です（`input var`ポート8件、診断位置4件、コメント幅1件、`:oracle:`エントリ3件、条項引用1件）。差分の理由は元の記録に記載されていません。意味上の不備が残る4件のテストは、取り込まなかった。ch22のincludeフィクスチャの復元で、既存の対応付け10件のincludeディレクトリのダイジェストが変わった。再ハッシュされ 再実行され 基準値の更新記録が なぜなのかを記録しています

追加の作成ラウンドで、ヘッダと分布のテストを追加した。K.2（31件受理）、I.3（55件）、N.2（7件）で、テストは18件となった。配列パターンの期待値が逆になっていたI.3のテスト1件は除外した。

また，作成ラウンドでは，アセシオン制御（受理20.11 , 42），カバー率制御とVPIコア（40.3.2.1/40.5.2 , 20），チェッカ宣言（17.2/17.3/17.7.2 , 29）と1364互換性（36.12.1 , 8），30テストを追加した。プログラムの暗黙終了に依存するチェッカテストを除外した。

最終ラウンドは，Annex A文法を4つのパーティションに分けて，517の提案から369のリンクを適用し，独立したレビュー後に93のテストを保持した。期待値の誤りや規格違反の構文がある15本のテストは、取り込み対象から外しました。修正された5つのテストが最初に再検証されましたこれにより、台帳は目標75%を超え、12319行中9244行（75.04%）となった。

その後の実行監査でスイート全体を実行し、出力または診断が既にIcarus Verilog 13.0と一致する、規格のみを根拠としたテストを277件検出した。これらは現在 iverilog@ 13.0 をリストし、その要求を実行されたと計算します。Verilator はスペックのみのテストに一致しませんでした。

候補テストがある4区間（33.4.1-37.10、37.12-37.32、37.33-38.31、38.32-40.4.5）の追加照合で、60件の対応付けを採用し、275件の観測を保留しました。

p01-p04（3.4-6.11.1、6.12-7.7、7.8-9.2.2.2、9.2.2.2.1-11.5.1）の追加レビューで、99件の対応付けを採用し、334件の観測を保留しました。

p05-p08（11.5.2-14.16、14.16.1-16.13.5、16.13.6-18.5.6、18.5.7.1-19.7）のレビューで、89件の対応付けを採用し、388件の観測を保留しました。

p09-p12（19.7.1-21.7.1.1、21.7.1.2-23.3.2、23.3.3-26.5、27.3-33.3.1）のレビューで、93件の対応付けを採用し、395件の観測を保留しました。

90%ラウンドは、g区分とh区分に対するp17-p18の対応付けおよび新規テストから開始した。320件の対応付けを採用し、137本のテストを追加しました。

第2ラウンドでは16、19、21章を対象とし、レビュー後に対応98件を受理し、テスト57件を採用した。

第3波で18、23、37章のテスト草案を完成させ、181件の対応付けを採用して、65本のテストを残しました。

第4ラウンドでは38、6/7/8、11/9/4、20/31/32/33/35/40章を対象とし、対応157件を受理、観測51件を保留、テスト93件を採用した。

第5ラウンドでは、残る37、38/17、16/18、A／H、および6/7/8/9の要求を扱い、144件の対応を受理し、97件のテストを採用した。

第6ラウンドでは、残る37、38/17、16/12、A／H、21/19、6/35/23の要求を対象とし、対応91件を受理し、テスト51件を採用した。

第7波では、6/8/11/13、19/21/40、37/17、38/16の各群の部分的な草案をレビューし、40件の対応付けを採用して、35本のテストを残しました。

第8波では、既存テストが条件の一部しか観測していない要求に補完テストを作成し、29件の対応付けを採用して、18本のテストを残しました。

フォーマル検証のラウンドで:type: formal、run_sby.pyランナー、およびFの要求へ対応付けた40件の既存SymbiYosysケースを追加した。フォーマル検証の第2ラウンドで、21件のF.3.4.3ケースを追加した。18 新しいリンクが受け入れられた。

形式検証の第3波で、F.3.4.2とF.5.2に対する20ケースを追加しました。19 新しいリンクが受け入れられた。

形式検証の第4波で、F.5.3.1に対する17ケースを追加しました。16 新しいリンクが受け入れられた。

フォーマル検証の第5ラウンドでは、nonvacuityの関係と9 F.5.3.3のケースを追加した。9 新しいリンクが受け入れられた。

形式検証の第6波では、F.3、F.5.1、F.5.4–F.5.6、F.6、F.7に対して93ケースを追加しました。91 新しいリンクが受け入れられた。

形式検証の第7波では、F.4.1/F.4.2の平坦化規則とF.4/F.4.3の宣言・代入の書き換えに対して40ケースを追加し、F.4を完了しました。40 新しいリンクが受け入れられた。

形式検証の第8波で附属書Fを完了しました。F.2モデル、F.3.2/F.3.3表記、F.5の語演算、残りの代入・宣言規則、accept_on、およびF.3.4.6のfree-checker書き換えに対する19ケースです。Fの要求253件は、現在すべて対応付け済みである。

質の監査は，13214のリンク全てを欠落テスト，過時の証拠，クロスチャプターオーバーリンクのためにチェックし，付属書，VPI，ch16のリンクをサンプルとし，すべての正式なケースをレビューした。現在、すべてのフォーマルケースに到達可能なcoverの証跡が付いている。フォーマル検証カタログは、518 PASSと、期待どおりの5件の変異モデルの失敗を報告する。2件のVPIヘッダテストを拡張し、規定のヘッダを両方含めた。第9ラウンドでは、既存のフォーマルケース31件を再利用し、新たに8件を追加して、第16章に残る69件の要求のうち37件を完了した。分母のレビューにより、まだ分母を承認できないことが判明した。解釈保留の行が21件、出典範囲のない行が92件、未監査の節が20件残っている。ランナーは現在、シミュレータ専用の期待出力に対応しており、固定したリリースIcarus 13.0とVerilator 5.052で実行証跡を更新した。台帳では12319行中10793行を対応付け済み（87.61%）で、そのうち6117行に実行確認があります（49.66%）。

<a id="state-after-these-commits-historical"></a>

### これらのコミット後の状態（履歴）

これらのコミット後、テスト総数は37章にわたり6799本で、うち1308本が生成テストです。`:oracle:`時点で、4092件がIcarus Verilog 13.0を、1339件がVerilator 5.052を記録し、1368件は規格のみを根拠としている。855本はxまたはzの値に依存し、512本はCコードを含み（97 DPI、415 VPI）、1695本は規格違反の設計で、33本には期待する終了コードの指定があります。これらの数は，この段階でのスイートを記述する。その後の追加と承認済みの分母は、[生成された動作集計](behavior-coverage-summary.md)と[更新されたハンドオフ](handover-20261028.md)に記録している。

<a id="tests-added-in-this-work"></a>

### ここで追加したテスト

|章|テスト|
| ---: | ---: |
| 3 | 13 |
| 14 | 16 |
| 17 | 9 |
| 24 | 11 |
| 26 | 8 |
| 29 | 13 |
| 32 | 4 |
| 33 | 2 |
| 36 | 9 |
| 39 | 8 |
| 40 | 7 |
|すべて| **100** |

条項別テスト数の追加対応による2本目のテスト12本、`%L`のテスト、規格違反のクロッキングテスト5本、規格だけを根拠とするVPIのテスト3本を合わせ、この作業の追加総数は121本です。

<a id="147-illegal-placements"></a>

### 14.7の不正な配置

条文は、クロッキングブロックを宣言できる場所も定めている。5つの不正な設計により、不足していた不正ケースを追加します。関数内、タスク内、パッケージ内、別のクロッキングブロック内への入れ子、およびコンパイル単位スコープです。Verilator 5.052 は名前付けられた行でそれぞれを拒否します。Icarus Verilog 13.0も拒否するが、その理由はクロッキングブロックに未対応であることによる。
