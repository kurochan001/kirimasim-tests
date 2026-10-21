/*
:name: test_illegal_extern_constraint_without_block
:description: A constraint prototype in the explicit form, with extern, needs an external constraint block (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the extern constraint prototype c_range is never completed by an external constraint block
:expected_stderr_regex: test_illegal_extern_constraint_without_block\.sv:23:
*/
// IEEE 1800-2023 §18.5.1: a prototype declared with extern promises an
// external constraint block of its name after the class. Unlike the
// implicit form, which becomes an empty constraint, it is an error when no
// such block is given. c_fixed is completed outside the class, c_range is
// not. Icarus Verilog 13.0 does not support constraint prototypes, so the
// syntax error it reports on that line does not count.

class ecw_obj;
  rand bit [7:0] v;
  extern constraint c_range;   // illegal: no external block for c_range
  extern constraint c_fixed;
endclass

constraint ecw_obj::c_fixed { v != 8'd0; }

module test_illegal_extern_constraint_without_block;
  ecw_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
