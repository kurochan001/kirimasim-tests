/*
:name: test_illegal_override_specifier_outside_class
:description: the dynamic override specifiers such as :final are not allowed on a function declared outside a class (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function twice of the module, which is not a class method, is declared with the dynamic override specifier :final
:expected_stderr_regex: test_illegal_override_specifier_outside_class\.sv:31:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 25): the dynamic override
// specifiers :initial, :extends and :final shall be legal only on method
// declarations inside a class that is not an interface class.
// The method get of the class has :final, which is legal, and the legal design
// prints what it returns: 7. The function twice, declared in the module and so
// not a method, has :final.
// Icarus Verilog 13.0 reports syntax errors on the specifier, which do not
// count.

class test_illegal_override_specifier_outside_class_c;
  function :final int get();
    return 7;
  endfunction
endclass

module test_illegal_override_specifier_outside_class;
  test_illegal_override_specifier_outside_class_c o;
  function :final int twice(int x);   // illegal: override specifier outside a class
    return 2 * x;
  endfunction
  initial begin
    o = new;
    $display("%0d", o.get());
  end
endmodule
