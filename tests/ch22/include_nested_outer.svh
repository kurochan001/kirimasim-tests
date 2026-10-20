// Included by test_include_nested (:files:); it includes another file.
`include "include_nested_inner.svh"
localparam int INCLUDE_NESTED_OUTER = INCLUDE_NESTED_INNER * 2;
