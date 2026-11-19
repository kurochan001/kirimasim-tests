/*
:name: random_cross_case_0024
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0024;
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0101010001101101110010010010011000101010111011001100100010001000,
      64'b1000001011100100010011011001100011000000100100101100010001111010,
      64'b0011100001010101001011111001000000101111011001010101100110111100,
      64'b0110010100100011000100101010000100111011010000000101111001101001,
      64'b0111110000110111100000100001011011000110010000101001000101011111,
      64'b0100011000011100011110111010001000101111011100101000001001001010,
      64'b0111101011000100111100100001101011001010000000111111010010111111,
      64'b0101010001111011101001110110011011011010010011100110011110100100
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
      64'b0011100001110110011000001000110001011000110100111100011001010001,
      64'b0000011101111000001101111110011110100010000010010011110001000011,
      64'b1101000001110100100111100110000110111101010100000110111111010011,
      64'b0000001111111000010100011101101101010110000111100010010001101110,
      64'b1111010001010111100010111010111110101010100011111000010010010000,
      64'b1010011110001000100001000100101111001000110001000110110011111101,
      64'b0100100000110110111010110101111010111101100101010000010111010010,
      64'b0100011001110000110100110010011001101001100101011111000010000000
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b1101000001100111110100111001111111101001100101110110011100000011,
      64'b1101101101110110110000100101101111001001011000000110000101000010,
      64'b0000100110101010011101100111110000111101010110101111110100011000,
      64'b1010000111111010100000110001010101100011010110001001111011101000,
      64'b0100001101011011000010101100101111111001101001100101101111100100,
      64'b1110110110000101100100000110111000101101110110011111110011010100,
      64'b1100001000111011010011100101101110001110001111011101000101011010,
      64'b0101111110100111111101111001111011000100000010101110010001111111
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
      64'b1111000010011000010001110000100111100000010010001110101100100110,
      64'b1010010011100011011001000001000101100110011101111010010110000001,
      64'b1011111010111101001111011011010010010110001000001000111110101101,
      64'b1101111000011101110111011100110010110101000010101111111100010110,
      64'b1011010101000011010011000010111001100010111111101101110110001100,
      64'b0001101010111100001110101101111010101110101110001100001011110100,
      64'b1111110100101001001110110001111111001001101110100010001000100010,
      64'b1010111010010100000010111111101110000001011101100100001000100000
    };
    control_a = 1'b1;
    control_b = 1'b0;
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
      64'b1111000010011000010001110000100111100000010010001110101100100110,
      64'b1010010011100011011001000001000101100110011101111010010110000001,
      64'b1011111010111101001111011011010010010110001000001000111110101101,
      64'b1101111000011101110111011100110010110101000010101111111100010110,
      64'b1011010101000011010011000010111001100010111111101101110110001100,
      64'b0001101010111100001110101101111010101110101110001100001011110100,
      64'b1111110100101001001110110001111111001001101110100010001000100010,
      64'b1010111010010100000010111111101110000001011101100100001000100000
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
      64'b1011001110011111111100001111110101011010110010110100101000101110,
      64'b1001111111001010100001000001000011100000010010011110100110100110,
      64'b0101111001010110100100100000011001111011010010101000110011110101,
      64'b0101100111111110001000110101001101110010001000010101100101001001,
      64'b0110111101101111000110110001111100111111010100000101001110010110,
      64'b1111010101110111111110101010111101101110100010010000101110010111,
      64'b1010100100110101000111011110100110111001010011100010001011000000,
      64'b0010000101001011000000010000010111100000110000001100110011101100
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
