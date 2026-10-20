/*
:name: test_global_constraints_rand_handles
:description: Constraints on the members of objects held by rand handles are solved together with the object's own, while an object held by a handle that is not rand is not randomized and its constraints are not applied (IEEE 1800-2023 Section 18.5.8)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.8 18.4 18.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_constraints_rand_handles.expected
*/
// IEEE 1800-2023 §18.5.8: randomize() of a Parent also randomizes the Node
// objects of its rand handles left and right, with their constraint nonzero,
// and solves the global constraint tree with them. fixed is not rand, so its
// object is not among the active random objects: its v stays 0 and is used as
// a state variable, and its constraint nonzero, which v = 0 breaks, is not
// applied. If it were, every call would fail (18.6.1). The test checks the
// results of 20 calls.

class Node;
  rand bit [7:0] v;
  constraint nonzero { v != 0; }
endclass

class Parent;
  rand bit [7:0] v;
  rand Node left, right;
  Node fixed;
  constraint tree { left.v < v; right.v > v; v > fixed.v; }

  function new();
    left = new();
    right = new();
    fixed = new();
    fixed.v = 0;
  endfunction
endclass

module test_global_constraints_rand_handles;
  Parent p = new();
  int ok = 0, failed = 0;

  initial begin
    repeat (20) begin
      if (!p.randomize()) failed++;
      else if (p.left.v != 0 && p.left.v < p.v && p.v < p.right.v && p.right.v != 0) ok++;
    end
    $display("%0d calls met the constraints, %0d failed; fixed.v = %0d", ok, failed, p.fixed.v);
  end
endmodule
