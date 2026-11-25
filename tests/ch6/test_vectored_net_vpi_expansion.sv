/*
:name: test_vectored_net_vpi_expansion
:description: VPI bit values in either permitted expansion mode of a vectored logic net
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vectored_net_vpi_expansion.expected
:vpi_c: @test_advisory_net_vpi_expansion.c
*/
module test_vectored_net_vpi_expansion;
  wire vectored [6:4] vector_bus = 3'b001;

  initial begin
    #1;
    $display("hdl vectored=%b", vector_bus);
    $vt_net_expansion;
    $finish;
  end
endmodule
