/*
:name: test_forward_class_typedef_parameterized
:description: a forward class typedef refers to a class with a parameter port list that is later specialized positionally and by name
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.27 8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forward_class_typedef_parameterized.expected
*/
// IEEE 1800-2023 8.27: a forward class typedef may refer to a class with a
// parameter port list, so a handle can be declared before the class
// definition, and the later declaration can override the parameters
// positionally or by name. 8.5: a class value parameter can be read through
// an object handle, although that expression is not a constant. The test
// declares handles of the forward class with two specializations before the
// class body, creates both objects, and prints the parameter and the property.

typedef class Cp;

module test_forward_class_typedef_parameterized;
  Cp#(1, real) v2;
  Cp#(.p(2), .T(int)) v3;

  initial begin
    v2 = new();
    v3 = new();
    $display("p=%0d %0d", v2.p, v3.p);
    $display("value=%0.1f %0d", v2.value, v3.value);
  end
endmodule

class Cp #(parameter p = 2, type T = int);
  T value;

  function new();
    value = T'(3);
  endfunction
endclass
