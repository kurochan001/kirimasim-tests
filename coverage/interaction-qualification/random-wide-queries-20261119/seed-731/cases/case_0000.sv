/*
:name: random_cross_case_0000
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0000;
  logic unsigned [512:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1110010010111110101110001111101110011100011100111011000101010000,
      64'b1000100111000100110101011110001101000110101000001110011110000100,
      64'b0011101101010100101000100111000010111001101101001000111000000101,
      64'b1000101000101111001110001110001011010111101011101010100100111110,
      64'b0110001010011101111100010101101001100111100100111010010001101001,
      64'b0110001111111011111111100101100010101011100110000010001010011100,
      64'b0101101000001001101111011100111111011011000000011001000110101110,
      64'b0010011011101100110000011011110001110110001010010111111011001001,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'bx;
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
      64'b0110010110101101110001001011101001101010001110100110110100100100,
      64'b1100101001111100010111010001111111010100110111010100000110000110,
      64'b0100101001011110010100101101110111011101010100011111111001101100,
      64'b1010101000010001101000101100101011101010010100001110010100010010,
      64'b1100011000010011011001011011111001101100000100000111001111111011,
      64'b0101001011101010001111101001100110000110000111011010000100101110,
      64'b1111010110111111101001010111000101001010001000100110101001010111,
      64'b0110010100110111001111110100010010111110011100110011111110001110,
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
      64'b0010001010000111100101111101001010001100000111100101001011110010,
      64'b0101101101100100000011001001010101101011001010001101111011010110,
      64'b1101100010101011101110000011001101011000011001010111100001011011,
      64'b0101100111010000010111100100001011101100010101000101001111010000,
      64'b0001010110011101011011000001010110100010000011100011100011001011,
      64'b1000111100001111101110011011011100001110011011010110100110111001,
      64'b0000111000011100001100010101110011010110001000011110000001001101,
      64'b0010000010000000001010001101111001100111011100011011010101101011,
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
      64'b1011101100101111011000010000001100100110011011011011101011110110,
      64'b1110001011111000110001110100111001011100100101111111011100011100,
      64'b0011010010010000010000110010010010110100111010000110001011001011,
      64'b1010111010001000100001110011000110001011110110100111110100000100,
      64'b1101110101100101010100011000001011001101111110001001100010101011,
      64'b0010010110010011011111001000z00110010011100100100000010110011100,
      64'b1000010011000010111100100011111010000111110110011011111111000101,
      64'b1010010100010101000001001011000011111111110100011100110000011101,
      1'b0
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
      64'b1000010001000101111001010101110111100001111001110111010101000000,
      64'b1011001101010011110000101000001000101100101110111110000001010111,
      64'b0111010000010011000111100000000011100100011001001110010000010001,
      64'b1010001011111110000011100101110100100001100101111101110010011101,
      64'b0001010011110011000100101110001011001101000001101000100001100010,
      64'b0001101001011100110101010100010100100100101000100010110101011000,
      64'b1010011110110111001111100101110011010101011101000111001101010110,
      64'b0111101001101110101101100101101101010000011011100110100001111000,
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
    control_a = 1'bx;
    control_b = 1'b1;
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
      64'b1100100100010101110000110010111001110000000101101111010100110111,
      64'b1000111110011011100001101110000101100011111101100011111000101010,
      64'b0011000100100110011001110000111110111101111010001110001100100000,
      64'b1011000001001100110111001010011001111100100011001011100000011110,
      64'b1111010101011111000000000110111010010101110001001111001011100011,
      64'b0101111011101001101010100111100101001100111011100101010011111111,
      64'b0100110100110100000001111101111101001000001011100100100110100111,
      64'b0010111001001011011001110110011011010010100101100100100101110100,
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
