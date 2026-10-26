/*
:name: test_port_collapse_trireg_and_uwire_cells
:description: Table 23-1 gives every cell whose dominating type is a trireg or a uwire, and the merged net keeps a charge or a single source as that type says, with the warnings the table marks (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_trireg_and_uwire_cells.expected
:expected_stderr_regex: (?i)warning
*/
// IEEE 1800-2023 §23.3.3.7: Table 23-1 selects the external net type for
// internal wand or wor with external trireg, for internal trireg with
// external wand or wor, and for internal trireg, tri0 or tri1 with external
// uwire; it selects the internal uwire for internal uwire with external
// trireg, tri0 or tri1. Every cell here is marked warn. A trireg net holds
// the value of its last drive while all drivers are z and starts at x
// (§6.6.4); a uwire net allows one driver only (§6.6.2), so those cells
// have the driver inside the module only. The first group runs the five
// phases (inside, outside) 1/0, 0/z, z/z, z/1, z/z and prints five samples;
// the second group drives 1, z, 0, z and prints four. A trireg gives x0011,
// a wand 00z1z and a wor 10z1z; a uwire passes its one driver, 1z0z, where
// a trireg would give 1101, a tri0 1000 and a tri1 1101. The cells 3-3,
// 6-6, 7-7 and 8-8 have the same type on both sides and are not here; see
// test_port_collapse_external_type_delay for the same-type cells whose
// delay can show which net the table selected. Neither release supports
// trireg, so this expected output follows the standard alone.

module cct_in_wand(inout wand w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module cct_in_wor(inout wor w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module cct_in_trireg(inout trireg w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module cct_in_tri0(inout tri0 w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module cct_in_tri1(inout tri1 w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module cct_in_uwire(inout uwire w, input logic [1:0] ci);
  assign w = ci[1] ? 1'bz : ci[0];
endmodule

module test_port_collapse_trireg_and_uwire_cells;
  logic [1:0] ci5, co5, ci4;
  logic [4:0] o_13, i_13;
  trireg n_13;
  assign n_13 = co5[1] ? 1'bz : co5[0];
  cct_in_wand u_13 (n_13, ci5);
  logic [4:0] o_23, i_23;
  trireg n_23;
  assign n_23 = co5[1] ? 1'bz : co5[0];
  cct_in_wor u_23 (n_23, ci5);
  logic [4:0] o_31, i_31;
  wand n_31;
  assign n_31 = co5[1] ? 1'bz : co5[0];
  cct_in_trireg u_31 (n_31, ci5);
  logic [4:0] o_32, i_32;
  wor n_32;
  assign n_32 = co5[1] ? 1'bz : co5[0];
  cct_in_trireg u_32 (n_32, ci5);
  logic [3:0] o_36, i_36;
  uwire n_36;
  cct_in_trireg u_36 (n_36, ci4);
  logic [3:0] o_46, i_46;
  uwire n_46;
  cct_in_tri0 u_46 (n_46, ci4);
  logic [3:0] o_56, i_56;
  uwire n_56;
  cct_in_tri1 u_56 (n_56, ci4);
  logic [3:0] o_63, i_63;
  trireg n_63;
  cct_in_uwire u_63 (n_63, ci4);
  logic [3:0] o_64, i_64;
  tri0 n_64;
  cct_in_uwire u_64 (n_64, ci4);
  logic [3:0] o_65, i_65;
  tri1 n_65;
  cct_in_uwire u_65 (n_65, ci4);

  task automatic sample5(int k);
    o_13[4-k] = n_13;
    i_13[4-k] = u_13.w;
    o_23[4-k] = n_23;
    i_23[4-k] = u_23.w;
    o_31[4-k] = n_31;
    i_31[4-k] = u_31.w;
    o_32[4-k] = n_32;
    i_32[4-k] = u_32.w;
  endtask

  task automatic sample4(int k);
    o_36[3-k] = n_36;
    i_36[3-k] = u_36.w;
    o_46[3-k] = n_46;
    i_46[3-k] = u_46.w;
    o_56[3-k] = n_56;
    i_56[3-k] = u_56.w;
    o_63[3-k] = n_63;
    i_63[3-k] = u_63.w;
    o_64[3-k] = n_64;
    i_64[3-k] = u_64.w;
    o_65[3-k] = n_65;
    i_65[3-k] = u_65.w;
  endtask

  initial begin
    ci5 = 1; co5 = 0;
    #1 sample5(0);
    ci5 = 0; co5 = 2;
    #1 sample5(1);
    ci5 = 2; co5 = 2;
    #1 sample5(2);
    ci5 = 2; co5 = 1;
    #1 sample5(3);
    ci5 = 2; co5 = 2;
    #1 sample5(4);
    ci4 = 1;
    #1 sample4(0);
    ci4 = 2;
    #1 sample4(1);
    ci4 = 0;
    #1 sample4(2);
    ci4 = 2;
    #1 sample4(3);
    $display("cell 1-3 wand->trireg outside %b inside %b", o_13, i_13);
    $display("cell 2-3 wor->trireg outside %b inside %b", o_23, i_23);
    $display("cell 3-1 trireg->wand outside %b inside %b", o_31, i_31);
    $display("cell 3-2 trireg->wor outside %b inside %b", o_32, i_32);
    $display("cell 3-6 trireg->uwire outside %b inside %b", o_36, i_36);
    $display("cell 4-6 tri0->uwire outside %b inside %b", o_46, i_46);
    $display("cell 5-6 tri1->uwire outside %b inside %b", o_56, i_56);
    $display("cell 6-3 uwire->trireg outside %b inside %b", o_63, i_63);
    $display("cell 6-4 uwire->tri0 outside %b inside %b", o_64, i_64);
    $display("cell 6-5 uwire->tri1 outside %b inside %b", o_65, i_65);
    $finish;
  end
endmodule
