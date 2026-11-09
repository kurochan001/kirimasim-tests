/*
:name: test_illegal_ref_static_given_automatic_variable
:description: a ref static argument cannot be passed an automatic variable (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the automatic variable local_v of the automatic task run is passed to the ref static argument of bump
:expected_stderr_regex: test_illegal_ref_static_given_automatic_variable\.sv:35:
*/
// IEEE 1800-2023 §13.5.2: a ref static argument shall be passed only
// variables, properties, members or elements of static lifetime, or another
// ref static argument, and not automatic variables. §6.21: a variable
// declared in an automatic task has the lifetime of the call. The first call
// in run passes the module variable mod_var, which is legal, and the legal
// design prints it after the increment: 1. The second call passes local_v,
// an automatic variable of run.
// Icarus Verilog 13.0 does not support ref arguments, and the 5.052 release
// of Verilator does not support ref static ones; both stop at a task header.

module test_illegal_ref_static_given_automatic_variable;
  int mod_var;

  task automatic bump(ref static int r);
    r++;
  endtask

  task automatic run();
    int local_v;
    bump(mod_var);
    $display("%0d", mod_var);
    bump(local_v);   // illegal: an automatic variable for a ref static argument
  endtask

  initial run();
endmodule
