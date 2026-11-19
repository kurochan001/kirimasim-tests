/*
:name: random_cross_case_0059
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0059;
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1001101011110011100011100100110001000111111000111001101011110111,
      64'b0011111011011110101111011100111110011100100111111101011001010111,
      64'b0111001001110101000110001000010010111111101011110001001011001010,
      64'b1111110010111001100011110010101101011100001010101010000011011111,
      64'b0001100101010101110010110000101000100010110011101111101001110110,
      64'b0110010011001001100000110001111010111000110011010011000111100110,
      64'b1111111010100101110100010110110011111000010001000101010011001011,
      64'b1111010001001001101010101111111110011010110100010100110101111101
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b1101111011010000101100001101000110101001010101011001110100000111,
      64'b0000110001111001001100101101011100010011001100100111111000110001,
      64'b0000110100101000010100101101000101110000001101000100001101100010,
      64'b0010111110011010000111000010000001101101111110101100100000100101,
      64'b1100111011000110111001010000000011100001111011110010111110011001,
      64'b1011001111011100010010000011011000110001001110100011111001111010,
      64'b0001000111110111001011011110111110100011110010100011101101011101,
      64'b0110010100001111000011000110100111111001010011110110110100100000
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
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
      64'b0000110110001000011111111010111000100100001111100111101101100001,
      64'b1001000011111001010110111100010111001010000100000001111110101010,
      64'b1100011010010111111110111001101111010010010101110000100100100001,
      64'b0101001100101111101111111101011000010110001001110001010011011010,
      64'b0100101100101110000010110110110101111111000011000000110001101111,
      64'b0110000010101001111000010100001001000000010001110110010101010000,
      64'b0101001110100100001110101111100011000001101011111011111011001111,
      64'b0000100001100100011111001011111000001011001011010001101100111010
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
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
      64'b1100101001100111011110010010111001010011101011111100101100101010,
      64'b0110011010001110101011110001101111100011011000001011010111110000,
      64'b1001110011100111111101101011000001111000010101010001000001011110,
      64'b1011001011111010000100110011001000011001001100000000101000110100,
      64'b1011001100101001111011111111111011000010001011011111001100110011,
      64'b0110001101010001101100100001011101011101110100100001001111000011,
      64'b1101110000001001000011011011011010111101000101010010110000010100,
      64'b0011100100011100111111001010101001101110000001010011010110011111
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
      64'b1010101011000000101011000010111010000111110010111000001011110001,
      64'b0000000011001001001111010111100110011111011000010000110101100001,
      64'b0001000101001010110100001110011011000001010111011000100001111010,
      64'b1010010001000101111101011111011101001110110001111100111100000111,
      64'b0001000011010101010001100001000000001001011011101111110000010110,
      64'b1111011011101111100000101011001100110010000011101011011110100001,
      64'b1011101100011000011011001111001110011111110000100101100011001011,
      64'b1000110001000010000110111100010000110110111100110100001111001100
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
      64'b1010101011000000101011000010111010000111110010111000001011110001,
      64'b0000000011001001001111010111100110011111011000010000110101100001,
      64'b0001000101001010110100001110011011000001010111011000100001111010,
      64'b1010010001000101111101011111011101001110110001111100111100000111,
      64'b0001000011010101010001100001000000001001011011101111110000010110,
      64'b1111011011101111100000101011001100110010000011101011011110100001,
      64'b1011101100011000011011001111001110011111110000100101100011001011,
      64'b1000110001000010000110111100010000110110111100110100001111001100
    };
    control_a = 1'b1;
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
