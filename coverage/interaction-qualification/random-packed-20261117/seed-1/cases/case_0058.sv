/*
:name: random_cross_case_0058
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0058;
  typedef struct packed unsigned {
    bit unsigned [0:0] f0;
    bit unsigned [62:0] f1;
    bit unsigned [0:0] f2;
  } record_t;
  record_t value;
  logic [3:0] extended0;
  logic [65:0] extended1;
  logic [3:0] extended2;
  initial begin
    value = 65'b000000000000000000000000000000000000000x0000000000000000000000001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = 63'b111110001110100001010011101000100100101110001100000100011111110;
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
    value = value >> 65;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 1'bx;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 1'b0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 65'b10011100001000101111000011101100111000101100110110000001001100100;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value << 64;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 65'b0z00000000000000000000000000000000000000000000000000000000zx00001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
