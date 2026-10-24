/*
:name: test_illegal_task_exported_by_two_modules
:description: Two module instances connected to one interface cannot both export a task that the interface does not declare extern forkjoin (IEEE 1800-2023 Section 25.7.4)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instances t1 and t2 are connected to the same interface instance bus and both export put, which is declared extern without forkjoin
:expected_stderr_regex: test_illegal_task_exported_by_two_modules\.sv:(36|43|44):
*/
// IEEE 1800-2023 §25.7.4: it is normally an error for more than one module to
// export the same task name; instances of the same modport type connected to
// one interface can each export a task only if the interface declares it
// with extern forkjoin. In mte_bus, count is extern forkjoin and put is
// plain extern. The instances t1 and t2 of mte_target are connected to the
// same bus, so both export count, which is legal, and both export put.
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces or subroutines in modports, and its syntax errors, which also fall
// on the lines named here, are not counted; the 5.052 release of Verilator
// reports extern and extern forkjoin tasks as unsupported.

interface mte_bus;
  int n;
  extern forkjoin task count();
  extern task put(input int v);
  modport tgt (export count, export put);
endinterface

module mte_target(mte_bus.tgt b);
  task b.count();
    b.n++;
  endtask
  task b.put(input int v);   // the error can also be reported here
    b.n = v;
  endtask
endmodule

module test_illegal_task_exported_by_two_modules;
  mte_bus bus ();
  mte_target t1 (bus);   // the error can also be reported here
  mte_target t2 (bus);   // illegal: a second export of put
endmodule
