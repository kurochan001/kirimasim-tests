/*
:name: test_format_library_cell_default_work
:description: %l and %L print library.cell for the module instance that calls the display task, with the library work for source files that no library map assigns (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 33.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_library_cell_default_work.expected
*/
// IEEE 1800-2023 §21.2.1.1: %l or %L displays the library binding of the
// module instance that calls the task as "library.cell": the library from
// which the instance was taken and its cell name, and like %m it takes no
// argument. §33.2.1: the cell name is the name of the design element.
// §33.3.1: a source file that matches no library of the library map is
// compiled into the library named work; the test is run without a library
// map, so every module here is in work.
// The top module and two instances of another module print their binding
// with %l and %L at different times; the value after %l shows that %l takes
// no argument.
// Icarus Verilog 13.0 does not support %l and prints <%l>.

module cell_lib_sub;
  parameter int N = 0;
  initial #N $display("u%0d [%l][%L]", N);
endmodule

module test_format_library_cell_default_work;
  cell_lib_sub #(.N(1)) u1();
  cell_lib_sub #(.N(2)) u2();

  initial begin
    $display("[%l][%L] %0d", 7);
  end
endmodule
