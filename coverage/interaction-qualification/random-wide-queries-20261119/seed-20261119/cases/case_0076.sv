/*
:name: random_cross_case_0076
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0076;
  logic unsigned [254:0] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b1010011010111010000000010011100111001001001001010001000100001111,
      64'b1111110011101111110111110111110110010001100111100010001000001000,
      64'b1110000111100010100100110011111101000100101011010101111011010110,
      63'b000110110000011110010010011010011100000111111111100011000001010
    };
    control_a = 1'bz;
    control_b = 1'bx;
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
      64'b0011001011010100001010111111000100001000101111011000100001000101,
      64'b1110001010011011000001101000000001100001111011001101001110011111,
      64'b0001010100101010110001001101011110001110011010111111110110010101,
      63'b000100111001000000010100101011101100100011111011111111001001011
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b11101011111001011011x0101000011110000000001000111010010110111011,
      64'b0110101101110001010010011000110000101100100111100010101101101100,
      64'b011011101000010101100110001000010101100001001111100z110111010000,
      63'b001000010011111001011000010001101001100001011100000001011000101
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b0111000100000110101101001010010101010011011110101010011001001011,
      64'b0000010100110011101101111110111100111101110101001101101100101011,
      64'b0101100001111110010110111101010011110001100010010111011001011110,
      63'b110100100001010111001110011001100000010001011011101110111000000
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
      64'b0110100111010011101000011111011011001100101010001000101100100110,
      64'b1111100101000110111101000001000011101100001110001000000100001011,
      64'b1111110110010000011010110011000100001100111101101111110110110111,
      63'b111000010000111000101101011011110110100100011100110110111111000
    };
    control_a = 1'bx;
    control_b = 1'b0;
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
      64'b1010010011100001011000110111000101001101101110010100110010001000,
      64'b0000011011010101001111011101010001001011110101011001011000101011,
      64'b1110100100111001010010000000101000001101011001000000000010101000,
      63'b100010101001001011001011011001011010001111001000100001001010011
    };
    control_a = 1'b1;
    control_b = 1'bx;
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
      64'b1101000000010110000010101010100111100110100010001000010101110100,
      64'b0011011011111010100100101010001000101010111010100010011011110011,
      64'b0100101110100100110011100011001110110111100110001000110000101000,
      63'b111100101011111001101000100101011001111110110001010110101011001
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
      64'b0000010111010010100000101011000111110100101110111000100010010011,
      64'b1111011101010100111111111000101100010011111111110010000101111101,
      64'b1011101101111000011100001011010011110111011010011000001111001100,
      63'b111111100011001101001001000010000011100111111000000001000001000
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
