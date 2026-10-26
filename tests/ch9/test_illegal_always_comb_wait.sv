/*
:name: test_illegal_always_comb_wait
:description: an always_comb procedure cannot contain a wait statement, which blocks
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_comb procedure contains a wait statement
:expected_stderr_regex: test_illegal_always_comb_wait\.sv:24:
*/
// IEEE 1800-2023 9.2.2.2.2: the statements of an always_comb procedure shall
// not include those that block, have blocking timing or event controls, or
// fork-join statements. A wait statement blocks until its condition is true,
// so it is illegal here. Icarus Verilog 13.0 rejects the wait statement, and
// the 5.052 release accepts the design.

module test_illegal_always_comb_wait;
  logic a = 0, y;

  always_comb begin
    wait (a);   // illegal: a blocking statement in always_comb
    y = a;
  end

  initial #5 $display("y=%b", y);
endmodule
