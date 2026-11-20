# 生成テストの仕分けの案（2026-11-20）

[English](generator-classification-20261120.en.md) / [日本語](generator-classification-20261120.md)

生成テスト9,351本のうち7,605本は要求台帳（`coverage/behaviors.json`）に対応付いておらず、生成器155個のうち142個（7,066本）は1本も対応付いていません。要求カバレッジに何を足しているかを見えるようにするため、生成器ごとの区分を提案します。**この資料は案で、所有者の承認まで何も反映しません。**

仕分けはAIによる一次案で、人の確認ではありません。約40個は生成器の説明と生成されたテストと期待出力を読んで判断しましたが、相互作用の生成器の約55個は、カタログの説明とテスト名だけから判断しました。生成器ごとの区分・候補の行・理由は[データ](measurements/2026-11-20/generator-classification.json)にあります。

<a id="categories"></a>

## 区分

- 対応付けられる：テストが、要求台帳の既存の行の動作と受入条件の全体を観測している。承認の後、`tools/matching_kit/`の手順で、入力と観測を確かめてから対応付けます。条項の引用からは推測しません。
- 実装境界テスト：要求はほかのテストと同じで、幅（32/33/64/65/128/129ビット、255/256/257ビットなど）や語の境界、大きさ、同じ規則の組合せを広げるだけのもの。承認の後、生成器カタログに区分の列を足し、READMEの収録本数で別に数えます。
- 判断できない：生成器とテストからは決められないもの。

<a id="counts"></a>

## 本数

| 区分の案 | 生成器 | テスト | うち要求に未対応 |
| --- | ---: | ---: | ---: |
| 対応付けられる | 25 | 2766 | 1110 |
| 実装境界テスト | 96 | 5727 | 5637 |
| 判断できない | 34 | 858 | 858 |
| 計 | 155 | 9351 | 7605 |

<a id="large"></a>

## 80本以上で、1本も対応付いていない生成器

| 生成器 | 本数 | 区分の案 |
| --- | ---: | --- |
| `wide_value_boundaries` | 312 | 実装境界テスト |
| `nba_boundaries` | 192 | 実装境界テスト |
| `packed_lanes` | 192 | 実装境界テスト |
| `wide_shift_boundaries` | 192 | 実装境界テスト |
| `wide_cast_boundaries` | 180 | 実装境界テスト |
| `wide_scan` | 180 | 実装境界テスト |
| `memory_file_boundaries` | 138 | 実装境界テスト |
| `interaction_macro` | 114 | 対応付けられる |
| `wide_force_boundaries` | 108 | 実装境界テスト |
| `interaction_compare` | 100 | 実装境界テスト |
| `packed_read_controls` | 96 | 実装境界テスト |
| `stream_boundaries` | 96 | 実装境界テスト |
| `interaction_shortcircuit` | 92 | 実装境界テスト |
| `interaction_litfmt` | 91 | 対応付けられる |
| `arithmetic_context` | 90 | 実装境界テスト |
| `array_element_refs` | 80 | 判断できない |

<a id="lists"></a>

## 区分ごとの生成器（括弧内は本数）

### 対応付けられる

`ambiguous_strength_union` (20), `cg_option_levels` (17), `constant_power_controls` (16), `gate_strength_truth` (5), `interaction_agglit` (48), `interaction_arrayloop` (40), `interaction_casedigit` (24), `interaction_delayval` (60), `interaction_escname` (29), `interaction_force` (72), `interaction_hiername` (65), `interaction_hierproc` (42), `interaction_litfmt` (91), `interaction_macro` (114), `interaction_paramtype` (44), `interaction_progassert` (27), `interaction_simend` (42), `keywords` (496), `keywords_inherited` (804), `negative_power_controls` (16), `primitive_array_bounds` (61), `primitive_array_identity` (15), `scheduling` (325), `strength` (135), `xz_propagation` (158)

### 実装境界テスト

`arithmetic_context` (90), `array_shape_queries` (60), `bitvector_queries` (48), `division_boundaries` (72), `fourstate_boundaries` (54), `function_formal_contexts` (60), `interaction_array` (36), `interaction_assertion` (36), `interaction_assocquery` (18), `interaction_binding` (36), `interaction_case` (36), `interaction_case_inside` (34), `interaction_cast` (32), `interaction_class_import` (34), `interaction_class_method` (36), `interaction_class_select` (36), `interaction_clockevent` (24), `interaction_clocking` (36), `interaction_compare` (100), `interaction_compound` (40), `interaction_concat` (72), `interaction_cond` (32), `interaction_config` (41), `interaction_default` (36), `interaction_deferarg` (29), `interaction_delay` (63), `interaction_dist` (31), `interaction_divide` (72), `interaction_edge` (64), `interaction_eventflow` (36), `interaction_expr` (51), `interaction_genenum` (36), `interaction_generate` (36), `interaction_genexpr` (36), `interaction_genloop` (36), `interaction_gensub` (36), `interaction_ifexpr` (49), `interaction_ifgenerate` (36), `interaction_ifimport` (36), `interaction_ifquery` (36), `interaction_import` (39), `interaction_index` (44), `interaction_inside` (46), `interaction_litarg` (62), `interaction_literal` (66), `interaction_logic` (70), `interaction_loop_nba` (36), `interaction_loopsched` (55), `interaction_mailbox` (36), `interaction_memfile` (36), `interaction_method` (72), `interaction_nba` (36), `interaction_nettype` (40), `interaction_pkgnba` (36), `interaction_pkgquery` (36), `interaction_pkgwatch` (36), `interaction_port` (36), `interaction_process` (36), `interaction_progframe` (36), `interaction_query` (60), `interaction_queue` (48), `interaction_queue_ref` (60), `interaction_range` (46), `interaction_reactive` (36), `interaction_resize` (38), `interaction_return` (36), `interaction_scansel` (36), `interaction_select` (36), `interaction_sense` (61), `interaction_shift` (56), `interaction_shortcircuit` (92), `interaction_stream` (36), `interaction_struct` (36), `interaction_task` (36), `interaction_udp` (25), `interaction_udpstate` (36), `interaction_wait` (36), `memory_file_boundaries` (138), `nba_boundaries` (192), `packed_lanes` (192), `packed_read_controls` (96), `power_boundaries` (72), `stream_boundaries` (96), `wide_array_shapes` (60), `wide_bitvector_queries` (48), `wide_cast_boundaries` (180), `wide_constant_calls` (36), `wide_force_boundaries` (108), `wide_format_fields` (72), `wide_format_roundtrips` (36), `wide_paths` (91), `wide_runtime_aliases` (36), `wide_scan` (180), `wide_shift_boundaries` (192), `wide_value_boundaries` (312), `width_sign` (144)

### 判断できない

`array_element_refs` (80), `combination_aggregates` (18), `combination_events` (9), `combination_io` (13), `combination_monitors` (18), `combination_nba` (16), `function_result_ranges` (24), `interaction_assertquery` (30), `interaction_cgsample` (33), `interaction_checksample` (27), `interaction_class_array` (18), `interaction_clockassert` (18), `interaction_clockiff` (12), `interaction_constraint` (13), `interaction_deferdis` (31), `interaction_dpi_array` (30), `interaction_dpi_nba` (18), `interaction_dpiquery` (16), `interaction_event_rebind` (27), `interaction_event_task` (13), `interaction_eventlife` (18), `interaction_gatearray` (51), `interaction_gendisable` (18), `interaction_iff` (27), `interaction_pkglookup` (37), `interaction_progif` (30), `interaction_progmod` (24), `interaction_program` (18), `interaction_randreduce` (13), `interaction_scopeclass` (48), `interaction_sdfpath` (18), `interaction_strengthfmt` (31), `interaction_timescope` (48), `interaction_vif_class` (13)

<a id="handwritten"></a>

## 手書きのテスト

手書きのテスト6,947本のうち1,994本が要求に対応付いていません。章ごとの本数は次のとおりで、この作業では対応付けません：ch11 345, ch6 193, ch7 188, ch20 166, ch8 98, ch10 80, ch12 77, ch13 73, ch9 73, ch23 65, ch27 64, ch21 61, ch16 52, ch25 45, ch26 34, ch4 32, ch19 31, ch38 29, ch18 28, ch29 27, ch17 26, ch14 22, ch28 22, ch15 20, ch22 18, ch3 17, ch5 17, ch36 14, ch32 13, ch24 11, ch40 10, ch33 9, ch35 9, ch37 9, ch39 8, ch31 6, ch30 2。

<a id="decisions"></a>

## 承認を待つこと

- この区分で進めてよいか。特に、説明だけから判断した相互作用の生成器と、「判断できない」34個の扱い。
- 「実装境界テスト」を収録本数の表で別に数えるか。
- 承認の後、「対応付けられる」の生成器を照合キットで対応付けます。要求カバレッジの分母（12,332行）は変えません。
