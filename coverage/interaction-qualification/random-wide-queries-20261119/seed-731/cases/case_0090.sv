/*
:name: random_cross_case_0090
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0090;
  logic signed [510:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0011011011111101101110001010001111001001000010010101010101000110,
      64'b0011011100111000111010101111010011101000011001100100101001011001,
      64'b1001101001010100010111110001110101010111000100100101000100100000,
      64'b1001010000101111011101000101011010000100100100100110001110010001,
      64'b1000101111010110111010000011110001100111101101101100010011011110,
      64'b11000101101010110100011110000111111101011100001010110x0001000010,
      64'b0110010100110101110010100110110000110101101111100100010011100010,
      63'b000101100000100001011000000101011000010001000011010100111001011
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
      64'b1101111100010100101001011010101000100001011000100101010010000000,
      64'b1011011000001111010000110111010111010011001010110110010100011010,
      64'b000111111011001101100011111011110011001110011000x111001001101110,
      64'b0111000101000010100100100111010101000100011111100011001010001110,
      64'b1101111110001010000100101011001111011101011111011011000000011101,
      64'b0001010001001110001000111010110110010011000011100001011111001011,
      64'b1111111111010100001001001010001110101101110000110011001111011010,
      63'b010000101001110011110110101010001111101101101110011100111010101
    };
    control_a = 1'b1;
    control_b = 1'b0;
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
      64'b1010000011010110111010100000000110010011111011100001001001000100,
      64'b0111011100110011100000100001110010001000011001010111101001000011,
      64'b1000011100101100101101010001011010111010001001110000111101001010,
      64'b0010000010000001000110110110011010101010001100011001110100101010,
      64'b1001011010110001110010111111101000010110110100011100101101101000,
      64'b0100110100110100110001111000100000100001001101110110010100100011,
      64'b0001001110010100101001011010100000101111100001010011000101100100,
      63'b010110000010001111000010100111011101110110101100101110000011101
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
      64'b1100010110011111101011101110111000101110110110000110101111101110,
      64'b0110010111101101000010000011000001001000001001011111110000001110,
      64'b1000011001001100111100110001000001000001100001010000011110100000,
      64'b1001100111100001000101001011100100100000011111011010101111010110,
      64'b0000010000101011110010011101111111111000101000001101111110010011,
      64'b0001000011011000000111110111110101101010011000111011100101111101,
      64'b0101000100011000110000001101101110001110101001101010100101111000,
      63'b011101011000001011100100000111101001110100101101110010001100111
    };
    control_a = 1'bz;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b1001000001101010111010110111111001010011111100101111100100100001,
      64'b0011100100110001100010110001001011001101010111010100011011110100,
      64'b1011110011011100000011000110110010011011001001111000101101111011,
      64'b1101111101111100000101110000110110000010010000101110111110111111,
      64'b1011010111111111010000000000000000111000001100100010110101001000,
      64'b1101111010110001110101110110100110110000111100101001100100111101,
      64'b1111001000111100101010100000111010100101111101011011100000110110,
      63'b110100001101010111001111110011001010000000111100101101011000001
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b1010111011110011101110101000000010011011010110010011111000001010,
      64'b1010011011111000010011100101001011001101100011100001000001001111,
      64'b0001100111000011001100010100101010010001111010011110110000010110,
      64'b0011011011010100000110110110011110000001100100010010001000010011,
      64'b1110110101010110011101101110100101000010001101011001110111111001,
      64'b1000110110001110110000110011011001000011000001110101011001100100,
      64'b0001101100001001010010110100011010001011111111111010110100001110,
      63'b010111111110100101001111100001000011100110101110010111110001100
    };
    control_a = 1'bx;
    control_b = 1'bx;
    control_c = 1'bx;
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
      64'b0000000000000000000000000x00000000000000000000000000000000000000,
      64'b000000000000000000000z000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b00000000000000000000000000000z0000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'bz;
    control_b = 1'bx;
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
