/*
:name: test_module_contains_declarations
:description: A module between module and endmodule holds ports with their declarations, nets, variables, structures and unions, constants, user-defined types and package imports, and each of them works (IEEE 1800-2023 Section 3.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.3 23.2.2 6.20 6.18 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_contains_declarations.expected
*/
// IEEE 1800-2023 §3.3: a module is enclosed between module and endmodule and
// can contain, among others, ports with port declarations, data declarations
// (nets, variables, structures and unions), constant declarations,
// user-defined types and imports from packages. Each kind appears below and
// its value is printed:
// - ports: the adder declares its ports in its body after a list of port
//   names, the inverter declares them in its header (§23.2.2); the top module
//   connects both and prints the results;
// - nets and variables: a wire driven by a continuous assignment, a logic
//   variable, a packed structure and a packed union whose members share bits;
// - constants: a parameter, a localparam computed from it and a const
//   variable (§6.20);
// - user-defined types: an enum and a structure typedef (§6.18);
// - imports: a package localparam and a package function, visible through a
//   wildcard import in the module body (§26.3).
// The three modules follow each other, each closed by endmodule (one of them
// with the optional end label), so each port and declaration belongs to the
// module that encloses it.

package test_module_contains_declarations_pkg;
  localparam int PKG_BASE = 40;

  function automatic int pkg_twice(int v);
    return 2 * v;
  endfunction
endpackage

module test_module_contains_declarations_adder(a, b, y);
  input logic [3:0] a;
  input logic [3:0] b;
  output logic [4:0] y;

  assign y = a + b;
endmodule

module test_module_contains_declarations_inverter #(parameter int WIDTH = 4)
    (input logic [WIDTH-1:0] in_v, output logic [WIDTH-1:0] out_v);
  assign out_v = ~in_v;
endmodule : test_module_contains_declarations_inverter

module test_module_contains_declarations;
  import test_module_contains_declarations_pkg::*;

  parameter int P = 3;
  localparam int LP = P * 4;
  const int C = 7;

  typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;

  wire [3:0] w;
  logic [3:0] v;
  pair_t s;
  union packed { pair_t pair; logic [7:0] raw; } u;
  state_t st;
  logic [4:0] sum;
  logic [5:0] inv;

  assign w = v + 4'd1;

  test_module_contains_declarations_adder u_add(.a(4'd9), .b(4'd8), .y(sum));
  test_module_contains_declarations_inverter #(.WIDTH(6)) u_inv(.in_v(6'b000101), .out_v(inv));

  initial begin
    v = 4'd6;
    s = '{4'hA, 4'h5};
    u.raw = 8'h3C;
    st = DONE;
    #1;
    $display("ports: sum=%0d inv=%b", sum, inv);
    $display("data: w=%0d v=%0d s=%h s.lo=%h u.pair.hi=%h u.pair.lo=%h",
             w, v, s, s.lo, u.pair.hi, u.pair.lo);
    $display("constants: P=%0d LP=%0d C=%0d", P, LP, C);
    $display("types: st=%s(%0d) bits(pair_t)=%0d", st.name(), st, $bits(pair_t));
    $display("import: PKG_BASE=%0d pkg_twice(5)=%0d", PKG_BASE, pkg_twice(5));
  end
endmodule
