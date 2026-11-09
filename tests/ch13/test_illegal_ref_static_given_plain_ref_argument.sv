/*
:name: test_illegal_ref_static_given_plain_ref_argument
:description: a ref static argument can be passed on another ref static argument, but not a ref argument without the static qualifier (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: pass_plain passes its ref argument p, declared without static, to the ref static argument of bump
:expected_stderr_regex: test_illegal_ref_static_given_plain_ref_argument\.sv:35:
*/
// IEEE 1800-2023 §13.5.2: a ref static argument may be passed another ref
// static argument, but not a ref argument without the static qualifier,
// which may refer to an automatic variable. pass_static forwards its ref
// static argument to bump, which is legal, and the legal design prints x
// after that increment: 1. pass_plain forwards its plain ref argument p,
// which is illegal in itself, whatever the caller passes to it.
// Icarus Verilog 13.0 does not support ref arguments, and the 5.052 release
// of Verilator does not support ref static ones; both stop at a task header.

module test_illegal_ref_static_given_plain_ref_argument;
  int x;

  task automatic bump(ref static int r);
    r++;
  endtask

  task automatic pass_static(ref static int p);
    bump(p);
  endtask

  task automatic pass_plain(ref int p);
    bump(p);   // illegal: a ref argument without static for a ref static argument
  endtask

  initial begin
    pass_static(x);
    $display("%0d", x);
    pass_plain(x);
  end
endmodule
