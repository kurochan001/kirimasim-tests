<a id="oracle-token-review-2026-11-12"></a>

# Review of the oracle tokens of illegal tests (2026-11-12)

[English](oracle-token-review-20261112.en.md) / [日本語](oracle-token-review-20261112.md)

This record says which `iverilog@13.0` and `verilator@5.052` tokens were
removed from the `:oracle:` of illegal tests, and why. A first pass left some
tokens unchecked; a [second pass](#second-pass) of the same day checked them.
A [third pass](#third-pass) ran a legal counterpart for every Verilator token
that was left. No test changed its code or its expected result.

<a id="what-was-wrong"></a>

## What was wrong

An illegal test (`:should_fail_because:`) may list a fixed release in
`:oracle:` only when that release rejects the design at the marked line for
the reason the test means. A rejection for another reason, such as a construct
the release does not support, does not count. The
[README](../README.md#where-the-expected-outputs-come-from) states this rule.

A commit of 2026-10-26 added `iverilog@13.0` to many tests at once, where the
runner reported a match. For many illegal tests, Icarus Verilog 13.0 fails
only on syntax it does not know. The error falls on the marked line, and the
runner cannot tell the difference. The comments of 152 tests said that the
error of Icarus Verilog does not count, while their `:oracle:` listed it.

The token matters for the figures. Execution coverage counts a pass of an
illegal test only when its `:oracle:` lists the fixed release. A wrong token
therefore counted a requirement as confirmed by a release that does not
diagnose the rule.

<a id="how-it-was-checked"></a>

## How it was checked

- A repository review listed 253 illegal tests with `iverilog@13.0` whose
  token looked wrong. In 152 the comment said that the error does not count,
  in 76 the comment said that the release does not support the construct, and
  25 had no statement.
- Every illegal test that listed a fixed release ran on that release: 1,173
  tests on Icarus Verilog 13.0 and 550 tests on Verilator 5.052. The messages
  on the marked line were recorded.
- Where a message did not settle the question, a legal counterpart of the
  same construct was tried. When the release reports the same error for the
  legal form, its error does not diagnose the rule.
- After the removal, the changed tests ran again with the runners of the
  suite. No status changed.

<a id="counts"></a>

## Counts

| Item | Icarus Verilog 13.0 | Verilator 5.052 |
| --- | ---: | ---: |
| Tokens of the reviewed set | 253 | – |
| Removed from the reviewed set | 249 | – |
| Kept in the reviewed set | 3 | – |
| Test of the reviewed set that no longer exists | 1 | – |
| Removed outside the reviewed set | 5 | 6 |
| Removed in total | 254 | 6 |

The removed tokens belong to 259 tests; one test lost both tokens. The test
that no longer exists is `ch8/test_illegal_weak_reference_non_class`, removed
as a duplicate on 2026-11-11.

The 254 tokens of Icarus Verilog by chapter: 84 in chapter 16, 25 in 6, 22 in
7, 21 in 18, 19 in 8, 15 in 10, 14 in 25, 11 each in 11 and 12, 6 in 23, 4
each in 14, 33 and 35, 3 each in 9 and 13, 2 each in 19, 22 and 30, and 1 each
in 20 and 27. The 6 tokens of Verilator: 3 in chapter 17, 2 in 6 and 1 in 27.

Where the comment of a test did not explain why the error does not count, a
short comment now says what the release reports. This was needed in 9 tests.
The comment of `ch17/test_illegal_checker_in_function` said that a checker
cannot be instantiated in procedural code. That contradicted 17.3, which
allows an always or initial procedure; the comment now names a function body.
The expected result of that test did not change.

<a id="kept-tests"></a>

## The three tests that keep the token

| Test | What Icarus Verilog 13.0 reports at the marked line |
| --- | --- |
| `ch10/test_illegal_charge_strength_on_wire` | A syntax error on `wire (medium) w;`. It parses the legal `trireg (medium) t;`, so the error is the rule of the grammar. |
| `ch23/test_illegal_implicit_name_port_declared_later` | It cannot bind `data` on line 44 and points to the declaration after the use. It also rejects the legal `.cfg`, so the design would be rejected anyway. |
| `ch13/test_illegal_constant_function_calls_nonconstant_function` | On line 33 a reference to a non-local variable is not allowed in a constant function, and on line 54 it cannot evaluate the parameter. It also fails on the legal call of `h`. |

The comments of these three tests now say what the release reports and that
it diagnoses the rule.

<a id="outside-the-reviewed-set"></a>

## Tokens found outside the reviewed set

Of the other 920 tests with `iverilog@13.0`, 624 have a syntax error on the
marked line. A sweep over them confirmed five wrong tokens with a legal
counterpart:

- `ch18/test_illegal_packed_struct_member_rand` and
  `ch18/test_illegal_packed_union_member_rand`: the same syntax error for a
  `rand` member of an unpacked structure, which is legal.
- `ch33/test_illegal_config_positional_parameter`: the same syntax error for
  the legal `use #(.W(8))`.
- `ch27/test_illegal_generate_module_block_extern_task`: the same syntax error
  for an extern task in an interface, where it is legal. The test kept
  `verilator@5.052` until the [third pass](#third-pass).
- `ch6/test_ch6_extra_event_not_bit_storage`: not a syntax error. Icarus
  Verilog reports that it could not find the variable, also for the legal
  `e = f` and `e = null`.

Of the 550 tests with `verilator@5.052`, 125 have a syntax error on the marked
line and 3 an error marked as unsupported. Six tokens were removed:

- `ch17/test_illegal_checker_in_class`,
  `ch17/test_illegal_checker_in_function`,
  `ch17/test_illegal_checker_module_instance` and
  `ch27/test_illegal_generate_checker_block_module_instance`: the same syntax
  error for a legal checker instance in the same place.
- `ch6/test_ch6_extra_event_not_bit_storage`: an assignment to an event is
  reported as unsupported, also for the legal `e = f` and `e = null`.
- `ch6/test_illegal_handle_to_real_cast`: the cast is reported as unsupported.
  The test keeps `iverilog@13.0`.

<a id="not-yet-checked"></a>

## What the first pass did not check

The [second pass](#second-pass) checked both items of this section. They are
kept here as the first pass left them.

- 296 illegal tests listed `iverilog@13.0` and the error on their marked line
  was not a syntax error. Their messages were recorded, but they were not
  compared with the rule one by one.
- Four tokens were doubtful and stayed. Three tests of chapter 33 state rules of
  the grammar of a config (`test_illegal_config_default_use`,
  `test_illegal_config_design_after_rule`,
  `test_illegal_config_two_design_statements`), but Icarus Verilog 13.0 only
  parses a config and then skips it. `ch35/test_35_rest_dpi_class_formal`
  lists Verilator 5.052, which words its error as unsupported, although the
  standard forbids the construct.

After the first pass, 1,975 tests were illegal designs; 918 of them listed
`iverilog@13.0` and 544 listed `verilator@5.052`.

<a id="effect-on-the-figures"></a>

## Effect on the figures

| Figure | Before | After |
| --- | ---: | ---: |
| Tests with `iverilog@13.0` | 6,651 | 6,397 |
| Tests with `verilator@5.052` and no `iverilog@13.0` | 2,246 | 2,243 |
| Tests with `spec` alone | 3,368 | 3,625 |
| Design coverage | 90.14% (11,086/12,298) | 90.14% (11,086/12,298) |
| Execution coverage without Ghost | 51.29% (6,308/12,298) | 50.27% (6,182/12,298) |
| Execution coverage with Ghost and kirimasim | 78.68% (9,676/12,298) | 77.65% (9,550/12,298) |

126 requirements lost their execution evidence. All of them are requirements
of the kind error, and each has a test whose token was removed. No other
requirement changed. By chapter:

| Chapter | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 16 | 18 | 20 | 22 | 23 | 25 | 33 | 35 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Requirements | 17 | 9 | 6 | 2 | 8 | 5 | 8 | 1 | 1 | 43 | 10 | 1 | 2 | 3 | 6 | 3 | 1 |

These requirements stay mapped to their tests. They need a simulator that
diagnoses the rule before they count as executed again.

The input digests of 273 tests changed: the 259 tests, the 3 kept tests whose
comment changed, and 11 tests of `tests/ch22` that hash the whole directory.
These and 73 tests that share a check group with one of them ran again, 346
in all, and the results are in `coverage/results/oracle-tokens-20261112-*.json`.
Icarus Verilog 13.0 has 305 pass and 41 known; Verilator 5.052 has 175 pass
and 171 known for both seeds 1 and 73; kirimasim `7de185f776a1` has 303 pass,
33 unsupported and 10 fail. Every status equals that of the full run of the
same day. The saved results of Ghost for these tests are stale now; no
requirement lost evidence for that reason.

The ledger keeps the mappings. The input digests of 263 checks of 188
requirements and of 31 records in `coverage/test-matching-reviews.json` were
refreshed. 99 of the requirements have check groups, so the baseline was
written again with a reason.

<a id="second-pass"></a>

## Second pass (2026-11-12)

The second pass checked the tokens that the first pass had left. It removed
11 more tokens from 10 tests: 8 `iverilog@13.0` and 3 `verilator@5.052`.
No test changed its code or its expected result.

<a id="second-pass-what-was-checked"></a>

### What was checked

All 918 illegal tests with `iverilog@13.0` are checked now:

- 299 tests whose error on the marked line is not a syntax error. Each message
  was read with the line of the test. For 14 of them a legal counterpart was
  run as well. 295 tokens stay and 4 were removed. The first pass counted 296
  such tests; the grouping of this pass gives 299.
- 120 hand-written tests with a syntax error on the marked line. Each ran with
  a legal counterpart of the same construct. 116 tokens stay and 4 were
  removed.
- All 496 generated keyword tests of `tests/gen/ch22`. Each uses a reserved
  word as an identifier and gets a syntax error. With the identifier renamed,
  every one of them compiles, so all 496 tokens stay.
- The three config tests of chapter 33 that the first pass called doubtful.
  Their tokens are right. Icarus Verilog 13.0 parses the legal forms of the
  same statements and then skips the config with a "sorry" message, and it
  reports a syntax error only for the illegal forms. This is the rule of the
  grammar, as in `ch10/test_illegal_charge_strength_on_wire`.

Nothing remains unchecked on the side of Icarus Verilog.

Of the 544 illegal tests with `verilator@5.052`, the first pass had checked
those with a syntax error on the marked line. The second pass covered the
other 423:

- `ch35/test_35_rest_dpi_class_formal`, the doubtful token of the first pass.
  It was removed.
- 422 tests whose error is neither a syntax error nor marked as unsupported.
  For 18 of them a legal counterpart was run: 16 tokens stay and 2 were
  removed. The other 404 tokens were judged from the text of the message
  alone. Where the message states the rule, the token stays. No legal
  counterpart was run for these 404, so this check is weaker than the one for
  Icarus Verilog. This was the state after the second pass. The
  [third pass](#third-pass) ran a legal counterpart for all of these tests,
  so no token is judged from the message alone any more.

<a id="second-pass-removed"></a>

### The 11 removed tokens

| Test | Token | What the release reports, and for which legal use it reports the same |
| --- | --- | --- |
| `ch21/test_illegal_readmem_higher_range` | `iverilog@13.0` | The array needs 2 indices. The same for the legal load target `m[1]`. |
| `ch21/test_illegal_readmem_higher_range` | `verilator@5.052` | "`$readmemh` loading non-variable". The same for the legal `m[1]`. |
| `ch7/test_illegal_sort_iterator_without_with` | `iverilog@13.0` | An unknown task `a.sort`. The same for the legal `a.sort()`. |
| `ch13/test_illegal_nonvoid_function_call_without_parentheses` | `iverilog@13.0` | It cannot bind `get_k`. It rejects a legal call of a class function method without parentheses as well, with the message that the class has no such property. |
| `ch10/test_illegal_assignment_pattern_in_port_expression` | `iverilog@13.0` | A syntax error. The same for `ab_t'{a, b}` in a legal assignment. |
| `ch20/test_illegal_typename_hierarchical_constant` | `iverilog@13.0` | A hierarchical reference is not allowed in a constant expression. It rejects the legal `$typename(sig)` of a local variable in a localparam too, and no constant `$typename` form was accepted. |
| `ch13/test_illegal_ref_combined_with_inout`, `_input`, `_output` | `iverilog@13.0` | A syntax error. The same for the legal `const ref`, and the legal `ref` formal of the same test is reported as not supported. |
| `ch35/test_35_rest_dpi_class_formal` | `verilator@5.052` | The class type is an unsupported DPI argument. The same for a legal unpacked structure formal. |
| `ch23/test_23_extra_bound_param_constant` | `verilator@5.052` | It cannot find the bound instance `b`. The same for a legal reference to `u.b.P` in procedural code. |

The four tokens of `ch20/test_illegal_typename_hierarchical_constant` and of
the three `ref` tests were less clear than the others, because the message or
the syntax error fits the rule. The owner approved their removal: the release
rejects the legal use as well.

Eight tests got a short comment at the end of the file that says what the
release reports and why it does not count. In
`ch35/test_35_rest_dpi_class_formal` and
`ch23/test_23_extra_bound_param_constant` an existing comment said that
Verilator observes the rule; it was reworded in the same lines. No line that
`:expected_stderr_regex:` names moved.

<a id="second-pass-figures"></a>

### Effect on the figures

| Figure | Before | After |
| --- | ---: | ---: |
| Tests with `iverilog@13.0` | 6,397 | 6,389 |
| Tests with `verilator@5.052` and no `iverilog@13.0` | 2,238 | 2,241 |
| Tests with `spec` alone | 3,627 | 3,632 |
| Illegal tests with `iverilog@13.0` | 918 | 910 |
| Illegal tests with `verilator@5.052` | 544 | 541 |
| Design coverage | 90.14% (11,086/12,298) | 90.14% (11,086/12,298) |
| Execution coverage without Ghost | 50.27% (6,182/12,298) | 50.24% (6,178/12,298) |
| Execution coverage with Ghost and kirimasim | 77.65% (9,550/12,298) | 77.62% (9,546/12,298) |

Four requirements of the kind error lost their execution evidence, one each
in 10.9, 21.4, 23.11 and 35.5.4. The requirements of 7.12 and 13.5.2 keep
theirs, because their tests still list `verilator@5.052`. The requirement of
13.5 had no execution evidence before. The test of chapter 20 is mapped to no
requirement.

The input digests of the 10 tests changed. They and
`ch13/test_illegal_recursive_class_function_call_without_parentheses`, which
shares a check group with one of them, ran again. The results are in
`coverage/results/oracle-tokens-2-20261112-*.json`. Icarus Verilog 13.0 has 9
pass and 2 known; Verilator 5.052 has 9 pass and 2 known for both seeds 1 and
73; kirimasim `7de185f776a1` has 10 pass and 1 unsupported. Every status
equals the one saved before.

The input digests of 9 checks of 7 requirements were refreshed. Two of the
requirements have check groups, so the baseline was written again with a
reason. One observation of 35.5.4 now says that the error of Verilator does
not count. No record of `coverage/test-matching-reviews.json` names these
tests.

<a id="third-pass"></a>

## Third pass (2026-11-12)

The third pass ran a legal counterpart for every illegal test that still
listed `verilator@5.052`. It removed 9 more tokens from 9 tests. No test
changed its code or its expected result.

<a id="third-pass-what-was-checked"></a>

### What was checked

After the second pass, 541 illegal tests listed `verilator@5.052`. Each of
them ran on Verilator 5.052 (`--lint-only`), and a legal counterpart ran
beside it:

- For 421 tests the marked line was edited into a legal form of the same
  construct. The release accepts the legal form, so the tokens stay.
- For 111 tests the marked line was removed, because a legal form of the
  construct stays in the file. The release accepts the rest, so the tokens
  stay. For 36 of these 111 the files were not read one by one. They were
  kept on the writing pattern of the suite, which puts a legal use beside
  the illegal line. This part of the check is weaker than the rest.
- For 9 tests the release also rejects the legal form, or its message is
  about another rule. Their tokens were removed.

532 tokens stay. The second pass had judged 404 tokens from the text of the
message alone. That statement described the second pass and is corrected
here: every one of the 541 tests now has a legal counterpart run.

<a id="third-pass-removed"></a>

### The 9 removed tokens

There are three causes.

The legal form gets the same message:

| Test | What Verilator 5.052 reports |
| --- | --- |
| `ch16/test_illegal_property_flattened_delay_variable` | The delay value is not an elaboration-time constant. The same for the legal instance `p_dly(2)`; only a literal `##2` is accepted. |
| `ch27/test_illegal_generate_repeated_genvar_value` | Unrolling the generate loop took too long. The same for a legal loop of 200000 iterations. The test keeps `iverilog@13.0`. |
| `ch27/test_illegal_generate_module_block_extern_task` | A syntax error at `extern`. The same for an extern task in a generate block of an interface, where it is legal. |

Every legal form of the construct is reported as unsupported:

| Test | What Verilator 5.052 reports |
| --- | --- |
| `ch18/test_illegal_dist_default_colon_equal` | A syntax error that expects `:/`. The legal `default :/ 1` is reported as unsupported. |
| `ch18/test_illegal_dist_default_no_weight` | A syntax error that expects `:/`. The legal `default :/ 2` of the same test is reported as unsupported. |
| `ch25/test_illegal_extern_forkjoin_function` | A syntax error that expects `task`. The legal extern forkjoin task alone is reported as unsupported. |

The rejection cannot be told apart, or it is about another rule:

| Test | What Verilator 5.052 reports |
| --- | --- |
| `ch16/test_illegal_local_variable_visible_in_instantiating_sequence` | It cannot find `v`. The legal `s_inner` alone, with its local variable, ends in an internal error. |
| `ch19/test_illegal_cg_transition_sole_range` | A transition requires at least two values. A legal transition with a range, `([1:2] => 3)`, ends in an internal error; `(1 => 2)` is accepted. |
| `ch29/test_illegal_udp_sequential_entry_without_state` | The output of a combinational UDP must not be `reg`. This is another rule, and the message does not name the missing state field. The test keeps `iverilog@13.0`. |

The first six were clear. The last three were less clear, because the
message of the first two fits the rule; the owner approved their removal.

Eight tests got a short comment at the end of the file that says what the
release reports and why it does not count. In
`ch27/test_illegal_generate_module_block_extern_task` an existing comment
said that the syntax error of Verilator is right; it was reworded in the
same lines. No line that `:expected_stderr_regex:` names moved.

<a id="third-pass-figures"></a>

### Effect on the figures

| Figure | Before | After |
| --- | ---: | ---: |
| Tests with `iverilog@13.0` | 6,389 | 6,389 |
| Tests with `verilator@5.052` and no `iverilog@13.0` | 2,241 | 2,234 |
| Tests with `spec` alone | 3,632 | 3,639 |
| Illegal tests with `iverilog@13.0` | 910 | 910 |
| Illegal tests with `verilator@5.052` | 541 | 532 |
| Design coverage | 90.14% (11,086/12,298) | 90.14% (11,086/12,298) |
| Execution coverage without Ghost | 50.24% (6,178/12,298) | 50.20% (6,174/12,298) |
| Execution coverage with Ghost and kirimasim | 77.62% (9,546/12,298) | 77.59% (9,542/12,298) |

Four requirements of the kind error lost their execution evidence, one each
in 16.10, 16.12, 25.7 and 29.3.4. The requirement of 29.3.4 has a check group
of two tests, and both have to pass in one result file.
`ch29/test_illegal_udp_sequential_entry_without_state` still lists
`iverilog@13.0`, but the other test of the group,
`ch29/test_illegal_udp_two_transitions_in_entry`, lists only
`verilator@5.052`. So no single release confirms both tests now. The
requirement of 27.4 keeps its evidence, because its test still lists
`iverilog@13.0`. The requirements of 18.5.3 and 27.3 had no execution
evidence before. The test of chapter 19 is mapped to no requirement.

The input digests of the 9 tests changed. They and 4 tests that share a check
group with one of them ran again, 13 in all. The results are in
`coverage/results/oracle-tokens-3-20261112-*.json`. Icarus Verilog 13.0 has
11 pass and 2 known; Verilator 5.052 has 12 pass and 1 known for both seeds 1
and 73; kirimasim `7de185f776a1` has 12 pass and 1 unsupported. Every status
equals the one saved before.

The input digests of 8 checks of 7 requirements and of 2 records in
`coverage/test-matching-reviews.json` were refreshed. Three of the
requirements have check groups, so the baseline was written again with a
reason. Three observations, of 16.10, 25.7 and 27.4, now say that the
rejection of Verilator does not count.
