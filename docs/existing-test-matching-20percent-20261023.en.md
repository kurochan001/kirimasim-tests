<a id="既存テストの要求照合20超過の結果2026-10-23"></a>

# Existing-test requirement mapping: results exceeding 20% (2026-10-23)

[English](existing-test-matching-20percent-20261023.en.md) / [日本語](existing-test-matching-20percent-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current aggregates](behavior-coverage-summary.en.md) / [Mapping registry](test-requirement-matching.en.md) / [Progress and observations on accumulation](existing-test-matching-review-20261022.en.md)

The existing tests were repeatedly compared, and the provisional requirements coverage (test design) was 20.009741% (2,465/12,319 requirements). Achieved the target of exceeding 20%. With fixed denominator 12,319, 2,464 requirements exceed 20%. The current 2 digit representation is 20.01%, and the 6 digit is also shown to ensure the correct increment.

<a id="集計"></a>

## Aggregation

- Mapped requirements: initial 1,242 → 2,465 (1,223 added).
- Added mapping evidence: 1,296 entries, 418 tests. The scope is only the checked observations in each file.
- Tests with at least one mapping: 1,030 → 1,386. Of all 3,938 tests, 2,552 tests are not registered.
- Provisional requirement coverage (test design): 10.081987% → 20.009741% (20.01% when displayed to 2 digits).
- Requirements with recorded passes for current inputs: 754 → 1,292 (538 requirements added).
- Provisional execution verification coverage: 6.120627% → 10.487864% (1,292/12,319, displayed 10.49%).
- Finalized values: both design and execution remain unfinalized. Denominator approval, semantic deduplication, and existing pending interpretations remain outstanding.
- AND Collective evidence: 55 → 126 required. Do not combine partial successes from separate runs.
- Pending ledger: 372 tests and 504 entries → 406 tests and 546 entries (added 42 assessments).

Existing tests, expected output, C helpers, citation metadata, requirement definitions, and denominator are unchanged. Also retains the uncommitted 10% arrival job that existed at the start. This time, the original test is not rerunned, but the input and runner hash of the saved result is compared. Codex (AI) performed this work; it is not independently verified by a person. Not the percentage of completed reviews of the entire file, or the percentage of attempted combinations of all inputs.

<a id="今回確認した範囲"></a>

## Scope checked in this work

Reviewed numeric/string literals, generated bufif strength tests, operators, VPI UDP/value access/array API/registration data, random distributions, PLA, covergroup, randomize, display/input formats, SVA properties/sequences, clocking, checkers, assertion VPI, coverage API, FSM recognition, SDF annotation, specify paths, timing checks, interfaces, types/arrays/context API in DPI and Annex H, integer types, strings, classes/weak references, array/bit queries, process API, enum/typedef, soft constraints, UDP, covergroup inheritance/cross selection, subroutine lifetimes, VCD, program termination/exit, config binding, sampled-value functions, assertion controls, short-circuit/equality operators, VPI variable/net/instance/scope/expression/atomic-statement/process/primitive/assertion models, package initialization/std, generate external names, interface classes, string packing, SVA local variables, file positioning/binary fread, net truth tables, creation/release of VPI handles, interface/modport links, statement children and specify-path/timing-check observations. Independently recalculated the 19 pairs of return values and updated seeds in Annex N using LCG, IEEE float conversion, each distribution transformation, and rounding, and confirmed matches. Statistical convergence of distribution means/spreads is a separate unmapped requirement.

For example, compare bufif L/H with %v StL/PuH as well as %b x. SVA checks truth values at different times, match multiplicity, simultaneous earliest matches for first_match, implication's all-match requirement, and followed-by's existence condition using concrete ending times and pass/fail queues. For tests observing only part of a compound requirement, choose individual requirement mappings, a AND group containing every necessary test, or a reasoned hold.

<a id="追加した指摘保留"></a>

## Added findings and pending assessments

- M65: PLA output is a net. `test_pla_sync_snapshot_versus_async_update` declares output argument asynchronous as wire. 20.16 requires a variable lvalue, so its positive simulation mapping remains pending.
- M66: escape contents are not compared. Relevant `test_lexical_strings` cases mainly compare length; incorrect converted ASCII of the same length still passes. Do not treat newline/backslash/quote values as verified.
- M67: no stimulus for strength contention. The case described as strong override in `test_net_resolution_multi` has no competing pull driver.
- M68: the negative side of not's vacuity is unobserved. Not of `test_nonvacuous_evaluation_forms` can always be misclassified as nonvacuous and produce the same output. The temporary response of this inheritance rule was excluded in the audit.
- M69: set-expression construction timing alone is insufficient. `test_cg_bins_with_set_expr` does not verify invisibility of within-covergroup names. The complete compound row covering timing and visibility remains pending.
- M70: return-type signedness remains unchecked. `test_urandom_range_bounds` assigns to int unsigned, so it does not independently verify the function's own unsigned type. Mapped only the individual default/reverse rows.
- M71: the 1step description differs from the standard. `test_clocking_input_step_skew` describes a value after Observed/NBA, but the standard specifies the previous time step's value. Because the stimulus does not distinguish the two methods, this explanation cannot justify the expected value.
- M72: misses premature updates from off-event drives. The first read of `test_clocking_drive_between_edges` is after the next event. RHS capture is observable, but an update before the next event cannot be ruled out.
- M73: does not cite the cycle-drive definition clause. `test_clocking_output_skew_cycle_delay` does not cite 14.16 in the supplied edition. 14.16.1 alone did not accommodate different requirements, and the existing input was retained.
- M74: the bin-set expression references a module's variable queue. `bins picked[] = vals` in `test_cg_bins_with_set_expr` is inconsistent with the restrictions on variables permitted in the covergroup expression in 19.5. Standard-conformance cleanup is needed, such as using non-ref covergroup arguments.

- M75: checks only acceptance of coverage kinds. `test_coverage_api_minimum_types` allows anything other than ERROR, so it will pass the uncollected NOCOV. Kept evidence of actual collection behavior for each kind pending.
- M76: even all-0 satisfies scope sums and reset/stop checks. `test_coverage_scope_sums` and `test_coverage_reset_and_stop` require no nonzero control. Left scope-aggregation and control-effect registrations pending.
- M77: skips checks when collection fails to start. `test_vpi_coverage_assertion` and `test_coverage_fsm_pragma_states` produce expected output even if their start is not OK. Limit mappings to what is actually compared, such as the unconditional VPI maximum.
- M78: VPI control also passes with all-0. Held the control-effect mappings for `test_vpi_coverage_control` and `test_vpi_coverage_instance_control` because they do not verify collection before reset/stop and pass even when always 0.

- M79: Ordered connection of generic interface. `test_generic_interface_parameterized_instances` does not use the named port connection required by 25.3.3. Left the positive-case mapping pending regardless of expected width.
- M80: Compares the status of the DPI export task only with non-zero. Because `test_dpi_disable_import_task` is `!=0`, the test passes even if the return value specified by the standard, 1, is incorrectly implemented as 2 or similar. The disable state is observable, but the strict export-status row remains pending.
- M81: uses changes to a DPI input formal. `test_dpi_input_inout_semantics` advances input numeric values and pointers on the C side. Do not approve every input-protection requirement until the relationship among 35.5.1.2 formal-write prohibition, protection of actuals during changes and the const rule in H.8.7 is resolved.
- M82: compound conditions for scope API are unobserved. `test_dpi_context_scope` does not compare unknown-name handling, the previous-scope return value itself, or return values for unregistered userdata / errors. Registered the actually checked current scope/full name, leaving the full set of conditions including these pending.

- M83: incorrect expected dimension count for scalar logic. `test_array_multidim_query` expects `$dimensions(scalar_val)` to be 0, while the simple bit-vector definitions in 20.7 and 6.11.1 imply 1. We registered the size change of the correct test instead of using the entire file as the basis for the new match.
- M84: the basis for tag encoding of a 3-member tagged union is unverified. `test_tagged_union_packed` fixes the expected value at 00/01/10. It remains unresolved whether the minimum width/layout in 7.3.2 and 0/1 in the 2-member diagram justify declaration-order encoding for arbitrary member counts. Kept new approval for this file pending; checked tag/payload coupling with an encoding-independent pattern test.

Also left the soft-constraint handle-declaration-order compound row, including alias conditions, pending; recorded missing observations for `disable soft` when the target name occurs only in an enclosing condition or nonconflicting constraints are discarded. VCD is limited to comparing the value of raw with the declaration width, time, and section, and does not register unchecked header items or unstimulated types.

- M85: checks only whether the VPI config name is nonempty. `test_vpi_module_binding_properties` compares library/cell against concrete values, but any nonempty config passes. Left the requirement to return correct `vpiConfig` values pending.
- M86: The errors of future value and action delay can be compensated. `test_global_clocking_sampled_functions` uses the same global/assertion clock, comparing future-function evaluation and delayed actions at one queue time. An incorrect implementation replacing future with past while omitting action delay is indistinguishable, so this does not count toward individual future-value/delay requirements. Registered only the scope where a separate VPI test compares different event and callback execution times.
- M87: The negative API harness that terminates normally is not accepted by the management side. `test_vpi_chk_error_callbacks` is a valid negative test that checks the NULL return value and error status for invalid API, and the success of a callback permitted by the standard. The current validator limits error requirements to `should_fail_because` cases with stderr regexes and rejects registration in this form. Do not count this until the management format is explicitly extended and checked; existing test inputs were not changed to bypass the issue.
- M88: no combination condition of package export was observed. Positive output alone from `test_package_export_all` and `test_package_export_named_wildcard` cannot distinguish declaration identity across multiple re-export paths, export-before-import, or lack of re-export for unreferenced wildcard candidates. Left mappings to all requirements including these pending.

- M89: can pass even if bind is ignored. `test_bind_assertion_basic` compares DUT's ready but does not check bound-instance existence or pass/cover counts. Left the evidence for bind behavioral requirements pending.
- M90: does not execute cancellation of pending decay. The first decay in `test_trireg_charge_decay` expires at t30; redrive occurs at t40. The comment's condition of redriving before expiry to cancel is not stimulated. Registered only separate start/expiry requirements.
- M91: Differentiation of X output and X input of the generated net test. `test_gen_strength_tri0_16` supplies only 9 combinations of 0/1/Z. StX from opposing known values does not count as a truth-table cell with an X input driver. Restricted each known-value cell to cases whose active strength at that point matches the table's strong condition.
- M92: The relationship checks for non-NULL only are excluded by the reaudit. Withdrew 4 mappings that do not compare correct types, values, and identity of returned handles for class objects, nested tagged patterns, and do-while condition/body. Apply the same criteria as existing M60; checks that pass with an incorrect non-NULL handle are not evidence of one-to-one relations.

- M93: only compare if the constraint condition is not NULL. `test_vpi_constraint_items` does not check correct condition values or operators. Kept the condition relation itself pending, distinguishing it from group-type and iterator-count observations.
- M94: does not directly check NULL without a resolver. `none` in `test_vpi_nettype_declarations` also appears when the returned handle is non-NULL but its name is NULL. Left this pending as evidence for `vpiWith == NULL`.
- M95: enum last also equals the maximum value. 3/1/6 in `test_enum_first_last_num` is nonmonotonic, but last's 6 is also the numeric maximum. This cannot distinguish an incorrect implementation returning the maximum for last.
- M96: callback counts alone do not prove execution has not started. named begin/while in `test_vpi_statement_callbacks` does not compare timing against first block execution or condition side effects. Individual requirements for separate tests to compare side effects and time are registered.
- M97: no false-result control for string relational operators. `test_string_compare` checks `<`, `<=`, `>` and `>=` only with inputs making all true, so always returning 1 would pass. Left the full rules for each operator pending.

Rechecked the pending tag-encoding assessment for M84 and excluded 3 provisional width/layout mappings from the same file from final totals. Meanwhile, mapped the class-object relationship in M92 using an observation that distinguishes `c.v=7` in a separate fixture from the default value 0 of a separate object. The pending assessment for the original fixture is unchanged.

<a id="最終の保留整合監査"></a>

## Final pending-status consistency audit

Rechecked all newly added mappings against the existing hold ledger. The opening total of 2,465 requirements follows removal of 20 provisional mappings for 16 requirements with unresolved pending reasons, and addition of 20 mappings for 17 requirements from other existing tests. The interim 2,464-requirement aggregate was not directly finalized.

- string putc/getc: writes at valid indices alone do not verify the no-effect behavior of out-of-range/zero values or the index formal's type.
- sort/rsort: comparing every element for ordinary sort and only endpoints/the first element for with-sort does not establish ordering of every element by the projected key (M38).
- Property initialization / virtual methods: defaults after new do not prove initialization before the constructor body; virtual dispatch alone does not verify nonvirtual static binding (M33).
- `test_std_package_access`: this file is not used as new evidence here because of an existing oracle issue (M04) that fixes the successful try_get value at 1. The signature of self was verified by another thread identification fixture.
- Virtual initializers and interface parents in VPI: the displayed `none` can come from a NULL name on a non-NULL handle, as well as from NULL on the returned handle, so it was excluded as evidence for the requirement to return NULL.
- VPI vector uses: per-kind counts alone do not exclude incorrect same-kind targets (M60). Excluded case-item relationships because an existing helper issue makes inappropriate Lhs queries on other statements (M64).

The remaining overlap with a pending assessment for the same test/requirement concerns task-local lifetime overrides. A static local in the original automatic task checks only one direction; combining it with a separate file's automatic local in a static task as a AND set verifies both directions. Retained the pending assessment for the original partial observations.

The final additions checked out-of-range part-select reads and writes, indirect dependencies in localparam, automatic-local reinitialization, typed return values from process::self, concrete display-format conversions, the newline difference between write and display, and the return value of sformatf. Hex/octal grouping rules use a AND set requiring both fixtures. Format mappings observe concrete conversions; they do not establish uppercase-alias or all-input-combination verification.

Assessment target ID, input hashes, and stimulus anchors are recorded in `coverage/test-matching-reviews.json`.

<a id="分母証跡の保全"></a>

## Preserving the denominator and evidence

The denominator is 12,319 and its identifier is `d9e94724b317c8668673f4f4883c4923bf94caad46d79ba7c79e1fd16302e6ac`. Preserved requirement definitions, existing checks/AND sets, and prior hold decisions; the material index and PDF/extracted-text identifiers are also unchanged. Unmapped requirements, including 49 pending-interpretation rows, remain in the denominator.

<a id="検証"></a>

## Verification

Checked the management tools' 74 tests, requirement coverage and material-hash validation, mapping ledger, suite statistics/catalog/per-clause test counts (at least 2 tests), generated-test reproducibility, metadata lint, and `git diff --check`. Comparison with the starting snapshot also verified preservation of requirement definitions, existing checks/AND sets, existing hold decisions, preexisting history, the fixed denominator, and material index. It is not achieved by rerunning the original SystemVerilog /C test or adding new tests.
