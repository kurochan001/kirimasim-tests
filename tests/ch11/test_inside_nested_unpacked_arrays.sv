/*
:name: test_inside_nested_unpacked_arrays
:description: inside searches unpacked arrays whose elements are unpacked arrays, fixed-size, dynamic or queues, down to their singular elements (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_nested_unpacked_arrays.expected
*/
// IEEE 1800-2023 §11.4.13: an unpacked array in the set of inside is
// traversed down to its singular values, also when its elements are arrays.
// So a value that is an element of a row of a two-dimensional array, of an
// array held by a dynamic array, or of a queue of arrays, is inside the set,
// and a value that is in none of the rows is not.

module test_inside_nested_unpacked_arrays;
  typedef logic [3:0] row_t[0:1];
  row_t a[];
  row_t q[$];
  row_t grid[2];
  logic [3:0] needle;

  initial begin
    a = new[1];
    a[0] = '{4'd3, 4'd13};
    q.push_back('{4'd6, 4'd11});
    grid[0] = '{4'd1, 4'd2};
    grid[1] = '{4'd7, 4'd9};
    needle = 4'd13;
    $display("13 inside {a}: %b", needle inside {a});
    needle = 4'd9;
    $display("9 inside {grid}: %b", needle inside {grid});
    needle = 4'd11;
    $display("11 inside {q}: %b", needle inside {q});
    needle = 4'd5;
    $display("5 inside {a, q, grid}: %b", needle inside {a, q, grid});
  end
endmodule
