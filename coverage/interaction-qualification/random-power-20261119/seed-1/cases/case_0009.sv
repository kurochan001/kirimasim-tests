/*
:name: random_cross_case_0009
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0009;
  logic unsigned [255:0] base, narrow;
  logic signed [31:0] exponent;
  logic [255:0] full, captured;
  bit [255:0] stored;
  bit [255:0] converted;
  initial begin
    base = 256'b0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
    exponent = 32'b11111111111111111111111111111110;
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
    base = 256'b1101111011111101010101100111000000101010011001101011001001011001101110110111100110001110100110111010000000111010000110010001010100010010100100011111000000000110001100001001110101010111111011010100010011100011001011011011110111001001000100001100001000000001;
    exponent = 32'b01111111111111111111111111111111;
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
    base = 256'b1011011100111011011000000110001011100100110101001010110110000110001000110101101001100011110101011100011101001001010111011111100100100011011111001001010101000000001010011001101111110010001011011000011011001110110000010011001101110101100110101010111011101110;
    exponent = 32'b00000000000000000000000000000111;
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
    base = 256'b00010001011101110100011000011000010011100011010011111010011101111010111001110000001001001110110110110111111011100001101010011010001101001100100011010000001110101011011111011001001101100101110000011101101z0111011111011001000100111101100100001111110100100111;
    exponent = 32'b00000000000000000000000000000001;
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
    base = 256'b0011011101110000010101001100111111000000100111110000001001011110111000111000110101100010101001110000010111110101111001110001101110011000111101101010011001000100110011110011100x11101111110101110000111000101010111101100100000100z01011100000111101101001010000;
    exponent = 32'b00000000000000000000000000000001;
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
    base = 256'b1111100100110011001111110111010000101011001010010011010111110010110000000010100000100011111011000110000010111101101011011100111001110011001001110000000100110011011111101011100111010001110010000011101110110100001011011001110101100110010100110001110110101111;
    exponent = 32'b00000000000000000000000000000111;
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
    base = 256'b0101010010000010100100001001111101000010000001000001011101101001101101110000010111111011111100110111001110100010011010001001000000110110001111111000100111000010011000111011110001100110000000011001010001110110011110001111010110001100000010010111100001101011;
    exponent = 32'bx1111110100100001001000100000011;
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
    base = 256'b0011001000100101011110001110101111101011001110010001110100000110010010011000011011110011101001101001010010001011100000101011000111011001000100001101110111010111011000100001010111110110011110011110001110001010010110011010101001010001110011111010000101001110;
    exponent = 32'b10000000000000000000000000000000;
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
