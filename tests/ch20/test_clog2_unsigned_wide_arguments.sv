/*
:name: test_clog2_unsigned_wide_arguments
:description: $clog2 returns the base-2 logarithm rounded up, 0 for an argument of 0, treats a negative or signed argument as unsigned and takes vectors wider than 64 bits (IEEE 1800-2023 Section 20.8.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2_unsigned_wide_arguments.expected
*/
// IEEE 1800-2023 §20.8.1: $clog2 returns the ceiling of the log base 2 of its
// argument, which may be an integer or a vector of any size and is treated
// as unsigned; an argument of 0 gives 0.
// Line 1 covers 0, 1 and both sides of powers of two (2, 3, 4, 5, 1024,
// 1025). Line 2 gives signed arguments whose bits read as unsigned are
// large: the int -1 (2**32 - 1, so 32), the 8-bit -1 (255, so 8) and the
// int -2147483648 (2**31, so 31). Line 3 gives vectors of 100 and 70 bits:
// 2**96 (96), 2**96 + 1 (97) and 2**69 (69).

module test_clog2_unsigned_wide_arguments;
  int neg1 = -1;
  logic signed [7:0] neg8 = -8'sd1;
  int minint = 32'sh8000_0000;
  logic [99:0] p96 = 100'h1 << 96;
  logic [99:0] p96p1 = (100'h1 << 96) + 100'h1;
  logic [69:0] p69 = {1'b1, 69'b0};

  initial begin
    $display("%0d %0d %0d %0d %0d %0d %0d %0d", $clog2(0), $clog2(1), $clog2(2), $clog2(3),
             $clog2(4), $clog2(5), $clog2(1024), $clog2(1025));
    $display("%0d %0d %0d", $clog2(neg1), $clog2(neg8), $clog2(minint));
    $display("%0d %0d %0d", $clog2(p96), $clog2(p96p1), $clog2(p69));
  end
endmodule
