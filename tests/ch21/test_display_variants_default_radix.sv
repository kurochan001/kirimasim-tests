/*
:name: test_display_variants_default_radix
:description: $display, $write and their b, o and h variants show an argument without a format in decimal, binary, octal and hexadecimal, and the variants accept an empty argument list (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1 21.2.1.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_variants_default_radix.expected
*/
// IEEE 1800-2023 §21.2.1 names eight display tasks, $display, $displayb,
// $displayo, $displayh, $write, $writeb, $writeo and $writeh, each with an
// optional argument list. §21.2.1.1: an expression with no format of its own
// is shown in decimal by $display and $write, in binary by the b variants, in
// octal by the o variants and in hexadecimal by the h variants. §21.2.1.2
// sizes the field automatically: an 8-bit value takes three decimal columns
// with leading spaces, 8 binary digits, 3 octal digits and 2 hexadecimal
// digits with leading zeros; a 12-bit value takes 3 hexadecimal digits.
// v is 45 (binary 00101101, octal 055, hexadecimal 2d) and w is 300
// (hexadecimal 12c). A format in the string still applies to the argument it
// takes, and only the next one falls back to the default radix. The h, b and
// o variants of $write without arguments add nothing between "x" and "y".

module test_display_variants_default_radix;
  logic [7:0] v = 8'd45;
  logic [11:0] w = 12'd300;

  initial begin
    $display("[", v, "]");
    $displayb("[", v, "]");
    $displayo("[", v, "]");
    $displayh("[", v, "]");
    $write("[", v, "|");
    $writeb(v, "|");
    $writeo(v, "|");
    $writeh(v, "]");
    $display;
    $displayh("[%0d|", v, v, "|", w, "]");
    $write("x");
    $writeb;
    $writeo();
    $writeh;
    $display("y");
  end
endmodule
