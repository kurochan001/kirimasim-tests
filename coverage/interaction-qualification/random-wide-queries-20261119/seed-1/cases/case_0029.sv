/*
:name: random_cross_case_0029
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0029;
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1010001000100000011001110100011101101101110110101110110111100001,
      64'b1110101000010110001110001011000110110000100000110101101011011110,
      64'b0101101011110101111010100111110010011110100010011001011010011110,
      64'b0111001010000110101101010101001000110101110000111111000011101100,
      64'b0111110100011100000110001010010100000000000100000010100001110001,
      64'b1100001111111001101111111000100000110110110010111100001000100100,
      64'b1101000100011101101101100111011010111100000111101101011010001010,
      64'b1010111010010010011110110011011011100100110100001011011001010011,
      1'b0
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
      64'b1101111001011001100010110101100001110000001110000010000011111011,
      64'b0000111110000000111010010100001101110010110111111001111110011000,
      64'b0010000000111110111001101100001100101111000001110000101101010101,
      64'b0100011000010000111000000101001011100001100101010100001000000101,
      64'b0110111011100100000010000101010011001000101010100101000111101111,
      64'b1011101111100000011101100001011101000010101100101110100111101101,
      64'b1111000100011000100001100110001000010000100010100011000010101110,
      64'b1010000011100100000000001101110000110110110110000000001110001001,
      1'b1
    };
    control_a = 1'b1;
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
      64'b1000100111011101010101011100001100101100110010100100110010100010,
      64'b1000001010000001000011011000010100001101001100101101100000010111,
      64'b0001110110010001111110001111101111100001101110001011011110101000,
      64'b0010100101001011101100011110100111101100101111000001000110111110,
      64'b1011111001110110000001100010111111101001111110000000001010110111,
      64'b0000011000100001110001110011010111101011110111100000001010000001,
      64'b1000001110011011100110111101000001000100101101010010010100100110,
      64'b1011000000110101010011011101010110111111111101100010010010001001,
      1'b0
    };
    control_a = 1'b1;
    control_b = 1'b0;
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
      64'b0001110111010100011111011111000100010111111010111101101010000110,
      64'b0010111010110111001110011101100001111111001111011010101000111101,
      64'b0101100011001010111000100001100111110011110010100110011011100101,
      64'b1011110010011001101101111101011101100000110110001001011001101100,
      64'b0010001110111010000000110010011111010000011011011100011010101101,
      64'b0001010101110111101011100011111110001001101011001001001000011000,
      64'b0111111010001111011011010110100111011110110111101001001100001100,
      64'b1111001000101111011001010111111100111010110101101011001001001101,
      1'b1
    };
    control_a = 1'b1;
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
      64'b1111000000001000010111110001010011100110000001001101101101101101,
      64'b0101000001000010111110100100100110110010001000000101101111100100,
      64'b0001010110010011001000110010100011111001000010110100000100101011,
      64'b0010000011011100001110110001011000001001001110011011001000111001,
      64'b1010011100110011101011111101101000010111001110111100100000110011,
      64'b0001100100110110000011111000110100011001011001101100111101010010,
      64'b0001001100001011011101010110001110111100001011011001000111011110,
      64'b1010011011101011100111111010011100000001011010100111001010000011,
      1'b0
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
      64'b1001101101000111101000110000010010100000111011100010000000101110,
      64'b0001100000010101100101000110001000010010010110111001101110010001,
      64'b1111000000000101111110110101001000000000011010001010000111001010,
      64'b1110101011001000010010100111110110100000000100110001011001111110,
      64'b1010101111100101111101100001000000101011000111111101101101010011,
      64'b0001001100000110101010010011101101111110110110001100011111000011,
      64'b1011000101111111110011001111101001110110011111000011110111010100,
      64'b1010010000100000100100001101100111111000101100000101001010000111,
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
      64'b0011011111000111000110101011000000000011111111110100001000111111,
      64'b0111000110110100010001010001100000010110110011101100100111000110,
      64'b0111100100010101000011110001000010011001111110111011001011011100,
      64'b1110110100110001100101010000111000010011001001110011000110101111,
      64'b0100110101000010101111010010101110001001111110110110110111100100,
      64'b1101111111011100010011001011101100001110000011001111011110000001,
      64'b0101001000110001010000010100011011110100111111001101001010010110,
      64'b1110000001101010101110111110110001000011000000010100011100111110,
      1'b0
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
