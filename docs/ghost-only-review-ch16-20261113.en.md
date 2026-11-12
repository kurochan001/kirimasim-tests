<a id="ghost-only-review-ch16-2026-11-13"></a>

# Review of the tests that only Ghost passes: Clause 16 (2026-11-13)

[English](ghost-only-review-ch16-20261113.en.md) / [日本語](ghost-only-review-ch16-20261113.md)

This record gives the result of comparing with IEEE 1800-2023 the 90 tests of Clause 16 (assertions) that match their expectation on Ghost alone.
The method is that of the [review of Clause 37](ghost-only-review-ch37-20261113.en.md).
The verdicts come from the standard alone; no simulator output was used.
No test was changed in this review.

<a id="what-was-reviewed"></a>

## What was reviewed

- In the Nightly of 2026-11-12, 90 tests of Clause 16 pass on Ghost alone. Of these, 89 are simulation tests and one is a test of an illegal design.
- Two reviews read all 90 tests without seeing each other's results. Each followed the sampled values and the attempts time step by time step, derived the output and compared it with the expected output.
- All reviews were made by AI. They are not an independent human review.

<a id="verdicts"></a>

## Verdicts

| Verdict | Tests |
|---|---:|
| The expectation is right | 85 |
| The expectation is wrong | 0 |
| The test is flawed | 0 |
| The reading is contested | 5 |
| Total | 90 |

The two reviews agreed on "right" for 84 tests.
One review alone raised a point on each of the other six. Five of them are contested, and one was found right.

<a id="contested"></a>

## The five contested tests

| Test | Clauses | What is contested |
|---|---|---|
| `ch16/test_first_match_items_and_boolean_or` | 16.9.8, 16.11 | It expects the call of `first_match(seq, call)` to run once, for the first match. 16.9.8 says the form is equivalent to `first_match((seq, call))`. 16.11 runs a call at every end point of the sequence it is attached to, which gives two calls. |
| `ch16/test_sequence_consecutive_repetition` | 16.9.2.1, 16.14.3, 16.12.22 | Its last line puts the sequence `a[*0] ##0 b`, which has no match, in a `cover sequence`. 16.12.22 restricts properties and antecedents of implications. But 16.14.3 defines the matches of a cover sequence through an implication, whose antecedent needs a match. |
| `ch16/test_sequence_empty_match_concatenation` | 16.9.2.1, 16.14.3, 16.12.22 | For the same reason the line of `a ##0 b[*0]` is contested. The other five lines are right under both readings. |
| `ch16/test_sequence_empty_match_fusion` | 16.9.2.1, 16.14.3, 16.12.22 | For the same reason the three covers of sequences without a match are contested. The other six are right. |
| `ch16/test_sequence_local_formal_assignment` | 16.8.1, 16.8.2 | It expects that an assignment to a `local input` formal is not written back to the actual `w`. 16.8.2 makes an input only an initial value. The text of item c of 16.8.1 says that, when the actual is a variable, an assignment to the formal is followed by one to the actual. 16.8.2 is the more specific rule. The test does not cite 16.8.2. |

<a id="settled"></a>

## The test that was found right

In `ch16/test_sequence_formal_arguments_substitution` assertions without an else clause fail, so the default `$error` is called (16.14.1).
One review called it a flaw that the destination of that message is not fixed.
This suite removes the messages of severity tasks before the comparison. The six printed values follow the standard, so the test is right.

<a id="notes"></a>

## Wrong citations and comments

They do not affect an expectation. They will be corrected when Ghost's results are saved again.

- `ch16/test_property_statement_forms`: the comment says that `a3` fails at the "third, fifth and sixth tick"; it is the second, fifth and sixth. restrict is 16.14.4, not 16.14.3.
- `ch16/test_sequence_formal_arguments_substitution`: the rule that a direction needs local is in 16.8.2, not 16.8.1.
- `ch16/test_sequence_triggered`: for the `wait` on `triggered`, 9.4.4 fits better than 9.4.3.
- `ch16/test_property_declaration_names_and_clock`: 16.12.20 holds only examples. The basis is A.2.10 and 16.16.

<a id="next"></a>

## What happens next

- The five contested tests wait for a decision.
- The coverage figures are unchanged.
