/*
:name: test_illegal_config_generate_scope_path
:description: A hierarchical reference in a configuration parameter override cannot go through a generate scope (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hierarchical name in a parameter override of the config goes through a generate block
:expected_stderr_regex: test_illegal_config_generate_scope_path\.sv:35:
*/
// IEEE 1800-2023 §33.4.3: hierarchical references in parameter overrides
// of a configuration cannot include scopes of generate blocks or arrays of
// instances. The override of u takes the value of P from the generate
// block g of cfggs_top (27.5), which is an error.
// Icarus Verilog 13.0 and Verilator 5.052 do not support parameter
// overrides in a config, so the errors they report on that line do not
// count.

module cfggs_leaf #(parameter int W = 4) ();
  initial $display("W=%0d", W);
endmodule

module cfggs_top;
  if (1) begin : g
    localparam int P = 9;
  end
  cfggs_leaf u();
endmodule

config cfggs;
  design work.cfggs_top;
  instance cfggs_top.u use #(.W(cfggs_top.g.P));   // illegal: path through a generate block
endconfig
