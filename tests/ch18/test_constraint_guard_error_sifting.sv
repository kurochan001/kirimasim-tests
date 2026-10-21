/*
:name: test_constraint_guard_error_sifting
:description: In a guard, a true term of a disjunction or a false term of a conjunction decides the guard even when another term reads through a null handle, and a guard that is true creates its constraint (IEEE 1800-2023 Section 18.5.12)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.12 18.5.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_guard_error_sifting.expected
*/
// IEEE 1800-2023 §18.5.12: the conditions of the implications (18.5.5) here
// use only state variables, so they are guards, evaluated before solving.
// Each term is true, false, or an error, such as a.x > b.x when b is null.
// A disjunction with a true term is true, and a conjunction with a false
// term is false, whatever the other terms give; only otherwise does an error
// make the guard an error.
// With a.x = 5 and b null, the guard of c_or is true, so v == 10 is created,
// and that of c_and is false, so v == 20 is not: randomize() succeeds and v
// is 10. With b set and a.x = 6, b.x = 1 both guards are true, both
// constraints are created, and randomize() fails, leaving v at 10. With
// b.x = 9 both guards are false and v is free: the inline v == 33 holds.

class cge_data;
  int x;
endclass

class cge_obj;
  rand bit [7:0] v;
  cge_data a, b;
  constraint c_or  { (a.x == 5 || a.x > b.x) -> v == 8'd10; }
  constraint c_and { (a.x == 6 && a.x > b.x) -> v == 8'd20; }
endclass

module test_constraint_guard_error_sifting;
  cge_obj o;
  int ok;

  initial begin
    o = new;
    o.a = new;
    o.a.x = 5;
    ok = o.randomize();
    $display("a.x=5, b null: ok=%0d v=%0d", ok, o.v);
    o.b = new;
    o.a.x = 6;
    o.b.x = 1;
    ok = o.randomize();
    $display("a.x=6, b.x=1: ok=%0d v=%0d", ok, o.v);
    o.b.x = 9;
    ok = o.randomize() with { v == 8'd33; };
    $display("a.x=6, b.x=9: ok=%0d v=%0d", ok, o.v);
  end
endmodule
