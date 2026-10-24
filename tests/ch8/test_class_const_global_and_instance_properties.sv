/*
:name: test_class_const_global_and_instance_properties
:description: a const class property is a global constant when its declaration gives the value, possibly static, and an instance constant, with a value of its own in each object, when the constructor assigns it once (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.19
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_const_global_and_instance_properties.expected
*/
// IEEE 1800-2023 §8.19: class properties can be read-only in two forms. A
// global constant has its initial value in its declaration and is not
// assigned anywhere else; it can also be static. An instance constant has
// only the const qualifier and is assigned once, at run time, in the
// constructor, so each object can hold a different value.
// buf_c has the global constants max_size and unit (static) and the instance
// constant size, which its constructor sets from the argument, limited by
// max_size. Two objects get different sizes; the global constants are read
// through handles and through the class scope.
// Icarus Verilog 13.0 does not parse buf_c::unit, a static property read
// through the class scope.

class buf_c;
  const int max_size = 16;
  const static int unit = 4;
  const int size;
  function new(int n);
    size = (n > max_size) ? max_size : n;
  endfunction
endclass

module test_class_const_global_and_instance_properties;
  buf_c b1, b2;

  initial begin
    b1 = new(10);
    b2 = new(40);
    $display("instance constants: b1.size=%0d b2.size=%0d", b1.size, b2.size);
    $display("global constants: b1.max_size=%0d b2.max_size=%0d unit=%0d b1.unit=%0d",
             b1.max_size, b2.max_size, buf_c::unit, b1.unit);
  end
endmodule
