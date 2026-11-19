/*
:name: random_cross_case_0030
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0030;
  logic unsigned [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1010001111010010011101101000110101000100001101001001111010100110,
      64'b0010011010100000111010001111100111010011111000110110011101101100,
      64'b1110111110100000110011110001010101001110010100011100100011110001,
      64'b1010101110100000010010110110100000011100100100001111111000110010,
      64'b1111000010001111010101001001111001010001000010111111010000110011,
      64'b1000001110010011000100010011101100111010110100101101000001111000,
      64'b0111110111011011001000010000000011101110110011111110001010010100,
      64'b0111001111000011100010110000000100011101000110101110110100110000
    };
    control_a = 1'bx;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b1010001111010010011101101000110101000100001101001001111010100110,
      64'b0010011010100000111010001111100111010011111000110110011101101100,
      64'b1110111110100000110011110001010101001110010100011100100011110001,
      64'b1010101110100000010010110110100000011100100100001111111000110010,
      64'b1111000010001111010101001001111001010001000010111111010000110011,
      64'b1000001110010011000100010011101100111010110100101101000001111000,
      64'b0111110111011011001000010000000011101110110011111110001010010100,
      64'b0111001111000011100010110000000100011101000110101110110100110000
    };
    control_a = 1'bx;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b1010001111010010011101101000110101000100001101001001111010100110,
      64'b0010011010100000111010001111100111010011111000110110011101101100,
      64'b1110111110100000110011110001010101001110010100011100100011110001,
      64'b1010101110100000010010110110100000011100100100001111111000110010,
      64'b1111000010001111010101001001111001010001000010111111010000110011,
      64'b1000001110010011000100010011101100111010110100101101000001111000,
      64'b0111110111011011001000010000000011101110110011111110001010010100,
      64'b0111001111000011100010110000000100011101000110101110110100110000
    };
    control_a = 1'bx;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b1010001111010010011101101000110101000100001101001001111010100110,
      64'b0010011010100000111010001111100111010011111000110110011101101100,
      64'b1110111110100000110011110001010101001110010100011100100011110001,
      64'b1010101110100000010010110110100000011100100100001111111000110010,
      64'b1111000010001111010101001001111001010001000010111111010000110011,
      64'b1000001110010011000100010011101100111010110100101101000001111000,
      64'b0111110111011011001000010000000011101110110011111110001010010100,
      64'b0111001111000011100010110000000100011101000110101110110100110000
    };
    control_a = 1'bx;
    control_b = 1'b1;
    control_c = 1'bx;
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
      64'b0101100111101111101111100011110100101100110101101011011111011110,
      64'b0011001100010110010100011100110000010110111000111101011000111001,
      64'b1001011001010010111x01010000100101010110011110001110010001110010,
      64'b0111111111010011110101010111011110100101000100100110101010100111,
      64'b1110101001101110111111000001111110011001001001101000011011010110,
      64'b101110001101001100000100111110001011100001100100z110101110010000,
      64'b0111101101110011010001110001011001001010100100000101111011000100,
      64'b1011100110100101010110100010101100000111110111110101100110011110
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
      64'b0101100111101111101111100011110100101100110101101011011111011110,
      64'b0011001100010110010100011100110000010110111000111101011000111001,
      64'b1001011001010010111x01010000100101010110011110001110010001110010,
      64'b0111111111010011110101010111011110100101000100100110101010100111,
      64'b1110101001101110111111000001111110011001001001101000011011010110,
      64'b101110001101001100000100111110001011100001100100z110101110010000,
      64'b0111101101110011010001110001011001001010100100000101111011000100,
      64'b1011100110100101010110100010101100000111110111110101100110011110
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
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
      64'b0000000000000000000000000000000000000000000000000000000000000001
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
