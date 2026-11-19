/*
:name: random_cross_case_0065
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0065;
  logic unsigned [510:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0011000011101110011110111110110001010110001000000100001111010001,
      64'b0000101101000110010100001111110000110001101001010110011111111101,
      64'b1011100011100111010000100110001001101001101011110110101011001000,
      64'b1000110001110010011001000000111110011111110101111011101001100001,
      64'b1110100000001110111100001011101110111110000110101101111001000011,
      64'b0001110010100000011101111100010000010101011110110110001011100001,
      64'b1001111011010111110000011000000100000111101101010000011001100011,
      63'b111010001100010110101000111111110011010111010000010110011110110
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1000000010010110011101011100001101011101110111001001101110000101,
      64'b1000100111011010111011111111000110011011100010011111011011111111,
      64'b1000101100111111110100101001111100110010101111111011010000101100,
      64'b1110101001000010010000000110101111100101100101010101001100010111,
      64'b1111100011011000101000001000110000001010010101111010000000110110,
      64'b1000010110111110010110110110010111011010010000011001001110110000,
      64'b1010000111110001100000001001111011111000110110111110111000111000,
      63'b111100101100011111001100001000000001110111000100111110110111100
    };
    control_a = 1'b0;
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
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
      64'b1010011001010100010001010111000000100011101000000101001110010011,
      64'b1011001001110100011001111010110010000110000111110011100101001100,
      64'b0011000001011001101001011011110000010011111011001010011110000001,
      64'b1001110011111110110110100010101010110101101001100010110011111011,
      64'b1101110000110010001100010010111100101001110011101010111101011100,
      64'b0011110111100111100110111101010111011101001101100100111010011000,
      64'b1010001000110010100100111110111000100010100001100001001001110101,
      63'b111101111111000011111111101100110110000101100111101000010101011
    };
    control_a = 1'b0;
    control_b = 1'b1;
    control_c = 1'b0;
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
      64'b1011011101111001101110100110011010000110111001110110001011010001,
      64'b0111101001111111000110101011001101001110001001001111001110001111,
      64'b0100111001011100101001100001101000101101101111111101001100011110,
      64'b1101000110101000100111100011100100101010100100001001101110100010,
      64'b0000111001101110010001011111011011111010001110111100010000010010,
      64'b1000110100010111001100011100101001110011001110100011000101001110,
      64'b1111001010010100011111011001001011001110001010101101000101110110,
      63'b010100110001010010110011101011011000110011110001010101111100001
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'b1;
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
      64'b1101000100110010100111110010101010011100010100100010011101101011,
      64'b1110101100100111010101101001000110101001011110010001101000011101,
      64'b1111100111001011000101010001011111001111110011001000001000001010,
      64'b0011111111000110001100101111101001100101101001110011010010001011,
      64'b1000101010111001000111111011011001011001110101111001110001000010,
      64'b1110101000101110110110111011010111101111001111100100011001010000,
      64'b1111100011111100001100100100000010011101101000000110111101111100,
      63'b000010111101011101110111010011100011000101011001111101010010000
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b1001101111000101011110110100110011110000010100111000010010110110,
      64'b0010010100000100111011001001011111010110001001111111100101010000,
      64'b0111001010001111001010001001111001100010110110000100110001101000,
      64'b1100111101110111110001010010010011001011110100000101101111010101,
      64'b0010110100110111111001010000000010110110000101110010111100001000,
      64'b0110111000000000001110110011101011010101101111000011110110000001,
      64'b1101100100001011010000100011011100010100101001101100100000101110,
      63'b010101011001111110111110100001100100111110010101000110000101000
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
      64'b1001101111000101011110110100110011110000010100111000010010110110,
      64'b0010010100000100111011001001011111010110001001111111100101010000,
      64'b0111001010001111001010001001111001100010110110000100110001101000,
      64'b1100111101110111110001010010010011001011110100000101101111010101,
      64'b0010110100110111111001010000000010110110000101110010111100001000,
      64'b0110111000000000001110110011101011010101101111000011110110000001,
      64'b1101100100001011010000100011011100010100101001101100100000101110,
      63'b010101011001111110111110100001100100111110010101000110000101000
    };
    control_a = 1'b1;
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
