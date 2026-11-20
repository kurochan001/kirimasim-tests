/*
:name: test_array_method_index_argument_without_iterator
:description: An array method call may give only the index argument, leaving the iterator name item, and the renamed index method works in locator, reduction, min and max calls and takes the dimension argument of the index method (IEEE 1800-2023 Sections 7.12, 7.12.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.4 7.12.1 7.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method_index_argument_without_iterator.expected
*/
// IEEE 1800-2023 §7.12: the argument list of an array method is
// ([iterator_argument] [, index_argument]); without an iterator argument the
// element is called item, and the index argument names the index method of
// the iterator, index by default. So a.find(, pos) keeps item and calls the
// index method pos. §7.12.4: the index method has the prototype
// index_method_name(int dimension = 1), returns an int here, and dimension 1
// is the default, so x.p(1) and x.p are equal. §7.12.1: find returns the
// elements and find_index the indices for which the with expression holds,
// in an order the standard leaves open, so these queues are sorted before
// they are printed; max and min with a with clause return the element whose
// expression is the largest or the smallest. §7.12.3: sum with a with clause
// adds the values of the expression.
//
// a is {6, 5, 2, 7, 3} at 0..4. Only a[2] equals its position; a[0], a[1] and
// a[3] are larger than theirs. The positions add up to 10, the products of
// element and position to 0+5+4+21+12 = 42. With the position as the key,
// max gives a[4] = 3 and min gives a[0] = 6. x.p(1) != x.p holds nowhere.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports the
// index argument, so the expected output follows the cited clauses.

module test_array_method_index_argument_without_iterator;
  int a [0:4] = '{6, 5, 2, 7, 3};
  int q[$];
  int s;

  task automatic show(string label);
    string t = "";
    q.sort();
    foreach (q[i]) t = {t, $sformatf(" %0d", q[i])};
    $display("%s: %0d:%s", label, q.size(), t);
  endtask

  initial begin
    q = a.find(, pos) with (item == item.pos);
    show("find(, pos)");
    q = a.find_index(, pos) with (item > item.pos);
    show("find_index(, pos)");
    s = a.sum(x, i) with (x.i);
    $display("sum of positions: %0d", s);
    s = a.sum(x, i) with (x * x.i);
    $display("sum of products: %0d", s);
    q = a.max(x, i) with (x.i);
    show("max by position");
    q = a.min(x, i) with (x.i);
    show("min by position");
    q = a.find_index(x, p) with (x.p(1) != x.p);
    show("p(1) differs from p");
  end
endmodule
