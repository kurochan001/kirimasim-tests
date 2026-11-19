/*
:name: random_cross_case_0084
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0084;
  logic signed [254:0] base, narrow;
  logic signed [31:0] exponent;
  logic [253:0] full, captured;
  bit [253:0] stored;
  bit [253:0] converted;
  initial begin
    base = 255'b011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
    exponent = 32'b10000000000000000000000000000000;
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
    base = 255'b011101011101000100100101001010001100011001000000111010110110001110011000010001110111110110000001001101000000111010001000001000111110110000000010110001010111100100001011001100000110000010111111011111100101010101111111001100110100001011000111101101111010011;
    exponent = 32'b0100101101100110111z001000000111;
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
    base = 255'b111111100111110000010100100011001011011111110000011000110010100010010110010010001111110010001101110000111110100100101011000111111000110110001010111011000110100111101110100101100001101000100111010000100110100001110010000100111000110000011110110010001101111;
    exponent = 32'b11111111111111111111111111111101;
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
    base = 255'b110000110101100101110100010000110100011110000010101110000110101000111001100100010010100101100111111010111100111101010001011101000001100000000011010011110000010110011010001100011110100001101011010011000010110111111100111011100010011101000000101110100010111;
    exponent = 32'b10010110110111101110110000100010;
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
    base = 255'b111010110100111110100100011011110110110001111110001001000110001001001001000110101010111110100111111111111000110001101010100001100100011111000111110010101011101010111011000001011100110001010101101000001100101101011000001111101111001001111011001001111111101;
    exponent = 32'b11111111111111111111111111111101;
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
    base = 255'b011011011101000000011101111101000011011110111000100001110101010001110100101001000001110010100010100111111111101000001001010111011001011100011111111101100010101011011100010010011101001111100100010110011001111011100101111100011110111101100001110010101010111;
    exponent = 32'b11111111111111111111111111111111;
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
    base = 255'b000z1001010000010111001100100011000011011100111100100011x000111110000010100011100010001100001010001111101111011101011011011100000010001100001111000100000001010011111011000000111110000001100110010011011111101110101101010011110001001001010111111110100011100;
    exponent = 32'b11111111111111111111111111111101;
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
    base = 255'b100100001011110101111000101011111111001000000111111100101101010000001000110110010111110100110001101010101011110110101010110001101110101010001100001100110000110111111110100100110101110011011100100010101010000010000000000110111101110000001010011011010110011;
    exponent = 32'b00101010110010111101001011010010;
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
