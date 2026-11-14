/*
:name: test_vpi_ref_obj_declared_cases
:description: Ref objs exist for every declared case: a variable, a named event and a named event array that are low connections of ref ports and subelements of them, an interface port and a modport port and the net, variable, named event and named event array reached through them, and a ref formal argument of a task and its subelement; vpiActual gives the bound object of each and vpiParent the ref obj of a subelement (IEEE 1800-2023 Section 37.15)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_ref_obj_declared_cases.c
:expected_stdout: @test_vpi_ref_obj_declared_cases.expected
*/
// IEEE 1800-2023 §37.15 detail 1 lists the cases of a ref obj: a variable, a
// named event or a named event array that is the low connection of a ref
// port, and any subelement of them; a local declaration of an interface or
// modport passed through a port, and any net, variable, named event or named
// event array of it; and a ref formal argument of a task or function, and
// any subelement of it. Detail 2: a ref obj is reached by walking port
// connections or through an expression that uses it. Detail 3: vpiActual
// gives the object it is bound to; detail 4: vpiParent of a subelement gives
// the ref obj it belongs to. rc_dev declares one of each: the ref ports r, e
// and ea, the interface port s and the modport port sm, and the task tf with
// the ref formal f. $vt_ports walks the ports of d in port order and prints
// each low connection; every $vt_ref call passes a use of a ref obj, and the
// application prints its actual (type and name) and, for the subelements
// r[1], ea[1] and f[2], its parent. The modport port is connected to the
// modport b.mp, so its actual is that modport (as for the port of c_2 in the
// example of 37.15).

interface rc_if;
  wire w;
  logic v;
  event ev;
  event eva [2];

  modport mp (input w);
endinterface

module rc_dev (rc_if s, rc_if.mp sm, ref logic [2:0] r, ref event e, ref event ea [2]);
  logic [3:0] loc4;

  task automatic tf(ref logic [3:0] f);
    $vt_ref("f", f);
    $vt_ref("f[2]", f[2]);
  endtask

  initial begin
    #1 $vt_ports;
    $vt_ref("r[1]", r[1]);
    $vt_ref("ea[1]", ea[1]);
    $vt_ref("s.w", s.w);
    $vt_ref("s.v", s.v);
    $vt_ref("s.ev", s.ev);
    $vt_ref("s.eva", s.eva);
    $vt_ref("sm.w", sm.w);
    tf(loc4);
  end
endmodule

module test_vpi_ref_obj_declared_cases;
  rc_if b ();
  logic [2:0] a;
  event te;
  event tea [2];

  rc_dev d (.s(b), .sm(b.mp), .r(a), .e(te), .ea(tea));
endmodule
