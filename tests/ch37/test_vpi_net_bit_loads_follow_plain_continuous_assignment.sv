/*
:name: test_vpi_net_bit_loads_follow_plain_continuous_assignment
:description: Each bit of a vector net reaches its own continuous assignment bit as a load
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.46 37.47 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_continuous_assignment_bit_loads.c
:expected_stdout: @test_vpi_net_bit_loads_follow_plain_continuous_assignment.expected
*/
module test_vpi_net_bit_loads_follow_plain_continuous_assignment;
  logic [3:0] drive = 4'b1010;
  wire [3:0] source, destination;
  assign source = drive;
  assign destination = source;

  initial begin
    #1;
    $display("hdl destination=%b", destination);
    $vt_cont_assignment_bit_loads(0);
  end
endmodule
