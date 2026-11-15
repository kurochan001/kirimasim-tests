/*
:name: test_task_formal_direction_default_and_inherited
:description: Task formals with no direction are inputs until a direction is given, and a later formal with no direction behaves as an output, an inout or a ref when the formal before it is one (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_formal_direction_default_and_inherited.expected
*/
// IEEE 1800-2023 §13.3: a formal with no direction is an input when no
// direction has been given before it; once a direction is given, the formals
// after it that have none take the same direction.
//
// In t(int a, b, output int u, v, inout int w, x, ref int r1, r2), a and b
// have no direction and are inputs, v takes output from u, x takes inout from
// w, and r2 takes ref from r1. The task prints a, b, v, x and r2 on entry,
// writes each of them, and prints their actuals, which it reads by their
// module names, before it returns; the initial procedure prints the actuals
// again after the call.
//   a, b: inputs, so they start with ia and ib (1 and 2), and the writes 100
//         and 200 reach ia and ib neither before nor after the return;
//   v:    output, so it starts at 0, the initial value of an int formal of an
//         automatic task, not with ov (60), and ov gets 5 on the return;
//   x:    inout, so it starts with ix (8), and ix gets 18 only on the return;
//   r2:   ref, so it starts with rr2 (4), and rr2 gets 9 at once, before the
//         task returns (13.5.2).
// A formal that wrongly kept the input direction would leave its actual
// unchanged after the return, one that wrongly became ref would change the
// actual before the return, and an output that started from its actual
// would print 60 on entry.
// Icarus Verilog 13.0 does not support ref ports.

module test_task_formal_direction_default_and_inherited;
  int ia, ib, ou, ov, iw, ix, rr1, rr2;

  task automatic t(int a, b, output int u, v, inout int w, x, ref int r1, r2);
    $display("entry: a=%0d b=%0d v=%0d x=%0d r2=%0d", a, b, v, x, r2);
    a = 100;
    b = 200;
    v = 5;
    x = x + 10;
    r2 = 9;
    $display("before return: ia=%0d ib=%0d ov=%0d ix=%0d rr2=%0d", ia, ib, ov, ix, rr2);
  endtask

  initial begin
    ia = 1;
    ib = 2;
    ou = 50;
    ov = 60;
    iw = 7;
    ix = 8;
    rr1 = 3;
    rr2 = 4;
    t(ia, ib, ou, ov, iw, ix, rr1, rr2);
    $display("after return: ia=%0d ib=%0d ov=%0d ix=%0d rr2=%0d", ia, ib, ov, ix, rr2);
  end
endmodule
