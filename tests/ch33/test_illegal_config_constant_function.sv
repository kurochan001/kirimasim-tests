/*
:name: test_illegal_config_constant_function
:description: A parameter override of a configuration cannot call a constant function other than a built-in constant system function (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3 13.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a parameter override of the config calls a user-defined constant function
:expected_stderr_regex: test_illegal_config_constant_function\.sv:38:
*/
// IEEE 1800-2023 §33.4.3: a parameter override in a configuration shall not
// refer to a constant function (13.4.3) other than a built-in constant
// system function such as $clog2. The override of u calls twice, a function
// of the package cfgcf_pkg, which is an error.
// Icarus Verilog 13.0 and Verilator 5.052 do not support parameter
// overrides in a config, so the errors they report on that line do not
// count.

package cfgcf_pkg;
  function automatic int twice(input int v);
    return 2 * v;
  endfunction
endpackage

module cfgcf_leaf #(parameter int W = 4) ();
  initial $display("W=%0d", W);
endmodule

module cfgcf_top;
  cfgcf_leaf u();
endmodule

config cfgcf;
  design work.cfgcf_top;
  instance cfgcf_top.u use #(.W(cfgcf_pkg::twice(3)));   // illegal: user constant function
endconfig
