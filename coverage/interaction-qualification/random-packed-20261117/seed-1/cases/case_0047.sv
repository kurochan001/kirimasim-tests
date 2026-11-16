/*
:name: random_cross_case_0047
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0047;
  logic [510:-1] value;
  logic signed [31:0] index;
  logic [62:0] selected;
  logic single;
  initial begin
    value = 512'b01111101010001100001010011110110000110011010111010011010000101110010110010010100110011011101001001001010001001000101111100111100110000001100010001000001101110101101100101100110000000001001101001010000001010100101011110100011011000110001000000011101100100111001010011001000101001100010110010100100110000000101000011101101010011011001011110110101101000001011011001011110000101000001110110111101101001001111010110101111010011010011101010101100111101110111001000000011110001001011011110110111011111000010101110110101;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000001000101;
    value[index +: 63] = 63'b110010010111110111110011101101100111001100101111100110010111010;
    selected = value[index +: 63];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000101;
    selected = value[index +: 63];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111110111111;
    value[index +: 63] = 63'b000000000000000000000000000000000000000000000000000000000000000;
    selected = value[index +: 63];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000101;
    selected = value[index +: 63];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000111110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000111111110;
    selected = value[index +: 63];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000101;
    selected = value[index +: 63];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
