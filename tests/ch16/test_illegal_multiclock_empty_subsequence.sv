/*
:name: test_illegal_multiclock_empty_subsequence
:description: Every maximal singly clocked subsequence of a multiclocked sequence has to admit only nonempty matches, so a posedge c2 subsequence b[*0:1] that can match empty makes the concatenation illegal (IEEE 1800-2023 Section 16.13.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the maximal singly clocked subsequence b[*0:1] admits an empty match
:expected_stderr_regex: test_illegal_multiclock_empty_subsequence\.sv:27:
*/
// IEEE 1800-2023 §16.13.1: when differently clocked sequences are
// concatenated, each maximal singly clocked subsequence shall admit only
// nonempty matches, so that the clock at the end of the sequence is well
// defined. p_ok has b under posedge c2, which cannot match empty. p_bad has
// b[*0:1] under posedge c2; the zero alternative matches the empty word, so
// it is not known whether the sequence ends at a tick of c1 or of c2. The
// standard gives this exact form as an example of an illegal sequence.

module test_illegal_multiclock_empty_subsequence;
  logic c1 = 0, c2 = 0;
  logic a = 0, b = 0;

  p_ok: assert property (@(posedge c1) a ##1 @(posedge c2) b);
  p_bad: assert property (@(posedge c1) a ##1 @(posedge c2) b[*0:1]);   // illegal
endmodule
