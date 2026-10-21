/*
:name: test_illegal_method_extends_without_base
:description: A method declared :extends has to override a virtual method of a base class (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a method declared :extends does not override any virtual method
:expected_stderr_regex: test_illegal_method_extends_without_base\.sv:20:
*/
// IEEE 1800-2023 §8.20: specifying extends when not extending a virtual method
// from a base class shall result in an error; the class has no base class.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so the
// error it reports on that line does not count.

class test_illegal_method_extends_without_base_c;
  function :extends int id();   // illegal: nothing to extend
    return 1;
  endfunction
endclass

module test_illegal_method_extends_without_base;
  test_illegal_method_extends_without_base_c c = new;
  initial $display("id=%0d", c.id());
endmodule
