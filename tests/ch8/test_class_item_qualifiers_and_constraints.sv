/*
:name: test_class_item_qualifiers_and_constraints
:description: Class items named by identifiers with one qualifier of each allowed kind: a local rand and a randc property, a const property, a static property, a static constraint, a virtual method that a derived class overrides, and a pure virtual method that a virtual class declares and a derived class defines; the constraints are randomized, including one whose subject is a parenthesized array built-in method call, and null is a constant primary (IEEE 1800-2023 Sections 8.3, 8.6, 8.8, 8.21, 18.5 and 18.7, footnotes 7, 8, 10, 11, 12, 25 and 43 of A.10)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.3 8.6 8.8 8.21 18.5 18.7 A.9.3 A.8.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_item_qualifiers_and_constraints.expected
*/
// IEEE 1800-2023 A.9.3: the names of a class, its properties, its methods,
// its constraints and a const property are identifiers. A.8.4: null is a
// primary and a constant primary. Footnotes of A.10: 7 says a parameter in a
// class body is a localparam; 8 says a pure virtual method has no final; 10
// allows only one of protected and local, one of rand and randc, and static
// and virtual only once in a declaration; 11 forbids the dynamic override
// specifiers on a static constraint; 12 allows the parentheses of an array
// built-in method as a constraint primary; 25 allows the dynamic override
// specifiers only on methods of a class that is not an interface class; 43
// forbids null and the identifier list after with in a scope randomize.
//
// §8.3, §8.6 and §8.8: the rand property a is local, so only geta reads it,
// randc makes b cycle, const CI cannot change, count is shared by the class,
// and a static constraint applies to every instance. §8.21: the virtual class
// abs_c declares pure1 as pure virtual and conc_c defines it. §18.5 and
// §18.7: randomize makes a and b satisfy the constraints, and q.size() == 0
// keeps the empty queue empty. §18.12: std::randomize with a constraint gives
// its variable the value that the constraint fixes.
//
// b5 specializes base_c with W = 5, so its body parameter BODY is 6 and
// read is 12; three constructors ran, so count is 3. a is not 3 because of
// the static constraint and is inside 0:3, and b is inside 0:2, so the two
// tests print 1; CI is 5 and the queue has size 0. who gives 1 in item and 2
// in item2, and pure1 gives 7. The null handle p and the parameter NP are
// null, and o1 is not. std::randomize(sr) with sr == 5 and std::randomize(sd)
// with 2 < sd < 4 both return 1, so the sum is 2 and the variables are 5 and
// 3.
//
// Icarus Verilog 13.0 has no classes; Verilator 5.052 produces this output.

`timescale 1ns/1ns

class base_c #(parameter int W = 2);
  parameter int BODY = W + 1;

  function int read();
    return BODY * 2;
  endfunction
endclass

class item;
  local rand int a;
  randc int b;
  const int CI = 5;
  static int count = 0;
  int arr [3];
  int q [$];

  constraint ca { a inside {[0:3]}; b inside {[0:2]}; }
  constraint cb { q.size() == 0; }
  static constraint cs { a != 3; }

  function new();
    count++;
  endfunction

  function int geta();
    return a;
  endfunction

  virtual function int who();
    return 1;
  endfunction
endclass

class item2 extends item;
  virtual function int who();
    return 2;
  endfunction
endclass

virtual class abs_c;
  pure virtual function int pure1();
endclass

class conc_c extends abs_c;
  virtual function int pure1();
    return 7;
  endfunction
endclass

module test_class_item_qualifiers_and_constraints;
  base_c #(5) b5;
  item o1, o2;
  item2 o3;
  conc_c cc;
  item p;
  localparam item NP = null;
  int ok, a1, b1, sz, sr, sd;

  initial begin
    b5 = new;
    o1 = new;
    o2 = new;
    o3 = new;
    cc = new;
    ok = o1.randomize();
    a1 = o1.geta();
    b1 = o1.b;
    sz = o1.q.size();
    $display("class %0d %0d %0d", ok, b5.read(), item::count);
    $display("qual %0d %0d %0d %0d", a1 >= 0 && a1 <= 2 && a1 != 3,
             b1 >= 0 && b1 <= 2, o1.CI, sz);
    $display("virt %0d %0d %0d", o1.who(), o3.who(), cc.pure1());
    $display("null %0d %0d %0d", p == null, (p == null) && (o1 != null),
             NP == null);
    sr = 0;
    p = new;
    ok = std::randomize(sr) with { sr == 5; };
    sd = 0;
    ok = ok + std::randomize(sd) with { sd > 2 && sd < 4; };
    $display("scope %0d %0d %0d", ok, sr, sd);
  end
endmodule
