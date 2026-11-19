/*
:name: random_cross_case_0087
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0087;
  logic unsigned [511:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1001001010101000000001000010010111100000011101011000010011100001,
      64'b0010111111010010111111001011101111111011101010011100111100111001,
      64'b0100011010101010110001101001100011111100001100111100010001100111,
      64'b0001100010010100000101101010011110110111011011101101101101110001,
      64'b0011110100111011010010010110110110101110001110001111100110010101,
      64'b0010110110111000001000110011000001000001100110111010010011010010,
      64'b1001001101100010011001001100100011011011100101101011110101101001,
      64'b0010000110101100010100101100100110001010011010001111110000000111
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
      64'b0001110110101001000001111100100001010011110101001011000011101001,
      64'b0010110111011011000000111001110000011111010100011011110111010111,
      64'b1000000011100011110101000001110011110101101110011001011101011110,
      64'b0110100001010000011100011010001001000100110111110111010101001011,
      64'b0101010111000110101110111101010011011101001001000011011100110100,
      64'b0110000010101101111101100010011010111100111001100110101000111110,
      64'b1100110011110001101110100101010111110100110100101010110001111101,
      64'b1100010100101101011111010101100011111100100001110011001000100001
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'bz;
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
      64'b0110111001001100010001111010011111001001111111001000100001101101,
      64'b1111010101111100100011111110100111011111111001100111001001110100,
      64'b0010011011010111000011101110011111100110011111100000001011100011,
      64'b0000111110111111010011011000111101111010010010101111010001100111,
      64'b0011000101101100010100010111000101011101001101111111111101110101,
      64'b0010101111011000101101100000011011101010010000001101101101010111,
      64'b1011110101011010111110000010001010100101000110100101001110011100,
      64'b0001001011100100000111111010110000101100011110100001011011011011
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
      64'b1101100101101001001011011101000010010000011011011011001011110110,
      64'b1011011101101001100101010011000111011110111001010111101001100010,
      64'b1010000011011010001011011011000110101110110101110100101110100011,
      64'b0111101100001100100111010000000000001101001101010100000101000001,
      64'b0010111011100111100110110000111010001011011111000000101101100100,
      64'b0110100011000101000011011101000001110010001110011011100100111011,
      64'b1001100010001010111100101111000100100101011001100110110011101101,
      64'b1010001010010010010100100110110100110110010101000111011100011000
    };
    control_a = 1'b1;
    control_b = 1'bz;
    control_c = 1'bx;
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
      64'b0110100101111111010110111010000001000101001111101000000111101000,
      64'b1010000100011000110101101011111111001110111111101111010000000101,
      64'b0100110101100010100100010010011011000011110111011101001110101101,
      64'b1100010010011011000010011001110000100101001111110010010110000110,
      64'b0001001111100100110010101111011100001000010101000010010110101110,
      64'b0101001100100000001100010001010100000001110000001111101001000001,
      64'b0110100100001000110110100111110001100000111000100101100001111110,
      64'b0110100000011000100111111100010001011010111101011110001000010110
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
      64'b0110100101111111010110111010000001000101001111101000000111101000,
      64'b1010000100011000110101101011111111001110111111101111010000000101,
      64'b0100110101100010100100010010011011000011110111011101001110101101,
      64'b1100010010011011000010011001110000100101001111110010010110000110,
      64'b0001001111100100110010101111011100001000010101000010010110101110,
      64'b0101001100100000001100010001010100000001110000001111101001000001,
      64'b0110100100001000110110100111110001100000111000100101100001111110,
      64'b0110100000011000100111111100010001011010111101011110001000010110
    };
    control_a = 1'bx;
    control_b = 1'b0;
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
