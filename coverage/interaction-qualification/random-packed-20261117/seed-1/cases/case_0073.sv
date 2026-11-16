/*
:name: random_cross_case_0073
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0073;
  logic [512:0] value;
  logic signed [31:0] index;
  logic [63:0] selected;
  logic single;
  initial begin
    value = 513'b010111110111110000010011100010000111000010111110010101001101010001100111011100110011101001011101011100100011111101010010000100000001010110010000011101101100101000000011010101100010101100011100001110001100011100011001100110100101001110001011011011011010010100000010011011110111011101011101001010101101111010101111100100000000010000101110101011111010010000001010101101011011111100010001110000101001100111010010010110011001111011010011101111011101110111011011001011101101101101110111011110000000000111011100000111111;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000010101010;
    value[index +: 64] = 64'b0100011100100011111111110011000000110z0111111101100101100001100z;
    selected = value[index +: 64];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010101010;
    selected = value[index +: 64];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    selected = value[index +: 64];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000000000;
    selected = value[index +: 64];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    selected = value[index +: 64];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111110111111;
    selected = value[index +: 64];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000000000001010101x;
    value[index +: 64] = 64'b0001011110111110010101101101110000001010001000010001110110000011;
    selected = value[index +: 64];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000000000;
    value[index +: 64] = 64'b0z10101001011111x011011010000101000010100z0001111000111011001001;
    selected = value[index +: 64];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
