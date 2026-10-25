/*
:name: test_constraint_grammar_forms
:description: A constraint block holds expressions of each form - soft, dist, implication to a braced set, if-else with a single expression, foreach, unique, solve-before with several primaries, disable soft - and an empty block; the values after randomize() show each form (IEEE 1800-2023 Sections 18.5.3 to 18.5.9 and 18.5.13)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3 18.5.4 18.5.5 18.5.6 18.5.7 18.5.9 18.5.13 18.5.13.2 A.1.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_grammar_forms.expected
*/
// IEEE 1800-2023 §18.5 with A.1.10: a constraint block is braces around zero
// or more constraint-block items, an item being a constraint expression or a
// solve-before item. A constraint set may be one expression or a braced list.
// The class below has an empty block and one expression of each form: a soft
// constraint (§18.5.13), a distribution with a value range and a default
// weight (§18.5.3), an implication to a braced set of two expressions
// (§18.5.5), an if-else whose branches are single expressions (§18.5.6), a
// foreach over a fixed array (§18.5.7), a unique constraint (§18.5.4), and a
// solve-before item with several primaries on each side (§18.5.9). The last
// block declares a soft constraint on e, disables it (§18.5.13.2), and gives
// e a new soft value; the empty declaration of dyn then fixes its size.
//
// Every random variable but p, q and the elements of dyn is fixed by a
// constraint, so the print is the same on every run: a is 5 from the soft
// constraint, b 4 from its positive bound and the implication, c 6 from the
// taken if branch, d 8 from the only value with a nonzero weight, arr is 1,
// 2, 3, u, v and w are three different values, and e is 12 because disable
// soft removed the earlier soft value 11. p and q are only ordered against f
// and g, which are 10 and 11. distinct is 1 when u, v and w differ.

class cg_obj;
  rand int a;
  rand int b;
  rand int c;
  rand int d;
  rand int arr[3];
  rand bit [1:0] u, v, w;
  rand int p, q, f, g;
  rand int e;
  rand int dyn[];

  constraint c_empty { }
  constraint c_soft { soft a == 5; }
  constraint c_pos { b > 0; }
  constraint c_imp { b > 0 -> { b == 4; b < 5; } }
  constraint c_if { if (a == 5) c == 6; else c == 7; }
  constraint c_dist { d dist { [8:8] := 1, default :/ 0 }; }
  constraint c_foreach { foreach (arr[i]) arr[i] == i + 1; }
  constraint c_unique { unique {u, v, w}; }
  constraint c_solve { solve this.p, q before f, g; q == 9; f == 10; g == 11; }
  constraint c_soft2 { soft e == 11; disable soft e; soft e == 12; }
  constraint c_size { soft dyn.size() == 2; disable soft dyn.size(); dyn.size() == 3; }
endclass

module test_constraint_grammar_forms;
  cg_obj o;
  int ok;
  int distinct;

  initial begin
    o = new;
    ok = o.randomize();
    distinct = (o.u != o.v) && (o.v != o.w) && (o.u != o.w);
    $display("ok=%0d a=%0d b=%0d c=%0d d=%0d arr=%0d,%0d,%0d", ok, o.a, o.b, o.c,
             o.d, o.arr[0], o.arr[1], o.arr[2]);
    $display("e=%0d f=%0d g=%0d q=%0d size=%0d distinct=%0d", o.e, o.f, o.g, o.q,
             o.dyn.size(), distinct);
  end
endmodule
