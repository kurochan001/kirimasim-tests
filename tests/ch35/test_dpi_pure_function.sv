/*
:name: test_dpi_pure_function
:description: A pure imported function can be used wherever a function call can, including a continuous assignment that follows its inputs (IEEE 1800-2023 Section 35.5.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.2 35.5.4 10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_pure_function.c
:expected_stdout: @test_dpi_pure_function.expected
*/
// IEEE 1800-2023 §35.5.2: a pure import is a non-void function without output
// or inout arguments whose result depends only on its inputs; a call may be
// left out or its earlier result reused, which cannot change the result of this
// test, because dpi_gcd has no side effects. The function is used in a
// continuous assignment (10.3), which is evaluated again when a or b changes.

`timescale 1ns/1ns

module test_dpi_pure_function;
  import "DPI-C" pure function int dpi_gcd(input int a, input int b);

  int a = 48, b = 18;
  wire [31:0] g;

  assign g = dpi_gcd(a, b);

  initial begin
    #1 $display("gcd(%0d, %0d) = %0d", a, b, g);
    a = 35;
    b = 14;
    #1 $display("gcd(%0d, %0d) = %0d", a, b, g);
    $display("gcd(1071, 462) = %0d", dpi_gcd(1071, 462));
  end
endmodule
