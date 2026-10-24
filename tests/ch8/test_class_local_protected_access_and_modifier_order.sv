/*
:name: test_class_local_protected_access_and_modifier_order
:description: a local member is used by the methods of its class, also on another instance and through an inherited method, a protected member is used by a subclass, and the local, protected, static, const and virtual modifiers can be written in any order (IEEE 1800-2023 Section 8.18)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_local_protected_access_and_modifier_order.expected
*/
// IEEE 1800-2023 §8.18: a local member is available only to the methods of
// its class, which may use it on a different instance of that class, and a
// nonlocal method that uses it keeps working when a subclass inherits it. A
// protected member is like a local one but is visible to subclasses. The
// modifiers of a member have no predefined order.
// vault_c compares its local secret with that of another instance, and
// box_c inherits the method reveal, which reads the local secret of vault_c.
// box_c's own method reads the protected tag of vault_c directly. vault_c
// declares its members with the modifiers in both orders: protected const and
// const protected, static local and local static, protected virtual and
// virtual protected; the values and the override of the virtual methods show
// that each declaration took effect.
// Icarus Verilog 13.0 rejects protected const and protected virtual, which
// put protected first.

class vault_c;
  local int secret;
  protected int tag;
  protected const int pc = 4;
  const protected int cp = 5;
  static local int sl = 6;
  local static int ls = 7;
  function new(int s);
    secret = s;
    tag = s * 10;
  endfunction
  function bit same_secret(vault_c other);
    return this.secret == other.secret;
  endfunction
  function int reveal();
    return secret;
  endfunction
  function int statics();
    return sl + ls;
  endfunction
  protected virtual function int pv();
    return 1;
  endfunction
  virtual protected function int vp();
    return 2;
  endfunction
  function int both();
    return pv() * 10 + vp();
  endfunction
endclass

class box_c extends vault_c;
  function new(int s);
    super.new(s);
  endfunction
  function int read_tag();
    return tag + pc + cp;
  endfunction
  protected virtual function int pv();
    return 3;
  endfunction
  virtual protected function int vp();
    return 4;
  endfunction
endclass

module test_class_local_protected_access_and_modifier_order;
  vault_c v1, v2, v3;
  box_c b;

  initial begin
    v1 = new(8);
    v2 = new(8);
    v3 = new(9);
    $display("other instance: v1/v2=%0d v1/v3=%0d", v1.same_secret(v2), v1.same_secret(v3));
    b = new(12);
    $display("inherited reveal=%0d, protected via subclass=%0d", b.reveal(), b.read_tag());
    $display("statics=%0d, virtual: vault=%0d box=%0d", v1.statics(), v1.both(), b.both());
  end
endmodule
