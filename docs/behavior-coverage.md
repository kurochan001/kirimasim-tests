# IEEE 1800-2023 動作カバレッジ

`tools/behavior_coverage.py` が `coverage/` の台帳と実行証跡から生成します。
[管理手順](../coverage/README.md) / [節の引用数](../docs/coverage-depth.md)

**規格全動作のテスト設計網羅率: 未確定（要求の洗い出しが未完了）。**
規格全動作の実行確認率: 未確定。
節の引用やテスト本数を、全動作の網羅率に換算しません。

- 規格棚卸し: 本文1–41章と附属書A–Q、計 1740 見出し。
- 規定部分の洗い出し完了: 3/1703 見出し。
- 登録済み動作に対するテスト設計網羅率: 94/105 (89.52%)。
- 登録済み動作のうち、新鮮な実行成功証跡があるもの: 85/105 (80.95%)。
- 登録済みだがテスト未対応: 11 動作。

登録済み動作だけの割合は規格全体の割合ではありません。親節の導入本文も独立した
調査対象です。図・表・構文・例外・エラー・他節参照を調べ、要求を分解して初めて
その見出しを完了にできます。ツール依存・未実装は自動的な除外理由になりません。

## 実行証跡

成功は対応テストの全期待出力／診断の一致を意味します。`known`、`unsupported`、
`fail`、来歴なし、入力／ランナー変更後の結果は成功に数えません。複数の結果の和集合は
独立した検証環境での確認数であり、一つのシミュレータの適合率ではありません。

- `icarus.json`: Icarus Verilog version 13.0 (stable) (v13_0) / 2026-10-22T07:18:10.878145+00:00 / 59/105 動作確認、古い入力との対応 0 件。
- `verilator.json`: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905 / 2026-10-22T07:18:13.917102+00:00 / 71/105 動作確認、古い入力との対応 0 件。

## 章・附属書別の調査状態

件数は見出しごとの本文の調査状態です。動作数とは異なります。

- 1 Overview: 規定部分調査 0/12、登録 0、テスト対応 0。
- 2 Normative references: 規定部分調査 0/1、登録 0、テスト対応 0。
- 3 Design and verification building blocks: 規定部分調査 0/22、登録 0、テスト対応 0。
- 4 Scheduling semantics: 規定部分調査 0/40、登録 4、テスト対応 4。
- 5 Lexical conventions: 規定部分調査 1/21、登録 5、テスト対応 4。
- 6 Data types: 規定部分調査 0/92、登録 25、テスト対応 23。
- 7 Aggregate data types: 規定部分調査 1/61、登録 20、テスト対応 16。
- 8 Classes: 規定部分調査 0/49、登録 1、テスト対応 1。
- 9 Processes: 規定部分調査 0/34、登録 0、テスト対応 0。
- 10 Assignment statements: 規定部分調査 0/25、登録 1、テスト対応 1。
- 11 Operators and expressions: 規定部分調査 0/55、登録 27、テスト対応 23。
- 12 Procedural programming statements: 規定部分調査 0/28、登録 2、テスト対応 2。
- 13 Tasks and functions (subroutines): 規定部分調査 0/20、登録 2、テスト対応 2。
- 14 Clocking blocks: 規定部分調査 0/19、登録 0、テスト対応 0。
- 15 Interprocess synchronization and communication: 規定部分調査 0/27、登録 0、テスト対応 0。
- 16 Assertions: 規定部分調査 0/82、登録 0、テスト対応 0。
- 17 Checkers: 規定部分調査 0/13、登録 0、テスト対応 0。
- 18 Constrained random value generation: 規定部分調査 0/58、登録 0、テスト対応 0。
- 19 Functional coverage: 規定部分調査 0/34、登録 0、テスト対応 0。
- 20 Utility system tasks and system functions: 規定部分調査 0/45、登録 4、テスト対応 4。
- 21 Input/output system tasks and system functions: 規定部分調査 0/65、登録 4、テスト対応 4。
- 22 Compiler directives: 規定部分調査 0/28、登録 2、テスト対応 2。
- 23 Modules and hierarchy: 規定部分調査 0/47、登録 3、テスト対応 3。
- 24 Programs: 規定部分調査 0/10、登録 1、テスト対応 1。
- 25 Interfaces: 規定部分調査 0/25、登録 0、テスト対応 0。
- 26 Packages: 規定部分調査 0/8、登録 1、テスト対応 1。
- 27 Generate constructs: 規定部分調査 0/7、登録 0、テスト対応 0。
- 28 Gate-level and switch-level modeling: 規定部分調査 0/34、登録 2、テスト対応 2。
- 29 User-defined primitives: 規定部分調査 0/17、登録 1、テスト対応 1。
- 30 Specify blocks: 規定部分調査 0/31、登録 0、テスト対応 0。
- 31 Timing checks: 規定部分調査 0/26、登録 0、テスト対応 0。
- 32 Backannotation using the standard delay format: 規定部分調査 0/14、登録 0、テスト対応 0。
- 33 Configuring the contents of a design: 規定部分調査 0/36、登録 0、テスト対応 0。
- 34 Protected envelopes: 規定部分調査 0/104、登録 0、テスト対応 0。
- 35 Direct programming interface: 規定部分調査 0/31、登録 0、テスト対応 0。
- 36 Programming language interface (PLI/VPI) overview: 規定部分調査 0/29、登録 0、テスト対応 0。
- 37 VPI object model diagrams: 規定部分調査 0/101、登録 0、テスト対応 0。
- 38 VPI routine definitions: 規定部分調査 0/51、登録 0、テスト対応 0。
- 39 Assertion API: 規定部分調査 0/14、登録 0、テスト対応 0。
- 40 Code coverage control and API: 規定部分調査 0/26、登録 0、テスト対応 0。
- 41 Data read API: 規定部分調査 1/1、登録 0、テスト対応 0。
- A Formal syntax: 規定部分調査 0/87、登録 0、テスト対応 0。
- B Keywords: 規定部分調査 0/1、登録 0、テスト対応 0。
- C Deprecation: 規定部分調査 0/16、登録 0、テスト対応 0。
- D Optional system tasks and system functions: 参考（規範要件の分母に含めない）、登録 0、テスト対応 0。
- E Optional compiler directives: 参考（規範要件の分母に含めない）、登録 0、テスト対応 0。
- F Formal semantics of concurrent assertions: 規定部分調査 0/53、登録 0、テスト対応 0。
- G Std package: 規定部分調査 0/8、登録 0、テスト対応 0。
- H DPI C layer: 規定部分調査 0/72、登録 0、テスト対応 0。
- I svdpi.h: 規定部分調査 0/4、登録 0、テスト対応 0。
- J Inclusion of foreign language code: 規定部分調査 0/7、登録 0、テスト対応 0。
- K vpi_user.h: 規定部分調査 0/3、登録 0、テスト対応 0。
- L vpi_compatibility.h: 規定部分調査 0/3、登録 0、テスト対応 0。
- M sv_vpi_user.h: 規定部分調査 0/3、登録 0、テスト対応 0。
- N Algorithm for probabilistic distribution functions: 規定部分調査 0/3、登録 0、テスト対応 0。
- O Encryption/decryption flow: 参考（規範要件の分母に含めない）、登録 0、テスト対応 0。
- P Glossary: 参考（規範要件の分母に含めない）、登録 0、テスト対応 0。
- Q Bibliography: 参考（規範要件の分母に含めない）、登録 0、テスト対応 0。

## 登録済み動作と観測点

`coverage/behaviors.json` には条件・合格基準・根拠・入力ハッシュも記録します。
以下の対応は内容を確認したものだけです。引用だけがあるテストは候補として扱います。

未対応は台帳上の対応未確認を意味し、既存テストが一切ないという判定ではありません。

### SV2023-4.9.3-LHS-ON-RESUME

4.9.3 / normal / 実行確認あり

An intra-assignment blocking delay selects the destination when the process resumes.

合格基準: The write goes to a[1]; a[0] retains 10 after index changes during the delay.

- [test_blocking_delayed_target_after_index_change.sv](../tests/ch4/test_blocking_delayed_target_after_index_change.sv): The write goes to a[1]; a[0] retains 10 after index changes during the delay.

### SV2023-4.9.3-RHS-SAMPLED

4.9.3 / normal / 実行確認あり

An intra-assignment blocking delay samples its RHS before suspension.

合格基準: The saved source value is 7, despite source becoming 99 while suspended.

- [test_blocking_delayed_target_after_index_change.sv](../tests/ch4/test_blocking_delayed_target_after_index_change.sv): The saved source value is 7, despite source becoming 99 while suspended.

### SV2023-4.9.7-INOUT-DEFERRED

4.9.7 / normal / 実行確認あり

Writes to a by-value inout formal are copied back only at return.

合格基準: The actual b remains 2 during the call and becomes 8 after return.

- [test_subroutine_output_copy_only_at_return.sv](../tests/ch4/test_subroutine_output_copy_only_at_return.sv): The actual b remains 2 during the call and becomes 8 after return.

### SV2023-4.9.7-OUTPUT-DEFERRED

4.9.7 / normal / 実行確認あり

Writes to a by-value output formal are copied to the actual only at return.

合格基準: The actual a remains 1 during the call and becomes 9 after return.

- [test_subroutine_output_copy_only_at_return.sv](../tests/ch4/test_subroutine_output_copy_only_at_return.sv): The actual a remains 1 during the call and becomes 9 after return.

### SV2023-5.3-EOF-SEPARATOR

5.3 / boundary / テスト未対応

End of file is a white-space boundary.

合格基準: A complete source ending at a token without a final newline is accepted and yields the specified output.


### SV2023-5.3-STRING-BLANKS

5.3 / boundary / 実行確認あり

Blanks inside a string literal are significant.

合格基準: The string retains both adjacent blanks and has length 6.

- [test_free_format_layout.sv](../tests/ch5/test_free_format_layout.sv): The string retains both adjacent blanks and has length 6.

### SV2023-5.3-STRING-TABS

5.3 / boundary / 実行確認あり

Tabs inside a string literal are significant.

合格基準: The literal tab remains byte 9 at index 4.

- [test_free_format_layout.sv](../tests/ch5/test_free_format_layout.sv): The literal tab remains byte 9 at index 4.

### SV2023-5.3-TOKEN-SEPARATION

5.3 / normal / 実行確認あり

Spaces, tabs, newlines and formfeeds separate tokens without changing their meaning.

合格基準: The free-format computation yields total=42.

- [test_free_format_layout.sv](../tests/ch5/test_free_format_layout.sv): The free-format computation yields total=42.

### SV2023-5.6.4-DIRECTIVE-READ-ORDER

5.6.4 / normal / 実行確認あり

A compiler directive takes effect at its position in the input stream.

合格基準: The earlier and later expansions retain 13 and 27 respectively.

- [test_directive_redefinition_read_order.sv](../tests/ch5/test_directive_redefinition_read_order.sv): The earlier and later expansions retain 13 and 27 respectively.

### SV2023-6.8-FOUR-STATE-DEFAULT

6.8 / normal / 実行確認あり

Uninitialized four-state integer and time variables start unknown.

合格基準: Both integer and time are reported unknown.

- [test_integer_atom_defaults_and_widths.sv](../tests/ch6/test_integer_atom_defaults_and_widths.sv): Both integer and time are reported unknown.

### SV2023-6.8-TWO-STATE-DEFAULT

6.8 / normal / 実行確認あり

Uninitialized two-state integer atoms start at zero.

合格基準: byte, shortint, int and longint each report zero.

- [test_integer_atom_defaults_and_widths.sv](../tests/ch6/test_integer_atom_defaults_and_widths.sv): byte, shortint, int and longint each report zero.

### SV2023-6.11-INTEGER-WIDTHS

6.11 / normal / 実行確認あり

The integer atom types have their prescribed fixed widths.

合格基準: byte, shortint, int, longint, integer and time have widths 8,16,32,64,32,64.

- [test_integer_atom_defaults_and_widths.sv](../tests/ch6/test_integer_atom_defaults_and_widths.sv): byte, shortint, int, longint, integer and time have widths 8,16,32,64,32,64.

### SV2023-6.11.3-SIGNED-ATOMS

6.11.3 / normal / 実行確認あり

byte and shortint are signed unless declared otherwise.

合格基準: All-one assignments are interpreted as -1 for both types.

- [test_integer_atom_defaults_and_widths.sv](../tests/ch6/test_integer_atom_defaults_and_widths.sv): All-one assignments are interpreted as -1 for both types.

### SV2023-6.16-STRING-LEFT-TRUNCATE

6.16 / normal / 実行確認あり

An integral target too short for a string literal discards leftmost characters.

合格基準: WXYZ stored in 16 bits becomes 595a.

- [test_string_integral_truncation_and_lexical_compare.sv](../tests/ch11/test_string_integral_truncation_and_lexical_compare.sv): WXYZ stored in 16 bits becomes 595a.

### SV2023-6.16.13-OCTAL-HIGH

6.16.13 / boundary / 実行確認あり

octtoa overwrites the receiver with an ASCII representation of a high positive integer.

合格基準: The text contains only base-appropriate digits and atooct recovers the original value.

- [test_string_binary_octal_round_trip.sv](../tests/ch6/test_string_binary_octal_round_trip.sv): The text contains only base-appropriate digits and atooct recovers the original value.

### SV2023-6.16.13-OCTAL-NEGATIVE

6.16.13 / boundary / テスト未対応

octtoa accepts an integer argument, including negative values.

合格基準: After converting -1, the inverse parsing method recovers -1 and the receiver no longer contains its previous text.


### SV2023-6.16.13-OCTAL-ONE

6.16.13 / normal / 実行確認あり

octtoa overwrites the receiver with an ASCII representation of one.

合格基準: The text contains only base-appropriate digits and atooct recovers the original value.

- [test_string_binary_octal_round_trip.sv](../tests/ch6/test_string_binary_octal_round_trip.sv): The text contains only base-appropriate digits and atooct recovers the original value.

### SV2023-6.16.13-OCTAL-ZERO

6.16.13 / boundary / 実行確認あり

octtoa overwrites the receiver with an ASCII representation of zero.

合格基準: The text contains only base-appropriate digits and atooct recovers the original value.

- [test_string_binary_octal_round_trip.sv](../tests/ch6/test_string_binary_octal_round_trip.sv): The text contains only base-appropriate digits and atooct recovers the original value.

### SV2023-6.16.14-BINARY-HIGH

6.16.14 / boundary / 実行確認あり

bintoa overwrites the receiver with an ASCII representation of a high positive integer.

合格基準: The text contains only base-appropriate digits and atobin recovers the original value.

- [test_string_binary_octal_round_trip.sv](../tests/ch6/test_string_binary_octal_round_trip.sv): The text contains only base-appropriate digits and atobin recovers the original value.

### SV2023-6.16.14-BINARY-NEGATIVE

6.16.14 / boundary / テスト未対応

bintoa accepts an integer argument, including negative values.

合格基準: After converting -1, the inverse parsing method recovers -1 and the receiver no longer contains its previous text.


### SV2023-6.16.14-BINARY-ONE

6.16.14 / normal / 実行確認あり

bintoa overwrites the receiver with an ASCII representation of one.

合格基準: The text contains only base-appropriate digits and atobin recovers the original value.

- [test_string_binary_octal_round_trip.sv](../tests/ch6/test_string_binary_octal_round_trip.sv): The text contains only base-appropriate digits and atobin recovers the original value.

### SV2023-6.16.14-BINARY-ZERO

6.16.14 / boundary / 実行確認あり

bintoa overwrites the receiver with an ASCII representation of zero.

合格基準: The text contains only base-appropriate digits and atobin recovers the original value.

- [test_string_binary_octal_round_trip.sv](../tests/ch6/test_string_binary_octal_round_trip.sv): The text contains only base-appropriate digits and atobin recovers the original value.

### SV2023-6.19.2-DESCENDING-NAMES

6.19.2 / normal / 実行確認あり

A descending generated enum name range still receives increasing values.

合格基準: SLOT2, SLOT1 and SLOT0 have values 7,8,9.

- [test_enum_descending_names_and_wrap.sv](../tests/ch6/test_enum_descending_names_and_wrap.sv): SLOT2, SLOT1 and SLOT0 have values 7,8,9.

### SV2023-6.19.5.1-FIRST-DECLARED

6.19.5.1 / normal / 実行確認あり

Enum first() returns the first declared member.

合格基準: The first value is 7.

- [test_enum_descending_names_and_wrap.sv](../tests/ch6/test_enum_descending_names_and_wrap.sv): The first value is 7.

### SV2023-6.19.5.2-LAST-DECLARED

6.19.5.2 / normal / 実行確認あり

Enum last() returns the last declared member.

合格基準: The last value is 20.

- [test_enum_descending_names_and_wrap.sv](../tests/ch6/test_enum_descending_names_and_wrap.sv): The last value is 20.

### SV2023-6.19.5.4-PREV-WRAP

6.19.5.4 / boundary / 実行確認あり

Enum prev() wraps in declaration order across value gaps.

合格基準: One step before SLOT2 is DONE=20, and two steps before SLOT2 is SLOT0=9.

- [test_enum_descending_names_and_wrap.sv](../tests/ch6/test_enum_descending_names_and_wrap.sv): One step before SLOT2 is DONE=20, and two steps before SLOT2 is SLOT0=9.

### SV2023-6.19.5.5-NUM-MEMBERS

6.19.5.5 / normal / 実行確認あり

Enum num() counts members rather than the numeric value span.

合格基準: The enum reports four members despite its gap from 9 to 20.

- [test_enum_descending_names_and_wrap.sv](../tests/ch6/test_enum_descending_names_and_wrap.sv): The enum reports four members despite its gap from 9 to 20.

### SV2023-6.20.7-QUEUE-LAST-AFTER-POP

6.20.7 / normal / 実行確認あり

A queue dollar index is recomputed after shrinkage.

合格基準: After removing 9, q[$] is 4.

- [test_unbounded_queue_tail_after_resize.sv](../tests/ch6/test_unbounded_queue_tail_after_resize.sv): After removing 9, q[$] is 4.

### SV2023-6.20.7-QUEUE-LAST-AFTER-PUSH

6.20.7 / normal / 実行確認あり

A queue dollar index reflects the current last element after growth.

合格基準: After push_back(9), q[$] is 9 and q[1:$] is 4,9.

- [test_unbounded_queue_tail_after_resize.sv](../tests/ch6/test_unbounded_queue_tail_after_resize.sv): After push_back(9), q[$] is 9 and q[1:$] is 4,9.

### SV2023-6.22.4-ENUM-CAST-FAIL

6.22.4 / boundary / 実行確認あり

An unsuccessful function-form dynamic enum cast leaves its destination unchanged.

合格基準: Casting 99 fails with status 0 and preserves HIGH=8.

- [test_enum_explicit_cast_and_failed_dynamic_cast.sv](../tests/ch6/test_enum_explicit_cast_and_failed_dynamic_cast.sv): Casting 99 fails with status 0 and preserves HIGH=8.

### SV2023-6.22.4-ENUM-CAST-PASS

6.22.4 / normal / 実行確認あり

A dynamic enum cast succeeds for a declared member value.

合格基準: Casting 3 succeeds with status 1 and stores LOW=3.

- [test_enum_explicit_cast_and_failed_dynamic_cast.sv](../tests/ch6/test_enum_explicit_cast_and_failed_dynamic_cast.sv): Casting 3 succeeds with status 1 and stores LOW=3.

### SV2023-6.22.5-NO-HANDLE-REAL

6.22.5 / error / 実行確認あり

A class handle cannot be converted to an incompatible real type.

合格基準: Compilation rejects the real cast at the intended source line.

- [test_illegal_handle_to_real_cast.sv](../tests/ch6/test_illegal_handle_to_real_cast.sv): Compilation rejects the real cast at the intended source line.

### SV2023-6.24.3-ARRAY-TO-BITS

6.24.3 / normal / テスト対応あり・実行未確認

Bit-stream casting a fixed unpacked array puts its leftmost element in the most significant bits.

合格基準: The descending array containing 12,ab,34 casts to packed 12ab34.

- [test_bitstream_array_to_packed_order.sv](../tests/ch6/test_bitstream_array_to_packed_order.sv): The descending array containing 12,ab,34 casts to packed 12ab34.

### SV2023-6.24.3-BITS-TO-ARRAY

6.24.3 / normal / テスト対応あり・実行未確認

Bit-stream casting to a fixed unpacked array fills elements in declared left-to-right order.

合格基準: fedcba fills array indices 2,1,0 with fe,dc,ba.

- [test_bitstream_array_to_packed_order.sv](../tests/ch6/test_bitstream_array_to_packed_order.sv): fedcba fills array indices 2,1,0 with fe,dc,ba.

### SV2023-7.8.2-EMPTY-STRING-KEY

7.8.2 / boundary / 実行確認あり

The empty string is a valid associative-array string index.

合格基準: Reverse traversal reaches an allocated key of length zero.

- [test_assoc_string_empty_and_reverse_order.sv](../tests/ch7/test_assoc_string_empty_and_reverse_order.sv): Reverse traversal reaches an allocated key of length zero.

### SV2023-7.8.2-LEXICAL-ORDER

7.8.2 / normal / 実行確認あり

String associative indices are traversed in lexical order.

合格基準: Descending traversal visits b, aa, then the empty string.

- [test_assoc_string_empty_and_reverse_order.sv](../tests/ch7/test_assoc_string_empty_and_reverse_order.sv): Descending traversal visits b, aa, then the empty string.

### SV2023-7.8.4-SIGNED-ORDER

7.8.4 / normal / テスト対応あり・実行未確認

Signed integral associative indices are ordered by signed value.

合格基準: Traversal visits -3,0,2 in that order.

- [test_assoc_signed_boundary_order.sv](../tests/ch7/test_assoc_signed_boundary_order.sv): Traversal visits -3,0,2 in that order.

### SV2023-7.8.5-NO-REAL-MEMBER

7.8.5 / error / テスト対応あり・実行未確認

An associative index type may not contain a real member.

合格基準: Compilation rejects an associative declaration indexed by an unpacked struct containing real.

- [test_illegal_assoc_real_member_key.sv](../tests/ch7/test_illegal_assoc_real_member_key.sv): Compilation rejects an associative declaration indexed by an unpacked struct containing real.

### SV2023-7.8.6-IGNORE-UNKNOWN-WRITE

7.8.6 / boundary / テスト対応あり・実行未確認

An associative write with an x or z in the index does not create or overwrite a valid entry.

合格基準: After both invalid writes, size remains 1 and the known key retains 17.

- [test_assoc_unknown_write_does_not_allocate.sv](../tests/ch7/test_assoc_unknown_write_does_not_allocate.sv): After both invalid writes, size remains 1 and the known key retains 17.

### SV2023-7.8.6-INVALID-WRITE-WARNING

7.8.6 / boundary / テスト未対応

An invalid associative-array write issues a warning.

合格基準: Observe a warning attributable to the invalid index rather than checking only array contents.


### SV2023-7.8.6-MISSING-READ-WARNING

7.8.6 / boundary / テスト未対応

A missing associative-array read without a user default issues a warning and returns the type default.

合格基準: Check both the returned value and the required warning.


### SV2023-7.9.7-INDEX-ARGUMENT-TYPE

7.9.7 / error / テスト未対応

The prev() reference argument has an index type appropriate to the associative array.

合格基準: Passing a real reference argument to prev() on a string-indexed associative array is rejected at the call.


### SV2023-7.9.7-NO-PREDECESSOR

7.9.7 / boundary / 実行確認あり

When no predecessor exists, prev() returns 0 and preserves its index argument.

合格基準: At the empty-string key the status is 0 and the key remains empty.

- [test_assoc_string_empty_and_reverse_order.sv](../tests/ch7/test_assoc_string_empty_and_reverse_order.sv): At the empty-string key the status is 0 and the key remains empty.

### SV2023-7.9.7-NO-WILDCARD

7.9.7 / error / テスト未対応

prev() is not allowed on a wildcard-indexed associative array.

合格基準: Reject the traversal on the intended declaration/call rather than an unrelated unsupported feature.


### SV2023-7.9.7-PREDECESSOR

7.9.7 / normal / 実行確認あり

prev() finds the greatest key strictly below the supplied index, updates it and returns 1.

合格基準: Starting from b, the predecessor is aa with status 1.

- [test_assoc_string_empty_and_reverse_order.sv](../tests/ch7/test_assoc_string_empty_and_reverse_order.sv): Starting from b, the predecessor is aa with status 1.

### SV2023-7.9.8-NEXT-TRUNCATION

7.9.8 / boundary / テスト対応あり・実行未確認

A narrow traversal output argument causes next() to return -1 and copy truncated index bits.

合格基準: Key 600 is reported as status -1 and eight-bit value 88.

- [test_assoc_narrow_prev_next_overflow.sv](../tests/ch7/test_assoc_narrow_prev_next_overflow.sv): Key 600 is reported as status -1 and eight-bit value 88.

### SV2023-7.9.8-PREV-TRUNCATION

7.9.8 / boundary / テスト対応あり・実行未確認

A narrow traversal output argument causes prev() to return -1 and copy truncated index bits.

合格基準: Key -300 is reported as status -1 and eight-bit value 212.

- [test_assoc_narrow_prev_next_overflow.sv](../tests/ch7/test_assoc_narrow_prev_next_overflow.sv): Key -300 is reported as status -1 and eight-bit value 212.

### SV2023-7.9.9-REPLACE-NOT-MERGE

7.9.9 / normal / 実行確認あり

Associative assignment clears old destination entries before copying source entries.

合格基準: The old key 9 disappears and destination size becomes 2.

- [test_assoc_assignment_clears_and_detaches.sv](../tests/ch7/test_assoc_assignment_clears_and_detaches.sv): The old key 9 disappears and destination size becomes 2.

### SV2023-7.9.9-VALUE-COPY

7.9.9 / normal / 実行確認あり

Associative assignment copies entries rather than aliases their storage.

合格基準: Changing source key 2 to 40 leaves copied destination key 2 at 4.

- [test_assoc_assignment_clears_and_detaches.sv](../tests/ch7/test_assoc_assignment_clears_and_detaches.sv): Changing source key 2 to 40 leaves copied destination key 2 at 4.

### SV2023-7.9.10-VALUE-FORMAL-COPY

7.9.10 / normal / 実行確認あり

A by-value associative formal is a local copy.

合格基準: Deleting and replacing the formal leaves the caller array with its two original entries.

- [test_assoc_assignment_clears_and_detaches.sv](../tests/ch7/test_assoc_assignment_clears_and_detaches.sv): Deleting and replacing the formal leaves the caller array with its two original entries.

### SV2023-7.9.11-DEFAULT-NO-ALLOCATION

7.9.11 / boundary / 実行確認あり

Reading a user-default value does not allocate an associative entry.

合格基準: After a missing read and traversal, size remains 3.

- [test_assoc_string_empty_and_reverse_order.sv](../tests/ch7/test_assoc_string_empty_and_reverse_order.sv): After a missing read and traversal, size remains 3.

### SV2023-7.9.11-USER-DEFAULT

7.9.11 / boundary / 実行確認あり

A missing associative entry returns its explicitly specified default.

合格基準: Reading absent returns -7 rather than an implicit integer default.

- [test_assoc_string_empty_and_reverse_order.sv](../tests/ch7/test_assoc_string_empty_and_reverse_order.sv): Reading absent returns -7 rather than an implicit integer default.

### SV2023-7.10.2.7-SIZE-WAIT-BLOCKED

7.10.2.7 / normal / 実行確認あり

A size-dependent wait remains blocked while its condition is false.

合格基準: After the first pop, size is 1 and the waiter has not run.

- [test_queue_size_wait_after_pop.sv](../tests/ch7/test_queue_size_wait_after_pop.sv): After the first pop, size is 1 and the waiter has not run.

### SV2023-7.10.2.7-SIZE-WAIT-WAKES

7.10.2.7 / boundary / 実行確認あり

A size-dependent wait is re-evaluated when queue size changes.

合格基準: Removing the last element makes the waiter run.

- [test_queue_size_wait_after_pop.sv](../tests/ch7/test_queue_size_wait_after_pop.sv): Removing the last element makes the waiter run.

### SV2023-8.26.5-NO-INTERFACE-NEW

8.26.5 / error / 実行確認あり

An interface class cannot be constructed.

合格基準: Compilation rejects new on the interface class at the intended source line.

- [test_illegal_interface_class_construction.sv](../tests/ch8/test_illegal_interface_class_construction.sv): Compilation rejects new on the interface class at the intended source line.

### SV2023-10.5-INITIALIZE-ONCE

10.5 / normal / 実行確認あり

A declaration initializer is a one-time procedural initialization.

合格基準: The captured variable stays 7 after its source changes to 40.

- [test_declaration_initialization_is_not_driver.sv](../tests/ch10/test_declaration_initialization_is_not_driver.sv): The captured variable stays 7 after its source changes to 40.

### SV2023-11.3.1-COMPARISON-WIDTH

11.3.1 / normal / 実行確認あり

A comparison involving real values still has a one-bit result.

合格基準: The real comparison has bit width 1.

- [test_real_operator_result_and_condition.sv](../tests/ch11/test_real_operator_result_and_condition.sv): The real comparison has bit width 1.

### SV2023-11.3.1-CONDITION-NO-PROMOTION

11.3.1 / normal / 実行確認あり

A real conditional condition does not promote integral branch result types.

合格基準: Integral alternatives under a real condition retain a 32-bit result.

- [test_real_operator_result_and_condition.sv](../tests/ch11/test_real_operator_result_and_condition.sv): Integral alternatives under a real condition retain a 32-bit result.

### SV2023-11.3.1-REAL-PROMOTION

11.3.1 / normal / 実行確認あり

A real arithmetic operand promotes an arithmetic expression to real.

合格基準: 2.5 plus integer 3 yields real 5.5.

- [test_real_operator_result_and_condition.sv](../tests/ch11/test_real_operator_result_and_condition.sv): 2.5 plus integer 3 yields real 5.5.

### SV2023-11.3.4-TWO-STATE-CONVERSION

11.3.4 / boundary / 実行確認あり

Converting a four-state value to bit maps x and z bits to zero before later operations.

合格基準: 1xz0 converts to 1000, whose inversion is 0111.

- [test_two_state_conversion_before_bitwise.sv](../tests/ch11/test_two_state_conversion_before_bitwise.sv): 1xz0 converts to 1000, whose inversion is 0111.

### SV2023-11.3.5-AND-EVALUATE

11.3.5 / normal / 実行確認あり

Logical AND evaluates a needed RHS including its side effects.

合格基準: The result and the exact call count match: 1 && f: r=1 calls=1.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 1 && f: r=1 calls=1.

### SV2023-11.3.5-AND-SKIP

11.3.5 / normal / 実行確認あり

Logical AND skips RHS evaluation when the LHS is false.

合格基準: The result and the exact call count match: 0 && f: r=0 calls=0.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 0 && f: r=0 calls=0.

### SV2023-11.3.5-BITWISE-AND

11.3.5 / normal / 実行確認あり

Bitwise AND does not skip operand side effects even when zero determines the bit value.

合格基準: The result and the exact call count match: 0 & f: r=0 calls=1.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 0 & f: r=0 calls=1.

### SV2023-11.3.5-BITWISE-OR

11.3.5 / normal / 実行確認あり

Bitwise OR does not skip operand side effects even when one determines the bit value.

合格基準: The result and the exact call count match: 1 | f: r=1 calls=1.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 1 | f: r=1 calls=1.

### SV2023-11.3.5-CONDITIONAL-FALSE

11.3.5 / normal / 実行確認あり

A false conditional condition skips the true alternative.

合格基準: The result and the exact call count match: 0 ? f : 7: t=7 calls=0.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 0 ? f : 7: t=7 calls=0.

### SV2023-11.3.5-CONDITIONAL-TRUE

11.3.5 / normal / 実行確認あり

A true conditional condition skips the false alternative.

合格基準: The result and the exact call count match: 1 ? 5 : f: t=5 calls=0.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 1 ? 5 : f: t=5 calls=0.

### SV2023-11.3.5-IMPLIES-EVALUATE

11.3.5 / normal / 実行確認あり

Logical implication evaluates its RHS for a true antecedent.

合格基準: The result and the exact call count match: 1 -> f: r=0 calls=1.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 1 -> f: r=0 calls=1.

### SV2023-11.3.5-IMPLIES-SKIP

11.3.5 / normal / 実行確認あり

Logical implication skips RHS evaluation for a false antecedent.

合格基準: The result and the exact call count match: 0 -> f: r=1 calls=0.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 0 -> f: r=1 calls=0.

### SV2023-11.3.5-OR-EVALUATE

11.3.5 / normal / 実行確認あり

Logical OR evaluates a needed RHS including its side effects.

合格基準: The result and the exact call count match: 0 || f: r=1 calls=1.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 0 || f: r=1 calls=1.

### SV2023-11.3.5-OR-SKIP

11.3.5 / normal / 実行確認あり

Logical OR skips RHS evaluation when the LHS is true.

合格基準: The result and the exact call count match: 1 || f: r=1 calls=0.

- [test_short_circuit_side_effects.sv](../tests/ch11/test_short_circuit_side_effects.sv): The result and the exact call count match: 1 || f: r=1 calls=0.

### SV2023-11.3.5-UNKNOWN-CONDITION

11.3.5 / boundary / テスト未対応

With an unknown LHS, logical AND evaluates a needed RHS; a false RHS determines a false result.

合格基準: For X && touch(0), the function is called once and the result is 0.


### SV2023-11.3.6-ASSIGNMENT-RESULT

11.3.6 / normal / 実行確認あり

An assignment expression returns the value converted to its destination type.

合格基準: Assigning fe to a four-bit target stores e and returns integer value 14.

- [test_assignment_expression_returns_converted_value.sv](../tests/ch11/test_assignment_expression_returns_converted_value.sv): Assigning fe to a four-bit target stores e and returns integer value 14.

### SV2023-11.3.6-CONCATENATION-TYPE

11.3.6 / boundary / テスト未対応

An assignment expression with concatenated LHS returns an unsigned integral result of the combined width.

合格基準: Check signedness and bit width as well as the returned value for a concatenated destination.


### SV2023-11.3.6-NO-TIMING-CONTROL

11.3.6 / error / テスト未対応

An assignment used within an expression may not contain timing control.

合格基準: Reject an intra-assignment delay inside an enclosing expression.


### SV2023-11.3.6-PARENTHESES

11.3.6 / error / テスト未対応

An assignment within an expression must be enclosed in parentheses.

合格基準: Reject an unparenthesized assignment in an expression.


### SV2023-11.4.3.1-DIVIDE-TRUNCATES

11.4.3.1 / normal / 実行確認あり

Signed integer division truncates toward zero.

合格基準: -7 divided by 3 produces -2.

- [test_literal_unsigned_division_and_remainder.sv](../tests/ch11/test_literal_unsigned_division_and_remainder.sv): -7 divided by 3 produces -2.

### SV2023-11.4.3.1-REMAINDER-SIGN

11.4.3.1 / normal / 実行確認あり

A signed integer remainder follows the dividend sign.

合格基準: -7 modulo 3 produces -1.

- [test_literal_unsigned_division_and_remainder.sv](../tests/ch11/test_literal_unsigned_division_and_remainder.sv): -7 modulo 3 produces -1.

### SV2023-11.4.12.2-STRING-REPEAT

11.4.12.2 / normal / 実行確認あり

A string repetition count may be determined at run time.

合格基準: A runtime count of 3 produces QQQ followed by ! and length 4.

- [test_string_concat_empty_replication.sv](../tests/ch11/test_string_concat_empty_replication.sv): A runtime count of 3 produces QQQ followed by ! and length 4.

### SV2023-11.8.3-UNSIGNED-ZERO-EXTEND

11.8.3 / boundary / 実行確認あり

An unsigned source is zero-extended even if its high bit is unknown.

合格基準: Unsigned x10 extends to 00000x10.

- [test_signed_unknown_extension_and_unsigned_padding.sv](../tests/ch11/test_signed_unknown_extension_and_unsigned_padding.sv): Unsigned x10 extends to 00000x10.

### SV2023-11.8.4-X-SIGN-EXTEND

11.8.4 / boundary / 実行確認あり

A signed unknown sign bit is replicated when extending width.

合格基準: Signed x10 extends to xxxxxx10.

- [test_signed_unknown_extension_and_unsigned_padding.sv](../tests/ch11/test_signed_unknown_extension_and_unsigned_padding.sv): Signed x10 extends to xxxxxx10.

### SV2023-11.8.4-Z-SIGN-EXTEND

11.8.4 / boundary / 実行確認あり

A signed high-impedance sign bit is replicated when extending width.

合格基準: Signed z01 extends to zzzzzz01.

- [test_signed_unknown_extension_and_unsigned_padding.sv](../tests/ch11/test_signed_unknown_extension_and_unsigned_padding.sv): Signed z01 extends to zzzzzz01.

### SV2023-11.10.2-STRING-ZERO-PAD

11.10.2 / normal / 実行確認あり

An integral target wider than a string literal is zero padded on the left.

合格基準: K stored in 32 bits becomes 0000004b.

- [test_string_integral_truncation_and_lexical_compare.sv](../tests/ch11/test_string_integral_truncation_and_lexical_compare.sv): K stored in 32 bits becomes 0000004b.

### SV2023-11.10.3-EMPTY-STRING-VALUE

11.10.3 / boundary / 実行確認あり

An empty string literal converted to an integral value is zero.

合格基準: Eight-bit casts distinguish empty=0 from zero_character=48.

- [test_string_integral_truncation_and_lexical_compare.sv](../tests/ch11/test_string_integral_truncation_and_lexical_compare.sv): Eight-bit casts distinguish empty=0 from zero_character=48.

### SV2023-12.5.2-CASEX-DEFAULT

12.5.2 / boundary / 実行確認あり

casex takes default when no wildcard item matches.

合格基準: Selector 0000 selects default item 3.

- [test_casex_first_wildcard_item.sv](../tests/ch12/test_casex_first_wildcard_item.sv): Selector 0000 selects default item 3.

### SV2023-12.5.2-CASEX-FIRST-MATCH

12.5.2 / boundary / 実行確認あり

casex executes only the first matching wildcard item.

合格基準: Selector 1x01 matches overlapping patterns but selects the first item.

- [test_casex_first_wildcard_item.sv](../tests/ch12/test_casex_first_wildcard_item.sv): Selector 1x01 matches overlapping patterns but selects the first item.

### SV2023-13.3.2-AUTOMATIC-FRESH

13.3.2 / normal / 実行確認あり

An automatic task local is initialized for each activation.

合格基準: Two sequential calls each produce count 1.

- [test_task_static_and_automatic_retention.sv](../tests/ch13/test_task_static_and_automatic_retention.sv): Two sequential calls each produce count 1.

### SV2023-13.3.2-STATIC-RETENTION

13.3.2 / normal / 実行確認あり

A static task local retains its value between calls.

合格基準: Two sequential calls produce counts 1 and 2.

- [test_task_static_and_automatic_retention.sv](../tests/ch13/test_task_static_and_automatic_retention.sv): Two sequential calls produce counts 1 and 2.

### SV2023-20.3.2-STIME-ROUNDING

20.3.2 / boundary / 実行確認あり

stime rounds simulation time to the local time unit.

合格基準: At 1.6 local units, stime returns 2 while realtime remains 1.6.

- [test_stime_rounding_with_local_unit.sv](../tests/ch20/test_stime_rounding_with_local_unit.sv): At 1.6 local units, stime returns 2 while realtime remains 1.6.

### SV2023-20.3.2-STIME-WIDTH

20.3.2 / normal / 実行確認あり

stime has a 32-bit result.

合格基準: The returned value has bit width 32.

- [test_stime_rounding_with_local_unit.sv](../tests/ch20/test_stime_rounding_with_local_unit.sv): The returned value has bit width 32.

### SV2023-20.14.2-DIST-SEED-REPLAY

20.14.2 / normal / 実行確認あり

Identical incoming seeds produce identical distribution values and updated seeds.

合格基準: Ten paired dist_normal calls retain equal values and seed states.

- [test_distribution_seed_replay_and_singleton_range.sv](../tests/ch20/test_distribution_seed_replay_and_singleton_range.sv): Ten paired dist_normal calls retain equal values and seed states.

### SV2023-20.14.2-UNIFORM-SINGLETON

20.14.2 / boundary / 実行確認あり

A uniform distribution with equal bounds can produce only that bound.

合格基準: Ten calls with bounds -4,-4 all return -4.

- [test_distribution_seed_replay_and_singleton_range.sv](../tests/ch20/test_distribution_seed_replay_and_singleton_range.sv): Ten calls with bounds -4,-4 all return -4.

### SV2023-21.3.4.4-FREAD-EOF

21.3.4.4 / boundary / 実行確認あり

Binary fread returns zero when no bytes remain.

合格基準: A second read at EOF returns 0 without asserting unspecified unread bits.

- [test_fread_partial_word_and_eof.sv](../tests/ch21/test_fread_partial_word_and_eof.sv): A second read at EOF returns 0 without asserting unspecified unread bits.

### SV2023-21.3.4.4-FREAD-PARTIAL

21.3.4.4 / boundary / 実行確認あり

Binary fread fills the most significant byte positions first and returns bytes read.

合格基準: Two available bytes fill the upper sixteen bits of a 24-bit variable and the count is 2.

- [test_fread_partial_word_and_eof.sv](../tests/ch21/test_fread_partial_word_and_eof.sv): Two available bytes fill the upper sixteen bits of a 24-bit variable and the count is 2.

### SV2023-21.3.5-SEEK-CANCELS-PUSHBACK

21.3.5 / normal / 実行確認あり

File repositioning cancels a previous ungetc.

合格基準: After pushback of Z and seek to offset 2, the next character is c, not Z.

- [test_fseek_cancels_ungetc_and_clears_error.sv](../tests/ch21/test_fseek_cancels_ungetc_and_clears_error.sv): After pushback of Z and seek to offset 2, the next character is c, not Z.

### SV2023-21.3.7-FERROR-NO-ERROR

21.3.7 / normal / 実行確認あり

ferror returns zero and clears its string argument when no error exists.

合格基準: After successful operations the error code is 0 and stale error text is empty.

- [test_fseek_cancels_ungetc_and_clears_error.sv](../tests/ch21/test_fseek_cancels_ungetc_and_clears_error.sv): After successful operations the error code is 0 and stale error text is empty.

### SV2023-22.5.3-UNDEFINE-ALL

22.5.3 / normal / 実行確認あり

undefineall removes both direct and forwarding text macro definitions.

合格基準: Both source-defined macros are absent after the directive.

- [test_undefineall_clears_nested_macro_expansion.sv](../tests/ch22/test_undefineall_clears_nested_macro_expansion.sv): Both source-defined macros are absent after the directive.

### SV2023-22.9-PULL-DECLARATION

22.9 / normal / 実行確認あり

Unconnected-drive directives apply at module declaration and affect every bit of open input vectors.

合格基準: Modules declared under pull1/pull0 receive 111/000; nounconnected_drive restores zzz.

- [test_unconnected_drive_instances_restore.sv](../tests/ch22/test_unconnected_drive_instances_restore.sv): Modules declared under pull1/pull0 receive 111/000; nounconnected_drive restores zzz.

### SV2023-23.3.2.3-EXPLICIT-OVERRIDE

23.3.2.3 / normal / 実行確認あり

An explicit named port connection takes precedence over a wildcard connection.

合格基準: Explicit data=c is used despite same-named local data=3, so inverted output is 3.

- [test_wildcard_ports_explicit_override.sv](../tests/ch23/test_wildcard_ports_explicit_override.sv): Explicit data=c is used despite same-named local data=3, so inverted output is 3.

### SV2023-23.3.3.8-PORT-SIGNEDNESS

23.3.3.8 / normal / 実行確認あり

The port declaration determines the signedness of values used inside the module.

合格基準: The same actual bits extend as fe through a signed formal and 0e through an unsigned formal.

- [test_signed_port_extension_uses_local_declaration.sv](../tests/ch23/test_signed_port_extension_uses_local_declaration.sv): The same actual bits extend as fe through a signed formal and 0e through an unsigned formal.

### SV2023-23.11-SELECTIVE-BIND

23.11 / normal / テスト対応あり・実行未確認

Binding to a selected instance does not bind to its sibling instances.

合格基準: Only the selected right-hand instance emits bound_flag=1.

- [test_bind_only_selected_instance.sv](../tests/ch23/test_bind_only_selected_instance.sv): Only the selected right-hand instance emits bound_flag=1.

### SV2023-24.3.2-PROGRAM-CA-REGION

24.3.2 / normal / テスト対応あり・実行未確認

A program continuous assignment evaluates after the module active-region set settles.

合格基準: The output observer sees the completed module NBA state 1 along with the new program output c.

- [test_program_output_after_module_nba_chain.sv](../tests/ch24/test_program_output_after_module_nba_chain.sv): The output observer sees the completed module NBA state 1 along with the new program output c.

### SV2023-26.5-SCOPED-PACKAGE-NAME

26.5 / normal / 実行確認あり

Explicit package qualification selects a name despite competing wildcard candidates.

合格基準: Qualified writes/readbacks affect left::value=13 while right::value remains 29.

- [test_package_scoped_name_avoids_wildcard_conflict.sv](../tests/ch26/test_package_scoped_name_avoids_wildcard_conflict.sv): Qualified writes/readbacks affect left::value=13 while right::value remains 29.

### SV2023-28.3.1-MULTIPLE-INSTANCES

28.3.1 / normal / 実行確認あり

One gate instantiation may declare multiple named instances.

合格基準: The two buffer instances produce scalar values 1 and 0.

- [test_gate_array_scalar_broadcast_and_instances.sv](../tests/ch28/test_gate_array_scalar_broadcast_and_instances.sv): The two buffer instances produce scalar values 1 and 0.

### SV2023-28.3.2-SCALAR-BROADCAST

28.3.2 / normal / 実行確認あり

A scalar gate-array input is shared across the gate instances.

合格基準: Shared enable=0 clears every output, and enable=1 reproduces data=1010.

- [test_gate_array_scalar_broadcast_and_instances.sv](../tests/ch28/test_gate_array_scalar_broadcast_and_instances.sv): Shared enable=0 clears every output, and enable=1 reproduces data=1010.

### SV2023-29.9-LEVEL-OVER-EDGE

29.9 / boundary / 実行確認あり

A sequential UDP level-sensitive entry takes priority over an overlapping edge-sensitive entry.

合格基準: A falling edge captures 0 without preset, but overlapping asserted preset yields 1.

- [test_udp_level_preset_over_falling_capture.sv](../tests/ch29/test_udp_level_preset_over_falling_capture.sv): A falling edge captures 0 without preset, but overlapping asserted preset yields 1.
