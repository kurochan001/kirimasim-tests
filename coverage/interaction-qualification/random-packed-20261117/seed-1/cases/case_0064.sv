/*
:name: random_cross_case_0064
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0064;
  logic [0:32] value;
  logic signed [31:0] index;
  logic [7:0] selected;
  logic single;
  initial begin
    value = 33'b101000011100100111001011110001101;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000010111;
    value[index +: 8] = 8'b00101001;
    selected = value[index +: 8];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000010111;
    selected = value[index +: 8];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    value[index +: 8] = 8'b11111101;
    selected = value[index +: 8];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000000101x1;
    selected = value[index +: 8];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000100000;
    selected = value[index +: 8];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000000000000z010111;
    selected = value[index +: 8];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000100000;
    value[index +: 8] = 8'b10001010;
    selected = value[index +: 8];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000100000;
    value[index +: 8] = 8'b11111111;
    selected = value[index +: 8];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
