/*
:name: test_param_declaration_forms_aggregates_selects
:description: parameter and localparam declarations take a data type or only signing and packed dimensions, several assignments, unpacked dimensions on a name, and lists of type assignments; aggregate parameters are read by element and member, integral ones by bit and part select (IEEE 1800-2023 Sections 6.20.1 and 6.20.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 6.20.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_declaration_forms_aggregates_selects.expected
*/
// IEEE 1800-2023 §6.20.1, Syntax 6-6: a parameter or localparam declaration
// has a data type, or only signing and packed dimensions, then one or more
// assignments; each name may have unpacked dimensions; a type declaration
// has a list of type assignments. §6.20.2: a parameter may have an aggregate
// type such as an unpacked array or structure, whose elements and members
// can be read in expressions, and an integral parameter allows bit selects
// and part selects. The sizes and signs of the printed values follow the
// declared types: S2 = 8'h80 is -128 in signed [7:0], N1 = 4'ha is 10 in the
// unsigned [3:0]. Icarus Verilog 13.0 does not support unpacked structures
// (unsupported construct).

module test_param_declaration_forms_aggregates_selects;
  typedef struct { int a; byte b; } pair_t;
  parameter int unsigned U1 = 7, U2 = U1 * 2;
  parameter signed [7:0] S1 = -3, S2 = 8'h80;
  localparam [3:0] N1 = 4'ha;
  parameter int ARR [3] = '{10, 20, 30};
  localparam int MAT [2][2] = '{'{1, 2}, '{3, 4}};
  parameter pair_t SP = '{a: 5, b: -2};
  localparam type T1 = shortint, T2 = logic [5:0];
  parameter type T3 = int;
  localparam logic [15:0] W = 16'habcd;
  T1 v1;
  T2 v2;
  T3 v3;

  initial begin
    $display("typed list: U1=%0d U2=%0d bits=%0d", U1, U2, $bits(U2));
    $display("signed dims: S1=%0d S2=%0d bits=%0d", S1, S2, $bits(S2));
    $display("dims only: N1=%0d bits=%0d neg=%0d", N1, $bits(N1), N1 < 0);
    $display("array: ARR[1]=%0d size=%0d MAT[1][0]=%0d MAT[0][1]=%0d", ARR[1], $size(ARR),
             MAT[1][0], MAT[0][1]);
    $display("struct: SP.a=%0d SP.b=%0d sum=%0d", SP.a, SP.b, SP.a + SP.b);
    $display("types: %0d %0d %0d", $bits(v1), $bits(v2), $bits(v3));
    $display("selects: W[15]=%b W[3:0]=%h W[11 -: 4]=%h W[4 +: 8]=%h", W[15], W[3:0],
             W[11 -: 4], W[4 +: 8]);
  end
endmodule
