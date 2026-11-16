/*
:name: random_cross_case_0085
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0085;
  logic [-1:-1] value;
  logic signed [31:0] index;
  bit [0:0] selected;
  logic single;
  initial begin
    value = 1'bx;
    $display("initial=%b", value);
    index = 32'sb11111111111111111111111111111111;
    value[index -: 1] = 1'b0;
    selected = value[index -: 1];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    selected = value[index -: 1];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb111111111111111111111111z1111111;
    value[index -: 1] = 1'b0;
    selected = value[index -: 1];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=4 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111111;
    value[index -: 1] = 1'b0;
    selected = value[index -: 1];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb1111111111111111111111111111z111;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index -: 1] = 1'b1;
    selected = value[index -: 1];
    single = value[index];
    $display("step=7 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
