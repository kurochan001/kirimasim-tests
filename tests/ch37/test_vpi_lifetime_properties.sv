/*
:name: test_vpi_lifetime_properties
:description: vpiAutomatic gives the default lifetime of instances and the lifetime of tasks, functions and variables, and a handle to a static variable of an automatic task, taken while the task runs, stays valid with its value change callback after the call ends (IEEE 1800-2023 Section 37.3.7)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.7 37.2.2 37.2.4 37.3.8 37.10 37.41 37.17 37.12 6.21 23.2.1 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_lifetime_properties.c
:expected_stdout: @test_vpi_lifetime_properties.expected
*/
// IEEE 1800-2023 §37.3.7: vpiAutomatic is false for a static object and true
// for a non-static one; on an instance (37.10) it is the default lifetime of
// the tasks and functions declared in it (23.2.1), which a task or function
// takes unless it declares its own lifetime, as the keyword of a scope gives
// the default of its objects (37.3.7, 37.41). Variables of a module are static
// whatever the module's lifetime, those of an automatic task are automatic, and
// one declared static inside it is static (6.21, 37.17). The application reads
// the variables from the task declaration (37.12).
//
// The static variable count of the automatic task tk exists for the whole
// simulation (6.21, 37.3.7) and belongs to no frame, so a handle to it stays
// valid until it is released (37.2.4, 37.3.8), and neither the handle nor a
// callback on it is released when a frame of tk ends (37.2.2 item 2, and its
// NOTE 3). $vt_keep, called inside the first call of tk at 1, takes a handle to
// count and puts a value change callback (38.36.1) on it. After the call, at 2,
// the handle reads 5; the second call at 3 changes count to 12, which the
// callback reports with the new value, and at 4 the handle reads 12.

`timescale 1ns/1ns

module automatic test_vpi_lifetime_properties_am;
  int mv = 0;

  task t_default(input int a);
    mv = a;
  endtask

  task static t_static(input int a);
    mv = mv + a;
  endtask

  initial begin
    t_default(1);
    t_static(2);
  end
endmodule

module test_vpi_lifetime_properties;
  int calls = 0;

  task automatic tk(input int x);
    static int count = 0;
    int auto_v;
    auto_v = x;
    count = count + auto_v;
    if (calls == 0) $vt_keep;
    calls++;
  endtask

  function int f_default(input int a);
    return a + 1;
  endfunction

  test_vpi_lifetime_properties_am am();

  initial begin
    $vt_lifetimes;
    #1 tk(5);
    #1 $vt_read;
    #1 tk(7);
    #1 $vt_read;
    calls = f_default(calls);
  end
endmodule
