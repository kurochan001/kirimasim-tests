# kirimasim-tests の夜間実行結果

[English](README.md) / [日本語](README.ja.md)

[kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) の[夜間ワークフロー](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml)がこのブランチを更新します。毎晩、main ブランチの全テストを各シミュレータで実行し、結果を `history.json` に追加して、以下の図を生成します。ローカル実行の結果も取り込むことができ、`local` と表示します。出力と指定された検査が期待結果に一致する場合、または不正な設計が必要な診断付きで拒否される場合に、テストを「一致」と数えます。各ステータスの意味はスイートの README を参照してください。

最新の実行: 2026-11-03 05:51 UTC、スイートのコミット [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c)、テスト10511件、[ワークフロー実行](https://github.com/kurochan001/kirimasim-tests/actions/runs/41561194045)。

## シミュレータごとの最新結果

各行と章別表の各列には、そのシミュレータの最新の実行記録を使います。実行日時、スイートのコミット、テスト数は異なる場合があります。古い結果の日時はそのまま保持し、最新の実行に含まれる結果としては扱いません。

| シミュレータ | バージョン | 実行 (UTC) | スイート | 取り込み元 | 一致 (pass) | 不一致 (fail) | 既知の差異 (known) | 未対応 (unsupported) |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-802-g61dbc3c2) | 2026-11-03 05:51 | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | nightly | 6208 (60.6%) | 16 | 4019 | 0 |
| Verilator | Verilator 5.055 devel rev v5.054-39-g094b04d7 | 2026-11-03 05:51 | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | nightly | 5702 (55.7%) | 15 | 4526 | 0 |
| kirimasim | kirimasim 0.0.0 (commit f3ea0379a7e5), built with GNU 13.3.0 | 2026-11-03 05:51 | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | nightly | 7703 (75.2%) | 140 | 0 | 2400 |
| Lyra | Lyra (commit 554db457ac73) | 2026-11-03 05:51 | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | nightly | 7948 (77.6%) | 561 | 0 | 1734 |
| Ghost | private build 3499c4a8842c | 2026-11-03 05:51 | [`9064ac9`](https://github.com/kurochan001/kirimasim-tests/commit/9064ac95375dae023c6128b1ef30ac464715009c) | nightly | 9456 (92.3%) | 787 | 0 | 0 |

Ghost は正式公開前に参加している匿名のシミュレータです。現在公開しているのはテスト結果のみです。名称、ソースコード、ビルドログは非公開で、ビルドIDには実行ファイルのハッシュを使用します。

![期待結果に一致するテスト数](charts/overview.ja.svg?v=20261103T055105)

![一致したテストの割合](charts/rate.ja.svg?v=20261103T055105)

## 最新の実行での変化

同じシミュレータの前回実行では一致せず今回は一致したテストと、前回は一致したものの今回は一致しなくなったテストです。スイートに追加されたテストの件数は上の表に示します。

### Verilator

新たに一致（4件）: `ch26/test_illegal_export_named_from_package_not_imported`, `ch26/test_package_explicit_import_hides_wildcard`, `ch26/test_package_export_transitivity`, `ch26/test_package_search_order_cases`

### kirimasim

新たに一致（2件）: `ch8/test_class_cast_forms_null_and_failures`, `ch8/test_class_cast_task_failure_reports_error`

### Lyra

新たに一致（2件）: `ch35/test_35_extra_35_5_3_chain_attribute`, `ch35/test_dpi_context_scope_of_declaration`

一致しなくなったテスト（1件）:

- `ch19/test_cg_sample_time_evaluation`: 不一致 (fail) — error: internal error: mir verify: 'sample' of class 'mon::cg' in unit '$unit__8ceffae85a47acaf', as it leaves its rewrites reaches a call of the library entry 'object_of' (expression 5 of its block) at 2 places, and one run evaluates it at two of them: under a dereference and under a dereference (in unit '$unit__8ceffae85a47acaf')

### Ghost

新たに一致（102件）: `ch11/test_equality_class_interface_chandle_handles`, `ch13/test_call_without_parentheses_subroutine_kinds`, `ch16/test_assume_property_actions`, `ch16/test_cover_property_sequence_counters`, `ch16/test_sequence_and_or_intersect`, `ch16/test_sequence_consecutive_repetition`, `ch16/test_sequence_empty_match_concatenation`, `ch16/test_sequence_expression_forms_and_match_items`, `ch16/test_sequence_formal_arguments`, `ch16/test_sequence_local_formal_arguments`, `ch16/test_sequence_local_formal_copies_and_casts`, `ch16/test_sequence_local_variable_threads_and_merge`, `ch16/test_sequence_local_variables`, `ch16/test_sequence_or_and_local_flow`, `ch16/test_sequence_repetition_and_delay_shorthands`, `ch19/test_cg_coverage_event_kinds`, `ch7/test_array_ordering_methods_and_index_queries`, `gen/ch11/test_gen_combo_packed_parent_runtime_aa_bit_nba`, `gen/ch11/test_gen_combo_packed_parent_runtime_aa_logic_blocking`, `gen/ch11/test_gen_combo_packed_parent_runtime_ad_bit_blocking`, `gen/ch11/test_gen_combo_packed_parent_runtime_ad_logic_nba`, `gen/ch11/test_gen_combo_packed_parent_runtime_da_bit_blocking`, `gen/ch11/test_gen_combo_packed_parent_runtime_da_logic_nba`, `gen/ch11/test_gen_combo_packed_parent_runtime_dd_bit_nba`, `gen/ch11/test_gen_combo_packed_parent_runtime_dd_logic_blocking`, `gen/ch11/test_gen_combo_stream_nested_target_ll`, `gen/ch11/test_gen_combo_stream_nested_target_lr`, `gen/ch11/test_gen_combo_stream_nested_target_rl`, `gen/ch11/test_gen_combo_stream_nested_target_rr`, `gen/ch11/test_gen_cross_compound_shift_w129_b_u_part_shr_width_c8_known`, `gen/ch11/test_gen_cross_compound_shift_w1_b_u_part_ashr_z_c65_z`, `gen/ch11/test_gen_cross_compound_shift_w1_l_s_part_shr_ones_c8_x`, `gen/ch11/test_gen_cross_compound_shift_w32_b_u_part_shl_width_c8_x`, `gen/ch11/test_gen_cross_compound_shift_w33_l_s_part_ashr_last_c8_known`, `gen/ch11/test_gen_cross_compound_shift_w64_b_u_part_shr_x_c8_z`, `gen/ch11/test_gen_cross_compound_shift_w65_b_s_part_shl_zero_c8_x`, `gen/ch11/test_gen_cross_concat_w129_halves_s_s_lb_mu_b_x`, `gen/ch11/test_gen_cross_concat_w129_head_bit_n_u_lb_mu_b_z`, `gen/ch11/test_gen_cross_concat_w2_head_bit_n_u_lb_mu_b_x`, `gen/ch11/test_gen_cross_concat_w2_head_bit_n_u_lb_mu_b_z`, `gen/ch11/test_gen_cross_concat_w32_head_bit_n_u_lb_mu_b_x`, `gen/ch11/test_gen_cross_concat_w32_head_bit_n_u_lb_mu_b_z`, `gen/ch11/test_gen_cross_concat_w32_tail_bit_n_s_bl_mu_b_x`, `gen/ch11/test_gen_cross_concat_w33_halves_s_u_bl_ms_b_z`, `gen/ch11/test_gen_cross_concat_w33_head_bit_n_u_lb_mu_b_z`, `gen/ch11/test_gen_cross_concat_w64_head_bit_n_u_lb_mu_b_x`, `gen/ch11/test_gen_cross_concat_w64_head_bit_s_u_lb_mu_b_z`, `gen/ch11/test_gen_cross_concat_w65_head_bit_n_u_lb_mu_b_x`, `gen/ch11/test_gen_cross_range_w32_w_us_b_rel_tol_bound_z_s`, `gen/ch12/test_gen_cross_caseinside_w129_n_su_b_array_known_uv`, `gen/ch12/test_gen_cross_caseinside_w1_s_ss_b_array_item_z_pc`, `gen/ch12/test_gen_cross_caseinside_w33_w_us_l_array_known_pv`, `gen/ch12/test_gen_cross_caseinside_w64_s_su_l_array_item_x_pv`, `gen/ch12/test_gen_cross_caseinside_w64_w_su_l_array_item_z_uv`, `gen/ch12/test_gen_cross_caseinside_w65_s_su_b_array_item_x_uv`, `gen/ch13/test_gen_fixed_array_slice_inout_copyback_ascending`, `gen/ch13/test_gen_fixed_array_slice_inout_copyback_descending`, `gen/ch13/test_gen_fixed_array_slice_output_copyback_ascending`, `gen/ch13/test_gen_fixed_array_slice_output_copyback_descending`, `gen/ch15/test_gen_cross_event_rebind_interface_direct_after_arm_nba_chain_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_interface_direct_before_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_interface_direct_before_call_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_interface_input_after_arm_blocking_single_new_old_2`, `gen/ch15/test_gen_cross_event_rebind_interface_input_before_arm_nba_chain_new_old_3`, `gen/ch15/test_gen_cross_event_rebind_interface_input_before_call_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_interface_ref_after_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_interface_ref_before_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_interface_ref_before_call_nba_chain_new_old_1`, `gen/ch15/test_gen_cross_event_rebind_module_direct_after_arm_blocking_single_old_new_3`, `gen/ch15/test_gen_cross_event_rebind_module_direct_before_arm_nba_single_old_new_2`, `gen/ch15/test_gen_cross_event_rebind_module_direct_before_call_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_module_input_after_arm_nba_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_module_input_before_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_module_input_before_call_nba_chain_old_new_3`, `gen/ch15/test_gen_cross_event_rebind_module_ref_after_arm_nba_single_new_old_3`, `gen/ch15/test_gen_cross_event_rebind_module_ref_before_arm_nba_single_new_old_2`, `gen/ch15/test_gen_cross_event_rebind_module_ref_before_call_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_package_direct_after_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_package_direct_before_arm_blocking_single_new_old_1`, `gen/ch15/test_gen_cross_event_rebind_package_direct_before_call_nba_chain_new_old_2`, `gen/ch15/test_gen_cross_event_rebind_package_input_after_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_package_input_before_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_package_input_before_call_blocking_single_new_old_3`, `gen/ch15/test_gen_cross_event_rebind_package_ref_after_arm_blocking_chain_old_new_2`, `gen/ch15/test_gen_cross_event_rebind_package_ref_before_arm_blocking_single_old_new_1`, `gen/ch15/test_gen_cross_event_rebind_package_ref_before_call_blocking_single_old_new_1`, `gen/ch18/test_gen_cross_randreduce_33_unsigned_fixed_sum_element_2_sat_fail_sat`, `gen/ch6/test_gen_combo_struct_array_automatic_elements`, `gen/ch6/test_gen_combo_struct_array_automatic_member`, `gen/ch7/test_gen_cross_method_w32_l_u_f_product_widen_known`, `gen/ch7/test_gen_cross_method_w33_b_u_q_product_widen_known`, `gen/ch7/test_gen_cross_method_w64_l_u_d_or_int_known`, `gen/ch8/test_gen_cross_class_method_129_bit_known_base_nonvirtual_function_ref_1`, `gen/ch8/test_gen_cross_class_method_129_logic_z_base_virtual_task_const_ref_3`, `gen/ch8/test_gen_cross_class_method_1_bit_x_base_nonvirtual_task_input_3`, `gen/ch8/test_gen_cross_class_method_1_bit_z_base_virtual_task_ref_1`, `gen/ch8/test_gen_cross_class_method_1_logic_x_direct_task_const_ref_0`, `gen/ch8/test_gen_cross_class_method_32_logic_known_base_nonvirtual_task_ref_3`, `gen/ch8/test_gen_cross_class_method_33_bit_known_base_nonvirtual_function_const_ref_3`, `gen/ch8/test_gen_cross_class_method_33_logic_known_base_nonvirtual_task_const_ref_1`、ほか2件

## 章別の結果

![章別の一致テスト数](charts/chapters.ja.svg?v=20261103T055105)

## シミュレータごとの推移

![Icarus Verilog：ステータス別の結果](charts/status-icarus.ja.svg?v=20261103T055105)

![Verilator：ステータス別の結果](charts/status-verilator.ja.svg?v=20261103T055105)

![kirimasim：ステータス別の結果](charts/status-kirimasim.ja.svg?v=20261103T055105)

![Lyra：ステータス別の結果](charts/status-lyra.ja.svg?v=20261103T055105)

![Ghost：ステータス別の結果](charts/status-ghost.ja.svg?v=20261103T055105)

## 最近の実行

各シミュレータの一致したテスト数と、その前回実行からの増減です。バージョンは変更されたときに表示します。

| 実行 (UTC) | スイート | テスト数 | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
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
