/*
:name: test_process_resume_waiting_resensitizes
:description: suspend() on processes blocked on an event, a wait condition and delays makes them SUSPENDED before it returns; resume() makes each one sensitive again, continuing at once when the condition is already true or the delay has passed, and otherwise at the next event or at the original end of the delay (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_resume_waiting_resensitizes.expected
*/
// IEEE 1800-2023 §9.7: suspend() suspends the target before it returns. A
// process suspended while WAITING no longer reacts to the event, the wait
// condition or the end of the delay it is blocked on. resume() makes it
// sensitive again to that event, condition or delay; if the condition is
// already true or the original delay has already passed, the process is
// scheduled to continue in the current time step.
//
// At time 2 the controlling process suspends pe (blocked on @e), pc (on
// wait (flag)), pd1 and pd2 (both on #10 from time 0) and prints their
// states right after the calls: all SUSPENDED. At time 3 it triggers e and
// sets flag; neither suspended process reacts.
//   t=5  resume pc: flag is already true, so pc continues at 5
//   t=6  resume pe: it waits for the next e, triggered at 7
//   t=8  resume pd1: its delay ends at 10 as before, so it continues at 10
//   t=12 resume pd2: its delay ended at 10, so it continues at 12
//
// Icarus Verilog 13.0 does not compile the process class, and release 5.052
// of Verilator does not support suspend().

`timescale 1ns/1ns
module test_process_resume_waiting_resensitizes;
  process pe, pc, pd1, pd2;
  event e;
  bit flag = 0;

  function automatic string st(process h);
    process::state s;
    s = h.status();
    return s.name();
  endfunction

  initial begin
    fork
      begin pe = process::self(); @e; $display("t=%0t pe woke on e", $time); end
      begin pc = process::self(); wait (flag); $display("t=%0t pc saw flag", $time); end
      begin pd1 = process::self(); #10; $display("t=%0t pd1 delay over", $time); end
      begin pd2 = process::self(); #10; $display("t=%0t pd2 delay over", $time); end
    join_none
    #2;
    pe.suspend();
    pc.suspend();
    pd1.suspend();
    pd2.suspend();
    $display("t=%0t after suspend: pe=%s pc=%s pd1=%s pd2=%s", $time, st(pe), st(pc), st(pd1),
             st(pd2));
    #1;
    -> e;
    flag = 1;
    #1 $display("t=%0t still: pe=%s pc=%s", $time, st(pe), st(pc));
    #1 pc.resume();
    #1 pe.resume();
    #1 -> e;
    #1 pd1.resume();
    #4 pd2.resume();
  end
endmodule
