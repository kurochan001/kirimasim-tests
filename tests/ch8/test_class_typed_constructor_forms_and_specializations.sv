/*
:name: test_class_typed_constructor_forms_and_specializations
:description: a constructor call is new with optional arguments, preceded by a class scope to construct an object of that class, also of a specialization of a parameterized class, or new followed by an expression for a shallow copy (IEEE 1800-2023 Section 8.8)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.8 8.12 8.25.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_typed_constructor_forms_and_specializations.expected
*/
// IEEE 1800-2023 §8.8: the forms of a constructor call are new with optional
// arguments, the same with a class scope in front, which constructs an object
// of that class whatever the type of the target (the class has to be
// assignment compatible with it), and new followed by an expression that
// gives a handle, which makes a shallow copy (§8.12). For a parameterized
// class the class scope can give a specialization, and arguments are passed
// as to an ordinary constructor.
// The base_c handle b receives objects made by ext_c#(5)::new(3), by
// ext_c#()::new (the default specialization, K = 2, with the default argument;
// outside the class the scope needs the #() form, §8.25.1)
// and by ext_c#(.K(7))::new(.a(1)), then a copy made with new b, and finally
// an object of its own class from plain new. id() is virtual and tells the
// class and the specialization of each object; v shows the constructor
// argument.
// Icarus Verilog 13.0 does not support parameterized classes.

class base_c;
  int v = 1;
  virtual function int id();
    return 1;
  endfunction
endclass

class ext_c #(int K = 2) extends base_c;
  function new(int a = 0);
    v = a + K;
  endfunction
  virtual function int id();
    return 10 + K;
  endfunction
endclass

module test_class_typed_constructor_forms_and_specializations;
  base_c b, c;

  initial begin
    b = ext_c#(5)::new(3);
    $display("ext_c#(5)::new(3): id=%0d v=%0d", b.id(), b.v);
    b = ext_c#()::new;
    $display("ext_c#()::new: id=%0d v=%0d", b.id(), b.v);
    b = ext_c#(.K(7))::new(.a(1));
    $display("ext_c#(.K(7))::new(.a(1)): id=%0d v=%0d", b.id(), b.v);
    c = new b;
    $display("new b: id=%0d v=%0d distinct=%0d", c.id(), c.v, c != b);
    b = new;
    $display("new: id=%0d v=%0d", b.id(), b.v);
  end
endmodule
