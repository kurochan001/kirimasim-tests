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
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1011100110001111000110011101011001110001011100111101100110011100,
      64'b1010110100110111101011101100110011000110011001010100101101011001,
      64'b1001001110110110111001110111000000110110110101000111011000010010,
      64'b0000100111100011101111101101111010100111101001011001001000101101,
      64'b1011110010001101011010100000001001101101100011100100110011101111,
      64'b101x001101111101111111011001100000010101111101010001111111100010,
      64'b0010100001011000111000111101010111010010100100010011110110110111,
      64'b1010110110001111110110101100000100011110001000101000010001011000,
      1'b1
    };
    control_a = 1'bz;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b0000011111111100000010001011011010011010111001101100100000001101,
      64'b0110011000110000010100001110010011111011100000101110000111110000,
      64'b1101101100010101110100001110101111001110100101000010010010011010,
      64'b0111000101001111111100001011000000100010101011000101101110111110,
      64'b1111110100010000010010000101010110000100001011010011101011100011,
      64'b0011000000001110101111110001101101111001011010100111000011100100,
      64'b0001011110100010000101110010001110001111011010011100001111001110,
      64'b1101001110111100100001100100101010101011110010010010111010010111,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'bx;
    control_c = 1'b0;
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
      64'b1111001110100111101011000101110011001100110101011000111111001100,
      64'b1100010100001100111011110011001001110001110111101110011000000010,
      64'b1111001101010110111010000001011111000001001011111000010001000001,
      64'b1100000101011110011011110010101011001001011001010101001101100010,
      64'b1010011111011101011000101010100000001001101001101001101000001101,
      64'b0001110100110001100111000111011100010100110010001001011000100001,
      64'b1001001000000111101100000110001010100010000111011111010111100101,
      64'b1111000111110110000100100111000001000000110010011100101001110111,
      1'b0
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
      64'b1000011001001111000100110001100110010111100010111001011101101101,
      64'b1010111001110010111010010001001010111110001010111111011111011100,
      64'b1001010011110000101000101001101000000010101101101010101000011110,
      64'b0001101010100111111000101111101001100010111000011001101011001101,
      64'b1001000100011001010010110001000110010010001101101111001100101000,
      64'b1110000110101001110111101100001100011101010011011110000111101101,
      64'b1001101001000100100001111010110010100011011100100011011110110101,
      64'b1000100101111110000001110101110111100110111110001010010011010011,
      1'b0
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      1'b1
    };
    control_a = 1'bz;
    control_b = 1'b0;
    control_c = 1'bz;
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      1'b1
    };
    control_a = 1'bz;
    control_b = 1'b0;
    control_c = 1'bz;
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
      64'b1011010100110000100101101100011010101011010000110111001110001100,
      64'bx011110110001110110010011110000110001011011101111111011011010110,
      64'b1100100101010100011011011011101111100100010100001000100000100001,
      64'b1111000111111000011111001110100010101000101011000000110010111001,
      64'b1100110101110100000011100000010110100111111000010100010011111011,
      64'b1111111110x10111010010001100010011010101101110100000110000000100,
      64'b1100100010011001000111111100111101110111011101100100111100010101,
      64'b1101111011101010001100110110110111010101000001110010011110001101,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b1010110110100000100010001011000000100011100111111100011100101001,
      64'b0001101111010011111011001000000011001110011101011101000011011111,
      64'b1111011010101110111010110001000000110111000111101001010001110100,
      64'b1011011100111001011011011111000100001110110100101011100001111010,
      64'b1000011000111000100000010011000010100101001110000110001110000101,
      64'b0101000100011101001110011001011000010100110010000000111111111100,
      64'b0010010110110010101010101000010000000001100010001011010011010111,
      64'b1111100110110100000011010100111010110101001111100010110101110001,
      1'b0
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'b0;
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
