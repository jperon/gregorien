import open from io
import execute, tmpname from os
import sum from require"lib.xxh64"

TEXDOC = [[\documentclass{scrartcl}\usepackage{ebgaramond}\usepackage{gregoriotex}\grechangestaffsize{13}\pagestyle{empty}\begin{document}\gabcsnippet{<<<GABC>>>}\end{document}]]

contains = (item) =>
  for v in *@
    return true if v == item

exists = => if f = open @ then return f\close!

compile_gabc = =>
  jobname = ".tmp/#{sum(@)}"
  pdf = "#{jobname}.pdf"
  svg = "#{jobname}.avif"
  execute"mkdir .tmp"
  if not exists pdf
    command = "openout_any=a lualatex --jobname #{jobname} <<EOF\n#{TEXDOC\gsub "<<<GABC>>>", @}'\nEOF"
    print command
    execute command
    execute"pdfcrop #{pdf}"
    execute"convert -density 300 #{jobname}-crop.pdf #{svg}"
  return svg
  
Code = =>
  if contains @attr.classes, "gabc"
    pandoc.Image "", compile_gabc @text

CodeBlock = =>
  if contains @attr.classes, "gabc"
    pandoc.Image "", compile_gabc @text

{
  {:Code}
  {:CodeBlock}
  {:Image}
}