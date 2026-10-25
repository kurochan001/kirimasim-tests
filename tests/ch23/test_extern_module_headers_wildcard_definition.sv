/*
:name: test_extern_module_headers_wildcard_definition
:description: Extern module declarations with a non-ANSI and an ANSI header give the ports and parameters that module definitions with the port list .* take over, including the attributes, lifetime, time unit and end label of such a definition (IEEE 1800-2023 Section 23.5)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.5 23.2.1 3.14.2.2 6.21 A.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_module_headers_wildcard_definition.expected
*/
// IEEE 1800-2023 §23.5 and A.1.2: "extern" followed by a non-ANSI or an ANSI
// module header, with no body and no endmodule, declares the ports (and
// parameters) of a module. A module definition whose port list is ( .* ) then
// has exactly the ports and parameters of its extern declaration. A.1.2 lets
// such a definition have attribute instances, a lifetime, a time unit, module
// items (including port declarations) and an end label.
//   - xm_sel has the ports a, b, y in that order from its non-ANSI extern
//     declaration; its items declare their directions. y = a & ~b, so an
//     ordered connection shows the order: 1100 & ~1010 = 0100.
//   - xm_inv has the parameter W and the ports p, q from its ANSI extern
//     declaration; the instance sets W to 8, so q is 8 bits wide.
//   - xm_sel is automatic, so the local counter of bump starts again at each
//     call (6.21), and its time unit is 100ps, so #5 ends at 0.5ns.
// Icarus Verilog 13.0 does not accept extern module declarations, and the
// 5.052 release of Verilator does not accept the port list ( .* ) of a module
// definition; with the ports written out, both print the expected lines.

timeunit 1ns / 1ps;

extern module xm_sel (a, b, y);
extern module xm_inv #(parameter int W = 4) (input logic [W-1:0] p, output logic [W-1:0] q);

(* xm_style = "wildcard" *) (* xm_note *)
module automatic xm_sel (.*);
  timeunit 100ps;
  input [3:0] a, b;
  output [3:0] y;
  int r1, r2, r3;
  bit tick = 1'b0;

  function int bump();
    int c;
    c = c + 1;
    return c;
  endfunction

  assign y = a & ~b;
  initial begin
    r1 = bump();
    r2 = bump();
    r3 = bump();
    #5 tick = 1'b1;
  end
endmodule : xm_sel

module xm_inv (.*);
  assign q = ~p;
endmodule : xm_inv

module test_extern_module_headers_wildcard_definition;
  logic [3:0] a = 4'b1100, b = 4'b1010;
  wire [3:0] y;
  logic [7:0] p = 8'h3c;
  wire [7:0] q;

  xm_sel u_sel (a, b, y);
  xm_inv #(8) u_inv (.p(p), .q(q));

  initial #1 begin
    $display("y=%b bumps=%0d,%0d,%0d tick=%b", y, u_sel.r1, u_sel.r2, u_sel.r3, u_sel.tick);
    $display("q=%h width=%0d", q, $bits(u_inv.q));
  end
endmodule
