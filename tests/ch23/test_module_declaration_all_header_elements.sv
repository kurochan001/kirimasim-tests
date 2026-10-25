/*
:name: test_module_declaration_all_header_elements
:description: ANSI and non-ANSI module declarations with attributes, the module or macromodule keyword, a lifetime, several package imports, a parameter port list, the port list, a time unit, items and an end label, where each element has its effect (IEEE 1800-2023 Section 23.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.1 23.2 23.2.2.2 23.2.2.1 23.2.3 3.14.2.2 6.21 26.4 A.1.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_declaration_all_header_elements.expected
*/
// IEEE 1800-2023 §23.2.1 and A.1.2: a module header has attribute instances,
// the keyword module or macromodule (interchangeable, 23.2), an optional
// lifetime, the name, package import declarations, an optional parameter port
// list and the ports, which an ANSI header declares (23.2.2.2) and a non-ANSI
// header only lists for the items to declare (23.2.2.1). The header may be
// followed by a timeunits_declaration (3.14.2.2), then the items, endmodule
// and the name again after a colon.
//   - The imports of the header make the package names visible in the
//     parameter port list and the port declarations (26.4): BASE and STEP are
//     parameter defaults, and the ports have the 8-bit type byte_t.
//   - The lifetime is the default of the subroutines of the module (6.21):
//     bump keeps its local counter between calls only in the static module,
//     so three calls give 1,1,1 in hm_ansi and 1,2,3 in hm_nonansi.
//   - The time units are 100ps and 10ps, so the #5 and #50 of the two modules
//     both end at 0.5ns, before the top module prints at 1ns.
// A compilation-unit time unit gives the other design elements theirs.

timeunit 1ns / 1ps;

package hm_pkg_a;
  typedef logic [7:0] byte_t;
  localparam int BASE = 10;
endpackage

package hm_pkg_b;
  localparam int STEP = 3;
endpackage

(* hm_style = "ansi" *) (* hm_note *)
macromodule automatic hm_ansi
  import hm_pkg_a::*;
  import hm_pkg_b::STEP;
  #(parameter int N = BASE, parameter int M = STEP)
  (input byte_t a, output int sum);
  timeunit 100ps;
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
endmodule : hm_ansi

(* hm_style = "nonansi" *)
module static hm_nonansi
  import hm_pkg_a::byte_t;
  import hm_pkg_b::*;
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
endmodule : hm_nonansi

module test_module_declaration_all_header_elements;
  logic [7:0] a1 = 8'd5, a2 = 8'd7;
  int sum;
  logic [7:0] y;

  hm_ansi #(.M(4)) u_ansi (.a(a1), .sum(sum));
  hm_nonansi u_nonansi (a2, y);

  initial #1 begin
    $display("ansi sum=%0d width=%0d bumps=%0d,%0d,%0d tick=%b", sum, $bits(u_ansi.a),
             u_ansi.r1, u_ansi.r2, u_ansi.r3, u_ansi.tick);
    $display("nonansi y=%0d width=%0d bumps=%0d,%0d,%0d tick=%b", y, $bits(u_nonansi.a),
             u_nonansi.r1, u_nonansi.r2, u_nonansi.r3, u_nonansi.tick);
  end
endmodule
