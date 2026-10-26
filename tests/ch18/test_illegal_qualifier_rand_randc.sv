/*
:name: test_illegal_qualifier_rand_randc
:description: A declaration may have at most one of rand and randc, so a declaration with both is an error (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: x is declared with both rand and randc
:expected_stderr_regex: test_illegal_qualifier_rand_randc\.sv:26:
*/
// IEEE 1800-2023 §18.4: in any one declaration, only one of rand or randc is
// allowed. rr_ok has one random qualifier in each declaration; the
// declaration of x in rr_obj has both and is illegal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design, so their results
// do not count.

class rr_ok;
  rand int a;
  randc int b;
endclass

class rr_obj;
  rand randc int x;   // illegal: rand and randc together
endclass

module test_illegal_qualifier_rand_randc;
  rr_obj o = new;

  initial begin
    $display("done");
  end
endmodule
