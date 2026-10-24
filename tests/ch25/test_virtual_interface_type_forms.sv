/*
:name: test_virtual_interface_type_forms
:description: virtual interface variables declared with and without the interface keyword, with parameter values and with a modport refer to interface instances, and one without a modport can be assigned to one with a modport (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_type_forms.expected
*/
// IEEE 1800-2023 §25.9: a virtual interface is a variable that represents an
// interface instance. Its type is written virtual, optionally interface,
// the interface name, optionally parameter values and optionally .modport.
// An interface instance, or a virtual interface with no modport selected,
// may be assigned to a virtual interface of the same interface type that
// selects a modport.
// Two instances of vt_if have W = 4 and W = 8. The variables v_plain and
// v_kw (default W = 4) are set to instance a, v_par (W = 8) to instance b;
// v_mod, which selects modport rd, is assigned from v_plain, and v_all,
// which has the keyword, a parameter value and modport rd, from instance b
// directly. A write through v_kw changes a.d, which every variable that
// refers to a then shows.


interface vt_if #(parameter int W = 4) ();
  logic [W-1:0] d;
  modport rd (input d);
endinterface

module test_virtual_interface_type_forms;
  vt_if #(.W(4)) a ();
  vt_if #(.W(8)) b ();
  virtual vt_if v_plain;
  virtual interface vt_if v_kw;
  virtual vt_if #(.W(8)) v_par;
  virtual vt_if.rd v_mod;
  virtual interface vt_if #(.W(8)).rd v_all;

  initial begin
    a.d = 4'h9;
    b.d = 8'hc3;
    v_plain = a;
    v_kw = a;
    v_par = b;
    v_mod = v_plain;
    v_all = b;
    #1 $display("v_plain=%h v_kw=%h v_par=%h v_mod=%h v_all=%h", v_plain.d, v_kw.d, v_par.d,
                v_mod.d, v_all.d);
    v_kw.d = 4'h6;
    #1 $display("a.d=%h v_plain=%h v_mod=%h", a.d, v_plain.d, v_mod.d);
  end
endmodule
