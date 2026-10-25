/*
:name: test_conversion_functions_constant_expressions
:description: $rtoi, $itor, $realtobits, $bitstoreal, $shortrealtobits, $bitstoshortreal, $signed and $unsigned can be used in constant expressions: parameter values, packed and unpacked dimensions and a generate condition (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 11.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conversion_functions_constant_expressions.expected
*/
// IEEE 1800-2023 §20.5: the conversion functions may be used in constant
// expressions (§11.2.1), where a constant system function call has constant
// arguments.
// Local parameters take their values from each of the eight functions:
// $rtoi truncates 3.99 to 3, $itor gives -7.0, 1.5 is 3ff8000000000000 as
// double bits and 0.5 is 3f000000 as single bits, 4004000000000000 is 2.5
// and 3fc00000 is 1.5, and $signed of 4'hc is -4 while $unsigned of -4'sd4 is
// 12. The results also set the width of v1 (from $rtoi, [3:0]) and of v2
// (from $rtoi of $bitstoreal times 2, [4:0]), the size of the unpacked array
// arr (from $unsigned, 12) and the condition of a generate if (from
// $signed), which are all places that need a constant.
// Neither simulator follows the clause here: Icarus Verilog 13.0 cannot
// evaluate $bitstoreal, $shortrealtobits and $bitstoshortreal in a
// parameter, and release 5.052 of the Verilator tool gives 0 for
// $shortrealtobits(0.5) and $bitstoshortreal(32'h3fc00000).

module test_conversion_functions_constant_expressions;
  localparam int P_RTOI = $rtoi(3.99);
  localparam real P_ITOR = $itor(-7);
  localparam bit [63:0] P_R2B = $realtobits(1.5);
  localparam real P_B2R = $bitstoreal(64'h4004000000000000);
  localparam bit [31:0] P_S2B = $shortrealtobits(0.5);
  localparam shortreal P_B2S = $bitstoshortreal(32'h3fc00000);
  localparam int P_SG = $signed(4'hc);
  localparam int P_US = $unsigned(-4'sd4);

  logic [P_RTOI:0] v1;
  logic [$rtoi($bitstoreal(64'h4004000000000000) * 2.0) - 1:0] v2;
  int arr [$unsigned(-4'sd4)];

  if ($signed(4'hc) < 0) begin : g_neg
    initial #1 $display("generate: negative");
  end else begin : g_pos
    initial #1 $display("generate: not negative");
  end

  initial begin
    $display("rtoi=%0d itor=%.1f r2b=%h b2r=%.1f", P_RTOI, P_ITOR, P_R2B, P_B2R);
    $display("s2b=%h b2s=%.1f signed=%0d unsigned=%0d", P_S2B, P_B2S, P_SG, P_US);
    $display("bits v1=%0d v2=%0d size arr=%0d", $bits(v1), $bits(v2), $size(arr));
  end
endmodule
