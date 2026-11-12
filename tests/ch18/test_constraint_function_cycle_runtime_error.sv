/*
:name: test_constraint_function_cycle_runtime_error
:description: Random variables used as function arguments establish an implicit ordering, and a circular dependency created by that ordering results in an error; the cycle exists only among the constraints that are active, so randomize() succeeds while one of the two constraint blocks is off and reports the error once both are on (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.11 18.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_function_cycle_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §18.5.11: a random variable used as a function argument gets
// the higher priority, so c1 solves y before x and c2 solves x before y. A
// circular dependency created by this implicit ordering shall result in an
// error. §18.9: constraint_mode(0) makes a constraint block inactive, and
// randomize() does not consider an inactive block. With c2 off only c1
// orders the variables, so the first randomize() succeeds and gives x <= y.
// With c2 on again the two orderings form a cycle, and the second
// randomize() shall give the error. The clause does not say when the error
// is reported or what it looks like, so the messages of the run are checked
// only for an error, after the two lines that the test prints before it.
// Until 2026-11-12 this was an illegal-design test that accepted only a
// rejection at compilation that named the constraint lines. The ordering
// depends on which constraints are active when randomize() is called, so a
// tool that reports the cycle at run time conforms too; with the constraint
// switched off first, the design is legal until the second call.

`timescale 1ns/1ns

class c_function_cycle;
  rand int x, y;

  function automatic int f(int v);
    return v;
  endfunction

  constraint c1 { x <= f(y); }   // y before x
  constraint c2 { y <= f(x); }   // x before y: a cycle when both are active
endclass

module test_constraint_function_cycle_runtime_error;
  c_function_cycle o = new;

  initial begin
    o.c2.constraint_mode(0);
    if (o.randomize() && o.x <= o.y) $display("c1 alone: solved");
    o.c2.constraint_mode(1);
    $display("calling randomize with c1 and c2");
    void'(o.randomize());
  end
endmodule
