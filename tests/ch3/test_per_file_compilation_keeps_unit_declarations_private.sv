/*
:name: test_per_file_compilation_keeps_unit_declarations_private
:description: Independent source files may declare different types and values under the same unit names
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_per_file_compilation_keeps_unit_declarations_private.expected
:files: unit_mode_provider.sv
:args: --compilation-unit=per-file
*/
typedef bit [5:0] item;
item local_value = 6'd41;

module test_per_file_compilation_keeps_unit_declarations_private;
  unit_mode_provider remote();

  initial begin
    remote.bump();
    $display("local=%0d bits=%0d remote=%0d", $unit::local_value, $bits(item), remote.current());
  end
endmodule
