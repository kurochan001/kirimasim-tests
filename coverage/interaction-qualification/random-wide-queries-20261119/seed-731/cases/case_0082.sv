/*
:name: random_cross_case_0082
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0082;
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1100001011110001110111110000001011100000001000101100001011000101,
      64'b1100111011101010000110111010101001111101101011010001001110011101,
      64'b0000101011110101010000010110010001111011111010001110110101111110,
      64'b1011010100100100101001111100100101110001010101100000100001111100,
      64'b0011000100011010101110101000011101101010101101000111011101100011,
      64'b0101000111101101100111110010000011000111111001110010010100110100,
      64'b1000101101011101110100101001000101111001110110010100010011011101,
      64'b1110101111000101101110000100000011101100011111111110101011100100,
      1'b0
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000z00000000000000000000000000000000000000000000000000,
      1'b1
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
      64'b1000100100010101000001011011011111100100110000100001100001110000,
      64'b1001100001110000111001110000011111010101100110100001001011110111,
      64'b0000100110010110111000010000011100101111111110101100001110100101,
      64'b0000001101110010100100111001100100100100100010101111001000011111,
      64'b0000010000110010010101010011010110101110010010111101110100111101,
      64'b0001000110100000110001001001010111000111111111100111111110101001,
      64'b0010100000111101111000011100000010011001111000011110011101101111,
      64'b0111001011100101001111110100011000110000110010101010111010110110,
      1'b1
    };
    control_a = 1'bx;
    control_b = 1'b0;
    control_c = 1'bx;
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
      64'b0000011110000111010110001110110001110011101011011010000100010000,
      64'b0111111101x10101111001101101001011000100101011010010110101001111,
      64'b010100000000001111011011000x110010000010111111110000011110010101,
      64'b1010011011000110000110101110011100000111110010100111100110011001,
      64'b1010010011111110010111010111001101100101001111111000011001001111,
      64'b0001110001101011101000100000011100100110111011110001010010100101,
      64'b1111110100101000010101001011100010111001100110111101101111110100,
      64'b0000000110101000001001111001101101011100010110001110010100001100,
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
      64'b0010101000111101001011011011001000001111110001000111000011100111,
      64'b0011001101110011000000000010100010101000111111101101100011001001,
      64'b1000100110011010100000011001111000001101111111010110110110010001,
      64'b0000111110000000000101111100101111011100011011011000001000011000,
      64'b0010001011110111110111110000001100101000010100011111001000010010,
      64'b0011111000110110001101000111101010010101000101100010001001101101,
      64'b0100111011111110101001101101001110100110010010101101111011110101,
      64'b0011010010000101111001010000011011011101100110101011010000100100,
      1'b1
    };
    control_a = 1'bx;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b0001001111111100101000101100010101100001011101011101001010101001,
      64'b1100001100111111011000011101000010100001100111001111100101110001,
      64'b1111100110000001011101010111101010110110111100110111101010100010,
      64'b0100100011111101000011110010110011000101111001101001110110000000,
      64'b0010101011100000001000101010111100011111010100111111111011000001,
      64'b1101111101101010110001100110011101110101000011010100011000111110,
      64'b10011010110011100000011001x11011z0001011111101101100001010001001,
      64'b0010101110000010010010111101101101001111001100100101100110000110,
      1'b1
    };
    control_a = 1'b0;
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
      64'b0010110001011101111001010111000000001001000111011011110111000000,
      64'b0011001101100010001010011110000101111011010001011110011101100100,
      64'b1001100000100111011001000000001111111001100111101000010110111111,
      64'b1011011101011101110101101001001000110010101010111000001110101011,
      64'b1101010101011000110011010000010000010111100110101011101100110110,
      64'b0000001110001100010000110111000001111000001100001000001111000110,
      64'b1111000011000100011011011111011100000000000010100011010100110010,
      64'b1111011000100111000111101000101110111110001110010000011100111101,
      1'b0
    };
    control_a = 1'bz;
    control_b = 1'bx;
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
      64'b0111001001000101011000010010010111000000101011101100111010100100,
      64'b0010001100011011110000111100100010100001100001011011011000000101,
      64'b110011100z010001011110011001001011110110010000101110000101110101,
      64'b0111001000100001100001101110101001100001110011000010111101101011,
      64'b1000011011010001011001000010110111000101100100110110011000010001,
      64'b0110000010010110110100000101010101010101100111110011011011111011,
      64'b0110110101111011010111011000011101000001000100110110100000010001,
      64'b100010101010011101111111101000110001111111100001000010111111001x,
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
