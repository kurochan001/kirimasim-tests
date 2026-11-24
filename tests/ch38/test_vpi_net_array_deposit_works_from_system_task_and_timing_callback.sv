/*
:name: test_vpi_net_array_deposit_works_from_system_task_and_timing_callback
:description: A bulk net deposit from a system task and a time callback updates separate matching arrays
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 38.36.2 38.37
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_array_deposit_works_from_system_task_and_timing_callback.c
:expected_stdout: @test_vpi_net_array_deposit_works_from_system_task_and_timing_callback.expected
*/
`timescale 1ns/1ns
module test_vpi_net_array_deposit_works_from_system_task_and_timing_callback;
  logic [7:0] sources [0:2];
  wire [7:0] task_wires [0:2], callback_wires [0:2];
  assign task_wires = sources;
  assign callback_wires = sources;

  task automatic sample(input string label_text);
    $display("%s task=%h/%h/%h callback=%h/%h/%h", label_text,
             task_wires[0], task_wires[1], task_wires[2],
             callback_wires[0], callback_wires[1], callback_wires[2]);
  endtask

  initial begin
    sources = '{8'h14, 8'h35, 8'h36};
    #1 sample("initial");
    #1 $deposit_from_system_task;
    #1 sample("deposited");
    $finish(0);
  end
endmodule
