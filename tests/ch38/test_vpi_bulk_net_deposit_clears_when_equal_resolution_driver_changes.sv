/*
:name: test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes
:description: A bulk net deposit ends per element when either driver changes even if the resolved value was unchanged
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 6.6.1 28.12
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes.c
:expected_stdout: @test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes.expected
*/
`timescale 1ns/1ns
module test_vpi_bulk_net_deposit_clears_when_equal_resolution_driver_changes;
  logic [3:0] first_driver [3:6], second_driver [3:6];
  wire [3:0] bus [3:6];

  for (genvar i = 3; i <= 6; i++) begin : lanes
    assign bus[i] = first_driver[i];
    assign bus[i] = second_driver[i];
  end

  task automatic sample(input string label_text);
    $display("%s=%h/%h/%h/%h", label_text, bus[3], bus[4], bus[5], bus[6]);
  endtask

  initial begin
    first_driver = '{4'h9, 4'hc, 4'ha, 4'h7};
    second_driver = '{4'hz, 4'hc, 4'hz, 4'hz};
    #1 sample("drivers");
    #2 sample("deposited");
    first_driver[3] = 4'h6;
    #1 sample("unrelated driver");
    #2 sample("second deposit");
    first_driver[4] = 4'hz;
    #1 sample("equal resolution driver");
    second_driver[5] = 4'h5;
    #1 sample("conflicting driver");
    $finish(0);
  end
endmodule
