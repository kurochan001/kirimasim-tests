/*
:name: random_cross_case_0037
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0037;
  logic unsigned [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0010011101101111010001000111101101000001000011101100010000001110,
      64'b1111010101010001001000101001100010110010101101110101110111100001,
      64'b1111001000000101110011000011000000110111111000100100011000110000,
      64'b1110111111010010110010110111110010011010100110110010110000001001,
      64'b0001100110100011100110011111000110000110110110011101010100000111,
      64'b1101011000000111111000011001001000011100111101101111111000101000,
      64'b1110110110001100101000000100111011101100011001101110011011100001,
      64'b0111111000000001110011111100110000011101000001111110111010101100
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
      64'b1000100010110100000000010101111000110110001110001110000010110110,
      64'b0000110111100001100010101110100110111101111011000111000100011111,
      64'b0100011011111111011001011101010110010111101111011001010110011111,
      64'b1100110110010110100110010100111001001011000011101011011000001011,
      64'b1000001101010001001111110000010001100000000100001000010111111110,
      64'b0011010110100010111010001000011110010101111100100101100100000010,
      64'b0110110111100100100010100110001100000100100110111010101110010111,
      64'b1110101100000010010101011100010110010011001111001110010011100101
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
      64'b1110000010100111111110110101001010100001101100001110010011010010,
      64'b0011001011101100101010000000110110111101111001111110011101101010,
      64'b0010110110001111001001011000110100101001100000111011001111110111,
      64'b0001001100010111010000011111000011110011111001100001000110010010,
      64'b0100001001011110111011111011101110000111010100110010011011001110,
      64'b1110100101111100101111100010000000000011000000110111011001010110,
      64'b0100000101010000100001010000101010110001101110110110100110111101,
      64'b0011111110110001011010111001100111000011010101100100001010010101
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
      64'b1110000010100111111110110101001010100001101100001110010011010010,
      64'b0011001011101100101010000000110110111101111001111110011101101010,
      64'b0010110110001111001001011000110100101001100000111011001111110111,
      64'b0001001100010111010000011111000011110011111001100001000110010010,
      64'b0100001001011110111011111011101110000111010100110010011011001110,
      64'b1110100101111100101111100010000000000011000000110111011001010110,
      64'b0100000101010000100001010000101010110001101110110110100110111101,
      64'b0011111110110001011010111001100111000011010101100100001010010101
    };
    control_a = 1'bz;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b1001010011z11001101010010101101010010110000111111010011111111000,
      64'b1011000111100001101011101101010001010010000001001101001000101100,
      64'b1101011010000111101110011001000100000010100001101100000111100100,
      64'b110100010010111100101110100001001011101011111100100110011z111111,
      64'b1100011110110000110001110010101010100110001010010010000011010111,
      64'b1111000000110101111100000000000010110010011110101110110100110001,
      64'b110011100111100000011101001001001001000x001011010011011110011001,
      64'b1011100000100101001101000110010001100001101001100011011010110010
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
      64'b0110011000101100110111000100011111001100011000110011101011100000,
      64'b0001010100001010010001100100010010011101110011000101010110111111,
      64'b1110011100000001001001110010001011110011101100110000010011100010,
      64'b0011001101111010001101111111100010000010000110101011001100100111,
      64'b1011100100100011101110001010110110000100100101011110001010001100,
      64'b1111011111000111010100010011001010111011100011101110111111111101,
      64'b0111000011110110100110110101110111001001001000101000011110101001,
      64'b1100111000101101111010100001010110000101011101101001000001010100
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b000000000000000000000000000000000000000z0000000000z0000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b000000000000000000000000000000000000000000000000000x000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b000000000000000000000000000000000000000z0000000000z0000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b000000000000000000000000000000000000000000000000000x000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
