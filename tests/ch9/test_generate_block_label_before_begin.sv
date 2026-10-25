/*
:name: test_generate_block_label_before_begin
:description: a label written before the begin of a generate block names the block, so the items declared in it are reached through that name, also with the matching name after end (IEEE 1800-2023 Section 9.3.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.5 27.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_block_label_before_begin.expected
*/
// IEEE 1800-2023 §9.3.5: a label may be written before the begin of a
// generate begin-end block (27.3), where it names the block as a name
// after begin would. The conditional generate block below is labeled cfg
// and ends with "end : cfg"; each generated block of the loop is labeled
// row. The parameter, variable and net declared in them are reached as
// cfg.K, cfg.q, row[1].r and row[2].w.
//
// Icarus Verilog 13.0 does not accept a label before a generate begin.

module test_generate_block_label_before_begin;
  localparam bit USE = 1;

  if (USE) cfg: begin
    localparam int K = 3;
    int q = 30;
  end : cfg

  for (genvar i = 0; i < 3; i++) row: begin
    int r = 10 * i;
    wire [7:0] w = 8'(i + 100);
  end

  initial #1 $display("cfg.K=%0d cfg.q=%0d row[1].r=%0d row[2].w=%0d", cfg.K, cfg.q, row[1].r,
                      row[2].w);
endmodule
