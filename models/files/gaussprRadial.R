modelInfo <- list(label = "Gaussian Process with Radial Basis Function Kernel",
                  library = "kernlab",
                  type = c("Regression", "Classification"),
                  parameters = data.frame(parameter = c('sigma'),
                                          class = c("numeric"),
                                          label = c('Sigma')),
                  grid = function(x, y, len = NULL, search = "grid") {
                    sigmas <- kernlab::sigest(as.matrix(x), na.action = na.omit, scaled = TRUE)
                    if(search == "grid") {
                      out <- expand.grid(sigma = mean(as.vector(sigmas[-2])))
                    } else {
                      rng <- extendrange(log(sigmas), f = .75)
                      out <- data.frame(sigma = exp(runif(len, min = rng[1], max = rng[2])))
                    }
                    out
                  },
                  loop = NULL,
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) {
                    kernlab::gausspr(x = as.matrix(x), y = y,
                                     kernel = kernlab::rbfdot,
                                     kpar = list(sigma = param$sigma), ...)
                    },
                  predict = function(modelFit, newdata, submodels = NULL) {  
                    out <- predict(modelFit, as.matrix(newdata))
                    if(is.matrix(out)) out <- out[,1]
                    out
                  },
                  prob = function(modelFit, newdata, submodels = NULL) {
                    predict(modelFit, as.matrix(newdata), type = "probabilities")
                  },
                  predictors = function(x, ...) {
                    if(hasTerms(x) & !is.null(x@terms))
                    {
                      out <- predictors.terms(x@terms)
                    } else {
                      out <- colnames(attr(x, "xmatrix"))
                    }
                    if(is.null(out)) out <- names(attr(x, "scaling")$x.scale$`scaled:center`)
                    if(is.null(out)) out <-NA
                    out
                  },
                  tags = c("Kernel Method", "Gaussian Process", "Radial Basis Function"),
                  levels = function(x) lev(x),
                  sort = function(x) x)
