/*
:name: test_package_local_visibility
:description: a name is locally visible if it is a nested scope of the scope, or is declared or explicitly imported before the reference; otherwise the compilation unit's declaration is found (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_local_visibility.expected
*/
// IEEE 1800-2023 §26.3: at a point in a scope, an identifier is locally
// visible if it names a nested scope of that scope, wherever that is
// declared, or if it is declared, or explicitly imported, before that
// point. A reference that matches no locally visible identifier, and no
// wildcard candidate, is looked up in the outer scope, here the
// compilation unit, which declares w = 300 and y = 400.
// In the module, w_first reads w before the local w = 30 is declared and
// w_then after it; y_first reads y before the explicit import of lv::y
// (7) and y_then after it. The initial procedure reads blk.v from the
// generate block blk, which is declared after it. Icarus Verilog 13.0
// gives y_first=7 and the 5.052 release of Verilator also w_first=30.

localparam int w = 300;
localparam int y = 400;

package lv;
  localparam int y = 7;
endpackage

module test_package_local_visibility;
  localparam int w_first = w;
  localparam int w = 30;
  localparam int w_then = w;
  localparam int y_first = y;
  import lv::y;
  localparam int y_then = y;

  initial #1 $display("w_first=%0d w_then=%0d y_first=%0d y_then=%0d blk.v=%0d",
                      w_first, w_then, y_first, y_then, blk.v);

  if (1) begin : blk
    int v = 8;
  end
endmodule
