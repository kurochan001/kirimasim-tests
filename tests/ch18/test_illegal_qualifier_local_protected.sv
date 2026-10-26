/*
:name: test_illegal_qualifier_local_protected
:description: A declaration may have at most one of local and protected, so combining them is an error (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: x is declared with both local and protected
:expected_stderr_regex: test_illegal_qualifier_local_protected\.sv:26:
*/
// IEEE 1800-2023 §18.4: in any one declaration, only one of local or
// protected is allowed. lp_ok has one of them in each declaration; the
// declaration of x in lp_obj has both and is illegal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design, so their results
// do not count.

class lp_ok;
  local int a;
  protected int b;
endclass

class lp_obj;
  local protected int x;   // illegal: two of local and protected
endclass

module test_illegal_qualifier_local_protected;
  lp_obj o = new;

  initial begin
    $display("done");
  end
endmodule
