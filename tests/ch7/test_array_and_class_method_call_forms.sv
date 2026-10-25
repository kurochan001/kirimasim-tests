/*
:name: test_array_and_class_method_call_forms
:description: Method calls on a primary or on this or super, with attribute instances after the method name, and array manipulation calls named by an identifier or by unique, and, or and xor, with and without parentheses, an iterator argument and a with clause, and with a select after the call (IEEE 1800-2023 Section 7.12)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.1 7.12.3 8.11 8.15 A.8.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_and_class_method_call_forms.expected
*/
// IEEE 1800-2023 A.8.2: a method call is a root (a primary, or this, super or
// this.super) followed by a dot and either a method name with attribute
// instances and an optional argument list, or a built-in call. An array
// manipulation call is the method name, which is an identifier or one of the
// keywords unique, and, or and xor, any number of attribute instances, an
// optional argument list and an optional with (expression).
// §7.12.3: sum, and, or and xor reduce the elements, or the values of the with
// expression for them. §7.12.1: find and find_index return the elements, or
// indexes, for which the with expression holds, and unique one element of
// each value, in an unspecified order, so the test sorts these queues before
// printing them; max returns a queue with the largest element, and a select
// may follow the call (§7.12). §8.11 and §8.15: this.get calls the method of
// the object, and super.get the method of the base class.
//
// With a = '{3, 6, 5, 6, 12}:
//   a.sum(), a.sum and a.sum with (item * 2) are 32, 32 and 64; a.and is 0,
//   a.or() 15 and a.xor with (item + 1) is 4 ^ 7 ^ 6 ^ 7 ^ 13 = 15;
//   a.unique() sorted is 3 5 6 12, a.find with (item > 5) sorted is 6 6 12,
//   a.find_index(x) with (x == 6) sorted is 1 3, and a.max ()[0] is 12;
//   o.get(2) is 100 + 3 + 2 = 105, o.self() calls this.get(1) and is 104,
//   as is o.self without parentheses,
//   o.get with an attribute instance and (5) is 108, and s.len() is 5.
//
// Icarus Verilog 13.0 rejects the array reduction calls with a with clause
// as syntax errors.

module test_array_and_class_method_call_forms;
  class mc_base;
    int k = 3;
    function int get(int d = 0);
      return k + d;
    endfunction
  endclass

  class mc_derived extends mc_base;
    function int get(int d = 0);
      return 100 + super.get(d);
    endfunction
    function int self();
      return this.get(1);
    endfunction
  endclass

  int a [5] = '{3, 6, 5, 6, 12};
  int q [$];
  int mx;
  string s = "hello";
  mc_derived o;

  initial begin
    $display("reduce %0d %0d %0d %0d %0d %0d", a.sum(), a.sum, a.sum with (item * 2), a.and,
             a.or(), a.xor with (item + 1));
    q = a.unique();
    q.sort();
    $display("unique %0d: %0d %0d %0d %0d", q.size(), q[0], q[1], q[2], q[3]);
    q = a.find (* note *) with (item > 5);
    q.sort();
    $display("find %0d: %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    q = a.find_index(x) with (x == 6);
    q.sort();
    $display("find_index %0d: %0d %0d", q.size(), q[0], q[1]);
    mx = a.max (* m *) ()[0];
    $display("max %0d", mx);
    o = new;
    $display("methods %0d %0d %0d %0d %0d", o.get(2), o.self(), o.self, o.get (* g *) (5),
             s.len());
  end
endmodule
