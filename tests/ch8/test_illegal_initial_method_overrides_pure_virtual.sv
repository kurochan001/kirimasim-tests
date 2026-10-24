/*
:name: test_illegal_initial_method_overrides_pure_virtual
:description: a method declared :initial must not override a pure virtual method of an abstract base class either (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20 8.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method area of sq_c is declared :initial but implements the pure virtual method area of shape_c
:expected_stderr_regex: test_illegal_initial_method_overrides_pure_virtual\.sv:34:
*/
// IEEE 1800-2023 §8.20: specifying :initial when overriding a virtual method,
// including a method declared pure virtual in the base class (§8.21), is an
// error. sq_c implements the pure virtual sides legally and adds the new
// method tag with :initial, which overrides nothing; its implementation of the
// pure virtual area with :initial is the error.
// Icarus Verilog 13.0 does not support :initial and reports a syntax error on
// its first use, so its error does not count.

virtual class shape_c;
  pure virtual function int sides();
  pure virtual function int area();
endclass

class sq_c extends shape_c;
  virtual function int sides();
    return 4;
  endfunction
  function :initial int tag();
    return 7;
  endfunction
  virtual function :initial int area();   // illegal: :initial overrides a pure virtual
    return 16;
  endfunction
endclass

module test_illegal_initial_method_overrides_pure_virtual;
  sq_c s = new;
  initial $display("sides=%0d tag=%0d", s.sides(), s.tag());
endmodule
