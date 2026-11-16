# レビュー候補

[English](review-candidates.md)

期待値の根拠が規格の読み方にしかないテストと条項を、各シミュレータの最新の結果から挙げます。候補は誤りの指摘ではなく、規格と照らした見直しで判断します。[見直しの記録の仕方](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/docs/review-candidates.md)。

## 読んだ結果

| シミュレータ | 版 | 時刻 | スイートのコミット |
| --- | --- | --- | --- |
| Icarus Verilog | `Icarus Verilog version 14.0 (devel) (s20260301-1091-g32d891a8)` | 2026-11-16T05:12:16Z | `9f9121f0` |
| Verilator | `Verilator 5.055 devel rev v5.054-288-g1e30e73a` | 2026-11-16T05:12:16Z | `9f9121f0` |
| kirimasim | `kirimasim 0.1.0 (commit c152d237ac8d), built with GNU 13.3.0` | 2026-11-16T05:12:16Z | `9f9121f0` |
| Lyra | `Lyra (commit 05225260af49)` | 2026-11-16T05:12:16Z | `9f9121f0` |
| Ghost | `private build c82f33747734` | 2026-11-16T05:12:16Z | `9f9121f0` |

## 件数

| 候補 | 件数 |
| --- | ---: |
| specのみで、Ghost・kirimasim・Lyraのすべてでfail | 19 |
| specのみで、kirimasimだけがpass | 7 |
| specのみで、どこでもpassしないその他のテスト | 60 |
| 固定版のoracleがあり、GhostとLyraの両方でfail | 14 |
| 引用するテストがすべてspecのみの条項 | 212 |

結果: I Icarus Verilog、V Verilator、K kirimasim、L Lyra、G Ghost。p pass、f fail、u unsupported、k known、- 未実行。

## specのみで、Ghost・kirimasim・Lyraのすべてでfail

| テスト | 結果 |
| --- | --- |
| [`ch10/test_illegal_force_mixed_driven_variable`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch10/test_illegal_force_mixed_driven_variable.sv) | `Ik Vk Kf Lf Gf` |
| [`ch13/test_illegal_constant_function_call_in_constant_context`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch13/test_illegal_constant_function_call_in_constant_context.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_illegal_isunbounded_variable`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch20/test_illegal_isunbounded_variable.sv) | `Ik Vk Kf Lf Gf` |
| [`ch22/test_illegal_begin_keywords_without_end`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch22/test_illegal_begin_keywords_without_end.sv) | `Ik Vk Kf Lf Gf` |
| [`ch22/test_illegal_line_directive_trailing_comment`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch22/test_illegal_line_directive_trailing_comment.sv) | `Ik Vk Kf Lf Gf` |
| [`ch25/test_illegal_modport_import_default_argument_without_prototype`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch25/test_illegal_modport_import_default_argument_without_prototype.sv) | `Ik Vk Kf Lf Gf` |
| [`ch25/test_illegal_modport_import_named_binding_without_prototype`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch25/test_illegal_modport_import_named_binding_without_prototype.sv) | `Ik Vk Kf Lf Gf` |
| [`ch25/test_illegal_modport_prototype_unnamed_named_binding`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch25/test_illegal_modport_prototype_unnamed_named_binding.sv) | `Ik Vk Kf Lf Gf` |
| [`ch5/test_illegal_method_implicit_variable_without_parentheses`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch5/test_illegal_method_implicit_variable_without_parentheses.sv) | `Ik Vk Kf Lf Gf` |
| [`ch5/test_illegal_string_octal_escape_z_digit`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch5/test_illegal_string_octal_escape_z_digit.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_illegal_chandle_event_control`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_illegal_chandle_event_control.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_illegal_initial_block_variable_initializer_no_keyword`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_illegal_initial_block_variable_initializer_no_keyword.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_illegal_static_task_variable_initializer_no_keyword`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_illegal_static_task_variable_initializer_no_keyword.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_illegal_type_parameter_scope_prefix_in_variable`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_illegal_type_parameter_scope_prefix_in_variable.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_interconnect_declaration_generic_forms`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_interconnect_declaration_generic_forms.sv) | `Ik Vk Kf Lf Gf` |
| [`ch7/test_illegal_union_holding_struct_member_default`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch7/test_illegal_union_holding_struct_member_default.sv) | `Ik Vk Kf Lf Gf` |
| [`ch8/test_illegal_interface_method_default_not_constant`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch8/test_illegal_interface_method_default_not_constant.sv) | `Ik Vk Kf Lf Gf` |
| [`ch8/test_illegal_interface_typedef_scope_prefix_in_variable_declaration`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch8/test_illegal_interface_typedef_scope_prefix_in_variable_declaration.sv) | `Ik Vk Kf Lf Gf` |
| [`ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration.sv) | `Ik Vk Kf Lf Gf` |

## specのみで、kirimasimだけがpass

| テスト | 結果 |
| --- | --- |
| [`ch16/test_illegal_final_deferred_postponed_call`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_illegal_final_deferred_postponed_call.sv) | `Ik Vk Kp Lf Gf` |
| [`ch20/test_illegal_bits_function_dynamic_return`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch20/test_illegal_bits_function_dynamic_return.sv) | `Ik Vk Kp Lf Gf` |
| [`ch20/test_illegal_timeformat_unit_above_range`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch20/test_illegal_timeformat_unit_above_range.sv) | `Ik Vk Kp Lf Gf` |
| [`ch20/test_illegal_timeformat_unit_below_range`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch20/test_illegal_timeformat_unit_below_range.sv) | `Ik Vk Kp Lf Gf` |
| [`ch20/test_illegal_timeformat_unit_out_of_range`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch20/test_illegal_timeformat_unit_out_of_range.sv) | `Ik Vk Kp Lf Gf` |
| [`ch4/test_illegal_final_deferred_action_schedules_event`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch4/test_illegal_final_deferred_action_schedules_event.sv) | `Ik Vk Kp Lf Gf` |
| [`ch4/test_illegal_final_deferred_action_writes_variable`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch4/test_illegal_final_deferred_action_writes_variable.sv) | `Ik Vk Kp Lf Gf` |

## specのみで、どこでもpassしないその他のテスト

| テスト | 結果 |
| --- | --- |
| [`ch10/test_illegal_user_nettype_assignment_two_delays`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch10/test_illegal_user_nettype_assignment_two_delays.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_illegal_assertion_clocking_input_not_1step`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_illegal_assertion_clocking_input_not_1step.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_illegal_assertion_function_keeps_state`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_illegal_assertion_function_keeps_state.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_illegal_assertion_function_side_effect`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_illegal_assertion_function_side_effect.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_illegal_local_variable_implicit_type`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_illegal_local_variable_implicit_type.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_illegal_triggered_ending_clock`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_illegal_triggered_ending_clock.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_sequence_method_inferred_clock_default`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch16/test_sequence_method_inferred_clock_default.sv) | `Ik Vk Ku Lu Gf` |
| [`ch17/test_checker_always_ff_assertions_sampled`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch17/test_checker_always_ff_assertions_sampled.sv) | `Ik Vk Ku Lu Gf` |
| [`ch17/test_checker_dollar_actual_unbounded_range`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch17/test_checker_dollar_actual_unbounded_range.sv) | `Ik Vk Ku Lu Gf` |
| [`ch17/test_illegal_checker_function_keeps_state`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch17/test_illegal_checker_function_keeps_state.sv) | `Ik Vk Ku Lf Gf` |
| [`ch17/test_illegal_checker_function_side_effect`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch17/test_illegal_checker_function_side_effect.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_constraint_function_priority_partition`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch18/test_constraint_function_priority_partition.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_discarded_soft_distribution`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch18/test_discarded_soft_distribution.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_illegal_constraint_function_mode`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch18/test_illegal_constraint_function_mode.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_illegal_constraint_function_state`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch18/test_illegal_constraint_function_state.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_illegal_randsequence_negative_weight`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch18/test_illegal_randsequence_negative_weight.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_solve_before_partial_latest_set`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch18/test_solve_before_partial_latest_set.sv) | `Ik Vk Ku Lf Gf` |
| [`ch19/test_cg_four_state_literal_wildcard_enum`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch19/test_cg_four_state_literal_wildcard_enum.sv) | `Ik Vk Ku Lf Gf` |
| [`ch21/test_illegal_value_plusargs_bad_format`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch21/test_illegal_value_plusargs_bad_format.sv) | `Ik Vk Ku Lf Gf` |
| [`ch25/test_illegal_virtual_interface_component_in_always_event_control`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch25/test_illegal_virtual_interface_component_in_always_event_control.sv) | `Ik Vk Ku Lf Gf` |
| [`ch25/test_illegal_virtual_interface_component_in_always_ff`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch25/test_illegal_virtual_interface_component_in_always_ff.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_edge_parallel_path_vector_destination`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_edge_parallel_path_vector_destination.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_pathpulse_error_below_reject`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_pathpulse_error_below_reject.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_pulsestyle_ondetect_after_path`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_pulsestyle_ondetect_after_path.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_pulsestyle_onevent_after_path`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_pulsestyle_onevent_after_path.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_showcancelled_after_path`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_showcancelled_after_path.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_specify_edge_path_part_and_bit_select`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_specify_edge_path_part_and_bit_select.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_illegal_specify_ifnone_with_unconditional_path`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_illegal_specify_ifnone_with_unconditional_path.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_specify_interface_signal_path_terminals`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_specify_interface_signal_path_terminals.sv) | `Ik Vk Ku Lf Gf` |
| [`ch30/test_specify_parallel_path_bit_to_bit`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_specify_parallel_path_bit_to_bit.sv) | `Ik Vk Ku Lu Gf` |
| [`ch30/test_specify_path_delay_mintypmax_vpi`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch30/test_specify_path_delay_mintypmax_vpi.sv) | `Ik Vk Ku Lu Gf` |
| [`ch31/test_illegal_hold_limit_negative`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch31/test_illegal_hold_limit_negative.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_illegal_recovery_limit_negative`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch31/test_illegal_recovery_limit_negative.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_illegal_removal_limit_negative`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch31/test_illegal_removal_limit_negative.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_illegal_setup_limit_negative`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch31/test_illegal_setup_limit_negative.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_illegal_setuphold_negative_sum`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch31/test_illegal_setuphold_negative_sum.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_illegal_timing_condition_two_signals`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch31/test_illegal_timing_condition_two_signals.sv) | `Ik Vk Ku Lf Gf` |
| [`ch32/test_sdf_backannotates_all_timing_values`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch32/test_sdf_backannotates_all_timing_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_label_recomputes_delay_expression`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch32/test_sdf_label_recomputes_delay_expression.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_label_specparam`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch32/test_sdf_label_specparam.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_attribute_ports_params`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch37/test_vpi_attribute_ports_params.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_program_interface_relations`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch37/test_vpi_program_interface_relations.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_struct_and_tagged_patterns`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch37/test_vpi_struct_and_tagged_patterns.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_get_delays_flag_layouts`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch38/test_vpi_get_delays_flag_layouts.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_size_change_callback_resizes`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch38/test_vpi_size_change_callback_resizes.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_cover_no_failure`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch39/test_vpi_assertion_cover_no_failure.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_system_task_control`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch39/test_vpi_assertion_system_task_control.sv) | `Ik Vk Ku Lu Gf` |
| [`ch6/test_parameter_and_specparam_override_mechanisms`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_parameter_and_specparam_override_mechanisms.sv) | `Ik Vk Ku Lu Gf` |
| [`ch7/test_illegal_string_in_untagged_union`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch7/test_illegal_string_in_untagged_union.sv) | `Ik Vk Ku Lf Gf` |
| [`ch7/test_illegal_unique_index_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch7/test_illegal_unique_index_without_with_struct_elements.sv) | `Ik Vk Ku Lf Gf` |
| [`ch7/test_illegal_unique_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch7/test_illegal_unique_without_with_struct_elements.sv) | `Ik Vk Ku Lf Gf` |
| [`gen/ch28/test_gen_prim_identity_switch_ascending`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_switch_ascending.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_switch_descending`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_switch_descending.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_switch_negative_down`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_switch_negative_down.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_switch_negative_up`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_switch_negative_up.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_switch_singleton`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_switch_singleton.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_udp_ascending`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_udp_ascending.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_udp_descending`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_udp_descending.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_udp_negative_down`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_udp_negative_down.sv) | `Ik Vk Ku Lu Gf` |
| [`gen/ch28/test_gen_prim_identity_udp_negative_up`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/gen/ch28/test_gen_prim_identity_udp_negative_up.sv) | `Ik Vk Ku Lu Gf` |

## 固定版のoracleがあり、GhostとLyraの両方でfail

| テスト | 結果 |
| --- | --- |
| [`ch11/test_illegal_unsized_constant_in_concatenation`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch11/test_illegal_unsized_constant_in_concatenation.sv) | `Ip Vk Kf Lf Gf` |
| [`ch17/test_illegal_checker_writes_input`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch17/test_illegal_checker_writes_input.sv) | `Ik Vp Ku Lf Gf` |
| [`ch19/test_illegal_cg_matches_negative`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch19/test_illegal_cg_matches_negative.sv) | `Ip Vp Ku Lf Gf` |
| [`ch19/test_illegal_cg_transition_length_zero`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch19/test_illegal_cg_transition_length_zero.sv) | `Ip Vf Ku Lf Gf` |
| [`ch22/test_illegal_directive_split_across_lines`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch22/test_illegal_directive_split_across_lines.sv) | `Ik Vp Kf Lf Gf` |
| [`ch22/test_illegal_include_line_trailing_code`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch22/test_illegal_include_line_trailing_code.sv) | `Ip Vk Kf Lf Gf` |
| [`ch23/test_illegal_scope_duplicate_in_unselected_generate`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch23/test_illegal_scope_duplicate_in_unselected_generate.sv) | `Ip Vp Kf Lf Gf` |
| [`ch26/test_illegal_package_imported_before_compiled`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch26/test_illegal_package_imported_before_compiled.sv) | `Ip Vk Kf Lf Gf` |
| [`ch3/test_illegal_package_import_precedes_package`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch3/test_illegal_package_import_precedes_package.sv) | `Ip Vk Kf Lf Gf` |
| [`ch3/test_illegal_package_scoped_name_precedes_package`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch3/test_illegal_package_scoped_name_precedes_package.sv) | `Ip Vk Kf Lf Gf` |
| [`ch6/test_ch6_extra_for_loop_automatic`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch6/test_ch6_extra_for_loop_automatic.sv) | `Ik Vp Kf Lf Gf` |
| [`ch7/test_illegal_dynamic_new_nonblocking_assignment`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch7/test_illegal_dynamic_new_nonblocking_assignment.sv) | `Ip Vp Kf Lf Gf` |
| [`ch8/test_illegal_instance_constant_assigned_twice`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch8/test_illegal_instance_constant_assigned_twice.sv) | `Ip Vk Kp Lf Gf` |
| [`ch9/test_illegal_automatic_variable_as_sequence_event_argument`](https://github.com/kurochan001/kirimasim-tests/blob/9f9121f0a5290dd2f2fdf1def77df5dded32ad9a/tests/ch9/test_illegal_automatic_variable_as_sequence_event_argument.sv) | `Ip Vp Ku Lf Gf` |

## 引用するテストがすべてspecのみの条項

| 条項 | 引用するテスト |
| --- | ---: |
| 9.4.4 | 2 |
| 12.4.2.2 | 2 |
| 12.5.3.2 | 2 |
| 16.4.5 | 2 |
| 16.12.20 | 2 |
| 16.14.6.3 | 2 |
| 17.4 | 2 |
| 19.6.1.1 | 2 |
| 21.7.3.2 | 2 |
| 21.7.3.3 | 2 |
| 21.7.3.5 | 2 |
| 21.7.3.7 | 2 |
| 21.7.4.2 | 2 |
| 21.7.4.3.2 | 2 |
| 25.3.2 | 2 |
| 28.16.2.2 | 2 |
| 31.8 | 2 |
| 32.2 | 2 |
| 33.3.1.1 | 2 |
| 33.5.4 | 2 |
| 35.2.2.1 | 2 |
| 35.5.1.5 | 2 |
| 36.10.3 | 2 |
| 37.3.5 | 2 |
| 37.7 | 2 |
| 37.56 | 2 |
| 37.69 | 2 |
| 37.79 | 2 |
| 39.4.2.1 | 2 |
| 39.5.3 | 2 |
| 40.2.1 | 2 |
| 4.9.2 | 3 |
| 6.6.4.1 | 3 |
| 6.6.4.2 | 3 |
| 8.29 | 3 |
| 8.30.1 | 3 |
| 8.30.2 | 3 |
| 8.30.4 | 3 |
| 16.13.7 | 3 |
| 16.14.6.2 | 3 |
| 16.14.6.4 | 3 |
| 19.6.3 | 3 |
| 21.7.3.4 | 3 |
| 23.3.3.7.2 | 3 |
| 30.7.4.2 | 3 |
| 36.10.1 | 3 |
| 37.3.2 | 3 |
| 37.8 | 3 |
| 37.38 | 3 |
| 37.55 | 3 |
| 37.62 | 3 |
| 37.65 | 3 |
| 37.70 | 3 |
| 37.73 | 3 |
| 37.76 | 3 |
| 37.77 | 3 |
| 37.78 | 3 |
| 37.82 | 3 |
| 37.84 | 3 |
| 38.7 | 3 |
| 38.36.1.3 | 3 |
| 40.5.3 | 3 |
| 4.4.2.5 | 4 |
| 6.7.2 | 4 |
| 6.22.6 | 4 |
| 8.30.3 | 4 |
| 8.30.5 | 4 |
| 10.10.3 | 4 |
| 12.6.3 | 4 |
| 16.4.3 | 4 |
| 16.12.5 | 4 |
| 19.6.1.3 | 4 |
| 19.6.2 | 4 |
| 19.9 | 4 |
| 20.16.1 | 4 |
| 20.16.2 | 4 |
| 20.16.4 | 4 |
| 25.6 | 4 |
| 28.16.2.1 | 4 |
| 32.4.3 | 4 |
| 37.3.6 | 4 |
| 37.3.8 | 4 |
| 37.9 | 4 |
| 37.18 | 4 |
| 37.19 | 4 |
| 37.21 | 4 |
| 37.23 | 4 |
| 37.24 | 4 |
| 37.30 | 4 |
| 37.48 | 4 |
| 37.57 | 4 |
| 37.58 | 4 |
| 37.66 | 4 |
| 37.71 | 4 |
| 37.74 | 4 |
| 37.80 | 4 |
| 37.81 | 4 |
| 6.7.3 | 5 |
| 8.26.4 | 5 |
| 8.26.6.2 | 5 |
| 16.9.10 | 5 |
| 16.9.11 | 5 |
| 16.12.4 | 5 |
| 16.12.18 | 5 |
| 16.13.2 | 5 |
| 19.6.1.4 | 5 |
| 21.7.4.3.1 | 5 |
| 33.4.2 | 5 |
| 37.46 | 5 |
| 37.50 | 5 |
| 37.54 | 5 |
| 37.60 | 5 |
| 37.67 | 5 |
| 37.68 | 5 |
| 37.72 | 5 |
| 39.3.2 | 5 |
| 39.4.1 | 5 |
| 40.3.2.4 | 5 |
| 40.3.2.5 | 5 |
| 7.9.8 | 6 |
| 12.4.2.1 | 6 |
| 15.5.4 | 6 |
| 16.9.1 | 6 |
| 16.9.5 | 6 |
| 16.9.7 | 6 |
| 16.9.8 | 6 |
| 19.5.7 | 6 |
| 21.7.4.1 | 6 |
| 24.6 | 6 |
| 25.7.4 | 6 |
| 28.15.2 | 6 |
| 31.4.1 | 6 |
| 31.4.5 | 6 |
| 36.8.1 | 6 |
| 37.6 | 6 |
| 37.15 | 6 |
| 37.29 | 6 |
| 37.34 | 6 |
| 37.36 | 6 |
| 37.44 | 6 |
| 37.49 | 6 |
| 37.53 | 6 |
| 37.63 | 6 |
| 37.75 | 6 |
| 37.83 | 6 |
| 12.6.2 | 7 |
| 16.12.19 | 7 |
| 16.12.22 | 7 |
| 16.14.6.1 | 7 |
| 19.5.1.1 | 7 |
| 30.7.4.1 | 7 |
| 31.4.2 | 7 |
| 37.3.4 | 7 |
| 37.26 | 7 |
| 37.61 | 7 |
| 37.64 | 7 |
| 38.36.1.1 | 7 |
| 38.36.1.2 | 7 |
| 17.7.2 | 8 |
| 19.5.5 | 8 |
| 19.5.6 | 8 |
| 20.16.3 | 8 |
| 23.3.3.7.1 | 8 |
| 32.4.2 | 8 |
| 37.22 | 8 |
| 37.40 | 8 |
| 37.51 | 8 |
| 37.52 | 8 |
| 40.5.2 | 8 |
| 16.9.6 | 9 |
| 16.13.1 | 9 |
| 31.3.5 | 9 |
| 31.7 | 9 |
| 37.41 | 9 |
| 39.5.1 | 9 |
| 12.6.1 | 10 |
| 16.12.13 | 10 |
| 37.13 | 10 |
| 37.20 | 10 |
| 39.3.1 | 10 |
| 19.4.1 | 11 |
| 21.7.3.1 | 11 |
| 37.59 | 11 |
| 16.12.10 | 12 |
| 16.17 | 12 |
| 19.11.3 | 12 |
| 11.9 | 13 |
| 16.9.2.1 | 13 |
| 36.12.1 | 13 |
| 37.25 | 13 |
| 7.3.2 | 14 |
| 37.32 | 14 |
| 37.33 | 14 |
| 39.5.2 | 14 |
| 40.2.2 | 14 |
| 16.12.17 | 15 |
| 37.47 | 15 |
| 37.31 | 16 |
| 40.3.2.2 | 16 |
| 31.3.2 | 17 |
| 36.12.2.1 | 17 |
| 16.11 | 19 |
| 31.3.1 | 20 |
| 37.11 | 22 |
| 40.3.2.3 | 22 |
| 6.6.8 | 24 |
| 16.8.2 | 25 |
| 37.35 | 25 |
| 40.3.2.1 | 32 |
| 15.5.5.2 | 50 |
| 15.5.5.1 | 52 |
| 15.5.5.3 | 52 |
