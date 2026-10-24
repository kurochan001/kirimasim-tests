/*
:name: test_vpi_part_select_parts
:description: A part-select gives its range with vpiLeftRange and vpiRightRange and an indexed part-select its base, width and direction; both lead with vpiParent to the expression without their range, have the width of the selection as vpiSize, and vpiConstantSelect is true only for constant ranges of a constant parent with static bounds (IEEE 1800-2023 Section 37.59)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.59 37.58 37.19 37.17 11.5.1 7.4.6 7.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_part_select_parts.c
:expected_stdout: @test_vpi_part_select_parts.expected
*/
// IEEE 1800-2023 §37.59: a part-select leads to its bounds (vpiLeftRange,
// vpiRightRange), an indexed part-select to its base (vpiBaseExpr) and width
// (vpiWidthExpr), and vpiIndexedPartSelectType is vpiPosIndexed for +: and
// vpiNegIndexed for -:. Both are expressions, so vpiSize gives their width
// (11.5.1). Their vpiParent is the expression without the range (detail 10).
// vpiConstantSelect is TRUE if, and only if, the parent has it TRUE, the
// parent is a packed or unpacked array with static bounds and every range
// expression is an elaboration-time constant (detail 9). §37.17 detail 27: a
// static variable without a parent has vpiConstantSelect TRUE, a dynamic array
// (7.5) too, but it has no static bounds. §37.19: mem[j] and mem[2] are var
// selects of the unpacked array mem, leading to their index with vpiIndex;
// with the variable index j, mem[j] has vpiConstantSelect FALSE.
//
// The task sels is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). Each assignment has its own target p1 to p6, by which the
// lines are sorted; the application prints the right-hand side: a constant
// as its value, a variable by name, a var select as name[index].
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the selection types, and the
// slice dyn[0:1] of the dynamic array, which 7.4.6 and 7.6 allow, is
// rejected by Verilator 5.052.

module test_vpi_part_select_parts;
  logic [15:0] v;
  logic [7:0] mem [0:3];
  logic [7:0] dyn [];
  logic [7:0] p6 [2];
  logic [5:0] p1, p2, p3, p4, p5;
  int i, j;

  task sels;
    p1 = v[7:4];
    p2 = v[i+:3];
    p3 = v[11-:5];
    p4 = mem[j][5:2];
    p5 = mem[2][6:1];
    p6 = dyn[0:1];
  endtask
endmodule
