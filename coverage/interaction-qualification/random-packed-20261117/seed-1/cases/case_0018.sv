/*
:name: random_cross_case_0018
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0018;
  logic [0:64] value;
  logic signed [31:0] index;
  bit [30:0] selected;
  logic single;
  initial begin
    value = 65'b11111000100111011011101100001100111111101100110000011110111110101;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000010100;
    value[index +: 31] = 31'b1100100011100010100010010110101;
    selected = value[index +: 31];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000010100;
    selected = value[index +: 31];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001100000;
    value[index +: 31] = 31'b1111101010111010101101111011010;
    selected = value[index +: 31];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111100000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000z00000000000000000000010100;
    value[index +: 31] = 31'b0000110001111001010100001111101;
    selected = value[index +: 31];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001100000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000z0000000000010100;
    selected = value[index +: 31];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
