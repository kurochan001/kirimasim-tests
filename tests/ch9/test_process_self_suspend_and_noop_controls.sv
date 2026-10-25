/*
:name: test_process_self_suspend_and_noop_controls
:description: a running process reports RUNNING and can suspend itself; resume() lets it continue in the same time step; suspend() of a suspended, finished or killed process and resume() of a process that is not suspended change nothing (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_self_suspend_and_noop_controls.expected
*/
// IEEE 1800-2023 §9.7: status() is RUNNING while the process executes
// outside a blocking statement. A process can suspend itself (outside a
// function); it is suspended before suspend() returns. resume() of a
// process that was suspended while RUNNING schedules it to continue in the
// current time step. suspend() of a process that is SUSPENDED, FINISHED or
// KILLED has no effect, and resume() of a process that is not SUSPENDED has
// no effect.
//
// At time 1, pr prints its own state (RUNNING) and suspends itself. At time
// 2 the controlling process prints its own state (RUNNING) and pr's
// (SUSPENDED), suspends pr a second time, and suspends pf (finished at time
// 0) and pk (killed just before): their states stay SUSPENDED, FINISHED and
// KILLED. It calls resume() on pw, which waits #30, and on pf: pw stays
// WAITING and still ends at 30, pf stays FINISHED. At time 4 a single
// resume() of pr lets it continue at time 4, so the second suspend() did
// not have to be undone by a second resume().
//
// Icarus Verilog 13.0 does not compile the process class, and release 5.052
// of Verilator does not support suspend().

`timescale 1ns/1ns
module test_process_self_suspend_and_noop_controls;
  process pr, pf, pk, pw, me;

  function automatic string st(process h);
    process::state s;
    s = h.status();
    return s.name();
  endfunction

  initial begin
    fork
      begin
        pr = process::self();
        #1 $display("t=%0t pr own status=%s", $time, st(pr));
        pr.suspend();
        $display("t=%0t pr continues", $time);
      end
      begin pf = process::self(); end
      begin pk = process::self(); #100; $display("pk must not print"); end
      begin pw = process::self(); #30; $display("t=%0t pw delay over", $time); end
    join_none
    #2;
    me = process::self();
    $display("t=%0t controller own status=%s, pr=%s", $time, st(me), st(pr));
    pk.kill();
    pr.suspend();
    pf.suspend();
    pk.suspend();
    $display("t=%0t after suspend: pr=%s pf=%s pk=%s", $time, st(pr), st(pf), st(pk));
    pw.resume();
    pf.resume();
    $display("t=%0t after resume: pw=%s pf=%s", $time, st(pw), st(pf));
    #2 $display("t=%0t resuming pr", $time);
    pr.resume();
  end
endmodule
