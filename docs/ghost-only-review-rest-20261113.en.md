<a id="ghost-only-review-rest-2026-11-13"></a>

# Review of the tests that only Ghost passes: the remaining clauses (2026-11-13)

[English](ghost-only-review-rest-20261113.en.md) / [日本語](ghost-only-review-rest-20261113.md)

This record gives the result of comparing with IEEE 1800-2023 the 332 tests that match their expectation on Ghost alone and that the reviews of [Clause 37](ghost-only-review-ch37-20261113.en.md), [Clause 16](ghost-only-review-ch16-20261113.en.md) and [Clauses 36, 38, 39 and 40](ghost-only-review-vpi-20261113.en.md) did not cover.
The verdicts come from the standard alone; no simulator output was used.
No test was changed in this review.

<a id="what-was-reviewed"></a>

## What was reviewed

- These are the 332 tests that pass on Ghost alone in the Nightly of 2026-11-12 and had not been reviewed yet: 44 in Clause 32, 34 in Clause 31, 32 in Clause 17, 29 in Clause 18, 23 in Clause 20, 22 in Clause 6, 18 in Clause 19, 17 in Clause 21, 15 in Clause 23, 11 in Clause 28, 11 in Clause 35, 10 in Clause 7, 10 in Clause 30, 10 in Clause 33, 8 in Clause 9, 6 in Clause 14, 5 in Clause 4, 5 in Clause 25, 3 in Clause 5, 3 in Clause 11, 3 in Clause 15, 3 in Clause 22, 2 in Clause 10, 2 in Clause 12, 2 in Clause 26, 1 in Clause 3, 1 in Clause 8, 1 in Clause 13, 1 in Clause 24. 35 of them are generated tests.
- To limit the usage, each test was read by one review, not two as before. The tests were split by clause into 17 groups, and one review read each group.
- For every verdict other than "right", the text, the syntax or the figure of the standard that it rests on was checked again. Figure 30-7 of 30.7.4.2 was checked as an image.
- All reviews were made by AI. They are not an independent human review.

<a id="verdicts"></a>

## Verdicts

| Verdict | Tests |
|---|---:|
| The expectation is right | 289 |
| The expectation is wrong | 0 |
| The test is flawed | 19 |
| The reading is contested | 24 |
| Total | 332 |

<a id="flawed"></a>

## The 19 flawed tests

| Test | Clauses | What is flawed |
|---|---|---|
| `ch6/test_interconnect_and_net_port_types` | 6.6.8, A.2.1.3 | The description promises a declaration with two identifiers, which the code does not contain. The element `arr[1]` is connected nowhere. The printed values are right. |
| `ch6/test_interconnect_net_alias` | A.2.1.3 | One `interconnect` declaration declares four names. The syntax allows at most two, so the design is not legal. |
| `ch17/test_checker_always_comb_output` | 17.2, 10.3.2 | The output `z` has an initial value and is also driven by `assign`. By 17.2 the initial value of an output means a variable initialization, and 10.3.2 forbids an initializer on a variable driven by a continuous assignment. |
| `ch17/test_checker_free_activity` | 17.7.2 | It tests `z != first` right after `first = z;`, so the condition is always false. It cannot show that `z` stays the same within a time step. `u[1]` is not printed either. |
| `ch18/test_rand_join_length_bias` | 18.17.5 | 18.17.5 does not quantify the bias of `rand join`. The relations between the counts are not guaranteed. |
| `ch18/test_rand_real_uniform_and_dist` | 18.5.3, 18.14.1 | The checks are statistical. A conforming generator fails them about 1.7% of the time. |
| `ch19/test_covergroup_bins_and_range_forms` | 19.5 | In `bins fromset = set_vals;`, `set_vals` is a module variable that is not constant. 19.5 allows as variables in a covergroup_expression only constants, instance constants and non-ref arguments. |
| `gen/ch21/test_gen_comb_fread_struct_array_member`, `gen/ch21/test_gen_comb_fread_struct_multidimensional` (two tests) | 21.3.4.4, 7.4.3 | 21.3.4.4 does not define `$fread` into an array of unpacked structures (multidimensional or not). The expectation is a natural combination of the rules of the standard. The fix belongs in the generator. |
| `ch23/test_port_collapse_trireg_charge_strength`, `ch23/test_port_collapse_trireg_external_charge` (two tests) | 23.3.3.7, 6.6.4.1 | They assume that the nets are merged at the port. 23.3.3.7 only permits the merge. Without it, the two triregs share the larger charge, and the hold lines change. |
| `ch23/test_vpi_port_kind_defaults` | 23.2.2.3, 6.7.1 | By 23.2.2.3, `input int in_int` is a net of the default net type, `wire int`. 6.7.1 allows only 4-state types for such a net, so the design is not legal. |
| `ch26/test_std_package_system_types` | 15.3.4, 6.21, 9.7 | It compares the result of `try_get` with 1, while 15.3.4 only promises a positive integer. It also calls `process::self()` in a static initializer, when there is no calling process yet. |
| `ch31/test_timing_edge_descriptors_all`, `ch32/test_sdf_tchk_edge_condition_match` (two tests) | 4.9.6, 6.7.1, 31.5, 31.3.2, 4.7 | At time 0 the port nets of the cell change from z to 0. Depending on the order of the updates, a hold violation occurs at time 0 and extra lines are printed. |
| `ch32/test_sdf_recrem_limits` | 31.6, 4.7 | At time 12 two notifiers change separately. If `always @(u.nrec or u.nrem)` runs between them, one more line is printed. |
| `ch35/test_dpi_dynamic_array_actual` | 35.5.6 | It passes a dynamic array to a sized array formal. 35.5.6 lets an implementation restrict such actual arguments. |
| `ch35/test_dpi_export_task_result` | 35.8 | The C code of an imported function calls an exported task. 35.8 forbids this. |
| `ch35/test_dpi_unpacked_aggregate_arguments` | H.7.4 | It adds a -4 held in a C `char`. Whether `char` is signed depends on the C implementation, and if it is not, the sum changes. |

<a id="contested"></a>

## The 24 contested tests

| Test | Clauses | What is contested |
|---|---|---|
| `ch6/test_a2_1_3_interconnect_declaration_identifiers` | 23.3.3.7.1 | The unconnected `ib[0]` stays an interconnect. Whether the last rule of 23.3.3.7.1 makes this illegal is contested. |
| `ch6/test_builtin_net_declaration_forms` | 10.3.4, 6.7.1 | It gives a drive strength to vector nets. 10.3.4 limits strengths to scalar nets. The expectation needs the reading that each bit takes the strength. |
| `ch7/test_array_ordering_methods_and_index_queries` | 7.12.3, 7.12.4 | For a two-dimensional array, whether `item` in `with` is an element or a row is contested. The example of 7.12.3 reads as a row. The expectation needs one element at a time. |
| `ch11/test_equality_class_interface_chandle_handles` | 11.4.6, Table 11-1, 8.4, 6.14 | The last paragraph of 11.4.6 makes `==?` on handles the same as `==`. Table 11-1, 8.4 and 6.14 do not list `==?` among the operators allowed on handles. |
| `ch17/test_checker_assertion_placement` | 17.7.3, 16.14.6, 4.5 | Whether a concurrent assertion queued in the Reactive region matures in the same time step is contested. |
| `ch18/test_inline_local_scope_binding` | 18.7.1, 8.4 | Whether `local::r` is the static member of the class or the randomized object itself is contested. |
| `ch18/test_rand_mode_inactive_handle`, `ch18/test_randomize_callback_override` (two tests) | 18.8 | Whether `o.h.rand_mode(0)` switches off the handle `h` or every random variable of the object of `h` is contested. The syntax of 18.8 fits both. |
| `ch19/test_cg_option_levels_readback` | 19.7, 19.7.1 | Whether `type_option` read before any instance exists has the value of the definition or the default is contested. |
| `ch20/test_pla_all_forms`, `ch20/test_pla_sync_snapshot_versus_async_update` (two tests) | 20.16.1, 20.16.4 | Whether an asynchronous PLA task evaluates once when it is called is contested. 20.16.1 names only changes of the inputs or the personality, and the example of 20.16.4 assumes an evaluation at the call. |
| `gen/ch20/test_gen_cross_dpiquery_1_up_neg_one_4_sized_offset_same_variable`, `gen/ch20/test_gen_cross_dpiquery_2_up_pos_one_4_sized_offset_same_variable`, `gen/ch20/test_gen_cross_dpiquery_3_up_neg_one_4_open_offset_switch_literal` (three tests) | H.12.2, 20.7 | Whether `svDimensions` also counts the packed dimension is contested. H.12.2 gives it the meaning of 20.7. The expectation counts only the unpacked dimensions. |
| `ch21/test_fwrite_unformatted_aggregates` | 21.2.1.1 | 21.2.1.1 forbids `%u` on unpacked aggregates, and also defines `%u` for unpacked structures. The expectation follows the latter. |
| `ch23/test_defparam_block_task_function_parameters` | 6.20.1, 23.10 | In a module with a parameter port list, whether the parameters inside a block, a task and a function become local parameters is contested. |
| `ch31/test_timing_check_condition_x` | 31.7, 31.2 | Whether the check is enabled by the condition `en !== 1'b1` when `en` is x is contested. By the sentence of 31.7 it is not. The value of the expression is 1. |
| `ch32/test_sdf_scale_type_members` | 32.9 (Table 32-6) | Whether `FROM_MINIMUM` and the like apply all three factors to one value, or scale only that value by its own factor, is contested. |
| `ch33/test_config_cell_parameter`, `gen/ch33/test_gen_cross_config_1_both_reset_all_0_if_literal_direct`, `gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_case_literal_wrapped`, `gen/ch33/test_gen_cross_config_32_defparam_reset_all_0_if_literal_direct`, `gen/ch33/test_gen_cross_config_64_both_reset_all_0_if_literal_wrapped` (five tests) | 33.4.1 (Syntax 33-4), A.1.5, 33.4.3 | The `#( )` of a use clause. The syntax does not have it, and the examples of 33.4.3 do. This is the [conflict already recorded](simulator-differences.md#config-use-parameter-form). |
| `ch33/test_duplicate_cell_last_definition_wins` | 33.3.1.1, 3.13 | Two modules have the same name. 33.3.1.1 takes the last definition with a warning, and 3.13 a) forbids the second declaration. |

<a id="notes"></a>

## Remarks that do not change a verdict

The expectations of the following five tests are right, but they cite the wrong subclause.

- `ch9/test_wait_sequence_same_slot_twice`: citation 16.13.5 → 16.13.6
- `ch14/test_clocking_net_outputs_strong_drivers_resolved`: citation 21.2.1.5 → 21.2.1.4
- `ch28/test_trireg_charge_strength`: citation 28.15.1 → 28.15.2
- `ch32/test_sdf_cond_iopath`: citation 30.4.4.3 → 30.4.4.4
- `ch32/test_sdf_iopath_retain_forms`: citation 30.4.4.3 → 30.4.4.4

The reviews also noted small errors in comments, and forms that a description names but the test does not really use, in a few tests. None of them affects an expectation.

<a id="all-756"></a>

## Result for all 756 tests

| Scope | Tests | Right | Wrong | Flawed | Standard gap | Contested |
|---|---:|---:|---:|---:|---:|---:|
| Clause 37 | 193 | 142 | 4 | 26 | 4 | 17 |
| Clause 16 | 90 | 85 | 0 | 0 | 0 | 5 |
| Clauses 36, 38, 39 and 40 | 141 | 108 | 3 | 19 | 0 | 11 |
| The remaining clauses | 332 | 289 | 0 | 19 | 0 | 24 |
| Total | 756 | 624 | 7 | 64 | 4 | 57 |

<a id="next"></a>

## What happens next

- The 19 flawed tests will be corrected when Ghost's results are saved again. For the two generated tests, the generator will be corrected.
- The 24 contested tests wait for a decision.
- Tests whose timing checks can report a violation because a port net changes from z at time 0 may also exist among the tests that pass elsewhere. The next review will search the whole suite.
- The coverage figures are unchanged.
