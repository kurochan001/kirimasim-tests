/*
:name: test_vpi_instance_binding_properties_follow_selected_rules
:description: VPI reports compilation library, bound cell and controlling configuration for sibling module instances selected by different binding clauses
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.7 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_instance_binding_properties_follow_selected_rules
:vpi_c: @test_vpi_instance_binding_properties_follow_selected_rules.c
:expected_stdout: @test_vpi_instance_binding_properties_follow_selected_rules.expected
*/
module binding_probe_original(output wire [7:0] value);
  assign value = 8'ha1;
endmodule

module binding_probe_outer_cell(output wire [7:0] value);
  assign value = 8'hb2;
endmodule

module binding_probe_inner_cell(output wire [7:0] value);
  assign value = 8'hc3;
endmodule

module binding_probe_branch(output wire [7:0] value);
  binding_probe_original nested(value);
endmodule

module test_vpi_instance_binding_properties_follow_selected_rules;
  wire [7:0] by_default, by_use, by_nested;
  binding_probe_original plain(by_default);
  binding_probe_original replaced(by_use);
  binding_probe_branch branch(by_nested);
  initial begin
    #1;
    $display("outputs=%h %h %h", by_default, by_use, by_nested);
    $vt_report_binding_properties;
  end
endmodule

config binding_probe_nested;
  design work.binding_probe_branch;
  default liblist work;
  instance binding_probe_branch.nested use work.binding_probe_inner_cell;
endconfig

config binding_probe_outer;
  design work.test_vpi_instance_binding_properties_follow_selected_rules;
  default liblist work;
  instance test_vpi_instance_binding_properties_follow_selected_rules.replaced
    use work.binding_probe_outer_cell;
  instance test_vpi_instance_binding_properties_follow_selected_rules.branch
    use work.binding_probe_nested:config;
endconfig
