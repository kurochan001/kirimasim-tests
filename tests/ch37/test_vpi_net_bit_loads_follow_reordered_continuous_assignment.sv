/*
:name: test_vpi_net_bit_loads_follow_reordered_continuous_assignment
:description: Reversed source bits lead to distinct assignment offsets through VPI net loads
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.46 37.47 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_continuous_assignment_bit_loads.c
:expected_stdout: @test_vpi_net_bit_loads_follow_reordered_continuous_assignment.expected
*/
module test_vpi_net_bit_loads_follow_reordered_continuous_assignment;
  logic [3:0] drive = 4'b1010;
  wire [3:0] source, destination;
  assign source = drive;
  assign destination = {source[0], source[1], source[2], source[3]};

  initial begin
    #1;
    $display("hdl destination=%b", destination);
    $vt_cont_assignment_bit_loads(1);
  end
endmodule
