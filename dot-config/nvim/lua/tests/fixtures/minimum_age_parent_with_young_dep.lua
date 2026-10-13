return {
  src = _G._fixture_src_parent,
  name = 'parent-plugin',
  dependencies = { { src = _G._fixture_src, name = 'young-dep' } },
  lazy = false,
}
