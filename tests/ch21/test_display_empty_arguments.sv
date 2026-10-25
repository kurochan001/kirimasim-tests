/*
:name: test_display_empty_arguments
:description: an empty argument of $write or $display, at the start, at the end or between two commas, prints one space, and a lone comma is two empty arguments (IEEE 1800-2023 Section 21.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_empty_arguments.expected
*/
// IEEE 1800-2023 §21.2.1: a comma at the start or at the end of the argument
// list, or two commas next to each other, mark an empty argument, which is
// shown as one space; an argument list that is only a comma holds two empty
// arguments. White space around the commas does not matter.
// The calls below write two lines with no space of their own, so every space
// in the output comes from an empty argument: a leading one, a trailing one,
// a lone comma (two spaces), one between two strings, two in a row (two
// spaces), and one
// between two 1-bit values, which are shown in decimal with one digit.
// Release 5.052 of Verilator rejects $write(,) with a syntax error.

module test_display_empty_arguments;
  initial begin
    $write("<");
    $write(,"a");
    $write("b",);
    $write(,);
    $write("c",,"d");
    $write("e", , ,"f");
    $display(">");
    $write("[");
    $write(1'b1,,1'b0);
    $display("]");
  end
endmodule
