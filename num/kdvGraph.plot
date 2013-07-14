# !/usr/bin/gnuplot
# @descrição: "Script para gerar animação do gráfico de propagação de ondas 
# do tipo kdv"
# @autor: Rafael Lima
# @versão: 0.3

set terminal pngcairo size 350,200 enhanced font 'Verdana,10;
# Definição de cores
set style line 1 lc rgb '#0060ad' lt 1 lw 1.5 # --- blue
# Borda
set style line 101 lc rgb '#808080' lt 1
set border 0 back ls 101
set tics out nomirror scale 0
set format ''
# Grade
set style line 102 lc rgb '#ddccdd' lt 1 lw 0.5 # --- red
set grid xtics ytics back ls 102

# Definições da região do gráfico
#unset key
set xtics 0.01;
set ytics 0.15;
#set xrange [-30:30];
#set yrange [-0.5:1.5];
#set lmargin screen 0.01
#set rmargin screen 0.98

#a=0;
#DT = 0.01;
#N = 100;

# Plotando
#do for[a = 0:11]{
#  outfile = sprintf('./image/ani1-%03.0f.png',a);
#  set output outfile;
#  datafile = sprintf('./data/ut%.0f.dat',a);
#  tgraph = sprintf('t = %2.3f',a*0.01);
#  plot datafile u 2:3 ls 1 t tgraph;
#}

# Gerando gif
# system "convert -delay 20 -loop 0 image/ani1-* vani1.gif";
# Removendo as imagens auxiliares:
# system "rm image/ani1-*";


set xrange [-30:30]
set yrange [-0.5:1.5]
do for[a = 0:11]{
outfile = sprintf('./image/ani1-%03.0f.png',a);
set output outfile;
datafile = sprintf('./data/ut%.0f.dat',a);
tgraph = sprintf('t = %2.3f',a*0.01);
plot datafile u 2:3 ls 1 t tgraph;}