/*
:name: test_dpi_context_chain_escape_observation
:description: Observe a nonlocal return across a DPI export and check ordinary scope restoration
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_chain_escape_observation.c
:expected_stdout: @test_dpi_context_chain_escape_observation.expected
*/
`timescale 1ns/1ns

module dpi_chain_escape_side;
  import "DPI-C" context function void capture_alternate_scope();
  initial capture_alternate_scope();
endmodule

module test_dpi_context_chain_escape_observation;
  dpi_chain_escape_side side();
  import "DPI-C" context function int start_chain(input int jump_now);
  import "DPI-C" context function void nested_chain(input int jump_now);
  export "DPI-C" function exported_step;

  function int exported_step(int jump_now);
    nested_chain(jump_now);
    $display("export returned normally");
    return 41;
  endfunction

  initial begin
    int result;
    #1 result = start_chain(int'($test$plusargs("escape")));
    $display("SV observed result=%0d", result);
  end
endmodule
