/*
:name: random_cross_case_0009
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0009;
  logic unsigned [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0010001110100000000100110101100110111000100101100111010010010010,
      64'b0001111011100011011000110001010001000101011111011100001111111000,
      64'b1010110000010011000010001110010110010101111001010100101101110010,
      64'b0000100101110101100010100100011001000000101011101110101111000110,
      64'b1110111110110110001100010101001101100110011110111101011010001011,
      64'b0001011010110100011110100001101110000010110001101111111111001100,
      64'b0100001101001101110001001110100110100111000010000101001100111000,
      64'b1101110000110101101000110110111001001111111110011010010100000000,
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
      64'b1000001011111000100110111110110110100101000000010111010110000101,
      64'b1101011000111110010100011001100100001111101010000110110101000110,
      64'b0100001000010111101010110010110011100111101110001111011011010101,
      64'b0100111011000011000100010111011000011000000001101100001100101101,
      64'b1000000101010000010000001110100111011001010100111110101111101100,
      64'b1101110001101001110011010001110111110101101100100100000001100001,
      64'b0001101011010010100010011010001100001011111111001010000011111000,
      64'b1101100101011001101101010001001111010011010110101001101111000101,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'bx;
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
      64'b1000001011111000100110111110110110100101000000010111010110000101,
      64'b1101011000111110010100011001100100001111101010000110110101000110,
      64'b0100001000010111101010110010110011100111101110001111011011010101,
      64'b0100111011000011000100010111011000011000000001101100001100101101,
      64'b1000000101010000010000001110100111011001010100111110101111101100,
      64'b1101110001101001110011010001110111110101101100100100000001100001,
      64'b0001101011010010100010011010001100001011111111001010000011111000,
      64'b1101100101011001101101010001001111010011010110101001101111000101,
      1'b1
    };
    control_a = 1'b0;
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
      64'b0010000000000010010101000111110010010000101101011001101010010111,
      64'b0110110001101011000100011010001101001101100111001110111111011010,
      64'b0000000011011100101001011001111110100110010110111000110011111100,
      64'b0000010101000110111111101111011110001100110011100100000110100101,
      64'b0100100111011010100101001110000101101101011010000110110101100111,
      64'b1000000000101000111011111101010000010001100101100100101110011101,
      64'b0010000010111110011100100001100101001011111101111011111100001101,
      64'b0101110100101001100111100110011000100100100001111001011101010001,
      1'b0
    };
    control_a = 1'bz;
    control_b = 1'bz;
    control_c = 1'bz;
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
      64'b0110001111110111001001011010011111101101000111010100011000110010,
      64'b1101011000000110101111110101001101100001110000000010001000010010,
      64'b1101111111101000000111100011000011110001011000001100001011000101,
      64'b1001100101100100001101001111110111101000000010100111110101101000,
      64'b1000001000101100110111011111001111101000101010001100101000001010,
      64'b0111010011000111001110111010111111011001010001100101010100110011,
      64'b1101110000110010111010101110100011000011000111101000010011111010,
      64'b0000110000001111001101001010110110100110010111010000101111110111,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b0110001111110111001001011010011111101101000111010100011000110010,
      64'b1101011000000110101111110101001101100001110000000010001000010010,
      64'b1101111111101000000111100011000011110001011000001100001011000101,
      64'b1001100101100100001101001111110111101000000010100111110101101000,
      64'b1000001000101100110111011111001111101000101010001100101000001010,
      64'b0111010011000111001110111010111111011001010001100101010100110011,
      64'b1101110000110010111010101110100011000011000111101000010011111010,
      64'b0000110000001111001101001010110110100110010111010000101111110111,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'bx;
    control_c = 1'b1;
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
      64'b1101110111000100100100101000111000000111000110101000001011001000,
      64'b0000110011001010101100100000111111011000111001000111010000010100,
      64'b1101101100100101101110111100010010100011001011010111110000101110,
      64'b0011110011000101111100100011111010001011111111110101011110101010,
      64'b1001001111100011101000110110110001100000010011111001101110100101,
      64'b0010101111110011110001101010111001100110000010001100001101010011,
      64'b1000000100011101000000111111110110011110110000010000000111001111,
      64'b1001110111011001101000111010010011001000011011001011110110110011,
      1'b0
    };
    control_a = 1'bz;
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
      64'b1000100010100001110111000100011000010000010101101001101010110101,
      64'b1110110010111000000111101101110000011011110000110001010110111111,
      64'b1111111010000011111100000100110110010111110000001110001001110011,
      64'b0100011000011111000010001010110001000100010101000110011001111111,
      64'b0000101111001111011000110001100101101001001000101111101000110100,
      64'b1100100110000101001001010111001111110101100000111100111001100110,
      64'b1111100001011000011001100001000010101011111110010001011110111001,
      64'b1001011010001001101001001101100101010100001000101011100110011011,
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
