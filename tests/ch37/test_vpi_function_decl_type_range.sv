/*
:name: test_vpi_function_decl_type_range
:description: a function gives vpiFuncType for the type of its result, vpiSigned for the signedness of its result and, for a result with a range, the left and the right bound through vpiLeftRange and vpiRightRange; the io declarations of a task or function lead back to it, and a method leads to its class definition (IEEE 1800-2023 Section 37.41)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.41 37.13 37.31 13.4 13.4.1 6.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_function_decl_type_range.c
:expected_stdout: @test_vpi_function_decl_type_range.expected
*/
// IEEE 1800-2023 §37.41: vpiFuncType of a function is the category of its
// result (13.4.1): vpiIntFunc for integer, vpiRealFunc for real, vpiTimeFunc
// for time, vpiSizedFunc for an unsigned vector, vpiSizedSignedFunc for a
// signed vector and vpiOtherFunc for another type, here string. vpiSigned is
// TRUE for the signed integer and logic signed [3:0] results and FALSE for
// time and logic [7:2] (6.11). For a result with a range, vpiLeftRange and
// vpiRightRange give its bounds: 7 and 2, and 3 and 0. An io decl has a
// one-to-one relation to its task or function (vpi_handle(vpiTaskFunc, io),
// 37.13), here every io decl of f_int and of the task t_io. A method has a
// one-to-one relation to its class defn: m1 and t1 lead to c1 and m2 to c2;
// the methods are found from the class definitions of the module (37.31).
// Lists are sorted.

module test_vpi_function_decl_type_range;
  class c1;
    function int m1();
      return 1;
    endfunction
    task t1();
    endtask
  endclass

  class c2;
    function int m2();
      return 2;
    endfunction
  endclass

  function integer f_int(input int a, output int b);
    b = a;
    return a;
  endfunction

  function real f_real(input real r);
    return r;
  endfunction

  function time f_time();
    return 0;
  endfunction

  function logic [7:2] f_vec(input logic x);
    return {6{x}};
  endfunction

  function logic signed [3:0] f_svec();
    return -4'sd1;
  endfunction

  function string f_str();
    return "s";
  endfunction

  task t_io(input int x, inout logic y, output bit z);
    z = y;
  endtask

  initial #1 $vt_funcs;
endmodule
