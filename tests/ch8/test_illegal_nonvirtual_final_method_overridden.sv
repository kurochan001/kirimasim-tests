/*
:name: test_illegal_nonvirtual_final_method_overridden
:description: a method declared :final cannot be overridden in a subclass even when it is not virtual (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the subclass declares f again, overriding the non-virtual method f declared :final in its base class
:expected_stderr_regex: test_illegal_nonvirtual_final_method_overridden\.sv:35:
*/
// IEEE 1800-2023 §8.20: :final does not make a method virtual, and an attempt
// by a subclass to override a method specified as final is an error whether or
// not the method is virtual. f is non-virtual and :final in base_c; g is
// non-virtual without :final, so the subclass may override it, and calling
// the inherited f is legal. Only the redeclaration of f is an error.
// Icarus Verilog 13.0 does not support :final and reports a syntax error on
// its first use, so its error does not count.

class base_c;
  function :final int f();
    return 1;
  endfunction
  function int g();
    return 2;
  endfunction
endclass

class sub_c extends base_c;
  function int g();
    return 20 + f();
  endfunction
  function int f();   // illegal: overrides the :final method f
    return 10;
  endfunction
endclass

module test_illegal_nonvirtual_final_method_overridden;
  sub_c s = new;
  initial $display("g=%0d", s.g());
endmodule
