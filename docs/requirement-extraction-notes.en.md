<a id="ieee-1800-2023-要求抽出の解釈再検討記録"></a>

# IEEE 1800-2023 Interpretation and re-examination of requirement extraction record

[English](requirement-extraction-notes.en.md) / [日本語](requirement-extraction-notes.md)

On 2026-10-22, completed checks of all 1,740 clauses and 15,846 source blocks in main-text Chapters 1–41 and Annexes A–Q. The material confirmation rate is 100%. There are no unconfirmed sections. [Extraction results](requirement-extraction.en.md) / [Current aggregates](behavior-coverage.en.md)

Initially, requirement interpretations had 46 pending issues covering 42 clauses and 49 registered rows. Resolved 27 issues (22 sections) in 2026-10-24 and the remaining 19 issues, 20 sections, and 21 registered rows in [Denominator review](denominator-review-20261028.en.md#1-解釈の解決21行19論点) of 2026-10-28; 0 interpretation holds remain. The following is a history of the extraction state and the re-examination of 2026-10-24. “Still pending” records the judgment at that time, not the current status. The interpretation and policy choices adopted in 2026-10-28 are described in the denominator review and in `source_note` for each line of `coverage/behaviors.json`. You cannot replace 100% for documentation verification with 100% for interpretation confirmation and operational testing. These are comparison results within the supplied PDF; they do not establish that official IEEE corrections or interpretations have been checked.

<a id="static-block-lifetime--ブロック変数の寿命"></a>

## STATIC-BLOCK-LIFETIME — life of block variable

- Source: 9.3.4, PDF physical page 230, B004. This text makes all block variables static, meaning that they do not change values when they are entered or exited.
- Related: 6.21, PDF physical page 134. Explicitly specifies automatic variables within blocks, the automatic default, and overriding it with static.
- Unresolved: scope of 9.3.4's unqualified description. If tested as a general rule that prohibits automatic, it will conflict with the permission of 6.21.
- The state at extraction: 9.3.4 is kept as `in_progress`. Approval of mapped tests for `SV2023-9.3.4-EXTRACT-STATIC-TEXT-CONFLICT` is prohibited.
- The solution condition is that the scope of application can be explained in the primary data. After correcting the requirement, the basis, and the audit record, the section is completed.
- Reconsideration of 2026-10-24 (hold retained): decisive evidence is missing—a statement limiting 9.3.4 B004 to static-lifetime variables (the default for 6.21), a statement establishing precedence between 9.3.4 and 6.21, or official errata. Observable automatic/static block-variable behavior is already specified by rows 6.21 and 12.7.1, so this pending issue does not prevent their testing.

<a id="chandle-event-control--chandleのイベント式"></a>

## CHANDLE-EVENT-CONTROL — chandle event expression

- Source: 6.14, PDF physical page 112, B006. It prohibits chandle in sensitivity lists and event expressions.
- Related: 9.4.2, PDF physical page 234, B016. For simple object handles or chandle variables, explicitly specify events when writing changes the value.
- Unresolved: Should the normal change-of-value event of chandle be allowed. Silently discarding either the permission or prohibition prevents claiming that both passages have been satisfied.
- The state at extraction: 9.4.2 is kept as `in_progress`. Approval of mapped tests for `SV2023-9.4.2-EXTRACT-HANDLE-CHANGE-EVENT` is prohibited. I have also left the requirement for 6.14 to be banned in the log.
- The solution condition: To confirm the scope of application or correction of both sections in the primary material, and to re-review the expectations of the normal system test/standard violation test.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is a statement establishing which rule takes precedence (for example, restricting 9.4.2 B016 to class handles, or adding a value-change-event exception to the prohibition in 6.14), or an official erratum.

<a id="constant-timescale-name--定数式で使用できる関数名"></a>

## CONSTANT-TIMESCALE-NAME — Function names permitted in constant expressions

- Source: 11.2.1, PDF physical page 271, B002. Lists `$timescale` and `$timeprecision` as timescale functions usable in constant expressions.
- Related: 20.4, PDF physical page 623. The list of corresponding function names is `$timeunit` and `$timeprecision`, and the list of `$printtimescale` and `$timeformat` are separate.
- Unsolved: First function name of 11.2.1. Do not add a name different from the reference as an independent API permission.
- Status at extraction: 11.2.1 is `in_progress`; test mappings for `SV2023-11.2.1-EXTRACT-CONSTANT-TIMESCALE-NAME` remain pending.
- Resolution condition: compare detailed definition API with official corrections/interpretations and establish, with evidence, which functions are permitted in constant expressions.
- Re-examination (resolution) of 2026-10-24: The timescale functions that can be called as constant system functions are $timeunit and $timeprecision, which are listed in 20.4. The $timescale in the parentheses of 11.2.1 is read as a misspelling of $timeunit and is not treated as allowing or requiring the independent $timescale function. Source: 11.2.1 B002 identifies the object by reference to "the timescale system functions listed in 20.4", and adds $timescale and $timeprecision in parentheses. The list in 20.4 B002 contains $timeunit, $timeprecision, $printtimescale, and $timeformat; only $timeunit and $timeprecision are system functions (20.4.1 B002 and B004 in Syntax 20-3 define them as functions. $printtimescale and $timeformat are tasks). The list of classifications of 20.1 also lists the same 2. When searching the full text, $timescale appears only in this part of 11.2.1 and in the VCD file of 21.7 as a keyword, and nowhere as a system function. Because the referenced list, syntax definitions, and classification list agree, the first parenthesized name can be uniquely restored as a misspelling of $timeunit (a spelling conflicts with API and the syntax definition, while the definitions agree). The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="multiclock-sequence-strength--マルチクロックのシーケンスプロパティ"></a>

## MULTICLOCK-SEQUENCE-STRENGTH — Multiclock sequences and properties

- Source: 16.13.2, PDF physical page 468, B005. The result of evaluating a sequence as a property is described as true if it matches from the starting point.
- Related: 16.12.2, PDF physical page 444, B002–B003. Sequence properties default to weak for assert/assume and strong elsewhere; weak is true unless a finite prefix establishes that no match is possible.
- Unsolved: How to combine the explanation of 16.13.2 with the established formal semantics of strength for finite execution where the clock stops. It does not assume that multiclock alone is always strong.
- Status at extraction: 16.13.2 is `in_progress`; test mappings for `SV2023-16.13.2-EXTRACT-MATCH-STRENGTH-TEXT` remain pending.
- Comparison status: Annex F reviewed. F.3.4.3.1 represents the default of assert/assume weak, and F.5.3.1 represents a definition by the prefix of weak. The scope of 16.13.2's unqualified match description remains unresolved.
- The solution condition is that the scope of application of formal semantics can be explained. Check official corrections/interpretations as needed and establish the expectations for finite executions.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is an Annex F derivation rule for using a bare clocked sequence S as a property (an S version of F.3.4.3.1), a statement that 16.13.2 B005 follows the default strength (weak and strong differ on finite executions), or an official erratum.

<a id="four-state-bin-resolution--xzを含む明示的なビン"></a>

## FOUR-STATE-BIN-RESOLUTION — Explicit bins containing x/z

- Source: 19.5.7, PDF physical page 597, B002–B003. For non-wildcard bins, values containing x/z cause a warning and removal of the affected individual value.
- Related: 19.5.4, PDF physical page 595, B002. In the usual explicit integer and transition bins, x/z is matched by case equality.
- Unsolved: The scope of application, whether to remove the normal 4 -state bin at build time, or count the x/z of the sample.
- Status at extraction: 19.5.7 and `SV2023-19.5.7-EXTRACT-WARN-UNKNOWN-TEXT` pending.
- The solution condition is to explain the scope of application of both sections in primary data and to determine the expectations of the value bin and the transition bin respectively.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is a restriction on the scope of 19.5.7 rule 3) and the removal rule (for example, only for a 2-state effective type), a statement that 19.5.4's 4-state bins take precedence over 19.5.7 removal, or an official erratum. Required separately for both value bins and transition bins.

<a id="cross-retain-option-scope--自動クロスビン保持オプションの配置"></a>

## CROSS-RETAIN-OPTION-SCOPE — Placement of the automatic-cross-bin retention option

- Source: 19.7, PDF physical page 608, B025. It includes `cross_retain_auto_bins` among the options that can be set only in a covergroup / coverpoint definition.
- Related: Table 19-2 (physical page 609, B038) and the structure definitions in 19.10 permit covergroup/cross and do not include it in coverpoint.
- Unresolved: You need to separate the restrictions of allowable syntactic layout from the restrictions of being able to change it after build.
- Status at extraction: 19.7 and `SV2023-19.7-EXTRACT-CROSS-RETAIN-SCOPE-TEXT` pending.
- The problem is solved by explaining the relationship between table, structure and text in primary data and by determining the expected position and timing of changes.
- Reconsideration of 2026-10-24 (resolved): cross_retain_auto_bins is an option usable only at definition time. Within a covergroup definition, it can be set only at the covergroup level as a default for crosses or inside a cross, not inside coverpoint or by procedural assignment after instantiation. “covergroup or coverpoint” in B025 holds literally for auto_bin_max and detect_overlap; for cross_retain_auto_bins, read it as covergroup / cross according to Table 19-2 and the structures in 19.10. Rationale: 19.7 B025 groups the 3 items auto_bin_max, detect_overlap, and cross_retain_auto_bins as settable only in a covergroup or coverpoint definition. The main focus of this sentence is the distinction between the time that can be set only at the definition time (other options can be substituted procedurally after generation), as the following sentence shows. For the levels of syntax that can be set, B028 has placed the table 19-2 as its summary. Table 19-2 B038 permits cross_retain_auto_bins for covergroup (the cross default), prohibits it for coverpoint, and permits it for cross. The structures in 19.10 are consistent too: the option for coverpoint (B004) lacks this member, while the cross option (B005) and the option for covergroup (B003) have it. The effects described in Table 19-1 B014 and 19.6.1 B004 are also only for cross bins. Read literally, B025 assigns to a nonexistent option-structure member for coverpoint, and contradicts the table and structure by prohibiting the setting on a cross. Because the definitions in Table 19-2 and the 19.10 structure agree, coverpoint in B025 unambiguously refers to cross for this option: a discrepancy between consistent table/structure definitions and prose. The time constraint of definition time-only is maintained because it does not contradict any of the descriptions. The row without pending interpretations, SV2023-19. The behavior of 7 - EXTRACT-DEFINITION-ONLY-OPTIONS is also "subject to the unresolved cross_retain_auto_bins wording", so the coordinator needs to modify it to match the same interpretation. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="enum-auto-coverage-denominator--enumの自動ビンの分母"></a>

## ENUM-AUTO-COVERAGE-DENOMINATOR — Denominator for enum automatic bins

- Source: 19.11.1, PDF physical page 616, B005–B007. The automatic-bin denominator is `min(auto_bin_max, 2**M)`.
- Related: 19.5.3, PDF physical page 595, B003. enum specifies creating as many bins as there are enumerated values.
- Unsolved point: The denominator of the enumerated values if the number of enumerated values is not a power of 2. How should the enum-specific count be applied to the general formula?
- Status at extraction: 19.11.1 and `SV2023-19.11.1-EXTRACT-AUTO-DENOMINATOR-TEXT` pending.
- Resolution condition: establish the calculation rules for enum from primary sources and determine the ratio when all enumerated values have been observed.
- Reconsideration of 2026-10-24 (still pending): proposed resolution (use the number N of automatic bins created under 19.5.3 as the automatic-bin coverage denominator, excluding valueless bins under B008). Read MIN(auto_bin_max, 2 ** M) as an expression for N for integers coverpoint other than enum; for coverpoint in enum, use the number of enumerated values as the denominator. The handling of the enumerated values exceeding auto_bin_max is not included in this decision. ), but review found the evidence inconclusive, so the hold remains. Reason: The inference of the core is correct. According to 19.8 B012, argument 2 of get_inst_coverage for coverpoint is the “number of defined bins,” which directly supplies the denominator. 19.5.3 B003 is enum's number of bins N as the number of enumerated values. Thus, MIN(auto_bin_max, 2 ** M) in 19.11.1 B006 can be read as an expression for N for cases other than enum. The reason for returning is that rewriting is beyond the scope of judgment. adopted_interpretation states that "the tension of 19.5.3 B003 and the table 19-1 B012 is not included in this judgment if the number of enumerated values exceeds auto_bin_max." However, behavior and review_note unconditionally describe the denominator of enum as the number of enumerated values. For example, with 100 enumerators and auto_bin_max at its default 64, the behavior row would require total = 100, silently resolving the point left undecided. Correct this by limiting behavior and review_note to “the number of automatic bins actually created under 19.5.3,” or restricting the case to at most auto_bin_max enumerated values. Or, the case of exceeding the upper limit is determined separately with reasons. The acceptance criteria can remain unchanged (total = 3 for 3-state enum; 2/3 when sampling only 2-state values).

<a id="cross-auto-coverage-denominator--自動クロスビンを保持しない場合の分母"></a>

## CROSS-AUTO-COVERAGE-DENOMINATOR — Denominator when automatic cross bins are not retained

- Source: 19.11.2, PDF physical page 617, B004–B005. Expresses the automatic-bin count as the product of the bin counts of each coverpoint minus the number of cross products in user bins.
- Related: 19.6.1, B004 and `cross_retain_auto_bins` of table 19-1. When false and explicit bins exist, remove all automatic bins.
- Unsolved: How to adjust the number of automatic bins in the calculation when the keep option is false.
- Status at extraction: 19.11.2 and `SV2023-19.11.2-EXTRACT-CROSS-AUTO-FORMULA-TEXT` pending.
- The solution condition is to explain the retention options and the application conditions of the calculation formula in the primary data and to determine the denominator of the ratio.
- Reconsideration of 2026-10-24 (resolved): Bc is the number of automatic cross bins that actually exist. If the automatic bin is maintained (cross_retain_auto_bins is true, default), then ∏Bj - Bb, and if there is an explicit crossbin with false, then 0, and the denominator is only Bu. Evidence: 19.11.2 B005 defines Bc as the number of automatic cross bins. The equation ∏Bj − Bb of B004 counts the number of products not contained in the user-defined cross-bins, and corresponds to the number of auto-bins under the default of 19.6.1 B004 (keeping the auto-bin for products not intersecting with the user-defined bins). 19.6.1 B004 states that this retention is controlled by cross_retain_auto_bins. Table 19-1 B014 specifies that when false, the presence of even one explicit cross bin removes all automatically generated bins. Thus, when the option is false and explicit cross bins exist, no automatic cross bins remain, and the definition of B005 gives Bc = 0. 19.8 B012 likewise defines the denominator of get_inst_coverage for a cross as the number of defined bins, consistent with this interpretation. The only case where the expression and the definition are not in agreement is when false, and Bc can be uniquely reconstructed from the definition (B005) in the same paragraph and from the table 19-1 (a type of reconstruction of the error of the mathematical expression from the text defining the same concept). This judgment does not include whether the removal occurs as an "explicit cross bin" if only ignore_bins / illegal_bins is explicitly specified, and the acceptance criteria uses the normal bins. The covergroup level is used to set the options. This level is not dependent on the judgment of CROSS-RETAIN-OPTION-SCOPE, since there is no conflict between the table 19-2 and the table 19.7 B025. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="timeformat-precision-domain--時刻表示の小数桁数"></a>

## TIMEFORMAT-PRECISION-DOMAIN — Number of decimals in the time display

- Source: 20.4.3, PDF physical page 626, B006. The integer range `-15..2` is applied to both `units_number` and `precision_number`.
- Related: the example in the same clause (physical page 627, B016, B023) uses `$timeformat(-9, 5, " ns", 10)` and describes displaying 5 decimal places.
- Unsolved point: The scope of application of a description that imposes the same range on the exponent of the time unit and the number of decimal digits of the display.
- Status at extraction: 20.4.3 and `SV2023-20.4.3-EXTRACT-FORMAT-PRECISION-DOMAIN-TEXT` pending.
- Conditions for solving: Verify the range of the formal arguments of the decimal number in the primary data and do not incorrectly test the value 5 as a range error.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is a normative definition of precision_number's meaning (decimal-place count or time-unit exponent) and valid range, or an erratum restricting B006's range to units_number alone.

<a id="file-read-open-modes--読み取り可能なファイルのモード"></a>

## FILE-READ-OPEN-MODES — Readable file mode

- Source: 21.3.4, PDF physical page 670, B004. Files opened for read are marked as r or r+ modes.
- Related: Table 21-6 (physical page 667) is defined as read-write both w+ and a+ and binary versions.
- Unsolved: A set of modes that can be passed to a read task. This is not a test to disable update mode altogether.
- Status at extraction: 21.3.4 and `SV2023-21.3.4-EXTRACT-READ-OPEN-MODES-TEXT` pending.
- The solution is to explain the scope of the read task and the definition of the update mode in the primary document, and to determine the expectations of the permission and prohibition.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is a statement that functions in 21.3.4 can read an fd opened with w+/a+ or their binary variants (or that B004's list is exhaustive), or an official erratum. In addition, the specified results when applying the read function to fd which is not allowed to read.

<a id="virtual-interface-sensitivity--virtual-interfaceのイベント待ち"></a>

## VIRTUAL-INTERFACE-SENSITIVITY — Waiting for virtual interface event

- Source: 25.9, PDF physical page 803, B015. This disables the use of virtual interface components in the sensitivity list.
- Related: the example in B021 of the same clause uses `@(posedge bus.grant)`. The example of 25.9.2 also has a waiting for a clock event via the virtual interface.
- Unsolved point: The border between sensitivity lists and procedural event waiting. We do not accept tests that generally consider the waiting appearing in the example as a violation of the standard.
- Status at extraction: 25.9 and `SV2023-25.9-EXTRACT-VIRTUAL-SENSITIVITY-TEXT` pending.
- Conditions for solving: To compare with detailed rules of event control and clocking, and to determine the scope of forbidden and allowed syntax.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is a definition of sensitivity-list scope—only event controls at the start of always procedures and implicit always_comb lists, or also procedural event controls and clocking-event waits—or an explicit rule allowing/prohibiting virtual-interface components in event controls.

<a id="virtual-clocking-modport-scope--クロッキングブロックとmodport"></a>

## VIRTUAL-CLOCKING-MODPORT-SCOPE — Clocking block and modport

- Source: 25.9.2, PDF physical page 805, B002. This is a description of how to limit direct clock references to interfaces without modports.
- Related: 25.10, physical page 807, B002 Differentiate between the presence of a modport and the restriction of access by choice. 25.9 also makes the selected modport part of the type.
- Unsolved: Does "no modport" mean that the declaration does not exist or does it mean that the reference is not selected?
- Status at extraction: 25.9.2 and `SV2023-25.9.2-EXTRACT-VIRTUAL-CLOCKING-SCOPE-TEXT` pending.
- Resolution condition: distinguish an unselected virtual interface from references through a selected modport and explain how the two passages' scopes apply.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence: an explicit rule for access to interface members, including clocking blocks, through a virtual interface with no modport selected when the interface declares modports (a virtual-interface counterpart of 25.5 B025), or text showing that “modports” in 25.9.2 B002 means selection.

<a id="generate-region-container--generate領域を置ける構文上の位置"></a>

## GENERATE-REGION-CONTAINER — syntax location for the generate area

- Source: 27.3, PDF physical page 819, B005. This restricts the explicit generate area to just below the module.
- Related: The formal syntax of 24.3 and 25.3 also includes the generate area in the program and interface items.
- Unsolved point: the scope of the term module. The outline of this article alone does not prohibit the formal syntax of program/interface.
- Status at extraction: 27.3 and `SV2023-27.3-EXTRACT-GENERATE-REGION-CONTAINER-TEXT` pending.
- Resolution condition: establish region-placement conditions from each container's formal syntax and item restrictions.
- Reconsideration of 2026-10-24 (resolved): an explicit generate region may appear directly within the body of a container (module, interface, program, checker) whose item syntax directly includes generate_region. Read “module” in 27.3 B005 as referring to these containers. Retain the “direct” restriction (excluding placement inside packages or generate blocks, for example) and the prohibition on nesting. 27.3 B005 assumes that the explicit generate area can only be placed just below the module. In contrast, the item grammar of each container in normative Annex A explicitly lists generate_region as a direct item: module has non_port_module_item in 23.2.4 B003; interface has non_port_interface_item in 25.3 B002; program has program_generate_item in 24.3 B005; checker has checker_or_generate_item through checker_generate_item in 17.2 B002/B003. Footnote 5 in 24.3 B006 and footnote 6 in 17.2 B004 constrain the contents of program/checker generate items. Footnote 35 (B009) in 27.3's own syntax box also constrains generate_item within interface and checker declarations. The examples of 17.9 (B008 - B009, B015) place the generate area just below the checker (reference). Chapter 27 is written around modules throughout (“module items” in 27.2 B002, and 27.3 B004). Annex A B004 says the text supplements BNF, but a restriction that disallows all generate_region explicitly listed for the 3 containers contradicts the syntax definition rather than supplementing it. Since the syntax definition side is consistent, the "module" of B005 can be uniquely reduced to a container (module, interface, program, checker) with generate_region as a direct item (type of the text and syntax definition mismatch). B005's “direct” restriction and prohibition of nesting (separate row SV2023-27. The 3 - EXTRACT-GENERATE-OPTIONAL-REGION) is maintained. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="ambiguous-strength-union--曖昧な強度範囲の結合"></a>

## AMBIGUOUS-STRENGTH-UNION — Combining ambiguous strength ranges

- Source: 28.12.2, PDF physical page 846, B024. Describes combining 2 ambiguous strengths as a range containing the constituent signals' strength levels.
- The superiority of the strength of 28.12.1 and the residue and erasure rules of 28.12.3 for each component are discussed. The ambiguous strengths include the strength ranges with known values.
- Unresolved: whether this is a general rule retaining all constituent levels even when one range is always stronger than the other.
- Status at extraction: 28.12.2 and `SV2023-28.12.2-EXTRACT-AMBIGUOUS-UNION-TEXT` pending.
- Resolution condition: explain when range combination and strength dominance apply; do not simply use a union of ranges as the expected value.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is an explicit rule/diagram for combining 2 ambiguous signals where one range is always stronger than the other, or a statement that 28.12.3's componentwise rule also applies between ambiguous signals.

<a id="width-coincident-edges--幅チェックの同時エッジ"></a>

## WIDTH-COINCIDENT-EDGES — Simultaneous edges in width checks

31.4.4 is written as opposing edges not synchronizing, but the scope of application including delta events at the same time is unknown. This is not the expected value to eliminate zero-width pulses in general.

- Source: 31.4.4, PDF physical page 913, B020.
- Ledger ID: `SV2023-31.4.4-EXTRACT-WIDTH-COINCIDENT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination of 2026-10-24 (continuation of retention): Missing as a determiner: There is no explicit rule that defines how $width should treat reverse transitions within the same time slot as reference/data events (whether to detect the edge at the same time or update the timestamp). There is no description indicating that B020 is merely an informative description.

<a id="notifier-argument-position--notifierの引数位置"></a>

## NOTIFIER-ARGUMENT-POSITION — position of the notifier argument

Although 31.6 says “last argument,” the formal syntax of composite timing checks has arguments after notifier too. It is necessary to distinguish between the syntax of each API and the scope of the general description.

- Source: 31.6, PDF physical page 916, B003.
- Ledger ID: `SV2023-31.6-EXTRACT-NOTIFIER-POSITION-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolution) of 2026-10-24: notifier is passed at the position specified by the syntax of each timing check. The last argument in $setup / $hold / $recovery / $removal / $skew / $period / $width / $nochange. For $setuphold / $recrem, timestamp_condition, timecheck_condition, delayed_reference, and delayed_data may follow; for $timeskew / $fullskew, event_based_flag and remain_active_flag may follow. Source: 31.6 B003 describes the notifier in general as the last argument of the timing check. The definitions of notifier placement consistently put optional arguments after notifier in 4 kinds of extended checks. The relevant items are Syntax 31-1 (31.2 B003 / B004), the syntax excerpts in each clause (31.3.3 B003, 31.3.6 B003, 31.4.2 B003, 31.4.3 B003), and Annex A.7.5.1 B001 / B002. 1.8 B047 Appendix A is a formal syntax. The argument tables use the same order, with timestamp_condition and others after notifier (Tables 31-3 31.3.3 B012 onward, 31-6 31.3.6 B012 onward, 31-8 31.4.2 B011 onward, and 31-9 31.4.3 B013 onward). The 31.9.2 B005 in the specification text specifies that timestamp_condition and timecheck_condition follow immediately after the notifier. The examples (31.9.2 B006 / B012 / B013, and $timeskew with the 31.4.2 flag) use the same form. The definition side is consistent, and in other 8 checks the notifier is actually the last argument. Therefore, the "last argument" of B003 can be read uniquely as the position of the notifier defined by the syntax of each check. The kind is left as boundary. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="library-map-contents--ライブラリマップの内容"></a>

## LIBRARY-MAP-CONTENTS — Contents of the library map

33.3.2's limited contents list conflicts with the formal syntax in 33.3.1 and A.1.1, which includes config declarations and empty statements. A.1.1 is verified.

- Source: 33.3.2, PDF physical page 938, B003.
- Ledger ID: `SV2023-33.3.2-EXTRACT-MAP-LIMITED-CONTENTS-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence: there is no text determining whether config_declaration and the empty statement ';' are legal within lib.map. Examples include a normative example placing config in lib.map, a restriction note on library_text such as A.10, or a rule establishing precedence between the main text and Annex A syntax.

<a id="config-parameter-override-grammar--configのパラメータ初期化構文"></a>

## CONFIG-PARAMETER-OVERRIDE-GRAMMAR — Parameter initialization syntax for config

33.4.3 describes resets using #() and .W(), but their relationship to the official syntax in 33.4.1 / A.1.5 is unclear. You need to confirm the delimiter to accept and the blank specification.

- Source: 33.4.3, PDF physical page 943, B034.
- Ledger ID: `SV2023-33.4.3-EXTRACT-CONFIG-RESET-GRAMMAR-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (hold retained): there is no decisive production or note accepting `use #( ... )` with an empty `use #()`, nor normative text showing how to express a reset of all parameters in the A.1.5 grammar.

<a id="data-keyname-combine--データ鍵の選択"></a>

## DATA-KEYNAME-COMBINE — Data key selection

34.5.12.2 repeats data_keyname for both selection terms, unlike the decryption-side explanation that pairs it with data_keyowner.

- Source: 34.5.12.2, PDF physical page 959, B003.
- Ledger ID: `SV2023-34.5.12.2-EXTRACT-NAME-COMBINE-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): for encryption output, if the input contains data_keyname, the encryption tool combines data_keyname and data_keyowner to determine the data-encryption key. Read occurrence 2 of data_keyname in the text as data_keyowner. Source: 34.5.12.2 B003 says "Combine this pragma expression (data_keyname) with data_keyname", which is a combination of itself, read literally, and does not contain any content as a rule. All descriptions that define the same concept are given as data_keyowner. In the same section, B002 assumes that data_keyname is incorrect unless it is one of the known keys of the specified data_keyowner, and B005 assumes that the key 1 is chosen by combining data_keyname and data_keyowner during decryption. 34.5.10.2 B002 specifies that data_keyowner is used by the encryption tool to select the encryption key for data_block. The same type of sentences 34.5.18.2 B003 (combining digest_keyname with digest_keyowner) and 34.5.25.2 B003 (combining key_keyname with key_keyowner) are also in the same form. The wrong suboperator can be uniquely reduced to data_keyowner, and there is no conflicting specification with the literal reading. The rows after correction do not exceed the obligations already in 34.5.10.2 B002. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="digest-key-block-name--ダイジェスト鍵の格納先"></a>

## DIGEST-KEY-BLOCK-NAME — Where to store the digest keys

34.5.16.2's digest_key_block is not in the official keyword set. You need to establish the relationship with the associated key_block.

- Source: 34.5.16.2, PDF physical page 961, B003.
- Ledger ID: `SV2023-34.5.16.2-EXTRACT-DIGEST-OWNER-OUTPUT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (still pending): the missing decisive evidence is a definition of digest_key_block. In the case of digital signatures, there is no explicit description of which method (key_method or digest_key_method) to use to encrypt digest_keyowner and which block (key_block or digest_block) to place it in.

<a id="digest-key-owner-spelling--ダイジェスト鍵所有者の名前"></a>

## DIGEST-KEY-OWNER-SPELLING — Name of the digest key owner

The digest_key_keyowner of 34.5.22.2 is different from the digest_keyowner defined by 34.5.16.

- Source: 34.5.22.2, PDF physical page 964, B003.
- Ledger ID: `SV2023-34.5.22.2-EXTRACT-DIGEST-KEY-OWNER-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (fix) of 2026-10-24: digest_key_keyowner in the digest generation paragraph is read as the defined pragma keyword digest_keyowner. The message digest is encrypted with a key chosen from digest_keyowner and digest_keyname / digest_public_key / digest_decrypt_key. Rationale: 34.5.22.2 B003 specifies the digest encryption key using digest_keyname, digest_key_keyowner, digest_public_key, and digest_decrypt_key. However, digest_key_keyowner is not defined in either the table 34-1 or 34.5, and the full-text search only appears in this 1. The definition side is consistently digest_keyowner. These include 34.4 B020 in Table 34-1, Syntax 34.5.16.1 B002, 34.5.16.2 B002 (selecting the digest_block encryption key using the digest_keyowner value), and 34.5.18.2 B002 / B004 (the combination of digest_keyname and digest_keyowner). The other 3 in the row are all defined digest_* selectors, and there is only digest_keyowner as a defined keyword for the owner of the digest key. key_keyowner is the owner of the key encryption key (34.5.23.2) and is not involved in encrypting the digest. Therefore, it can be corrected as a spelling error. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="key-keyname-decrypt-target--復号対象のブロック"></a>

## KEY-KEYNAME-DECRYPT-TARGET — Blocks to be decrypted

34.5.25.2 specifies data_block, but the key-input definition and 34.5.23 / . 24 ／. 26 targets key_block.

- Source: 34.5.25.2, PDF physical page 966, B004.
- Ledger ID: `SV2023-34.5.25.2-EXTRACT-KEY-NAME-DECRYPT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolving) of 2026-10-24: In the decryption input, a single key is chosen from the combination of key_keyname and key_keyowner, and the key is used to decrypt key_block. In this article, data_block is read as key_block. Source: 34.5.25.2 B004 writes that the key selected in key_keyname and key_keyowner decrypts data_block. However, the description that defines the sequence of key_* is consistent, and the decrypted object is key_block. Examples are B002 in the same section (key_keyname names the key used to decrypt key_block), 34.4 B029 in Table 34-1 (key_keyname names a key-encryption key), B031 (key_block is a key-data block), 34.5.23.2 B004, 34.5.24.2 B002/B004, and 34.5.26.2 B004. The key for decrypting data_block is selected by data_keyname and data_keyowner (34.5.12.2 B005, 34.5.10.2 B004). If read literally, the 2 selection rules would each choose a "single key" for data_block, which conflicts with the hierarchy of the data key and the key encryption key. The sentence B004 is the same type as 34.5.12.2 B005 and 34.5.18.2 B004, but the block name is misrepresented. There is only one block corresponding to key_*, key_block, so it can be uniquely restored. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="remove-callback-api-name--コールバック解除api名"></a>

## REMOVE-CALLBACK-API-NAME — API name for callback removal

For vpi_remove_callback in 37.2.2, API as defined by 38.39 and K.2 B151 is vpi_remove_cb. Do not add an independent API.

- Source: 37.2.2, PDF physical page 1000, B003.
- Ledger ID: `SV2023-37.2.2-EXTRACT-CALLBACK-RELEASE-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolution) of 2026-10-24: vpi_remove_callback() of 37.2.2 is vpi_remove_cb(). vpi_remove_cb() releases the corresponding callback handle as part of its operation. Source: 37.2.2 B003 writes that vpi_remove_callback() releases the corresponding callback handle. However, this name occurs only these 1 times in the entire text and is absent from normative header K.2. The callback-removal API is consistently defined as vpi_remove_cb(). These include Table 36-1 (36.11 B007), related routines in 38.36 B009, 38.36.1.3 B003, the definitions in 38.39 B002–B010, and the `vpi_remove_cb(vpiHandle cb_obj)` declaration in K.2 B151. 38.39 B010 assumes that its handle is deactivated after the call, which also matches the description of the release. Therefore, it can be corrected as a spelling error. Do not add another API. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="callback-relation-cardinality--コールバック関係の多重度"></a>

## CALLBACK-RELATION-CARDINALITY — Multiplicity of callback relationships

You need to establish the relationship between the single arrow of 37.80 and the description that repeats multiple callbacks of 38.23 / 38.36.

- Source: 37.80, PDF physical page 1083, B002, B003, B004.
- Ledger ID: `SV2023-37.80-EXTRACT-CALLBACK-ARROW-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (still pending): no statement explicitly specifies whether object-to-callback traversal uses vpi_handle or vpi_iterate, that is, one-to-one or one-to-many. A double-arrow diagram consistent with detailed definition 2, or text explicitly requiring access by iteration, is needed.

<a id="active-time-format-name--時刻表示形式への関係名"></a>

## ACTIVE-TIME-FORMAT-NAME — Relationship name to time format

The figure in 37.82 and K.2 B043 use vpiActiveTimeFormat, while the explanatory text uses vpiActiveFormat. The header is matched, but the source discrepancy is left.

- Source: 37.82, PDF physical page 1084, B003.
- Ledger ID: `SV2023-37.82-EXTRACT-ACTIVE-FORMAT-NAME-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): if $timeformat() has not yet been called, vpi_handle(vpiActiveTimeFormat, NULL) returns NULL. Read vpiActiveFormat in the detailed description as vpiActiveTimeFormat. Rationale: inspection of physical page 1084 in PDF shows that the tag in the 37.82 diagram (B002) is vpiActiveTimeFormat. The standard header K.2 B043 is also defined as `#define vpiActiveTimeFormat 119`. vpiActiveFormat in detailed section B003 is not defined in any of headers K, L, or M, and appears only these 1 times in the entire text. The figure and the header definition match, so it can be corrected as a spelling error. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="scalar-object-format-names--スカラー値形式の名前"></a>

## SCALAR-OBJECT-FORMAT-NAMES — Name of the scalar value format

Distinguish vpiScalar/vpiStrength in the text of 38.15 from the value formats vpiScalarVal/vpiStrengthVal in Table 38-3 and K.2 B108.

- Source: 38.15, PDF physical page 1102, B014.
- Ledger ID: `SV2023-38.15-EXTRACT-SCALAR-OBJECT-FORMAT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): specifying vpiObjTypeVal for a scalar replaces format with either vpiScalarVal or vpiStrengthVal and sets the value. Read vpiScalar and vpiStrength in the text as these 2 value-format constants. Rationale: 38.15 B014 states that the format field is changed for vpiObjTypeVal, and lists vpiScalar or vpiStrength for scalars. The values in the format field are consistently *Val value format constants on the definition side. Examples are comment `vpi[...Scalar,...,Strength,...]Val` in Figure 38-7 (38.15 B016), vpiScalarVal in Table 38-3 B029, vpiStrengthVal in B035, K.2 B105, and the value-format list B108. The other items in the same clause are vpiIntVal, vpiRealVal, vpiTimeVal, and vpiVectorVal, all of which are *Val. vpiStrength is not defined in any header; only vpiStrength0 / 1 exist. vpiScalar is defined in K.2 B054 as a net/port property (value 17), rather than a value format. 17 is vpiRawTwoStateVal. vpiScalarVal and vpiStrengthVal are therefore unambiguous. If you want to return either, you can use either as in the text. The other issue UDP-SYMBOL-BYTE-ORDER in 38.15 was also marked resolve, so both issues are resolved and the clause can be closed. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="udp-symbol-byte-order--udpシンボルのバイト配置"></a>

## UDP-SYMBOL-BYTE-ORDER — UDP Byte layout of symbol

38.15 says abit/bbit, but the structure has aval/bval. There is also ambiguity in the description of the position of 4 pieces and the symbol arrangement of 2 byte units within the 32 bit pair.

- Source: 38.15, PDF physical page 1105, B041.
- Ledger ID: `SV2023-38.15-EXTRACT-UDP-SYMBOL-ORDER-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolution) of 2026-10-24: UDP Each s_vpi_vecval element of a table entry contains a symbol of 2 bytes in the following order: aval[ 31:16 ], aval[ 15:0 ], bval[ 31:16 ], and bval[ 15:0 ]. In each pair, the 1 character is the upper byte, and the 1 character symbol is the lower 2 byte, ASCII\0. The abit and bbit in this text refer to aval and bval. The text of 38.15 B041 alone can be used to determine the layout. From array-size expression ((table_entry_size–1)/4+1), a s_vpi_vecval 1 element contains 4 symbols. Since each symbol is 2 bytes, the 1 element is 8 bytes. Figure 38-8 (B018) and K.2 B097/B098 show that s_vpi_vecval has only 2 fields, aval and bval, each 32 bits. Mapping the text's 4 positions (abit's most/least significant parts and bbit's most/least significant parts) to 4 symbols at a 1-to-1 ratio, with 2 bytes per symbol, necessarily makes each position the upper 16 bits or lower 16 bits of its field. abit and bbit are determined by pointing to aval and bval, since there are only two possible fields. In order within the pair, the text is listed from the top, so "2 byte of the pair" (the position where ASCII \ 0 enters the 1 character symbol) is read as the lower byte. Cross-checking the example code and output (B050, B054, B058) shows that all 3 examples agree with placing the 1-th symbol in the upper 16 bits of aval and the first character in the upper byte of the pair. For example, in `0(01):?:-`, aval becomes 0x 30003031. However, we do not rely on the example code as the basis for the correction. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="array-shortreal-field--shortreal取得フィールド"></a>

## ARRAY-SHORTREAL-FIELD — shortreal Fields obtained

The description of 38.16 is shortrealvals, the declaration of the same section and K.2 B106 are shortreals. The official header is verified.

- Source: 38.16, PDF physical page 1108, B018.
- Ledger ID: `SV2023-38.16-EXTRACT-SHORTREAL-ARRAY-FIELD-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): vpiShortRealVal retrieves num float values through the shortreals union member of s_vpi_arrayvalue. In this text, shortrealvals is read shortreals. Rationale: the description of vpiShortRealVal in 38.16 B018 says to store the value in the union's *shortrealvals field. However, in declaration B016 in the same clause and the s_vpi_arrayvalue definition in normative header K.2 B106, the union's only float member is `float *shortreals`. The name shortrealvals appears in the whole text only in 38.16 B018 and 38.35 B017. The declaration and header match, and there is only one float member for the "field of union" that the text says, so it can be corrected as a spelling error. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="put-array-shortreal-field--shortreal設定フィールド"></a>

## PUT-ARRAY-SHORTREAL-FIELD - shortreal Configuration Fields

The description of 38.35 is shortrealvals, the declaration and K.2 B106 are shortreals. The official header is verified.

- Source: 38.35, PDF physical page 1130, B017.
- Ledger ID: `SV2023-38.35-EXTRACT-PUT-SHORTREAL-FIELD-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): vpiShortRealVal passes num float values to be set through the shortreals union member of s_vpi_arrayvalue. In this text, shortrealvals is read shortreals. Evidence: the description of vpiShortRealVal in 38.35 B017 says *shortrealvals. However, declaration B015 in the same clause, 38.16 B016, and normative header K.2 B106 consistently give only `float *shortreals` as the float member of the union in s_vpi_arrayvalue. The shortrealvals are only 38.16 B018 and this in the whole text, and they are not in line with the declaration. For the same reason as ARRAY-SHORTREAL-FIELD, it can be uniquely corrected by shortreals. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="assertion-system-fail-action-event--失敗アクションのイベント"></a>

## ASSERTION-SYSTEM-FAIL-ACTION-EVENT — Fail-action events

The description of the system failure action enable/disable callback of 39.4.1 refers to the success evaluation. It is necessary to align with the success/failure distinction of 39.4.2 / 39.5.1.

- Source: 39.4.1, PDF physical page 1150, B003.
- Ledger ID: `SV2023-39.4.1-EXTRACT-SYSTEM-DISABLE-FAIL-TEXT`.
- Source: 39.4.1, PDF physical page 1150, B003.
- Ledger ID: `SV2023-39.4.1-EXTRACT-SYSTEM-ENABLE-FAIL-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): treat cbAssertionSysEnableFailAction / cbAssertionSysDisableFailAction as callbacks reporting that execution of fail actions (actions executed on failure) has been enabled or disabled throughout the assertion system. Treat “for vacuous and nonvacuous success” as a phrase mistakenly copied from the pass-action entry, and impose no success-related condition. Evidence: only the cbAssertionSysEnableFailAction / cbAssertionSysDisableFailAction entries in 39.4.1 B003 say that fail actions are enabled or disabled “for vacuous/nonvacuous success.” Descriptions defining the same operation consistently omit any success-related qualification. The system control vpiAssertionSys{Enable,Disable}FailAction (39.5.1 B003) specifies only enabling or disabling execution of an assertion's fail action. The assertion-level cbAssertion{Enable,Disable}FailAction (39.4.2 B008) likewise says only “that assertion's fail action.” The same applies to the FailOn/FailOff of $assertcontrol (including 20.11 B035 and the default $error). The fail action (fail statement) is a sentence that is executed on failure (16.3 B010), and the fail action that is executed on success is not anywhere in the specification, so there is no object to which the conditional clause can refer. This qualifier can be read as wording copied from the immediately following pass-action entries (39.4.1 B003, PassOn/PassOff in 20.11 B035). In both cases, the callback is triggered by the enable or disable of the fail action. The definition side is consistent, so the problem is solved. However, since 39.4.1 keeps ASSERTION-SYSTEM-OFF-CALLBACKS, the section remains in_progress. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="assertion-system-off-callbacks--停止中のアサーションコールバック"></a>

## ASSERTION-SYSTEM-OFF-CALLBACKS — Assertion callbacks while stopped

You need to distinguish between the description of 39.4.1 as a new callback stop and the scope of 39.5.1 as a running trial and maintaining an existing callback. Do not confuse new registration with actual call.

- Source: 39.4.1, PDF physical page 1150, B003.
- Ledger ID: `SV2023-39.4.1-EXTRACT-SYSTEM-OFF-CALLBACK-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is normative text specifying whether the following callbacks are invoked while stopped. (1) Events from attempts already running before the stop (cbAssertionSuccess / Failure / Step, etc.). ( 2 ) Not belonging to the trial ( lock/unlock, action control, etc. ). The "do not affect existing callbacks" of 39.5.1 only indicates that the registration remains, and does not determine whether a call is made.

<a id="coverage-module-macro-name--モジュール範囲マクロ名"></a>

## COVERAGE-MODULE-MACRO-NAME — Module-scope macro name

SV_MODULE_COV in 40.3.2.1 differs from SV_COV_MODULE in 40.3.1 / Table 40-2.

- Source: 40.3.2.1, PDF physical pages 1159, 1160, B013, B014.
- Ledger ID: `SV2023-40.3.2.1-EXTRACT-MODULE-SCOPE-MACRO-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): SV_MODULE_COV in 40.3.2.1's scope-selection text refers to \`SV_COV_MODULE defined in 40.3.1. Use \`SV_COV_MODULE to select module-local scope, excluding child hierarchy; do not require a separate predefined macro named SV_MODULE_COV. Rationale: SV_MODULE_COV occurs in only 2 places across the entire standard—40.3.2.1 B013 and B014—and is defined nowhere. The predefined macro for module-local scope is \`SV_COV_MODULE (value 10) in 40.3.1 B005, appearing 4 times in the entire text. 40.3.2.1's own Table 40-2 (B018) and the example in Figure 40-1 (B032) also use this spelling. Its counterpart \`SV_COV_HIER likewise uses the defined spelling in B013 and B014; all predefined scope macros share the SV_COV_ prefix. Because the definitions (40.3.1, tables, and examples) agree, read the spelling in the text as \`SV_COV_MODULE. This is not adding another macro as already defined. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="current-coverage-return-text--現在値と最大値の戻り値"></a>

## CURRENT-COVERAGE-RETURN-TEXT — Returns the current value and maximum value

Although 40.3.2.3 defines the current covered-item count and ratio, the positive-return-value description repeats the maximum coverable-item count. This affects the expected value if only part of the coverage is used.

- Source: 40.3.2.3, PDF physical page 1162, B007.
- Ledger ID: `SV2023-40.3.2.3-EXTRACT-CURRENT-VERSUS-MAX-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): positive return value pos_num of $coverage_get is the number of covered items of the relevant type in the specified hierarchy (the current coverage level). This is not the maximum number of items that can be covered. The negative value and the meaning of 0 remains B007. Rationale: within 40.3.2.3, B003, B004, and B005 are mutually consistent. B003 defines $coverage_get as the function that obtains the current coverage value. B004 gives coverage% = $coverage_get()/ $coverage_get_max()× 100. B005 is specified as having the same type as $coverage_get_max ( 40.3.2.2 ), but pos_num represents the current coverage level, i.e., the number of items covered. The positive value items of B007 are identical to the text of 40.3.2.2 B004, and can be read as a copy of the part that B005 says it replaces. If B007 is taken literally, $coverage_get returns the same value as $coverage_get_max, and the ratio of B004 is always 100%, which is not compatible with B003 and B005. The problem is solved because B005 itself specifies the reading of the type of B007 (-2 / -1/0 are common, and the positive value is the current value). The meaning of -2 / -1/0 is not changed. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="fsm-state-value-argument--fsm状態値api引数"></a>

## FSM-STATE-VALUE-ARGUMENT — FSM state value API argument

40.5.2 describes argument 2 of vpi_get_value as a state handle, but 38.15 and K.2 B162 require p_vpi_value.

- Source: 40.5.2, PDF physical page 1169, B044, B045.
- Ledger ID: `SV2023-40.5.2-EXTRACT-FSM-STATE-VALUE-CALL-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolution) of 2026-10-24: The value of the FSM state is obtained in vpi_get_value ( fsm_state_handle, value_p ). The 1 argument is the handle of the FSM state, the 2 argument is the normal p_vpi_value, and the value is stored in s_vpi_value according to the rules of 38.15. Rationale: the normative definition of vpi_get_value is consistent between 38.15 and the official header K.2 B162. 38.15 B004, B006, B008, and B009 specify a void return, argument 1 as vpiHandle obj, and argument 2 as p_vpi_value value_p; the value goes into application-allocated s_vpi_value (B011). The prototype in K.2 B162 is also (vpiHandle expr, p_vpi_value value_p). C has no overloading. 40.5.2 B002 also states that it adds a property to vpi_get, but does not specify a new call form. Argument 1, fsm_state_handle, of 40.5.2 B044 identifies the object whose value is retrieved, so returning the state value in B045 must mean returning it through value_p. The 2 'state-handle' argument is not a handle type, so it is judged to be a misspelling of the pointer to the value structure. Value formatting follows the format rules in 38.15 (B013, B014), without adding new obligations. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="vpi-coverage-save-constant--カバレッジ保存定数名"></a>

## VPI–COVERAGE-SAVE-CONSTANT — Coverage-save constant name

coverageSave in 40.5.3 differs from vpiCoverageSave in 40.5.1 and M.2 B068. The check with the official header is complete.

- Source: 40.5.3, PDF physical page 1169, B005, B006, B007.
- Ledger ID: `SV2023-40.5.3-EXTRACT-VPI-COVERAGE-SAVE-NAME-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): coverageSave in 40.5.3 denotes constant vpiCoverageSave defined in 40.5.1 and M.2. Saving uses vpi_control(vpiCoverageSave, \<coverageType\>, name), with semantics from $coverage_save. Rationale: coverageSave occurs at only 1 location in 40.5.3 B006 across the standard, and B007 in the continuation of that sentence explicitly refers to its definition in 40.5.1. The coverage-control constant in 40.5.1 B002 is vpiCoverageSave, and official header M.2 B068 also defines vpiCoverageSave (755). The parallel description of merge (40.5.3 B009) uses vpiCoverageMerge, as defined. coverageSave is also not an angle-bracketed substitution item such as \<coverageControl\> in B003 and B004. Because the definitions (40.5.1 and M.2) are consistent, interpret this as vpiCoverageSave. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="bind-semicolon-grammar--bindの終端セミコロン"></a>

## BIND-SEMICOLON-GRAMMAR — bind's final semicolon

A.1.4 adds a semicolon after bind_instantiation, but every alternative in A.4.1 already has a terminating semicolon. Because expansion duplicates it, the relationship to the main-text syntax in 23.11 must be resolved.

- Source: A.1.4, PDF physical page 1177, B003.
- Ledger ID: `SV2023-A.1.4-EXTRACT-BIND-INSTANCE-GRAMMAR`.
- Source: A.1.4, PDF physical page 1177, B003.
- Ledger ID: `SV2023-A.1.4-EXTRACT-BIND-SCOPE-GRAMMAR`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (hold retained): decisive evidence is missing—normative text establishing that bind_directive needs only 1 terminating ';' (such as a correction to BNF or a note in A.10), or official errata. At present, a single ';' is supported only by informative examples and an inference from the explanation of 23.11 B008.

<a id="sequence-copyout-direction--シーケンスのコピーアウト方向"></a>

## SEQUENCE-COPYOUT-DIRECTION — direction of the sequence copyout

F.4.1.1 describes the prohibition on duplicate actual arguments as inout/input, while 16.8.2 says inout/output. Do not add additional restrictions to input.

- Source: F.4.1.1, PDF physical page 1244, B008.
- Ledger ID: `SV2023-F.4.1.1-EXTRACT-ACTUAL-DISTINCT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): read 'input' in F.4.1.1 B008 as a typo for 'output' and as a restatement of 16.8.2, requiring distinct actual arguments for inout/output local-variable formal arguments. As a result, the results of copy-out assignment of 6(b) and 6(c) are not dependent on the order. Do not impose a distinctness constraint on actual arguments for input formals. Rationale: checking F.4.1.1 B008 in PDF (physical page 1244) gives “under 16.8.2, for distinct local-variable formals f and f' whose direction is inout or input, a_f ≠ a_f'” (the extracted text corrupts ≠ to =). We conclude that the results of assignment of 6(b) and 6(c) are not dependent on the order. This paragraph calls itself a restatement of 16.8.2; its reference 16.8.2 B012 makes it an error to connect the same local variable as an actual argument to 2 or more inout/output local-variable formals. Only 6(b) (inout) and 6(c) (output) generate copy-out assignments (F.4.1.1 B007); input (6(a)) does not generate an assignment. An input actual argument may be any expression (16.8.2 B012 requires references to local variables only for inout/output). A distinctness condition targeting input cannot exclude 2 outputs sharing the same actual argument, so the paragraph's conclusion does not follow. Resolve this because only inout/output agrees with the reference and supports the conclusion. No new restrictions are added to input. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="vacuity-next-index--nexttimeの非空虚性の添字"></a>

## VACUITY-NEXT-INDEX — Index in nexttime nonvacuity

The spelling nextime and unbound index i in F.5.3.3 need to be compared against nexttime and index 1 in F.5.3.1.

- Source: F.5.3.3, PDF physical page 1251, B002.
- Ledger ID: `SV2023-F.5.3.3-EXTRACT-NEXT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): nexttime P is nonvacuous when |w| \> 0 and P is nonvacuous on w^{1..}. Read nextime as nexttime, and use suffix index 1, the same as for nexttime in F.5.3.1, for unbound i. Rationale: the nexttime row in F.5.3.3 B002 of PDF (physical page 1251) spells it 'nextime', has no quantifier for suffix index i, and gives the condition |w|\>0. Other lines that use i are all bound to i in the form of "there is an i", but this line is not bound to it. Neutral satisfaction of nexttime is defined in F.5.3.1 B013 (PDF 1250) as |w|=0 or w^{1..} satisfying P; nexttime examines only suffix 1. Nonvacuity for the other operators in F.5.3.3 (|-\>, until, always, etc.) is also defined on the same suffix as neutral satisfaction. The nexttime row's |w|\>0 negates the |w|=0 branch in F.5.3.1, so the suffix in the remaining branch is unambiguously 1. The spelling 'nextime' is a typo for the nexttime form (reserved word nexttime) in F.3.2 B009. This is the case when the index can be uniquely reconstructed from the definition of the same concept (F.5.3.1). The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="local-accept-context--accept_on式のローカル文脈"></a>

## LOCAL-ACCEPT-CONTEXT — local context of the accept_on formula

In F.5.6.1, branch 2 of accept_on omits the local context L0. The relationship between the 1 branch and the definition of the neighborhood needs to be explained.

- Source: F.5.6.1, PDF physical page 1255, B007.
- Ledger ID: `SV2023-F.5.6.1-EXTRACT-ACCEPT-CONTEXT-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): read branch 2 of accept_on(b) P as w^{0, i-1}T^ω, L0 ⊨ P, evaluating P in the same input context L0 as branch 1. Rationale: F.5.6.1 B002 introduces local-variable contexts L0/L1, and every unclocked-property P satisfaction relation in B007 passes the context in the form w, L0 ⊨ … . Branch 1 of accept_on is also w, L0 ⊨ P, but branch 2 is w^{0, i-1}T^ω ⊨ P, omitting the context (checked in PDF 1255). The relation without a context is defined in F.5.6.1 only for clocked property Q in item 1 of B007 (using empty context {}); it is not defined for unclocked P. The context-free definition of F.5.3.1 assumes the absence of local variables (F.5.3.1 B002), so it cannot be applied to P with local variables. The structurally equivalent abort, a top-level disable iff (B004, B005), passes the same L0 to the extended prefix w^{0, i-1}⊥^ω. 16.12.14 likewise only prohibits local-variable references in the abort condition; it does not say that operand P's context changes. With the relationship already defined, the only way to match the 1 branch and the surrounding expressions is to use L0, and there is no basis for other ways of matching, such as the empty context {}. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="local-property-disabled-marker--ローカル宣言式のdisabled記号"></a>

## LOCAL-PROPERTY-DISABLED-MARKER — Disabled symbol in local declaration

The declaration expression for ordinary property P in F.5.6.1 has the superscript d from the top-level disabled relation. The inconsistency with the surrounding ordinary satisfaction relation remains pending.

- Source: F.5.6.1, PDF physical page 1255, B007.
- Ledger ID: `SV2023-F.5.6.1-EXTRACT-LOCAL-DECLARATION-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): w, L0 ⊨ (t v; P) is defined as equivalent to w, L0 \v ⊨ P (ordinary neutral satisfaction with v removed from the context). Treat the superscript d on the right-hand side as a typo and do not apply the top-level disabling relation. Base F.5.6.1 B007 of (t v; In the expression P), the satisfaction symbol on the right-hand side in PDF 1255 has a superscript d. The d-marked relation (disabling) is defined in B005 only for top-level T/U; item 1 specifies that for T = P (an ordinary property without disable iff), w, L0 ⊭^d T, meaning that it never holds. If read literally, properties with local variable declarations are never satisfied. This contrasts with the surrounding type, where the declaration's expression does not change the relationship by simply removing v from the context. This form appears in the top-level versions (both sides use ⊨ in B004 and ⊨^d in B005) and in the local-variable nonvacuity rule F.5.6.3 B002 (both sides use non). Only using the same relation (⊨) on both sides agrees with surrounding definitions, allowing unique restoration. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="past-gated-grouping--past式のゲートの括弧"></a>

## Brackets for gates of PAST-GATED-GROUPING - $past

The expression in F.6.2 is not closed by parentheses, and can be read as applying the iteration only to e2 and not to the whole of c && e2. You must refer to the definition of a gate clock of 16.9.3.

- Source: F.6.2, PDF physical page 1256, B002.
- Ledger ID: `SV2023-F.6.2-EXTRACT-PAST-EQUATION-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): for n ≥ 1, if w^{i,j} ⊨ ((c && e2) ##1 (c && e2)[=n-1] ##1 1) for some 0 ≤ i \< j, set $past(e1,n,e2,c)[w^j] = e1[w^i]. That is, take the value at the position where gated clock c && e2 held for the nth time before j. If no such i exists, evaluate e1 using initial values. Evidence: F.6.2 B002 in PDF 1256 reads w^{i,j},{},{} ⊨ ((c && e2) ##1 (c && e2 [=n-1] ##1 1), missing 1 closing parenthesis/parentheses. The abstract grammar defines [=m] only for Boolean b (F.3.4.2.3 B002); && is not a sequence operator (F.3.2 B004). Therefore, 'c && e2[=n-1]' can only be read as adding [= n-1 ] to c && e2 of the Boolean (expression_or_dist [boolean_abbrev ] of A.2.10 is added to the whole expression, but the abbreviation is added). Wherever the missing parentheses are inserted, every well-formed reading has the same meaning as (c && e2) ##1 (c && e2)[=n-1] ##1 1 (##1 concatenation is associative). This sequence means “c && e2 holds at i, and i + 1.. means “holds exactly n-1 times in j-1, with arbitrary j”; i is the position of the nth gated-clock tick before j. This is consistent with the following description. 16.9.3 B029 (the kth strictly preceding time step where ev iff expression2 occurred), 16.9.3 B041 and B045 (sampling on a clock gated by expression2), and F.3.1 B004 (τ(e iff b) = τ(e) && b). The reading that the repetition only applies to e2 is not grammatically correct. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="past-global-index--past_gclkの条件と添字"></a>

## Conditions and indexes for PAST-GLOBAL-INDEX - $past_gclk

F.6.2 defines nonnegative j, then requires j \< 0 while using unbound i-1 on the right-hand side.

- Source: F.6.2, PDF physical page 1256, B002.
- Ledger ID: `SV2023-F.6.2-EXTRACT-PAST-GLOBAL-INDEX-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolution) of 2026-10-24: For 0 \<j\<|w|, let $past_gclk (e)[w^j] = e[w^{ j-1 }] (value at the tick of the immediately preceding global clock). For j = 0, evaluate e using the variables' initial values. Rationale: after defining j by 0≤j\<|w|, F.6.2 B002 states that if j\<0, then $past_gclk(e)[w^j] = e[w^{i-1}] (verified in PDF 1256). This condition is never met, and the right-hand i is not bound either. Because the following sentence separately defines the j = 0 case, the 1-th rule can apply only to 0 \< j \< |w|. The values are determined by the following description. 16.9.4 B006 sets $past_gclk (v) to equal $past (v,,,@ $global_clock ), and 16.9.4 B002 to the value of the tick of the immediately previous global clock. According to F.3.1 B004, all clock events occur at the tick of the global clock, and since τ($global_clock )= 1, each letter corresponds to a 1 tick. Substituting n = 1, e2 = 1, and c = 1 into the general $past rule in F.6.2 gives i = j-1, unambiguously recovering the RHS as e[w^{j-1}]. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="future-global-index--future_gclkの添字"></a>

## FUTURE-GLOBAL-INDEX - $future_gclk indexes

F.6.3 defines j, but the right-hand side uses unbound i + 1. The rule that the final position of a finite word is undefined is kept separate.

- Source: F.6.3, PDF physical page 1256, B002.
- Ledger ID: `SV2023-F.6.3-EXTRACT-FUTURE-INDEX-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Re-examination (resolution) of 2026-10-24: For 0 ≤j\<|w| -1, let $future_gclk (e)[w^j] = e[w^{j+ 1 }] (value at the tick of the next global clock). The final position of the finite word remains undefined. Rationale: F.6.3 B002 binds j with 0≤j\<|w| -1, but the RHS contains the unbound e[w^{i+1}] (PDF 1256). 16.9.4 B008 defines $future_gclk(v) as the sample value at the next tick of the global clock. F.3.1 B004 means that each character is a 1 tick of the global clock, so the next tick is the character j+ 1. The upper limit of j, |w| -1, is the range in which just j+ 1 fits into the word, and it also fits into the following sentences where the value is undefined at the end of the finite word. The derivation of F.3.4.4, such as $rising_gclk of B001, also uses $future_gclk as the value of the following character. Thus, i+ 1 can be reduced to j+ 1. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="dpi-signed-bits-macro--dpiの符号拡張マクロ"></a>

## DPI-SIGNED-BITS-MACRO — Sign-extension macro for DPI

H.10.1.2 and I.3 determine the sign of an N-bit extraction using bit N. Unlike the normal signedness position of N bits, N-1, both sources have the same formula. The domain in which C shift expressions are defined also requires care.

- Source: H.10.1.2, PDF physical page 1276, B008.
- Ledger ID: `SV2023-H.10.1.2-EXTRACT-SIGNED-TEXT`.
- Source: I.3, PDF physical page 1295, B018.
- Ledger ID: `SV2023-I.3-EXTRACT-SIGNED-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (still pending): missing decisive evidence is normative prose defining SV_GET_SIGNED_BITS's result, especially which bit is the sign bit, or an official erratum for IEEE. Even in the present state, a test to verify the token array of the header is possible, but the value of the sign extension cannot be used as a criterion for acceptance or rejection. The fact that SV_MASK of -1 \<\<N is an undefined operation in C remains as another problem.

<a id="dpi-get-user-data-return--ユーザーデータ取得の戻り値"></a>

## DPI-GET-USER-DATA-RETURN — Return value of user data retrieval

The comment for I.3 specifies 0 on success; H.9.3 specifies the non-NULL data pointer obtained. If you set 0 to a success value, the meaning of the acquired API is lost.

- Source: I.3, PDF physical pages 1298, 1299, B047, B048.
- Ledger ID: `SV2023-I.3-EXTRACT-GET-DATA-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (resolved): svGetUserData returns void*. Return NULL on error and when svPutUserData has not been called. On success, returns the non-NULL user-data pointer saved with svPutUserData. The "successful 0" of I.3 is read according to H.9.3 B017. Rationale: the comment in I.3 B047 says NULL on error and 0 on success, but the return type is void*, and 0 and NULL denote the same null pointer value. A literal reading cannot distinguish success from error and also contradicts the start of the same comment, which says to retrieve the user-data pointer saved with svPutUserData. B046 in the same I.3 (the comment for svPutUserData) recommends avoiding 0 (NULL) for userData, because it would make svGetUserData errors indistinguishable. This caution makes sense only when the saved userData is returned unchanged on success. H.9.3 B017 explicitly returns a non-NULL user data pointer on success for the same declaration. H.9.3 B004 also describes put/get as a mechanism for storing items for later retrieval. “0 upon success” in B047 can be read as wording copied from the preceding svPutUserData (B046: -1 on error, 0 on success). Resolve this because B046 in I.3 itself, the beginning of B047, and H.9.3 are consistent, and the literal interpretation fails even within I.3. However, the section of I.3 is in_progress because it keeps DPI-SIGNED-BITS-MACRO. The requirement text, reference note, and the section table were updated, and the section was completed. This is not an official correction or interpretation of IEEE, but a decision after rebuttal by an independent verification agent.

<a id="distribution-c-width--乱数アルゴリズムのc整数幅"></a>

## DISTRIBUTION-C-WIDTH — C integer width of random algorithm

N.2 uses long, LONG_MIN / LONG_MAX, signed multiplication, and a union of unsigned and float. Do not treat values compiled unchanged on an arbitrary host C as correct without establishing a fixed-width interpretation consistent with 20.14.1's 32-bit and cross-implementation reproducibility requirements.

- Source: N.2, PDF physical page 1343, B034.
- Ledger ID: `SV2023-N.2-EXTRACT-SEED-UPDATE-TEXT`.
- Status at extraction: the clause is `in_progress`; approval of test mappings for the affected row is pending. The application relationship with the related formal definitions is confirmed with rationale before updating.
- Reconsideration of 2026-10-24 (still pending): decisive evidence is missing—a normative statement or official interpretation specifying the integer model for evaluating the C code in N.2. For example: use 32-bit long/unsigned, wrap signed arithmetic modulo 2^32, and treat LONG_MIN / LONG_MAX as the 32-bit limits. The present state can only be inferred from the objective of reproducibility and the result of 32 bits.

<a id="抽出中の訂正と記録の限界"></a>

## Limits of correction and recording during extraction

The upper limit of "operator is 3 characters long" which was invented from the outline of 5.5 is not adopted. The formal syntax includes 4-character `<<<=` and `>>>=`; the requirements are mapped to that syntax. In extracting Annex A, corrected the optional lifetime in wildcard-module declarations and the empty parameter list `#()`. The macro name and structure fields are compared with the appendix K/M, and the formula is compared with the PDF image.

The requirement registry contains the appearance of the requirement, the verification items by condition, and the specific observation case of the initial registration. The number of registrations at the time of the sampling was the provisional denominator. Merged duplicate 21 rows into 2026-10-28 and accepted the denominator of the 12,298 requirement. This approval does not mean that all programs and all inputs are encompassed. `recommendation` is recommended and distinguished from the mandatory error. The expected values are not arbitrarily given to unspecified orders, undefined actions, and implementation dependencies. The mechanical examination of block hash and cross reference does not prove the correctness of the interpretation or the decomposition grain. The audit is confirmed by AI, not approved by an independent person.
