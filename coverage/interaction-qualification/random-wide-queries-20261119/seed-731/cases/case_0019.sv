/*
:name: random_cross_case_0019
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0019;
  logic unsigned [510:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0000111001010010101100100000110001110111110011010001111000001001,
      64'b1010011010011110000010111101011001101111000011001001101100110101,
      64'b1101101101110000010011110101110011100111010101000001110110110100,
      64'b11101100001111010000111100000111000111110101101010101001111011x0,
      64'b1101100100010001011101100111110000001000110100000001100100010001,
      64'b1101101101100010100011011000010101110011000110010111011010111100,
      64'b1101011001111011000110110111101001111111011011110101111101101100,
      63'b111011101010110111001010001110111110000100011100111010000000001
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
      64'b0000111001010010101100100000110001110111110011010001111000001001,
      64'b1010011010011110000010111101011001101111000011001001101100110101,
      64'b1101101101110000010011110101110011100111010101000001110110110100,
      64'b11101100001111010000111100000111000111110101101010101001111011x0,
      64'b1101100100010001011101100111110000001000110100000001100100010001,
      64'b1101101101100010100011011000010101110011000110010111011010111100,
      64'b1101011001111011000110110111101001111111011011110101111101101100,
      63'b111011101010110111001010001110111110000100011100111010000000001
    };
    control_a = 1'b0;
    control_b = 1'bx;
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
      64'b1011100001111011111101111000000101010011011100001100000111100101,
      64'b1010010011101010110011001010100110001110001101111010011000101011,
      64'b0111110101100010110111011011010110100110010010100001000001101001,
      64'b1110100111100000110111100100111100000111101111101001101010011101,
      64'b1110110010110110100000101110100101100010110011101111100111101101,
      64'b1100011001011111001110010110100111100101000011101010011000101111,
      64'b0000001011101001001101111100101001010111010110010111100000010010,
      63'b011111011101001111010010111000011101101100000001011010110111111
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b1011100001111011111101111000000101010011011100001100000111100101,
      64'b1010010011101010110011001010100110001110001101111010011000101011,
      64'b0111110101100010110111011011010110100110010010100001000001101001,
      64'b1110100111100000110111100100111100000111101111101001101010011101,
      64'b1110110010110110100000101110100101100010110011101111100111101101,
      64'b1100011001011111001110010110100111100101000011101010011000101111,
      64'b0000001011101001001101111100101001010111010110010111100000010010,
      63'b011111011101001111010010111000011101101100000001011010110111111
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b1101000010001111000001110000000110011101001000000000011011001110,
      64'b0011100111001110110110011001011100110000010110001001111100110100,
      64'b1100111100001001100100111010110010011110010110111000000101000110,
      64'b0100000100100101000001000011101100011011111010101110101111101101,
      64'b1001000001100001101010101100111010100001111000011111000010010101,
      64'b0101001100110101110111110010010010111010011010001110011000100110,
      64'b0100000110001001010111000101011100100101100110101100001010001100,
      63'b010010000111100100111100001011110010000011001001100011110110111
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
      64'b1111001010010111011001001011111111111011110111101010000101110100,
      64'b00110001010011111000011010011101111010100101010101100x1011100100,
      64'b110011z110010101111000010110111010110010011011011100101000101101,
      64'b1010011110101111110001100111100011100010111111000000101100010001,
      64'b1110101001110111100010100110101101010010110101110100011000110010,
      64'b0110110111100011011100100110111011110111111100110110010101110010,
      64'b1011010100110010111001111100111011001110011000011101010001000101,
      63'b110111110101111001110101011110011010110111100110010110110110011
    };
    control_a = 1'bx;
    control_b = 1'bx;
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
      64'b0101000011100110110011111111010011100100111110011101011111011111,
      64'b0101000101011010101110101010111000110110010000011000011011111110,
      64'b1101010001010010011111100101111100101010111110111111101111110010,
      64'b0011111110001100011100101110110111101110010110000111011100000001,
      64'b1100101011010010111100101010100011100000111000110011100100000101,
      64'b0010001011001101110101010001101011101101010101111001000011010010,
      64'b1111110001111011101010001101110110100110110010000001010001010010,
      63'b011010000111001111111011001001011110000000011100001000100100010
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
