/*
:name: test_illegal_instance_constant_assigned_in_method
:description: An instance constant of a class can be assigned only in its constructor (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a method other than the constructor assigns an instance constant
:expected_stderr_regex: test_illegal_instance_constant_assigned_in_method\.sv:24:
*/
// IEEE 1800-2023 §8.19: an instance constant, a const property without an
// initial value, is assigned once at run time, and only in the constructor of
// its class.

class test_illegal_instance_constant_assigned_in_method_c;
  const int size;
  function new(int n);
    size = n;
  endfunction
  function void resize(int n);
    size = n;   // illegal: instance constant assigned outside the constructor
  endfunction
endclass

module test_illegal_instance_constant_assigned_in_method;
  test_illegal_instance_constant_assigned_in_method_c c = new(4);
  initial begin
    c.resize(8);
    $display("size=%0d", c.size);
  end
endmodule
