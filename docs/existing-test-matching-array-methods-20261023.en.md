<a id="既存テストの要求照合配列メソッド2026-10-23"></a>

# Existing-test requirement mapping: array methods (2026-10-23)

[English](existing-test-matching-array-methods-20261023.en.md) / [日本語](existing-test-matching-array-methods-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Previous class mapping](existing-test-matching-classes-20261023.en.md)

<a id="今回の進捗"></a>

## Progress in this round

Compared 7.12 and 7.12.1–7.12.5 in the supplied IEEE 1800-2023 against the complete stimulus and expected output of the existing tests. Covered search, representative elements, reduction, ordering, iterator indices, and map for fixed arrays, dynamic arrays, and queues. Also checked key specifications for structure arrays and observations on real queues.

- Registered bindings: 858 → 893 tests (added 35 of 3,923 total tests).
- Mapped requirements: 725 → 746 rows (21 added). Added 119 pieces of mapping evidence.
- Execution-verified requirements: 651 → 672 rows (21 added).
- Provisional requirement coverage (test design): 6.06% (746/12,319).
- The provisional execution confirmation rate is 5.45% ( 672/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and resolution of pending interpretations remain.
- Tests without even one registered mapping: 3,030. Mappings based on verification content for every case remain incomplete.

Registered-test counts mean tests with at least one observation mapped to a requirement; they do not count files whose complete observations/requirements are fully reviewed. AI performed the review; it is not independently verified by a person.

Test inputs, expected values, citations, runners, and requirement definitions are unchanged. Preserved requirement definitions for all 12,319 rows, existing mapping evidence / set evidence / assessment records, and previously uncommitted changes.

<a id="採用した観測と集合証拠"></a>

## Accepted observations and set-level evidence

[test_array_find.sv](../tests/ch7/test_array_find.sv) sorts the results of find and checks for all elements of 25/25/30/40. Compare multiplicities too, without imposing unspecified search order on expected values. For first/last, used observations returning 25 and 40 under the same predicate. Left find_last, which only selects the same value 20 from several candidates, pending because erroneously returning first would not be detected.

[test_array_unique_methods.sv](../tests/ch7/test_array_unique_methods.sv) sorts unique results and checks every representative value. unique_index sorts the original values selected by the returned indices and compares them against 10/20/30/40. Do not fix representative indices for duplicates or result order.

In the reduction, we combined the normal element value with the non-identity value conversion by using with. Doubling sum30 and sum-of-squares 55 in [test_array_reduction_with_clause.sv](../tests/ch7/test_array_reduction_with_clause.sv), and 24 of `product with (item+1)` in [test_comb_queue_with_clause.sv](../tests/ch7/test_comb_queue_with_clause.sv), distinguish implementations that ignore with or use it only as a Boolean filter to select original values. [test_array_reduction_and_or_xor_with.sv](../tests/ch7/test_array_reduction_and_or_xor_with.sv) directly contrasts ordinary 0/3/0 and projected 8/7/5 values for and/or/xor.

Added set-level evidence for the following 8 requirements. Cumulative 32 rows. The AND within the group and the OR between groups requires success for all members of the same run.

- LOCATOR-EMPTY: no-match of non-empty array and unique of empty array.
- LOCATOR-UNPACKED: 3 container types—fixed unpacked array, dynamic array, and queue.
- MAXIMUM: observes size1 even with duplicate maxima, and returns original value -10 using square as the key.
- SUM / PRODUCT / AND / OR / XOR-REDUCE: observations with with omitted and with a non-identity projection.

These set conditions are met in the same run as the saved `verilator.json`. Corresponding known results on Icarus are not counted as successes. All 21 new rows have usable recorded pass results and were added to execution verification too.

Simulators were not rerun. Because the inputs are unchanged, checked the saved Icarus 13.0 / Verilator 5.052 execution results for all 3,912 tests against the current input hashes. Also retain partial runs for subsequent additions/citation changes; do not treat them as a batch rerun of all 3,923 tests. Partial successes from separate runs are not combined into set evidence.

<a id="m36未規定のlocator結果順を固定するoracle"></a>

## M36: Oracle fixing unspecified locator result order

[test_array_method_index_argument.sv](../tests/ch7/test_array_method_index_argument.sv) stimulates rename of iterator/index and avoidance of collision with index members of the structure. However, the find values 20/40, the find_index indices 2/4, and the record values 10/20 are displayed in order without sorting, and that order is fixed in the expected output.

Locator search order is unspecified in 7.12.1. Reversed results can also conform, so this whole-file oracle remains pending. The rename stimulus is useful, but the response from this result is not added. Oracle corrections such as order normalization and reruns after input changes remain outstanding.

<a id="m37size先頭値だけでは内容や位置を確認できない"></a>

## M37: Content and position cannot be verified by size and initial value alone.

There are several tests that only check the size of unique/unique_index. Same-size results with duplicates, omissions, or incorrect representative indices can pass, so adopted another test checking all representative values. Checking only find's result count does not verify the complete returned matching multiset.

[test_array_min.sv](../tests/ch7/test_array_min.sv) and [test_array_max.sv](../tests/ch7/test_array_max.sv) contain ties with all elements equal to 7, but check only size \> 0 and the first element 7. size == 1 is determined by a different array, which does not have duplicate extremes. This cannot detect an incorrect implementation returning every tied value.

MAXIMUM uses set-level evidence combining size1 and projection for duplicate maximum 8 in a separate test. The same tie condition in MINIMUM remains pending due to insufficient observations in the checked scope. find_last also returns the same value 20 and cannot distinguish first, so used another observation with differing candidate values.

<a id="m38ソートの両端と相関したkeyだけを見る"></a>

## M38: Only see the keys that correspond to the two ends of the sort

Checking only endpoints after sort/rsort cannot detect incorrect middle ordering or lost elements. Tests check every position for ordinary scalars, but evidence checking every position with with-keys is insufficient.

The square-key sort in [test_comb_queue_with_clause.sv](../tests/ch7/test_comb_queue_with_clause.sv) checks only the first 3 keys' order. Because the final 2 elements are not displayed on success, even an exact expected-output match cannot fill that observation gap. [test_struct_array_sort.sv](../tests/ch7/test_struct_array_sort.sv) also checks only the two endpoints; moreover, value = id*10, so confusing id and value leaves the ranking unchanged.

Checking every ordinary-sort position in another file does not verify the unobserved middle positions of projection sorting. The entire SORT / RSORT row is not included in this coverage.

<a id="m39代入先の型rangeはメソッド結果そのものではない"></a>

## M39: destination types/ranges are not the method result itself

`$bits(big[2])` in [test_array_map_method.sv](../tests/ch7/test_array_map_method.sv) measures the explicitly declared destination of type bit. This does not directly measure map's self-determined element type. The fixed array g[ 2:4 ] is also the range of the assignment, and it can be hidden by assignment even if the range of the returned array changes.

[test_map_result_to_same_array.sv](../tests/ch7/test_map_result_to_same_array.sv) checks values, size, and unchanged source arrays, but does not satisfy the combined conditions for non-0/reversed ranges, associative key sets, and differing element types. Left MAP-SHAPE / MAP-SELF-DETERMINED-TYPE pending.

In reductions too, destinations of 8bit or int alone do not verify the reduction expression's own type/width. Cases are needed contrasting overflow when each element is widened by a cast in with against merely using a wider destination. RESULT-TYPE / REDUCTION-SIGNATURE / WITH-RESULT-WIDTH were not added in this update.

<a id="m40shuffleの不変条件と正常系規格違反を含む複合行"></a>

## M40: shuffle invariants and compound rows combining positive/standard-violation behavior

sum/product/size alone cannot detect a different multiset with the same aggregates. Sorting and comparing every element is useful verification, but shuffle permits the original ordering as a valid permutation, so one call must not be required to change the order.

The current SHUFFLE / REVERSE requirement rows combine normal sorting with “compile error when with is specified.” Even positive tests checking every position do not observe rejection of prohibited forms, so kept these entire composite rows pending. Requirement definitions were not weakened to increase percentages.

<a id="m41未使用宣言filterと同じ結果になるprojectionxを見逃す判定"></a>

## M41: unused declarations, projections indistinguishable from filters, and checks that miss X

Dedicated sum/product/and/or/xor tests only declare empty arr4 and do not call those methods. Accepted ordinary-value and singleton results without claiming empty-array verification. The xor_result of [test_array_method_corner.sv](../tests/ch7/test_array_method_corner.sv) is not determined or displayed after the assignment.

`sum with (item>2?item:0)` in [test_array_method_sum.sv](../tests/ch7/test_array_method_sum.sv) is also 12 if item \> 2 is treated as a Boolean filter and only the original values are summed. Use separate doubling/squaring evidence to distinguish projections from filters.

For a result of type logic, [test_array_and_or_xor.sv](../tests/ch7/test_array_and_or_xor.sv) detects failure only with `if (result != expected)` and does not display the value. If an incorrect implementation returns X, the comparison is also X and if is not true, allowing execution to reach PASS. This file is not used for this operation.

<a id="m42iteratorの値名前scope次元戻り値型を区別する"></a>

## M42: Differentiate the value, name, scope, dimension, and return type of the iterator.

`sum with (item.index)` has element values 1 .. Indices 0 .. rather than sum 15 of 5 Registered the observation returning sum 10 of 4 under INDEX-QUERY. Do not claim verification of dimension2 or higher, explicit dimension arguments, or associative index types. first/last on ordinary 0-based arrays are not equated with associative first()/last() or reversed-range boundaries.

Using default items and explicit iterators does not establish scope boundaries against same-named outer variables or attribute forms. Even filenames like array_predicates do not have a with evaluation for tests that only use size/new/delete and queue push/pop.

<a id="m43withなしiterator指定の診断oracle"></a>

## M43: diagnostic oracle for an explicit iterator without with

`q.sum(v)` in [test_illegal_iterator_argument_without_with.sv](../tests/ch7/test_illegal_iterator_argument_without_with.sv) is stimulus containing a standard violation: an explicit iterator without with. However, the expected stderr regular expressions are only filename and line number, and they can match even if the array method or iterator syntax itself is not supported. Diagnostics identifying the relevant semantic constraint and execution on supporting environments remain outstanding; no error-requirement mapping was registered.

<a id="記録と検査"></a>

## Records and checks

Appended 87 hold decisions across 39 files to [Assessment ledger](../coverage/test-matching-reviews.json). The cumulative 272 tests and 354 item are recorded for partial observation, complex requirement, and oracle problem. These are neither counts of fully reviewed tests nor additions to coverage.

Compared against the initial snapshot to verify preservation of all requirement definitions and previous mappings, set evidence, and assessment records. All 74 management-tool unit tests and consistency checks for text sources, coverage, matching, catalogs, statistics, depth, and generators succeeded. Metadata has 0 new issues and 378 known issues. `git diff --check` also succeeded.
