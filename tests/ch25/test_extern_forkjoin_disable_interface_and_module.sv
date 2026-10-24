/*
:name: test_extern_forkjoin_disable_interface_and_module
:description: Disabling an extern forkjoin task through the interface instance disables the calls of every module that defines it, and disabling it through one module instance disables only that module's call (IEEE 1800-2023 Section 25.7.4)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_forkjoin_disable_interface_and_module.expected
*/
// IEEE 1800-2023 §25.7.4: a call of an extern forkjoin task runs the
// definitions of all modules connected to the interface as a fork-join. If
// the task is disabled through the interface instance, all its calls are
// disabled; if it is disabled through a module instance, only the call to
// that module instance is disabled. The modules m0 and m1 both define work,
// which waits 10 and then sets the bit of mask of the module. The first call
// is disabled through bus at time 5: it returns at 5 with no bit set. The
// second, from time 5, is disabled through m0 at time 10: m1 still sets its
// bit at 15, when the call returns. The third runs without a disable and
// sets both bits at 25.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator do
// not support extern forkjoin tasks.

`timescale 1ns/1ns

interface fd_bus;
  bit [1:0] mask;
  extern forkjoin task work();
  modport tgt (export work);
endinterface

module fd_target #(parameter int ID = 0) (fd_bus.tgt b);
  task b.work();
    #10 b.mask[ID] = 1'b1;
  endtask
endmodule

module test_extern_forkjoin_disable_interface_and_module;
  fd_bus bus ();
  fd_target #(0) m0 (bus);
  fd_target #(1) m1 (bus);

  initial begin
    fork
      bus.work();
      #5 disable bus.work;
    join
    $display("%0t: disabled through bus: mask=%b", $time, bus.mask);
    fork
      bus.work();
      #5 disable m0.b.work;
    join
    $display("%0t: disabled through m0: mask=%b", $time, bus.mask);
    bus.mask = '0;
    bus.work();
    $display("%0t: not disabled: mask=%b", $time, bus.mask);
  end
endmodule
