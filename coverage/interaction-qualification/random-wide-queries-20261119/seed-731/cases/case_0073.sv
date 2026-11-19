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
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1110101000000110110001001010000110011101010010001011110100100001,
      64'b1101000101000010011000001001011111010111110101010100110111110001,
      64'b0011101010111100100011001111100100010000011100101110100010110011,
      64'b1100001110010111100111010010010101110101001001111100111100100110,
      64'b1000001000000000010101100101111101110100110000110110101100011010,
      64'b1100000110101101010111010011010000111101110110010110001110110011,
      64'b0011110100101111011101011111011010001111011010001101010010100111,
      64'b1111010001010010010110100100010101111011101101110000011011100110
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
      64'b1110101000000110110001001010000110011101010010001011110100100001,
      64'b1101000101000010011000001001011111010111110101010100110111110001,
      64'b0011101010111100100011001111100100010000011100101110100010110011,
      64'b1100001110010111100111010010010101110101001001111100111100100110,
      64'b1000001000000000010101100101111101110100110000110110101100011010,
      64'b1100000110101101010111010011010000111101110110010110001110110011,
      64'b0011110100101111011101011111011010001111011010001101010010100111,
      64'b1111010001010010010110100100010101111011101101110000011011100110
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
      64'b0000011000110101010101110011110100001010101000111011100101000110,
      64'b1100001111001011001001100101111010110101101001111011010001101111,
      64'b1001101010010010111101101011011000101100000100010111000000101101,
      64'b0010001010010101000111011110100111000010111010110010000010001101,
      64'b1010011011001101111010111101000100011011100010000101100101111000,
      64'b0001110101010000000000111000000000010010010010101100100011011111,
      64'b0101100011000000111111101101110110100011010100010010000010010011,
      64'b1001111110001101110101100001000111001100011101011001001000001111
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
      64'b0110001011111001101111011010101011100100111110110011011001000011,
      64'b1100001011001100000100101110011111001110000000001111111001000101,
      64'b0011010011111101110100110110010001111100010111101111001011000100,
      64'b1100111000110010001000101101001010111100101100010000010001010110,
      64'b0110011010101110100011001100110111010101011011011000011000110001,
      64'b1001110001011001000000011000010100011100110100110100001110111111,
      64'b0000011001011100011101001110100110110010100011100011001111100011,
      64'b0000110111001101100010010100110100010110000011100011010001111110
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
      64'b0110001011111001101111011010101011100100111110110011011001000011,
      64'b1100001011001100000100101110011111001110000000001111111001000101,
      64'b0011010011111101110100110110010001111100010111101111001011000100,
      64'b1100111000110010001000101101001010111100101100010000010001010110,
      64'b0110011010101110100011001100110111010101011011011000011000110001,
      64'b1001110001011001000000011000010100011100110100110100001110111111,
      64'b0000011001011100011101001110100110110010100011100011001111100011,
      64'b0000110111001101100010010100110100010110000011100011010001111110
    };
    control_a = 1'b0;
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
      64'b0110000101110101111000011110011000010011111001011010101110000010,
      64'b0010111000011000001110100010000000010101100110111001010110111110,
      64'b1001010100110111010100011011011110101000011000011010110000100011,
      64'b1101111101011001011111000101001101101010101001110010000010100101,
      64'b0110010001101000011100100110011101101110000010110110110100010010,
      64'b0011111100100111011100101100011001011011010100010000001000001111,
      64'b1110110100011010001100000111100111001110010111110101100110100011,
      64'b0101111100101000001000101011000111010000111010010001101001110000
    };
    control_a = 1'b0;
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
      64'b0110000101110101111000011110011000010011111001011010101110000010,
      64'b0010111000011000001110100010000000010101100110111001010110111110,
      64'b1001010100110111010100011011011110101000011000011010110000100011,
      64'b1101111101011001011111000101001101101010101001110010000010100101,
      64'b0110010001101000011100100110011101101110000010110110110100010010,
      64'b0011111100100111011100101100011001011011010100010000001000001111,
      64'b1110110100011010001100000111100111001110010111110101100110100011,
      64'b0101111100101000001000101011000111010000111010010001101001110000
    };
    control_a = 1'b0;
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
      64'b0110000101110101111000011110011000010011111001011010101110000010,
      64'b0010111000011000001110100010000000010101100110111001010110111110,
      64'b1001010100110111010100011011011110101000011000011010110000100011,
      64'b1101111101011001011111000101001101101010101001110010000010100101,
      64'b0110010001101000011100100110011101101110000010110110110100010010,
      64'b0011111100100111011100101100011001011011010100010000001000001111,
      64'b1110110100011010001100000111100111001110010111110101100110100011,
      64'b0101111100101000001000101011000111010000111010010001101001110000
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
