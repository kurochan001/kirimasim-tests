<a id="review-of-spec-only-tests-2026-11-09"></a>

# Review of spec-only tests (2026-11-09)

[English](spec-only-review-20261109.en.md) / [日本語](spec-only-review-20261109.md)

[Review candidates for expected results](review-candidates.en.md) / [Differences between simulators and the standard](simulator-differences.md) / [Review of tests disagreeing with Lyra](lyra-disagreement-review-20261025.en.md)

At the request of an external review, the first two kinds of [review candidates](review-candidates.en.md) were checked against the text of the standard:

- the 30 spec-only tests failing on Ghost, kirimasim and Lyra
- the 21 spec-only tests passing on kirimasim alone

The candidates come from the first record (results branch `32fb7b7f`) of the manual Nightly of 2026-11-08 ([run 42477954992](https://github.com/kurochan001/kirimasim-tests/actions/runs/42477954992), suite commit `36ba5dd1`).
Lyra's results in it are those of `3ee7454c` from 2026-11-06.
An AI (Claude) did the review. It is not an independent human check, so `:spec_check: ai` is unchanged.
kirimasim and Lyra share slang as their front end, so their agreement on parsing and elaboration is not independent evidence.

<a id="summary"></a>

## Summary

| Kind | Tests | Result of the review |
| --- | ---: | --- |
| Spec only, failing on Ghost, kirimasim and Lyra | 30 | Four tests had wrong expectations and two contained a point where the standard disagrees with itself; all six were fixed. The other 24 expectations are right, and the simulators lack the feature or get it wrong |
| Spec only, passing on kirimasim alone | 21 | All 21 expectations were confirmed. Six of them also pass on Lyra `ed6c62dc` |

<a id="fixed-tests"></a>

## Fixed tests

| Test | Clauses | Error and fix |
| --- | --- | --- |
| `ch10/test_syntax_assignment_pattern_forms` | 10.9, 6.21 | An assignment pattern has no self-determined type and can be one side of an assignment only when the other side has one. The two places assigning an untyped pattern to an lvalue pattern were illegal; their right sides are now the typed pattern `nib2_t'{...}`. `tr`, declared with an initializer in an `initial` block, is now declared `static`. The expected output is unchanged |
| `ch16/test_deferred_flush_points` | 9.2.2.2.1, 9.2.2.3, 16.4.2 | The implicit sensitivity of an always_latch leaves out `lq`, which the block itself writes, so the update of `lq` does not resume the block and the failure at t=15 is not flushed. The block now reads `lqc`, a continuous copy of `lq`, so the test checks the flush on resumption. The expected output is unchanged |
| `ch16/test_syntax_deferred_immediate_assertions` | 16.4 | The expression of a deferred assertion and the arguments its action takes by value are evaluated when the statement is reached; only the report and the action are deferred. The test assumed the opposite. It was rewritten so that each check is true when reached and false after the next assignment, and each action prints the value at the statement |
| `ch23/test_syntax_port_expression_and_explicit_ports` | 10.3.2, 6.5, 23.3.3, 21.2.1.3 | The variable `w`, driven by a continuous assignment through an input port, had an initializer, which is illegal; it was removed. The 8-bit `hi` and `lo` print two digits with `%h`, so the expected output is now `hi=0a lo=05` |
| `ch20/test_array_query_types_and_invalid` | 20.7, 6.16 | A point where the standard disagrees with itself: 20.7 gives `$dimensions` of the string type the value 1 but makes it an error to use these functions directly on a dynamically sized type identifier, and 6.16 calls strings dynamic. The test now queries a string variable; [recorded in the differences](simulator-differences.md#dimensions-of-string-type) |
| `ch33/test_config_declaration_grammar_forms` | 33.4.1 (Syntax 33-4), A.1.5, 33.4.3 | A point where the standard disagrees with itself: the grammar writes the parameter assignments of a use clause without `#`, the examples of 33.4.3 with `#(...)`. The use clause no longer assigns a parameter and the default value is expected; [recorded in the differences](simulator-differences.md#config-use-parameter-form) |

Three of the fixed tests now match on kirimasim `33cee3fa` (the two `ch16` tests and `ch33`).
`ch10` and `ch23` are unsupported there, for lvalue assignment patterns and ref ports.
`ch20` still fails, because slang reports an error where 20.7 returns `'x` for a constant dimension out of range.
In the ledger, the 28 mappings that rest on these tests have new quoted strings, observations and input digests.

<a id="rules-checked-against-the-standard"></a>

## Rules checked against the standard

The expectations of these tests follow from the standard.

| Test | Clauses | Finding |
| --- | --- | --- |
| `ch10/test_illegal_force_mixed_driven_variable` | 10.6.2, 6.5 | forcing a variable with both continuous and procedural assignments is illegal |
| `ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects` | 11.4.14.1, 11.4.14.3 | the standard covers streaming class handles and null; kirimasim's and Lyra's "not a bit-stream type" is a missing feature |
| `ch13/test_illegal_constant_function_call_in_constant_context` | 13.4.3 | a function that calls a constant function where a constant expression is required is not a constant function |
| `ch16/test_illegal_final_deferred_postponed_call` | 16.4, 4.4.2.9 | a final action may call only what can be called in the Postponed region, not a task that writes a variable |
| `ch20/test_illegal_bits_function_dynamic_return` | 20.6.2 | `$bits` around a function returning a dynamically sized type is an error |
| `ch20/test_illegal_isunbounded_variable` | 20.6.3 | the argument shall be a parameter name |
| `ch20/test_illegal_timeformat_unit_out_of_range` | 20.4.3, Table 20-2 | units and precision range from 2 to -15 |
| `ch22/test_illegal_begin_keywords_without_end` | 22.14 | `` `begin_keywords `` and `` `end_keywords `` are used in pairs |
| `ch22/test_illegal_line_directive_trailing_comment` | 22.12 | no comment on the line of `` `line `` |
| `ch23/test_23_extra_uwire_dominates` and four other uwire tests | 23.3.3.7 (Table 23-1), 23.3.3.6, 6.6.2 | uwire is forbidden only on terminals of bidirectional pass switches, not on inout ports; the values follow Table 23-1 |
| `ch23/test_port_collapse_supply_cells`, `ch23/test_port_collapse_value_external_cells` | 23.3.3.7 (key of Table 23-1) | the external type is used and a warning is issued |
| the three `ch25/test_illegal_modport_import_*` tests | 25.7, 13.5.4 | default arguments and binding by name need a full prototype in the modport |
| two `ch5` and three `ch6` tests (parentheses, escape, chandle, static variables) | 5.13, 13.4.1, 5.9.1, 6.14, 6.21 | a select after a built-in method without parentheses, z after an octal escape, a chandle in an event control and an initialized static variable without the keyword are all illegal |
| `ch6/test_user_nettype_resolution_forms` | 6.6.7, 6.7.2, 6.7.3, 10.3.2 | an element of an array of nets of a nettype is one net and can be driven whole; a renamed nettype keeps its resolution function |
| `ch6/test_illegal_type_parameter_scope_prefix_in_variable`, `ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration` | 6.20.3, 8.23 | declaring a variable with a type selected through a type-parameter prefix is illegal |
| `ch7/test_illegal_union_holding_struct_member_default` | 7.2.2 | members of an unpacked structure containing a union take no default values |
| `ch8/test_illegal_interface_method_default_not_constant` | 8.26.8 | defaults of interface class methods are constant expressions |
| `gen/ch10/test_gen_cross_force_pca_const_source_blocking_monitor_hier` | 10.6.1, 10.6.2 | release reestablishes the procedural continuous assignment |
| the nine `gen/ch28/test_gen_cross_gatearray_*` tests | 28.3.6, 28.4 to 28.7, 28.16 (Table 28-9) | the split of connections to arrays of gates, the truth tables and the choice of delays agree with the generator |
| `gen/ch13/test_gen_cross_litarg_fillx_bit8_default_plain` | 13.5.3, 6.11 | a default of `'x` becomes 0 in a bit argument |
| the two `gen/ch3/test_gen_cross_timescope_nested_interface_*` tests | 3.14, 20.3, 20.4.3 | a nested interface takes the time unit of the enclosing one |
| the three `gen/ch4/test_gen_cross_sense_*_unread_*` tests | 9.2.2.2.1, 9.2.2.3, 11.5.3 | the implicit sensitivity is the longest static prefix read, so writing another member of the structure does not wake the block |

<a id="points-left-as-they-are"></a>

## Points left as they are

The standard leaves room in these points, but no simulator disagrees with the tests on them now, so the tests are unchanged.

- Line 35 of `ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration`, `holder_c #(T::nib_t)`: the grammar does not make clear whether "type parameter assignments" in 8.23 include a specialization `#(...)`.
- `ch25/test_illegal_modport_prototype_unnamed_named_binding`: the rule is written about the prototype, so a tool may report the modport line instead of the call.
- `ch16/test_illegal_final_deferred_postponed_call`: kirimasim detects it at run time. Depending on the order of the `initial` block and `always @(a)` at time 0, a run-time check might not be reached.
- The five uwire and supply port tests: 23.3.3.7 makes merging the nets permissible, so the values are those of a tool that merges.
- `ch22/test_illegal_begin_keywords_without_end`: 22.14 requires the pair but does not say "it shall be an error".
