/*
:name: test_expr_selects_and_prefixes
:description: constant bit and part selects, indexed part selects with constant and variable bases, and the static prefixes of an identifier, a package, a hierarchy, a field and a multi-index select (IEEE 1800-2023 11.5.1, 11.5.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 11.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_selects_and_prefixes.expected
*/
// IEEE 1800-2023 §11.5.1: a bit-select is constant when its position is
// constant, and a part-select when its position and width are constant, which
// includes an indexed part-select with a constant base. The test uses constant
// selects in localparam initializers and a variable base at run time. §11.5.3:
// an identifier, a hierarchical reference, a package reference and a field
// select whose prefix is static are static prefixes, and an indexing select is
// static when its prefix and select expression are. The test reads a package
// variable, a hierarchical variable, a field of a packed struct and a two
// index select of an unpacked array, then writes through an indexed part
// select whose base is a variable. A wrong constant-folded value or a select
// that addresses another bit prints a different line.

package pkg;
  int pv = 3;
endpackage

module sub;
  int hv = 4;
endmodule

module test_expr_selects_and_prefixes;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } nib_t;

  sub u();
  logic [7:0] v = 8'hA5;
  logic [7:0] m [2][3];
  nib_t ns;
  int i;
  localparam logic [7:0] C = 8'hA5;
  localparam bit CB = C[3];
  localparam logic [3:0] CP = C[7:4];
  localparam logic [3:0] IP = C[4 +: 4];

  initial begin
    $display("cb=%0d cp=%h ip=%h", CB, CP, IP);
    $display("bitsel=%b part=%h idxpart=%h", v[3], v[7:4], v[4 +: 4]);
    i = 2;
    $display("varpart=%h", v[i +: 3]);
    v[i +: 3] = 3'b111;
    $display("wrote=%h", v);
    m[1][2] = 8'h11;
    ns.hi = 4'hC;
    ns.lo = 4'h3;
    $display("mem=%h pkg=%0d hier=%0d", m[1][2], pkg::pv, u.hv);
    $display("field=%h hi=%h lo=%h", ns, ns.hi, ns.lo);
    $finish;
  end
endmodule
