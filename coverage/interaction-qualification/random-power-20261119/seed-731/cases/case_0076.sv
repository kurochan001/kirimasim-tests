/*
:name: random_cross_case_0076
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0076;
  logic unsigned [256:0] base, narrow;
  logic unsigned [64:0] exponent;
  logic [255:0] full, captured;
  logic [255:0] stored;
  bit [255:0] converted;
  initial begin
    base = 257'b110010111001000011011010000010110111010100101110111011100011000000111111000011100010110100101011110011110000111100111100110001001111110011100101011001100111z111111x01111110010110111110000111001011111001101110111001000100001011101000000x100001001000011110001;
    exponent = 65'b10000000000000000000000000000000000000000000000000000000000000001;
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
    base = 257'b001111101111110110011001100001010011011111100010001z10111110x010011000100000001100110111010101010110101111110001001010101111011011000010110011000100010110011100111001100101010111110101x111000101000101110100010111000011101100011011010011000010100010100110101;
    exponent = 65'b01111111111111111111111111111111111111111111111111111111111111111;
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
    base = 257'b01001100101000010010011000001001110000001111100000110110011101100101111101111000100011101000111010100011100111001001100100011001110110011100011100111111011101111110001001000010010010001001010001100010010011011011010110011000110110010001101100111000111001111;
    exponent = 65'b00000000000000000000000000000000100000000000000000000000000000000;
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
    base = 257'b10101100110111111100000000011010000100100000110111001111101011110010100010110111010100110101101101100011010001010001001110001011001111110100001111110010101110001010001111110011001000011100100000111110000011001101001011111000101101001010111111011000101010101;
    exponent = 65'b00000000000000000000000000000000000000000000000000000000000000011;
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
    base = 257'b0000000000000000000000000000000000000000000000000000000000000000000000000000000x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000z000000000000000000000000000000000000000000000000001;
    exponent = 65'b01000011100001101100111111101010110011001110100000111001010000110;
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
    base = 257'b0010011011100011000111111110111011001011101100111010110111111110011001z010010101011101101110001101100111100011011000000000011110000100101001010000111z000000011011001111011100100101010011101100x1010110000001101101011101101101110101101011110000110101011111111;
    exponent = 65'b11111111111111111111111111111111111111111111111111111111111111110;
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
    base = 257'b10100100001111110110000001101111101010101000001100011101111001000000111110100011011110111000111011111111110110001110010110000011010010001010101001101110011110110001101100100001111011101101010001110110000110000011000110011110000100010001100010010000010010010;
    exponent = 65'b11111111111111111111111111111111111111111111111111111111111111111;
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
    base = 257'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000z00000000000000000000000000000000000000000000000x000000000000000000000000000000000000000000000000000000000000000000000000000000z0000000000000000000000000000000000000000001;
    exponent = 65'b11111101001010011010001110001100001011100110111010110101011101101;
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
