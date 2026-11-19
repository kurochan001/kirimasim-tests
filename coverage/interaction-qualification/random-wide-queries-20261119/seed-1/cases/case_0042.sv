/*
:name: random_cross_case_0042
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0042;
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1101011001100111001110101110111010111101001110011101110011000100,
      64'b1111001010011011001010111111101101110110010010110000001000110111,
      64'b1011110000101010110101010101101110000100001100111000010101011100,
      64'b0100100110110111000000100111111010001100101000010000100010010111,
      64'b0010100011001000111110001000010001101111101100000100010010100101,
      64'b0000000111101110001101111100101000011000100101101001011101000010,
      64'b0111000001100000011101101000100111110101111100011100100000110111,
      64'b0011100011011100111000011111100011001011000001111000010100110010
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
      64'b0001101100001110100100001010010100001110001001100101001100001101,
      64'b1110010100110000110110110101100010001111010000110011010101010000,
      64'b0101101100000000110110110000001101100010010100000010101001001101,
      64'b1000111000110100000111100010000011001001111000100000000101000100,
      64'b0000110100100101110001011101111101111011110111100101100101010100,
      64'b0001111001011011010111111100010110001111110100000000111101101100,
      64'b0001111001001001101010111110111110100101001010101101110111010011,
      64'b1111001010101000011101110001101100011101011010100001100100111010
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
      64'b1101011001010100100000010010010100010100110100110010110011010001,
      64'b1010010110010101100110001111101111101110100001011011001011101011,
      64'b0001111101001111110001111011000110010111111011101001011111110011,
      64'b1100100110110001110111111110001100011101000001010100110100110111,
      64'b1101100101000010111000110010011110001000000011101101100111001111,
      64'b0100100111000101111100111001111100100000011100001000100000011001,
      64'b0000110000111101111111100101001001110101010011010000010110010111,
      64'b0100111110000010011000110111001011010010010011001011110111110111
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
      64'b1100000001100010110110011010011001001011001011000111001110111111,
      64'b1110110101100000010100011010100001101010001001011101101110100101,
      64'b1100001110101110101110011101011011101011000010101000100111001010,
      64'b1000000111111111110010000010010110011011100011100010100001110111,
      64'b1101010100010111110110001011001010110100011110111001100011001010,
      64'b1010011000100101110100110111111010110111101011111011011100101110,
      64'b0111111111010000111000001100010101111110000110100010101010001110,
      64'b1001001101101000111101010001100010110011011101001100011001010101
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
      64'b1100000001100010110110011010011001001011001011000111001110111111,
      64'b1110110101100000010100011010100001101010001001011101101110100101,
      64'b1100001110101110101110011101011011101011000010101000100111001010,
      64'b1000000111111111110010000010010110011011100011100010100001110111,
      64'b1101010100010111110110001011001010110100011110111001100011001010,
      64'b1010011000100101110100110111111010110111101011111011011100101110,
      64'b0111111111010000111000001100010101111110000110100010101010001110,
      64'b1001001101101000111101010001100010110011011101001100011001010101
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
      64'b0110101111110111001100000011101011000010101010100011111100110000,
      64'b0011011010010110000110100111000011011000010111001011111111011100,
      64'b0010101100010001100100000110110101101000010001010110011111100011,
      64'b0010101110100101100111111001100100101010101010001101111110000010,
      64'b1010100011001101010000010011101000010111000110011110000101011110,
      64'b1000011111011001001011110010101100101111001100110011000100101001,
      64'b1101001001110101010100001010110011101010000101110111110011111111,
      64'b0001010111000000011011101101000100100101001101011010100010100011
    };
    control_a = 1'b0;
    control_b = 1'b1;
    control_c = 1'b0;
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
      64'b0100101011011110111011010001011110100001110100011111100000001001,
      64'b0010101110110000001011011100111100111011000111011101000001011100,
      64'b1011100111101000101101000000010110111111111010101110111000011010,
      64'b1100000011111000011011101000110011000110001111100011010111110010,
      64'b0000001011101101100010011110011111101110000010000011110001110001,
      64'b1101010110100000000111001100111011000011010010011001011110000100,
      64'b1011111010001001000111100001101001010100000010101111100101110001,
      64'b0110101000100001011100001000000111101111111011001101110100110101
    };
    control_a = 1'b0;
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
