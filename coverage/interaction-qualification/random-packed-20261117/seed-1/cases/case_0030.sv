/*
:name: random_cross_case_0030
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0030;
  logic [32:0] value;
  logic signed [31:0] index;
  logic [6:0] selected;
  logic single;
  initial begin
    value = 33'b110010111010011000010000101001111;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000011000;
    value[index -: 7] = 7'b0000001;
    selected = value[index -: 7];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000011000;
    selected = value[index -: 7];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    selected = value[index -: 7];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    value[index -: 7] = 7'b0111111;
    selected = value[index -: 7];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000101000;
    selected = value[index -: 7];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000000000x0000000000011000;
    value[index -: 7] = 7'b0110010;
    selected = value[index -: 7];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000011000;
    value[index -: 7] = 7'b11001z0;
    selected = value[index -: 7];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111000;
    selected = value[index -: 7];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
