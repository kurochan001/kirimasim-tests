/*
:name: test_interface_declaration_all_header_elements
:description: ANSI and non-ANSI interface declarations with attributes, a lifetime, several package imports, a parameter port list, the port list, a time unit, items (port declarations among them) and an end label, where each element has its effect (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 23.2.1 3.14.2.2 6.21 26.4 A.1.2 A.1.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_declaration_all_header_elements.expected
*/
// IEEE 1800-2023 §25.3 and A.1.2: an interface is declared like a module,
// with an ANSI header that declares its ports or a non-ANSI header that only
// lists them; both have attribute instances, interface, an optional lifetime,
// the name, package imports and an optional parameter port list. A time unit
// can follow the header, then the items and endinterface with an optional
// end label. A.1.6: an item of a non-ANSI interface can be a port declaration
// ending with a semicolon.
//   - The imports of the header make BASE, STEP and byte_t visible in the
//     parameter port list and the port declarations (26.4).
//   - The lifetime is the default of the subroutines of the interface (6.21):
//     three calls of bump give 1,1,1 when automatic and 1,2,3 when static.
//   - The time units are 100ps and 10ps, so the #5 and #50 end at 0.5ns,
//     before the top module prints at 1ns.

timeunit 1ns / 1ps;

package ih_pkg_a;
  typedef logic [7:0] byte_t;
  localparam int BASE = 10;
endpackage

package ih_pkg_b;
  localparam int STEP = 3;
endpackage

(* ih_style = "ansi" *) (* ih_note *)
interface automatic ih_ansi
  import ih_pkg_a::*;
  import ih_pkg_b::STEP;
  #(parameter int N = BASE, parameter int M = STEP)
  (input byte_t a);
  timeunit 100ps;
  int sum;
  int r1, r2, r3;
  bit tick = 1'b0;

  function int bump();
    int c;
    c = c + 1;
    return c;
  endfunction

  assign sum = a + N + M;
  initial begin
    r1 = bump();
    r2 = bump();
    r3 = bump();
    #5 tick = 1'b1;
  end
endinterface : ih_ansi

(* ih_style = "nonansi" *)
interface static ih_nonansi
  import ih_pkg_a::byte_t;
  import ih_pkg_b::*;
  #(parameter int K = STEP)
  (a, y);
  timeunit 10ps;
  input byte_t a;
  output byte_t y;
  int r1, r2, r3;
  bit tick = 1'b0;

  function int bump();
    int c;
    c = c + 1;
    return c;
  endfunction

  assign y = a * K;
  initial begin
    r1 = bump();
    r2 = bump();
    r3 = bump();
    #50 tick = 1'b1;
  end
endinterface : ih_nonansi

module test_interface_declaration_all_header_elements;
  logic [7:0] a1 = 8'd5, a2 = 8'd7;
  logic [7:0] y;

  ih_ansi #(.M(4)) u_ansi (.a(a1));
  ih_nonansi u_nonansi (a2, y);

  initial #1 begin
    $display("ansi sum=%0d width=%0d bumps=%0d,%0d,%0d tick=%b", u_ansi.sum, $bits(u_ansi.a),
             u_ansi.r1, u_ansi.r2, u_ansi.r3, u_ansi.tick);
    $display("nonansi y=%0d width=%0d bumps=%0d,%0d,%0d tick=%b", y, $bits(u_nonansi.a),
             u_nonansi.r1, u_nonansi.r2, u_nonansi.r3, u_nonansi.tick);
  end
endmodule
