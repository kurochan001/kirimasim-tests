/*
:name: random_cross_case_0050
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0050;
  logic [-1:255] value;
  logic signed [31:0] index;
  bit [62:0] selected;
  logic single;
  initial begin
    value = 257'b10101111000111000010011111111100101101111101010101011100010101001011010010101000010011001111110010110001000111010100100111011101011000000001010001101001010101110111011101011000010110101111100100101100101010001010011011101110110100101111001101010100100110001;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000010000100;
    value[index -: 63] = 63'b000100001001101000011111110010011111011101100011001000010111111;
    selected = value[index -: 63];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010000100;
    selected = value[index -: 63];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111110111111;
    value[index -: 63] = 63'b001100100110111101001000100100011100011001000010010000011101011;
    selected = value[index -: 63];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index -: 63] = 63'b010001000101100000111011011000100001010110010101101101001001010;
    selected = value[index -: 63];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010000100;
    value[index -: 63] = 63'b100000000000000000000000000000000000000000000000000000000000000;
    selected = value[index -: 63];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010000100;
    selected = value[index -: 63];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000100001x0;
    selected = value[index -: 63];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    selected = value[index -: 63];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
