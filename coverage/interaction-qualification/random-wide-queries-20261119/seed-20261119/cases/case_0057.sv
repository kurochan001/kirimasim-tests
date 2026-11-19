/*
:name: random_cross_case_0057
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0057;
  logic unsigned [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
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
      64'b0010011001101110100111111110000101001110111111101010100101100111,
      64'b1000110011011001001111011101001101100001010101000110011010001000,
      64'b0010110111101010101100010000100011101101101110100001000110100001,
      64'b1010011001000010100111101101110001110110001100000000011010001111,
      64'b0101000100010010100111101101001001010010100101111001101111001110,
      64'b0001000000100100010110101100010100101000011101111110100100001100,
      64'b0110100000000000011000000100001000001101010110100011101000110110,
      63'b101011110101010011111001101000011000100010110110010010101111111
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'bz;
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
      64'b0111111100110111110000110101111011000001111011101001000110000100,
      64'b1111110111100010110001100111101000001101001010101010111100001111,
      64'b0001110000110000101101000100011101001110111010111010111111011100,
      64'b0101100001110111010010011000111010111101011011111001000010110011,
      64'b1001001000100101000010011101011110111110000100111111000000011110,
      64'b0011111100001010000110011101101000000100111101111001000010110110,
      64'b0110111110010100000010111110111010111101011000011101011100010111,
      63'b000010010101110111111110011101010100010110101010011100100110011
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b1101111011011000001011011001000110010101111011101101111001110001,
      64'b1110100110110101001000011110010000111001001111010111110110010110,
      64'b0111000101100101001011000100010101111011100110001100011000100101,
      64'b0011010100100110101110110001010100010011101110010110111011000110,
      64'b1111000001010110101110110001011001010101111000100101000101101110,
      64'b1010001111111101011001110001000011100110001101110011110010101100,
      64'b0001101001010100110001000100100001101000010011010110111010010001,
      63'b111111011011110110001100010000000010010100010100001001100010111
    };
    control_a = 1'bx;
    control_b = 1'b0;
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
      64'b0011101000000000100111111010001010011101110101001110010000000100,
      64'b1000000000011101110000000110011000101011101110110001101001101011,
      64'b0010111101111110001111011011010110001011010001000101100101000100,
      64'b1000011010101011001110101010000110101001010000001111110000100111,
      64'b1011001100110000100110011010110011010001011100011010010111000000,
      64'b0100111110001111010111010000010100110000000111111001100001011000,
      64'b0111011100001111111000110100111110000010101011000011110110010001,
      63'b010111001101010110100010000110111111100000001001000110010010100
    };
    control_a = 1'bx;
    control_b = 1'b1;
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
      64'b0110010011100100100001110000000101011011000110010011101000101100,
      64'b0101011001110011010001111010001110000110000000001010001011011010,
      64'b0010011110111101011110100111101001010111100100111100110010110110,
      64'b0011101101101001011101100001110001001000110011001111000100010110,
      64'b1010000001001100101010100101000010100010100111110100000010101011,
      64'b1110010010000110110011001101011010011011001011001001010010001000,
      64'b1110011100010000001001110101110110101000011100101011011011011000,
      63'b110001011111000111101111110110110100001010110100010010101001100
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
      64'b0001001001111111010111100001001100110010000000101001010000000001,
      64'b1100100001101110100010111001101010111101101011101101001111011010,
      64'b00010101111101100010000100001101110111011010111000000100x0101010,
      64'b1000001001100010100101010000011111000001000000110100001001001011,
      64'b1011100001011111000010111011100111001001010011000010111011011111,
      64'b0110000111100001111010101111110011111010010001011101010101111001,
      64'b1010010001011101010101010111100001010111100101100111001110000010,
      63'b00110110000010100001100100100110x101000101100100111100010001011
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b0101111111001010010101010011001110101101000110010010100111000000,
      64'b0101000010110100100000110101011100111100010111010001010010110110,
      64'b1011100000101000011010001000111111100101111110000000111010111010,
      64'b0011111111000000101001000100100110111110111110011010101011010010,
      64'b0010101100111011110000110101111011010110011111101101111001100111,
      64'b0110001101111111001000100010101100010111001110110001011111100000,
      64'b1010000100100000011101010100111110101010000101101001001110000110,
      63'b110111100110000001101011111101101101011000001001000000111101101
    };
    control_a = 1'b0;
    control_b = 1'b1;
    control_c = 1'bz;
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
