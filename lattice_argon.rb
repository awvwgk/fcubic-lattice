#!/bin/ruby
# Copyright (C) 2017 awvwgk
#
# This program is free software: you can redistribute it and/or 
# modify it under the terms of the GNU General Public License as 
# published by the Free Software Foundation, either version 3 of 
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  
# If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------#
require 'optparse'
options = Hash.new
usage   = 'Benutzung: ruby lattice.rb density atoms output'
OptionParser.new do |option|
	option.banner = usage
	option.on_tail '-h','--help','Zeige diese  Nachricht' do
		puts option
		exit
	end
end.parse!
puts usage+"\n\n"
exit unless ARGV[1]
#-------------------------------------------------------------------#
#Umrechnungsfaktor für Dichte: 0.6022140857 u/Å³/(g/cm³)
class Float
	def convert_to_atomic
		self*0.6022140857
	end
end
#-------------------------------------------------------------------#
$density = ARGV[0].to_f.convert_to_atomic
$atoms   = ARGV[1].to_i
$output  = ARGV[2] ? ARGV[2] : "%s-%s" % ARGV
$argon   = 39.948 #u
printf "Platziere %i Argonatome in einem System mit %.5f u/Å³\n",
	$atoms,$density
#-------------------------------------------------------------------#
# Berechne die Gesamtmasse
mass     = $atoms*$argon
# Berechne das Volumen
volume   = mass/$density
printf "Das Gesamtvolumen des Systems liegt bei: %.5f Å³\n", 
	volume
# Berechne die Länge der kubischen Simulationsbox
length   = volume**(1/3.0) #Math::exp(Math::log(volume)/3.0)
printf "Die Kantenlänge der kubischen Box liegt bei: %.5f Å\n", 
	length
#-------------------------------------------------------------------#
# Berechne die Anzahl der Elementarzellen
number3D = ($atoms/4.0).round
# Berechne wie viele Elementarzellen entlang einer Achse sind
number1D = (number3D**(1/3.0)).round
printf "Es werden %i Elementarzellen platziert "+
	"%i entlang einer Achse\n", number3D, number1D
# Umformen voon number1D in einen verarbeitbaren Bereich
range    = 0..(number1D-1)
#-------------------------------------------------------------------#
# Gitterparameter berechnen
$a       = length/number1D
printf "Der Gitterparameter a ist: %.5f Å\n", $a
# initzialisieren der Koordinaten
$x,$y,$z = [],[],[]
#-------------------------------------------------------------------#
# Definition der flächenzentrieren Elementarzelle
def place_fcubic x,y,z
	# first
	$x << x
	$y << y
	$z << z
	# second
	$x << x+0.5*$a
	$y << y+0.5*$a
	$z << z
	# third
	$x << x+0.5*$a
	$y << y
	$z << z+0.5*$a
	# fourth
	$x << x
	$y << y+0.5*$a
	$z << z+0.5*$a
end
#-------------------------------------------------------------------#
# Platzieren aller Teilchen
=begin
for k in range do k.to_f
	for l in range do l.to_f
		for m in range do m.to_f
			place_fcubic $a*k,$a*l,$a*m
		end
	end
end
=end
range.each do |k| range.each do |l| range.each do |m|
	place_fcubic $a*k,$a*l,$a*m
end	end end
#-------------------------------------------------------------------#
# Ausgabe der Ergebnisse
xyz = File.open($output+'.xyz','w+')
printf "Erstelle %s.xyz\n", $output
xyz << "%i\n" % $x.length
xyz << "#Diese Datei wurde automatisch von lattice.rb erstellt\n"
for i in 0..($atoms-1) do
	xyz << "Ar\t%.10f\t%.10f\t%.10f\n" % [$x[i],$y[i],$z[i]]
end
xyz.close
printf "\nErfolgreich abgeschlossen!\n"
