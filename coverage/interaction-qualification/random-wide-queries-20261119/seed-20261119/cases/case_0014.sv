/*
:name: random_cross_case_0014
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0014;
  logic unsigned [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'bz;
    control_b = 1'b0;
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
      64'b0111001011100011101111100000110001100010001011100000001110000101,
      64'b0011111001111100001111110001000011110000001011100001110110010101,
      64'b1100111100100011101000101101111000101011101100110101100101011010,
      64'b1010001000001101011111101001001110001100110100100110010100000100,
      64'b0011110111101101000011101100111011110101000110000000001011001101,
      64'b0011010100010110100001011000110000100111110011011110100110110001,
      64'b1000001011001000001000001010010010000011101101010001100010100011,
      63'b110001101110100110110101110111000000100100110011010001010110111
    };
    control_a = 1'b1;
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
      64'b0111001011100011101111100000110001100010001011100000001110000101,
      64'b0011111001111100001111110001000011110000001011100001110110010101,
      64'b1100111100100011101000101101111000101011101100110101100101011010,
      64'b1010001000001101011111101001001110001100110100100110010100000100,
      64'b0011110111101101000011101100111011110101000110000000001011001101,
      64'b0011010100010110100001011000110000100111110011011110100110110001,
      64'b1000001011001000001000001010010010000011101101010001100010100011,
      63'b110001101110100110110101110111000000100100110011010001010110111
    };
    control_a = 1'b1;
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
      64'b0111001011100011101111100000110001100010001011100000001110000101,
      64'b0011111001111100001111110001000011110000001011100001110110010101,
      64'b1100111100100011101000101101111000101011101100110101100101011010,
      64'b1010001000001101011111101001001110001100110100100110010100000100,
      64'b0011110111101101000011101100111011110101000110000000001011001101,
      64'b0011010100010110100001011000110000100111110011011110100110110001,
      64'b1000001011001000001000001010010010000011101101010001100010100011,
      63'b110001101110100110110101110111000000100100110011010001010110111
    };
    control_a = 1'b1;
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
      64'b0011100001010010100111100000111000010111110110000010000100011101,
      64'b1000100011100010000000011100000010010001111100011111111111001010,
      64'b1010000101111100100110011110000111110110010100110000110000011111,
      64'b0011101111101011000000001000000001011100010101000000000100101001,
      64'b0110011101010101111001111111111001101000010000100010100001000011,
      64'b1100000001000010110111011000011111011011011001011111000001010111,
      64'b0101110101101101100001011111011010100100101111011101011010110011,
      63'b000011001001100000011011010101110110000000010110110100011010000
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'bx;
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
      64'b1110000011000001010110011100001101010101110001011001010110001000,
      64'b1100000101100110111011000111101000010101100100011110111001110111,
      64'b0111000100010111100010110000011110011011111111000011110011011100,
      64'b0010000010000110000001110101101111011101011111010110110111000100,
      64'b0111010111011001011000110110001001010110010001010110001111101101,
      64'b1101011011011001100000101010010101000010011110000011011010011111,
      64'b1000101110111100010100000001101011010001000100110010000010010111,
      63'b111111101111100000110100111011011110011100001010100011100001011
    };
    control_a = 1'bx;
    control_b = 1'bz;
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
      64'b1010111010101111100101000111100000111001000001010000110111100001,
      64'b0100011010100111011100101011010001101101011101001001111011101000,
      64'b1010100011010101001100110001110111000000100110101000111100000000,
      64'b0100111101101000110111110001101011100000101000101001101000011111,
      64'b0110011101010001010011001110110101001001001111111001011001101011,
      64'b0011010010100010000100110111101011011000000101001010001000010001,
      64'b1001111000011101000001010111000100101010101001010110100001110001,
      63'b100111101101111011110011100100011000001011010010100100010111001
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
