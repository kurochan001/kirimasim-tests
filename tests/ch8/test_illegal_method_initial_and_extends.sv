/*
:name: test_illegal_method_initial_and_extends
:description: A method cannot be declared both :initial and :extends (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a method is declared both :initial and :extends
:expected_stderr_regex: test_illegal_method_initial_and_extends\.sv:27:
*/
// IEEE 1800-2023 §8.20: initial and extends are mutually exclusive, and
// specifying both in a method declaration shall result in an error.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so the
// error it reports on that line does not count.

class test_illegal_method_initial_and_extends_base;
  virtual function int id();
    return 1;
  endfunction
endclass

class test_illegal_method_initial_and_extends_derived
    extends test_illegal_method_initial_and_extends_base;
  function :initial :extends int id();   // illegal: both specifiers
    return 2;
  endfunction
endclass

module test_illegal_method_initial_and_extends;
  test_illegal_method_initial_and_extends_derived d = new;
  initial $display("id=%0d", d.id());
endmodule
