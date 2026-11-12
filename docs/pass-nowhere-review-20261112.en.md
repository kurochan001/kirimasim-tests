<a id="pass-nowhere-review-2026-11-12"></a>

# Review of the tests that no simulator passes (2026-11-12)

[English](pass-nowhere-review-20261112.en.md) / [日本語](pass-nowhere-review-20261112.md)

This record says what a review of the tests that pass on no simulator found,
which tests were corrected, and what is left for a decision. Expected results
come from IEEE 1800-2023 only. No expectation was changed to fit the output of
a simulator.

<a id="what-was-reviewed"></a>

## What was reviewed

- 148 tests pass on none of the simulators that the project runs: the pinned
  releases Icarus Verilog 13.0 and Verilator 5.052, kirimasim `7de185f776a1`,
  and the simulators of the Nightly, which include Lyra and Ghost.
- A first review read every test and the clauses it cites, and gave each test
  one verdict.
- A second, independent review took the tests that the first one judged wrong
  or flawed. It derived the expected results again and fixed the exact
  corrections. Where the two reviews differ, this record follows the second.
- Both reviews were made by an AI. Neither is an independent human review.
- The 17 contested tests were judged by the first review only.

<a id="verdicts"></a>

## Verdicts

| Verdict | Tests |
|---|---:|
| The expectation is right | 91 |
| The expectation is wrong | 9 |
| The test is flawed | 10 |
| Contested: two readings can be defended | 17 |
| Cannot run anywhere | 21 |
| Total | 148 |

"Cannot run anywhere" means that every simulator lacks the feature, so no run
says anything. The expectation was still compared with the standard as far as
possible.

<a id="corrected-tests"></a>

## Corrected tests

17 of the 19 wrong or flawed tests were corrected. Four tests outside the 148
have the same fault as one of them and were corrected with it, so 21 tests
changed. Every changed test says in its comment what was corrected and why.

| Test | Clause | What was wrong | Correction |
|---|---|---|---|
| `ch16/test_ch16_sim_multiclock_init` | 16.13.2, 16.13.7, 20.11 | The test put the evaluation of the consequent at 75. After the antecedent match at 10, a multiclocked `\|=>` goes to the nearest later tick of the second clock, 25. The pass action also runs on a vacuous success by default, and the expected output had no such lines. | `$assertvacuousoff` is called first and `e` rises at 20. Expected: `pass at 25`, `done`. |
| `ch16/test_ch16_sim_prop_inherited_eventually` | 20.11, 16.14.8 | The pass action also runs at the ticks where the antecedent is false. The expected output had no such lines. | `$assertvacuousoff` is called first. The expected output is the same. |
| `ch16/test_sequence_method_empty_matches` | 16.13.6, 16.13.5 | The second clock rose only at 10, 30 and 50, where `b` is 0. So the source sequence had no nonempty match and `matched` was never true. | The second clock rises every 10 time units. The expected output is the same. |
| `ch17/test_checker_assertion_placement` | 17.3, 16.5.1 | `d` is 4 at the clock at 15, not 9, so the static concurrent assertion fails twice. | Expected: `static: concurrent=2 deferred=3`. |
| `ch19/test_covergroup_bins_and_range_forms` | 19.5 | The coverage counted the default sequence bin. Default bins are left out of the calculation. | Expected transition coverage: 85.7 (6 of 7 bins). |
| Four cases of `gen/ch35/test_gen_cross_dpi_array_*` with a dynamic array or queue of one element | 20.7, H.12.2 | `svIncrement` was expected to be 1. It is -1 for every dynamic array or queue dimension. | The generator and its independent check give -1. See [the model](interaction-verification.en.md#dpi-open-array-shape-and-copyback). |
| `ch19/test_cg_illegal_transition_error`, `ch19/test_cg_illegal_cross_error` | 19.5.6, 19.6.3 | The tests required a source line of the test in the run-time error. The standard does not fix the form of the error. | The messages are checked only for an error, as in `ch19/test_cg_illegal_value_error`. The second test is outside the 148. |
| `ch18/test_constraint_function_cycle_runtime_error` (was `test_illegal_constraint_function_cycle`) | 18.5.11, 18.9 | The test accepted only a rejection at compilation. The ordering exists among the constraints that are active at `randomize()`, so the error may come at run time. | It is a run-time test. One constraint is switched off first, so the cycle exists only at the second `randomize()`. |
| `ch35/test_a2_5_dpi_open_array_packed_dimension` | H.7.6, H.7.7, H.12.2, H.12.4 | The C code read the size in bytes as a number of elements and indexed an unpacked dimension. The formal `logic []` has none. | The C code prints the size and bounds of dimension 0 and compares the value through `svGetArrayPtr`. A NULL pointer is accepted. |
| `ch37/test_vpi_constraint_iteration` | 37.32 detail 9 | The application asked the result of `vpiExtends` for another relation. For a class typespec the result is the base class typespec itself. | The application iterates the result directly. The expected output is the same. |
| `ch37/test_vpi_class_specialization_types`, `ch37/test_vpi_nettype_net_parts`, `ch37/test_vpi_variable_driver_load_arrays`, `ch37/test_vpi_net_bits_constant_select` | Annex K, 37.16 detail 10, 37.17 details 13 and 18 | The applications read `vpiIndex` with `vpi_get`. `vpiIndex` is a relation, not an integer property. | A helper takes the index object from `vpi_iterate` or `vpi_handle` and reads its integer value. The expected outputs are the same. The last three tests are outside the 148. |
| `ch37/test_vpi_struct_and_tagged_patterns` | 37.72 | The test required an iteration of all member patterns with their values, and the type of the typespec of a tagged pattern. The diagram, which is all the clause says, fixes neither. | The application prints only whether each relation gives an object. |
| `ch37/test_vpi_udp_table_primitive` | 37.36 detail 1 | The test required table rows without blanks. The clause says only that the row is a decompiled string. | The rows are compared without blanks and without a closing semicolon. The expected output is the same. |
| `ch38/test_vpi_put_value_udp_array_errors` | 38.34 | The value was put while an output event of the primitive was pending, and read in the same process. The clause fixes neither result. | The value is put at 16, after the primitive settled, and read at 17. The put that is an error writes the value the UDP already has. |

<a id="left-for-a-decision"></a>

## Two flawed tests left for a decision

These two tests did not change.

- `ch4/test_illegal_final_deferred_action_schedules_event` (4.4.2.9). The
  design is illegal. The message pattern asks for the line and also for
  certain words about the Postponed region and events. A right rejection in
  other words does not match. The proposal keeps the line numbers and drops
  the words. The README allows patterns with required words, and 31 of the
  illegal tests have one, so this is a question of policy.
- `ch18/test_illegal_randsequence_negative_weight` (18.17.1). A weight has to
  evaluate to a value that is not negative, and it is evaluated when its
  production is selected. So this is a run-time condition, and the standard
  does not say that an error is issued. The test can become a run-time test
  with a comment that the error is the reading of the suite, or it can be
  removed.

<a id="contested-tests"></a>

## Contested tests

Only the first review judged these 17 tests. None of them changed. Reading A
is the reading of the test.

| Test | Clause | Reading A | Reading B | Proposed handling |
|---|---|---|---|---|
| `ch7/test_illegal_string_in_untagged_union` | 7.3 | A string is a dynamic type, which an untagged union shall not hold. | The glossary's list of dynamic types does not name the string. | Use a queue or chandle member, which is not disputed. |
| `ch7/test_illegal_unique_index_without_with_struct_elements`, `ch7/test_illegal_unique_without_with_struct_elements` | 7.12.1 | The `with` clause may be left out only when `<`, `>` and `==` are all defined for the element type. | `unique` and `unique_index` compare for equality only, and `==` is defined for unpacked structures. | Accept either result. The tests of `min` and `max` keep the rule. |
| `ch11/test_illegal_stream_with_on_two_dimensional_array` | 11.4.14.4 | The expression before `with` is limited to a one-dimensional unpacked array. | The sentence says "can be" and states no error. | Do not count it as a required error: withdraw the test or mark it as contested. |
| `ch19/test_cg_four_state_literal_wildcard_enum` | 19.5.4, 19.5.7 | By 19.5.4 a bin value with x or z counts by `===`. | By 19.5.7 such a value gets a warning and takes no part in the bins. The standard conflicts with itself. | Keep the test with its comment, or print only what both readings give. |
| `ch21/test_illegal_value_plusargs_bad_format` | 21.6 | The listed conversions are the only valid ones, so `%q` is illegal. | No error is stated. With no matching argument the function returns 0 and gives no warning. | Drop the illegal test or accept either result. |
| `ch22/test_illegal_include_absolute_path_in_angle_brackets` | 22.4 | Only the form with double quotes may name an absolute path. | The sentence says "can" and states no error. | Do not count it as a required error. |
| `ch23/test_port_collapse_uwire_external_delay` | 23.3.3.7, 28.16 | The two nets are merged and take the delay of the dominating net. | Merging is optional. A tool that keeps both nets applies both delays. | Give the internal net no delay, so that both readings print the same. |
| `ch30/test_illegal_specify_edge_path_same_edge_and_condition` | 30.4.4.3 | Two delays for one edge-sensitive path need a different edge or condition. | The sentence says "can be assigned" under these conditions and states no error. | Do not count it as a required error. A sibling test rests on the same sentence. |
| `ch31/test_illegal_setuphold_negative_sum` | 31.3.3, 31.9.1 | With a negative limit the sum of setup and hold has to be positive. | 31.9.1 gives a warning and a repair for such values, not a rejection. | Drop the test or accept a warning. |
| `ch31/test_illegal_timing_condition_two_signals` | 31.7 | Logic of more than one conditioning signal shall be combined outside the specify block. | The grammar allows any expression after `&&&`, and no error is stated. | Accept either result or drop the test. |
| `ch36/test_vpi_compatibility_1800v2017_mode`, `ch36/test_vpi_compatibility_1800v2023_mode` | 36.10.2, 36.12.2.1, L.2 | 36.12.2.1 lists the mode symbol as valid, and the application prints from its startup routine. | 36.10.2 allows only the two registration routines there, and the header of L.2 as printed does not compile with this symbol. | Print from the start-of-simulation callback. Record the defect of L.2 as a conflict in the standard. |
| `ch37/test_vpi_class_relations_scope_typespec` | 37.31 detail 6, 8.17 | `vpiArgument` of the extends object gives the argument of `super.new(v)`. | The extends object stands for the extends clause and gives only the arguments written there. | Write the argument in the extends clause, which both readings return. |
| `ch37/test_vpi_program_interface_relations` | 37.9, 37.10 detail 3 | A program leads to the interfaces connected to its ports, and `vpiInstance` leads back to the program. | `vpiInstance` returns the instance that holds the interface, which is the module. | Remove the test or accept both. |
| `gen/ch21/test_gen_cross_litfmt_fill_b_display_param`, `gen/ch5/test_gen_cross_literal_fill_unsigned_unsized_one_add_signed_logic_65` | 6.20.2, 5.7.1 | `localparam P = '1;` has the one-bit value of a self-determined `'1`. | By the last item of 6.20.2 an untyped parameter with an unsized value has at least 32 bits. | Do not let the generators fix the width of such a parameter. |

<a id="vacuous-success-scan"></a>

## Scan for the pass action on a vacuous success

By 20.11 the pass action also runs on a vacuous success unless a control task
turns it off. The second review looked for other tests that forget this. Of
the tests with a pass action and no control task, 55 have an implication: 19
hand-written tests, 18 cases of the disable model and 18 cases of the program
assertion model. Only the two tests corrected above forgot it. 42 tests
already expect the lines of the vacuous successes, and in 11 the antecedent is
always true or the pass action belongs to an assertion without an implication.

<a id="runs-and-figures"></a>

## Runs and figures

- The 21 changed tests and one test that shares a check group with one of
  them ran on Icarus Verilog 13.0, Verilator 5.052 (seeds 1 and 73) and
  kirimasim `7de185f776a1`: `coverage/results/test-fixes-20261112-*.json`. As
  before, no simulator passes any of them: 22 known on each pinned release
  and 22 unsupported on kirimasim. All 21 changed tests list `spec` alone in
  `:oracle:`, so no token changed.
- Design coverage is 90.14% (11,085/12,298); it was 11,086. The requirement
  of 18.5.11 has the kind error, and the ledger accepts only an illegal-design
  test for such a row. Its test is now a run-time test, so the mapping was
  withdrawn and the reason recorded in `coverage/test-matching-reviews.json`.
- Execution coverage without Ghost stays at 50.20% (6,174/12,298). With the
  results of Ghost and of kirimasim added it is 77.57% (9,540/12,298); it was
  9,542. Two requirements of 37.16 lost their evidence. Their test,
  `ch37/test_vpi_net_bits_constant_select`, passed in Ghost's saved runs, and
  its C code changed, so those saved passes no longer count. They can count
  again when Ghost's results are saved again.
- Verilator 5.052 runs the corrected test of 18.5.11 and reports no error, and
  Icarus Verilog 13.0 gives a wrong `$increment` for dynamic arrays. Both are
  in the [list of differences](simulator-differences.md#icarus-increment-dynamic-20261112).

<a id="open-points"></a>

## Open points

- The two flawed tests and the 17 contested tests above wait for a decision.
- The ledger row for the relation from a struct pattern to its member patterns
  in 37.72 says "one to many". The diagram draws a single arrow. The corrected
  test accepts both access routines, and the row text did not change.
- The second review could not derive two expectations from the text and left
  them: that `svDimensions` counts the unpacked dimensions in the open array
  model, and the number of constraints (4) that the iteration from the NULL
  root returns in `ch37/test_vpi_constraint_iteration`.
