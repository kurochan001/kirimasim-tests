/*
:name: test_illegal_function_cycle_delay
:description: a function cannot contain a ## cycle delay, even when a default clocking block makes the cycle delay legal elsewhere (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function step contains the cycle delay ##1
:expected_stderr_regex: test_illegal_function_cycle_delay\.sv:33:
*/
// IEEE 1800-2023 13.4 a): a function shall not contain time-controlling
// statements, and ## is one of them. The module has a default clocking
// block, so the same cycle delay is legal in the initial procedure, where it
// waits for the next posedge of clk (14.11). The function step contains ##1
// as well. Without that line the design prints count=1 and finishes.
// Icarus Verilog 13.0 does not parse the clocking block or ## and reports
// syntax errors on the legal lines as well, so its error on the marked line
// does not count.

module test_illegal_function_cycle_delay;
  logic clk = 0;
  int count = 0;

  default clocking cb @(posedge clk);
  endclocking

  always #5 clk = ~clk;

  function void step();
    ##1;   // illegal: a cycle delay in a function
    count = count + 1;
  endfunction

  initial begin
    ##1;
    step();
    $display("count=%0d", count);
    $finish;
  end
endmodule
