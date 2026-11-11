<a id="oracle-token-review-2026-11-12"></a>

# Review of the oracle tokens of illegal tests (2026-11-12)

[English](oracle-token-review-20261112.en.md) / [日本語](oracle-token-review-20261112.md)

This record says which `iverilog@13.0` and `verilator@5.052` tokens were
removed from the `:oracle:` of illegal tests, why, and what is not checked
yet. No test changed its code or its expected result.

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
  for an extern task in an interface, where it is legal. The test keeps
  `verilator@5.052`.
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

## What is not checked yet

- 296 illegal tests list `iverilog@13.0` and the error on their marked line is
  not a syntax error. Their messages are recorded, but they were not compared
  with the rule one by one.
- Four tokens are doubtful and stay. Three tests of chapter 33 state rules of
  the grammar of a config (`test_illegal_config_default_use`,
  `test_illegal_config_design_after_rule`,
  `test_illegal_config_two_design_statements`), but Icarus Verilog 13.0 only
  parses a config and then skips it. `ch35/test_35_rest_dpi_class_formal`
  lists Verilator 5.052, which words its error as unsupported, although the
  standard forbids the construct.

After this change, 1,975 tests are illegal designs; 918 of them list
`iverilog@13.0` and 544 list `verilator@5.052`.

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
