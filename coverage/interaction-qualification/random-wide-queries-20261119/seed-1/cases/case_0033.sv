/*
:name: random_cross_case_0033
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0033;
  logic unsigned [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0011101111000010110001100100101011000111000111000000100011101101,
      64'b0000011101111101000000000101011000010101001110110111001101000011,
      64'b0001100010011010001110011000011111110100001111000010011111110110,
      64'b1100001111100111111101000011100010001110100000001010100110011000,
      64'b0110111011101100011000000110001011110111111010000110001110110111,
      64'b0101100011110010111111111100111010101100000011010010010001101000,
      64'b1001110000001111110001101110011000111111000111010000011000110010,
      64'b0011100100001101011010011011001010001100100101111010110001110100
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b0000000010000010001111110101010101100001100100001001000000001111,
      64'b0010110110111001110110010110001000100001100000101000110000001011,
      64'b1110111000001000111011010010100001111111110001101110001010000001,
      64'b1001010011001010101110001100111010011100111010011110011001011101,
      64'b0000000001100001010011000101001000110100101100011010001111100001,
      64'b1100010011101110011000100001110001011111001010001111001010101010,
      64'b0110110001111001101111110000110101011001000110110101100101000010,
      64'b1110001101111111111011000010010111011101110100110011110100100011
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
      64'b0101110000111110101101111001011110011100001111111000100110000010,
      64'b0110010010011110001110101110111010001100000110010011000011000000,
      64'b0010010110111000110101010101000101001010100010010101000001001011,
      64'b0000111010110001100111111011000100011001101011111101101101001010,
      64'b0011010100110010000011011101100010100000100010011001110000000011,
      64'b1101000100110111010001001001001100000000010111101011000110010101,
      64'b1101010110011010010101111000010110010101100010111110011101110111,
      64'b0010101111001011110111101100010100001011000010101001000000001001
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
      64'b0100010011010001111010111110000111001001001110001110011101110000,
      64'b1100111001101010100101100011101111011101100111001111010111010111,
      64'b1111111010100111000011100111000011011010110110011010011001000001,
      64'b0011011110111110110000111011100110100110101011111101111000000010,
      64'b0011101010010001101011001100000011111101010011111101110111100011,
      64'b1011101101000010101000101010011000001011001000001100110101011010,
      64'b1011010001100001010110001000000010010010100011100000011010111000,
      64'b0011111000001010101101010001000001110001010010011000100110011110
    };
    control_a = 1'b1;
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
      64'b1001100111010111001110000011000001100001100001000000111110000001,
      64'b1000001100111000110111001010101001101101000000101101011111101010,
      64'b1110111000100101110100011100111001101010101010111011110111010000,
      64'b1100001011101110110010110011011000010010110011000111010011001110,
      64'b1000101101000011000100000101101100011111100011011001011100101111,
      64'b0110110001100011010100000001001100100111101110000111010001111101,
      64'b1000101000101101010000110101100000111000111111101010110011000000,
      64'b0011101110000111110101110101000000001011111010101111111111011111
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'b0;
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
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
      64'b0000110111110111111000000111110100110100010011100101000101000000,
      64'b0110101010110110011110011110101101110110110110101010000001110110,
      64'b1110110000001011010011010010000101100110110010101010000001100000,
      64'b0101100000111111110010010001110101100100110110100010110101100100,
      64'b1110111110111000001101010000000100001000100110001101110100001000,
      64'b1101110001011111001011111101111101000001100001100111010011010001,
      64'b1010010000111001110000000111100101111110000011001101011010100101,
      64'b0011100100011111101110010111100110111101101000001010000100000111
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
