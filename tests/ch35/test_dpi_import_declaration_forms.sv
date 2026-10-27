/*
:name: test_dpi_import_declaration_forms
:description: Imported functions and tasks are declared with zero or more input, output and inout formals, imported functions return a value or are void, and an imported task, implemented by a C function that returns int, is called as a task enable (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 35.5.6 35.8 35.9 H.8.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_declaration_forms.c
:expected_stdout: @test_dpi_import_declaration_forms.expected
*/
// IEEE 1800-2023 §35.5.4: every imported subroutine is declared by an import
// declaration and can have zero or more formal input, output and inout
// arguments; an imported function returns a result or is void, and an
// imported task returns an int in C for the disable protocol (35.8, 35.9),
// while SystemVerilog calls it as a task. Output and inout formals of type
// int are pointers in C (H.8.8).
//
// c_count has no formals and returns the next value of a counter in C, which
// the void function c_reset sets from its input. c_split returns 2 and writes
// the upper and lower halves of its input into its two outputs. The void
// function c_twice doubles its inout argument. The task c_swap exchanges its
// two inout arguments, and the task c_add_hundred, without formals, adds 100
// to the counter; both are C functions returning 0 and are called as
// statements. Each step is printed with the values it gives.

module test_dpi_import_declaration_forms;
  import "DPI-C" function int c_count();
  import "DPI-C" function void c_reset(input int v);
  import "DPI-C" function int c_split(input int v, output int hi, output int lo);
  import "DPI-C" function void c_twice(inout int v);
  import "DPI-C" task c_swap(inout int a, inout int b);
  import "DPI-C" task c_add_hundred();

  int r1, r2, hi, lo, v, a, b;

  initial begin
    c_reset(10);
    r1 = c_count();
    r2 = c_count();
    $display("c_count after c_reset(10): %0d then %0d", r1, r2);
    r1 = c_split(32'h12345678, hi, lo);
    $display("c_split: result %0d, hi %h, lo %h", r1, hi, lo);
    v = 21;
    c_twice(v);
    $display("c_twice: v %0d", v);
    a = 3;
    b = 8;
    c_swap(a, b);
    $display("c_swap: a %0d, b %0d", a, b);
    c_add_hundred;
    r1 = c_count();
    $display("c_count after c_add_hundred: %0d", r1);
  end
endmodule
