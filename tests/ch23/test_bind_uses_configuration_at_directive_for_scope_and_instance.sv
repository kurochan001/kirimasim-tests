/*
:name: test_bind_uses_configuration_at_directive_for_scope_and_instance
:description: A bind uses the cell selection of its own configuration for both the target scope and bound instance
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 33.4.1.3 33.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bind_uses_configuration_at_directive_for_scope_and_instance.expected
*/
module bind_site_payload(output wire [7:0] marker);
  assign marker = 8'd41;
endmodule

module bind_target_payload(output wire [7:0] marker);
  assign marker = 8'd73;
endmodule

module bind_payload(output wire [7:0] marker);
  assign marker = 8'd11;
endmodule

module bind_scope_alias;
endmodule

module bind_left_cell;
  wire [7:0] by_scope, by_instance;
  wire [7:0] normal;
  bind_payload ordinary(normal);
endmodule

module bind_right_cell;
  wire [7:0] by_scope, by_instance;
  wire [7:0] normal;
  bind_payload ordinary(normal);
endmodule

module bind_origin;
  bind bind_scope_alias bind_payload scope_probe(by_scope);
  bind test_bind_uses_configuration_at_directive_for_scope_and_instance.right
    bind_payload instance_probe(by_instance);
endmodule

module test_bind_uses_configuration_at_directive_for_scope_and_instance;
  bind_origin origin();
  bind_scope_alias left();
  bind_scope_alias right();

  initial #1 begin
    $display("left scope=%0d instance=%0d ordinary=%0d",
             left.by_scope, left.by_instance, left.normal);
    $display("right scope=%0d instance=%0d ordinary=%0d",
             right.by_scope, right.by_instance, right.normal);
    $finish(0);
  end
endmodule

config test_bind_site_cfg;
  design work.test_bind_uses_configuration_at_directive_for_scope_and_instance;
  default liblist work;
  cell bind_scope_alias use work.bind_left_cell;
  cell bind_payload use work.bind_site_payload;
  instance test_bind_uses_configuration_at_directive_for_scope_and_instance.left
    use work.test_bind_left_cfg:config;
  instance test_bind_uses_configuration_at_directive_for_scope_and_instance.right
    use work.test_bind_right_cfg:config;
endconfig

config test_bind_left_cfg;
  design work.bind_left_cell;
  default liblist work;
  cell bind_payload use work.bind_target_payload;
endconfig

config test_bind_right_cfg;
  design work.bind_right_cell;
  default liblist work;
  cell bind_payload use work.bind_target_payload;
endconfig
