/*
:name: random_cross_case_0043
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0043;
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1101010110111111101000011101110001111110110011111100111011101001,
      64'b1001000000101101100001011110100010101100101001110000111010000001,
      64'b1100000111111000010001101011001000111001101110110100110001000101,
      64'b1101101011000010011000010010011001100110101000101001000110001010,
      64'b0101110100111100010011110000110111110110000001101101101101111001,
      64'b0010010110000101010000110100010010100001000000110111111010111110,
      64'b1110111001110000000000111000010101101100011010000000000001001011,
      64'b1011110000001010100001110100010010111001100101100100110110110011
    };
    control_a = 1'b0;
    control_b = 1'bx;
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
      64'b0011111011000010011010011000011001011001010000110111001011001110,
      64'b1111010001011111001101001110000001010110101100101101001000000011,
      64'b0100010111101000100110010110010011111011011010011001000110100010,
      64'b1000110101010100111011111011100100001110001111100001011011100011,
      64'b0000100011001101011010101011101110110101110010100000000100111001,
      64'b1111010011001000110110010110010101000110010011101010010110110001,
      64'b0111001101000000000100100010011010000001000010101101010110001011,
      64'b1010101100011000100111000100110100011101010101111011010011101111
    };
    control_a = 1'bz;
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
      64'b0101000111010110011010010001101100111101101100010011100110110000,
      64'b1111011101010010011011101000100011011010100101000111100100111110,
      64'b0100000011100010111011000000010100011000000000111010100110000011,
      64'b1101001100111110011101010010001111001011100111010111110010001011,
      64'b1010111010101010100110101100001111011011010000101010011010101111,
      64'b1100110000101001000100100000011011111000101101011010010101011011,
      64'b1110011001111010101001010100010111001100111111000010001011101101,
      64'b1101100101001110111000000110010101011010001111010000110000111001
    };
    control_a = 1'b1;
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
      64'b1011100100101000000001001000100010110101110100000010110100000010,
      64'b1000101110001010101000111101000000111100011111010011000111000101,
      64'b0000000101000000100001110110001011000011101000111100011110110111,
      64'b0110001010010110011110001001101010011110010100001000010100011011,
      64'b1101000001010000010101010000001101011111000101000000010001100011,
      64'b1110001100000000000110001000001111010101001010110010010001110111,
      64'b1001100011101110110011111100001111010011111100000000100011000000,
      64'b0011101100101111110100001010000011111111100101000101010001011000
    };
    control_a = 1'bx;
    control_b = 1'b0;
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
      64'b1011011000101000101111110001001100001000110010100110000010100011,
      64'b1100110100011010100110010001011010011110101101010110001000101000,
      64'b1111001000010110000111100010110000001111100000001010100011100100,
      64'bz101101011100001101000001100101100110111011011010101000001100000,
      64'b1001100011010110001011111011011011111011011100000110010101111011,
      64'b1101010010111110101101100001011110100010001100011001001010000111,
      64'b0111011101011100010110111000011100000011001110100110011110101111,
      64'b1010110010011110000011011100011010111000111011010001011100110110
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
      64'b1001100011010101101000111110011011111010101000110100110011010100,
      64'b0101101000000011001000101101100101001000101101110000000010000011,
      64'b1110111000001001111110010111001001011100001010100101110101110100,
      64'b0010010001101110000111011011000001100000101111010010010100001101,
      64'b1111001011000001100111011111101110111100010111110010001111110100,
      64'b0001111010010000010001010110110000111000010111110111001111111110,
      64'b0011101001110011011111011101000001011100110001100010010011001101,
      64'b1110000110111000000111101011111110010101000100010100111001010100
    };
    control_a = 1'bz;
    control_b = 1'b1;
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
      64'b0100110101110000101011001101101010110010111011000000000110110100,
      64'b0011100011110101010011001010110010101000011110111010100111110011,
      64'b0010011011011010000000000110111010011100010101111100101110001111,
      64'b1010100100011000101011001010100011100111010011011111111001110100,
      64'b0001100110100111011011001111000110001001011001101101111111000000,
      64'b0010011000010100000001000011010000101010101101110001110010101011,
      64'b0101001010011011100101110111001010001011100111010011111101000111,
      64'b1000010001000100100101111010010001100010111000011111101010100100
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'bx;
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
