/*
:name: random_cross_case_0094
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0094;
  logic [5:516] value;
  logic signed [31:0] index;
  logic [6:0] selected;
  logic single;
  initial begin
    value = 512'b000110100000000001110110000110111110110000111101111000010x010000100000001000111001011101001101100101010101100010100011110100010111010100111010110001011x0100100101110011011000101011100101011100011011000011100011111101100001010001110110000011000101110100010001011010101101011000100011000011000101001000010010001001111000000110100011100110110001100101001100101000100100101011100101100110111101111000101111010000011110111x1011111010011110011111011000111101001101100000100001000111011000110011010000010101011110000000;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000011100111;
    value[index +: 7] = 7'b1111111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011100111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000x0000000000000011100111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000001100;
    selected = value[index +: 7];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000000100;
    value[index +: 7] = 7'b0111111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000x000000000000000000011100111;
    value[index +: 7] = 7'b000000x;
    selected = value[index +: 7];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000001100;
    selected = value[index +: 7];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011100111;
    value[index +: 7] = 7'b0101011;
    selected = value[index +: 7];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
