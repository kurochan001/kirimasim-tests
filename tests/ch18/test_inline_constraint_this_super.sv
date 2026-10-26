/*
:name: test_inline_constraint_this_super
:description: In an inline constraint this and super bind to the class of the randomize() with object, while local::this and local::super bind in the scope that contains the call (IEEE 1800-2023 Section 18.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7.1 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inline_constraint_this_super.expected
*/
// IEEE 1800-2023 §18.7.1: names qualified only by this or super bind to the
// class of the object handle used in the randomize() with call, and names
// qualified by local:: bind in the scope that contains the call, including
// local::this and local::super. The caller ts_caller has a member v = 9 and a
// base member w = 3; the receiver ts_recv has a member v and a base member w.
// The inline constraint this.v == 1 sets the receiver's v, super.w == 2 its
// base w, and the two local:: forms check the caller's state (9 and 3), so the
// call succeeds only when all four bind as described.
// In Verilator 5.052 the local:: forms of this test are not supported.

class ts_rbase;
  rand int w;
endclass

class ts_recv extends ts_rbase;
  rand int v;
endclass

class ts_cbase;
  int w = 3;
endclass

class ts_caller extends ts_cbase;
  int v = 9;

  function int go(ts_recv r);
    go = r.randomize() with {
      this.v == 1;
      super.w == 2;
      local::this.v == 9;
      local::super.w == 3;
    };
  endfunction
endclass

module test_inline_constraint_this_super;
  ts_caller c = new;
  ts_recv r = new;
  int ok;

  initial begin
    ok = c.go(r);
    $display("call %0d, receiver v %0d, receiver w %0d", ok, r.v, r.w);
    $display("caller v %0d, caller w %0d", c.v, c.w);
  end
endmodule
