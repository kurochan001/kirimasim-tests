/*
:name: test_illegal_let_sampled_value_without_clock
:description: a sampled value function in the body of a let takes its clock from the place where the let is used, and it is an error if no clock can be inferred there (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the let past_a, whose body calls $past without a clock, is used in an initial procedure that has no clock to infer, and there is no default clocking
:expected_stderr_regex: test_illegal_let_sampled_value_without_clock\.sv:(30|37):
*/
// IEEE 1800-2023 §11.12: the clock of a sampled value function call in a let
// body, if not given, is inferred where the let is instantiated, as if the
// function were called there; it shall be an error if a clock is required
// but cannot be inferred. In always @(posedge clk) the clock posedge clk is
// inferred for past_a (16.9.3, 16.14.6), which is legal; the initial
// procedure has no event control from which a clock could be inferred, and
// the module has no default clocking. A tool can report the use of past_a
// or the call of $past in its body.
// Icarus Verilog 13.0 does not support let declarations.

`timescale 1ns/1ns

module test_illegal_let_sampled_value_without_clock;
  logic clk = 1'b0, a = 1'b0;
  logic r1, r2, r3;

  let past_a = $past(a);   // (or reported here)

  always #5 clk = ~clk;
  always @(posedge clk) r1 <= past_a;

  initial begin
    #12 r2 = a;
    r3 = past_a;   // illegal: no clock can be inferred here
    #20 $display("%b %b", r1, r2);
    $finish;
  end
endmodule
