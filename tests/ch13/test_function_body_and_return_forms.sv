/*
:name: test_function_body_and_return_forms
:description: A non-ANSI function body after the return specification, the function name, a semicolon, its tf-item declarations, its statements and an optional end label works with an implicit one-bit return, an integer return, void, an explicit packed range and an automatic lifetime, and returns the values its statements assign (IEEE 1800-2023 Sections 13.4, A.2.6)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 A.2.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_body_and_return_forms.expected
*/
// IEEE 1800-2023 A.2.6: a function_data_type_or_implicit is a data type,
// void or an implicit data type, and a non-ANSI function_body_declaration is
// that specification, the function identifier, a semicolon, any number of
// tf_item_declarations, any number of function statements or null statements
// and endfunction with an optional matching name.
//
// f_implicit has the implicit data type, one bit; f_integer sets the result
// from its input; f_void has no result and prints its input; f_range is
// automatic with a four-bit result; f_block declares a variable among its
// tf items, uses a return statement and carries an end label. The printed
// values are the results the statements assign: 1, 5, 12 and 11, and the
// void function prints 9.

`timescale 1ns/1ns

module test_function_body_and_return_forms;
  function f_implicit;
    f_implicit = 1'b1;
  endfunction

  function integer f_integer;
    input integer a;
    f_integer = a + 1;
  endfunction : f_integer

  function void f_void;
    input int a;
    $display("void %0d", a);
  endfunction

  function automatic [3:0] f_range;
    input [3:0] a;
    f_range = a ^ 4'hF;
  endfunction

  function int f_block;
    input int a;
    int b;
    b = a * 2;
    return b + 1;
  endfunction : f_block

  initial begin
    f_void(9);
    $display("implicit=%b integer=%0d range=%0d block=%0d",
             f_implicit(), f_integer(4), f_range(3), f_block(5));
  end
endmodule
