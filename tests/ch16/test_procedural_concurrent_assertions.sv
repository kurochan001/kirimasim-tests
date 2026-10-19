/*
:name: test_procedural_concurrent_assertions
:description: a concurrent assertion in an always procedure is queued each time it is reached, with the current values of automatic variables and const casts but the sampled values of static variables, is clocked by the procedure's event control, and is flushed when the procedure is disabled before the Observed region (IEEE 1800-2023 Sections 16.14.6, 16.14.6.1, 16.14.6.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6 16.14.6.1 16.14.6.4 16.5.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_concurrent_assertions.expected
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion in procedural code is placed
// on the procedure's queue each time it is reached, in a loop once per
// iteration, and only when the code around it runs; its clock is inferred
// from the procedure's single event control. §16.14.6.1: automatic variables
// and const casts keep their values at the time the assertion is queued,
// while static variables are sampled values (§16.5.1): after the first tick
// the static loop variable j is sampled as 4, its value after the loop of the
// previous tick, so all four instances check foo[4]. §16.14.6.4: disabling
// the outermost scope of the procedure flushes its queue. foo is 5'b01011, so
// foo[2] and foo[4] are 0; en is high at the second tick and stop at the
// third. The fail actions (§16.14.1) count the failures of three ticks.

`timescale 1ns/1ns

module test_procedural_concurrent_assertions;
  logic clk = 0, en = 0, stop = 0;
  logic [4:0] foo = 5'b01011;
  int f_auto = 0, f_static = 0, f_const = 0, f_cond = 0, f_dis = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25

  always @(posedge clk) begin
    int j;
    for (int i = 0; i < 4; i++)
      a_auto: assert property (foo[i]) else f_auto++;
    for (j = 0; j < 4; j++) begin
      a_static: assert property (foo[j]) else f_static++;
      a_const: assert property (foo[const'(j)]) else f_const++;
    end
    if (en)
      a_cond: assert property (foo[1] == 1'b0) else f_cond++;
  end

  always @(posedge clk) begin : b_dis
    a_dis: assert property (1'b0) else f_dis++;
    if (stop) disable b_dis;
  end

  initial begin
    #10 en = 1;
    #10 en = 0;
    stop = 1;
    #10;
    $display("automatic loop variable: %0d failures", f_auto);
    $display("static loop variable: %0d failures", f_static);
    $display("const'(j): %0d failures", f_const);
    $display("inside if (en): %0d failures", f_cond);
    $display("disabled at the third tick: %0d failures", f_dis);
    $finish;
  end
endmodule
