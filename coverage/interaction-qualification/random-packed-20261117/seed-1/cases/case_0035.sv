/*
:name: random_cross_case_0035
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0035;
  typedef struct packed signed {
    bit signed [254:0] f0;
    bit unsigned [0:0] f1;
    bit unsigned [256:0] f2;
  } record_t;
  record_t value;
  logic [257:0] extended0;
  logic [3:0] extended1;
  logic [259:0] extended2;
  initial begin
    value = 513'b001000010010101111010111001011011100010100010101001110000010101111001101101111101011000110000110101100101011111000001000110111111110011100100001010011110110111011100001111010011010101100001111110010000001111100000011110110101010011010011000010000100000110001000011001000010011010111010101011010001110001000100001000000010101011001111011001111111100011010100010010101101001011000100101111010101000000110010011000100101001010100101011000010101111101100111100010011110111010110101100010011010100011011001010001010111;
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
    value.f2 = value.f0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=1 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >> 0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 513'b000110011010000111011011110100101100001110011010101011000000001101111001000100011010000111110111100001000111111001001100101000100001011000101111001101001000001111101000100101100100100100010011010000110001110001100001001101011000101011010101111100101101110001110001100101010100111100111101111000011110001000010011101010100001110101110011100100101100100010000001001011001011110010100101000001010001101001100010001001001100011010100110100010001001110001110011000010000001110110001111001000000110110010010010010101101;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = value.f1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 513'b10000010101001001101011100011100101111100110000100101000110101010000001011110111001111100001110010101110100001100110110011110010001111001010110010111001010101000100111010001100100000111111000100110110100011110000100100001110110010100110011011000001001101101111011101101011000100110101001111111010010010110010111110001111101001100000001011100000111x110z110011111100000001011111000010011101011110011010001110010000100110011000000000001101110010x0101000010111001110110110111010110110010011000001001010101101110110100;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >>> 514;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
