# kirimasim-tests の夜間実行結果

[English](README.md) / [日本語](README.ja.md)

[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) の[夜間ワークフロー](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)がこのブランチを更新します。毎晩、main ブランチの全テストを各シミュレータで実行し、結果を `history.json` に追加して、以下の図を生成します。ローカル実行の結果も取り込むことができ、`local` と表示します。出力と指定された検査が期待結果に一致する場合、または不正な設計が必要な診断付きで拒否される場合に、テストを「一致」と数えます。各ステータスの意味はスイートの README を参照してください。

最新の実行: 2026-11-03 16:13 UTC、スイートのコミット [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292)、テスト10672件、[ワークフロー実行](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801)。

## シミュレータごとの最新結果

各行と章別表の各列には、そのシミュレータの最新の実行記録を使います。実行日時、スイートのコミット、テスト数は異なる場合があります。古い結果の日時はそのまま保持し、最新の実行に含まれる結果としては扱いません。

| シミュレータ | バージョン | 実行 (UTC) | スイート | 取り込み元 | 一致 (pass) | 不一致 (fail) | 既知の差異 (known) | 未対応 (unsupported) |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-802-g61dbc3c2) | 2026-11-03 16:13 | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | nightly | 6244 (60.0%) | 16 | 4144 | 0 |
| Verilator | Verilator 5.055 devel rev v5.054-46-ga9e5a51f | 2026-11-03 16:13 | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | nightly | 5768 (55.4%) | 15 | 4621 | 0 |
| kirimasim | kirimasim 0.0.0 (commit d73d8922dfa2), built with GNU 13.3.0 | 2026-11-03 16:13 | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | nightly | 7863 (75.6%) | 133 | 0 | 2408 |
| Lyra | Lyra (commit fff84e924071) | 2026-11-03 16:13 | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | nightly | 8110 (78.0%) | 565 | 0 | 1729 |
| Ghost | private build e629cbd964b4 | 2026-11-03 16:13 | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | nightly | 9702 (93.3%) | 702 | 0 | 0 |

Ghost は正式公開前に参加している匿名のシミュレータです。現在公開しているのはテスト結果のみです。名称、ソースコード、ビルドログは非公開で、ビルドIDには実行ファイルのハッシュを使用します。

![期待結果に一致するテスト数](charts/overview.ja.svg?v=20261103T161332)

![一致したテストの割合](charts/rate.ja.svg?v=20261103T161332)

## 最新の実行での変化

同じシミュレータの前回実行では一致せず今回は一致したテストと、前回は一致したものの今回は一致しなくなったテストです。スイートに追加されたテストの件数は上の表に示します。

### kirimasim

新たに一致（11件）: `ch11/test_inside_array_set_mixed_sign_width`, `ch20/test_illegal_random_seed_real`, `ch8/test_illegal_constraint_mode_via_interface_handle`, `ch8/test_illegal_rand_mode_via_interface_handle`, `gen/ch11/test_gen_cross_inside_w33_w_us_l_fixed_n3_rhs_x`, `gen/ch12/test_gen_cross_caseinside_w33_w_us_l_array_known_pv`, `gen/ch16/test_gen_cross_deferdis_assertion_assert_odd_inverse_before_function_change`, `gen/ch16/test_gen_cross_deferdis_assertion_assert_odd_positive_after_variable_stable`, `gen/ch16/test_gen_cross_deferdis_assertion_assume_even_positive_before_function_stable`, `gen/ch16/test_gen_cross_deferdis_assertion_assume_odd_alternating_after_variable_change`, `gen/ch16/test_gen_cross_deferdis_assertion_cover_even_inverse_after_variable_stable`

### Lyra

新たに一致（27件）: `ch16/test_concurrent_assert_actions`, `ch16/test_immediate_assertion_default_error`, `ch16/test_immediate_assertion_statement_places`, `ch16/test_nonvacuous_if_nonoverlap_instance_disable`, `ch16/test_nonvacuous_property_case`, `ch16/test_nonvacuous_sequence_strong_weak`, `ch16/test_sva_satisfaction_fail_strong`, `ch19/test_cg_sample_time_evaluation`, `ch20/test_assert_action_control_tasks`, `ch20/test_assertcontrol`, `ch20/test_assertcontrol_action_controls_ongoing`, `ch20/test_assertcontrol_assertion_type_bits_fail_off`, `ch20/test_assertcontrol_directive_type_ignored_for_expect_and_violations`, `ch20/test_assertcontrol_directive_type_mask`, `ch20/test_assertcontrol_lock_expect_and_violation_reports`, `ch20/test_assertcontrol_lock_until_unlock`, `ch20/test_assertcontrol_off_kill_on_pending`, `ch20/test_assertcontrol_violation_and_expect_types`, `ch20/test_assertion_default_error_failoff_failon`, `ch3/test_timeunit_package_class`, `ch35/test_dpi_import_result_logic_shortreal_void`, `ch35/test_dpi_import_result_types_all_small`, `ch35/test_dpi_packed_struct_union_formals`, `ch35/test_dpi_packed_tagged_union_tag_bits`, `ch35/test_dpi_shortreal`, `ch35/test_dpi_unsigned_types`, `ch6/test_class_cast_compatibility_dynamic`

一致しなくなったテスト（2件）:

- `ch19/test_cg_option_group_defaults`: 不一致 (fail) — error: internal error: mir verify: body 7 of a scope of unit 'test_cg_option_group_defaults', as it leaves its rewrites reaches a read (expression 34 of its block) at 5 places, and one run evaluates it at two of them: under a call of the library entry 'object_of' and under a call of the library entry 'object_of' (in unit 'test_cg_option_group_defaults')
- `ch19/test_covergroup_declaration_and_option_forms`: 不一致 (fail) — error: internal error: mir verify: body 12 of a scope of unit 'test_covergroup_declaration_and_option_forms', as it leaves its rewrites reaches a read (expression 47 of its block) at 2 places, and one run evaluates it at two of them: under a call of the library entry 'object_of' and under a call of the library entry 'object_of' (in unit 'test_covergroup_declaration_and_option_forms')

### Ghost

新たに一致（148件）: `ch16/test_clocking_block_other_clock_assertion`, `ch16/test_default_disable_iff_scopes`, `ch16/test_deferred_assertion_action_arguments`, `ch16/test_deferred_assertion_forked_processes`, `ch16/test_deferred_immediate_syntax_placement`, `ch16/test_expect_vacuous_and_nonblocking`, `ch16/test_implicit_always_attempts`, `ch16/test_multiclock_clock_flow_operands`, `ch16/test_multiclock_implication_if_sync`, `ch16/test_nonoverlapped_implication_expansion`, `ch16/test_procedural_assertion_clock_inference`, `ch16/test_procedural_assertion_disable_label`, `ch16/test_procedural_assertion_flush_points`, `ch16/test_procedural_assertion_no_glitch`, `ch16/test_procedural_assertion_queue_rules`, `ch16/test_sequence_first_match`, `ch16/test_sequence_intersect_within_precedence`, `ch16/test_sequence_triggered`, `ch16/test_triggered_matched_multiclock`, `ch17/test_checker_context_inference`, `ch17/test_checker_covergroup_sample`, `ch17/test_checker_package_context`, `ch17/test_checker_static_scope`, `ch18/test_constraint_block_all_forms`, `ch21/test_swrite_radix_forms_and_targets`, `ch28/test_ambiguous_strength_ranges_and_levels`, `ch28/test_cmos_switch_nmos_pmos_equivalence`, `ch28/test_gate_instance_array`, `ch28/test_mos_cmos_switch_delay_forms`, `ch28/test_rcmos_reduction`, `ch28/test_rcmos_switch_rnmos_rpmos_equivalence`, `ch30/test_module_path_delay_input_inout_ports`, `ch30/test_specify_inout_paths`, `ch30/test_specify_path_vs_distributed_delay`, `ch30/test_specify_simple_path_declarations_and_terminals`, `ch6/test_net_declaration_drive_strength_pairs`, `ch9/test_edge_event_vector_lsb_only`, `ch9/test_edge_table_all_scalar_transitions`, `gen/ch10/test_gen_comb_heap_sensitivity_queue_continuous`, `gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending`, `gen/ch10/test_gen_ref_static_array_event_nba_w65_descending`, `gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending`, `gen/ch10/test_gen_ref_static_array_event_nba_w8_descending`, `gen/ch13/test_gen_cross_return_129_bit_x_for_middle_package`, `gen/ch13/test_gen_cross_return_129_bit_z_repeat_tail_local`, `gen/ch13/test_gen_cross_return_1_bit_z_repeat_middle_package`, `gen/ch13/test_gen_cross_return_32_bit_x_repeat_head_package`, `gen/ch13/test_gen_cross_return_32_bit_z_for_tail_local`, `gen/ch13/test_gen_cross_return_33_bit_x_repeat_tail_package`, `gen/ch13/test_gen_cross_return_64_bit_x_repeat_middle_local`, `gen/ch13/test_gen_cross_return_64_bit_z_while_head_package`, `gen/ch13/test_gen_cross_return_65_bit_z_repeat_head_local`, `gen/ch15/test_gen_combo_event_conditional_initializer`, `gen/ch15/test_gen_combo_event_return_initializer`, `gen/ch15/test_gen_cross_eventlife_nested_copy_1_before_arm_blocking_forward_1`, `gen/ch15/test_gen_cross_eventlife_nested_copy_2_before_arm_nba_reverse_1`, `gen/ch15/test_gen_cross_eventlife_nested_copy_3_before_arm_blocking_reverse_2`, `gen/ch15/test_gen_cross_eventlife_nested_direct_1_after_arm_blocking_reverse_1`, `gen/ch15/test_gen_cross_eventlife_nested_direct_2_after_wake_blocking_forward_2`, `gen/ch15/test_gen_cross_eventlife_nested_direct_3_after_wake_blocking_forward_1`, `gen/ch15/test_gen_cross_eventlife_scalar_copy_1_after_wake_nba_reverse_2`, `gen/ch15/test_gen_cross_eventlife_scalar_copy_2_after_arm_nba_forward_1`, `gen/ch15/test_gen_cross_eventlife_scalar_copy_3_after_arm_nba_reverse_1`, `gen/ch15/test_gen_cross_eventlife_scalar_direct_1_before_arm_blocking_forward_1`, `gen/ch15/test_gen_cross_eventlife_scalar_direct_2_after_arm_blocking_reverse_2`, `gen/ch15/test_gen_cross_eventlife_scalar_direct_3_before_arm_nba_forward_2`, `gen/ch15/test_gen_cross_eventlife_struct_copy_1_after_arm_blocking_forward_2`, `gen/ch15/test_gen_cross_eventlife_struct_copy_2_after_wake_nba_forward_1`, `gen/ch15/test_gen_cross_eventlife_struct_copy_3_before_arm_blocking_forward_1`, `gen/ch15/test_gen_cross_eventlife_struct_direct_1_before_arm_blocking_forward_1`, `gen/ch15/test_gen_cross_eventlife_struct_direct_2_after_wake_blocking_reverse_1`, `gen/ch15/test_gen_cross_eventlife_struct_direct_3_after_arm_nba_reverse_2`, `gen/ch16/test_gen_cross_gendisable_case_override_present_default_at_end_before`, `gen/ch16/test_gen_cross_gendisable_loop_override_absent_default_between_before`, `gen/ch16/test_gen_cross_gendisable_loop_override_present_default_at_start_before`, `gen/ch21/test_gen_comb_vcd_program_interface_all_model`, `gen/ch21/test_gen_comb_vcd_program_interface_explicit`, `gen/ch27/test_gen_cross_ifgenerate_129_1_if_a_whole_bit_known`, `gen/ch27/test_gen_cross_ifgenerate_129_1_if_a_whole_bit_z`, `gen/ch27/test_gen_cross_ifgenerate_129_1_if_a_whole_logic_known`, `gen/ch27/test_gen_cross_ifgenerate_129_1_if_a_whole_logic_x`, `gen/ch27/test_gen_cross_ifgenerate_129_2_if_a_whole_bit_x`, `gen/ch27/test_gen_cross_ifgenerate_129_3_case_b_modport_logic_z`, `gen/ch27/test_gen_cross_ifgenerate_1_1_if_a_whole_bit_known`, `gen/ch27/test_gen_cross_ifgenerate_1_1_if_a_whole_bit_z`, `gen/ch27/test_gen_cross_ifgenerate_1_1_if_a_whole_logic_x`, `gen/ch27/test_gen_cross_ifgenerate_1_1_if_b_modport_logic_z`, `gen/ch27/test_gen_cross_ifgenerate_1_2_if_a_whole_bit_x`, `gen/ch27/test_gen_cross_ifgenerate_1_3_case_a_whole_logic_known`, `gen/ch27/test_gen_cross_ifgenerate_32_1_case_b_whole_logic_x`, `gen/ch27/test_gen_cross_ifgenerate_32_1_if_a_whole_bit_x`, `gen/ch27/test_gen_cross_ifgenerate_32_1_if_a_whole_bit_z`, `gen/ch27/test_gen_cross_ifgenerate_32_1_if_a_whole_logic_known`, `gen/ch27/test_gen_cross_ifgenerate_32_2_case_b_modport_bit_known`, `gen/ch27/test_gen_cross_ifgenerate_32_3_if_a_whole_logic_z`, `gen/ch27/test_gen_cross_ifgenerate_33_1_if_a_whole_bit_known`, `gen/ch27/test_gen_cross_ifgenerate_33_1_if_a_whole_bit_x`, `gen/ch27/test_gen_cross_ifgenerate_33_2_case_a_whole_logic_known`, `gen/ch27/test_gen_cross_ifgenerate_33_2_if_a_whole_logic_z`, `gen/ch27/test_gen_cross_ifgenerate_33_3_case_b_modport_bit_z`、ほか48件

一致しなくなったテスト（2件）:

- `ch13/test_ref_and_inout_object_handle_replacement`: 不一致 (fail) — output differs
- `ch6/test_vector_net_scalared`: 不一致 (fail) — output differs

## 章別の結果

![章別の一致テスト数](charts/chapters.ja.svg?v=20261103T161332)

## シミュレータごとの推移

![Icarus Verilog：ステータス別の結果](charts/status-icarus.ja.svg?v=20261103T161332)

![Verilator：ステータス別の結果](charts/status-verilator.ja.svg?v=20261103T161332)

![kirimasim：ステータス別の結果](charts/status-kirimasim.ja.svg?v=20261103T161332)

![Lyra：ステータス別の結果](charts/status-lyra.ja.svg?v=20261103T161332)

![Ghost：ステータス別の結果](charts/status-ghost.ja.svg?v=20261103T161332)

## 最近の実行

各シミュレータの一致したテスト数と、その前回実行からの増減です。バージョンは変更されたときに表示します。

| 実行 (UTC) | スイート | テスト数 | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [2026-11-03 16:13](https://github.com/kurochan001/kirimasim-tests/actions/runs/41650010801) | [`e8d991a`](https://github.com/kurochan001/kirimasim-tests/commit/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292) | 10672 | 6244 (+36 −0) | 5768 (+66 −0) `5.055 devel a9e5a51` | 7863 (+160 −0) `d73d8922d` | 8110 (+164 −2) `fff84e924` | 9702 (+248 −2) `private build e629cbd964b4` |
| [2026-11-03 05:51](https://github.com/kurochan001/kirimasim-tests/actions/runs/41561194045) | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | 10511 | 6208 (+3 −0) | 5702 (+135 −0) `5.055 devel 094b04d` | 7703 (+28 −0) `f3ea0379a` | 7948 (+170 −1) `554db457a` | 9456 (+269 −0) `private build 3499c4a8842c` |
| [2026-11-02 15:52](https://github.com/kurochan001/kirimasim-tests/actions/runs/41454861438) | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | 10289 | 6205 (+44 −0) `14.0 devel 61dbc3c` | 5567 (+119 −1) `5.055 devel 4298d7b` | 7675 (+252 −1) `2edfebbc6` | 7779 (+137 −1) `099acd527` | 9187 (+281 −2) `private build 4d414f2efa2c` |
| [2026-11-01 02:35](https://github.com/kurochan001/kirimasim-tests/actions/runs/41248878297) | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | 10042 | 6161 (+461 −1) `14.0 devel d62a606` | 5449 (+184 −0) `5.053 devel dd8a7d5` | 7424 (+956 −0) `1feede1ac` | 7643 (+712 −2) `bfc12e95d` | 8908 (+873 −1) `private build ab7995cae1ca` |
| [2026-10-31 02:16](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886) | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | 9203 | 5701 (+199 −0) `14.0 devel 5d04888` | 5265 (+117 −3) `5.053 devel 92ac405` | 6468 (+360 −0) `17b7192b4` | 6933 (+397 −1) `e13a01796` | 8036 (+882 −5) `private build a20e2aaaee3a` |
| [2026-10-30 01:43](https://github.com/kurochan001/kirimasim-tests/actions/runs/40972765631) | [`360ef70`](https://github.com/kurochan001/kirimasim-tests/commit/360ef70c73218de1f44dd83c1cda24f60e242537) | 8779 | 5502 (+898 −3) `14.0 devel 6991445` | 5151 (+372 −0) `5.053 devel 453b02a` | 6108 (+1032 −0) `51cda3143` | 6537 (+1037 −1) `8eff7abdc` | 7159 (+1071 −7) `private build 2d76b598f1c1` |
| [2026-10-29 03:55](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805499579) | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | 7744 | 4607 | 4779 `5.053 devel ad83990` | 5076 (+6 −0) `938d60c83` | 5501 (+9 −6) `ed9515d8e` | 6095 (+12 −0) `private build 5c1261cba4df` |
| [2026-10-29 00:48](https://github.com/kurochan001/kirimasim-tests/actions/runs/40786512421) | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | 7744 | 4607 (+5 −1) `14.0 devel fd8759f` | 4779 (+3 −1) `5.053 devel 375685d` | 5070 (+17 −0) `df25891fa` | 5498 (+19 −0) | 6083 (+143 −3) `private build af267bf4f8b1` |
| [2026-10-28 09:54](https://github.com/kurochan001/kirimasim-tests/actions/runs/40657143465) | [`b83d0ff`](https://github.com/kurochan001/kirimasim-tests/commit/b83d0ffd666f533b0ce1c77f6cb5377fbbe0b511) | 7740 | 4603 (+4 −0) | 4777 (+14 −0) `5.053 devel 9440ae8` | 5053 (+8 −0) `a24202947` | 5479 (+5 −0) | 5943 (+9 −1) `private build 07c6cb0ee0df` |
| [2026-10-28 00:30](https://github.com/kurochan001/kirimasim-tests/actions/runs/40599008464) | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | 7732 | 4599 (+64 −0) `14.0 devel d95f240` | 4763 (+120 −3) `5.053 devel c0b2894` | 5045 (+79 −3) `cfb76b386` | 5474 (+76 −0) | 5935 (+128 −16) `private build bdc4d9a56351` |
| [2026-10-27 16:21](https://github.com/kurochan001/kirimasim-tests/blob/3fe8d730711e1b773d39656dc13732ac644abae9/coverage/results/ghost-local-20261028.json) (local) | [`23b4c54`](https://github.com/kurochan001/kirimasim-tests/commit/23b4c54256d44cdaeabccde13b2a806fecee1927) | 7629 | — | — | — | — | 5823 `private build d59b7c7f8feb` |
| [2026-10-27 00:11](https://github.com/kurochan001/kirimasim-tests/actions/runs/40417919375) | [`1ff9998`](https://github.com/kurochan001/kirimasim-tests/commit/1ff999828c59ca24649bf722f6bfc46b70724520) | 7327 | 4535 (+39 −12) `14.0 devel 0accff4` | 4646 (+96 −4) `5.053 devel be33a0f` | 4969 (+103 −0) `1650064d2` | 5398 (+118 −0) | — |
| [2026-10-26 14:44](https://github.com/kurochan001/kirimasim-tests/actions/runs/40333187203) | [`5fb3c45`](https://github.com/kurochan001/kirimasim-tests/commit/5fb3c45d73e4946d99690389752b82c86eecaa50) | 7144 | 4508 (+152 −0) `14.0 devel 1d601c9` | 4554 (+167 −0) `5.053 devel 5dcc718` | 4866 (+174 −0) `5563871fc` | 5280 (+674 −1) | — |
| [2026-10-25 22:50](https://github.com/kurochan001/kirimasim-tests/actions/runs/40237581816) | [`eadc98d`](https://github.com/kurochan001/kirimasim-tests/commit/eadc98d6c452244167e267a46866808291771198) | 6799 | 4356 (+338 −0) `14.0 devel 49bebc9` | 4387 (+363 −0) `5.053 devel 7fa05ab` | 4692 (+458 −1) `a4f653c1d` | — | — |
| [2026-10-24 22:48](https://github.com/kurochan001/kirimasim-tests/actions/runs/40135271002) | [`c87448b`](https://github.com/kurochan001/kirimasim-tests/commit/c87448ba87b6b6ca136bf526b1ee8710efcb05a3) | 6009 | 4018 | 4024 (+1 −0) `5.053 devel 441c0df` | 4235 `c507631d2` | 4607 | — |
| [2026-10-24 12:44](https://github.com/kurochan001/kirimasim-tests/actions/runs/40084390631) | [`0073c69`](https://github.com/kurochan001/kirimasim-tests/commit/0073c6947bc210d7b928d0d651ef34d5095b5999) | 6009 | 4018 (+1298 −0) `14.0 devel 9cfecc9` | 4023 (+1202 −0) | 4235 (+1449 −0) `c0388da8a` | 4607 `7e2c604b9` | — |
| [2026-10-23 23:03](https://github.com/kurochan001/kirimasim-tests/actions/runs/40033104165) | [`721db37`](https://github.com/kurochan001/kirimasim-tests/commit/721db3743b9db84ecb14fa86a8165dbcff8fdb0d) | 3986 | 2720 (+1 −0) `14.0 devel 1a663cb` | 2821 (+19 −0) `5.053 devel 0041d20` | 2786 (+126 −0) `0d27da4e7` | — | — |
| [2026-10-22 23:07](https://github.com/kurochan001/kirimasim-tests/actions/runs/39865168055) | [`bc1609d`](https://github.com/kurochan001/kirimasim-tests/commit/bc1609dc005548ac6dd7848355b705983d7aacd5) | 3938 | 2719 (+108 −0) `14.0 devel e072b33` | 2802 (+144 −0) `5.053 devel bb916d0` | 2660 (+108 −0) `499198369` | — | — |
| [2026-10-21 22:46](https://github.com/kurochan001/kirimasim-tests/actions/runs/39686633157) | [`4752cea`](https://github.com/kurochan001/kirimasim-tests/commit/4752cea52e9dc0d24ef58240eddee11ef055c673) | 3719 | 2611 (+140 −0) `14.0 devel ce98681` | 2659 (+149 −0) `5.053 devel 019f1ca` | 2552 (+147 −0) `b27968d1f` | — | — |
| [2026-10-21 01:31](https://github.com/kurochan001/kirimasim-tests/actions/runs/39523323680) | [`0cfd00b`](https://github.com/kurochan001/kirimasim-tests/commit/0cfd00b58140ba628bb18a68e439933a07312fa2) | 3403 | 2471 (+36 −0) | 2512 (+35 −0) `5.053 devel 4c98f02` | 2405 (+61 −0) `7b2b17aa1` | — | — |
| [2026-10-21 01:02](https://github.com/kurochan001/kirimasim-tests/actions/runs/39507186309) | [`824f574`](https://github.com/kurochan001/kirimasim-tests/commit/824f5748dd619afaf472f60fd0ce83d0a547d829) | 3332 | 2435 (+857 −0) | 2477 (+549 −0) `5.053 devel 3cc4981` | 2344 (+754 −0) `0680c67d5` | — | — |
| [2026-10-20 07:49](https://github.com/kurochan001/kirimasim-tests/actions/runs/39387575855) | [`6bffc4a`](https://github.com/kurochan001/kirimasim-tests/commit/6bffc4a184134250ca4b934ef2b40af9961bc4d5) | 2327 | 1578 `14.0 devel 7e3d0c6` | — | 1590 `b1be7015e` | — | — |
| [2026-10-20 05:01](https://github.com/kurochan001/kirimasim-tests/actions/runs/39363555028) | [`56508cd`](https://github.com/kurochan001/kirimasim-tests/commit/56508cdce0a414ca1623756c6856dd1f49819977) | 2327 | 1578 (+56 −0) | 1928 (+103 −0) `5.053 devel 0177067` | 1590 (+60 −0) `ff80adcf6` | — | — |
| [2026-10-19 22:42](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210) | [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f) | 2176 | 1522 `14.0 devel eed9291` | 1825 `5.053 devel 60f166e` | 1530 `8b598b574` | — | — |

## ファイル

- `history.json`: 実行ごとに1件の記録。各シミュレータのステータス別・章別の件数と、結果が変わったテストを保存します。
- `latest/<simulator>.json`: 各シミュレータの最新実行における全テストの結果。次回実行の比較元になります。
- `charts/*.svg`: 上記の図。日本語版は `.ja.svg`、英語版は `.svg` です。
