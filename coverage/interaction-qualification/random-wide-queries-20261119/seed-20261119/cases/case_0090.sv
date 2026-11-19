/*
:name: random_cross_case_0090
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0090;
  logic unsigned [510:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0110100101111011111110010101001001111010001001111000010100100110,
      64'b0101100001110010100010011110010101110110100110000000011000000000,
      64'b0101011100011001010010010110000000001000110111111000111111010011,
      64'b1001001011010000010010101101011100101010000111110111011011011000,
      64'b1111000110000101000101001110010011111001011000101111010110011110,
      64'b1111000011100001101010000000101011111110101011010011101111111000,
      64'b0111010010101110100100001100111001011011010010101101011111000000,
      63'b000001110001001001100001101110001010111000000010011111010110100
    };
    control_a = 1'b1;
    control_b = 1'b1;
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
      64'b0111111010111010010110111100001101000100011101010010010010011010,
      64'b0000111100001001110100101101001101010011111010110011101011000101,
      64'b0100100111100110101111110100100111001001101000000100110111001101,
      64'b1010111011001110011010101111101001110100011010011111010000100001,
      64'b0111001101111000011100011111111001100010100110100011111001010010,
      64'b0010010011100111001100001000111101000011111001110000101000001010,
      64'b1110100001101111011101010010111101000110011101110110011111000101,
      63'b111000101111110010011101101110001000000110001010011101000101101
    };
    control_a = 1'b0;
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
      64'b0111111010111010010110111100001101000100011101010010010010011010,
      64'b0000111100001001110100101101001101010011111010110011101011000101,
      64'b0100100111100110101111110100100111001001101000000100110111001101,
      64'b1010111011001110011010101111101001110100011010011111010000100001,
      64'b0111001101111000011100011111111001100010100110100011111001010010,
      64'b0010010011100111001100001000111101000011111001110000101000001010,
      64'b1110100001101111011101010010111101000110011101110110011111000101,
      63'b111000101111110010011101101110001000000110001010011101000101101
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
      64'b1110100110110101000100011011110111011100001111000111011100000001,
      64'b1100000100100101101011011001111100110101101000011011x00110001010,
      64'b0101111000100101110010100010100000001000101110101110010011100110,
      64'b0100111100111000101010010100010010001101010000010101101101110011,
      64'b0011110001101011011001111001101011100010111000100001100010101001,
      64'b1001110011101110101010111101011111100010100001010001001111001011,
      64'b00111110000011110111010101001001101001010100001001110101x0000000,
      63'b001011001110000011011101101001101000001101110010100101011000110
    };
    control_a = 1'bx;
    control_b = 1'bx;
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
      64'b0100100001001011111001101110001010011100001100011101011100110011,
      64'b0100010111001000011011100000100001000110010001010110001001011001,
      64'b110001111011000001010z010100100010000111011100110010000011111000,
      64'b11z0001111111000001001010001101110000000010101010001001001001101,
      64'b1011101000001100001010110101011000100000011101000111101111010010,
      64'b1100000101101110110001001000000111011000001000110010001100111z01,
      64'b1011100001001110100001011000001101111100001011001110101011000111,
      63'b011000000100001100010000100010011111100000000000001010111110110
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
      64'b0100100001001011111001101110001010011100001100011101011100110011,
      64'b0100010111001000011011100000100001000110010001010110001001011001,
      64'b110001111011000001010z010100100010000111011100110010000011111000,
      64'b11z0001111111000001001010001101110000000010101010001001001001101,
      64'b1011101000001100001010110101011000100000011101000111101111010010,
      64'b1100000101101110110001001000000111011000001000110010001100111z01,
      64'b1011100001001110100001011000001101111100001011001110101011000111,
      63'b011000000100001100010000100010011111100000000000001010111110110
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
      64'b1010100000101011100101111110101010101100110000010011111001000100,
      64'b0110011100000000111001101111111000011000100111001011011101111001,
      64'b1111000100110111011111110001110001010100101100100100100100100101,
      64'b1111001100010111001110110110011001110110110100000101010100101010,
      64'b0001110100111011100110001110011100111001111001110011100100010000,
      64'b0011100100010000011011001100101000100001000110110001011110111110,
      64'b1101111001111000111000001100010011000011001001111011011110001010,
      63'b111000001001111011000101111100100011011011110100101100000100010
    };
    control_a = 1'b1;
    control_b = 1'b1;
    control_c = 1'b1;
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
      64'b100111100110001010110110011110111000011011010111000001000x111001,
      64'b1111100010011110110000011111001011001000101111011100011010000010,
      64'b0001111001111111011000101100001001010011000000111011110000001101,
      64'b1010011100010001110111111100110000100011011010010101100110010100,
      64'b1011110100100011101011001110110111100011011100100111110000101110,
      64'b0110000110011011001100000101000010001001001011100111001101001001,
      64'b0001100101101111110001100010110111101000100111111100101011110010,
      63'b0110111000000110000001001z11z1001101011111000111110101011100000
    };
    control_a = 1'b1;
    control_b = 1'bz;
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
