/*
:name: test_immediate_assertion_action_statements
:description: the pass and fail statements of an immediate assertion can be any procedural statement: an assignment, a repeat loop, a nonblocking assignment or an event trigger that signals the failure to another process, and a block that records the failure time and reports it after a delay (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertion_action_statements.expected
*/
// IEEE 1800-2023 §16.3: the pass and fail statements of an immediate assert
// are ordinary procedural statements, so a fail statement can signal the
// failure to another part of the testbench, and when the report comes after
// a delay, the action can first record the time of the failure. At 10,
// a_pass passes and adds 1 to count, a_loop passes and adds 10 three times,
// a_event fails and triggers fail_ev, which another process waits for, and
// a_nba fails and sets flag with a nonblocking assignment, which a third
// process waits for. At 20 a_late fails; its fail statement stores $time,
// waits 7 and then prints the stored time and the current one. The
// procedure goes on only after that block. The waiting processes store the
// times at which they woke, and one line prints them at the end.

`timescale 1ns/1ns

module test_immediate_assertion_action_statements;
  event fail_ev;
  logic flag = 1'b0;
  int a = 3, count = 0;
  int ev_time = -1, flag_time = -1;
  time t_fail;

  initial begin
    @fail_ev;
    ev_time = $time;
  end

  initial begin
    @(posedge flag);
    flag_time = $time;
  end

  initial begin
    #10;
    a_pass: assert (a == 3) count = count + 1; else -> fail_ev;
    a_loop: assert (a == 3) repeat (3) count += 10;
    a_event: assert (a == 4) count = count + 100; else -> fail_ev;
    a_nba: assert (a == 4) else flag <= 1'b1;
    #10;
    a_late: assert (a == 5) else begin
      t_fail = $time;
      #7 $display("a_late failed at %0t, reported at %0t", t_fail, $time);
    end
    $display("t=%0t: count=%0d, fail_ev seen at %0d, flag rose at %0d", $time, count, ev_time,
             flag_time);
  end
endmodule
