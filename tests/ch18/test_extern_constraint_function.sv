/*
:name: test_extern_constraint_function
:description: Constraint blocks declared by prototype and completed outside the class, and a function call in a constraint (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.1 18.5.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_constraint_function.expected
*/
// IEEE 1800-2023 §18.5.1: a class can declare a constraint by name only, in the
// implicit form or with extern, and give its block after the class with the
// class scope resolution operator. §18.5.11: a function can be called in a
// constraint; the random variables passed to it are solved before the
// constraint that uses the result, so here a is 12 and b is twice a.

class ecf_obj;
  rand bit [7:0] a, b;
  constraint c_a;
  extern constraint c_b;
  function int twice(int x);
    return 2 * x;
  endfunction
endclass

constraint ecf_obj::c_a { a == 8'd12; }
constraint ecf_obj::c_b { b == twice(a); }

module test_extern_constraint_function;
  ecf_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d a=%0d b=%0d", ok, o.a, o.b);
  end
endmodule
