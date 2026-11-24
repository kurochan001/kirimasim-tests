# Review candidates

[日本語](review-candidates.ja.md)

Tests and clauses whose expected results rest least on anything but the reading of the standard, from the latest results of each simulator. A candidate is not a finding: a review against the standard decides. [How the reviews are recorded](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/docs/review-candidates.en.md).

## Results read

| Simulator | Version | Time | Suite commit |
| --- | --- | --- | --- |
| Icarus Verilog | `Icarus Verilog version 14.0 (devel) (s20260301-1283-gaddeab31)` | 2026-11-24T07:22:08Z | `cbbd51a3` |
| Verilator | `Verilator 5.055 devel rev v5.054-373-g9dee5c5f` | 2026-11-24T07:22:08Z | `cbbd51a3` |
| kirimasim | `kirimasim 0.2.1 (commit e93839fdcbea), built with GNU 13.3.0` | 2026-11-24T07:22:08Z | `cbbd51a3` |
| Lyra | `Lyra (commit 3a8b6c77f2a9)` | 2026-11-24T07:22:08Z | `cbbd51a3` |
| Ghost | `private build ddc1a7154d2d` | 2026-11-24T07:22:08Z | `cbbd51a3` |

## Counts

| Candidate | Number |
| --- | ---: |
| Spec only, failing on Ghost, kirimasim and Lyra | 0 |
| Spec only, passing on kirimasim alone | 0 |
| Other spec-only tests passing nowhere | 0 |
| Release oracle, failing on both Ghost and Lyra | 1 |
| Clauses whose citing tests are all spec only | 210 |
| Tests with contested readings | 78 |

Results: I Icarus Verilog, V Verilator, K kirimasim, L Lyra, G Ghost; p pass, f fail, u unsupported, k known, - not run.

## Spec only, failing on Ghost, kirimasim and Lyra

None.

## Spec only, passing on kirimasim alone

None.

## Other spec-only tests passing nowhere

None.

## Release oracle, failing on both Ghost and Lyra

| Test | Results |
| --- | --- |
| [`ch26/test_package_wildcard_binding_across_functions`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch26/test_package_wildcard_binding_across_functions.sv) | `Ip Vp Kf Lf Gf` |

## Clauses whose citing tests are all spec only

| Clause | Citing tests |
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
| 21.7.3.7 | 2 |
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
| 37.56 | 2 |
| 37.69 | 2 |
| 37.79 | 2 |
| 39.4.2.1 | 2 |
| 39.5.3 | 2 |
| 40.2.1 | 2 |
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
| 21.7.3.3 | 3 |
| 21.7.3.4 | 3 |
| 21.7.4.2 | 3 |
| 23.3.3.7.2 | 3 |
| 30.7.4.2 | 3 |
| 36.10.1 | 3 |
| 37.3.2 | 3 |
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
| 6.22.6 | 4 |
| 8.30.3 | 4 |
| 8.30.5 | 4 |
| 12.6.3 | 4 |
| 16.4.3 | 4 |
| 16.12.5 | 4 |
| 19.6.1.3 | 4 |
| 19.6.2 | 4 |
| 19.9 | 4 |
| 21.7.3.5 | 4 |
| 25.6 | 4 |
| 28.16.2.1 | 4 |
| 32.4.3 | 4 |
| 37.3.6 | 4 |
| 37.3.8 | 4 |
| 37.18 | 4 |
| 37.19 | 4 |
| 37.21 | 4 |
| 37.23 | 4 |
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
| 37.24 | 5 |
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
| 16.9.1 | 6 |
| 16.9.5 | 6 |
| 16.9.7 | 6 |
| 16.9.8 | 6 |
| 19.5.7 | 6 |
| 20.16.1 | 6 |
| 20.16.2 | 6 |
| 20.16.4 | 6 |
| 21.7.4.1 | 6 |
| 24.6 | 6 |
| 25.7.4 | 6 |
| 31.4.1 | 6 |
| 31.4.5 | 6 |
| 36.8.1 | 6 |
| 37.6 | 6 |
| 37.34 | 6 |
| 37.36 | 6 |
| 37.49 | 6 |
| 37.53 | 6 |
| 37.63 | 6 |
| 37.75 | 6 |
| 37.83 | 6 |
| 12.6.2 | 7 |
| 15.5.4 | 7 |
| 16.12.19 | 7 |
| 16.12.22 | 7 |
| 16.14.6.1 | 7 |
| 28.15.2 | 7 |
| 30.7.4.1 | 7 |
| 31.4.2 | 7 |
| 37.3.4 | 7 |
| 37.15 | 7 |
| 37.26 | 7 |
| 37.29 | 7 |
| 37.44 | 7 |
| 37.61 | 7 |
| 37.64 | 7 |
| 38.36.1.1 | 7 |
| 38.36.1.2 | 7 |
| 19.5.1.1 | 8 |
| 19.5.5 | 8 |
| 19.5.6 | 8 |
| 23.3.3.7.1 | 8 |
| 32.4.2 | 8 |
| 37.22 | 8 |
| 37.40 | 8 |
| 37.51 | 8 |
| 37.52 | 8 |
| 40.5.2 | 8 |
| 16.9.6 | 9 |
| 16.13.1 | 9 |
| 17.7.2 | 9 |
| 31.3.5 | 9 |
| 31.7 | 9 |
| 37.41 | 9 |
| 39.5.1 | 9 |
| 12.6.1 | 10 |
| 16.12.13 | 10 |
| 20.16.3 | 10 |
| 37.13 | 10 |
| 37.20 | 10 |
| 39.3.1 | 10 |
| 19.4.1 | 11 |
| 37.59 | 11 |
| 16.12.10 | 12 |
| 16.17 | 12 |
| 19.11.3 | 12 |
| 11.9 | 13 |
| 16.9.2.1 | 13 |
| 21.7.3.1 | 13 |
| 36.12.1 | 13 |
| 37.25 | 13 |
| 7.3.2 | 14 |
| 39.5.2 | 14 |
| 40.2.2 | 14 |
| 16.12.17 | 15 |
| 37.32 | 15 |
| 37.33 | 15 |
| 37.47 | 15 |
| 37.31 | 16 |
| 40.3.2.2 | 16 |
| 31.3.2 | 17 |
| 36.12.2.1 | 17 |
| 16.11 | 20 |
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

## Tests with contested readings

The tests of the [ledger of contested readings](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/docs/interpretation-splits.en.md), listed apart; they stay in the candidates above and no count changes.

| Test | Kind | Status | Results |
| --- | --- | --- | --- |
| [`ch11/test_equality_class_interface_chandle_handles`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch11/test_equality_class_interface_chandle_handles.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch11/test_illegal_stream_with_on_two_dimensional_array`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch11/test_illegal_stream_with_on_two_dimensional_array.sv) | `contested` | `unresolved` | `Ip Vp Ku Lf Gp` |
| [`ch16/test_first_match_items_and_boolean_or`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch16/test_first_match_items_and_boolean_or.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_consecutive_repetition`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch16/test_sequence_consecutive_repetition.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_empty_match_concatenation`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch16/test_sequence_empty_match_concatenation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_empty_match_fusion`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch16/test_sequence_empty_match_fusion.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch16/test_sequence_local_formal_assignment`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch16/test_sequence_local_formal_assignment.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch17/test_checker_assertion_placement`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch17/test_checker_assertion_placement.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch18/test_inline_local_scope_binding`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch18/test_inline_local_scope_binding.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch18/test_rand_mode_inactive_handle`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch18/test_rand_mode_inactive_handle.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch18/test_randomize_callback_override`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch18/test_randomize_callback_override.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch19/test_cg_four_state_literal_wildcard_enum`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch19/test_cg_four_state_literal_wildcard_enum.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`ch19/test_cg_option_levels_readback`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch19/test_cg_option_levels_readback.sv) | `contested` | `unresolved` | `Ik Vk Ku Lp Gp` |
| [`ch20/test_pla_all_forms`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch20/test_pla_all_forms.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch20/test_pla_sync_snapshot_versus_async_update`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch20/test_pla_sync_snapshot_versus_async_update.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch21/test_fwrite_unformatted_aggregates`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch21/test_fwrite_unformatted_aggregates.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch21/test_illegal_value_plusargs_bad_format`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch21/test_illegal_value_plusargs_bad_format.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch22/test_illegal_include_absolute_path_in_angle_brackets`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch22/test_illegal_include_absolute_path_in_angle_brackets.sv) | `contested` | `unresolved` | `Ip Vk Kf Lf Gp` |
| [`ch23/test_defparam_block_task_function_parameters`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch23/test_defparam_block_task_function_parameters.sv) | `contested` | `unresolved` | `If Vk Kf Lf Gp` |
| [`ch23/test_port_collapse_uwire_external_delay`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch23/test_port_collapse_uwire_external_delay.sv) | `contested` | `unresolved` | `Ik Vp Kf Lf Gp` |
| [`ch30/test_illegal_specify_edge_path_same_edge_and_condition`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch30/test_illegal_specify_edge_path_same_edge_and_condition.sv) | `contested` | `unresolved` | `Ip Vk Ku Lf Gp` |
| [`ch31/test_illegal_setuphold_negative_sum`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch31/test_illegal_setuphold_negative_sum.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch31/test_illegal_timing_condition_two_signals`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch31/test_illegal_timing_condition_two_signals.sv) | `contested` | `unresolved` | `Ip Vk Ku Lf Gp` |
| [`ch31/test_timing_check_condition_x`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch31/test_timing_check_condition_x.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch32/test_sdf_scale_type_members`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch32/test_sdf_scale_type_members.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch33/test_config_cell_parameter`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch33/test_config_cell_parameter.sv) | `contested` | `unresolved` | `Ik Vk Kp Lf Gp` |
| [`ch33/test_duplicate_cell_last_definition_wins`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch33/test_duplicate_cell_last_definition_wins.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`ch36/test_vpi_chk_error_callbacks`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch36/test_vpi_chk_error_callbacks.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compatibility_1800v2017_mode`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch36/test_vpi_compatibility_1800v2017_mode.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compatibility_1800v2023_mode`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch36/test_vpi_compatibility_1800v2023_mode.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch36/test_vpi_compiletf_sizetf`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch36/test_vpi_compiletf_sizetf.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_atomic_task_call_label`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_atomic_task_call_label.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_attribute_value_types`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_attribute_value_types.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_class_relations_scope_typespec`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_class_relations_scope_typespec.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_cont_assign_bits_delays`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_cont_assign_bits_delays.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_generate_nettype_typedef`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_generate_nettype_typedef.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_interconnect_array_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_interconnect_array_ranges.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_iterator_objects`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_iterator_objects.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_module_paths`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_module_paths.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_named_event_relations`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_named_event_relations.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_named_events`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_named_events.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_net_driver_objects`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_net_driver_objects.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_alias_chain_relations`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_nettype_alias_chain_relations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_declarations`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_nettype_declarations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_net_parts`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_nettype_net_parts.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_nettype_relations`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_nettype_relations.sv) | `standard_gap` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_prefix_allocation`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_prefix_allocation.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_program_interface_relations`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_program_interface_relations.sv) | `contested` | `resolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_property_operator_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_property_operator_kinds.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_select_objects_event_arrays`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_select_objects_event_arrays.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_size_change_callback`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_size_change_callback.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_statement_control_kinds`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_statement_control_kinds.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_tf_call_kinds_relations`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_tf_call_kinds_relations.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch37/test_vpi_unbounded_const_ranges`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch37/test_vpi_unbounded_const_ranges.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_error_callback_runtime_errors`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch38/test_vpi_error_callback_runtime_errors.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_get_value_array`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch38/test_vpi_get_value_array.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_get_value_real_conversion`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch38/test_vpi_get_value_real_conversion.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_mcd_open_reuse`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch38/test_vpi_mcd_open_reuse.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch38/test_vpi_value_change_event`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch38/test_vpi_value_change_event.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch39/test_vpi_assertion_reset_restores_initial_state`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch39/test_vpi_assertion_reset_restores_initial_state.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_coverage_control_package_scope`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch40/test_coverage_control_package_scope.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_coverage_fsm_next_state_pragmas`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch40/test_coverage_fsm_next_state_pragmas.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch40/test_vpi_coverage_save_merge`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch40/test_vpi_coverage_save_merge.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch6/test_a2_1_3_interconnect_declaration_identifiers`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch6/test_a2_1_3_interconnect_declaration_identifiers.sv) | `contested` | `unresolved` | `Ik Vk Kf Lu Gp` |
| [`ch6/test_builtin_net_declaration_forms`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch6/test_builtin_net_declaration_forms.sv) | `contested` | `unresolved` | `Ik Vk Ku Lu Gp` |
| [`ch7/test_array_ordering_methods_and_index_queries`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch7/test_array_ordering_methods_and_index_queries.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_string_in_untagged_union`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch7/test_illegal_string_in_untagged_union.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_unique_index_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch7/test_illegal_unique_index_without_with_struct_elements.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`ch7/test_illegal_unique_without_with_struct_elements`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/ch7/test_illegal_unique_without_with_struct_elements.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal.sv) | `contested` | `unresolved` | `Ik Vk Ku Lf Gp` |
| [`gen/ch21/test_gen_cross_litfmt_fill_b_display_param`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch21/test_gen_cross_litfmt_fill_b_display_param.sv) | `contested` | `unresolved` | `Ip Vp Kp Lf Gp` |
| [`gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped.sv) | `contested` | `unresolved` | `Ik Vk Kf Lf Gp` |
| [`gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65`](https://github.com/kurochan001/kirimasim-tests/blob/cbbd51a3258858ad65d0759ba41cb7d4b44fd540/tests/gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65.sv) | `contested` | `unresolved` | `Ip Vp Kp Lf Gp` |
