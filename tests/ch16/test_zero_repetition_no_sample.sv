/*
:name: test_zero_repetition_no_sample
:description: Zero repetition takes no sample, so empty ##1 b and an empty antecedent of |=> check b at the current tick; both assertions fail at time 10 and pass at time 20 (IEEE 1800-2023 Sections 16.9.2.1, 16.12.7 and 16.12.22)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.22 16.9.2.1 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_zero_repetition_no_sample.expected
*/
// IEEE 1800-2023 16.12.22: a[*0] is empty and takes no sample of a.
// Section 16.9.2.1 reduces a[*0] ##1 b to b at the current tick.
// Section 16.12.7 also aligns the consequent of an empty antecedent of |=>
// to the current tick in this singly clocked property.
// At time 10 start is 1 and b is 0, so both assertions fail immediately.
// At time 20 start and b are 1, so both new attempts pass immediately.
// The counters printed at time 25 are one pass and one failure per assertion;
// no attempt remains pending for a clock tick at time 30. The value of a,
// which stays 0, does not affect either empty match.

`timescale 1ns/1ns

module test_zero_repetition_no_sample;
  logic clk = 0;
  logic start = 0;
  logic a = 0;
  logic b = 0;
  int pass_zero = 0, fail_zero = 0;
  int pass_ant = 0, fail_ant = 0;

  p_zero: assert property (@(posedge clk) start |-> (a[*0] ##1 b))
    pass_zero++; else fail_zero++;
  p_ant: assert property (@(posedge clk) (a[*0]) |=> b)
    pass_ant++; else fail_ant++;

  initial begin
    #5 start = 1;          // 5: start is 1 at the edge at 10
    #5 clk = 1;            // 10: first attempts check b=0 and fail
    #5 clk = 0;            // 15
    #4 b = 1;              // 19: b is 1 at the edge at 20
    #1 clk = 1;            // 20: new attempts check b=1 and pass
    #5 $display("zero: pass=%0d fail=%0d; antecedent: pass=%0d fail=%0d",
                pass_zero, fail_zero, pass_ant, fail_ant);
    $finish;
  end
endmodule
