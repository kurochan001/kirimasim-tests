/*
:name: test_illegal_ref_in_static_task
:description: A static task cannot have a ref argument (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the static task bump has a ref argument
:expected_stderr_regex: test_illegal_ref_in_static_task\.sv:20:
*/
// IEEE 1800-2023 §13.5.2: passing arguments by reference is illegal for
// subroutines with a static lifetime. Tasks of a module are static unless
// declared automatic.

module test_illegal_ref_in_static_task;
  int n = 0;
  task bump(ref int x);   // illegal: ref in a static task
    x++;
  endtask
  initial bump(n);
endmodule
