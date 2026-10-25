/*
:name: test_repeat_nonpositive_or_unknown_count
:description: A repeat loop whose count is zero, negative, x or z runs no iteration, while an unsigned count with its top bit set and a positive count run that many times (IEEE 1800-2023 Section 12.7.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_repeat_nonpositive_or_unknown_count.expected
*/
// IEEE 1800-2023 §12.7.2: if the expression of a repeat loop evaluates to a
// negative, unknown or high-impedance value, it is treated as zero, and the
// statement is not executed at all.
//
// The counts are 0, the int -2, the signed 4-bit value -1, a 4-bit value
// that is all x, one that is all z, and one with a single x bit. For
// comparison, the unsigned 4-bit value 4'b1111 is 15, not negative, and the
// int 2 is an ordinary count. Each body leaves the loop with break (12.8)
// at its 20th iteration, so a count taken wrongly as large shows as 20
// instead of a long run.
//
// Simulator note: Icarus Verilog 13.0 runs the loops with the counts
// 4'bxxxx, 4'bzzzz and 4'b01x1 until the break (20 iterations) instead of
// treating them as zero.

module test_repeat_nonpositive_or_unknown_count;
  int count;
  int n;
  logic signed [3:0] s4;
  logic [3:0] u4;

  initial begin
    count = 0;
    n = 0;
    repeat (n) begin
      count++;
      if (count == 20) break;
    end
    $display("int 0: %0d iterations", count);
    count = 0;
    n = -2;
    repeat (n) begin
      count++;
      if (count == 20) break;
    end
    $display("int -2: %0d iterations", count);
    count = 0;
    s4 = -4'sd1;
    repeat (s4) begin
      count++;
      if (count == 20) break;
    end
    $display("signed 4'b1111 (-1): %0d iterations", count);
    count = 0;
    u4 = 4'bxxxx;
    repeat (u4) begin
      count++;
      if (count == 20) break;
    end
    $display("4'bxxxx: %0d iterations", count);
    count = 0;
    u4 = 4'bzzzz;
    repeat (u4) begin
      count++;
      if (count == 20) break;
    end
    $display("4'bzzzz: %0d iterations", count);
    count = 0;
    u4 = 4'b01x1;
    repeat (u4) begin
      count++;
      if (count == 20) break;
    end
    $display("4'b01x1: %0d iterations", count);
    count = 0;
    u4 = 4'b1111;
    repeat (u4) begin
      count++;
      if (count == 20) break;
    end
    $display("unsigned 4'b1111 (15): %0d iterations", count);
    count = 0;
    n = 2;
    repeat (n) begin
      count++;
      if (count == 20) break;
    end
    $display("int 2: %0d iterations", count);
  end
endmodule
