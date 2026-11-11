/*
:name: test_illegal_override_specifier_on_module_function
:description: a dynamic override specifier is allowed only on a method of a class that is not an interface class (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function plain_f declared in the module has the dynamic override specifier :final
:expected_stderr_regex: test_illegal_override_specifier_on_module_function\.sv:29:
*/
// IEEE 1800-2023 §9.2: the dynamic override specifiers (:initial, :extends,
// :final, 8.20) of the function and task syntax shall only be legal on method
// declarations in a class that is not an interface class. base_c::get with
// :final is legal; plain_f, a function of the module, is not a method.
// Icarus Verilog 13.0 does not parse override specifiers and gives syntax
// errors also on the legal method of base_c, so its error does not count,
// and Verilator 5.052 accepts the design.

class base_c;
  virtual function :final int get();
    return 1;
  endfunction
endclass

module test_illegal_override_specifier_on_module_function;
  function :final int plain_f();   // illegal: not a class method
    return 2;
  endfunction

  base_c b = new;
  initial $display("%0d", b.get());
endmodule
