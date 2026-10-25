/*
:name: test_macro_use_space_before_arguments
:description: White space is allowed between the name of a macro and the parenthesis of its actual arguments, and for an escaped macro name it is needed, since without it the parenthesis belongs to the escaped name (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 5.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_use_space_before_arguments.expected
*/
// IEEE 1800-2023 §22.5.1: white space is allowed between the macro name and
// the left parenthesis of a macro use, and is required when the name is an
// escaped identifier. ADD2 is used with no space, a space, several spaces and
// a tab. An escaped identifier ends only at white space (5.6.1), so \tag(1) is
// a name of its own: the test defines the macro \tag(1) without arguments,
// with the text 200, and the macro \tag with the formal v. `\tag(1) then
// expands to 200, and `\tag (1), with the space, uses \tag with the actual 1.
// The 5.052 release of Verilator rejects the use of the escaped macro name
// with an argument.

`define ADD2(a, b) (a + b)
`define \tag(1) 200
`define \tag (v) (v + 1000)

module test_macro_use_space_before_arguments;
  initial begin
    $display("ADD2: %0d %0d %0d %0d", `ADD2(1, 2), `ADD2 (3, 4), `ADD2   (5, 6), `ADD2	(7, 8));
    $display("escaped: %0d %0d", `\tag(1) , `\tag (1));
  end
endmodule
