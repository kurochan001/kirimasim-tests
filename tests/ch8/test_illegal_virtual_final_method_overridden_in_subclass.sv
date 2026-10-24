/*
:name: test_illegal_virtual_final_method_overridden_in_subclass
:description: a virtual method declared :final cannot be overridden in a subclass, also two levels down and without the keyword virtual (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class leaf_c declares f, overriding the virtual method f that mid_c declared :final
:expected_stderr_regex: test_illegal_virtual_final_method_overridden_in_subclass\.sv:40:
*/
// IEEE 1800-2023 §8.20: no further override of a method specified as final is
// allowed, whether or not the method is virtual. mid_c overrides the virtual f
// of top_c legally and declares it :final; the virtual g is not final, so
// leaf_c may override it. leaf_c's declaration of f is the only error.
// Icarus Verilog 13.0 does not support :final and reports a syntax error on
// its first use, so its error does not count.

class top_c;
  virtual function int f();
    return 1;
  endfunction
  virtual function int g();
    return 2;
  endfunction
endclass

class mid_c extends top_c;
  virtual function :final int f();
    return 10;
  endfunction
endclass

class leaf_c extends mid_c;
  function int g();
    return 200;
  endfunction
  function int f();   // illegal: overrides the :final method f of mid_c
    return 100;
  endfunction
endclass

module test_illegal_virtual_final_method_overridden_in_subclass;
  leaf_c l = new;
  initial $display("g=%0d", l.g());
endmodule
