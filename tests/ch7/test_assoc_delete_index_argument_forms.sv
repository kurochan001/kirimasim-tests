/*
:name: test_assoc_delete_index_argument_forms
:description: the associative array method delete is a void function whose optional input argument has the index type of the array, so it takes string, converted integral and class handle keys, and without the argument it removes every entry (IEEE 1800-2023 Section 7.9.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_delete_index_argument_forms.expected
*/
// IEEE 1800-2023 §7.9.2: delete is function void delete([input index]), where
// index has the type of the index of the array. With an index it removes that
// entry; without one it removes all entries.
// delete is only called as a statement. sm is indexed by string; bm by byte,
// so the argument 300 is converted to the byte 44 and 9'h1ff to -1, as an
// input argument of type byte; cm by a class, so a handle selects the entry.
// The calls without an argument, with and without parentheses, empty the
// arrays.
// Icarus Verilog 13.0 does not support associative arrays with these index
// types.

module test_assoc_delete_index_argument_forms;
  class key_c;
    int id;
  endclass

  int sm[string];
  int bm[byte];
  int cm[key_c];
  key_c k1, k2;

  initial begin
    sm["a"] = 1;
    sm["b"] = 2;
    sm["c"] = 3;
    sm.delete("b");
    $display("string: num=%0d a=%0d b=%0d c=%0d", sm.num(), sm.exists("a"), sm.exists("b"),
             sm.exists("c"));
    sm.delete;
    $display("string after delete: num=%0d", sm.num());

    bm[44] = 1;
    bm[-1] = 2;
    bm[7] = 3;
    bm.delete(300);
    $display("byte after delete(300): num=%0d 44=%0d -1=%0d 7=%0d", bm.num(), bm.exists(44),
             bm.exists(-1), bm.exists(7));
    bm.delete(9'h1ff);
    $display("byte after delete(9'h1ff): num=%0d -1=%0d", bm.num(), bm.exists(-1));
    bm.delete();
    $display("byte after delete(): num=%0d", bm.num());

    k1 = new;
    k2 = new;
    cm[k1] = 10;
    cm[k2] = 20;
    cm.delete(k1);
    $display("class: num=%0d k1=%0d k2=%0d", cm.num(), cm.exists(k1), cm.exists(k2));
  end
endmodule
