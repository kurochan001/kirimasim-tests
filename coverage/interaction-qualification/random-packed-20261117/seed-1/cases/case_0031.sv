/*
:name: random_cross_case_0031
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0031;
  typedef struct packed unsigned {
    bit signed [254:0] f0;
    bit signed [0:0] f1;
    bit unsigned [254:0] f2;
  } record_t;
  record_t value;
  logic [257:0] extended0;
  logic [3:0] extended1;
  logic [257:0] extended2;
  initial begin
    value = 511'b0100010010000101011000111111000001110110000110100010001001110011001110100010011101100x01111101110001011100001001110010101000001011110110110011001011100001001001010100110111101101101001110111001100000110001111110000111010111100100000000110111110001100011011100001101101010100110000110010011111100011101000001110110001100001100111001100001100011z1101111110011110000000110011110110110010001111011110010101111100010101010110111101110111110000111010110000000001110111000000000z001001010111001100111100000110110110111;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 255'b001001001101000000110110000101110110101100101101011010110010111010011000011111101010010100101110011100110100000000111000100111100101101101001010100101000000111110101101010111001001100101011101011111111000010010001110001010101011011010110110100011010110011;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=0 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = value.f1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=1 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >>> 1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 511'b0101000011001011011111111100000110010000000000000110101111001001101010000011100001101000110011000001101010101000001100100000000000011101110100101011010001110101001111001001100110101100000001101000001010000001110011010110001011100011000111101001111101100111100000100110111001100111010101001011111011001001101010110110000100111010111110011000010100001010001101001100000110001011100011010010111101101000100100111010101100111110100000000000000011111101100111101101001011101011111011111001100111100000011110000110110;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = 255'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = 255'b101101010011011001110100111111111111100010101110000110111010000111001111111000011101110100111001110100110000010000101001000110000011111000111101111000001110100011001011001011000100101011010011000000111111010000001100010011110000001000101011000000010111100;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >>> 63;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
