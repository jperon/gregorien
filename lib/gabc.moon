import open from io
import execute, tmpname from os
import concat, sort from table
import sum from require"lib.xxh64"

pwd = io.popen"pwd"\read"*a"\sub 1, -2

execute"mkdir .tmp 2>&1 >/dev/null"

TEXDOC = [[
\documentclass[fontsize=<<<FONTSIZE>>>]{scrartcl}
<<<PACKAGES>>>
\grechangestaffsize{<<<SIZE>>>}
\gresetinitiallines{<<<INITIALLINES>>>}
\pagestyle{empty}
\begin{document}
<<<TEX>>>
−−−−GABC−−−−
\end{document}]]

contains = (item) =>
  if type(item) == "table"
    for i in *item
      return i if contains @, i
  for v in *@
    return v if v == item

exists = => if f = open @ then return f\close!

opairs = =>
  _k = [ k for k in pairs @ ]
  sort _k
  i = 0
  ->
    i += 1
    k = _k[i]
    k, @[k]

compile_gabc = =>
  @fontsize or= 12
  @size or= 15
  jobname = ".tmp/#{sum concat [k..v for k, v in opairs @]}"
  gabc = "#{jobname}.gabc"
  pdf = "#{jobname}.pdf"
  img = "#{jobname}.avif"
  packages = {
    {"ebgaramond"},
    {"gregoriotex", "autocompile"}
  }
  gabccode = "name:#{jobname};\n%%\n#{@text}"
  if @color
    packages[#packages+1] = "xcolor"
    gabccode = "\\color{#{@color}}#{gabccode}"
  if @noclef
    @tex or= ""
    @tex ..= "\\gresetclef{invisible}"
  if @nolines
    @tex or= ""
    @tex ..= "\\gresetlines{invisible}"
  if @nonotes
    @tex or= ""
    @tex ..= "\\gresetnotes{invisible}"
  if gabccode\match "|"
    gabccode = "nabc-lines:1;\n#{gabccode}"
    @tex or= ""
    @tex ..= "\\gresetnabc{1}{visible}\\gresetnabcfont{gresgmodern}{15}"
  if not exists pdf
    f = open gabc, "w"
    f\write gabccode
    f\close! 
    texdoc = TEXDOC\gsub "<<<PACKAGES>>>", concat [ "\\usepackage#{p[2] and '['..p[2]..']' or ''}{#{p[1]}}" for p in *packages ]
    texdoc = texdoc\gsub("<<<#{k\upper!}>>>", v) for k, v in pairs @
    if @width
      texdoc = texdoc\gsub "−−−−GABC−−−−", "\\parbox{#{@width}}{−−−−GABC−−−−}"
    texdoc = texdoc\gsub(
      "[^\n]*<<<[^>]*>>>[^\n]*\n?", ""
    )\gsub(
      "−−−−GABC−−−−", "\\gregorioscore{#{gabc}}"
    )\gsub("\n", "")
    command = "openout_any=a lualatex --interaction=batchmode --jobname #{jobname} <<EOF\n#{texdoc}\nEOF"
    print command
    execute command
    execute"pdfcrop #{pdf}"
    execute"convert -density 300 #{jobname}-crop.pdf #{img}"
  img

compile_neume = =>
  @font or= "Caeciliae-Staffless.ttf"
  @fontsize or= 36
  jobname = ".tmp/#{sum concat [k..v for k, v in opairs @]}"
  pdf = "#{jobname}.pdf"
  img = "#{jobname}.avif"
  packages = {"fontspec"}
  gabc = "\\fontspec{#{@font}} #{@text}"
  if @color
    packages[#packages+1] = "xcolor"
    gabc = "\\color{#{@color}}#{gabc}"
  if not exists pdf
    texdoc = TEXDOC\gsub "<<<PACKAGES>>>", concat [ "\\usepackage{#{p}}" for p in *packages ]
    texdoc = texdoc\gsub("<<<#{k\upper!}>>>", v) for k, v in pairs @
    texdoc = texdoc\gsub(
      "−−−−GABC−−−−", gabc
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
  if t = contains @attr.classes, {"gabc", "ngabc"}
    attr = {k, v for k, v in pairs @attr.attributes}
    if t == "ngabc"
      attr.nolines = ""
      attr.noclef = ""
    if contains @attr.classes, "file"
      if f = open "gabc/#{@text}.gabc"
        @text = f\read"*a"\gsub ".*%%\n", ""
        f\close!
    attr.text = @text
    img = compile_gabc attr
  if t = contains @attr.classes, {"neume", "sgall"}
    attr = @attr.attributes
    attr.text = @text
    if t == "sgall"
      attr.font or= "gresgmodern.ttf"
      attr.fontsize or= 12
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