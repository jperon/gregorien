local open
open = io.open
local execute, tmpname
do
  local _obj_0 = os
  execute, tmpname = _obj_0.execute, _obj_0.tmpname
end
local sum
sum = require("lib.xxh64").sum
local TEXDOC = [[\documentclass{scrartcl}\usepackage{ebgaramond}\usepackage{gregoriotex}\grechangestaffsize{13}\pagestyle{empty}\begin{document}\gabcsnippet{<<<GABC>>>}\end{document}]]
local contains
contains = function(self, item)
  for _index_0 = 1, #self do
    local v = self[_index_0]
    if v == item then
      return true
    end
  end
end
local exists
exists = function(self)
  do
    local f = open(self)
    if f then
      return f:close()
    end
  end
end
local compile_gabc
compile_gabc = function(self)
  local jobname = ".tmp/" .. tostring(sum(self))
  local pdf = tostring(jobname) .. ".pdf"
  local svg = tostring(jobname) .. ".avif"
  execute("mkdir .tmp")
  if not exists(pdf) then
    local command = "openout_any=a lualatex --jobname " .. tostring(jobname) .. " <<EOF\n" .. tostring(TEXDOC:gsub("<<<GABC>>>", self)) .. "'\nEOF"
    print(command)
    execute(command)
    execute("pdfcrop " .. tostring(pdf))
    execute("convert -density 300 " .. tostring(jobname) .. "-crop.pdf " .. tostring(svg))
  end
  return svg
end
local Code
Code = function(self)
  if contains(self.attr.classes, "gabc") then
    return pandoc.Image("", compile_gabc(self.text))
  end
end
local CodeBlock
CodeBlock = function(self)
  if contains(self.attr.classes, "gabc") then
    return pandoc.Image("", compile_gabc(self.text))
  end
end
return {
  {
    Code = Code
  },
  {
    CodeBlock = CodeBlock
  },
  {
    Image = Image
  }
}
