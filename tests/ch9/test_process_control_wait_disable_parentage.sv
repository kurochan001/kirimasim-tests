/*
:name: test_process_control_wait_disable_parentage
:description: wait fork waits only for the children of its own process, a named disable ends a block from an unrelated process and from a child of the block, and disable fork ends only the children of its own process (IEEE 1800-2023 Section 9.6)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6 9.6.1 9.6.2 9.6.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_control_wait_disable_parentage.expected
*/
// IEEE 1800-2023 §9.6: wait fork waits for the termination of processes; the
// disable of a named block stops all the activity in it without regard to
// parent and child (a child can end its parent, and a process can end an
// unrelated one); disable fork stops processes with regard to the
// parent-child relation.
//
// Process p1 forks children ending at 3 and 7 and waits with wait fork: it
// goes on at 7, although the child that process p2 forked at time 0 runs until
// 20. p1 then waits 10 inside the block victim, which p2, unrelated to it,
// disables at 9: p1 goes on after the block at 9. Inside the block outer a
// child of p1 disables outer, its parent's block, at 11. Last, p1 forks a
// child that would print at 14 and runs disable fork at 12: that child ends,
// while the child of p2 prints at 20.

`timescale 1ns/1ns

module test_process_control_wait_disable_parentage;
  initial begin : p1
    fork
      #3 $display("%0t p1 child A done", $time);
      #7 $display("%0t p1 child B done", $time);
    join_none
    wait fork;
    $display("%0t p1 wait fork returned", $time);

    begin : victim
      #10 $display("%0t victim not disabled", $time);
    end
    $display("%0t p1 after victim", $time);

    begin : outer
      fork
        #2 disable outer;
      join_none
      #5 $display("%0t outer not disabled", $time);
    end
    $display("%0t p1 after outer", $time);

    fork
      #3 $display("%0t p1 child C not disabled", $time);
    join_none
    #1 disable fork;
    $display("%0t p1 after disable fork", $time);
    #10 $display("%0t p1 done", $time);
  end

  initial begin : p2
    fork
      #20 $display("%0t p2 child done", $time);
    join_none
    #9 disable p1.victim;
  end
endmodule
