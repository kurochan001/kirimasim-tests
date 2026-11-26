/*
:name: test_config_expansion_forms
:description: Configuration cell binding, an empty liblist, and named overrides with use
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.6 A.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: expansion_cfg
:expected_stdout: @test_config_expansion_forms.expected
*/
module expansion_default #(parameter int P = 1, Q = 2);
endmodule

module expansion_replacement #(parameter int P = 3, Q = 4);
endmodule

module test_config_expansion_forms;
  expansion_default named_only(), cell_and_named(), nested(), default_cell();

  initial begin
    #1;
    $display("bindings %0d,%0d %0d,%0d %0d %0d", named_only.P, named_only.Q,
             cell_and_named.P, cell_and_named.Q, nested.P, default_cell.P);
    $finish(0);
  end
endmodule

config expansion_nested;
  design work.expansion_replacement;
endconfig

config expansion_cfg;
  design work.test_config_expansion_forms;
  cell expansion_default liblist;
  cell work.expansion_replacement use work.expansion_replacement;
  instance test_config_expansion_forms.named_only use .P(11), .Q(12);
  instance test_config_expansion_forms.cell_and_named
    use work.expansion_replacement .P(13), .Q(14);
  instance test_config_expansion_forms.nested use work.expansion_nested:config;
endconfig
