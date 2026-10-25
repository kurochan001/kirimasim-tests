/*
:name: test_swrite_unpacked_byte_array_order
:description: $swrite and $swriteh store their text into an unpacked array of bytes from its left bound to its right bound, whether the range is ascending or descending, and left-justified when the text is longer than the array (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_swrite_unpacked_byte_array_order.expected
*/
// IEEE 1800-2023 §21.3.3: the first argument of the $swrite tasks can be an
// unpacked array of bytes; its characters are ordered from the left bound of
// the array to its right bound, and it is assigned by the rules for a string
// literal (5.9), which left-justify the text in an unpacked array of bytes.
// The arrays have the ranges [0:3] and [3:0], so "wxyz" puts w into element 0
// of the first and into element 3 of the second; $swriteh of 24'habcdef puts
// the six digits into a 4-byte array, which keeps the first four. Icarus
// Verilog 13.0 rejects an unpacked array as first argument of $swrite, and the
// 5.052 release of Verilator cannot build the calls.

module test_swrite_unpacked_byte_array_order;
  byte up [0:3];
  byte dn [3:0];

  initial begin
    $swrite(up, "wxyz");
    $display("[0:3]: up[0]=%c up[1]=%c up[2]=%c up[3]=%c", up[0], up[1], up[2], up[3]);
    $swrite(dn, "wxyz");
    $display("[3:0]: dn[3]=%c dn[2]=%c dn[1]=%c dn[0]=%c", dn[3], dn[2], dn[1], dn[0]);
    $swriteh(up, 24'habcdef);
    $display("longer text: %c%c%c%c", up[0], up[1], up[2], up[3]);
  end
endmodule
