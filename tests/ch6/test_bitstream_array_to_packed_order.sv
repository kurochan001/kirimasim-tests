/*
:name: test_bitstream_array_to_packed_order
:description: Bit stream casts place the first unpacked element at the most significant end (IEEE 1800-2023 Section 6.24.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitstream_array_to_packed_order.expected
*/
// IEEE 1800-2023 6.24.3: Fixed unpacked arrays are cast as a complete bit
// stream in declared left-to-right order; the reverse cast restores each
// element.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_bitstream_array_to_packed_order;
  typedef bit [7:0] bytes_t [2:0];
  typedef bit [23:0] word_t;
  bytes_t bytes, restored;
  word_t packed_word;
  initial begin
    bytes = '{8'h12, 8'hab, 8'h34};
    packed_word = word_t'(bytes);
    restored = bytes_t'(24'hfedcba);
    $display("packed=%h restored=%h,%h,%h", packed_word,
             restored[2], restored[1], restored[0]);
  end
endmodule
