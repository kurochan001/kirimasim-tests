/*
:name: random_cross_case_0021
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0021;
  logic unsigned [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1101100111100010001000110111101000100110101110111000101011111011,
      64'b1110100101101000100000100101101110100110011011111001010111000000,
      64'b0000100101011010110000101101100001011111111000011101111101011010,
      64'b1000111010000110000011001100110111001100100101100110010101100010,
      64'b0001011111011110101111110110010100000101011001001010000110010100,
      64'b0000010000000110000000011011010111110110011011011011001001111010,
      64'b0001101001000010011010100000000100001001000001111000000111101011,
      64'b0100000000010001100101011100000011101011100001110100011101101100
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
      64'b1111001011000011101010101111000110111101101110001111110001001001,
      64'b1000110000011011111011111001010001010110111001101101001011100011,
      64'b1100011110010101010111010111000101011100111000100001000100010010,
      64'b0111001101011111100000110100101101001101011110000111001000110000,
      64'b1000010001010011110011110110111100011011001001000001000000111101,
      64'b0110010010110001110110001011000001100100001110001000100010000111,
      64'b0010111101011001111000011010111111000001110001100111001101010110,
      64'b1101001011111100001110101000110001100101000010011101001011100110
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b000000000000000000000000000000000x000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b000000000000000000000000000000000x000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b0001000110100000010100000010111010101100101110010001100111000100,
      64'b1101101001110110000110001000101111101000001110111100111011000010,
      64'b1110100011111001010101111000110100010001111101110101011100101111,
      64'b1100001100101101011011001100111011110010101110101101010010001100,
      64'b1000110101000010100011101100010011001001101111101111011001110000,
      64'b1010011100101111011001101101101010000010101000110101111011110000,
      64'b1010110000101011011000100100000001010011100000101101100010000100,
      64'b1111010111011110110100011000111110110011101000110101000010010111
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
      64'b0110100111001000101010010111000110001010000111100000110011000101,
      64'b0011100010000000111000111001110110101101111001001101111100011010,
      64'b1011001010011110011111001010000101100110000101110000110111110010,
      64'b0100101110101110100000100010010000000110010110011111000111010100,
      64'b1001011000110100100111000110001011110101111111101101001101110101,
      64'b0000110101101100011111111111010001101100101011001000001101001111,
      64'b10001010001100010101111011001x0101011000001101101010101100101111,
      64'b1111101001010100100101010100010111010111000011000010001111111111
    };
    control_a = 1'bx;
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
      64'b0110000101111111000001111110101111100110100010110011001001000111,
      64'b1011000010100011000001111100011000011100011100101101110100010010,
      64'b0000001110100111001000001011101011010000100011100100100100100001,
      64'b0000001111110011000100011010100101101011010001111100000010111011,
      64'b0001111101110011110100110000011110110110101001110100101101110011,
      64'b0001001111001001101101011010010110001000111010010110110111110000,
      64'b1110000010111111010010111111101011111011000001010101101000000110,
      64'b0001111001011000000000011101001110000001001111011110110010111010
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
      64'b1111001010000111101101111001100011100001000100111001110011000100,
      64'b0001011110110010100101101001011110101000011111001100011001001110,
      64'b1100110101101000010011110100010100100000101110010111010010001000,
      64'b0101011000000010001000111011001000011000000010011111000001000111,
      64'b1001011101001010111110101100001111110110010110011011000101111000,
      64'b1000100100110000100101011001111101000011100101011101111111000000,
      64'b0100011001001001011100100000111101001101011001010011100011010000,
      64'b0110110101011000101110010111101100111110001101011110100111110101
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
