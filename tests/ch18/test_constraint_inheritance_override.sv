/*
:name: test_constraint_inheritance_override
:description: A derived class inherits the constraints of its base class, and a constraint with the same name replaces the inherited one (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.2 18.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_inheritance_override.expected
*/
// IEEE 1800-2023 §18.5.2: a derived class has all the constraints of its base
// class; a constraint of the same name replaces the inherited one, and one with
// a new name is added. randomize() is virtual, so the constraints of the object
// apply even when it is called through a base class handle. When the inherited
// and the replacing constraints contradict each other randomize() fails and the
// variable keeps its value (18.6.3).

class cio_base;
  rand bit [3:0] v;
  constraint c_val   { v == 4'd3; }
  constraint c_limit { v < 4'd8; }
endclass

class cio_derived extends cio_base;
  constraint c_val { v == 4'd6; }
endclass

class cio_bad extends cio_base;
  constraint c_val { v == 4'd9; }
endclass

module test_constraint_inheritance_override;
  cio_base h;
  cio_derived d;
  cio_bad bad;
  int ok;

  initial begin
    h = new;
    ok = h.randomize();
    $display("base: ok=%0d v=%0d", ok, h.v);
    d = new;
    h = d;
    ok = h.randomize();
    $display("derived through a base handle: ok=%0d v=%0d", ok, h.v);
    bad = new;
    bad.v = 4'd1;
    ok = bad.randomize();
    $display("replacing constraint against the inherited limit: ok=%0d v=%0d", ok, bad.v);
  end
endmodule
