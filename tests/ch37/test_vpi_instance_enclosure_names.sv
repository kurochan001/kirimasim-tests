/*
:name: test_vpi_instance_enclosure_names
:description: vpiInstance gives the immediate compilation unit, package, module, interface or program of an object, vpiModule gives its module or NULL outside modules, vpiUnit tells a compilation unit from a package, and full names use $unit:: and package:: before the first component, :: after a class defn and . elsewhere (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 3.12.1 26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_enclosure_names.c
:expected_stdout: @test_vpi_instance_enclosure_names.expected
*/
// IEEE 1800-2023 §37.10: package, interface, program and module are the
// members of the instance group, and a package that is a compilation unit
// (3.12.1) has vpiUnit TRUE. vpiInstance gives the immediate instance in which
// an object is (detail 3): the instance and not a named block in it, the
// nested instance and not the top module. vpiModule gives the module that
// contains the object, and NULL for an object that is not in a module
// (detail 2), such as a compilation-unit or package variable. The full name of
// an object in a compilation unit begins with "$unit::", that of an object in
// a package with the package name and "::", and "." separates the components
// that follow (detail 5), except after a package or a class defn, so the
// static property cnt of the class ie_cls is ie_cls::cnt; the full name of a
// package is its name, which should be followed by "::", so the application
// removes a final "::" before it prints it. Interface and program objects get
// no vpiModule line: whether an interface or program instance inside a module
// counts as being inside that module is not needed here. The compilation-unit
// and package variables are passed as arguments, since items of a compilation
// unit cannot be found by vpi_handle_by_name (detail 6).

int cu_var = 3;

package ie_pkg;
  int pv = 1;

  task pt;
    int tv;
    tv = pv;
  endtask
endpackage

interface ie_if;
  logic iv;
endinterface

program ie_prog;
  int prv;
endprogram

module ie_leaf;
  logic lv;

  class ie_cls;
    static int cnt;
  endclass

  initial begin : blk
    logic bv;
    bv = 1'b0;
  end
endmodule

module test_vpi_instance_enclosure_names;
  ie_leaf u();
  ie_if ifc();
  ie_prog pr();

  initial #1 $vt_enclosure(cu_var, ie_pkg::pv);
endmodule
