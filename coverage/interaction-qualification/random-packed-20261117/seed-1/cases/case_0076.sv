/*
:name: random_cross_case_0076
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0076;
  logic [30:0] value;
  logic signed [31:0] index;
  logic [30:0] selected;
  logic single;
  initial begin
    value = 31'b1111000001101010011100100111101;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000000000;
    value[index +: 31] = 31'b1011011001010001010010000011111;
    selected = value[index +: 31];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000011110;
    selected = value[index +: 31];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111110;
    value[index +: 31] = 31'b100010z101111111010011110011000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    selected = value[index +: 31];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    value[index +: 31] = 31'b0111111111111111111111111111111;
    selected = value[index +: 31];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111100000;
    selected = value[index +: 31];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000011110;
    value[index +: 31] = 31'b011000000010000111011101001x111;
    selected = value[index +: 31];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
