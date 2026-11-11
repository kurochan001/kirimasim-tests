/*
:name: test_illegal_super_new_default_without_default
:description: super.new(default) needs default in the argument list of the constructor (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: super.new(default) is called in a constructor whose argument list has no default
:expected_stderr_regex: test_illegal_super_new_default_without_default\.sv:30:
*/
// IEEE 1800-2023 §8.17: it shall be an error to use the default keyword for
// super.new() if the default keyword was not used in the constructor argument
// list.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports default in
// super.new, so the syntax errors they report on that line do not count.

class test_illegal_super_new_default_without_default_base;
  int a;
  function new(int a);
    this.a = a;
  endfunction
endclass

class test_illegal_super_new_default_without_default_derived
    extends test_illegal_super_new_default_without_default_base;
  function new(int x);
    super.new(default);   // illegal: no default in the argument list
  endfunction
endclass

module test_illegal_super_new_default_without_default;
  test_illegal_super_new_default_without_default_derived d = new(4);
  initial $display("a=%0d", d.a);
endmodule
