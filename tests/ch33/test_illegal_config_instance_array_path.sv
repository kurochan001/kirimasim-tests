/*
:name: test_illegal_config_instance_array_path
:description: A hierarchical reference in a configuration parameter override cannot go through an array of instances (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3 23.3.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hierarchical name in a parameter override of the config goes through an element of an array of instances
:expected_stderr_regex: test_illegal_config_instance_array_path\.sv:36:
*/
// IEEE 1800-2023 §33.4.3: hierarchical references in parameter overrides
// of a configuration cannot include scopes of generate blocks or arrays of
// instances. The override of u takes the value of P from arr[0], an element
// of an array of instances of cfgia_top (23.3.3.5), which is an error.
// Icarus Verilog 13.0 and Verilator 5.052 do not support parameter
// overrides in a config, so the errors they report on that line do not
// count.

module cfgia_leaf #(parameter int W = 4) ();
  initial $display("W=%0d", W);
endmodule

module cfgia_holder #(parameter int P = 6) ();
endmodule

module cfgia_top;
  cfgia_holder arr [1:0] ();
  cfgia_leaf u();
endmodule

config cfgia;
  design work.cfgia_top;
  instance cfgia_top.u use #(.W(cfgia_top.arr[0].P));   // illegal: path through an instance array
endconfig
