/*
:name: random_cross_case_0078
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0078;
  logic [69:5] value;
  logic signed [31:0] index;
  logic [64:0] selected;
  logic single;
  initial begin
    value = 65'b01110111011011000010001011100001000001101111011100101001111001000;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000000101;
    value[index +: 65] = 65'b00011001101111001010111010111110010011011101010000001101000000110;
    selected = value[index +: 65];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000101;
    selected = value[index +: 65];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000000001z1;
    selected = value[index +: 65];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 65] = 65'b10001100010001001001111100001101110011110100011100101101010110101;
    selected = value[index +: 65];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000101;
    selected = value[index +: 65];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000z000000000000000000101;
    selected = value[index +: 65];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000000001x1;
    value[index +: 65] = 65'b01111111111111111111111111111111111111111111111111111111111111111;
    selected = value[index +: 65];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000x0000000000000101;
    value[index +: 65] = 65'b11111111111111111111111111111111111111111111111z11111111111111111;
    selected = value[index +: 65];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
