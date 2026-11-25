/*
:name: test_dpi_portable_logic_chunks_and_scalar_ports
:description: A prebuilt DPI object uses canonical logic chunks and a signed byte output
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.2 H.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_portable_logic_chunks_and_scalar_ports.c
:expected_stdout: @test_dpi_portable_logic_chunks_and_scalar_ports.expected
*/
module test_dpi_portable_logic_chunks_and_scalar_ports;
  import "DPI-C" function int portable_logic(input logic [64:0] data,
                                              output logic [64:0] output_data,
                                              output byte result);

  logic [64:0] output_data;
  byte result;
  int unknown;

  initial begin
    unknown = portable_logic(65'h1_99aa55cc_0011eeff, output_data, result);
    $display("DPI ABI logic=%017h byte=%0d unknown=%0d", output_data, result, unknown);
    unknown = portable_logic(65'h0_01234567_0cafe642, output_data, result);
    $display("DPI ABI logic=%017h byte=%0d unknown=%0d", output_data, result, unknown);
  end
endmodule
