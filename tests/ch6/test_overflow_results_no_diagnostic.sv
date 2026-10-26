/*
:name: test_overflow_results_no_diagnostic
:description: integer operations that overflow still produce the prescribed finite-width result, and no overflow message is required
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_overflow_results_no_diagnostic.expected
*/
// IEEE 1800-2023 6.9.1: an implementation is not required to diagnose an
// overflow of an integer operation. The test adds one to the largest signed
// value of int, shortint and byte, adds one to the largest 8-bit unsigned
// value, and adds two values whose sum exceeds int; each assignment keeps the
// low bits of the size of its target, so the printed results are the wrapped
// values. The test checks no message, so a tool may warn; a tool that makes
// the overflow an error cannot print the lines, which the clause does not
// allow.

module test_overflow_results_no_diagnostic;
  int i = 32'h7fff_ffff;
  shortint si = 16'sh7fff;
  byte b = 8'sd127;
  logic [7:0] u = 8'hff;
  int s = 2_000_000_000;

  initial begin
    i = i + 1;
    si = si + 1;
    b = b + 1;
    u = u + 8'd1;
    s = s + 2_000_000_000;
    $display("i=%0d si=%0d b=%0d u=%0d s=%0d", i, si, b, u, s);
  end
endmodule
