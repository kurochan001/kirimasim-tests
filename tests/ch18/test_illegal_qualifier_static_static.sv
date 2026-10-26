/*
:name: test_illegal_qualifier_static_static
:description: Static may appear only once in a declaration, so writing it twice is an error (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: x is declared with static twice
:expected_stderr_regex: test_illegal_qualifier_static_static\.sv:25:
*/
// IEEE 1800-2023 §18.4: static and virtual can appear only once in a
// declaration. ss_ok has static once; the declaration of x in ss_obj has it
// twice and is illegal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design, so their results
// do not count.

class ss_ok;
  static int a;
endclass

class ss_obj;
  static static int x;   // illegal: static twice
endclass

module test_illegal_qualifier_static_static;
  ss_obj o = new;

  initial begin
    $display("done");
  end
endmodule
