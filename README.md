# Nightly results of kirimasim-tests

[English](README.md) / [日本語](README.ja.md)

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. Local runs can also be imported and are marked `local`. A test matches when its output and specified checks agree with the expected result, or an illegal design is rejected with the required diagnostic; see the suite's README for what each status means.

Latest run: 2026-11-14 07:31 UTC, suite commit [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec), 12344 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/43533749064).

## Latest results per simulator

Each row and chapter-table column uses that simulator's most recent recorded run. Dates, suite commits and test counts can differ; older results retain their own dates and are not treated as part of the latest run.

A green workflow does not mean every test passed: [why Differ can remain](https://github.com/kurochan001/kirimasim-tests/blob/aef04b93c6ebe776c598f3a40474eeea1e88dfec/docs/faq.en.md#q11-why-can-nightly-be-green-with-differ-results). Read [status meanings and per-test evidence](https://github.com/kurochan001/kirimasim-tests/blob/aef04b93c6ebe776c598f3a40474eeea1e88dfec/docs/faq.en.md#q9-what-do-match-differ-known-difference-and-unsupported-mean) before comparing totals.

| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-995-g27a70c82) | 2026-11-14 07:31 | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | nightly | 7420 (61.4%) | 7 | 4650 | 0 |
| Verilator | Verilator 5.055 devel rev v5.054-256-gafacb7a6 | 2026-11-14 07:31 | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | nightly | 6843 (56.7%) | 29 | 5205 | 0 |
| kirimasim | kirimasim 0.0.0 (commit c093a2a971ec), built with GNU 13.3.0 | 2026-11-14 07:31 | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | nightly | 9574 (79.3%) | 105 | 0 | 2398 |
| Lyra | Lyra (commit 2f842a92f99c) | 2026-11-14 07:31 | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | nightly | 9868 (81.7%) | 600 | 0 | 1609 |
| Ghost | private build 17224fd34b2f | 2026-11-14 07:31 | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | nightly | 11788 (97.6%) | 289 | 0 | 0 |

Ghost is an unidentified simulator taking part before its public debut. For now, only its test results step out from behind the curtain. Its name, source and build logs remain private; build IDs are executable hashes.

![Tests that match their expected results](charts/overview.svg?v=20261114T073153)

![Share of the tests that match](charts/rate.svg?v=20261114T073153)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Verilator

No longer match (1):

- `ch10/test_illegal_unpacked_concat_with_default_key`: differ — the design was accepted, but it is illegal

### kirimasim

Newly match (10): `ch11/test_precedence_distinguishing_values`, `ch11/test_precedence_logical_conditional_implication_levels`, `ch33/test_config_binding_descends_through_children`, `ch33/test_config_cell_parameter`, `ch33/test_config_hierarchical`, `ch33/test_config_instance_over_cell`, `ch33/test_config_library_cell_and_topmodule_names`, `ch33/test_config_name_disambiguation_config_suffix`, `ch33/test_config_rules_bind_each_instance`, `ch33/test_config_use_config_suffix`

### Lyra

Newly match (4): `ch18/test_rand_mode_inactive_handle`, `ch18/test_randomize_callback_override`, `ch20/test_assertion_control_levels_and_scopes`, `ch23/test_hierarchy_branches_syntax_and_uses`

### Ghost

Newly match (82): `ch10/test_force_release_target_forms`, `ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects`, `ch13/test_ref_static_accepted_actuals`, `ch16/test_assertion_clock_expressions_global_clock`, `ch16/test_assertion_dist_as_inside`, `ch16/test_ch16_sim_bias_no_relaxation`, `ch16/test_ch16_sim_checker_inference`, `ch18/test_constraint_bidirectional_solver`, `ch18/test_constraint_if_else_equivalence`, `ch18/test_randc_solved_first_distribution`, `ch18/test_random_stability_seeding`, `ch18/test_soft_priority_layers`, `ch18/test_solve_before_changes_distribution`, `ch18/test_solve_before_partial_order`, `ch18/test_solve_before_size_handle_prefixes`, `ch18/test_std_randomize_task_locals`, `ch19/test_cg_option_evaluated_at_new`, `ch19/test_cg_real_bin_intervals`, `ch19/test_cg_real_bins_fixed_and_dollar`, `ch19/test_cg_real_bins_tolerance_and_merge`, `ch20/test_assertcontrol_callbacks_selected`, `ch20/test_assertcontrol_callbacks_system`, `ch23/test_23_extra_uwire_dominates`, `ch23/test_23_extra_uwire_warn`, `ch23/test_interconnect_port_inheritance_typeless`, `ch23/test_port_collapse_net_delay`, `ch23/test_port_collapse_supply_cells`, `ch23/test_port_collapse_trireg`, `ch23/test_port_collapse_trireg_and_uwire_cells`, `ch23/test_port_collapse_uwire_external_delay`, `ch23/test_port_collapse_wand_external_delay`, `ch23/test_port_collapse_wand_uwire_warning`, `ch23/test_port_collapse_wire_external_delay`, `ch23/test_port_collapse_wor_external_delay`, `ch23/test_port_collapse_wor_uwire_warning`, `ch24/test_program_assertion_clocked_by_program_variable`, `ch3/test_interface_ports_of_module_program_and_interface`, `ch33/test_vpi_module_binding_properties`, `ch33/test_vpi_module_config_name`, `ch35/test_dpi_import_task_reentrant_wait`, `ch36/test_vpi_compatibility_1800v2017_mode`, `ch36/test_vpi_compatibility_1800v2023_mode`, `ch36/test_vpi_interface_decl_class_current_mode`, `ch36/test_vpi_routines_objects_by_name_index`, `ch36/test_vpi_systf_argument_on_demand`, `ch36/test_vpi_systf_function_types`, `ch36/test_vpi_systf_override_display`, `ch36/test_vpi_systf_override_signed_width`, `ch36/test_vpi_variable_arrays_1800v2005_mode`, `ch36/test_vpi_variable_arrays_1800v2009_mode`, `ch37/test_vpi_class_object_members`, `ch37/test_vpi_class_relations_scope_typespec`, `ch37/test_vpi_class_specialization_members`, `ch37/test_vpi_class_specialization_types`, `ch37/test_vpi_constraint_iteration`, `ch37/test_vpi_constraint_orderings_dists`, `ch37/test_vpi_named_event_waiters_lifetime`, `ch37/test_vpi_struct_union_flags_members`, `ch37/test_vpi_sys_func_call_value_info`, `ch37/test_vpi_type_constants_more`, `ch37/test_vpi_udp_defn_entries`, `ch37/test_vpi_udp_table_primitive`, `ch38/test_vpi_handle_by_multi_index`, `ch38/test_vpi_put_value_udp_array_errors`, `ch38/test_vpi_systf_function_result_kinds`, `ch4/test_pli_slot_entry_regions_run_once`, `ch40/test_vpi_coverage_cover_sequence`, `ch8/test_class_constructor_this_and_super_order`, `gen/ch16/test_gen_cross_assertquery_countones_one_simple_clocked_glitch`, `gen/ch16/test_gen_cross_assertquery_onehot0_xall_final_clocked_glitch`, `gen/ch16/test_gen_cross_deferdis_outer_assert_odd_inverse_before_variable_change`, `gen/ch16/test_gen_cross_deferdis_outer_assert_odd_positive_after_function_change`, `gen/ch16/test_gen_cross_deferdis_outer_assume_even_alternating_before_variable_stable`, `gen/ch16/test_gen_cross_deferdis_outer_assume_even_positive_after_variable_stable`, `gen/ch16/test_gen_cross_deferdis_outer_cover_even_inverse_after_variable_stable`, `gen/ch16/test_gen_cross_deferdis_outer_cover_odd_alternating_before_function_stable`, `gen/ch18/test_gen_cross_randreduce_4_signed_fixed_product_wide_2_fail_sat_fail`, `gen/ch21/test_gen_cross_litfmt_fill_b_display_param`, `gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65`, `gen/ch8/test_gen_cross_scopeclass_gen_for_param_local_static_outer`, `gen/ch8/test_gen_cross_scopeclass_module_local_local_static_none`, `imported/ch10/test_procedural_continuous_assign`

No longer match (2):

- `ch15/test_ipc_classes_extended_shadowed_and_created`: differ — output differs
- `ch39/test_vpi_assertion_system_task_control`: differ — output differs

## By chapter

Cells show matching tests / recorded results, including known and unsupported in the denominator: [8/10 example](https://github.com/kurochan001/kirimasim-tests/blob/aef04b93c6ebe776c598f3a40474eeea1e88dfec/docs/faq.en.md#q12-what-percentage-does-by-chapter-show). This is [not requirement coverage](https://github.com/kurochan001/kirimasim-tests/blob/aef04b93c6ebe776c598f3a40474eeea1e88dfec/docs/faq.en.md#q15-is-the-nightly-match-rate-requirement-coverage).

![Matching tests by chapter](charts/chapters.svg?v=20261114T073153)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg?v=20261114T073153)

![Verilator: results by status](charts/status-verilator.svg?v=20261114T073153)

![kirimasim: results by status](charts/status-kirimasim.svg?v=20261114T073153)

![Lyra: results by status](charts/status-lyra.svg?v=20261114T073153)

![Ghost: results by status](charts/status-ghost.svg?v=20261114T073153)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [2026-11-14 07:31](https://github.com/kurochan001/kirimasim-tests/actions/runs/43533749064) | [`aef04b9`](https://github.com/kurochan001/kirimasim-tests/commit/aef04b93c6ebe776c598f3a40474eeea1e88dfec) | 12344 | 7420 (+53 −0) `14.0 devel 27a70c8` | 6843 (+40 −1) `5.055 devel afacb7a` | 9574 (+82 −0) `c093a2a97` | 9868 (+76 −0) `2f842a92f` | 11788 (+132 −2) `private build 17224fd34b2f` |
| [2026-11-13 06:56](https://github.com/kurochan001/kirimasim-tests/actions/runs/43338039082) | [`67d26cf`](https://github.com/kurochan001/kirimasim-tests/commit/67d26cfdbe3799438b00a2117c56689b0be5f446) | 12272 | 7367 (+7 −0) `14.0 devel c489c3a` | 6804 (+6 −13) `5.055 devel ab558b4` | 9492 (+15 −0) `614332613` | 9792 (+7 −0) | 11658 (+7 −3) `private build ace38e2ddc53` |
| [2026-11-12 08:32](https://github.com/kurochan001/kirimasim-tests/actions/runs/43135452856) | [`68f5ecc`](https://github.com/kurochan001/kirimasim-tests/commit/68f5ecc7507d6157f7944b48aa50c61fcc6fa2e1) | 12262 | 7360 (+17 −0) `14.0 devel 3c970ad` | 6811 (+11 −0) `5.055 devel 12ce860` | 9477 (+17 −0) `cae3134e4` | 9785 (+49 −1) `0d94fc7d2` | 11654 (+46 −1) `private build 909f828b22b0` |
| [2026-11-11 07:32](https://github.com/kurochan001/kirimasim-tests/actions/runs/42928672063) | [`a155aec`](https://github.com/kurochan001/kirimasim-tests/commit/a155aec8d7a87178f5abfa352286105aa5afbb58) | 12268 | 7362 (+1 −1) `14.0 devel bd5af29` | 6813 (+3 −0) `5.055 devel 18c1650` | 9479 | 9759 | 11638 (+2 −3) `private build 8d5097472bdb` |
| [2026-11-10 11:08](https://github.com/kurochan001/kirimasim-tests/actions/runs/42741584464) | [`a155aec`](https://github.com/kurochan001/kirimasim-tests/commit/a155aec8d7a87178f5abfa352286105aa5afbb58) | 12268 | 7362 (+33 −0) | 6810 (+45 −0) `5.055 devel 4ab62c3` | 9479 (+62 −0) `7de185f77` | 9759 (+85 −0) `eaaea0380` | 11639 (+407 −0) `private build edda91f4108d` |
| [2026-11-09 06:18](https://github.com/kurochan001/kirimasim-tests/actions/runs/42532762726) | [`9eab9bf`](https://github.com/kurochan001/kirimasim-tests/commit/9eab9bf2f4316112651e9637bcb03fe555016b95) | 12165 | 7329 (+23 −0) `14.0 devel 3e2189b` | 6765 (+2 −2) `5.055 devel 448e1ab` | 9417 `82b300377` | — | 11232 (+11 −1) `private build b0ba803c6b49` |
| [2026-11-08 18:32](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992) | [`36ba5dd`](https://github.com/kurochan001/kirimasim-tests/commit/36ba5dd11df6c382c8bcfbc1ece5137a536e9fb9) | 12165 | 7306 | 6765 | 9417 | 9674 (+1235 −0) `ed6c62dc8` | 11222 |
| [2026-11-08 12:39](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992) | [`36ba5dd`](https://github.com/kurochan001/kirimasim-tests/commit/36ba5dd11df6c382c8bcfbc1ece5137a536e9fb9) | 12165 | 7306 (+297 −5) `14.0 devel beb32f3` | 6765 (+317 −0) `5.055 devel 423f871` | 9417 (+379 −0) `33cee3fa2` | — | 11222 (+402 −1) `private build 9997c689a2e6` |
| [2026-11-08 06:25](https://github.com/kurochan001/kirimasim-tests/actions/runs/42422374691) | [`89df6e9`](https://github.com/kurochan001/kirimasim-tests/commit/89df6e9b015c88b996199997ff8cfb6eee13c63b) | 11773 | 7014 (+586 −0) `14.0 devel 66f0e8a` | 6448 (+532 −4) `5.055 devel cd99c77` | 9038 (+807 −2) `f029ddd0e` | — | 10821 (+871 −41) `private build c2138e5f3a5c` |
| [2026-11-07 06:16](https://github.com/kurochan001/kirimasim-tests/actions/runs/42313961551) | [`3c3a5ab`](https://github.com/kurochan001/kirimasim-tests/commit/3c3a5ab8cdb179aaa9d38d97990803dbc44f5cd6) | 11028 | 6428 (+19 −7) `14.0 devel 257f08d` | 5920 (+14 −3) `5.055 devel 9d9dd1c` | 8233 (+42 −0) `b279f5627` | — | 9991 (+85 −12) `private build 56cfd9e560f1` |
| [2026-11-06 05:05](https://github.com/kurochan001/kirimasim-tests/actions/runs/42136599265) | [`6732107`](https://github.com/kurochan001/kirimasim-tests/commit/673210797a4e131a47f75524b4662f93de866206) | 10994 | 6417 (+131 −0) `14.0 devel 3b5615f` | 5911 (+77 −1) `5.055 devel ab53e01` | 8191 (+216 −0) `6f5c69841` | 8440 (+225 −2) `3ee7454cc` | 9918 (+126 −1) `private build 63199c0a337a` |
| [2026-11-05 04:44](https://github.com/kurochan001/kirimasim-tests/actions/runs/41941310616) | [`19cd790`](https://github.com/kurochan001/kirimasim-tests/commit/19cd790a5f639348ad67fd63959dce9811d3ab56) | 10778 | 6286 (+36 −0) `14.0 devel 9f26050` | 5835 (+74 −6) `5.055 devel 57bbb29` | 7975 (+107 −0) `50a897dee` | 8217 (+107 −0) `ccfc8aa4f` | 9793 (+92 −0) `private build 3314f9902a64` |
| [2026-11-04 03:25](https://github.com/kurochan001/kirimasim-tests/actions/runs/41743702063) | [`9926160`](https://github.com/kurochan001/kirimasim-tests/commit/9926160a1397f514cdd09f84384392c832de2cc5) | 10672 | 6250 (+6 −0) `14.0 devel 16efc8c` | 5767 (+1 −2) `5.055 devel c0e51ca` | 7868 (+5 −0) `911395591` | 8110 `7c55e9f93` | 9701 (+0 −1) `private build 1c85ee891430` |
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

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.
