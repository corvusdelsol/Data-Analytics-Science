#Metropolis Sampling Rcode###########################################################
#########################1st Metropolis Sampler#################################
x <- c(-1,0,1,10)
x.bar <- mean(x)
K <- 10000
thetas <- array(dim=c(K,1))
thetas[1,] <- x.bar
## run metropolis
for(k in 1:(K-1)){
  
  ## generate proposal
  theta.prop <- rnorm(1,thetas[k,],1)
  
  ## acceptance ratio
  r <- dnorm(theta.prop,2,sqrt(1/5)) / dnorm(thetas[k,],2,sqrt(1/5))
  
  ## accept or reject
  u <- runif(1)
  thetas[k+1,] <- ( if(r>u) theta.prop else thetas[k,] )
  
}

## trace plot
matplot(thetas[1:10000,],type='l')
## proportion accepted
mean(thetas[1:(K-1),]!=thetas[2:K,])
## effective sample size # requires the package "coda"
coda::effectiveSize(thetas)
mean(thetas)
sd(thetas)
var(thetas)
#########################2nd Metropolis Sampler#################################
thetas.2 <- array(dim=c(K,1))
thetas.2[1,] <- x.bar
## run metropolis
for(k in 1:(K-1)){
  
  ## generate proposal
  theta.prop <- rcauchy(1,location=thetas.2[k,],scale=1)
  
  ## acceptance ratio
  r <- (dnorm(theta.prop,0,1)*dcauchy(theta.prop,location=thetas.2[k,],scale=1)) / 
    (dnorm(thetas.2[k,],0,1)*dcauchy(thetas.2[k],location=thetas.2[k,],scale=1))
  
  ## accept or reject
  u <- runif(1)
  thetas.2[k+1,] <- ( if(r>u) theta.prop else thetas.2[k,] )
  
}

## trace plot
matplot(thetas.2[1:10000,],type='l')
## proportion accepted
mean(thetas.2[1:(K-1),]!=thetas.2[2:K,])
## effective sample size # requires the package "coda"
coda::effectiveSize(thetas.2)
mean(thetas.2)
sd(thetas.2)
var(thetas.2)
plot(density(rnorm(K,2,sqrt(1/5))),
     main='Exact and Metropolis-sampled Posterior Densities',xlab='Theta',
     xlim=c(-4,4),ylim=c(0,1))
lines(density(thetas[,1]),col=2)
lines(density(thetas.2[,1]),col=3)
abline(v=x.bar,col='dodgerblue')
legend(-4,1,legend=c('exact','normal proposal','cauchy proposal','sample mean'),
       col=c(1,2,3,'dodgerblue'),lty=1,bty='n')
#housekeep
rm(thetas,thetas.2,k,K,r,theta.prop,u,x,x.bar)
dev.off()

