/*
:name: random_cross_case_0042
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0042;
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1110001001111101001100001100001110001110011000010000111001110111,
      64'b0010100101010000000111011110001011001000000011110100100111110000,
      64'b0010011000100100100111001000000111001000000001111011110100001011,
      64'b0011010000111110100110000110101000011010011011110100111110111000,
      64'b0010010001011011101000000111110100000111111101001000101010010100,
      64'b1010010100101011101000101111111111100010000011011101011110110110,
      64'b0110001010011000100111110010010101010111011101011010111010000100,
      64'b1101001100101011011010000000101100010010110001010001011000011000
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
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b0011011000100010101011111011100111010010110100101110111111101100,
      64'b1000010010011110100101111000111101110000011111110110000011101100,
      64'b1011111100111111000100010000101011100001011111001010101010111011,
      64'b1001010011011000000100001100011100000000011001000010010100011111,
      64'b1001110011010000101100111111110111110100111000100110010000000001,
      64'b1001101010000000100111110001101001111100100011000110110000100010,
      64'b0110110111000100000010011000101101000110111111111000010010011100,
      64'b1000000001001011001100100011101100111111000111101100101000110001
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
      64'b0111000000011010110111010110111101001111110000000001000011101100,
      64'b0110001011101010110010001100101011011110101110010110011000101001,
      64'b0100100001000010110110101010110111000110011101001100101101111011,
      64'b1100000110010011010100110111001100111110000001010001111100010100,
      64'b1100111001101011011111000101110010000101011001101100110100010111,
      64'b1000110110001111001101111110000010010101100010101100000011001100,
      64'b0010111001101111111010110011000011000101100101010100111011001111,
      64'b1101110011100000001111101000100101010001011101100100111101000111
    };
    control_a = 1'b1;
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
      64'b0101110101010100110001010000010111011010110000000010010111100111,
      64'b1000100011111111010011100101101101101101100010100100011101111011,
      64'b0011001000110011101101000111111010001000101110010100101101100111,
      64'b0010100100100110111110110011111011110000001101000110110101010011,
      64'b1010100111111110010110010000101101101011100100100011110001110010,
      64'b1010100101111101001101101100110001101100010100100110000000101100,
      64'b0110000000000100011101110010111011111011000010110011111001001000,
      64'b0011111010011001000001111001101100011101000000111001011101011100
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
      64'b0111111100000111010111100000100000001001011011000011110110001010,
      64'b1110110011011011001111001111011110010110101110000000111101010101,
      64'b0010010011100110111110011000101101000000100111100101010100001111,
      64'b1010111010100110001011101000011010100011110011100001001000100100,
      64'b0010111100001010001011110011001011100000001101011011101100011111,
      64'b1110100110111110110110010001100000000010111010110101001000100010,
      64'b1100011011100010001111110000011000001010100101011000010101110100,
      64'b0100000110111100001101010010011011110001010011010111100110101000
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
      64'b1111000111110000000001000101100110111100011011010110011101101001,
      64'b1101100011110100111011000001101100011100110110000100100101000000,
      64'b0101100010100011100001011011001010111101100000101100011001010010,
      64'b0010111100010110111110101001111000111101010010001101110101001100,
      64'b1001000100011011001011110010110111001111010000111001110111100000,
      64'b1001011000001101001110100000000111110100100011100101101101110000,
      64'b1110111011000101101001110011001011010101010111011110100110011100,
      64'b1010110010000101001111000110100101110100010011011110101010010011
    };
    control_a = 1'b1;
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
