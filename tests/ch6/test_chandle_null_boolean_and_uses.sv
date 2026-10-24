/*
:name: test_chandle_null_boolean_and_uses
:description: A chandle starts as null, which C sees as a zero pointer; as a Boolean it is 0 when null and 1 otherwise; === and !== give the same results as == and !=; and a chandle can be a class property and an associative array index (IEEE 1800-2023 Section 6.14)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.14 7.8 35.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_chandle_null_boolean_and_uses.c
:expected_stdout: @test_chandle_null_boolean_and_uses.expected
*/
// IEEE 1800-2023 §6.14: a chandle is always initialized to null, which is 0
// on the C side. Tested as a Boolean it is 0 when null and 1 otherwise. It
// can be compared with another chandle or with null by == and !=, and by ===
// and !==, which have the same meaning. A chandle can be a property of a
// class, and an index of an associative array (7.8), whose order of entries
// is not fixed, so the test does not depend on it.
// The C functions return pointers to two static cells, or NULL for any other
// k, and tell whether a pointer is NULL (35.5.6). a and a2 hold the same
// pointer, b another one, and n the NULL that C returned. truth() tests a
// chandle with if.

module test_chandle_null_boolean_and_uses;
  import "DPI-C" function chandle chu_cell(input int k);
  import "DPI-C" function int chu_is_zero(input chandle h);
  import "DPI-C" function int chu_value(input chandle h);

  class holder;
    chandle p;
    function int peek();
      return chu_value(p);
    endfunction
  endclass

  chandle unset, a, a2, b, n;
  holder obj;
  int aa[chandle];

  function automatic int truth(chandle h);
    if (h)
      return 1;
    else
      return 0;
  endfunction

  initial begin
    $display("unset: == null %0d, === null %0d, zero in C %0d, Boolean %0d", unset == null,
             unset === null, chu_is_zero(unset), truth(unset));
    a = chu_cell(0);
    a2 = chu_cell(0);
    b = chu_cell(1);
    n = chu_cell(5);
    $display("from C: Boolean a %0d b %0d n %0d, n == null %0d, a zero in C %0d", truth(a),
             truth(b), truth(n), n == null, chu_is_zero(a));
    $display("a vs a2: == %0d === %0d != %0d !== %0d", a == a2, a === a2, a != a2, a !== a2);
    $display("a vs b: == %0d === %0d != %0d !== %0d", a == b, a === b, a != b, a !== b);
    $display("a vs null: == %0d === %0d != %0d !== %0d", a == null, a === null, a != null,
             a !== null);
    $display("n vs null: == %0d === %0d != %0d !== %0d", n == null, n === null, n != null,
             n !== null);
    obj = new;
    $display("class property: null %0d", obj.p == null);
    obj.p = b;
    $display("class property set: value %0d same %0d", obj.peek(), obj.p == b);
    aa[a] = 100;
    aa[b] = 200;
    aa[a2] = 101;
    $display("associative array: num %0d [a] %0d [b] %0d", aa.num(), aa[a], aa[b]);
  end
endmodule
