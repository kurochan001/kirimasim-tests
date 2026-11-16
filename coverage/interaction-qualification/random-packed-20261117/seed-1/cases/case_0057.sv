/*
:name: random_cross_case_0057
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0057;
  logic [259:5] value;
  logic signed [31:0] index;
  logic [64:0] selected;
  logic single;
  initial begin
    value = 255'b101100111001011010010011011100111000101101101000010110101101010101000100110011101000001101001110011111110010000011010010001000011111100111111111001101011111010001110111001000010010101110110001001101001011110110100010101100001010011110010111100000011010100;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000000101100;
    value[index +: 65] = 65'b110101100000z0110010110001001000011110001100001x0000001001z001010;
    selected = value[index +: 65];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000101100;
    selected = value[index +: 65];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000000100;
    value[index +: 65] = 65'b0111110001000110z001110100001000110110100100010011x10000001001001;
    selected = value[index +: 65];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000101000101;
    value[index +: 65] = 65'b00000z11111010101011100100101100111001101101000001100001011110100;
    selected = value[index +: 65];
    single = value[index];
    $display("step=3 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000000101100;
    selected = value[index +: 65];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000101000101;
    value[index +: 65] = 65'b000001010110111011000110110000101110001z0111110000011101110011010;
    selected = value[index +: 65];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000100000011;
    value[index +: 65] = 65'b10101101110001001111100011110001110011110111010001100100000011101;
    selected = value[index +: 65];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb0000000000z000000000000000101100;
    selected = value[index +: 65];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
