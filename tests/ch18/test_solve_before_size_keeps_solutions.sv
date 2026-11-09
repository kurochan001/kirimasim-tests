/*
:name: test_solve_before_size_keeps_solutions
:description: The size of a rand queue or dynamic array, written size() or size, may stand on either side of solve...before, also in an inline constraint block, and the ordering keeps the set of solutions, so a size that has no solution for the later variables is never chosen (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9 18.4 18.5.7.1 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_size_keeps_solutions.expected
*/
// IEEE 1800-2023 §18.5.9 (with §18.4): the size of a rand dynamic array or
// queue may be ordered in solve...before, with or without the empty
// parentheses after size, and on either side of before. An ordering only
// changes how likely each solution is; it never removes a solution and so
// cannot make randomize() fail. The solver therefore cannot pick the size of
// q first and then find no x for it.
// - c_q allows q.size() 2, 3 or 4, but x == 10 * size and x > 30 leave only
//   size 4 with x 40. solve q.size() before x does not change that, so every
//   call prints q.size=4 x=40 (a solver that fixed the size at 2 or 3 before
//   looking at x would fail and return 0).
// - c_d leaves only y == 2, so d.size() == y + 1 is 3; solve y before d.size
//   (the size on the right of before) is legal. §18.5.7.1: the size is solved
//   before the foreach over d, so d is 5 6 7.
// - §18.7: the constraint block of randomize() with may hold a solve...before
//   item too. The inline block orders q.size() before z with z == size + 1,
//   so z is 5 while c_q still gives size 4.
// The values printed are the only solution of each constraint set.
// Icarus Verilog 13.0 does not support constraints. The 5.052 release
// of Verilator rejects the parentheses after size in solve...before,
// and without them it stops with an internal error at the ordering of
// the size.

class sbk_obj;
  rand byte q[$];
  rand int x;
  rand int y;
  rand int z;
  rand bit [7:0] d[];
  constraint c_q { q.size() inside {[2:4]}; x == q.size() * 10; x > 30; }
  constraint o_q { solve q.size() before x; }
  constraint c_d { y inside {[1:2]}; y != 1; d.size() == y + 1;
                   foreach (d[i]) d[i] == 8'(i + 5); }
  constraint o_d { solve y before d.size; }
endclass

module test_solve_before_size_keeps_solutions;
  sbk_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d q.size=%0d x=%0d", ok, o.q.size(), o.x);
    $display("ok=%0d y=%0d d.size=%0d d=%0d %0d %0d", ok, o.y, o.d.size(), o.d[0], o.d[1],
             o.d[2]);
    ok = o.randomize() with { solve q.size() before z; z == q.size() + 1; };
    $display("ok=%0d q.size=%0d z=%0d", ok, o.q.size(), o.z);
  end
endmodule
