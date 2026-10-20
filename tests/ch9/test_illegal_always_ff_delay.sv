/*
:name: test_illegal_always_ff_delay
:description: An always_ff procedure cannot contain a delay control (IEEE 1800-2023 Section 9.2.2.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_ff procedure has a blocking delay control in its body
:expected_stderr_regex: test_illegal_always_ff_delay\.sv:21:
*/
// IEEE 1800-2023 §9.2.2.4: an always_ff procedure contains no blocking timing
// controls; the #1 below is one.

module test_illegal_always_ff_delay;
  logic clk = 0;
  int q;
  always_ff @(posedge clk) begin
    #1 q <= 1;                       // illegal: a delay control
  end
endmodule
