/*
:name: test_illegal_cg_transition_array_unbounded
:description: a transition bin array may not use a sequence of unbounded or undetermined varying length (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin array many uses the nonconsecutive repetition 1[=2], whose length is unbounded and varies
:expected_stderr_regex: test_illegal_cg_transition_array_unbounded\.sv:28:
*/
// IEEE 1800-2023 §19.5.2: transitions of unbounded or undetermined varying
// length cannot be used with the multiple bins construct, the [] notation.
// The bin array ok[] uses the bounded transition 1=>2, and the single bin
// single uses the same transition without []; both are legal. The bin array
// many[] uses 1[=2], a nonconsecutive repetition whose length is unbounded
// and varies, which is the one error.

module test_illegal_cg_transition_array_unbounded;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins ok[] = (1 => 2);
      bins single = (1 => 2);
      bins many[] = (1 [= 2]);   // illegal: unbounded sequence in a [] bin
    }
  endgroup

  cg g = new;

  initial begin
    $display("not reached");
  end
endmodule
