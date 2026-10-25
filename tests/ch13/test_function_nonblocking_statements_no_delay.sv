/*
:name: test_function_nonblocking_statements_no_delay
:description: A function called from an initial procedure returns without delay while a nonblocking assignment, an event trigger, a clocking drive and a fork-join_none inside it take effect later (IEEE 1800-2023 Section 13.4.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.4 14.16 9.3.2 15.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_nonblocking_statements_no_delay.expected
*/
// IEEE 1800-2023 §13.4.4: a function executes with no delay, so the caller
// goes on at once; statements that do not block are allowed in it,
// specifically nonblocking assignments, event triggers, clocking drives and
// fork-join_none. The function here is called from an initial procedure,
// where scheduling work for after the return is allowed.
//
// At the clocking event at 5, kick(7) does q <= 7, -> ev, cb.y <= 1 and a
// fork-join_none whose branch sets forked to 7 after #2. Right after the
// call the time is still 5 and q, y and forked are unchanged. A process
// that waits for ev from time 0 stores the time it wakes up. At 8 the
// nonblocking assignment and the drive (zero output skew, so at time 5)
// have updated q and y, the forked branch has run at 7, and the waiter
// woke up at 5.

`timescale 1ns/1ns

module test_function_nonblocking_statements_no_delay;
  logic clk = 0;
  int q = 0;
  logic y = 0;
  int forked = 0;
  int woke = -1;
  event ev;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    output y;
  endclocking

  function automatic void kick(int v);
    q <= v;
    -> ev;
    cb.y <= 1'b1;
    fork
      #2 forked = v;
    join_none
  endfunction

  initial begin
    @(ev);
    woke = $time;
  end

  initial begin
    @(cb);
    kick(7);
    $display("t=%0t after the call: q=%0d y=%0d forked=%0d", $time, q, y, forked);
    #3;
    $display("t=%0t: q=%0d y=%0d forked=%0d waiter woke at %0d", $time, q, y, forked, woke);
    $finish;
  end
endmodule
