/*
:name: random_cross_case_0025
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0025;
  logic unsigned [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1010101001101100011010000000000111011000110011011000011000000111,
      64'b0011011010100001001010111011010101001000111110110011110000010110,
      64'b0101111010110000110100000101011111111100110111111000101100001100,
      64'b1101010000100101100001101000011111010110110110001001010111101101,
      64'b1010000100101011101001110011000010010111001011010000011001000101,
      64'b0111000011000111010000101100110001101000111000011111011110010000,
      64'b1110011000010011110100111001100100111110011001101011101011101001,
      63'b111111001001000100111110101000110111000110110011101011100110010
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'b1;
    $display("v0_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v0_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v0_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v0_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b1010101001101100011010000000000111011000110011011000011000000111,
      64'b0011011010100001001010111011010101001000111110110011110000010110,
      64'b0101111010110000110100000101011111111100110111111000101100001100,
      64'b1101010000100101100001101000011111010110110110001001010111101101,
      64'b1010000100101011101001110011000010010111001011010000011001000101,
      64'b0111000011000111010000101100110001101000111000011111011110010000,
      64'b1110011000010011110100111001100100111110011001101011101011101001,
      63'b111111001001000100111110101000110111000110110011101011100110010
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'b1;
    $display("v1_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v1_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v1_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v1_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b1011000001101001110110001111011001101101100110011010101001010000,
      64'b0011110101100100011000100100011110000000000110011110000011110101,
      64'b0101011100001100000001001011000101100010111000010001101110101001,
      64'b0111000111101100100111011010101100101111101101110011010011110000,
      64'b0011100000001000101011100110001110000010010101010001001111101010,
      64'b1011010000111111111101100110011110110101110000110010000101000101,
      64'b1110000001001010111110010101101111001010010100001000000000000000,
      63'b111111001010101000010111101010101111001011000001111001111010101
    };
    control_a = 1'b0;
    control_b = 1'b1;
    control_c = 1'b0;
    $display("v2_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v2_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v2_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v2_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b1110010111100111010101001110011100010110010010110000000110000111,
      64'b0000000101101000000011100101000110000100111011010100111110011100,
      64'b0110110010011100001001011111000110001101010110010000101110010011,
      64'b0010101000010000001111101001010000010111000001000010111000010100,
      64'b0101000111001010111001101001001101101100100011000011100110101101,
      64'b0000011000000011111111100011110111001010010100111011010010011110,
      64'b0010001011001101000101101011111110011001100000011100000110001010,
      63'b010010001000111100110011101110110000110100011101101110011011101
    };
    control_a = 1'b0;
    control_b = 1'b0;
    control_c = 1'b1;
    $display("v3_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v3_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v3_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v3_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b1001111110011000110110111011011101011111110000100110110001110011,
      64'b1111011100011111101010011001010010001010111101110111101010011011,
      64'b1010000111110001010011100001010011110010100101110011110100110101,
      64'b1100100011100111001101011101100100100111100000110001000000110110,
      64'b1110110000011001100000100000101101010110010010101000110011000000,
      64'b0110100000011001001011100011100010001010010111100001111100011001,
      64'b1111101110001111111011100011110110001001000010000000111101101010,
      63'b011011111000101110100011000010011011011001010100100100101001001
    };
    control_a = 1'b0;
    control_b = 1'b0;
    control_c = 1'b0;
    $display("v4_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v4_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v4_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v4_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b1110001111011011100011000001011101101010100010110010111100000010,
      64'b1000001000110111100101011001101001010000011000111110010111011000,
      64'b0100111101100111100110001111101001111111000110110100001111100100,
      64'b1010001111110011101000110000011111010010100001011111101000101111,
      64'b1100111011110101010011010010011100000100101000001001000101100100,
      64'b0111010000101101010001111100010110101101011001001010011011010101,
      64'b1100011110110011101110111101011110100100000010110110101110111001,
      63'b111111000100100000001100011001010000100110101011010110101101011
    };
    control_a = 1'bx;
    control_b = 1'bz;
    control_c = 1'b0;
    $display("v5_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v5_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v5_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v5_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'b1;
    $display("v6_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v6_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v6_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v6_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b000000000z000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
    };
    control_a = 1'bz;
    control_b = 1'b1;
    control_c = 1'b1;
    $display("v7_input=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("v7_hist zeros=%0d ones=%0d x=%0d z=%0d",
             $countbits(source, 1'b0), $countones(source),
             $countbits(source, 1'bx), $countbits(source, 1'bz));
    $display("v7_queries hot=%0d hot0=%0d unknown=%0d selected=%0d single=%0d",
             $onehot(source), $onehot0(source), $isunknown(source),
             $countbits(source, control_a, control_b, control_c, control_a),
             $countbits(source, control_a));
    $display("v7_after=%b a=%b b=%b c=%b",
             source, control_a, control_b, control_c);
    $display("return_bits=%0d,%0d,%0d,%0d,%0d",
             $bits($countbits(source, 1'b1)), $bits($countones(source)),
             $bits($onehot(source)), $bits($onehot0(source)),
             $bits($isunknown(source)));
    $finish;
  end
endmodule
