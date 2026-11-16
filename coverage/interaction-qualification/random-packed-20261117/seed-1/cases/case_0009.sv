/*
:name: random_cross_case_0009
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0009;
  logic [62:-1] value;
  logic signed [31:0] index;
  bit [62:0] selected;
  logic single;
  initial begin
    value = 64'b110011111000000x111101110101000101001000101101110101010101000001;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000000000;
    value[index +: 63] = 63'b000111100011101100100101111001011101000110001111010000000011101;
    selected = value[index +: 63];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000000;
    selected = value[index +: 63];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111110;
    value[index +: 63] = 63'b100011110011001100100100100000110z11111111001000100010000001110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001111110;
    value[index +: 63] = 63'b011111111111111111111111111111111111111111111111111111111111111;
    selected = value[index +: 63];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000z000000000000000;
    value[index +: 63] = 63'b001001011111111000111010000110001001000111001110111001010111010;
    selected = value[index +: 63];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000111110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001111110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000000000000000z000;
    value[index +: 63] = 63'b011010111000001011101101010111001111z01101001011010110101010010;
    selected = value[index +: 63];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
