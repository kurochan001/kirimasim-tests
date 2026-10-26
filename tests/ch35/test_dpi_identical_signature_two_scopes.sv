/*
:name: test_dpi_identical_signature_two_scopes
:description: two import declarations of one c_identifier in different modules have the same return type, argument list and qualifiers, so both resolve to the one global foreign function; imports also take an explicit c_identifier, the function name itself, and the pure and context properties (IEEE 1800-2023 Sections 35.4, 35.5.4 and 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.4 35.5.4 35.5.2 35.5.3 35.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_identical_signature_two_scopes.c
:expected_stdout: @test_dpi_identical_signature_two_scopes.expected
*/
// IEEE 1800-2023 §35.5.4: an import declaration names the linkage name with an
// optional c_identifier, which defaults to the SystemVerilog name, and takes an
// optional context or pure property and a function prototype. §35.4: all
// declarations of one linkage identifier in different scopes must have the
// same result type, arguments and qualifiers, and then they denote one global
// symbol. §35.5.2: a pure import is a nonvoid function with no output or inout
// arguments. §35.5.3: a context import may call exports.
//
// The modules dpi_same_one and dpi_same_two declare same_foreign with the same
// two int arguments and int result, so both calls reach the one C function,
// which returns 10*a+b. The top module imports identity without a
// c_identifier, a pure function plus_one and a context function with_context.
// The three processes print at 1, 2 and 3 ns.

module dpi_same_one;
  import "DPI-C" same_foreign = function int first_copy(input int a, input int b);

  initial #1 $display("first copy=%0d", first_copy(3, 4));
endmodule

module dpi_same_two;
  import "DPI-C" same_foreign = function int second_copy(input int a, input int b);

  initial #2 $display("second copy=%0d", second_copy(5, 6));
endmodule

module test_dpi_identical_signature_two_scopes;
  import "DPI-C" function int identity(input int a);
  import "DPI-C" pure function int plus_one(input int a);
  import "DPI-C" context function int with_context(input int a);

  dpi_same_one u1();
  dpi_same_two u2();

  initial #3 $display("plain=%0d pure=%0d context=%0d",
                      identity(9), plus_one(9), with_context(9));
endmodule
