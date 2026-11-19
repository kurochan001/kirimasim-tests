/*
:name: random_cross_case_0050
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0050;
  logic unsigned [0:510] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    control_a = 1'b1;
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
      64'b0111100111000010110000010001101010000001001001101100000100100110,
      64'b1110111001101010010100000000000000100110011010000010110110101000,
      64'b1011111000111101000001000001101000110101100100110011101100111001,
      64'b1110110010111111011100100110000111111100010011011100110000111101,
      64'b0111001011010010000011101110101011110110110001100110100100100011,
      64'b0011010101011010101010011000001110010011100100011110110110111100,
      64'b1100110001001111000011000101010010100010100110010011100000011010,
      63'b111111110010110000000010010101111011101101110011100100000001110
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
      64'b0111100111000010110000010001101010000001001001101100000100100110,
      64'b1110111001101010010100000000000000100110011010000010110110101000,
      64'b1011111000111101000001000001101000110101100100110011101100111001,
      64'b1110110010111111011100100110000111111100010011011100110000111101,
      64'b0111001011010010000011101110101011110110110001100110100100100011,
      64'b0011010101011010101010011000001110010011100100011110110110111100,
      64'b1100110001001111000011000101010010100010100110010011100000011010,
      63'b111111110010110000000010010101111011101101110011100100000001110
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
      64'b0010011100111110110010000111011111000010000100011011001000001011,
      64'b0111000010011111101111011001111010001111101111001101101101100000,
      64'b1000110100100000101110001110011000110001010111011001110011001001,
      64'b1100010011010010011101011101100000110100100011110111001101110110,
      64'b1011110101101000100111110100010100111011011101110001101101111110,
      64'b1001100110000011010111110101101000011011000010100001001000001110,
      64'b0111011010000111110000111110001000110001001110011111101110011100,
      63'b110010100000100001001001010010000001100100111101010110101111001
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
      64'b0010011100111110110010000111011111000010000100011011001000001011,
      64'b0111000010011111101111011001111010001111101111001101101101100000,
      64'b1000110100100000101110001110011000110001010111011001110011001001,
      64'b1100010011010010011101011101100000110100100011110111001101110110,
      64'b1011110101101000100111110100010100111011011101110001101101111110,
      64'b1001100110000011010111110101101000011011000010100001001000001110,
      64'b0111011010000111110000111110001000110001001110011111101110011100,
      63'b110010100000100001001001010010000001100100111101010110101111001
    };
    control_a = 1'b1;
    control_b = 1'b0;
    control_c = 1'b1;
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
      64'b0010101100100110101010011000000000001101000011101101101100011101,
      64'b0100001001000001111011100100111011011001100111100010111001110110,
      64'b1010001011111010101100110111110011100001111010010001101000110001,
      64'b0111000101000101000111110011010000011010011101110011000011110100,
      64'b1111100111011110111001100110101010011000101100100001010001110010,
      64'b1101111001110000100001010000110101000000001111010001011100010010,
      64'b1010100110000000100111110010110000000110010000011101000010000000,
      63'b000011110110111001100010010011110110111001000001010111011110010
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
      64'b0011010110100011000100101110100100111011010101100000111011110010,
      64'b0100100000100011010000100111110011111001110110110010111000011101,
      64'b1001101010000001111000010011111010111011111010010101001100100110,
      64'b1010010100010111101100111011000110000111110010011010100011100101,
      64'b0000111110110011100011011011111110000010111111011110011010101000,
      64'b1001111001111111100001101001101101101000000011001001100100001101,
      64'b0010101101101000000001100100011100010101011110101101101011011001,
      63'b000101010010110010110101111111001100101001011010111101011111000
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
