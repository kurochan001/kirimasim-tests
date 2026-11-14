/*
:name: test_function_controls_other_and_own_process
:description: functions call kill(), suspend() and resume() on other processes and kill() on the process that called them; the controls take effect before the functions return (IEEE 1800-2023 Sections 13.4 and 9.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_controls_other_and_own_process.expected
*/
// IEEE 1800-2023 13.4 c): a function may call the fine-grain process control
// methods of 9.7 to kill, suspend or resume another process, or to kill the
// process that is executing the function. 9.7: kill() and suspend() take
// effect before they return; resume() of a process suspended in a delay that
// has already run out lets it continue in the current time step; a process
// killed while it runs does not execute its next statements.
//
// Three processes are forked from an initial procedure. At time 1 the parent
// calls kill_other on pk (waiting #5) and suspend_other on ps (waiting #3)
// and prints both states at once: KILLED and SUSPENDED. At time 2 pm calls
// kill_me, which gets its own handle with process::self() and kills it: the
// rest of kill_me and the statement after the call in pm do not run, so
// fn_after and caller_after stay 0 and pm is KILLED. At time 6, pk never set
// k_done and ps, desensitized at time 1, has not reached its assignment.
// resume_other then resumes ps; its delay ended at time 3, so it continues at
// time 6 and records s_time = 6 and finishes.
//
// Icarus Verilog 13.0 does not compile the process class. The 5.052 and
// 5.054 releases of Verilator report suspend() as not supported and leave ps
// WAITING; in 5.052, with the suspend() and resume() calls left out, its
// kill() of the own process inside kill_me did not end pm either.

`timescale 1ns/1ns

module test_function_controls_other_and_own_process;
  process pk, ps, pm;
  int k_done = 0, s_time = -1, fn_after = 0, caller_after = 0;

  function void kill_other(process p);
    p.kill();
  endfunction

  function void suspend_other(process p);
    p.suspend();
  endfunction

  function void resume_other(process p);
    p.resume();
  endfunction

  function automatic void kill_me();
    process me;
    me = process::self();
    me.kill();
    fn_after = 1;
  endfunction

  initial begin
    fork
      begin pk = process::self(); #5 k_done = 1; end
      begin ps = process::self(); #3 s_time = $time; end
      begin pm = process::self(); #2 kill_me(); caller_after = 1; end
    join_none
    #1;
    kill_other(pk);
    suspend_other(ps);
    $display("t=%0t pk=%s ps=%s", $time, pk.status().name(), ps.status().name());
    #5;
    $display("t=%0t pm=%s fn_after=%0d caller_after=%0d", $time, pm.status().name(),
             fn_after, caller_after);
    $display("t=%0t k_done=%0d s_time=%0d ps=%s", $time, k_done, s_time,
             ps.status().name());
    resume_other(ps);
    #1;
    $display("t=%0t s_time=%0d ps=%s", $time, s_time, ps.status().name());
  end
endmodule
