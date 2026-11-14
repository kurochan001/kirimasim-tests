/*
:name: test_illegal_function_override_specifier_outside_class
:description: a function declared in a module, which is not a class method, cannot have a dynamic override specifier (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module function twice is declared with the dynamic override specifier :initial
:expected_stderr_regex: test_illegal_function_override_specifier_outside_class\.sv:34:
*/
// IEEE 1800-2023 13.4 (Syntax 13-2, footnote 25): the dynamic override
// specifiers after the keyword function are legal only on method
// declarations inside a class that is not an interface class. The method
// counter::next has :initial, which is legal; the function twice belongs to
// the module and has :initial too. Without that specifier the design prints
// 3 8.
// Icarus Verilog 13.0 does not parse override specifiers and reports syntax
// errors on the legal method next as well, so its error on the marked line
// does not count; release 5.054 of Verilator accepts the design.

module test_illegal_function_override_specifier_outside_class;
  class counter;
    int n = 2;
    function :initial int next();
      n = n + 1;
      return n;
    endfunction
  endclass

  counter c = new;
  function :initial int twice(int v);   // illegal: not a class method
    return 2 * v;
  endfunction
  initial $display("%0d %0d", c.next(), twice(4));
endmodule
