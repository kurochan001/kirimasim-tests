/*
:name: random_cross_case_0053
:type: simulation
:lrm: 1800-2023 20.9 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0053;
  logic signed [0:254] source;
  logic [0:0] control_a, control_b, control_c;
  initial begin
    source = {
      64'b0111010010100100000110110111111011000110100100110111011101011101,
      64'b1011111001000010101111100010100100000101111010101011101000011101,
      64'b1000011101000001010000100101001110101011001011101000100101011010,
      63'b000110101101010100111110101011101100010111001111100011010000110
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
      64'b1111011010101011010011100101110101100000100010011011110011001011,
      64'b011010100000110100111110100100011z011011111001101111010111101101,
      64'b0110x11001010110111110111010011101011001011100000011110110101110,
      63'b00z100010111101110111001011010101110010000000111110011110100100
    };
    control_a = 1'b0;
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
      64'b1101100001100000101110010110101101001111010010101010101011001001,
      64'b1011101100100010001010010101101010000011110010010111110100100100,
      64'b0100110100010101010111110010100101101000010101010010001110100001,
      63'b010101011010010000101100001110011100000110101000000100111001100
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
      64'b1011111111101010101000110010001111010011010000111111010111101110,
      64'b1111110110111110010111100011000111110010100001110101001101000011,
      64'b011101010110101001011111101010100001100100001110110101001111x000,
      63'b001010011011011111110001101001000011101000000100001011010100000
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
      64'b0110000101010001010101001111010001011111001111001111000110000010,
      64'b1100100011110110010011011110011101011011101000001110011000101001,
      64'b0010000011101010010100001010011011010000100001011010011001011011,
      63'b101100010100001110101011001011011110101011111110101110110001101
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
      64'b1010011000101111011110011000111010111000100011010001110011101000,
      64'b1001011111101000110011001001111110100001011100110011100101111100,
      64'b0111111110011111110011001011000000110110101110011001010111011010,
      63'b001110011111011011010010110101001101011100011111000101000011111
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
      64'b0100110100001101110111010100111110011010001100100011010110101111,
      64'b0110111100000001101110100110011101111111111100010100101001010110,
      64'b0100100001100110000000100001111110000111011100110101100001100101,
      63'b000101011110101011010100010000000110111111011011100000111011011
    };
    control_a = 1'b0;
    control_b = 1'bz;
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
      64'b1001011111010001100011111101000101111111100010110000010101010101,
      64'b0110000001101011111100110111011001011100101011110110111010100100,
      64'b0101100101001110001010110010010111010000111111000111101010001010,
      63'b100101000010111000111110011000001000111101011011111110100110100
    };
    control_a = 1'b0;
    control_b = 1'b1;
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
