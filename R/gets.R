#' @title Search the DNB catalogue - simple search
#' @description \code{dnb_search} exposes a search in the DNB catalogue. 
#' @param title the title (including subtitle, short title, volume title, etc.); optional single string value or vector of strings.
#' @param author the author(s); optional single string value or vector of strings.
#' @param year the year of publishing; optional single integer value or vector of integers.
#' @param publisher the publisher (publisher name and/or location); optional single string value or vector of strings.
#' @param keyword one or a set of keywords describing the work (subjects, persons, locations, organisations, etc.); optional single string value or vector of strings.
#' @param type the type of publication (optional), one or a vector of \code{articles}, \code{manuscript}, \code{biographicaldoc}, \code{letters}, \code{bequest}, \code{collections}, \code{books}, \code{brailles}, \code{maps}, \code{discs}, \code{dissertations}, \code{online}, \code{films}, \code{microfiches}, \code{multimedia}, \code{music}, \code{scores}, \code{serials}, \code{persons}, \code{subjects}, \code{corperations}, \code{works}, \code{events}, \code{geographics}.
#' @param language the language of the work by ISO 639-2/B code (\url{https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes}); single string value or vector of strings.
#' @param limit number and (optional) starting point of results returned; single integer value (number of results), vector of two integer values (number of results and first result, >=1) or \code{"all"} for a complete list of results.
#' @param clean if \code{TRUE} (the default), the results are cleaned (see \code{\link{dnb_advanced}} for details).
#' @param print if \code{TRUE} the search results are printed (default is \code{FALSE}).
#' @return A list of results with metadata.
#' @details to do
#' @export
#' @examples
#' \dontrun{
#' # title search
#' single.title <- dnb_search(title="katze")
#' multi.title <- dnb_search(title=c("katze", "kater", "+maus", "-hund"))
#'
#' # author search
#' single.author <- dnb_search(author="kern")
#' author.or.author <- dnb_search(author=c("kern", "locke"))
#' author.and.author <- dnb_search(author=c("kern", "+locke"))
#' author.not.author <- dnb_search(author=c("kern", "-locke"))
#'
#' # publication year 
#' single.year <- dnb_search(title="katze", year=2015)
#' sequence.of.years <- dnb_search(title="katze", year=2010:2015)
#' set.of.years <- dnb_search(title="katze", year=c(2010:2013, 2015))
#'
#' # publisher search
#' single.publisher <- dnb_search(title="katze", publisher="kiepenheuer")
#' set.of.publishers <- dnb_search(title="katze", publisher=c("kiepenheuer", "piper"))
#'
#' # keyword search
#' single.keyword <- dnb_search(author="kern")
#' keyword.or.keyword <- dnb_search(keyword=c("katze", "hund"))
#' keyword.and.keyword <- dnb_search(keyword=c("katze", "+hund"))
#' keyword.not.keyword <- dnb_search(keyword=c("katze", "-hund"))
#'
#' # type search
#' single.type <- dnb_search(title="katze", type="books")
#' set.of.types <- dnb_search(title="katze", type=c("books", "articles", "online"))
#'
#' # language search
#' single.language <- dnb_search(title="cat", language="eng")
#' set.of.languages <- dnb_search(title=c("cat", "katze"), language=c("eng", "ger"))
#'
#' # change limit of results
#' first.result <- dnb_search(title="katze", limit=1)
#' 5.results.starting.with.the.21st <- dnb_search(title="katze", limit=c(5, 21))
#' all.results <- dnb_search(title="katze", limit="all")
#' }
dnb_search <- function(title, author, year, publisher, keyword, type, language, limit=10, clean=TRUE, print=FALSE) {		
	# init query
	query <- ""
	
	# prepare title
	if(!missing(title)) {
		title <- paste0("tit=", title, collapse=" OR ")
		title <- gsub("OR tit=+", "AND tit=", title, fixed=TRUE)
		title <- gsub("OR tit=-", "NOT tit=", title, fixed=TRUE)
		if(substr(title, 1, 5)=="tit=+" || substr(title, 1, 5)=="tit=-") stop("Do not use '+' or '-' in case of a single search string or with first string of a vector")
		query <- paste0("(", title, ")")
	}
	
	# prepare author
	if(!missing(author)) {
		author <- paste0("atr=", author, collapse=" OR ")
		author <- gsub("OR atr=+", "AND atr=", author, fixed=TRUE)
		author <- gsub("OR atr=-", "NOT atr=", author, fixed=TRUE)
		if(substr(author, 1, 5)=="atr=+" || substr(author, 1, 5)=="atr=-") stop("Do not use '+' or '-' in case of a single search string or with first string of a vector")
		if(query=="") query <- paste0("(", author, ")")
		else query <- paste(query, paste0("(", author, ")"), sep=" AND ") 
	}
	
	# prepare year
	if(!missing(year)) {
		if(length(year)>1 && (tail(year, 1)-year[1]+1)==length(year)) {
			year <- paste0("jhr>=", year[1], " AND jhr<=", tail(year, 1))
		} else {
			year <- paste0("jhr=", year, collapse=" OR ")
		}
		if(query=="") query <- paste0("(", year, ")")
		else query <- paste(query, paste0("(", year, ")"), sep=" AND ")
	}
	
	# prepare publisher
	if(!missing(publisher)) {
		publisher <- paste0("vlg=", publisher, collapse=" OR ")
		publisher <- gsub("OR vlg=+", "AND vlg=", publisher, fixed=TRUE)
		publisher <- gsub("OR vlg=-", "NOT vlg=", publisher, fixed=TRUE)
		if(substr(publisher, 1, 5)=="vlg=+" || substr(publisher, 1, 5)=="vlg=-") stop("Do not use '+' or '-' in case of a single search string or with first string of a vector")
		if(query=="") query <- paste0("(", publisher, ")")
		else query <- paste(query, paste0("(", publisher, ")"), sep=" AND ") 
	}
	
	# prepare keyword
	if(!missing(keyword)) {
		keyword <- paste0("sw=", keyword, collapse=" OR ")
		keyword <- gsub("OR sw=+", "AND sw=", keyword, fixed=TRUE)
		keyword <- gsub("OR sw=-", "NOT sw=", keyword, fixed=TRUE)
		if(substr(keyword, 1, 5)=="sw=+" || substr(keyword, 1, 5)=="sw=-") stop("Do not use '+' or '-' in case of a single search string or with first string of a vector")
		if(query=="") query <- paste0("(", keyword, ")")
		else query <- paste(query, paste0("(", keyword, ")"), sep=" AND ")
	}
	
	# prepare type
	if(!missing(type)) {
		avail.types <- c("articles", "manuscript", "biographicaldoc", "letters", "bequest", "collections", "books", "brailles", "maps", "discs", "dissertations", "online", "films", "microfiches", "multimedia", "music", "scores", "serials", "persons", "subjects", "corperations", "works", "events", "geographics")
		type <- avail.types[pmatch(type, avail.types)]		
		type <- paste0("mat=", type, collapse=" OR ")
		if(query=="") query <- paste0("(", type, ")")
		else query <- paste(query, paste0("(", type, ")"), sep=" AND ")
	}
	
	# prepare language
	if(!missing(language)) {
		language <- paste0("spr=", language, collapse=" OR ")
		if(query=="") query <- paste0("(", language, ")")
		else query <- paste(query, paste0("(", language, ")"), sep=" AND ")
	}
	
	# call dnb_advanced
	df <- dnb_advanced(query=query, limit=limit, clean=clean, print=FALSE)
  
  # return
  if(print) print(df)
  invisible(df)
}


#' @title Search the DNB catalogue - advanced search
#' @description \code{dnb_search} exposes a search in the DNB catalogue, expressed in the DNB query language. 
#' @param query the search query, expressed in the DNB query language; single string value. 
#' @param limit number and (optional) starting point of results returned; single integer value (number of results), vector of two integer values (number of results and first result, >=1) or \code{"all"} for a complete list of results.
#' @param clean if \code{TRUE} (the default), the results are cleaned (see below for details).
#' @param print if \code{TRUE} the search results are printed (default is \code{FALSE}).
#' @return A \code{data.frame} of results with metadata.
#' @details \emph{Cleaning of results}
#'
#' To harmonise the results, some clutter is deleted and abbreviations frequently used in the dnb catalogue are replaced by full words. Here is a list of all replacements:
#' \tabular{lll}{
#' Variable \tab Searched \tab Replaced by \cr
#' complete dataset \tab \\u0098 \tab [deleted] \cr
#' complete dataset \tab \\u009c \tab [deleted] \cr
#' complete dataset \tab ,, \tab , \cr
#' complete dataset \tab .. \tab . \cr
#' complete dataset \tab ;; \tab ; \cr
#' year \tab [string] \tab [numeric] \cr
#' pages \tab  S. \tab [deleted] \cr
#' pages \tab  Seiten \tab [deleted] \cr
#' pages \tab [ \tab [deleted] \cr
#' pages \tab ] \tab [deleted] \cr
#' publisher \tab Verl. \tab Verlag \cr
#' publisher \tab verl. \tab verlag \cr
#' publisher \tab [ \tab [deleted] \cr
#' publisher \tab ] \tab [deleted] \cr
#' edition \tab Aufl. \tab Auflage \cr
#' edition \tab aufl. \tab auflage \cr
#' edition \tab Orig. \tab Original \cr
#' edition \tab Ed. \tab Edition \cr
#' edition \tab ed. \tab edition \cr
#' edition \tab Ausg. \tab Ausgabe \cr
#' edition \tab ausg. \tab ausgabe \cr
#' edition \tab Nachdr. \tab Nachdruck \cr
#' edition \tab Bibliogr. \tab Bibliografie \cr
#' edition \tab [ \tab [deleted] \cr
#' edition \tab ] \tab [deleted] \cr
#' edition \tab [x]., \tab [x]. \cr 
#' price \tab kart. \tab Kartoniert \cr
#' price \tab Gb. \tab Gebunden \cr
#' price \tab Spiralb. \tab Spiralbindung \cr
#' price \tab Pb. \tab Paperback
#' }
#' @export
#' @examples
#' \dontrun{
#' # german books titled with 'cat' (male or female), 
#' # excluding titles containing dogs, since the year 2001
#' cats <- dnb_advanced("(tit=katze OR tit=kater NOT tit=hund) AND jhr>2000 AND mat=books AND spr=ger")
#' }
dnb_advanced <- function(query, limit=10, clean=TRUE, print=FALSE) {		
	# prepare limit
	if(any(limit=="all")) {
		lim <- 100
		strt <- 1
	} else if(is.numeric(limit)) {
		if(length(limit)==1) {
			lim <- limit
			strt <- 1
		} else if(length(limit)==2) {
			lim <- limit[1]
			strt <- limit[2]
		} else stop("cannot read 'limit'")
	} else stop("cannot read 'limit'")
	
	# make request
  req <- dnb_get_url(path="sru/dnb", query=query, limit=lim, start=strt)
  raw <- dnb_parse(req)$searchRetrieveResponse
  
  # print number of records
	nrec <- as.numeric(raw[["numberOfRecords"]])
	if(nrec==0) {
		message("no records found")
		return(NULL)
	}
  
  # convert
  df <- dnb_to_df(raw, clean=clean)
  
  # loop request for more than 100 records
	nend <- NULL
	if(any(limit=="all") || lim>100) {
		if(any(limit=="all")) {
		  nend <- nrec
		} else {
			nend <- lim
			lim <- 100
		}
		strt <- as.numeric(raw[["nextRecordPosition"]])
		pb <- txtProgressBar(min=0, max=nend, style=3)
		repeat{
		  if(strt>nend) break
			req <- dnb_get_url(path="sru/dnb", query=query, limit=lim, start=strt)
			raw <- dnb_parse(req)$searchRetrieveResponse
			df_add <- dnb_to_df(raw, clean=clean)
			df <- rbind(df, df_add)
			strt <- as.numeric(raw[["nextRecordPosition"]])
			if(length(strt) == 0) break
			setTxtProgressBar(pb, strt)
		}
		setTxtProgressBar(pb, nend)
		close(pb)
		if(!any(limit=="all")) df <- df[1:nend,]
	}
	
	# print number of records
	if(any(limit=="all")) message(nrec, " records found")
	else {
		if(!is.null(nend)) message(nrec, " records found (request limited to ", nend, " records)")
		else message(nrec, " records found (request limited to ", lim, " records)")
	}
	# add metadata
	attr(df, "number_of_records") <- nrec
	attr(df, "query") <- unlist(raw[["echoedSearchRetrieveRequest"]][["query"]])
  
  # return
  if(print) print(df)
  invisible(df)
}
