import open from io
import execute, tmpname from os
import concat from table
import sum from require"lib.xxh64"

pwd = io.popen"pwd"\read"*a"\sub 1, -2

TEXDOC = [[
\documentclass[fontsize=<<<FONTSIZE>>>]{scrartcl}
<<<PACKAGES>>>
\grechangestaffsize{<<<SIZE>>>}
\gresetinitiallines{<<<INITIALLINES>>>}
\pagestyle{empty}
\begin{document}
<<<TEX>>>
<<<GABC>>>
\end{document}]]

contains = (item) =>
  if type(item) == "table"
    for i in *item
      return i if contains @, i
  for v in *@
    return v if v == item

exists = => if f = open @ then return f\close!

compile_gabc = =>
  @fontsize or= 12
  @size or= 15
  jobname = ".tmp/#{sum concat [k..v for k, v in pairs @]}"
  pdf = "#{jobname}.pdf"
  img = "#{jobname}.avif"
  execute"mkdir .tmp 2>&1 >/dev/null"
  packages = {"ebgaramond", "gregoriotex"}
  gabc = "\\gabcsnippet{#{@text}}"
  if @color
    packages[#packages+1] = "xcolor"
    gabc = "\\color{#{@color}}#{gabc}"
  if @noclef
    @tex or= ""
    @tex ..= "\\gresetclef{invisible}"
  if @nolines
    @tex or= ""
    @tex ..= "\\gresetlines{invisible}"
  if not exists pdf
    texdoc = TEXDOC\gsub "<<<PACKAGES>>>", concat [ "\\usepackage{#{p}}" for p in *packages ]
    texdoc = texdoc\gsub("<<<#{k\upper!}>>>", v) for k, v in pairs @
    texdoc = texdoc\gsub(
      "<<<GABC>>>", gabc
    )\gsub(
      "[^\n]*<<<[^>]*>>>[^\n]*", ""
    )\gsub "\n", " "
    command = "openout_any=a lualatex --interaction=batchmode --jobname #{jobname} <<EOF\n#{texdoc}\nEOF"
    execute command
    execute"pdfcrop #{pdf}"
    execute"convert -density 300 #{jobname}-crop.pdf #{img}"
  img

compile_neume = =>
  @font or= "Caeciliae-Staffless.ttf"
  @fontsize or= 36
  jobname = ".tmp/#{sum concat [k..v for k, v in pairs @]}"
  pdf = "#{jobname}.pdf"
  img = "#{jobname}.avif"
  execute"mkdir .tmp 2>&1 >/dev/null"
  packages = {"fontspec"}
  gabc = "\\fontspec{#{@font}} #{@text}"
  if @color
    packages[#packages+1] = "xcolor"
    gabc = "\\color{#{@color}}#{gabc}"
  if not exists pdf
    texdoc = TEXDOC\gsub "<<<PACKAGES>>>", concat [ "\\usepackage{#{p}}" for p in *packages ]
    texdoc = texdoc\gsub("<<<#{k\upper!}>>>", v) for k, v in pairs @
    texdoc = texdoc\gsub(
      "<<<GABC>>>", gabc
    )\gsub(
      "[^\n]*<<<[^>]*>>>[^\n]*", ""
    )\gsub "\n", " "
    command = "openout_any=a lualatex --interaction=batchmode --jobname #{jobname} <<EOF\n#{texdoc}\nEOF"
    execute command
    execute"pdfcrop #{pdf}"
    execute"convert -density 300 #{jobname}-crop.pdf #{img}"
  img

Code = =>
  local img
  if contains @attr.classes, "gabc"
    if contains @attr.classes, "file"
      if f = open "gabc/#{@text}.gabc"
        @text = f\read"*a"
        f\close!
    attr = @attr.attributes
    attr.text = @text
    img = compile_gabc attr
  if t = contains @attr.classes, {"neume", "sgall"}
    attr = @attr.attributes
    attr.text = @text
    if t == "sgall"
      attr.font or= "Carolineale-SanktGallen"
      attr.fontsize or= 16
      attr.color or= "red"
    else
      attr.font or= "Caeciliae-Staffless.ttf"
      attr.fontsize or= 36
    img = compile_neume attr
  pandoc.Image("", img) if img

CodeBlock = Code

{
  {:Code}
  {:CodeBlock}
  {:Image}
}