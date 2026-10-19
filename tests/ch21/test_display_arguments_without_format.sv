/*
:name: test_display_arguments_without_format
:description: $display and $monitor print arguments without a format in default decimal, and an empty argument as a space (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1 21.2.1.2 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_arguments_without_format.expected
*/
// IEEE 1800-2023 §21.2.1.1: an expression argument of $display that no
// format specification uses is printed in the default decimal format, with
// the automatic width of 21.2.1.2: 3 characters for 8 bits, 10 for the 32
// bits of $stime, also when it is the first argument of $monitor. §21.2.1:
// an empty argument, a leading comma or two adjacent commas, prints one
// space. A conditional operator whose operands are string literals (11.4.11)
// is an expression, not a string literal: "no" chosen by it is the 24-bit
// value 24'h006e6f, printed as 28271 in 8 characters.

module test_display_arguments_without_format;
  logic [7:0] b = 8'd5;
  int sel = 0;
  reg a = 0;

  initial begin
    $display(b, "|");
    $display("x",, "y");
    $display(, "z");
    $display(sel ? "yes" : "no", "|");
    $monitor($stime,, "a=%b", a);
    #5 a = 1;
  end
endmodule
