/*
:name: test_process_kill_terminates_descendants
:description: kill() ends its target together with the children and grandchildren it forked before it returns, and kill() on a process that has already finished still ends its running children (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_kill_terminates_descendants.expected
*/
// IEEE 1800-2023 §9.7: kill() forcibly ends the process it is called on and
// all its descendants, the processes forked by it or by its descendants;
// all of them are ended before kill() returns. Calling kill() on a process
// that is already FINISHED or KILLED still ends those of its descendants
// that have not ended yet.
//
// p forks c, which forks g; all three wait for #10. p2 forks c2 (which waits
// #10) and then finishes at time 1. At time 2 the controlling process kills
// p and prints, right after the call, the states of p, c and g: all KILLED.
// It then kills the finished p2 and prints the state of c2: KILLED. None of
// the four waiting processes reaches the statement after its delay.
//
// Icarus Verilog 13.0 does not compile the process class. The 5.052 release
// of Verilator reports p2 as RUNNING after its block has ended, and its
// kill() ends only the target, so c, g and c2 keep running.

`timescale 1ns/1ns
module test_process_kill_terminates_descendants;
  process p, c, g, p2, c2;
  int p_done = 0, c_done = 0, g_done = 0, c2_done = 0;

  function automatic string st(process h);
    process::state s;
    s = h.status();
    return s.name();
  endfunction

  initial begin
    fork
      begin
        p = process::self();
        fork
          begin
            c = process::self();
            fork
              begin
                g = process::self();
                #10 g_done = 1;
              end
            join_none
            #10 c_done = 1;
          end
        join_none
        #10 p_done = 1;
      end
      begin
        p2 = process::self();
        fork
          begin
            c2 = process::self();
            #10 c2_done = 1;
          end
        join_none
        #1;
      end
    join_none
    #2;
    $display("before: p=%s c=%s g=%s p2=%s c2=%s", st(p), st(c), st(g), st(p2), st(c2));
    p.kill();
    $display("after p.kill(): p=%s c=%s g=%s", st(p), st(c), st(g));
    p2.kill();
    $display("after p2.kill(): c2=%s", st(c2));
    #20 $display("t=%0t done flags: p=%0d c=%0d g=%0d c2=%0d", $time, p_done, c_done, g_done,
                 c2_done);
  end
endmodule
