/*
:name: random_cross_case_0023
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0023;
  logic signed [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b1100111010101010000011010111101110111010000001110111010001100011,
      64'b1011001000010010011110011001011100100100100001110110011000100011,
      64'b0100010000000010111111101011010011001110001011111110001101110101,
      64'b0111000011001000111001001100110110001111110000110111010101000101,
      64'b0000111011111000000011011110111101010111100000101010011000010111,
      64'b0000111001100010001000000100110111110011001011010011110111101011,
      64'b0110001000000010000101001111101001001001100001101100000000101101,
      64'b1011000100011011011011101011110010100111110010011111110010110001
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
      64'b0110010110100111000011101100111001011010111110101001111101100000,
      64'b1100111110011111100110000010011110011100110101001010101010000111,
      64'b1110100111111011000011000010101010000101000100010000011110110111,
      64'b0000011011101000000111101011000001001110101011101000110111001110,
      64'b0011100110010110110000000101010101110000011010011001110111001100,
      64'b1000110011111010011101010100111001111101001010100001110110110011,
      64'b1001001010000000011101001011111101100001111100101100011101011111,
      64'b0000010101000100110101110011010010001010000001011001110100010011
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b0000010111011100000001111110101101100011011110111110011101110110,
      64'b1000110000100110000111011111011110001100001010001111011011111100,
      64'b0010000101101100011100010110001100110111100010011110111101111000,
      64'b0111000111110111110100011000101001000010110001111111100000101100,
      64'b1011100111001001111110001001101110011001100011000011000011100101,
      64'b1111101011011001011011110001101101100001100011001010110001001111,
      64'b0011110100000101100010111001000000101010000111010010011001100101,
      64'b0111011000110101100000100011000110001100001010101011100000110100
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
      64'b1000010111101000011111011100011110001101110111100110001011001000,
      64'b0000011101000111001010000101101101111100111011000010101110000100,
      64'b0011010000001110111110010001111100011101001010001110100110001100,
      64'b1011101001101010100011000010001011101110001001100000101011000100,
      64'b100001110011011100010001100010101010000101000111110011110z010111,
      64'b1101011110010100110000100110000111000011101101101101100110011100,
      64'b0111001011110011010110001110011101010000101011001010011111111110,
      64'b1101011001100011111111011010110000000111001110100100101000111101
    };
    control_a = 1'b1;
    control_b = 1'bx;
    control_c = 1'bz;
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
      64'b0001000010010100111100100010010110000000000101010000000110011001,
      64'b1110010010101011111111010101100000000111111100010111100011100110,
      64'b011011111111010000111010000001101010111101011001110100x100111011,
      64'b1000100100010001110011100011001110100001001011111101100010001000,
      64'b0111011001111011011010111001001100101011010000011110011110100011,
      64'b0010000011010011000001110011011101000111000011011100010110000000,
      64'b0001011010000010100000100111010000000111011100010000001110001110,
      64'b1011010010101000000111010001001100001110100110110110011100001101
    };
    control_a = 1'bx;
    control_b = 1'b0;
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
      64'b0111010101100011101110001111000010111111001000111001010110000000,
      64'b1101101101101101011000001110010000010001101100010000000101010000,
      64'b0101000000011100110001001001111010001011111111010111011111001010,
      64'b0011010001001010101110100111101000100011011111111011000011110000,
      64'b1000100100011010011111001010000011000111100000111100100011101001,
      64'b0000011011100101010101000001111000100000010100000110110111101101,
      64'b0010111100111100100001000010011000000000100110100111000111011000,
      64'b1101111001010101111000110101101111011110101110100111101101011001
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
