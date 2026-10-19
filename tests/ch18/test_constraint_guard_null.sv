/*
:name: test_constraint_guard_null
:description: A constraint guard on a null handle keeps the solver from using the missing object (IEEE 1800-2023 Section 18.5.12)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.12 18.5.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_guard_null.expected
*/
// IEEE 1800-2023 §18.5.12: a condition that uses only constants, state
// variables and handle comparisons, such as next != null, is a guard: it is
// evaluated before solving, and the constraint it guards (18.5.6) is created
// only when it is true. So the last node of a list, whose next is null,
// randomizes without error, and each other node gets a value below its
// successor. Verilator 5.052 reads next.v of the last node and stops on the
// null handle; Icarus Verilog 13.0 does not compile classes with constraints.

class cgn_node;
  rand bit [7:0] v;
  cgn_node next;
  constraint c_order { if (next != null) v < next.v; }
endclass

module test_constraint_guard_null;
  cgn_node n0, n1, n2;
  int ok2, ok1, ok0;

  initial begin
    n0 = new; n1 = new; n2 = new;
    n0.next = n1;
    n1.next = n2;
    ok2 = n2.randomize() with { v > 200; };
    ok1 = n1.randomize() with { v > 100; };
    ok0 = n0.randomize();
    $display("ok: %0d %0d %0d", ok2, ok1, ok0);
    $display("ordered: %0d", n0.v < n1.v && n1.v < n2.v);
  end
endmodule
