/*
:name: random_cross_case_0067
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0067;
  logic unsigned [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0101111011110100100111111110000001111001101101100110001111111101,
      64'b1000111010101001001101010111101000000101001011000001001110100101,
      64'b1011000101110110011101101110101000111110010000000010010011001011,
      64'b0000011000000011101100011010111010101111001001001011001000011011,
      64'b1000010110100001010011011011001111000110001111101011010101100000,
      64'b0111111011111000011011100110101111000010011110010011010011100100,
      64'b1111101100110011111000010001000010101111100100001011000101011000,
      63'b011110100111010111010010010001101110111100111011000011101000101
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
      64'b0101111011110100100111111110000001111001101101100110001111111101,
      64'b1000111010101001001101010111101000000101001011000001001110100101,
      64'b1011000101110110011101101110101000111110010000000010010011001011,
      64'b0000011000000011101100011010111010101111001001001011001000011011,
      64'b1000010110100001010011011011001111000110001111101011010101100000,
      64'b0111111011111000011011100110101111000010011110010011010011100100,
      64'b1111101100110011111000010001000010101111100100001011000101011000,
      63'b011110100111010111010010010001101110111100111011000011101000101
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
      64'b1101001000010111001000000010000000100110000011111100111110101001,
      64'b0110111100000100001011010111111001010111110101000111010100000100,
      64'b1101001100100110001001111100000000110111111100001110010111110101,
      64'b0100111011010111000001100000100010001101000011000101010101101010,
      64'b0100110110100100111101101100010001110001001100000001100011110011,
      64'b0010101000111010110111000100110000100010110001110001010010011110,
      64'b1101010011101011001010000011111010110111011000000101011011010111,
      63'b000100001110000101001111011001110100101110011010100010100000010
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
      64'b0001100011111110001110111101111100010111000110010011010100111100,
      64'b1010011110001101110111000110101010110110001010011000110010000110,
      64'b0001111000011100010000110111111010011001010010000011010100110110,
      64'b0100100011000011000100010110110101001001001001001010111010001010,
      64'b0111011001011111000101000111000010011010001001100001110011000001,
      64'b1100011100011100100110011100110010010101011100010100111001101010,
      64'b1000110111011111000000100011011000011111001110010100111001100101,
      63'b111000000001010001001100100100101010001111100111101010011100111
    };
    control_a = 1'b1;
    control_b = 1'b0;
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
      64'b0100111010000000100111101010110100101101001010011110010000100101,
      64'b0001001001101010110111010001011011111100010111111001111000111001,
      64'b0011111101001111110011001100011010111001111000011100111101100111,
      64'b0010010111111110101111100001101110000001101001101000000100111000,
      64'b1011110001110001000010011110010111101100101100101001101010100001,
      64'b1000000110101001101011000001011001001001111011101010100010000101,
      64'b1011111110011001110001110110011000011010001000100111100111100010,
      63'b010001101010010000111101000110110101010110011011101011011010100
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
      64'b0010000000011011110001110110010100000111101111010011110100001100,
      64'b1010110011000011010000010111010111111011001011100011111000010111,
      64'b0110010111001011111110101011111011010111000110110100111101011101,
      64'b0111101111101100011111000100001010010000001110100011000011001011,
      64'b0111101110011001110011101011010111110010110001011101010001001010,
      64'b1011011101100101101001110011101111000100011000011011001111110111,
      64'b0110100001100101111011111001111101101000000010101001100101110101,
      63'b111010000001010011001101001110101001100110011111011100111100001
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
      64'b0010000001010111011000101110011001011100011100001100111000011111,
      64'b1100100110101101001011100100001110100010000100010110000101010010,
      64'b0100010011100110000101000101100011110110110000010101101001101111,
      64'b0011010000010111111100010100010000110101010001100001011001110011,
      64'b1000000100111011100100100011101101110110100100110010101010001010,
      64'b0000001011000110000110010101101011000110100101111001010001100111,
      64'b0111111111010101001000011001000111110111100000111001001001000010,
      63'b101000101101110111001100110111100011001111101100101110101010011
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
