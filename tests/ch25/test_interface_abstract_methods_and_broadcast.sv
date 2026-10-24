/*
:name: test_interface_abstract_methods_and_broadcast
:description: Interface methods can be declared in the interface, defined in one module and called from another through the instance's local names, and a forkjoin task defined in two modules runs both definitions concurrently (IEEE 1800-2023 Section 25.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.2 25.7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_abstract_methods_and_broadcast.expected
*/
// IEEE 1800-2023 §25.2: interface methods can be abstract, declared in the
// interface, defined in one module and called in another, with export and
// import and the local hierarchical names of the interface port for both the
// definition and the call. Broadcast is modeled by forkjoin tasks, which can
// be defined in more than one module and run concurrently (25.7.4: a call
// behaves as a fork-join of the definitions). The task put is declared extern
// in am_bus and defined in am_store; am_caller calls it through its own port
// and sees value 7 at once. The task tick is extern forkjoin and defined in
// the two instances c1 and c2, each of which waits 5 and sets its own bit of
// mask; the call returns at time 5 with both bits set, not at time 10 as
// calls one after the other would.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator do
// not support extern tasks in interfaces.

`timescale 1ns/1ns

interface am_bus;
  int value;
  bit [1:0] mask;
  extern task put(input int v);
  extern forkjoin task tick();
  modport store (export put);
  modport counter (export tick);
  modport caller (import task put(input int v), import task tick());
endinterface

module am_store(am_bus.store b);
  task b.put(input int v);
    b.value = v;
  endtask
endmodule

module am_counter #(parameter int ID = 0) (am_bus.counter b);
  task b.tick();
    #5 b.mask[ID] = 1'b1;
  endtask
endmodule

module am_caller(am_bus.caller b);
  initial begin
    b.put(7);
    $display("%0t: value=%0d", $time, b.value);
    b.tick();
    $display("%0t: mask=%b", $time, b.mask);
  end
endmodule

module test_interface_abstract_methods_and_broadcast;
  am_bus bus ();
  am_store s (bus);
  am_counter #(0) c1 (bus);
  am_counter #(1) c2 (bus);
  am_caller k (bus);
endmodule
