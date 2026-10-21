/*
:name: test_assoc_allocate_on_write_types
:description: A write to a nonexistent associative array element allocates it first, with the default or initial value of the element type or with a nested array, for an increment, a member write, a string concatenation and a ref argument (IEEE 1800-2023 Section 7.8.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.7 7.9.1 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_allocate_on_write_types.expected
*/
// IEEE 1800-2023 §7.8.7: an assignment to a nonexistent element of an
// associative array first allocates the element with the default value of its
// type, and a member or compound assignment then applies to that value. For
// an int the default is 0, so a[10] += 3 gives 3 and a[11]++ gives 1. A
// structure is allocated with its member initializers, so the write to s[1].x
// leaves y at 2. Reading str[2] gives the empty string, and the concatenation
// stores "ab" there. §13.5.2: passing the array by ref lets the function
// allocate a[12]. A nested associative array is allocated on the same write,
// so n[1][2] gives n[1] one element.
//
// Icarus Verilog 13.0 does not compile associative arrays, so the expected
// output was recorded with version 5.052 of Verilator.

module test_assoc_allocate_on_write_types;
  typedef struct {
    int x;
    int y = 2;
  } s_t;

  int a[int];
  s_t s[int];
  string str[int];
  int n[int][int];

  function automatic void set(ref int m[int], input int k, input int v);
    m[k] = v;
  endfunction

  initial begin
    a[10] += 3;
    a[11]++;
    $display("a10=%0d a11=%0d num=%0d", a[10], a[11], a.num());
    s[1].x = 7;
    $display("s1 x=%0d y=%0d num=%0d", s[1].x, s[1].y, s.num());
    str[2] = {str[2], "ab"};
    $display("str2='%s' num=%0d", str[2], str.num());
    set(a, 12, 9);
    $display("a12=%0d num=%0d", a[12], a.num());
    n[1][2] = 5;
    $display("n12=%0d outer=%0d inner=%0d", n[1][2], n.num(), n[1].num());
  end
endmodule
