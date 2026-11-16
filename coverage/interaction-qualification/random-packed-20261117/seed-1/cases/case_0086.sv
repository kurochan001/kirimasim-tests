/*
:name: random_cross_case_0086
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0086;
  logic [2:0] value;
  logic signed [31:0] index;
  logic [0:0] selected;
  logic single;
  initial begin
    value = 3'b001;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000000010;
    value[index -: 1] = 1'bz;
    selected = value[index -: 1];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000010;
    selected = value[index -: 1];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    selected = value[index -: 1];
    single = value[index];
    $display("step=2 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000010;
    value[index -: 1] = 1'bz;
    selected = value[index -: 1];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000x00000000000000000000010;
    value[index -: 1] = 1'bx;
    selected = value[index -: 1];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000x000000000000000000000010;
    selected = value[index -: 1];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000x000000000000000000000010;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    selected = value[index -: 1];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
