/*
:name: random_cross_case_0070
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0070;
  logic unsigned [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1110001000101000001111000000000011011110010111010101111000001111,
      64'b1000010001001111101111011101100101101100110000110011101110100101,
      64'b1111001001111100001000110101011011010101011101010100100101000110,
      64'b1001100100111001010101101111111011111111100011100111101001101001,
      64'b0101011101011001000001010111111000111100101110000001111111110110,
      64'b1011001001011000000001111010011010010011111001001100111010001111,
      64'b0100010000101000011001000110001111110001110101111111010111010000,
      64'b0010100100010001111000001100111111110111011100010110011011101000,
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
      64'b0111110000101000100001100010100011010001110010001100001110110101,
      64'b1000000001100001000110000111100111110010010010000001010100101010,
      64'b1010101011000011111011011110111010011010000001010001100100010111,
      64'b1001111000000101010010001011001101111100011101101001100011100100,
      64'b1011010111100001011011110101101111011110010110100000110001000001,
      64'b1010110010111101101010100111001100011100001011001000110101111001,
      64'b0111110101100001111100110001101101001111010000110000111101111001,
      64'b1001000111001010010101000011011010111010010010101010011101101111,
      1'b0
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b0111110000101000100001100010100011010001110010001100001110110101,
      64'b1000000001100001000110000111100111110010010010000001010100101010,
      64'b1010101011000011111011011110111010011010000001010001100100010111,
      64'b1001111000000101010010001011001101111100011101101001100011100100,
      64'b1011010111100001011011110101101111011110010110100000110001000001,
      64'b1010110010111101101010100111001100011100001011001000110101111001,
      64'b0111110101100001111100110001101101001111010000110000111101111001,
      64'b1001000111001010010101000011011010111010010010101010011101101111,
      1'b0
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b0010111001100001011010111101000110010001101101100011101010111001,
      64'b0001101101100011111011111110011101011010111011011100001100101010,
      64'b1011001000000100101011010001001110110110001100101111000110100100,
      64'b0101100010011000010100100010011111011101000011001000010111100111,
      64'b1011101101010100010111001101000100011101000110001011011101111100,
      64'b0011101100011110100110110010110110110001011101100101011010001011,
      64'b1100011010001100110111011001110000101000010110011000011011000100,
      64'b0011001111111010001000010001000000001101001010110110100100101010,
      1'b0
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b1100101001011001001101110011011010000001110101001000110000011010,
      64'b1101111100110000100101001001110101111100101010101001100111001001,
      64'b0010001111111100101110111011000011010001000100010011100111111011,
      64'b0100110001110011001011111001100011010010100101000000110100001111,
      64'b0011101011010010001101100111011011000110001011111100001110101001,
      64'b1000010101010000011100000000001000100000100111101110110101011101,
      64'b1111110101011111010100101110100010000100100001110001001010010000,
      64'b1000110111000101100010011101111100110101100101000010101111101110,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1110101000111111001001110100110100101100001000100011001011010101,
      64'b1011101011010001111111011101011010001110110011111111101000110010,
      64'b0111000101111000101011001001000011011110101100110010011001110010,
      64'b1001111010010100011110001011001101011110100111111010010011100101,
      64'b1011000011000011001110110111010110110000010111001011011101111110,
      64'b0011101001011011110011101110011011011101011100000000000010111011,
      64'b1010001101000011111110101000110111110010000011001110101110000100,
      64'b1001110101110100100111110111011101110111111110110100110000111110,
      1'b0
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
      64'b0011000110100111001010000110010001000101100101000111111100001010,
      64'b1101100000000010110001010001011010110110001100100101010100110100,
      64'b0101111001111111010000110100110011011111101011000011101000011001,
      64'b0001011010011100100000101000011010001010001110110101011001111000,
      64'b0101010011001010100001110010011000100000110101111111110100111000,
      64'b0000111010011101110100001000110010000000000000100010000000100001,
      64'b1110001010011001001111000001010001001010010010110011100111000111,
      64'b0001001101100000010101010000000111100100111001101010101100101111,
      1'b1
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
