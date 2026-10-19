/*
:name: test_static_constraint_mode
:description: constraint_mode on a static constraint block turns it off and on for every object of the class (IEEE 1800-2023 Section 18.5.10)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.10 18.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_constraint_mode.expected
*/
// IEEE 1800-2023 §18.5.10: constraint_mode() (18.9) on a static constraint
// block affects that constraint in all objects of the class, while for an
// ordinary constraint block it affects only the object it is called on.

class scm_obj;
  rand bit [3:0] v, w;
  static constraint c_s { v == 4'd5; }
  constraint c_d { w == 4'd6; }
endclass

module test_static_constraint_mode;
  scm_obj a, b;
  int ok;

  initial begin
    a = new;
    b = new;
    a.c_s.constraint_mode(0);
    a.c_d.constraint_mode(0);
    $display("after turning both off in a: b.c_s=%0d b.c_d=%0d", b.c_s.constraint_mode(), b.c_d.constraint_mode());
    ok = b.randomize() with { v == 4'd9; };
    $display("b with v==9: ok=%0d v=%0d", ok, b.v);
    ok = b.randomize() with { w == 4'd9; };
    $display("b with w==9: ok=%0d", ok);
    b.c_s.constraint_mode(1);
    ok = a.randomize();
    $display("after turning c_s on in b: a.c_s=%0d a.v=%0d", a.c_s.constraint_mode(), a.v);
  end
endmodule
