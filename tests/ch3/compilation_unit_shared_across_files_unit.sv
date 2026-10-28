/*
 * Compilation-unit declarations shared by compilation_unit_shared_across_files.
 * This file is not a test; it is named by that test's :files:.
 */
int unit_shared = 40;

function automatic int unit_add(int v);
  return v + 2;
endfunction
