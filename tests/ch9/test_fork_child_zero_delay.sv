/*
:name: test_fork_child_zero_delay
:description: A fork branch that starts with #0 runs after the branches without a delay (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.2 9.4.1 4.4.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fork_child_zero_delay.expected
*/
// IEEE 1800-2023 §9.3.2: each statement of a fork...join runs as a process of
// its own. A process that reaches #0 suspends and resumes in the Inactive
// region of the same time step (9.4.1, 4.4.2.3). So a branch without a delay
// runs to its end in the Active region before a branch that starts with #0,
// whichever starts first, and a branch with two #0 runs last.

module test_fork_child_zero_delay;
  int seq = 0, zero_pos = 0, none_pos = 0, two_pos = 0;

  initial begin
    fork
      #0 begin
        seq++;
        zero_pos = seq;
      end
      begin
        seq++;
        none_pos = seq;
      end
      begin
        #0;
        #0;
        seq++;
        two_pos = seq;
      end
    join
    $display("t=%0d no delay ran %0d, #0 ran %0d, #0 #0 ran %0d", $time, none_pos, zero_pos,
             two_pos);
  end
endmodule
