/*
:name: random_cross_case_0007
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0007;
  logic unsigned [256:0] base, narrow;
  logic unsigned [2:0] exponent;
  logic [256:0] full, captured;
  bit [256:0] stored;
  bit [256:0] converted;
  initial begin
    base = 257'b10101000011010011001110001110011100101000000110101110111011000010110010010100000101110000010011111010101110110110100010011110100001011110110001110100011000000001010010111101110101100000110011111111011101011111101101111011110111011001100111000001011000001000;
    exponent = 3'b011;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v0_base=%b", base);
    $display("v0_exponent=%b", exponent);
    $display("v0_narrow=%b", narrow);
    $display("v0_full=%b", full);
    $display("v0_captured=%b", captured);
    $display("v0_stored=%b", stored);
    $display("v0_converted=%b", converted);
    $display("v0_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b00100011011010001111110111010100011111101100000100101011101101111000010101001011100010100001110011100001111000101010001010101000001000011000000110010111110010011101010110000000001101011101010101111101011001001111001100010000000111011000111011101110000101011;
    exponent = 3'b011;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v1_base=%b", base);
    $display("v1_exponent=%b", exponent);
    $display("v1_narrow=%b", narrow);
    $display("v1_full=%b", full);
    $display("v1_captured=%b", captured);
    $display("v1_stored=%b", stored);
    $display("v1_converted=%b", converted);
    $display("v1_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b01001000101011111010110100110010000110011101001010011010011001000010111101000001100010111000010010100011000001001001110001101110101101010110011011100000011110101011110000110101101100000111000001000001001000011100110111010101100101110000001001101011000010110;
    exponent = 3'b011;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v2_base=%b", base);
    $display("v2_exponent=%b", exponent);
    $display("v2_narrow=%b", narrow);
    $display("v2_full=%b", full);
    $display("v2_captured=%b", captured);
    $display("v2_stored=%b", stored);
    $display("v2_converted=%b", converted);
    $display("v2_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b00111001000011100000000111000101010101101111000001100010100101100000000100110111000010011100101111100101001010101101011001101000110110111001101011101110100101001100111011000111110000111000100100101001110111000010101110110011010011000011111010000010011100011;
    exponent = 3'b101;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v3_base=%b", base);
    $display("v3_exponent=%b", exponent);
    $display("v3_narrow=%b", narrow);
    $display("v3_full=%b", full);
    $display("v3_captured=%b", captured);
    $display("v3_stored=%b", stored);
    $display("v3_converted=%b", converted);
    $display("v3_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b0101100100011010010011001111111001010110100100z000011111111100010101111011001111011011011111101100111110110100101010110110110000010000111001110011100100010110100110011001101100001000101110100000001111110110x10001010110100110100110110001101001110100100100101;
    exponent = 3'b001;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v4_base=%b", base);
    $display("v4_exponent=%b", exponent);
    $display("v4_narrow=%b", narrow);
    $display("v4_full=%b", full);
    $display("v4_captured=%b", captured);
    $display("v4_stored=%b", stored);
    $display("v4_converted=%b", converted);
    $display("v4_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b01110110111111111110011100000000011111000111100011101101010110010100010011010000111100011010000011110010011111010001110000111100100000010001111111000001000111101110000110000001110001110100101000100000101000000100001101000011111110010110001101010001001000101;
    exponent = 3'b0x0;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v5_base=%b", base);
    $display("v5_exponent=%b", exponent);
    $display("v5_narrow=%b", narrow);
    $display("v5_full=%b", full);
    $display("v5_captured=%b", captured);
    $display("v5_stored=%b", stored);
    $display("v5_converted=%b", converted);
    $display("v5_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b0111010011010111000011001111100010000101011101011110010110111010001000001010x1110011011011111111010001111011010011000111101111001110110100011z0110001111010000010111000000001111000011100011z10101001100100100011000100001010100111101010111000101000001001111010;
    exponent = 3'b011;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v6_base=%b", base);
    $display("v6_exponent=%b", exponent);
    $display("v6_narrow=%b", narrow);
    $display("v6_full=%b", full);
    $display("v6_captured=%b", captured);
    $display("v6_stored=%b", stored);
    $display("v6_converted=%b", converted);
    $display("v6_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    base = 257'b10011111011111000011110111001001101010111110110011011000111000011100011010111111000101110111100101000100100111110011000110000101000110101001110000000001001000100010011011101011110011111101101100111100100010111100110110010111110111111111100000101000010111111;
    exponent = 3'b100;
    narrow = base ** exponent;
    full = base ** exponent;
    captured = narrow;
    stored = base ** exponent;
    converted = full;
    $display("v7_base=%b", base);
    $display("v7_exponent=%b", exponent);
    $display("v7_narrow=%b", narrow);
    $display("v7_full=%b", full);
    $display("v7_captured=%b", captured);
    $display("v7_stored=%b", stored);
    $display("v7_converted=%b", converted);
    $display("v7_widths=%0d,%0d,%0d",
             $bits(base ** exponent), $bits(exponent), $bits(full));
    $finish;
  end
endmodule
