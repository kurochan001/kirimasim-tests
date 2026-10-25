/*
:name: test_dpi_import_unnamed_formal_arguments
:description: The formal arguments of an import declaration, a function or task prototype, can be given by type and direction without names, and the actual arguments then bind to them by position, for input, output and inout formals of a function and a task (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 13.5.1 A.2.7 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_unnamed_formal_arguments.c
:expected_stdout: @test_dpi_import_unnamed_formal_arguments.expected
*/
// IEEE 1800-2023 §35.5.4 with footnote 28 of A.10 (on tf_port_item,
// A.2.7): the name of a formal argument can be left out only in a function
// or task prototype, and an import declaration is one (dpi_function_proto
// and dpi_task_proto are function_prototype and task_prototype). Formal
// names are needed only for binding by name, so the calls here bind by
// position.
//
// dpi_n_mix(int, byte, shortint) returns a * 10000 + b * 100 + c, so its
// value shows each actual in its place: dpi_n_mix(7, 8, 9) = 70809.
// dpi_n_split(input int, output int, output int) writes the quotient and
// the remainder of its input by 10 to the two outputs, in that order.
// dpi_n_step(inout int, input int), a void function, adds its second
// argument to its first. The task dpi_n_task(input int, output int, inout
// int) writes three times its input to the second argument and doubles the
// third. Each call with other values would give other results.
//
// Icarus Verilog 13.0 has no DPI. The 5.052 release of Verilator reports
// a syntax error at the first formal argument without a name.

module test_dpi_import_unnamed_formal_arguments;
  import "DPI-C" function int dpi_n_mix(int, byte, shortint);
  import "DPI-C" function void dpi_n_split(input int, output int, output int);
  import "DPI-C" function void dpi_n_step(inout int, input int);
  import "DPI-C" task dpi_n_task(input int, output int, inout int);

  initial begin
    int q, r, acc, t_out, t_io;
    $display("mix: %0d %0d", dpi_n_mix(7, 8, 9), dpi_n_mix(1, 0, 2));
    dpi_n_split(57, q, r);
    $display("split: q=%0d r=%0d", q, r);
    acc = 100;
    dpi_n_step(acc, 5);
    dpi_n_step(acc, 20);
    $display("step: acc=%0d", acc);
    t_io = 4;
    dpi_n_task(6, t_out, t_io);
    $display("task: out=%0d io=%0d", t_out, t_io);
  end
endmodule
