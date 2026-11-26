<a id="既存テストと規格要求の照合"></a>

# Comparison of existing tests with the standard requirements

[English](test-requirement-matching.en.md) / [日本語](test-requirement-matching.md)

[Requirement-coverage aggregation](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](../coverage/test-matching/) / [Content check errors](existing-test-matching-review-20261022.en.md)

The reference candidates are listed from the citation section for all 17120 tests. The test which has registered the demand response based on stimulus and expected result is 7383 tests, and the test which is not registered is 9737 tests.

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

1495 The range and judgment of the present paper were recorded in [Review judgement table](../coverage/test-matching-reviews.json). This is a record of the scope-limited judgments, not the number of completed reviews of the whole test. This information is not used as information for the corresponding registration or to increase the operation coverage rate. Checks the input hash, the string base, and the request ID, preventing the reuse of the decision after the change.

- `citation_refinement` : 191 item.
- `compound_requirement` : 176 item.
- `oracle_issue` : 242 item.
- `partial_observation` : 2293 item.

<a id="章別の登録状況"></a>

## Registration status by chapter

- ch3 : All 166 tests, registered 101 tests, unregistered 65 tests.
- ch4 : All 485 tests, registered 132 tests, unregistered 353 tests.
- ch5 : All 533 tests, registered 349 tests, unregistered 184 tests.
- ch6 : All 924 tests, registered 466 tests, unregistered 458 tests.
- ch7 : All 1139 tests, registered 352 tests, unregistered 787 tests.
- ch8 : All 516 tests, registered 262 tests, unregistered 254 tests.
- ch9 : All 493 tests, registered 185 tests, unregistered 308 tests.
- ch10 : All 770 tests, registered 166 tests, unregistered 604 tests.
- ch11 : All 2638 tests, registered 420 tests, unregistered 2218 tests.
- ch12 : All 328 tests, registered 125 tests, unregistered 203 tests.
- ch13 : All 764 tests, registered 177 tests, unregistered 587 tests.
- ch14 : All 174 tests, registered 79 tests, unregistered 95 tests.
- ch15 : All 218 tests, registered 64 tests, unregistered 154 tests.
- ch16 : All 819 tests, registered 629 tests, unregistered 190 tests.
- ch17 : All 141 tests, registered 86 tests, unregistered 55 tests.
- ch18 : All 302 tests, registered 210 tests, unregistered 92 tests.
- ch19 : All 259 tests, registered 189 tests, unregistered 70 tests.
- ch20 : All 723 tests, registered 156 tests, unregistered 567 tests.
- ch21 : All 971 tests, registered 191 tests, unregistered 780 tests.
- ch22 : All 1332 tests, registered 1159 tests, unregistered 173 tests.
- ch23 : All 448 tests, registered 216 tests, unregistered 232 tests.
- ch24 : All 225 tests, registered 43 tests, unregistered 182 tests.
- ch25 : All 282 tests, registered 96 tests, unregistered 186 tests.
- ch26 : All 271 tests, registered 57 tests, unregistered 214 tests.
- ch27 : All 295 tests, registered 48 tests, unregistered 247 tests.
- ch28 : All 423 tests, registered 262 tests, unregistered 161 tests.
- ch29 : All 148 tests, registered 62 tests, unregistered 86 tests.
- ch30 : All 73 tests, registered 71 tests, unregistered 2 tests.
- ch31 : All 89 tests, registered 81 tests, unregistered 8 tests.
- ch32 : All 80 tests, registered 48 tests, unregistered 32 tests.
- ch33 : All 110 tests, registered 60 tests, unregistered 50 tests.
- ch34 : All 52 tests, registered 52 tests, unregistered 0 tests.
- ch35 : All 247 tests, registered 186 tests, unregistered 61 tests.
- ch36 : All 101 tests, registered 86 tests, unregistered 15 tests.
- ch37 : All 296 tests, registered 275 tests, unregistered 21 tests.
- ch38 : All 190 tests, registered 165 tests, unregistered 25 tests.
- ch39 : All 50 tests, registered 42 tests, unregistered 8 tests.
- ch40 : All 45 tests, registered 35 tests, unregistered 10 tests.

<a id="更新検査"></a>

## Update and check

```sh
python3 tools/requirement_matching.py --update
python3 tools/requirement_matching.py --check
```

`--check` detects the age of the table by changing the input and correspondence. The fact that an unregistered item remains does not in itself fail.
