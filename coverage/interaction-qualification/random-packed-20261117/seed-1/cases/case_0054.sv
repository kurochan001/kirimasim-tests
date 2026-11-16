/*
:name: random_cross_case_0054
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0054;
  typedef struct packed unsigned {
    bit unsigned [254:0] f0;
    bit signed [0:0] f1;
    bit signed [254:0] f2;
  } record_t;
  record_t value;
  logic [257:0] extended0;
  logic [3:0] extended1;
  logic [257:0] extended2;
  initial begin
    value = 511'b1101011111101100110111111000011010010000100011101110011110010011111011100010000010001111011011110011100011001010010100001110011011011101000111011111011000010110000010110010010000110101100101111111101110111010111011000101010111011101101111101110111111101110000111010001110000010110100011001000011110011010110010110011101100110001001010000100001000101111101101100101000110000101000011000010001110011100111000110110010001111111000010011001110010101111100111111110011010001101101010110010011111001101111110011101100;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 255'b001000000000100001100001011111001011111000011001101x0001000011010001z10101111111011110100000011010100110110001110001011001110101110100100010110001100101010001010010001110110100000000101011011101110z011001001101111000101011001111000001110111101010110000100;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=0 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=1 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >>> 0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value << 1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f2;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 511'b1000011110011111111010001000100100011100001101010100011110100110001111000000110111001101100100000001010111011110000100001010000110011100110110011110110010100010001110111000111111001100100111010011101111111001011101001001110000011100011100000111110111010100010101101101011111011011111110100110000000111100110011110000011000010110010111011011010000111111010110111101001011011100101001111011111101100000000000010001110100101101100101001000011011100010101011111111111011101101110000110000111100111100110100110010101;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 255'b101100001010011100011110111101111100101111100001010000110010101010110100101011010011100001010001000000011110010111011100001100000010110111101001011000010100000001101111010001000010100101010101101110110011000011001110010100100111010010110011100010011000011;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = value.f2;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
