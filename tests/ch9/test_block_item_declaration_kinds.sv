/*
:name: test_block_item_declaration_kinds
:description: A sequential block and a parallel block accept block item declarations: a data declaration, a localparam, a parameter and a let declaration, each with any number of attribute instances before it (IEEE 1800-2023 Sections 9.3.1 and 9.3.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1 9.3.2 11.12 A.2.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_item_declaration_kinds.expected
*/
// IEEE 1800-2023 §9.3.1, Syntax 9-2: a sequential block holds zero or more
// block item declarations before its statements. §9.3.2 gives the same for a
// parallel block. A.2.8 lists the alternatives of a block item declaration: a
// data declaration, a localparam declaration, a parameter declaration and a
// let declaration, each preceded by any number of attribute instances. The
// named sequential block blk declares x = 3, L = 4 and P = 5, each with an
// attribute instance, and the let declaration y with one too; y(2) adds its
// argument to the three values. The parallel block par declares its own z
// and prints it after a delay. The attributes have no effect on the values,
// and the values printed are those of the declarations in each block.
//
// Icarus Verilog 13.0 rejects an attribute instance before a block item
// declaration and has no let declaration; Verilator 5.052 produces this
// output.

module test_block_item_declaration_kinds;
  initial begin : blk
    (* keep = "true" *) static int x = 3;
    (* keep = "true" *) localparam int L = 4;
    (* keep = "true" *) parameter int P = 5;
    (* keep = "true" *) let y(i) = i + x + L + P;
    $display("blk x=%0d L=%0d P=%0d y=%0d", x, L, P, y(2));
    fork : par
      automatic int z = 6;
      #1 $display("par z=%0d", z);
    join
  end
endmodule
