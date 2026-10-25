/*
:name: test_illegal_soft_constraint_state_only
:description: a soft constraint on a variable that is not random is an error (IEEE 1800-2023 Section 18.5.13.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.13.1 18.5.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the soft constraint of block s_m constrains only the state variable mode, which is not random
:expected_stderr_regex: test_illegal_soft_constraint_state_only\.sv:29:
*/
// IEEE 1800-2023 §18.5.13.1: soft constraints can only be specified on
// random variables, and not on randc variables. The soft constraint of s_v
// relates the rand variable v to the state variable mode and is legal. The
// soft constraint of s_m constrains mode alone, a variable that is not
// random, which is the error. test_illegal_soft_constraint_randc has a soft
// constraint on a randc variable.
// Icarus Verilog 13.0 does not support constraint declarations, so its error
// does not count. The 5.052 release of Verilator accepts the design.

class sso_obj;
  rand bit [3:0] v;
  bit [3:0] mode = 4'd2;

  constraint s_v { soft v > mode; }
  constraint h_v { v < 4'd12; }
  constraint s_m { soft mode == 4'd3; }   // illegal: soft on a state variable
endclass

module test_illegal_soft_constraint_state_only;
  sso_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
