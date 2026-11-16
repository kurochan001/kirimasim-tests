/*
:name: random_cross_case_0069
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0069;
  typedef struct packed unsigned {
    logic signed [64:0] f0;
    logic signed [62:0] f1;
    logic unsigned [0:0] f2;
  } record_t;
  record_t value;
  logic [67:0] extended0;
  logic [65:0] extended1;
  logic [3:0] extended2;
  initial begin
    value = 129'b1000100100000100111011001010001111101101100100000100010010111100110000111101x0101011110001111011001010011011100110011100001100001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = 63'b111111111111111111111111111111111111111111111111111111111111111;
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
    value = value >> 129;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 129'b10001111010011101101000000110001011111x00011000110000110111000011000000100100001000001010010101111111011100101010101110x010010111;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 129'b01110111010x00011000110000110z1001101000010000110000010010110101z0001101110111000011001101000101000010100011101100110110100110001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 129'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f2 = 1'b1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = value.f2;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
