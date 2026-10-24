/*
:name: test_conditional_class_branches_result_type
:description: a conditional expression with class handle branches has the other branch's type when one branch is null or assignment compatible with the other, and the closest common base class otherwise; null with null acts as null (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 6.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_class_branches_result_type.expected
*/
// IEEE 1800-2023 §11.4.11: when a branch of ?: is a class handle, null and
// null act as the literal null; null and a handle give the type of the
// handle; otherwise, if the first branch can be assigned to the second, the
// type is that of the second, else, if the second can be assigned to the
// first, that of the first, else the closest class both derive from. The
// value is the selected branch.
// Each variable v is declared with the type of a conditional expression
// (type operator, §6.23) and then gets the value of that expression. name()
// is not virtual, so it is chosen by the declared type, while the virtual
// vname() shows which object was selected. dd_c and de_c extend d1_c; d1_c
// and d2_c extend base_c. dd and d1 give d1 in either order; d1 and d2 give
// base; dd and de give d1, their closest common base, not base; dd and d2
// give base; with null, the type is that of the other branch.
// Icarus Verilog 13.0 does not parse the type operator.

class base_c;
  function string name(); return "base"; endfunction
  virtual function string vname(); return "base"; endfunction
endclass

class d1_c extends base_c;
  function string name(); return "d1"; endfunction
  virtual function string vname(); return "d1"; endfunction
endclass

class d2_c extends base_c;
  function string name(); return "d2"; endfunction
  virtual function string vname(); return "d2"; endfunction
endclass

class dd_c extends d1_c;
  function string name(); return "dd"; endfunction
  virtual function string vname(); return "dd"; endfunction
endclass

class de_c extends d1_c;
  function string name(); return "de"; endfunction
  virtual function string vname(); return "de"; endfunction
endclass

module test_conditional_class_branches_result_type;
  bit t = 1, f = 0;
  d1_c hd1 = new;
  d2_c hd2 = new;
  dd_c hdd = new;
  de_c hde = new;
  base_c hn;

  initial begin
    var type(t ? hdd : hd1) v1;
    var type(f ? hd1 : hdd) v2;
    var type(t ? hd1 : hd2) v3;
    var type(f ? hdd : hde) v4;
    var type(t ? hdd : hd2) v5;
    var type(f ? null : hdd) v6;
    var type(t ? hd2 : null) v7;
    v1 = t ? hdd : hd1;
    v2 = f ? hd1 : hdd;
    v3 = t ? hd1 : hd2;
    v4 = f ? hdd : hde;
    v5 = t ? hdd : hd2;
    v6 = f ? null : hdd;
    v7 = t ? hd2 : null;
    $display("first compatible with second: %s %s", v1.name(), v1.vname());
    $display("second compatible with first: %s %s", v2.name(), v2.vname());
    $display("common base: %s %s", v3.name(), v3.vname());
    $display("closest common base: %s %s", v4.name(), v4.vname());
    $display("deeper common base: %s %s", v5.name(), v5.vname());
    $display("one null: %s %s", v6.name(), v7.name());
    hn = hd1;
    hn = t ? null : null;
    $display("null and null: %0d", hn == null);
  end
endmodule
