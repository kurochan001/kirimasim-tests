/*
:name: test_lvalue_scopes_selects_and_concatenation_forms
:description: Variable lvalues with a package scope, this, a hierarchical name, member, bit and part selects and nested concatenations; nonrange variable lvalues of the same kinds that receive a dynamic array new; and net lvalues with constant bit and part selects, a hierarchical name and a concatenation (IEEE 1800-2023 Section 10.4)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 10.3.2 7.5.1 11.4.12 A.8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lvalue_scopes_selects_and_concatenation_forms.expected
*/
// IEEE 1800-2023 A.8.5: a variable lvalue is a variable name, optionally
// after this. or a package scope, which may be hierarchical, with a select
// (member selects, bit selects and a part select), or a brace-enclosed list
// of variable lvalues. A nonrange variable lvalue is the same without a part
// select; it is the target that receives a dynamic array new (§7.5.1). A net
// lvalue is a net name, possibly hierarchical, with a constant select, or a
// brace-enclosed list of net lvalues. §10.4: a procedural assignment writes
// the variable its lvalue names; §10.3.2: a continuous assignment drives the
// net its lvalue names; §11.4.12: a concatenation on the left-hand side
// splits the value over its parts, left part first.
//
// The procedural assignments write lvp::pv (7), sub.v (8), obj.x through
// this.x in a method (5), st.m[1] (9), the part select st.f[3:0] (f, over
// 8'h50, giving 5f), the bit select bv[2] (bv 00000100) and
// {x, {y, z}} = {16'd11, 16'd12, 16'd13}. The dynamic arrays this.d,
// lvp::pd, sub.d, da[1] and st.dm receive new[2], new[4], new[5], new[3] and
// new[6]. The continuous assignments drive the nets w[3:0] and w[7:4] (a5),
// w2[0] (1), {n1, n2} = 8'hBC (b and c) and sub.n (3e).
//
// Icarus Verilog 13.0 does not support unpacked structures.

package lvp;
  int pv;
  int pd [];
endpackage

module lv_sub;
  int v;
  int d [];
  wire [7:0] n;
endmodule

module test_lvalue_scopes_selects_and_concatenation_forms;
  typedef struct {
    int m [2];
    logic [7:0] f;
    int dm [];
  } st_t;

  class lv_c;
    int x;
    int d [];
    function void set();
      this.x = 5;
      this.d = new[2];
    endfunction
  endclass

  lv_sub sub ();
  wire [7:0] w;
  wire [1:0] w2;
  wire [3:0] n1, n2;
  st_t st;
  bit [7:0] bv;
  shortint x, y, z;
  int da [2][];
  lv_c obj;

  assign w[3:0] = 4'h5;
  assign w[7:4] = 4'ha;
  assign w2[0] = 1'b1;
  assign w2[1] = 1'b0;
  assign {n1, n2} = 8'hBC;
  assign sub.n = 8'h3E;

  initial begin
    lvp::pv = 7;
    sub.v = 8;
    st.m[1] = 9;
    st.f = 8'h50;
    st.f[3:0] = 4'hF;
    bv[2] = 1'b1;
    {x, {y, z}} = {16'd11, 16'd12, 16'd13};
    obj = new;
    obj.set();
    lvp::pd = new[4];
    sub.d = new[5];
    da[1] = new[3];
    st.dm = new[6];
    #1;
    $display("var %0d %0d %0d %0d %h %b %0d %0d %0d", lvp::pv, sub.v, obj.x, st.m[1], st.f, bv,
             x, y, z);
    $display("new %0d %0d %0d %0d %0d", obj.d.size(), lvp::pd.size(), sub.d.size(),
             da[1].size(), st.dm.size());
    $display("net %h %b %h %h %h", w, w2, n1, n2, sub.n);
  end
endmodule
