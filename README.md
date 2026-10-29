# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. Local runs can also be imported and are marked `local`. A test matches when its output and specified checks agree with the expected result, or an illegal design is rejected with the required diagnostic; see the suite's README for what each status means.

Latest run: 2026-10-29 03:55 UTC, suite commit [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3), 7744 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805499579).

## Latest results per simulator

Each row and chapter-table column uses that simulator's most recent recorded run. Dates, suite commits and test counts can differ; older results retain their own dates and are not treated as part of the latest run.

| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-749-gfd8759f6) | 2026-10-29 03:55 | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | nightly | 4607 (61.6%) | 14 | 2855 | 0 |
| Verilator | Verilator 5.053 devel rev v5.052-637-gad839901 | 2026-10-29 03:55 | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | nightly | 4779 (63.9%) | 9 | 2688 | 0 |
| kirimasim | kirimasim 0.0.0 (commit 938d60c833a6), built with GNU 13.3.0 | 2026-10-29 03:55 | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | nightly | 5076 (67.9%) | 136 | 2 | 2262 |
| Lyra | Lyra (commit ed9515d8eec1) | 2026-10-29 03:55 | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | nightly | 5501 (73.6%) | 488 | 0 | 1487 |
| Ghost | private build 5c1261cba4df | 2026-10-29 03:55 | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | nightly | 6095 (78.7%) | 1649 | 0 | 0 |

Ghost is an unidentified simulator taking part before its public debut. For now, only its test results step out from behind the curtain. Its name, source and build logs remain private; build IDs are executable hashes.

![Tests that match their expected results](charts/overview.svg?v=20261029T035511)

![Share of the tests that match](charts/rate.svg?v=20261029T035511)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### kirimasim

Newly match (6): `ch14/test_clocking_blk_edge_cases`, `ch14/test_clocking_block_per_instance_local_scope`, `ch14/test_clocking_input`, `ch14/test_clocking_input_sample_holds`, `ch14/test_clocking_input_with_expression`, `ch4/test_one_step_sample_before_time_slot`

### Lyra

Newly match (9): `ch13/test_default_argument_declaring_scope`, `ch20/test_illegal_random_seed_real`, `ch21/test_fst_dump_control_keeps_header`, `ch21/test_fst_header_and_dumpfile`, `ch21/test_vcd_dumpflush_resume`, `ch21/test_vcd_vector_extension_and_event`, `ch8/test_illegal_constraint_mode_via_interface_handle`, `ch8/test_illegal_rand_mode_via_interface_handle`, `ch8/test_syntax_class_item_kinds`

No longer match (6):

- `ch11/test_real_shortreal_operands_of_arithmetic_logical_relational`: differ — compile failed: error: compiling 'test_real_shortreal_operands_of_arithmetic_logical_relational.cpp' failed
- `ch23/test_port_default_value_module_scope`: differ — error: internal error: UnitSignatures::ValuesOf: specialization '$unit__19fdd4645b9cedf5' published no values; every specialization of the design publishes (in unit 'port_default_value_module_scope_m__1a6a158f1396acd5')
- `ch26/test_package_explicit_import_only_named`: differ — error: internal error: UnitSignatures::ValuesOf: specialization '$unit__9bf2e7bfd44bc6ae' published no values; every specialization of the design publishes (in unit 'test_package_explicit_import_only_named')
- `ch26/test_package_export_wildcard_forms`: differ — error: internal error: UnitSignatures::ValuesOf: specialization '$unit__4fa0aa5bb0f60587' published no values; every specialization of the design publishes (in unit 'xw_use_all')
- `ch5/test_unsized_fill_wide_part_select_nba`: differ — error: internal error: UnitSignatures::ValuesOf: specialization '$unit__d52bd269ba466722' published no values; every specialization of the design publishes (in unit 'test_unsized_fill_wide_part_select_nba__7fe2ee550b530867')
- `ch6/test_class_cast_compatibility_dynamic`: differ — compile failed: error: compiling 'test_class_cast_compatibility_dynamic.cpp' failed

### Ghost

Newly match (12): `ch21/test_evcd_port_node_declarations`, `ch37/test_vpi_case_items_patterns`, `ch37/test_vpi_cast_pattern_constants`, `ch37/test_vpi_cont_assign_bits_delays`, `ch37/test_vpi_cont_assign_module_delays`, `ch37/test_vpi_delay_expressions`, `ch37/test_vpi_delay_source_and_effective`, `ch37/test_vpi_dpi_import_access_props`, `ch37/test_vpi_module_port_io_decl_relations`, `ch37/test_vpi_part_select_parts`, `ch37/test_vpi_relationships_and_tags`, `ch37/test_vpi_unbounded_const_ranges`

## By chapter

![Matching tests by chapter](charts/chapters.svg?v=20261029T035511)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg?v=20261029T035511)

![Verilator: results by status](charts/status-verilator.svg?v=20261029T035511)

![kirimasim: results by status](charts/status-kirimasim.svg?v=20261029T035511)

![Lyra: results by status](charts/status-lyra.svg?v=20261029T035511)

![Ghost: results by status](charts/status-ghost.svg?v=20261029T035511)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
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

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.
