// The package of tests/ch26/test_files_package_used_by_interface_file.sv,
// compiled first through :files:.
package files_layered_pkg;
  typedef logic [15:0] word_t;
  function automatic word_t swap(word_t w);
    return {w[7:0], w[15:8]};
  endfunction
endpackage
