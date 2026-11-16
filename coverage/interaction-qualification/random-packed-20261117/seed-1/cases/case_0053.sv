/*
:name: random_cross_case_0053
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0053;
  logic [516:5] value;
  logic signed [31:0] index;
  bit [0:0] selected;
  logic single;
  initial begin
    value = 512'b01000010010110010010100011111000010111000000111101011110011101011101001110111000011111100110011100011101101001001110111011110001111001001000100010010000100010001101001001000100000010001001110111111001000001000010100000011010011111100101100111011110000000100010010111011000100011011111110011111110001111101111010101111011000100000010101110111010011010010000010001100001001010011111000101001110011011011011011110010110001110000111111011000011000110011010000101011011011010011111110011000000100000111101101101110010;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000100010;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000100010;
    selected = value[index -: 1];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000011;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000000001000z0;
    selected = value[index -: 1];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000000110;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000000000000010x010;
    selected = value[index -: 1];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000000100;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000z00010;
    selected = value[index -: 1];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
