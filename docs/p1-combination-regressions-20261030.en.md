<a id="issue-21組合せ境界の回帰取り込み"></a>

# Issue # 21: Regression in the combination boundary

[English](p1-combination-regressions-20261030.en.md) / [日本語](p1-combination-regressions-20261030.md)

[Track](https://github.com/kurochan001/kirimasim-tests/issues/21) / [Original observation record](p1-combination-gaps-20261030.en.md) / [Mapping registry](../coverage/combination-gaps.json)

The 20 candidate of Issue # 21 is matched to the regression test of the existing main observation and control and the new boundary condition. The search history of the original 34 item is saved as a history. The completion of the registration of this log does not mean the completion of the function implementation of the kirimasim. Does not add automatically to the requested denominator, does not use non-match as an expected value of success, and explicitly specifies the scope of the interpretation reservation and the native API.

- Verified by: Codex GPT-6 (AI confirmed. an independent reviewer checks the standard and expected values separately from the authoring of event, NBA, and aggregate-type cases). Date of confirmation: 2026-10-30.
- The candidate 20 items and the object 88 items excluding duplicates are listed. The new 74 test is used, and the remaining test is reused from the existing test.
- The registration and standard verification are completed and the implementation is approved. Unsupported, known, and unexecuted are not included in the pass.
- The algorithm compares the input, expected value, and runner fingerprint of each execution, and does not synthesize partial success of different executions.
- The reserved interpretation and out-of-scope API are left below and are not overwritten to implementation shortcomings or success.

- The binary fingerprints of commits and builds before and after the update are stored in [Build evidence](../coverage/combination-qualification/issue21-build.json). This is the upstream version that is verified at the start of the program and does not automatically guarantee follow-up to subsequent updates.
- The VCD inspector confirms the decisions in [Fault Injection 4 Condition](../coverage/combination-qualification/issue21-vcd-checker.json), which is normal, program missing, module only, and excess of scope end.

<a id="e01automaticなstructのeventメンバと寿命"></a>

## E01: Event member and life of automatic struct.

Following 6.8, 6.21, and 15.5 you will see different events for each call and the lifetime of the autovariable that will be extended by the fork.

- [test_gen_combo_event_automatic_scalar_control_capture](../tests/gen/ch6/test_gen_combo_event_automatic_scalar_control_capture.sv) (main observation, new). The 2 call cycle is characterized by the event identification, capture value after task recurrence, individual awakening, and independence after alias unname. Clause: 6.21 、 6.8 、 6.17 、 9.3.2 、 15.5.2 、 15.5.5.2 。
- [test_gen_combo_event_automatic_struct_capture](../tests/gen/ch6/test_gen_combo_event_automatic_struct_capture.sv) (main observation, new). The 2 call cycle is characterized by the event identification, capture value after task recurrence, individual awakening, and independence after alias unname. Clause: 6.21 、 6.8 、 6.17 、 9.3.2 、 15.5.2 、 15.5.5.2 、 7.2.2 。

- Scope and limits: The SV output is used to observe the identification and reference life. Does not check the actual memory recovered by GC.

<a id="e02eventを返す関数と条件付き初期化"></a>

## E02: event return function and conditional initialization

Checks the return value of event and the handle selection by known conditional expressions. The null value is also observed.

- [test_gen_combo_event_conditional_initializer](../tests/gen/ch15/test_gen_combo_event_conditional_initializer.sv) (main observation, new). The problem of handling matches and mismatches after return value and condition selection, and the only standby processes that are triggered are discussed. Clause: 15.5.5.1 、 15.5.5.3 、 6.17 、 6.21 、 13.4 、 15.5.2 、 11.4.11 。
- [test_gen_combo_event_return_initializer](../tests/gen/ch15/test_gen_combo_event_return_initializer.sv) (main observation, new). The problem of handling matches and mismatches after return value and condition selection, and the only standby processes that are triggered are discussed. Clause: 15.5.5.1 、 15.5.5.3 、 6.17 、 6.21 、 13.4 、 15.5.2 。

- Scope and limits: Merge rules with unknown values are not covered by this section.

<a id="e03always_ffと計算したエッジ式"></a>

## E03: Edge formula calculated with always_ff

Put always_ff 1 event controls in the field, and use the equation as a calculation. The edge judgements of 9.2.2.4 and 9.4.2 are obtained from the stimulus column.

- [test_gen_combo_always_ff_computed_edge_capture](../tests/gen/ch9/test_gen_combo_always_ff_computed_edge_capture.sv) (main observation, new). The method captures only the actual computational edge from multiple changes in the input, and confirms the number of writes and the value. Clause: 9.2.2.4 、 9.4.2 、 10.4.2 。

- Scope and limits: Do not write the same variable from multiple processes.

<a id="e04iffガードと副作用を持つ関数"></a>

## E04: Function with iff guard and side effect.

The guard function is evaluated separately from the body execution when the guard is passed.

- [test_gen_combo_iff_function_side_effect_accept](../tests/gen/ch9/test_gen_combo_iff_function_side_effect_accept.sv) (main observation, new). The number of times the guard is called, the number of times the event is passed or failed, the number of times the event itself is called, and the final value. Clause: 9.4.2.3 、 9.4.2 、 13.4 。
- [test_gen_combo_iff_function_side_effect_reject](../tests/gen/ch9/test_gen_combo_iff_function_side_effect_reject.sv) (main observation, new). The number of times the guard is called, the number of times the event is passed or failed, the number of times the event itself is called, and the final value. Clause: 9.4.2.3 、 9.4.2 、 13.4 。

- Scope and limits: Do not write to the guard variable from other concurrent processes.

<a id="e05イベント制御付きノンブロッキングトリガ"></a>

## E05: Non-blocking trigger with event control

The event-controlled trigger of 15.5.1 is observed even after the issuer has been terminated. The basic asynchronous trigger reuses existing tests.

- [test_gen_combo_event_control_trigger_after_issuer_end](../tests/gen/ch15/test_gen_combo_event_control_trigger_after_issuer_end.sv) (main observation, new). Not to wake up immediately after the issue, to wake up only 1 times at the time 2 after the specified event, and not to repeat at subsequent times. Clause: 15.5.1 、 4.4.2.4 、 9.4.2 。
- [test_event_nonblocking_trigger](../tests/ch15/test_event_nonblocking_trigger.sv) (main observation and existing reuse). The present paper describes the basic operation of existing instantaneous and asynchronous triggers and standby. Clause: 15.5.1 、 4.4.2.4 、 9.4 。

- Scope and limits: The basic action of a simple -\>\> is observed separately from the event control that remains after the issuer is terminated.

<a id="e06名前付きforkとdisable"></a>

## E06: named fork and disable

The disable of a named block terminates a waiting child process and a delayed child process.

- [test_gen_combo_named_fork_disable_waiters](../tests/gen/ch9/test_gen_combo_named_fork_disable_waiters.sv) (main observation, new). The delay and event waiting of the disable object is not completed, only the unrelated child is completed and the join return time is set. Clause: 9.6.2 、 9.3.2 、 9.3.4 、 15.5.2 。
- [test_named_blocks_scope_items_and_disable](../tests/ch9/test_named_blocks_scope_items_and_disable.sv) (main observation and existing reuse). The scope of an existing named block fork and its disable. Clause: 9.3.4 、 9.6.2 。

- Scope and limits: The handling of disabled tasks leaving a reserved NBA is not used for expected values as an unspecified range of 9.6.2.

<a id="n01ref-staticと遅延nba"></a>

<a id="n01ref-staticと遅延-nba"></a>

## N01: ref static and delay NBA

The static arguments are passed to ref static. Follow 10.4.2, 9.4.5, and 13.5.2 to ensure that the value and write destination are retained when the reservation is made.

- [test_gen_ref_static_delayed_nba_w65_logic](../tests/gen/ch10/test_gen_ref_static_delayed_nba_w65_logic.sv) (main observation, new). The object is to maintain the identification of the real arguments even after the 2 auto task returns, and to be the old value for the Active at time 2, and the value of the appointment time after NBA. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 4.4.2.2 、 4.4.2.4 。
- [test_gen_ref_static_delayed_nba_w8_bit](../tests/gen/ch10/test_gen_ref_static_delayed_nba_w8_bit.sv) (main observation, new). The object is to maintain the identification of the real arguments even after the 2 auto task returns, and to be the old value for the Active at time 2, and the value of the appointment time after NBA. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 4.4.2.2 、 4.4.2.4 。
- [test_illegal_automatic_task_variable_nonblocking_target](../tests/ch13/test_illegal_automatic_task_variable_nonblocking_target.sv) (comparison and existing reuse). Rejecting the incorrect description of the autotask variable as NBA. Clause: 13.3.2 。

- Scope and limits: Do not use auto variables for ref static real arguments. Delays to automatic variables NBA are distinguished by existing maldescription tests.

<a id="n02ref経由の固定配列要素とイベント待ちnba"></a>

## N02: Fixed array elements and event waiting via reference NBA

8/65 bits, ascending/ descending order of array indexes, change the selectable variable and input value after reservation.

- [test_gen_ref_static_array_event_nba_w65_ascending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_ascending.sv) (main observation, new). The capture value is written to the array element selected at the time of reservation. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 7.4.1 、 4.4.2.3 、 4.4.2.4 。
- [test_gen_ref_static_array_event_nba_w65_descending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w65_descending.sv) (main observation, new). The capture value is written to the array element selected at the time of reservation. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 7.4.1 、 4.4.2.3 、 4.4.2.4 。
- [test_gen_ref_static_array_event_nba_w8_ascending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_ascending.sv) (main observation, new). The capture value is written to the array element selected at the time of reservation. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 7.4.1 、 4.4.2.3 、 4.4.2.4 。
- [test_gen_ref_static_array_event_nba_w8_descending](../tests/gen/ch10/test_gen_ref_static_array_event_nba_w8_descending.sv) (main observation, new). The capture value is written to the array element selected at the time of reservation. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 7.4.1 、 4.4.2.3 、 4.4.2.4 。

- Scope and limits: Do not create unorderly conflicting writes to the same element.

<a id="n03ref経由の多段packed選択とイベント待ちnba"></a>

## N03: multiple steps via reference packed Select and wait for event NBA

Only write to the parent selection range of the child selection, applying the 11.5.1 out-of-range rule.

- [test_gen_ref_static_nested_packed_event_nba_w65_outside_parent](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_outside_parent.sv) (main observation, new). Capture the parent and child selection of the 8/65 bit, and do not update the child bits outside the parent range. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 11.5.1 、 7.4.5 、 4.4.2.3 、 4.4.2.4 。
- [test_gen_ref_static_nested_packed_event_nba_w65_valid](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w65_valid.sv) (main observation, new). Capture the parent and child selection of the 8/65 bit, and do not update the child bits outside the parent range. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 11.5.1 、 7.4.5 、 4.4.2.3 、 4.4.2.4 。
- [test_gen_ref_static_nested_packed_event_nba_w8_outside_parent](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_outside_parent.sv) (main observation, new). Capture the parent and child selection of the 8/65 bit, and do not update the child bits outside the parent range. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 11.5.1 、 7.4.5 、 4.4.2.3 、 4.4.2.4 。
- [test_gen_ref_static_nested_packed_event_nba_w8_valid](../tests/gen/ch10/test_gen_ref_static_nested_packed_event_nba_w8_valid.sv) (main observation, new). Capture the parent and child selection of the 8/65 bit, and do not update the child bits outside the parent range. Clause: 10.4.2 、 9.4.5 、 13.5.2 、 11.5.1 、 7.4.5 、 4.4.2.3 、 4.4.2.4 。

- Scope and limits: The static out‐of‐range selection allows the diagnosis. Do not replace correct out-of-range handling with a simple compile-reject test.

<a id="n04stringの文字選択と遅延nba"></a>

## N04: character selection and delay of string NBA

Evaluate the letter attachment and right margin at the time of reservation, and change the letter attachment, right margin, and adjacent characters until updated.

- [test_gen_string_character_delayed_nba_index1](../tests/gen/ch10/test_gen_string_character_delayed_nba_index1.sv) (main observation, new). Write only the captured byte to the character position at the time of reservation, and keep another update to the adjacent character. Clause: 10.4.2 、 9.4.5 、 6.16 、 6.16.1 、 4.4.2.2 、 4.4.2.4 。
- [test_gen_string_character_delayed_nba_index3](../tests/gen/ch10/test_gen_string_character_delayed_nba_index3.sv) (main observation, new). Write only the captured byte to the character position at the time of reservation, and keep another update to the adjacent character. Clause: 10.4.2 、 9.4.5 、 6.16 、 6.16.1 、 4.4.2.2 、 4.4.2.4 。

- Scope and limits: The meaning of shortening or replacing entire strings during reservation is separated from this item. The string length is fixed.

<a id="a01unpacked-structと書込み可能なref"></a>

## A01: unpacked struct and writable ref

We refer an equivalent struct that follows 13.5.2 to the autotask and observe the instantaneous reflection, which is different from the copy-back.

- [test_gen_combo_struct_ref_immediate_and_return](../tests/gen/ch13/test_gen_combo_struct_ref_immediate_and_return.sv) (main observation, new). The task return is a function of the task recall. Clause: 13.5.2 、 7.2 、 6.21 、 9.4.1 。

- Scope and limits: The real argument is the static life. Do not write to const ref.

<a id="a02struct配列とautomaticinputコピー"></a>

## A02: Structure array and automatic input copy

Checks the pass of the struct array in the autotask and the pass of the array input separately.

- [test_gen_combo_struct_array_input_copy_ascending](../tests/gen/ch13/test_gen_combo_struct_array_input_copy_ascending.sv) (main observation, new). Initialization and independence of each call, input copy of ascending/descending array, and separation of call source change. Clause: 13.5.1 、 7.6 、 7.2 。
- [test_gen_combo_struct_array_input_copy_descending](../tests/gen/ch13/test_gen_combo_struct_array_input_copy_descending.sv) (main observation, new). Initialization and independence of each call, input copy of ascending/descending array, and separation of call source change. Clause: 13.5.1 、 7.6 、 7.2 。
- [test_gen_combo_struct_array_automatic_elements](../tests/gen/ch6/test_gen_combo_struct_array_automatic_elements.sv) (main observation, new). Initialization and independence of each call, input copy of ascending/descending array, and separation of call source change. Clause: 6.21 、 7.2 、 7.4.2 、 9.3.2 、 9.4.1 。

- Scope and limits: Do not confuse input copy with alias reference of ref.

<a id="a03structの固定配列メンバとautomatic"></a>

## A03: Fixed array member and automatic of struct

The struct as an automatic variable has a fixed array member, and the value and time are observed by multiple calls.

- [test_gen_combo_struct_array_automatic_member](../tests/gen/ch6/test_gen_combo_struct_array_automatic_member.sv) (main observation, new). The independent member array of each call, the value of the task execution, and the protection value of the call source. Clause: 6.21 、 7.2 、 7.4.2 、 9.3.2 、 9.4.1 。

- Scope and limits: The physical memory allocation of the structure members and the GC recovery are not observed.

<a id="a04固定配列スライスとoutputinoutコピー戻し"></a>

## A04: Fixed array slice and output/inout copy back

Apply output/inout pass-through of 13.5.1 and copy-back on return to a fixed array slice in ascending/descending order.

- [test_gen_fixed_array_slice_inout_copyback_ascending](../tests/gen/ch13/test_gen_fixed_array_slice_inout_copyback_ascending.sv) (main observation, new). Keep the source of the call during task execution, and update only the specified slice when returning, and keep the external elements. Clause: 13.5 、 13.5.1 、 7.4.6 、 7.6 。
- [test_gen_fixed_array_slice_inout_copyback_descending](../tests/gen/ch13/test_gen_fixed_array_slice_inout_copyback_descending.sv) (main observation, new). Keep the source of the call during task execution, and update only the specified slice when returning, and keep the external elements. Clause: 13.5 、 13.5.1 、 7.4.6 、 7.6 。
- [test_gen_fixed_array_slice_output_copyback_ascending](../tests/gen/ch13/test_gen_fixed_array_slice_output_copyback_ascending.sv) (main observation, new). Keep the source of the call during task execution, and update only the specified slice when returning, and keep the external elements. Clause: 13.5 、 13.5.1 、 7.4.6 、 7.6 。
- [test_gen_fixed_array_slice_output_copyback_descending](../tests/gen/ch13/test_gen_fixed_array_slice_output_copyback_descending.sv) (main observation, new). Keep the source of the call during task execution, and update only the specified slice when returning, and keep the external elements. Clause: 13.5 、 13.5.1 、 7.4.6 、 7.6 。

- Scope and limits: The boundary of the slice is a constant. Do not change real arguments in a separate process during task execution.

<a id="s01実行時packed親選択と子選択"></a>

## S01: Parent and child selections on runtime packed

Uses an array of packed elements of 33 bits x 2 to intersect parent/child direction, 2/4 state, and blocking/ NBA.

- [test_gen_combo_packed_parent_runtime_aa_bit_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_aa_bit_nba.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.2 。
- [test_gen_combo_packed_parent_runtime_aa_logic_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_aa_logic_blocking.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.1 。
- [test_gen_combo_packed_parent_runtime_ad_bit_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_ad_bit_blocking.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.1 。
- [test_gen_combo_packed_parent_runtime_ad_logic_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_ad_logic_nba.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.2 。
- [test_gen_combo_packed_parent_runtime_da_bit_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_da_bit_blocking.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.1 。
- [test_gen_combo_packed_parent_runtime_da_logic_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_da_logic_nba.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.2 。
- [test_gen_combo_packed_parent_runtime_dd_bit_nba](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_dd_bit_nba.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.2 。
- [test_gen_combo_packed_parent_runtime_dd_logic_blocking](../tests/gen/ch11/test_gen_combo_packed_parent_runtime_dd_logic_blocking.sv) (main observation, new). The parent and child positions are chosen during execution, out-of-range read and write are invalidated, and adjacent bits are retained. Clause: 11.5.1 、 7.4.1 、 7.4.5 、 10.4.1 。
- [test_packed_array_bitsel_write](../tests/ch7/test_packed_array_bitsel_write.sv) (comparison and existing reuse). The element write of the fixed packed array is compared with the out-of-range. Clause: 7.4.1 、 7.4.5 、 11.5.1 、 10.4.2 。

- Scope and limits: The 8 item contains all combinations of parent direction x child direction x state and all pairs of assignment modes. The coverage of all 4 factor combinations and registered t-way models is not claimed.

<a id="s02streamingのwithstring左辺入れ子左辺"></a>

## S02: with, string left, insert left of streaming

The with range reuses an existing 2 item. Adds string left-edge length determination and insert streaming left-edge alignment.

- [test_gen_combo_stream_nested_target_ll](../tests/gen/ch11/test_gen_combo_stream_nested_target_ll.sv) (main observation, new). The byte order of the overlapping streams is determined by the string length and the string value. Clause: 11.4.14.3 、 11.4.14.2 、 11.4.14 。
- [test_gen_combo_stream_nested_target_lr](../tests/gen/ch11/test_gen_combo_stream_nested_target_lr.sv) (main observation, new). The byte order of the overlapping streams is determined by the string length and the string value. Clause: 11.4.14.3 、 11.4.14.2 、 11.4.14 。
- [test_gen_combo_stream_nested_target_rl](../tests/gen/ch11/test_gen_combo_stream_nested_target_rl.sv) (main observation, new). The byte order of the overlapping streams is determined by the string length and the string value. Clause: 11.4.14.3 、 11.4.14.2 、 11.4.14 。
- [test_gen_combo_stream_nested_target_rr](../tests/gen/ch11/test_gen_combo_stream_nested_target_rr.sv) (main observation, new). The byte order of the overlapping streams is determined by the string length and the string value. Clause: 11.4.14.3 、 11.4.14.2 、 11.4.14 。
- [test_gen_combo_stream_string_target_resize](../tests/gen/ch11/test_gen_combo_stream_string_target_resize.sv) (main observation, new). The byte order of the overlapping streams is determined by the string length and the string value. Clause: 11.4.14.3 、 11.4.14.4 、 6.24.3 。
- [test_stream_expression_with_range_forms](../tests/ch11/test_stream_expression_with_range_forms.sv) (main observation and existing reuse). The current streaming with range and size and partial update are observed. Clause: 11.4.14.4 、 11.4.14 、 11.4.14.2 、 11.4.14.3 、 A.8.1 。
- [test_stream_with_range_extent_timing_and_partial](../tests/ch11/test_stream_with_range_extent_timing_and_partial.sv) (main observation and existing reuse). The current streaming with range and size and partial update are observed. Clause: 11.4.14.4 。

- Scope and limits: The expected value calculates byte substitution independently and does not overwrite the output of the implementation.

<a id="f01freadと動的配列structメンバ多次元メモリ"></a>

## F01: Fread and dynamic array, struct members, multidimensional memory.

Checks the read byte unit and member order of 21.3.4.4, including the remaining bytes of the file and the values outside the update object.

- [test_gen_comb_fread_dynamic_selection](../tests/gen/ch21/test_gen_comb_fread_dynamic_selection.sv) (main observation, new). Start/count of dynamic arrays, member order of struct arrays, number of all 4 elements and read bytes in 2 dimensions, and end sentinel. Clause: 21.3.4.4 、 21.3.1 、 21.3.2 。
- [test_gen_comb_fread_struct_array_member](../tests/gen/ch21/test_gen_comb_fread_struct_array_member.sv) (main observation, new). Start/count of dynamic arrays, member order of struct arrays, number of all 4 elements and read bytes in 2 dimensions, and end sentinel. Clause: 21.3.4.4 、 21.3.1 、 21.3.2 。
- [test_gen_comb_fread_struct_multidimensional](../tests/gen/ch21/test_gen_comb_fread_struct_multidimensional.sv) (main observation, new). Start/count of dynamic arrays, member order of struct arrays, number of all 4 elements and read bytes in 2 dimensions, and end sentinel. Clause: 21.3.4.4 、 21.3.1 、 21.3.2 。
- [test_fread_unpacked_struct_union](../tests/ch21/test_fread_unpacked_struct_union.sv) (comparison and existing reuse). The existing fixed memory struct read, and the comparison of the partial word with EOF. Clause: 21.3.4.4 。
- [test_fread_partial_word_and_eof](../tests/ch21/test_fread_partial_word_and_eof.sv) (comparison and existing reuse). The existing fixed memory struct read, and the comparison of the partial word with EOF. Clause: 21.3.4.4 。

- Scope and limits: The external byte expression of the real member is reserved because it cannot be determined from the specification. The multidimensional scan sequence repeats the same 2 byte set and cuts off the expected value.

<a id="f02vcdのprograminterface階層と変数"></a>

## F02: program/interface hierarchy and variables of VCD

Use dumpvars without arguments and explicit variable specifications for 21.7.1.2. Reference program variables from inside the program, obeying 24.3's prohibition on external references.

- [test_gen_comb_vcd_program_interface_all_model](../tests/gen/ch21/test_gen_comb_vcd_program_interface_all_model.sv) (main observation, new). Reload the generated VCD and check the scope of module/interface/program, the 1 bit variable name, the scope end support, and the enddefinitions. Clause: 21.7.1.2 、 21.7.1.6 、 21.7.2.1 、 21.7.2.3 、 21.7.5 。
- [test_gen_comb_vcd_program_interface_explicit](../tests/gen/ch21/test_gen_comb_vcd_program_interface_explicit.sv) (main observation, new). Reload the generated VCD and check the scope of module/interface/program, the 1 bit variable name, the scope end support, and the enddefinitions. Clause: 21.7.1.2 、 21.7.1.6 、 21.7.2.1 、 21.7.2.3 、 21.7.5 。
- [test_vcd_dump_readback](../tests/ch21/test_vcd_dump_readback.sv) (comparison and existing reuse). The VCD result check of existing module and signal is performed. Clause: 21.7.1.1 、 21.7.1.2 、 21.7.1.3 、 21.7.1.4 、 21.7.1.6 、 21.7.2.1 、 21.7.2.2 、 21.7.2.3 、 21.7.5 。

- Scope and limits: The date, version, identifier code, scope type notation, etc. are not fixed. The obligation to include program/interface recursively in dumpvars(0,dut) is uncertain, and it is separated from the original missing observation.

<a id="h01動的コンテナと暗黙の感度"></a>

## H01: Dynamic containers and implicit sensitivity

Queue/dynamic array crosses always_comb, always @*, continuous assignment, always_latch. Continuous assignment refers only to $size of 20.7.

- [test_gen_comb_heap_sensitivity_dynamic_continuous](../tests/gen/ch10/test_gen_comb_heap_sensitivity_dynamic_continuous.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 10.3.2 、 20.7 、 7.5.1 。
- [test_gen_comb_heap_sensitivity_queue_continuous](../tests/gen/ch10/test_gen_comb_heap_sensitivity_queue_continuous.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 10.3.2 、 20.7 、 7.10 。
- [test_gen_comb_heap_sensitivity_dynamic_comb](../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_comb.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 9.2.2.2.1 、 9.2.2.2 、 7.5.1 。
- [test_gen_comb_heap_sensitivity_dynamic_latch](../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_latch.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 9.2.2.3 、 9.2.2.2.1 、 7.5.1 。
- [test_gen_comb_heap_sensitivity_dynamic_star](../tests/gen/ch9/test_gen_comb_heap_sensitivity_dynamic_star.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 9.4.2.2 、 7.5.1 。
- [test_gen_comb_heap_sensitivity_queue_comb](../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_comb.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 9.2.2.2.1 、 9.2.2.2 、 7.10 。
- [test_gen_comb_heap_sensitivity_queue_latch](../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_latch.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 9.2.2.3 、 9.2.2.2.1 、 7.10 。
- [test_gen_comb_heap_sensitivity_queue_star](../tests/gen/ch9/test_gen_comb_heap_sensitivity_queue_star.sv) (main observation, new). The incremental values of resizing, updating of selected and unselected elements, container replacement and empty, enable and latch retention. Clause: 9.4.2.2 、 7.10 。
- [test_always_comb_vs_always_star](../tests/ch9/test_always_comb_vs_always_star.sv) (comparison and existing reuse). Comparison of the static variable always_comb and the static variable always@*. Clause: 9.2.2.2.2 、 9.2.2.2.1 、 9.4.2.2 。

- Scope and limits: 6.21 avoids non-procedural dynamic element references. In the continuum assignment, the sensitivity to the element value is not claimed. It does not depend on unconditional execution at @* start.

<a id="u01heap値のfile-monitorと登録元の記述位置"></a>

## U01: file monitor and registry source description location of heap value

Monitor registration of a queue/dynamic array of static lifetime from a 9 type description location to MCD / FD. Choose 18 from 36 and include 40 pairs and 3 required.

- [test_gen_comb_file_monitor_dynamic_fd_always](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_always.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_fd_fork](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_fork.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_fd_function](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_function.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_fd_generate](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_generate.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_fd_initial](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_initial.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_fd_interface](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_interface.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_fd_task](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_fd_task.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_mcd_package](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_mcd_package.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_dynamic_mcd_program](../tests/gen/ch21/test_gen_comb_file_monitor_dynamic_mcd_program.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.5.1 。
- [test_gen_comb_file_monitor_queue_fd_package](../tests/gen/ch21/test_gen_comb_file_monitor_queue_fd_package.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_fd_program](../tests/gen/ch21/test_gen_comb_file_monitor_queue_fd_program.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_always](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_always.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_fork](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_fork.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_function](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_function.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_generate](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_generate.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_initial](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_initial.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_interface](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_interface.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_gen_comb_file_monitor_queue_mcd_task](../tests/gen/ch21/test_gen_comb_file_monitor_queue_mcd_task.sv) (main observation, new). The following features are added to Postponed: concentration of simultaneous updates, changes of non-selected elements and selections, container replacement, output stop after monitoroff and close, and leakage prevention to reopen destination. Clause: 21.3.2 、 21.2.3 、 21.3.1 、 21.3.4.2 、 4.4.2.9 、 7.10 。
- [test_file_fmonitor_fstrobe](../tests/ch21/test_file_fmonitor_fstrobe.sv) (comparison and existing reuse). The file monitor, the lifetime of the descriptor, and the reuse of static variables are compared with close. Clause: 21.3.2 、 21.2.2 、 21.2.3 、 21.3.1 、 21.3.4.2 。
- [test_fclose_cancels_fmonitor_fstrobe](../tests/ch21/test_fclose_cancels_fmonitor_fstrobe.sv) (comparison and existing reuse). The file monitor, the lifetime of the descriptor, and the reuse of static variables are compared with close. Clause: 21.3.1 、 21.3.2 、 21.3.4.2 。
- [test_file_close_fd](../tests/imported/ch21/test_file_close_fd.sv) (comparison and existing reuse). The file monitor, the lifetime of the descriptor, and the reuse of static variables are compared with close. Clause: 21.3.1 、 21.3.2 、 21.3.4.2 。
- [test_file_output_initial](../tests/imported/ch21/test_file_output_initial.sv) (comparison and existing reuse). The file monitor, the lifetime of the descriptor, and the reuse of static variables are compared with close. Clause: 21.3.1 、 21.3.2 、 21.3.4.2 。

- Scope and limits: Only the following types are selected: Registry 9 Type x Container 2 Type x Descriptor 2 Type. Does not include all 36 3 factor combinations or all syntax.
- Scope and limits: The close result is observed without output. Do not verify removal of internal GC root or release of physical memory.
- Scope and limits: The registration and re-provision during native callback is not confirmed in another API test range. The SV function with side effects is not considered to be unconditionally equivalent.

<a id="分離した解釈api範囲"></a>

## Separate interpretation, API range

- automatic_nba_illegal_control: Reuse of incorrect description in existing test. 10.4.2 and 13.3.2 make NBA to automatic variables impossible. Not to be confused with the valid ref static of N01.
- strobe_auto: Interpretation reservation. You need to check individually whether the autovariable 13.3.2's tracing prohibition includes strobe. The original front-end rejection alone does not determine the illegality.
- packed_parent_constant_oob: Operation and diagnosis outside the legal range are allowed. Check for read/write out of range of 11.5.1. The existence of the diagnosis alone is not classified as illegal.
- fread_real_member: Interpretation of expected values is reserved. Cannot determine external byte encoding of real member from 21.3.4.4. Do not relabel the result as unsupported or illegal, or fabricate a positive expectation.
- vcd_recursive_program_interface: Separate the original observation and the obligation on the standard. The dumpvars(0,dut) outputs only modules, but keeps the original result. The obligation to include program/interface as well as child modules is not determined. Added valid regression for all variables or explicit variables.
- program_external_variable_reference: Avoid the prohibition by 24.3. Calls dumpvars from inside the program, without referring to program variables hierarchically from the module. # 0 also ensures the order with the simultaneous dumpfile settings.
- continuous_dynamic_element: Avoid the prohibition of extraprocedural reference by 6.21. Uses $size without selecting dynamic elements outside the procedure. In the sensitivity test in the procedure, the element and the size are observed.
- native_callback_reentry: other API range, not confirmed. Considering the Postponed constraint of 4.4.2.9 and the evaluation of the monitoring argument, the side effect function of SV is not equivalent to the registration reentry in any native callback. The deregistration, re-enrollment and GC root retention during dispatch is left as a task to be verified with the native API.

<a id="現在の入力に対応する実行証跡"></a>

## Execution trace corresponding to current input

### coverage/combination-results/issue21-icarus-13.json

- Edition: Icarus Verilog version 13.0 (stable) (v13_0-dirty)。
- Execution timestamp: 2026-10-30T00:40:13.297515+00:00.
- All objects: pass = 11 , fail = 0 , known = 76 , unsupported = 0 , stale = 1 , not_run = 0.
- E01: The main observation was not achieved. known = 2 。
- E02: The main observation was not achieved. known = 2 。
- E03: All main observations passed. pass = 1 。
- E04: The main observation was not achieved. known = 2 。
- E05: The main observation was not achieved. known = 2 。
- E06: All main observations passed. pass = 2 。
- N01: The main observation was not achieved. known = 2 。
- N02: The main observation was not achieved. known = 4 。
- N03: The main observation was not achieved. known = 4 。
- N04: The main observation was not achieved. known = 2 。
- A01: The main observation was not achieved. known = 1 。
- A02: The main observation was not achieved. known = 3 。
- A03: The main observation was not achieved. known = 1 。
- A04: The main observation was not achieved. known = 4 。
- S01: The main observation was not achieved. known = 8 。
- S02: The main observation was not achieved. known = 7 。
- F01: The main observation was not achieved. known = 3 。
- F02: All main observations passed. pass = 2 。
- H01: The main observation was not achieved. known = 8 。
- U01: The main observation was not achieved. known = 18 。

### coverage/combination-results/issue21-kirimasim-latest.json

- Edition: kirimasim 0.0.0 (commit 1ca363e2c922), built with AppleClang 21.0.0.21000334。
- Execution timestamp: 2026-10-30T00:41:13.175003+00:00.
- All objects: pass = 26 , fail = 2 , known = 0 , unsupported = 59 , stale = 1 , not_run = 0.
- E01: The main observation was not achieved. unsupported = 2 。
- E02: The main observation was not achieved. unsupported = 2 。
- E03: The main observation was not achieved. unsupported = 1 。
- E04: The main observation was not achieved. unsupported = 2 。
- E05: The main observation was not achieved. unsupported = 2 。
- E06: The main observation was not achieved. unsupported = 2 。
- N01: The main observation was not achieved. unsupported = 2 。
- N02: The main observation was not achieved. unsupported = 4 。
- N03: The main observation was not achieved. unsupported = 4 。
- N04: The main observation was not achieved. unsupported = 2 。
- A01: The main observation was not achieved. unsupported = 1 。
- A02: The main observation was not achieved. unsupported = 3 。
- A03: The main observation was not achieved. unsupported = 1 。
- A04: The main observation was not achieved. unsupported = 4 。
- S01: The main observation was not achieved. unsupported = 8 。
- S02: The main observation was not achieved. unsupported = 7 。
- F01: The main observation was not achieved. unsupported = 3 。
- F02: The main observation was not achieved. fail = 2 。
- H01: The main observation was not achieved. unsupported = 8 。
- U01: All main observations passed. pass = 18 。

### coverage/combination-results/issue21-verilator-5.052-seed1.json

- Edition: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- Execution timestamp: 2026-10-30T00:40:20.650747+00:00.
- All objects: pass = 27 , fail = 0 , known = 49 , unsupported = 0 , stale = 1 , not_run = 11.
- E01: The main observation was not achieved. known = 2 。
- E02: The main observation was not achieved. known = 2 。
- E03: All main observations passed. pass = 1 。
- E04: The main observation was not achieved. known = 2 。
- E05: The main observation was not achieved. known = 2 。
- E06: All main observations passed. pass = 2 。
- N01: The main observation was not achieved. known = 1 , not_run = 1 。
- N02: The main observation was not achieved. known = 2 , not_run = 2 。
- N03: The main observation was not achieved. known = 3 , not_run = 1 。
- N04: The main observation was not achieved. known = 2 。
- A01: All main observations passed. pass = 1 。
- A02: All main observations passed. pass = 3 。
- A03: All main observations passed. pass = 1 。
- A04: All main observations passed. pass = 4 。
- S01: The main observation was not achieved. known = 4 , not_run = 4 。
- S02: The main observation was not achieved. pass = 4 , known = 2 , not_run = 1 。
- F01: The main observation was not achieved. known = 3 。
- F02: The main observation was not achieved. known = 2 。
- H01: All main observations passed. pass = 8 。
- U01: The main observation was not achieved. known = 18 。

### coverage/combination-results/issue21-verilator-5.052-seed73.json

- Edition: Verilator 5.052 2026-09-05 rev vUNKNOWN-built20260905。
- Execution timestamp: 2026-10-30T00:40:24.278982+00:00.
- All objects: pass = 27 , fail = 0 , known = 49 , unsupported = 0 , stale = 1 , not_run = 11.
- E01: The main observation was not achieved. known = 2 。
- E02: The main observation was not achieved. known = 2 。
- E03: All main observations passed. pass = 1 。
- E04: The main observation was not achieved. known = 2 。
- E05: The main observation was not achieved. known = 2 。
- E06: All main observations passed. pass = 2 。
- N01: The main observation was not achieved. known = 1 , not_run = 1 。
- N02: The main observation was not achieved. known = 2 , not_run = 2 。
- N03: The main observation was not achieved. known = 3 , not_run = 1 。
- N04: The main observation was not achieved. known = 2 。
- A01: All main observations passed. pass = 1 。
- A02: All main observations passed. pass = 3 。
- A03: All main observations passed. pass = 1 。
- A04: All main observations passed. pass = 4 。
- S01: The main observation was not achieved. known = 4 , not_run = 4 。
- S02: The main observation was not achieved. pass = 4 , known = 2 , not_run = 1 。
- F01: The main observation was not achieved. known = 3 。
- F02: The main observation was not achieved. known = 2 。
- H01: All main observations passed. pass = 8 。
- U01: The main observation was not achieved. known = 18 。

<a id="再実行と更新"></a>

## Rerun and refresh

The fingerprints of the log are not updated automatically. Change the stimulus after reconfirming stimulus, observation, and standard basis. `--check` is a consistency check of the log and report, and does not require all cases of the implementation to pass.

```sh
python3 tools/combination_gaps.py --list-tests
python3 tools/combination_gaps.py --update
python3 tools/combination_gaps.py --check
```

Pass the output of `--list-tests` to the test argument of the existing runner, save the new results in `--json` to `coverage/combination-results/`, and then update the report. kirimasim should be checked for upstream commits just before execution and build from that version.
