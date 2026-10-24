/*
:name: test_class_this_selects_invoking_object_members
:description: this is the handle of the object a method was called on, and this.name selects that object's property, value parameter or method when an argument or local variable has the same name (IEEE 1800-2023 Section 8.11)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_this_selects_invoking_object_members.expected
*/
// IEEE 1800-2023 §8.11: this is a predefined object handle for the object used
// to invoke the method in which it appears, and it refers unambiguously to
// the properties, value parameters, local value parameters and methods of
// that object. An unqualified name resolves to the innermost scope first, so
// an argument called total hides the property total, which this.total still
// reaches.
// a and b are two objects; each call works on the object it is made through.
// add has an argument and a local variable named like the property total and
// the parameter STEP; this.total, this.STEP and this.get() reach the members.
// self returns this, which is compared with the handles a and b.
// Icarus Verilog 13.0 does not support parameterized classes.

class acc_c #(int STEP = 2);
  int total;
  function new(int total);
    this.total = total;
  endfunction
  function void add(int total);
    int STEP = 100;
    this.total = this.total + total * this.STEP + STEP - 100;
  endfunction
  function int get();
    return total;
  endfunction
  function int twice();
    return 2 * this.get();
  endfunction
  function acc_c #(STEP) self();
    return this;
  endfunction
endclass

module test_class_this_selects_invoking_object_members;
  acc_c #(2) a, b;

  initial begin
    a = new(5);
    b = new(100);
    a.add(3);
    b.add(1);
    $display("a.total=%0d b.total=%0d", a.total, b.total);
    $display("a.twice()=%0d b.twice()=%0d", a.twice(), b.twice());
    $display("a.self()==a=%0d a.self()==b=%0d b.self()==b=%0d", a.self() == a, a.self() == b,
             b.self() == b);
  end
endmodule
