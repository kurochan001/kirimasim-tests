/*
:name: test_legacy_dpi_packed_whole_array_transfer
:description: Legacy DPI whole-array copies transfer two-state and four-state packed values through vendor storage
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.14.1 H.14.2 I.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_legacy_dpi_packed_whole_array_transfer.expected
:dpi_c: @test_legacy_dpi_packed_whole_array_transfer.c
*/
// Exercise the optional SV3.1a compatibility interface.
module test_legacy_dpi_packed_whole_array_transfer;
  import "DPI" function void legacy_copy(input bit [7:-37] bit_input,
                                         input logic [0:44] logic_input,
                                         output bit [0:44] bit_output,
                                         output logic [44:0] logic_output);
  bit [7:-37] bit_input = 45'h1254_0123_4567;
  logic [0:44] logic_input = 45'h125x_x123_z567;
  bit [0:44] bit_output;
  logic [44:0] logic_output;

  initial begin
    legacy_copy(bit_input, logic_input, bit_output, logic_output);
    $display("written bit=%h logic=%h", bit_output, logic_output);
  end
endmodule
