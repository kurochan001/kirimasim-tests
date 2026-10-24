/*
:name: test_illegal_cg_default_sequence_array
:description: A default sequence bin cannot be an array of bins (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default sequence bin others is declared with [], which a default sequence does not accept
:expected_stderr_regex: test_illegal_cg_default_sequence_array\.sv:27:
*/
// IEEE 1800-2023 §19.5.2: a default sequence specification shall not accept
// multiple transition bins, that is, the [] notation is not allowed for it
// (Syntax 19-2 has no brackets in that form either). The bin others[] =
// default sequence is the only error; the transition bin up is legal. Icarus
// Verilog 13.0 does not support covergroups, so the syntax error it reports
// on that line does not count. Version 5.052 of Verilator accepts the design.

module test_illegal_cg_default_sequence_array;
  bit [2:0] v;

  covergroup cg;
    cp: coverpoint v {
      bins up = (1 => 2);
      bins others[] = default sequence;   // illegal: [] with default sequence
    }
  endgroup

  cg inst = new();

  initial begin
    v = 1;
    inst.sample();
    v = 2;
    inst.sample();
    $display("%.2f", inst.get_inst_coverage());
  end
endmodule
