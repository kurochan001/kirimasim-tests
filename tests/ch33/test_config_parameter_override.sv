/*
:name: test_config_parameter_override
:description: A config sets parameters with use #(...): to a literal, to a localparam of the config, to a parameter of the parent, or back to their defaults with #() and #(.W()) (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.3 33.4.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_parameter_override.expected
*/
// IEEE 1800-2023 §33.4.3: "instance <path> use #(...)" overrides parameters of
// that instance. A value may be a literal or a localparam of the config; a
// hierarchical name, resolved from the parent of the instance, may be the whole
// value. "use #()" sets every parameter of the instance back to the default of
// its module, dropping the overrides of the instantiation, and "use #(.W())"
// does this for W only. The config also changes WIDTH of the top-level module,
// and a5 takes the changed value. Icarus Verilog 13.0 skips config
// declarations, and Verilator 5.052 does not support a localparam in a config.

module cfg_param_leaf #(parameter int W = 8, parameter int D = 4) ();
endmodule

module test_config_parameter_override;
  parameter int WIDTH = 16;

  cfg_param_leaf a1();
  cfg_param_leaf a2();
  cfg_param_leaf #(.W(10), .D(20)) a3();
  cfg_param_leaf #(.W(11), .D(21)) a4();
  cfg_param_leaf a5();

  initial begin
    $display("WIDTH=%0d", WIDTH);
    $display("a1: W=%0d D=%0d", a1.W, a1.D);
    $display("a2: W=%0d D=%0d", a2.W, a2.D);
    $display("a3: W=%0d D=%0d", a3.W, a3.D);
    $display("a4: W=%0d D=%0d", a4.W, a4.D);
    $display("a5: W=%0d D=%0d", a5.W, a5.D);
  end
endmodule

config cfg;
  localparam S = 24;
  design work.test_config_parameter_override;
  instance test_config_parameter_override use #(.WIDTH(32));
  instance test_config_parameter_override.a1 use #(.W(12));
  instance test_config_parameter_override.a2 use #(.W(S));
  instance test_config_parameter_override.a3 use #();
  instance test_config_parameter_override.a4 use #(.W());
  instance test_config_parameter_override.a5 use #(.W(test_config_parameter_override.WIDTH));
endconfig
