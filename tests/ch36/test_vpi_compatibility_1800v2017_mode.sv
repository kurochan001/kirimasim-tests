/*
:name: test_vpi_compatibility_1800v2017_mode
:description: An application compiled with VPI_COMPATIBILITY_VERSION_1800v2017 has the 14 remapped routine names expand to their 1800v2012 variants, and through them gets the VPI behavior of the IEEE 1800-2012/2017/2023 column of Table 36-10 for all nine rows (IEEE 1800-2023 Sections 36.12.2.1 and L.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 36.12.1 L.1 L.2 37.17 37.20 37.32
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compatibility_1800v2017_mode.c
:expected_stdout: @test_vpi_compatibility_1800v2017_mode.expected
*/
// IEEE 1800-2023 §36.12.2.1: VPI_COMPATIBILITY_VERSION_1800v2017 is one of
// the symbols that select a compile-based compatibility mode when it is
// defined as 1 before a VPI header is included. vpi_user.h then includes
// vpi_compatibility.h by itself (L.1), which defines VPI_COMPATIBILITY_H and,
// for this symbol, defines the 1800v2012 symbol (L.2), so that the 14
// remapped routine names (vpi_compare_objects ... vpi_scan) become macros
// for their 1800v2012 variants. The listing defines that symbol without a
// value; since 36.12.2.1 makes the 1800v2017 symbol a valid selection, the
// header has to treat it as selecting the 1800v2012 variants. Table 36-10
// (36.12.1) gives IEEE 1800-2012, 1800-2017 and this standard one column.
//
// The VPI application defines the 1800v2017 symbol, prints from its startup
// routine whether VPI_COMPATIBILITY_H is defined and the name each routine
// name expands to (made into a string by the preprocessor), and registers a
// start of simulation callback, which uses the remapped vpi_handle_by_name,
// vpi_handle, vpi_iterate, vpi_scan, vpi_get and vpi_get_str. For each row of
// the column of Table 36-10 it prints what the mode gives, with the
// application's own names for the type constants (vpiReg is vpiLogicVar and
// vpiRegArray is vpiArrayVar, 37.17 detail 19); lists are sorted:
// 1) and 2) vpiMemory and vpiMemoryWord are only relations, giving the reg
//    array mem as vpiRegArray and its 4 words as vpiReg (37.20 detail 1);
// 3) and 4) the integer, time and real arrays ia, ta and ra are vpiRegArray
//    objects, while iv, tv and rv are vpiIntegerVar, vpiTimeVar and
//    vpiRealVar objects;
// 5) vpiVariables of the top module includes the reg lv and the arrays;
// 6) vpiReg over ia, ta and ra gives their 2 elements each as vpiIntegerVar,
//    vpiTimeVar and vpiRealVar objects;
// 7) vpiRegArray of the top module includes ia, ta and ra as well as mem;
// 8) vpiInterfaceDecl is not a relation of the class defn holder, which
//    has no such objects, so vpi_iterate returns NULL (38.23);
// 9) on the class typespec of the variable h (37.17, 37.32 details 1 and 11)
//    it gives the member vif as a vpiVirtualInterfaceVar, not a vpiRefObj.
// vpiMemory can also return other variable arrays, so only whether mem is
// among them and the types are printed.
//
// The vpi_user.h of Icarus Verilog 13.0 and of Verilator 5.052 does not
// include vpi_compatibility.h, so the routine names are not remapped there.
// Icarus Verilog 13.0 also rejects the virtual interface member of the class,
// and its headers lack vpiRefObj, vpiVirtualInterfaceVar, vpiInterfaceDecl
// and vpiTypespec. Verilator 5.052 gives no class defn and no typespec of h,
// returns no objects for vpiMemory, vpiMemoryWord, vpiVariables and
// vpiRegArray, and gives integer and time variables the type vpiReg.

interface cm17_if;
  logic s;
endinterface

module test_vpi_compatibility_1800v2017_mode_classes;
  cm17_if i0();

  class holder;
    virtual cm17_if vif;
  endclass

  holder h;

  initial begin
    h = new;
    h.vif = i0;
  end
endmodule

module test_vpi_compatibility_1800v2017_mode;
  reg [7:0] mem [0:3];
  integer ia [0:1];
  time ta [0:1];
  real ra [0:1];
  logic [3:0] lv;
  integer iv;
  time tv;
  real rv;

  test_vpi_compatibility_1800v2017_mode_classes u_cls();

  initial begin
    mem[0] = 8'd1;
    ia[0] = 2;
    ta[0] = 3;
    ra[0] = 4.0;
    lv = 4'd5;
    iv = 6;
    tv = 7;
    rv = 8.0;
    #1 $display("design: %0d %0d %0d %0.1f %0d %0d %0d %0.1f",
                mem[0], ia[0], ta[0], ra[0], lv, iv, tv, rv);
  end
endmodule
