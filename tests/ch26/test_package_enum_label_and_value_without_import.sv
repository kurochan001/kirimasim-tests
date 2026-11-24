/*
:name: test_package_enum_label_and_value_without_import
:description: Package qualification accesses an enum label and a value without an import
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.5 26.3
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_enum_label_and_value_without_import.expected
*/
// A qualified reference does not require an import or a local declaration.
package qualified_values;
  typedef enum int {OFF = 3, ON = 7} mode_t;
  localparam int step = 12;
endpackage

module test_package_enum_label_and_value_without_import;
  qualified_values::mode_t mode = qualified_values::ON;
  initial begin
    $display("on=%0d step=%0d", mode == qualified_values::ON, qualified_values::step);
    mode = qualified_values::OFF;
    $display("raw=%0d off=%0d", mode, mode == qualified_values::OFF);
  end
endmodule
