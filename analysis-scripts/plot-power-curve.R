#' ---
#' title: Plot hypothetical power curves
#' author: Halle R. Dimsdale-Zucker
#' output:
#'  html_document:
#'    toc: true
#'    toc_depth: 5
#'    toc_float:
#'      collapsed: false
#'      smooth_scroll: false
#'    number_sections: true
#'    theme: spacelab
#' ---

#' # Load packages
library(pwr)

#' # Power analysis plotting
# code from: http://www.math.hawaii.edu/~grw/Classes/2013-2014/2014Spring/Math472_1/Power_Curve.html

#' ## Define function
# Power Analysis For
# A Large Sample Hypothesis Test
# Where The Test Statistic Has
# An Approximately Normal Distribution.

## We will perform a right-tailed hypothesis test.
##
## Significance level = alpha, 
## Sample size = n,
## Standard deviation = sigma.
##
## H0 : theta = theta0
## Ha : theta > theta0
## TS : hat{theta} = (sigma/sqrt(n))*Z + theta
## RR : ( theta0 + (sigma/sqrt(n))*z.alpha , infinity )

plot_power <- function(sigma_val, n_val, theta0_val, pow_val, alpha_val){
  beta <- 1 - pow_val   # The desired maximum Type II error probability.
  z.alpha <- qnorm(1-alpha_val)  # P( Z > z.alpha ) = alpha
  z.beta <- qnorm(1-beta)    # P( Z > z.beta ) = beta
  
  ## Plot The Power Function, gamma(theta), theta >= theta0
  
  ### Here is where we use that the Test Statistic
  ### hat{theta} is normal. Because of this, the
  ### power function gamma(theta) is a piece a normal
  ### Cumulative Distribution Function (CDF).
  ###
  ### If we assume that theta (not theta0) is the true mean of
  ### hat{theta}, then 
  ### 
  ### gamma(theta)
  ### = P( hat{theta} > theta0 + (sigma/sqrt(n))*z.alpha )
  ### = P( Z < sqrt(n)*(theta - theta0)/sigma - z.alpha )
  ### = Phi( sqrt(n)*(theta - theta0)/sigma - z.alpha ),
  ### 
  ### where Phi(z) = P( Z < z ) is the CDF for the standard
  ### normal random variable, Z.
  
  ### In R, the function pnorm(x) is the CDF of Z.
  ### The R function "curve(...)" will plot an expression
  ### of the variable "x" and that is why the formula uses
  ### "x" instead of "theta."
  
  ### This command plots the power function
  curve(pnorm(sqrt(n_val)*(x - theta0_val)/sigma_val - z.alpha), 
        from=theta0_val,                   # Left endpoint of the domain
        to=theta0_val+3.7*sigma_val/sqrt(n_val),   # Right endopint of the domain
        col="blue",                    # Try different colors
        main=sprintf("Power Function: n = %d", n_val),         # The Main Title
        xlab=expression(theta),        # Label the horizontal axis
        ylab=expression(gamma(theta)), # Label the vertical axis
        lwd=2,                         # Line width.
        add=NA)                      # TRUE or NA. NA erases old plots.
  
  ### This command adds a horizontal line to the graph.
  ### The line shows where the power equals the minimum
  ### desired value (one of the parameter at the top of
  ### the page).
  
  abline(h=pow_val,       # Plot a horizontal line
         col="red",   # Choose the color
         lwd=2)       # Choose the line width.
  
  ### This command adds a vertical line to the graph.
  ### The line shows the theta value where the graph
  ### of the power function first meets the minimum
  ### desired power. Any value of theta to the right
  ### of this line is detectible with a power greater
  ### than the minimum desired power.
  
  abline(v=theta0_val+(z.alpha+z.beta)*sigma_val/sqrt(n_val),  # Plot a vertical line
         col="green",                              # Choose the color
         lwd=2)                                    # Choose the line width
}

#' # Set various parameters and see how power changes
possible_n <- seq(from = 20, to = 50, by = 5)
# Cohen suggests 0.1 = small, 0.3 = medium, 0.5 = large effect sizes
possible_corvals <- c(0.1, 0.3, 0.5)

#' ## Use plot_power function (is this really meant for correlations?)
for(inum in 1:length(possible_n)){
  sigma <- 5        # The standard deviation.
  n <- possible_n[inum]           # The sample size.
  theta0 <- 0       # The value of theta0 in H0.
  pow <- 0.80       # The minimum desired power.
  alpha <- 0.01     # The significance level. Try 0.01, 0.05, 0.10
  
  plot_power(sigma, n, theta0, pow, alpha)
}

#' ## powerCurve 
# https://www.rdocumentation.org/packages/simr/versions/1.0.4/topics/powerCurve
# unclear which option for `test` is best suited for correlations

#' ## pwr Package
for(irval in 1:length(possible_corvals)){
  power_calc <- pwr::pwr.r.test(n = NULL, r = possible_corvals[irval], sig.level = 0.05, power = 0.8)
  print(power_calc)
}
