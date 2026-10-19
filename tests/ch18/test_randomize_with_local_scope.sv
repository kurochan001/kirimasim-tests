/*
:name: test_randomize_with_local_scope
:description: Names in a randomize() with block refer first to the object's class, and local:: refers to the caller's scope (IEEE 1800-2023 Section 18.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7.1 18.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_with_local_scope.expected
*/
// IEEE 1800-2023 §18.7, §18.7.1: a name in the inline constraint of
// obj.randomize() with { ... } is looked up first in the class of obj and then
// in the scope of the call; local:: skips the class and takes the name from the
// scope of the call. So when the caller has variables x and lim and the class
// has properties of the same names, x and lim mean the properties and local::x
// and local::lim mean the caller's variables.

class rwl_obj;
  rand int x;
  int lim = 100;
endclass

module test_randomize_with_local_scope;
  rwl_obj o;

  function automatic void run(rwl_obj obj);
    int x;
    int lim;
    x = 5;
    lim = 3;
    void'(obj.randomize() with { x == local::x + 1; });
    $display("x == local::x + 1: x=%0d", obj.x);
    void'(obj.randomize() with { x == lim; });
    $display("x == lim: x=%0d", obj.x);
    void'(obj.randomize() with { x == local::lim; });
    $display("x == local::lim: x=%0d", obj.x);
  endfunction

  initial begin
    o = new;
    run(o);
  end
endmodule
