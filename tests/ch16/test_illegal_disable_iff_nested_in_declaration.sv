/*
:name: test_illegal_disable_iff_nested_in_declaration
:description: A property declaration cannot put a disable iff in front of an instance of a property that has one (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable iff in the body of p_out encloses the instance of p_in, whose body has its own disable iff
:expected_stderr_regex: test_illegal_disable_iff_nested_in_declaration\.sv:(31|34):
*/
// IEEE 1800-2023 §16.12: disable iff clauses shall not be nested, also not
// through a property instance in the body of another property. p_out
// writes disable iff (r1) before an instance of p_in, which has the
// clause disable iff (r2). A tool can report the error at the body of
// p_out or at the assertion that instantiates it.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_disable_iff_nested_in_declaration;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  property p_in;
    @(posedge clk) disable iff (r2) a |=> b;
  endproperty

  property p_out;
    @(posedge clk) disable iff (r1) p_in;   // illegal: nested through p_in
  endproperty

  a_out: assert property (p_out);   // illegal: instance of p_out
endmodule
