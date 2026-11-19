/*
:name: random_cross_case_0007
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0007;
  logic unsigned [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1110000011101110110000011110101100011110111010001100111101011000,
      64'b1101111010010101110001101111110000011010101000001001100000010101,
      64'b0000110111010100001001010101011001000100000010000111010111100000,
      64'b1010011110001001111001100100000011000010001111101110000111000101,
      64'b0100100010100111111101100010100010001101111011111101000001010101,
      64'b1110000111100010101011101100001110010011011011101111000101111000,
      64'b0110000011100001101000000001000101001011101011011110101100010101,
      64'b1100100010111000101100000100001110101010101111010001100011010110,
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
      64'b1000110011011010011001101111010001010011011011000000110100010111,
      64'b1001000101111111000000010000111110011001101011101100010111101011,
      64'b0111101001011101111001001101000110110101010100110111001011000100,
      64'b1110101001011011000000101011111100110011100000100000111111100110,
      64'b0001000101110001010000000011111011100110010101010011001000100110,
      64'b0100001001010101011000011110001101010010110101010010110110110110,
      64'b1011100111101110111010010100011111000000110010011111011001100000,
      64'b0000111110111100111000101000100010011100011011000101010100000010,
      1'b0
    };
    control_a = 1'b0;
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
      64'b1101001001110001111001100001001111000110010000001100111111111110,
      64'b0110110111010110110101110111101011011010000011100101101110000101,
      64'b0101100110011010010011011110111001011111010111010111101100001101,
      64'b1010101001111000111100011010001110010100111101001010011111010110,
      64'b1000000010110110100000001001000011110111001100100010101110111011,
      64'b1101000001011001000001101011011011001010100010101110110001011101,
      64'b1010101010110011110010000001010100001010100001111010110101000111,
      64'b0001010110110010010101111110010011100111010110011101010001000110,
      1'b1
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
      64'b0110110101101100111110000111100100000110100000011010100010111101,
      64'b1111010011110000000000000111101111001111110000111101101000111010,
      64'b0011001000001111010010100001111000001101011011100000111011101110,
      64'b0000001100111101111110010110000100010011010100111000101100011111,
      64'b1100101101010001001010101111000011011011011110001011010010001100,
      64'b0001011110111110110111110101011101000001110001110010001010100100,
      64'b1011000100011101110111001000000110111011101110011101001110100111,
      64'b1100111110001101010101010010000010011001110101100111101000100000,
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
      64'b0110110101101100111110000111100100000110100000011010100010111101,
      64'b1111010011110000000000000111101111001111110000111101101000111010,
      64'b0011001000001111010010100001111000001101011011100000111011101110,
      64'b0000001100111101111110010110000100010011010100111000101100011111,
      64'b1100101101010001001010101111000011011011011110001011010010001100,
      64'b0001011110111110110111110101011101000001110001110010001010100100,
      64'b1011000100011101110111001000000110111011101110011101001110100111,
      64'b1100111110001101010101010010000010011001110101100111101000100000,
      1'b0
    };
    control_a = 1'b0;
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
      64'b1011111101100101010100101010110001000111110111001111000010011101,
      64'b1111010010100101011111000110100011111100001110100111110101111101,
      64'b0111010101000110100011100100011100101110001101110110111111101000,
      64'b1000110100000000000111111111110001101111000011010100001110010100,
      64'b0110010010111100111111011010010101001100011110011110101110101100,
      64'b1000001010000001110111001000101010111011100000110011111010101011,
      64'b0001011010100001111101000001110010011011000101110011001000010100,
      64'b1010011101011011010100111010111001001011101100101000000011110110,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1000111110111111111011111100001001001110111000111110001011111111,
      64'b0010101100000100001101101001110011110000011011101010101010100000,
      64'b0001100101011101001111110010000000010011101100111001101101110110,
      64'b0001111110000010100011011001000001011011011101001000110100000110,
      64'b1000011000100011111101100111001001101000001101110000010000010101,
      64'b0100010110000001100011011010000111100000110101111001011101001111,
      64'b1111000011101001110001110000111001001111110111001101100110011110,
      64'b1100100110010001010101100011000110010100100001111110100101111110,
      1'b1
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
      64'b1111101010001101000100111011111100001000000000000101000111000100,
      64'b0101100100001111010111011011100111101001110010011001111101101001,
      64'b0001001111110001011000101000010111000100000100010000111011100011,
      64'b1100110011100110000100110011110101111110000101011111111100000011,
      64'b0111110111111101000110010111101011000010011110111011101000101100,
      64'b0101010101101100000001101011101110001110010010000000000111001110,
      64'b0100000001110110000101010011000001110000111001011000100011000000,
      64'b0000010101101000100010111010101000111010011110110010110101111001,
      1'b0
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
