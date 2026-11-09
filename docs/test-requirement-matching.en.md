<a id="既存テストと規格要求の照合"></a>

# Comparison of existing tests with the standard requirements

[English](test-requirement-matching.en.md) / [日本語](test-requirement-matching.md)

[Requirement-coverage aggregation](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](../coverage/test-matching.json) / [Content check errors](existing-test-matching-review-20261022.en.md)

The reference candidates are listed from the citation section for all 12268 tests. The test which has registered the demand response based on stimulus and expected result is 5400 tests, and the test which is not registered is 6868 tests.

The mapping based on the verification content of all tests is not complete. The list of candidates is an automatic process and does not represent approval of the match. The number of registered units is the number of units that correspond to at least one requirement, and not the number of completed verification of each test. Multiple observations of one test and the response of another test verifying the same requirement are recorded in sequence.

<a id="台帳の読み方"></a>

## Reading the daisho

- `registered_requirement_ids`: requirement registered by verifying stimulus and expected result. The evidence and reviewer and date are in `checks` of `behaviors.json`.
- `collective_requirement_ids`: Participation in a request that is shared by multiple tests. The test alone does not verify the entire requirement, but requires all successes of the specified group.
- `unapproved_candidate_ids`: candidates that match the citation section and the distinction of normal system/standard violation. The name and quotation are not supported.
- `interpretation_pending_ids` : Interpretation reserved for the quoted section. The authorization objects are separated from the coverage.
- `different_case_kind_ids`: Items that agree in the citation section but have different distinctions of normal system/standard violation. If the request line contains multiple conditions, it will also check whether the request needs to be split.
- `broader_citations`: The subsection of the citation section is also required. Even if there is no direct candidate, the test is not considered irrelevant.
- `inputs_sha256` : The identifier of the input that created the match candidate. If the test, expected value, and auxiliary file change, the reference is re-established.

Do not treat a requirement without a candidate or an unregistered test as evidence that the test does not exist. Tests that only observe a part of the complex requirements, tests that lack the required boundary conditions, tests that have errors in the expected values, and tests that give stimuli that violate the specifications, do not meet the entire requirements as they are.

<a id="対応を保留した理由"></a>

## Reasons for retention of response

1356 The range and judgment of the present paper were recorded in [Review judgement table](../coverage/test-matching-reviews.json). This is a record of the scope-limited judgments, not the number of completed reviews of the whole test. This information is not used as information for the corresponding registration or to increase the operation coverage rate. Checks the input hash, the string base, and the request ID, preventing the reuse of the decision after the change.

- `citation_refinement` : 196 item.
- `compound_requirement` : 176 item.
- `oracle_issue` : 244 item.
- `partial_observation` : 2136 item.

<a id="章別の登録状況"></a>

## Registration status by chapter

- ch3 : All 136 tests, registered 71 tests, unregistered 65 tests.
- ch4 : All 478 tests, registered 126 tests, unregistered 352 tests.
- ch5 : All 513 tests, registered 329 tests, unregistered 184 tests.
- ch6 : All 685 tests, registered 415 tests, unregistered 270 tests.
- ch7 : All 776 tests, registered 299 tests, unregistered 477 tests.
- ch8 : All 459 tests, registered 222 tests, unregistered 237 tests.
- ch9 : All 444 tests, registered 133 tests, unregistered 311 tests.
- ch10 : All 425 tests, registered 126 tests, unregistered 299 tests.
- ch11 : All 1647 tests, registered 367 tests, unregistered 1280 tests.
- ch12 : All 306 tests, registered 104 tests, unregistered 202 tests.
- ch13 : All 450 tests, registered 114 tests, unregistered 336 tests.
- ch14 : All 170 tests, registered 75 tests, unregistered 95 tests.
- ch15 : All 192 tests, registered 39 tests, unregistered 153 tests.
- ch16 : All 794 tests, registered 608 tests, unregistered 186 tests.
- ch17 : All 108 tests, registered 52 tests, unregistered 56 tests.
- ch18 : All 273 tests, registered 189 tests, unregistered 84 tests.
- ch19 : All 196 tests, registered 131 tests, unregistered 65 tests.
- ch20 : All 409 tests, registered 102 tests, unregistered 307 tests.
- ch21 : All 495 tests, registered 150 tests, unregistered 345 tests.
- ch22 : All 516 tests, registered 341 tests, unregistered 175 tests.
- ch23 : All 417 tests, registered 191 tests, unregistered 226 tests.
- ch24 : All 167 tests, registered 40 tests, unregistered 127 tests.
- ch25 : All 262 tests, registered 84 tests, unregistered 178 tests.
- ch26 : All 262 tests, registered 48 tests, unregistered 214 tests.
- ch27 : All 283 tests, registered 39 tests, unregistered 244 tests.
- ch28 : All 297 tests, registered 200 tests, unregistered 97 tests.
- ch29 : All 142 tests, registered 54 tests, unregistered 88 tests.
- ch30 : All 60 tests, registered 56 tests, unregistered 4 tests.
- ch31 : All 66 tests, registered 60 tests, unregistered 6 tests.
- ch32 : All 68 tests, registered 37 tests, unregistered 31 tests.
- ch33 : All 88 tests, registered 38 tests, unregistered 50 tests.
- ch34 : All 4 tests, registered 4 tests, unregistered 0 tests.
- ch35 : All 177 tests, registered 121 tests, unregistered 56 tests.
- ch36 : All 89 tests, registered 75 tests, unregistered 14 tests.
- ch37 : All 227 tests, registered 218 tests, unregistered 9 tests.
- ch38 : All 109 tests, registered 82 tests, unregistered 27 tests.
- ch39 : All 39 tests, registered 31 tests, unregistered 8 tests.
- ch40 : All 39 tests, registered 29 tests, unregistered 10 tests.

<a id="更新検査"></a>

## Update and check

```sh
python3 tools/requirement_matching.py --update
python3 tools/requirement_matching.py --check
```

`--check` detects the age of the table by changing the input and correspondence. The fact that an unregistered item remains does not in itself fail.
