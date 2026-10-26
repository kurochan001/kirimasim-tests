/*
:name: test_event_method_dependency
:description: a change to an object member, an aggregate element or a dynamic size used by a function or built-in method wakes the event control that reads it
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_method_dependency.expected
*/
// IEEE 1800-2023 9.4.2: changing an object data member, an aggregate element
// or the size of a dynamically sized array that a method or function in the
// event expression references causes the expression to be reevaluated. f reads
// obj.m and the queue size, so obj.m=3 at 10 wakes it with value 3; the
// built-in q.size() changes from 0 to 1 at 20; g reads arr[1], so writing 5
// there at 30 wakes it. A tool that samples such an expression only once, or
// that ignores a member or an element, misses a wake or prints another value.

`timescale 1ns/1ns

module test_event_method_dependency;
  class C;
    int m;
  endclass

  C obj = new;
  int q[$];
  int arr[2] = '{0, 0};

  function automatic int f();
    return obj.m + q.size();
  endfunction

  function automatic int g();
    return arr[1];
  endfunction

  initial begin
    @(f());
    $display("f t=%0d v=%0d", $time, f());
    @(q.size());
    $display("size t=%0d v=%0d", $time, q.size());
    @(g());
    $display("elem t=%0d v=%0d", $time, g());
  end

  initial begin
    #10 obj.m = 3;
    #10 q.push_back(7);
    #10 arr[1] = 5;
    #10 $finish;
  end
endmodule
