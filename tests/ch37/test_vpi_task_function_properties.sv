/*
:name: test_vpi_task_function_properties
:description: a function's vpiReturn is a variable with the function's name, the typedef of a user-defined return type and its size; tasks and functions give their visibility, method and virtual flags, the full name of an imported package function and of a class method, the DPI export properties, and the io declaration of a ref argument (IEEE 1800-2023 Section 37.41)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.41 37.13 37.31 37.10 37.12 37.25 35.7 8.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_task_function_properties.c
:expected_stdout: @test_vpi_task_function_properties.expected
*/
// IEEE 1800-2023 §37.41: a function contains a variable with its name, size and
// type that holds its return value (detail 1); vpiReturn gives it, always as a
// variable (detail 3), and for a user-defined type it gives the details of that
// type (detail 2), here the struct typespec named pair_t (37.25 detail 1).
// vpiVisibility is vpiPublicVis for a task or function that is not a class
// member and for a method that is neither local nor protected, and vpiLocalVis
// or vpiProtectedVis otherwise (detail 4; 8.18); vpiMethod is true for the
// class members, which detail 4 calls methods, and vpiVirtual, a property of
// the diagram, for the virtual one. The full name of a function of a package or
// of a class defn is that of the package or class defn followed by :: and its
// name (detail 5); the class defn, inside the module, has a . before its name
// (37.10 detail 5). vpiMethods of the class gives its declared methods (37.31
// detail 1), and vpiImport of the module the package function it imports and
// calls (37.12 detail 4). For the function sv_hook exported to C (35.7),
// vpiAccessType is vpiDPIExportAcc, vpiDPICStr is vpiDPIC for "DPI-C" and
// vpiDPICIdentifier is the C linkage name (details 6, 9 and 10); an export
// needs no C code, so the test has no DPI C file. §37.13: the io declaration
// of the ref argument slot of bump has vpiDirection vpiRef and a ref obj as
// vpiExpr (details 1 and 2). The methods are printed sorted by name.

`timescale 1ns/1ns

package test_vpi_task_function_properties_pkg;
  function automatic int twice(input int v);
    return 2 * v;
  endfunction
endpackage

module test_vpi_task_function_properties;
  import test_vpi_task_function_properties_pkg::twice;

  typedef struct {
    int lo;
    int hi;
  } pair_t;

  class counter;
    local int n;

    protected function int peek();
      return n;
    endfunction

    local function void reset();
      n = 0;
    endfunction

    virtual function int next();
      n++;
      return n;
    endfunction

    function int get();
      return peek();
    endfunction
  endclass

  pair_t p;
  int got, sum;
  logic [4:1] tally = 4'd2;

  function pair_t make_pair(input int v);
    make_pair.lo = v;
    make_pair.hi = v + 1;
  endfunction

  function bit [3:0] nib(input int v);
    return v[3:0];
  endfunction

  task automatic bump(ref logic [4:1] slot);
    slot = slot + 1;
  endtask

  export "DPI-C" vt_sv_hook = function sv_hook;

  function int sv_hook(input int v);
    return v + 3;
  endfunction

  initial begin
    counter c;
    c = new;
    p = make_pair(4);
    got = nib(18) + twice(2) + c.next() + c.get();
    bump(tally);
    sum = sv_hook(2);
    $vt_tf;
  end
endmodule
