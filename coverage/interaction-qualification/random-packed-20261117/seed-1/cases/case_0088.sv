/*
:name: random_cross_case_0088
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0088;
  logic [-17:14] value;
  logic signed [31:0] index;
  bit [7:0] selected;
  logic single;
  initial begin
    value = 32'b00110111000010101000001000001111;
    $display("initial=%b", value);
    index = 32'sb11111111111111111111111111111111;
    value[index -: 8] = 8'b11011100;
    selected = value[index -: 8];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    selected = value[index -: 8];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111100110;
    value[index -: 8] = 8'bz1z0000x;
    selected = value[index -: 8];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111z11111;
    value[index -: 8] = 8'b01100000;
    selected = value[index -: 8];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111101110;
    value[index -: 8] = 8'b00000011;
    selected = value[index -: 8];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000001110;
    selected = value[index -: 8];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111100110;
    selected = value[index -: 8];
    single = value[index];
    $display("step=6 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb1111111z111111111111111111111111;
    value[index -: 8] = 8'b10110000;
    selected = value[index -: 8];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
