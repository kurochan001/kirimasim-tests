/*
:name: test_illegal_chandle_dereference
:description: a chandle cannot be dereferenced as a class handle
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the marked access selects a member of a chandle
:expected_stderr_regex: test_illegal_chandle_dereference\.sv:24:
*/
// IEEE 1800-2023 8.4: a chandle is an opaque handle whose contents cannot be
// accessed from SystemVerilog; only class object handles can select members.
// The marked statement selects a member of a chandle, which a tool has to
// reject.

module test_illegal_chandle_dereference;
  chandle h;
  int v;
  initial begin
    h = null;
    v = h.value; // illegal: a chandle has no members
  end
endmodule
