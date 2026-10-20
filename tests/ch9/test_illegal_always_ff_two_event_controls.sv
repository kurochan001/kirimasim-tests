/*
:name: test_illegal_always_ff_two_event_controls
:description: An always_ff procedure cannot contain a second event control (IEEE 1800-2023 Section 9.2.2.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_ff procedure has an event control in its body besides the one at its start
:expected_stderr_regex: test_illegal_always_ff_two_event_controls\.sv:23:
*/
// IEEE 1800-2023 §9.2.2.4: an always_ff procedure contains exactly one event
// control and no blocking timing controls. The procedure below waits for a
// second edge inside its body.

module test_illegal_always_ff_two_event_controls;
  logic clk = 0;
  int q;
  always_ff @(posedge clk) begin
    q <= 1;
    @(posedge clk) q <= 2;           // illegal: a second event control
  end
endmodule
