/*
:name: test_illegal_hierarchical_task_definition_not_declared
:description: A subroutine that a module defines with a hierarchical name through an interface port has to be declared extern in the interface or exported in a modport (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: hmd_target defines the task b.clear, which the interface hmd_bus neither declares extern nor exports in a modport
:expected_stderr_regex: test_illegal_hierarchical_task_definition_not_declared\.sv:37:
*/
// IEEE 1800-2023 §25.7: subroutines defined in a module using a hierarchical
// name shall also be declared extern in the interface or export in a
// modport. put is declared extern in hmd_bus and exported by the modport
// tgt; get is only exported, with a prototype, by tgt; both definitions are
// legal. clear is declared nowhere in the interface.
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces or subroutines in modports, and its syntax errors, which also fall
// on the lines named here, are not counted; the 5.052 release of Verilator
// reports the extern task as unsupported.

interface hmd_bus;
  int r;
  extern task put(input int v);
  modport tgt (export put, export task get(output int v));
endinterface

module hmd_target(hmd_bus.tgt b);
  task b.put(input int v);
    b.r = v;
  endtask
  task b.get(output int v);
    v = b.r;
  endtask
  task b.clear();   // illegal: clear is neither extern nor exported
    b.r = 0;
  endtask
endmodule

module test_illegal_hierarchical_task_definition_not_declared;
  hmd_bus bus ();
  hmd_target t (bus);
endmodule
