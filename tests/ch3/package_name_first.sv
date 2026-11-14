// A source of test_illegal_package_name_reused_in_other_file, compiled
// before it (:files:). It defines the package pn_file_pkg, whose name the
// test file uses again for another package.
package pn_file_pkg;
  parameter int VALUE = 1;
endpackage
