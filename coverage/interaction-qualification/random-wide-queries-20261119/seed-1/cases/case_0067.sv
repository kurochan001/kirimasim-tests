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
  logic unsigned [0:256] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0100111000101111011100111000101111101100101111001000110011110101,
      64'b0001111001010010100101001010001000011011001100101100001z1000110x,
      64'b0000111111101101000101010110110010110011111101101010111001000101,
      64'b0010110011010111000000001000100111101000001011011010100110010110,
      1'b0
    };
    control_a = 1'bz;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b0100111000101111011100111000101111101100101111001000110011110101,
      64'b0001111001010010100101001010001000011011001100101100001z1000110x,
      64'b0000111111101101000101010110110010110011111101101010111001000101,
      64'b0010110011010111000000001000100111101000001011011010100110010110,
      1'b0
    };
    control_a = 1'bz;
    control_b = 1'b1;
    control_c = 1'bz;
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
      64'b1111011000101111110110010110010000010101011110110001010010001110,
      64'b1110001000011001100001111101001011110000000100101111010100111110,
      64'b0001110100111000000101111101000111111000011100111110110010000100,
      64'b0100110001000001111011000010101100000010101011111001110001101011,
      1'b1
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
      64'b1100100110111011010010100100111101100010100011110001111101101111,
      64'b0100110010011101110101111100111110001101110011111101100010011011,
      64'b1111100101001101010110010000001001100001011000001000011010001000,
      64'b0000101011000100010101111000000001001111010010101001100110100001,
      1'b1
    };
    control_a = 1'bz;
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
      64'b1110111011001110100111000101110110101010001011010110101110100001,
      64'b0010111010100001100010000100111001011110110010010010000000100100,
      64'b1000011101001001001101101101110101010011101100100100001000110010,
      64'b1110101110001100010011110010110100101101101001101110111100001111,
      1'b0
    };
    control_a = 1'bx;
    control_b = 1'bz;
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
      64'b1110111011001110100111000101110110101010001011010110101110100001,
      64'b0010111010100001100010000100111001011110110010010010000000100100,
      64'b1000011101001001001101101101110101010011101100100100001000110010,
      64'b1110101110001100010011110010110100101101101001101110111100001111,
      1'b0
    };
    control_a = 1'bx;
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
      64'b0010001101001110110110110000011001010111101001100101101010000100,
      64'b1100001101110010011010001100010110110111100000001000110110000100,
      64'b0111000101010111110111110011010011111101000010111101011101101010,
      64'b0010010000110001111000001111000100110110000010001101010010111011,
      1'b1
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
      64'b011z110101010101101011101111001101111001110110000011111110000010,
      64'b0110001101001000100011100110101001010101100010000000111101000100,
      64'b1111100010110111000111001001000110000111110101111010100111011101,
      64'b1011110010110000000010101100001111001000001100000101010000101111,
      1'b0
    };
    control_a = 1'bx;
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
