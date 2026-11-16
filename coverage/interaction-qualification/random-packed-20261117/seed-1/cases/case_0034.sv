/*
:name: random_cross_case_0034
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0034;
  logic [37:5] value;
  logic signed [31:0] index;
  bit [32:0] selected;
  logic single;
  initial begin
    value = 33'b100011101011000010001010100111010;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000000101;
    value[index +: 33] = 33'b001101001111011101010101101001010;
    selected = value[index +: 33];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000101;
    selected = value[index +: 33];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000100101;
    selected = value[index +: 33];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 33] = 33'b111111111111111111111111111111111;
    selected = value[index +: 33];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000101;
    selected = value[index +: 33];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000z000000000000000101;
    value[index +: 33] = 33'b101010110111101000100111110000001;
    selected = value[index +: 33];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000z00000000000000000000101;
    value[index +: 33] = 33'b01101000001101010111z010110000111;
    selected = value[index +: 33];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000x000000000000000000101;
    value[index +: 33] = 33'b100101111001100101110101111011011;
    selected = value[index +: 33];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
