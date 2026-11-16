/*
:name: random_cross_case_0063
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0063;
  logic [5:259] value;
  logic signed [31:0] index;
  bit [1:0] selected;
  logic single;
  initial begin
    value = 255'b011001100000000000011001000101101101001000110000110100101110101011000001010101000110111111000011011011100001000001111111001010011010111110110101110111100111001100110101111000000011000010110010000101001100011111011110001011011010110101000001011101100100001;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000001001;
    value[index +: 2] = 2'b00;
    selected = value[index +: 2];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000001001;
    selected = value[index +: 2];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000100000011;
    value[index +: 2] = 2'b10;
    selected = value[index +: 2];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000001001;
    selected = value[index +: 2];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000z0000001001;
    value[index +: 2] = 2'b0x;
    selected = value[index +: 2];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000010;
    value[index +: 2] = 2'bzx;
    selected = value[index +: 2];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000010;
    value[index +: 2] = 2'b10;
    selected = value[index +: 2];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000z000000000001001;
    selected = value[index +: 2];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
