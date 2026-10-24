/*
:name: test_array_method_iterator_index_names_and_selects
:description: array method calls use item and index as default names, an iterator argument names the element only inside the with expression, an index argument renames the index method, index() returns int or the associative index type, and selects and methods on the result follow the with clause or the call (IEEE 1800-2023 Sections 7.12, 7.12.1, 7.12.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.1 7.12.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method_iterator_index_names_and_selects.expected
*/
// IEEE 1800-2023 §7.12: an array method call is expression.method, then
// optional attributes, an optional (iterator, index) argument list and an
// optional with (expression). Without an iterator argument the element is
// named item, and without an index argument the index method is named index;
// the iterator argument is in scope only in the with expression. Selects and
// methods applied to the result follow the with clause if there is one, and
// the call otherwise. §7.12.4: index(dimension = 1) returns the index of the
// element, an int, or a value of the index type for an associative array; the
// index argument renames it, for elements with a member called index.
// §7.12.1: index locators return a queue of int, or of the associative index
// type. Locators traverse in an unspecified order, so every resulting queue is
// sorted before it is printed. The module variable item is 4: without an
// iterator argument the element named item hides it in the with expression,
// and with the iterator x, "item" there is that variable.
// Icarus Verilog 13.0 does not support unpacked structures or these method
// calls. Verilator 5.052 does not support the index argument or index(1).

module test_array_method_iterator_index_names_and_selects;
  typedef struct {
    int index;
    int v;
  } rec_t;

  int a [0:4] = '{5, 3, 8, 3, 1};
  int c [-2:2] = '{7, 7, 7, 7, 7};
  rec_t recs [0:2] = '{'{index: 2, v: 10}, '{index: 1, v: 20}, '{index: 2, v: 30}};
  int aa [string] = '{"b": 1, "a": 2, "c": 3};
  int item = 4;
  int q[$];
  string ks[$];
  int n, s;

  task automatic show(string label);
    string t = "";
    q.sort();
    foreach (q[i]) t = {t, $sformatf(" %0d", q[i])};
    $display("%s size=%0d:%s", label, q.size(), t);
  endtask

  initial begin
    q = a.find with (item > item.index * 2);
    show("default item and index:");
    q = a.find(x) with (x < item);
    show("iterator x, outer item:");
    $display("outer item after the call: %0d", item);
    q = recs.find_index(r, pos) with (r.index == r.pos);
    show("renamed index method:");
    q = a.find_index with (item.index(1) != item.index);
    show("index(1) differs from index:");
    q = c.find_index with (item.index < 0);
    show("negative int indices:");
    ks = aa.find_index with (item.index > "a");
    ks.sort();
    $display("string indices: size=%0d: %s %s", ks.size(), ks[0], ks[1]);
    n = a.find(x) with (x > 2).size();
    s = a.unique().size();
    $display("size after with: %0d, size after call: %0d", n, s);
    $display("select after call: min=%0d max=%0d", a.min()[0], a.max()[0]);
    s = a.sum (* note = "attribute" *) (x) with (x * 2);
    $display("attribute and iterator: sum=%0d", s);
  end
endmodule
