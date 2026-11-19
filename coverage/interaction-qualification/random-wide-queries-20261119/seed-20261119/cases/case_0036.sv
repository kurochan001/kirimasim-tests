/*
:name: random_cross_case_0036
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0036;
  logic signed [0:512] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1011111111010001010001001000011101100110001000001011000111111100,
      64'b1010010110101100001101011101101111001111111110100100110001101000,
      64'b1000111011010111001000111001100001001111100100011110010110000101,
      64'b0000111010111000101100000010110000010110101111100010000101110110,
      64'b1001001101010010000000100000110111001011101100010110111001000101,
      64'b0101101100011101100110000010011100000110111101111010100000111100,
      64'b1101011011111001010011110111110001000111010010010001001001001110,
      64'b1011111110000010111110111111101011010100110000011010100000111100,
      1'b1
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
      64'b1011111111010001010001001000011101100110001000001011000111111100,
      64'b1010010110101100001101011101101111001111111110100100110001101000,
      64'b1000111011010111001000111001100001001111100100011110010110000101,
      64'b0000111010111000101100000010110000010110101111100010000101110110,
      64'b1001001101010010000000100000110111001011101100010110111001000101,
      64'b0101101100011101100110000010011100000110111101111010100000111100,
      64'b1101011011111001010011110111110001000111010010010001001001001110,
      64'b1011111110000010111110111111101011010100110000011010100000111100,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b1011111111010001010001001000011101100110001000001011000111111100,
      64'b1010010110101100001101011101101111001111111110100100110001101000,
      64'b1000111011010111001000111001100001001111100100011110010110000101,
      64'b0000111010111000101100000010110000010110101111100010000101110110,
      64'b1001001101010010000000100000110111001011101100010110111001000101,
      64'b0101101100011101100110000010011100000110111101111010100000111100,
      64'b1101011011111001010011110111110001000111010010010001001001001110,
      64'b1011111110000010111110111111101011010100110000011010100000111100,
      1'b1
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
      64'b10111100011110100110000010101100010010100x1001100101001011110001,
      64'b0010100011001111111000100100010101010111011101010100100011111011,
      64'b1001001000011011110000110011101000000101110100010101100001010110,
      64'b1011001000111001111110001111101001101100111000011000010011011101,
      64'b1011101100001011110000101000100111001110100100011000100010010011,
      64'b0100110100101011111111000011001011011001100110010010110101010101,
      64'b01111111010001100z1110000100110000101111111100001001000001010111,
      64'b0111001000111111101110111100111010110010111111100010100100111100,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b10111100011110100110000010101100010010100x1001100101001011110001,
      64'b0010100011001111111000100100010101010111011101010100100011111011,
      64'b1001001000011011110000110011101000000101110100010101100001010110,
      64'b1011001000111001111110001111101001101100111000011000010011011101,
      64'b1011101100001011110000101000100111001110100100011000100010010011,
      64'b0100110100101011111111000011001011011001100110010010110101010101,
      64'b01111111010001100z1110000100110000101111111100001001000001010111,
      64'b0111001000111111101110111100111010110010111111100010100100111100,
      1'b1
    };
    control_a = 1'b0;
    control_b = 1'bz;
    control_c = 1'bx;
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
      64'b1101010010110011000100110010000000111101001110101011111010110111,
      64'b1101111011011101111111011110010010010100110011100110010010101110,
      64'b0111100000111101101001111111010100100001100111001000001100000001,
      64'b1011001011000100000010000011100100100001010010010111101001101101,
      64'b0011111100100010000011110100101000110011110001101000111010000011,
      64'b1101111110001110010111001101100100111001011001101011000000001011,
      64'b1011011001000001001011010010001110010011110110111001100101001111,
      64'b0001100011110110100000010111000011011111101011110001001000011110,
      1'b1
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'bx;
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
      64'b1110001000011010000111100001101111000010101000001110001111111100,
      64'b1001001110011001000111000001011111000110000100100100101110010110,
      64'b0111110111100010100011010000010010001111111110110110011011001010,
      64'b0010001001110001011111010101010111100111000000111010101110011111,
      64'b0111110001111011111110000111000101001011010100001111101100110001,
      64'b1110001010000001011011011101010001111100000010100101001000100100,
      64'b0001010011001110110101001011111110011011110000001000110101010111,
      64'b0101000011100100010001100100110101001001101000111111110000111111,
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
      64'b1110001000011010000111100001101111000010101000001110001111111100,
      64'b1001001110011001000111000001011111000110000100100100101110010110,
      64'b0111110111100010100011010000010010001111111110110110011011001010,
      64'b0010001001110001011111010101010111100111000000111010101110011111,
      64'b0111110001111011111110000111000101001011010100001111101100110001,
      64'b1110001010000001011011011101010001111100000010100101001000100100,
      64'b0001010011001110110101001011111110011011110000001000110101010111,
      64'b0101000011100100010001100100110101001001101000111111110000111111,
      1'b0
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
