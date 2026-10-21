/*
:name: test_illegal_super_new_not_first
:description: A call of super.new has to be the first statement of a constructor (IEEE 1800-2023 Section 8.15)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.15 8.17
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor of the subclass runs a statement before super.new
:expected_stderr_regex: test_illegal_super_new_not_first\.sv:28:
*/
// IEEE 1800-2023 §8.15 and §8.17: a call of super.new shall be the first
// statement executed in the constructor of the subclass.

class test_illegal_super_new_not_first_base;
  int v;
  function new(int n);
    v = n;
  endfunction
endclass

class test_illegal_super_new_not_first_derived extends test_illegal_super_new_not_first_base;
  int w;
  function new();
    w = 2;
    super.new(5);   // illegal: super.new after another statement
  endfunction
endclass

module test_illegal_super_new_not_first;
  test_illegal_super_new_not_first_derived d = new;
  initial $display("v=%0d w=%0d", d.v, d.w);
endmodule
