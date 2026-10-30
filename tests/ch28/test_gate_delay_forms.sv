/*
:name: test_gate_delay_forms
:description: A delay value as an unsigned number, a real number, a package-scoped identifier, a time literal and 1step, a two-value delay on an n-input gate and on a buf gate, a three-value delay on a bufif1 gate, and the third value as the turn-off delay (IEEE 1800-2023 Sections 28.3.3, 28.4 and 28.16)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.3 28.16 28.4 A.2.2.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_delay_forms.expected
*/
// IEEE 1800-2023 A.2.2.3: a delay value is an unsigned number, a real
// number, a package-scoped identifier, a time literal or 1step; delay2 is a
// delay value or a parenthesized list of one or two expressions, and delay3
// is a delay value or a parenthesized list of one to three expressions.
// 28.16: the first value of a delay is the rise delay, the second the fall
// delay and the third the turn-off delay. A buf or not gate takes delay2, at
// most two values (28.5), so the three-value delays are on bufif1 gates, an
// enable gate with delay3 (28.6) whose control input is held at 1 or used to
// turn the output off.
//   - in dl_edges, e rises at 10 and falls at 30, and nine gates drive their
//     own nets: 1step, the two values 1 and 2, the time literal 2.5ns, the
//     real number 3.5, the three values 4, 5 and 6, the two values 6 and 7
//     on an and gate, the unsigned number 8, and the package-scoped
//     identifier dpkg::D, which is 9,
//   - each always block prints the time of a rising or a falling edge, so
//     the expected time is the edge time plus the delay of that direction,
//   - in dl_off, the control en of a bufif1 that passes 1 falls at 10; the
//     third value 4.5 of its delay is the turn-off delay, so its output
//     becomes z at 14.5.
//
// Icarus Verilog 13.0 does not accept 1step or the package-scoped
// identifier. Verilator 5.052 does not use gate delays here.

`timescale 1ns/1ps

package dpkg;
  parameter int D = 9;
endpackage

module dl_edges;
  logic e = 1'b0;
  wire d_step, d_two, d_time, d_real, d_three, d_and, d_uns, d_ps;

  buf #1step u_step (d_step, e);
  buf #(1, 2) u_two (d_two, e);
  buf #2.5ns u_time (d_time, e);
  buf #3.5 u_real (d_real, e);
  bufif1 #(4, 5, 6) u_three (d_three, e, 1'b1);
  and #(6, 7) u_and (d_and, e, 1'b1);
  buf #8 u_uns (d_uns, e);
  buf #dpkg::D u_ps (d_ps, e);

  always @(d_step) if (d_step === 1'b1) $display("step_rise=%0.3f", $realtime);
  always @(d_step) if (d_step === 1'b0 && $realtime > 20) $display("step_fall=%0.3f", $realtime);
  always @(d_two) if (d_two === 1'b1) $display("two_rise=%0.3f", $realtime);
  always @(d_two) if (d_two === 1'b0 && $realtime > 20) $display("two_fall=%0.3f", $realtime);
  always @(d_time) if (d_time === 1'b1) $display("time_rise=%0.3f", $realtime);
  always @(d_time) if (d_time === 1'b0 && $realtime > 20) $display("time_fall=%0.3f", $realtime);
  always @(d_real) if (d_real === 1'b1) $display("real_rise=%0.3f", $realtime);
  always @(d_real) if (d_real === 1'b0 && $realtime > 20) $display("real_fall=%0.3f", $realtime);
  always @(d_three) if (d_three === 1'b1) $display("three_rise=%0.3f", $realtime);
  always @(d_three) if (d_three === 1'b0 && $realtime > 20) $display("three_fall=%0.3f", $realtime);
  always @(d_and) if (d_and === 1'b1) $display("and_rise=%0.3f", $realtime);
  always @(d_and) if (d_and === 1'b0 && $realtime > 20) $display("and_fall=%0.3f", $realtime);
  always @(d_uns) if (d_uns === 1'b1) $display("uns_rise=%0.3f", $realtime);
  always @(d_uns) if (d_uns === 1'b0 && $realtime > 20) $display("uns_fall=%0.3f", $realtime);
  always @(d_ps) if (d_ps === 1'b1) $display("ps_rise=%0.3f", $realtime);
  always @(d_ps) if (d_ps === 1'b0 && $realtime > 20) $display("ps_fall=%0.3f", $realtime);

  initial begin
    #10 e = 1'b1;
    #20 e = 1'b0;
  end
endmodule

module dl_off;
  logic en = 1'b1;
  wire y;

  bufif1 #(2, 3, 4.5) u_off (y, 1'b1, en);

  always @(y) if (y === 1'bz) $display("off_turnoff=%0.3f", $realtime);

  initial #10 en = 1'b0;
endmodule

module test_gate_delay_forms;
  dl_edges ue ();
  dl_off uo ();

  initial #60 $finish;
endmodule
