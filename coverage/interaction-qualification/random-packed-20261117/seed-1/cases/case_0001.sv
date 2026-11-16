/*
:name: random_cross_case_0001
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0001;
  logic [-17:47] value;
  logic signed [31:0] index;
  logic [30:0] selected;
  logic single;
  initial begin
    value = 65'b01z01101100001011110010100001011011110111001011110010101110111000;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000010000;
    value[index +: 31] = 31'b1010100000011010101001000000101;
    selected = value[index +: 31];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000010000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000x0000000010000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000x00000010000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111001111;
    value[index +: 31] = 31'b1111111111111111111111111111111;
    selected = value[index +: 31];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000101111;
    selected = value[index +: 31];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000z0000000000000010000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000010000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
