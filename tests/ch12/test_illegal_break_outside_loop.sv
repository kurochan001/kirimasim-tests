/*
:name: test_illegal_break_outside_loop
:description: A break statement that is not inside a loop is illegal (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a break statement appears in an initial block outside any loop
:expected_stderr_regex: test_illegal_break_outside_loop\.sv:26:
*/
// IEEE 1800-2023 §12.8: break and continue can only be used in a loop.
// Here break is inside an if statement in an initial block, with no loop
// around it; the other statements are legal. Icarus Verilog 13.0 also
// rejects the design, but its message gives no file and line.

module test_illegal_break_outside_loop;
  int n;

  initial begin
    n = 1;
    if (n == 1) begin
      $display("before");
      break;   // illegal: not inside a loop
    end
    $display("after");
  end
endmodule
