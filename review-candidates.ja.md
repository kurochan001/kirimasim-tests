# レビュー候補

[English](review-candidates.md)

期待値の根拠が規格の読み方にしかないテストと条項を、各シミュレータの最新の結果から挙げます。候補は誤りの指摘ではなく、規格と照らした見直しで判断します。[見直しの記録の仕方](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/docs/review-candidates.md)。

## 読んだ結果

| シミュレータ | 版 | 時刻 | スイートのコミット |
| --- | --- | --- | --- |
| Icarus Verilog | `Icarus Verilog version 14.0 (devel) (s20260301-1208-g65504129)` | 2026-11-19T20:50:41Z | `68ce2bc2` |
| Verilator | `Verilator 5.055 devel rev v5.054-325-g464643f7` | 2026-11-19T20:50:41Z | `68ce2bc2` |
| kirimasim | `kirimasim 0.1.1 (commit bd81035d9809), built with GNU 13.3.0` | 2026-11-19T20:50:41Z | `68ce2bc2` |
| Lyra | `Lyra (commit f164508a8662)` | 2026-11-19T06:47:05Z | `a00ad6ad`（古いコミット） |
| Ghost | `private build 0b90acaa7ed6` | 2026-11-19T20:50:41Z | `68ce2bc2` |

## 件数

| 候補 | 件数 |
| --- | ---: |
| specのみで、Ghost・kirimasim・Lyraのすべてでfail | 0 |
| specのみで、kirimasimだけがpass | 38 |
| specのみで、どこでもpassしないその他のテスト | 13 |
| 固定版のoracleがあり、GhostとLyraの両方でfail | 3 |
| 引用するテストがすべてspecのみの条項 | 212 |

結果: I Icarus Verilog、V Verilator、K kirimasim、L Lyra、G Ghost。p pass、f fail、u unsupported、k known、- 未実行。

## specのみで、Ghost・kirimasim・Lyraのすべてでfail

なし。

## specのみで、kirimasimだけがpass

| テスト | 結果 |
| --- | --- |
| [`gen/ch11/test_gen_constant_negative_power_zero_e3`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_constant_negative_power_zero_e3.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_constant_negative_power_zero_e32`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_constant_negative_power_zero_e32.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_constant_negative_power_zero_e8`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_constant_negative_power_zero_e8.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_negative_power_zero_e3`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_negative_power_zero_e3.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_negative_power_zero_e32`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_negative_power_zero_e32.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_negative_power_zero_e8`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_negative_power_zero_e8.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w127`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w127.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w128`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w128.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w129`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w129.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w255`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w255.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w256`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w256.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w257`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w257.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w63`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w63.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w64`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w64.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_signed_w65`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_signed_w65.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w127`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w127.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w128`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w128.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w129`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w129.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w255`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w255.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w256`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w256.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w257`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w257.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w63`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w63.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w64`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w64.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch11/test_gen_power_boundary_negative_unsigned_w65`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch11/test_gen_power_boundary_negative_unsigned_w65.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w128`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w128.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w129`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w129.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w255`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w255.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w256`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w256.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w257`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w257.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w64`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w64.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_signed_w65`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_signed_w65.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w128`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w128.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w129`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w129.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w255`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w255.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w256`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w256.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w257`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w257.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w64`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w64.sv) | `Ik Vk Kp L- Gf` |
| [`gen/ch21/test_gen_wide_scan_decimal_unsigned_w65`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/gen/ch21/test_gen_wide_scan_decimal_unsigned_w65.sv) | `Ik Vk Kp L- Gf` |

## specのみで、どこでもpassしないその他のテスト

| テスト | 結果 |
| --- | --- |
| [`ch18/test_discarded_soft_distribution`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch18/test_discarded_soft_distribution.sv) | `Ik Vk Ku Lf Gf` |
| [`ch19/test_cg_cross_set_function_matches`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch19/test_cg_cross_set_function_matches.sv) | `Ik Vk Ku Lu Gf` |
| [`ch19/test_covergroup_cross_and_select_forms`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch19/test_covergroup_cross_and_select_forms.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_mtm_spec`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch32/test_sdf_mtm_spec.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_scale_factors`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch32/test_sdf_scale_factors.sv) | `Ik Vk Ku Lu Gf` |
| [`ch32/test_sdf_scale_type_members`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch32/test_sdf_scale_type_members.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_attribute_ports_params`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch37/test_vpi_attribute_ports_params.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_io_decl_scope_typespec_ports`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch37/test_vpi_io_decl_scope_typespec_ports.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_program_interface_relations`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch37/test_vpi_program_interface_relations.sv) | `Ik Vk Ku Lu Gf` |
| [`ch37/test_vpi_struct_and_tagged_patterns`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch37/test_vpi_struct_and_tagged_patterns.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_cover_no_failure`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch39/test_vpi_assertion_cover_no_failure.sv) | `Ik Vk Ku Lu Gf` |
| [`ch39/test_vpi_assertion_system_task_control`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch39/test_vpi_assertion_system_task_control.sv) | `Ik Vk Ku Lu Gf` |
| [`ch7/test_illegal_wildcard_array_find`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch7/test_illegal_wildcard_array_find.sv) | `Ik Vk Ku Lf Gf` |

## 固定版のoracleがあり、GhostとLyraの両方でfail

| テスト | 結果 |
| --- | --- |
| [`ch21/test_fopen_name_and_type_forms`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch21/test_fopen_name_and_type_forms.sv) | `Ip Vp Kf Lf Gf` |
| [`ch21/test_vcd_dumpvars_all_filename_start`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch21/test_vcd_dumpvars_all_filename_start.sv) | `Ip Vk Kf Lf Gf` |
| [`ch6/test_ch6_extra_for_loop_automatic`](https://github.com/kurochan001/kirimasim-tests/blob/68ce2bc2a458f118cae0e4e65f1e042c3b90aa6e/tests/ch6/test_ch6_extra_for_loop_automatic.sv) | `Ik Vp Kf Lf Gf` |

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
