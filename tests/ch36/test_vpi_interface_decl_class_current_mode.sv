/*
:name: test_vpi_interface_decl_class_current_mode
:description: without a compatibility mode, vpiInterfaceDecl, the same constant as vpiVirtualInterfaceVar, cannot be iterated on a class definition, while on the class typespec of a class variable it gives the virtual interface member as a vpiVirtualInterfaceVar object, not a vpiRefObj (IEEE 1800-2023 Section 36.12.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 37.31 37.32 37.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_decl_class_current_mode.c
:expected_stdout: @test_vpi_interface_decl_class_current_mode.expected
*/
// IEEE 1800-2023 §36.12.1, rows 8 and 9 of Table 36-10 and their details:
// since IEEE Std 1800-2012 the vpiInterfaceDecl iteration, now an alias of
// vpiVirtualInterfaceVar, is no longer allowed on a vpiClassDefn, which is
// only a lexical scope, but it stays allowed on a vpiClassTypespec, which can
// be an active scope; and it gives vpiVirtualInterfaceVar objects, where
// IEEE Std 1800-2005 and 1800-2009 gave vpiRefObj objects. §37.31: the class
// defn diagram has no relation to virtual interface vars. §37.32: the type of
// a variable outside any class is a class typespec that is a class
// specialization (detail 1), and on it the vpiVirtualInterfaceVar iteration
// gives the virtual interface variables of the class (detail 11).
// The VPI application defines no compatibility mode. At the start of
// simulation it finds the class defn holder of the module and iterates
// vpiInterfaceDecl on it, then takes the typespec of the variable h of type
// holder (§37.17) and iterates vpiInterfaceDecl on that, printing the name
// and type of what it gets.
// Icarus Verilog 13.0 rejects the virtual interface member of the class, and
// its sv_vpi_user.h has no vpiInterfaceDecl, vpiVirtualInterfaceVar or
// vpiRefObj. Verilator 5.052 gives no class defn and no typespec of h.

interface vic_if;
  logic s;
endinterface

module test_vpi_interface_decl_class_current_mode;
  vic_if i0();

  class holder;
    virtual vic_if vif;
    int n;
  endclass

  holder h;

  initial begin
    h = new;
    h.vif = i0;
    h.n = 3;
    #1 $display("design: n=%0d", h.n);
  end
endmodule
