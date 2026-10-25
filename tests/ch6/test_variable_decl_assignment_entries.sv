/*
:name: test_variable_decl_assignment_entries
:description: lists of variable declaration assignments whose entries are names with fixed, queue, associative and dynamic dimensions and an optional initializer, dynamic arrays with new[n] and new[n](array), and class variables with new, new(arguments), a typed constructor call, a shallow copy or no initializer (IEEE 1800-2023 Sections 6.8, 7.5.1, 8.8, 8.12, A.2.3, A.2.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 7.5.1 8.7 8.8 8.12 A.2.3 A.2.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_decl_assignment_entries.expected
*/
// IEEE 1800-2023 A.2.3: a list of variable declaration assignments has one or
// more entries separated by commas. A.2.4: an entry is a name with variable
// dimensions and an optional = expression; a dynamic array name with [],
// optional further dimensions and an optional new[size] or new[size](array);
// or a class variable with an optional constructor call, written new,
// new(arguments) or class_scope::new(...), or new handle (a shallow copy).
// - m2, q, aa and d0 are one declaration: a fixed array and a queue with
//   initializers, an associative array without one (empty) and a dynamic
//   array sized by new[3] (elements 0).
// - §7.5.1: new[4](src) copies src and pads with 0 or truncates it to 4
//   elements; new[1](src) keeps only src[0]; d3 has elements of the fixed
//   type int [2], so new[k] alone gives k elements of 2 ints; d4 without an
//   initializer is empty.
// - §8.7: new runs the constructor, here with its default argument 5, and
//   new(k) passes k; §8.8: Leaf::new(k) builds a Leaf (val k + 100) that a
//   Node variable holds, so $cast to Leaf succeeds; §8.12: new from copies
//   the object, so writing from.val afterwards leaves the copy unchanged; a
//   class variable without an initializer is null.
// The entries in the task depend only on its arguments, which exist before
// the body starts, so no initializer depends on another one. Icarus Verilog
// 13.0 does not compile the test (typed constructor calls, dynamic arrays
// of arrays and associative array methods).

class Node;
  int val;
  function new(int v = 5);
    val = v;
  endfunction
endclass

class Leaf extends Node;
  function new(int v = 9);
    super.new(v + 100);
  endfunction
endclass

module test_variable_decl_assignment_entries;
  int m2 [2][3] = '{'{1, 2, 3}, '{4, 5, 6}}, q [$] = '{10, 20}, aa [string], d0 [] = new[3];

  task automatic check(int k, int src [], Node from);
    int d1 [] = new[4](src), d2 [] = new[1](src), d3 [][2] = new[k], d4 [];
    Node n_copy = new from, n_def = new, n_arg = new(k), n_typed = Leaf::new(k), n_none;
    Leaf l_h;
    from.val = 0;
    d3[k - 1][1] = 7 * k;
    $display("k=%0d d1=%0d,%0d,%0d,%0d/%0d d2=%0d/%0d d3=%0d,%0d,%0d d4=%0d", k, d1[0], d1[1],
             d1[2], d1[3], d1.size(), d2[0], d2.size(), d3.size(), $size(d3[0]), d3[k - 1][1],
             d4.size());
    $display("k=%0d copy=%0d orig=%0d def=%0d arg=%0d typed=%0d cast=%0d none_null=%0d", k,
             n_copy.val, from.val, n_def.val, n_arg.val, n_typed.val, $cast(l_h, n_typed),
             n_none == null);
  endtask

  initial begin
    Node p;
    p = new(77);
    $display("m2=%0d,%0d q=%0d,%0d/%0d aa=%0d d0=%0d/%0d", m2[0][0], m2[1][2], q[0], q[1],
             q.size(), aa.num(), d0[2], d0.size());
    check(2, '{1, 2}, p);
    p.val = 88;
    check(5, '{3, 4, 5, 6, 7}, p);
  end
endmodule
