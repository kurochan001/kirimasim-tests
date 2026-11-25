/*
:name: test_scalared_net_vpi_expansion
:description: VPI expansion and bit values of a scalared logic net
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scalared_net_vpi_expansion.expected
:vpi_c: @test_advisory_net_vpi_expansion.c
*/
module test_scalared_net_vpi_expansion;
  wire scalared [4:6] scalar_bus = 3'b110;

  initial begin
    #1;
    $display("hdl scalared=%b", scalar_bus);
    $vt_net_expansion;
    $finish;
  end
endmodule
