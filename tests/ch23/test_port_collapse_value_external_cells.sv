/*
:name: test_port_collapse_value_external_cells
:description: For each cell of Table 23-1 whose dominating net type a port connection shows in its resolved value, the merged net resolves as the external net type, and a dissimilar connection without a dominating type uses the external type (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_value_external_cells.expected
:expected_stderr_regex: (?i)warning
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects two nets of different
// built-in net types, the simulated net takes the type that Table 23-1
// selects, and a warning is issued in the cells the table marks warn. The
// test runs the five phases (driver inside, driver outside) 1/0, 0/z, z/z,
// z/1 and z/z on every cell, and prints the merged net as seen from the
// outer net and through the port. A strong 1 against a strong 0 gives x on
// a wire or tri net (§6.6.1), 0 on a wand or triand net (§6.6.3) and 1 on
// a wor or trior net; a tri0 net pulls an undriven or conflicting net to 0
// and a tri1 net pulls it to 1 (§6.6.5). The cells and the values the
// table gives are: internal wand with external wor, tri0 or tri1 (10z1z,
// x0010, x0111), internal wor with external wand, tri0 or tri1 (00z1z,
// x0010, x0111), internal tri0 with external wand, wor or tri1 (00z1z,
// 10z1z, x0111) and internal tri1 with external wand, wor or tri0 (00z1z,
// 10z1z, x0010). Cell 1-0 has a dominating internal net: internal wand
// with external wire gives the internal wand, 00z1z, where keeping the
// external wire would give x0z1z. Every cell except 1-0 is marked warn.
// The cells whose dominating type is a trireg or uwire are in
// test_port_collapse_trireg_and_uwire_cells and
// test_port_collapse_uwire_external_delay. No release issues the warnings,
// so this expected output follows the standard alone.

module ccv_in_wand(inout wand w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module ccv_in_wor(inout wor w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module ccv_in_tri0(inout tri0 w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module ccv_in_tri1(inout tri1 w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module test_port_collapse_value_external_cells;
  logic [1:0] ci, co;
  logic [4:0] o_10, i_10;
  wire n_10;
  assign n_10 = co[1] ? 1'bz : co[0];
  ccv_in_wand u_10 (n_10, ci);
  logic [4:0] o_12, i_12;
  wor n_12;
  assign n_12 = co[1] ? 1'bz : co[0];
  ccv_in_wand u_12 (n_12, ci);
  logic [4:0] o_14, i_14;
  tri0 n_14;
  assign n_14 = co[1] ? 1'bz : co[0];
  ccv_in_wand u_14 (n_14, ci);
  logic [4:0] o_15, i_15;
  tri1 n_15;
  assign n_15 = co[1] ? 1'bz : co[0];
  ccv_in_wand u_15 (n_15, ci);
  logic [4:0] o_21, i_21;
  wand n_21;
  assign n_21 = co[1] ? 1'bz : co[0];
  ccv_in_wor u_21 (n_21, ci);
  logic [4:0] o_24, i_24;
  tri0 n_24;
  assign n_24 = co[1] ? 1'bz : co[0];
  ccv_in_wor u_24 (n_24, ci);
  logic [4:0] o_25, i_25;
  tri1 n_25;
  assign n_25 = co[1] ? 1'bz : co[0];
  ccv_in_wor u_25 (n_25, ci);
  logic [4:0] o_41, i_41;
  wand n_41;
  assign n_41 = co[1] ? 1'bz : co[0];
  ccv_in_tri0 u_41 (n_41, ci);
  logic [4:0] o_42, i_42;
  wor n_42;
  assign n_42 = co[1] ? 1'bz : co[0];
  ccv_in_tri0 u_42 (n_42, ci);
  logic [4:0] o_45, i_45;
  tri1 n_45;
  assign n_45 = co[1] ? 1'bz : co[0];
  ccv_in_tri0 u_45 (n_45, ci);
  logic [4:0] o_51, i_51;
  wand n_51;
  assign n_51 = co[1] ? 1'bz : co[0];
  ccv_in_tri1 u_51 (n_51, ci);
  logic [4:0] o_52, i_52;
  wor n_52;
  assign n_52 = co[1] ? 1'bz : co[0];
  ccv_in_tri1 u_52 (n_52, ci);
  logic [4:0] o_54, i_54;
  tri0 n_54;
  assign n_54 = co[1] ? 1'bz : co[0];
  ccv_in_tri1 u_54 (n_54, ci);

  task automatic sample(int k);
    o_10[4-k] = n_10;
    i_10[4-k] = u_10.w;
    o_12[4-k] = n_12;
    i_12[4-k] = u_12.w;
    o_14[4-k] = n_14;
    i_14[4-k] = u_14.w;
    o_15[4-k] = n_15;
    i_15[4-k] = u_15.w;
    o_21[4-k] = n_21;
    i_21[4-k] = u_21.w;
    o_24[4-k] = n_24;
    i_24[4-k] = u_24.w;
    o_25[4-k] = n_25;
    i_25[4-k] = u_25.w;
    o_41[4-k] = n_41;
    i_41[4-k] = u_41.w;
    o_42[4-k] = n_42;
    i_42[4-k] = u_42.w;
    o_45[4-k] = n_45;
    i_45[4-k] = u_45.w;
    o_51[4-k] = n_51;
    i_51[4-k] = u_51.w;
    o_52[4-k] = n_52;
    i_52[4-k] = u_52.w;
    o_54[4-k] = n_54;
    i_54[4-k] = u_54.w;
  endtask

  initial begin
    ci = 1; co = 0;
    #1 sample(0);
    ci = 0; co = 2;
    #1 sample(1);
    ci = 2; co = 2;
    #1 sample(2);
    ci = 2; co = 1;
    #1 sample(3);
    ci = 2; co = 2;
    #1 sample(4);
    $display("cell 1-0 wand->wire outside %b inside %b", o_10, i_10);
    $display("cell 1-2 wand->wor outside %b inside %b", o_12, i_12);
    $display("cell 1-4 wand->tri0 outside %b inside %b", o_14, i_14);
    $display("cell 1-5 wand->tri1 outside %b inside %b", o_15, i_15);
    $display("cell 2-1 wor->wand outside %b inside %b", o_21, i_21);
    $display("cell 2-4 wor->tri0 outside %b inside %b", o_24, i_24);
    $display("cell 2-5 wor->tri1 outside %b inside %b", o_25, i_25);
    $display("cell 4-1 tri0->wand outside %b inside %b", o_41, i_41);
    $display("cell 4-2 tri0->wor outside %b inside %b", o_42, i_42);
    $display("cell 4-5 tri0->tri1 outside %b inside %b", o_45, i_45);
    $display("cell 5-1 tri1->wand outside %b inside %b", o_51, i_51);
    $display("cell 5-2 tri1->wor outside %b inside %b", o_52, i_52);
    $display("cell 5-4 tri1->tri0 outside %b inside %b", o_54, i_54);
  end
endmodule
