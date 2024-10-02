# Set up terminal and output file
set terminal png font ",8"
set output 'histogram.png'

# Set up title and labels
set title 'Histogram'
set xlabel 'Bins'
set ylabel 'Count'

# Set style for the histogram
set style data histograms
set style fill solid 0.5
set boxwidth 100

# Set datafile separator to comma
set datafile separator ","

# Read data from CSV and get stats from the 4th column
stats 'output.csv' using 4 nooutput

# Check if there are valid data points


set xrange [-50:STATS_max+50]      # Set x-axis range based on the max value

# Set xtics to the appropriate bins
set xtics 100                   # Set xtics to every 100 units
set ytics 20
# Plot using the 4th column and smooth frequency
plot 'output.csv' using (floor($4/100)*100+50):(1) smooth freq with boxes title "Cantidad"
