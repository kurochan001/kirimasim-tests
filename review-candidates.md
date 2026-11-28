# Review candidates

[日本語](review-candidates.ja.md)

Tests and clauses whose expected results rest least on anything but the reading of the standard, from the latest results of each simulator. A candidate is not a finding: a review against the standard decides. [How the reviews are recorded](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/docs/review-candidates.en.md).

## Results read

| Simulator | Version | Time | Suite commit |
| --- | --- | --- | --- |
| Icarus Verilog | `Icarus Verilog version 14.0 (devel) (s20260301-1293-g24acba16)` | 2026-11-28T04:02:56Z | `1fca5f36` |
| Verilator | `Verilator 5.055 devel rev v5.054-425-gf56b1008` | 2026-11-28T04:02:56Z | `1fca5f36` |
| kirimasim | `kirimasim 0.3.0 (commit 9f825f60b76c), built with GNU 13.3.0` | 2026-11-28T04:02:56Z | `1fca5f36` |
| Lyra | `Lyra (commit d55cec646337)` | 2026-11-26T06:35:01Z | `3cf9bee1` (older suite commit) |
| Ghost | `private build ca9735e98154` | 2026-11-26T06:35:01Z | `3cf9bee1` (older suite commit) |

## Counts

| Candidate | Number |
| --- | ---: |
| Spec only, failing on Ghost, kirimasim and Lyra | 33 |
| Spec only, passing on kirimasim alone | 1 |
| Other spec-only tests passing nowhere | 177 |
| Release oracle, failing on both Ghost and Lyra | 9 |
| Clauses whose citing tests are all spec only | 255 |
| Tests with contested readings | 82 |

Results: I Icarus Verilog, V Verilator, K kirimasim, L Lyra, G Ghost; p pass, f fail, u unsupported, k known, - not run.

## Spec only, failing on Ghost, kirimasim and Lyra

| Test | Results |
| --- | --- |
| [`ch10/test_illegal_user_drive_strength_on_full_vector_net`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch10/test_illegal_user_drive_strength_on_full_vector_net.sv) | `Ik Vk Kf Lf Gf` |
| [`ch10/test_illegal_user_drive_strength_on_supply_net`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch10/test_illegal_user_drive_strength_on_supply_net.sv) | `Ik Vk Kf Lf Gf` |
| [`ch13/test_discarded_function_return_warns_only_without_void_cast`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch13/test_discarded_function_return_warns_only_without_void_cast.sv) | `Ik Vk Kf Lf Gf` |
| [`ch17/test_checker_named_empty_binding_takes_precedence_over_wildcard`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch17/test_checker_named_empty_binding_takes_precedence_over_wildcard.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_elaboration_fatal_reports_logical_location_and_blocks_simulation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_elaboration_fatal_reports_logical_location_and_blocks_simulation.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_finish_diagnostic_two_reports_time_location_memory_and_cpu`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_finish_diagnostic_two_reports_time_location_memory_and_cpu.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_illegal_isunbounded_constant_expression_not_parameter_name`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_illegal_isunbounded_constant_expression_not_parameter_name.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_sampled_value_functions_accept_empty_trailing_clock_arguments`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_sampled_value_functions_accept_empty_trailing_clock_arguments.sv) | `Ik Vk Kf Lf Gf` |
| [`ch20/test_stop_suspends_each_call_and_resumes_same_tick`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_stop_suspends_each_call_and_resumes_same_tick.sv) | `Ik Vk Kf Lf Gf` |
| [`ch21/test_scan_reports_destination_for_suppressed_conversion`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch21/test_scan_reports_destination_for_suppressed_conversion.sv) | `Ik Vk Kf Lf Gf` |
| [`ch21/test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch21/test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices.sv) | `Ik Vk Kf Lf Gf` |
| [`ch22/test_angle_include_search_uses_only_standard_files`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch22/test_angle_include_search_uses_only_standard_files.sv) | `Ik Vk Kf Lf Gf` |
| [`ch22/test_selected_default_keyword_set_controls_bit`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch22/test_selected_default_keyword_set_controls_bit.sv) | `Ik Vk Kf Lf Gf` |
| [`ch23/test_uwire_nonmerge_warns_when_port_width_conversion_is_required`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch23/test_uwire_nonmerge_warns_when_port_width_conversion_is_required.sv) | `Ik Vk Kf Lf Gf` |
| [`ch28/test_aliased_user_nettype_switch_connects_original_and_renamed_nets`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch28/test_aliased_user_nettype_switch_connects_original_and_renamed_nets.sv) | `Ik Vk Kf Lf Gf` |
| [`ch28/test_illegal_interconnect_scalar_connects_to_primitive_array`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch28/test_illegal_interconnect_scalar_connects_to_primitive_array.sv) | `Ik Vk Kf Lf Gf` |
| [`ch28/test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch28/test_interconnect_vector_and_ordinary_scalar_connect_to_primitive_array.sv) | `Ik Vk Kf Lf Gf` |
| [`ch3/test_library_contains_all_seven_cell_categories`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch3/test_library_contains_all_seven_cell_categories.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_illegal_library_map_contains_a_module_declaration`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_illegal_library_map_contains_a_module_declaration.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_illegal_library_map_same_priority_file_match`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_illegal_library_map_same_priority_file_match.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_dot_and_parent_are_relative_to_the_map`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_dot_and_parent_are_relative_to_the_map.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_grammar_binds_config_and_local_include_lists`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_grammar_binds_config_and_local_include_lists.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_hierarchical_wildcard_matches_zero_and_nested_directories`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_hierarchical_wildcard_matches_zero_and_nested_directories.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_include_preserves_its_own_relative_paths`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_include_preserves_its_own_relative_paths.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_question_matches_exactly_one_character`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_question_matches_exactly_one_character.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_relative_directory_path_aliases`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_relative_directory_path_aliases.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_reversed_order_changes_selected_cell`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_reversed_order_changes_selected_cell.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_map_star_stays_within_a_path_component`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_map_star_stays_within_a_path_component.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_maps_prefer_explicit_then_wildcard_then_directory`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_maps_prefer_explicit_then_wildcard_then_directory.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_library_search_option_overrides_map_default_order`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_library_search_option_overrides_map_default_order.sv) | `Ik Vk Kf Lf Gf` |
| [`ch33/test_nested_library_map_includes_restore_the_containing_directory`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_nested_library_map_includes_restore_the_containing_directory.sv) | `Ik Vk Kf Lf Gf` |
| [`ch6/test_uwire_padded_port_connection_warns`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch6/test_uwire_padded_port_connection_warns.sv) | `Ik Vk Kf Lf Gf` |
| [`ch9/test_intraassignment_repeat_counts_two_edges_at_one_time`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch9/test_intraassignment_repeat_counts_two_edges_at_one_time.sv) | `Ik Vk Kf Lf Gf` |

## Spec only, passing on kirimasim alone

| Test | Results |
| --- | --- |
| [`ch13/test_illegal_function_background_work_from_static_initializer`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch13/test_illegal_function_background_work_from_static_initializer.sv) | `Ik Vk Kp Lf Gf` |

## Other spec-only tests passing nowhere

| Test | Results |
| --- | --- |
| [`ch10/test_alias_chain_with_typed_net_assignment_pattern`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch10/test_alias_chain_with_typed_net_assignment_pattern.sv) | `Ik Vk Ku Lf Gf` |
| [`ch10/test_interconnect_array_declaration_delay_and_two_declarators`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch10/test_interconnect_array_declaration_delay_and_two_declarators.sv) | `Ik Vk Ku Lu Gf` |
| [`ch10/test_net_declaration_delay_preserves_large_integral_tick`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch10/test_net_declaration_delay_preserves_large_integral_tick.sv) | `Ik Vk Ku Lu Gf` |
| [`ch11/test_illegal_stream_with_negative_index_on_dynamic_array`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_illegal_stream_with_negative_index_on_dynamic_array.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_below_declared_range_discards_only_prefix`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_stream_unpack_below_declared_range_discards_only_prefix.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_outside_fixed_array_updates_only_in_range_entries`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_stream_unpack_outside_fixed_array_updates_only_in_range_entries.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_partial_fixed_extent_reports_runtime_error`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_stream_unpack_partial_fixed_extent_reports_runtime_error.sv) | `Ik Vk Ku Lf Gf` |
| [`ch11/test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap.sv) | `Ik Vk Ku Lf Gf` |
| [`ch12/test_matches_precedes_boolean_and_or`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch12/test_matches_precedes_boolean_and_or.sv) | `Ik Vk Ku Lf Gf` |
| [`ch14/test_illegal_clocking_cycle_delay_negative_integer`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch14/test_illegal_clocking_cycle_delay_negative_integer.sv) | `Ik Vk Ku Lf Gf` |
| [`ch16/test_cover_property_defaults_to_strong_under_property_negation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_cover_property_defaults_to_strong_under_property_negation.sv) | `Ik Vk Ku Lu Gf` |
| [`ch16/test_cover_property_negated_explicit_strong_matches_at_end_of_trace`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_cover_property_negated_explicit_strong_matches_at_end_of_trace.sv) | `Ik Vk Ku Lu Gf` |
| [`ch17/test_checker_free_joint_solutions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch17/test_checker_free_joint_solutions.sv) | `Ik Vk Ku L- G-` |
| [`ch17/test_checker_port_property_actual_attributes_and_omissions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch17/test_checker_port_property_actual_attributes_and_omissions.sv) | `Ik Vk Ku Lu Gf` |
| [`ch18/test_constraint_function_priority_does_not_prune_high_randc_cycle`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch18/test_constraint_function_priority_does_not_prune_high_randc_cycle.sv) | `Ik Vk Ku Lf Gf` |
| [`ch18/test_constraint_function_priority_partition`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch18/test_constraint_function_priority_partition.sv) | `Ik Vk Ku Lf Gf` |
| [`ch19/test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch19/test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns.sv) | `Ik Vk Ku Lf Gf` |
| [`ch19/test_default_sequence_catches_first_unmatched_transition`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch19/test_default_sequence_catches_first_unmatched_transition.sv) | `Ik Vk Ku Lf Gf` |
| [`ch20/test_elaboration_messages_identify_selected_scope_without_user_formatting`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_elaboration_messages_identify_selected_scope_without_user_formatting.sv) | `Ik Vk Ku Lf Gf` |
| [`ch20/test_global_clock_sampled_functions_evaluate_computed_operands`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_global_clock_sampled_functions_evaluate_computed_operands.sv) | `Ik Vk Ku Lu Gf` |
| [`ch20/test_stacktrace_resumed_task_context`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_stacktrace_resumed_task_context.sv) | `Ik Vk Kf Lu Gf` |
| [`ch20/test_stacktrace_task_and_function_results`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_stacktrace_task_and_function_results.sv) | `Ik Vk Kf Lu Gf` |
| [`ch23/test_interconnect_single_port_retains_all_local_wired_drivers`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch23/test_interconnect_single_port_retains_all_local_wired_drivers.sv) | `Ik Vk Ku Lu Gf` |
| [`ch23/test_resolved_user_nettype_counts_local_drivers_across_port_merges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch23/test_resolved_user_nettype_counts_local_drivers_across_port_merges.sv) | `Ik Vk Ku Lu Gf` |
| [`ch25/test_illegal_ref_modport_signal_used_as_timing_check_terminal`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch25/test_illegal_ref_modport_signal_used_as_timing_check_terminal.sv) | `Ik Vk Ku Lf Gf` |
| [`ch25/test_illegal_virtual_interface_component_in_always_comb`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch25/test_illegal_virtual_interface_component_in_always_comb.sv) | `Ik Vk Kf L- G-` |
| [`ch28/test_user_nettype_active_low_switch_unknown_turnoff_delay`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch28/test_user_nettype_active_low_switch_unknown_turnoff_delay.sv) | `Ik Vk Ku Lu Gf` |
| [`ch3/test_vpi_per_file_units_iterate_same_named_locals_separately`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch3/test_vpi_per_file_units_iterate_same_named_locals_separately.sv) | `Ik Vk Ku Lu Gf` |
| [`ch30/test_global_pulse_limit_sources`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch30/test_global_pulse_limit_sources.sv) | `Ik Vk Ku L- G-` |
| [`ch31/test_inconsistent_negative_limits_clear_numerically_smallest_limit`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_inconsistent_negative_limits_clear_numerically_smallest_limit.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_inconsistent_negative_timing_recalculates_after_each_relaxation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_inconsistent_negative_timing_recalculates_after_each_relaxation.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_recrem_delayed_condition_roles`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_recrem_delayed_condition_roles.sv) | `Ik Vk Ku L- G-` |
| [`ch31/test_negative_setup_shift_clamps_adjusted_hold_and_warns`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_setup_shift_clamps_adjusted_hold_and_warns.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_setuphold_delayed_condition_roles`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_setuphold_delayed_condition_roles.sv) | `Ik Vk Ku L- G-` |
| [`ch31/test_negative_setuphold_explicit_and_implicit_latches`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_setuphold_explicit_and_implicit_latches.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_setuphold_has_exclusive_window_endpoints`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_setuphold_has_exclusive_window_endpoints.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_setuphold_notifier_tracks_repeated_delayed_edges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_setuphold_notifier_tracks_repeated_delayed_edges.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_timing_adjusts_all_check_categories`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_timing_adjusts_all_check_categories.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_timing_condition_compares_undelayed_input_at_delayed_edge`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_timing_condition_compares_undelayed_input_at_delayed_edge.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_timing_copies_align_setup_and_hold`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_timing_copies_align_setup_and_hold.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_negative_timing_notifiers_follow_delayed_violating_edges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_negative_timing_notifiers_follow_delayed_violating_edges.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_setuphold_and_recrem_shift_the_same_violation_window`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_setuphold_and_recrem_shift_the_same_violation_window.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_setuphold_negative_limits_event_roles_and_conditions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_setuphold_negative_limits_event_roles_and_conditions.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_setuphold_uses_explicit_delayed_reference_for_both_checks`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_setuphold_uses_explicit_delayed_reference_for_both_checks.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_skew_checks_use_undelayed_timing_inputs`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_skew_checks_use_undelayed_timing_inputs.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_specify_output_waits_for_longer_negative_timing_delay`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_specify_output_waits_for_longer_negative_timing_delay.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_timing_condition_can_use_explicit_delayed_reference_value`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_timing_condition_can_use_explicit_delayed_reference_value.sv) | `Ik Vk Ku Lf Gf` |
| [`ch31/test_vector_timing_check_expansion`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_vector_timing_check_expansion.sv) | `Ik Vk Ku L- G-` |
| [`ch32/test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_invalid_source_resets_both_driver_delays`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_invalid_source_resets_both_driver_delays.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_keeps_twenty_four_queued_transitions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_keeps_twenty_four_queued_transitions.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_overlaps_parent_and_child_loads`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_overlaps_parent_and_child_loads.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_rejects_reversed_port_directions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_rejects_reversed_port_directions.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_interconnect_uses_trailing_transition_pulse_limits`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_interconnect_uses_trailing_transition_pulse_limits.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_named_log_has_distinct_entries_for_two_paths`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_named_log_has_distinct_entries_for_two_paths.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_task_arguments_override_configuration_scaling`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_task_arguments_override_configuration_scaling.sv) | `Ik Vk Ku Lu Gf` |
| [`ch33/test_config_expansion_forms`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_config_expansion_forms.sv) | `Ik Vk Kf L- G-` |
| [`ch33/test_config_precompiled_cells`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_config_precompiled_cells.sv) | `Ik Vk Kf L- G-` |
| [`ch33/test_config_precompiled_transitive_cells`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_config_precompiled_transitive_cells.sv) | `Ik Vk Kf L- G-` |
| [`ch35/test_dpi_context_task_does_not_authorize_noncontext_child_import`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_context_task_does_not_authorize_noncontext_child_import.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_disabled_import_task_cannot_call_another_export`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_disabled_import_task_cannot_call_another_export.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_import_function_rejects_omitted_acknowledgement`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_import_function_rejects_omitted_acknowledgement.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_import_task_rejects_disable_status_after_normal_return`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_import_task_rejects_disable_status_after_normal_return.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_import_task_rejects_wrong_status_after_disable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_import_task_rejects_wrong_status_after_disable.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_imported_function_cannot_enable_untimed_exported_task`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_imported_function_cannot_enable_untimed_exported_task.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_dpi_legacy_source_layout`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_legacy_source_layout.sv) | `Ik Vk Ku L- G-` |
| [`ch35/test_dpi_nested_noncontext_call_cannot_inherit_export_permission`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_dpi_nested_noncontext_call_cannot_inherit_export_permission.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_illegal_dpi_version_mismatch_across_package_and_module`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_illegal_dpi_version_mismatch_across_package_and_module.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_illegal_dpi_versions_share_one_c_linkage_identifier`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_illegal_dpi_versions_share_one_c_linkage_identifier.sv) | `Ik Vk Ku Lf Gf` |
| [`ch35/test_legacy_dpi_packed_selects_cross_canonical_word_boundary`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch35/test_legacy_dpi_packed_selects_cross_canonical_word_boundary.sv) | `Ik Vk Ku Lf Gf` |
| [`ch36/test_normative_dated_vpi_edition`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_normative_dated_vpi_edition.sv) | `Ik Vk Ku L- G-` |
| [`ch36/test_vpi_compatibility_mode_uses_null_handle_for_bound_mode`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_compatibility_mode_uses_null_handle_for_bound_mode.sv) | `Ik Vk Ku Lu Gf` |
| [`ch36/test_vpi_host_default_and_compile_bound_modes`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_host_default_and_compile_bound_modes.sv) | `Ik Vk Ku L- G-` |
| [`ch36/test_vpi_host_default_reversed_library_order`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_host_default_reversed_library_order.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_aggregate_nets_do_not_have_whole_values`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_aggregate_nets_do_not_have_whole_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_callback_relationship_arrows`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_callback_relationship_arrows.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_class_definition_and_specialization_value_access_differ`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_class_definition_and_specialization_value_access_differ.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_class_specializations_are_scopes_with_definition_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_class_specializations_are_scopes_with_definition_relations.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_definition_handles_cannot_read_or_write_class_storage`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_definition_handles_cannot_read_or_write_class_storage.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_delayed_write_refuses_automatic_variable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_delayed_write_refuses_automatic_variable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_diagram_access`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_diagram_access.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_direct_modport_expression`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_direct_modport_expression.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_dpi_language_and_linkage_name_for_imports_and_exports`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_extended_attribute_owners`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_extended_attribute_owners.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_frame_scope_editions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_frame_scope_editions.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_frame_status_without_vpi_valid`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_frame_status_without_vpi_valid.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_get_value_classifies_assignment_and_builtin_side_effects`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_get_value_classifies_assignment_and_builtin_side_effects.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_indexed_ports_and_input_delays`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_indexed_ports_and_input_delays.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_inline_member_typespec_name`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_inline_member_typespec_name.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interconnect_delay_device_one_fanout_branch`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interconnect_delay_device_one_fanout_branch.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interconnect_delay_device_single_load`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interconnect_delay_device_single_load.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interface_and_module_specify_paths_distinguish_legacy_owner`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interface_and_module_specify_paths_distinguish_legacy_owner.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interface_formal_rejects_get_and_put_delays`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interface_formal_rejects_get_and_put_delays.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interface_ownership`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interface_ownership.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_interface_specify_paths_keep_interface_owner`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interface_specify_paths_keep_interface_owner.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_legacy_array_property_on_named_event_elements`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_legacy_array_property_on_named_event_elements.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_legacy_array_property_on_net_elements`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_legacy_array_property_on_net_elements.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_legacy_array_property_on_variable_elements`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_legacy_array_property_on_variable_elements.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_net_bit_loads_follow_plain_continuous_assignment`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_net_bit_loads_follow_plain_continuous_assignment.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_net_bit_loads_follow_reordered_continuous_assignment`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_net_bit_loads_follow_reordered_continuous_assignment.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_other_transient_objects`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_other_transient_objects.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_part_select_uses_distinct_bound_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_part_select_uses_distinct_bound_relations.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_pattern_constraint_properties`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_pattern_constraint_properties.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_port_bit_excludes_name_and_port_index`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_port_bit_excludes_name_and_port_index.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_program_array_interface_port_relation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_program_array_interface_port_relation.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_program_scalar_interface_port_relation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_program_scalar_interface_port_relation.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_property_variables_expose_declarations_without_values`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_property_variables_expose_declarations_without_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_put_rejects_hidden_side_effects_in_index_calls`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_put_rejects_hidden_side_effects_in_index_calls.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_put_value_rejects_side_effect_in_bit_select_index`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_put_value_rejects_side_effect_in_bit_select_index.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_ref_port_simple_expression_use`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_ref_port_simple_expression_use.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_restart_releases_previous_handles`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_restart_releases_previous_handles.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_sdf_delay_device_and_terminal_type_names`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_sdf_delay_device_and_terminal_type_names.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_simulated_net_is_shared_across_interconnect_merges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_simulated_net_is_shared_across_interconnect_merges.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_size_query_preserves_side_effecting_string_call`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_size_query_preserves_side_effecting_string_call.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_static_part_select_rejects_ambiguous_expression`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_static_part_select_rejects_ambiguous_expression.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_task_reference_parent`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_task_reference_parent.sv) | `Ik Vk Ku L- G-` |
| [`ch37/test_vpi_typespec_handles_allow_static_storage_only`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_typespec_handles_allow_static_storage_only.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_unpacked_aggregates_only_expose_member_values`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_unpacked_aggregates_only_expose_member_values.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_unpacked_structure_rejects_whole_value_access`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_unpacked_structure_rejects_whole_value_access.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_unpacked_union_rejects_whole_value_access`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_unpacked_union_rejects_whole_value_access.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_value_change_callback_refuses_automatic_variable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_value_change_callback_refuses_automatic_variable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_action_error_callback_information`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_action_error_callback_information.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_bulk_array_checks_element_type_and_storage_lifetime`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_bulk_array_checks_element_type_and_storage_lifetime.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_checkpoint_location_is_available_in_each_action_callback`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_checkpoint_location_is_available_in_each_action_callback.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_class_reclaim_lifetimes`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_class_reclaim_lifetimes.sv) | `Ik Vk Ku L- G-` |
| [`ch38/test_vpi_control_scope_change_reports_selected_instance`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_control_scope_change_reports_selected_instance.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_direct_reset_brackets_time_zero_restoration`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_direct_reset_brackets_time_zero_restoration.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_end_of_frame_or_thread_object_reports_no_time`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_end_of_frame_or_thread_object_reports_no_time.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_end_save_data_is_available_at_start_of_restart`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_end_save_data_is_available_at_start_of_restart.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_feature_callbacks_bracket_state_restore`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_feature_callbacks_bracket_state_restore.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_flush_exposes_live_console_and_current_log_bytes`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_flush_exposes_live_console_and_current_log_bytes.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_force_and_release_concatenated_net_selections_and_variable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_force_and_release_concatenated_net_selections_and_variable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_force_release_rejects_variable_and_user_nettype_selections`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_force_release_rejects_variable_and_user_nettype_selections.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_force_release_whole_resolved_user_nettype`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_force_release_whole_resolved_user_nettype.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_printf_reports_formatted_length_and_encoding_error`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_printf_reports_formatted_length_and_encoding_error.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_protected_access_controls`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_protected_access_controls.sv) | `Ik Vk Ku L- G-` |
| [`ch38/test_vpi_protected_statement_callbacks`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_protected_statement_callbacks.sv) | `Ik Vk Ku L- G-` |
| [`ch38/test_vpi_put_data_counts_at_end_of_save`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_put_data_counts_at_end_of_save.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_put_data_counts_at_start_of_save`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_put_data_counts_at_start_of_save.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_put_value_rejects_gate_and_combinational_udp_instances`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_put_value_rejects_gate_and_combinational_udp_instances.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_put_value_rejects_user_nettype_subelement`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_put_value_rejects_user_nettype_subelement.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_refuses_force_release_disable_callbacks_on_variable_bits`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_refuses_force_release_disable_callbacks_on_variable_bits.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_removed_timer_callback_disappears_from_iteration`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_removed_timer_callback_disappears_from_iteration.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_removed_value_callback_disappears_from_iteration`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_removed_value_callback_disappears_from_iteration.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_reset_defers_until_return_and_restores_initial_state`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_reset_defers_until_return_and_restores_initial_state.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_restart_preserves_restart_callbacks_and_drops_value_change`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_restart_preserves_restart_callbacks_and_drops_value_change.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_restart_stream_warns_and_zero_fills_a_short_read`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_restart_stream_warns_and_zero_fills_a_short_read.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_save_restart_reads_interleaved_streams_in_new_chunks`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_save_restart_reads_interleaved_streams_in_new_chunks.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_scalar_callbacks_keep_high_and_low_strength_states`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_scalar_callbacks_keep_high_and_low_strength_states.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_time_callback_reentrant_start_stays_before_active_events`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_time_callback_reentrant_start_stays_before_active_events.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_unresolved_task_callback_supplies_called_name`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_unresolved_task_callback_supplies_called_name.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_value_change_traces_expression_primitive_terminal_and_net`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_value_change_traces_expression_primitive_terminal_and_net.sv) | `Ik Vk Ku Lu Gf` |
| [`ch38/test_vpi_vector_callback_storage_survives_get_value_until_return`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_vector_callback_storage_survives_get_value_until_return.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_control_rejects_property_and_sequence_instance_handles`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch39/test_vpi_assertion_control_rejects_property_and_sequence_instance_handles.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch39/test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_initialization_callback_guards_controls`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch39/test_vpi_assertion_initialization_callback_guards_controls.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_system_fail_action_controls_respect_scope`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch39/test_vpi_assertion_system_fail_action_controls_respect_scope.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_system_notifications_follow_lifecycle`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch39/test_vpi_assertion_system_notifications_follow_lifecycle.sv) | `Ik Vk Ku Lu Gf` |
| [`ch4/test_pli_region_controls_assertion_fail`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch4/test_pli_region_controls_assertion_fail.sv) | `Ik Vk Ku L- G-` |
| [`ch4/test_pli_region_controls_assertion_pass`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch4/test_pli_region_controls_assertion_pass.sv) | `Ik Vk Ku L- G-` |
| [`ch40/test_vpi_covered_count_assertion_successes`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch40/test_vpi_covered_count_assertion_successes.sv) | `Ik Vk Ku Lu Gf` |
| [`ch6/test_scalared_net_vpi_expansion`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch6/test_scalared_net_vpi_expansion.sv) | `Ik Vk Ku Lu Gf` |
| [`ch7/test_associative_event_key_identity`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch7/test_associative_event_key_identity.sv) | `Ik Vk Ku L- G-` |
| [`ch8/test_weak_reference_reclamation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch8/test_weak_reference_reclamation.sv) | `Ik Vk Ku L- G-` |
| [`ch9/test_await_resumes_after_normal_and_forced_exit_then_rejects_self`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch9/test_await_resumes_after_normal_and_forced_exit_then_rejects_self.sv) | `Ik Vk Ku Lf Gf` |
| [`ch9/test_process_await_rejects_current_process`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch9/test_process_await_rejects_current_process.sv) | `Ik Vk Ku Lf Gf` |
| [`ch9/test_process_control_target_origins`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch9/test_process_control_target_origins.sv) | `Ik Vk Ku L- G-` |
| [`ch9/test_process_function_cannot_suspend_current_process`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch9/test_process_function_cannot_suspend_current_process.sv) | `Ik Vk Ku Lf Gf` |

## Release oracle, failing on both Ghost and Lyra

| Test | Results |
| --- | --- |
| [`ch21/test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch21/test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds.sv) | `Ip Vk Kf Lf Gf` |
| [`ch21/test_readmem_stops_at_address_outside_selected_slice_without_resuming`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch21/test_readmem_stops_at_address_outside_selected_slice_without_resuming.sv) | `Ip Vk Kf Lf Gf` |
| [`ch26/test_package_wildcard_binding_across_functions`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch26/test_package_wildcard_binding_across_functions.sv) | `Ip Vp Kf Lf Gf` |
| [`ch26/test_wildcard_reference_in_generate_binds_name_in_enclosing_scope`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch26/test_wildcard_reference_in_generate_binds_name_in_enclosing_scope.sv) | `Ip Vp Kf Lf Gf` |
| [`ch28/test_illegal_resistive_pass_switch_vector_terminals`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch28/test_illegal_resistive_pass_switch_vector_terminals.sv) | `Ip Vk Ku Lf Gf` |
| [`ch30/test_specify_path_delay_preserves_large_integral_tick`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch30/test_specify_path_delay_preserves_large_integral_tick.sv) | `Ip Vk Kp Lf Gf` |
| [`ch5/test_tool_system_function_raw_simulation_time`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch5/test_tool_system_function_raw_simulation_time.sv) | `Ip Vk Kf Lf Gf` |
| [`ch6/test_vectored_bit_select_when_permitted`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch6/test_vectored_bit_select_when_permitted.sv) | `Ip Vp Kf Lf Gf` |
| [`ch6/test_vectored_part_select_when_permitted`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch6/test_vectored_part_select_when_permitted.sv) | `Ip Vp Kf Lf Gf` |

## Clauses whose citing tests are all spec only

| Clause | Citing tests |
| --- | ---: |
| 4.4.3.1 | 2 |
| 4.4.3.5 | 2 |
| 4.4.3.6 | 2 |
| 4.4.3.7 | 2 |
| 4.4.3.8 | 2 |
| 12.4.2.2 | 2 |
| 12.5.3.2 | 2 |
| 16.4.5 | 2 |
| 16.12.20 | 2 |
| 16.14.6.3 | 2 |
| 17.4 | 2 |
| 17.9 | 2 |
| 19.6.1.1 | 2 |
| 20.12 | 2 |
| 21.7.3.7 | 2 |
| 21.7.4.3.2 | 2 |
| 25.3.2 | 2 |
| 30.7.3 | 2 |
| 32.2 | 2 |
| 33.5.3 | 2 |
| 33.5.4 | 2 |
| 33.6.1 | 2 |
| 33.8.1 | 2 |
| 34.5.1.1 | 2 |
| 34.5.2.1 | 2 |
| 34.5.2.2 | 2 |
| 34.5.5.1 | 2 |
| 34.5.6.1 | 2 |
| 34.5.7.1 | 2 |
| 34.5.7.2 | 2 |
| 34.5.8.1 | 2 |
| 34.5.9.1 | 2 |
| 34.5.10.1 | 2 |
| 34.5.11.1 | 2 |
| 34.5.12.1 | 2 |
| 34.5.13.1 | 2 |
| 34.5.14.1 | 2 |
| 34.5.15.1 | 2 |
| 34.5.16.1 | 2 |
| 34.5.17.1 | 2 |
| 34.5.18.1 | 2 |
| 34.5.19.1 | 2 |
| 34.5.20.1 | 2 |
| 34.5.21.1 | 2 |
| 34.5.22.1 | 2 |
| 34.5.23.1 | 2 |
| 34.5.24.1 | 2 |
| 34.5.25.1 | 2 |
| 34.5.26.1 | 2 |
| 34.5.27.1 | 2 |
| 34.5.28.1 | 2 |
| 34.5.29.1 | 2 |
| 34.5.30.1 | 2 |
| 34.5.31.1 | 2 |
| 34.5.31.2 | 2 |
| 34.5.32.1 | 2 |
| 35.5.1.5 | 2 |
| 36.10.3 | 2 |
| 36.12.2.2 | 2 |
| 37.4.1 | 2 |
| 37.69 | 2 |
| 37.79 | 2 |
| 39.4.2.1 | 2 |
| 39.5.3 | 2 |
| 6.6.4.1 | 3 |
| 6.6.4.2 | 3 |
| 9.4.4 | 3 |
| 16.13.7 | 3 |
| 16.14.6.2 | 3 |
| 16.14.6.4 | 3 |
| 19.6.3 | 3 |
| 21.7.3.2 | 3 |
| 21.7.3.3 | 3 |
| 22.11.1 | 3 |
| 23.3.3.7.2 | 3 |
| 30.7.4.2 | 3 |
| 31.8 | 3 |
| 36.10.1 | 3 |
| 37.7 | 3 |
| 37.8 | 3 |
| 37.38 | 3 |
| 37.45 | 3 |
| 37.55 | 3 |
| 37.56 | 3 |
| 37.62 | 3 |
| 37.65 | 3 |
| 37.70 | 3 |
| 37.73 | 3 |
| 37.76 | 3 |
| 37.77 | 3 |
| 37.78 | 3 |
| 37.82 | 3 |
| 37.84 | 3 |
| 40.2.1 | 3 |
| 40.5.3 | 3 |
| 6.7.2 | 4 |
| 8.30.2 | 4 |
| 12.6.3 | 4 |
| 16.4.3 | 4 |
| 16.12.5 | 4 |
| 19.6.1.3 | 4 |
| 19.6.2 | 4 |
| 21.7.3.4 | 4 |
| 21.7.3.5 | 4 |
| 21.7.3.6.1 | 4 |
| 28.16.2.1 | 4 |
| 28.16.2.2 | 4 |
| 32.4.3 | 4 |
| 33.3.1.1 | 4 |
| 33.3.2 | 4 |
| 37.18 | 4 |
| 37.19 | 4 |
| 37.21 | 4 |
| 37.23 | 4 |
| 37.30 | 4 |
| 37.57 | 4 |
| 37.66 | 4 |
| 37.71 | 4 |
| 37.74 | 4 |
| 38.7 | 4 |
| 38.36.1.3 | 4 |
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
| 31.9.3 | 5 |
| 33.4.2 | 5 |
| 37.3.6 | 5 |
| 37.24 | 5 |
| 37.48 | 5 |
| 37.54 | 5 |
| 37.58 | 5 |
| 37.60 | 5 |
| 37.67 | 5 |
| 37.68 | 5 |
| 37.80 | 5 |
| 37.81 | 5 |
| 4.4.2.5 | 6 |
| 6.7.3 | 6 |
| 7.9.8 | 6 |
| 16.9.1 | 6 |
| 16.9.5 | 6 |
| 16.9.7 | 6 |
| 16.9.8 | 6 |
| 16.13.2 | 6 |
| 20.16.2 | 6 |
| 20.16.4 | 6 |
| 24.6 | 6 |
| 31.4.5 | 6 |
| 36.8.1 | 6 |
| 37.9 | 6 |
| 37.49 | 6 |
| 37.50 | 6 |
| 37.63 | 6 |
| 37.72 | 6 |
| 37.75 | 6 |
| 38.9 | 6 |
| 39.3.2 | 6 |
| 8.30.5 | 7 |
| 15.5.4 | 7 |
| 16.9.11 | 7 |
| 16.12.19 | 7 |
| 16.12.22 | 7 |
| 16.14.6.1 | 7 |
| 20.16.1 | 7 |
| 25.7.4 | 7 |
| 28.15.2 | 7 |
| 30.7.4.1 | 7 |
| 31.4.1 | 7 |
| 37.3.8 | 7 |
| 37.34 | 7 |
| 37.53 | 7 |
| 37.61 | 7 |
| 37.64 | 7 |
| 37.83 | 7 |
| 38.36.1.2 | 7 |
| 8.30.3 | 8 |
| 8.30.4 | 8 |
| 12.4.2.1 | 8 |
| 19.5.5 | 8 |
| 19.5.7 | 8 |
| 31.4.2 | 8 |
| 32.4.2 | 8 |
| 37.3.4 | 8 |
| 37.29 | 8 |
| 37.36 | 8 |
| 38.36.1.1 | 8 |
| 12.6.2 | 9 |
| 16.9.6 | 9 |
| 19.5.1.1 | 9 |
| 31.3.5 | 9 |
| 31.7 | 9 |
| 37.6 | 9 |
| 37.15 | 9 |
| 37.22 | 9 |
| 37.46 | 9 |
| 37.51 | 9 |
| 37.52 | 9 |
| 8.30.1 | 10 |
| 16.12.13 | 10 |
| 19.5.6 | 10 |
| 20.16.3 | 10 |
| 37.13 | 10 |
| 16.13.1 | 11 |
| 25.6 | 11 |
| 37.20 | 11 |
| 37.26 | 11 |
| 37.40 | 11 |
| 37.41 | 11 |
| 39.4.1 | 11 |
| 12.6.1 | 12 |
| 16.12.10 | 12 |
| 16.17 | 12 |
| 19.11.3 | 12 |
| 21.7.4.1 | 12 |
| 23.3.3.7.1 | 12 |
| 39.3.1 | 12 |
| 16.9.2.1 | 13 |
| 19.4.1 | 13 |
| 40.5.2 | 13 |
| 37.25 | 14 |
| 37.44 | 14 |
| 39.5.1 | 14 |
| 16.12.17 | 15 |
| 37.59 | 15 |
| 21.7.3.1 | 16 |
| 40.2.2 | 16 |
| 40.3.2.2 | 16 |
| 17.7.2 | 17 |
| 36.12.1 | 17 |
| 37.33 | 17 |
| 37.47 | 17 |
| 39.5.2 | 17 |
| 11.9 | 18 |
| 37.32 | 18 |
| 7.3.2 | 19 |
| 31.3.2 | 19 |
| 37.31 | 19 |
| 16.11 | 20 |
| 36.12.2.1 | 21 |
| 31.3.1 | 22 |
| 37.11 | 22 |
| 40.3.2.3 | 22 |
| 16.8.2 | 27 |
| 37.35 | 29 |
| 6.6.8 | 30 |
| 40.3.2.1 | 33 |
| 15.5.5.3 | 54 |

## Tests with contested readings

The tests of the [ledger of contested readings](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/docs/interpretation-splits.en.md), listed apart; they stay in the candidates above and no count changes.

| Test | Kind | Status | Results |
| --- | --- | --- | --- |
| [`ch11/test_equality_class_interface_chandle_handles`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_equality_class_interface_chandle_handles.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch11/test_illegal_stream_with_on_two_dimensional_array`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch11/test_illegal_stream_with_on_two_dimensional_array.sv) | `contested` | `unresolved` | `Ip Vp Ku Lf Gp` |
| [`ch16/test_first_match_items_and_boolean_or`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_first_match_items_and_boolean_or.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_consecutive_repetition`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_sequence_consecutive_repetition.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_empty_match_concatenation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_sequence_empty_match_concatenation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_empty_match_fusion`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_sequence_empty_match_fusion.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_local_formal_assignment`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch16/test_sequence_local_formal_assignment.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch17/test_checker_assertion_placement`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch17/test_checker_assertion_placement.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch18/test_inline_local_scope_binding`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch18/test_inline_local_scope_binding.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch18/test_rand_mode_inactive_handle`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch18/test_rand_mode_inactive_handle.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch18/test_randomize_callback_override`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch18/test_randomize_callback_override.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch19/test_cg_four_state_literal_wildcard_enum`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch19/test_cg_four_state_literal_wildcard_enum.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`ch19/test_cg_option_levels_readback`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch19/test_cg_option_levels_readback.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch20/test_pla_all_forms`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_pla_all_forms.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch20/test_pla_sync_snapshot_versus_async_update`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch20/test_pla_sync_snapshot_versus_async_update.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch21/test_fwrite_unformatted_aggregates`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch21/test_fwrite_unformatted_aggregates.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch21/test_illegal_value_plusargs_bad_format`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch21/test_illegal_value_plusargs_bad_format.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch22/test_illegal_include_absolute_path_in_angle_brackets`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch22/test_illegal_include_absolute_path_in_angle_brackets.sv) | `contested` | `unresolved` | `Ip Vk Kf Lf Gp` |
| [`ch23/test_defparam_block_task_function_parameters`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch23/test_defparam_block_task_function_parameters.sv) | `contested` | `unresolved` | `If Vk Kf Lf Gp` |
| [`ch23/test_port_collapse_uwire_external_delay`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch23/test_port_collapse_uwire_external_delay.sv) | `contested` | `unresolved` | `Ik Vp Kf Lf Gp` |
| [`ch30/test_illegal_specify_edge_path_same_edge_and_condition`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch30/test_illegal_specify_edge_path_same_edge_and_condition.sv) | `contested` | `unresolved` | `Ip Vk Ku Lf Gp` |
| [`ch31/test_illegal_setuphold_negative_sum`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_illegal_setuphold_negative_sum.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch31/test_illegal_timing_condition_two_signals`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_illegal_timing_condition_two_signals.sv) | `contested` | `unresolved` | `Ip Vk Ku Lf Gp` |
| [`ch31/test_timing_check_condition_x`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch31/test_timing_check_condition_x.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch32/test_sdf_scale_type_members`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch32/test_sdf_scale_type_members.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch33/test_config_cell_parameter`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_config_cell_parameter.sv) | `contested` | `unresolved` | `Ik Vk Kp Lf Gp` |
| [`ch33/test_duplicate_cell_last_definition_wins`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch33/test_duplicate_cell_last_definition_wins.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`ch36/test_vpi_chk_error_callbacks`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_chk_error_callbacks.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compatibility_1800v2017_mode`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_compatibility_1800v2017_mode.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compatibility_1800v2023_mode`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_compatibility_1800v2023_mode.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compiletf_sizetf`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch36/test_vpi_compiletf_sizetf.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_atomic_task_call_label`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_atomic_task_call_label.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_attribute_value_types`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_attribute_value_types.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_class_relations_scope_typespec`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_class_relations_scope_typespec.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_cont_assign_bits_delays`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_cont_assign_bits_delays.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_generate_nettype_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_generate_nettype_typedef.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_interconnect_array_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interconnect_array_ranges.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_interface_and_module_specify_paths_distinguish_legacy_owner`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interface_and_module_specify_paths_distinguish_legacy_owner.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_interface_specify_paths_keep_interface_owner`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_interface_specify_paths_keep_interface_owner.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_iterator_objects`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_iterator_objects.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_module_paths`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_module_paths.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_named_event_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_named_event_relations.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_named_events`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_named_events.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_net_driver_objects`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_net_driver_objects.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_alias_chain_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_nettype_alias_chain_relations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_declarations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_nettype_declarations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_net_parts`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_nettype_net_parts.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_nettype_relations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_prefix_allocation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_prefix_allocation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_program_array_interface_port_relation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_program_array_interface_port_relation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_program_interface_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_program_interface_relations.sv) | `contested` | `resolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_program_scalar_interface_port_relation`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_program_scalar_interface_port_relation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_property_operator_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_property_operator_kinds.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_select_objects_event_arrays`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_select_objects_event_arrays.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_size_change_callback`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_size_change_callback.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_statement_control_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_statement_control_kinds.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_tf_call_kinds_relations`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_tf_call_kinds_relations.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_unbounded_const_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch37/test_vpi_unbounded_const_ranges.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_error_callback_runtime_errors`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_error_callback_runtime_errors.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_get_value_array`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_get_value_array.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_get_value_real_conversion`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_get_value_real_conversion.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_mcd_open_reuse`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_mcd_open_reuse.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_value_change_event`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch38/test_vpi_value_change_event.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch39/test_vpi_assertion_reset_restores_initial_state`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch39/test_vpi_assertion_reset_restores_initial_state.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_coverage_control_package_scope`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch40/test_coverage_control_package_scope.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_coverage_fsm_next_state_pragmas`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch40/test_coverage_fsm_next_state_pragmas.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_vpi_coverage_save_merge`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch40/test_vpi_coverage_save_merge.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch6/test_a2_1_3_interconnect_declaration_identifiers`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch6/test_a2_1_3_interconnect_declaration_identifiers.sv) | `contested` | `unresolved` | `Ik Vk Kf Lu Gp` |
| [`ch6/test_builtin_net_declaration_forms`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch6/test_builtin_net_declaration_forms.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch7/test_array_ordering_methods_and_index_queries`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch7/test_array_ordering_methods_and_index_queries.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_string_in_untagged_union`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch7/test_illegal_string_in_untagged_union.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_unique_index_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch7/test_illegal_unique_index_without_with_struct_elements.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_unique_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/ch7/test_illegal_unique_without_with_struct_elements.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch21/test_gen_cross_litfmt_fill_b_display_param`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch21/test_gen_cross_litfmt_fill_b_display_param.sv) | `contested` | `unresolved` | `Ip Vp Kp Lf Gp` |
| [`gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65`](https://github.com/kurochan001/kirimasim-tests/blob/1fca5f36c37be669d42975bbd9fea38de70e5e16/tests/gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65.sv) | `contested` | `unresolved` | `Ip Vp Kp Lf Gp` |
