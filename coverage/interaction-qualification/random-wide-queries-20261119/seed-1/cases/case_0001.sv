/*
:name: random_cross_case_0001
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0001;
  logic signed [0:511] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0001110100101001011001011000100001010111000111001110111011101110,
      64'b0101011010111110111110100011100101011110001111000101001101101100,
      64'b0100000101011010110001000000000011010111010101000111000010000000,
      64'b1000000110000001111010000100110110011001101001110100100100100100,
      64'b0101010100001101010000001101110111000010010101010111000000110101,
      64'b0100010010011100010011001010001000110110100001010001010101101011,
      64'b1000100111001000000011000100110111101001001101100111111011011001,
      64'b0010101010100011001100000000101100101011011100010001001101000011
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
      64'b0001110100101001011001011000100001010111000111001110111011101110,
      64'b0101011010111110111110100011100101011110001111000101001101101100,
      64'b0100000101011010110001000000000011010111010101000111000010000000,
      64'b1000000110000001111010000100110110011001101001110100100100100100,
      64'b0101010100001101010000001101110111000010010101010111000000110101,
      64'b0100010010011100010011001010001000110110100001010001010101101011,
      64'b1000100111001000000011000100110111101001001101100111111011011001,
      64'b0010101010100011001100000000101100101011011100010001001101000011
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b1111001111000110011010001011000100010100111011010010000001001001,
      64'b1001000011100011001011101000001000111001010001010101001101010011,
      64'b1000110011011110110011100111010110010010000111101011110011100110,
      64'b0001001110011111011100010001000001100000110001110011010010010100,
      64'b1110110100011001001011011010001111001000001010101101010110001001,
      64'b1001011001100000010111011001010110011101011111001101010011110110,
      64'b0001110101011100010010000010010101010111010001010000111001100101,
      64'b0010000000000001001000010111000011010100000110001111011110101111
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
      64'b1111001111000110011010001011000100010100111011010010000001001001,
      64'b1001000011100011001011101000001000111001010001010101001101010011,
      64'b1000110011011110110011100111010110010010000111101011110011100110,
      64'b0001001110011111011100010001000001100000110001110011010010010100,
      64'b1110110100011001001011011010001111001000001010101101010110001001,
      64'b1001011001100000010111011001010110011101011111001101010011110110,
      64'b0001110101011100010010000010010101010111010001010000111001100101,
      64'b0010000000000001001000010111000011010100000110001111011110101111
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
      64'b1111001111000110011010001011000100010100111011010010000001001001,
      64'b1001000011100011001011101000001000111001010001010101001101010011,
      64'b1000110011011110110011100111010110010010000111101011110011100110,
      64'b0001001110011111011100010001000001100000110001110011010010010100,
      64'b1110110100011001001011011010001111001000001010101101010110001001,
      64'b1001011001100000010111011001010110011101011111001101010011110110,
      64'b0001110101011100010010000010010101010111010001010000111001100101,
      64'b0010000000000001001000010111000011010100000110001111011110101111
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b111111111111111111111111111111111111111x111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
      64'b1001100010111000110110101001111110111001111110101101011001111110,
      64'b0100101110101001001001111100001111101100111101000101110011001011,
      64'b1111101110001010100110011010001011001001011011111010011101011000,
      64'b0000001010110000100001111111100000000110111110101010110110110001,
      64'b0000101000100100100011001111111101010001010000100011001010000110,
      64'b1010011011101100110000110001111100110101001001100011101101000101,
      64'b0001100110100010000100000101110001010000100000000110111100000001,
      64'b0111101000011101010101010110110010110110001011000010001010001110
    };
    control_a = 1'b0;
    control_b = 1'bx;
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
      64'b0100111010101100100110001101011000110101001101001100110010101110,
      64'b1000101010100110011100100011010100101110111001111010111110010111,
      64'b0100001001010011011101011011111001011011000101110111101000111000,
      64'b1010100101101101111110110010110001111000000010110010010111011001,
      64'b1011000000101101001101010000010011011110000110111111000011001101,
      64'b1000101011111100010110111110111011100100001001100100110010011111,
      64'b1111101011011110001100010010110111000111001001011011110110010111,
      64'b1001111000101000100101110110000111001000111111101010010111010111
    };
    control_a = 1'bz;
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
