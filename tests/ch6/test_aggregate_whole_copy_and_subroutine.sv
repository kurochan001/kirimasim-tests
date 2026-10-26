/*
:name: test_aggregate_whole_copy_and_subroutine
:description: unpacked structures, unions and arrays are aggregate types whose whole value is copied in assignment and passed by value to a subroutine
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.4 7.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_aggregate_whole_copy_and_subroutine.expected
*/
// IEEE 1800-2023 6.4: unpacked structures, unpacked unions and unpacked arrays
// are aggregate types. 7.2.2: a structure may be passed into and returned from
// a subroutine as a whole. The test copies each of the three aggregate kinds
// with one assignment, changes the copy, and observes that the original is
// unchanged; it then passes an unpacked structure and an unpacked array to a
// task by value and observes that changes to the formals do not reach the
// actuals, while a structure returned by a function arrives as a whole.

typedef struct {
  int a;
  byte b;
} ust_t;

typedef union {
  int i;
  byte b;
} uun_t;

module test_aggregate_whole_copy_and_subroutine;
  ust_t s1, s2, s3;
  uun_t u1, u2;
  int arr1[0:2];

  task automatic mutate(input ust_t s, input int arr[0:2], output ust_t out);
    s.a = 99;
    arr[0] = 99;
    out = s;
  endtask

  function automatic ust_t make(input int x);
    ust_t t;
    t.a = x;
    t.b = 8'h7;
    return t;
  endfunction

  initial begin
    s1.a = 1;
    s1.b = 2;
    s2 = s1;
    s2.a = 5;
    $display("struct s1=%0d s2=%0d", s1.a, s2.a);
    u1.b = 8'h44;
    u2 = u1;
    u2.b = 8'h33;
    $display("union u1=%h u2=%h", u1.b, u2.b);
    arr1[0] = 10;
    arr1[1] = 11;
    arr1[2] = 12;
    begin : copy_block
      int arr2[0:2];
      arr2 = arr1;
      arr2[0] = 20;
      $display("array a1=%0d a2=%0d", arr1[0], arr2[0]);
    end
    mutate(s1, arr1, s3);
    $display("after s1=%0d arr1=%0d out=%0d", s1.a, arr1[0], s3.a);
    s3 = make(4);
    $display("returned a=%0d b=%0d", s3.a, s3.b);
  end
endmodule
