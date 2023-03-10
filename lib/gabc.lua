local open
open = io.open
local execute, tmpname
do
  local _obj_0 = os
  execute, tmpname = _obj_0.execute, _obj_0.tmpname
end
local concat, sort
do
  local _obj_0 = table
  concat, sort = _obj_0.concat, _obj_0.sort
end
local sum
sum = require("lib.xxh64").sum
local pwd = io.popen("pwd"):read("*a"):sub(1, -2)
execute("mkdir .tmp 2>&1 >/dev/null")
local TEXDOC = [[\documentclass[fontsize=<<<FONTSIZE>>>]{scrartcl}
<<<PACKAGES>>>
\grechangestaffsize{<<<SIZE>>>}
\gresetinitiallines{<<<INITIALLINES>>>}
\pagestyle{empty}
\begin{document}
<<<TEX>>>
−−−−GABC−−−−
\end{document}]]
local contains
contains = function(self, item)
  if type(item) == "table" then
    for _index_0 = 1, #item do
      local i = item[_index_0]
      if contains(self, i) then
        return i
      end
    end
  end
  for _index_0 = 1, #self do
    local v = self[_index_0]
    if v == item then
      return v
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
local opairs
opairs = function(self)
  local _k
  do
    local _accum_0 = { }
    local _len_0 = 1
    for k in pairs(self) do
      _accum_0[_len_0] = k
      _len_0 = _len_0 + 1
    end
    _k = _accum_0
  end
  sort(_k)
  local i = 0
  return function()
    i = i + 1
    local k = _k[i]
    return k, self[k]
  end
end
local compile_gabc
compile_gabc = function(self)
  self.fontsize = self.fontsize or 12
  self.size = self.size or 15
  local jobname = ".tmp/" .. tostring(sum(concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for k, v in opairs(self) do
      _accum_0[_len_0] = k .. v
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)())))
  local gabc = tostring(jobname) .. ".gabc"
  local pdf = tostring(jobname) .. ".pdf"
  local img = tostring(jobname) .. ".avif"
  local packages = {
    {
      "ebgaramond"
    },
    {
      "gregoriotex",
      "autocompile"
    }
  }
  local gabccode = "name:" .. tostring(jobname) .. ";\n%%\n" .. tostring(self.text)
  if self.color then
    packages[#packages + 1] = "xcolor"
    gabccode = "\\color{" .. tostring(self.color) .. "}" .. tostring(gabccode)
  end
  if self.noclef then
    self.tex = self.tex or ""
    self.tex = self.tex .. "\\gresetclef{invisible}"
  end
  if self.nolines then
    self.tex = self.tex or ""
    self.tex = self.tex .. "\\gresetlines{invisible}"
  end
  if self.nonotes then
    self.tex = self.tex or ""
    self.tex = self.tex .. "\\gresetnotes{invisible}"
  end
  if gabccode:match("|") then
    gabccode = "nabc-lines:1;\n" .. tostring(gabccode)
    self.tex = self.tex or ""
    self.tex = self.tex .. "\\gresetnabc{1}{visible}\\gresetnabcfont{gresgmodern}{15}"
  end
  if not exists(pdf) then
    local f = open(gabc, "w")
    f:write(gabccode)
    f:close()
    local texdoc = TEXDOC:gsub("<<<PACKAGES>>>", concat((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #packages do
        local p = packages[_index_0]
        _accum_0[_len_0] = "\\usepackage" .. tostring(p[2] and '[' .. p[2] .. ']' or '') .. "{" .. tostring(p[1]) .. "}"
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()))
    for k, v in pairs(self) do
      texdoc = texdoc:gsub("<<<" .. tostring(k:upper()) .. ">>>", v)
    end
    if self.width then
      texdoc = texdoc:gsub("−−−−GABC−−−−", "\\parbox{" .. tostring(self.width) .. "}{−−−−GABC−−−−}")
    end
    texdoc = texdoc:gsub("[^\n]*<<<[^>]*>>>[^\n]*\n?", ""):gsub("−−−−GABC−−−−", "\\gregorioscore{" .. tostring(gabc) .. "}"):gsub("\n", "")
    local command = "openout_any=a lualatex --interaction=batchmode --jobname " .. tostring(jobname) .. " <<EOF\n" .. tostring(texdoc) .. "\nEOF"
    print(command)
    execute(command)
    execute("pdfcrop " .. tostring(pdf))
    execute("convert -density 300 " .. tostring(jobname) .. "-crop.pdf " .. tostring(img))
  end
  return img
end
local compile_neume
compile_neume = function(self)
  self.font = self.font or "Caeciliae-Staffless.ttf"
  self.fontsize = self.fontsize or 36
  local jobname = ".tmp/" .. tostring(sum(concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for k, v in opairs(self) do
      _accum_0[_len_0] = k .. v
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)())))
  local pdf = tostring(jobname) .. ".pdf"
  local img = tostring(jobname) .. ".avif"
  local packages = {
    "fontspec"
  }
  local gabc = "\\fontspec{" .. tostring(self.font) .. "} " .. tostring(self.text)
  if self.color then
    packages[#packages + 1] = "xcolor"
    gabc = "\\color{" .. tostring(self.color) .. "}" .. tostring(gabc)
  end
  if not exists(pdf) then
    local texdoc = TEXDOC:gsub("<<<PACKAGES>>>", concat((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #packages do
        local p = packages[_index_0]
        _accum_0[_len_0] = "\\usepackage{" .. tostring(p) .. "}"
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()))
    for k, v in pairs(self) do
      texdoc = texdoc:gsub("<<<" .. tostring(k:upper()) .. ">>>", v)
    end
    texdoc = texdoc:gsub("−−−−GABC−−−−", gabc):gsub("[^\n]*<<<[^>]*>>>[^\n]*", ""):gsub("\n", " ")
    local command = "openout_any=a lualatex --interaction=batchmode --jobname " .. tostring(jobname) .. " <<EOF\n" .. tostring(texdoc) .. "\nEOF"
    execute(command)
    execute("pdfcrop " .. tostring(pdf))
    execute("convert -density 300 " .. tostring(jobname) .. "-crop.pdf " .. tostring(img))
  end
  return img
end
local Code
Code = function(self)
  local img
  do
    local t = contains(self.attr.classes, {
      "gabc",
      "ngabc"
    })
    if t then
      local attr
      do
        local _tbl_0 = { }
        for k, v in pairs(self.attr.attributes) do
          _tbl_0[k] = v
        end
        attr = _tbl_0
      end
      if t == "ngabc" then
        attr.nolines = ""
        attr.noclef = ""
      end
      if contains(self.attr.classes, "file") then
        do
          local f = open("gabc/" .. tostring(self.text) .. ".gabc")
          if f then
            self.text = f:read("*a"):gsub(".*%%\n", "")
            f:close()
          end
        end
      end
      attr.text = self.text
      img = compile_gabc(attr)
    end
  end
  do
    local t = contains(self.attr.classes, {
      "neume",
      "sgall"
    })
    if t then
      local attr = self.attr.attributes
      attr.text = self.text
      if t == "sgall" then
        attr.font = attr.font or "gresgmodern.ttf"
        attr.fontsize = attr.fontsize or 12
        attr.color = attr.color or "red"
      else
        attr.font = attr.font or "Caeciliae-Staffless.ttf"
        attr.fontsize = attr.fontsize or 36
      end
      img = compile_neume(attr)
    end
  end
  if img then
    return pandoc.Image("", img)
  end
end
local CodeBlock = Code
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
