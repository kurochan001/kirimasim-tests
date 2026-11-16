/*
:name: random_cross_case_0020
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0020;
  logic [254:0] value;
  logic signed [31:0] index;
  bit [1:0] selected;
  logic single;
  initial begin
    value = 255'b100000011001111000000011100001100100001100001011000011001100100010011010100100111111111110011100111001111011000011111111101011101001110110010010101001000011100100101001100000001010000010100111010000101000101011001101110011010011010010011110001011110110110;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000010111111;
    value[index +: 2] = 2'b10;
    selected = value[index +: 2];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010111111;
    selected = value[index +: 2];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010111111;
    selected = value[index +: 2];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000100000001;
    selected = value[index +: 2];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010111111;
    selected = value[index +: 2];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010111z11;
    value[index +: 2] = 2'b11;
    selected = value[index +: 2];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sbx0000000000000000000000010111111;
    value[index +: 2] = 2'b10;
    selected = value[index +: 2];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000z0000010111111;
    selected = value[index +: 2];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
