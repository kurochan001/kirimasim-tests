/*
:name: random_cross_case_0026
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0026;
  logic [15:-17] value;
  logic signed [31:0] index;
  logic [30:0] selected;
  logic single;
  initial begin
    value = 33'b100000111110001100001010001001000;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000001110;
    value[index -: 31] = 31'b01x00111001z11011101z0010011101;
    selected = value[index -: 31];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000001110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111001111;
    value[index -: 31] = 31'b0001001100001000011001011110010;
    selected = value[index -: 31];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000x000000000000001110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000000000z0000001110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000001111;
    value[index -: 31] = 31'b1101100101011111001111011010000;
    selected = value[index -: 31];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000000000000000000000z110;
    selected = value[index -: 31];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000001110;
    value[index -: 31] = 31'bz1001011100110000100100011011xx;
    selected = value[index -: 31];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
