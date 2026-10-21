/*
:name: test_illegal_break_in_fork_to_outer_loop
:description: break inside a fork-join block cannot end a loop outside the block (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.8 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a break inside a fork-join block refers to the loop around the block
:expected_stderr_regex: test_illegal_break_in_fork_to_outer_loop\.sv:25:
*/
// IEEE 1800-2023 §12.8: continue and break cannot be used inside a fork-join
// block to control a loop outside the fork-join block (§9.3.2).
// The design is accepted by Icarus Verilog 13.0 and Verilator 5.052
// (docs/simulator-differences.md).

module test_illegal_break_in_fork_to_outer_loop;
  int n;
  initial begin
    for (n = 0; n < 4; n++) begin
      fork
        begin
          if (n == 2) break;   // illegal: break out of the fork to the for loop
        end
      join
    end
    $display("n=%0d", n);
  end
endmodule
