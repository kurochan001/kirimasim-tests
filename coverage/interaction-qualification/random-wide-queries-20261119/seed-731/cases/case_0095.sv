/*
:name: random_cross_case_0095
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0095;
  logic signed [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1010101100000001010110100010010100110010010111101101000100010100,
      64'b0110111011010111011001011001000101011101101000111101011000001010,
      64'b1000000011101110011011010011011010110010101111101101100100001100,
      64'b0001101110101010101101100000101111101111110100101110010101001111,
      64'b1000001101010000011111110110011101000011111111010101001001110110,
      64'b1100101101110111101101000100010011001000001100100000111110011000,
      64'b0111001001110110111000000011110010110001100001110100101111000001,
      64'b0000010101010111111101001010000001110001110100011100001010100111
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1001101011011100011011110110010000111000100010010100101110001101,
      64'b1001011010000011001100100000111100100001100000101000101111000010,
      64'b1000110110011111110010101011001011101010000110110101000101100000,
      64'b0000000010001000110100001110001010010101000000111001000111101101,
      64'b1010101110000110100110110111100010000000100010011010001001011001,
      64'b1000110010110111101010001011101001001100010010001100010110101011,
      64'b1011101111110110000010110101111011101101010010110110101011011000,
      64'b0001000111010001111011010111010010101111010110011000111101110010
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b0110100110000100011100110101001111011110010000011110000000111000,
      64'b0111010110010001100000101111011000111100001001010000101111111001,
      64'b1110010110011011111100000100001100101100001100110101110110010100,
      64'b1110011001110110111101110001111001010011110011010110010101101111,
      64'b0001101110010011011010001100010000000011101011111001010110100000,
      64'b1001111111010000100101010100001110101000100000111110000110111001,
      64'b1100001111011110100011010010111100100111101000010010101100101001,
      64'b0010111001011110101000110001010000101101111111001011000011001101
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b0110100110000100011100110101001111011110010000011110000000111000,
      64'b0111010110010001100000101111011000111100001001010000101111111001,
      64'b1110010110011011111100000100001100101100001100110101110110010100,
      64'b1110011001110110111101110001111001010011110011010110010101101111,
      64'b0001101110010011011010001100010000000011101011111001010110100000,
      64'b1001111111010000100101010100001110101000100000111110000110111001,
      64'b1100001111011110100011010010111100100111101000010010101100101001,
      64'b0010111001011110101000110001010000101101111111001011000011001101
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
      64'b0110100110000100011100110101001111011110010000011110000000111000,
      64'b0111010110010001100000101111011000111100001001010000101111111001,
      64'b1110010110011011111100000100001100101100001100110101110110010100,
      64'b1110011001110110111101110001111001010011110011010110010101101111,
      64'b0001101110010011011010001100010000000011101011111001010110100000,
      64'b1001111111010000100101010100001110101000100000111110000110111001,
      64'b1100001111011110100011010010111100100111101000010010101100101001,
      64'b0010111001011110101000110001010000101101111111001011000011001101
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
      64'b1100100100101001100010101110111111011100011011001100111100000110,
      64'b1101001111110001010101100100001110110010011000001010001100001001,
      64'b0001000100101100011111100011001101010111100011111110101111000010,
      64'b0001011000000000000000101101010011111010001010001100101101000001,
      64'b1010100001110101111110010100101100001111011010101001110101001100,
      64'b1100110110110100111010100110011001111000110001101111111001011101,
      64'b0001110100100100110011111101111111001110101001011111100001101111,
      64'b0010101110110111001000111000111111011111000100110100101001000000
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
      64'b1101100110000100001001011001111000110111110011001010000001101111,
      64'b0001101010010101001011110111110011101001000011111101111001100010,
      64'b1001011100101100100100111100010111111110100111001101010010100010,
      64'b1011010000011001011110010001000011010001011010110100100100000110,
      64'b0111011000111000001000010000111001110111011001111101100100001011,
      64'b1101110110100001111101010011010000101011001001110100100101000101,
      64'b1001011000111011110011000010110100001110000000101000000010100000,
      64'b0101110101101101000110101101101001010101111111101010110011110000
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
      64'b1011100111110010010011110011100111000101100101100101100110011000,
      64'b1011001111111010100001111110100110010110110010100001100101110011,
      64'b0000000111010011110110111001000000101110000101010010100000110011,
      64'b1011001111101111101001000000010010111110100011011000010111110010,
      64'b1110111111100011101111111000101010010010110110101010101110110110,
      64'b0111011111101010101010011000001010011101110111001001001010001111,
      64'b1011110000001111101011111100001100110010101111010111100100111110,
      64'b1000010010011110001110100010111000110001110110110111101001110001
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
