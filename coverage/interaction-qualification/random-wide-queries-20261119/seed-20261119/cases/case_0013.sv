/*
:name: random_cross_case_0013
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0013;
  logic signed [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0011111001001001111101101101000101101110100001001000101110010011,
      64'b1001111100101110011100000111001011111011011101001101100010100110,
      64'b0010110100010100011111001100101100110001001110000000001101101001,
      64'b1111011100111011000111010010000111111100011100100110101011001000,
      64'b1110000101111111011110000000000000010101100100101110101110001110,
      64'b0100010111111100011101011000111011101011011000101101111010111111,
      64'b1001100010110101101110110111001111010101000010011000000100000111,
      63'b010011101101011000111110111000011010101001000111000011100111100
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
      64'b0011110001100101010101100100100010100110100100000001000010101001,
      64'b1000101100011100110110001101111100010110000000101100001001011011,
      64'b0000001101100011001010001110010100001100000010011111001010111100,
      64'b1101111001101011110001011000111101110111010100101101100000001011,
      64'b1010110111100000001010111110000010010100011001101111111111000100,
      64'b1111101100110011110000111111101010001111100111001010011010100011,
      64'b0001101111100101100010100001101100110001110110100010100000000111,
      63'b11111011010010111001110110100100101110001010110101100001x001001
    };
    control_a = 1'b1;
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
      64'b0101000110000001110111101010011011001000001110100100100011101010,
      64'b0101001101000100101110101100001001101000001010011100001111110010,
      64'b1100000110001100111100000101000010011110101010011000111101010110,
      64'b0100001000001100001010101010010101011001101100101111011100101110,
      64'b1010011100000000010001111101001111101000111010011111001111010011,
      64'b1001110000000100101001111010000100101011100011010001100110101000,
      64'b1010101010111110001010000100110001000001110100111010001010100011,
      63'b100101011110011100010010100110011001111100011010110101100100000
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
      64'b1001101110110111111011010111100011111000011111111010101111000100,
      64'b0011110010010101110100001010101101111100000111010010010001010010,
      64'b1110000011100000111000101101110000010010100110111010001110101100,
      64'b1001111001000101010101111011011001111000011001100110100010111101,
      64'b0111001101010001100100011000001110110010010110100011000101000001,
      64'b1100010011000100100100111001110111010000100101010110010001100111,
      64'b1100000101000011011000101110010011000011100001100011001111101011,
      63'b100100000110101110100010100101111111011001000001010010101011110
    };
    control_a = 1'bx;
    control_b = 1'bz;
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
      64'b0100101101101000101011001101101010000011100111001100111001010110,
      64'b1010000011000001110011010100100110000101100000010000001111101001,
      64'b0101110110101001101000100010101001110000101110010010011001110100,
      64'b1011110011001100110101101101110011101110110000010000101011111111,
      64'b1100110101101101011000110111000001010110100011100100000111110110,
      64'b0110101001110110101011100111x00000011001110000010111010100011100,
      64'b100101010011110010000010111011110010110100111010z011010011110101,
      63'b101101011100111010100000101010000011110010101011101110111000011
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
      64'b001110101010110010001100010110000010101110101110111010110z111010,
      64'b0101110111100001101100111010110010011100101101110110010111011110,
      64'b1101100000001100000110100101011100100000000110110101000100111111,
      64'b011110100100010101000000011110011101001001x010001100010100110011,
      64'b0101000101001111101100111100010010011110101011011110011111111100,
      64'b1100001011100101111111111011001101010111011001001101101100110111,
      64'b0110110111111111111111001001100000110000011111101110001110000010,
      63'b100000011011011011011101001110001001011111010110100010011110000
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
    };
    control_a = 1'bx;
    control_b = 1'bz;
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
    };
    control_a = 1'b0;
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
