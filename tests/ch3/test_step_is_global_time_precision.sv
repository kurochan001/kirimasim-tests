/*
:name: test_step_is_global_time_precision
:description: The step time unit is the global time precision, so a #1step delay in a module with a time unit of 1 ns and the global precision of 1 ps lasts 1 ps, and an input skew of 1step in a module whose own precision is 1 ns samples a change made 1 ps before the clock edge, which an input skew of #1 misses (IEEE 1800-2023 Section 3.14.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.3 14.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_step_is_global_time_precision.expected
*/
// IEEE 1800-2023 §3.14.3: the global time precision is the finest precision
// in the design, and the step time unit is equal to it. §14.4: an input skew
// of 1step samples the signal at the end of the previous time step, that is,
// its last value just before the clock edge; an input skew given as a number
// is that many time units of the scope before the edge.
// The top module has the time unit and precision 1 ns. The module
// step_source declares the time unit 1 ns and the precision 1 ps, the finest
// in the design, so the global precision and the step are 1 ps.
// - step_source starts a #1step delay at 0; it ends at 1 ps, which is 0.001
//   in its time unit. Had the step been its time unit, it would end at 1.000.
// - step_source drives d from 0 to 1 at 9.999 ns, and clk rises at 10 ns.
//   The clocking block c_step samples d with the skew 1step, at the end of
//   the time step at 9.999 ns, and gets 1; c_one samples it 1 ns (#1 in the
//   top module) before the edge, at 9 ns, and gets 0. Had the step been the
//   precision or the time unit of the top module, 1 ns, c_step would also
//   get 0. Both clocking variables are read at 12 ns, after the edge.
// The 5.054 release of Verilator produces this output; Icarus Verilog 13.0
// stops with a syntax error at the first clocking block.

`timescale 1ns/1ns

module test_step_is_global_time_precision;
  logic clk = 1'b0;
  wire d;

  step_source src (.q(d));

  clocking c_step @(posedge clk);
    input #1step d;
  endclocking

  clocking c_one @(posedge clk);
    input #1 d;
  endclocking

  initial begin
    #10 clk = 1'b1;
    #2 $display("at 12 ns: 1step sample %b, #1 sample %b", c_step.d, c_one.d);
  end
endmodule

module step_source (output logic q);
  timeunit 1ns;
  timeprecision 1ps;

  initial begin
    q = 1'b0;
    #9.999 q = 1'b1;
  end

  initial begin
    #1step;
    $display("#1step ended at %0.3f ns", $realtime);
  end
endmodule
