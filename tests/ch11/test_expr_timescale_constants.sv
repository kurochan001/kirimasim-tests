/*
:name: test_expr_timescale_constants
:description: argument-free $timeunit and $timeprecision are constant system function calls that elaborate to -9 and -12 under timescale 1ns/1ps and can size a vector (IEEE 1800-2023 11.2.1, 20.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_timescale_constants.expected
*/
// IEEE 1800-2023 §11.2.1: a call to a timescale system function of 20.4 with
// constant arguments is a constant system function call, evaluated while the
// design is elaborated. §20.4: $timeunit and $timeprecision without an
// argument return the time unit and precision of the current scope as the
// exponent of the power of ten, so timescale 1ns/1ps gives -9 and -12. The
// test uses both calls in localparam initializers and the negated unit as the
// width of a vector, then prints them and the width of that vector. Neither
// Icarus Verilog 13.0 nor Verilator 5.052 evaluates these calls in a constant
// expression, so the expected output follows the clauses.

`timescale 1ns/1ps

module test_expr_timescale_constants;
  localparam int TU = $timeunit;
  localparam int TP = $timeprecision;
  localparam int W = -TU;
  logic [W-1:0] v;

  initial begin
    $display("tu=%0d tp=%0d w=%0d bits=%0d", TU, TP, W, $bits(v));
    #1 $display("at=%0d", $time);
    $finish;
  end
endmodule
