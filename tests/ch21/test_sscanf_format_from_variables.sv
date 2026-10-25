/*
:name: test_sscanf_format_from_variables
:description: The format of $sscanf can be a string literal, a string variable or an integral variable holding the characters, and the same format with white space, an ordinary character, a suppressed conversion and a field width reads the same input the same way from each of them (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_format_from_variables.expected
*/
// IEEE 1800-2023 §21.3.4.3: the format of $sscanf is an expression of a string
// literal, the string type or an integral type. It holds white space, which
// skips input white space, ordinary characters, which have to match the input,
// and conversions with an optional * that suppresses the assignment and an
// optional maximum field width. The format "%*d %2d:%d" is given as a literal,
// as a string variable and as an 80-bit variable. On "99 12:7" the 99 is read
// and dropped, 12 and 7 are assigned and the result is 2. On "99 123:7" the
// width 2 stops the field after 12, the colon does not match the 3 and the
// result is 1. A value that was not assigned keeps -1. Icarus Verilog 13.0
// stops with a segmentation fault at the first call with the string variable
// as format, and the 5.052 release of Verilator accepts only a string literal
// as format.

module test_sscanf_format_from_variables;
  int n, a, b;
  string fmt_s;
  logic [8*10-1:0] fmt_i;

  initial begin
    fmt_s = "%*d %2d:%d";
    fmt_i = "%*d %2d:%d";

    a = -1; b = -1; n = $sscanf("99 12:7", "%*d %2d:%d", a, b);
    $display("literal: n=%0d a=%0d b=%0d", n, a, b);
    a = -1; b = -1; n = $sscanf("99 123:7", "%*d %2d:%d", a, b);
    $display("literal: n=%0d a=%0d b=%0d", n, a, b);

    a = -1; b = -1; n = $sscanf("99 12:7", fmt_s, a, b);
    $display("string: n=%0d a=%0d b=%0d", n, a, b);
    a = -1; b = -1; n = $sscanf("99 123:7", fmt_s, a, b);
    $display("string: n=%0d a=%0d b=%0d", n, a, b);

    a = -1; b = -1; n = $sscanf("99 12:7", fmt_i, a, b);
    $display("integral: n=%0d a=%0d b=%0d", n, a, b);
    a = -1; b = -1; n = $sscanf("99 123:7", fmt_i, a, b);
    $display("integral: n=%0d a=%0d b=%0d", n, a, b);
  end
endmodule
