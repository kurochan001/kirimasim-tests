/*
:name: random_cross_case_0015
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0015;
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'b0;
    control_c = 1'b0;
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
      64'b0011011111011100001001010011100001011000010101111011110111011100,
      64'b1111100010001011010100001101001011000110110010110110001111110011,
      64'b1101000001101000000001110010001101000101100110100100100110000110,
      64'b1110100000011110000110010100011101011011101001011001001011100101,
      64'b1110011111010010100101101001111001001001101100001001010110000001,
      64'b1001100010101001000101010011100010110101010101111001111101011001,
      64'b1010001011110110000010100011111000111111001001011100100110011100,
      64'b0100101100000111001110000100000011001111101111111111010111101000,
      1'b0
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b0010001100111100101101011111101001110011110000000101011110110110,
      64'b0110100111010110011111011001101011001101100001001010111000101110,
      64'b1000010111001111000001100010101010111001011000100010000110001111,
      64'b1001011110111100110011111100101101101000001101001100100100000101,
      64'b1111101100001111100011110010000111110110110010011111001001000010,
      64'b0001111100101010000110011011101000110000111000010111010101010001,
      64'b0010000100101000001011000001000101111000100010110100101110001110,
      64'b0101011110100011010110000110010011111000000101011010000110000010,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b1000010110110001000101001000010111101110010110101100111110100011,
      64'b0011001011110000111011101001100110100111011011110101000101100010,
      64'b0100011111000110111111011000100000010101010111011010000011011011,
      64'b1010111000001000010000000111100100001110010000101111000000100110,
      64'b0011011011001000100101111110101010001001011111010101000011100100,
      64'b0111000010001110100011111101101001010001111001100000100101010100,
      64'b1100101011111011111001010000100110010111010000100000010000100100,
      64'b1111101100000110110011100001101111111110101000101001010111010001,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b1000010110110001000101001000010111101110010110101100111110100011,
      64'b0011001011110000111011101001100110100111011011110101000101100010,
      64'b0100011111000110111111011000100000010101010111011010000011011011,
      64'b1010111000001000010000000111100100001110010000101111000000100110,
      64'b0011011011001000100101111110101010001001011111010101000011100100,
      64'b0111000010001110100011111101101001010001111001100000100101010100,
      64'b1100101011111011111001010000100110010111010000100000010000100100,
      64'b1111101100000110110011100001101111111110101000101001010111010001,
      1'b1
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
      64'b0000100100110000000100111011001111000000100000110001110111111100,
      64'b1010000111110101000000101100000001110010110000110001011001011110,
      64'b1011001100101110101101011100011001010010001000100011101110110101,
      64'b1101110111101010000011001111011010101100001111001111011011110100,
      64'b0111001111001111111001110111001001010010000011001101000000001010,
      64'b1100010111111101100111010110000010001101100011000011111111111110,
      64'b1100010001000000010011011010001000100111111011101100100110000111,
      64'b0100100100111110110111001011000010000001010011010001110110110100,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b0000100100110000000100111011001111000000100000110001110111111100,
      64'b1010000111110101000000101100000001110010110000110001011001011110,
      64'b1011001100101110101101011100011001010010001000100011101110110101,
      64'b1101110111101010000011001111011010101100001111001111011011110100,
      64'b0111001111001111111001110111001001010010000011001101000000001010,
      64'b1100010111111101100111010110000010001101100011000011111111111110,
      64'b1100010001000000010011011010001000100111111011101100100110000111,
      64'b0100100100111110110111001011000010000001010011010001110110110100,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'bz;
    control_c = 1'bx;
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
      64'b1111111001000001100111111011010101011111011000100010011101101111,
      64'b0110001001101001010110100010010011000010101011011001011101101110,
      64'b1010011001110111000101010010101010010110101101110010101111111111,
      64'b0011101100111011110000110000110010010110000000001001011001111001,
      64'b0011010111001010101010100101010000010010001001000011001100010111,
      64'b1011001011110001011100001101110101011110000000010000001000111101,
      64'b0011000001010101011001010110001011011011100101101000001100011001,
      64'b0000111001000101011011010000111100001111100010000110110010011000,
      1'b1
    };
    control_a = 1'b0;
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
