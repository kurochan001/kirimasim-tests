/*
:name: random_cross_case_0035
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0035;
  logic unsigned [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0001100010100111011111010010100101101010100100111011101100001111,
      64'b0001110101111000101100000101110011100000101110011000000001001001,
      64'b0110010011110011001011011101100110010100111110101111011001101110,
      64'b1111001000010101010010001100101011001010000000011000110010011111,
      64'b0011000000100101100001100010111100101010000100101000110101111001,
      64'b0010011110010000101010001001111010111011001100110101111111000010,
      64'b0101011110100101111000111101000010111110010010100011100000101110,
      64'b0011001110000110111011111000101110001010111100111100100001011011,
      1'b0
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b0111110000000101101000010000001010100110110000010100100101101111,
      64'b0011001110001110000111000100100111001100000010100011011111100101,
      64'b0111100011110001011010110000000001010000001101111110101011111001,
      64'b0111100001010110111111001111010111101000101001000000000101101011,
      64'b0110101000111100011001000110101000001110010000001011100100001000,
      64'b0010010111010011001011000000101010001101011110110101101110101101,
      64'b1111011011110111101111101101100011100110001110101000011101011001,
      64'b1111011010001101100001010001111011010111001001011111110001000001,
      1'b0
    };
    control_a = 1'b0;
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
      64'b1001111010011111100111111001000111010101111000001101100110100101,
      64'b0101011111001001000101100101100010100001110111011101101101111000,
      64'b1010000110110011010110000111011001100001001100111010000011010100,
      64'b1101001100100010000010011011010101101010110010011001110010000110,
      64'b1001111010000001001000110101001110000100001101000000111101011001,
      64'b0000101110100010100000100011010110100010011100110011011011110100,
      64'b0000101011110110111101100011110111011010110100111111110000011010,
      64'b0101011000101000100000100001100011100100011100011111010011000110,
      1'b0
    };
    control_a = 1'bz;
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
    control_a = 1'bz;
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
    control_a = 1'bz;
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
      64'b1001110111111110111110111110011001011000110111010011000000111100,
      64'b001011010010100001111111011111x110011011000111100001011010011001,
      64'b1010000001011000001111001011001101101100010000010110000100010110,
      64'b1011100111001011101000111011000011010001110001100001101100000000,
      64'b0011111100111101000010001100101001000000000100100101010111010011,
      64'b1001011100000000100001100111110100011000011110110100001000010001,
      64'b0100000011010011110011001101110101001110101000111010000011111010,
      64'b0000101000010110101111110111101011001001011111101110110001000100,
      1'b1
    };
    control_a = 1'bz;
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
      64'b0110011011011110011000010000000000001111010010010100000001000010,
      64'b1100110011100011010100111000011110001001000101000100101010100111,
      64'b0101001010001101010000001011011010111111010111000011110110111011,
      64'b1111101100111010111111000111110101110011100010010001101101100101,
      64'b0100101111001101100100000111101101110101011010111101110001011001,
      64'b1101101111010110011100000101001000001110011110001000111100100001,
      64'b0011011000011100100100011011110110100010110001011101101000011100,
      64'b0010001001000101000111011111001001010110110011110000101011010000,
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
      64'b0011011110011111010010101011100110110001011010000000100011000110,
      64'b1111010110011001110011001011001110100001110111000101101110110011,
      64'b1010111111001110100110001001011011100011100000110101001001000000,
      64'b0110110001110101101101100001111010100100001001001101010101011101,
      64'b1101000000111011001101011001010010010011010000001100011100111110,
      64'b0110000100001111111000001111001010011000000011100010101111101100,
      64'b1100110001011111001010110011001100010011111110111101110101101111,
      64'b1011001101110010011010101011110011001001010010010110100101110011,
      1'b0
    };
    control_a = 1'bz;
    control_b = 1'bz;
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
