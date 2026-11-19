/*
:name: random_cross_case_0071
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0071;
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0000001110000011101111101010010101011010011101001101110110000011,
      64'b1111011101111111000111010000011011110001111111000110001011101111,
      64'b0100001100110101010001001000110011100001000100001101100000001111,
      64'b1101111100000101111001000011000100110101110010111000010011110001,
      64'b0111001011010001000101011101100010001100000101000111011011111111,
      64'b0001110011100001100000010000000100100111010101101110010111100111,
      64'b1011001010111001000101111011101010100001001011000101100011110000,
      64'b1001101010100001100100100110110101111001110001100001111110000110,
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
      64'b0010111001000110100111111100100010000000000111001111001101000011,
      64'b0110010001110011001110000011011101101011100000111111001001101011,
      64'b1110110111111101010011001011110111011110011101111010001111100011,
      64'b0000000110110000100101111011001101100111111101011001001101000010,
      64'b1110011100011001100111010110111101111010010001101010001001010011,
      64'b0101010101100100101101110100000100001011110010100010001010010101,
      64'b1001101001111100110000001100101000010111011010010000010100110010,
      64'b1010010111110000110110111000110011001100000100010110110111001111,
      1'b1
    };
    control_a = 1'bz;
    control_b = 1'bz;
    control_c = 1'bx;
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
      64'b1100010111000010110111100100010011001110101001110110110101001010,
      64'b0001011100010001011100010001011011110111000100110100100001000100,
      64'b1001001100011000101000110111110000110011010000110000011101101100,
      64'b1111100110001011100110100000101100111000111110101101011110111100,
      64'b0100101000100110101010001100100111001110100100001001000101110111,
      64'b1010111001011011011100101011101111000010101010110110111001010110,
      64'b1000110111010000111011010101110111111000110100010101011001110001,
      64'b0011101111111101110101110110101011111100001110000000001010100010,
      1'b0
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
      64'b1000010100000101110111010100010000011011100100111001001001110001,
      64'b0100101100100001010011111001101011111111011010010010100011010011,
      64'b0000001100010001101000101011010001111001101010100010100000001011,
      64'b0100111111010111111011011011010001111100111011100111000001101000,
      64'b0101000100110000101000001000001000101100011010000010111011111110,
      64'b1111111100111010101001111100101001010110000001001001011110110011,
      64'b1110000001010111010111000001011000011011101101000011101110001010,
      64'b1011001010001010100110011110111001010011011010100111111110000100,
      1'b0
    };
    control_a = 1'bz;
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
      64'b1111101101000000000011011000000110100011000011011101011000000001,
      64'b1011000101001100101010000100000000010101111101001101111111110000,
      64'b1000001100011101010001100101100011100001011110101101110001100011,
      64'b0000010100010101100001101001011001001000001100100111001000101111,
      64'b0101111000000100000011010001011011000101101100010111011010110011,
      64'b1011001100010101010110011110011111111100111010000110011011101111,
      64'b1011111101011111010101101101000011100110111100110001100000101100,
      64'b0010100011100010011100111010111000011101001010011101111000101001,
      1'b0
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b1101110100001011001111101101001111011100011100111010100000101011,
      64'b1110001110101111011011010100011011010111111001000011000100111100,
      64'b1001110100110000111011111000010011010001000110010000100111011001,
      64'b1001100110001010000011011011001000000110001011111000001101011111,
      64'b1001001000000000110001110101110110001111001011000100011011001110,
      64'b0111110010000010001001000011111110010011110000110101101111010001,
      64'b0000101010011011000100101100001001010001110011100101100001011110,
      64'b1101011010111010001101110101011100001010001101000001101110100111,
      1'b0
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
      64'b0111111111011101100011101101011001010101111000101100010101110000,
      64'b1101111111000011110111011111101011101111001101111110001101100011,
      64'b1100101100001111100110100111110010010100000101000010001001000110,
      64'b0001111001001001000100000001111110101101111010010111110111001011,
      64'b1101101110011011011011111000001011011001100001010110001100000111,
      64'b1101111000100101000111000001011010010100001100110001101000100000,
      64'b1000010111111111010100011010110110100111000100011100000111100110,
      64'b1111000110001011010100111010011100000010111010101011100001111101,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'b0;
    control_c = 1'b0;
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
      64'b1100010001100001011110010010011100001110010111110111110010000100,
      64'b1001011111111110100011101111111111000011001001011000000010001000,
      64'b0100000001000001011110000010000100011001101010011000101001000001,
      64'b0111011110101000001101011000100100001111011100110111001001101110,
      64'b1011111011001111000100101100111001000011011011100111010111110100,
      64'b1100100101000101111001001011001100000001011001011001111010110110,
      64'b1111011001000010011001100111001111100011001111000111000100111111,
      64'b1010110100001101010100001110001110010001100100011011100100000101,
      1'b1
    };
    control_a = 1'bx;
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
