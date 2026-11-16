/*
:name: random_cross_case_0070
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0070;
  logic [-17:111] value;
  logic signed [31:0] index;
  logic [1:0] selected;
  logic single;
  initial begin
    value = 129'b010101011010001011111100001000001011010001000110100111000110101110010000010010011000010111001000110100100001000100110011001110001;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000110001;
    value[index -: 2] = 2'b0x;
    selected = value[index -: 2];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000110001;
    selected = value[index -: 2];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001110010;
    value[index -: 2] = 2'b11;
    selected = value[index -: 2];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000110001;
    selected = value[index -: 2];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb000000000z0000000000000000110001;
    selected = value[index -: 2];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000110001;
    selected = value[index -: 2];
    single = value[index];
    $display("step=5 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001101111;
    value[index -: 2] = 2'b11;
    selected = value[index -: 2];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000001110010;
    value[index -: 2] = 2'b01;
    selected = value[index -: 2];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
