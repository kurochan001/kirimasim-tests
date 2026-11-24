/*
:name: test_dpi_resolves_imports_from_two_foreign_objects
:description: A DPI design calls two independent imported symbols backed by shared objects
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 J.3 J.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_resolves_imports_from_two_foreign_objects.expected
:dpi_c: @test_dpi_resolves_imports_from_two_foreign_objects.c
*/
module test_dpi_resolves_imports_from_two_foreign_objects;
  import "DPI-C" function int from_left(input int value);
  import "DPI-C" function int from_right(input int value);

  initial begin
    $display("from left=%0d right=%0d", from_left(8), from_right(13));
  end
endmodule
