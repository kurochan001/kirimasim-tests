/*
:name: test_bit_vector_functions_constant_expressions
:description: $countbits, $countones, $onehot, $onehot0 and $isunknown with constant arguments are constant expressions that can give localparam values, widths, array sizes and generate conditions (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 11.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_vector_functions_constant_expressions.expected
*/
// IEEE 1800-2023 §20.9: the bit vector functions may be used as constant
// expressions (§11.2.1) when all of their arguments are constant.
// MASK is a parameter with five 1 bits and three 0 bits. Local parameters
// take $countones(MASK) (5) and $countbits(MASK, '0) (3); a vector gets its
// width from $countones and an unpacked array its size from $countbits of a
// literal with two 1 bits; generate if conditions use $onehot of a
// parameter (true), $onehot0 of MASK (false) and $isunknown of MASK (false).

module test_bit_vector_functions_constant_expressions;
  parameter logic [7:0] MASK = 8'b1011_0101;
  parameter logic [3:0] SEL = 4'b0100;
  localparam int ONES = $countones(MASK);
  localparam int ZEROS = $countbits(MASK, '0);

  logic [ONES - 1:0] packed_v;
  int arr [$countbits(8'b0001_0010, '1)];

  if ($onehot(SEL)) begin : g_onehot
    initial #1 $display("generate: SEL is one-hot");
  end
  if ($onehot0(MASK)) begin : g_onehot0
    initial #2 $display("generate: MASK has at most one 1");
  end
  if (!$isunknown(MASK)) begin : g_known
    initial #3 $display("generate: MASK is known");
  end

  initial $display("ONES=%0d ZEROS=%0d width=%0d size=%0d", ONES, ZEROS, $bits(packed_v),
                   $size(arr));
endmodule
