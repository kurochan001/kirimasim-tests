// A source of test_declaration_across_file_boundary, compiled before it
// (:files:). The module begun here is not complete at the end of this file:
// it ends in declaration_across_file_boundary_tail.sv.
module declaration_split_module(output int a, output int b);
  assign a = 7;
