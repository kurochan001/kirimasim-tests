/*
:name: test_extern_forkjoin_without_definition_runtime_error
:description: A call of an extern forkjoin task that no module connected to the interface instance defines reports a run-time error and returns at once with no effect (IEEE 1800-2023 Section 25.7.4)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7.4 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_forkjoin_without_definition_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §25.7.4: if an interface contains an extern forkjoin task
// and no module connected to that interface defines the task, any call to
// the task shall report a run-time error and return immediately with no
// effect. §25.7: only a module connected through a modport that exports the
// task has to define it, so an instance without such a module elaborates.
// fjw_bus declares the extern forkjoin task ping, exported by the modport
// target and imported by the modport caller. The instance with_def has the
// module fjw_target connected through target, which defines ping as a wait
// of 2 and an increment of hits; the instance without_def has only a caller.
// Both callers call ping at 1 and print when the call returns:
// - with_def: the definition runs, so the call returns at 3 with hits=1;
// - without_def: no module defines ping, so the call reports an error and
//   returns at once, at 1, with hits still 0.
// The messages of the run are checked for an error, whose form the standard
// leaves to the tool.
// Icarus Verilog 13.0 and Verilator 5.052 do not support extern forkjoin
// tasks.

`timescale 1ns/1ns

interface fjw_bus;
  int hits = 0;
  extern forkjoin task ping();
  modport target (ref hits, export ping);
  modport caller (input hits, import task ping());
endinterface

module fjw_target (fjw_bus.target a);
  task a.ping();
    #2 a.hits++;
  endtask
endmodule

module fjw_caller #(parameter int ID = 0) (fjw_bus.caller b);
  initial begin
    #1 b.ping();
    $display("bus %0d: ping returned at t=%0t with hits=%0d", ID, $time, b.hits);
  end
endmodule

module test_extern_forkjoin_without_definition_runtime_error;
  fjw_bus with_def (), without_def ();
  fjw_target t (with_def);
  fjw_caller #(1) c1 (with_def);
  fjw_caller #(2) c2 (without_def);
endmodule
