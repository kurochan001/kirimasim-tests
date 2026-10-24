/*
:name: test_illegal_automatic_variable_as_sequence_event_argument
:description: the arguments of a sequence used in an event control have to be static, not automatic variables (IEEE 1800-2023 Section 9.4.2.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.4.2.4 16.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the automatic argument v of the task wait_hi is passed to the sequence s_hi in the event control @(s_hi(v))
:expected_stderr_regex: test_illegal_automatic_variable_as_sequence_event_argument\.sv:32:
*/
// IEEE 1800-2023 §9.4.2.4: a sequence instance can be used in an event control
// to wait for the end point of the sequence. Its arguments shall be static;
// automatic variables used as sequence arguments shall result in an error.
// The initial procedure waits for s_hi(flag) with the static variable flag,
// which is legal; the automatic task wait_hi passes its automatic argument v.
// Icarus Verilog 13.0 does not support sequences; its syntax errors, one of
// them on the line of the error, do not count.

`timescale 1ns/1ns

module test_illegal_automatic_variable_as_sequence_event_argument;
  logic clk = 1'b0, flag = 1'b1;

  sequence s_hi(x);
    @(posedge clk) x;
  endsequence

  task automatic wait_hi(input logic v);
    @(s_hi(v));   // illegal: automatic variable as sequence argument
  endtask

  always #5 clk = ~clk;

  initial begin
    @(s_hi(flag));
    $display("%0t", $time);
    $finish;
  end
endmodule
