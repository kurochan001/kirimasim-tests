/*
:name: test_legacy_dpi_packed_selects_cross_canonical_word_boundary
:description: Legacy DPI scalar and part selects use normalized indexes across packed word boundaries
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.14.2 I.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_legacy_dpi_packed_selects_cross_canonical_word_boundary.expected
:dpi_c: @test_legacy_dpi_packed_selects_cross_canonical_word_boundary.c
*/
// Exercise the optional SV3.1a compatibility interface.
module test_legacy_dpi_packed_selects_cross_canonical_word_boundary;
  import "DPI" function void legacy_selects(input bit [95:0] all_bits,
                                           input logic [0:44] all_logic,
                                           output bit [95:0] bit_output,
                                           output logic [44:0] logic_output,
                                           output logic [44:0] wide_logic_output);
  bit [95:0] source_bits = 96'h2468ace0_13579bdf_8a57abcd;
  logic [44:0] source_logic = '0;
  logic [0:44] ascending_logic;
  bit [95:0] bit_output;
  logic [44:0] logic_output, wide_logic_output;

  initial begin
    source_bits[36:29] = 8'ha6;
    source_logic[36:29] = 8'b10xz01zx;
    ascending_logic = source_logic;
    legacy_selects(source_bits, ascending_logic, bit_output, logic_output, wide_logic_output);
    $display("written bit=%b/%b/%02h/%b logic=%b/%b/%b/%b",
             bit_output[95], bit_output[38], bit_output[37:30], bit_output[29],
             logic_output[44], logic_output[38], logic_output[37:30], logic_output[29]);
    $display("wide writes bit=%h logic=%h adjacent=%b%b",
             bit_output[71:40], wide_logic_output[41:10],
             wide_logic_output[42], wide_logic_output[9]);
  end
endmodule
