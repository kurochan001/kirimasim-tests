/*
:name: random_cross_case_0027
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0027;
  logic unsigned [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1011011011010011000110010000010101011010001110110001000110101111,
      64'b0110101011001000101110100111111000101000101010111010001000110111,
      64'b0011111011101110100001111001010000000110101011110010011110011010,
      64'b1010001101100010111100100001000100111101011010010001001000110011,
      64'b0100000101111100001011001010101001100001011100100111111110111100,
      64'b0110101111100001110110010011111001010101101011010101011010101000,
      64'b1000011101111011100010101101001110100010111111011100010001100101,
      64'b1111101010001100011110110011011000100110100111011001110011011111,
      1'b0
    };
    control_a = 1'bx;
    control_b = 1'bz;
    control_c = 1'bx;
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
      64'b0000001000101010001101011101001010110110011110101111011001011101,
      64'b1110100100011101010101101101001010111010000000011001010000001101,
      64'b1001011110001010010011110000100101101111111110000000011110011001,
      64'b0100100100001000101000000001111010100011110001000001011111101010,
      64'b0111101100011000100000110011000111011001111001111000000001011011,
      64'b0001111010101111011101011101000110100001000001100010010101001111,
      64'b1000101111100000110111001111000010010000100001110111111011001100,
      64'b1101110011010011101000010101101101001101101100111111100000111101,
      1'b1
    };
    control_a = 1'b0;
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
      64'b0000001000101010001101011101001010110110011110101111011001011101,
      64'b1110100100011101010101101101001010111010000000011001010000001101,
      64'b1001011110001010010011110000100101101111111110000000011110011001,
      64'b0100100100001000101000000001111010100011110001000001011111101010,
      64'b0111101100011000100000110011000111011001111001111000000001011011,
      64'b0001111010101111011101011101000110100001000001100010010101001111,
      64'b1000101111100000110111001111000010010000100001110111111011001100,
      64'b1101110011010011101000010101101101001101101100111111100000111101,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b0100010110011101000100110110001110010001111011101110110101100100,
      64'b0000001110101100010111101111001101000000110000111000100010110110,
      64'b1111111000110101001101001101000010101001101000111011100111011000,
      64'b0010000100110011000100110001001110100101010010111010111101101101,
      64'b1000011111101011001101110100101011001100111001101000101111110000,
      64'b1010000110011001011011011010100011101110000111111000000010100101,
      64'b0000001101101001011111111100001110110100100010010000000011101000,
      64'b1110111011110010000111100100010001100111111111100100000101100000,
      1'b1
    };
    control_a = 1'bz;
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
      64'b1111101111001000101110000001111011110001000100111111110010100111,
      64'b0000101101000001110111010010000111010000111101011010101111101100,
      64'b0000001001001110000011110001101110010001010010110011110011101011,
      64'b0100001111010001110101111101010100001001111100001100101100001011,
      64'b1100011100000000100111101001111011111100101000101011110011111101,
      64'b0011111111010001000001111001110000100100000110001001000001000111,
      64'b1101011100100001101000000111100000101001111100110001000001000100,
      64'b0100111001000111101101011010011110110011111111110111101001100101,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b0010000001011101101110110100100111011000110100101010111111000101,
      64'b1111001100000010101010010001110001010001100010010001110111101110,
      64'b0010000000001101010111011001011000111101001010000001101000110111,
      64'b0101100110101100011100110111101000010000111111110010101101100001,
      64'b0110011001001000011010001010111010010011011001001011001011000100,
      64'b0011010011010010110011100000110111011001101010111011111001110001,
      64'b1100111111001001111101001111111101110001010101111010111101100000,
      64'b1111110101101111000111001110110010101001101111111101011000001110,
      1'b0
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
      64'b1100100000000011110101001100000011000110110101001000111001100000,
      64'b0101011101100000100000010111100000001000111110000111100000010000,
      64'b0110001111011001000000011001111100101010101000110101010111110001,
      64'b0001110111001000111010010001000101111110000110101011011111101000,
      64'b1111000000111101110001001010001110010011010110100010101010111111,
      64'b0110110000100111111100110000101001111010001100011110111010011000,
      64'b0011110010110110000011100110111101011001000000111001100101111000,
      64'b1101001011111011001111001000111101110001101110111111101101011011,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'bx;
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
