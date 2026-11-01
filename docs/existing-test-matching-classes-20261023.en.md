<a id="既存テストの要求照合クラス構築メソッド2026-10-23"></a>

# Existing-test requirement mapping: classes, construction, and methods (2026-10-23)

[English](existing-test-matching-classes-20261023.en.md) / [日本語](existing-test-matching-classes-20261023.md)

> Counts, percentages, and pending statuses in this document record their respective work dates.
> The current value is [Aggregated Summary](behavior-coverage-summary.en.md); the approval history for the denominator and interpretations is in
> See [Results of requirement extraction](requirement-extraction.en.md).

[Current coverage](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](test-requirement-matching.en.md) / [Previous control-statement/loop mapping](existing-test-matching-control-flow-20261023.en.md)

<a id="今回の進捗"></a>

## Progress in this round

Compared the relevant text of Chapter 8 in the supplied IEEE 1800-2023 against the complete stimulus and expected output of each test. Scope includes handles, constructors, static members, this, copies, inheritance, virtual dispatch, pure prototypes, and casts. The support is not based on the existence of the filename or declaration alone.

- Tests registered as mapping to at least one requirement: increased from 813 to 858 (45 added out of 3,923 total).
- Mapped requirements: 698 → 725 rows (27 added). The new match base is 92.
- Execution-verified requirements: 624 → 651 rows (27 added).
- Provisional requirement coverage (test design): 5.89% (725/12,319).
- The provisional execution confirmation rate is 5.28% ( 651/12,319 ).
- Finalized values: both design and execution remain unfinalized. Denominator approval, deduplication, and pending interpretations remain outstanding.
- Tests without even one registered mapping: 3,065. Mappings based on verification content for every case remain incomplete.

Registered test counts mean tests with at least one mapped observation, not files whose every observation/requirement has been fully reviewed. AI performed the review; it is not independently verified by a person.

Test inputs, expected values, citations, runners, and requirement definitions are unchanged. All 12,319 line definitions, conventional support, set evidence, and judgment records, and previously uncommitted changes are retained.

<a id="採用した観測と集合証拠"></a>

## Accepted observations and set-level evidence

[test_property_initializer_after_super_new.sv](../tests/ch8/test_property_initializer_after_super_new.sv) changes the base property's initial value 1 to 41 in the constructor; the derived initializer reads it to produce 43, then the derived body records that 43 and changes it to 430. Expected value `b=41 seen_c=43 c=430` distinguishes the order of base constructor, derived-property initializer, and derived body.

[test_class_vs_struct_assignment.sv](../tests/ch8/test_class_vs_struct_assignment.sv) compares `c2=c1` and `c3=new c1` under the same stimulus. Value 10/10/1 after source changes and handle comparison 1/0 distinguish aliases from copies into separate objects. Also accepted dynamic-array, queue, and fixed-array independence in [test_shallow_copy_array_properties.sv](../tests/ch8/test_shallow_copy_array_properties.sv).

[test_typed_constructor_into_base_handle.sv](../tests/ch8/test_typed_constructor_into_base_handle.sv) assigns `child::new(7)` to a base-typed target and checks the child constructor's value 17 and virtual read's value 34. [test_class_static_2.sv](../tests/ch8/test_class_static_2.sv) checks count0 before the first new, 1/3 after construction, and id1/2/3 for each instance, distinguishing static reinitialization from shared instance properties.

Added new set-level evidence for the following 3 requirements. Requirements with set-level evidence total 24 rows. Requires all members of the group to succeed in the same saved run.

- 8.4 HANDLE-ASSIGNMENT: same-type handle/null assignment in `test_class_null_comparison` and shared changes through aliases in `test_class_basics`. Both are successful in the all suite results of Icarus / Verilator.
- 8.7 CONSTRUCTOR-ARGUMENTS: Omission default for `test_class_new_args` and runtime property actual for `test_class_copy_2`. Both succeed in the same saved full-suite Verilator result.
- 8.20 VIRTUAL-LATEST-OVERRIDE: contrast `test_method_virtual`'s most recent multilevel override / inherited virtual body with static selection of the same-named nonvirtual method in `test_method_initial_extends`. Both succeed in the same saved full-suite Verilator result. The Icarus known is not converted to success.

Simulators were not rerun. Because the inputs were unchanged, compared the saved Icarus 13.0 / Verilator 5.052 execution results for all 3,912 tests against the current input hashes. Partial runs for subsequent additions/citation changes are also retained. 3,923 partial results are not treated as reruns of all tests, and partial successes of different runs are not synthesized into a set of proofs.

<a id="m29自作copyメソッドと規格の浅いコピーの混同"></a>

## M29: confusing a custom copy method with standard shallow copying

The copy / shallow_copy / deep_copy / clone methods in [test_class_copy_corner.sv](../tests/ch8/test_class_copy_corner.sv), [test_class_copy_2.sv](../tests/ch8/test_class_copy_2.sv), and [test_class_copy_3.sv](../tests/ch8/test_class_copy_3.sv) are user methods implemented with ordinary constructor calls and field assignments. Sharing nested handles in a custom method does not prove that `new source` shares them as the standard specifies. Constructor/declaration-initializer nonexecution and dynamic-class duplication are also unverified.

The clone of `test_class_copy_corner` is a base type return, but the caller orig is a derivative type. This alone does not verify dispatch through a base-type handle. `test_class_copy_2` does observe a call to Dog.copy through the base type, but its citations do not include 8.20, so only the constructor and chained-member observations were mapped in this round.

[test_copy_obj.sv](../tests/ch8/test_copy_obj.sv) checks shared changes through aliases and independence after a later new. Because `new source` is unused and there is no 8.4 citation for handle assignment, left citation clarification as remaining work.

<a id="m30実際の浅いコピーでも未観測の条件が残る"></a>

## M30: unobserved conditions remain even with actual shallow copying

The 3 tests actually using `new source` provide evidence of value copying into distinct objects. There are no class-typed properties, so nested-object handle sharing, especially when new occurs in a property declaration, is unverified. Array properties are copied by value and cannot be equated with sharing nested class handles. Therefore registered under COPY-RESULT-ASSIGNMENT and left the complete compound SHALLOW-MEMBER-COPY row pending.

Constructor/declaration-initializer counts or side effects are unobserved, so an implementation incorrectly executing them before overwriting properties is undetected. No stimulus copies a derived object through a base-type handle, so COPY-NO-CONSTRUCTION and COPY-DYNAMIC-TYPE remain unapproved.

<a id="m31static-propertystatic-methodautomatic-lifetimeの区別"></a>

<a id="m31staticプロパティstaticメソッドautomatic寿命の区別"></a>

## M31: distinguishing static properties, static methods, and automatic lifetime

The static get_count/reset in [test_class_static_members.sv](../tests/ch8/test_class_static_members.sv) is not called. Property sharing is verified, but method declarations alone are not behavioral evidence for 8.10.

Even in tests that actually call static methods, the separation of argument/local variables by recurrence or simultaneous activation is not observed. Left the requirement that static class-method qualification does not give arguments/locals static lifetime pending.

InitTest in [test_class_static_corner.sv](../tests/ch8/test_class_static_corner.sv) checks one initializer display, but never constructs an InitTest object with new. Used separate tests with cumulative counts and independent ids as evidence detecting reinitialization per new. [test_static_method_through_null_handle.sv](../tests/ch8/test_static_method_through_null_handle.sv) is also access to a static member, and not a verification of a specified operation forbidden to access a nonstatic member/virtual method from null.

<a id="m32default引数implicit-constructor初期化順序の区別"></a>

## M32: distinguishing default arguments, implicit constructors, and initialization order

Some tests display “Default constructor” but call an explicitly declared `function new` using default arguments. For implicit constructors, used [test_method_class.sv](../tests/ch8/test_method_class.sv), which creates Calculator without a declared new and executes a method.

[test_class_multilevel_inheritance.sv](../tests/ch8/test_class_multilevel_inheritance.sv) overwrites the base value in the derived body. A final total alone cannot verify base-constructor execution or ordering. An example that only succeeds with correctly placed initial super.new also cannot distinguish an implementation incorrectly accepting a later call. Used the previously described 41 → 43 → 430 ordering, distinguishing successful acceptance of standard-compliant syntax from observation of the order.

There are valid observations for this property access, return values, and method selection; value-parameter / localparam selection in the same row remains unobserved. Registered observations distinguishing shadowing of formals/properties under INNER-SCOPE-SHADOW, leaving the broader compound row pending.

<a id="m33仮想呼び出しの対照と複合条件の不足"></a>

## M33: insufficient virtual-call controls and compound conditions

Virtual declarations or direct calls through derived types alone do not establish runtime lookup through a base-type handle. Even tests with calls from the base type may not have a static selection of nonvirtual or a re-declaration property selection. Did not register the complete compound 8.14 row; assigned the set evidence above to latest-override 8.20.

Observing that a base method marked `:initial` remains nonvirtual does not verify the form that marks a derived method `:initial` to override a nonvirtual base method. Tests with ordinary Animal as the base do not verify abstract-type variable rules.

There are strong observations for static separation of parameterized classes, but broader compound requirements for sharing through nonparameterized bases, type identity across package/module instances, and type/value-type conditions remain pending.

<a id="m34エラーテストの行番号だけの診断oracle"></a>

## M34: diagnostic oracle checking only error-test line numbers

For the 5 tests concerning final overrides, virtual overrides by initial, missing extends targets, combined initial/extends, and pure final, expected stderr regexes check only filenames/line numbers. Syntax errors due solely to unsupported new syntax can also pass, preventing identification of rejection for the intended semantic constraint. More specific diagnostic oracles and execution in syntax-supporting environments remain outstanding.

Standard-compliant uses in [test_final_class_and_method.sv](../tests/ch8/test_final_class_and_method.sv) do not verify prohibitions on overriding final methods or extending final classes.

<a id="m35castのnull-literal失敗状態task形式の不足"></a>

## M35: missing cast null literals, failure states, and task forms

The null source of [test_dynamic_cast.sv](../tests/ch8/test_dynamic_cast.sv) is the value of the null substituted in the Base type variable. This differs from passing a literal null directly. Together with [test_class_cast_edge_cases.sv](../tests/ch8/test_class_cast_edge_cases.sv), mapped checked downcasts and upcasts of compatible actual objects, but the following remain unobserved.

- Failure when a source with an incompatible static type is null.
- Place a sentinel handle in the destination and verify it remains unchanged after failure.
- The cast in task form and the diagnostics in case of failure are described.

[test_class_compare.sv](../tests/ch8/test_class_compare.sv) does not prove their equivalence, even if there is a comparison by means of == between custom equals and handles. Continued reads through live aliases do not establish observation of GC for unreachable objects.

<a id="記録と検査"></a>

## Records and checks

Appended pending reasons for 39 tests and 53 entries to [Assessment ledger](../coverage/test-matching-reviews.json). Cumulative totals are 233 tests and 267 entries, separating partial observations, compound requirements, citation refinement, and oracle issues. These assessments neither mean complete-file review nor count toward coverage.

Compared against the initial snapshot to verify preservation of all existing requirement definitions, mapping evidence, set evidence, and assessment records. The acceptance status of the denominator is unchanged.

All 74 management-tool unit tests and consistency checks for text sources, coverage, matching, catalogs, statistics, depth, and generators succeeded. Metadata has 0 new issues and 378 known issues. `git diff --check` also succeeded. No simulations were rerun for these mapping additions.
