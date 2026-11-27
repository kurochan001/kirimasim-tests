/*
:name: test_virtual_interface_procedural_edge_controls
:description: Initial and task event controls may wait on a virtual interface component
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 9.4.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_procedural_edge_controls.expected
:expected_exit: 0
*/
`timescale 1ns/1ns

interface procedural_edge_bus;
  bit grant;
  int payload;
endinterface

module test_virtual_interface_procedural_edge_controls;
  procedural_edge_bus selected_bus(), other_bus();
  virtual procedural_edge_bus selected;
  time initial_edge, task_edge;
  int initial_payload, task_payload, concrete_payload;

  always_comb concrete_payload = selected_bus.payload;

  task automatic wait_for_grant(virtual procedural_edge_bus bus);
    @(posedge bus.grant);
    task_edge = $time;
    task_payload = bus.payload;
  endtask

  initial begin
    selected = selected_bus;
    fork
      begin
        @(posedge selected.grant);
        initial_edge = $time;
        initial_payload = selected.payload;
      end
      wait_for_grant(selected);
    join
  end

  initial begin
    #2;
    other_bus.payload = 13;
    other_bus.grant = 1;
    #3;
    selected_bus.payload = 47;
    selected_bus.grant = 1;
    #1;
    $display("initial edge=%0d payload=%0d", initial_edge, initial_payload);
    $display("task edge=%0d payload=%0d", task_edge, task_payload);
    $display("concrete always_comb payload=%0d", concrete_payload);
    $finish(0);
  end
endmodule
