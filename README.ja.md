# kirimasim-tests の夜間実行結果

[English](README.md) / [日本語](README.ja.md)

[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) の[夜間ワークフロー](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)がこのブランチを更新します。毎晩、main ブランチの全テストを各シミュレータで実行し、結果を `history.json` に追加して、以下の図を生成します。ローカル実行の結果も取り込むことができ、`local` と表示します。出力と指定された検査が期待結果に一致する場合、または不正な設計が必要な診断付きで拒否される場合に、テストを「一致」と数えます。各ステータスの意味はスイートの README を参照してください。

最新の実行: 2026-11-02 15:52 UTC、スイートのコミット [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93)、テスト10289件、[ワークフロー実行](https://github.com/kurochan001/kirimasim-tests/actions/runs/41454861438)。

## シミュレータごとの最新結果

各行と章別表の各列には、そのシミュレータの最新の実行記録を使います。実行日時、スイートのコミット、テスト数は異なる場合があります。古い結果の日時はそのまま保持し、最新の実行に含まれる結果としては扱いません。

| シミュレータ | バージョン | 実行 (UTC) | スイート | 取り込み元 | 一致 (pass) | 不一致 (fail) | 既知の差異 (known) | 未対応 (unsupported) |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-802-g61dbc3c2) | 2026-11-02 15:52 | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | nightly | 6205 (61.9%) | 16 | 3800 | 0 |
| Verilator | Verilator 5.055 devel rev v5.054-30-g4298d7b7 | 2026-11-02 15:52 | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | nightly | 5567 (55.6%) | 10 | 4444 | 0 |
| kirimasim | kirimasim 0.0.0 (commit 2edfebbc6270), built with GNU 13.3.0 | 2026-11-02 15:52 | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | nightly | 7675 (76.6%) | 135 | 0 | 2211 |
| Lyra | Lyra (commit 099acd527059) | 2026-11-02 15:52 | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | nightly | 7779 (77.6%) | 553 | 0 | 1689 |
| Ghost | private build 4d414f2efa2c | 2026-11-02 15:52 | [`0afc896`](https://github.com/kurochan001/kirimasim-tests/commit/0afc89659c16a22f88c82816358e305de3f34d93) | nightly | 9187 (91.7%) | 834 | 0 | 0 |

Ghost は正式公開前に参加している匿名のシミュレータです。現在公開しているのはテスト結果のみです。名称、ソースコード、ビルドログは非公開で、ビルドIDには実行ファイルのハッシュを使用します。

![期待結果に一致するテスト数](charts/overview.ja.svg?v=20261102T155230)

![一致したテストの割合](charts/rate.ja.svg?v=20261102T155230)

## 最新の実行での変化

同じシミュレータの前回実行では一致せず今回は一致したテストと、前回は一致したものの今回は一致しなくなったテストです。スイートに追加されたテストの件数は上の表に示します。

### Icarus Verilog

新たに一致（13件）: `ch6/test_comb_string_compare`, `ch6/test_edge_case_strings`, `ch6/test_expr_string`, `ch6/test_string_compare_2`, `ch6/test_string_edge_cases_2`, `ch6/test_string_getc`, `ch6/test_string_getc_2`, `ch6/test_string_getc_is_byte`, `ch6/test_string_icompare`, `ch6/test_string_index_read_bounds`, `ch6/test_string_manipulation`, `ch6/test_sv_string`, `ch6/test_value_string`

### Verilator

新たに一致（2件）: `ch9/test_illegal_always_ff_no_event_control`, `ch9/test_illegal_always_latch_other_writer`

一致しなくなったテスト（1件）:

- `ch9/test_always_latch_comb_in_interface`: 不一致 (fail) — build failed: %Error-COMBDLY: /home/runner/work/kirimasim-tests/kirimasim-tests/tests/ch9/test_always_latch_comb_in_interface.sv:24:15: Non-blocking assignment '<=' in combinational logic

### kirimasim

新たに一致（215件）: `ch10/test_lvalue_scopes_selects_and_concatenation_forms`, `ch10/test_syntax_continuous_assign_forms`, `ch21/test_display_strength_format`, `ch21/test_format_upper_lower_name_strength_time`, `ch21/test_pattern_format_enum_value`, `ch21/test_pattern_print_array_and_packed_struct`, `ch21/test_sformat_only_second_argument_is_format`, `ch28/test_ambiguous_strength_ranges_and_levels`, `ch28/test_ambiguous_strengths`, `ch28/test_bufif_gate_truth_table_all_inputs`, `ch28/test_cmos_switch_nmos_pmos_equivalence`, `ch28/test_drive_strength_components_on_gates_and_assigns`, `ch28/test_drive_strength_forms`, `ch28/test_gate_delay_independent_of_input_strength`, `ch28/test_gate_instance_array`, `ch28/test_gate_strength_keywords_and_highz`, `ch28/test_mos_cmos_switch_delay_forms`, `ch28/test_mos_switch_kinds_unidirectional`, `ch28/test_mos_switch_truth_tables`, `ch28/test_net_types_pull_and_supply_strength_levels`, `ch28/test_nonresistive_pass_preserves_pull_strength`, `ch28/test_nonresistive_switch_strength`, `ch28/test_nonresistive_switch_strength_each_level`, `ch28/test_not_and_three_state_gate_drive_strength`, `ch28/test_notif_gate_truth_table_all_inputs`, `ch28/test_pass_switch_direction_and_control_kinds`, `ch28/test_pull_supply_net_strength`, `ch28/test_rcmos_reduction`, `ch28/test_rcmos_switch_rnmos_rpmos_equivalence`, `ch28/test_resistive_pass_switch_reduction_each_level`, `ch28/test_rtran_reduction_table`, `ch28/test_rtranif_control_and_reduction`, `ch28/test_syntax_enable_gates`, `ch28/test_syntax_mos_cmos_switches`, `ch28/test_syntax_n_input_n_output_gates`, `ch28/test_syntax_pass_switches`, `ch28/test_syntax_pullup_pulldown_strengths`, `ch28/test_syntax_resistive_mos_switches`, `ch28/test_three_state_gate_unknown_output_delay`, `ch28/test_wired_logic_ambiguous_strength_combinations`, `ch28/test_wired_logic_strength`, `ch29/test_syntax_udp_instantiation`, `ch29/test_udp_instance_strength_and_array_range`, `ch3/test_module_contains_classes_subroutines_processes`, `ch3/test_module_contains_specify_block`, `ch3/test_same_class_name_in_two_scopes`, `ch30/test_global_pulse_defaults`, `ch30/test_path_polarity_no_effect`, `ch30/test_specify_delay_selection`, `ch30/test_specify_edge_paths_by_edge`, `ch30/test_specify_edge_sensitive_path`, `ch30/test_specify_mixed_delay_per_transition`, `ch30/test_specify_multiple_paths_x_delays`, `ch30/test_specify_negative_path_delay`, `ch30/test_specify_path_rise_fall`, `ch30/test_specify_path_vs_distributed_delay`, `ch30/test_specify_unknown_polarity_xor`, `ch4/test_bidirectional_switch_kinds_and_network`, `ch4/test_inout_port_keeps_strength`, `ch4/test_primitive_terminal_direct_connections`, `ch5/test_attribute_prefix_positions`, `ch6/test_builtin_net_undriven_values`, `ch6/test_continuous_assign_to_variable_converts_and_drops_strength`, `ch6/test_gate_drive_strength_beside_net_value`, `ch6/test_net_declaration_drive_strength`, `ch6/test_net_declaration_drive_strength_pairs`, `ch6/test_net_declaration_legal_strength_pairs`, `ch6/test_parameter_port_list_without_defaults`, `ch6/test_port_variable_net_implied_continuous`, `ch6/test_specify_specparam_delays`, `ch6/test_specparam_declaration_forms`, `ch6/test_specparam_from_parameters_and_specparams`, `ch6/test_tri0_tri1_resolution_tables`, `ch6/test_variable_declaration_forms_and_modifiers`, `ch6/test_variable_default_values_nonintegral`, `ch6/test_wire_tri_resolution_table`, `ch7/test_edge_dynamic_array_resize`, `ch7/test_queue_edge_cases_3`, `ch8/test_class_scope_nested_class_and_static_access`, `gen/ch28/test_gen_strength_bufif0_01`, `gen/ch28/test_gen_strength_bufif0_02`, `gen/ch28/test_gen_strength_bufif0_03`, `gen/ch28/test_gen_strength_bufif0_04`, `gen/ch28/test_gen_strength_bufif0_05`, `gen/ch28/test_gen_strength_bufif0_06`, `gen/ch28/test_gen_strength_bufif0_07`, `gen/ch28/test_gen_strength_bufif0_08`, `gen/ch28/test_gen_strength_bufif1_01`, `gen/ch28/test_gen_strength_bufif1_02`, `gen/ch28/test_gen_strength_bufif1_03`, `gen/ch28/test_gen_strength_bufif1_04`, `gen/ch28/test_gen_strength_bufif1_05`, `gen/ch28/test_gen_strength_bufif1_06`, `gen/ch28/test_gen_strength_bufif1_07`, `gen/ch28/test_gen_strength_bufif1_08`, `gen/ch28/test_gen_strength_tri0_01`, `gen/ch28/test_gen_strength_tri0_02`, `gen/ch28/test_gen_strength_tri0_03`, `gen/ch28/test_gen_strength_tri0_04`, `gen/ch28/test_gen_strength_tri0_05`、ほか115件

一致しなくなったテスト（1件）:

- `ch6/test_specparam_declaration_with_pulse_control`: 未対応 (unsupported) — specify pulse control or timing check (not implemented yet)

### Lyra

新たに一致（6件）: `ch11/test_conditional_class_branches_result_type`, `ch11/test_streaming_nested_concat`, `ch21/test_fseek_append_and_gap`, `ch25/test_interface_abstract_methods_and_broadcast`, `ch25/test_interface_extern_and_generate_items`, `ch25/test_interface_task_export`

一致しなくなったテスト（1件）:

- `ch25/test_virtual_interface_type_forms`: 不一致 (fail) — error: internal error: UnitSignatures::PublishValues: one lowering publishes its values once

### Ghost

新たに一致（88件）: `ch16/test_property_expression_operands_bind_first`, `ch16/test_sampled_automatic_and_const_current`, `ch16/test_sampled_automatic_const_current`, `ch16/test_sampled_defaults_and_methods`, `ch16/test_sampled_function_arguments`, `ch16/test_sampled_function_clock_inference`, `ch16/test_sampled_value_time_zero_defaults`, `ch28/test_gate_delay_forms`, `ch3/test_timeunit_repeated_as_later_item`, `ch3/test_timeunits_repeated_as_later_items`, `ch31/test_timing_check_flags_threshold_and_limits`, `ch31/test_timing_fullskew_event_based`, `ch31/test_timing_skew_checks`, `ch31/test_timing_skew_dormant_and_restart`, `ch31/test_timing_skew_simultaneous_and_expiry`, `ch32/test_sdf_cond_iopath`, `ch32/test_sdf_interconnect_pair_warning`, `ch36/test_vpi_compiletf_sizetf`, `ch36/test_vpi_user_h_routine_declarations`, `ch37/test_vpi_case_loop_force_stmts`, `ch37/test_vpi_concurrent_assertion_actions`, `ch37/test_vpi_loop_branch_children`, `ch37/test_vpi_loop_var_scopes`, `ch37/test_vpi_packed_array_levels`, `ch37/test_vpi_packed_array_var_kinds`, `ch37/test_vpi_process_statements`, `ch37/test_vpi_tf_call_kinds_relations`, `ch37/test_vpi_value_parameter_props`, `ch38/test_vpi_array_get_errors`, `ch38/test_vpi_value_change_strength_time_objtype`, `ch6/test_param_declaration_forms_aggregates_selects`, `ch6/test_string_putc_index_rules`, `ch7/test_array_invalid_index_read_handles_real_string`, `ch7/test_assoc_allocate_on_write_types`, `ch7/test_queue_method_prototypes_and_invalid_indices`, `gen/ch11/test_gen_cross_index_w129_z_a_b_u_z_known`, `gen/ch11/test_gen_cross_index_w1_n_a_b_u_x_x`, `gen/ch11/test_gen_cross_index_w1_z_d_b_s_z_known`, `gen/ch11/test_gen_cross_index_w32_n_a_b_s_z_known`, `gen/ch11/test_gen_cross_index_w32_o_d_l_s_before_known`, `gen/ch11/test_gen_cross_index_w33_n_a_b_s_x_known`, `gen/ch11/test_gen_cross_index_w64_o_a_b_s_z_known`, `gen/ch11/test_gen_cross_index_w65_o_d_b_u_x_known`, `gen/ch11/test_gen_cross_inside_w129_w_ss_l_dynamic_n3_both_unknown`, `gen/ch11/test_gen_cross_range_w1_w_ss_l_low_open_lhs_x_s`, `gen/ch11/test_gen_cross_range_w65_n_ss_l_rel_tol_known_s`, `gen/ch11/test_gen_cross_range_w65_s_su_b_rel_tol_known_m`, `gen/ch11/test_gen_cross_range_w65_s_us_b_low_open_bound_z_s`, `gen/ch11/test_gen_cross_range_w65_w_uu_b_low_open_bound_x_m`, `gen/ch11/test_gen_cross_sc_w129_n_lb_mixed_zero_b`, `gen/ch11/test_gen_cross_sc_w129_n_ll_mixed_zero_b`, `gen/ch11/test_gen_cross_sc_w32_s_lb_mixed_mixed_l`, `gen/ch11/test_gen_cross_sc_w32_w_ll_mixed_one_b`, `gen/ch11/test_gen_cross_sc_w33_n_ll_mixed_unknown_b`, `gen/ch11/test_gen_cross_sc_w33_s_lb_mixed_unknown_l`, `gen/ch11/test_gen_cross_sc_w64_n_lb_mixed_zero_b`, `gen/ch11/test_gen_cross_sc_w64_n_ll_mixed_mixed_b`, `gen/ch11/test_gen_cross_sc_w65_n_lb_mixed_one_b`, `gen/ch11/test_gen_cross_sc_w65_n_ll_mixed_zero_l`, `gen/ch13/test_gen_cross_return_1_bit_x_while_none_local`, `gen/ch13/test_gen_cross_return_33_bit_z_for_none_local`, `gen/ch13/test_gen_cross_return_65_bit_x_for_none_package`, `gen/ch16/test_gen_cross_assert_129_logic_z_equal_negedge_nba_edge_interface`, `gen/ch16/test_gen_cross_assert_1_bit_known_reduce_or_posedge_nba_edge_module`, `gen/ch16/test_gen_cross_assert_1_logic_x_equal_negedge_nba_before_module`, `gen/ch16/test_gen_cross_assert_32_logic_known_equal_posedge_blocking_edge_module`, `gen/ch16/test_gen_cross_assert_33_bit_z_case_equal_posedge_blocking_edge_module`, `gen/ch16/test_gen_cross_assert_64_bit_x_case_equal_posedge_blocking_edge_interface`, `gen/ch16/test_gen_cross_assert_65_bit_known_equal_posedge_blocking_before_module`, `gen/ch16/test_gen_cross_assert_65_bit_z_reduce_or_negedge_blocking_edge_interface`, `gen/ch21/test_gen_comb_file_monitor_dynamic_fd_always`, `gen/ch21/test_gen_comb_file_monitor_dynamic_mcd_package`, `gen/ch21/test_gen_comb_file_monitor_dynamic_mcd_program`, `gen/ch21/test_gen_comb_file_monitor_queue_fd_package`, `gen/ch21/test_gen_comb_file_monitor_queue_fd_program`, `gen/ch21/test_gen_comb_file_monitor_queue_mcd_always`, `gen/ch21/test_gen_comb_fread_struct_array_member`, `gen/ch21/test_gen_comb_fread_struct_multidimensional`, `gen/ch21/test_gen_cross_memfile_33_bit_enum_x_hex_single_up_logic_forward`, `gen/ch21/test_gen_cross_memfile_33_bit_enum_z_bin_all_up_bit_reverse`, `gen/ch21/test_gen_cross_memfile_64_bit_enum_x_bin_single_up_bit_forward`, `gen/ch7/test_gen_cross_queue_w129_l_s_c2_n0_insert_known`, `gen/ch7/test_gen_cross_queue_w1_b_s_cu_n0_insert_x`, `gen/ch7/test_gen_cross_queue_w32_l_u_cu_n2_insert_z`, `gen/ch7/test_gen_cross_queue_w33_b_s_cu_n3_insert_z`, `gen/ch7/test_gen_cross_queue_w64_l_u_c3_n0_insert_known`, `gen/ch7/test_gen_cross_queue_w65_b_u_c2_n2_insert_x`, `imported/ch21/test_file_output_initial`

一致しなくなったテスト（2件）:

- `ch17/test_checker_assume_stability`: 不一致 (fail) — output differs
- `ch18/test_constraint_block_all_forms`: 不一致 (fail) — output differs (exit 2)

## 章別の結果

![章別の一致テスト数](charts/chapters.ja.svg?v=20261102T155230)

## シミュレータごとの推移

![Icarus Verilog：ステータス別の結果](charts/status-icarus.ja.svg?v=20261102T155230)

![Verilator：ステータス別の結果](charts/status-verilator.ja.svg?v=20261102T155230)

![kirimasim：ステータス別の結果](charts/status-kirimasim.ja.svg?v=20261102T155230)

![Lyra：ステータス別の結果](charts/status-lyra.ja.svg?v=20261102T155230)

![Ghost：ステータス別の結果](charts/status-ghost.ja.svg?v=20261102T155230)

## 最近の実行

各シミュレータの一致したテスト数と、その前回実行からの増減です。バージョンは変更されたときに表示します。

| 実行 (UTC) | スイート | テスト数 | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
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
