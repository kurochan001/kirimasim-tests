/*
:name: test_soft_handle_priority
:description: Among the random objects held by a container, a later declared handle has higher priority for its soft constraints, and handles that alias one object use its highest-priority, last-declared handle (IEEE 1800-2023 Section 18.5.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.1 18.5.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_soft_handle_priority.expected
*/
// IEEE 1800-2023 §18.5.13.1: the soft constraints of contained objects rank by
// the declaration order of their handles, a later handle above an earlier one.
// Each leaf prefers its own value pref, and the hard constraints make all
// leaves equal, so the highest-priority soft constraint decides:
// - a, b and c are distinct and prefer 1, 2 and 3; c is declared last, so v
//   is 3 in every leaf;
// - in the second object c aliases a, and the constraints of that object use
//   its highest-priority handle, c, so a's preference 1 now outranks b's 2 and
//   v is 1.

class sh_leaf;
  rand int v;
  int pref;
  constraint c { soft v == pref; }
endclass

class sh_obj;
  rand sh_leaf a, b, c;
  constraint g { a.v == b.v; b.v == c.v; }
  function new();
    a = new;
    b = new;
    c = new;
  endfunction
endclass

module test_soft_handle_priority;
  sh_obj o1 = new;
  sh_obj o2 = new;
  int ok1, ok2;

  initial begin
    o1.a.pref = 1;
    o1.b.pref = 2;
    o1.c.pref = 3;
    ok1 = o1.randomize();
    $display("distinct handles: ok %0d, v %0d", ok1, o1.a.v);
    o2.c = o2.a;
    o2.a.pref = 1;
    o2.b.pref = 2;
    ok2 = o2.randomize();
    $display("aliased handles: ok %0d, v %0d", ok2, o2.a.v);
  end
endmodule
