/*
:name: random_cross_case_0037
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0037;
  logic signed [254:0] base, narrow;
  logic signed [7:0] exponent;
  logic [510:0] full, captured;
  bit [510:0] stored;
  bit [510:0] converted;
  initial begin
    base = 255'b001000111001000101101101011101100101101110111010100110111101010101100110111101010011001010111100001100101000010101111110101110111000100001000000000001110010000010001000011111000010101111111101100000110111111010010110000111001000000100101001010000001010100;
    exponent = 8'b11111111;
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
    base = 255'b000001000100011001000111001100011100111001011111110011101111010100010000010000000001001001100110011011101111011101010110001011111011011110010010111110110000111100011010011000000001011010011000011001101111111110101011101111111010011110110110010101001010000;
    exponent = 8'b00000000;
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
    base = 255'b101001100111z01100010101110001001100010111011110111000100101001001111011111111101001011000011010010110111110000010001110011010011101110101111100111101110110001100001100011010001101001110000011011010011000010101001011z00111111110100000010011110100000000000;
    exponent = 8'b01111111;
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
    base = 255'b110101011111010001000110010011010100000001101110110010111000101101010101011101010101100110000110011001010110011101100111000000001001010110111011111110100111000001110101111111111011111111001011100011000101110110111101011001010111100010001010111101110011101;
    exponent = 8'b11011111;
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
    base = 255'b010111111110110011001111011011011011001110100011100111111110111111001100001110010010100101100010001111100000101110010001001100001010110010110110101010000000000101110100111000011011000001111000110101000101111101010100011111101001111011010000011100010110111;
    exponent = 8'b00000011;
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
    base = 255'b001010101111111101000001000111111010000010010010011111110100110001011101101100111011000101100110101011111111011100000111110110101001110001000000101010110001011001101110101101011101011101111111100000010100011111101110000101101111111111000001010100110010000;
    exponent = 8'bx1111111;
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
    base = 255'b000111110110001100001010000100010111011011101110000011010100011110010101000101010110011011011100101001101100001011010011001000011001000011101011000111110100011110001101101010100010000001001101010110001011010010101001100110001010000100111110001011110110101;
    exponent = 8'b00000011;
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
    base = 255'b101010001011111111101111110110111111101000001100101100010000111000110001001110000111100100110111111011110001110110110101110111101110010111100011000010000111101000001111011100100111000000011011000111011010101000011010000110011001011011101100111011100001111;
    exponent = 8'b00000111;
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
