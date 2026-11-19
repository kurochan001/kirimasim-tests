/*
:name: random_cross_case_0079
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0079;
  logic signed [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      1'b0
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
      64'b1100111000011100000011000011011111111101111000111100001001000011,
      64'b1010100010110100001000001100011001001001000001100011110011110010,
      64'b1010111101011110110101000001100101100010000111010001101001100100,
      64'b0101110001100100101100111011011000100110100101111010110111111011,
      64'b1001111110001111100101010010111100010001100010100111100001000011,
      64'b0011101000000101111101011111110111001101011100111011001000101100,
      64'b0110010101101101010001100111001000001000001000110100100001000001,
      64'b1000101011100110011001001101110010110000010111010101000010000110,
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
      64'b0111011111110001111011100001011101010010101110001100110111111000,
      64'b0000011001101011101100101011010011011010010111001010010011000011,
      64'b0111010010111111001001001001100001101110000011110100000101011110,
      64'b1000110111010001001001010011010000001010001101000110110001100011,
      64'b0001011101010100010100110010110110001101101010101110010101100011,
      64'b1011101011110010001010101111011010000110111010101101010100010010,
      64'b1101110100001000000101111000000100100011000000000101101100110011,
      64'b1001100011100111110101000101010111011010111011101100111101100110,
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
      64'b1101000010110010011001101100100110110011010011011000001100000000,
      64'b0001110010110001101010100111101101110011000100110110010101101011,
      64'b1111111111000100100111001111111100101111001011011011011101010110,
      64'b0100111100010001100110011010001011100011011101011101100110101001,
      64'b1011000111000101110000001011110110000100011101001001000111001110,
      64'b0011010010100001100010101011100111111000110011110100100001101101,
      64'b0010011100111000111001101011000100111010011011011111110011101101,
      64'b0111111101111110101011011100101101010100010010000011001010011100,
      1'b0
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
      64'b1010011100011100100100111011111111001011000001000100000000010001,
      64'b1001000011111101010101010010010000011010110100011100000011101000,
      64'b1011111011001100001001110100000101000010100011110011001100110001,
      64'b0010111100000101001101000101000111011010000000010110010011000010,
      64'b0000011101000010001110010001000111000001110001101100011001100101,
      64'b0101100100000011110100001001001000100111100011000100110111000000,
      64'b1001101100101111111001010001111010110111010010101101100100110011,
      64'b0000011011101111011111010101001001011101000011000101000101111110,
      1'b1
    };
    control_a = 1'bz;
    control_b = 1'b1;
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
      64'b1000000101011100111001111001010110011101011010000010101111100000,
      64'b0101110101001000011010110001001110100100100001000100000010000010,
      64'b1011010100111100011111111111101111011110001010101010100111011100,
      64'b1010000111001000010001110100111011101010001101101101101001011101,
      64'b0000101010001010011001101000101011101011100010110110011110000111,
      64'b1100111111000110101000110011010000011110110100101010110010111101,
      64'b0011110101000000111010101100110000000000100100011001011111010011,
      64'b0100100011101010110000000001110011101001001100110111111111010011,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1000000101011100111001111001010110011101011010000010101111100000,
      64'b0101110101001000011010110001001110100100100001000100000010000010,
      64'b1011010100111100011111111111101111011110001010101010100111011100,
      64'b1010000111001000010001110100111011101010001101101101101001011101,
      64'b0000101010001010011001101000101011101011100010110110011110000111,
      64'b1100111111000110101000110011010000011110110100101010110010111101,
      64'b0011110101000000111010101100110000000000100100011001011111010011,
      64'b0100100011101010110000000001110011101001001100110111111111010011,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b1000000101011100111001111001010110011101011010000010101111100000,
      64'b0101110101001000011010110001001110100100100001000100000010000010,
      64'b1011010100111100011111111111101111011110001010101010100111011100,
      64'b1010000111001000010001110100111011101010001101101101101001011101,
      64'b0000101010001010011001101000101011101011100010110110011110000111,
      64'b1100111111000110101000110011010000011110110100101010110010111101,
      64'b0011110101000000111010101100110000000000100100011001011111010011,
      64'b0100100011101010110000000001110011101001001100110111111111010011,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'bz;
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
