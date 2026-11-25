/*
:name: test_vpi_callback_relationship_arrows
:description: Retrieve callbacks from a primitive terminal, expression, statement and time queue, and scan unrelated callbacks separately
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.4.3 37.80 37.81 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callback_relationship_arrows.c
:expected_stdout: @test_vpi_callback_relationship_arrows.expected
*/
`timescale 1ns/1ns

module test_vpi_callback_relationship_arrows;
  logic [1:0] sources = 2'b00;
  wire parity, inverted;
  assign parity = ^sources;
  not input_gate(inverted, sources[0]);

  initial begin : changes
    #4 sources = 2'b01;
    while (sources == 2'b01)
      sources = 2'b10;
    #1 $display("stimulus parity=%b inverted=%b", parity, inverted);
  end

  initial begin
    #1 $inspect_callback_arrows;
    #7 $report_callback_arrows;
  end
endmodule
