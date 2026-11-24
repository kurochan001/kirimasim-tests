/*
:name: test_virtual_modport_task_wait_selects_rebound_interface
:description: A task using a virtual modport waits on each selected interface in turn
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 25.5 9.4.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_modport_task_wait_selects_rebound_interface.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
interface grant_link;
  bit grant;
  int payload;
  modport receiver(input grant, payload);
endinterface

module test_virtual_modport_task_wait_selects_rebound_interface;
  grant_link left();
  grant_link right();
  virtual grant_link.receiver selected;
  int completed;

  task automatic receive(virtual grant_link.receiver bus, output int value);
    @(posedge bus.grant);
    value = bus.payload;
  endtask

  initial begin
    int value;
    selected = left;
    receive(selected, value);
    $display("first t=%0d payload=%0d", $time, value);
    completed++;
    selected = right;
    receive(selected, value);
    $display("second t=%0d payload=%0d", $time, value);
    completed++;
  end

  initial begin
    #2;
    right.payload = 7;
    right.grant = 1;
    #1;
    right.grant = 0;
    #1;
    left.payload = 23;
    left.grant = 1;
    #1;
    left.grant = 0;
    #1;
    left.payload = 66;
    left.grant = 1;
    #2;
    right.payload = 51;
    right.grant = 1;
    #1;
    $display("completed=%0d", completed);
    $finish;
  end
endmodule
