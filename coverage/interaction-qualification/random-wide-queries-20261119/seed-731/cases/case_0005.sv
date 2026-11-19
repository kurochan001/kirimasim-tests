/*
:name: random_cross_case_0005
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0005;
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1000111001110110000111101011001101011001100100001101011100111011,
      64'b1111001100010011001100101010011001101001010000100000100100010010,
      64'b1001110011111101010000110010100100101000100101010100110111010100,
      64'b0101000011100000100011011010001011001101011111110110111100010100,
      64'b0011011110001010010011111000100010011001001001001101011011110100,
      64'b0111110111111100000011010110110000011110011001111110000111011111,
      64'b0101111001001000001111110101000010100110010100001110110111111001,
      64'b0110000100111000010001001000001010000111111001101110011001101010,
      1'b0
    };
    control_a = 1'b1;
    control_b = 1'b0;
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
      64'b1000111001110110000111101011001101011001100100001101011100111011,
      64'b1111001100010011001100101010011001101001010000100000100100010010,
      64'b1001110011111101010000110010100100101000100101010100110111010100,
      64'b0101000011100000100011011010001011001101011111110110111100010100,
      64'b0011011110001010010011111000100010011001001001001101011011110100,
      64'b0111110111111100000011010110110000011110011001111110000111011111,
      64'b0101111001001000001111110101000010100110010100001110110111111001,
      64'b0110000100111000010001001000001010000111111001101110011001101010,
      1'b0
    };
    control_a = 1'b1;
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
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
      64'b0111100111100011001101100001100000110111101000100010110111100100,
      64'b1000101100111011100011100000110111100100101110000100100101011000,
      64'b0011111000011100111111001100011101001001110001101110000011111001,
      64'b1101111101011101011111100111110110000111110110111001110111011000,
      64'b0110110100011010110001010110001010111110111011000001000100001011,
      64'b0001100001101110011101100001110100011010011111101001110111110010,
      64'b0001011010110111111111001001110111011111100000001000001100101011,
      64'b0010001000010000000110010100000011001010000000000010111000001100,
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
      64'b0111100111100011001101100001100000110111101000100010110111100100,
      64'b1000101100111011100011100000110111100100101110000100100101011000,
      64'b0011111000011100111111001100011101001001110001101110000011111001,
      64'b1101111101011101011111100111110110000111110110111001110111011000,
      64'b0110110100011010110001010110001010111110111011000001000100001011,
      64'b0001100001101110011101100001110100011010011111101001110111110010,
      64'b0001011010110111111111001001110111011111100000001000001100101011,
      64'b0010001000010000000110010100000011001010000000000010111000001100,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1100000001101010001111010101010010100101110100111001010011101010,
      64'b0000100111100110001110000001001011101001010110011011110110111010,
      64'b1011010111100000011001001110100100011000110110101100000100111100,
      64'b0000110001101000011011011100110010011101100000001000110011000011,
      64'b0000001111111000111111100000001011001100100001001100110101110011,
      64'b0100000001011111111101001110000110000011111010011110101010100101,
      64'b1000001110110010100011100010000010111001000110110101100000011001,
      64'b0010010101000001011110101001000100010001011011101100011101011101,
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
      64'b1000010000111111101000111000011110001100110000001100110011111101,
      64'b0011110110100011101110011100101111011000110000100011010111001100,
      64'b1001010000010011000010110011111110000101001101000011010000011001,
      64'b1101010101000110000011001100011110011010000110111000001010001110,
      64'b0000101101011101101101101100001100101110010000111010000101000110,
      64'b1001000011110100100100110010100101001101111010010000011110010100,
      64'b1111001110111110011101000001000100000000010010001000011111100110,
      64'b0001011101000010000101000000111000000011000110011100010010010100,
      1'b0
    };
    control_a = 1'b0;
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
