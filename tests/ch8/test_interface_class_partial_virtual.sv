/*
:name: test_interface_class_partial_virtual
:description: A virtual class can implement an interface class partly, declaring the rest pure, and a derived class completes it (IEEE 1800-2023 Section 8.26.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.7 8.21 8.26.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_partial_virtual.expected
*/
// IEEE 1800-2023 §8.26.7: a virtual class (8.21) that implements an interface
// class must, for each method, either implement it or declare it again as pure;
// a class derived from it then implements the rest. §8.26.8: a method of an
// interface class may have default argument values, used when the call leaves
// the argument out.

interface class part_ops;
  pure virtual function int scale(int v, int k = 10);
  pure virtual function string name();
endclass

virtual class part_base implements part_ops;
  virtual function int scale(int v, int k = 10);
    return v * k;
  endfunction
  pure virtual function string name();
endclass

class part_full extends part_base;
  virtual function string name();
    return "full";
  endfunction
endclass

module test_interface_class_partial_virtual;
  part_full f;
  part_ops ops;

  initial begin
    f = new;
    ops = f;
    $display("name=%s", ops.name());
    $display("scale(3, 2)=%0d", ops.scale(3, 2));
    $display("scale(3) with the default=%0d", ops.scale(3));
  end
endmodule
