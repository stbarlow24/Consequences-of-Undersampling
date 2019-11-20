# Consequences-of-Undersampling
A function for generating a grid of points with different signal widths; 
resampling of the points at different frequencies results in a better understanding of how sampling frequency affects signal acquisition.

I created this function to help with a project which aimed to understand the consequences of converting electrochemical signals 
to fluorescence signals using a bipolar electrochemical cell.  Due to the difference in sampling rates available at current amplifiers and 
cameras, my coworkers observed a degradation of signal quality when converting current to light.  
This script quantifies this degradation by comparing the "true" signal width (full-width half-maximum, FWHM) with a resampled signal. 
Signals were resampled by applying a rolling average function to the original dataset with an interval, k, determined by the desired resampling rate.

We gained quantitative insight as a lab into this process thanks to this script.
