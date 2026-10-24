/*
:name: test_vector_65536_bits
:description: A vector of 65536 bits, the smallest maximum length an implementation may set, can be declared, written and read at both ends (IEEE 1800-2023 Section 6.9.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.1 20.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vector_65536_bits.expected
*/
// IEEE 1800-2023 §6.9.1: an implementation may limit the length of a vector,
// but the limit is at least 65536 bits. big has exactly 65536 bits. Its two
// end bits and one in the middle are set; $bits gives the width, $countones
// (20.9) counts the set bits, a shift brings the top bit down to bit 0, and
// adding 1 to the all-ones value wraps to zero across the whole width.

module test_vector_65536_bits;
  logic [65535:0] big;

  initial begin
    big = '0;
    big[65535] = 1'b1;
    big[32768] = 1'b1;
    big[0] = 1'b1;
    $display("bits=%0d ones=%0d top=%b mid=%b low=%b", $bits(big), $countones(big), big[65535],
             big[32768], big[0]);
    $display("shifted top: %0d", big >> 65535);
    big = '1;
    big = big + 1'b1;
    $display("all ones plus 1: ones=%0d", $countones(big));
  end
endmodule
