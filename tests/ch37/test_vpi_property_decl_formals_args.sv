/*
:name: test_vpi_property_decl_formals_args
:description: a property instance leads to its declaration and gives its arguments in the order of the formals with the defaults filled in, whether the actuals are given by position or by name; the formals of a property declaration come in declaration order with their direction and typespec, a declaration gives its variables and its full name, and the items of a case property group their conditions, with no expression iterator for the default (IEEE 1800-2023 Sections 37.51 and 37.52)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.51 37.52 37.50 16.12 16.12.1 16.12.16 16.12.19 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_decl_formals_args.c
:expected_stdout: @test_vpi_property_decl_formals_args.expected
*/
// IEEE 1800-2023 §37.51: a property inst leads to its property decl, and
// vpiArgument returns its arguments in the order of the formals, with the
// default of a formal that the instance leaves out (detail 2): p_formals(a)
// gives a 2 5, p_formals(b, 7) gives b 7 5 and p_formals(.n(9), .x(c)), whose
// actuals are bound by name in another order (16.12.1), gives c 9 5. The
// instances are the properties of the assertions a1 to a3 (37.50 vpiProperty;
// one written as a property spec holding the instance is looked through).
// vpiPropFormalDecl returns the formals in declaration order (detail 1);
// vpiTypespec is NULL for the untyped x and an int typespec for n and v
// (detail 3); vpiDirection is vpiNoDirection for x and n and vpiInput for the
// local variable argument v (detail 5, 16.12.19). vpiVariables of p_vars gives
// its assertion variables cnt and flag (16.10). vpiFullName of a property
// decl is the hierarchical name, through the generate block g for p_gen.
// §37.52: a case property gives its condition sel and its case property
// items; an item groups all conditions that lead to the same property
// statement (detail 4), so 2'd0, 2'd1: a is one item with two conditions, and
// vpi_iterate(vpiExpr) of the default item returns NULL (detail 5). The clock
// never ticks, so no assertion is evaluated. Variables, items and the values
// of the conditions of an item are sorted.

module test_vpi_property_decl_formals_args;
  logic clk = 1'b0, a = 1'b0, b = 1'b0, c = 1'b0;
  logic [1:0] sel = 2'd0;

  property p_formals(x, int n = 2, local input int v = 5);
    @(posedge clk) x |-> (v > n);
  endproperty

  property p_vars;
    int cnt;
    logic flag;
    @(posedge clk) (a, cnt = 1) |-> b;
  endproperty

  property p_case;
    case (sel)
      2'd0, 2'd1: a;
      2'd2: b;
      default: c;
    endcase
  endproperty

  if (1) begin : g
    property p_gen;
      a |-> b;
    endproperty
  end

  a1: assert property (p_formals(a));
  a2: assert property (p_formals(b, 7));
  a3: assert property (p_formals(.n(9), .x(c)));

  initial #1 $vt_props;
endmodule
