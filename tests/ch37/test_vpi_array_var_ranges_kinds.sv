/*
:name: test_vpi_array_var_ranges_kinds
:description: Array vars give their kind with vpiArrayType and their ranges from the leftmost, with empty ranges for associative dimensions, for empty dynamic arrays and queues and for dynamic, queue and associative dimensions after the first; packed variables give only their declared packed ranges; vpiLeftRange and vpiRightRange give the leftmost dimension or NULL; the typespecs give their kind and empty ranges for every variable-size dimension (IEEE 1800-2023 Sections 37.17, 37.22 and 37.25)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.22 37.25 7.4 7.5 7.8 7.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_array_var_ranges_kinds.c
:expected_stdout: @test_vpi_array_var_ranges_kinds.expected
*/
// IEEE 1800-2023 §37.17: vpiArrayType of an array var is vpiStaticArray,
// vpiDynamicArray, vpiQueueArray or vpiAssocArray (detail 21). vpiRange of an
// array var gives its unpacked ranges from the leftmost (detail 4); a dynamic
// array or queue as first dimension gives its current range, from 0 to its
// size minus 1, but an empty range (37.22: size 0, NULL bounds) when it has no
// elements, and an associative dimension, or a dynamic or queue dimension
// after the first, always gives an empty range (37.22 detail 1). For a packed
// variable the ranges are its packed ranges from the leftmost, without the
// width of a packed struct or union element or the base range of an enum
// element (detail 4). vpiLeftRange and vpiRightRange give the bounds of the
// leftmost unpacked dimension of an unpacked array (lu: 1 and 2, not the
// packed 3:0) and of the leftmost packed dimension of a packed one, and NULL
// for an array with no members or with an empty leftmost range (detail 6).
// §37.25: vpiArrayType of an array typespec gives the kind of its dimension,
// and its ranges come from the leftmost with an empty range for every dynamic,
// queue or associative dimension (details 9 and 10, 37.22), even when the
// variable has elements; a logic or bit typespec gives its packed ranges from
// the leftmost (detail 10). At 1, da has 3 elements, qa 2, aa 2 and each
// element of mx and mq some; de and qe are empty.

typedef enum logic [1:0] {E0, E1, E2} test_vpi_array_var_ranges_kinds_e;
typedef struct packed { logic [3:0] hi, lo; } test_vpi_array_var_ranges_kinds_s;
typedef union packed { logic [5:0] w; bit [5:0] b; } test_vpi_array_var_ranges_kinds_u;

module test_vpi_array_var_ranges_kinds;
  int sa [2:5][0:1];
  int da [];
  int de [];
  int qa [$];
  int qe [$];
  int aa [string];
  int mx [1:0][];
  int mq [0:1][$];
  int ma [0:1][int];
  logic [3:0] lu [1:2];
  logic [7:0][3:0] pv;
  bit [2:1][0:3] bv;
  test_vpi_array_var_ranges_kinds_s [1:0] ps;
  test_vpi_array_var_ranges_kinds_u [0:2] pu;
  test_vpi_array_var_ranges_kinds_e [2:0] pe;

  initial begin
    da = new[3];
    qa.push_back(5);
    qa.push_back(6);
    aa["x"] = 1;
    aa["y"] = 2;
    mx[0] = new[2];
    mx[1] = new[4];
    mq[0].push_back(1);
    ma[1][7] = 3;
    #1 $vt_ranges;
  end
endmodule
