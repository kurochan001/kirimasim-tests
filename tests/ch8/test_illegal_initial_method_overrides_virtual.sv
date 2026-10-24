/*
:name: test_illegal_initial_method_overrides_virtual
:description: a method declared :initial must not override a virtual method of a base class (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method f of sub_c is declared :initial but overrides the virtual method f of base_c
:expected_stderr_regex: test_illegal_initial_method_overrides_virtual\.sv:39:
*/
// IEEE 1800-2023 §8.20: :initial says that a method is not a virtual
// override, and specifying it when overriding a virtual method of a base
// class is an error. sub_c overrides the non-virtual g without :initial and
// declares the new method h with :initial, which overrides nothing; both are
// legal. f is virtual in base_c, so the :initial declaration of f is the
// error.
// Icarus Verilog 13.0 does not support :initial and reports a syntax error on
// its first use, so its error does not count.

class base_c;
  virtual function int f();
    return 1;
  endfunction
  function int g();
    return 2;
  endfunction
endclass

class sub_c extends base_c;
  function int g();
    return 20;
  endfunction
  function :initial int h();
    return 30;
  endfunction
  function :initial int f();   // illegal: :initial on an override of a virtual method
    return 10;
  endfunction
endclass

module test_illegal_initial_method_overrides_virtual;
  sub_c s = new;
  initial $display("g=%0d h=%0d", s.g(), s.h());
endmodule
