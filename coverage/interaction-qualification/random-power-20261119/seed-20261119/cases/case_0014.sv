/*
:name: random_cross_case_0014
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0014;
  logic signed [256:0] base, narrow;
  logic unsigned [2:0] exponent;
  logic [514:0] full, captured;
  logic [514:0] stored;
  bit [514:0] converted;
  initial begin
    base = 257'b10011011011100101011110001100100001111011010011001000101010111000010111011010010100101011011011110110010100000010000000000101110100110100110010001110011011001101100101110000111100100001100010100001101111011101010101001100110000010101110001111011110110101001;
    exponent = 3'b001;
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
    base = 257'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000x0000000000000x000000x00000001;
    exponent = 3'b111;
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
    base = 257'b0101010110001011000100001100110101001000011111100111011011011110010111110010110001010000010111111010000100111000x1010011101110011001100000000011111001111111110000111000x1110000111010100111010010010010010111111000010011011010001101111010100010111010101011110;
    exponent = 3'b001;
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
    base = 257'b110110001100101001100000101111111001110001100101000011010111111010000011111110110011100011111110100011000000010011111101111001000101110000010110010001110010011111110010000001100110010101000111011001101010101100110011001011000000101110000010x1101110110001111;
    exponent = 3'b100;
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
    base = 257'b10000101010111001110111100101001111110110100001011100111111010111001000010001110111001101000011100001011101110001111101100100110010010010111010010100010001110011110110110100010111001100001100001010000110101000000010111111101011110110111110111111011001001100;
    exponent = 3'b100;
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
    base = 257'b110011111100111z0100100100100100100111110000110001101000000001101100111010001110010111011101110101001110010111101001111001101110001100000001010100000000001110001111111101000101110110101000101010001010100001010111010010000101110010101000110101011101101111111;
    exponent = 3'b011;
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
    base = 257'b11000011001000110011110001110001010101011000111001101100010010100111001100000101000010100110010110000110011111011010101011001111010011110100011110110000101101000000100101001111011011101111111000000110101010000100101011101000011100111101z10111100111110101011;
    exponent = 3'b001;
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
    base = 257'b00011111100000001110111111011101100111001001001111111110000101011010101001000111011111001001011001010010010101011000011001011000011011001011100011010111111101010101101010100110011111101101001010100101001000010110100110011110001011100010110111101101100000001;
    exponent = 3'b010;
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
