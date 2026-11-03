<a id="機能間クロスの計画と実行確認"></a>

# Plan and execution of cross‐functionality verification.

[English](interaction-coverage.en.md) / [日本語](interaction-coverage.md)

This report is only for registered finite models. The coverage of the requirements and the combination of all languages is not the same. The coverage on the plan and the confirmation of the pass based on the execution result are divided. The existing test is not reduced. A reduction in selected case count is not a measured reduction in runtime.

For the source, use, and limits of application, see [Import procedure](https://github.com/kurochan001/kirimasim-tests/blob/e8d991a97b2abb12a41a1fb6b89c2406f9aa7292/docs/interaction-verification.en.md).

## scheduling_visibility / model 1

- The number of combinations satisfying the constraint is 325.
- Existing and new tests available: 325.
- Short run options: 51.
- The case must be kept separate: 0.
- The plan of the factor 2: 126/126.
- The plan of the factor 3: 51/51.

Observe the existing 8-bit writes at specified times and event regions from the writing process, a separate waiting process, strobe and monitor. Keep the existing generated tests and expected values unchanged.

- writer: blocking, nba, nbadelay, assign, force。
- reader: same, wait, strobe, monitor。
- home: initial, always, task, function, fork, interface, generate。
- delay: nodelay, delay0, delay1。

Constraints: The existing scheduling.allowed is followed, and the combinations with uncertain observation results and the delayed NBA within the function are excluded. Do not exclude cases because a simulator lacks support

## nba_capture / model 1

- The number of combinations satisfying the constraint is 432.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 3.
- The plan of the factor 2: 162/162.
- The plan of the factor 3: 44/44.

Use outputs immediately after assignment, after stimulus changes, at time 1 and at completion to check value and target capture, preservation of adjacent elements, ordering between the Active and NBA regions, and updates after an automatic task returns.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- storage: scalar, array。
- direction: none, ascending, descending。
- home: initial, task。
- timing: immediate, delayed。

Constraints: The direction of the addition of the scale is not appropriate. In the array, we choose ascending or descending order.

## expression_context / model 1

- The number of combinations satisfying the constraint is 588.
- Existing and new tests available: 51.
- Short run options: 51.
- The case must be kept separate: 3.
- The plan of the factor 2: 143/143.
- The plan of the factor 3: 63/63.

Check addition, subtraction and multiplication with 4 input sets. Combine sign/zero extension before the operation, destination-driven width propagation, carry and final truncation.

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- result_width: narrow, same, wide。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- operator: add, sub, mul。

Constraints: The narrow for width 1 is excluded because the width is 0. The difference in width is 1 bits.

## packed_part_select / model 1

- The number of combinations satisfying the constraint is 744.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 3.
- The plan of the factor 2: 162/162.
- The plan of the factor 3: 48/48.

Display the whole vector and selected range before and after writing a part-select to check index direction, selection direction, X/Z conversion and preservation of unselected bits.

- width: 1, 32, 33, 64, 65, 129。
- direction: ascending, descending。
- select: plus, minus。
- span: single, half。
- position: low, high, interior。
- state: bit, logic。
- value: known, x, z。

Constraints: Excludes the selection of width 0. The combination where high/interior is in the same position as low is excluded. The selection range is within a vector. The lower limit of the index is 4.

## conditional_merge / model 1

- The number of combinations satisfying the constraint is 1408.
- Existing and new tests available: 32.
- Short run options: 32.
- The case must be kept separate: 3.
- The plan of the factor 2: 185/185.
- The plan of the factor 3: 76/76.

Display both branch inputs and the conditional result to check branch selection, bitwise merging under X/Z, sign extension, destination width and 2-state conversion in one expression pipeline.

- width: 1, 33, 65, 129。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- condition: 0, 1, x, z。
- pattern: equal, opposite, same_xz, mixed_xz。
- result_width: narrow, same, wide。
- state: bit, logic。

Constraints: The narrow of width 1 is excluded because it is width 0. The source width of both branches is the same, and only the assignment width is increased or decreased by 1 bits. The condition is 1 bits.

## shift_context / model 1

- The number of combinations satisfying the constraint is 5520.
- Existing and new tests available: 56.
- Short run options: 56.
- The case must be kept separate: 4.
- The plan of the factor 2: 298/298.
- The plan of the factor 3: 92/92.

Display the pre-shift value, shift amount and result to check destination-driven width, signed fill, X/Z movement, unknown shift amounts and final 2-state conversion.

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- operator: shl, shr, ashl, ashr。
- count: zero, one, last, width, beyond, x, z。
- value: known, x, z。
- result_width: narrow, same, wide。
- state: bit, logic。

Constraints: The narrow of width 1 is excluded because the width is 0. The one/last values with duplicate numbers in width 1 are integrated into width/zero. The width/last/beyond of count is based on the original left operand width.

## cast_pipeline / model 1

- The number of combinations satisfying the constraint is 1512.
- Existing and new tests available: 32.
- Short run options: 32.
- The case must be kept separate: 3.
- The plan of the factor 2: 214/214.
- The plan of the factor 3: 76/76.

Display the original value, immediate cast result and subsequent arithmetic result separately to check cast width/sign, X/Z conversion before arithmetic, outer assignment context and final conversion order.

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- value: known, x, z。
- cast: size, signed, unsigned, typed_bit, typed_logic。
- cast_width: narrow, same, wide。
- operation: plain, add。
- state: bit, logic。

Constraints: The signing cast does not change the width, so cast_width =same. The narrow of width 1 is excluded. The assignment point is the original width +2. typed cast type is unsigned

## task_argument_visibility / model 1

- The number of combinations satisfying the constraint is 576.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 3.
- The plan of the factor 2: 144/144.
- The plan of the factor 3: 52/52.

Observe actual arguments inside the task, immediately before return and after return to check update timing for copy and reference arguments, values and preservation of adjacent elements.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- mode: input, output, inout, ref。
- storage: scalar, element。
- timing: immediate, delayed。

Constraints: Use the automatic task on all lines, and make the real and temporary arguments of the same type typedef. The sequence is fixed length of [2:3 ]. Does not change the index of the real argument during the call

## argument_binding_index / model 1

- The number of combinations satisfying the constraint is 972.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 5.
- The plan of the factor 2: 162/162.
- The plan of the factor 3: 63/63.

After the call, change the index to an equal value, the next element and -1, then observe actual/formal values at multiple times to check binding to the original element, input value copying, bidirectional ref visibility, live reads through const ref, absence of return-time writeback and preservation of adjacent elements.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- mode: input, ref, const_ref。
- storage: fixed, dynamic, queue。
- index: same, next, invalid。

Constraints: Use automatic tasks for all lines. The fixed array is [ 2:4 ], and the dynamic array and queue are 3 elements. The index of the real arguments is pointed to the beginning of the argument at the call, and is changed to the equivalent subelement -1 after the 1 tick. Do not read the array with the post-change index. The type avoids the type conversion of the reference with the same typedef. We cycle the input of the 3 pair, and include the known values of the X/Z row as well. The return point evaluation of output/inout, the size change, the real argument with side effects, and NBA are excluded.

## packed_structure / model 1

- The number of combinations satisfying the constraint is 1152.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 3.
- The plan of the factor 2: 186/186.
- The plan of the factor 3: 52/52.

Observe all structure bits, payload, tag and the extended results of members and the whole structure to check layout, the updated region, NBA value capture and signedness of each expression.

- width: 1, 32, 33, 64, 65, 129。
- layout: first, last。
- aggregate_sign: unsigned, signed。
- member_sign: unsigned, signed。
- state: bit, logic。
- value: known, x, z。
- access: member, whole。
- update: blocking, nba。

Constraints: The tag of the payload and the 3 bit is the same 2/4 state type. The tag is fixed to 101. The extension point is the payload width +4. The pack structure is static, and after NBA it is observed as #1

## case_matching / model 1

- The number of combinations satisfying the constraint is 2448.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 3.
- The plan of the factor 2: 220/220.
- The plan of the factor 3: 82/82.

Display selector and item values and observe 2 branch outcomes with overlapping and fallback items to check width/sign unification, X/Z handling and first-match priority.

- width: 1, 32, 33, 64, 65, 129。
- selector_sign: unsigned, signed。
- item_sign: unsigned, signed。
- item_width: narrow, same, wide。
- kind: case, casez, casex。
- value: known, x, z。
- pattern: equal, flip_low, wild_high, unknown_low。

Constraints: The narrow of width 1 is excluded because it is width 0. 2 items are of the same type and width. The unique/priority modification, inside, matches, and the side effects of the expression are excluded.

## port_connection / model 1

- The number of combinations satisfying the constraint is 1632.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 5.
- The plan of the factor 2: 204/204.
- The plan of the factor 3: 56/56.

Use width-changing parent/child connections and observe the source value, 4-state connection and sampled variable to check connection direction, source signedness, declaration/connection forms and final 2-state conversion.

- width: 1, 32, 33, 64, 65, 129。
- direction: input, output。
- sign: unsigned, signed。
- sink_width: narrow, same, wide。
- value: known, x, z。
- sample_state: bit, logic。
- binding: named, positional。
- declaration: ansi, nonansi。

Constraints: The narrow of width 1 is excluded. The port and the connection line are explicitly stated as 4 wire. bit / logic is the type of the sample variable after # 1, not the type of the port itself. inout/ref is not applicable

## unpacked_array_copy / model 1

- The number of combinations satisfying the constraint is 576.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 3.
- The plan of the factor 2: 148/148.
- The plan of the factor 3: 52/52.

Copy 2 input sets to whole arrays or slices to check declaration-order correspondence, preservation of unselected elements, independence after source updates and sign extension of read elements.

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- state: bit, logic。
- source_order: ascending, descending。
- target_order: ascending, descending。
- value: known, x, z。
- operation: whole, slice。

Constraints: The element type of both arrays is the same typedef. Each 3 element and slice is the first 2 element in the declaration order. The method uses a fixed‐length array with non‐zero indexes, and excludes dynamic array, queue, and element‐type conversions.

## bit_vector_queries / model 1

- The number of combinations satisfying the constraint is 3320.
- Existing and new tests available: 60.
- Short run options: 60.
- The case must be kept separate: 4.
- The plan of the factor 2: 285/285.
- The plan of the factor 3: 108/108.

Display actual argument bits/width and function results to check expression form, state conversion, X/Z position, deduplication of control bits, one-hot classification and unknown detection.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- expression: direct, half, prefix, repeat。
- value: zero, one, many, x, z, mixed。
- position: none, low, middle, high。
- controls: zero, one, unknown, mixed, duplicate。

Constraints: The position of zero is none. Other values are low/middle/high. In width 1, only low is used, many/mixed and half are excluded. Half is the lower half. The control bit is the 1 bit constant.

## streaming_permutation / model 1

- The number of combinations satisfying the constraint is 1152.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 4.
- The plan of the factor 2: 182/182.
- The plan of the factor 3: 68/68.

Compare the input stream and result to check block order, partial blocks, concatenation of multiple items, inverse pack/unpack transformations and conversion to 2-state storage.

- width: 1, 32, 33, 64, 65, 129。
- direction: left, right。
- slice: 1, 4, 8, 16。
- form: plain, tagged。
- operation: pack, unpack。
- state: bit, logic。
- value: known, x, z。

Constraints: The slice width is a positive constant. tagged adds 101 to the prefix. The number of bits of the input and output is identical, and only the packet vector is used. Dynamic arrays, with ranges, and size mismatch are excluded.

## comparison_context / model 1

- The number of combinations satisfying the constraint is 3400.
- Existing and new tests available: 100.
- Short run options: 100.
- The case must be kept separate: 4.
- The plan of the factor 2: 302/302.
- The plan of the factor 3: 174/174.

Use 4 input sets to check width/sign unification, unknowns versus known mismatches and right-hand-only wildcards, then assign the 1-bit comparison result directly to wide logic/bit destinations to observe conversion order.

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- operator: lt, le, gt, ge, eq, ne, ceq, cne, weq, wne。
- value: known, lhs_x, rhs_x, rhs_z, both_unknown。

Constraints: The narrow for width 1 is excluded because the width is 0. The comparison object is a pack integer. Using the input of the 4 pair, both_unknown puts X/X·Z/Z·X/Z·Z/X to the front bit.

## array_reduction_pipeline / model 1

- The number of combinations satisfying the constraint is 4320.
- Existing and new tests available: 72.
- Short run options: 72.
- The case must be kept separate: 8.
- The plan of the factor 2: 261/261.
- The plan of the factor 3: 162/162.

Observe fixed-array, dynamic-array and queue reductions under 2 background input sets to check element conversion in the with expression, result width, overflow, X/Z propagation and extension after the call.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- storage: fixed, dynamic, queue。
- method: sum, product, and, or, xor。
- transform: plain, widen, int, integer。
- value: known, high_x, high_z。

Constraints: Each container is a 3 element. The fixed length sequence is [3:1 ]. widen is a size cast to element width +1; int / integer are casts to signed 32-bit 2/4-state types. The empty array, the associative array, and the with expression with side effects are excluded.

## variable_bit_index / model 1

- The number of combinations satisfying the constraint is 2880.
- Existing and new tests available: 44.
- Short run options: 44.
- The case must be kept separate: 4.
- The plan of the factor 2: 253/253.
- The plan of the factor 3: 106/106.

Observe variable-index bits and the whole value before/after writes to check index signedness, range origin/direction, default values for invalid reads and preservation under invalid writes.

- width: 1, 32, 33, 64, 65, 129。
- origin: zero, offset, negative。
- direction: ascending, descending。
- state: bit, logic。
- index_sign: unsigned, signed。
- index: low, high, middle, before, after, x, z。
- value: known, x, z。

Constraints: The range is 0 starting point, 5 starting point and 3 species with all the indexes negative. The index is logic of 16 bits. The width of 1 is the same as low, so high/middle is excluded. Verify read and write in all cases.

## queue_update_capacity / model 1

- The number of combinations satisfying the constraint is 3456.
- Existing and new tests available: 48.
- Short run options: 48.
- The case must be kept separate: 5.
- The plan of the factor 2: 258/258.
- The plan of the factor 3: 120/120.

Use 2 input sets to observe size, every element, popped values and a pre-operation copy, checking insertion position, capacity-driven discard, empty defaults, type conversion and independence of value copies.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- capacity: unbounded, two, three。
- size: 0, 2, 3。
- operation: push_front, push_back, insert, write_end, pop_front, pop_back。
- value: known, x, z。

Constraints: The initial sizes were 0, 2, and 3. The size of the capacity 2 is excluded, except for 3. The capacity is expressed in the number of elements. The additional value is the element width +1, insert is the center, and write_end is a write to size(). The input of the 2 pair is used to observe the pre‐operation copy. The validity period of the element reference is excluded.

## queue_element_reference / model 1

- The number of combinations satisfying the constraint is 2160.
- Existing and new tests available: 60.
- Short run options: 60.
- The case must be kept separate: 5.
- The plan of the factor 2: 257/257.
- The plan of the factor 3: 96/96.

Use 3 input sets to observe retained references, all elements after changes, the result after 2 writes and a value copy, checking identity after element movement, survival and isolated writes of old references after deletion/whole assignment, tail discard on capacity overflow and bit/logic argument conversion.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- capacity: unbounded, three。
- held: first, middle, last。
- operation: push_front, push_back, insert, pop_front, pop_back, delete_held, delete_other, copy, concat, clear。
- value: known, x, z。

Constraints: The initial number of elements is 3, and the capacity is unlimited or 3. The insert is the adjective 1. delete_other is adding 2 if the reference is first, and 0 if the first is not. The index is not changed during the call. We cycle the known inputs of the 3 group, and include the known values of the X/Z row as well. The synchronous competition, ref static, dynamic/associative array, and physical memory retrieval are excluded. Do not exclude cases because of unsupported behavior

## division_context / model 1

- The number of combinations satisfying the constraint is 4704.
- Existing and new tests available: 72.
- Short run options: 72.
- The case must be kept separate: 5.
- The plan of the factor 2: 283/283.
- The plan of the factor 3: 98/98.

Observe both operands and the result to check width/sign unification before arithmetic, quotient rounding toward 0, remainder sign, division by zero, X/Z propagation and final 2-state conversion.

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- result_width: narrow, same, wide。
- sign_a: unsigned, signed。
- sign_b: unsigned, signed。
- operator: div, mod。
- value: known, zero, lhs_x, lhs_z, rhs_x, rhs_z。
- state: bit, logic。

Constraints: The narrow for width 1 is excluded because the width is 0. Both inputs are integers of logic packets. state is the assignment type, and the 2 state is converted after the operation. The 4 group of known values is verified for all rows, and the zero/X/Z row also applies the specified values to the same 4 group. -1 is the smallest negative value, and the positive and negative coefficients are confirmed. Real numbers are excluded.

## dynamic_array_resize / model 1

- The number of combinations satisfying the constraint is 2016.
- Existing and new tests available: 38.
- Short run options: 38.
- The case must be kept separate: 5.
- The plan of the factor 2: 219/219.
- The plan of the factor 3: 96/96.

Observe size and all elements before/after allocation to check copying another array, self-resizing, reconstruction without an initializer, truncation, type-specific defaults in added elements and independence after copying.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- value: known, x, z。
- old_size: 0, 2, 3。
- new_size: 0, 1, 2, 4。
- operation: copy, self, reset。

Constraints: Initial size 0 fixes the value factor to known and excludes the duplication that has no value. We compare the regeneration of the same dynamic array typedef with a separate array copy, self-resize, and no initialization formula. The size is a runtime variable. The validity period of the element reference and multidimensional arrays are excluded.

## concatenated_assignment / model 1

- The number of combinations satisfying the constraint is 4608.
- Existing and new tests available: 72.
- Short run options: 72.
- The case must be kept separate: 5.
- The plan of the factor 2: 265/265.
- The plan of the factor 3: 126/126.

Use 2 sets of known and X/Z inputs to check extension/splitting of the whole concatenation, state conversion of each item, immediate updates versus NBA value capture, and signedness when reading individual items versus the concatenation.

- width: 2, 32, 33, 64, 65, 129。
- split: head_bit, halves, tail_bit。
- rhs_width: narrow, same, wide。
- rhs_sign: unsigned, signed。
- state: bb, bl, lb, ll。
- member_sign: unsigned, signed。
- update: blocking, nba。
- value: known, x, z。

Constraints: The width is the minimum width of the whole link 2, and each element is the normal width. In the width 2, the same division is unified to head_bit. The static variables 2 are linked together, and the signedness of the two variables are common. state is left/right bit / logic. The known 2 group and the 2 group of X/Z are observed if necessary. Duplicate assignment, partial selection, multidimensional array are excluded.

## packed_logical_reduction / model 1

- The number of combinations satisfying the constraint is 1180.
- Existing and new tests available: 70.
- Short run options: 70.
- The case must be kept separate: 6.
- The plan of the factor 2: 218/218.
- The plan of the factor 3: 142/142.

For every row, observe inputs, actual expressions and results for all 6 reductions and logical negation to check controlling values and X/Z, state conversion before/after the operation, extension of the 1-bit unsigned result and self-determined input width.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- expression: direct, half, prefix_zero, prefix_one。
- value: zero, ones, one, x, z, mixed。
- position: none, low, middle, high。
- result_state: bit, logic。

Constraints: The position of zero/ones is none, and the other is low/middle/high. The width 1 uses only low, excluding half which is mixed and the width 0. Half is the lower half. In each row, all 6 reductions and! were observed. We separate the state type of the input and the state type of the destination, and we observe all known 1 inputs in all lines. Fixes the input to signed and confirms that the result is unsigned.

## logical_short_circuit / model 1

- The number of combinations satisfying the constraint is 2088.
- Existing and new tests available: 92.
- Short run options: 92.
- The case must be kept separate: 5.
- The plan of the factor 2: 214/214.
- The plan of the factor 3: 236/236.

For each 4 operation, display left/right function call counts, observed values and independent side effects to check short-circuit suppression of the right operand, truth conversion of unknowns, the result and state conversion at final storage.

- width: 1, 32, 33, 64, 65, 129。
- rhs_width: narrow, same, wide。
- state: bb, bl, lb, ll。
- value_a: zero, one, unknown, mixed。
- value_b: zero, one, unknown, mixed。
- result_state: bit, logic。

Constraints: Exclude the right input of width 0. The mixed is the topmost X/Z and the lowest 1, so the width 1 is excluded. state is left/right bit / logic. The unknown values of X/Z are confirmed by both separate stimuli in the same row. The 4 calculation is performed on all lines, and the side effects are independent on the left and the right. Fixed input to signed

## edge_event_expression / model 1

- The number of combinations satisfying the constraint is 4096.
- Existing and new tests available: 64.
- Short run options: 64.
- The case must be kept separate: 5.
- The plan of the factor 2: 260/260.
- The plan of the factor 3: 152/152.

Exclude the initial event under both backgrounds and observe values immediately after updates and 3 counters in the next time step to check X/Z transitions, expression changes, vector LSB rules, state conversion and NBA update timing.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- expression: vector, lsb, msb, reduce_or。
- position: low, middle, high。
- before: 0, 1, x, z。
- after: 0, 1, x, z。
- update: blocking, nba。

Constraints: The focus position of the width 1 is unified to low. In each row, the background 0/1, the known 0 → 1 and the specified transition are observed. For the whole expression and the LSB / MSB / OR expressions, measure posedge, negedge, and non-edge changes simultaneously. Clear the counter by converging the initial settings and count at the next time of the update. Event OR, iff, multiple updates, glitches, and multiple clocks are outside scope

## event_or_iff / model 1

- The number of combinations satisfying the constraint is 252.
- Existing and new tests available: 27.
- Short run options: 27.
- The case must be kept separate: 4.
- The plan of the factor 2: 104/104.
- The plan of the factor 3: 59/59.

Observe independent left/right event counts, wakeups of conditional OR controls and preservation after condition-only changes to check per-term iff binding, equivalence of or/comma, repeated named-event triggering, truth of conditions containing X/Z and blocking/NBA update timing.

- join: or, comma。
- source: signals, named, mixed。
- edge: change, posedge, negedge。
- filter: both, first, second。
- guard: known, xz, mixed。
- update: blocking, nba。

Constraints: The rows for named events only are unified to edge =change. Mixed is marked with a signal on the left and a name on the right. Edge designation is applied only to signal items. The condition and two events are updated at different times, and the count is cleared after initial setting. The side effects of simultaneous triggering, grit, sequence events, and conditional expressions are excluded. Do not exclude cases because of unsupported behavior

## heap_file_monitor_context / model 1

- The number of combinations satisfying the constraint is 36.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 3.
- The plan of the factor 2: 40/40.

Cross 9 registration locations with 2 container/descriptor kinds, then read files back to check final Postponed values, unselected elements, selection/replacement, monitoroff and output suppression after closing.

- context: initial, task, function, fork, generate, interface, program, package, always。
- storage: queue, dynamic。
- descriptor: mcd, fd。

Constraints: All 36 lines are valid. The context is where the registration is done, and the object of monitoring is the static variable. The program is placed in a separate existing process. In each row, the failures of multiple updates at the same time, monitoroff, and close are observed. Re-entry and re-allot from native callback to another unconfirmed API range

## compound_shift_target / model 1

- The number of combinations satisfying the constraint is 7560.
- Existing and new tests available: 40.
- Short run options: 40.
- The case must be kept separate: 4.
- The plan of the factor 2: 308/308.
- The plan of the factor 3: 90/90.

Observe scalars, every array element, parent vectors, extended values and index-function call counts before/after compound shift assignments to check 1-time evaluation of the left operand, part-select signedness, independent shift-amount width and type conversion.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- sign: unsigned, signed。
- target: scalar, element, part。
- operator: shl, shr, ashr。
- count: zero, last, width, ones, x, z。
- count_width: 8, 65。
- value: known, x, z。

Constraints: Exclude only the rows where last is zero with width 1. The left-hand side is the packed part selection of the isomorphic scale, fixed array element, and width w. The subselection is unsigned regardless of the parent's sign. Count is a signed 8/65 bit variable, and ones is all 1 (in declaration -1), but the shift is unsigned. NBA and the duplication of the compound left-hand side are excluded.

## membership_container / model 1

- The number of combinations satisfying the constraint is 5984.
- Existing and new tests available: 46.
- Short run options: 46.
- The case must be kept separate: 5.
- The plan of the factor 2: 305/305.
- The plan of the factor 3: 174/174.

Observe individual lists, fixed arrays, dynamic arrays and queues, including their elements/sizes, inputs of differing widths/signs, raw membership results, extension, bit conversion and reversed lists to check one-sided wildcards and OR.

- width: 1, 32, 33, 64, 65, 129。
- needle_width: narrow, same, wide。
- needle_sign: unsigned, signed。
- set_sign: unsigned, signed。
- set_state: bit, logic。
- container: list, fixed, dynamic, queue。
- size: 0, 1, 3。
- value: known, lhs_x, rhs_x, rhs_z, both_unknown。

Constraints: The narrow of width 1 is excluded because it is width 0. The empty set is represented only by dynamic arrays and queues, and no individual enumeration of the empty set or fixed arrays of 0 elements are created. The empty set has no value of RHS, so only known/ lhs_x is left. All elements of the set are of the same type and width. The following observations are excluded: range, non‐integer, heterogeneous set element, insertion array, side‐effect formula, and scanning order.

## membership_range / model 1

- The number of combinations satisfying the constraint is 5680.
- Existing and new tests available: 46.
- Short run options: 46.
- The case must be kept separate: 6.
- The plan of the factor 2: 303/303.
- The plan of the factor 3: 178/178.

For closed/reversed ranges, $ endpoints and absolute/relative tolerance ranges, observe stored endpoints, inputs around each endpoint, raw membership results, extension, bit conversion and equivalent relational comparisons to distinguish range comparison from set-value wildcard matching and check tolerance-endpoint swapping and truncation.

- width: 1, 32, 33, 64, 65, 129。
- needle_width: narrow, same, wide。
- needle_sign: unsigned, signed。
- bound_sign: unsigned, signed。
- bound_state: bit, logic。
- form: closed, reversed, low_open, high_open, abs_tol, rel_tol。
- value: known, lhs_x, bound_x, bound_z。
- members: single, mixed。

Constraints: The narrow of width 1 is excluded because it is width 0. 2 3 and 1 1 are the values of the empty range, including X/Z, which are not defined in this paper, and are represented by positive values with the left edge larger than the right edge, regardless of the interpretation of the signedness. The edge points and the set elements are all of the same type and width, and the tolerance is limited to the values not exceeding the range of the type. In the closed segment endpoint X/Z, only the input satisfying the other endpoint is used. The non‐integer, heterogeneous set elements, and formulas with side‐effects are excluded.

## case_inside_selection / model 1

- The number of combinations satisfying the constraint is 8704.
- Existing and new tests available: 34.
- Short run options: 34.
- The case must be kept separate: 7.
- The plan of the factor 2: 315/315.
- The plan of the factor 3: 154/154.

In case inside with a leading item containing values, ranges, fixed arrays or 2 values, observe 4 case-expression sets targeting every item/default, stored item values, selected branches and evaluation counts for the case expression and counted items to check continuation after X comparisons, endpoint extension and unique0 evaluation.

- width: 1, 32, 33, 64, 65, 129。
- expr_width: narrow, same, wide。
- expr_sign: unsigned, signed。
- item_sign: unsigned, signed。
- item_state: bit, logic。
- first: value, range, array, list。
- value: known, expr_x, item_x, item_z。
- qualifier: plain, unique0。
- third: variable, call。

Constraints: The narrow of width 1 is excluded because it is width 0. All items are of the same type and width, and integer literal items are not used. Priority and unique are excluded because the relationship between the violation report and default is not explicitly mentioned in this paper, and only inputs with less than 1 matching items are used in unique0. The number of evaluations of multiple expressions in the item, the order of side effects, and the casez/casex of the case are excluded.

## clocking_input_sampling / model 1

- The number of combinations satisfying the constraint is 864.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 5.
- The plan of the factor 2: 165/165.
- The plan of the factor 3: 72/72.

Use 3 background sets to observe pre-clock and updated values, cb samples/live values and wakeup counts, checking interactions among #1step/#0, blocking/NBA updates, state types, clock direction and local/interface/virtual-modport reference paths. Retain known-value controls for X/Z rows.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- access: local, interface, virtual。
- skew: step, zero。
- edge: posedge, negedge。
- update: blocking, nba。

Constraints: All 864 lines are valid. The update is done at the module-side clock edge, and the observation waits for the cb event. The stimulus was prepared, the initial value was set, and the observation was carried out at different times. The X/Z rows are also contrasted with the known values. This excludes program-derived clock, multiple clock, output skive, inout, iff, and multiple edges at the same time. Do not exclude cases because of unsupported behavior

## assertion_sample_visibility / model 1

- The number of combinations satisfying the constraint is 2592.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 7.
- The plan of the factor 2: 225/225.
- The plan of the factor 3: 96/96.

For known and X/Z values before/after updates, observe assertion pass/fail counts, sampled values, 1-bit expression values, Reactive live values and final values. Cross types, expressions, edges, blocking/NBA updates, update timing and module/interface contexts to distinguish sampling from action execution.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- expression: reduce_or, equal, case_equal。
- edge: posedge, negedge。
- update: blocking, nba。
- timing: before, edge, after。
- home: module, interface。

Constraints: All 2592 lines are valid. A single cycle Boolean property of a single clock, which specifies both pass/fail actions. Initialization, stimulation preparation and final observation were at different times. The X/Z rows also contain a positive and negative contrast of the known values. The program, clocking variable, automatic variable, disable iff, assay control, time calculation and history functions are excluded. The fault is not excluded if the response is not correct.

## container_wait_visibility / model 1

- The number of combinations satisfying the constraint is 1440.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 214/214.
- The plan of the factor 3: 88/88.

Wait on size, first element or both, then observe wakeup times/counts and all elements before/after creation, growth, shrinkage, deletion and same-size replacement of dynamic arrays and queues. Distinguish premature wakeups from unrelated container updates, and check already-true conditions and case-equality waits on converted X/Z values.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- container: dynamic, queue。
- change: create, grow, shrink, clear, replace。
- condition: size, element, both。
- timing: waiting, ready。

Constraints: The create/clear with empty values only uses the size condition and does not create invalid element access. The same size replace is only for the element/both condition, and the condition before the waiting starts is false. The ready line starts waiting after the change. The dynamic array is replaced from the prepared array with new, and the queue is changed with push_front / pop_front /delete/all assignment. The non-coordination is not excluded. Multiple parallel changes, reference arguments, associative arrays, invalid adjectives are excluded.

## class_method_reference / model 1

- The number of combinations satisfying the constraint is 1944.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 202/202.
- The plan of the factor 3: 99/99.

Call 2 derived instances in A/B/A order and observe virtual/nonvirtual bodies and owners, recursive entry/exit formals and properties, return values, counters and guards. Check per-frame input copies, ref/const ref references to the same object and 2-state conversion.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- dispatch: direct, base_virtual, base_nonvirtual。
- kind: function, task。
- mode: input, ref, const_ref。
- depth: 0, 1, 3。

Constraints: The same typedef property and temporary arguments are used, and no type mismatch is created. 2 Calls the derivative instances in the A/B/A order, and distinguishes between virtual/nonvirtual calls through the base handle and direct calls through the derivative handle. Class methods are automatic, depth is finite, and tasks consume no time. const ref Updates the properties of the same entity without writing to itself. The non-coordination is not excluded. Array, parallel, super, time control are not included.

## function_loop_return / model 1

- The number of combinations satisfying the constraint is 864.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 161/161.
- The plan of the factor 3: 120/120.

Return from for/while/repeat at the first non-0 bit and observe the return value, scan count, index sum, tail reachability and side effects after return. With A/B/A calls, also check per-instance state, shared package state, preservation of same-named caller variables and X/Z-to-2-state conversion.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- loop: for, while, repeat。
- stop: head, middle, tail, none。
- scope: local, package。

Constraints: Using input and return values of the same width and state type, the scanning is done from 0 to LSB to less than width. The head/middle/tail of width 1 is kept as a valid boundary condition, which is the same position. The!== 0 is used to stop X/Z and to distinguish the continuation of the scanning by the conversion to bit. The 2 instance is called in A/B/A order, and the individual state of the local and the shared state of the package are observed. No exclusions for unsupported behavior. Recurrence, break/continue, parallel invocation, time control are not included.

## loop_assignment_order / model 1

- The number of combinations satisfying the constraint is 3888.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 246/246.
- The plan of the factor 3: 111/111.

Use multiple assignments inside for/while/repeat to distinguish blocking updates that consume intermediate values from NBA scheduling based on old values. Observe per-iteration values/indices in A/B/A calls and all elements, counters and guards in Active and after NBA to check write order, state conversion and independent module/interface storage.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- loop: for, while, repeat。
- count: 2, 3, 5。
- storage: scalar, same, rotate。
- update: blocking, nba。
- home: module, interface。

Constraints: All of them were legal. The left-hand side of NBA is only static scalar or fixed array elements, and the automatic task computes the right-hand side time and index. The fixed array is [2:4], same is a index 2, and rotate is 2 +(i% 3). Calls from the same process in A/B/A order, and does not place a competing write source. After the observation in active, 1 tick is carried forward and the observation is carried out after NBA is completed. No exclusions for unsupported behavior. NBA with delay, dynamic array, parallel write, modport excluded

## implicit_process_visibility / model 1

- The number of combinations satisfying the constraint is 1728.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 242/242.
- The plan of the factor 3: 96/96.

Observe startup at time 0 from declaration initialization, reevaluation after data/mask changes and function-internal reads, comb defaults and latch retention for 0/X/Z. Change 1 variable at a time to check both instances' outputs/evaluation counts and distinguish extra activations from unrelated noise or self-updates.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- process: comb, latch。
- access: direct, function。
- home: module, interface。
- gate: zero, one, x, z。
- idle: zero, one, hold。

Constraints: Comb will replace the disabled output with zero/one, and only latch will hold. The automatic execution of the time 0 is observed after the declaration initialization of the input is completed. Only the 1 variable of the 1 instance is changed at each stimulus, and both are observed after the 1 tick. The number of evaluations is updated only within a single process, and even incorrect self-reruns stop at 512. The function reads data/mask from the same instance without arguments. No exclusions for unsupported behavior. Data paths with parallel drivers, delay functions, dynamic appendage, and feedback are excluded.

## generate_scope_lookup / model 1

- The number of combinations satisfying the constraint is 576.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 148/148.
- The plan of the factor 3: 68/68.

Read generate elements of 2 instances by hierarchical name and observe selected branches, local declarations, genvar constants, type widths, package constants and continuous-assignment values. Check imports versus explicit qualification, nesting, type/constant shadowing, tracking of X/Z input changes and scope independence.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- access: import, qualified。
- shadow: none, local。
- depth: one, two。
- branch: if, case。

Constraints: All 576 lines are valid. The method uses the hidden wildcard import and local declaration, and does not use the explicit import which collides and is invalid. 2 instances of SELECT are made into 0/1, each of which is made up of 2 generating elements. Only branch 0 declares local WIDTH / ORIGIN / word_t, and increases width 1 and reverses state type. The explicit modification uses the type and constants of the package even if there is a local declaration. No exclusions for unsupported behavior. Dynamic hierarchical adjectives, config, defparam, anonymousgenerate, noted operations are excluded

## default_argument_scope / model 1

- The number of combinations satisfying the constraint is 720.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 159/159.
- The plan of the factor 3: 128/128.

Change default-value sources on every A/B/A hierarchical call and observe both formals, the return value and function evaluation counts at declaration/caller sites. Check omitted/empty/named arguments, evaluation suppression for explicit 0 arguments, call-time binding to declaration scope, type conversion and independent module/interface instances.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- home: module, interface。
- expression: variable, function。
- passing: omitted, empty_data, named_data, explicit_zero, named_both。

Constraints: All 720 lines are valid. The default value is defined in the 2 argument in the form ANSI, using the same type of input and return value. The 2 instance is called from the source and the variable and function of the same name are prepared. The call is performed in A/B/A order, and the default source is updated before each call. The 2 default function only increases the individual counters and does not create stimuli and observations that depend on the order of argument evaluation. No exclusions for unsupported behavior. The class, virtual interface, output/inout /ref, time control, recurrence are excluded.

## event_task_scope / model 1

- The number of combinations satisfying the constraint is 288.
- Existing and new tests available: 13.
- Short run options: 13.
- The case must be kept separate: 6.
- The plan of the factor 2: 109/109.
- The plan of the factor 3: 52/52.

Pass 2 events from separate module/interface instances or a package through input/ref arguments and observe 1/2/3 waiters' times, counts and values. Distinguish nonretention of pre-wait triggers, value visibility at ordinary/NBA wakeups, trigger paths, reverse-order re-waiting, noise and extra activations after completion.

- home: module, interface, package。
- passing: input, ref。
- emitter: direct, task。
- trigger: blocking, nba。
- listeners: 1, 2, 3。
- order: a_b, b_a。
- arrival: early, late。

Constraints: All 288 lines are valid. The static life event is passed to the automatic task in input/ref. The waiting is only @, and it is registered with 1/6 tick after the call. Triggers and observations are placed in separate ticks, and multiple waits update only separate array elements. The NBA to the static stamp is reserved before the trigger, and the observations generated by Active/NBA are distinguished. The following are the examples of the event variables: assignment, comparison, null standby, triggered, wait_order, delayed non-blocking trigger, virtual interface, and lifetime of automatic variables. The differences in the recombinant of input/ref are not checked. No exclusions for unsupported behavior

## continuous_delay_inertial / model 1

- The number of combinations satisfying the constraint is 504.
- Existing and new tests available: 63.
- Short run options: 63.
- The case must be kept separate: 7.
- The plan of the factor 2: 141/141.
- The plan of the factor 3: 129/129.

Use 1/2/3 delay values with 1-wide scalars and vectors of width 2 or greater to observe short-pulse rejection and cancellation of scheduled updates. At every tick, check bit/logic storage, values after inversion, X/Z delay selection, whole-value update times/counts and last-change times.

- width: 1, 2, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- profile: one, two, three。
- pulse: short, long。
- expression: direct, invert。

Constraints: All 504 lines are valid. Scalar nets with widths 1 and above are used, and vector nets with widths 2 and above are used. 1 bit packed vector is excluded. The delay is 5, (7,3), and (7,5,2), and the pulse width 1/10 does not match the delay. After initial stabilization of the 20 tick, each tick is observed in Postponed. The recurrence of short pulses and the re-reservation of known values are performed before the scheduled update. The delay of net declaration, multiple drivers, intensity, SDF, min/typ/max, and delay of unknown values are excluded. No exclusions for unsupported behavior

## port_import_scope / model 1

- The number of combinations satisfying the constraint is 540.
- Existing and new tests available: 39.
- Short run options: 39.
- The case must be kept separate: 6.
- The plan of the factor 2: 158/158.
- The plan of the factor 3: 141/141.

Distinguish input connections and defaults under package wildcard/explicit imports, local declarations and .* / .name / explicit connections. Observe 2 children with 0/all-1 defaults and an independent control scope to check live tracking, shadowing and type conversion.

- width: 1, 32, 33, 64, 65, 129。
- sample_state: bit, logic。
- value: known, x, z。
- import_style: wild, explicit。
- shadow: none, local。
- binding: star, short, named, qualified, zero。

Constraints: The 180 line is excluded because it is invalid in 26.3 and the valid 540 line is targeted. The 4 state wire is the state where all connection types and widths are set and input/output is explicitly specified. bit / logic is the sample type after the stabilization. Each parent has a 2 child with default value 0 / all 1, and the contrast to the other parent scope always uses only wildcard import and *. Do not create another unmodified p reference in a scope that is only..*. Use default_nettype none to prohibit implicit nets. The empty real argument, width conversion, multiple competing packages, and inout/ref are excluded. No exclusions for unsupported behavior

## typed_memory_file / model 1

- The number of combinations satisfying the constraint is 2880.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 248/248.
- The plan of the factor 3: 82/82.

Write bit/logic and enumeration memory files, change the source array, then read into a different index range. Also read independently prepared input files and check element values, out-of-range preservation, declaration direction versus read order and overwriting.

- width: 1, 32, 33, 64, 65, 129。
- source_state: bit, logic。
- kind: plain, enum。
- value: known, x, z。
- format: bin, hex。
- span: all, middle, single。
- declaration: up, down。
- target_state: bit, logic。
- read_order: forward, reverse。

Constraints: The fixed 1 dimension array is used. The reverse order of single is represented in order, because the start/end is the same and equivalent, and the 576 row is reduced to 2880 row. All rows are legal; none are excluded because a simulator lacks support. Update only the 1/3/5 elements from 11 in the source array [2:6], write to 2:6/3:5/4:4, and read to [10:16] or [16:10]. The storage to enum is explicit cast. The unknown values are arranged in nibble units, and the information loss of partial nibble in hex is not mixed. Dynamic/associative array, multidimensional, width conversion, signedness conversion are excluded.

## program_descendant_shutdown / model 1

- The number of combinations satisfying the constraint is 288.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 4.
- The plan of the factor 2: 109/109.
- The plan of the factor 3: 38/38.

Cross natural program termination and direct/task-internal $exit with multiple initial processes and waiting children/grandchildren. Observe progress before termination, cancellation of later writes, wakeups in another program with the same wait condition and implicit termination by the last program.

- finish: natural, exit, task。
- initials: one, two。
- waiting: delay, event, level。
- topology: flat, nested。
- progress: waiting, partial。
- spawn: none, any。
- keepers: one, two。

Constraints: All 288 rows are legal; none are excluded because a simulator lacks support. The main initial of the target program calls either 4 or $exit at the end of the time, and the additional initial ends at 6. The observation point of the child is 5 and the release is 7/8, which distinguishes between the total initial wait of natural termination and the explicit termination. The other program persists until 12/15, and the implicit $finish occurs before the 20 guard of the module. The data width and state type are not incremented by the factor.

## implicit_port_nettype / model 1

- The number of combinations satisfying the constraint is 576.
- Existing and new tests available: 40.
- Short run options: 40.
- The case must be kept separate: 6.
- The plan of the factor 2: 156/156.
- The plan of the factor 3: 72/72.

Omit the net type in ANSI/non-ANSI port declarations and compare parent/child vector/scalar resolved values and widths under default_nettype. Under the same stimulus, compare vector-only explicit wire overrides and a separate module after directive reset to check default-type scope.

- nettype: wire, tri, wand, triand, wor, trior。
- width: 1, 32, 33, 64, 65, 129。
- style: nonansi, ansi。
- override: implicit, wire。
- value: binary, xz。
- reset: wire, resetall。

Constraints: All 576 rows are legal; none are excluded because a simulator lacks support. The 2 drivers of equal strength are used to check wire /tri, wand/triand, and wor/trior. Each alias is kept for the purpose of checking the wording of the instruction and the declaration rules. In contrast to the implicit scalar output, only the vector output can be overwritten by explicit wire. The subsequent module is defined after default_nettype wire or resetall. Incorrect multidrive of none/uwire, pull of tri0 / tri1, charge retention of trireg, intensity difference and delay are excluded. The binary stimulus also has a X due to the competition of wire so all fourstate =yes

## generated_interface_binding / model 1

- The number of combinations satisfying the constraint is 864.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 165/165.
- The plan of the factor 3: 74/74.

Create 2 interfaces of differing widths per generate element and connect the if/case-selected side to whole-interface/modport writers/readers. Observe inversion before bit/logic storage, unselected-side controls, actual widths, identifying tags, bindings and independence of all elements.

- base_width: 1, 32, 33, 64, 65, 129。
- count: 1, 2, 3。
- form: if, case。
- route: a, b。
- access: whole, modport。
- state: bit, logic。
- value: known, x, z。

Constraints: All 864 rows are legal; none are excluded because a simulator lacks support. The width of the generate element i is base width +i, and the maximum bit is 131. 2 interfaces of the same type are placed on each element, and only the selected side is connected to the writer/reader, and the other side is driven as a contrast. The two options of if/case use the same route name. The b-side is stored in the bit/logic type of the interface after the inversion. The 13 known stimuli identify all elements, bit positions, active/guard, and give 3 additional stimuli to X/Z. The improper access to virtual interface, interface array port, clocking, and modport is excluded.

## program_reactive_handoff / model 1

- The number of combinations satisfying the constraint is 1296.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 183/183.
- The plan of the factor 3: 84/84.

Observe before/after completion of a module NBA chain using an early module control and a program running in Reactive. Check continuous/blocking/Re-NBA outputs and captures, type conversion, every stage's value, NBA scheduling counts and capture contexts.

- width: 1, 32, 33, 64, 65, 129。
- source_state: bit, logic。
- value: known, x, z。
- depth: 1, 2, 3。
- update: blocking, nba。
- producer: continuous, blocking, nba。
- operation: direct, invert。

Constraints: All 1296 rows are legal; none are excluded because a simulator lacks support. The NBA chain of the 1/2/3 segment is triggered by the source update of the module. The program output is either a sequence of assignments or blocking/NBA after event waiting. The same expression in the module is quickly compared. The bit position is identified by 16 known stimuli, and the change is guaranteed by giving all 1 immediately before each stimulus of X/Z. The values of each stimulus are separated by 10, and the values and contexts are observed after 1. The results show that the NBA, clocking, multiple write competition, and simultaneous external stimulus to the automatic variables are not considered.

## configuration_generated_shape / model 1

- The number of combinations satisfying the constraint is 1056.
- Existing and new tests available: 41.
- Short run options: 41.
- The case must be kept separate: 6.
- The plan of the factor 2: 213/213.
- The plan of the factor 3: 80/80.

Compare config overrides, W-only reset and reset of all parameters with defaults, instance overrides and defparam. Observe normal-hierarchy parent parameters, config localparam shadowing, generated widths/counts/if-case branches and unaffected siblings.

- base_width: 1, 32, 33, 64, 65, 129。
- prior: default, instance, defparam, both。
- action: set, reset_w, reset_all。
- mode: 0, 1, 2。
- form: if, case。
- rhs: literal, local, parent。
- hierarchy: direct, wrapped。

Constraints: In the total Cartesian product 2592 row, mode/rhs not used in reset is represented by 0 /literal, and the 1536 row is omitted to make 1056 row. All rows are legal; none are excluded because a simulator lacks support. The config sets the W/ MODE of the target in the normal module hierarchy, and the parameters determine the width, number, and branch of the generate. reset_w returns only W, reset_all returns all parameters to default. The reference guard is not covered by config/defparam. RHS is a number, config localparam is a normal parent module parameter only. generate internal config reference, cell substitution, library switching, unknown parameters are excluded

## udp_array_strength / model 1

- The number of combinations satisfying the constraint is 1152.
- Existing and new tests available: 25.
- Short run options: 25.
- The case must be kept separate: 6.
- The plan of the factor 2: 182/182.
- The plan of the factor 3: 80/80.

Distribute vector bits to an array of combinational UDP instances and connect a scalar in common. Compare isolated outputs, outputs with a competing driver and an unnamed single UDP to check strengths, all 4-state input pairs and positional identification.

- width: 1, 32, 33, 64, 65, 129。
- udp: andnot, ornot。
- drive: default, pull, strong_weak, weak_strong。
- contender: weak, pull, strong。
- array_order: down, up。
- port_order: down, up。
- input_mode: scalar, vector。

Constraints: All 1152 lines are valid. Only the combination UDP is used. Both arrays have the same intensity and input, and only one of them competes with a different driver. In the identification stimulus of the known input, all the competing values 0/1 /Z are observed. In the 4 state, the competing side is released to Z in the all input pair. Step UDP Delay %v Hierarchical reference of named array elements Setting to individual elements is excluded. No exclusions for unsupported behavior

## generated_udp_state / model 1

- The number of combinations satisfying the constraint is 864.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 165/165.
- The plan of the factor 3: 68/68.

Use generate to select sequential UDP instances with differing initial values per bit, and sample/retain individual states under common/alternating clocks. Check X/Z storage into bit/logic, all 1 preparation states before unknown inputs, recovery to known values, retention of the other-clock control and its later sampling.

- width: 1, 32, 33, 64, 65, 129。
- storage: bit, logic。
- value: known, x, z。
- edge: rise, fall。
- offset: 0, 1, 2。
- form: if, case。
- clocks: shared, masked。

Constraints: All 864 lines are valid. For each bit of generate, select initial value 0/1 / no initial value by (i+offset)% 3, and contrast to other UDP with one offset initial value. Only the known 0/1 clock is used, and the data update is 1 ns away. Only the target is driven first, and only the guard is driven later. The algorithm takes all 1 before the unknown input and finally recovers to the known value. The primitives of unknown clock, synchronous input change, sequential delay of UDP, drive intensity, and array form are excluded. No exclusions for unsupported behavior

## interface_header_import / model 1

- The number of combinations satisfying the constraint is 1296.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 183/183.
- The plan of the factor 3: 78/78.

Bind parameter defaults, types and package functions through interface-header imports and compare target-only width/tag changes with a guard. Against same-named caller declarations, check bit/logic formal conversion before package-function operations, actual widths and intermediate values.

- width: 1, 32, 33, 64, 65, 129。
- storage: bit, logic。
- value: known, x, z。
- package: a, b。
- imports: wildcard, explicit, export。
- header: ansi, nonansi。
- override: defaults, narrow, wide。

Constraints: All 1296 lines are valid. The import header provides the parameter default value, input type, body type and function. The export path explicitly imports the 5 item in the relay package and exports it, and does not republish unused wildcard candidates. Compares the width/tag overwrite of target only with the default guard. The input is of type logic, and the temporary arguments of the package function are of type bit / logic. The competing import, change of type parameters, modport, virtual interface, and package subroutine that uses time are excluded. No exclusions for unsupported behavior

## mailbox_class_alias / model 1

- The number of combinations satisfying the constraint is 3456.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 9.
- The plan of the factor 2: 245/245.
- The plan of the factor 3: 92/92.

Pass class handles through typed/typeless mailboxes and check FIFO, get/peek, capacity limits, null messages and bidirectional member updates before/after retrieval. Also observe preservation and later updates of another mailbox and empty nonblocking return values.

- width: 1, 32, 33, 64, 65, 129。
- storage: bit, logic。
- value: known, x, z。
- typing: typed, typeless。
- operation: get, try_get, peek, try_peek。
- update: before, after, both。
- capacity: bounded, unbounded。
- tail: object, null。

Constraints: All 3456 lines are valid. Only handles of the same packet type are sent, and type mismatch is excluded. The full/empty verification is done by a non-blocking method, and get/peek is called after storage. The 1 process is a sequential operation, and the order of selection of waiting processes and concurrent execution competitions are excluded. The typeless, 4 state, and null are not excluded for non-support.

## distribution_expression_binding / model 1

- The number of combinations satisfying the constraint is 972.
- Existing and new tests available: 31.
- Short run options: 31.
- The case must be kept separate: 8.
- The plan of the factor 2: 154/154.
- The plan of the factor 3: 81/81.

Compare operator precedence and parentheses, widths and signedness, and dist weights and overlapping items. Make the candidate solution unique and compare value retention after all-zero-weight failure against a separate instance that always succeeds.

- width: 4, 8, 33。
- sign: unsigned, signed。
- operation: add_shift, add_mul, add_rel。
- grouping: implicit, whole, altered。
- weight: each, total。
- layout: singleton, zero, overlap。
- sequence: sat_only, sat_fail_sat, fail_sat_fail。

Constraints: All 972 lines are valid. Define two or three candidate values per width so positive weights leave exactly one solution. Compare default arithmetic/shift/comparison precedence, whole-expression parentheses and parentheses that change grouping. Check singleton items, zero-weight alternatives, and overlap between a zero item and a positive singleton range. Set every weight to zero to make constraints infeasible and observe retention of initial values or the previous solution after failure. A separate object is a control that succeeds every time. Probability ratios and matching random sequences are not required. Separate repeated success from both orders of alternating success and failure. X/Z, real values, randc, default distributions, inheritance, callbacks and concurrent randomize are outside scope. No exclusions for unsupported behavior.

## generate_default_disable / model 1

- The number of combinations satisfying the constraint is 216.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 4.
- The plan of the factor 2: 93/93.
- The plan of the factor 3: 60/60.

Compare default disable iff inheritance, override, name resolution and declaration placement inside generate scopes, including explicit conditions and cancellation by zero. Disable two instances independently before launch, between clocks or by NBA at the final clock, comparing disable effects and success/failure counts with controls.

- form: if, case, loop。
- default: inherit, override。
- shadow: absent, present。
- mode: default, zero, explicit。
- timing: at_start, between, at_end。
- order: before, after。

Constraints: All 216 lines are valid. Compare inherited parent defaults, outer-generate overrides, inner same-name signals, explicit disable conditions and cancellation by zero in child scopes of two generate instances. Each row has 7 phases covering no disable, parent conditions, each instance's local and explicit conditions, and a successful completion. Distinguish conditions before launch, pulses only between clock ticks, and NBA updates on the final clock. Count vacuous passes too; disabled attempts count as neither successes nor failures. X/Z, multiple clocks, nested module declarations, interface/program, explicit disable inside a property, and assertion control are outside scope. No exclusions for unsupported behavior.

## array_reduction_constraint / model 1

- The number of combinations satisfying the constraint is 192.
- Existing and new tests available: 13.
- Short run options: 13.
- The case must be kept separate: 4.
- The plan of the factor 2: 96/96.
- The plan of the factor 3: 40/40.

Alternate unique solutions and contradictions for fixed and dynamic arrays; compare element-type and with-expression reductions, extension before arithmetic, all values and size after failure, and an independent control object.

- width: 4, 8, 33。
- sign: unsigned, signed。
- kind: fixed, dynamic。
- method: sum, product。
- projection: element, wide。
- length: 2, 3。
- sequence: sat_fail_sat, fail_sat_fail。

Constraints: All 192 lines are valid. Per-element constraints make the successful solution unique; only the reduction condition is made contradictory. Use a type endpoint first and 3 or -3 for remaining elements to distinguish element-width results from longint extension before reduction. Dynamic arrays start 1 element larger than required; observe size and value retention after failure. A separate object is a control that succeeds every time. Matching random sequences is not required. All extended arithmetic stays within 64 bits. Empty arrays, X/Z, queues, soft constraints, inheritance, callbacks and concurrent execution are outside scope. No exclusions for unsupported behavior.

## associative_array_queries / model 1

- The number of combinations satisfying the constraint is 216.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 4.
- The plan of the factor 2: 93/93.
- The plan of the factor 3: 54/54.

Across associative-array insertion, overwrite, deletion and reuse, compare the index domain and allocated bounds, query integer conversion, first/last key width and signedness, entry counts and every key/value.

- width: 4, 8, 33。
- sign: unsigned, signed。
- keys: compact, extreme。
- order: ascending, descending, zigzag。
- delete: low, middle, high。
- dimension: implicit, explicit。

Constraints: All 216 lines are valid. Insert 3 distinct known integral keys. Distinguish the index domain from allocated bounds, overwrite from allocation, and single-key deletion from clearing. Query results use the 32-bit signed integer return type. Do not read low/high or first/last output arguments when the array is empty. X/Z keys, string or wildcard indices, multidimensional arrays and concurrent updates are outside scope. No exclusions for unsupported behavior.

## clocking_event_iff / model 1

- The number of combinations satisfying the constraint is 288.
- Existing and new tests available: 12.
- Short run options: 12.
- The case must be kept separate: 4.
- The plan of the factor 2: 109/109.
- The plan of the factor 3: 44/44.

Count iff-qualified clocking events separately from raw edges, checking sampling on accepted edges and sample retention on rejected edges. Cross guard-only changes before/after an edge, a high 1 in 33 bits, input skew and update path; compare clockvar and observer samples.

- width: 1, 8, 33。
- state: bit, logic。
- edge: posedge, negedge。
- skew: step, zero。
- update: blocking, nba。
- guard_shape: scalar, wide_low, wide_high。
- guard_timing: before, after。

Constraints: All 288 lines are valid. Use only known 0/1 guards, including 33-bit guards with a low/high bit set to 1. Warm up the clockvar to known 0 and separate guard-only changes, raw edges and later guard changes in time. Update inputs at module raw edges and capture them in an observer waiting on the cb event. Rejected edges and guard-only changes retain the previous sample. Blocking/NBA paths are controls for the same settled observations after Observed. X/Z, same-slot guard updates, output skew, programs, interface paths, multiple clocks and assertions are outside scope. No exclusions for unsupported behavior.

## class_virtual_interface / model 1

- The number of combinations satisfying the constraint is 192.
- Existing and new tests available: 13.
- Short run options: 13.
- The case must be kept separate: 4.
- The plan of the factor 2: 96/96.
- The plan of the factor 3: 48/48.

Compare class-held virtual-interface bindings under shallow copies and class-handle assignment, checking rebinding and guarded null writes. Check saved references, source/copy bindings, successful-write counts and a guard through method/direct paths and full/modport types.

- width: 1, 8, 33。
- state: bit, logic。
- port: full, modport。
- initial: a, b。
- copy: shallow, alias。
- actor: source, copy。
- access: method, property。

Constraints: All 192 lines are valid. The 3 interfaces have the same type and tags 11/22/33. Use either the full type or one consistent modport type exposing data by ref. Shallow copies have separate virtual-interface variables; handle assignment shares the class object. Rebind either source or copy to the other interface, then null, then the original interface; observe a separately saved reference. Null is handled only by comparisons and guards, with no member dereference or write-count change. Use known values only; bit/logic are equivalence controls. X/Z, type mismatches, abnormal termination from null dereferences, inheritance, clocking, time controls and concurrent drivers are outside scope. No exclusions for unsupported behavior.

## resolved_strength_format / model 1

- The number of combinations satisfying the constraint is 180.
- Existing and new tests available: 31.
- Short run options: 31.
- The case must be kept separate: 4.
- The plan of the factor 2: 87/87.
- The plan of the factor 3: 78/78.

Check resolved logic and strength from 2-driver contention/release and tri0/tri1 pull defaults through 3 format API families. Cross strength asymmetry, update order and polarity, checking overwrite behavior across 11 observations and isolated supply controls.

- net: wire, tri0, tri1。
- strengths: equal_weak, equal_pull, equal_strong, a_stronger, b_stronger。
- order: ab, ba。
- api: display, sformatf, swrite。
- polarity: normal, inverse。

Constraints: All 180 lines are valid. Each of the 2 continuous assignments uses the same single strength for both 0/1 logic values. Drive only known 0/1 and Z; generate X by equal-strength 0/1 contention. Compare released wire with tri0/tri1 pull defaults, separating each write and observation by 1tick. Pass the scalar net directly to the format API at all 11 observations; overwrite string results each time. Separate supply0/supply1 nets provide controls for strength formatting. Ambiguous drive strengths, L/H, numeric strength ranges, trireg, wired logic, vectors, delayed gates, strength propagation through variables and file output are outside scope. No exclusions for unsupported behavior.

## class_array_shallow_copy / model 1

- The number of combinations satisfying the constraint is 240.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 4.
- The plan of the factor 2: 108/108.
- The plan of the factor 3: 60/60.

Compare class shallow copies with handle-assignment controls to distinguish independent array storage from sharing of objects referenced by element handles. Check element replacement, growth/shrinkage through the source or copy, retained element handles, constructor counts and an independent guard.

- container: fixed, dynamic, queue。
- width: 1, 8, 33。
- length: 1, 3。
- position: first, last。
- copy: shallow, alias。
- writer: source, copy。
- operation: element, resize。

Constraints: 240 of the 288 Cartesian rows are legal. Exclude only fixed-array resize because it has no meaning for this level. No rows are excluded for unsupported tool features. Each holder has a bit-vector array and a same-shaped array of class handles. Shallow copies have independent array-element storage while sharing objects referenced by their element handles. Handle assignment is the sharing control; mutate through either the source or the copy. Resize 1 to 3 or 3 to 1, checking the preserved prefix and default values of appended elements. A saved element handle retains its referenced object after replacement or shrinking. First/last positions are equivalence controls for initial length 1. X/Z, empty arrays, inheritance, rand state, covergroup, ref arguments and concurrent execution are outside scope.

## dpi_openarray_shape / model 1

- The number of combinations satisfying the constraint is 168.
- Existing and new tests available: 30.
- Short run options: 30.
- The case must be kept separate: 4.
- The plan of the factor 2: 100/100.
- The plan of the factor 3: 72/72.

Pass fixed arrays, dynamic arrays and queues through open-array DPI formals, checking bounds and every element at each call and copyback on return. Cross argument direction, numerical traversal order, sign patterns and growth/shrinkage between calls; also check that a separate guard array is unchanged.

- actual: ascending, descending, dynamic, queue。
- direction: input, output, inout。
- length: 1, 3, 5。
- pattern: positive, mixed。
- walk: ascending, descending。
- calls: stable, resize。

Constraints: 168 of the 288 Cartesian rows are legal. Exclude dynamic-array/queue actuals for open output formals as forbidden by 7.7; exclude fixed-array resize because it does not match the meaning of this level. No exclusions for unsupported behavior. Use only 1-dimensional open arrays of int elements, resetting every element for each of 2 calls. Resize 1 to 3, 3 to 5 or 5 to 2; compare C bounds and all elements on each call and SV copyback afterward. Do not read the initial value of an output argument. C obtains a pointer for each element on each visit and does not assume contiguous whole-array layout. X/Z, empty arrays, multiple dimensions, sized formals, ref arguments, C reentry and retained handles are outside scope.

## clocking_assertion_sampling / model 1

- The number of combinations satisfying the constraint is 288.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 4.
- The plan of the factor 2: 109/109.
- The plan of the factor 3: 50/50.

Observe default/explicit #1step clocking inputs in assertions at their own event and a later independent clock. Combine updates before or after sampling, blocking/NBA and independent edge polarities. Compare sampled values, Reactive live signals and action counts separately to detect erroneous resampling on the other clock.

- width: 1, 8, 33。
- state: bit, logic。
- sample_edge: posedge, negedge。
- probe_edge: posedge, negedge。
- timing: early, edge, between。
- update: blocking, nba。
- declaration: default, explicit。

Constraints: All 288 lines are valid. Clocking inputs referenced by assertions use only #1step as required by 16.5.1; compare default and explicit declarations. Sampling and evaluation clocks are separate signals, driven at times 8 and 12 in each cycle. Separate updates at times 6/8/10 from reporting at time 14. Compare the same-slot #1step value, Reactive live data and the value retained for a later independent clock. X/Z, illegal non-#1step inputs, output skew, programs, temporal operators, disable iff and simultaneous clocks are outside this model. No exclusions for unsupported behavior.

## constraint_inheritance / model 1

- The number of combinations satisfying the constraint is 96.
- Existing and new tests available: 13.
- Short run options: 13.
- The case must be kept separate: 4.
- The plan of the factor 2: 70/70.
- The plan of the factor 3: 40/40.

Solve inherited constraints through base/derived handles across 3 class levels, comparing same-name replacement, new-name addition, pure implementation and external completion. Alternate a unique solution with a contradiction, checking initial values on first failure, retention after success, and independent success of a separate object.

- handle: base, derived。
- rule: replace, add。
- origin: concrete, pure。
- definition: inline, extern。
- sequence: sat_fail_sat, fail_sat_fail。
- width: 4, 8, 33。

Constraints: All 96 lines are valid. Across 3 inheritance levels, the middle class implements the pure constraint; a same-name leaf constraint replaces its inherited block and a new-name constraint adds a block. Successful solutions are unique and do not depend on random values or search order. A non-rand flag switches between satisfiable constraints and a contradiction; failure retains the initial values or the preceding solution. A separate object, called through the opposite static handle type, serves as a control that succeeds every time. X/Z, randc, soft constraints, constraint_mode, rand_mode and matching RNG sequences are outside the model. No exclusions for unsupported behavior.

## dpi_nba_capture / model 1

- The number of combinations satisfying the constraint is 144.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 4.
- The plan of the factor 2: 81/81.
- The plan of the factor 3: 48/48.

Combine DPI input/output/inout, scheduling the NBA before or after the call, and the same or a different array element. Check width, signedness and bit/logic conversion to int, immediate copyback, changes to indices and values after scheduling, and every element in Postponed and at the next time, to verify NBA value and destination capture.

- direction: input, output, inout。
- order: nba_first, dpi_first。
- actual: same, other。
- width: 8, 32, 65。
- signedness: unsigned, signed。
- state: bit, logic。

Constraints: All 144 lines are valid. Use only statically allocated elements of a fixed-size array. Pass known values to the DPI int formal and observe input width/sign conversion and copyback immediately after return. Order NBA scheduling and the DPI call in one process, then change the indices, right-hand side inputs and original element after scheduling. Do not read the initial value of an output argument. X/Z, open arrays, reentry from C into SV, time-consuming DPI tasks and competing processes are outside this model. No exclusions for unsupported behavior.

## aggregate_event_lifetime / model 1

- The number of combinations satisfying the constraint is 432.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 6.
- The plan of the factor 2: 123/123.
- The plan of the factor 3: 54/54.

Compare aggregate event identity after automatic task return, alias release and delayed registration with independent calls, copied payloads and wake times.

- storage: scalar, struct, nested。
- capture: direct, copy。
- calls: 1, 2, 3。
- release: before_arm, after_arm, after_wake。
- trigger: blocking, nba。
- order: forward, reverse。
- listeners: 1, 2。

Constraints: All 432 lines are valid. Each automatic task owns a fresh event and payload; children wait 2 ticks after the owner returns. Scalar storage is a control; flat and nested structs distinguish member access from whole-structure copying. After copying, rebind the original event to noise and change its payload. Clear the caller alias to null before registration, after registration or after wakeup, while retaining a trigger alias until all wakeups finish. Place registration, release, triggers and observations in separate ticks. Null waits, triggered, GC timing, physical memory reclamation, delayed nonblocking triggers and ref arguments are outside scope. No exclusions for unsupported behavior.

## sv_dpi_array_queries / model 1

- The number of combinations satisfying the constraint is 1152.
- Existing and new tests available: 19.
- Short run options: 19.
- The case must be kept separate: 7.
- The plan of the factor 2: 177/177.
- The plan of the factor 3: 66/66.

Compare SV/DPI-C queries of the same actual through dimension mapping, normalized packed ranges, each dimension range and increment, and shape refresh on every call.

- rank: 1, 2, 3。
- bounds: up, down, mixed。
- origin: neg, pos。
- extent: one, varied。
- width: 4, 33。
- formal: sized, open。
- packed: normal, offset。
- calls: same, switch。
- query: literal, variable。

Constraints: All 1152 lines are valid. Use 1/2/3 fixed unpacked dimensions and a packed dimension of bit; query the same actual through SV and DPI-C. Distinguish normalized and offset ranges of the packed actual. C dimension 0 is the normalized packed range; positive dimensions retain the actual unpacked ranges. The switch case changes actual arguments and ranges; only open packed also changes width between 4 and 33. Sized packed keeps its width. Singleton increment is 1 regardless of direction. Dynamic, queue or empty arrays, X/Z, element values or copyback, sized unpacked, invalid dimensions, C callbacks and retained handles are outside scope. No exclusions for unsupported behavior.

## sdf_conditional_paths / model 1

- The number of combinations satisfying the constraint is 288.
- Existing and new tests available: 18.
- Short run options: 18.
- The case must be kept separate: 7.
- The plan of the factor 2: 109/109.
- The plan of the factor 3: 46/46.

Compare SDF conditions, annotation scope, replacement/addition and rise/fall delays. Use sibling instances and separate outputs as controls; observe values, change counts and last-change times.

- path: plain, cond, else。
- mode: absolute, increment。
- profile: balanced, rise, fall。
- scope: cell, parent。
- target: v, g。
- first: high, low。
- guard: same, opposite。

Constraints: All 288 lines are valid. Annotate IOPATH/COND/CONDELSE 1 time using one SDF file. ABSOLUTE replaces the delay; INCREMENT adds to the default rise/fall delay. Select only one of 2 instances; the other instance and a separate output of each are controls. Change selects 2 ticks before the input transition. All delays are positive even numbers up to 14; input transitions are 20 ticks apart and observations occur 1/3/5/7/9/11/13/15 ticks after each transition. Short pulses, X/Z, edge-qualified paths, equivalent condition expressions, repeated annotations, min/typ/max, timescale conversion, INTERCONNECT and TIMINGCHECK are outside scope. No exclusions for unsupported behavior.

## checker_assertion_sampling / model 1

- The number of combinations satisfying the constraint is 1296.
- Existing and new tests available: 27.
- Short run options: 27.
- The case must be kept separate: 6.
- The plan of the factor 2: 174/174.
- The plan of the factor 3: 63/63.

Compare checker and module reference decisions, sampled values, Reactive values and execution times. Vary connection forms and placement; observe independence of 2 instances and output-argument propagation.

- width: 1, 8, 33。
- home: module, interface。
- connection: positional, named, wildcard。
- timing: before, edge, after。
- update: blocking, nba。
- edge: posedge, negedge。
- clocking: explicit, default。
- predicate: nonzero, zero, parity。

Constraints: All 1296 lines are valid. Place static checkers in 2 module/interface instances and pass the same actuals to separate module reference assertions. Observe only checker output arguments; do not use hierarchical references into checker internals. The 2 clocks occur at 8/12 within each period; update data 2 ticks before, on the clock or 2 ticks after, then observe at 16. Use 6 known-data periods and a complementary second instance. Compare Preponed samples and Reactive action observations. X/Z, procedural checkers, bind, checker procedures, free variables, output NBA, disable iff, multicycle properties, history functions and programs are outside scope. No exclusions for unsupported behavior.

## program_assertion_attempts / model 1

- The number of combinations satisfying the constraint is 648.
- Existing and new tests available: 27.
- Short run options: 27.
- The case must be kept separate: 6.
- The plan of the factor 2: 138/138.
- The plan of the factor 3: 75/75.

Compare each program and module-reference clock attempt using plain predicates and overlapped/nonoverlapped implication. Distinguish vacuous successes from pending attempts, observing decision counts and completion-time sampled-value sums through output arguments.

- width: 1, 8, 33。
- property: plain, overlap, next。
- timing: before, edge, after。
- update: blocking, nba。
- edge: posedge, negedge。
- connection: positional, named, wildcard。
- ticks: 3, 5。

Constraints: All 648 lines are valid. Pass the same inputs to 2 instances each of a program and module reference. Programs have no initial procedures and are never entered through external hierarchical references. Clocks occur at 8/12 in each 20-tick period; inputs update 2 ticks before, on, or 2 ticks after the clock. For plain predicates and overlapped/nonoverlapped implication, compare pass/fail counts including vacuous successes and sums of action-time sampled values at tick 16. Do not count a final next-cycle attempt before it completes. X/Z, disable iff, history functions, program procedures and termination, clocking blocks, checkers, bind, multiclock properties and action controls are outside scope. No exclusions for unsupported behavior.

## container_coverage_sampling / model 1

- The number of combinations satisfying the constraint is 1056.
- Existing and new tests available: 33.
- Short run options: 33.
- The case must be kept separate: 6.
- The plan of the factor 2: 172/172.
- The plan of the factor 3: 79/79.

Sample size and first/last values around array/queue changes; compare live/argument binding, empty guards, hit thresholds and separate target/control bin histories.

- container: fixed, dynamic, queue。
- operation: overwrite, reverse, replace, clear。
- sampling: before, after, both。
- binding: live, arguments。
- position: first, last。
- threshold: 1, 2。
- guard: all, nonempty。
- length: 1, 3。

Constraints: Of 1152 rows, excluding 96 fixed-array clear rows leaves 1056 legal rows. Containers hold known int elements indexed from 0, with initial length 1/3. After a whole-container copy to a same-type control, update only the target through 3 stages. Sample 2 times before, after or on both sides of each change; observe size, first/last value and individual coverpoint percentages after each call. Use -1 for an empty container value without reading an element. The nonempty guard suppresses only empty samples. Compare live references and sample arguments, including at_least 1/2. Fixed-array length and reversal at length 1 are unchanged controls. X/Z, concurrent updates, event-driven sampling, cross bins, type aggregation, ref arguments to get_inst_coverage, start/stop, automatic bins and default/ignore/illegal bins are outside scope. No exclusions for unsupported behavior.

## deferred_disable_reports / model 1

- The number of combinations satisfying the constraint is 720.
- Existing and new tests available: 31.
- Short run options: 31.
- The case must be kept separate: 10.
- The plan of the factor 2: 151/151.
- The plan of the factor 3: 92/92.

Compare disable scope and immature deferred reports with sibling/separate-process controls, input capture and side effects, live action data, ordinary control transfer and retained report history.

- scope: none, assertion, outer, inner, task。
- directive: assert, assume, cover。
- cancel: odd, even。
- predicate: alternating, inverse, positive。
- sibling: before, after。
- argument: variable, function。
- payload: stable, change。

Constraints: All 720 lines are valid. Use observed deferred assert/assume/cover # 0; evaluate the worker every 10 ticks and a separate-process control 2 ticks later, observing after another 1 tick. A label cancels only its target; the outermost worker scope cancels all immature reports of that process. Disabling an inner block or task does not remove reports. Disable on odd/even activations across 3 iterations, observing ordinary control transfer separately from previously reported history. Input arguments capture values on registration; argument-function side effects remain even when a report is cancelled. Read live data in the report function in Reactive. The cancel factor is an equivalent-result control for none. Final/Postponed, always_comb, flush on resumption, multiple activations in one time slot, task outputs/ref arguments, NBA, assertion controls and X/Z are outside scope. No exclusions for unsupported behavior.

## event_rebinding / model 1

- The number of combinations satisfying the constraint is 648.
- Existing and new tests available: 27.
- Short run options: 27.
- The case must be kept separate: 6.
- The plan of the factor 2: 138/138.
- The plan of the factor 3: 69/69.

Rebind static events before task calls, before wait registration and after registration, then check input copies versus ref/direct references, retention of registered waits, multiple and late waiters, independent aliases and values observed in Active/NBA.

- home: module, interface, package。
- passing: direct, input, ref。
- rebind: before_call, before_arm, after_arm。
- trigger: blocking, nba。
- aliases: single, chain。
- order: old_new, new_old。
- listeners: 1, 2, 3。

Constraints: All 648 lines are valid. Using static life events, we separate call at time 2, standby registration at time 4, and recoupling at time 1/3/5. Input copies the handle at call, and ref and direct reference use the value at standby registration. The registered @ waits for the original synchronous object even after re-association. The null is used only for assignment, comparison, and null triggers after all waiting is completed. Waiting for null, triggered, wait_order, automatic event recovery, and the re-association of the same tick and registration competition are excluded. No exclusions for unsupported behavior.

## clocking_named_event / model 1

- The number of combinations satisfying the constraint is 192.
- Existing and new tests available: 24.
- Short run options: 24.
- The case must be kept separate: 6.
- The plan of the factor 2: 100/100.
- The plan of the factor 3: 40/40.

Notify waiters through a named event after clocking input sampling, comparing sampled and live values immediately after notification and after the live signal changes. Cross input skew, edge, update mode, notification mode, listener count and width; also observe spurious wakeups from another event and rearming across repetitions.

- width: 1, 32, 33, 64, 65, 129。
- skew: step, zero。
- edge: posedge, negedge。
- update: blocking, nba。
- trigger: blocking, nba。
- listeners: 1, 2。

Constraints: All 192 lines are valid. Use only known values and notify waiters through a named event after each clock. Change only the live signal on the next tick; observe sampled and live values separately immediately after notification and two ticks later. Trigger a distinct event between periods to detect spurious wakeups. Waiter ordering within a tick, distinguishing notification regions, X/Z, event rebinding, virtual interfaces, output skew and programs are outside scope. No exclusions for unsupported behavior.

## deferred_argument_capture / model 1

- The number of combinations satisfying the constraint is 368.
- Existing and new tests available: 29.
- Short run options: 29.
- The case must be kept separate: 7.
- The plan of the factor 2: 145/145.
- The plan of the factor 3: 71/71.

Compare deferred value and static-reference arguments with registration-time captures, report-time live values and width conversions. Cross functions/tasks, report regions, update modes, widths and signedness, also observing argument-evaluation side effects and execution time.

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- passing: input, constref。
- formal: same, narrow, wide。
- routine: function, task。
- queue: observed, final。
- update: blocking, nba。

Constraints: Use equivalent-type static variables for const ref, restricting formal to same. Exclude narrow at width one because it cannot yield a positive formal width. All remaining rows are legal. Use three known-value frames; capture input arguments at registration and read references and live values at reporting. Final report actions only display and do not write static variables in Postponed. Automatic ref actuals, dynamic actual selection, output arguments, cancellation, flushing and X/Z are outside scope. No exclusions for unsupported behavior.

## generated_enum_navigation / model 1

- The number of combinations satisfying the constraint is 1056.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 181/181.
- The plan of the factor 3: 110/110.

Generate iterations and branches determine enum widths and value tables, observed through signedness, declaration order and next/prev counts. Two starting states and reads after other elements operate and at idle also check independent values and retained copies.

- width: 1, 32, 33, 64, 65, 129。
- sign: unsigned, signed。
- form: if, case。
- encoding: dense, high, descending。
- count: 2, 3。
- method: next, prev。
- step: zero, one, cycle, beyond。

Constraints: Restrict count to two at base width one because its narrowest generated type cannot represent three distinct members. All other rows are legal; none is excluded because of unsupported behavior. Two instances choose opposite branches, each containing two generated elements. Local width adds genvar and the branch value to base width; branch one rotates the declaration-order values by one. Each case starts at both first and last and reads state after other elements operate and again at idle. X/Z members, nonmember values, incompatible assignments, negative counts, config and defparam are outside scope.

## package_nba_capture / model 1

- The number of combinations satisfying the constraint is 1296.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 183/183.
- The plan of the factor 3: 126/126.

Two modules sequentially reserve NBAs on one package variable, crossing reference spellings, array indices, delays and state types. Compare captured values and targets, reservation order, alias reads and retained neighbors/other packages in Active and after NBA updates.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- access: qualified, wildcard, explicit。
- storage: scalar, up, down。
- timing: now, delayed。
- order: a_b, b_a。

Constraints: All rows are legal; none is excluded for unsupported behavior. The same initial thread calls automatic tasks in two modules sequentially, defining NBA reservation order. Targets are static package variables; inputs and indices change after reservation, and updates follow task return. Controls are a probe using another reference spelling, a neighboring element and a same-named variable in another package. Ascending arrays use negative indices; descending arrays use nonzero indices. Ordering of independent concurrent writers, dynamic arrays, real values, nets, force and VPI are outside scope.

## package_change_observers / model 1

- The number of combinations satisfying the constraint is 2592.
- Existing and new tests available: 36.
- Short run options: 36.
- The case must be kept separate: 6.
- The plan of the factor 2: 225/225.
- The plan of the factor 3: 122/122.

Checks multiple event and wait observers of the same package variable and always_comb reading an external reference inside a function. Observes whole-word and least-significant-bit sensitivity, X conditions, notifications and wake history across repeated writes, neighbors and another package.

- width: 1, 32, 33, 64, 65, 129。
- state: bit, logic。
- value: known, x, z。
- access: qualified, wildcard, explicit。
- storage: scalar, up, down。
- update: blocking, nba。
- event: full, lsb。
- wait: logical, case。

Constraints: All rows are legal; none is excluded for unsupported behavior. Initialization at time zero, observer registration at time one and the first change at time five avoid registration races. Two observer modules read the same package variable; the control reads an identically named variable in another package. Events count changes to the whole word or its least significant bit; always_comb follows external references inside a function. A wait using logical or case equality to zero completes once; the current condition and retained wake history are read separately. Checks also cover negative ascending and nonzero descending array indices, repeated writes, neighbors and later control updates. Variable observer indices, classes, dynamic arrays, ordering between independent writers and direct X-to-Z transitions are outside scope.

<a id="入力指紋が一致した実行の確認"></a>

## Verify that the input fingerprint matches the execution.

Each snapshot is evaluated independently. Do not synthesize partial successes of multiple versions and runs. The pass is the only proof of success, and known, unsupported, and stale are not included in the pass. This aggregation is the proportion of combinations that confirmed the agreement with the expected value. The raw reach rate from failed execution is not measured.

### results/ghost.json

- Environment: private build e629cbd964b4.
- Execution timestamp: 2026-11-03T14:27:22.606665+00:00.

- scheduling_visibility:
  - The confirmed combination of the 2 factor: 126/126.
  - The confirmed combination of the 3 factor: 51/51.
  - Individual mandatory cases: No objects.
  - Case statuses: pass=325, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- nba_capture:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 44/44.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- expression_context:
  - The confirmed combination of the 2 factor: 143/143.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 3/3.
  - Case statuses: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_part_select:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- conditional_merge:
  - The confirmed combination of the 2 factor: 185/185.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- shift_context:
  - The confirmed combination of the 2 factor: 298/298.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 4/4.
  - Case statuses: pass=56, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- cast_pipeline:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- task_argument_visibility:
  - The confirmed combination of the 2 factor: 144/144.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- argument_binding_index:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_structure:
  - The confirmed combination of the 2 factor: 186/186.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- case_matching:
  - The confirmed combination of the 2 factor: 220/220.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_connection:
  - The confirmed combination of the 2 factor: 204/204.
  - The confirmed combination of the 3 factor: 56/56.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- unpacked_array_copy:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- bit_vector_queries:
  - The confirmed combination of the 2 factor: 285/285.
  - The confirmed combination of the 3 factor: 108/108.
  - Mandatory case: 4/4.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- streaming_permutation:
  - The confirmed combination of the 2 factor: 182/182.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 4/4.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- comparison_context:
  - The confirmed combination of the 2 factor: 302/302.
  - The confirmed combination of the 3 factor: 174/174.
  - Mandatory case: 4/4.
  - Case statuses: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- array_reduction_pipeline:
  - The confirmed combination of the 2 factor: 261/261.
  - The confirmed combination of the 3 factor: 162/162.
  - Mandatory case: 8/8.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- variable_bit_index:
  - The confirmed combination of the 2 factor: 253/253.
  - The confirmed combination of the 3 factor: 106/106.
  - Mandatory case: 4/4.
  - Case statuses: pass=44, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- queue_update_capacity:
  - The confirmed combination of the 2 factor: 258/258.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 5/5.
  - Case statuses: pass=48, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- queue_element_reference:
  - The confirmed combination of the 2 factor: 257/257.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- division_context:
  - The confirmed combination of the 2 factor: 283/283.
  - The confirmed combination of the 3 factor: 98/98.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dynamic_array_resize:
  - The confirmed combination of the 2 factor: 219/219.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- concatenated_assignment:
  - The confirmed combination of the 2 factor: 265/265.
  - The confirmed combination of the 3 factor: 126/126.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_logical_reduction:
  - The confirmed combination of the 2 factor: 218/218.
  - The confirmed combination of the 3 factor: 142/142.
  - Mandatory case: 6/6.
  - Case statuses: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- logical_short_circuit:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 236/236.
  - Mandatory case: 5/5.
  - Case statuses: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- edge_event_expression:
  - The confirmed combination of the 2 factor: 260/260.
  - The confirmed combination of the 3 factor: 152/152.
  - Mandatory case: 5/5.
  - Case statuses: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_or_iff:
  - The confirmed combination of the 2 factor: 104/104.
  - The confirmed combination of the 3 factor: 59/59.
  - Mandatory case: 4/4.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- heap_file_monitor_context:
  - The confirmed combination of the 2 factor: 40/40.
  - Mandatory case: 3/3.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- compound_shift_target:
  - The confirmed combination of the 2 factor: 308/308.
  - The confirmed combination of the 3 factor: 90/90.
  - Mandatory case: 4/4.
  - Case statuses: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- membership_container:
  - The confirmed combination of the 2 factor: 305/305.
  - The confirmed combination of the 3 factor: 174/174.
  - Mandatory case: 5/5.
  - Case statuses: pass=46, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- membership_range:
  - The confirmed combination of the 2 factor: 303/303.
  - The confirmed combination of the 3 factor: 178/178.
  - Mandatory case: 6/6.
  - Case statuses: pass=46, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- case_inside_selection:
  - The confirmed combination of the 2 factor: 315/315.
  - The confirmed combination of the 3 factor: 154/154.
  - Mandatory case: 7/7.
  - Case statuses: pass=34, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- clocking_input_sampling:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 72/72.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- assertion_sample_visibility:
  - The confirmed combination of the 2 factor: 225/225.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 7/7.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- container_wait_visibility:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 88/88.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_method_reference:
  - The confirmed combination of the 2 factor: 202/202.
  - The confirmed combination of the 3 factor: 99/99.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- function_loop_return:
  - The confirmed combination of the 2 factor: 161/161.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- loop_assignment_order:
  - The confirmed combination of the 2 factor: 246/246.
  - The confirmed combination of the 3 factor: 111/111.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_process_visibility:
  - The confirmed combination of the 2 factor: 242/242.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generate_scope_lookup:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- default_argument_scope:
  - The confirmed combination of the 2 factor: 159/159.
  - The confirmed combination of the 3 factor: 128/128.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_task_scope:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 6/6.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- continuous_delay_inertial:
  - The confirmed combination of the 2 factor: 141/141.
  - The confirmed combination of the 3 factor: 129/129.
  - Mandatory case: 7/7.
  - Case statuses: pass=63, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_import_scope:
  - The confirmed combination of the 2 factor: 158/158.
  - The confirmed combination of the 3 factor: 141/141.
  - Mandatory case: 6/6.
  - Case statuses: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- typed_memory_file:
  - The confirmed combination of the 2 factor: 248/248.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_descendant_shutdown:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 38/38.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_port_nettype:
  - The confirmed combination of the 2 factor: 156/156.
  - The confirmed combination of the 3 factor: 72/72.
  - Mandatory case: 6/6.
  - Case statuses: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_interface_binding:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 74/74.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_reactive_handoff:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 84/84.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- configuration_generated_shape:
  - The confirmed combination of the 2 factor: 207/213.
  - The confirmed combination of the 3 factor: 72/80.
  - Mandatory case: 6/6.
  - Case statuses: pass=37, fail=4, known=0, unsupported=0, stale=0, not_run=0.
- udp_array_strength:
  - The confirmed combination of the 2 factor: 182/182.
  - The confirmed combination of the 3 factor: 80/80.
  - Mandatory case: 6/6.
  - Case statuses: pass=25, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_udp_state:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- interface_header_import:
  - The confirmed combination of the 2 factor: 0/183.
  - The confirmed combination of the 3 factor: 0/78.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=36, known=0, unsupported=0, stale=0, not_run=0.
- mailbox_class_alias:
  - The confirmed combination of the 2 factor: 245/245.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 9/9.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- distribution_expression_binding:
  - The confirmed combination of the 2 factor: 154/154.
  - The confirmed combination of the 3 factor: 81/81.
  - Mandatory case: 8/8.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generate_default_disable:
  - The confirmed combination of the 2 factor: 93/93.
  - The confirmed combination of the 3 factor: 60/60.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- array_reduction_constraint:
  - The confirmed combination of the 2 factor: 50/96.
  - The confirmed combination of the 3 factor: 13/40.
  - Mandatory case: 1/4.
  - Case statuses: pass=4, fail=9, known=0, unsupported=0, stale=0, not_run=0.
- associative_array_queries:
  - The confirmed combination of the 2 factor: 93/93.
  - The confirmed combination of the 3 factor: 54/54.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- clocking_event_iff:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 44/44.
  - Mandatory case: 4/4.
  - Case statuses: pass=12, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_virtual_interface:
  - The confirmed combination of the 2 factor: 96/96.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 4/4.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- resolved_strength_format:
  - The confirmed combination of the 2 factor: 87/87.
  - The confirmed combination of the 3 factor: 78/78.
  - Mandatory case: 4/4.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_array_shallow_copy:
  - The confirmed combination of the 2 factor: 108/108.
  - The confirmed combination of the 3 factor: 60/60.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dpi_openarray_shape:
  - The confirmed combination of the 2 factor: 93/100.
  - The confirmed combination of the 3 factor: 57/72.
  - Mandatory case: 3/4.
  - Case statuses: pass=25, fail=5, known=0, unsupported=0, stale=0, not_run=0.
- clocking_assertion_sampling:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 50/50.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- constraint_inheritance:
  - The confirmed combination of the 2 factor: 70/70.
  - The confirmed combination of the 3 factor: 40/40.
  - Mandatory case: 4/4.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dpi_nba_capture:
  - The confirmed combination of the 2 factor: 55/81.
  - The confirmed combination of the 3 factor: 16/48.
  - Mandatory case: 1/4.
  - Case statuses: pass=6, fail=12, known=0, unsupported=0, stale=0, not_run=0.
- aggregate_event_lifetime:
  - The confirmed combination of the 2 factor: 123/123.
  - The confirmed combination of the 3 factor: 54/54.
  - Mandatory case: 6/6.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- sv_dpi_array_queries:
  - The confirmed combination of the 2 factor: 177/177.
  - The confirmed combination of the 3 factor: 66/66.
  - Mandatory case: 7/7.
  - Case statuses: pass=19, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- sdf_conditional_paths:
  - The confirmed combination of the 2 factor: 82/109.
  - The confirmed combination of the 3 factor: 22/46.
  - Mandatory case: 3/7.
  - Case statuses: pass=6, fail=12, known=0, unsupported=0, stale=0, not_run=0.
- checker_assertion_sampling:
  - The confirmed combination of the 2 factor: 120/174.
  - The confirmed combination of the 3 factor: 30/63.
  - Mandatory case: 1/6.
  - Case statuses: pass=17, fail=10, known=0, unsupported=0, stale=0, not_run=0.
- program_assertion_attempts:
  - The confirmed combination of the 2 factor: 129/138.
  - The confirmed combination of the 3 factor: 54/75.
  - Mandatory case: 4/6.
  - Case statuses: pass=21, fail=6, known=0, unsupported=0, stale=0, not_run=0.
- container_coverage_sampling:
  - The confirmed combination of the 2 factor: 172/172.
  - The confirmed combination of the 3 factor: 79/79.
  - Mandatory case: 6/6.
  - Case statuses: pass=33, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- deferred_disable_reports:
  - The confirmed combination of the 2 factor: 137/151.
  - The confirmed combination of the 3 factor: 76/92.
  - Mandatory case: 8/10.
  - Case statuses: pass=25, fail=6, known=0, unsupported=0, stale=0, not_run=0.
- event_rebinding:
  - The confirmed combination of the 2 factor: 138/138.
  - The confirmed combination of the 3 factor: 69/69.
  - Mandatory case: 6/6.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- clocking_named_event:
  - The confirmed combination of the 2 factor: 100/100.
  - The confirmed combination of the 3 factor: 40/40.
  - Mandatory case: 6/6.
  - Case statuses: pass=24, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- deferred_argument_capture:
  - The confirmed combination of the 2 factor: 145/145.
  - The confirmed combination of the 3 factor: 71/71.
  - Mandatory case: 7/7.
  - Case statuses: pass=29, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_enum_navigation:
  - The confirmed combination of the 2 factor: 0/181.
  - The confirmed combination of the 3 factor: 0/110.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=36, known=0, unsupported=0, stale=0, not_run=0.
- package_nba_capture:
  - The confirmed combination of the 2 factor: 148/183.
  - The confirmed combination of the 3 factor: 65/126.
  - Mandatory case: 2/6.
  - Case statuses: pass=18, fail=18, known=0, unsupported=0, stale=0, not_run=0.
- package_change_observers:
  - The confirmed combination of the 2 factor: 210/225.
  - The confirmed combination of the 3 factor: 93/122.
  - Mandatory case: 3/6.
  - Case statuses: pass=29, fail=7, known=0, unsupported=0, stale=0, not_run=0.

### results/icarus.json

- Environment: Icarus Verilog version 14.0 (devel) (s20260301-802-g61dbc3c2).
- Execution timestamp: 2026-11-03T14:05:52.634278+00:00.

- scheduling_visibility:
  - The confirmed combination of the 2 factor: 126/126.
  - The confirmed combination of the 3 factor: 51/51.
  - Individual mandatory cases: No objects.
  - Case statuses: pass=325, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- nba_capture:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 44/44.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- expression_context:
  - The confirmed combination of the 2 factor: 143/143.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 3/3.
  - Case statuses: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_part_select:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- conditional_merge:
  - The confirmed combination of the 2 factor: 182/185.
  - The confirmed combination of the 3 factor: 71/76.
  - Mandatory case: 2/3.
  - Case statuses: pass=30, fail=0, known=2, unsupported=0, stale=0, not_run=0.
- shift_context:
  - The confirmed combination of the 2 factor: 298/298.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 4/4.
  - Case statuses: pass=56, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- cast_pipeline:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- task_argument_visibility:
  - The confirmed combination of the 2 factor: 126/144.
  - The confirmed combination of the 3 factor: 42/52.
  - Mandatory case: 2/3.
  - Case statuses: pass=30, fail=0, known=6, unsupported=0, stale=0, not_run=0.
- argument_binding_index:
  - The confirmed combination of the 2 factor: 104/162.
  - The confirmed combination of the 3 factor: 27/63.
  - Mandatory case: 1/5.
  - Case statuses: pass=18, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- packed_structure:
  - The confirmed combination of the 2 factor: 186/186.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- case_matching:
  - The confirmed combination of the 2 factor: 220/220.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_connection:
  - The confirmed combination of the 2 factor: 198/204.
  - The confirmed combination of the 3 factor: 52/56.
  - Mandatory case: 3/5.
  - Case statuses: pass=34, fail=0, known=2, unsupported=0, stale=0, not_run=0.
- unpacked_array_copy:
  - The confirmed combination of the 2 factor: 107/148.
  - The confirmed combination of the 3 factor: 30/52.
  - Mandatory case: 1/3.
  - Case statuses: pass=26, fail=0, known=10, unsupported=0, stale=0, not_run=0.
- bit_vector_queries:
  - The confirmed combination of the 2 factor: 285/285.
  - The confirmed combination of the 3 factor: 108/108.
  - Mandatory case: 4/4.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- streaming_permutation:
  - The confirmed combination of the 2 factor: 0/182.
  - The confirmed combination of the 3 factor: 0/68.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- comparison_context:
  - The confirmed combination of the 2 factor: 302/302.
  - The confirmed combination of the 3 factor: 174/174.
  - Mandatory case: 4/4.
  - Case statuses: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- array_reduction_pipeline:
  - The confirmed combination of the 2 factor: 129/261.
  - The confirmed combination of the 3 factor: 34/162.
  - Mandatory case: 0/8.
  - Case statuses: pass=12, fail=0, known=60, unsupported=0, stale=0, not_run=0.
- variable_bit_index:
  - The confirmed combination of the 2 factor: 217/253.
  - The confirmed combination of the 3 factor: 68/106.
  - Mandatory case: 3/4.
  - Case statuses: pass=26, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- queue_update_capacity:
  - The confirmed combination of the 2 factor: 245/258.
  - The confirmed combination of the 3 factor: 100/120.
  - Mandatory case: 4/5.
  - Case statuses: pass=41, fail=0, known=7, unsupported=0, stale=0, not_run=0.
- queue_element_reference:
  - The confirmed combination of the 2 factor: 0/257.
  - The confirmed combination of the 3 factor: 0/96.
  - Mandatory case: 0/5.
  - Case statuses: pass=0, fail=0, known=60, unsupported=0, stale=0, not_run=0.
- division_context:
  - The confirmed combination of the 2 factor: 283/283.
  - The confirmed combination of the 3 factor: 98/98.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dynamic_array_resize:
  - The confirmed combination of the 2 factor: 219/219.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- concatenated_assignment:
  - The confirmed combination of the 2 factor: 244/265.
  - The confirmed combination of the 3 factor: 113/126.
  - Mandatory case: 4/5.
  - Case statuses: pass=66, fail=0, known=6, unsupported=0, stale=0, not_run=0.
- packed_logical_reduction:
  - The confirmed combination of the 2 factor: 218/218.
  - The confirmed combination of the 3 factor: 142/142.
  - Mandatory case: 6/6.
  - Case statuses: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- logical_short_circuit:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 236/236.
  - Mandatory case: 5/5.
  - Case statuses: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- edge_event_expression:
  - The confirmed combination of the 2 factor: 260/260.
  - The confirmed combination of the 3 factor: 152/152.
  - Mandatory case: 5/5.
  - Case statuses: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_or_iff:
  - The confirmed combination of the 2 factor: 0/104.
  - The confirmed combination of the 3 factor: 0/59.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0.
- heap_file_monitor_context:
  - The confirmed combination of the 2 factor: 0/40.
  - Mandatory case: 0/3.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- compound_shift_target:
  - The confirmed combination of the 2 factor: 293/308.
  - The confirmed combination of the 3 factor: 82/90.
  - Mandatory case: 3/4.
  - Case statuses: pass=34, fail=0, known=6, unsupported=0, stale=0, not_run=0.
- membership_container:
  - The confirmed combination of the 2 factor: 0/305.
  - The confirmed combination of the 3 factor: 0/174.
  - Mandatory case: 0/5.
  - Case statuses: pass=0, fail=0, known=46, unsupported=0, stale=0, not_run=0.
- membership_range:
  - The confirmed combination of the 2 factor: 0/303.
  - The confirmed combination of the 3 factor: 0/178.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=46, unsupported=0, stale=0, not_run=0.
- case_inside_selection:
  - The confirmed combination of the 2 factor: 0/315.
  - The confirmed combination of the 3 factor: 0/154.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=34, unsupported=0, stale=0, not_run=0.
- clocking_input_sampling:
  - The confirmed combination of the 2 factor: 0/165.
  - The confirmed combination of the 3 factor: 0/72.
  - Mandatory case: 0/5.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- assertion_sample_visibility:
  - The confirmed combination of the 2 factor: 0/225.
  - The confirmed combination of the 3 factor: 0/96.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- container_wait_visibility:
  - The confirmed combination of the 2 factor: 194/214.
  - The confirmed combination of the 3 factor: 63/88.
  - Mandatory case: 3/6.
  - Case statuses: pass=26, fail=0, known=10, unsupported=0, stale=0, not_run=0.
- class_method_reference:
  - The confirmed combination of the 2 factor: 111/202.
  - The confirmed combination of the 3 factor: 30/99.
  - Mandatory case: 2/6.
  - Case statuses: pass=15, fail=0, known=21, unsupported=0, stale=0, not_run=0.
- function_loop_return:
  - The confirmed combination of the 2 factor: 161/161.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- loop_assignment_order:
  - The confirmed combination of the 2 factor: 246/246.
  - The confirmed combination of the 3 factor: 111/111.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_process_visibility:
  - The confirmed combination of the 2 factor: 242/242.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generate_scope_lookup:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- default_argument_scope:
  - The confirmed combination of the 2 factor: 159/159.
  - The confirmed combination of the 3 factor: 128/128.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_task_scope:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/52.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0.
- continuous_delay_inertial:
  - The confirmed combination of the 2 factor: 134/141.
  - The confirmed combination of the 3 factor: 114/129.
  - Mandatory case: 5/7.
  - Case statuses: pass=57, fail=0, known=6, unsupported=0, stale=0, not_run=0.
- port_import_scope:
  - The confirmed combination of the 2 factor: 158/158.
  - The confirmed combination of the 3 factor: 141/141.
  - Mandatory case: 6/6.
  - Case statuses: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- typed_memory_file:
  - The confirmed combination of the 2 factor: 248/248.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_descendant_shutdown:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/38.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- implicit_port_nettype:
  - The confirmed combination of the 2 factor: 90/156.
  - The confirmed combination of the 3 factor: 28/72.
  - Mandatory case: 2/6.
  - Case statuses: pass=14, fail=0, known=26, unsupported=0, stale=0, not_run=0.
- generated_interface_binding:
  - The confirmed combination of the 2 factor: 0/165.
  - The confirmed combination of the 3 factor: 0/74.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- program_reactive_handoff:
  - The confirmed combination of the 2 factor: 0/183.
  - The confirmed combination of the 3 factor: 0/84.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- configuration_generated_shape:
  - The confirmed combination of the 2 factor: 0/213.
  - The confirmed combination of the 3 factor: 0/80.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=41, unsupported=0, stale=0, not_run=0.
- udp_array_strength:
  - The confirmed combination of the 2 factor: 21/182.
  - The confirmed combination of the 3 factor: 4/80.
  - Mandatory case: 1/6.
  - Case statuses: pass=1, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- generated_udp_state:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- interface_header_import:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 78/78.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- mailbox_class_alias:
  - The confirmed combination of the 2 factor: 0/245.
  - The confirmed combination of the 3 factor: 0/92.
  - Mandatory case: 0/9.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- distribution_expression_binding:
  - The confirmed combination of the 2 factor: 0/154.
  - The confirmed combination of the 3 factor: 0/81.
  - Mandatory case: 0/8.
  - Case statuses: pass=0, fail=0, known=31, unsupported=0, stale=0, not_run=0.
- generate_default_disable:
  - The confirmed combination of the 2 factor: 0/93.
  - The confirmed combination of the 3 factor: 0/60.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- array_reduction_constraint:
  - The confirmed combination of the 2 factor: 0/96.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0.
- associative_array_queries:
  - The confirmed combination of the 2 factor: 0/93.
  - The confirmed combination of the 3 factor: 0/54.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- clocking_event_iff:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/44.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=12, unsupported=0, stale=0, not_run=0.
- class_virtual_interface:
  - The confirmed combination of the 2 factor: 0/96.
  - The confirmed combination of the 3 factor: 0/48.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0.
- resolved_strength_format:
  - The confirmed combination of the 2 factor: 87/87.
  - The confirmed combination of the 3 factor: 78/78.
  - Mandatory case: 4/4.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_array_shallow_copy:
  - The confirmed combination of the 2 factor: 0/108.
  - The confirmed combination of the 3 factor: 0/60.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- dpi_openarray_shape:
  - The confirmed combination of the 2 factor: 0/100.
  - The confirmed combination of the 3 factor: 0/72.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=30, unsupported=0, stale=0, not_run=0.
- clocking_assertion_sampling:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/50.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- constraint_inheritance:
  - The confirmed combination of the 2 factor: 0/70.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0.
- dpi_nba_capture:
  - The confirmed combination of the 2 factor: 0/81.
  - The confirmed combination of the 3 factor: 0/48.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- aggregate_event_lifetime:
  - The confirmed combination of the 2 factor: 0/123.
  - The confirmed combination of the 3 factor: 0/54.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- sv_dpi_array_queries:
  - The confirmed combination of the 2 factor: 0/177.
  - The confirmed combination of the 3 factor: 0/66.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=19, unsupported=0, stale=0, not_run=0.
- sdf_conditional_paths:
  - The confirmed combination of the 2 factor: 51/109.
  - The confirmed combination of the 3 factor: 11/46.
  - Mandatory case: 3/7.
  - Case statuses: pass=3, fail=0, known=15, unsupported=0, stale=0, not_run=0.
- checker_assertion_sampling:
  - The confirmed combination of the 2 factor: 0/174.
  - The confirmed combination of the 3 factor: 0/63.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0.
- program_assertion_attempts:
  - The confirmed combination of the 2 factor: 0/138.
  - The confirmed combination of the 3 factor: 0/75.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0.
- container_coverage_sampling:
  - The confirmed combination of the 2 factor: 0/172.
  - The confirmed combination of the 3 factor: 0/79.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=33, unsupported=0, stale=0, not_run=0.
- deferred_disable_reports:
  - The confirmed combination of the 2 factor: 0/151.
  - The confirmed combination of the 3 factor: 0/92.
  - Mandatory case: 0/10.
  - Case statuses: pass=0, fail=0, known=31, unsupported=0, stale=0, not_run=0.
- event_rebinding:
  - The confirmed combination of the 2 factor: 0/138.
  - The confirmed combination of the 3 factor: 0/69.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0.
- clocking_named_event:
  - The confirmed combination of the 2 factor: 0/100.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- deferred_argument_capture:
  - The confirmed combination of the 2 factor: 0/145.
  - The confirmed combination of the 3 factor: 0/71.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=29, unsupported=0, stale=0, not_run=0.
- generated_enum_navigation:
  - The confirmed combination of the 2 factor: 181/181.
  - The confirmed combination of the 3 factor: 110/110.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- package_nba_capture:
  - The confirmed combination of the 2 factor: 0/183.
  - The confirmed combination of the 3 factor: 0/126.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- package_change_observers:
  - The confirmed combination of the 2 factor: 0/225.
  - The confirmed combination of the 3 factor: 0/122.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.

### results/kirimasim.json

- Environment: kirimasim 0.0.0 (commit d73d8922dfa2), built with GNU 13.3.0.
- Execution timestamp: 2026-11-03T14:14:01.360649+00:00.

- scheduling_visibility:
  - The confirmed combination of the 2 factor: 126/126.
  - The confirmed combination of the 3 factor: 51/51.
  - Individual mandatory cases: No objects.
  - Case statuses: pass=325, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- nba_capture:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 44/44.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- expression_context:
  - The confirmed combination of the 2 factor: 143/143.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 3/3.
  - Case statuses: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_part_select:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- conditional_merge:
  - The confirmed combination of the 2 factor: 185/185.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- shift_context:
  - The confirmed combination of the 2 factor: 298/298.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 4/4.
  - Case statuses: pass=56, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- cast_pipeline:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- task_argument_visibility:
  - The confirmed combination of the 2 factor: 144/144.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- argument_binding_index:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_structure:
  - The confirmed combination of the 2 factor: 186/186.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- case_matching:
  - The confirmed combination of the 2 factor: 220/220.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_connection:
  - The confirmed combination of the 2 factor: 204/204.
  - The confirmed combination of the 3 factor: 56/56.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- unpacked_array_copy:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- bit_vector_queries:
  - The confirmed combination of the 2 factor: 285/285.
  - The confirmed combination of the 3 factor: 108/108.
  - Mandatory case: 4/4.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- streaming_permutation:
  - The confirmed combination of the 2 factor: 182/182.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 4/4.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- comparison_context:
  - The confirmed combination of the 2 factor: 302/302.
  - The confirmed combination of the 3 factor: 174/174.
  - Mandatory case: 4/4.
  - Case statuses: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- array_reduction_pipeline:
  - The confirmed combination of the 2 factor: 261/261.
  - The confirmed combination of the 3 factor: 162/162.
  - Mandatory case: 8/8.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- variable_bit_index:
  - The confirmed combination of the 2 factor: 253/253.
  - The confirmed combination of the 3 factor: 106/106.
  - Mandatory case: 4/4.
  - Case statuses: pass=44, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- queue_update_capacity:
  - The confirmed combination of the 2 factor: 258/258.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 5/5.
  - Case statuses: pass=48, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- queue_element_reference:
  - The confirmed combination of the 2 factor: 257/257.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- division_context:
  - The confirmed combination of the 2 factor: 283/283.
  - The confirmed combination of the 3 factor: 98/98.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dynamic_array_resize:
  - The confirmed combination of the 2 factor: 219/219.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- concatenated_assignment:
  - The confirmed combination of the 2 factor: 265/265.
  - The confirmed combination of the 3 factor: 126/126.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_logical_reduction:
  - The confirmed combination of the 2 factor: 218/218.
  - The confirmed combination of the 3 factor: 142/142.
  - Mandatory case: 6/6.
  - Case statuses: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- logical_short_circuit:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 236/236.
  - Mandatory case: 5/5.
  - Case statuses: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- edge_event_expression:
  - The confirmed combination of the 2 factor: 260/260.
  - The confirmed combination of the 3 factor: 152/152.
  - Mandatory case: 5/5.
  - Case statuses: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_or_iff:
  - The confirmed combination of the 2 factor: 104/104.
  - The confirmed combination of the 3 factor: 59/59.
  - Mandatory case: 4/4.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- heap_file_monitor_context:
  - The confirmed combination of the 2 factor: 40/40.
  - Mandatory case: 3/3.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- compound_shift_target:
  - The confirmed combination of the 2 factor: 308/308.
  - The confirmed combination of the 3 factor: 90/90.
  - Mandatory case: 4/4.
  - Case statuses: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- membership_container:
  - The confirmed combination of the 2 factor: 214/305.
  - The confirmed combination of the 3 factor: 89/174.
  - Mandatory case: 2/5.
  - Case statuses: pass=20, fail=0, known=0, unsupported=26, stale=0, not_run=0.
- membership_range:
  - The confirmed combination of the 2 factor: 252/303.
  - The confirmed combination of the 3 factor: 117/178.
  - Mandatory case: 4/6.
  - Case statuses: pass=30, fail=0, known=0, unsupported=16, stale=0, not_run=0.
- case_inside_selection:
  - The confirmed combination of the 2 factor: 277/315.
  - The confirmed combination of the 3 factor: 120/154.
  - Mandatory case: 4/7.
  - Case statuses: pass=26, fail=0, known=0, unsupported=8, stale=0, not_run=0.
- clocking_input_sampling:
  - The confirmed combination of the 2 factor: 118/165.
  - The confirmed combination of the 3 factor: 38/72.
  - Mandatory case: 2/5.
  - Case statuses: pass=24, fail=0, known=0, unsupported=12, stale=0, not_run=0.
- assertion_sample_visibility:
  - The confirmed combination of the 2 factor: 0/225.
  - The confirmed combination of the 3 factor: 0/96.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0.
- container_wait_visibility:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 88/88.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_method_reference:
  - The confirmed combination of the 2 factor: 135/202.
  - The confirmed combination of the 3 factor: 39/99.
  - Mandatory case: 2/6.
  - Case statuses: pass=18, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- function_loop_return:
  - The confirmed combination of the 2 factor: 161/161.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- loop_assignment_order:
  - The confirmed combination of the 2 factor: 246/246.
  - The confirmed combination of the 3 factor: 111/111.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_process_visibility:
  - The confirmed combination of the 2 factor: 242/242.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generate_scope_lookup:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- default_argument_scope:
  - The confirmed combination of the 2 factor: 159/159.
  - The confirmed combination of the 3 factor: 128/128.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_task_scope:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 6/6.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- continuous_delay_inertial:
  - The confirmed combination of the 2 factor: 141/141.
  - The confirmed combination of the 3 factor: 129/129.
  - Mandatory case: 7/7.
  - Case statuses: pass=63, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_import_scope:
  - The confirmed combination of the 2 factor: 158/158.
  - The confirmed combination of the 3 factor: 141/141.
  - Mandatory case: 6/6.
  - Case statuses: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- typed_memory_file:
  - The confirmed combination of the 2 factor: 248/248.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_descendant_shutdown:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 38/38.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_port_nettype:
  - The confirmed combination of the 2 factor: 156/156.
  - The confirmed combination of the 3 factor: 72/72.
  - Mandatory case: 6/6.
  - Case statuses: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_interface_binding:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 74/74.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_reactive_handoff:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 84/84.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- configuration_generated_shape:
  - The confirmed combination of the 2 factor: 207/213.
  - The confirmed combination of the 3 factor: 72/80.
  - Mandatory case: 6/6.
  - Case statuses: pass=37, fail=4, known=0, unsupported=0, stale=0, not_run=0.
- udp_array_strength:
  - The confirmed combination of the 2 factor: 182/182.
  - The confirmed combination of the 3 factor: 80/80.
  - Mandatory case: 6/6.
  - Case statuses: pass=25, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_udp_state:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- interface_header_import:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 78/78.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- mailbox_class_alias:
  - The confirmed combination of the 2 factor: 0/245.
  - The confirmed combination of the 3 factor: 0/92.
  - Mandatory case: 0/9.
  - Case statuses: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0.
- distribution_expression_binding:
  - The confirmed combination of the 2 factor: 0/154.
  - The confirmed combination of the 3 factor: 0/81.
  - Mandatory case: 0/8.
  - Case statuses: pass=0, fail=0, known=0, unsupported=31, stale=0, not_run=0.
- generate_default_disable:
  - The confirmed combination of the 2 factor: 0/93.
  - The confirmed combination of the 3 factor: 0/60.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- array_reduction_constraint:
  - The confirmed combination of the 2 factor: 0/96.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=13, stale=0, not_run=0.
- associative_array_queries:
  - The confirmed combination of the 2 factor: 0/93.
  - The confirmed combination of the 3 factor: 0/54.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- clocking_event_iff:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/44.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=12, stale=0, not_run=0.
- class_virtual_interface:
  - The confirmed combination of the 2 factor: 0/96.
  - The confirmed combination of the 3 factor: 0/48.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=13, stale=0, not_run=0.
- resolved_strength_format:
  - The confirmed combination of the 2 factor: 87/87.
  - The confirmed combination of the 3 factor: 78/78.
  - Mandatory case: 4/4.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_array_shallow_copy:
  - The confirmed combination of the 2 factor: 67/108.
  - The confirmed combination of the 3 factor: 21/60.
  - Mandatory case: 1/4.
  - Case statuses: pass=6, fail=0, known=0, unsupported=12, stale=0, not_run=0.
- dpi_openarray_shape:
  - The confirmed combination of the 2 factor: 0/100.
  - The confirmed combination of the 3 factor: 0/72.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=30, stale=0, not_run=0.
- clocking_assertion_sampling:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/50.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- constraint_inheritance:
  - The confirmed combination of the 2 factor: 0/70.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=13, stale=0, not_run=0.
- dpi_nba_capture:
  - The confirmed combination of the 2 factor: 0/81.
  - The confirmed combination of the 3 factor: 0/48.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- aggregate_event_lifetime:
  - The confirmed combination of the 2 factor: 0/123.
  - The confirmed combination of the 3 factor: 0/54.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- sv_dpi_array_queries:
  - The confirmed combination of the 2 factor: 0/177.
  - The confirmed combination of the 3 factor: 0/66.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=0, unsupported=19, stale=0, not_run=0.
- sdf_conditional_paths:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/46.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- checker_assertion_sampling:
  - The confirmed combination of the 2 factor: 0/174.
  - The confirmed combination of the 3 factor: 0/63.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=27, stale=0, not_run=0.
- program_assertion_attempts:
  - The confirmed combination of the 2 factor: 0/138.
  - The confirmed combination of the 3 factor: 0/75.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=27, stale=0, not_run=0.
- container_coverage_sampling:
  - The confirmed combination of the 2 factor: 0/172.
  - The confirmed combination of the 3 factor: 0/79.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=33, stale=0, not_run=0.
- deferred_disable_reports:
  - The confirmed combination of the 2 factor: 151/151.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 10/10.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_rebinding:
  - The confirmed combination of the 2 factor: 0/138.
  - The confirmed combination of the 3 factor: 0/69.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=27, stale=0, not_run=0.
- clocking_named_event:
  - The confirmed combination of the 2 factor: 78/100.
  - The confirmed combination of the 3 factor: 22/40.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=0, unsupported=12, stale=0, not_run=0.
- deferred_argument_capture:
  - The confirmed combination of the 2 factor: 145/145.
  - The confirmed combination of the 3 factor: 71/71.
  - Mandatory case: 7/7.
  - Case statuses: pass=29, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_enum_navigation:
  - The confirmed combination of the 2 factor: 181/181.
  - The confirmed combination of the 3 factor: 110/110.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- package_nba_capture:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 126/126.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- package_change_observers:
  - The confirmed combination of the 2 factor: 225/225.
  - The confirmed combination of the 3 factor: 122/122.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.

### results/lyra.json

- Environment: Lyra (commit fff84e924071).
- Execution timestamp: 2026-11-03T16:13:07.422811+00:00.

- scheduling_visibility:
  - The confirmed combination of the 2 factor: 111/126.
  - The confirmed combination of the 3 factor: 36/51.
  - Individual mandatory cases: No objects.
  - Case statuses: pass=226, fail=3, known=0, unsupported=96, stale=0, not_run=0.
- nba_capture:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 44/44.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- expression_context:
  - The confirmed combination of the 2 factor: 143/143.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 3/3.
  - Case statuses: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_part_select:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- conditional_merge:
  - The confirmed combination of the 2 factor: 185/185.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- shift_context:
  - The confirmed combination of the 2 factor: 298/298.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 4/4.
  - Case statuses: pass=56, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- cast_pipeline:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 76/76.
  - Mandatory case: 3/3.
  - Case statuses: pass=32, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- task_argument_visibility:
  - The confirmed combination of the 2 factor: 144/144.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- argument_binding_index:
  - The confirmed combination of the 2 factor: 162/162.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_structure:
  - The confirmed combination of the 2 factor: 186/186.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- case_matching:
  - The confirmed combination of the 2 factor: 220/220.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_connection:
  - The confirmed combination of the 2 factor: 204/204.
  - The confirmed combination of the 3 factor: 56/56.
  - Mandatory case: 5/5.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- unpacked_array_copy:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 3/3.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- bit_vector_queries:
  - The confirmed combination of the 2 factor: 285/285.
  - The confirmed combination of the 3 factor: 108/108.
  - Mandatory case: 4/4.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- streaming_permutation:
  - The confirmed combination of the 2 factor: 178/182.
  - The confirmed combination of the 3 factor: 62/68.
  - Mandatory case: 2/4.
  - Case statuses: pass=34, fail=2, known=0, unsupported=0, stale=0, not_run=0.
- comparison_context:
  - The confirmed combination of the 2 factor: 302/302.
  - The confirmed combination of the 3 factor: 174/174.
  - Mandatory case: 4/4.
  - Case statuses: pass=100, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- array_reduction_pipeline:
  - The confirmed combination of the 2 factor: 261/261.
  - The confirmed combination of the 3 factor: 162/162.
  - Mandatory case: 8/8.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- variable_bit_index:
  - The confirmed combination of the 2 factor: 253/253.
  - The confirmed combination of the 3 factor: 106/106.
  - Mandatory case: 4/4.
  - Case statuses: pass=44, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- queue_update_capacity:
  - The confirmed combination of the 2 factor: 258/258.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 5/5.
  - Case statuses: pass=48, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- queue_element_reference:
  - The confirmed combination of the 2 factor: 257/257.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=60, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- division_context:
  - The confirmed combination of the 2 factor: 283/283.
  - The confirmed combination of the 3 factor: 98/98.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dynamic_array_resize:
  - The confirmed combination of the 2 factor: 219/219.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 5/5.
  - Case statuses: pass=38, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- concatenated_assignment:
  - The confirmed combination of the 2 factor: 265/265.
  - The confirmed combination of the 3 factor: 126/126.
  - Mandatory case: 5/5.
  - Case statuses: pass=72, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_logical_reduction:
  - The confirmed combination of the 2 factor: 218/218.
  - The confirmed combination of the 3 factor: 142/142.
  - Mandatory case: 6/6.
  - Case statuses: pass=70, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- logical_short_circuit:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 236/236.
  - Mandatory case: 5/5.
  - Case statuses: pass=92, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- edge_event_expression:
  - The confirmed combination of the 2 factor: 260/260.
  - The confirmed combination of the 3 factor: 152/152.
  - Mandatory case: 5/5.
  - Case statuses: pass=64, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_or_iff:
  - The confirmed combination of the 2 factor: 104/104.
  - The confirmed combination of the 3 factor: 59/59.
  - Mandatory case: 4/4.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- heap_file_monitor_context:
  - The confirmed combination of the 2 factor: 0/40.
  - Mandatory case: 0/3.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- compound_shift_target:
  - The confirmed combination of the 2 factor: 308/308.
  - The confirmed combination of the 3 factor: 90/90.
  - Mandatory case: 4/4.
  - Case statuses: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- membership_container:
  - The confirmed combination of the 2 factor: 302/305.
  - The confirmed combination of the 3 factor: 164/174.
  - Mandatory case: 4/5.
  - Case statuses: pass=44, fail=2, known=0, unsupported=0, stale=0, not_run=0.
- membership_range:
  - The confirmed combination of the 2 factor: 252/303.
  - The confirmed combination of the 3 factor: 117/178.
  - Mandatory case: 4/6.
  - Case statuses: pass=30, fail=0, known=0, unsupported=16, stale=0, not_run=0.
- case_inside_selection:
  - The confirmed combination of the 2 factor: 314/315.
  - The confirmed combination of the 3 factor: 149/154.
  - Mandatory case: 6/7.
  - Case statuses: pass=33, fail=1, known=0, unsupported=0, stale=0, not_run=0.
- clocking_input_sampling:
  - The confirmed combination of the 2 factor: 0/165.
  - The confirmed combination of the 3 factor: 0/72.
  - Mandatory case: 0/5.
  - Case statuses: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0.
- assertion_sample_visibility:
  - The confirmed combination of the 2 factor: 225/225.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 7/7.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- container_wait_visibility:
  - The confirmed combination of the 2 factor: 214/214.
  - The confirmed combination of the 3 factor: 88/88.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- class_method_reference:
  - The confirmed combination of the 2 factor: 202/202.
  - The confirmed combination of the 3 factor: 99/99.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- function_loop_return:
  - The confirmed combination of the 2 factor: 161/161.
  - The confirmed combination of the 3 factor: 120/120.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- loop_assignment_order:
  - The confirmed combination of the 2 factor: 246/246.
  - The confirmed combination of the 3 factor: 111/111.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_process_visibility:
  - The confirmed combination of the 2 factor: 242/242.
  - The confirmed combination of the 3 factor: 96/96.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generate_scope_lookup:
  - The confirmed combination of the 2 factor: 148/148.
  - The confirmed combination of the 3 factor: 68/68.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- default_argument_scope:
  - The confirmed combination of the 2 factor: 159/159.
  - The confirmed combination of the 3 factor: 128/128.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_task_scope:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 52/52.
  - Mandatory case: 6/6.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- continuous_delay_inertial:
  - The confirmed combination of the 2 factor: 141/141.
  - The confirmed combination of the 3 factor: 129/129.
  - Mandatory case: 7/7.
  - Case statuses: pass=63, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- port_import_scope:
  - The confirmed combination of the 2 factor: 158/158.
  - The confirmed combination of the 3 factor: 141/141.
  - Mandatory case: 6/6.
  - Case statuses: pass=39, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- typed_memory_file:
  - The confirmed combination of the 2 factor: 248/248.
  - The confirmed combination of the 3 factor: 82/82.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_descendant_shutdown:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 38/38.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- implicit_port_nettype:
  - The confirmed combination of the 2 factor: 156/156.
  - The confirmed combination of the 3 factor: 72/72.
  - Mandatory case: 6/6.
  - Case statuses: pass=40, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_interface_binding:
  - The confirmed combination of the 2 factor: 165/165.
  - The confirmed combination of the 3 factor: 74/74.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- program_reactive_handoff:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 84/84.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- configuration_generated_shape:
  - The confirmed combination of the 2 factor: 77/213.
  - The confirmed combination of the 3 factor: 23/80.
  - Mandatory case: 0/6.
  - Case statuses: pass=11, fail=30, known=0, unsupported=0, stale=0, not_run=0.
- udp_array_strength:
  - The confirmed combination of the 2 factor: 0/182.
  - The confirmed combination of the 3 factor: 0/80.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=25, known=0, unsupported=0, stale=0, not_run=0.
- generated_udp_state:
  - The confirmed combination of the 2 factor: 0/165.
  - The confirmed combination of the 3 factor: 0/68.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=36, stale=0, not_run=0.
- interface_header_import:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 78/78.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- mailbox_class_alias:
  - The confirmed combination of the 2 factor: 245/245.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 9/9.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- distribution_expression_binding:
  - The confirmed combination of the 2 factor: 154/154.
  - The confirmed combination of the 3 factor: 81/81.
  - Mandatory case: 8/8.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generate_default_disable:
  - The confirmed combination of the 2 factor: 93/93.
  - The confirmed combination of the 3 factor: 60/60.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- array_reduction_constraint:
  - The confirmed combination of the 2 factor: 96/96.
  - The confirmed combination of the 3 factor: 40/40.
  - Mandatory case: 4/4.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- associative_array_queries:
  - The confirmed combination of the 2 factor: 77/93.
  - The confirmed combination of the 3 factor: 32/54.
  - Mandatory case: 3/4.
  - Case statuses: pass=8, fail=10, known=0, unsupported=0, stale=0, not_run=0.
- clocking_event_iff:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/44.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=12, stale=0, not_run=0.
- class_virtual_interface:
  - The confirmed combination of the 2 factor: 76/96.
  - The confirmed combination of the 3 factor: 25/48.
  - Mandatory case: 2/4.
  - Case statuses: pass=7, fail=0, known=0, unsupported=6, stale=0, not_run=0.
- resolved_strength_format:
  - The confirmed combination of the 2 factor: 0/87.
  - The confirmed combination of the 3 factor: 0/78.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=31, stale=0, not_run=0.
- class_array_shallow_copy:
  - The confirmed combination of the 2 factor: 83/108.
  - The confirmed combination of the 3 factor: 32/60.
  - Mandatory case: 1/4.
  - Case statuses: pass=9, fail=0, known=0, unsupported=9, stale=0, not_run=0.
- dpi_openarray_shape:
  - The confirmed combination of the 2 factor: 0/100.
  - The confirmed combination of the 3 factor: 0/72.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=24, known=0, unsupported=6, stale=0, not_run=0.
- clocking_assertion_sampling:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/50.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- constraint_inheritance:
  - The confirmed combination of the 2 factor: 70/70.
  - The confirmed combination of the 3 factor: 40/40.
  - Mandatory case: 4/4.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dpi_nba_capture:
  - The confirmed combination of the 2 factor: 81/81.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- aggregate_event_lifetime:
  - The confirmed combination of the 2 factor: 123/123.
  - The confirmed combination of the 3 factor: 54/54.
  - Mandatory case: 6/6.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- sv_dpi_array_queries:
  - The confirmed combination of the 2 factor: 151/177.
  - The confirmed combination of the 3 factor: 42/66.
  - Mandatory case: 5/7.
  - Case statuses: pass=10, fail=9, known=0, unsupported=0, stale=0, not_run=0.
- sdf_conditional_paths:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/46.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=0, unsupported=18, stale=0, not_run=0.
- checker_assertion_sampling:
  - The confirmed combination of the 2 factor: 0/174.
  - The confirmed combination of the 3 factor: 0/63.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=27, stale=0, not_run=0.
- program_assertion_attempts:
  - The confirmed combination of the 2 factor: 138/138.
  - The confirmed combination of the 3 factor: 75/75.
  - Mandatory case: 6/6.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- container_coverage_sampling:
  - The confirmed combination of the 2 factor: 172/172.
  - The confirmed combination of the 3 factor: 79/79.
  - Mandatory case: 6/6.
  - Case statuses: pass=33, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- deferred_disable_reports:
  - The confirmed combination of the 2 factor: 151/151.
  - The confirmed combination of the 3 factor: 92/92.
  - Mandatory case: 10/10.
  - Case statuses: pass=31, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- event_rebinding:
  - The confirmed combination of the 2 factor: 138/138.
  - The confirmed combination of the 3 factor: 69/69.
  - Mandatory case: 6/6.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- clocking_named_event:
  - The confirmed combination of the 2 factor: 0/100.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=0, unsupported=24, stale=0, not_run=0.
- deferred_argument_capture:
  - The confirmed combination of the 2 factor: 145/145.
  - The confirmed combination of the 3 factor: 71/71.
  - Mandatory case: 7/7.
  - Case statuses: pass=29, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- generated_enum_navigation:
  - The confirmed combination of the 2 factor: 181/181.
  - The confirmed combination of the 3 factor: 110/110.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- package_nba_capture:
  - The confirmed combination of the 2 factor: 183/183.
  - The confirmed combination of the 3 factor: 126/126.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- package_change_observers:
  - The confirmed combination of the 2 factor: 225/225.
  - The confirmed combination of the 3 factor: 122/122.
  - Mandatory case: 6/6.
  - Case statuses: pass=36, fail=0, known=0, unsupported=0, stale=0, not_run=0.

### results/verilator.json

- Environment: Verilator 5.055 devel rev v5.054-46-ga9e5a51f.
- Execution timestamp: 2026-11-03T14:37:38.651336+00:00.

- scheduling_visibility:
  - The confirmed combination of the 2 factor: 126/126.
  - The confirmed combination of the 3 factor: 48/51.
  - Individual mandatory cases: No objects.
  - Case statuses: pass=300, fail=0, known=25, unsupported=0, stale=0, not_run=0.
- nba_capture:
  - The confirmed combination of the 2 factor: 104/162.
  - The confirmed combination of the 3 factor: 18/44.
  - Mandatory case: 0/3.
  - Case statuses: pass=13, fail=0, known=23, unsupported=0, stale=0, not_run=0.
- expression_context:
  - The confirmed combination of the 2 factor: 143/143.
  - The confirmed combination of the 3 factor: 63/63.
  - Mandatory case: 3/3.
  - Case statuses: pass=51, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- packed_part_select:
  - The confirmed combination of the 2 factor: 129/162.
  - The confirmed combination of the 3 factor: 28/48.
  - Mandatory case: 1/3.
  - Case statuses: pass=20, fail=0, known=16, unsupported=0, stale=0, not_run=0.
- conditional_merge:
  - The confirmed combination of the 2 factor: 122/185.
  - The confirmed combination of the 3 factor: 31/76.
  - Mandatory case: 0/3.
  - Case statuses: pass=12, fail=0, known=20, unsupported=0, stale=0, not_run=0.
- shift_context:
  - The confirmed combination of the 2 factor: 166/298.
  - The confirmed combination of the 3 factor: 34/92.
  - Mandatory case: 2/4.
  - Case statuses: pass=23, fail=0, known=33, unsupported=0, stale=0, not_run=0.
- cast_pipeline:
  - The confirmed combination of the 2 factor: 131/214.
  - The confirmed combination of the 3 factor: 32/76.
  - Mandatory case: 1/3.
  - Case statuses: pass=12, fail=0, known=20, unsupported=0, stale=0, not_run=0.
- task_argument_visibility:
  - The confirmed combination of the 2 factor: 121/144.
  - The confirmed combination of the 3 factor: 32/52.
  - Mandatory case: 1/3.
  - Case statuses: pass=21, fail=0, known=15, unsupported=0, stale=0, not_run=0.
- argument_binding_index:
  - The confirmed combination of the 2 factor: 75/162.
  - The confirmed combination of the 3 factor: 15/63.
  - Mandatory case: 2/5.
  - Case statuses: pass=8, fail=0, known=28, unsupported=0, stale=0, not_run=0.
- packed_structure:
  - The confirmed combination of the 2 factor: 133/186.
  - The confirmed combination of the 3 factor: 24/52.
  - Mandatory case: 0/3.
  - Case statuses: pass=13, fail=0, known=23, unsupported=0, stale=0, not_run=0.
- case_matching:
  - The confirmed combination of the 2 factor: 81/220.
  - The confirmed combination of the 3 factor: 18/82.
  - Mandatory case: 1/3.
  - Case statuses: pass=6, fail=0, known=30, unsupported=0, stale=0, not_run=0.
- port_connection:
  - The confirmed combination of the 2 factor: 133/204.
  - The confirmed combination of the 3 factor: 24/56.
  - Mandatory case: 2/5.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- unpacked_array_copy:
  - The confirmed combination of the 2 factor: 95/148.
  - The confirmed combination of the 3 factor: 21/52.
  - Mandatory case: 1/3.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- bit_vector_queries:
  - The confirmed combination of the 2 factor: 140/285.
  - The confirmed combination of the 3 factor: 34/108.
  - Mandatory case: 1/4.
  - Case statuses: pass=18, fail=0, known=42, unsupported=0, stale=0, not_run=0.
- streaming_permutation:
  - The confirmed combination of the 2 factor: 105/182.
  - The confirmed combination of the 3 factor: 22/68.
  - Mandatory case: 0/4.
  - Case statuses: pass=11, fail=0, known=25, unsupported=0, stale=0, not_run=0.
- comparison_context:
  - The confirmed combination of the 2 factor: 117/302.
  - The confirmed combination of the 3 factor: 42/174.
  - Mandatory case: 1/4.
  - Case statuses: pass=16, fail=0, known=84, unsupported=0, stale=0, not_run=0.
- array_reduction_pipeline:
  - The confirmed combination of the 2 factor: 187/261.
  - The confirmed combination of the 3 factor: 58/162.
  - Mandatory case: 3/8.
  - Case statuses: pass=23, fail=0, known=49, unsupported=0, stale=0, not_run=0.
- variable_bit_index:
  - The confirmed combination of the 2 factor: 109/253.
  - The confirmed combination of the 3 factor: 24/106.
  - Mandatory case: 1/4.
  - Case statuses: pass=9, fail=0, known=35, unsupported=0, stale=0, not_run=0.
- queue_update_capacity:
  - The confirmed combination of the 2 factor: 141/258.
  - The confirmed combination of the 3 factor: 35/120.
  - Mandatory case: 0/5.
  - Case statuses: pass=17, fail=0, known=31, unsupported=0, stale=0, not_run=0.
- queue_element_reference:
  - The confirmed combination of the 2 factor: 135/257.
  - The confirmed combination of the 3 factor: 30/96.
  - Mandatory case: 3/5.
  - Case statuses: pass=20, fail=0, known=40, unsupported=0, stale=0, not_run=0.
- division_context:
  - The confirmed combination of the 2 factor: 142/283.
  - The confirmed combination of the 3 factor: 21/98.
  - Mandatory case: 4/5.
  - Case statuses: pass=12, fail=0, known=60, unsupported=0, stale=0, not_run=0.
- dynamic_array_resize:
  - The confirmed combination of the 2 factor: 116/219.
  - The confirmed combination of the 3 factor: 30/96.
  - Mandatory case: 1/5.
  - Case statuses: pass=11, fail=0, known=27, unsupported=0, stale=0, not_run=0.
- concatenated_assignment:
  - The confirmed combination of the 2 factor: 181/265.
  - The confirmed combination of the 3 factor: 48/126.
  - Mandatory case: 3/5.
  - Case statuses: pass=24, fail=0, known=48, unsupported=0, stale=0, not_run=0.
- packed_logical_reduction:
  - The confirmed combination of the 2 factor: 146/218.
  - The confirmed combination of the 3 factor: 72/142.
  - Mandatory case: 2/6.
  - Case statuses: pass=36, fail=0, known=34, unsupported=0, stale=0, not_run=0.
- logical_short_circuit:
  - The confirmed combination of the 2 factor: 123/214.
  - The confirmed combination of the 3 factor: 74/236.
  - Mandatory case: 0/5.
  - Case statuses: pass=32, fail=0, known=60, unsupported=0, stale=0, not_run=0.
- edge_event_expression:
  - The confirmed combination of the 2 factor: 130/260.
  - The confirmed combination of the 3 factor: 41/152.
  - Mandatory case: 1/5.
  - Case statuses: pass=16, fail=0, known=48, unsupported=0, stale=0, not_run=0.
- event_or_iff:
  - The confirmed combination of the 2 factor: 71/104.
  - The confirmed combination of the 3 factor: 26/59.
  - Mandatory case: 2/4.
  - Case statuses: pass=9, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- heap_file_monitor_context:
  - The confirmed combination of the 2 factor: 0/40.
  - Mandatory case: 0/3.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- compound_shift_target:
  - The confirmed combination of the 2 factor: 157/308.
  - The confirmed combination of the 3 factor: 28/90.
  - Mandatory case: 1/4.
  - Case statuses: pass=10, fail=0, known=30, unsupported=0, stale=0, not_run=0.
- membership_container:
  - The confirmed combination of the 2 factor: 95/305.
  - The confirmed combination of the 3 factor: 19/174.
  - Mandatory case: 0/5.
  - Case statuses: pass=6, fail=0, known=40, unsupported=0, stale=0, not_run=0.
- membership_range:
  - The confirmed combination of the 2 factor: 108/303.
  - The confirmed combination of the 3 factor: 25/178.
  - Mandatory case: 1/6.
  - Case statuses: pass=7, fail=0, known=39, unsupported=0, stale=0, not_run=0.
- case_inside_selection:
  - The confirmed combination of the 2 factor: 128/315.
  - The confirmed combination of the 3 factor: 27/154.
  - Mandatory case: 0/7.
  - Case statuses: pass=5, fail=0, known=29, unsupported=0, stale=0, not_run=0.
- clocking_input_sampling:
  - The confirmed combination of the 2 factor: 109/165.
  - The confirmed combination of the 3 factor: 29/72.
  - Mandatory case: 2/5.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- assertion_sample_visibility:
  - The confirmed combination of the 2 factor: 133/225.
  - The confirmed combination of the 3 factor: 34/96.
  - Mandatory case: 3/7.
  - Case statuses: pass=11, fail=0, known=25, unsupported=0, stale=0, not_run=0.
- container_wait_visibility:
  - The confirmed combination of the 2 factor: 126/214.
  - The confirmed combination of the 3 factor: 36/88.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- class_method_reference:
  - The confirmed combination of the 2 factor: 130/202.
  - The confirmed combination of the 3 factor: 43/99.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- function_loop_return:
  - The confirmed combination of the 2 factor: 102/161.
  - The confirmed combination of the 3 factor: 44/120.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- loop_assignment_order:
  - The confirmed combination of the 2 factor: 160/246.
  - The confirmed combination of the 3 factor: 46/111.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- implicit_process_visibility:
  - The confirmed combination of the 2 factor: 0/242.
  - The confirmed combination of the 3 factor: 0/96.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- generate_scope_lookup:
  - The confirmed combination of the 2 factor: 90/148.
  - The confirmed combination of the 3 factor: 30/68.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- default_argument_scope:
  - The confirmed combination of the 2 factor: 100/159.
  - The confirmed combination of the 3 factor: 47/128.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- event_task_scope:
  - The confirmed combination of the 2 factor: 79/109.
  - The confirmed combination of the 3 factor: 27/52.
  - Mandatory case: 3/6.
  - Case statuses: pass=6, fail=0, known=7, unsupported=0, stale=0, not_run=0.
- continuous_delay_inertial:
  - The confirmed combination of the 2 factor: 90/141.
  - The confirmed combination of the 3 factor: 41/129.
  - Mandatory case: 2/7.
  - Case statuses: pass=17, fail=0, known=46, unsupported=0, stale=0, not_run=0.
- port_import_scope:
  - The confirmed combination of the 2 factor: 0/158.
  - The confirmed combination of the 3 factor: 0/141.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=39, unsupported=0, stale=0, not_run=0.
- typed_memory_file:
  - The confirmed combination of the 2 factor: 161/248.
  - The confirmed combination of the 3 factor: 32/82.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- program_descendant_shutdown:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/38.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- implicit_port_nettype:
  - The confirmed combination of the 2 factor: 0/156.
  - The confirmed combination of the 3 factor: 0/72.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=40, unsupported=0, stale=0, not_run=0.
- generated_interface_binding:
  - The confirmed combination of the 2 factor: 98/165.
  - The confirmed combination of the 3 factor: 26/74.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- program_reactive_handoff:
  - The confirmed combination of the 2 factor: 0/183.
  - The confirmed combination of the 3 factor: 0/84.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=36, unsupported=0, stale=0, not_run=0.
- configuration_generated_shape:
  - The confirmed combination of the 2 factor: 0/213.
  - The confirmed combination of the 3 factor: 0/80.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=41, unsupported=0, stale=0, not_run=0.
- udp_array_strength:
  - The confirmed combination of the 2 factor: 0/182.
  - The confirmed combination of the 3 factor: 0/80.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=25, unsupported=0, stale=0, not_run=0.
- generated_udp_state:
  - The confirmed combination of the 2 factor: 27/165.
  - The confirmed combination of the 3 factor: 6/68.
  - Mandatory case: 1/6.
  - Case statuses: pass=2, fail=0, known=34, unsupported=0, stale=0, not_run=0.
- interface_header_import:
  - The confirmed combination of the 2 factor: 108/183.
  - The confirmed combination of the 3 factor: 28/78.
  - Mandatory case: 2/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- mailbox_class_alias:
  - The confirmed combination of the 2 factor: 138/245.
  - The confirmed combination of the 3 factor: 34/92.
  - Mandatory case: 6/9.
  - Case statuses: pass=11, fail=0, known=25, unsupported=0, stale=0, not_run=0.
- distribution_expression_binding:
  - The confirmed combination of the 2 factor: 111/154.
  - The confirmed combination of the 3 factor: 53/81.
  - Mandatory case: 4/8.
  - Case statuses: pass=19, fail=0, known=12, unsupported=0, stale=0, not_run=0.
- generate_default_disable:
  - The confirmed combination of the 2 factor: 0/93.
  - The confirmed combination of the 3 factor: 0/60.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=5, known=13, unsupported=0, stale=0, not_run=0.
- array_reduction_constraint:
  - The confirmed combination of the 2 factor: 0/96.
  - The confirmed combination of the 3 factor: 0/40.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=13, unsupported=0, stale=0, not_run=0.
- associative_array_queries:
  - The confirmed combination of the 2 factor: 0/93.
  - The confirmed combination of the 3 factor: 0/54.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- clocking_event_iff:
  - The confirmed combination of the 2 factor: 65/109.
  - The confirmed combination of the 3 factor: 16/44.
  - Mandatory case: 1/4.
  - Case statuses: pass=4, fail=0, known=8, unsupported=0, stale=0, not_run=0.
- class_virtual_interface:
  - The confirmed combination of the 2 factor: 96/96.
  - The confirmed combination of the 3 factor: 48/48.
  - Mandatory case: 4/4.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- resolved_strength_format:
  - The confirmed combination of the 2 factor: 0/87.
  - The confirmed combination of the 3 factor: 0/78.
  - Mandatory case: 0/4.
  - Case statuses: pass=0, fail=0, known=31, unsupported=0, stale=0, not_run=0.
- class_array_shallow_copy:
  - The confirmed combination of the 2 factor: 108/108.
  - The confirmed combination of the 3 factor: 60/60.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dpi_openarray_shape:
  - The confirmed combination of the 2 factor: 93/100.
  - The confirmed combination of the 3 factor: 59/72.
  - Mandatory case: 3/4.
  - Case statuses: pass=26, fail=0, known=4, unsupported=0, stale=0, not_run=0.
- clocking_assertion_sampling:
  - The confirmed combination of the 2 factor: 109/109.
  - The confirmed combination of the 3 factor: 50/50.
  - Mandatory case: 4/4.
  - Case statuses: pass=18, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- constraint_inheritance:
  - The confirmed combination of the 2 factor: 70/70.
  - The confirmed combination of the 3 factor: 40/40.
  - Mandatory case: 4/4.
  - Case statuses: pass=13, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- dpi_nba_capture:
  - The confirmed combination of the 2 factor: 79/81.
  - The confirmed combination of the 3 factor: 37/48.
  - Mandatory case: 3/4.
  - Case statuses: pass=14, fail=0, known=4, unsupported=0, stale=0, not_run=0.
- aggregate_event_lifetime:
  - The confirmed combination of the 2 factor: 0/123.
  - The confirmed combination of the 3 factor: 0/54.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- sv_dpi_array_queries:
  - The confirmed combination of the 2 factor: 148/177.
  - The confirmed combination of the 3 factor: 45/66.
  - Mandatory case: 4/7.
  - Case statuses: pass=14, fail=0, known=5, unsupported=0, stale=0, not_run=0.
- sdf_conditional_paths:
  - The confirmed combination of the 2 factor: 0/109.
  - The confirmed combination of the 3 factor: 0/46.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- checker_assertion_sampling:
  - The confirmed combination of the 2 factor: 170/174.
  - The confirmed combination of the 3 factor: 56/63.
  - Mandatory case: 5/6.
  - Case statuses: pass=25, fail=0, known=2, unsupported=0, stale=0, not_run=0.
- program_assertion_attempts:
  - The confirmed combination of the 2 factor: 138/138.
  - The confirmed combination of the 3 factor: 75/75.
  - Mandatory case: 6/6.
  - Case statuses: pass=27, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- container_coverage_sampling:
  - The confirmed combination of the 2 factor: 172/172.
  - The confirmed combination of the 3 factor: 79/79.
  - Mandatory case: 6/6.
  - Case statuses: pass=33, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- deferred_disable_reports:
  - The confirmed combination of the 2 factor: 103/151.
  - The confirmed combination of the 3 factor: 36/92.
  - Mandatory case: 6/10.
  - Case statuses: pass=13, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- event_rebinding:
  - The confirmed combination of the 2 factor: 0/138.
  - The confirmed combination of the 3 factor: 0/69.
  - Mandatory case: 0/6.
  - Case statuses: pass=0, fail=0, known=27, unsupported=0, stale=0, not_run=0.
- clocking_named_event:
  - The confirmed combination of the 2 factor: 100/100.
  - The confirmed combination of the 3 factor: 40/40.
  - Mandatory case: 6/6.
  - Case statuses: pass=24, fail=0, known=0, unsupported=0, stale=0, not_run=0.
- deferred_argument_capture:
  - The confirmed combination of the 2 factor: 0/145.
  - The confirmed combination of the 3 factor: 0/71.
  - Mandatory case: 0/7.
  - Case statuses: pass=0, fail=0, known=29, unsupported=0, stale=0, not_run=0.
- generated_enum_navigation:
  - The confirmed combination of the 2 factor: 133/181.
  - The confirmed combination of the 3 factor: 61/110.
  - Mandatory case: 3/6.
  - Case statuses: pass=18, fail=0, known=18, unsupported=0, stale=0, not_run=0.
- package_nba_capture:
  - The confirmed combination of the 2 factor: 113/183.
  - The confirmed combination of the 3 factor: 48/126.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
- package_change_observers:
  - The confirmed combination of the 2 factor: 151/225.
  - The confirmed combination of the 3 factor: 48/122.
  - Mandatory case: 3/6.
  - Case statuses: pass=12, fail=0, known=24, unsupported=0, stale=0, not_run=0.
