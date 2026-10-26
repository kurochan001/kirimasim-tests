/*
:name: test_port_collapse_supply_cells
:description: An internal supply0 with an external supply1 and an internal supply1 with an external supply0 merge into the external supply net, so the merged net takes the external value (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_collapse_supply_cells.expected
:expected_stderr_regex: (?i)warning
*/
// IEEE 1800-2023 §23.3.3.7: for internal supply0 with external supply1, and
// for internal supply1 with external supply0, Table 23-1 selects the
// external net type and marks the cell warn. A supply0 net has the value 0
// and a supply1 net the value 1 at supply strength, whatever drives them
// (§6.6.6), so the merged net shows which of the two supply nets the table
// selected: the external supply1 gives 1 for the first cell where the
// internal supply0 would give 0, and the external supply0 gives 0 for the
// second cell where the internal supply1 would give 1. Neither side has a
// driver, so only the net type decides the value. The cells 7-7 and 8-8
// have the same type on both sides, and no legal stimulus distinguishes
// which of the two identical supply nets was selected. No release issues
// the warnings, so this expected output follows the standard alone.

module ccs_in_supply0(inout supply0 w);
endmodule

module ccs_in_supply1(inout supply1 w);
endmodule

module test_port_collapse_supply_cells;
  logic [2:0] a_87, i_87, a_78, i_78;
  supply1 n_78;
  supply0 n_87;
  ccs_in_supply0 u_78 (n_78);
  ccs_in_supply1 u_87 (n_87);

  initial begin
    #1 a_78 = {3{n_78}};
    i_78 = {3{u_78.w}};
    a_87 = {3{n_87}};
    i_87 = {3{u_87.w}};
    $display("cell 7-8 supply0->supply1 outside %b inside %b", a_78, i_78);
    $display("cell 8-7 supply1->supply0 outside %b inside %b", a_87, i_87);
  end
endmodule
