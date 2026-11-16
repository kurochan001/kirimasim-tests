/*
:name: random_cross_case_0093
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0093;
  logic [5:260] value;
  logic signed [31:0] index;
  bit [63:0] selected;
  logic single;
  initial begin
    value = 256'b1110111011010101001010111101111011110100000100010101001011111011000010010000000000010000000001000110000011000101110110100010100000110010101000101011101100100101101010011010011110101100000101001010101110010000100111100110110100100000000110010001101110000101;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000110001;
    value[index +: 64] = 64'b1010011011010000010001100100000100101101010111100001011100111110;
    selected = value[index +: 64];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000110001;
    selected = value[index +: 64];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 64] = 64'b0111010100011011001100100010010111101011011111011100100100000010;
    selected = value[index +: 64];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000110001;
    selected = value[index +: 64];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000101000101;
    selected = value[index +: 64];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111000100;
    selected = value[index +: 64];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000101000101;
    selected = value[index +: 64];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111000100;
    selected = value[index +: 64];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
