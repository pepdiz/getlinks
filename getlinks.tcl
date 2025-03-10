
package require struct::stack 1.3
package require cmdline 
package require htmlparse 
package require http
package require tls

####
# extract to stdout all links (A tags) in html to stdout

#set NAME $argv0
## proc syntax {} {
 #    global NAME
 #    puts "$NAME \[options] html"
 #    puts ""
 #    puts "html is an uri if begins with http\[s]:// or a file path if not"
 #    puts ""
 #    puts "options accepted:"
 #    puts " -a	show links with absolute full path"	
 #    puts " -r 	regex to filter links to show"
 # }
 ##


# Description of the options
#    {f.arg   "" "input html file"}
#    {h.arg   "" "input html url"}
set OPTIONS {
    {a "show absolute path for links in url"}
    {r.arg ".*" "regex to filter links to show"}
}

# Part of the usage message; feel free to tweak
set USAGE "\[options] html\noptions:"

proc url-join {a b} {
	if {[startsWith $b "/"]} { set b [string range $b 1 end] }
	if {[string range $a end end] eq "/"} { set a [string range $a 1 end-1] }
	return "$a/$b"
}

proc getbase url {
	regsub -- {^(https?://[^\s/]+)/?.*$} $url "\\1" base
	set base
}

proc read-url url {

        if {[startsWith $url https]} {
		http::register https 443 tls::socket
	}
	
	# Perform the HTTP GET request
	set token [http::geturl $url]

	set status [http::status $token]
	# Get the HTML content
	set html_content [http::data $token]

	# Clean up the HTTP token
	http::cleanup $token

        if {[startsWith $url https]} {
		http::unregister https
	}
	
	if { $status eq "ok"} {
		# Print the HTML content
		set html_content	
	} else { 
		return ""
	}
}	

proc read-file FILE {
	set f [open $FILE r]
	set H [read $f]
	close $f
	set H	
}

proc isUrl {str} {
    set urlPattern {^https?://[^\s/$.?#].[^\s]*$}
    if {[regexp -nocase $urlPattern $str]} {
        return 1
    } else {
        return 0
    }
}

proc startsWith {str prefix} {
    return [string match -nocase "$prefix*" $str]
}

proc handleTag {tag attrs text behind} {
   global PATH FILTER
    if {$tag eq "a"} {
        if {$text != ""} { 
   	   regsub -- {.*href="([^ ]*)".*} $text "\\1" res
	   if {[regexp $FILTER $res]} {
		if {[startsWith $res http]} {
		   puts "$res"
		} else {
		   puts "[url-join $PATH $res]"
		}
	   }
	}
    }
}

# Process the options
try {
    array set opts [cmdline::getoptions argv $OPTIONS $USAGE]
} trap {CMDLINE USAGE} {msg} {
    puts stderr $msg
    exit 1
}

# should be only one argument resting
if {[llength $argv] != 1 } {
	#syntax
	exit
}


## default values
set PATH ""
set FILTER ".*"

if {[isUrl $argv]} {
	set H [read-url $argv]
	if {$opts(a)} { set PATH [getbase $argv] }
	puts "PATH=$PATH"
} else {
	set H [read-file $argv]
}

set FILTER $opts(r)


#now H have the html content

# Now, we can just use them; $::argv is everything not processed
#set filename $opts(f)
# ...


htmlparse::parse -cmd handleTag $H