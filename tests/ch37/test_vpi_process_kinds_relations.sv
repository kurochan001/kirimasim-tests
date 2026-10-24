/*
:name: test_vpi_process_kinds_relations
:description: vpiAlwaysType tells always, always_comb, always_ff and always_latch apart; a process leads to the module instance it is in; a statement, atomic or a named block, leads to its process with vpiProcess and to the scope it is in with vpiScope (IEEE 1800-2023 Section 37.63)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.63 37.12 9.2 9.2.2 9.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_process_kinds_relations.c
:expected_stdout: @test_vpi_process_kinds_relations.expected
*/
// IEEE 1800-2023 §37.63: initial, final and always procedures are processes;
// a module leads to its processes and a process to its module (vpiModule).
// vpiAlwaysType of an always procedure is vpiAlways, vpiAlwaysComb,
// vpiAlwaysFF or vpiAlwaysLatch (detail 1; 9.2.2). A statement leads to its
// process (vpiProcess) and to its scope (vpiScope); the statement group holds
// the atomic statements and the scopes that are statements, such as a named
// begin. §37.12: a named begin is a scope, and an unnamed begin without
// declarations is not, so a statement directly in a procedure has the module
// instance as its scope and one in a named begin has that block.
//
// The top module has one procedure of each kind, and the instance u has an
// initial procedure of its own. From a start-of-simulation callback the
// application iterates the processes of the top module and of u and prints
// for each: its kind and vpiAlwaysType, the full name of its module, the kind
// of its statement, whether that statement leads back to the same process,
// and the full name of the scope of the statement. It then does the same for
// the statement inside the if of always_latch and for the statements of the
// named begins init_blk and fin_blk. The lines are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiProcess and the statement types, and a
// run with Verilator 5.052 finds no processes.

module test_vpi_process_kinds_relations_sub;
  logic s;
  initial s = 1'b1;
endmodule

module test_vpi_process_kinds_relations;
  logic clk = 1'b0, d = 1'b0, en = 1'b0;
  logic y_plain, y_comb, q_ff, q_latch, done;

  always @(clk) y_plain = clk;
  always_comb y_comb = d;
  always_ff @(posedge clk) q_ff <= d;
  always_latch if (en) q_latch = d;

  initial begin : init_blk
    d = 1'b1;
  end

  final begin : fin_blk
    done = 1'b1;
  end

  test_vpi_process_kinds_relations_sub u();
endmodule
