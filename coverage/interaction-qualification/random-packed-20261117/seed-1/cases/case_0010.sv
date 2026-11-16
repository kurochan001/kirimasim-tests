/*
:name: random_cross_case_0010
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0010;
  logic [-1:255] value;
  logic signed [31:0] index;
  logic [30:0] selected;
  logic single;
  initial begin
    value = 257'b11111110011010010110011110001111010110110010011100001011100101111101111101010000000011100101000001110111111111110011101101110000001101000101100011111001111001001100001000101010001100000001001101101010110100111111010110010111010011001110100000010011010100111;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000010001100;
    value[index -: 31] = 31'b1100001000110100010001110010111;
    selected = value[index -: 31];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010001100;
    selected = value[index -: 31];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010001100;
    value[index -: 31] = 31'b1011011111001100101110100101100;
    selected = value[index -: 31];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011111111;
    selected = value[index -: 31];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000100011111;
    selected = value[index -: 31];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011111111;
    selected = value[index -: 31];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000010001100;
    selected = value[index -: 31];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111011111;
    value[index -: 31] = 31'b1111111111111111111111111111111;
    selected = value[index -: 31];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
