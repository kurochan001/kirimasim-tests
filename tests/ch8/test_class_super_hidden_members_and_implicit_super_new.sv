/*
:name: test_class_super_hidden_members_and_implicit_super_new
:description: super reaches the properties, methods, value parameters and local parameters of the immediate base class, also those the derived class hides and those the base inherits, and a constructor without super.new gets one inserted, which uses the default argument of the base constructor (IEEE 1800-2023 Section 8.15)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.15 8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_super_hidden_members_and_implicit_super_new.expected
*/
// IEEE 1800-2023 §8.15: within a derived class, super refers to the members,
// value parameters and local value parameters of the base class one level up,
// declared there or inherited by it; it is needed when the derived class
// overrides them. When a constructor does not call super.new, the compiler
// inserts the call (§8.7).
// low_c, mid_c and top_c each declare count and get(); low_c also hides the
// local parameter KK of mid_c. super in low_c reaches mid_c's count, get() and
// KK, the parameter K of the specialization mid_c #(4), and only_top, which
// mid_c inherits from top_c. b_c and c_c have no super.new call, and order
// shows that the constructors of a_c, b_c and c_c still run base first; e_c
// gets the default argument 5 of the constructor of d_c.
// Icarus Verilog 13.0 does not support parameterized classes.

class top_c;
  int count = 1;
  int only_top = 9;
  function int get();
    return count;
  endfunction
endclass

class mid_c #(int K = 3) extends top_c;
  int count = 2;
  localparam int KK = K * 10;
  function int get();
    return count + 100;
  endfunction
endclass

class low_c extends mid_c #(4);
  int count = 3;
  localparam int KK = 7;
  function int get();
    return count + 1000;
  endfunction
  function string show();
    return $sformatf("count=%0d get=%0d KK=%0d super.count=%0d super.get=%0d super.KK=%0d",
                     count, get(), KK, super.count, super.get(), super.KK);
  endfunction
  function string show_up();
    return $sformatf("super.K=%0d super.only_top=%0d", super.K, super.only_top);
  endfunction
endclass

int order[$];

class a_c;
  function new();
    order.push_back(1);
  endfunction
endclass

class b_c extends a_c;
  function new();
    order.push_back(2);
  endfunction
endclass

class c_c extends b_c;
endclass

class d_c;
  int v;
  function new(int v = 5);
    this.v = v;
  endfunction
endclass

class e_c extends d_c;
  function new();
  endfunction
endclass

module test_class_super_hidden_members_and_implicit_super_new;
  low_c l;
  c_c c;
  e_c e;

  initial begin
    l = new;
    $display("%s", l.show());
    $display("%s", l.show_up());
    c = new;
    $display("constructor order: size=%0d %0d %0d", order.size(), order[0], order[1]);
    e = new;
    $display("inserted super.new() with default: v=%0d", e.v);
  end
endmodule
