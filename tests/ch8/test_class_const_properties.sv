/*
:name: test_class_const_properties
:description: Global constant class properties take their value in the declaration, and instance constants are set once in the constructor (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.19 8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_const_properties.expected
*/
// IEEE 1800-2023 §8.19: a class property declared const is read-only. A global
// constant has its value in its declaration and is often also static (8.9), so
// it is the same for every object and can be read through the class name. An
// instance constant has no value in its declaration and is assigned once in the
// constructor, so each object can have its own value.

class const_cfg;
  const int width = 8;
  static const int limit = 100;
  const int id;

  function new(int i);
    id = i;
  endfunction
endclass

module test_class_const_properties;
  const_cfg a, b;

  initial begin
    a = new(1);
    b = new(2);
    $display("width: a=%0d b=%0d", a.width, b.width);
    $display("limit: class=%0d a=%0d", const_cfg::limit, a.limit);
    $display("id: a=%0d b=%0d", a.id, b.id);
  end
endmodule
