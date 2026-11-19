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
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1000101001100111110011111001110100110100110110000100000010010110,
      64'b0011010001011110010110110100011110010110001011111111010001111110,
      64'b0011000100000010110111111011101111000010110010010101101100010100,
      64'b1110000010010001010010010010010010100010101000110100000001111000,
      64'b0010101001110101001011011100011111100100101001011010001000000010,
      64'b1110011000010101101001000001110000101011111010101001000100101000,
      64'b1000101110011100100011000101111010000011000001001111011110101101,
      64'b1000010000110111110101100000100010001010010100111100011111001110
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
      64'b0001111001000010000101001111111110000010010101101100011011011110,
      64'b0010110001010100111000110000011001111100101011001000111001001001,
      64'b1000110111010010011001001001110101101011000111001101110101110100,
      64'b1110010100100110010011100001100000111011001110111011111001110011,
      64'b0010000001001010000111010000100000101101110111011011110010010101,
      64'b1101000111000111100101010010001001010000110100100101111111011011,
      64'b0000011101100100011111010011100111010111100111100111001011001001,
      64'b1010111000000101000000100001101101010100101111111111011110101111
    };
    control_a = 1'b0;
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
      64'b0001111001000010000101001111111110000010010101101100011011011110,
      64'b0010110001010100111000110000011001111100101011001000111001001001,
      64'b1000110111010010011001001001110101101011000111001101110101110100,
      64'b1110010100100110010011100001100000111011001110111011111001110011,
      64'b0010000001001010000111010000100000101101110111011011110010010101,
      64'b1101000111000111100101010010001001010000110100100101111111011011,
      64'b0000011101100100011111010011100111010111100111100111001011001001,
      64'b1010111000000101000000100001101101010100101111111111011110101111
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
      64'b1010111011010010011010011100110110010001000000101000101001101010,
      64'b0111010011100010000001111010010000010000010000001000110111001100,
      64'b0101011100100110001001100001010001010110001010001111001000001011,
      64'b0001101000101100010100010010000001000010111110111011010100110000,
      64'b1001001010010001000010000100111011010111111100100101101110001101,
      64'b1010000110110001010011110111010001110111101100010110011100111101,
      64'b0111111001101000111111011111011110011001110111101101111001001111,
      64'b0111011010101111101110010011100111001001001110111011101001001110
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b1010111011010010011010011100110110010001000000101000101001101010,
      64'b0111010011100010000001111010010000010000010000001000110111001100,
      64'b0101011100100110001001100001010001010110001010001111001000001011,
      64'b0001101000101100010100010010000001000010111110111011010100110000,
      64'b1001001010010001000010000100111011010111111100100101101110001101,
      64'b1010000110110001010011110111010001110111101100010110011100111101,
      64'b0111111001101000111111011111011110011001110111101101111001001111,
      64'b0111011010101111101110010011100111001001001110111011101001001110
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
      64'b1011011011110111011011010100010100101011101110110101010100010111,
      64'b0110011101011111000011000000100000111111010111101011100100111000,
      64'b1110110001110000001000111101011100011111111101100011101010000011,
      64'b1101110001010011101100010000100001100001111010111111000101011001,
      64'b1001111001101111100010100110111000101111111100010011011100001001,
      64'b0010111000101100001100110001111100100101100101110011011001111000,
      64'b0000010100011011000001001101011010101011001011000010111010001011,
      64'b1010011010101011100100001111000101000010011100000111001001100001
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
      64'b1011011011110111011011010100010100101011101110110101010100010111,
      64'b0110011101011111000011000000100000111111010111101011100100111000,
      64'b1110110001110000001000111101011100011111111101100011101010000011,
      64'b1101110001010011101100010000100001100001111010111111000101011001,
      64'b1001111001101111100010100110111000101111111100010011011100001001,
      64'b0010111000101100001100110001111100100101100101110011011001111000,
      64'b0000010100011011000001001101011010101011001011000010111010001011,
      64'b1010011010101011100100001111000101000010011100000111001001100001
    };
    control_a = 1'b0;
    control_b = 1'b0;
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
