/*
:name: test_extern_interface_program_headers_wildcard
:description: Extern interface and extern program declarations with non-ANSI and ANSI headers give the ports and parameters that interface and program definitions with the port list .* take over, with the attributes, time unit, port declaration items and end label of such definitions (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 24.3 23.5 3.14.2.2 A.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_interface_program_headers_wildcard.expected
*/
// IEEE 1800-2023 A.1.2, 25.3 and 24.3: like a module (23.5), an interface or
// a program can be declared with "extern" followed by its non-ANSI or ANSI
// header, with no items and no end keyword. A definition whose port list is
// ( .* ) then takes the ports and parameters of the extern declaration (23.5;
// 24.3: program ports work as module ports). Such a definition has attribute
// instances, the keyword, the name and ( .* ) with no lifetime, then an
// optional time unit, items that can declare the ports, and the end keyword
// with an optional end label.
//   - xi_diff: ports a, b from its non-ANSI extern declaration, connected by
//     position: d = a - b = 9 - 4 = 5 (it would be 251 with the order
//     swapped). Its time unit is 100ps, so #5 sets tick at 0.5ns.
//   - xi_cfg: parameter W and port seed from its ANSI extern declaration;
//     the instance sets W to 6, so inv = ~6'b000101 = 111010, 6 bits wide.
//   - xp_drv: ports lim, val, tick from its non-ANSI extern declaration,
//     connected by position; time unit 10ps, so val = lim + 1 = 41 at 0.1ns
//     and tick = 1 at 0.5ns. Its initial procedure ends at 2ns, which ends
//     the simulation (24.3).
//   - xp_sum: parameter K and ports v, total from its ANSI extern
//     declaration; K is set to 3, so total = 41 * 3 = 123.
// The top module prints at 1ns. It reads the program only through the nets
// and the variable connected to its ports (24.3 forbids hierarchical
// references to program signals from outside programs).
// Icarus Verilog 13.0 does not accept extern declarations, and the 5.052
// release of Verilator does not accept the port list ( .* ) of a definition.

timeunit 1ns / 1ps;

extern interface xi_diff (a, b);
extern interface xi_cfg #(parameter int W = 4) (input logic [W-1:0] seed);
extern program xp_drv (lim, val, tick);
extern program xp_sum #(parameter int K = 2) (input logic [7:0] v, output int total);

(* xi_kind = "wildcard" *) (* xi_note *)
interface xi_diff (.*);
  timeunit 100ps;
  input [7:0] a;
  input [7:0] b;
  logic [7:0] d;
  bit tick = 1'b0;
  assign d = a - b;
  initial #5 tick = 1'b1;
endinterface : xi_diff

interface xi_cfg (.*);
  logic [W-1:0] inv;
  assign inv = ~seed;
endinterface : xi_cfg

(* xp_kind = "wildcard" *) (* xp_note *)
program xp_drv (.*);
  timeunit 10ps;
  input [7:0] lim;
  output logic [7:0] val;
  output bit tick;
  initial begin
    #10 val = lim + 8'd1;
    #40 tick = 1'b1;
    #150;
  end
endprogram : xp_drv

program xp_sum (.*);
  assign total = v * K;
endprogram : xp_sum

module test_extern_interface_program_headers_wildcard;
  logic [7:0] lim = 8'd40;
  wire [7:0] val;
  wire tick;
  int total;

  xi_diff u_diff (8'd9, 8'd4);
  xi_cfg #(.W(6)) u_cfg (.seed(6'b000101));
  xp_drv u_drv (lim, val, tick);
  xp_sum #(.K(3)) u_sum (.v(val), .total(total));

  initial #1 begin
    $display("diff d=%0d tick=%b", u_diff.d, u_diff.tick);
    $display("cfg inv=%b width=%0d", u_cfg.inv, $bits(u_cfg.inv));
    $display("drv val=%0d tick=%b sum total=%0d", val, tick, total);
  end
endmodule
