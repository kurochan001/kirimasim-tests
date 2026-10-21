/*
:name: test_program_exit_from_fork
:description: $exit called in a thread that an initial procedure of a program forked ends every initial procedure of that program and their descendants, and leaves the initial procedures of the module and of other programs running (IEEE 1800-2023 Section 24.7)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.7 24.3 9.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_exit_from_fork.expected
*/
// IEEE 1800-2023 §24.7: $exit ends all the initial procedures of the program
// whose initial procedure started the calling thread, and their descendant
// threads. The thread forked by the first initial procedure of p_exit calls
// $exit at 3, which ends the parent initial procedure before its message at
// 4, the second initial procedure of p_exit before its message at 4, and the
// forked thread itself. It does not touch p_other, which prints at 4 and is
// still waiting for 7, or the module, which prints and calls $finish at 6.
// Icarus Verilog 13.0 does not support $exit, and Verilator 5.052 ends the
// simulation at the call (docs/simulator-differences.md), so neither produces
// this output.

`timescale 1ns/1ns

program p_exit;
  initial begin
    fork
      #3 begin
        $display("%0d: forked thread calls $exit", $time);
        $exit;
      end
    join_none
    #4 $display("%0d: first initial procedure goes on", $time);
  end

  initial #4 $display("%0d: second initial procedure goes on", $time);
endprogram

program p_other;
  initial begin
    #4 $display("%0d: p_other continues", $time);
    #3 $display("%0d: p_other goes on", $time);
  end
endprogram

module test_program_exit_from_fork;
  p_exit x();
  p_other o();

  initial begin
    #6 $display("%0d: module continues", $time);
    $finish;
  end
endmodule
