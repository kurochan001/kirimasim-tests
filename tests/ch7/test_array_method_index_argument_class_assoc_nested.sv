/*
:name: test_array_method_index_argument_class_assoc_nested
:description: With the index argument, a queue of class handles whose class has a method named index can use both that method and the position, a renamed index method of an associative array returns the signed byte keys, and a nested array method call in the with expression reads the renamed index of the outer iterator (IEEE 1800-2023 Sections 7.12, 7.12.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.4 7.12.1 7.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method_index_argument_class_assoc_nested.expected
*/
// IEEE 1800-2023 §7.12: the second argument of an array method names the
// index method of the iterator, index by default; the iterator argument is in
// scope in the with expression. §7.12.4: the default name can clash with a
// member or method of the elements, which the index argument avoids; the index
// method returns an int, or for an associative array a value of its index
// type. §7.12.1: find_index returns the indices, in an order the standard
// leaves open, so they are sorted before they are printed. §7.12.3: sum adds
// the values of its with expression.
//
// - objs holds objects of node_c with v = 0, 10, 50 and 30, whose method
//   index() returns v / 10: 0, 1, 5 and 3 at positions 0 to 3. With the
//   index method named at, o.index() is the method of the class and o.at the
//   position: they are equal at 0, 1 and 3, and only the object with v = 50
//   has o.index() > o.at.
// - aa has the byte keys -3, 4 and 100. With the index method named k, the
//   keys below 0 are only -3, which a key type without a sign would not give,
//   and $bits(v.k) is 8 for each of the 3 elements, 24 in all.
// - The outer sum names its iterator x and its index method i; the inner sum
//   over w uses y and j and keeps w[j] only where y.j equals x.i, so it gives
//   w[i], and the result is 10*3 + 20*1 + 30*2 = 110.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports the
// index argument, so the expected output follows the cited clauses.

class node_c;
  int v;
  function new(int v);
    this.v = v;
  endfunction
  function int index();
    return v / 10;
  endfunction
endclass

module test_array_method_index_argument_class_assoc_nested;
  int vs[4] = '{0, 10, 50, 30};
  node_c objs[$];
  node_c big[$];
  int aa[byte];
  int a[3] = '{10, 20, 30};
  int w[3] = '{3, 1, 2};
  int q[$];
  byte keys[$];
  int s;

  initial begin
    foreach (vs[n]) begin
      node_c o;
      o = new(vs[n]);
      objs.push_back(o);
    end
    $display("index(): %0d %0d %0d %0d", objs[0].index(), objs[1].index(), objs[2].index(),
             objs[3].index());
    q = objs.find_index(o, at) with (o.index() == o.at);
    q.sort();
    $display("index() equals position: %0d: %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    big = objs.find(o, at) with (o.index() > o.at);
    $display("index() above position: %0d, v=%0d", big.size(), big[0].v);
    aa[-3] = 7;
    aa[4] = 9;
    aa[100] = 1;
    keys = aa.find_index(v, k) with (v.k < 0);
    $display("keys below 0: %0d: %0d", keys.size(), keys[0]);
    s = aa.sum(v, k) with ($bits(v.k));
    $display("bits of the keys: %0d", s);
    s = a.sum(x, i) with (x * w.sum(y, j) with (int'(y.j == x.i) * y));
    $display("weighted sum: %0d", s);
  end
endmodule
