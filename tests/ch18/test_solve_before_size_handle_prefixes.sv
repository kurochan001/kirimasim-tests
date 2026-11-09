/*
:name: test_solve_before_size_handle_prefixes
:description: A solve...before list may name the size of an array through this or through a rand class handle, next to other sizes and variables on each side, and the sizes and values are the ones the other constraints fix (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9 18.4 A.1.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_size_handle_prefixes.expected
*/
// IEEE 1800-2023 §18.5.9 and A.1.10: each entry of a solve...before list is a
// constraint primary, which may start with an implicit class handle such as
// this and may be a hierarchical name, and may end in the empty parentheses
// of an array method such as size(); a list may hold several entries. The
// size of a rand dynamic array or queue counts as a variable that can be
// ordered (§18.4), also when the array belongs to the object of a rand class
// handle, whose variables are solved together with those of the containing
// object (§18.4).
// The order constraint names this.q.size() and h.v.size (the array v of the
// rand member object h) before n and m. The other constraints leave one
// solution: both sizes are at most 3 and add up to 6, so both are 3, n is
// their difference 0 and m is 2 * n + 1, that is 1. The elements of v are
// fixed to 9 by the constraint of its own class. The second call adds an
// inline block that orders h.v.size() and n before k with
// k == 10 * h.v.size(), so k is 30 and the other values stay the same.
// Icarus Verilog 13.0 does not support constraints. The 5.052 release
// of Verilator rejects the parentheses after size in solve...before;
// without the ordering constraints it finds no solution for the size
// and foreach constraints of the member object h, although it solves
// them for an object of that class alone.

class sbh_item;
  rand bit [3:0] v[];
  constraint c_v { v.size() inside {[1:3]}; foreach (v[i]) v[i] == 4'd9; }
endclass

class sbh_obj;
  rand sbh_item h;
  rand bit [3:0] q[$];
  rand int n, m, k;
  constraint c { q.size() <= 3; q.size() + h.v.size() == 6;
                 n == int'(q.size()) - int'(h.v.size()); m == 2 * n + 1; }
  constraint o { solve this.q.size(), h.v.size before n, m; }
  function new();
    h = new;
  endfunction
endclass

module test_solve_before_size_handle_prefixes;
  sbh_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d q.size=%0d v.size=%0d n=%0d m=%0d v=%0d %0d %0d", ok, o.q.size(),
             o.h.v.size(), o.n, o.m, o.h.v[0], o.h.v[1], o.h.v[2]);
    ok = o.randomize() with { solve h.v.size(), n before k; k == 10 * h.v.size(); };
    $display("ok=%0d q.size=%0d v.size=%0d n=%0d m=%0d k=%0d", ok, o.q.size(), o.h.v.size(),
             o.n, o.m, o.k);
  end
endmodule
