/*
:name: test_illegal_final_method_overridden
:description: A method declared :final cannot be overridden in a subclass (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a subclass overrides a method declared :final
:expected_stderr_regex: test_illegal_final_method_overridden\.sv:28:
*/
// IEEE 1800-2023 §8.20: the final specifier on a method says that no further
// overrides of it shall be allowed, and a subclass that overrides it is an
// error, whether or not either method is virtual.
// Icarus Verilog 13.0 does not support :final and stops with a syntax error on
// the base method.

class test_illegal_final_method_overridden_base;
  virtual function :final int id();
    return 1;
  endfunction
endclass

class test_illegal_final_method_overridden_derived
    extends test_illegal_final_method_overridden_base;
  virtual function int id();   // illegal
    return 2;
  endfunction
endclass

module test_illegal_final_method_overridden;
  test_illegal_final_method_overridden_derived d = new;
  initial $display("id=%0d", d.id());
endmodule
