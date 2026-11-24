/*
:name: test_formal_ch16_holds_and_its_extensions
:description: A weak always property holds on a clean prefix and can fail or hold strongly after extension
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12.21 16.12.11 F.5.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: ch16_holds_and_its_extensions
*/
// Compare the one-sample prefix of always[0:2] a with all possible extensions.
// A strong property with the same incomplete range is pending.
// The completed weak property succeeds only if every sample is true.
// formal result: PASS
