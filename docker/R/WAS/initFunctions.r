# The MIT License (MIT)
# Copyright (c) 2017 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# load the required r files
loadSource <- function() {
	source("/data/scripts/WAS/loadData.r")
	source("/data/scripts/WAS/reassignValue.r")
	source("/data/scripts/WAS/validatePhenotypeInput.r")
	source("/data/scripts/WAS/validateTraitInput.r")
	source("/data/scripts/WAS/testNumExamples.r")
	source("/data/scripts/WAS/binaryLogisticRegression.r")
	source("/data/scripts/WAS/equalSizedBins.r")
	source("/data/scripts/WAS/fixOddFieldsToCatMul.r")
	source("/data/scripts/WAS/replaceMissingCodes.r")
	source("/data/scripts/WAS/replaceNaN.r")
	source("/data/scripts/WAS/testAssociations.r")
	source("/data/scripts/WAS/testCatMultiple.r")
	source("/data/scripts/WAS/testCatSingle.r")
	source("/data/scripts/WAS/testContinuous.r")
	source("/data/scripts/WAS/testInteger.r")
	source("/data/scripts/WAS/testCategoricalOrdered.r")
	source("/data/scripts/WAS/testCategoricalUnordered.r")
	source("/data/scripts/WAS/saveCounts.r")
	source("/data/scripts/WAS/incrementCounter.r")
	source("/data/scripts/WAS/getIsCatMultExposure.r")
	source("/data/scripts/WAS/getIsExposure.r")
	source("/data/scripts/WAS/addToCounts.r")
	source("/data/scripts/WAS/getNumValuesCatMultExposure.r")	
	source("/data/scripts/WAS/storeNewVar.r")
	source("/data/scripts/WAS/loadPhenotypes.r")
	source("/data/scripts/WAS/loadTraitOfInterest.r")	
	source("/data/scripts/WAS/loadConfounders.r")
	source("/data/scripts/WAS/makeTestDataFrame.r")
	source("/data/scripts/WAS/loadIndicatorFields.r")
}

# init the counters used to determine how many variables took each path in the variable processing flow.
initCounters <- function() {
	counters = data.frame(name=character(),countValue=integer(), stringsAsFactors=FALSE)
	return(counters);
}

# create new results files and headers
initResultsFiles <- function() {

	## only linear and continuous fields can create linear results
	file.create(paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-linear-",opt$varTypeArg,".txt",sep=""), append="TRUE");

	## all field types can create binary results	
	file.create(paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-logistic-binary-",opt$varTypeArg,".txt",sep=""), append="TRUE");

	## only categorical multiple cannot generate order categorical results
	file.create(paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-ordered-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
	
	## only categorical single fields can generate unordered categorical results
	file.create(paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""));
	write("varName,varType,n,beta,lower,upper,pvalue", file=paste(opt$resDir,"results-multinomial-logistic-",opt$varTypeArg,".txt",sep=""), append="TRUE");
	
}

# load the variable information and data code information files
initVariableLists <- function() {

	phenoInfo=read.table(opt$variablelistfile,sep="\t",header=1,comment.char="",quote="");

	dataCodeInfo=read.table(opt$datacodingfile,sep=",", header=1);

	vars=list(phenoInfo=phenoInfo, dataCodeInfo=dataCodeInfo);
	return(vars);
}











