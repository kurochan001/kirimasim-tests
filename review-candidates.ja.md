# レビュー候補

[English](review-candidates.md)

期待値の根拠が規格の読み方にしかないテストと条項を、各シミュレータの最新の結果から挙げます。候補は誤りの指摘ではなく、規格と照らした見直しで判断します。[見直しの記録の仕方](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/docs/review-candidates.md)。

## 読んだ結果

| シミュレータ | 版 | 時刻 | スイートのコミット |
| --- | --- | --- | --- |
| Icarus Verilog | `Icarus Verilog version 14.0 (devel) (s20260301-1291-g3f05f92b)` | 2026-11-25T05:36:07Z | `f029182b` |
| Verilator | `Verilator 5.055 devel rev v5.054-394-g342ca8e0` | 2026-11-25T05:36:07Z | `f029182b` |
| kirimasim | `kirimasim 0.2.2 (commit a50ec73c37d8), built with GNU 13.3.0` | 2026-11-25T05:36:07Z | `f029182b` |
| Lyra | `Lyra (commit b1666593b9f4)` | 2026-11-25T05:36:07Z | `f029182b` |
| Ghost | `private build a4db8bcf783c` | 2026-11-25T05:36:07Z | `f029182b` |

## 件数

| 候補 | 件数 |
| --- | ---: |
| specのみで、Ghost・kirimasim・Lyraのすべてでfail | 16 |
| specのみで、kirimasimだけがpass | 1 |
| specのみで、どこでもpassしないその他のテスト | 112 |
| 固定版のoracleがあり、GhostとLyraの両方でfail | 6 |
| 引用するテストがすべてspecのみの条項 | 215 |
| 読み方が割れるテスト | 78 |

結果: I Icarus Verilog、V Verilator、K kirimasim、L Lyra、G Ghost。p pass、f fail、u unsupported、k known、- 未実行。

## specのみで、Ghost・kirimasim・Lyraのすべてでfail

| テスト | 結果 |
| --- | --- |
| [`ch10/test_illegal_user_drive_strength_on_full_vector_net`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch10/test_illegal_user_drive_strength_on_full_vector_net.sv) | `Ik Vk Kf Lf Gf` |
| [`ch10/test_illegal_user_drive_strength_on_supply_net`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch10/test_illegal_user_drive_strength_on_supply_net.sv) | `Ik Vk Kf Lf Gf` |
| [`ch13/test_discarded_function_return_warns_only_without_void_cast`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch13/test_discarded_function_return_warns_only_without_void_cast.sv) | `Ik Vk Kf Lf Gf` |
| [`ch17/test_checker_named_empty_binding_takes_precedence_over_wildcard`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch17/test_checker_named_empty_binding_takes_precedence_over_wildcard.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_elaboration_fatal_reports_logical_location_and_blocks_simulation`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_elaboration_fatal_reports_logical_location_and_blocks_simulation.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_finish_diagnostic_two_reports_time_location_memory_and_cpu`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_finish_diagnostic_two_reports_time_location_memory_and_cpu.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_illegal_isunbounded_constant_expression_not_parameter_name`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_illegal_isunbounded_constant_expression_not_parameter_name.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_sampled_value_functions_accept_empty_trailing_clock_arguments`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_sampled_value_functions_accept_empty_trailing_clock_arguments.sv) | `Ik Vk Kf Lf Gf` |
| [`ch21/test_scan_reports_destination_for_suppressed_conversion`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch21/test_scan_reports_destination_for_suppressed_conversion.sv) | `Ik Vk Kf Lf Gf` |
| [`ch21/test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch21/test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices.sv) | `Ik Vk Kf Lf Gf` |
| [`ch23/test_uwire_nonmerge_warns_when_port_width_conversion_is_required`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch23/test_uwire_nonmerge_warns_when_port_width_conversion_is_required.sv) | `Ik Vk Kf Lf Gf` |
| [`ch28/test_aliased_user_nettype_switch_connects_original_and_renamed_nets`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch28/test_aliased_user_nettype_switch_connects_original_and_renamed_nets.sv) | `Ik Vk Kf Lf Gf` |
| [`ch28/test_illegal_interconnect_scalar_connects_to_primitive_array`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch28/test_illegal_interconnect_scalar_connects_to_primitive_array.sv) | `Ik Vk Kf Lf Gf` |
| [`ch28/test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch28/test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_uwire_padded_port_connection_warns`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch6/test_uwire_padded_port_connection_warns.sv) | `Ik Vk Kf Lf Gf` |
| [`ch9/test_intraassignment_repeat_counts_two_edges_at_one_time`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch9/test_intraassignment_repeat_counts_two_edges_at_one_time.sv) | `Ik Vk Kf Lf Gf` |

## specのみで、kirimasimだけがpass

| テスト | 結果 |
| --- | --- |
| [`ch13/test_illegal_function_background_work_from_static_initializer`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch13/test_illegal_function_background_work_from_static_initializer.sv) | `Ik Vk Kp Lf Gf` |

## specのみで、どこでもpassしないその他のテスト

| テスト | 結果 |
| --- | --- |
| [`ch10/test_alias_chain_with_typed_net_assignment_pattern`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch10/test_alias_chain_with_typed_net_assignment_pattern.sv) | `Ik Vk Ku Lf Gf` |
| [`ch10/test_interconnect_array_declaration_delay_and_two_declarators`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch10/test_interconnect_array_declaration_delay_and_two_declarators.sv) | `Ik Vk Ku Lu Gf` |
| [`ch10/test_net_declaration_delay_preserves_large_integral_tick`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch10/test_net_declaration_delay_preserves_large_integral_tick.sv) | `Ik Vk Ku Lu Gf` |
| [`ch11/test_illegal_stream_with_negative_index_on_dynamic_array`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_illegal_stream_with_negative_index_on_dynamic_array.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_below_declared_range_discards_only_prefix`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_stream_unpack_below_declared_range_discards_only_prefix.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_outside_fixed_array_updates_only_in_range_entries`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_stream_unpack_outside_fixed_array_updates_only_in_range_entries.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_partial_fixed_extent_reports_runtime_error`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_stream_unpack_partial_fixed_extent_reports_runtime_error.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap.sv) | `Ik Vk Ku Lf Gf` |
| [`ch12/test_matches_precedes_boolean_and_or`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch12/test_matches_precedes_boolean_and_or.sv) | `Ik Vk Ku Lf Gf` |
| [`ch14/test_illegal_clocking_cycle_delay_negative_integer`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch14/test_illegal_clocking_cycle_delay_negative_integer.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_cover_property_defaults_to_strong_under_property_negation`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_cover_property_defaults_to_strong_under_property_negation.sv) | `Ik Vk Ku Lu Gf` |
| [`ch16/test_cover_property_negated_explicit_strong_matches_at_end_of_trace`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_cover_property_negated_explicit_strong_matches_at_end_of_trace.sv) | `Ik Vk Ku Lu Gf` |
| [`ch17/test_checker_port_property_actual_attributes_and_omissions`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch17/test_checker_port_property_actual_attributes_and_omissions.sv) | `Ik Vk Ku Lu Gf` |
| [`ch18/test_constraint_function_priority_does_not_prune_high_randc_cycle`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch18/test_constraint_function_priority_does_not_prune_high_randc_cycle.sv) | `Ik Vk Ku Lf Gf` |
| [`ch19/test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch19/test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns.sv) | `Ik Vk Ku Lf Gf` |
| [`ch19/test_default_sequence_catches_first_unmatched_transition`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch19/test_default_sequence_catches_first_unmatched_transition.sv) | `Ik Vk Ku Lf Gf` |
| [`ch20/test_elaboration_messages_identify_selected_scope_without_user_formatting`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_elaboration_messages_identify_selected_scope_without_user_formatting.sv) | `Ik Vk Ku Lf Gf` |
| [`ch20/test_global_clock_sampled_functions_evaluate_computed_operands`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_global_clock_sampled_functions_evaluate_computed_operands.sv) | `Ik Vk Ku Lu Gf` |
| [`ch23/test_interconnect_single_port_retains_all_local_wired_drivers`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch23/test_interconnect_single_port_retains_all_local_wired_drivers.sv) | `Ik Vk Ku Lu Gf` |
| [`ch23/test_resolved_user_nettype_counts_local_drivers_across_port_merges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch23/test_resolved_user_nettype_counts_local_drivers_across_port_merges.sv) | `Ik Vk Ku Lu Gf` |
| [`ch25/test_illegal_ref_modport_signal_used_as_timing_check_terminal`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch25/test_illegal_ref_modport_signal_used_as_timing_check_terminal.sv) | `Ik Vk Ku Lf Gf` |
| [`ch28/test_user_nettype_active_low_switch_unknown_turnoff_delay`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch28/test_user_nettype_active_low_switch_unknown_turnoff_delay.sv) | `Ik Vk Ku Lu Gf` |
| [`ch3/test_vpi_per_file_units_iterate_same_named_locals_separately`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch3/test_vpi_per_file_units_iterate_same_named_locals_separately.sv) | `Ik Vk Ku Lu Gf` |
| [`ch31/test_inconsistent_negative_limits_clear_numerically_smallest_limit`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_inconsistent_negative_limits_clear_numerically_smallest_limit.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_inconsistent_negative_timing_recalculates_after_each_relaxation`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_inconsistent_negative_timing_recalculates_after_each_relaxation.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_setup_shift_clamps_adjusted_hold_and_warns`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_negative_setup_shift_clamps_adjusted_hold_and_warns.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_setuphold_has_exclusive_window_endpoints`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_negative_setuphold_has_exclusive_window_endpoints.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_setuphold_notifier_tracks_repeated_delayed_edges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_negative_setuphold_notifier_tracks_repeated_delayed_edges.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_timing_condition_compares_undelayed_input_at_delayed_edge`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_negative_timing_condition_compares_undelayed_input_at_delayed_edge.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_timing_notifiers_follow_delayed_violating_edges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_negative_timing_notifiers_follow_delayed_violating_edges.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_setuphold_and_recrem_shift_the_same_violation_window`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_setuphold_and_recrem_shift_the_same_violation_window.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_setuphold_negative_limits_event_roles_and_conditions`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_setuphold_negative_limits_event_roles_and_conditions.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_setuphold_uses_explicit_delayed_reference_for_both_checks`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_setuphold_uses_explicit_delayed_reference_for_both_checks.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_specify_output_waits_for_longer_negative_timing_delay`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_specify_output_waits_for_longer_negative_timing_delay.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_timing_condition_can_use_explicit_delayed_reference_value`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_timing_condition_can_use_explicit_delayed_reference_value.sv) | `Ik Vk Ku Lf Gf` |
| [`ch32/test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_invalid_source_resets_both_driver_delays`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_invalid_source_resets_both_driver_delays.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_keeps_twenty_four_queued_transitions`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_keeps_twenty_four_queued_transitions.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_overlaps_parent_and_child_loads`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_overlaps_parent_and_child_loads.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_rejects_reversed_port_directions`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_rejects_reversed_port_directions.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_uses_trailing_transition_pulse_limits`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_interconnect_uses_trailing_transition_pulse_limits.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_named_log_has_distinct_entries_for_two_paths`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_named_log_has_distinct_entries_for_two_paths.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_task_arguments_override_configuration_scaling`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_task_arguments_override_configuration_scaling.sv) | `Ik Vk Ku Lu Gf` |
| [`ch35/test_dpi_context_task_does_not_authorize_noncontext_child_import`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_dpi_context_task_does_not_authorize_noncontext_child_import.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_disabled_import_task_cannot_call_another_export`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_dpi_disabled_import_task_cannot_call_another_export.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_import_task_rejects_disable_status_after_normal_return`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_dpi_import_task_rejects_disable_status_after_normal_return.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_import_task_rejects_wrong_status_after_disable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_dpi_import_task_rejects_wrong_status_after_disable.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_imported_function_cannot_enable_untimed_exported_task`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_dpi_imported_function_cannot_enable_untimed_exported_task.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_nested_noncontext_call_cannot_inherit_export_permission`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_dpi_nested_noncontext_call_cannot_inherit_export_permission.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_illegal_dpi_version_mismatch_across_package_and_module`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_illegal_dpi_version_mismatch_across_package_and_module.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_illegal_dpi_versions_share_one_c_linkage_identifier`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_illegal_dpi_versions_share_one_c_linkage_identifier.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_legacy_dpi_packed_selects_cross_canonical_word_boundary`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch35/test_legacy_dpi_packed_selects_cross_canonical_word_boundary.sv) | `Ik Vk Ku Lf Gf` |
| [`ch36/test_vpi_compatibility_mode_uses_null_handle_for_bound_mode`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch36/test_vpi_compatibility_mode_uses_null_handle_for_bound_mode.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_aggregate_nets_do_not_have_whole_values`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_aggregate_nets_do_not_have_whole_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_class_definition_and_specialization_value_access_differ`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_class_definition_and_specialization_value_access_differ.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_definition_handles_cannot_read_or_write_class_storage`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_definition_handles_cannot_read_or_write_class_storage.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_delayed_write_refuses_automatic_variable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_delayed_write_refuses_automatic_variable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_dpi_language_and_linkage_name_for_imports_and_exports`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interface_formal_rejects_get_and_put_delays`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_interface_formal_rejects_get_and_put_delays.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_legacy_array_property_on_named_event_elements`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_legacy_array_property_on_named_event_elements.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_legacy_array_property_on_net_elements`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_legacy_array_property_on_net_elements.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_legacy_array_property_on_variable_elements`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_legacy_array_property_on_variable_elements.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_part_select_uses_distinct_bound_relations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_part_select_uses_distinct_bound_relations.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_port_bit_excludes_name_and_port_index`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_port_bit_excludes_name_and_port_index.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_property_variables_expose_declarations_without_values`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_property_variables_expose_declarations_without_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_put_rejects_hidden_side_effects_in_index_calls`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_put_rejects_hidden_side_effects_in_index_calls.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_put_value_rejects_side_effect_in_bit_select_index`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_put_value_rejects_side_effect_in_bit_select_index.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_simulated_net_is_shared_across_interconnect_merges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_simulated_net_is_shared_across_interconnect_merges.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_static_part_select_rejects_ambiguous_expression`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_static_part_select_rejects_ambiguous_expression.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_typespec_handles_allow_static_storage_only`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_typespec_handles_allow_static_storage_only.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_unpacked_aggregates_only_expose_member_values`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_unpacked_aggregates_only_expose_member_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_unpacked_structure_rejects_whole_value_access`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_unpacked_structure_rejects_whole_value_access.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_unpacked_union_rejects_whole_value_access`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_unpacked_union_rejects_whole_value_access.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_value_change_callback_refuses_automatic_variable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_value_change_callback_refuses_automatic_variable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_bulk_array_checks_element_type_and_storage_lifetime`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_bulk_array_checks_element_type_and_storage_lifetime.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_control_scope_change_reports_selected_instance`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_control_scope_change_reports_selected_instance.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_direct_reset_brackets_time_zero_restoration`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_direct_reset_brackets_time_zero_restoration.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_end_of_frame_or_thread_object_reports_no_time`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_end_of_frame_or_thread_object_reports_no_time.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_flush_exposes_live_console_and_current_log_bytes`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_flush_exposes_live_console_and_current_log_bytes.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_force_and_release_concatenated_net_selections_and_variable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_force_and_release_concatenated_net_selections_and_variable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_force_release_rejects_variable_and_user_nettype_selections`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_force_release_rejects_variable_and_user_nettype_selections.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_force_release_whole_resolved_user_nettype`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_force_release_whole_resolved_user_nettype.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_printf_reports_formatted_length_and_encoding_error`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_printf_reports_formatted_length_and_encoding_error.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_put_value_rejects_gate_and_combinational_udp_instances`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_put_value_rejects_gate_and_combinational_udp_instances.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_put_value_rejects_user_nettype_subelement`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_put_value_rejects_user_nettype_subelement.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_refuses_force_release_disable_callbacks_on_variable_bits`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_refuses_force_release_disable_callbacks_on_variable_bits.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_reset_defers_until_return_and_restores_initial_state`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_reset_defers_until_return_and_restores_initial_state.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_restart_preserves_restart_callbacks_and_drops_value_change`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_restart_preserves_restart_callbacks_and_drops_value_change.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_restart_stream_warns_and_zero_fills_a_short_read`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_restart_stream_warns_and_zero_fills_a_short_read.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_save_restart_reads_interleaved_streams_in_new_chunks`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_save_restart_reads_interleaved_streams_in_new_chunks.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_scalar_callbacks_keep_high_and_low_strength_states`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_scalar_callbacks_keep_high_and_low_strength_states.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_time_callback_reentrant_start_stays_before_active_events`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_time_callback_reentrant_start_stays_before_active_events.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_unresolved_task_callback_supplies_called_name`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_unresolved_task_callback_supplies_called_name.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_value_change_traces_expression_primitive_terminal_and_net`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_value_change_traces_expression_primitive_terminal_and_net.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_vector_callback_storage_survives_get_value_until_return`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_vector_callback_storage_survives_get_value_until_return.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_control_rejects_property_and_sequence_instance_handles`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch39/test_vpi_assertion_control_rejects_property_and_sequence_instance_handles.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch39/test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_initialization_callback_guards_controls`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch39/test_vpi_assertion_initialization_callback_guards_controls.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_system_fail_action_controls_respect_scope`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch39/test_vpi_assertion_system_fail_action_controls_respect_scope.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_system_notifications_follow_lifecycle`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch39/test_vpi_assertion_system_notifications_follow_lifecycle.sv) | `Ik Vk Ku Lu Gf` |
| [`ch9/test_await_resumes_after_normal_and_forced_exit_then_rejects_self`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch9/test_await_resumes_after_normal_and_forced_exit_then_rejects_self.sv) | `Ik Vk Ku Lf Gf` |
| [`ch9/test_process_await_rejects_current_process`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch9/test_process_await_rejects_current_process.sv) | `Ik Vk Ku Lf Gf` |
| [`ch9/test_process_function_cannot_suspend_current_process`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch9/test_process_function_cannot_suspend_current_process.sv) | `Ik Vk Ku Lf Gf` |

## 固定版のoracleがあり、GhostとLyraの両方でfail

| テスト | 結果 |
| --- | --- |
| [`ch21/test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch21/test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds.sv) | `Ip Vk Kf Lf Gf` |
| [`ch21/test_readmem_stops_at_address_outside_selected_slice_without_resuming`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch21/test_readmem_stops_at_address_outside_selected_slice_without_resuming.sv) | `Ip Vk Kf Lf Gf` |
| [`ch26/test_package_wildcard_binding_across_functions`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch26/test_package_wildcard_binding_across_functions.sv) | `Ip Vp Kf Lf Gf` |
| [`ch26/test_wildcard_reference_in_generate_binds_name_in_enclosing_scope`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch26/test_wildcard_reference_in_generate_binds_name_in_enclosing_scope.sv) | `Ip Vp Kf Lf Gf` |
| [`ch28/test_illegal_resistive_pass_switch_vector_terminals`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch28/test_illegal_resistive_pass_switch_vector_terminals.sv) | `Ip Vk Ku Lf Gf` |
| [`ch30/test_specify_path_delay_preserves_large_integral_tick`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch30/test_specify_path_delay_preserves_large_integral_tick.sv) | `Ip Vk Kp Lf Gf` |

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
| 20.12 | 2 |
| 21.7.3.6.1 | 2 |
| 21.7.3.7 | 2 |
| 21.7.4.3.2 | 2 |
| 25.3.2 | 2 |
| 30.7.3 | 2 |
| 31.8 | 2 |
| 31.9.3 | 2 |
| 32.2 | 2 |
| 33.3.1.1 | 2 |
| 33.5.4 | 2 |
| 35.2.2.1 | 2 |
| 35.5.1.5 | 2 |
| 36.10.3 | 2 |
| 37.56 | 2 |
| 37.69 | 2 |
| 37.79 | 2 |
| 38.9 | 2 |
| 39.4.2.1 | 2 |
| 39.5.3 | 2 |
| 40.2.1 | 2 |
| 6.6.4.1 | 3 |
| 6.6.4.2 | 3 |
| 8.29 | 3 |
| 16.13.7 | 3 |
| 16.14.6.2 | 3 |
| 16.14.6.4 | 3 |
| 19.6.3 | 3 |
| 21.7.3.2 | 3 |
| 21.7.3.3 | 3 |
| 23.3.3.7.2 | 3 |
| 30.7.4.2 | 3 |
| 36.10.1 | 3 |
| 37.7 | 3 |
| 37.8 | 3 |
| 37.9 | 3 |
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
| 8.30.2 | 4 |
| 12.6.3 | 4 |
| 16.4.3 | 4 |
| 16.12.5 | 4 |
| 19.6.1.3 | 4 |
| 19.6.2 | 4 |
| 21.7.3.4 | 4 |
| 21.7.3.5 | 4 |
| 28.16.2.1 | 4 |
| 28.16.2.2 | 4 |
| 32.4.3 | 4 |
| 37.3.5 | 4 |
| 37.3.6 | 4 |
| 37.3.8 | 4 |
| 37.18 | 4 |
| 37.19 | 4 |
| 37.21 | 4 |
| 37.23 | 4 |
| 37.30 | 4 |
| 37.57 | 4 |
| 37.58 | 4 |
| 37.66 | 4 |
| 37.71 | 4 |
| 37.74 | 4 |
| 37.80 | 4 |
| 37.81 | 4 |
| 6.7.3 | 5 |
| 6.22.6 | 5 |
| 8.26.4 | 5 |
| 8.26.6.2 | 5 |
| 12.5.3.1 | 5 |
| 16.9.10 | 5 |
| 16.12.4 | 5 |
| 16.12.18 | 5 |
| 19.6.1.4 | 5 |
| 19.9 | 5 |
| 21.7.4.2 | 5 |
| 21.7.4.3.1 | 5 |
| 33.4.2 | 5 |
| 37.3.2 | 5 |
| 37.24 | 5 |
| 37.46 | 5 |
| 37.48 | 5 |
| 37.54 | 5 |
| 37.60 | 5 |
| 37.67 | 5 |
| 37.68 | 5 |
| 37.72 | 5 |
| 40.3.2.4 | 5 |
| 40.3.2.5 | 5 |
| 7.9.8 | 6 |
| 8.30.5 | 6 |
| 16.9.1 | 6 |
| 16.9.5 | 6 |
| 16.9.7 | 6 |
| 16.9.8 | 6 |
| 16.13.2 | 6 |
| 20.16.2 | 6 |
| 20.16.4 | 6 |
| 24.6 | 6 |
| 31.4.1 | 6 |
| 31.4.5 | 6 |
| 36.8.1 | 6 |
| 37.6 | 6 |
| 37.34 | 6 |
| 37.49 | 6 |
| 37.50 | 6 |
| 37.63 | 6 |
| 37.75 | 6 |
| 37.83 | 6 |
| 39.3.2 | 6 |
| 15.5.4 | 7 |
| 16.9.11 | 7 |
| 16.12.19 | 7 |
| 16.12.22 | 7 |
| 16.14.6.1 | 7 |
| 20.16.1 | 7 |
| 25.7.4 | 7 |
| 28.15.2 | 7 |
| 30.7.4.1 | 7 |
| 31.4.2 | 7 |
| 37.3.4 | 7 |
| 37.15 | 7 |
| 37.29 | 7 |
| 37.36 | 7 |
| 37.53 | 7 |
| 37.61 | 7 |
| 37.64 | 7 |
| 38.36.1.1 | 7 |
| 38.36.1.2 | 7 |
| 8.30.3 | 8 |
| 8.30.4 | 8 |
| 12.4.2.1 | 8 |
| 19.5.1.1 | 8 |
| 19.5.5 | 8 |
| 19.5.7 | 8 |
| 32.4.2 | 8 |
| 37.22 | 8 |
| 8.30.1 | 9 |
| 12.6.2 | 9 |
| 16.9.6 | 9 |
| 21.7.4.1 | 9 |
| 31.3.5 | 9 |
| 31.7 | 9 |
| 37.40 | 9 |
| 37.44 | 9 |
| 37.51 | 9 |
| 37.52 | 9 |
| 40.5.2 | 9 |
| 16.12.13 | 10 |
| 16.13.1 | 10 |
| 19.5.6 | 10 |
| 20.16.3 | 10 |
| 37.13 | 10 |
| 37.41 | 10 |
| 17.7.2 | 11 |
| 25.6 | 11 |
| 37.20 | 11 |
| 37.26 | 11 |
| 39.4.1 | 11 |
| 12.6.1 | 12 |
| 16.12.10 | 12 |
| 16.17 | 12 |
| 19.11.3 | 12 |
| 23.3.3.7.1 | 12 |
| 39.3.1 | 12 |
| 16.9.2.1 | 13 |
| 19.4.1 | 13 |
| 37.25 | 13 |
| 37.59 | 13 |
| 36.12.1 | 14 |
| 39.5.1 | 14 |
| 40.2.2 | 14 |
| 16.12.17 | 15 |
| 21.7.3.1 | 15 |
| 37.47 | 15 |
| 40.3.2.2 | 16 |
| 11.9 | 17 |
| 37.32 | 17 |
| 37.33 | 17 |
| 39.5.2 | 17 |
| 7.3.2 | 18 |
| 37.31 | 18 |
| 31.3.2 | 19 |
| 36.12.2.1 | 19 |
| 16.11 | 20 |
| 31.3.1 | 22 |
| 37.11 | 22 |
| 40.3.2.3 | 22 |
| 16.8.2 | 27 |
| 37.35 | 28 |
| 6.6.8 | 30 |
| 40.3.2.1 | 32 |
| 15.5.5.2 | 50 |
| 15.5.5.3 | 54 |

## 読み方が割れるテスト

[読み方が割れるテストの台帳](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/docs/interpretation-splits.md)のテストを別枠で挙げます。上の候補にもそのまま含まれ、件数は変わりません。

| テスト | 区分 | 状態 | 結果 |
| --- | --- | --- | --- |
| [`ch11/test_equality_class_interface_chandle_handles`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_equality_class_interface_chandle_handles.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch11/test_illegal_stream_with_on_two_dimensional_array`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch11/test_illegal_stream_with_on_two_dimensional_array.sv) | `contested` | `unresolved` | `Ip Vp Ku Lf Gp` |
| [`ch16/test_first_match_items_and_boolean_or`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_first_match_items_and_boolean_or.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_consecutive_repetition`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_sequence_consecutive_repetition.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_empty_match_concatenation`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_sequence_empty_match_concatenation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_empty_match_fusion`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_sequence_empty_match_fusion.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_local_formal_assignment`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch16/test_sequence_local_formal_assignment.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch17/test_checker_assertion_placement`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch17/test_checker_assertion_placement.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch18/test_inline_local_scope_binding`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch18/test_inline_local_scope_binding.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch18/test_rand_mode_inactive_handle`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch18/test_rand_mode_inactive_handle.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch18/test_randomize_callback_override`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch18/test_randomize_callback_override.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch19/test_cg_four_state_literal_wildcard_enum`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch19/test_cg_four_state_literal_wildcard_enum.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`ch19/test_cg_option_levels_readback`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch19/test_cg_option_levels_readback.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch20/test_pla_all_forms`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_pla_all_forms.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch20/test_pla_sync_snapshot_versus_async_update`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch20/test_pla_sync_snapshot_versus_async_update.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch21/test_fwrite_unformatted_aggregates`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch21/test_fwrite_unformatted_aggregates.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch21/test_illegal_value_plusargs_bad_format`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch21/test_illegal_value_plusargs_bad_format.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch22/test_illegal_include_absolute_path_in_angle_brackets`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch22/test_illegal_include_absolute_path_in_angle_brackets.sv) | `contested` | `unresolved` | `Ip Vk Kf Lf Gp` |
| [`ch23/test_defparam_block_task_function_parameters`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch23/test_defparam_block_task_function_parameters.sv) | `contested` | `unresolved` | `If Vk Kf Lf Gp` |
| [`ch23/test_port_collapse_uwire_external_delay`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch23/test_port_collapse_uwire_external_delay.sv) | `contested` | `unresolved` | `Ik Vp Kf Lf Gp` |
| [`ch30/test_illegal_specify_edge_path_same_edge_and_condition`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch30/test_illegal_specify_edge_path_same_edge_and_condition.sv) | `contested` | `unresolved` | `Ip Vk Ku Lf Gp` |
| [`ch31/test_illegal_setuphold_negative_sum`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_illegal_setuphold_negative_sum.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch31/test_illegal_timing_condition_two_signals`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_illegal_timing_condition_two_signals.sv) | `contested` | `unresolved` | `Ip Vk Ku Lf Gp` |
| [`ch31/test_timing_check_condition_x`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch31/test_timing_check_condition_x.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch32/test_sdf_scale_type_members`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch32/test_sdf_scale_type_members.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch33/test_config_cell_parameter`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch33/test_config_cell_parameter.sv) | `contested` | `unresolved` | `Ik Vk Kp Lf Gp` |
| [`ch33/test_duplicate_cell_last_definition_wins`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch33/test_duplicate_cell_last_definition_wins.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`ch36/test_vpi_chk_error_callbacks`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch36/test_vpi_chk_error_callbacks.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compatibility_1800v2017_mode`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch36/test_vpi_compatibility_1800v2017_mode.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compatibility_1800v2023_mode`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch36/test_vpi_compatibility_1800v2023_mode.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compiletf_sizetf`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch36/test_vpi_compiletf_sizetf.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_atomic_task_call_label`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_atomic_task_call_label.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_attribute_value_types`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_attribute_value_types.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_class_relations_scope_typespec`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_class_relations_scope_typespec.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_cont_assign_bits_delays`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_cont_assign_bits_delays.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_generate_nettype_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_generate_nettype_typedef.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_interconnect_array_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_interconnect_array_ranges.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_iterator_objects`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_iterator_objects.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_module_paths`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_module_paths.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_named_event_relations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_named_event_relations.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_named_events`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_named_events.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_net_driver_objects`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_net_driver_objects.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_alias_chain_relations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_nettype_alias_chain_relations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_declarations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_nettype_declarations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_net_parts`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_nettype_net_parts.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_relations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_nettype_relations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_prefix_allocation`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_prefix_allocation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_program_interface_relations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_program_interface_relations.sv) | `contested` | `resolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_property_operator_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_property_operator_kinds.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_select_objects_event_arrays`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_select_objects_event_arrays.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_size_change_callback`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_size_change_callback.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_statement_control_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_statement_control_kinds.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_tf_call_kinds_relations`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_tf_call_kinds_relations.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_unbounded_const_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch37/test_vpi_unbounded_const_ranges.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_error_callback_runtime_errors`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_error_callback_runtime_errors.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_get_value_array`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_get_value_array.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_get_value_real_conversion`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_get_value_real_conversion.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_mcd_open_reuse`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_mcd_open_reuse.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_value_change_event`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch38/test_vpi_value_change_event.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch39/test_vpi_assertion_reset_restores_initial_state`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch39/test_vpi_assertion_reset_restores_initial_state.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_coverage_control_package_scope`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch40/test_coverage_control_package_scope.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_coverage_fsm_next_state_pragmas`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch40/test_coverage_fsm_next_state_pragmas.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_vpi_coverage_save_merge`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch40/test_vpi_coverage_save_merge.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch6/test_a2_1_3_interconnect_declaration_identifiers`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch6/test_a2_1_3_interconnect_declaration_identifiers.sv) | `contested` | `unresolved` | `Ik Vk Kf Lu Gp` |
| [`ch6/test_builtin_net_declaration_forms`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch6/test_builtin_net_declaration_forms.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch7/test_array_ordering_methods_and_index_queries`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch7/test_array_ordering_methods_and_index_queries.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_string_in_untagged_union`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch7/test_illegal_string_in_untagged_union.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_unique_index_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch7/test_illegal_unique_index_without_with_struct_elements.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_unique_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/ch7/test_illegal_unique_without_with_struct_elements.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch21/test_gen_cross_litfmt_fill_b_display_param`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch21/test_gen_cross_litfmt_fill_b_display_param.sv) | `contested` | `unresolved` | `Ip Vp Kp Lf Gp` |
| [`gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65`](https://github.com/kurochan001/kirimasim-tests/blob/f029182b31bfe8fded04eeb649f19517d988ca97/tests/gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65.sv) | `contested` | `unresolved` | `Ip Vp Kp Lf Gp` |
