/*
:name: random_cross_case_0071
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0071;
  logic [494:-17] value;
  logic signed [31:0] index;
  logic [62:0] selected;
  logic single;
  initial begin
    value = 512'b0001101100000100101000001000101000110000100001101110101110100101110001000010100110111010110100111101000000001101111000101000011011000000101100111000110111010001010111101100110011110110000110011111110001100100111000010101111010110000001011010110101001001111010111100111100111001010010000011011000000100010110011101100011001101101000101111z011100010z00010001001010110100010110010001000000111010111001111110111001101110111010001001111110000100000111111010010010001011011110001001000101000010011100101101101101111011;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000101011110;
    value[index +: 63] = 63'b111110100001110011111111111001000110010111101100100100100001111;
    selected = value[index +: 63];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000101011110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111101110;
    value[index +: 63] = 63'b01000001101001001111011101101110z0110001101011000x0111111001010;
    selected = value[index +: 63];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000001010111z0;
    value[index +: 63] = 63'b001110000z100000100100101x1110100011001100101101001001011001101;
    selected = value[index +: 63];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000z000000000101011110;
    value[index +: 63] = 63'b010111011001111001000100000001101000101110001010110011011000111;
    selected = value[index +: 63];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000111101110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000101110;
    value[index +: 63] = 63'b000000000000000000000000000000000000000000000000000000000000001;
    selected = value[index +: 63];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111110101111;
    value[index +: 63] = 63'b111010001100101000011101111001100000100010010111010000010100101;
    selected = value[index +: 63];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
