/*
:name: test_program_exit
:description: $exit in a program ends all initial procedures of that program and their child threads, and when the initial procedures of every program have ended the simulation ends with an implicit $finish (IEEE 1800-2023 Sections 24.7 and 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.7 24.3 9.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_exit.expected
*/
// IEEE 1800-2023 §24.7: $exit called from a thread that starts in an initial
// procedure of a program ends every initial procedure of that program and all
// their descendant threads. At 5, the first initial procedure of p_exit calls
// $exit, so its second initial procedure and the thread it forked at 0 never
// print. p_long ends its only initial procedure at 8. §24.3: once all initial
// procedures of all programs have ended, the simulation ends by an implicit
// $finish, so the module's message at 20 never appears; the module's final
// procedure runs as the simulation ends (9.2.3).

`timescale 1ns/1ns

program p_exit;
  initial begin
    fork
      #10 $display("%0d: p_exit child thread", $time);
    join_none
    #5 $display("%0d: p_exit calls $exit", $time);
    $exit();
    $display("%0d: p_exit after $exit", $time);
  end

  initial #12 $display("%0d: p_exit second initial", $time);
endprogram

program p_long;
  initial #8 $display("%0d: p_long ends", $time);
endprogram

module test_program_exit;
  initial #20 $display("%0d: module still running", $time);
  final $display("%0d: final procedure", $time);
endmodule
