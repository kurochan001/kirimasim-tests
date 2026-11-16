/*
:name: random_cross_case_0049
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1 6.11.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0049;
  logic [-1:510] value;
  logic signed [31:0] index;
  logic [64:0] selected;
  logic single;
  initial begin
    value = 512'b00010110111110100111101011001001101001101100000100000011101100101110110000110000010100000011001100001000110001011000010001010110011111010001110011111000011100001001011110101010100011010100010001111111001110000010001010100001101100010110101010111110100100000011110000101010001011110010000100111001111011110010101000100100001011001001010100101010010011111100011101110111100111011001101001011011110011101111010100000101000001010100111010010100001000100010001100011000001101011000110010011000001111000001010110110000;
    $display("initial=%b", value);
    index = 32'sb00000000000000000000000011000011;
    value[index +: 65] = 65'bx1101111100001010010001111111100110110101111z00111110000000001000;
    selected = value[index +: 65];
    single = value[index];
    $display("step=0 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000000011000011;
    selected = value[index +: 65];
    single = value[index];
    $display("step=1 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index +: 65] = 65'b00101011100100000100001010010110111000000111000110100001000110010;
    selected = value[index +: 65];
    single = value[index];
    $display("step=2 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111110111101;
    selected = value[index +: 65];
    single = value[index];
    $display("step=3 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb00000000000000000000001001000000;
    selected = value[index +: 65];
    single = value[index];
    $display("step=4 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index +: 65] = 65'b11111100001010100000000010110010000101010001011001010011100010001;
    selected = value[index +: 65];
    single = value[index];
    $display("step=5 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    value[index +: 65] = 65'b01000010110101001011010111111100110010101101111110101000010010100;
    selected = value[index +: 65];
    single = value[index];
    $display("step=6 kind=write index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    index = 32'sb11111111111111111111111111111110;
    selected = value[index +: 65];
    single = value[index];
    $display("step=7 kind=read index=%b whole=%b slice=%b bit=%b",
             index, value, selected, single);
    $finish;
  end
endmodule
