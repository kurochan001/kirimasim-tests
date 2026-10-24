/*
:name: test_dpi_scope_user_data_and_lookup
:description: User data stored with svPutUserData is found by svGetUserData for the same scope and key, from any import of that scope, never for another key or another instance, and a common area is shared only by storing its pointer in each scope; svGetScopeFromName finds module, interface and program instances and gives NULL for an unknown name; svSetScope returns the previous scope and selects the scope of a later export call (IEEE 1800-2023 Section 35.5.3, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.3 H.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_scope_user_data_and_lookup.c
:expected_stdout: @test_dpi_scope_user_data_and_lookup.expected
*/
// IEEE 1800-2023 §35.5.3: a context import runs in the scope of the instance
// that declares it. H.9.3: svPutUserData stores a pointer for a scope and a
// key and returns 0 on success; svGetUserData returns it, and NULL when
// nothing was stored for that scope and key. The key decides the sharing:
// imports of one scope that use the same key see the same data, and a key of
// its own keeps an import's data apart. Data are never shared between
// scopes: two instances that use the same key have their own data, and a
// common area is shared only by storing its pointer in each scope.
// svGetScopeFromName gives the scope of a module, interface or program
// instance by its full name, and NULL for a name it does not know.
// svSetScope makes a scope the context of the export calls that follow and
// returns the scope that was current (per svGetScope).
//
// The keys are addresses of static C variables, as H.9.3 advises. The C code
// prints -1 where svGetUserData gives NULL. The two instances of sul_unit run
// at different times: u1 at 1, 11 and 21, u2 at 2, 12 and 22. At 5 the top
// module stores the address of one int, 777, in both scopes; u1 reads it at
// 21 and adds 1, so u2 reads 778. At 40 the top module looks up scopes by
// name and checks each one with an export of that scope, and then sets the
// scope to u1 and to u2 in turn.

interface sul_ifc;
  export "DPI-C" function ifc_tag;
  function int ifc_tag();
    return 30;
  endfunction
endinterface

program sul_prg;
  export "DPI-C" function prg_tag;
  function int prg_tag();
    return 40;
  endfunction
endprogram

module sul_unit #(parameter int ID = 0) ();
  import "DPI-C" context function int c_get_shared();
  import "DPI-C" context function int c_put_shared(input int v);
  import "DPI-C" context function int c_read_shared_too();
  import "DPI-C" context function int c_put_own(input int v);
  import "DPI-C" context function int c_get_own();
  import "DPI-C" context function int c_get_common();
  import "DPI-C" context function void c_bump_common();
  export "DPI-C" function unit_id;

  function int unit_id();
    return ID;
  endfunction

  initial begin
    #(ID);
    $display("u%0d: shared key before any put: %0d", ID, c_get_shared());
    $display("u%0d: svPutUserData with the shared key returns %0d", ID, c_put_shared(ID * 100));
    $display("u%0d: another import with the shared key reads %0d", ID, c_read_shared_too());
    $display("u%0d: own key before any put: %0d", ID, c_get_own());
    $display("u%0d: svPutUserData with its own key returns %0d", ID, c_put_own(ID * 100 + 7));
    $display("u%0d: shared key %0d, own key %0d", ID, c_get_shared(), c_get_own());
    #10 $display("u%0d: shared key later: %0d", ID, c_get_shared());
    #10 $display("u%0d: common area: %0d", ID, c_get_common());
    if (ID == 1) c_bump_common();
  end
endmodule

module test_dpi_scope_user_data_and_lookup;
  import "DPI-C" context function void c_share_common();
  import "DPI-C" context function void c_lookups();
  import "DPI-C" context function void c_set_scope();

  sul_unit #(.ID(1)) u1();
  sul_unit #(.ID(2)) u2();
  sul_ifc i1();
  sul_prg p1();

  initial begin
    #5 c_share_common();
    #35 c_lookups();
    c_set_scope();
  end
endmodule
