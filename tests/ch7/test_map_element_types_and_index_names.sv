/*
:name: test_map_element_types_and_index_names
:description: map() gives elements of the type of its with expression, here strings, members of structure elements and properties of class objects, and the with expression can use another array through the index method, a renamed index method, and the index of an associative array, whose type is its index type (IEEE 1800-2023 Sections 7.12.5, 7.12.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.5 7.12.4 7.12 7.6 7.9.9 7.8.2 7.9.4 7.9.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_map_element_types_and_index_names.expected
*/
// IEEE 1800-2023 §7.12.5: map() returns an unpacked array with the range, or
// the indices, of the array it is called on, each element being the value of
// the with expression for that element, of the self-determined type of that
// expression. §7.12: the iterator argument names the element (item by
// default), and the index argument renames the index method, whose default
// name is index. §7.12.4: that method gives the index of the element, an int
// except for an associative array, where it has the index type of the array.
// Each result is assigned to an array whose elements have that same type
// (§7.6, §7.9.9).
// - $sformatf gives a string for each element of a: <4> <5> <6>.
// - As in the example of §7.12.5, x + b[x.index] adds the element of b with
//   the same index: 4+1 5+2 6+3 = 5 7 9.
// - With the index method named pos, x * x.pos is 4*0 5*1 6*2 = 0 5 12.
// - item.v + item.tag reads the members of each structure element: 11 22.
// - o.w * 2 reads a property of each object of the queue: 14 18.
// - On the associative array aa, x.index is the string key, so the result is
//   an array of strings with the same keys, each element its own key: the
//   result has 2 entries, and first() and next() visit them in the
//   lexicographical order of the keys (§7.8.2, §7.9.4, §7.9.6): a, then b.
// The expected output follows the standard alone. Icarus Verilog 13.0 does
// not support the with clause of array methods. The 5.052 release of
// the simulator named Verilator rejects the index argument of map(), and it
// does not support map() of a fixed-size array assigned to an unpacked array.

module test_map_element_types_and_index_names;
  typedef struct { int v; byte tag; } rec_t;

  class node;
    int w;
    function new(int w);
      this.w = w;
    endfunction
  endclass

  int a[3] = '{4, 5, 6};
  int b[3] = '{1, 2, 3};
  string names[3];
  int sums[$];
  int prod[3];
  rec_t recs[2];
  int vs[2];
  node n;
  node objs[$];
  int ws[$];
  int aa[string];
  string keys[string];
  string k;

  initial begin
    names = a.map() with ($sformatf("<%0d>", item));
    $display("names: %s %s %s", names[0], names[1], names[2]);
    sums = a.map(x) with (x + b[x.index]);
    $display("sums: %0d %0d %0d", sums[0], sums[1], sums[2]);
    prod = a.map(x, pos) with (x * x.pos);
    $display("prod: %0d %0d %0d", prod[0], prod[1], prod[2]);
    recs[0] = '{10, 1};
    recs[1] = '{20, 2};
    vs = recs.map() with (item.v + item.tag);
    $display("vs: %0d %0d", vs[0], vs[1]);
    n = new(7);
    objs.push_back(n);
    n = new(9);
    objs.push_back(n);
    ws = objs.map(o) with (o.w * 2);
    $display("ws: %0d %0d", ws[0], ws[1]);
    aa["b"] = 2;
    aa["a"] = 1;
    keys = aa.map(x) with (x.index);
    void'(keys.first(k));
    $write("keys: %0d, %s=%s", keys.num(), k, keys[k]);
    void'(keys.next(k));
    $display(" %s=%s", k, keys[k]);
  end
endmodule
