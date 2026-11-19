/*
:name: random_cross_case_0059
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0059;
  logic signed [510:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0110100011000011000000110010110010010010001001101001001111000100,
      64'b1100100011001011001100111101100000100000101011001101011001101010,
      64'b1001001010110000101000010010001001001100000010110101111001100011,
      64'b1111011011100000000100111000001110101100110111000111111010001111,
      64'b1100001111010111010100101100000001100010001110110010100101000100,
      64'b0100011111111011010111110110101001110100110001010110100111111100,
      64'b0100001010001010000111101111001010011000101100000010100010111111,
      63'b011011010011010011100010000101000010000111001101111100011001100
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b1010000101100001010011101101011111010010101000000000111001110110,
      64'b1100100000000000111001110001011110000101001011000010100100111101,
      64'b1011000111010110011100010110011110010111100010000110111011101011,
      64'b0011001111101010101100011001110010111101111111000011101001011000,
      64'b1101101110011110100001110010011000110011101011010100001000100111,
      64'b0011011101111110101010000111100000010101011100011011001110111000,
      64'b0100110001011101010000011010111000111010101101111000011110101010,
      63'b110101100001100011011000101110100000011001000100001110010111100
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
      64'b1000010101110010111010100000010111011010110010101101000110001111,
      64'b1001010010000101111111010010110110110110011111001110100100110011,
      64'b0101001011101100000101100011011000011001010010101111010011101010,
      64'b0101000111000111101010101001101010011110011010100011101101001011,
      64'b0010001110011001011010101100010010010111000000111110110101110111,
      64'b1100010100001101111111011010111001111100111001100011111000001100,
      64'b1110100110010111100101001001101000000110001000001110011010011110,
      63'b101000110101100111100100001100001111000101001111010011010001100
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
      64'b0111111001001100100100111110111001001110110000011110110101011000,
      64'b1011000101110011110101111001100110100110111101000010110010001111,
      64'b1111100011010011111000100000000000111110100001001101010001100000,
      64'b1111001000000111000111010100010000101110100100011010110000000110,
      64'b0010101110110101110101000001110001001110110110001111000001000100,
      64'b0011001000000100101100011000010010111001011110011000011111010110,
      64'b1101011001011001101001101111001110001010101100101111000100100101,
      63'b000110001011100000010100101011110010011111110010011010000000001
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b1011110001000100001010000100011011101111110000011010100001111000,
      64'b0000100100101001011011110110000101000010110100000101000011011011,
      64'b0010110110100100100001000011001101101010100110011101010110000000,
      64'b1010100000010010110010011110000111000100000001010100001101100000,
      64'b0000111011110110000110000101010010001110001010000001111001111111,
      64'b1111111101100011111100110110110011011100111001011000000100001100,
      64'b0011101110111010010000001011111001010001100100110100000100110001,
      63'b100011111001101001100001110111011100000001100011110111001111001
    };
    control_a = 1'bx;
    control_b = 1'b1;
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
      64'b1111101101011000000111110000101111010100010001100011001001101001,
      64'b0101101010100001000000111011111010001101011111001001111000010101,
      64'b1011101110000111100111000000100101001111010111111110010000100111,
      64'b1110000010000101001100100010100111100011101100011101000111111010,
      64'b0110111100101010111111110101010011001110100001001100000101110011,
      64'b0000001111010011001110100011100101010001010010010010011011010111,
      64'b0101010011010110010000010001100110000001110010000010011110001101,
      63'b001001010001010000101010110100110100111100101010111000101000010
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
