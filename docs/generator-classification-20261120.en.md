# Proposed classification of the generated tests (2026-11-20)

[English](generator-classification-20261120.en.md) / [日本語](generator-classification-20261120.md)

7,605 of the 9,351 generated tests are linked to no row of the requirement ledger (`coverage/behaviors.json`), and 142 of the 155 generators (7,066 tests) have no linked test at all. To make visible what they add to requirement coverage, this proposes a category for each generator. **This is a proposal; nothing is applied before the owner approves it.**

The classification is a first pass by an AI model, not checked by a person. About 40 generators were judged from their description, a generated test and its expected output; about 55 interaction generators only from the catalog description and the test names. The category, candidate rows and reason of each generator are in [the data](measurements/2026-11-20/generator-classification.json).

<a id="categories"></a>

## Categories

- Mappable: the tests observe the whole behavior and acceptance of existing rows of the ledger. After approval they are linked by the procedure of `tools/matching_kit/`, after their inputs and observations are checked; nothing is inferred from the cited clauses.
- Implementation boundary: the tests check the same requirements as other tests and only widen widths (32/33/64/65/128/129 bits, 255/256/257 bits and so on), word boundaries, sizes or combinations of one rule. After approval the generator catalog gets a column for the category and the README counts these tests apart.
- Undecided: the generator and its tests do not settle it.

<a id="counts"></a>

## Counts

| Proposed category | Generators | Tests | Not linked to a requirement |
| --- | ---: | ---: | ---: |
| Mappable | 25 | 2766 | 1110 |
| Implementation boundary | 96 | 5727 | 5637 |
| Undecided | 34 | 858 | 858 |
| Total | 155 | 9351 | 7605 |

<a id="large"></a>

## Generators with 80 or more tests and no linked test

| Generator | Tests | Proposed category |
| --- | ---: | --- |
| `wide_value_boundaries` | 312 | Implementation boundary |
| `nba_boundaries` | 192 | Implementation boundary |
| `packed_lanes` | 192 | Implementation boundary |
| `wide_shift_boundaries` | 192 | Implementation boundary |
| `wide_cast_boundaries` | 180 | Implementation boundary |
| `wide_scan` | 180 | Implementation boundary |
| `memory_file_boundaries` | 138 | Implementation boundary |
| `interaction_macro` | 114 | Mappable |
| `wide_force_boundaries` | 108 | Implementation boundary |
| `interaction_compare` | 100 | Implementation boundary |
| `packed_read_controls` | 96 | Implementation boundary |
| `stream_boundaries` | 96 | Implementation boundary |
| `interaction_shortcircuit` | 92 | Implementation boundary |
| `interaction_litfmt` | 91 | Mappable |
| `arithmetic_context` | 90 | Implementation boundary |
| `array_element_refs` | 80 | Undecided |

<a id="lists"></a>

## Generators per category (tests in parentheses)

### Mappable

`ambiguous_strength_union` (20), `cg_option_levels` (17), `constant_power_controls` (16), `gate_strength_truth` (5), `interaction_agglit` (48), `interaction_arrayloop` (40), `interaction_casedigit` (24), `interaction_delayval` (60), `interaction_escname` (29), `interaction_force` (72), `interaction_hiername` (65), `interaction_hierproc` (42), `interaction_litfmt` (91), `interaction_macro` (114), `interaction_paramtype` (44), `interaction_progassert` (27), `interaction_simend` (42), `keywords` (496), `keywords_inherited` (804), `negative_power_controls` (16), `primitive_array_bounds` (61), `primitive_array_identity` (15), `scheduling` (325), `strength` (135), `xz_propagation` (158)

### Implementation boundary

`arithmetic_context` (90), `array_shape_queries` (60), `bitvector_queries` (48), `division_boundaries` (72), `fourstate_boundaries` (54), `function_formal_contexts` (60), `interaction_array` (36), `interaction_assertion` (36), `interaction_assocquery` (18), `interaction_binding` (36), `interaction_case` (36), `interaction_case_inside` (34), `interaction_cast` (32), `interaction_class_import` (34), `interaction_class_method` (36), `interaction_class_select` (36), `interaction_clockevent` (24), `interaction_clocking` (36), `interaction_compare` (100), `interaction_compound` (40), `interaction_concat` (72), `interaction_cond` (32), `interaction_config` (41), `interaction_default` (36), `interaction_deferarg` (29), `interaction_delay` (63), `interaction_dist` (31), `interaction_divide` (72), `interaction_edge` (64), `interaction_eventflow` (36), `interaction_expr` (51), `interaction_genenum` (36), `interaction_generate` (36), `interaction_genexpr` (36), `interaction_genloop` (36), `interaction_gensub` (36), `interaction_ifexpr` (49), `interaction_ifgenerate` (36), `interaction_ifimport` (36), `interaction_ifquery` (36), `interaction_import` (39), `interaction_index` (44), `interaction_inside` (46), `interaction_litarg` (62), `interaction_literal` (66), `interaction_logic` (70), `interaction_loop_nba` (36), `interaction_loopsched` (55), `interaction_mailbox` (36), `interaction_memfile` (36), `interaction_method` (72), `interaction_nba` (36), `interaction_nettype` (40), `interaction_pkgnba` (36), `interaction_pkgquery` (36), `interaction_pkgwatch` (36), `interaction_port` (36), `interaction_process` (36), `interaction_progframe` (36), `interaction_query` (60), `interaction_queue` (48), `interaction_queue_ref` (60), `interaction_range` (46), `interaction_reactive` (36), `interaction_resize` (38), `interaction_return` (36), `interaction_scansel` (36), `interaction_select` (36), `interaction_sense` (61), `interaction_shift` (56), `interaction_shortcircuit` (92), `interaction_stream` (36), `interaction_struct` (36), `interaction_task` (36), `interaction_udp` (25), `interaction_udpstate` (36), `interaction_wait` (36), `memory_file_boundaries` (138), `nba_boundaries` (192), `packed_lanes` (192), `packed_read_controls` (96), `power_boundaries` (72), `stream_boundaries` (96), `wide_array_shapes` (60), `wide_bitvector_queries` (48), `wide_cast_boundaries` (180), `wide_constant_calls` (36), `wide_force_boundaries` (108), `wide_format_fields` (72), `wide_format_roundtrips` (36), `wide_paths` (91), `wide_runtime_aliases` (36), `wide_scan` (180), `wide_shift_boundaries` (192), `wide_value_boundaries` (312), `width_sign` (144)

### Undecided

`array_element_refs` (80), `combination_aggregates` (18), `combination_events` (9), `combination_io` (13), `combination_monitors` (18), `combination_nba` (16), `function_result_ranges` (24), `interaction_assertquery` (30), `interaction_cgsample` (33), `interaction_checksample` (27), `interaction_class_array` (18), `interaction_clockassert` (18), `interaction_clockiff` (12), `interaction_constraint` (13), `interaction_deferdis` (31), `interaction_dpi_array` (30), `interaction_dpi_nba` (18), `interaction_dpiquery` (16), `interaction_event_rebind` (27), `interaction_event_task` (13), `interaction_eventlife` (18), `interaction_gatearray` (51), `interaction_gendisable` (18), `interaction_iff` (27), `interaction_pkglookup` (37), `interaction_progif` (30), `interaction_progmod` (24), `interaction_program` (18), `interaction_randreduce` (13), `interaction_scopeclass` (48), `interaction_sdfpath` (18), `interaction_strengthfmt` (31), `interaction_timescope` (48), `interaction_vif_class` (13)

<a id="handwritten"></a>

## Hand-written tests

1,994 of the 6,947 hand-written tests are linked to no requirement. Per chapter (not linked in this work): ch11 345, ch6 193, ch7 188, ch20 166, ch8 98, ch10 80, ch12 77, ch13 73, ch9 73, ch23 65, ch27 64, ch21 61, ch16 52, ch25 45, ch26 34, ch4 32, ch19 31, ch38 29, ch18 28, ch29 27, ch17 26, ch14 22, ch28 22, ch15 20, ch22 18, ch3 17, ch5 17, ch36 14, ch32 13, ch24 11, ch40 10, ch33 9, ch35 9, ch37 9, ch39 8, ch31 6, ch30 2.

<a id="decisions"></a>

## Waiting for approval

- Whether to go ahead with these categories, in particular for the interaction generators judged from their descriptions and the 34 undecided ones.
- Whether the implementation boundary tests are counted apart in the table of tests.
- After approval the mappable generators are linked with the matching kit. The denominator of requirement coverage (12,332 rows) does not change.
