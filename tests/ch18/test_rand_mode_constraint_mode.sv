/*
:name: test_rand_mode_constraint_mode
:description: rand_mode turns a random variable into a state variable and constraint_mode turns constraint blocks off and on (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.8 18.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_mode_constraint_mode.expected
*/
// IEEE 1800-2023 §18.8: rand_mode(0) makes a random variable inactive: it is not
// changed by randomize() and is used as a state variable, and rand_mode() returns
// its current mode. §18.9: constraint_mode(0) turns a constraint block off, and
// constraint_mode() returns whether it is on. Called on the object, both apply to
// all variables or all constraint blocks.

class rmc_obj;
  rand bit [7:0] a, b;
  constraint c_a { a == 8'd10; }
  constraint c_b { b == 8'd20; }
endclass

module test_rand_mode_constraint_mode;
  rmc_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("all on: ok=%0d a=%0d b=%0d", ok, o.a, o.b);
    o.a.rand_mode(0);
    o.c_a.constraint_mode(0);
    o.a = 8'd77;
    ok = o.randomize();
    $display("a inactive, c_a off: ok=%0d a=%0d b=%0d", ok, o.a, o.b);
    $display("modes: a.rand_mode=%0d b.rand_mode=%0d c_a=%0d c_b=%0d",
             o.a.rand_mode(), o.b.rand_mode(), o.c_a.constraint_mode(), o.c_b.constraint_mode());
    o.c_a.constraint_mode(1);
    ok = o.randomize();
    $display("a inactive, c_a on again with a=77: ok=%0d a=%0d", ok, o.a);
    o.rand_mode(1);
    o.constraint_mode(1);
    ok = o.randomize();
    $display("all on again: ok=%0d a=%0d b=%0d", ok, o.a, o.b);
  end
endmodule
