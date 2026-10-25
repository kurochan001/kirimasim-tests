/*
:name: test_package_declaration_all_elements
:description: A package declaration with attributes, a lifetime, a time unit, attributed package items and an end label, and attributed package items directly in the compilation unit, where each element has its effect (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 6.21 3.14.2.2 3.12.1 A.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_declaration_all_elements.expected
*/
// IEEE 1800-2023 A.1.2 and 26.2: a description of the source text can be a
// package declaration, which has attribute instances, package, an optional
// lifetime, the name, an optional time unit, package items that can each have
// attribute instances, and endpackage with an optional end label. A
// description can also be a package item with attribute instances, directly
// in the compilation unit (3.12.1).
//   - The lifetime automatic is the default lifetime of the variables of the
//     subroutines of the package (6.21): three calls of bump give 1,1,1 (they
//     would give 1,2,3 with a static default). The package variable calls is
//     static (6.21) and counts the three calls.
//   - The time unit of the package is 100ps (3.14.2.2), so the #5 of the
//     task wait5 lasts 0.5ns, which the module prints in its unit of 1ns.
//   - K and word_t of the package give a 6-bit type.
//   - In the compilation unit, CU_BASE, the function cu_add and the type
//     cu_pair_t each have attribute instances; cu_add(2) = 42 and the pair
//     8'ha5 has hi = a and lo = 5.
// Icarus Verilog 13.0 stops with a syntax error at the attribute instances
// before the package and before its items; without them it prints the
// expected lines.

timeunit 1ns / 1ps;

(* pd_kind = "shared" *) (* pd_note *)
package automatic pd_pkg;
  timeunit 100ps;
  (* pd_item = 1 *) localparam int K = 6;
  (* pd_item = 2 *) typedef logic [K-1:0] word_t;
  int calls;

  (* pd_item = 3 *)
  function int bump();
    int c;
    c = c + 1;
    calls++;
    return c;
  endfunction

  task wait5();
    #5;
  endtask
endpackage : pd_pkg

(* cu_kind = "param" *) localparam int CU_BASE = 40;

(* cu_kind = "function" *)
function automatic int cu_add(int x);
  return x + CU_BASE;
endfunction

(* cu_kind = "type" *) typedef struct packed { logic [3:0] hi, lo; } cu_pair_t;

module test_package_declaration_all_elements;
  import pd_pkg::*;
  word_t w = '1;
  cu_pair_t pr = 8'ha5;
  int r1, r2, r3;

  initial begin
    r1 = bump();
    r2 = bump();
    r3 = bump();
    $display("pkg K=%0d width=%0d w=%b bumps=%0d,%0d,%0d calls=%0d", K, $bits(word_t), w,
             r1, r2, r3, calls);
    wait5();
    $display("wait5 ended at %.1f", $realtime);
    $display("unit add=%0d hi=%h lo=%h", cu_add(2), pr.hi, pr.lo);
  end
endmodule
