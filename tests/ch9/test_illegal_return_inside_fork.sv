/*
:name: test_illegal_return_inside_fork
:description: A return statement inside a fork-join block is a compilation error (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a return statement appears in a statement of a fork-join block
:expected_stderr_regex: test_illegal_return_inside_fork\.sv:27:
*/
// IEEE 1800-2023 §9.3.2: a return statement within the context of a
// fork-join block is illegal and shall result in a compilation error, since
// the forked statement runs as a process of its own. Here the second
// statement of the fork inside the task returns.

module test_illegal_return_inside_fork;
  int n = 0;

  task automatic step();
    fork
      #1 n++;
      begin
        #2;
        return;   // illegal: return inside a fork-join block
      end
    join
  endtask

  initial step();
endmodule
