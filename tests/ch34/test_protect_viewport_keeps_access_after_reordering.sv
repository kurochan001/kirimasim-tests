/*
:name: test_protect_viewport_keeps_access_after_reordering
:description: Reordering protected envelopes keeps viewport access tied to each model
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.32.2 34.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: viewport_top
:expected_stdout: viewport values=21,42,38,70,68,13
*/
`timescale 1ns/1ns

`pragma protect begin
`pragma protect viewport=(object="viewport_top.west.opened", access="read only")
module viewport_west;
  reg [7:0] opened = 8'h70;
  reg [7:0] kept = 8'h68;
endmodule
`pragma protect end

`pragma protect reset
`pragma protect begin
`pragma protect viewport=(object="viewport_top.east.opened", access="read only")
`pragma protect viewport=(object="viewport_top.east.writable", access="tool access")
module viewport_east;
  reg [7:0] opened = 8'h21;
  reg [7:0] writable = 8'h42;
  reg [7:0] kept = 8'h38;
endmodule
`pragma protect end
`pragma protect reset

module viewport_top;
  viewport_west west();
  viewport_east east();
  reg [7:0] clear = 8'h13;
  initial begin
    #1;
    // Viewport qualification operations
    $display("viewport values=%02h,%02h,%02h,%02h,%02h,%02h",
             east.opened, east.writable, east.kept, west.opened, west.kept, clear);
    $finish;
  end
endmodule
