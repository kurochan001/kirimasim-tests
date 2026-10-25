/*
:name: test_illegal_fork_join_any_reads_ref_formal
:description: A statement of a fork-join_any block cannot refer to a ref formal argument of the enclosing task (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a process forked by fork-join_any reads the ref argument r, which is not declared ref static
:expected_stderr_regex: test_illegal_fork_join_any_reads_ref_formal\.sv:28:
*/
// IEEE 1800-2023 §9.3.2: inside a fork-join_any or fork-join_none block it
// is illegal to refer to a formal argument passed by reference, other than
// in the initialization of a variable declared at the start of the fork,
// unless the argument is ref static. The first forked statement below
// reads the ref argument r.
// Icarus Verilog 13.0 does not support ref arguments and stops at the task
// header, which does not count; the 5.052 release of Verilator accepts the
// design.

module test_illegal_fork_join_any_reads_ref_formal;
  int x = 1, y;

  task automatic spawn(ref int r);
    fork
      y = r;   // illegal: ref formal used in fork-join_any
      #2;
    join_any
  endtask

  initial spawn(x);
endmodule
