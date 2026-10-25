/*
:name: test_format_string_unpacked_byte_array_order
:description: %s accepts a string variable and an unpacked array of bytes, whose characters are taken from the left bound of the array to the right bound (IEEE 1800-2023 Section 21.2.1.7)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_string_unpacked_byte_array_order.expected
*/
// IEEE 1800-2023 §21.2.1.7: the argument of %s may also be a variable of the
// string type or an unpacked array of byte, and the characters of the array
// are printed in order from its left bound to its right bound.
// The arrays below hold different letters at each index and are declared
// with an ascending range [0:2], a descending range [2:0] and a descending
// range [3:1], so printing them in the order of the indices instead of from
// left to right would reverse the descending ones.
// Neither simulator follows the clause here: Icarus Verilog 13.0 rejects an
// unpacked array as an argument of $display, and release 5.052 of Verilator
// prints the arrays as assignment patterns of hexadecimal values.

module test_format_string_unpacked_byte_array_order;
  byte asc [0:2];
  byte desc [2:0];
  byte off [3:1];
  string str = "hello";

  initial begin
    asc[0] = "a";
    asc[1] = "b";
    asc[2] = "c";
    desc[2] = "x";
    desc[1] = "y";
    desc[0] = "z";
    off[3] = "p";
    off[2] = "q";
    off[1] = "r";
    $display("[%s][%s][%s][%s]", asc, desc, off, str);
  end
endmodule
