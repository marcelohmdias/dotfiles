---@diagnostic disable: undefined-global
-- Runner script for headless test execution.
-- Outputs JSON results to stdout for parsing by ui.lua.
-- Usage: nvim --headless -u tests/minimal_init.lua -l tests/run.lua

require('mini.test').setup()

local cases = MiniTest.collect()
local results = {}

MiniTest.execute(cases, {
  reporter = {
    update = function(case_num)
      local case = cases[case_num]
      if not case or not case.exec then return end

      local state = case.exec.state
      if state ~= 'Pass' and state ~= 'Fail' then return end

      local entry = { desc = case.desc, state = state }
      if state == 'Fail' and case.exec.fails then
        local msgs = {}
        for _, f in ipairs(case.exec.fails) do
          msgs[#msgs + 1] = tostring(f)
        end
        entry.error = table.concat(msgs, '\n')
      end
      results[#results + 1] = entry
    end,
    finish = function()
      io.stdout:write(vim.json.encode(results) .. '\n')
    end,
  },
})

vim.cmd('qa!')
