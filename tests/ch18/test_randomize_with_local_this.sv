/*
:name: test_randomize_with_local_this
:description: In a randomize() with block called from a method of another class, this names the randomized object, local::this and local:: names the calling object, and local:: also bypasses the object class in a restricted block (IEEE 1800-2023 Section 18.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7.1 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_with_local_this.expected
*/
// IEEE 1800-2023 §18.7.1: in t.randomize() with { ... }, names qualified by
// this bind to the class of t, while local:: starts the search in the scope
// of the call, here a method of rwt_caller, and local::this is the calling
// object. Both classes have lim and x. So this.lim is the 100 of t,
// local::this.lim the 7 of the caller, and local::x the caller's 40, while
// the unqualified k is found in the class of t (3). In a restricted block,
// with (x), only x resolves in the class of t (18.7): lim is the caller's,
// and local::x still is the caller's x.

class rwt_target;
  rand int x;
  int lim = 100;
  int k = 3;
endclass

class rwt_caller;
  int lim = 7;
  int x = 40;
  rwt_target t;

  function new();
    t = new;
  endfunction

  function void run();
    void'(t.randomize() with { x == this.lim; });
    $display("x == this.lim: %0d", t.x);
    void'(t.randomize() with { x == local::this.lim + 1; });
    $display("x == local::this.lim + 1: %0d", t.x);
    void'(t.randomize() with { x == local::x + k; });
    $display("x == local::x + k: %0d", t.x);
    void'(t.randomize() with (x) { x == lim + 2; });
    $display("with (x), x == lim + 2: %0d", t.x);
    void'(t.randomize() with (x) { x == local::x + 1; });
    $display("with (x), x == local::x + 1: %0d", t.x);
  endfunction
endclass

module test_randomize_with_local_this;
  rwt_caller c;

  initial begin
    c = new;
    c.run();
  end
endmodule
