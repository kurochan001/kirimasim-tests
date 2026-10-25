/*
:name: test_foreach_dimensions_and_string_bytes
:description: A foreach loop with comma-separated loop variables iterates over the dimensions of an unpacked array, each over its declared range with the rightmost one changing fastest, and over a packed dimension, and a string is iterated as a dynamic array of bytes indexed 0 to length - 1 (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_dimensions_and_string_bytes.expected
*/
// IEEE 1800-2023 §12.7.3: the argument of foreach is an array identifier
// followed by a comma-separated list of loop variables in square brackets,
// one per dimension; each variable runs over the range of its dimension,
// and the loops for later dimensions are nested inside those for earlier
// ones. The array can be packed or unpacked. A string is treated as a
// dynamic array of bytes indexed from 0 to N-1, N being its length.
//
// grid has the dimensions [2] (0 to 1) and [3:1] (3 down to 1); vec is a
// packed vector [4:7]; word is a 3-character string and empty an empty one.

module test_foreach_dimensions_and_string_bytes;
  int grid [2][3:1];
  logic [4:7] vec;
  string word, empty;
  string trace;
  int count;

  initial begin
    trace = "";
    foreach (grid[i, j]) begin
      grid[i][j] = 10 * i + j;
      trace = {trace, $sformatf(" (%0d,%0d)", i, j)};
    end
    $display("grid[i, j]:%s", trace);
    $display("grid[1][2]=%0d grid[0][3]=%0d", grid[1][2], grid[0][3]);

    trace = "";
    vec = 4'b1000;
    foreach (vec[b]) trace = {trace, $sformatf(" %0d:%b", b, vec[b])};
    $display("vec[b]:%s", trace);

    word = "SV!";
    trace = "";
    foreach (word[k]) trace = {trace, $sformatf(" %0d:%0d", k, word[k])};
    $display("word[k]:%s", trace);

    empty = "";
    count = 0;
    foreach (empty[k]) count++;
    $display("empty string: %0d iterations", count);
  end
endmodule
