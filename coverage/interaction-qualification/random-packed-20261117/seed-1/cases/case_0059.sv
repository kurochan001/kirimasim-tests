/*
:name: random_cross_case_0059
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0059;
  typedef struct packed unsigned {
    logic unsigned [254:0] f0;
    logic unsigned [0:0] f1;
    logic unsigned [254:0] f2;
  } record_t;
  record_t value;
  logic [257:0] extended0;
  logic [3:0] extended1;
  logic [257:0] extended2;
  initial begin
    value = 511'b10000110101000010101100111x011100110101010100010100011010111100100111100010010111100111010000101110011011010110111101001010011100100010000100110011010010110001011z010011011011011111101110101110010000000100100110001010001011011110101011001010110110000010111100001001111111101010101110011100101110000100001100111000101000000101101010100001101111110100000100011101101000111101110001100001110111001010000111010010110101100010001000010011x11100111011101000011101010001111110101010011010000111101101000000010100001001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = 1'bx;
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
    value = value >>> 512;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = value.f0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 511'b0000011101011101000101101111000101110101000100000001011101011001111101001011010010111011100010101110000101100101010100111011111000001101001101000011001111001011111100101011101010110001001010010101011000110011011100000110011111000100101111101011000011111101010111110100000011110100001101010011000101000000111110101011100100111111000100011001110011110110010001010111011101001010000111011100111111100011100111100100001101000101110111001110011011001010011000111010110010101111101110100000111101101100101011111011111;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >>> 63;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 511'b1000101100110101100011110010110000000100000011010001001100111000110010111111101001010100110001000110001111000010010110111100001010000101100111010010110101100101000101000000110100010100010110010000100011101111110111100101010000101011010111100111011010100111001001110100000100000110011100011101001111010111100111001111110010100100000000001100110100000100010001100011010100011110110011011011111000010110110101111001100000001000001011100010101111100110001000000001101100000000101110000100011011011010101111100001010;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = value.f1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
