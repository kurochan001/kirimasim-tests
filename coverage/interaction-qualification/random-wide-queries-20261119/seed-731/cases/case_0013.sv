/*
:name: random_cross_case_0013
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0013;
  logic signed [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1100100101001011100011000001111111100110101111000000000101000110,
      64'b1110001111011010001000111010110011001010000000110110000111000101,
      64'b0010101000110110010100110110110111001100101101101000010000010110,
      64'b0110100011101101010101100001100100101010000000111011101011z11100,
      64'b1001111011001110111000000110111001101000111100000001101101100001,
      64'b0101010100111011010110100100000x01000010011001001111100010111111,
      64'b10111010110001001011110110011001001111101101100100001x1000001100,
      64'b1011110111101011110110111000010100000011010011000010001010001110,
      1'b0
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
      64'b0010111110011100010011111100100000110010010011010101101000000101,
      64'b0000100011011100000011000111101001101110010111010010101011000010,
      64'b1010110101100000001001011000101111011111101101011001101011010110,
      64'b0110001000101000110101000001011101000101011101000000100010101000,
      64'b0100110111010110100010000110111101010001011101010010101111110110,
      64'b0111000011000010101001101100001000100000100010111100010110100111,
      64'b0011111010010101000111010110010100111011110101010111110111011000,
      64'b0010100000010010011110001110000100011111110001101000100110011110,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1111110001101111000100110111111011111101100010110100111010001000,
      64'b0100010110001111010000001001101110110001101111001111000110110000,
      64'b0101000101100010111000010101010011010100100001101001111111001111,
      64'b1011100101010000101110001001000001010100111101010100101100100100,
      64'b1011101000001001010011000000010010101111110000111100111001001111,
      64'b0110110010110000110111010101011000011111101100011110101101110001,
      64'b1011001110100000000101111010000011010111101111001011001110000001,
      64'b0100011011111100010111001001001001010000100111000100010010001111,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'b1;
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
      64'b111110010111100010110000101z011010100001100101011011010011011100,
      64'b0000111110000111011011110011111111010100011010000000101010111010,
      64'b111100001011z000011001111000100010111000110110011111101110001010,
      64'b0001011010000011111000101100111110101001010000010001111101000111,
      64'b1111110100010110100011000001111011111110010000011111010111110100,
      64'b100010110z011101111110111100100100011010110010000101101110001110,
      64'b0011000100100111100010011111001000001010101010000111011101010010,
      64'b0101100110100100100001110111000000010111101101001100010001001100,
      1'b1
    };
    control_a = 1'bx;
    control_b = 1'b0;
    control_c = 1'bx;
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
      64'b111110010111100010110000101z011010100001100101011011010011011100,
      64'b0000111110000111011011110011111111010100011010000000101010111010,
      64'b111100001011z000011001111000100010111000110110011111101110001010,
      64'b0001011010000011111000101100111110101001010000010001111101000111,
      64'b1111110100010110100011000001111011111110010000011111010111110100,
      64'b100010110z011101111110111100100100011010110010000101101110001110,
      64'b0011000100100111100010011111001000001010101010000111011101010010,
      64'b0101100110100100100001110111000000010111101101001100010001001100,
      1'b1
    };
    control_a = 1'bx;
    control_b = 1'b0;
    control_c = 1'bx;
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
      64'b111110010111100010110000101z011010100001100101011011010011011100,
      64'b0000111110000111011011110011111111010100011010000000101010111010,
      64'b111100001011z000011001111000100010111000110110011111101110001010,
      64'b0001011010000011111000101100111110101001010000010001111101000111,
      64'b1111110100010110100011000001111011111110010000011111010111110100,
      64'b100010110z011101111110111100100100011010110010000101101110001110,
      64'b0011000100100111100010011111001000001010101010000111011101010010,
      64'b0101100110100100100001110111000000010111101101001100010001001100,
      1'b1
    };
    control_a = 1'bx;
    control_b = 1'b0;
    control_c = 1'bx;
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
      64'b111111111111111111111111111111111111111111111x111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111x11111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b0;
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
      64'b0001100011001000100011100101100010000011010000111001000000000101,
      64'b1011011111110101010011111001101101011110011000111001001000001101,
      64'b0111001111100101000110011101111101110010110010101101000000100001,
      64'b1010001110011000111001011111000000100010011101110011010011011101,
      64'b0111101011111101010100000110101000000001011000110101100100100001,
      64'b0111001010110001010010010010010110011000111111101110001001011110,
      64'b1001010110010000001110001111010001111111110011000111001111100111,
      64'b0000000010010000110000000010001001011011011110000010111010101000,
      1'b1
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
