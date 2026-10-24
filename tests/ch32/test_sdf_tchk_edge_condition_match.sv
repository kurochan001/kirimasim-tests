/*
:name: test_sdf_tchk_edge_condition_match
:description: An SDF timing check without edges or conditions annotates every timing check of its signals whatever their edges and conditions, and one with an edge or a COND annotates only the timing checks whose edge or condition is the same (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 31.3.2 31.7 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_tchk_edge_condition_match.expected
*/
// IEEE 1800-2023 §32.4.2: an SDF timing check whose signals have no edges and
// no conditions annotates all the matching timing checks, whether they have
// edges or conditions or not. When the SDF timing check gives an edge or a
// condition (COND) for a signal, the timing check is annotated only if it has
// the same edge or condition there; a qualifier the SDF entry does not give
// is not compared.
//
// The cell has $hold(posedge c &&& en, d, 1, n_p) and $hold(negedge c, d, 1,
// n_n). Each instance gets one HOLD entry with the limit 4:
//   qa (HOLD d c ...): both checks.
//   qb (HOLD d (posedge c) ...): only the posedge check.
//   qc (HOLD d (COND en (posedge c)) ...): only the posedge check.
//   qd (HOLD d (negedge c) ...): only the negedge check.
//   qe (HOLD d (COND en (negedge c)) ...): neither, as the negedge check has
//   no condition.
//   qf (HOLD d (COND en c) ...): only the posedge check, the one with the
//   condition en.
// en stays 1. d changes 2 after the rising edge of c at 10 and 2 after its
// falling edge at 20: with the limit 4 that is a hold violation (§31.3.2) at
// 12 for the posedge check and at 22 for the negedge check, and with the
// limit 1 none. §31.6: each violation toggles the notifier. The times at
// which each notifier changes are printed at the end. The test creates its
// SDF file in the current directory.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module sdf_q_cell (input c, d, en);
  reg n_p = 0, n_n = 0;
  specify
    $hold(posedge c &&& en, d, 1, n_p);
    $hold(negedge c, d, 1, n_n);
  endspecify
endmodule

module test_sdf_tchk_edge_condition_match;
  reg c = 0, d = 0, en = 1;
  string s[12];
  integer f;

  sdf_q_cell qa (c, d, en);
  sdf_q_cell qb (c, d, en);
  sdf_q_cell qc (c, d, en);
  sdf_q_cell qd (c, d, en);
  sdf_q_cell qe (c, d, en);
  sdf_q_cell qf (c, d, en);

  always @(qa.n_p) s[0] = {s[0], $sformatf(" %0d", $time)};
  always @(qa.n_n) s[1] = {s[1], $sformatf(" %0d", $time)};
  always @(qb.n_p) s[2] = {s[2], $sformatf(" %0d", $time)};
  always @(qb.n_n) s[3] = {s[3], $sformatf(" %0d", $time)};
  always @(qc.n_p) s[4] = {s[4], $sformatf(" %0d", $time)};
  always @(qc.n_n) s[5] = {s[5], $sformatf(" %0d", $time)};
  always @(qd.n_p) s[6] = {s[6], $sformatf(" %0d", $time)};
  always @(qd.n_n) s[7] = {s[7], $sformatf(" %0d", $time)};
  always @(qe.n_p) s[8] = {s[8], $sformatf(" %0d", $time)};
  always @(qe.n_n) s[9] = {s[9], $sformatf(" %0d", $time)};
  always @(qf.n_p) s[10] = {s[10], $sformatf(" %0d", $time)};
  always @(qf.n_n) s[11] = {s[11], $sformatf(" %0d", $time)};

  initial begin
    f = $fopen("test_sdf_tchk_edge_condition_match.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_q_cell\") (INSTANCE qa)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d c (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_q_cell\") (INSTANCE qb)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d (posedge c) (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_q_cell\") (INSTANCE qc)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d (COND en (posedge c)) (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_q_cell\") (INSTANCE qd)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d (negedge c) (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_q_cell\") (INSTANCE qe)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d (COND en (negedge c)) (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_q_cell\") (INSTANCE qf)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d (COND en c) (4)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_tchk_edge_condition_match.sdf");
    #10 c = 1;           // 10
    #2 d = 1;            // 12: 2 after the rising edge
    #8 c = 0;            // 20
    #2 d = 0;            // 22: 2 after the falling edge
    #18 $display("qa: posedge:%s negedge:%s", s[0], s[1]);
    $display("qb: posedge:%s negedge:%s", s[2], s[3]);
    $display("qc: posedge:%s negedge:%s", s[4], s[5]);
    $display("qd: posedge:%s negedge:%s", s[6], s[7]);
    $display("qe: posedge:%s negedge:%s", s[8], s[9]);
    $display("qf: posedge:%s negedge:%s", s[10], s[11]);
  end
endmodule
