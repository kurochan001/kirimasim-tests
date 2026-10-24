/*
:name: test_illegal_begin_keywords_unknown_version
:description: An implementation that does not recognize the version specifier of `begin_keywords has to report an error, so the specifier 1800-1999, which names no version, is an error (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: 1800-1999 is not one of the version specifiers of `begin_keywords and names no version of IEEE Std 1800
:expected_stderr_regex: test_illegal_begin_keywords_unknown_version\.sv:31:
*/
// IEEE 1800-2023 §22.14: the version specifier of `begin_keywords is one of
// the versions of IEEE Std 1364 or 1800 that the clause lists, or a custom
// one that an implementation adds; it shall be an error if the
// implementation does not recognize it. There has never been a version
// 1800-1999, so the specifier below names no keyword set. The first pair
// uses a listed specifier and is legal.
// Icarus Verilog 13.0 prints that it ignores the unknown string and accepts
// the design.
// The second `begin_keywords is rejected by Verilator 5.052, which reports
// it as an undefined directive because it takes `begin_keywords only with a
// specifier it knows; it accepts the first pair.

`begin_keywords "1800-2012"
module keywords_known_version;
endmodule
`end_keywords

`begin_keywords "1800-1999"  // illegal: not a known version specifier
module test_illegal_begin_keywords_unknown_version;
endmodule
`end_keywords
