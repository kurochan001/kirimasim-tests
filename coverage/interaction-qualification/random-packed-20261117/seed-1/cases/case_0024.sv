/*
:name: random_cross_case_0024
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0024;
  logic [239:-17] value;
  logic signed [31:0] index;
  bit [6:0] selected;
  logic single;
  initial begin
    value = 257'b001011000110101101000x011110000000101010001110000000001110010001100011111z010010011011111000000110000010111101011100000010110010101100001000110000100010001100001100001001011011111010001010110111011100000000001000000001100101010011001111001000011111010010100;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000111111;
    value[index +: 7] = 7'b0111101;
    selected = value[index +: 7];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111111;
    value[index +: 7] = 7'b1011001;
    selected = value[index +: 7];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111101110;
    value[index +: 7] = 7'b0111111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000x000000000000000000111111;
    value[index +: 7] = 7'b1000000;
    selected = value[index +: 7];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111100111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111111;
    value[index +: 7] = 7'b1101001;
    selected = value[index +: 7];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111111;
    value[index +: 7] = 7'b1010111;
    selected = value[index +: 7];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
