/*
:name: random_cross_case_0003
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0003;
  typedef struct packed unsigned {
    bit unsigned [254:0] f0;
    bit signed [0:0] f1;
    bit unsigned [256:0] f2;
  } record_t;
  record_t value;
  logic [257:0] extended0;
  logic [3:0] extended1;
  logic [259:0] extended2;
  initial begin
    value = 513'b011110011110001100110100010110001000101001110110100100000010010011001000011100011001011101000001000111001010001010101001101010011100011001101111011001110011101011001001000011110101111001110011000010011100111110111000100010000011000001100011100110100100101001110110100011001001011011010001111001000001010101101010110001001100101100110000001011101100101011001110101111100110101001111011000011101010111000100100000100101010101110100010100001110011001010010000000000001001000010111000011010100000110001111011110101111;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = 1'b0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=0 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f2;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=1 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value << 65;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 255'b001101101000100100011110111010101101101111000101011001100111011010101101100111011111000111011000010001010011000101111011011000111001000010111110000110101000110100100000011011100010101110010001111110010101111010010100101101011001111101001101100111100111110;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 513'b000001010010101111010111100110101101110011011100000010110001101010001000010111000111111100010001000111100000100010110010101001001100010000101001101000010000001101111110001001010010001000111111011000100100110000111001011000110011111000000100000011011101101111000100011001001110110101000101010101111111001100111001111110110110101100111001100001000001110011110000111100100100001010101011111101010000110010000101100101010010110000000011010001010100111011000110000110001010000000110110111101110101000111101011010000101;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 255'b010111100011110001010011011011001000001010110101100010000000000110101110101010001110000100000001000000110000001111010000100110110011001101001110100100100100100010101010000110101000000110111011100001001010101011100000011010101000100100111000100110010100010;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = 257'b00110100000010110110111100000011000001010000001001110111101001000010100100001101100011000101010010001101010110001110001000010111111000101001011110100111110111110100011010001100110000010000111111001010001111000000100001101100000100010101001100000100010111111;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
