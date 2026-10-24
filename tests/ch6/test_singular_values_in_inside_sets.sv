/*
:name: test_singular_values_in_inside_sets
:description: The inside operator descends into unpacked arrays down to singular values, and stops at a packed vector, which is one value although it can be sliced, at a string, which is one value although it can be indexed, and at a class handle (IEEE 1800-2023 Section 6.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.4 11.4.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_singular_values_in_inside_sets.expected
*/
// IEEE 1800-2023 §6.4: integral types are singular even though they can be
// sliced into several singular values, a string is singular even though it
// can be indexed like an unpacked array of bytes, and class objects are only
// reached through handles, which are singular. §11.4.13: when an expression
// in the set of an inside operator is an unpacked array, inside descends into
// it until it reaches singular values, and compares those.
// up is an unpacked array of two 4-bit values, pk a packed array with the same
// bits: 4'h5 is found among the elements of up, but pk is the single value
// 8'h35. The strings of sa are elements, but their characters are not, so "c"
// is not found in it. The handle h2 is found among the handles of harr, and a
// handle to another object with the same contents is not.

module test_singular_values_in_inside_sets;
  class item;
    int k;
    function new(int k);
      this.k = k;
    endfunction
  endclass

  bit [3:0] up [2] = '{4'h3, 4'h5};
  bit [1:0][3:0] pk = {4'h3, 4'h5};
  string sa [2] = '{"ab", "cd"};
  item h1, h2, other;
  item harr [2];

  initial begin
    h1 = new(1);
    h2 = new(2);
    other = new(2);
    harr = '{h1, h2};
    $display("unpacked array: 5 %0d, 3 %0d, 7 %0d", 4'h5 inside {up}, 4'h3 inside {up},
             4'h7 inside {up});
    $display("packed array: 5 %0d, 35 %0d", 4'h5 inside {pk}, 8'h35 inside {pk});
    $display("strings: cd %0d, c %0d", "cd" inside {sa}, "c" inside {sa});
    $display("handles: h2 %0d, other %0d", h2 inside {harr}, other inside {harr});
  end
endmodule
