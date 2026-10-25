/*
:name: test_begin_end_order_across_suspensions
:description: The statements of a begin-end block run in the order of the source, also when the block is suspended by delays, event controls, #0 and wait statements and other processes run in between (IEEE 1800-2023 Section 4.6)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.6 9.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_end_order_across_suspensions.expected
*/
// IEEE 1800-2023 §4.6 a): the statements of a begin-end block (§9.3.1) are
// executed in the order in which they appear; the block can be suspended in
// favor of other processes, but its statements never run in another order.
// The block a logs six steps, separated by a delay, an event control, no
// control, #0 and a wait. The process b runs between them: it logs at 2,
// then triggers ev, and at 3 logs again and sets flag. Each step logs its
// time and the variable step, which a counts up as it goes, so a step run
// out of order would log a wrong count. The steps of a come out in source
// order, interleaved with b at the times their controls allow.

module test_begin_end_order_across_suspensions;
  string log_lines[$];
  int step = 0;
  bit flag = 0;
  event ev;

  function automatic void note(string who);
    log_lines.push_back($sformatf("%s step=%0d at %0d", who, step, $time));
  endfunction

  initial begin : a
    step++;
    note("a1");
    #1 step++;
    note("a2");
    @(ev) step++;
    note("a3");
    step++;
    note("a4");
    #0 step++;
    note("a5");
    wait (flag) step++;
    note("a6");
  end

  initial begin : b
    #2 note("b1");
    ->ev;
    #1 note("b2");
    flag = 1;
  end

  final foreach (log_lines[i]) $display("%s", log_lines[i]);
endmodule
