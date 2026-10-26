/*
:name: test_net_delay_value_forms
:description: The delay of a net declaration can be an unsigned number, a real number, an identifier, a time literal or 1step, each scaled in the time unit of the module (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_delay_value_forms.expected
*/
// IEEE 1800-2023 §6.7: a net declaration may carry a delay, and a delay value
// can be an unsigned number, a real number, an identifier, a time literal or
// the form 1step. Without a time unit in the value, the delay is a number of
// the time unit of the module, which is 1 ns here, and the precision is 1 ps.
// 1step denotes that precision. Each net follows the variable src with its own
// delay: 5 ns, 2.5 ns, the parameter D = 4 ns, 3ns and one precision step.
// src rises at 1 ns, so the last transition of each net is at 1 ns plus its
// delay, and the variables record the time of that transition.

`timescale 1ns/1ps

// Neither release implements the delay of a net declaration: Icarus Verilog
// 13.0 stops at the first one and Verilator 5.052 records 0 for every
// transition. The expected output follows the standard alone.

module test_net_delay_value_forms;
  parameter int D = 4;

  logic src = 1'b0;

  wire #5 w_num;
  wire #2.5 w_real;
  wire #D w_id;
  wire #3ns w_time;
  wire #1step w_step;

  real t_num, t_real, t_id, t_time, t_step;

  assign w_num = src;
  assign w_real = src;
  assign w_id = src;
  assign w_time = src;
  assign w_step = src;

  always @(w_num) t_num = $realtime;
  always @(w_real) t_real = $realtime;
  always @(w_id) t_id = $realtime;
  always @(w_time) t_time = $realtime;
  always @(w_step) t_step = $realtime;

  initial #1 src = 1'b1;

  initial begin
    #10;
    $display("number %0.3f %b", t_num, w_num);
    $display("real %0.3f %b", t_real, w_real);
    $display("identifier %0.3f %b", t_id, w_id);
    $display("time literal %0.3f %b", t_time, w_time);
    $display("1step %0.3f %b", t_step, w_step);
  end
endmodule
