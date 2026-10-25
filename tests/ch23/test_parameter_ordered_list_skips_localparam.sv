/*
:name: test_parameter_ordered_list_skips_localparam
:description: An ordered parameter value list assigns the overridable value and type parameters in declaration order, may stop before the last ones, which keep their defaults, and passes over local parameters, in a parameter port list and among module items (IEEE 1800-2023 Section 23.10.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.2.1 23.10 6.20.1 6.20.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_ordered_list_skips_localparam.expected
*/
// IEEE 1800-2023 §23.10.2.1: the values of an ordered parameter value list
// go to the parameters in the order of their declarations in the module. The
// list may end early, and the parameters after it keep their defaults, but
// it cannot skip a parameter. Local parameters cannot be overridden, so they
// take no place in the list, even in a parameter port list; a local
// parameter keeps the value of its declaration, computed from the final
// values of the others. A type parameter takes its place like a value
// parameter (§6.20.3).
//   withports has the parameter port list A, local L = A * 2, type T, C;
//   initems has no port list, so its module items P1, local L1 = P1 + 1, P2
//   and P3 are its parameters.
// Each line shows the parameters of one instance, and for the type T its
// width $bits(T), which withports keeps in a local parameter TB.
// If the local parameters took a place, #(5, shortint) would try to give
// shortint to L and leave T a byte, and #(11, 22) would leave P2 at 20.

module parameter_ordered_list_withports
  #(parameter int A = 1, localparam int L = A * 2, parameter type T = byte,
    parameter int C = 4) ();
  localparam int TB = $bits(T);
endmodule

module parameter_ordered_list_initems;
  parameter int P1 = 10;
  localparam int L1 = P1 + 1;
  parameter int P2 = 20;
  parameter int P3 = 30;
endmodule

module test_parameter_ordered_list_skips_localparam;
  parameter_ordered_list_withports w0();
  parameter_ordered_list_withports #(5) w1();
  parameter_ordered_list_withports #(5, shortint) w2();
  parameter_ordered_list_withports #(5, shortint, 9) w3();
  parameter_ordered_list_initems i0();
  parameter_ordered_list_initems #(11) i1();
  parameter_ordered_list_initems #(11, 22) i2();
  parameter_ordered_list_initems #(11, 22, 33) i3();

  initial begin
    $display("w0: A=%0d L=%0d T=%0d C=%0d", w0.A, w0.L, w0.TB, w0.C);
    $display("w1: A=%0d L=%0d T=%0d C=%0d", w1.A, w1.L, w1.TB, w1.C);
    $display("w2: A=%0d L=%0d T=%0d C=%0d", w2.A, w2.L, w2.TB, w2.C);
    $display("w3: A=%0d L=%0d T=%0d C=%0d", w3.A, w3.L, w3.TB, w3.C);
    $display("i0: P1=%0d L1=%0d P2=%0d P3=%0d", i0.P1, i0.L1, i0.P2, i0.P3);
    $display("i1: P1=%0d L1=%0d P2=%0d P3=%0d", i1.P1, i1.L1, i1.P2, i1.P3);
    $display("i2: P1=%0d L1=%0d P2=%0d P3=%0d", i2.P1, i2.L1, i2.P2, i2.P3);
    $display("i3: P1=%0d L1=%0d P2=%0d P3=%0d", i3.P1, i3.L1, i3.P2, i3.P3);
  end
endmodule
