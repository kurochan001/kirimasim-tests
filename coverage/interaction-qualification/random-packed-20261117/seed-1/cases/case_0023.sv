/*
:name: random_cross_case_0023
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0023;
  logic [253:-1] value;
  logic signed [31:0] index;
  bit [63:0] selected;
  logic single;
  initial begin
    value = 255'b001011100110001101011101000011011000010010010000101111010101010100110110001000101000011001100100010110100011000101111100010111101010110101000010000110110011011001111011101110110011000010110010111100001110101111001110011111110011001010110001000000011111011;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000001000000;
    value[index -: 64] = 64'b1110001010011001110101110101111011101101000000100001001000011101;
    selected = value[index -: 64];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000000;
    selected = value[index -: 64];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001000000;
    selected = value[index -: 64];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011111101;
    value[index -: 64] = 64'b0100011001001001110111101010010110000010000011010011000100011010;
    selected = value[index -: 64];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000x0000000001000000;
    selected = value[index -: 64];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index -: 64] = 64'b0110100001100000001z00101011100000z10001111111111101z11111111110;
    selected = value[index -: 64];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011111101;
    selected = value[index -: 64];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    selected = value[index -: 64];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
