/*
:name: test_exit_waits_for_programs
:description: $exit, written with or without empty parentheses, ends the initial procedures of the calling program, and the simulation goes on until every program has completed and then ends by an implicit $finish (IEEE 1800-2023 Section 20.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2 24.7 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exit_waits_for_programs.expected
*/
// IEEE 1800-2023 §20.2: $exit waits for all program blocks to complete and then
// calls $finish implicitly; Syntax 20-1 allows it with or without an empty
// pair of parentheses. §24.7: a call of $exit from an initial procedure of a
// program ends all initial procedures of that program and their descendant
// threads. §24.3: when every program has completed, the simulation ends.
//
// At 5, p_first calls $exit(): its statement after the call does not run, but
// the simulation does not end, because p_second is still running, so the
// module keeps printing at 8 and 12. At 15, p_second calls $exit, which also
// ends the thread it forked for 20; now every program has completed and the
// implicit $finish ends the simulation at 15, so the module does not print at
// 16. No two prints happen at the same time.
//
// Icarus Verilog 13.0 does not know $exit. Version 5.052 of Verilator ends
// the simulation at the first $exit, at 5, after running the rest of the
// calling procedure.

`timescale 1ns/1ns

program p_first;
  initial begin
    #5 $display("%0d: p_first calls $exit()", $time);
    $exit();
    $display("%0d: p_first after $exit", $time);
  end
endprogram

program p_second;
  initial begin
    fork
      #20 $display("%0d: p_second child thread", $time);
    join_none
    #15 $display("%0d: p_second calls $exit", $time);
    $exit;
    $display("%0d: p_second after $exit", $time);
  end
endprogram

module test_exit_waits_for_programs;
  always #4 $display("%0d: module tick", $time);
endmodule
