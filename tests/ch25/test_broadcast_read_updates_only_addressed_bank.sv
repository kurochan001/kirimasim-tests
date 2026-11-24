/*
:name: test_broadcast_read_updates_only_addressed_bank
:description: A broadcast interface read updates only the addressed bank and preserves the result for an unmapped address
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_broadcast_read_updates_only_addressed_bank.expected
*/
`timescale 1ns/1ns
interface read_bus;
  int result = -1;
  extern forkjoin task read(input int address);
  modport target(ref result, export read);
endinterface

module read_bank #(parameter int BASE = 0, LIMIT = 9, ID = 100,
                   parameter time LATENCY = 2)(read_bus.target link);
  int responses = 0;

  task link.read(input int address);
    if (address < BASE || address > LIMIT)
      return;
    #LATENCY;
    link.result = ID + address;
    responses++;
  endtask
endmodule

module test_broadcast_read_updates_only_addressed_bank;
  read_bus bus();
  read_bank left(bus.target);
  read_bank #(10, 29, 200, 4) right(bus.target);

  task automatic observe_read(input int address);
    time start_time = $time;
    bus.read(address);
    $display("address=%0d time=%0d..%0d data=%0d responses=%0d,%0d",
             address, start_time, $time, bus.result, left.responses, right.responses);
  endtask

  initial begin
    #1 observe_read(2);
    observe_read(20);
    observe_read(99);
  end
endmodule
