/*
:name: test_object_strongly_reachable
:description: An object stays strongly reachable, so its weak references are not cleared, while a handle in an active scope refers to it or a nonblocking assignment to one of its members is pending (IEEE 1800-2023 Section 8.29)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.29 8.30.1 8.30.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_object_strongly_reachable.expected
*/
// IEEE 1800-2023 §8.29: an object is strongly reachable while a class handle
// in an active scope refers to it, or while a nonblocking assignment to one of
// its non-static members is pending, and only an object that is not strongly
// reachable can lose its weak references (8.30.1). kept stays referenced by
// the automatic variable of a task that is still waiting at 5. The only
// handle to pending is cleared right after a nonblocking assignment to its
// member, and get() (8.30.3) is called before that update. The output says
// nothing about what happens to objects that become unreachable, which the
// standard leaves to the implementation.

`timescale 1ns/1ns

module test_object_strongly_reachable;
  class item;
    int v;
  endclass

  weak_reference #(item) wk, wp;
  item h;

  task automatic hold();
    item kept = new();
    wk = new(kept);
    #10 kept.v = 1;
  endtask

  initial begin
    fork
      hold();
    join_none
    h = new();
    wp = new(h);
    h.v <= 5;
    h = null;
    $display("pending update: still referenced: %0d", wp.get() != null);
    #5 $display("held by a waiting task: still referenced: %0d", wk.get() != null);
  end
endmodule
