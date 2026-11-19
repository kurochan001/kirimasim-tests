/*
:name: random_cross_case_0001
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0001;
  logic unsigned [256:0] base, narrow;
  logic unsigned [64:0] exponent;
  logic [256:0] full, captured;
  bit [256:0] stored;
  bit [256:0] converted;
  initial begin
    base = 257'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
    exponent = 65'b10110100100100000100001100100100101101001110100001100010110010111;
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
    base = 257'b01010101000100010011110000110001010011110011100110011010100010100111001110110101001101100001010001001110001011100111000110011101101010111001011101010010011101001000111100100101111010001010101110001101011111010100000101100111111101000110100010101111001101111;
    exponent = 65'b00000000000000000000000000000000000000000000000000000000000000011;
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
    base = 257'b01010101011101000111001101010110011110100110111010110110010110110101000001101110011010000111100000110011000011100000110100101111101001101101011101000100010000100101101110000000011101110110001111111101010110101111101010110000111001101101110100010011011111101;
    exponent = 65'b01111111111111111111111111111111111111111111111111111111111111111;
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
    base = 257'b10000100010001011110010101011101111000011110011101110101010000001011001101010011110000101000001000101100101110111110000001010111011101000001001100011110000000001110010001100100111001000001000110100010111111100000111001011101001000011001011111011100100111010;
    exponent = 65'b10000000000000000000000000000000000000000000000000000000000000001;
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
    base = 257'b11101010101101111001111101011001110010100000101010001101010000111010001110000001111101000001011111011001000110111000000011100000111110010101011001110011010110011000010111101111000110001100011000010111000101001000111000001110110000011011110100000101111101100;
    exponent = 65'b10000000000000000000000000000000000000000000000000000000000000000;
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
    base = 257'b01011111101010000011010011001011011000011111100110000110110110111111000101000010011010111010111100000101011110101010010010111111011001100000110001101110111100111000100110101011011001010011011101110001101101100100010010101000001111001001011111011011010101001;
    exponent = 65'b11011011101011100001110001110000110000011000111011000100010000001;
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
    base = 257'b11001000001011100100100110100111001011100100101101100111011001101101001010010110010010010111010010100001011001011011010001111101110011100101101000101010101001000011110110000000111011000000100000110011011010111001011011001001000010001100011101001100010011111;
    exponent = 65'b11111111111111111111111111111111111111111111111111111111111111101;
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
    base = 257'b00111111101010000010110110100101011001111000110010011101100110010110100011011011000010000100111111111101101001001011111100110000110010010001010111000011001011100111000000010110111101010011011110001111100110111000011011100001011000111111011000111110001010100;
    exponent = 65'b00000000000000000000000000000000000000000000000000000000000000010;
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
