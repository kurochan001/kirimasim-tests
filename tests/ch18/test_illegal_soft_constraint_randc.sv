/*
:name: test_illegal_soft_constraint_randc
:description: a soft constraint on a randc variable is an error (IEEE 1800-2023 Section 18.5.13.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.13.1 18.5.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the soft constraint of block s_k constrains the randc variable k
:expected_stderr_regex: test_illegal_soft_constraint_randc\.sv:29:
*/
// IEEE 1800-2023 §18.5.13.1: soft constraints can only be specified on
// random variables, and not on randc variables. The soft constraint of s_v
// constrains the rand variable v and is legal, and the hard constraint of
// h_k on the randc variable k is legal too. The soft constraint of s_k
// constrains k, which is the error. test_illegal_soft_constraint_state_only
// has a soft constraint on a variable that is not random.
// Icarus Verilog 13.0 does not support constraint declarations, so its error
// does not count.

class scr_obj;
  rand bit [3:0] v;
  randc bit [2:0] k;

  constraint s_v { soft v == 4'd9; }
  constraint h_k { k != 3'd7; }
  constraint s_k { soft k < 3'd4; }   // illegal: soft on a randc variable
endclass

module test_illegal_soft_constraint_randc;
  scr_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
