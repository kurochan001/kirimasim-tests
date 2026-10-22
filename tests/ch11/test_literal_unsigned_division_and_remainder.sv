/*
:name: test_literal_unsigned_division_and_remainder
:description: Signed and unsigned literal forms change division and remainder with the same bit pattern (IEEE 1800-2023 Section 11.3.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.3 11.4.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_literal_unsigned_division_and_remainder.expected
*/
// IEEE 1800-2023 11.3.3 11.4.3.1: Division truncates toward zero; a signed
// remainder follows the dividend, while an unsigned operand makes the
// calculation unsigned.

module test_literal_unsigned_division_and_remainder;
  initial begin
    $display("signed=%0d,%0d", -8'sd7 / 8'sd3, -8'sd7 % 8'sd3);
    $display("unsigned=%0d,%0d", 8'hf9 / 8'd3, 8'hf9 % 8'd3);
  end
endmodule
