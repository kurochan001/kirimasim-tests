/*
:name: test_ch6_extra_ref_equiv_closed
:description: Types are equivalent only through the inductive rules, so an int and a logic [31:0] are nonequivalent and cannot be paired by a ref argument (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22.2 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ref argument l has type logic [31:0], which is not equivalent to the int formal a
:expected_stderr_regex: test_ch6_extra_ref_equiv_closed\.sv:30:
*/
// IEEE 1800-2023 §6.22.2: two types are equivalent only if the inductive
// rules establish it; otherwise they are nonequivalent. Rule c makes types
// equivalent when they have the same number of bits, are all 2-state or all
// 4-state and have the same signing. int is 2-state and logic [31:0] is
// 4-state, so they are nonequivalent. §13.5.2 requires a ref argument to be
// matched with an equivalent data type and forbids a cast, so the call on the
// marked line is illegal.
// Icarus Verilog 13.0 does not support ref ports, so this test has no Icarus
// oracle.

module test_ch6_extra_ref_equiv_closed;
  task automatic take(ref int a);
    a = 1;
  endtask

  logic [31:0] l;
  initial take(l);   // illegal: logic [31:0] is not equivalent to int
endmodule
