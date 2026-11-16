/*
:name: random_cross_case_0004
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0004;
  logic [67:5] value;
  logic signed [31:0] index;
  bit [1:0] selected;
  logic single;
  initial begin
    value = 63'b010100000011001100101100101110001100100001010100011010101111100;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000111001;
    value[index +: 2] = 2'b0x;
    selected = value[index +: 2];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111001;
    selected = value[index +: 2];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00z00000000000000000000000111001;
    value[index +: 2] = 2'b11;
    selected = value[index +: 2];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 2] = 2'b00;
    selected = value[index +: 2];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 2] = 2'b11;
    selected = value[index +: 2];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000z0000000111001;
    selected = value[index +: 2];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000001110x1;
    selected = value[index +: 2];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111001;
    value[index +: 2] = 2'b0z;
    selected = value[index +: 2];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
