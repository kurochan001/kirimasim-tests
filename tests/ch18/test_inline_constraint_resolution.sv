/*
:name: test_inline_constraint_resolution
:description: In an inline constraint a dotted name is resolved downwards from the receiver class first and then from the scope of the call, local::lim reaches a wildcard-imported package name, local:: may qualify a type or a class scope, and randomize() with can appear wherever an expression can and use every constraint form (IEEE 1800-2023 Sections 18.7 and 18.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7 18.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inline_constraint_resolution.expected
*/
// IEEE 1800-2023 §18.7: a dotted name in an unrestricted inline constraint is
// resolved downwards from the receiver class first. The local variable sub is
// also an object with a member x, but sub.x binds to r.sub.x, so that x is 7
// and the local one stays 42. The receiver class has no other, so other.x
// falls back to the local object and its state value 5 makes the call succeed,
// while other.x == 6 fails. randomize() with is an expression: it can be an
// argument of a function and the condition of ?:, and its block uses dist,
// if-else, foreach, unique, soft and disable soft.
// §18.7.1: local::lim reaches the package name imported by the wildcard
// import, so both local::lim and the unqualified lim give the package value
// 4; local:: may qualify the local type ir_int and the class scope ir_scope.
// In Verilator 5.052 the inline local:: forms of this test are not supported.

package ir_pkg;
  int lim = 4;
endpackage

class ir_inner;
  rand int x;
endclass

class ir_recv;
  rand ir_inner sub;
endclass

class ir_forms;
  rand int a, b, c;
  rand int arr[3];
  rand int u1, u2;
endclass

class ir_scope;
  static int sv = 9;
endclass

module test_inline_constraint_resolution;
  import ir_pkg::*;

  typedef int ir_int;

  ir_inner sub;
  ir_inner other;
  ir_recv r;
  ir_forms f;
  int down_ok, local_kept, fallback_true, fallback_false;
  int arg_ok, ternary_ok, forms_ok;

  function automatic int consume(int v);
    return v;
  endfunction

  initial begin
    sub = new;
    sub.x = 42;
    r = new;
    r.sub = new;
    down_ok = r.randomize() with { sub.x == 7; };
    local_kept = (sub.x == 42);
    $display("dotted name: receiver first %0d, local kept %0d",
             down_ok && r.sub.x == 7, local_kept);
    other = new;
    other.x = 5;
    fallback_true = r.randomize() with { other.x == 5; };
    fallback_false = r.randomize() with { other.x == 6; };
    $display("fallback to the call scope: true %0d, false %0d",
             fallback_true, fallback_false);
    f = new;
    arg_ok = consume(f.randomize() with { a == 0; b == 1; }) == 1;
    ternary_ok = (f.randomize() with { a == 1; b dist {2 := 1, 3 := 1}; })
                 ? (f.a + f.b == 3 || f.a + f.b == 4) : 0;
    forms_ok = f.randomize() with {
      solve a before b;
      a dist {0 := 1, 1 := 1};
      if (a) b == 2; else b == 3;
      foreach (arr[i]) arr[i] inside {[0:9]};
      unique {u1, u2};
      soft c == 4;
      disable soft c;
      c inside {[4:5]};
    };
    $display("expression and forms: argument %0d, ternary %0d, forms %0d",
             arg_ok, ternary_ok, forms_ok);
    $display("local import: local 4 %0d, unqualified 4 %0d",
             f.randomize() with { a == local::lim; } && f.a == 4,
             f.randomize() with { a == lim; } && f.a == 4);
    $display("local type name: 7 %0d", f.randomize() with { a == local::ir_int'(7); }
             && f.a == 7);
    $display("local class scope: 9 %0d", f.randomize() with { a == local::ir_scope::sv; }
             && f.a == 9);
  end
endmodule
