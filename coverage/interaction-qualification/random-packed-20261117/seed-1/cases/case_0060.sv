/*
:name: random_cross_case_0060
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0060;
  logic [131:5] value;
  logic signed [31:0] index;
  bit [0:0] selected;
  logic single;
  initial begin
    value = 127'b0001100101010011011011101011100110011010000010101110000x0111z10001001101010x101111101101101011000000011110011011010101011001100;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000010101;
    value[index +: 1] = 1'b1;
    selected = value[index +: 1];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000010101;
    selected = value[index +: 1];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010000101;
    selected = value[index +: 1];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010000101;
    value[index +: 1] = 1'b0;
    selected = value[index +: 1];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000x0010101;
    selected = value[index +: 1];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010000101;
    value[index +: 1] = 1'b0;
    selected = value[index +: 1];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 1] = 1'b0;
    selected = value[index +: 1];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000010101;
    selected = value[index +: 1];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
