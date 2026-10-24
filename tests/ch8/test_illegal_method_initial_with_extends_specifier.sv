/*
:name: test_illegal_method_initial_with_extends_specifier
:description: a method declaration cannot have both :initial and :extends, while :final may follow either of them (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20 8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method h of sub_c is declared with both :initial and :extends
:expected_stderr_regex: test_illegal_method_initial_with_extends_specifier\.sv:38:
*/
// IEEE 1800-2023 §8.20: :initial and :extends are mutually exclusive, and a
// method that has both is an error; :final may be combined with either. In
// the grammar of §8.3 a method takes at most one of :initial and :extends,
// followed by an optional :final. sub_c declares f with :extends :final and g
// with :initial :final, which are legal, and h with :initial :extends.
// Icarus Verilog 13.0 does not support these specifiers and reports a syntax
// error on their first use, so its error does not count.

class base_c;
  virtual function int f();
    return 1;
  endfunction
  virtual function int h();
    return 3;
  endfunction
endclass

class sub_c extends base_c;
  function :extends :final int f();
    return 10;
  endfunction
  function :initial :final int g();
    return 20;
  endfunction
  function :initial :extends int h();   // illegal: :initial together with :extends
    return 30;
  endfunction
endclass

module test_illegal_method_initial_with_extends_specifier;
  sub_c s = new;
  initial $display("f=%0d g=%0d", s.f(), s.g());
endmodule
