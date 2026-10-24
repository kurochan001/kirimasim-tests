/*
:name: test_sequence_attached_call_kinds_order_region
:description: a void function, a task, a void function method, a task method and a system task attached to a sequence all run at each of its end points, in the order of the list, in the Reactive region after the nonblocking assignments of that time step, and a variable they write wakes a module process in the same time step (IEEE 1800-2023 Section 16.11)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_attached_call_kinds_order_region.expected
*/
// IEEE 1800-2023 §16.11: tasks, task methods, void functions, void function
// methods and system tasks can be attached to a sequence after its
// expression, in parentheses. They run at every end point of the sequence,
// in the order of the list; the assertion does not wait for them. Like an
// action block, they are scheduled in the Reactive region, so they come
// after the nonblocking assignments of the time step, and the always
// procedure woken by the write of w runs later in the same time step.
// a is high at the tick at 15 and b at 25 and 35, so a ##[1:2] b has its end
// points at 25 and 35. nba goes up by one at every tick through a nonblocking
// assignment; t_task reads it by const ref, after that update (3 at 25, 4
// at 35). Only the attached calls and the always procedure print.

`timescale 1ns/1ns

module test_sequence_attached_call_kinds_order_region;
  class rec_c;
    function void fm(int v);
      $display("%0t: function method %0d", $time, v);
    endfunction

    task tm(int v);
      $display("%0t: task method %0d", $time, v);
    endtask
  endclass

  logic clk = 0, a = 0, b = 0;
  int nba = 0, w = 0;
  rec_c h = new;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...
  always @(posedge clk) nba <= nba + 1;

  function automatic void f_void(int v);
    $display("%0t: function %0d", $time, v);
  endfunction

  task automatic t_task(const ref int r);
    $display("%0t: task, nba = %0d", $time, r);
  endtask

  function automatic void bump_w();
    w = w + 1;
  endfunction

  always @(w) $display("%0t: always sees w = %0d", $time, w);

  c_calls: cover sequence (@(posedge clk) (a ##[1:2] b, f_void(1), t_task(nba), h.fm(2), h.tm(3),
                                          $display("%0t: system task", $time), bump_w()));

  initial begin
    #10 a = 1;          // tick at 15
    #10 a = 0; b = 1;   // ticks at 25 and 35
    #20 b = 0;
    #30 $finish;
  end
endmodule
