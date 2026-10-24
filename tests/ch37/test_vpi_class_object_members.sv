/*
:name: test_vpi_class_object_members
:description: a class object gives the class typespec it was created with, while its class variable gives the declared one; the object iterates its static and automatic properties and methods without built-in methods, its virtual interface variables one element at a time, its constraints, events, event arrays and parameters, whose values match those of its class typespec; vpiObjId identifies live objects uniquely and is 0 for a null variable, and a non-static property is found by its full name (IEEE 1800-2023 Section 37.33)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.33 37.32 37.28 8.13 8.25 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_object_members.c
:expected_stdout: @test_vpi_class_object_members.expected
*/
// IEEE 1800-2023 §37.33: vpiClassTypespec of a class var is the type it was
// declared with and that of a class obj the type it was created with (detail
// 5): p is declared packet #(6) and refers to an object created as linked; the
// null variable n has no class obj. From the object of q, vpiVariables,
// vpiMethods, vpiNamedEvent and vpiNamedEventArray give static and automatic
// members (s_cnt and id, sget and get, s_ev and ev, s_evs and evs) and no
// built-in method such as new or randomize (detail 6); vpiVirtualInterfaceVar
// gives vif and each element of vifs, which vpiVariables gives whole as a
// vpiArrayVar (detail 7, 25.9); vpiConstraint gives its constraints;
// vpiParameter gives W and K, local only for K, with the values that the class
// typespec of q gives (detail 8). vpiObjId, a 64-bit property read with
// vpi_get64, is the identity of a live object and, for a class var, that of
// its object or 0 (details 1 and 2): q and r share an object, the four live
// objects have distinct nonzero identities, and n gives 0. vpi_handle_by_name
// accepts the full name of the non-static property id of the object of q
// (detail 9), whose value is 7. The identities themselves are not printed;
// names are sorted.
//
// Icarus Verilog 13.0 cannot build the application (its sv_vpi_user.h lacks
// the class object constants of Annex M), and Verilator 5.052 cannot call a
// system task registered by a VPI application.

interface test_vpi_class_object_members_ifc;
  logic s;
endinterface

module test_vpi_class_object_members;
  class packet #(int W = 4);
    localparam int K = 3;
    static int s_cnt;
    int id;
    virtual test_vpi_class_object_members_ifc vif;
    virtual test_vpi_class_object_members_ifc vifs [2];
    event ev;
    event evs [2];
    static event s_ev;
    static event s_evs [2];
    constraint c_one { id > 0; }
    constraint c_two { id < 100; }

    function int get();
      return id;
    endfunction

    static function int sget();
      return s_cnt;
    endfunction
  endclass

  class linked extends packet #(6);
    int nxt;
  endclass

  packet #(6) q, r, p, n, o1, o2;
  linked l;

  initial begin
    q = new;
    q.id = 7;
    r = q;
    l = new;
    p = l;
    o1 = new;
    o2 = new;
    #1 $vt_obj;
  end
endmodule
