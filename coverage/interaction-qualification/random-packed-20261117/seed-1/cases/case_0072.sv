/*
:name: random_cross_case_0072
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0072;
  logic [515:5] value;
  logic signed [31:0] index;
  bit [30:0] selected;
  logic single;
  initial begin
    value = 511'b111101111111000000001111010010101001111000011011000101111000111101001111111011110110000111111100011011100000110111011100110011001111110001010000110100x011100101010100011010101101111001111100010110110110011000111001111000101111001101010011100111010110101110010101000111110111011010100000011101011101011110111000011001111101001010111111011001000001000111100100010011011010110100010001111101010110100101010z10111111000011010001111111011100110100001110001100101001111110010000111011101111110011001101001010000011110;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000111111110;
    value[index -: 31] = 31'b0011100100011000111001010011001;
    selected = value[index -: 31];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000111111110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000000011;
    selected = value[index -: 31];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0x000000000000000000000111111110;
    value[index -: 31] = 31'b0000000000000000000000000000001;
    selected = value[index -: 31];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000000000011111z110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111100101;
    selected = value[index -: 31];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001000100011;
    value[index -: 31] = 31'b1000000000000000000000000000000;
    selected = value[index -: 31];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000x000000000111111110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
