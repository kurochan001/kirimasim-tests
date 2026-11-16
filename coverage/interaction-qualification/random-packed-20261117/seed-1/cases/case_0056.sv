/*
:name: random_cross_case_0056
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0056;
  logic [510:-1] value;
  logic signed [31:0] index;
  bit [32:0] selected;
  logic single;
  initial begin
    value = 512'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000001111011;
    value[index +: 33] = 33'b010010011001011110110010111000010;
    selected = value[index +: 33];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001111011;
    selected = value[index +: 33];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111011101;
    selected = value[index +: 33];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000011x1011;
    selected = value[index +: 33];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000100000;
    selected = value[index +: 33];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0z000000000000000000000001111011;
    selected = value[index +: 33];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000z0000000000000001111011;
    selected = value[index +: 33];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index +: 33] = 33'b101100011011111011000111111101000;
    selected = value[index +: 33];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
