/*
:name: random_cross_case_0005
:type: simulation
:lrm: 1800-2023 7.2.1 6.11.2 10.7 11.4.10 11.8.1
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0005;
  typedef struct packed unsigned {
    bit signed [6:0] f0;
    bit unsigned [0:0] f1;
    bit unsigned [7:0] f2;
  } record_t;
  record_t value;
  logic [9:0] extended0;
  logic [3:0] extended1;
  logic [10:0] extended2;
  initial begin
    value = 16'b0000000000000001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("initial whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 7'b1010100;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=0 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = value.f1;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=1 kind=copy whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = value >> 64;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=2 kind=shift whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f0 = 7'b0001010;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=3 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 16'b0001011100101010;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=4 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = 1'b0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=5 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value.f1 = 1'b0;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=6 kind=field whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    value = 16'b0000000000000001;
    extended0 = value.f0;
    extended1 = value.f1;
    extended2 = value.f2;
    $display("step=7 kind=whole whole=%b f0=%b f1=%b f2=%b e0=%b e1=%b e2=%b",
             value, value.f0, value.f1, value.f2, extended0, extended1, extended2);
    $finish;
  end
endmodule
