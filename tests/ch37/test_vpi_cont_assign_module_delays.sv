/*
:name: test_vpi_cont_assign_module_delays
:description: a continuous assignment leads to the module instance that holds it, and the assignment and each of its bits give the delay written in the source through vpiDelay, a constant for one delay and a list operation for two, give the same delays through vpi_get_delays and give their values through vpi_get_value (IEEE 1800-2023 Section 37.47)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.47 37.3.4 38.10 38.15 10.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_cont_assign_module_delays.c
:expected_stdout: @test_vpi_cont_assign_module_delays.expected
*/
// IEEE 1800-2023 §37.47: a cont assign has a one-to-one relation to its
// module, here the top module for the assignment to w and the instance s for
// the one to o. vpiDelay belongs to the cont assign class, so the assignment
// and each cont assign bit (vpiBit) lead to the delay expression of the
// source: by §37.3.4 an expression that evaluates to the constant for the one
// delay #4 and an operation of type vpiListOp for the two delays #(2, 3)
// (10.3.3). Delay and value are properties of the class as well: vpi_get_delays
// (38.10) returns the delays in source order, as many as are written, in the
// time unit of the modules, 1 ns, and vpi_get_value (38.15) returns the value
// of the assignment, a vector, and of a bit, a scalar; vpiOffset is 0 for the
// LSB (detail 3). At 10 all values have settled: w is 0101 and o, the
// complement of a, is 1010. The operands of a list are printed sorted.

`timescale 1ns/1ns

module test_vpi_cont_assign_module_delays_sub (input wire [3:0] i, output wire [3:0] o);
  assign #(2, 3) o = ~i;
endmodule

module test_vpi_cont_assign_module_delays;
  logic [3:0] a = 4'b0101;
  wire [3:0] w, o;

  assign #4 w = a;
  test_vpi_cont_assign_module_delays_sub s (.i(a), .o(o));

  initial #10 $vt_assigns;
endmodule
