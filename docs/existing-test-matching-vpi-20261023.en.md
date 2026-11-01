<a id="既存テストの要求照合vpiと10到達2026-10-23"></a>

# Existing-test requirement matching: VPI and 10% milestones reached (2026-10-23)

[English](existing-test-matching-vpi-20261023.en.md) / [日本語](existing-test-matching-vpi-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current aggregates](behavior-coverage-summary.en.md) / [Mapping registry](test-requirement-matching.en.md) / [Progress and observations on accumulation](existing-test-matching-review-20261022.en.md)

Repeated existing-test mapping until provisional design requirement coverage exceeded 10%. The final value is 10.081987% (1,242/12,319 requirement). The rounded value for display is 10.08%. In fixed denominator 12,319, the 1,232 line goes beyond 10%. The final audit excluded insufficient provisional coverage and confirmed additional evidence, resulting in the 1,242 line. This is a provisional value for the requirement registry before the duplication sort, and not the proportion of all input combinations tested or the standard fit rate of a single simulator.

<a id="最終結果"></a>

## Final results

- Mapped requirements: 810 → 1,242 rows (432 added).
- Added mapping evidence: 442 entries, 55 tests. The test with at least one corresponding is 975 tests → 1,030 tests.
- Of all 3,938 tests, 2,908 lack registered mappings. The mapping based on the verification content of all tests is still incomplete.
- Provisional requirement coverage (test design): 6.58% → 10.08%.
- Requirements with recorded pass results for the current inputs: 718 rows → 754 rows (36 additional rows).
- Provisional execution verification coverage: 5.83% → 6.12% (754/12,319).
- Finalized values: both design and execution remain unfinalized. Denominator approval, semantic deduplication and resolution of interpretation issues remain outstanding.
- Set-level evidence: 50 → 55 requirements. This 5 requirement also handles all members as AND.
- Decisions to hold mappings: added 39 entries; the ledger grew from 465 entries across 345 files to 504 entries across 372 files.

The scope is the checked observations in 57 tests with added mappings or recorded pending decisions. 55 This does not mean that all functions of the tests have been examined. Codex (AI) performed this work; it is not independently verified by a person.

<a id="照合の反復と採用基準"></a>

## Repetition of comparison and adoption criteria

First, we checked the variables, net, parameter, type name, and attribute, and proceeded to the 866 line. There are 942 lines for type information, unpacked / packed arrays, structures, and memory; 1,028 for ports, subroutines, clocking, and selects; 1,096 for generate, hierarchy, classes, and constraints; and 1,179 for properties/sequences, let, and statements. Finally checked dynamic prefix, frame, interface, VPI API, and IO declaration, and confirmed attainment at 1,242 rows after the final audit. Reviewed provisional registrations in the final audit; excluded 3 cases using incorrect sources, substituting API, or failing to identify the parent. Added final post-audit measurements to history and retained all history predating this work.

Read `IEEE_Std_1800-2023_SystemVerilog.pdf` in the supplied materials and the relevant extracted-text clauses; checked relation diagrams by rendering PDF. The API, properties and relations called by the C helper are linked to the SV stimulus and the actual expected-output values. The requirement ID, acceptance criteria, and denominator have not been changed to increase the count. The display of mere quotations, definitions only, or fixed labels only is not adopted. Also avoid treating a single read of vpiType as coverage of general group membership in the figure.

For example, verified the following actual retrieval results.

- Net/variable signedness, widths, bounds, initial values, array-element names/full names/indices, and parent-handle identity.
- Stepwise Element traversal of multidimensional packed arrays, Index order from the inside, and flag differences between direct struct members and grandchildren.
- typedef names, alias targets, names and values of enum constants, typespec member types and defaults, and both NULL bounds and size0 for empty ranges.
- Port order, names, directions, widths and high/low connections; both NULL handles and size0 for a null formal.
- Clocking-block default skews and individual IO skew/edge; virtual-prefix Actual when null and after assignment.
- Actual class/constraint names and declaration order, extern-prototype position, static keyword, solve order, and dist kinds/ranges/weights.
- Property/sequence operators and operand order, strong/weak, clock names, let actual-argument order, and defaults for omitted arguments.
- Assignment LHS/RHS, blocking and compound operators, actual delay values, and the targets of force/release/assign/deassign.
- Difference between automatic variable and declaration from frame, all 3 values of allocation scheme, conditional values of HasActual.
- Actual routine pointer, NULL, and user data in VPI registration information; scaled time; writes through negative/descending multi-indices and reads on the SV side.

<a id="追加したand集合証拠"></a>

## Added AND collection evidence.

- Indexed access to 37.11: requires single index and multi-index 2 tests.
- The 37.19 constant select: constant/variable index and static/dynamic parent conditions are shared by the 2 tests.
- bit-select constant in 37.58: 2 tests divide coverage between index conditions and propagation from a nonconstant parent select.
- The 37.34 constraint order: the declaration position of the external prototype and the actual content order of the internal item are shared by the 2 tests.
- 37.48 clocking defaults: 2 tests jointly cover block/IO input/output skews and edges.

The execution confirmation is only available if all members are fresh passes in the same simulator and execution snapshot. Do not combine partial successes from different runs. Design mappings and execution success are distinguished too.

<a id="m59nullそのものを検査していない"></a>

## M59: does not check NULL itself

The else in `test_vpi_parameters`’s `if (left && right)` yields no range even when only one side is NULL. Some nettype/virtual-interface/interface-typespec helpers convert both NULL handles and valid handles named NULL to the same none. The 0 case/default expressions also do not distinguish an iterator that immediately ends its scan on a non-NULL result. These are not used to prove the obligation of "both boundaries NULL" and "With/Expr/Parent/iterator is NULL". For empty typespec ranges, one-sided absence has a distinct display and size0 is also read, so accepted that requirement.

<a id="m60存在や個数だけでは取得対象が正しいといえない"></a>

## M60: existence/count alone does not establish correct retrieval targets

Many child relations and do-while of control statements only check for the existence of a handle. Some checks for all instance-array elements, Use sets, and waiting-process sets likewise examine only counts or per-type counts. A nonactive parent frame in the same thread is also insufficient to identify the correct activating frame. Retrieving `vpiModule` from the module hierarchy also cannot establish a separate relation from a net to `vpiInstance`. Restricted mappings to individual relations distinguishable by actual values, names, types, or identity, and kept the broader claims pending.

<a id="m61提供2023版と参照節番号が合わない"></a>

## M61: The reference section number does not match the version of the 2023.

`test_vpi_delay_expressions` describes 37.75 as continuous assignment and 37.80 as primitives, but in the supplied PDF they are Do-while/foreach and Callback, respectively. The corresponding models are 37.47 and 37.35. The get_time citation in `test_vpi_time_queue` is also 38.11, and the supplied edition defines API as 38.13. In this case, we have not changed the citation to preserve the existing metadata and input hash, and we have reserved the correspondence to that section. If the reference number is corrected, it is also necessary to retrieve evidence for the input after the update.

<a id="m62複合要求の一部を行全体へ広げない"></a>

## M62: Do not extend part of the compound requirement to the entire row

Separately checked every scalar/vector kind; parent and leaf flags of packed arrays; element counts from bit width and range products; all typespec-unwind endpoints; range order including queues; struct and union member types; DPI import/export/pure/context; function size versus return-variable size; and class exclusions for static/automatic/event/built-in items. Partial observations are not assigned to the entire complex row. Restrict mappings to individual supported figure property/relation rows or AND sets. Even if the constraint is non-extern, the mere display of `!= vpiExternAcc` as 0 does not prove the actual value 0.

<a id="m63object-idの64bit値を検査していない"></a>

## M63: does not check Object ID's 64bit value

`test_vpi_class_obj_id.c` uses `vpi_get(vpiObjId, ...)` and `PLI_INT32`. Low-part comparison cannot verify the standard's 64bit property, so Object ID rows were not registered. The class-variable→typespec relation in which the same test retrieves named items was accepted as a separate observation.

<a id="m64kindに合わないlhs問い合わせ"></a>

## M64: a LHS query inappropriate for the object kind

`test_vpi_case_loop_force_stmts.c`'s describe_stmt performs a Lhs query to all statements before switching. It also queries case/foreach/do-while without LHS, so move the queries inside branches for the corresponding kinds. In this comparison, stimulus and helper were not changed, and the observation of non-NULL only of do-while was not accepted.

<a id="実行証跡保全検査"></a>

## Execution evidence, preservation and checks

Original simulation tests were not rerun. Compared the saved Icarus 13.0 / Verilator 5.052 and partial-run results against the current input SHA-256 and runner identifier. The 36 line has increased execution confirmation among the new 432 lines. Known, unsupported, and stale results are not treated as passes. The difference between execution verification coverage over 754 rows and design requirement coverage over 1,242 rows includes these unsuccessful cases.

Mechanically compared and preserved 12,319 requirement definitions, denominator identifier, material-audit results, existing checks/check_groups, and pending assessments. There are no changes to existing tests, expectations, metadata, C helper, and runners, and no new tests are added. Denominator SHA-256 is `d9e94724b317c8668673f4f4883c4923bf94caad46d79ba7c79e1fd16302e6ac`; the measurement-rule version is 3.

The 74 test of the management tool, the hash of the supply document, the consistency of the requirement compliance, the judgment table, the saved execution trace, the catalogue, the statistics, the depth, the product, the metadata, and the diff were carried out. The 2,908 unregistered tests and 504 pending entries remain for future mapping and are not considered complete.

<a id="今回追加した対応の索引"></a>

## Index of mappings added in this round

The following indexes the 442 additions. The complete ID of each request is followed by `SV2023-`. The stimulus, expectation output, C anchor, input SHA-256, and the person and date are in the checks of [behaviors.json](../coverage/behaviors.json). Indexing does not mean that the entire file has been checked.

- [test_vpi_array_var](../tests/ch37/test_vpi_array_var.sv) / [C](../tests/ch37/test_vpi_array_var.c): `37.17-EXTRACT-ARRAY-SIZE`, `37.17-EXTRACT-DIAGRAM-039`, `37.17-EXTRACT-DIAGRAM-040`, `37.17-EXTRACT-DIAGRAM-041`, `37.17-EXTRACT-DIAGRAM-045`, `37.17-EXTRACT-DIAGRAM-046`, `37.17-EXTRACT-DIAGRAM-074`, `37.17-EXTRACT-DIAGRAM-075`, `37.17-EXTRACT-DIAGRAM-076`, `37.17-EXTRACT-VARIABLE-ARRAY-INDICES`.
- [test_vpi_attribute_object](../tests/ch37/test_vpi_attribute_object.sv) / [C](../tests/ch37/test_vpi_attribute_object.c): `37.83-EXTRACT-DIAGRAM-001`, `37.83-EXTRACT-DIAGRAM-049`, `37.83-EXTRACT-DIAGRAM-050`, `37.83-EXTRACT-DIAGRAM-053`.
- [test_vpi_case_loop_force_stmts](../tests/ch37/test_vpi_case_loop_force_stmts.sv) / [C](../tests/ch37/test_vpi_case_loop_force_stmts.c): `37.12-EXTRACT-DIAGRAM-017`, `37.72-EXTRACT-DIAGRAM-001`, `37.72-EXTRACT-DIAGRAM-005`, `37.72-EXTRACT-DIAGRAM-006`, `37.75-EXTRACT-DIAGRAM-003`, `37.75-EXTRACT-DIAGRAM-005`, `37.75-EXTRACT-FOREACH-INDEXED-OBJECT`, `37.75-EXTRACT-FOREACH-INDICES`, `37.79-EXTRACT-DIAGRAM-001`, `37.79-EXTRACT-DIAGRAM-002`, `37.79-EXTRACT-DIAGRAM-003`, `37.79-EXTRACT-DIAGRAM-004`, `37.79-EXTRACT-DIAGRAM-005`, `37.79-EXTRACT-DIAGRAM-006`.
- [test_vpi_class_definitions](../tests/ch37/test_vpi_class_definitions.sv) / [C](../tests/ch37/test_vpi_class_definitions.c): `37.31-EXTRACT-CLASS-PARAMETERS`, `37.31-EXTRACT-DERIVED-CLASSES`, `37.31-EXTRACT-DIAGRAM-002`, `37.31-EXTRACT-DIAGRAM-003`, `37.31-EXTRACT-DIAGRAM-004`, `37.31-EXTRACT-DIAGRAM-006`, `37.31-EXTRACT-DIAGRAM-010`, `37.31-EXTRACT-DIAGRAM-012`, `37.31-EXTRACT-DIAGRAM-014`, `37.31-EXTRACT-DIAGRAM-016`, `37.31-EXTRACT-DIAGRAM-026`, `37.31-EXTRACT-DIAGRAM-027`.
- [test_vpi_class_obj_id](../tests/ch37/test_vpi_class_obj_id.sv) / [C](../tests/ch37/test_vpi_class_obj_id.c): `37.33-EXTRACT-DIAGRAM-002`.
- [test_vpi_clocking_blocks](../tests/ch37/test_vpi_clocking_blocks.sv) / [C](../tests/ch37/test_vpi_clocking_blocks.c): `37.48-EXTRACT-CLOCKING-DEFAULTS`, `37.48-EXTRACT-CLOCKING-IO-EXPRESSION`, `37.48-EXTRACT-DIAGRAM-001`, `37.48-EXTRACT-DIAGRAM-002`, `37.48-EXTRACT-DIAGRAM-003`, `37.48-EXTRACT-DIAGRAM-004`, `37.48-EXTRACT-DIAGRAM-006`, `37.48-EXTRACT-DIAGRAM-016`, `37.48-EXTRACT-DIAGRAM-017`, `37.48-EXTRACT-DIAGRAM-020`, `37.48-EXTRACT-DIAGRAM-024`.
- [test_vpi_clocking_edges_prefix](../tests/ch37/test_vpi_clocking_edges_prefix.sv) / [C](../tests/ch37/test_vpi_clocking_edges_prefix.c): `37.48-EXTRACT-CLOCKING-DEFAULTS`, `37.48-EXTRACT-CLOCKING-VIRTUAL-PREFIX`, `37.48-EXTRACT-DIAGRAM-005`, `37.48-EXTRACT-DIAGRAM-012`, `37.48-EXTRACT-DIAGRAM-013`, `37.48-EXTRACT-DIAGRAM-014`, `37.48-EXTRACT-DIAGRAM-015`, `37.48-EXTRACT-DIAGRAM-018`, `37.48-EXTRACT-DIAGRAM-019`, `37.48-EXTRACT-DIAGRAM-021`, `37.48-EXTRACT-DIAGRAM-022`.
- [test_vpi_constant_select](../tests/ch37/test_vpi_constant_select.sv) / [C](../tests/ch37/test_vpi_constant_select.c): `37.19-EXTRACT-DIAGRAM-006`, `37.19-EXTRACT-SELECT-CONSTANT`, `37.58-EXTRACT-BIT-SELECT-CONSTANT`, `37.58-EXTRACT-DIAGRAM-014`.
- [test_vpi_constraint_items](../tests/ch37/test_vpi_constraint_items.sv) / [C](../tests/ch37/test_vpi_constraint_items.c): `37.34-EXTRACT-CONSTRAINT-ORDER`, `37.34-EXTRACT-CONSTRAINT-STATIC`, `37.34-EXTRACT-DIAGRAM-008`, `37.34-EXTRACT-DIAGRAM-010`, `37.34-EXTRACT-DIAGRAM-011`, `37.38-EXTRACT-DIAGRAM-017`, `37.38-EXTRACT-DIAGRAM-018`, `37.38-EXTRACT-FOREACH-ARRAY`, `37.38-EXTRACT-FOREACH-LOOP-VARS`.
- [test_vpi_constraint_orderings_dists](../tests/ch37/test_vpi_constraint_orderings_dists.sv) / [C](../tests/ch37/test_vpi_constraint_orderings_dists.c): `37.34-EXTRACT-CONSTRAINT-ORDER`, `37.34-EXTRACT-DIAGRAM-002`, `37.34-EXTRACT-DIAGRAM-003`, `37.34-EXTRACT-DIAGRAM-004`, `37.34-EXTRACT-DIAGRAM-013`, `37.34-EXTRACT-DIAGRAM-014`, `37.34-EXTRACT-DIAGRAM-015`, `37.34-EXTRACT-DIAGRAM-016`, `37.34-EXTRACT-DIAGRAM-018`, `37.34-EXTRACT-DIAGRAM-019`, `37.34-EXTRACT-DIAGRAM-020`, `37.34-EXTRACT-DIAGRAM-021`, `37.38-EXTRACT-DIAGRAM-008`, `37.38-EXTRACT-DIAGRAM-009`, `37.38-EXTRACT-DIAGRAM-010`, `37.38-EXTRACT-DIAGRAM-011`, `37.38-EXTRACT-DIAGRAM-015`, `37.38-EXTRACT-DIAGRAM-016`.
- [test_vpi_cont_assign_bits_delays](../tests/ch37/test_vpi_cont_assign_bits_delays.sv) / [C](../tests/ch37/test_vpi_cont_assign_bits_delays.c): `37.47-EXTRACT-ASSIGN-BIT-SCALAR`, `37.47-EXTRACT-ASSIGN-VALUE-CALLBACK`, `37.47-EXTRACT-DIAGRAM-001`, `37.47-EXTRACT-DIAGRAM-003`, `37.47-EXTRACT-DIAGRAM-004`, `37.47-EXTRACT-DIAGRAM-006`, `37.47-EXTRACT-DIAGRAM-008`.
- [test_vpi_control_statement_child_relations](../tests/ch37/test_vpi_control_statement_child_relations.sv) / [C](../tests/ch37/test_vpi_control_statement_child_relations.c): `37.66-EXTRACT-DIAGRAM-003`, `37.77-EXTRACT-DIAGRAM-003`.
- [test_vpi_file_line](../tests/ch37/test_vpi_file_line.sv) / [C](../tests/ch37/test_vpi_file_line.c): `37.3.3-EXTRACT-LOCATION`, `37.10-EXTRACT-DIAGRAM-061`, `37.10-EXTRACT-DIAGRAM-062`.
- [test_vpi_frames_threads_alloc](../tests/ch37/test_vpi_frames_threads_alloc.sv) / [C](../tests/ch37/test_vpi_frames_threads_alloc.c): `37.3.7-EXTRACT-ALLOCATION-SCHEME`, `37.12-EXTRACT-DIAGRAM-034`, `37.33-EXTRACT-DIAGRAM-004`, `37.43-EXTRACT-DIAGRAM-002`, `37.43-EXTRACT-DIAGRAM-005`, `37.43-EXTRACT-DIAGRAM-007`, `37.43-EXTRACT-DIAGRAM-009`, `37.44-EXTRACT-DIAGRAM-006`, `37.61-EXTRACT-HAS-ACTUAL-AUTOMATIC-FRAME`, `37.61-EXTRACT-HAS-ACTUAL-STATIC-ELABORATED`, `37.61-EXTRACT-NO-ACTUAL-AUTOMATIC-DECLARATION`.
- [test_vpi_generate_scope_contents](../tests/ch37/test_vpi_generate_scope_contents.sv) / [C](../tests/ch37/test_vpi_generate_scope_contents.c): `37.12-EXTRACT-DIAGRAM-046`, `37.12-EXTRACT-DIAGRAM-048`, `37.12-EXTRACT-DIAGRAM-055`, `37.85-EXTRACT-DIAGRAM-066`, `37.85-EXTRACT-DIAGRAM-070`, `37.85-EXTRACT-GENERATE-LOCALPARAMS`.
- [test_vpi_generate_scopes](../tests/ch37/test_vpi_generate_scopes.sv) / [C](../tests/ch37/test_vpi_generate_scopes.c): `37.85-EXTRACT-DIAGRAM-006`, `37.85-EXTRACT-DIAGRAM-007`, `37.85-EXTRACT-DIAGRAM-009`, `37.85-EXTRACT-DIAGRAM-010`, `37.85-EXTRACT-DIAGRAM-012`, `37.85-EXTRACT-DIAGRAM-016`, `37.85-EXTRACT-DIAGRAM-018`, `37.85-EXTRACT-DIAGRAM-020`, `37.85-EXTRACT-DIAGRAM-070`, `37.85-EXTRACT-GENERATE-ARRAY-SIZE`, `37.85-EXTRACT-UNNAMED-GENERATE`.
- [test_vpi_instance_array_kinds](../tests/ch37/test_vpi_instance_array_kinds.sv) / [C](../tests/ch37/test_vpi_instance_array_kinds.c): `37.6-EXTRACT-DIAGRAM-001`, `37.6-EXTRACT-INSTANCE-INDEX`, `37.9-EXTRACT-DIAGRAM-001`, `37.9-EXTRACT-INSTANCE-INDEX`, `37.11-EXTRACT-ARRAY-RANGE-ORDER`, `37.11-EXTRACT-DIAGRAM-008`, `37.11-EXTRACT-DIAGRAM-009`, `37.11-EXTRACT-DIAGRAM-016`, `37.11-EXTRACT-DIAGRAM-019`, `37.11-EXTRACT-DIAGRAM-023`, `37.35-EXTRACT-DIAGRAM-010`, `37.35-EXTRACT-PRIMITIVE-INDEX`.
- [test_vpi_instance_arrays](../tests/ch37/test_vpi_instance_arrays.sv) / [C](../tests/ch37/test_vpi_instance_arrays.c): `37.11-EXTRACT-DIAGRAM-010`, `37.11-EXTRACT-DIAGRAM-011`, `37.11-EXTRACT-DIAGRAM-021`, `37.11-EXTRACT-DIAGRAM-022`, `37.11-EXTRACT-DIAGRAM-023`.
- [test_vpi_interconnect_elements](../tests/ch37/test_vpi_interconnect_elements.sv) / [C](../tests/ch37/test_vpi_interconnect_elements.c): `37.24-EXTRACT-DIAGRAM-005`, `37.24-EXTRACT-INTERCONNECT-ELEMENT-LEVEL`.
- [test_vpi_interface_typespecs](../tests/ch37/test_vpi_interface_typespecs.sv) / [C](../tests/ch37/test_vpi_interface_typespecs.c): `37.30-EXTRACT-DIAGRAM-001`, `37.30-EXTRACT-DIAGRAM-004`, `37.30-EXTRACT-DIAGRAM-005`, `37.30-EXTRACT-INTERFACE-TYPE-DEFINITION`.
- [test_vpi_io_decl_ref_objs](../tests/ch37/test_vpi_io_decl_ref_objs.sv) / [C](../tests/ch37/test_vpi_io_decl_ref_objs.c): `37.13-EXTRACT-DIAGRAM-001`, `37.13-EXTRACT-DIAGRAM-007`, `37.13-EXTRACT-DIAGRAM-010`, `37.13-EXTRACT-DIAGRAM-011`, `37.13-EXTRACT-DIAGRAM-018`, `37.15-EXTRACT-DIAGRAM-008`, `37.15-EXTRACT-DIAGRAM-012`, `37.15-EXTRACT-DIAGRAM-013`, `37.15-EXTRACT-REF-DEFINITION`, `37.15-EXTRACT-REF-PARENT`, `37.15-EXTRACT-REF-TYPESPEC`.
- [test_vpi_iterator_objects](../tests/ch37/test_vpi_iterator_objects.sv) / [C](../tests/ch37/test_vpi_iterator_objects.c): `37.84-EXTRACT-DIAGRAM-001`, `37.84-EXTRACT-DIAGRAM-002`, `37.84-EXTRACT-ITERATOR-REFERENCE`.
- [test_vpi_let_expr_arguments](../tests/ch37/test_vpi_let_expr_arguments.sv) / [C](../tests/ch37/test_vpi_let_expr_arguments.c): `37.57-EXTRACT-LET-ARGUMENT-ORDER`.
- [test_vpi_lifetime_properties](../tests/ch37/test_vpi_lifetime_properties.sv) / [C](../tests/ch37/test_vpi_lifetime_properties.c): `37.10-EXTRACT-DIAGRAM-074`, `37.17-EXTRACT-DIAGRAM-079`, `37.41-EXTRACT-DIAGRAM-019`.
- [test_vpi_memory_word_objects](../tests/ch37/test_vpi_memory_word_objects.sv) / [C](../tests/ch37/test_vpi_memory_word_objects.c): `37.10-EXTRACT-DIAGRAM-032`, `37.10-EXTRACT-MEMORY-ARRAY`, `37.12-EXTRACT-DIAGRAM-044`, `37.20-EXTRACT-DIAGRAM-001`, `37.20-EXTRACT-DIAGRAM-003`, `37.20-EXTRACT-DIAGRAM-005`, `37.20-EXTRACT-DIAGRAM-006`, `37.20-EXTRACT-DIAGRAM-007`, `37.20-EXTRACT-DIAGRAM-008`, `37.20-EXTRACT-DIAGRAM-009`, `37.20-EXTRACT-DIAGRAM-010`, `37.20-EXTRACT-DIAGRAM-011`, `37.20-EXTRACT-MEMORY-METHODS`.
- [test_vpi_module_hierarchy](../tests/ch37/test_vpi_module_hierarchy.sv) / [C](../tests/ch37/test_vpi_module_hierarchy.c): `37.10-EXTRACT-DIAGRAM-012`, `37.10-EXTRACT-DIAGRAM-028`, `37.10-EXTRACT-DIAGRAM-063`, `37.16-EXTRACT-DIAGRAM-029`, `37.16-EXTRACT-DIAGRAM-074`, `37.17-EXTRACT-DIAGRAM-022`.
- [test_vpi_module_relations](../tests/ch37/test_vpi_module_relations.sv) / [C](../tests/ch37/test_vpi_module_relations.c): `37.5-EXTRACT-DIAGRAM-002`, `37.5-EXTRACT-DIAGRAM-003`, `37.5-EXTRACT-DIAGRAM-004`, `37.5-EXTRACT-DIAGRAM-005`, `37.5-EXTRACT-DIAGRAM-037`, `37.5-EXTRACT-DIAGRAM-042`, `37.5-EXTRACT-MODULE-INDEX`, `37.76-EXTRACT-DIAGRAM-001`, `37.76-EXTRACT-DIAGRAM-003`, `37.76-EXTRACT-DIAGRAM-004`.
- [test_vpi_named_events](../tests/ch37/test_vpi_named_events.sv) / [C](../tests/ch37/test_vpi_named_events.c): `37.27-EXTRACT-DIAGRAM-001`, `37.27-EXTRACT-DIAGRAM-005`, `37.27-EXTRACT-DIAGRAM-009`, `37.27-EXTRACT-DIAGRAM-011`, `37.27-EXTRACT-DIAGRAM-018`, `37.27-EXTRACT-DIAGRAM-022`, `37.27-EXTRACT-DIAGRAM-027`.
- [test_vpi_net_properties](../tests/ch37/test_vpi_net_properties.sv) / [C](../tests/ch37/test_vpi_net_properties.c): `37.16-EXTRACT-DIAGRAM-046`, `37.16-EXTRACT-DIAGRAM-047`, `37.16-EXTRACT-DIAGRAM-060`, `37.16-EXTRACT-DIAGRAM-061`, `37.16-EXTRACT-DIAGRAM-072`, `37.16-EXTRACT-DIAGRAM-077`, `37.16-EXTRACT-DIAGRAM-079`, `37.16-EXTRACT-DIAGRAM-081`, `37.16-EXTRACT-DIAGRAM-082`, `37.16-EXTRACT-DIAGRAM-086`, `37.16-EXTRACT-IMPLICIT-NET-LOCATION`.
- [test_vpi_nettype_alias_chain_relations](../tests/ch37/test_vpi_nettype_alias_chain_relations.sv) / [C](../tests/ch37/test_vpi_nettype_alias_chain_relations.c): `37.23-EXTRACT-DIAGRAM-001`, `37.23-EXTRACT-DIAGRAM-004`, `37.23-EXTRACT-NETTYPE-ALIAS`.
- [test_vpi_nettype_declarations](../tests/ch37/test_vpi_nettype_declarations.sv) / [C](../tests/ch37/test_vpi_nettype_declarations.c): `37.23-EXTRACT-DIAGRAM-003`.
- [test_vpi_object_access_basics](../tests/ch37/test_vpi_object_access_basics.sv) / [C](../tests/ch37/test_vpi_object_access_basics.c): `37.3.1-EXTRACT-HANDLE-ACCESS`, `37.3.1-EXTRACT-ONE-TO-ONE`, `37.5-EXTRACT-DIAGRAM-001`, `37.5-EXTRACT-DIAGRAM-021`, `37.5-EXTRACT-DIAGRAM-041`, `37.5-EXTRACT-TOP-MODULES`, `37.10-EXTRACT-DIAGRAM-065`, `37.10-EXTRACT-DIAGRAM-066`, `37.10-EXTRACT-DIAGRAM-068`, `37.10-EXTRACT-DIAGRAM-069`, `37.10-EXTRACT-ROOT-TIME`.
- [test_vpi_packed_array_levels](../tests/ch37/test_vpi_packed_array_levels.sv) / [C](../tests/ch37/test_vpi_packed_array_levels.c): `37.17-EXTRACT-DIAGRAM-047`, `37.17-EXTRACT-DIAGRAM-067`, `37.17-EXTRACT-DIAGRAM-084`, `37.17-EXTRACT-VARIABLE-STRUCT-MEMBER`, `37.18-EXTRACT-PACKED-ELEMENT-LEVEL`, `37.18-EXTRACT-PACKED-INDEX-ORDER`, `37.18-EXTRACT-PACKED-MEMBER-FLAG`, `37.18-EXTRACT-PACKED-STRUCT-FLAG`, `37.26-EXTRACT-DIAGRAM-002`.
- [test_vpi_packed_array_vars](../tests/ch37/test_vpi_packed_array_vars.sv) / [C](../tests/ch37/test_vpi_packed_array_vars.c): `37.18-EXTRACT-DIAGRAM-001`, `37.18-EXTRACT-DIAGRAM-002`, `37.18-EXTRACT-DIAGRAM-003`, `37.18-EXTRACT-DIAGRAM-004`, `37.18-EXTRACT-DIAGRAM-005`.
- [test_vpi_parameters](../tests/ch37/test_vpi_parameters.sv) / [C](../tests/ch37/test_vpi_parameters.c): `37.28-EXTRACT-DIAGRAM-003`, `37.28-EXTRACT-DIAGRAM-007`, `37.28-EXTRACT-DIAGRAM-008`, `37.28-EXTRACT-DIAGRAM-011`, `37.28-EXTRACT-DIAGRAM-015`, `37.28-EXTRACT-DIAGRAM-016`, `37.28-EXTRACT-DIAGRAM-017`, `37.28-EXTRACT-DIAGRAM-024`, `37.28-EXTRACT-DIAGRAM-028`.
- [test_vpi_ports](../tests/ch37/test_vpi_ports.sv) / [C](../tests/ch37/test_vpi_ports.c): `37.14-EXTRACT-DIAGRAM-003`, `37.14-EXTRACT-DIAGRAM-005`, `37.14-EXTRACT-DIAGRAM-009`, `37.14-EXTRACT-DIAGRAM-010`, `37.14-EXTRACT-DIAGRAM-013`, `37.14-EXTRACT-DIAGRAM-015`, `37.14-EXTRACT-DIAGRAM-016`, `37.14-EXTRACT-DIAGRAM-018`, `37.14-EXTRACT-DIAGRAM-019`, `37.14-EXTRACT-DIAGRAM-020`, `37.14-EXTRACT-NULL-PORT`, `37.14-EXTRACT-PORT-NAME`, `37.14-EXTRACT-PORT-ORDER`.
- [test_vpi_prefix_has_actual](../tests/ch37/test_vpi_prefix_has_actual.sv) / [C](../tests/ch37/test_vpi_prefix_has_actual.c): `37.61-EXTRACT-DIAGRAM-001`, `37.61-EXTRACT-DIAGRAM-002`, `37.61-EXTRACT-HAS-ACTUAL-PREFIX-PRESENT`, `37.61-EXTRACT-NO-ACTUAL-PREFIX-ABSENT`.
- [test_vpi_process_statements](../tests/ch37/test_vpi_process_statements.sv) / [C](../tests/ch37/test_vpi_process_statements.c): `37.63-EXTRACT-DIAGRAM-004`, `37.63-EXTRACT-DIAGRAM-006`, `37.63-EXTRACT-DIAGRAM-011`, `37.64-EXTRACT-ASSIGNMENT-OP-TYPE`, `37.64-EXTRACT-DIAGRAM-001`, `37.64-EXTRACT-DIAGRAM-002`, `37.64-EXTRACT-DIAGRAM-003`, `37.64-EXTRACT-DIAGRAM-006`, `37.64-EXTRACT-DIAGRAM-007`, `37.65-EXTRACT-DIAGRAM-001`, `37.65-EXTRACT-DIAGRAM-002`, `37.68-EXTRACT-DIAGRAM-001`, `37.68-EXTRACT-DIAGRAM-003`.
- [test_vpi_property_sequence_decls](../tests/ch37/test_vpi_property_sequence_decls.sv) / [C](../tests/ch37/test_vpi_property_sequence_decls.c): `37.12-EXTRACT-DIAGRAM-024`, `37.12-EXTRACT-DIAGRAM-026`, `37.51-EXTRACT-DIAGRAM-002`, `37.51-EXTRACT-DIAGRAM-007`, `37.51-EXTRACT-DIAGRAM-011`, `37.51-EXTRACT-DIAGRAM-012`, `37.51-EXTRACT-PROPERTY-FORMAL-TYPE`, `37.53-EXTRACT-DIAGRAM-003`, `37.53-EXTRACT-DIAGRAM-007`, `37.53-EXTRACT-DIAGRAM-008`, `37.53-EXTRACT-DIAGRAM-009`, `37.53-EXTRACT-SEQUENCE-FORMAL-ORDER`, `37.53-EXTRACT-SEQUENCE-FORMAL-TYPE`.
- [test_vpi_property_sequence_operators](../tests/ch37/test_vpi_property_sequence_operators.sv) / [C](../tests/ch37/test_vpi_property_sequence_operators.c): `37.51-EXTRACT-DIAGRAM-004`, `37.51-EXTRACT-DIAGRAM-009`, `37.52-EXTRACT-DIAGRAM-002`, `37.52-EXTRACT-DIAGRAM-003`, `37.52-EXTRACT-DIAGRAM-010`, `37.52-EXTRACT-DIAGRAM-011`, `37.52-EXTRACT-DIAGRAM-012`, `37.52-EXTRACT-DIAGRAM-013`, `37.52-EXTRACT-DIAGRAM-014`, `37.52-EXTRACT-DIAGRAM-015`, `37.52-EXTRACT-DIAGRAM-016`, `37.52-EXTRACT-DIAGRAM-018`, `37.52-EXTRACT-PROPERTY-OP-VPIALWAYSOP`, `37.52-EXTRACT-PROPERTY-OP-VPICOMPANDOP`, `37.52-EXTRACT-PROPERTY-OP-VPINEXTTIMEOP`, `37.52-EXTRACT-PROPERTY-OP-VPIOVERLAPIMPLYOP`, `37.52-EXTRACT-PROPERTY-OP-VPIUNTILOP`, `37.53-EXTRACT-DIAGRAM-004`, `37.53-EXTRACT-DIAGRAM-005`, `37.54-EXTRACT-DIAGRAM-005`, `37.54-EXTRACT-DIAGRAM-006`, `37.54-EXTRACT-SEQUENCE-OP-VPIFIRSTMATCHOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIGOTOREPEATOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIINTERSECTOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIREPEATOP`, `37.54-EXTRACT-SEQUENCE-OP-VPITHROUGHOUTOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIUNARYCYCLEDELAYOP`, `37.54-EXTRACT-SEQUENCE-OP-VPIWITHINOP`, `37.56-EXTRACT-DIAGRAM-001`, `37.56-EXTRACT-DIAGRAM-002`, `37.57-EXTRACT-DIAGRAM-001`, `37.57-EXTRACT-DIAGRAM-002`, `37.57-EXTRACT-DIAGRAM-004`, `37.57-EXTRACT-DIAGRAM-005`.
- [test_vpi_ref_obj_actual](../tests/ch37/test_vpi_ref_obj_actual.sv) / [C](../tests/ch37/test_vpi_ref_obj_actual.c): `37.15-EXTRACT-DIAGRAM-001`, `37.15-EXTRACT-DIAGRAM-009`, `37.15-EXTRACT-DIAGRAM-010`, `37.15-EXTRACT-REF-ACTUAL`.
- [test_vpi_relationships_and_tags](../tests/ch37/test_vpi_relationships_and_tags.sv) / [C](../tests/ch37/test_vpi_relationships_and_tags.c): `37.3.1-EXTRACT-HANDLE-ACCESS`, `37.3.1-EXTRACT-ONE-TO-ONE`.
- [test_vpi_select_objects_event_arrays](../tests/ch37/test_vpi_select_objects_event_arrays.sv) / [C](../tests/ch37/test_vpi_select_objects_event_arrays.c): `37.19-EXTRACT-DIAGRAM-002`, `37.19-EXTRACT-DIAGRAM-005`, `37.19-EXTRACT-DIAGRAM-009`, `37.19-EXTRACT-SELECT-CONSTANT`, `37.27-EXTRACT-DIAGRAM-007`, `37.27-EXTRACT-DIAGRAM-013`, `37.27-EXTRACT-DIAGRAM-015`, `37.27-EXTRACT-DIAGRAM-016`, `37.27-EXTRACT-DIAGRAM-017`, `37.27-EXTRACT-EVENT-INDICES`, `37.27-EXTRACT-EVENT-RANGES`, `37.58-EXTRACT-BIT-SELECT-CONSTANT`, `37.58-EXTRACT-DIAGRAM-010`, `37.58-EXTRACT-DIAGRAM-011`.
- [test_vpi_struct_typespecs](../tests/ch37/test_vpi_struct_typespecs.sv) / [C](../tests/ch37/test_vpi_struct_typespecs.c): `37.17-EXTRACT-DIAGRAM-032`, `37.17-EXTRACT-DIAGRAM-066`, `37.17-EXTRACT-DIAGRAM-068`, `37.25-EXTRACT-DIAGRAM-028`, `37.25-EXTRACT-DIAGRAM-030`, `37.25-EXTRACT-DIAGRAM-031`, `37.25-EXTRACT-DIAGRAM-032`, `37.25-EXTRACT-DIAGRAM-034`, `37.25-EXTRACT-DIAGRAM-036`, `37.26-EXTRACT-DIAGRAM-001`, `37.26-EXTRACT-DIAGRAM-005`, `37.26-EXTRACT-DIAGRAM-006`, `37.26-EXTRACT-DIAGRAM-010`.
- [test_vpi_systf_argument_expressions](../tests/ch37/test_vpi_systf_argument_expressions.sv) / [C](../tests/ch37/test_vpi_systf_argument_expressions.c): `37.42-EXTRACT-DIAGRAM-008`, `37.42-EXTRACT-DIAGRAM-028`, `37.59-EXTRACT-DIAGRAM-021`.
- [test_vpi_task_function_properties](../tests/ch37/test_vpi_task_function_properties.sv) / [C](../tests/ch37/test_vpi_task_function_properties.c): `37.12-EXTRACT-DIAGRAM-050`, `37.13-EXTRACT-DIAGRAM-005`, `37.13-EXTRACT-DIAGRAM-009`, `37.13-EXTRACT-DIAGRAM-014`, `37.13-EXTRACT-DIAGRAM-015`, `37.41-EXTRACT-DIAGRAM-003`, `37.41-EXTRACT-DIAGRAM-011`, `37.41-EXTRACT-DIAGRAM-015`, `37.41-EXTRACT-DIAGRAM-016`, `37.41-EXTRACT-DIAGRAM-017`, `37.41-EXTRACT-DIAGRAM-018`, `37.41-EXTRACT-DIAGRAM-022`, `37.41-EXTRACT-DIAGRAM-023`, `37.41-EXTRACT-SUBROUTINE-FULLNAME`, `37.41-EXTRACT-SUBROUTINE-VISIBILITY`.
- [test_vpi_type_strings](../tests/ch37/test_vpi_type_strings.sv) / [C](../tests/ch37/test_vpi_type_strings.c): `37.3.2-EXTRACT-TYPE-INTEGER`, `37.3.2-EXTRACT-TYPE-STRING`.
- [test_vpi_typespec_relations](../tests/ch37/test_vpi_typespec_relations.sv) / [C](../tests/ch37/test_vpi_typespec_relations.c): `37.22-EXTRACT-DIAGRAM-001`, `37.22-EXTRACT-DIAGRAM-002`, `37.22-EXTRACT-DIAGRAM-003`, `37.22-EXTRACT-EMPTY-RANGE-RESULT`, `37.24-EXTRACT-DIAGRAM-006`, `37.24-EXTRACT-DIAGRAM-008`, `37.25-EXTRACT-ALIAS-KIND`, `37.25-EXTRACT-DIAGRAM-026`, `37.25-EXTRACT-DIAGRAM-032`, `37.25-EXTRACT-DIAGRAM-035`, `37.25-EXTRACT-DIAGRAM-036`, `37.25-EXTRACT-DIAGRAM-048`, `37.25-EXTRACT-DIAGRAM-049`, `37.25-EXTRACT-DIAGRAM-053`, `37.25-EXTRACT-DIAGRAM-054`, `37.25-EXTRACT-DIAGRAM-055`, `37.25-EXTRACT-DIAGRAM-057`, `37.25-EXTRACT-DIAGRAM-059`, `37.25-EXTRACT-DIAGRAM-060`, `37.25-EXTRACT-DIAGRAM-061`, `37.25-EXTRACT-MEMBER-DEFAULT`, `37.25-EXTRACT-TYPE-BOUNDS`, `37.25-EXTRACT-TYPEDEF-NAME`.
- [test_vpi_variable_properties](../tests/ch37/test_vpi_variable_properties.sv) / [C](../tests/ch37/test_vpi_variable_properties.c): `37.17-EXTRACT-DIAGRAM-031`, `37.17-EXTRACT-DIAGRAM-051`, `37.17-EXTRACT-DIAGRAM-052`, `37.17-EXTRACT-DIAGRAM-054`, `37.17-EXTRACT-DIAGRAM-055`, `37.17-EXTRACT-DIAGRAM-061`, `37.17-EXTRACT-DIAGRAM-070`, `37.17-EXTRACT-DIAGRAM-077`, `37.17-EXTRACT-DIAGRAM-078`, `37.17-EXTRACT-DIAGRAM-085`, `37.17-EXTRACT-DIAGRAM-087`, `37.17-EXTRACT-VARIABLE-INITIALIZER`.
- [test_vpi_virtual_interface_vars](../tests/ch37/test_vpi_virtual_interface_vars.sv) / [C](../tests/ch37/test_vpi_virtual_interface_vars.c): `37.29-EXTRACT-DIAGRAM-007`, `37.29-EXTRACT-DIAGRAM-008`, `37.29-EXTRACT-DIAGRAM-009`, `37.29-EXTRACT-DIAGRAM-011`.
- [test_vpi_get_property_values](../tests/ch38/test_vpi_get_property_values.sv) / [C](../tests/ch38/test_vpi_get_property_values.c): `38.6-EXTRACT-GET-SIGNATURE`, `38.6-EXTRACT-GET-VALUES`.
- [test_vpi_get_systf_info_function_types](../tests/ch38/test_vpi_get_systf_info_function_types.sv) / [C](../tests/ch38/test_vpi_get_systf_info_function_types.c): `38.12-EXTRACT-SYSTF-INFO-ALLOCATION`, `38.12-EXTRACT-SYSTF-INFO-SIGNATURE`, `38.37.1-EXTRACT-SYSTF-NAME`, `38.37.1-EXTRACT-SYSTF-TYPE`, `38.37.1-EXTRACT-USER-SYSTF-REGISTER`.
- [test_vpi_get_time_scaled](../tests/ch38/test_vpi_get_time_scaled.sv) / [C](../tests/ch38/test_vpi_get_time_scaled.c): `38.13-EXTRACT-GET-TIME-FORMAT`, `38.13-EXTRACT-GET-TIME-SIGNATURE`.
- [test_vpi_get_vlog_info](../tests/ch38/test_vpi_get_vlog_info.sv) / [C](../tests/ch38/test_vpi_get_vlog_info.c): `38.17-EXTRACT-VLOG-INFO-CONTENTS`, `38.17-EXTRACT-VLOG-INFO-SIGNATURE`.
- [test_vpi_handle_by_multi_index_ranges](../tests/ch38/test_vpi_handle_by_multi_index_ranges.sv) / [C](../tests/ch38/test_vpi_handle_by_multi_index_ranges.c): `38.20-EXTRACT-MULTI-INDEX-ORDER`, `38.20-EXTRACT-MULTI-INDEX-SIGNATURE`.
