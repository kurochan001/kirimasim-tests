/*
:name: test_array_invalid_index_read_chandle
:description: reading an unpacked array of chandles that C code has set to non-null pointers with an out-of-bounds index or an index with an x bit gives null (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 6.14
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_array_invalid_index_read_chandle.c
:expected_stdout: @test_array_invalid_index_read_chandle.expected
*/
// IEEE 1800-2023 §7.4.5: reading an unpacked array with an invalid index (out
// of bounds, or with an x or z bit) returns the value of Table 7-1 for its
// element type, which is null for chandle (§6.14).
// A chandle can only be non-null when C code provides the pointer, so the
// imported function c_token returns the address of a C variable for each
// element, and c_token_value reads that variable back through a chandle. The
// valid index 1 thus reads a non-null chandle, while the out-of-bounds index 7
// and the index 2'b1x have to read null.
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 returns a stored non-null
// chandle for both invalid indices.

module test_array_invalid_index_read_chandle;
  import "DPI-C" function chandle c_token(input int k);
  import "DPI-C" function int c_token_value(input chandle h);

  chandle ch [0:3];
  int oob = 7;
  logic [1:0] xi = 2'b1x;

  initial begin
    foreach (ch[k]) ch[k] = c_token(k);
    $display("valid: null=%0d value=%0d", ch[1] == null, c_token_value(ch[1]));
    $display("out of bounds: null=%0d", ch[oob] == null);
    $display("x index: null=%0d", ch[xi] == null);
  end
endmodule
