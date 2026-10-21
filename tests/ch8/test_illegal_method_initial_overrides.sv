/*
:name: test_illegal_method_initial_overrides
:description: A method declared :initial cannot override a virtual method (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a subclass method declared :initial overrides a virtual method of the base class
:expected_stderr_regex: test_illegal_method_initial_overrides\.sv:27:
*/
// IEEE 1800-2023 §8.20: specifying initial when overriding a virtual method in
// a subclass shall result in an error.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so the
// error it reports on that line does not count.

class test_illegal_method_initial_overrides_base;
  virtual function int id();
    return 1;
  endfunction
endclass

class test_illegal_method_initial_overrides_derived
    extends test_illegal_method_initial_overrides_base;
  virtual function :initial int id();   // illegal: :initial on an override
    return 2;
  endfunction
endclass

module test_illegal_method_initial_overrides;
  test_illegal_method_initial_overrides_derived d = new;
  initial $display("id=%0d", d.id());
endmodule
