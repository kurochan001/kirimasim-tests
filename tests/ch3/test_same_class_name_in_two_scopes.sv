/*
:name: test_same_class_name_in_two_scopes
:description: Classes with the same name declared in two modules or in two packages are different classes (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 26.3 8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_same_class_name_in_two_scopes.expected
*/
// IEEE 1800-2023 §3.13: a class declared in a module or a package belongs to
// the name space of that module or package. So class C of module mod_a and
// class C of module mod_b are different classes, each with its own methods
// and its own static properties (8.9), and so are pa::C and pb::C (26.3).

package pa;
  class C;
    function int f();
      return 100;
    endfunction
  endclass
endpackage

package pb;
  class C;
    function int f();
      return 200;
    endfunction
  endclass
endpackage

module mod_a (output int r, output int n);
  class C;
    static int made = 0;
    function new();
      made++;
    endfunction
    function int get();
      return 300;
    endfunction
  endclass
  initial begin
    C c1, c2;
    c1 = new;
    c2 = new;
    r = c1.get();
    n = C::made;
  end
endmodule

module mod_b (output int r, output int n);
  class C;
    static int made = 0;
    function new();
      made++;
    endfunction
    function int get();
      return 400;
    endfunction
  endclass
  initial begin
    C c1;
    c1 = new;
    r = c1.get();
    n = C::made;
  end
endmodule

module test_same_class_name_in_two_scopes;
  int ra, rb, na, nb;
  mod_a a (ra, na);
  mod_b b (rb, nb);

  initial begin
    pa::C x;
    pb::C y;
    x = new;
    y = new;
    #1;
    $display("pa::C: %0d, pb::C: %0d", x.f(), y.f());
    $display("mod_a.C: %0d made %0d, mod_b.C: %0d made %0d", ra, na, rb, nb);
  end
endmodule
