/*
:name: test_illegal_extern_forkjoin_function
:description: Only a task, not a function, can be declared extern forkjoin so that several module instances define it (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7 25.7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface fjf_bus declares the function peek with extern forkjoin, so that the instances t1 and t2 can both define it
:expected_stderr_regex: test_illegal_extern_forkjoin_function\.sv:(30|38|46):
*/
// IEEE 1800-2023 §25.7: tasks (not functions) can be defined in a module that
// is instantiated more than once, which an extern forkjoin declaration in the
// interface allows; the extern forkjoin form takes a task prototype only
// (25.7.4, and functions cannot be exported from several modules). The task
// count is declared extern forkjoin and defined by both instances t1 and t2,
// which is legal; the function peek is declared extern forkjoin as well and
// is also defined by both instances.
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces and reports a syntax error on each of them, which is not
// counted. The 5.052 release of Verilator reports extern forkjoin of the task
// as unsupported, and rejects line 30 with a syntax error that expects the
// keyword task there.

interface fjf_bus;
  int n;
  extern forkjoin task count();
  extern forkjoin function int peek();   // illegal: a function
  modport tgt (export count, export peek);
endinterface

module fjf_target(fjf_bus.tgt b);
  task b.count();
    b.n++;
  endtask
  function int b.peek();   // the error can also be reported here
    return b.n;
  endfunction
endmodule

module test_illegal_extern_forkjoin_function;
  fjf_bus bus ();
  fjf_target t1 (bus);
  fjf_target t2 (bus);   // the error can also be reported here
endmodule
