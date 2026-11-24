<a id="既存テストと規格要求の照合"></a>

# Comparison of existing tests with the standard requirements

[English](test-requirement-matching.en.md) / [日本語](test-requirement-matching.md)

[Requirement-coverage aggregation](behavior-coverage-summary.en.md) / [Comparison ledger for all tests](../coverage/test-matching/) / [Content check errors](existing-test-matching-review-20261022.en.md)

The reference candidates are listed from the citation section for all 16755 tests. The test which has registered the demand response based on stimulus and expected result is 7023 tests, and the test which is not registered is 9732 tests.

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

1479 The range and judgment of the present paper were recorded in [Review judgement table](../coverage/test-matching-reviews.json). This is a record of the scope-limited judgments, not the number of completed reviews of the whole test. This information is not used as information for the corresponding registration or to increase the operation coverage rate. Checks the input hash, the string base, and the request ID, preventing the reuse of the decision after the change.

- `citation_refinement` : 194 item.
- `compound_requirement` : 176 item.
- `oracle_issue` : 242 item.
- `partial_observation` : 2275 item.

<a id="章別の登録状況"></a>

## Registration status by chapter

- ch3 : All 153 tests, registered 88 tests, unregistered 65 tests.
- ch4 : All 481 tests, registered 128 tests, unregistered 353 tests.
- ch5 : All 526 tests, registered 342 tests, unregistered 184 tests.
- ch6 : All 909 tests, registered 452 tests, unregistered 457 tests.
- ch7 : All 1131 tests, registered 347 tests, unregistered 784 tests.
- ch8 : All 503 tests, registered 249 tests, unregistered 254 tests.
- ch9 : All 484 tests, registered 176 tests, unregistered 308 tests.
- ch10 : All 761 tests, registered 157 tests, unregistered 604 tests.
- ch11 : All 2635 tests, registered 417 tests, unregistered 2218 tests.
- ch12 : All 323 tests, registered 120 tests, unregistered 203 tests.
- ch13 : All 759 tests, registered 174 tests, unregistered 585 tests.
- ch14 : All 173 tests, registered 79 tests, unregistered 94 tests.
- ch15 : All 214 tests, registered 62 tests, unregistered 152 tests.
- ch16 : All 815 tests, registered 625 tests, unregistered 190 tests.
- ch17 : All 134 tests, registered 79 tests, unregistered 55 tests.
- ch18 : All 296 tests, registered 204 tests, unregistered 92 tests.
- ch19 : All 252 tests, registered 181 tests, unregistered 71 tests.
- ch20 : All 709 tests, registered 142 tests, unregistered 567 tests.
- ch21 : All 952 tests, registered 172 tests, unregistered 780 tests.
- ch22 : All 1327 tests, registered 1155 tests, unregistered 172 tests.
- ch23 : All 444 tests, registered 212 tests, unregistered 232 tests.
- ch24 : All 222 tests, registered 41 tests, unregistered 181 tests.
- ch25 : All 274 tests, registered 89 tests, unregistered 185 tests.
- ch26 : All 271 tests, registered 57 tests, unregistered 214 tests.
- ch27 : All 293 tests, registered 46 tests, unregistered 247 tests.
- ch28 : All 423 tests, registered 262 tests, unregistered 161 tests.
- ch29 : All 145 tests, registered 58 tests, unregistered 87 tests.
- ch30 : All 73 tests, registered 71 tests, unregistered 2 tests.
- ch31 : All 85 tests, registered 77 tests, unregistered 8 tests.
- ch32 : All 77 tests, registered 44 tests, unregistered 33 tests.
- ch33 : All 90 tests, registered 40 tests, unregistered 50 tests.
- ch34 : All 4 tests, registered 4 tests, unregistered 0 tests.
- ch35 : All 208 tests, registered 142 tests, unregistered 66 tests.
- ch36 : All 91 tests, registered 77 tests, unregistered 14 tests.
- ch37 : All 262 tests, registered 244 tests, unregistered 18 tests.
- ch38 : All 166 tests, registered 138 tests, unregistered 28 tests.
- ch39 : All 50 tests, registered 42 tests, unregistered 8 tests.
- ch40 : All 40 tests, registered 30 tests, unregistered 10 tests.

<a id="更新検査"></a>

## Update and check

```sh
python3 tools/requirement_matching.py --update
python3 tools/requirement_matching.py --check
```

`--check` detects the age of the table by changing the input and correspondence. The fact that an unregistered item remains does not in itself fail.
