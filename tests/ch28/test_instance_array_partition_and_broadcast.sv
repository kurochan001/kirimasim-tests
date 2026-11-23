/*
:name: test_instance_array_partition_and_broadcast
:description: Ascending and descending instance arrays take two-bit slices from a packed bus and broadcast a single port width
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.6 23.3.3.5
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: instance_array_ports/two_bit_lane.sv
:expected_stdout: @test_instance_array_partition_and_broadcast.expected
*/
module test_instance_array_partition_and_broadcast;
  logic [2:9] bus;
  wire [5:0] up_result, down_result, broadcast_result;
  partition_lane up[4:6](bus[3+:6], up_result);
  partition_lane down[6:4](bus[3+:6], down_result);
  partition_lane shared_input[4:6](bus[3+:2], broadcast_result);

  task automatic show();
    // Read physical indices in the same order for both declarations.
    $display("up=%b,%b,%b down=%b,%b,%b",
             up[4].data, up[5].data, up[6].data,
             down[4].data, down[5].data, down[6].data);
    $display("outputs=%b,%b broadcast=%b",
             up_result, down_result, broadcast_result);
  endtask

  initial begin
    bus = 8'b1_01_11_10_0;
    #1 show();
    bus = 8'b0_10_00_01_1;
    #1 show();
  end
endmodule
