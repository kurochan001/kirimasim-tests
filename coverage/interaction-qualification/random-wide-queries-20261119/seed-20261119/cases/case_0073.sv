/*
:name: random_cross_case_0073
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0073;
  logic signed [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0000101011000100111001110100001101101111101010111110100011001100,
      64'b0000011101000110101110011110011000000110000110100011011100110011,
      64'b1101000100010100001001000001111011010000010100111101100111101100,
      64'b1110111101101111011110010010101101110110110111110011111111111010,
      64'b1010111100000111001011111001100111010111010111011111001110111010,
      64'b1010111100111100001000010101101100000001111110000101000010000001,
      64'b0101111011011000101100010111100101001101010111110011011101101011,
      63'b010011000111110101000100011100011000011110101001010110001001101
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
      64'b1000110110010000000110110101100011010101101111000011100101011010,
      64'b0110111111111110101110111011001000010001111101000000111101110110,
      64'b0001010000001111000101000010111001111111011010111111100010011010,
      64'b1001100001000010101110000011010000100000111110001110000110011111,
      64'b0000100110011001010110111011111011101111111000010100010000100111,
      64'b1010110011101011000101001111101011111010010101001011010110001011,
      64'b1111001101100010010100111111001100111100000001111101100100011110,
      63'b010000001010110101001010100111001111110101100100100101101000100
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
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
      64'b0100011011101010101100100000000011110100101000110000011111001100,
      64'b1111110010000101010111101001001101111001010000001110001100111000,
      64'b0110100100010001111110011000010001010000001111110100100101000000,
      64'b1010010000011001010100101010011001110110111011000010010011010001,
      64'b0101010000000110011001010110111100010010000011101101101110111111,
      64'b0100010000101110101010111111100011000101100100111001110100111100,
      64'b1010101110101011110010111011110100000110011111101011001010111110,
      63'b010110110101100100111110101100111011001110111101101111111000000
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
      64'b0100011011101010101100100000000011110100101000110000011111001100,
      64'b1111110010000101010111101001001101111001010000001110001100111000,
      64'b0110100100010001111110011000010001010000001111110100100101000000,
      64'b1010010000011001010100101010011001110110111011000010010011010001,
      64'b0101010000000110011001010110111100010010000011101101101110111111,
      64'b0100010000101110101010111111100011000101100100111001110100111100,
      64'b1010101110101011110010111011110100000110011111101011001010111110,
      63'b010110110101100100111110101100111011001110111101101111111000000
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b0111110001110111000110011111111010100010101110100101111110101000,
      64'b0110011010000011101111100000101001000010001000111001000111011011,
      64'b1110100000001001001111110010100010000001001111011010000101011000,
      64'b0100010100110011010010110101111011111111101101100111001111100001,
      64'b1010010101000000000110110111011010101101000001100011001010010000,
      64'b0000101101101000111010101111001101110011010000111100011011110101,
      64'b1101000101100001101001000101001001101111000010001010010011000100,
      63'b110011000101111000110101001011011110000000011011001001110001011
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
      64'b0110111110010101001101000001010100111111001010100011000011011110,
      64'b0011001110000111010100001101000000000000101100000001100101110110,
      64'b0011001111010010100011100101100101111111000011111001010000011000,
      64'b1011110011010000110110101011001001111101000101101010011011110101,
      64'b1100111101010100001001101111111001010001111101000011010111101000,
      64'b1101011000110111001010011111100111011110011101000001111100100100,
      64'b0001011111111001011011001011000100101101101010100011100111000000,
      63'b110001010001111111111010011100110100111111001011110010110011100
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
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
